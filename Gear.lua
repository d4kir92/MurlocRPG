local _, ns = ...
local G = ns.Game
local SLOT_SIZE = 44
local SLOT_STEP = 52
local BAG_SLOT = 46
local BAG_STEP = 54
local BAG_COLS = 5
local BAG_SECTION_COLS = 3
local BAG_GAP = 26
local function SectionWidth(cols)
	return cols * BAG_SLOT + (cols - 1) * (BAG_STEP - BAG_SLOT)
end

local function BagSections()
	local sections = {
		{
			first = 1,
			count = ns.BAG_SIZE,
			cols = BAG_COLS
		},
	}

	local index = ns.BAG_SIZE + 1
	for _, slotKey in ipairs(ns.BAG_SLOT_ORDER) do
		local item = ns.ITEM_BY_ID[G:Equipped()[slotKey]]
		if item then
			local count = item.stats.slots or 0
			sections[#sections + 1] = {
				first = index,
				count = count,
				cols = BAG_SECTION_COLS,
				label = item.name
			}

			index = index + count
		end
	end
	return sections
end

local function LayoutBags(slots, headers, x0, yTop)
	local sections = BagSections()
	local x = x0
	local maxRows = 0
	local index = 1
	for i, section in ipairs(sections) do
		local header = i > 1 and headers[i - 1] or nil
		if header then
			header:ClearAllPoints()
			header:SetPoint("TOPLEFT", x, yTop + 20)
			header:SetText(section.label)
			header:Show()
		end

		for n = 1, section.count do
			local b = slots[index]
			if b then
				b:ClearAllPoints()
				b:SetPoint("TOPLEFT", x + ((n - 1) % section.cols) * BAG_STEP, yTop - math.floor((n - 1) / section.cols) * BAG_STEP)
				b:Show()
			end

			index = index + 1
		end

		maxRows = math.max(maxRows, math.ceil(section.count / section.cols))
		x = x + SectionWidth(section.cols) + BAG_GAP
	end

	for i = index, #slots do
		slots[i]:Hide()
	end

	for i = #sections, #headers do
		headers[i]:Hide()
	end

	return x - BAG_GAP - x0, maxRows * BAG_SLOT + (maxRows - 1) * (BAG_STEP - BAG_SLOT)
end

ns.LayoutBags = LayoutBags
local function MakeBagHeaders(parent)
	local headers = {}
	for i = 1, #ns.BAG_SLOT_ORDER do
		local text = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		text:SetJustifyH("LEFT")
		text:Hide()
		headers[i] = text
	end
	return headers
end

ns.MakeBagHeaders = MakeBagHeaders
local LEFT_SLOTS = {"HEAD", "NECK", "SHOULDER", "BACK", "CHEST", "WRISTS"}
local RIGHT_SLOTS = {"HANDS", "WAIST", "LEGS", "FEET", "FINGER1", "FINGER2"}
local WEAPON_SLOTS = {"MAINHAND", "OFFHAND"}
local function SlotName(slotKey, slotType)
	local slot = ns.SLOTS[slotKey or ""] or ns.SLOTS[slotType or ""]
	if slot then return ns:Trans(slot.name) end
	if slotType == "FINGER" then return ns:Trans("LID_SLOT_FINGER") end

	return slotType or ""
end

ns.SlotName = SlotName
local function CompareTooltip()
	if not ns.compareTooltip then
		ns.compareTooltip = CreateFrame("GameTooltip", "MurlocRPGCompareTooltip", UIParent, "GameTooltipTemplate")
	end

	return ns.compareTooltip
end

local function HideCompare()
	if ns.compareTooltip then ns.compareTooltip:Hide() end
end

ns.HideCompare = HideCompare
local function ShowCompare(item)
	HideCompare()
	if not item or not item.slotType then return end
	local slotKey = G:TargetSlot(item)
	local equipped = ns.ITEM_BY_ID[G:Equipped()[slotKey]]
	local tip = CompareTooltip()
	tip:SetOwner(UIParent, "ANCHOR_NONE")
	tip:ClearAllPoints()
	tip:SetPoint("TOPLEFT", GameTooltip, "TOPRIGHT", 4, 0)
	tip:ClearLines()
	tip:AddLine(ns:Trans("LID_CURRENTLY_EQUIPPED"), 1, 0.82, 0)
	if not equipped then
		tip:AddLine(SlotName(slotKey, item.slotType), 0.8, 0.8, 0.8)
		tip:AddLine(ns:Trans("LID_EMPTY_SLOT"), 0.6, 0.6, 0.6)
		tip:Show()

		return
	end

	local r, g, b = ns.ItemColor(equipped)
	tip:AddLine(equipped.name, r, g, b)
	tip:AddLine(SlotName(slotKey, equipped.slotType), 0.8, 0.8, 0.8)
	for _, line in ipairs(ns.ItemStatLines(equipped)) do
		tip:AddLine(line, 0.2, 1, 0.2)
	end

	tip:AddLine(format(ns:Trans("LID_ITEM_SLOT_REQ"), equipped.level), 0.7, 0.7, 0.7)
	if equipped.value and equipped.value > 0 then tip:AddLine(format(ns:Trans("LID_ITEM_VALUE"), ns.MoneyText(equipped.value)), 0.9, 0.85, 0.5) end
	tip:Show()
end

ns.ShowCompare = ShowCompare
local function BagUnequipWarning(item)
	if not item or item.slotType ~= "BAG" then return nil end
	if G:BagFits(item.id, nil, 1) then return nil end
	return ns:Trans("LID_BAG_KEEP")
end

local function BagSwapWarning(item)
	if not item or item.slotType ~= "BAG" then return nil end
	local previous = G:Equipped()[G:TargetSlot(item)]
	if not previous or G:BagFits(previous, item) then return nil end
	return ns:Trans("LID_BAG_KEEP")
end
local function ShowItemTooltip(button, item, hint, priceLabel, warning)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	if not item then
		GameTooltip:AddLine(button.slotLabel or ns:Trans("LID_EMPTY_SLOT"), 0.6, 0.6, 0.6)
		GameTooltip:Show()
		return
	end

	local r, g, b = ns.ItemColor(item)
	GameTooltip:AddLine(item.name, r, g, b)
	GameTooltip:AddLine(SlotName(button.slotKey, item.slotType), 0.8, 0.8, 0.8)
	for _, line in ipairs(ns.ItemStatLines(item)) do
		GameTooltip:AddLine(line, 0.2, 1, 0.2)
	end

	if (G.db.level or 1) < item.level then
		GameTooltip:AddLine(format(ns:Trans("LID_ITEM_SLOT_REQ"), item.level), 1, 0.2, 0.2)
	else
		GameTooltip:AddLine(format(ns:Trans("LID_ITEM_SLOT_REQ"), item.level), 0.7, 0.7, 0.7)
	end

	if item.value and item.value > 0 then GameTooltip:AddLine(format(priceLabel or ns:Trans("LID_ITEM_VALUE"), ns.MoneyText(item.value)), 0.9, 0.85, 0.5) end
	if warning then GameTooltip:AddLine(warning, 1, 0.2, 0.2, true) end
	if hint then GameTooltip:AddLine(hint, 0.5, 0.5, 0.5, true) end
	GameTooltip:Show()
end

ns.ShowItemTooltip = ShowItemTooltip
local function ItemSlot(parent, size, onClick)
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(size, size)
	b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	ns.Fill(b, 0, 0, 0, 0.85)
	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetPoint("TOPLEFT", 2, -2)
	b.icon:SetPoint("BOTTOMRIGHT", -2, 2)
	ns.Border(b, 0.3, 0.3, 0.3, 1)
	b:SetScript("OnClick", onClick)
	b:SetScript("OnLeave", function()
		GameTooltip:Hide()
		HideCompare()
	end)

	return b
end

ns.ItemSlot = ItemSlot
local Character = {}
ns.Character = Character
function Character:Create()
	if self.frame then return end
	local f = CreateFrame("Frame", "MurlocRPGCharacterFrame", UIParent)
	f:SetSize(340, 570)
	ns.LockScale(f)
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
	tinsert(UISpecialFrames, "MurlocRPGCharacterFrame")
	self.frame = f
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -3, -3)
	self.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.title:SetPoint("TOP", 0, -8)
	self.title:SetText(ns:Trans("LID_CHARACTER"))
	self.subtitle = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.subtitle:SetPoint("TOP", self.title, "BOTTOM", 0, -2)
	local stage = CreateFrame("Frame", nil, f)
	stage:SetPoint("TOPLEFT", 72, -60)
	stage:SetSize(196, 200)
	self.murk = ns.CreateSprite(stage, 150)
	self.murk:SetPos(98, 4)
	self.murk:SetFlip(false)
	self.murk:Play(ns.SPRITES.MURK_IDLE, 40, true)
	self.slots = {}
	local function MakeSlot(slotKey, x, y)
		local b = ItemSlot(f, SLOT_SIZE, function(self2)
			if G:Unequip(slotKey) then
				Character:Refresh()
				ns.Inventory:Refresh()
				ns.UI:Refresh()
				ns.RefreshTooltip(self2)
			end
		end)

		b:SetPoint("TOPLEFT", x, y)
		b.slotKey = slotKey
		b.slotLabel = ns:Trans(ns.SLOTS[slotKey].name)
		b:SetScript("OnEnter", function(self2)
			local item = ns.ITEM_BY_ID[G:Equipped()[slotKey]]
			ShowItemTooltip(self2, item, ns:Trans("LID_EQUIPPED_HINT"), nil, BagUnequipWarning(item))
		end)
		self.slots[slotKey] = b
	end

	for i, slotKey in ipairs(LEFT_SLOTS) do
		MakeSlot(slotKey, 12, -44 - (i - 1) * SLOT_STEP)
	end

	for i, slotKey in ipairs(RIGHT_SLOTS) do
		MakeSlot(slotKey, 340 - 12 - SLOT_SIZE, -44 - (i - 1) * SLOT_STEP)
	end

	local weaponWidth = #WEAPON_SLOTS * SLOT_SIZE + (#WEAPON_SLOTS - 1) * (SLOT_STEP - SLOT_SIZE)
	local weaponLeft = (340 - weaponWidth) / 2
	for i, slotKey in ipairs(WEAPON_SLOTS) do
		MakeSlot(slotKey, weaponLeft + (i - 1) * SLOT_STEP, -300)
	end

	local bagWidth = #ns.BAG_SLOT_ORDER * SLOT_SIZE + (#ns.BAG_SLOT_ORDER - 1) * (SLOT_STEP - SLOT_SIZE)
	local bagLeft = (340 - bagWidth) / 2
	for i, slotKey in ipairs(ns.BAG_SLOT_ORDER) do
		MakeSlot(slotKey, bagLeft + (i - 1) * SLOT_STEP, -352)
	end

	local statsHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	statsHeader:SetPoint("TOPLEFT", 14, -414)
	statsHeader:SetText(ns:Trans("LID_STATS"))
	self.statLabels = {}
	self.statValues = {}
	local keys = {"STAT_STR", "STAT_STM", "STAT_INT", "STAT_AGI", "STAT_HEALTH", "STAT_MANA", "STAT_DAMAGE", "STAT_CRIT", "STAT_ARMOR", "STAT_REGEN", "STAT_LIFESTEAL",}
	for i, key in ipairs(keys) do
		local column = (i - 1) % 2
		local row = math.floor((i - 1) / 2)
		local x = 20 + column * 160
		local y = -438 - row * 18
		local label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		label:SetPoint("TOPLEFT", x, y)
		label:SetText(ns:Trans("LID_" .. key))
		label:SetTextColor(0.7, 0.7, 0.7)
		local value = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		value:SetPoint("TOPLEFT", x + 96, y)
		value:SetJustifyH("RIGHT")
		value:SetWidth(56)
		local hover = CreateFrame("Frame", nil, f)
		hover:SetPoint("TOPLEFT", x - 4, y + 3)
		hover:SetSize(160, 16)
		hover:EnableMouse(true)
		ns.Tooltip(hover, ns:Trans("LID_" .. key), ns:Trans("LID_STATTIP_" .. key:gsub("^STAT_", "")))
		self.statLabels[i] = label
		self.statValues[i] = value
	end
end

function Character:Refresh()
	if not self.frame or not self.frame:IsShown() or not G:HasSave() then return end
	local class = G:Class()
	local s = G:Stats()
	local db = G.db
	self.subtitle:SetText(format("%s  -  %s  -  %s", G:Name(), class and ns:Trans(class.name) or "?", format(ns:Trans("LID_LEVEL"), db.level)))
	for slotKey, b in pairs(self.slots) do
		local item = ns.ITEM_BY_ID[G:Equipped()[slotKey]]
		if item then
			ns.SetIcon(b.icon, item.icon)
			b.icon:SetVertexColor(1, 1, 1)
			ns.SetBorderColor(b, ns.ItemColor(item))
		else
			ns.SetIcon(b.icon, ns.SLOTS[slotKey].empty)
			b.icon:SetVertexColor(0.55, 0.55, 0.55)
			ns.SetBorderColor(b, 0.3, 0.3, 0.3, 1)
		end
	end

	local values = {format("%d", s.str), format("%d", s.stm), format("%d", s.int), format("%d", s.agi), format("%d / %d", db.hp, s.maxHP), format("%d / %d", db.mp, s.maxMP), format("%d - %d", s.minDmg, s.maxDmg), format("%d%%", s.crit), format("%d", s.armor), format("%d", s.regen), format("%d%%", s.lifesteal),}
	for i, value in ipairs(values) do
		self.statValues[i]:SetText(value)
	end
end

function Character:Toggle()
	self:Create()
	if self.frame:IsShown() then
		self.frame:Hide()
		return
	end

	self.frame:ClearAllPoints()
	if ns.UI.frame and ns.UI.frame:IsShown() then
		self.frame:SetPoint("TOPRIGHT", ns.UI.frame, "TOPLEFT", -8, 0)
	else
		self.frame:SetPoint("CENTER")
	end

	self.frame:Show()
	self:Refresh()
end

function Character:Hide()
	if self.frame then self.frame:Hide() end
end

local Inventory = {}
ns.Inventory = Inventory
function Inventory:Create()
	if self.frame then return end
	local f = CreateFrame("Frame", "MurlocRPGInventoryFrame", UIParent)
	f:SetSize(300, 380)
	ns.LockScale(f)
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
	tinsert(UISpecialFrames, "MurlocRPGInventoryFrame")
	self.frame = f
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -3, -3)
	self.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.title:SetPoint("TOP", 0, -8)
	self.slots = {}
	for i = 1, ns.BAG_MAX_SIZE do
		local b = ItemSlot(f, BAG_SLOT, function(self2, button) Inventory:OnSlotClick(self2.bagIndex, button, self2) end)
		b.bagIndex = i
		b:SetScript("OnEnter", function(self2)
			local item = ns.ITEM_BY_ID[G:Bag()[self2.bagIndex]]
			ShowItemTooltip(self2, item, ns:Trans("LID_BAG_HINT"), nil, BagSwapWarning(item))
			ShowCompare(item)
		end)
		self.slots[i] = b
	end

	self.headers = MakeBagHeaders(f)
	self.hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	self.hint:SetPoint("BOTTOM", 0, 12)
	self.hint:SetWidth(276)
	self.hint:SetText(ns:Trans("LID_BAG_HINT"))
end

function Inventory:OnSlotClick(bagIndex, button, slot)
	if not G:Bag()[bagIndex] then return end
	if button == "RightButton" then
		if IsShiftKeyDown() and G:DestroyItem(bagIndex) then
			self:Refresh()
			ns.UI:Refresh()
			ns.RefreshTooltip(slot)
		end
		return
	end

	if G:Equip(bagIndex) then
		self:Refresh()
		ns.Character:Refresh()
		ns.UI:Refresh()
		ns.RefreshTooltip(slot)
	end
end

function Inventory:Refresh()
	if not self.frame or not self.frame:IsShown() or not G:HasSave() then return end
	local bag = G:Bag()
	local width, height = LayoutBags(self.slots, self.headers, 14, -58)
	self.frame:SetSize(width + 28, height + 100)
	self.hint:SetWidth(width)
	self.title:SetText(format(ns:Trans("LID_INVENTORY_TITLE"), #bag, G:BagSize()))
	for i, b in ipairs(self.slots) do
		local item = ns.ITEM_BY_ID[bag[i]]
		if item then
			ns.SetIcon(b.icon, item.icon)
			if (G.db.level or 1) < item.level then
				b.icon:SetVertexColor(1, 0.4, 0.4)
			else
				b.icon:SetVertexColor(1, 1, 1)
			end

			ns.SetBorderColor(b, ns.ItemColor(item))
		else
			ns.SetIcon(b.icon, "empty_inv_slot")
			b.icon:SetVertexColor(0.4, 0.4, 0.4)
			ns.SetBorderColor(b, 0.25, 0.25, 0.25, 1)
		end
	end
end

function Inventory:Toggle()
	self:Create()
	if self.frame:IsShown() then
		self.frame:Hide()
		return
	end

	ns.Talents:Hide()
	ns.Shop:Hide()
	ns.Quests:Hide()
	self.frame:ClearAllPoints()
	if ns.UI.frame and ns.UI.frame:IsShown() then
		self.frame:SetPoint("TOPLEFT", ns.UI.frame, "TOPRIGHT", 8, 0)
	else
		self.frame:SetPoint("CENTER")
	end

	self.frame:Show()
	G:ClearNewItems()
	self:Refresh()
	ns.UI:Refresh()
end

function Inventory:Hide()
	HideCompare()
	if self.frame then self.frame:Hide() end
end
