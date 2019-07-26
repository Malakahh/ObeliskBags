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
ns.BagSetupFrame:SetSize(300, 200)
ns.BagSetupFrame:SetFrameStrata("TOOLTIP")
ns.BagSetupFrame:EnableMouse(true)
ns.BagSetupFrame:SetScript("OnShow", function(self)
	self:ResetForms()
end)
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
ns.BagSetupFrame.BtnCreate:SetText("Create")
ns.BagSetupFrame.BtnCreate:SetScript("OnClick", function(btn)
	local bagConfig = ns.Util.Table.Copy(ns.BagFrame.DefaultConfigTable)
	bagConfig.NumColumns = ns.BagSetupFrame.ColumnSlider:GetValue()
	bagConfig.Slots = ns.BagSetupFrame.SlotSlider:GetValue()
	bagConfig.Title = ns.BagSetupFrame.EditBoxBagTitle:GetText()
	ns.BagFrame:New(bagConfig)
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
ns.BagSetupFrame.ColumnSlider:SetPoint("TOP", ns.BagSetupFrame.SlotSlider, "BOTTOM", 0, - spacing)
ns.BagSetupFrame.ColumnSlider:SetValue(1)

function ns.BagSetupFrame:ResetForms()
	local slotDefault = 1
	self.SlotSlider:SetMinMaxValues(1, ns.InventorySlotPool:Count())
	self.SlotSlider:SetValue(slotDefault)

	self.ColumnSlider:SetMinMaxValues(1, slotDefault)
	self.ColumnSlider:SetValue(1)

	self.EditBoxBagTitle:SetText("My Custom Bag")
end

function ns.BagSetupFrame:Open(bagframe, isEdit)
	if isEdit then
		self:ResetForms()
		self.Title:SetText("Edit - " .. bagframe.Title:GetText())
	else
		self:ResetForms()
		self.Title:SetText("Create new bag")
	end

	self:Show()
end
