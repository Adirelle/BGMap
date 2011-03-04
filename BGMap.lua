--[[
BGMap - Enhanced battleground map
Copyright 2010 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...

local function ReanchorMap()
	local x = BattlefieldMinimapTab:GetCenter() / BattlefieldMinimapTab:GetScale()
	local side = (x > UIParent:GetWidth() / 2) and "RIGHT" or "LEFT"
	local xOffset = BattlefieldMinimap1:IsShown() and 0 or BattlefieldMinimap:GetWidth() / 4
	if side == "LEFT" then
		xOffset = - xOffset
	end
	local yOffset = BattlefieldMinimapBackground:IsShown() and -5 or 0
	BattlefieldMinimap:ClearAllPoints()
	BattlefieldMinimap:SetPoint("TOP"..side, BattlefieldMinimapTab, "BOTTOM"..side, xOffset, yOffset)
end

hooksecurefunc(BattlefieldMinimapTab, 'StopMovingOrSizing', ReanchorMap)

local DEFAULT_BG_MAP = { narrow = true, scale = 1.5 }
local MAPS = {
	ArathiBasin = DEFAULT_BG_MAP,
	WarsongGulch = DEFAULT_BG_MAP,
	AlteracValley = DEFAULT_BG_MAP,
	IsleofConquest = DEFAULT_BG_MAP,
	NetherstormArena = DEFAULT_BG_MAP,
	StrandoftheAncients = DEFAULT_BG_MAP,
	TwinPeaks = DEFAULT_BG_MAP,
	GilneasBattleground2 = DEFAULT_BG_MAP,
	TolBarad = { scale = 1 },
	LakeWintergrasp = {	narrow = false, scale = 1 },
}

local origShow = BattlefieldMinimap1.Show
local origHide = BattlefieldMinimap1.Hide

local narrowTextures = {
		BattlefieldMinimap1,
		BattlefieldMinimap4,
		BattlefieldMinimap5,
		BattlefieldMinimap8,
		BattlefieldMinimap9,
		BattlefieldMinimap12,
}

local function UpdateMap()
	local currentMap = MAPS[GetMapInfo() or false]
	local enable, narrow, scale = false, false, 1
	if currentMap then
		enable, narrow, scale = true, currentMap.narrow, currentMap.scale
	end
	if enable then
		BattlefieldMinimapCorner:Hide()
		BattlefieldMinimapBackground:Hide()
		BattlefieldMinimapCloseButton:SetParent(BattlefieldMinimapTab)
		BattlefieldMinimapCloseButton:ClearAllPoints()
		BattlefieldMinimapCloseButton:SetWidth(24)
		BattlefieldMinimapCloseButton:SetHeight(24)
		BattlefieldMinimapCloseButton:SetPoint("BOTTOMRIGHT", BattlefieldMinimapTab, "BOTTOMRIGHT", -2, -2)
		BattlefieldMinimapCloseButton:SetAlpha(1)
	else
		BattlefieldMinimapCorner:Show()
		BattlefieldMinimapBackground:Show()
		BattlefieldMinimapCloseButton:SetParent(BattlefieldMinimap)
		BattlefieldMinimapCloseButton:SetWidth(32)
		BattlefieldMinimapCloseButton:SetHeight(32)
		BattlefieldMinimapCloseButton:ClearAllPoints()
		BattlefieldMinimapCloseButton:SetPoint("TOPRIGHT", BattlefieldMinimap, "TOPRIGHT", 2, 7)		
	end
	BattlefieldMinimapCloseButton:Show()
	local bonus = enable and 10 or 0
	BattlefieldMinimap:SetWidth(224 * scale + bonus)
	BattlefieldMinimap:SetHeight(150 * scale + bonus)
	if not BattlefieldMinimap.resizing then
		BattlefieldMinimap.resizing = true
		BattlefieldMinimap_OnUpdate(BattlefieldMinimap, 0)
		BattlefieldMinimap.resizing = nil
	end
	if narrow then
		for i, texture in pairs(narrowTextures) do
			texture:Hide()
			texture.Show = origHide
		end
	else
		for i, texture in pairs(narrowTextures) do
			texture.Show = origShow
			texture:Show()
		end
	end
	ReanchorMap()
end

-- Hooks
hooksecurefunc('BattlefieldMinimap_Update', UpdateMap)
BattlefieldMinimapCloseButton:SetScript('OnClick', function() BattlefieldMinimap_Toggle() end)

-- Update more often
BATTLEFIELD_MINIMAP_UPDATE_RATE = 0.2
BattlefieldMinimap:RegisterEvent("UPDATE_WORLD_STATES")
BattlefieldMinimap:HookScript('OnEvent', function(self, event, ...)
	if event == "UPDATE_WORLD_STATES" and BattlefieldMinimap:IsVisible() then
		BattlefieldMinimap_Update()
	end
end)

-- Small hack to have this executed on first visible frame
BattlefieldMinimapTab:SetScript('OnUpdate', function()
	UpdateMap()
	BattlefieldMinimapTab:SetScript('OnUpdate', nil)
end)

