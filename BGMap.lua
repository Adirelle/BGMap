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

-- Team blip enhancement

local function Blip_OnUpdate(self)
	if GetTime() % 1 < 0.5 then
		self.icon:SetVertexColor(1, 0, 0)
	else
		self.icon:SetVertexColor(self.r, self.g, self.b)
	end
end

local function Blip_Update(self)
	local player = self.unit or self.name
	local r, g, b, a = 1, 1, 1, 1
	if player then
		if PlayerIsPVPInactive(player) then
			r, g, b = 0.5, 0.2, 0.8
		elseif UnitIsDeadOrGhost(player) then
			r, g, b, a = 0.5, 0.5, 0.5, 0.5
		else
			local _, class = UnitClass(player)
			local color = (CUSTOM_RAID_COLORS or RAID_CLASS_COLORS)[class]
			if color then
				r, g, b = color.r, color.g, color.b
			end
		end
		if UnitAffectingCombat(player) then
			self.r, self.g, self.b = r, g, b
			self:SetScript('OnUpdate', Blip_OnUpdate)
		else
			self.delay = nil
			self:SetScript('OnUpdate', nil)
		end
	end
	self.icon:SetVertexColor(r, g, b, a)
end

local function Blip_OnEvent(self, event, unit)
	if not unit or UnitIsUnit(unit, self.unit or self.name) then
		Blip_Update(self)
	end
end

local function Blip_OnShow(self)
	self:RegisterEvent('UNIT_HEALTH')
	self:RegisterEvent('UNIT_FLAGS')
	self:RegisterEvent('UNIT_DYNAMIC_FLAGS')
	Blip_Update(self)
end

local function Blip_OnHide(self)
	self:UnregisterAllEvents()
end

local knownBlips = {}

local function EnhanceBlip(self)
	knownBlips[self] = true
	self.icon:SetTexture([[Interface\MINIMAP\PartyRaidBlips]])
	self.icon:SetTexCoord(0.875, 1, 0.25, 0.5)
	self:HookScript('OnShow', Blip_OnShow)
	self:HookScript('OnHide', Blip_OnHide)
	self:HookScript('OnEvent', Blip_OnEvent)
	if self:IsVisible() then
		Blip_OnShow(self)
	end
end

for i = 1, 4 do EnhanceBlip(_G["BattlefieldMinimapParty"..i]) end
for i = 1, 40 do EnhanceBlip(_G["BattlefieldMinimapRaid"..i]) end

hooksecurefunc("WorldMapUnit_Update", function(self) if knownBlips[self] then return Blip_Update(self) end end)

