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

function WorldStateFrame_ToggleBattlefieldMinimap()
	if not IsMapShown() and WorldStateFrame_CanShowBattlefieldMinimap() then
		if not BattlefieldMinimap then BattlefieldMinimap_LoadUI() end
		BattlefieldMinimap:Show()
	elseif IsMapShown() then
		BattlefieldMinimap:Hide()
	end
end

function WorldStateFrame_CanShowBattlefieldMinimap()
	local mode = GetMode()
	return mode == 2 or mode == 1 and InBattlefield()
end
