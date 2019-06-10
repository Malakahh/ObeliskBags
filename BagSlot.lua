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
	error(ns.Debug:sprint(addonName .. "BagSlot", "Failed to load ObeliskFrameworkClass"))
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
	--slot.NewItemTexture:Hide()
	slot:SetPoint("TOPLEFT")
	slot:SetPoint("BOTTOMRIGHT")
	slot:Show()

	slot.BattlepayItemTexture:Hide()

	local icon = slot:CreateTexture(slot:GetName() .. "IconTexture", "BACKGROUND")
	icon:SetAllPoints()

	local pushedTexture = slot:CreateTexture(slot:GetName() .. "PushedTexture", "BORDER")
	pushedTexture:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	pushedTexture:SetAllPoints()

	local highlightTexture = slot:CreateTexture(slot:GetName() .. "HighlightTexture", "BORDER")
	highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
	highlightTexture:SetAllPoints()

	slot.ItemCount = slot:CreateFontString(slot:GetName() .. "Count", "ARTWORK", "NumberFontNormal")
	slot.ItemCount:SetJustifyH("RIGHT")
	slot.ItemCount:SetPoint("BOTTOMRIGHT", -5, 2)

	slot.IconBorder = slot:CreateTexture(slot:GetName() .. "IconBorder", "BORDER")
	slot.IconBorder:SetTexture("Interface\\Common\\WhiteIconFrame");
	slot.IconBorder:SetAllPoints()
	slot.IconBorder:Hide()

	slot.IconQuestTexture = slot:CreateTexture(slot:GetName() .. "IconQuestTexture", "OVERLAY")
	slot.IconQuestTexture:SetAllPoints()
	slot.IconQuestTexture:Hide()

	slot.Icon = icon
	slot:SetPushedTexture(pushedTexture)
	slot:SetHighlightTexture(highlightTexture)
	--slot:SetNormalTexture("")
	slot.PushedTexture = pushedTexture
	slot.HighlightTexture = highlightTexture

	instance.ItemSlot = slot
	instance:Show()

	return instance
end



function ns.BagSlot:SetItem(itemId)
	if type(itemId) == "number" then
		local item = ns.ItemCache:GetInfo(itemId, true)

		local bagId = self:GetID()
		local slotId = self.ItemSlot:GetID()
		local isQuestItem, questId, questIsActive = GetContainerItemQuestInfo(bagId, slotId)
		local texture, count, _, quality, _, _, _, isFiltered = GetContainerItemInfo(bagId, slotId)

		self:SetIcon(texture)

		if quality and quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
			self.ItemSlot.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
			self.ItemSlot.IconBorder:Show()
		else
			self.ItemSlot.IconBorder:Hide()
		end

		if count > 1 then
			self.ItemSlot.ItemCount:SetText(count)
		else
			self.ItemSlot.ItemCount:SetText(nil)
		end

		if ( questId and not questIsActive ) then
			self.ItemSlot.IconQuestTexture:SetTexture("Interface\\ContainerFrame\\UI-Icon-QuestBang");
			self.ItemSlot.IconQuestTexture:Show();
		elseif ( questId or isQuestItem ) then
			self.ItemSlot.IconQuestTexture:SetTexture("Interface\\ContainerFrame\\UI-Icon-QuestBorder");
			self.ItemSlot.IconQuestTexture:Show();		
		else
			self.ItemSlot.IconQuestTexture:Hide();
		end
	else
		self:SetIcon(nil)
		self.ItemSlot.IconBorder:Hide()
		self.ItemSlot.ItemCount:SetText(nil)
		self.ItemSlot.IconQuestTexture:Hide();
	end
end

function ns.BagSlot:SetIcon(icon)
	self.ItemSlot.Icon:SetTexture(icon)
end

function ns.BagSlot:GetIdentifier(bagId, slotId)
	bagId = bagId or self:GetID()
	slotId = slotId or self.ItemSlot:GetID()

	if slotId < 10 then
		return bagId .. "0" .. slotId
	else
		return bagId .. slotId
	end

end

function ns.BagSlot:GetDebugText()
	return self:GetIdentifier()
end