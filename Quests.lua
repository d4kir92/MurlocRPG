local _, ns = ...
local G = ns.Game
local WIDTH = 340
local PAD = 14
local TEXT_W = WIDTH - PAD * 2
local ICON = 36
local GAP = 8
local Quests = {}
ns.Quests = Quests
local TRACKS = {"main", "dungeon"}
local TRACK_TITLE = {
	main = "LID_Q_TRACK_MAIN",
	dungeon = "LID_Q_TRACK_DUNGEON"
}

local function HintText(q, progress)
	local hint = ns.QuestText(q, "HINT")
	local _, slots = hint:gsub("%%d", "")
	if slots >= 2 then return format(hint, progress, q.need) end
	if slots == 1 then return format(hint, progress) end
	return hint
end

local function Action(track)
	if G:QuestReady(track) then
		G:TurnInQuest(track)
	elseif G:QuestAvailable(track) then
		G:AcceptQuest(track)
	end

	Quests:Refresh()
end

local function SlotTooltip(self)
	if self.itemId then
		ns.ShowItemTooltip(self, ns.ITEM_BY_ID[self.itemId])
		return
	end

	local supply = self.supplyId and ns.CONSUMABLE_BY_ID[self.supplyId]
	if not supply then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(ns:Trans(supply.name), 1, 0.82, 0)
	GameTooltip:AddLine(ns:Trans(supply.desc), 1, 1, 1, true)
	GameTooltip:Show()
end

local function CreateBlock(parent, track)
	local b = {}
	b.header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	b.header:SetJustifyH("LEFT")
	b.name = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	b.name:SetWidth(TEXT_W)
	b.name:SetJustifyH("LEFT")
	b.text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	b.text:SetWidth(TEXT_W)
	b.text:SetJustifyH("LEFT")
	b.progress = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	b.progress:SetWidth(TEXT_W)
	b.progress:SetJustifyH("LEFT")
	b.reward = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	b.reward:SetWidth(TEXT_W - ICON - GAP)
	b.reward:SetJustifyH("LEFT")
	b.slot = ns.ItemSlot(parent, ICON)
	b.slot:SetScript("OnEnter", SlotTooltip)
	b.count = parent:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
	b.count:SetPoint("BOTTOMRIGHT", b.slot, "BOTTOMRIGHT", -3, 3)
	b.button = ns.MakeButton(parent, 170, 24, "", nil, function() Action(track) end)
	return b
end

function Quests:Create()
	if self.frame then return end
	local f = CreateFrame("Frame", "MurlocRPGQuestFrame", UIParent)
	f:SetSize(WIDTH, 420)
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
	tinsert(UISpecialFrames, "MurlocRPGQuestFrame")
	self.frame = f
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -3, -3)
	self.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.title:SetPoint("TOP", 0, -8)
	self.title:SetText(ns:Trans("LID_QUESTLOG_TITLE"))
	self.blocks = {}
	for _, track in ipairs(TRACKS) do
		self.blocks[track] = CreateBlock(f, track)
	end
end

local function Place(fontString, y, text, r, g, b)
	if not text or text == "" then
		fontString:Hide()
		return y
	end

	fontString:ClearAllPoints()
	fontString:SetPoint("TOPLEFT", PAD, -y)
	fontString:SetText(text)
	fontString:SetTextColor(r, g, b)
	fontString:Show()
	return y + fontString:GetStringHeight() + 4
end

function Quests:RefreshBlock(b, track, y)
	local q = G:CurrentQuest(track)
	local unlocked = G:QuestUnlocked(track)
	local active = G:QuestActive(track)
	local ready = G:QuestReady(track)
	y = Place(b.header, y, ns:Trans(TRACK_TITLE[track]), 1, 0.82, 0)
	if not q then
		y = Place(b.name, y, ns:Trans("LID_Q_ALL_DONE"), 0.6, 0.6, 0.6)
		b.text:Hide()
		b.progress:Hide()
		b.reward:Hide()
		b.slot:Hide()
		b.count:Hide()
		b.button:SetText(ns:Trans("LID_Q_TRACK_DONE"))
		ns.Enable(b.button, false)
	else
		local dim = not unlocked
		y = Place(b.name, y, ns.QuestText(q, "NAME"), dim and 0.6 or 1, dim and 0.6 or 0.82, dim and 0.6 or 0)
		if unlocked then
			y = Place(b.text, y, active and HintText(q, G:QuestProgress(track)) or ns.QuestText(q, "OFFER"), 0.85, 0.85, 0.85)
		else
			b.text:Hide()
		end

		if active then
			if ready then
				y = Place(b.progress, y, ns:Trans("LID_Q_LINE_READY"), 0.4, 1, 0.4)
			else
				y = Place(b.progress, y, format(ns:Trans("LID_Q_LINE_PROGRESS"), G:QuestProgress(track), q.need), 1, 0.82, 0)
			end
		else
			b.progress:Hide()
		end

		local rewards = {}
		if q.xp and q.xp > 0 then rewards[#rewards + 1] = format(ns:Trans("LID_Q_REWARD_XP"), q.xp) end
		if q.money and q.money > 0 then rewards[#rewards + 1] = ns.MoneyText(q.money) end
		local item = q.item and ns.ITEM_BY_ID[q.item]
		local supply = q.supply and ns.CONSUMABLE_BY_ID[q.supply.id]
		b.slot.itemId = item and item.id or nil
		b.slot.supplyId = supply and supply.id or nil
		if item or supply then
			b.slot:ClearAllPoints()
			b.slot:SetPoint("TOPLEFT", PAD, -y)
			ns.SetIcon(b.slot.icon, item and item.icon or supply.icon)
			if item then
				ns.SetBorderColor(b.slot, ns.ItemColor(item))
				b.count:Hide()
			else
				ns.SetBorderColor(b.slot, 0.3, 0.3, 0.3, 1)
				b.count:SetText(q.supply.count)
				b.count:Show()
			end

			b.slot:Show()
			b.reward:ClearAllPoints()
			b.reward:SetPoint("TOPLEFT", PAD + ICON + GAP, -y - 2)
			b.reward:SetText(format(ns:Trans("LID_Q_REWARDS"), table.concat(rewards, "  ")))
			b.reward:SetTextColor(0.9, 0.85, 0.5)
			b.reward:Show()
			y = y + math.max(ICON, b.reward:GetStringHeight() + 2) + 6
		else
			b.slot:Hide()
			b.count:Hide()
			b.reward:SetWidth(TEXT_W)
			y = Place(b.reward, y, format(ns:Trans("LID_Q_REWARDS"), table.concat(rewards, "  ")), 0.9, 0.85, 0.5)
			b.reward:SetWidth(TEXT_W - ICON - GAP)
		end

		if not unlocked then
			b.button:SetText(format(ns:Trans("LID_Q_LOCKED"), q.level or 1))
			ns.Enable(b.button, false)
		elseif ready then
			b.button:SetText(ns:Trans("LID_Q_TURNIN"))
			ns.Enable(b.button, true)
		elseif active then
			b.button:SetText(ns:Trans("LID_Q_RUNNING"))
			ns.Enable(b.button, false)
		else
			b.button:SetText(ns:Trans("LID_Q_ACCEPT"))
			ns.Enable(b.button, true)
		end
	end

	b.button:ClearAllPoints()
	b.button:SetPoint("TOPLEFT", PAD, -y)
	return y + 24 + 14
end

function Quests:Refresh()
	if not self.frame or not G:HasSave() then return end
	local y = 38
	for _, track in ipairs(TRACKS) do
		y = self:RefreshBlock(self.blocks[track], track, y)
	end

	self.frame:SetHeight(y + PAD)
end

function Quests:Toggle()
	self:Create()
	if self.frame:IsShown() then
		self.frame:Hide()
		return
	end

	ns.Talents:Hide()
	ns.Inventory:Hide()
	ns.Character:Hide()
	ns.Shop:Hide()
	self.frame:ClearAllPoints()
	if ns.UI.frame and ns.UI.frame:IsShown() then
		self.frame:SetPoint("TOPLEFT", ns.UI.frame, "TOPRIGHT", 8, 0)
	else
		self.frame:SetPoint("CENTER")
	end

	self.frame:Show()
	self:Refresh()
	ns.Sound("IG_QUEST_LIST_OPEN")
end

function Quests:Hide()
	if self.frame then self.frame:Hide() end
end
