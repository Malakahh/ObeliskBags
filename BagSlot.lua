local addonName, ns = ...
ns.BagSlot = {}

setmetatable(ns.BagSlot, {
	__call = function (self, ...)
		return self:New(...)
	end
})

---------------
-- Libraries --
---------------

local FrameworkClass = ObeliskFrameworkManager:GetLibrary("ObeliskFrameworkClass", 1)
if not FrameworkClass then
	error(ns.Debug:sprint(addonName .. "BagSlot", "Failed to load ObeliskFrameworkClass"))
end

---------------
-- Functions --
---------------

function ns.BagSlot:New(bagId, slotId, parent)
	local instance = FrameworkClass({
		prototype = self,
		frameType = "FRAME",
		frameName = addonName .. "ItemSlotContainer" .. ns.BagSlot.EncodeSlotIdentifier(bagId, slotId),
		parent = parent,
	})

	instance.ContainerFrame = CreateFrame("Frame", nil, instance)
	instance.ContainerFrame:SetID(bagId)
	instance.ContainerFrame:SetAllPoints(instance)

	local backgroundTexture = instance:CreateTexture(instance:GetName() .. "NormalTexture", "BACKGROUND")
	backgroundTexture:SetTexture("Interface\\BUTTONS\\UI-Slot-Background")
	backgroundTexture:SetTexCoord(0, 0.640625, 0, 0.640625)
	backgroundTexture:SetAllPoints()

	local slot = CreateFrame("Button", addonName .. "ItemSlot" .. ns.BagSlot.EncodeSlotIdentifier(bagId, slotId), instance.ContainerFrame, "ContainerFrameItemButtonTemplate")
	slot:SetAllPoints(instance.ContainerFrame)
	slot:SetID(slotId)
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
	
	slot.PushedTexture = pushedTexture
	slot.HighlightTexture = highlightTexture

	instance.ItemSlot = slot
	instance:Show()

	return instance
end

function ns.BagSlot:SetItem(itemId)
	if type(itemId) == "number" then
		local item = ns.ItemCache:GetInfo(itemId, true)

		local bagId = self.ContainerFrame:GetID()
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

function ns.BagSlot:SetOwner(bag)
	self.Owner = bag
end

function ns.BagSlot.EncodeSlotIdentifier(bagId, slotId)
	if slotId < 10 then
		return bagId .. "00" .. slotId
	elseif slotId < 100 then
		return bagId .. "0" .. slotId
	else
		return bagId .. slotId
	end
end

function ns.BagSlot.DecodeSlotIdentifier(slotIdentifier)
	local slotId = string.sub(slotIdentifier, -3)
	local bagId = string.sub(slotIdentifier, 1, -4)

	return tonumber(bagId), tonumber(slotId)
end

function ns.BagSlot:GetPhysicalIdentifier()
	local bagId = self.ContainerFrame:GetID()
	local slotId = self.ItemSlot:GetID()

	return ns.BagSlot.EncodeSlotIdentifier(bagId, slotId)
end

function ns.BagSlot:GetVirtualIdentifier()
	local bagId = self.Owner.Id

	if self.Owner.IsMasterBag then
		bagId = 0
	end

	local slotId = ns.Util.Table.IndexOf(self.Owner.GridView.items, self)

	return ns.BagSlot.EncodeSlotIdentifier(bagId, slotId)
end

function ns.BagSlot:GetDebugText()
	return self:GetPhysicalIdentifier()
end