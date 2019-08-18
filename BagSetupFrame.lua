local addonName, ns = ...
local className = "BagSetupFrame"

---------------
-- Libraries --
---------------

local libSliderEditBox = ObeliskFrameworkManager:GetLibrary("ObeliskSliderEditBox", 0)
if not libSliderEditBox then
	error(ns.Debug:sprint(addonName .. className, "Failed to load ObeliskSliderEditBox"))
end

ns.BagSetupFrame = CreateFrame("FRAME", addonName .. className, UIParent)

local padding = 9
local spacing = 20

-- Frame
ns.BagSetupFrame:SetPoint("CENTER")
ns.BagSetupFrame:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4}
})
ns.BagSetupFrame:SetBackdropColor(0, 0, 0, 1)
ns.BagSetupFrame:SetClampedToScreen(true)
ns.BagSetupFrame:SetSize(300, 300)
ns.BagSetupFrame:SetFrameStrata("TOOLTIP")
ns.BagSetupFrame:EnableMouse(true)
ns.BagSetupFrame:Hide()

-- Title
ns.BagSetupFrame.Title = ns.BagSetupFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
ns.BagSetupFrame.Title:SetPoint("TOP", 0, -padding)

-- Btn Cancel
ns.BagSetupFrame.BtnCancel = CreateFrame("Button", addonName .. className .. "Cancel", ns.BagSetupFrame, "UIPanelButtonTemplate")
ns.BagSetupFrame.BtnCancel:SetSize(100, 22)
ns.BagSetupFrame.BtnCancel:SetPoint("BOTTOMRIGHT", -padding, padding)
ns.BagSetupFrame.BtnCancel:SetText("Cancel")
ns.BagSetupFrame.BtnCancel:SetScript("OnClick", function(btn)
	ns.BagSetupFrame:Hide()
end)

-- Btn Create
ns.BagSetupFrame.BtnCreate = CreateFrame("Button", addonName .. className .. "Create", ns.BagSetupFrame, "UIPanelButtonTemplate")
ns.BagSetupFrame.BtnCreate:SetSize(100, 22)
ns.BagSetupFrame.BtnCreate:SetPoint("RIGHT", ns.BagSetupFrame.BtnCancel, "LEFT", -padding, 0)
ns.BagSetupFrame.BtnCreate:SetScript("OnClick", function(btn)
	local configTable
	if ns.BagSetupFrame.BagFrame then
		configTable = ns.BagSetupFrame.BagFrame:GetConfigTable()

		if not configTable.IsMasterBag then
			Id = ns.BagSetupFrame.BagFrame.Id
			ns.BagSetupFrame.BagFrame:DeleteBag()
		end
	else
		configTable = ns.Util.Table.Copy(ns.BagFrame.DefaultConfigTable)
	end

	configTable.NumColumns = ns.BagSetupFrame.ColumnSlider:GetValue()
	configTable.Slots = ns.BagSetupFrame.SlotSlider:GetValue()
	configTable.Title = ns.BagSetupFrame.EditBoxBagTitle:GetText()
	configTable.BagFamily = ns.BagSetupFrame.BagFamily

	if configTable.IsMasterBag then
		ns.BagSetupFrame.BagFrame.TitleText = configTable.Title
		ns.BagSetupFrame.BagFrame.NumColumns = configTable.NumColumns
		ns.BagSetupFrame.BagFrame:Update()
	else
		ns.BagFrame:New(configTable, #ns.MasterBags[configTable.BagFamily].Children + 1)
	end

	ns.BagSetupFrame:Hide()
end)

-- BagNameHeader
ns.BagSetupFrame.BagTitleHeader = ns.BagSetupFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
ns.BagSetupFrame.BagTitleHeader:SetText("Bag Title:")
ns.BagSetupFrame.BagTitleHeader:SetPoint("TOP", ns.BagSetupFrame.Title, "BOTTOM", 0, -spacing)

ns.BagSetupFrame.EditBoxBagTitle = CreateFrame("EditBox", nil, ns.BagSetupFrame, "InputBoxTemplate")
ns.BagSetupFrame.EditBoxBagTitle:SetAutoFocus(false)
ns.BagSetupFrame.EditBoxBagTitle:SetSize(165, 20)
ns.BagSetupFrame.EditBoxBagTitle:SetPoint("TOP", ns.BagSetupFrame.BagTitleHeader, "BOTTOM", 0, -5)

----------
-- Sliders

-- Slot slider
ns.BagSetupFrame.SlotSlider = libSliderEditBox(addonName .. className .. "SlotSlider", ns.BagSetupFrame, "Slots:", function(self, value)
	ns.BagSetupFrame.ColumnSlider:SetMinMaxValues(1, value)
end)
ns.BagSetupFrame.SlotSlider:SetSize(175, 40)
ns.BagSetupFrame.SlotSlider:SetPoint("TOP", ns.BagSetupFrame.EditBoxBagTitle, "BOTTOM", 0, -(padding + spacing))
ns.BagSetupFrame.SlotSlider:SetValue(1)

-- Column slider
ns.BagSetupFrame.ColumnSlider = libSliderEditBox(addonName .. className .. "ColumnSlider", ns.BagSetupFrame, "Columns:", nil)
ns.BagSetupFrame.ColumnSlider:SetSize(175, 40)
ns.BagSetupFrame.ColumnSlider:SetPoint("TOP", ns.BagSetupFrame.SlotSlider, "BOTTOM", 0, -(padding + spacing))
ns.BagSetupFrame.ColumnSlider:SetValue(1)

function ns.BagSetupFrame:ResetForms(slotVal, columnVal, title, bagFrame, bagFamily)
	self.BagFrame = bagFrame
	self.BagFamily = bagFamily

	self.SlotSlider:SetMinMaxValues(1, ns.SlotPools[self.BagFamily]:Count())
	self.SlotSlider:SetValue(slotVal)
	self.SlotSlider:SetEnable(true)
	if self.BagFrame then
		local configTable = self.BagFrame:GetConfigTable()
		if configTable.IsMasterBag then
			self.SlotSlider:SetEnable(false)
		end
	end

	self.ColumnSlider:SetMinMaxValues(1, slotVal)
	self.ColumnSlider:SetValue(columnVal)

	self.EditBoxBagTitle:SetText(title)	
end

function ns.BagSetupFrame:Open(bagframe, isEdit, bagFamily)
	if isEdit then
		local configTable = bagframe:GetConfigTable()
		self:ResetForms(#configTable.Slots, configTable.NumColumns, configTable.Title, bagframe, bagFamily)
		self.Title:SetText("Configure - " .. configTable.Title)
		self.BtnCreate:SetText("Apply")
	else
		local slotDefault = 1
		self:ResetForms(slotDefault, slotDefault, ns.BagFrame.DefaultConfigTable.Title, nil, bagFamily)
		self.Title:SetText("Create new bag")
		self.BtnCreate:SetText("Create")
	end

	self:Show()
end
