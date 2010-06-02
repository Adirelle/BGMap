--[[
BGMap - Enhanced battleground map
Copyright 2010 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...

local function InBattlefield()
	return select(2, IsInInstance()) == "pvp" or GetMapInfo() == "LakeWintergrasp"
end

local function IsMapShown()
	return BattlefieldMinimap and BattlefieldMinimap:IsShown()
end

local function GetMode()
	return tonumber(GetCVar("showBattlefieldMinimap")) or 0
end

local LoadUI, Toggle, CanShow, UpdateVisibility

function LoadUI()
	LoadAddOn('Blizzard_BattlefieldMinimap')
	_G.BattlefieldMinimap_Toggle = Toggle
end

local override

function CanShow()
	if override == 'hide' then
		return false
	elseif override == 'show' then
		return true
	end
	local mode = GetMode()
	return mode == 2 or mode == 1 and InBattlefield()
end

function UpdateVisibility()
	if CanShow() then
		if not IsMapShown() then
			if not BattlefieldMinimap then
				LoadUI()
			end
			BattlefieldMinimap:Show()
		end
	elseif IsMapShown() then
		BattlefieldMinimap:Hide()
	end
end

function Toggle()
	if IsMapShown() then
		if override == 'show' then
			override = nil
		end
		if CanShow() then
			override = 'hide'
		end
	else
		if override == 'hide' then
			override = nil
		end
		if not CanShow() then
			override = 'show'
		end
	end
	UpdateVisibility()
end

-- Put our functions in place
_G.WorldStateFrame_CanShowBattlefieldMinimap = CanShow
_G.WorldStateFrame_ToggleBattlefieldMinimap = UpdateVisibility
_G.BattlefieldMinimap_Toggle = Toggle
_G.BattlefieldMinimap_LoadUI = LoadUI

local frame = CreateFrame("Frame")
frame:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)

frame:RegisterEvent('CVAR_UPDATE')
function frame:CVAR_UPDATE(_, name)
	if name == 'showBattlefieldMinimap' then
		override = nil
		UpdateVisibility()
	end
end

frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:RegisterEvent('ZONE_CHANGED')
frame:RegisterEvent('ZONE_CHANGED_NEW_AREA')
frame:RegisterEvent('WORLD_MAP_UPDATE')
frame.PLAYER_ENTERING_WORLD = UpdateVisibility
frame.ZONE_CHANGED = UpdateVisibility
frame.ZONE_CHANGED_NEW_AREA = UpdateVisibility
frame.WORLD_MAP_UPDATE = UpdateVisibility