local addonName, ns = ...

local libGridView = ObeliskFrameworkManager:GetLibrary("ObeliskGridView", 1)
if not libGridView then
	print("libGridView not gotten")
end

local frame = CreateFrame("FRAME")
frame:SetPoint("CENTER")
frame:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4}
	})
frame:SetBackdropColor(0, 0, 0, 1)
frame:SetClampedToScreen(true)

frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
frame:RegisterEvent("PLAYER_LOGIN")

local cellSize = 32

frame.gridView = libGridView(0, 0, nil, frame)
frame.gridView:SetPoint("TOPLEFT", 0, 0)
frame.gridView:SetPoint("BOTTOMRIGHT", 0, 0)
frame.gridView:SetCellSize(cellSize, cellSize)

function frame:PLAYER_LOGIN( ... )
	local cnt = ns.ContainerSlotManager.slotStack:Count()
	print("count: " .. cnt)
	self:SetSize(4 * cellSize, math.ceil(cnt / 4) * cellSize)
	self.gridView:SetNumColumns(4)

	local i = 0

	for _, v in pairs(ns.ContainerSlotManager.slotStack.items) do
		i = i + 1
		if i < 2 then			
			v:SetID(0)
			self.gridView:AddItem(v)
		end
	end

	self.gridView:Update()

	for _, v in pairs(ns.ContainerSlotManager.slotStack.items) do
		v:SetSize(cellSize, cellSize)
		v:SetScale(1)
	end
end

