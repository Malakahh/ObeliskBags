local addonName, ns = ...
local className = "BagArea"

ns.BagArea = ns.BagArea or {}

setmetatable(ns.BagArea, {
	__call = function (self, ...)
		return self:New(...)
	end
})

---------------
-- Libraries --
---------------

local FrameworkClass = ObeliskFrameworkManager:GetLibrary("ObeliskFrameworkClass", 1)
if not FrameworkClass then
	error(ns.Debug:sprint(addonName .. className, "Failed to load ObeliskFrameworkClass"))
end

local CustomEvents = ObeliskFrameworkManager:GetLibrary("ObeliskCustomEvents", 0)
if not CustomEvents then
	error(ns.Debug:sprint(addonName .. className, "Failed to load ObeliskCustomEvents"))
end

---------------
-- Constants --
---------------


-----------
-- local --
-----------


-----------
-- Class --
-----------

function ns.BagArea:New(AreaType, parent)
	local name = addonName .. className

	local instance = FrameworkClass({
		prototype = self,
		frameType = "FRAME",
		frameName = name,
		parent = parent,
	})

	instance:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

	instance.AreaType = AreaType
	instance:LayoutInit()

	return instance
end

function ns.BagArea:IsPurchasable(id)
	return ns.BagFamilies:IsBankBag(id) and (id - NUM_BAG_SLOTS) > GetNumBankSlots() or ns.BagFamilies:IsReagents(id) and not IsReagentBankUnlocked()
end

function ns.BagArea:Purchase(id)
	if ns.BagFamilies:IsReagents(id) then
		StaticPopup_Show('CONFIRM_BUY_REAGENTBANK_TAB')
	else
		if not StaticPopupDialogs["CONFIRM_BUY_BANK_SLOT_" .. addonName] then
			StaticPopupDialogs["CONFIRM_BUY_BANK_SLOT_" .. addonName] = {
				text = CONFIRM_BUY_BANK_SLOT,
				button1 = YES,
				button2 = NO,
				OnAccept = PurchaseSlot,
				OnShow = function(self)
					MoneyFrame_Update(self.moneyFrame, GetBankSlotCost(GetNumBankSlots()))
				end,
				hasMoneyFrame = 1,
				hideOnEscape = 1,
				timeout = 0,
				preferredIndex = STATICPOPUP_NUMDIALOGS
			}
		end

		StaticPopup_Show('CONFIRM_BUY_BANK_SLOT_' .. addonName)
	end
end

function ns.BagArea:GetCost()
	return ns.BagFamilies:IsReagents() and GetReagentBankCost() or GetBankSlotCost(GetNumBankSlots())
end

function ns.BagArea:UpdateTooltip(id)
	GameTooltip:ClearLines()

	if self:IsPurchasable(id) then
		GameTooltip:SetText(ns.BagFamilies:IsReagents(id) and REAGENT_BANK or BANK_BAG_PURCHASE, 1, 1, 1)
		GameTooltip:AddLine("Click to purchase this bank slot.")
		SetTooltipMoney(GameTooltip, self:GetCost())
	elseif ns.BagFamilies:IsBackpack(id) then
		GameTooltip:SetText(BACKPACK_TOOLTIP, 1,1,1)
	elseif ns.BagFamilies:IsBank(id) then
		GameTooltip:SetText(BANK, 1,1,1)
	elseif ns.BagFamilies:IsReagents(id) then
		GameTooltip:SetText(REAGENT_BANK, 1,1,1)
	elseif self.Bags[id].link then
		GameTooltip:SetHyperlink(self.Bags[id].link)
	elseif ns.BagFamilies:IsBankBag(id) then
		GameTooltip:SetText(BANK_BAG, 1,1,1)
	else
		GameTooltip:SetText(EQUIP_CONTAINER, 1,1,1)
	end

	GameTooltip:Show()
end

function ns.BagArea.OnEnter(self)
	local area = self:GetParent():GetParent()
	local id = self:GetID()

	if self:GetRight() > (GetScreenWidth() / 2) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	end
	area:UpdateTooltip(id)

	if (ns.BagFamilies:IsBackpack(id) or
		ns.BagFamilies:IsBank(id) or
		ns.BagFamilies:IsReagents(id) or
		self.link) then

		local maxNumSlots = GetContainerNumSlots(id)
		for i = 1, maxNumSlots do
			local slot = _G[addonName .. "ItemSlotContainer" .. ns.BagSlot.EncodeSlotIdentifier(id, i)]
			slot.ItemSlot.BattlepayItemTexture:Show()
		end
	end
end

function ns.BagArea.OnLeave(self)
	local area = self:GetParent():GetParent()
	local id = self:GetID()

	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end

	if (ns.BagFamilies:IsBackpack(id) or
		ns.BagFamilies:IsBank(id) or
		ns.BagFamilies:IsReagents(id) or
		self.link) then

		local maxNumSlots = GetContainerNumSlots(id)
		for i = 1, maxNumSlots do
			local slot = _G[addonName .. "ItemSlotContainer" .. ns.BagSlot.EncodeSlotIdentifier(id, i)]
			slot.ItemSlot.BattlepayItemTexture:Hide()
		end
	end
end

function ns.BagArea.OnClick(btn, key)
	local area = btn:GetParent():GetParent()
	area:OnClickHandler(key, btn:GetID())
end

function ns.BagArea:OnClickHandler(key, id)
	if self:IsPurchasable(id) then
		self:Purchase(id)
	elseif CursorHasItem() then
		if ns.BagFamilies:IsBackpack(id) then
			PutItemInBackpack()
		else
			PutItemInBag(ContainerIDToInventoryID(id))
		end
	end
end

function ns.BagArea.OnDrag(self)
	local id = self:GetID()
	if ns.BagFamilies:IsBackpackBag(id) or ns.BagFamilies:IsBankBag(id) then
		PickupBagFromSlot(ContainerIDToInventoryID(id))
	end
end

function ns.BagArea:CheckBagsChanged()
	local startIdx, endIdx
	if ns.BagFamilies:IsBackpack(self.AreaType) then
		startIdx = BACKPACK_CONTAINER + 1
		endIdx = NUM_BAG_SLOTS
	elseif ns.BagFamilies:IsBank(self.AreaType) then
		startIdx = NUM_BAG_SLOTS + 1
		endIdx = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
	end

	if startIdx and endIdx then
		local firstTime = false
		if not self.CachedBagsChanged then -- first time
			self.CachedBagsChanged = {}
			firstTime = true
		end

		if firstTime then
			for i = startIdx, endIdx do
				self.CachedBagsChanged[i] = {
					Family = ns.BagFamilies:BagIDToBagFamily(i),
					SlotCount = GetContainerNumSlots(i)
				}
			end
		else
			for i = startIdx, endIdx do
				local family = ns.BagFamilies:BagIDToBagFamily(i)
				local slotCount = GetContainerNumSlots(i)

				if family ~= self.CachedBagsChanged[i].Family or slotCount ~= self.CachedBagsChanged[i].SlotCount then
					CustomEvents:Fire("CUSTOM_EVENT_EQUIPPED_BAGS_CHANGED", i)
					return true
				end
			end
		end
	end

	return false
end

function ns.BagArea:BAG_UPDATE(bagID)
	if self:CheckBagsChanged() then
		return
	end

	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
		if self.Bags[i] then
			self:Update_Layout(i)
		end
	end
end

function ns.BagArea:REAGENTBANK_PURCHASED()
	self:Update_Layout(REAGENTBANK_CONTAINER)
end