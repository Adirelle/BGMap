--[[
BGMap - Enhanced battleground map
Copyright 2010 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...

local enabled, narrowed

local function ReanchorMap()
	local x = BattlefieldMinimapTab:GetCenter() / BattlefieldMinimapTab:GetScale()
	local side = (x > UIParent:GetWidth() / 2) and "RIGHT" or "LEFT"
	local xOffset = narrowed and BattlefieldMinimap:GetWidth() / 4 or 0
	if side == "LEFT" then
		xOffset = - xOffset
	end
	local yOffset = enabled and 0 or -5
	BattlefieldMinimap:ClearAllPoints()
	BattlefieldMinimap:SetPoint("TOP"..side, BattlefieldMinimapTab, "BOTTOM"..side, xOffset, yOffset)
end

hooksecurefunc(BattlefieldMinimapTab, 'StopMovingOrSizing', ReanchorMap)

BattlefieldMinimap.GetScale = function() return 1 end

local function UpdateMap(enable, narrow, scale)
	if enable and not enabled then
		BattlefieldMinimapCorner:Hide()
		BattlefieldMinimapBackground:Hide()
		BattlefieldMinimap:SetScale(scale or 1.5)
		enabled = true
	elseif not enable and enabled then
		BattlefieldMinimapCorner:Show()
		BattlefieldMinimapBackground:Show()
		BattlefieldMinimap:SetScale(1)
		enabled = false
	end
	if narrow and not narrowed then
		BattlefieldMinimap1:Hide()
		BattlefieldMinimap4:Hide()
		BattlefieldMinimap5:Hide()
		BattlefieldMinimap8:Hide()
		BattlefieldMinimap9:Hide()
		BattlefieldMinimap12:Hide()

		BattlefieldMinimapCloseButton:SetParent(BattlefieldMinimapTab)
		BattlefieldMinimapCloseButton:ClearAllPoints()
		BattlefieldMinimapCloseButton:SetPoint("BOTTOMRIGHT", -2, 2)

		narrowed = true
	elseif not narrow and narrowed then
		BattlefieldMinimap1:Show()
		BattlefieldMinimap4:Show()
		BattlefieldMinimap5:Show()
		BattlefieldMinimap8:Show()
		BattlefieldMinimap9:Show()
		BattlefieldMinimap12:Show()

		BattlefieldMinimapCloseButton:SetParent(BattlefieldMinimap)
		BattlefieldMinimapCloseButton:ClearAllPoints()
		BattlefieldMinimapCloseButton:SetPoint("TOPRIGHT", -2, 7)

		narrowed = false
	end
	ReanchorMap()
end

local MAPS = {
	ArathiBasin = {},
	WarsongGulch = {},
	AlteracValley = {},
	IsleofConquest = {},
	NetherstormArena = {},
	StrandoftheAncients = {},
	LakeWintergrasp = {	narrow = false, scale = 1 },
}

local currentMap
local function ZoneCheck()
	WorldStateFrame_ToggleBattlefieldMinimap()
	local newMap = MAPS[GetMapInfo() or false]
	if newMap ~= currentMap then
		currentMap = newMap
		if currentMap then
			UpdateMap(true, currentMap.narrow == nil or currentMap.narrow, currentMap.scale)
		else
			UpdateMap(false)
		end
	end
end

-- Hooks
hooksecurefunc('BattlefieldMinimap_Update', ZoneCheck)
BattlefieldMinimapCloseButton:SetScript('OnClick', function() BattlefieldMinimap_Toggle() end)

-- Small hack to have this executed on first visible frame
BattlefieldMinimapTab:SetScript('OnUpdate', function()
	ReanchorMap()
	ZoneCheck()
	BattlefieldMinimapTab:SetScript('OnUpdate', nil)
end)

-- Prevent the frame script to mess with the WorldMapFrame
local SetMapToCurrentZone = SetMapToCurrentZone
local env = setmetatable({
	SetMapToCurrentZone = function()
		if not WorldMapFrame:IsVisible() then
			SetMapToCurrentZone()
		end
	end
}, { __index = _G })
setfenv(BattlefieldMinimap_OnShow, env)
setfenv(BattlefieldMinimap_OnEvent, env)
setfenv(BattlefieldMinimap_OnUpdate, env)
