local addonName, ns = ...
local className = "BagArea"

ns.BagArea = ns.BagArea or {}

---------------
-- Libraries --
---------------

local libGridView = ObeliskFrameworkManager:GetLibrary("ObeliskGridView", 1)
if not libGridView then
	error(ns.Debug:sprint(addonName .. className, "Failed to load ObeliskGridView"))
end

---------------
-- Constants --
---------------

local CellSize = 30

-----------
-- Class --
-----------

function ns.BagArea:LayoutInit()
	
	-- GridView
	self.GridView = libGridView(0, 0, "GridView", self)
	self.GridView:SetCellSize(CellSize, CellSize)
	self.GridView:SetCellMargin(5, 0)
	self.GridView:SetNumRows(1)
	self.GridView:SetAllPoints(self)

	self.Bags = {}
	if ns.BagFamilies:IsBackpack(self.AreaType) then
		for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
			self:SpawnBagSlot(i)
		end
	elseif ns.BagFamilies:IsBank(self.AreaType) then
		self:SpawnBagSlot(BANK_CONTAINER)
		for i = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			self:SpawnBagSlot(i)
		end
		self:SpawnBagSlot(REAGENTBANK_CONTAINER)
	end

	local gridWidth, gridHeight = self.GridView:GetCalculatedGridSize()
	self.GridView:SetWidth(gridWidth)
	self.GridView:SetHeight(gridHeight)
	self:SetSize(gridWidth, gridHeight)

	self.GridView:Update()

	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("REAGENTBANK_PURCHASED")
end

function ns.BagArea:SpawnBagSlot(id)
	local bag = CreateFrame("BUTTON", addonName .. className .. "BagSlot" .. id, self.GridView)
	bag.Icon = bag:CreateTexture(bag:GetName() .. "IconTexture", "BORDER")
	bag.Icon:SetAllPoints(bag)

	local normalTex = bag:CreateTexture()
	normalTex:SetTexture("Interface\\Buttons\\UI-Quickslot2")
	normalTex:SetWidth(64 * CellSize / 36)
	normalTex:SetHeight(64 * CellSize / 36)
	normalTex:SetPoint("CENTER",0,0)

	local pushedTex = bag:CreateTexture()
	pushedTex:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	pushedTex:SetAllPoints()

	local highlightTex = bag:CreateTexture()
	highlightTex:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
	highlightTex:SetAllPoints()

	bag:SetID(id)
	bag:SetNormalTexture(normalTex)
	bag:SetPushedTexture(pushedTex)
	bag:SetHighlightTexture(highlightTex)
	bag:RegisterForClicks('anyUp')
	bag:RegisterForDrag('LeftButton')
	bag:SetSize(CellSize, CellSize)

	bag:SetScript("OnEnter", self.OnEnter)
	bag:SetScript("OnLeave", self.OnLeave)
	bag:SetScript("OnClick", self.OnClick)
	bag:SetScript("OnDragStart", self.OnDrag)
	bag:SetScript("OnReceiveDrag", self.OnClick)

	self.Bags[id] = bag
	self.GridView:AddItem(bag)
	self:Update_Layout(id)

	return bag
end

function ns.BagArea:Update_Layout(bagID)
	local bagFamilies = ns.BagFamilies
	if bagFamilies:IsBackpack(bagID) or bagFamilies:IsBank(bagID) then
		self:SetIcon(self.Bags[bagID], "Interface\\Buttons\\Button-Backpack-Up")
	elseif bagFamilies:IsReagents(bagID) then
		self:SetIcon(self.Bags[bagID], "Interface\\Icons\\Achievement_GuildPerk_BountifulBags")
	else
		local icon = GetInventoryItemTexture("player", ContainerIDToInventoryID(bagID))
		self:SetIcon(self.Bags[bagID], icon or "Interface\\PaperDoll\\UI-PaperDoll-Slot-Bag")

		self.Bags[bagID].link = GetInventoryItemLink("player", ContainerIDToInventoryID(bagID))
	end
end

function ns.BagArea:SetIcon(bag, icon)
	local color = self:IsPurchasable(bag:GetID()) and .1 or 1
	SetItemButtonTexture(bag, icon)
	SetItemButtonTextureVertexColor(bag, 1, color, color)
end

