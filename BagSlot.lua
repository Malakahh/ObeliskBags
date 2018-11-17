local addonName, ns = ...
ns.BagSlot = {}

setmetatable(ns.BagSlot, {
	__call = function (self, ...)
		return self:New(...)
	end,
	__index = ns.BagSlot
})

---------------
-- Libraries --
---------------

local FrameworkClass = ObeliskFrameworkManager:GetLibrary("ObeliskFrameworkClass", 0)
if not FrameworkClass then
	error(ns.Debug:sprint(libraryName, "Failed to load ObeliskFrameworkClass"))
end

---------------
-- Functions --
---------------

function ns.BagSlot:New(bagId, slotId, parent)
	local instance = FrameworkClass(self, "FRAME", addonName .. "ItemSlotContainer" .. self:GetIdentifier(bagId, slotId), parent or UIParent)
	instance:SetID(bagId)

	local backgroundTexture = instance:CreateTexture(instance:GetName() .. "NormalTexture", "BACKGROUND")
	backgroundTexture:SetTexture("Interface\\BUTTONS\\UI-Slot-Background")
	backgroundTexture:SetTexCoord(0, 0.640625, 0, 0.640625)
	backgroundTexture:SetAllPoints()


	local slot = CreateFrame("Button", addonName .. "ItemSlot" .. self:GetIdentifier(bagId, slotId), instance, "ContainerFrameItemButtonTemplate")
	slot:SetID(slotId)
	slot:SetPoint("TOPLEFT")
	slot:SetPoint("BOTTOMRIGHT")
	slot:Show()

	local icon = slot:CreateTexture(slot:GetName() .. "IconTexture", "BACKGROUND")
	icon:SetAllPoints()

	local pushedTexture = slot:CreateTexture(slot:GetName() .. "PushedTexture", "BORDER")
	pushedTexture:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	pushedTexture:SetAllPoints()

	local highlightTexture = slot:CreateTexture(slot:GetName() .. "HighlightTexture", "BORDER")
	highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
	highlightTexture:SetAllPoints()

	slot.Icon = icon
	slot:SetPushedTexture(pushedTexture)
	slot:SetHighlightTexture(highlightTexture)
	slot:SetNormalTexture("")
	slot.PushedTexture = pushedTexture
	slot.HighlightTexture = highlightTexture

	instance.ItemSlot = slot
	instance:Show()

	return instance
end

function ns.BagSlot:SetIcon(icon)
	self.ItemSlot.Icon:SetTexture(icon)
end

function ns.BagSlot:GetIdentifier(bagId, slotId)
	bagId = bagId or self:GetID()
	slotId = slotId or self.ItemSlot:GetID()
	return bagId .. slotId
end