local _, ns = ...
local G = ns.Game
local T = {}
ns.Talents = T
local ICON = 46
local ROW_STEP = 66
local COL_X = {88, 208}
local GRID_TOP = -74
function T:Create()
	if self.frame then return end
	local f = CreateFrame("Frame", "MurlocRPGTalentFrame", UIParent)
	f:SetSize(296, 470)
	f:SetFrameStrata("DIALOG")
	f:SetClampedToScreen(true)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:Hide()
	ns.Fill(f, 0.05, 0.06, 0.09, 0.97)
	ns.Border(f, 0.45, 0.35, 0.15, 1)
	tinsert(UISpecialFrames, "MurlocRPGTalentFrame")
	self.frame = f
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -3, -3)
	self.tabs = {}
	for i = 1, 2 do
		local tab = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
		tab:SetSize(128, 22)
		tab:SetPoint("TOPLEFT", 8 + (i - 1) * 132, -8)
		tab:SetScript("OnClick", function()
			T.activeTree = i
			T:Refresh()
		end)

		self.tabs[i] = tab
	end

	self.pointsText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.pointsText:SetPoint("TOPLEFT", 12, -40)
	self.spentText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.spentText:SetPoint("TOPRIGHT", -12, -40)
	self.links = {}
	self.buttons = {}
	for i = 1, 10 do
		local tier = math.ceil(i / 2)
		local column = (i - 1) % 2
		local b = ns.IconButton(f, ICON, nil, function() T:OnTalentClick(i) end)
		b:SetPoint("TOPLEFT", COL_X[column + 1] - ICON / 2, GRID_TOP - (tier - 1) * ROW_STEP)
		b.talentIndex = i
		self.buttons[i] = b
		if tier < 5 then
			local link = f:CreateTexture(nil, "ARTWORK")
			link:SetSize(5, ROW_STEP - ICON)
			link:SetPoint("TOP", b, "BOTTOM", 0, 0)
			link:SetColorTexture(0.85, 0.75, 0.1, 1)
			self.links[i] = link
		end
	end

	self.resetButton = ns.MakeButton(f, 100, 22, ns:Trans("LID_TALENT_RESET"), nil, function()
		G:ResetTalents()
		T:Refresh()
		ns.UI:Refresh()
	end)

	self.resetButton:SetPoint("BOTTOM", 0, 10)
	self.activeTree = 1
end

function T:Tree()
	local class = G:Class()
	if not class then return nil end
	return class.trees[self.activeTree or 1]
end

function T:OnTalentClick(index)
	local tree = self:Tree()
	if not tree then return end
	if G:LearnTalent(self.activeTree, tree.talents[index]) then
		self:Refresh()
		ns.UI:Refresh()
	end
end

function T:Refresh()
	if not self.frame or not self.frame:IsShown() then return end
	local class = G:Class()
	if not class then return end
	self.activeTree = self.activeTree or 1
	for i, tab in ipairs(self.tabs) do
		local tree = class.trees[i]
		tab:SetText(format("%s (%d)", tree.name, G:TreeSpent(i)))
		if i == self.activeTree then
			tab:LockHighlight()
		else
			tab:UnlockHighlight()
		end
	end

	local tree = class.trees[self.activeTree]
	self.pointsText:SetText(format(ns:Trans("LID_TALENT_POINTS"), G:TalentPoints()))
	self.spentText:SetText(format(ns:Trans("LID_TALENT_SPENT"), tree.name, G:TreeSpent(self.activeTree)))
	for i, b in ipairs(self.buttons) do
		local talent = tree.talents[i]
		ns.SetIcon(b.icon, talent.icon)
		local known = G:HasTalent(self.activeTree, i)
		local canLearn = G:CanLearn(self.activeTree, talent)
		local unlocked = G:TreeSpent(self.activeTree) >= talent.tier - 1
		local extra
		if known then
			b.icon:SetVertexColor(1, 1, 1)
			ns.SetBorderColor(b, 1, 0.82, 0, 1)
			extra = "Learned."
		elseif canLearn then
			b.icon:SetVertexColor(1, 1, 1)
			ns.SetBorderColor(b, 0.2, 1, 0.2, 1)
			extra = "Click to learn."
		else
			b.icon:SetVertexColor(0.35, 0.35, 0.35)
			ns.SetBorderColor(b, 0.3, 0.3, 0.3, 1)
			if not unlocked then
				extra = format(ns:Trans("LID_TALENT_NEED"), talent.tier - 1, tree.name)
			else
				extra = ns:Trans("LID_TALENT_NONE")
			end
		end

		ns.Tooltip(b, talent.name, ns.TalentDesc(talent), extra)
		ns.RefreshTooltip(b)
		local link = self.links[i]
		if link then
			if G:HasTalent(self.activeTree, i) then
				link:SetColorTexture(0.95, 0.85, 0.15, 1)
			else
				link:SetColorTexture(0.3, 0.28, 0.12, 1)
			end
		end
	end

	ns.Enable(self.resetButton, G:TalentSpent() > 0)
end

function T:Toggle()
	self:Create()
	if self.frame:IsShown() then
		self.frame:Hide()
		return
	end

	ns.Inventory:Hide()
	ns.Shop:Hide()
	self.frame:ClearAllPoints()
	if ns.UI.frame and ns.UI.frame:IsShown() then
		self.frame:SetPoint("TOPLEFT", ns.UI.frame, "TOPRIGHT", 8, 0)
	else
		self.frame:SetPoint("CENTER")
	end

	self.frame:Show()
	self:Refresh()
end

function T:Hide()
	if self.frame then self.frame:Hide() end
end
