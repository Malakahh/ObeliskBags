local addonName, ns = ...
local className = "BagSetupFrame"

ns.BagSetupFrame = CreateFrame("FRAME", addonName .. className, UIParent)

local padding = 9
local spacing = 12

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
	--ns.BagFrame.Spawn(ns.BagSetupFrame.ColumnSlider:GetValue(), ns.BagSetupFrame.SlotSlider:GetValue())
	local bagConfig = ns.Util.Table.Copy(ns.BagFrame.DefaultConfigTable)
	bagConfig.NumColumns = ns.BagSetupFrame.ColumnSlider:GetValue()
	bagConfig.Slots = ns.BagSetupFrame.SlotSlider:GetValue()
	ns.BagFrame:New(bagConfig)
	ns.BagSetupFrame:Hide()
end)

----------
-- Sliders

-- Slot slider
ns.BagSetupFrame.SlotSlider = CreateFrame("Slider", addonName .. className .. "SlotSlider", ns.BagSetupFrame, "OptionsSliderTemplate")
ns.BagSetupFrame.SlotSlider.CurrentText = ns.BagSetupFrame.SlotSlider:CreateFontString(nil, "ARTWORK", "OptionsFontSmall")
ns.BagSetupFrame.SlotSlider.CurrentText:SetPoint("TOP", ns.BagSetupFrame.SlotSlider, "BOTTOM", 0, 0)
ns.BagSetupFrame.SlotSlider:SetOrientation("HORIZONTAL")
ns.BagSetupFrame.SlotSlider:SetSize(115, 20)
ns.BagSetupFrame.SlotSlider:SetPoint("TOPRIGHT", ns.BagSetupFrame.Title, "BOTTOM", -spacing, -(padding + spacing))
ns.BagSetupFrame.SlotSlider:SetObeyStepOnDrag(true)
ns.BagSetupFrame.SlotSlider:SetValueStep(1)
ns.BagSetupFrame.SlotSlider:SetScript("OnValueChanged", function(self, value)
	self.CurrentText:SetText(value)

	ns.BagSetupFrame.ColumnSlider:SetMinMaxValues(1, value)
	_G[ns.BagSetupFrame.ColumnSlider:GetName() .. "High"]:SetText(value)
end)
ns.BagSetupFrame.SlotSlider:SetValue(1)
_G[ns.BagSetupFrame.SlotSlider:GetName() .. "Text"]:SetText("Slots:")

-- Column slider
ns.BagSetupFrame.ColumnSlider = CreateFrame("Slider", addonName .. className .. "ColumnSlider", ns.BagSetupFrame, "OptionsSliderTemplate")
ns.BagSetupFrame.ColumnSlider.CurrentText = ns.BagSetupFrame.ColumnSlider:CreateFontString(nil, "ARTWORK", "OptionsFontSmall")
ns.BagSetupFrame.ColumnSlider.CurrentText:SetPoint("TOP", ns.BagSetupFrame.ColumnSlider, "BOTTOM", 0, 0)
ns.BagSetupFrame.ColumnSlider:SetOrientation("HORIZONTAL")
ns.BagSetupFrame.ColumnSlider:SetSize(115, 20)
ns.BagSetupFrame.ColumnSlider:SetPoint("TOPLEFT", ns.BagSetupFrame.Title, "BOTTOM", spacing, -(padding + spacing))
ns.BagSetupFrame.ColumnSlider:SetObeyStepOnDrag(true)
ns.BagSetupFrame.ColumnSlider:SetValueStep(1)
ns.BagSetupFrame.ColumnSlider:SetScript("OnValueChanged", function(self, value)
	self.CurrentText:SetText(value)
end)
ns.BagSetupFrame.ColumnSlider:SetValue(1)
_G[ns.BagSetupFrame.ColumnSlider:GetName() .. "Text"]:SetText("Columns:")


function ns.BagSetupFrame:ResetForms()
	local slotDefault = 1
	self.SlotSlider:SetMinMaxValues(1, ns.InventorySlotPool:Count())
	_G[ns.BagSetupFrame.SlotSlider:GetName() .. "Low"]:SetText(1)
	_G[ns.BagSetupFrame.SlotSlider:GetName() .. "High"]:SetText(ns.InventorySlotPool:Count())
	self.SlotSlider:SetValue(slotDefault)

	self.ColumnSlider:SetMinMaxValues(1, 1)
	_G[ns.BagSetupFrame.ColumnSlider:GetName() .. "Low"]:SetText(1)
	_G[ns.BagSetupFrame.ColumnSlider:GetName() .. "High"]:SetText(slotDefault)
	self.ColumnSlider:SetValue(1)
end

function ns.BagSetupFrame:Open(bagframe, isEdit)
	if isEdit then
		self:ResetForms()
		ns.BagSetupFrame.Title:SetText("Edit - " .. bagframe.Title:GetText())
	else
		self:ResetForms()
		ns.BagSetupFrame.Title:SetText("New Bag")
	end


end
