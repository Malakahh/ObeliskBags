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

---------------
-- Constants --
---------------

ns.CellSize = 37

-----------
-- Class --
-----------

function ns.BagFrame:LayoutInit()
	self.padding = 6
	self.spacing = 6
	self.btnHeight = 19

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
	self.Title:SetPoint("TOPLEFT", self.padding, -self.padding)
	self.Title:SetText("Title - " .. self.Id)

	-- Btn Close
	self.BtnClose = CreateFrame("BUTTON", addonName .. "CloseButton", self, "UIPanelCloseButtonNoScripts")
	self.BtnClose:SetPoint("TOPRIGHT", 0, 0)
	self.BtnClose:SetScript("OnClick", self.BtnClose_OnClick)

	-- gridView
	self.GridView = libGridView(0, 0, "GridView", self)
	self.GridView:SetCellSize(ns.CellSize, ns.CellSize)
	self.GridView:SetCellMargin(2, 2)
	self.GridView:SetPoint("TOPRIGHT", self.BtnClose, "BOTTOMRIGHT", -self.padding, 0)

	-- frame movement
	self:SetMovable(true)
	self:SetClampedToScreen(true)

	-- ConfigBtn
	self.BtnConfig = CreateFrame("BUTTON", addonName .. "ConfigButton", self, "UIPanelButtonTemplate")
	self.BtnConfig:SetSize(25, self.btnHeight)
	self.BtnConfig.icon = self.BtnConfig:CreateTexture(nil, "ARTWORK")
	self.BtnConfig.icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
	self.BtnConfig.icon:SetSize(12, 12)
	self.BtnConfig.icon:SetPoint("TOPLEFT", self.BtnConfig, "TOPLEFT", 6, -4)

	-- Master bag depandant layout
	if self.IsMasterBag then
		self.BtnNewBag = CreateFrame("BUTTON", addonName .. "NewBagButton", self, "UIPanelButtonTemplate")
		self.BtnNewBag:SetSize(100, self.btnHeight)
		self.BtnNewBag:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.padding, self.padding)
		self.BtnNewBag:SetText("New Bag")

		self.BtnConfig:SetPoint("LEFT", self.BtnNewBag, "RIGHT", self.spacing, 0)

		self.BtnDefrag = CreateFrame("BUTTON", addonName .. "DefragButton", self, "UIPanelButtonTemplate")
		self.BtnDefrag:SetSize(100, self.btnHeight)
		self.BtnDefrag:SetText("Defrag")
		self.BtnDefrag:SetPoint("LEFT", self.BtnConfig, "RIGHT", self.spacing, 0)

		self.MoneyFrame = CreateFrame("FRAME", addonName .. "MoneyFrame", self, "SmallMoneyFrameTemplate")
		self.MoneyFrame:SetPoint("BOTTOMRIGHT", self.padding, self.padding * 1.5)

		self.BtnNewBag:SetScript("OnClick", self.BtnNew_OnClick)
		self.BtnConfig:SetScript("OnClick", self.BtnConfig_OnClick)
		self.BtnDefrag:SetScript("OnClick", self.BtnDefrag_OnClick)
	else
		self.BtnDelete = CreateFrame("BUTTON", addonName .. "DeleteButton", self, "UIPanelButtonTemplate")
		self.BtnDelete:SetSize(100, self.btnHeight)
		self.BtnDelete:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.padding, self.padding)
		self.BtnDelete:SetText("Delete bag")
		self.BtnDelete:SetScript("OnClick", self.BtnDelete_OnClick)

		self.BtnConfig:SetPoint("LEFT", self.BtnDelete, "RIGHT", self.spacing, 0)
		self.BtnConfig:SetScript("OnClick", self.BtnConfig_OnClick)
	end
end

function ns.BagFrame:LayoutInitDelayed()
	if self.IsMasterBag and self.BagFamily ~= ns.BagFamilies.Inventory() then
		self.MoneyFrame:Hide()
	end
end
