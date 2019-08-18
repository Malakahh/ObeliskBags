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

	if self:GetRight() > (GetScreenWidth() / 2) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	end

	area:UpdateTooltip(self:GetID())
end

function ns.BagArea.OnLeave(self)
	local area = self:GetParent():GetParent()

	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
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

