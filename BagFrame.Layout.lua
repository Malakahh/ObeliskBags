local addonName, ns = ...
local className = "BagFrame"

ns.BagFrame = ns.BagFrame or {}

---------------
-- Libraries --
---------------

local libGridView = ObeliskFrameworkManager:GetLibrary("ObeliskGridView", 1)
if not libGridView then
	error(ns.Debug:sprint(addonName .. className, "Failed to load ObeliskGridView"))
end

local libCollapsePanel = ObeliskFrameworkManager:GetLibrary("ObeliskCollapsePanel", 0)
if not libCollapsePanel then
	error(ns.Debug:sprint(addonName .. className, "Failed to load ObeliskCollapsePanel"))
end

---------------
-- Constants --
---------------

local CellSize = 37

-----------
-- Class --
-----------

function ns.BagFrame:LayoutInit()
	self.padding = 6
	self.spacing = 6
	self.btnHeight = 25
	self.btnWidth = 25

	-- BagFrame
	self:SetPoint("CENTER")
	self:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4}
	})
	self:SetBackdropColor(0, 0, 0, 1)

	self:SetScript("OnMouseDown", self.OnMouseDown)
	self:SetScript("OnMouseUp", self.OnMouseUp)

	-- Title
	self.Title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	self.Title:SetText("Title - " .. self.Id)

	-- Btn Close
	self.BtnClose = CreateFrame("BUTTON", addonName .. "CloseButton", self, "UIPanelCloseButtonNoScripts")
	self.BtnClose:SetPoint("TOPRIGHT", 0, 0)
	self.BtnClose:SetScript("OnClick", self.BtnClose_OnClick)

	-- gridView
	self.GridView = libGridView(0, 0, "GridView", self)
	self.GridView:SetCellSize(CellSize, CellSize)
	self.GridView:SetCellMargin(2, 2)

	-- frame movement
	self:SetMovable(true)
	self:SetClampedToScreen(true)

	-- ConfigBtn
	self.BtnConfig = CreateFrame("BUTTON", addonName .. "ConfigButton", self, "UIPanelButtonTemplate")
	self.BtnConfig:SetSize(self.btnWidth, self.btnHeight)
	self.BtnConfig.icon = self.BtnConfig:CreateTexture(nil, "ARTWORK")
	self.BtnConfig.icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
	self.BtnConfig.icon:SetSize(12, 12)
	self.BtnConfig.icon:SetPoint("CENTER", self.BtnConfig, "CENTER",0,-1)
	self.BtnConfig:SetScript("OnClick", self.BtnConfig_OnClick)

	-- Master bag depandant layout
	if self.IsMasterBag then

		-- New bag btn
		self.BtnNewBag = CreateFrame("BUTTON", addonName .. "NewBagButton", self, "UIPanelButtonTemplate")
		self.BtnNewBag:SetSize(100, self.btnHeight)
		self.BtnNewBag:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.padding, self.padding)
		self.BtnNewBag:SetText("New Bag")

		-- Defrag btn
		self.BtnDefrag = CreateFrame("BUTTON", addonName .. "DefragButton", self, "UIPanelButtonTemplate")
		self.BtnDefrag:SetSize(100, self.btnHeight)
		self.BtnDefrag:SetText("Defrag")
		self.BtnDefrag:SetPoint("LEFT", self.BtnConfig, "RIGHT", self.spacing, 0)

		-- Equipped Bags btn
		self.BtnEquippedBags = CreateFrame("CHECKBUTTON", addonName .. "ToggleEquippedBagsButton", self)
		self.BtnEquippedBags:SetSize(self.btnWidth, self.btnHeight)
		self.BtnEquippedBags:SetNormalTexture("Interface\\Buttons\\Button-Backpack-Up")
		self.BtnEquippedBags:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
		self.BtnEquippedBags:SetPoint("TOPLEFT", self, "TOPLEFT", self.padding, -self.padding)

		-- Equipped Bags Collapse Panel
		self.EquippedBagsPanel = libCollapsePanel:New(addonName .. "EquippedBagsPanel", self, 100, 30 + self.spacing + self.padding)
		-- self.EquippedBagsPanel.tex = self.EquippedBagsPanel:CreateTexture(nil, "BACKGROUND")
		-- self.EquippedBagsPanel.tex:SetAllPoints()
		-- self.EquippedBagsPanel.tex:SetColorTexture(0,0,1, 0.5)
		self.EquippedBagsPanel:SetPoint("TOPLEFT", self.BtnEquippedBags, "BOTTOMLEFT", 0, 0)
		self.EquippedBagsPanel:Close()

		-- Bag Slots
		--self:LayoutCreateBagSlots()
		self.BagArea = ns.BagArea:New(self.BagFamily, self.EquippedBagsPanel)
		self.BagArea:SetPoint("TOPLEFT", self.EquippedBagsPanel, "TOPLEFT", 1, -self.padding)

		-- Money frame
		self.MoneyFrame = CreateFrame("FRAME", addonName .. "MoneyFrame", self, "SmallMoneyFrameTemplate")
		self.MoneyFrame:SetPoint("BOTTOMRIGHT", self.padding, self.padding * 1.5)

		-- Additional moving of elements
		self.BtnConfig:SetPoint("LEFT", self.BtnNewBag, "RIGHT", self.spacing, 0)
		self.GridView:SetPoint("TOPLEFT", self.EquippedBagsPanel, "BOTTOMLEFT")
		self.Title:SetPoint("LEFT", self.BtnEquippedBags, "RIGHT", self.spacing, 0)

		-- OnClick handlers
		self.BtnNewBag:SetScript("OnClick", self.BtnNew_OnClick)
		self.BtnDefrag:SetScript("OnClick", self.BtnDefrag_OnClick)
		self.BtnEquippedBags:SetScript("OnClick", self.BtnEquippedBags_OnClick)
	else

		-- Delete bag
		self.BtnDelete = CreateFrame("BUTTON", addonName .. "DeleteButton", self, "UIPanelButtonTemplate")
		self.BtnDelete:SetSize(100, self.btnHeight)
		self.BtnDelete:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.padding, self.padding)
		self.BtnDelete:SetText("Delete bag")

		-- Additional moving of elements
		self.BtnConfig:SetPoint("LEFT", self.BtnDelete, "RIGHT", self.spacing, 0)
		self.GridView:SetPoint("TOPRIGHT", self.BtnClose, "BOTTOMRIGHT", -self.padding, 0)
		self.Title:SetPoint("TOPLEFT", self.padding, -self.padding)

		-- OnClick handlers
		self.BtnDelete:SetScript("OnClick", self.BtnDelete_OnClick)
	end
end

function ns.BagFrame:LayoutInitDelayed()
	if self.IsMasterBag and self.BagFamily ~= ns.BagFamilies.Inventory() then
		self.MoneyFrame:Hide()
	end
end

function ns.BagFrame:LayoutCreateBagSlots()
	-- self.BagSlots = {}
	-- local width = self.padding

	-- if self.BagFamily == ns.BagFamilies.Inventory() then
	-- 	for i = BACKPACK_CONTAINER + 1, NUM_BAG_SLOTS do
			
	-- 		--BagSlotButtonTemplate
	-- 		local bagSlot = CreateFrame("ITEMBUTTON", addonName .. "BagSlot" .. i, self, "ContainerFrameItemButtonTemplate")

	-- 		bagSlot:SetPoint("TOPLEFT", self.EquippedBagsPanel, "TOPLEFT", width, -self.padding)
	-- 		bagSlot:SetID(CONTAINER_BAG_OFFSET+i)
	-- 		width = width + bagSlot:GetWidth() + self.spacing * 2

	-- 		table.insert(self.BagSlots, bagSlot)
	-- 	end
	-- elseif self.BagFamily == ns.BagFamilies.Bank() then

	-- end

	-- self.EquippedBagsPanel.Width = width - self.spacing
end