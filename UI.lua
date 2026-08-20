local _, ns = ...
local G = ns.Game
local C = ns.Combat
local UI = {}
ns.UI = UI
local SCENE_W = 692
local SCENE_H = 300
local GROUND = 38
local SPRITE_SIZE = 150
local MURK_CAMP_X = 167
local BRAKIL_X = 389
local MERCHANT_X = 556
local MURK_FIGHT_X = 160
local ENEMY_X = 500
local LOAD_TIME = 0.96
local BATTLE_ICON = 62
local BG_LEFT = 0.2404
local BG_RIGHT = 0.7596
local function SetShown(frame, shown)
	if shown then
		frame:Show()
	else
		frame:Hide()
	end
end

local function PageBackground(page, texture)
	local bg = page:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(page)
	bg:SetTexture(texture)
	bg:SetTexCoord(BG_LEFT, BG_RIGHT, 0, 1)
	return bg
end

StaticPopupDialogs["MURLOCRPG_DELETE_SLOT"] = {
	text = "%s",
	button1 = YES,
	button2 = NO,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	showAlert = true,
	preferredIndex = 3,
	OnAccept = function(_, data)
		G:DeleteSlot(data)
		ns.Sound("IG_QUEST_FAILED")
		UI:RefreshMenu()
	end,
}

function UI:UpdateLogJump()
	if not self.logJumpButton or not self.log then return end
	local atBottom = true
	if self.log.AtBottom then atBottom = self.log:AtBottom() end
	ns.Enable(self.logJumpButton, not atBottom)
end

function UI:Log(msg, r, g, b)
	if not self.log then return end
	self.log:AddMessage(msg, r or 1, g or 1, b or 1)
	self:UpdateLogJump()
end

function UI:Create()
	if self.frame then return end
	local f = CreateFrame("Frame", "MurlocRPGFrame", UIParent)
	f:SetSize(720, 720)
	f:SetPoint("CENTER")
	f:SetFrameStrata("HIGH")
	f:SetClampedToScreen(true)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:SetScript("OnHide", function() UI:HideWindows() end)
	f:Hide()
	ns.Fill(f, 0.04, 0.09, 0.08, 0.96)
	ns.Border(f, 0.25, 0.55, 0.45, 1)
	tinsert(UISpecialFrames, "MurlocRPGFrame")
	self.frame = f
	self.busy = false
	self.transition = false
	self.mode = nil
	self.pages = {}
	self.titleText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.titleText:SetPoint("TOP", 0, -8)
	self.titleText:SetText(ns:Trans("LID_TITLE"))
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -3, -3)
	local area = CreateFrame("Frame", nil, f)
	area:SetPoint("TOPLEFT", 8, -34)
	area:SetSize(704, 678)
	self.area = area
	self:CreateMenuPage(area)
	self:CreateLoadingPage(area)
	self:CreateClassPage(area)
	self:CreateWorldPage(area)
	self:CreateGameOverPage(area)
	self:ShowPage("menu")
end

function UI:ShowPage(name)
	for key, page in pairs(self.pages) do
		SetShown(page, key == name)
	end

	self.current = name
	SetShown(self.titleText, name ~= "menu")
	if name ~= "world" then self:HideWindows() end
	if name == "menu" then
		self:RefreshMenu()
	elseif name == "class" then
		self:RefreshClassPage()
	elseif name == "world" then
		self:Refresh()
	end
end

function UI:HideWindows()
	ns.Talents:Hide()
	ns.Character:Hide()
	ns.Inventory:Hide()
	ns.Shop:Hide()
end

function UI:CreateMenuPage(parent)
	local p = CreateFrame("Frame", nil, parent)
	p:SetAllPoints(parent)
	p:Hide()
	self.pages.menu = p
	local bg = PageBackground(p, ns.BG_WORLD)
	bg:SetVertexColor(0.5, 0.5, 0.55)
	local logo = p:CreateTexture(nil, "ARTWORK")
	logo:SetSize(440, 220)
	logo:SetPoint("TOP", 0, -60)
	logo:SetTexture(ns.TITLE_ART)
	local sub = p:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	sub:SetPoint("TOP", logo, "BOTTOM", 0, 4)
	sub:SetText(ns:Trans("LID_SUBTITLE"))
	self.slotButtons = {}
	self.slotDeletes = {}
	for i = 1, ns.SAVE_SLOTS do
		local b = ns.MakeButton(p, 260, 34, "", nil, function() UI:PickSlot(i) end)
		b:SetPoint("TOP", sub, "BOTTOM", -21, -46 - (i - 1) * 44)
		local del = ns.MakeButton(p, 34, 34, "X", nil, function() UI:ConfirmDeleteSlot(i) end)
		del:SetPoint("LEFT", b, "RIGHT", 8, 0)
		if del.GetFontString and del:GetFontString() then del:GetFontString():SetTextColor(1, 0.35, 0.35) end
		ns.Tooltip(del, ns:Trans("LID_DELETE_SAVE"), ns:Trans("LID_DELETE_SAVE_TIP"))
		self.slotButtons[i] = b
		self.slotDeletes[i] = del
	end
end

function UI:RefreshMenu()
	for i, b in ipairs(self.slotButtons) do
		local used = G:SlotUsed(i)
		if used then
			local slot = G:SlotData(i)
			local class = ns.CLASS_BY_ID[slot.class]
			b:SetText(G:SlotName(i))
			ns.Tooltip(b, G:SlotName(i), format("%s  -  %s", class and ns:Trans(class.name) or "?", format(ns:Trans("LID_LEVEL"), slot.level or 1)), slot.hardcore and ns:Trans("LID_HARDCORE") or nil)
		else
			b:SetText(ns:Trans("LID_NEW_GAME"))
			ns.Tooltip(b, ns:Trans("LID_NEW_GAME"), nil)
		end

		SetShown(self.slotDeletes[i], used)
	end
end

function UI:PickSlot(index)
	G:SelectSlot(index)
	if G:HasSave() then
		self:StartLoading("world")
	else
		self:ResetCharName()
		self:ShowPage("class")
	end
end

function UI:ConfirmDeleteSlot(index)
	StaticPopup_Show("MURLOCRPG_DELETE_SLOT", format(ns:Trans("LID_DELETE_CONFIRM"), G:SlotName(index)), nil, index)
end

function UI:CreateLoadingPage(parent)
	local p = CreateFrame("Frame", nil, parent)
	p:SetAllPoints(parent)
	p:Hide()
	self.pages.loading = p
	local fill = p:CreateTexture(nil, "BACKGROUND")
	fill:SetAllPoints(p)
	fill:SetColorTexture(0, 0, 0, 1)
	local bg = p:CreateTexture(nil, "BACKGROUND", nil, 1)
	bg:SetPoint("CENTER")
	bg:SetSize(704, 352)
	bg:SetTexture(ns.BG_LOADING)
	self.loadBar = ns.Bar(p, 500, 22, 0.2, 0.45, 0.9)
	self.loadBar:SetPoint("BOTTOM", 0, 56)
	ns.Border(self.loadBar, 0.5, 0.45, 0.3, 1)
	local text = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	text:SetPoint("BOTTOM", self.loadBar, "TOP", 0, 8)
	text:SetText(ns:Trans("LID_LOADING"))
	p:SetScript("OnUpdate", function(_, elapsed)
		if UI.current ~= "loading" then return end
		UI.loadTime = (UI.loadTime or 0) + elapsed
		local pct = math.min(1, UI.loadTime / LOAD_TIME)
		ns.SetBar(UI.loadBar, pct, 1, format("%d%%", math.floor(pct * 100)))
		if pct >= 1 then
			local target = UI.loadTarget
			local fresh = UI.loadFresh
			UI.loadTarget = nil
			UI.loadFresh = false
			if target == "world" then
				UI:EnterWorld(fresh)
			elseif target then
				UI:ShowPage(target)
			end
		end
	end)
end

function UI:StartLoading(target, fresh)
	self.loadTarget = target
	self.loadFresh = fresh and true or false
	self.loadTime = 0
	ns.SetBar(self.loadBar, 0, 1, "0%")
	self:ShowPage("loading")
end

function UI:CreateClassPage(parent)
	local p = CreateFrame("Frame", nil, parent)
	p:SetAllPoints(parent)
	p:Hide()
	self.pages.class = p
	local bg = PageBackground(p, ns.BG_WORLD)
	bg:SetVertexColor(0.75, 0.75, 0.8)
	local header = p:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	header:SetPoint("TOP", 0, -6)
	header:SetText(ns:Trans("LID_CHOOSE_CLASS"))
	self.classButtons = {}
	for i, class in ipairs(ns.CLASSES) do
		local b = CreateFrame("Button", nil, p)
		b:SetSize(180, 54)
		b:SetPoint("TOPLEFT", 12, -44 - (i - 1) * 60)
		ns.Fill(b, 0, 0, 0, 0.55)
		ns.Border(b, 0.3, 0.3, 0.3, 1)
		b.icon = b:CreateTexture(nil, "ARTWORK")
		b.icon:SetSize(44, 44)
		b.icon:SetPoint("LEFT", 5, 0)
		ns.SetIcon(b.icon, class.icon)
		b.label = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		b.label:SetPoint("LEFT", b.icon, "RIGHT", 8, 0)
		b.label:SetText(ns:Trans(class.name))
		b.classIndex = i
		b:SetScript("OnClick", function()
			UI.selectedClass = i
			UI:RefreshClassPage()
			ns.Sound("IG_CHARACTER_INFO_TAB")
		end)

		self.classButtons[i] = b
	end

	local stage = CreateFrame("Frame", nil, p)
	stage:SetSize(180, 190)
	stage:SetPoint("TOPLEFT", 206, -60)
	self.classMurk = ns.CreateSprite(stage, SPRITE_SIZE)
	self.classMurk:SetPos(90, 8)
	self.classMurk:SetFlip(false)
	self.classMurk:Play(ns.SPRITES.MURK_IDLE, 40, true)
	local info = CreateFrame("Frame", nil, p)
	info:SetSize(300, 360)
	info:SetPoint("TOPRIGHT", -12, -44)
	ns.Fill(info, 0, 0, 0, 0.65)
	ns.Border(info, 0.45, 0.35, 0.15, 1)
	self.classTitle = info:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.classTitle:SetPoint("TOP", 0, -10)
	self.classDesc = info:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.classDesc:SetPoint("TOPLEFT", 12, -44)
	self.classDesc:SetWidth(276)
	self.classDesc:SetJustifyH("LEFT")
	self.classDesc:SetJustifyV("TOP")
	local skills = info:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	skills:SetPoint("BOTTOMLEFT", 12, 74)
	skills:SetText(ns:Trans("LID_SKILLS"))
	self.classSkills = {}
	for i = 1, 3 do
		local b = ns.IconButton(info, 52, nil)
		b:SetPoint("BOTTOMLEFT", 12 + (i - 1) * 60, 14)
		self.classSkills[i] = b
	end

	local nameBox = CreateFrame("EditBox", nil, p, "InputBoxTemplate")
	nameBox:SetSize(180, 22)
	nameBox:SetPoint("BOTTOM", 24, 92)
	nameBox:SetAutoFocus(false)
	nameBox:SetMaxLetters(12)
	nameBox:SetText(ns.DEFAULT_NAME)
	nameBox:SetScript("OnEscapePressed", function(self2) self2:ClearFocus() end)
	nameBox:SetScript("OnEnterPressed", function(self2) self2:ClearFocus() end)
	nameBox:SetScript("OnTextChanged", function() UI:RefreshNameState() end)
	local nameLabel = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	nameLabel:SetPoint("RIGHT", nameBox, "LEFT", -8, 0)
	nameLabel:SetText(ns:Trans("LID_CHAR_NAME"))
	self.nameBox = nameBox
	local hardcore = CreateFrame("CheckButton", nil, p, "UICheckButtonTemplate")
	hardcore:SetSize(26, 26)
	hardcore:SetPoint("BOTTOM", 0, 56)
	hardcore:SetChecked(false)
	hardcore.label = hardcore:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	hardcore.label:SetPoint("LEFT", hardcore, "RIGHT", 4, 0)
	hardcore.label:SetText(ns:Trans("LID_HARDCORE"))
	hardcore.label:SetTextColor(1, 0.4, 0.4)
	ns.Tooltip(hardcore, ns:Trans("LID_HARDCORE"), ns:Trans("LID_HARDCORE_HINT"))
	hardcore:SetScript("OnClick", function(self2)
		UI.hardcore = self2:GetChecked() and true or false
		ns.Sound("IG_MAINMENU_OPTION_CHECKBOX_ON")
	end)

	self.hardcoreCheck = hardcore
	self.enterButton = ns.MakeButton(p, 240, 34, ns:Trans("LID_ENTER_WORLD"), nil, function()
		G:NewGame(ns.CLASSES[UI.selectedClass or 1].id, UI.hardcore, UI:CharName())
		UI:StartLoading("world", true)
	end)

	self.enterButton:SetPoint("BOTTOM", 0, 16)
end

function UI:CharName()
	local name = self.nameBox and strtrim(self.nameBox:GetText()) or ""
	return name ~= "" and name or ns.DEFAULT_NAME
end

function UI:ResetCharName()
	if not self.nameBox then return end
	self.nameBox:SetText(ns.DEFAULT_NAME)
	self.nameBox:ClearFocus()
end

function UI:RefreshNameState()
	if not self.enterButton or not self.nameBox then return end
	ns.Enable(self.enterButton, strtrim(self.nameBox:GetText()) ~= "")
end

function UI:CreateGameOverPage(parent)
	local p = CreateFrame("Frame", nil, parent)
	p:SetAllPoints(parent)
	p:Hide()
	self.pages.gameover = p
	local bg = PageBackground(p, ns.BG_WORLD)
	bg:SetVertexColor(0.35, 0.3, 0.3)
	local header = p:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	header:SetPoint("TOP", 0, -70)
	header:SetText(ns:Trans("LID_GAMEOVER_TITLE"))
	header:SetTextColor(1, 0.4, 0.4)
	self.overHint = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.overHint:SetPoint("TOP", header, "BOTTOM", 0, -6)
	self.overHint:SetText(ns:Trans("LID_GAMEOVER_HINT"))
	self.overHint:SetTextColor(0.8, 0.7, 0.7)
	self.overScore = p:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.overScore:SetPoint("TOP", self.overHint, "BOTTOM", 0, -24)
	self.overScore:SetTextColor(1, 0.82, 0)
	local box = CreateFrame("Frame", nil, p)
	box:SetSize(360, 150)
	box:SetPoint("TOP", self.overScore, "BOTTOM", 0, -18)
	ns.Fill(box, 0, 0, 0, 0.65)
	ns.Border(box, 0.45, 0.35, 0.15, 1)
	self.overLines = {}
	for i = 1, 5 do
		local line = box:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		line:SetPoint("TOPLEFT", 16, -14 - (i - 1) * 26)
		line:SetJustifyH("LEFT")
		self.overLines[i] = line
	end

	self.overNewButton = ns.MakeButton(p, 240, 34, ns:Trans("LID_GAMEOVER_NEW_CHAR"), nil, function()
		G:DeleteSave()
		UI:ResetCharName()
		UI:ShowPage("class")
	end)

	self.overNewButton:SetPoint("BOTTOM", -125, 40)
	self.overNormalButton = ns.MakeButton(p, 240, 34, ns:Trans("LID_GAMEOVER_SWITCH_NORMAL"), nil, function()
		G:DisableHardcore()
		UI:StartLoading("world")
	end)

	self.overNormalButton:SetPoint("BOTTOM", 125, 40)
end

function UI:ShowGameOver(summary)
	self.busy = false
	self.transition = false
	self.mode = nil
	self:HidePanels()
	self.overScore:SetText(format(ns:Trans("LID_SCORE"), summary.score))
	self.overLines[1]:SetText(format(ns:Trans("LID_RUN_LEVEL"), summary.level))
	self.overLines[2]:SetText(format(ns:Trans("LID_RUN_QUESTS"), summary.questsDone, summary.questTotal))
	self.overLines[3]:SetText(format(ns:Trans("LID_RUN_KILLS"), summary.kills))
	self.overLines[4]:SetText(format(ns:Trans("LID_RUN_MONEY"), ns.MoneyText(summary.earned)))
	self.overLines[5]:SetText(format(ns:Trans("LID_RUN_KILLED_BY"), summary.killedBy and ns:Trans(summary.killedBy) or "?"))
	ns.Sound("IG_QUEST_FAILED")
	self:ShowPage("gameover")
end

function UI:RefreshClassPage()
	self.selectedClass = self.selectedClass or 1
	self.hardcoreCheck:SetChecked(self.hardcore and true or false)
	self:RefreshNameState()
	local class = ns.CLASSES[self.selectedClass]
	for i, b in ipairs(self.classButtons) do
		if i == self.selectedClass then
			ns.SetBorderColor(b, 1, 0.82, 0, 1)
			b.label:SetTextColor(1, 0.82, 0)
		else
			ns.SetBorderColor(b, 0.3, 0.3, 0.3, 1)
			b.label:SetTextColor(0.8, 0.8, 0.8)
		end
	end

	self.classTitle:SetText(ns:Trans(class.name))
	self.classDesc:SetText(ns:Trans(class.desc))
	for i, b in ipairs(self.classSkills) do
		local a = class.abilities[i]
		if a then
			b:Show()
			ns.SetIcon(b.icon, a.icon)
			ns.Tooltip(b, ns:Trans(a.name), ns.AbilityDesc(a), format("%s  %s", format(ns:Trans("LID_COST"), a.cost), format(ns:Trans("LID_LOCKED"), a.level)))
		else
			b:Hide()
		end
	end
end

function UI:CreateWorldPage(parent)
	local p = CreateFrame("Frame", nil, parent)
	p:SetAllPoints(parent)
	p:Hide()
	self.pages.world = p
	local portrait = CreateFrame("Frame", nil, p)
	portrait:SetSize(48, 48)
	portrait:SetPoint("TOPLEFT", 6, -4)
	ns.Fill(portrait, 0, 0, 0, 0.5)
	ns.Border(portrait, 0.35, 0.6, 0.5, 1)
	self.portrait = ns.CreateSprite(portrait, 46)
	self.portrait:SetPoint("CENTER")
	self.portrait:SetFlip(false)
	self.portrait:Play(ns.SPRITES.MURK_IDLE, 10, true)
	self.nameText = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.nameText:SetPoint("TOPLEFT", portrait, "TOPRIGHT", 8, 0)
	self.nameText:SetText(G:Name())
	self.levelText = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.levelText:SetPoint("LEFT", self.nameText, "RIGHT", 8, 0)
	self.hpBar = ns.Bar(p, 260, 12, 0.15, 0.65, 0.2)
	self.hpBar:SetPoint("TOPLEFT", portrait, "TOPRIGHT", 8, -16)
	self.mpBar = ns.Bar(p, 260, 12, 0.2, 0.4, 0.85)
	self.mpBar:SetPoint("TOPLEFT", self.hpBar, "BOTTOMLEFT", 0, -2)
	self.xpBar = ns.Bar(p, 260, 8, 0.55, 0.2, 0.65)
	self.xpBar:SetPoint("TOPLEFT", self.mpBar, "BOTTOMLEFT", 0, -2)
	self.moneyText = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.moneyText:SetPoint("TOPRIGHT", -6, -8)
	self.moneyText:SetJustifyH("RIGHT")
	self.bagText = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.bagText:SetPoint("TOPRIGHT", self.moneyText, "BOTTOMRIGHT", 0, -4)
	self.bagText:SetJustifyH("RIGHT")
	self.questText = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	self.questText:SetPoint("TOPRIGHT", self.bagText, "BOTTOMRIGHT", 0, -4)
	self.questText:SetJustifyH("RIGHT")
	self:CreateScene(p)
	self:CreateActions(p)
	local log = CreateFrame("ScrollingMessageFrame", nil, p)
	log:SetPoint("TOPLEFT", self.actions, "BOTTOMLEFT", 2, -6)
	log:SetSize(688, 138)
	log:SetFontObject(GameFontHighlightSmall)
	log:SetJustifyH("LEFT")
	log:SetFading(false)
	log:SetMaxLines(200)
	log:EnableMouseWheel(true)
	log:SetScript("OnMouseWheel", function(self2, delta)
		if delta > 0 then
			self2:ScrollUp()
		else
			self2:ScrollDown()
		end

		UI:UpdateLogJump()
	end)

	if log.SetInsertMode then log:SetInsertMode("BOTTOM") end
	self.log = log
	local jump = ns.MakeButton(p, 120, 20, ns:Trans("LID_LOG_LATEST"), nil, function()
		log:ScrollToBottom()
		UI:UpdateLogJump()
	end)

	jump:SetPoint("TOPRIGHT", log, "BOTTOMRIGHT", 0, -2)
	ns.Tooltip(jump, ns:Trans("LID_LOG_LATEST"), ns:Trans("LID_LOG_LATEST_TIP"))
	self.logJumpButton = jump
	self:UpdateLogJump()
end

function UI:CreateScene(parent)
	local scene = CreateFrame("Frame", nil, parent)
	scene:SetPoint("TOPLEFT", 6, -60)
	scene:SetSize(SCENE_W, SCENE_H)
	self.scene = scene
	if scene.SetClipsChildren then scene:SetClipsChildren(true) end
	local bg = scene:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(scene)
	bg:SetTexture(ns.SCENE_SHORE)
	bg:SetTexCoord(0, 1, 0.08, 0.92)
	self.sceneBG = bg
	ns.Border(scene, 0.2, 0.4, 0.35, 1)
	local function CampProp(file, x, size, y)
		local t = scene:CreateTexture(nil, "BORDER")
		t:SetTexture(file)
		t:SetSize(size, size)
		t:SetPoint("BOTTOM", scene, "BOTTOMLEFT", x, y)
		t:Hide()
		return t
	end

	self.campProps = {CampProp(ns.CAMP_HUT, 88, 150, GROUND + 6), CampProp(ns.CAMP_TENT, BRAKIL_X, 195, GROUND + 8), CampProp(ns.CAMP_HUT, 638, 125, GROUND + 4),}
	self.campLabel = scene:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.campLabel:SetPoint("TOP", 0, -8)
	self.streakText = scene:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.streakText:SetPoint("TOPRIGHT", -8, -8)
	self.streakText:SetJustifyH("RIGHT")
	self.streakText:SetTextColor(1, 0.65, 0.2)
	self.streakText:Hide()
	self.campLabel:SetText(ns:Trans("LID_CAMP_TITLE"))
	self.brakil = ns.CreateSprite(scene, SPRITE_SIZE)
	self.brakil:SetPos(BRAKIL_X, GROUND)
	self.brakil:Play(ns.SPRITES.BRAKIL_IDLE, 12, true)
	self.brakilName = scene:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	self.brakilName:SetPoint("BOTTOM", scene, "BOTTOMLEFT", BRAKIL_X, GROUND - 12)
	self.brakilName:SetText(ns:Trans("LID_BRAKIL"))
	local brakilHit = CreateFrame("Button", nil, scene)
	brakilHit:SetSize(110, 150)
	brakilHit:SetPoint("BOTTOM", scene, "BOTTOMLEFT", BRAKIL_X, GROUND)
	brakilHit:SetFrameLevel(scene:GetFrameLevel() + 20)
	brakilHit:SetScript("OnClick", function() UI:Talk() end)
	brakilHit:SetScript("OnEnter", function(self2)
		UI.brakil.texture:SetVertexColor(1.25, 1.25, 1.25)
		GameTooltip:SetOwner(self2, "ANCHOR_RIGHT")
		GameTooltip:AddLine(ns:Trans("LID_BRAKIL"), 1, 0.82, 0)
		GameTooltip:AddLine(ns:Trans("LID_TALK"), 1, 1, 1)
		local quest = G:CurrentQuest()
		if not quest then
			GameTooltip:AddLine(ns:Trans("LID_Q_ALL_DONE"), 0.6, 0.6, 0.6)
		elseif G.db.quest ~= "active" then
			GameTooltip:AddLine(format(ns:Trans("LID_Q_LINE_NEW"), ns.QuestText(quest, "NAME")), 1, 0.82, 0)
		elseif G:QuestReady() then
			GameTooltip:AddLine(format(ns:Trans("LID_Q_LINE_DONE"), ns.QuestText(quest, "NAME")), 0.4, 1, 0.4)
		else
			GameTooltip:AddLine(format(ns:Trans("LID_Q_LINE"), ns.QuestText(quest, "NAME"), G:QuestProgress(), quest.need), 1, 0.82, 0)
		end

		GameTooltip:Show()
	end)

	brakilHit:SetScript("OnLeave", function()
		UI.brakil.texture:SetVertexColor(1, 1, 1)
		GameTooltip:Hide()
	end)

	self.brakilHit = brakilHit
	self.merchant = ns.CreateSprite(scene, SPRITE_SIZE)
	self.merchant:SetPos(MERCHANT_X, GROUND)
	self.merchant:Play(ns.SPRITES.GOBLIN_IDLE, 8, true)
	self.merchantName = scene:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	self.merchantName:SetPoint("BOTTOM", scene, "BOTTOMLEFT", MERCHANT_X, GROUND - 12)
	self.merchantName:SetText(ns:Trans("LID_SHOP_TITLE"))
	local merchantHit = CreateFrame("Button", nil, scene)
	merchantHit:SetSize(82, 150)
	merchantHit:SetPoint("BOTTOM", scene, "BOTTOMLEFT", MERCHANT_X, GROUND)
	merchantHit:SetFrameLevel(scene:GetFrameLevel() + 20)
	merchantHit:SetScript("OnClick", function() ns.Shop:Toggle() end)
	merchantHit:SetScript("OnEnter", function(self2)
		UI.merchant.texture:SetVertexColor(1.25, 1.25, 1.25)
		GameTooltip:SetOwner(self2, "ANCHOR_RIGHT")
		GameTooltip:AddLine(ns:Trans("LID_SHOP_TITLE"), 1, 0.82, 0)
		GameTooltip:AddLine(ns:Trans("LID_CLICK_MERCHANT"), 1, 1, 1)
		GameTooltip:Show()
	end)

	merchantHit:SetScript("OnLeave", function()
		UI.merchant.texture:SetVertexColor(1, 1, 1)
		GameTooltip:Hide()
	end)

	self.merchantHit = merchantHit
	self.healer = ns.CreateSprite(scene, SPRITE_SIZE)
	self.healer:SetPos(ENEMY_X, GROUND)
	self.healer:Play(ns.SPRITES.BRAKIL_IDLE, 12, true)
	self.healer:SetTint(0.6, 0.88, 1)
	self.healer:Hide()
	self.healerName = scene:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	self.healerName:SetPoint("BOTTOM", scene, "BOTTOMLEFT", ENEMY_X, GROUND - 12)
	self.healerName:SetText(ns:Trans("LID_SPIRIT_HEALER"))
	self.healerName:SetTextColor(0.6, 0.88, 1)
	self.healerName:Hide()
	local healerHit = CreateFrame("Button", nil, scene)
	healerHit:SetSize(110, 150)
	healerHit:SetPoint("BOTTOM", scene, "BOTTOMLEFT", ENEMY_X, GROUND)
	healerHit:SetFrameLevel(scene:GetFrameLevel() + 20)
	healerHit:Hide()
	healerHit:SetScript("OnClick", function() UI:DoResurrect() end)
	healerHit:SetScript("OnEnter", function(self2)
		UI.healer:SetTint(0.85, 1, 1)
		GameTooltip:SetOwner(self2, "ANCHOR_RIGHT")
		GameTooltip:AddLine(ns:Trans("LID_SPIRIT_HEALER"), 0.6, 0.88, 1)
		GameTooltip:AddLine(ns:Trans("LID_HEALER_HINT"), 1, 1, 1)
		GameTooltip:Show()
	end)

	healerHit:SetScript("OnLeave", function()
		UI.healer:SetTint(0.6, 0.88, 1)
		GameTooltip:Hide()
	end)

	self.healerHit = healerHit
	self.enemy = ns.CreateSprite(scene, SPRITE_SIZE)
	self.enemy:SetPos(ENEMY_X, GROUND)
	self.enemy:Hide()
	self.murk = ns.CreateSprite(scene, SPRITE_SIZE)
	self.murk:SetPos(MURK_CAMP_X, GROUND)
	self.murk:SetFlip(false)
	self.murk:Play(ns.SPRITES.MURK_IDLE, 40, true)
	local murkHit = CreateFrame("Button", nil, scene)
	murkHit:SetAllPoints(self.murk)
	murkHit:SetFrameLevel(scene:GetFrameLevel() + 20)
	murkHit:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	murkHit:SetScript("OnClick", function(_, button)
		if UI.busy then return end
		if button == "RightButton" then
			ns.Inventory:Toggle()
		else
			ns.Character:Toggle()
		end
	end)

	murkHit:SetScript("OnEnter", function(self2)
		GameTooltip:SetOwner(self2, "ANCHOR_RIGHT")
		GameTooltip:AddLine(G:Name(), 1, 0.82, 0)
		GameTooltip:AddLine(ns:Trans("LID_MURK_HINT"), 1, 1, 1, true)
		GameTooltip:Show()
	end)

	murkHit:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.murkHit = murkHit
	self.fx = ns.CreateSprite(scene, 177)
	self.fx:SetPos(ENEMY_X, GROUND + 18)
	self.fx:SetFrameLevel(scene:GetFrameLevel() + 30)
	self.fx:Hide()
	self.enemyName = scene:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.enemyName:SetPoint("TOP", scene, "TOPLEFT", ENEMY_X, -10)
	self.enemyBar = ns.Bar(scene, 160, 12, 0.75, 0.2, 0.2)
	self.enemyBar:SetPoint("TOP", self.enemyName, "BOTTOM", 0, -3)
	for _, sprite in ipairs({self.brakil, self.merchant, self.healer, self.enemy, self.murk}) do
		sprite:SetFrameLevel(scene:GetFrameLevel() + 5)
	end
end

function UI:CreateActions(parent)
	local area = CreateFrame("Frame", nil, parent)
	area:SetPoint("TOPLEFT", self.scene, "BOTTOMLEFT", 0, -8)
	area:SetSize(SCENE_W, 136)
	self.actions = area
	local camp = CreateFrame("Frame", nil, area)
	camp:SetAllPoints(area)
	self.campActions = camp
	local talents = ns.MakeButton(camp, 339, 28, ns:Trans("LID_TALENTS"), "Ability_Marksmanship", function() ns.Talents:Toggle() end)
	talents:SetPoint("TOPLEFT", 4, -2)
	ns.Tooltip(talents, ns:Trans("LID_TALENTS"), ns:Trans("LID_TIP_TALENTS"))
	self.talentsButton = talents
	local character = ns.MakeButton(camp, 339, 28, ns:Trans("LID_CHARACTER"), "Murloc_icon", function() ns.Character:Toggle() end)
	character:SetPoint("LEFT", talents, "RIGHT", 8, 0)
	ns.Tooltip(character, ns:Trans("LID_CHARACTER"), ns:Trans("LID_TIP_CHARACTER"))
	self.characterButton = character
	local inventory = ns.MakeButton(camp, 339, 28, ns:Trans("LID_INVENTORY"), "Inv_misc_bag_08", function() ns.Inventory:Toggle() end)
	inventory:SetPoint("TOPLEFT", talents, "BOTTOMLEFT", 0, -6)
	ns.Tooltip(inventory, ns:Trans("LID_INVENTORY"), ns:Trans("LID_TIP_INVENTORY"))
	self.inventoryButton = inventory
	local shop = ns.MakeButton(camp, 339, 28, ns:Trans("LID_SHOP"), "gold_coin_icon", function() ns.Shop:Toggle() end)
	shop:SetPoint("LEFT", inventory, "RIGHT", 8, 0)
	ns.Tooltip(shop, ns:Trans("LID_SHOP"), ns:Trans("LID_TIP_SHOP"))
	self.shopButton = shop
	local rest = ns.MakeButton(camp, 339, 28, ns:Trans("LID_REST"), "Spell_nature_regeneration", function() UI:Rest() end)
	rest:SetPoint("TOPLEFT", inventory, "BOTTOMLEFT", 0, -6)
	ns.Tooltip(rest, ns:Trans("LID_REST"), ns:Trans("LID_TIP_REST"))
	self.restButton = rest
	local hunt = ns.MakeButton(camp, 339, 28, ns:Trans("LID_HUNT"), "stealth", function() UI:StartHunt() end)
	hunt:SetPoint("LEFT", rest, "RIGHT", 8, 0)
	ns.Tooltip(hunt, ns:Trans("LID_HUNT"), ns:Trans("LID_TIP_HUNT"))
	self.huntButton = hunt
	local dungeon = ns.MakeButton(camp, 339, 28, ns:Trans("LID_DUNGEON"), "Ability_Creature_Cursed_02", function() UI:StartDungeon() end)
	dungeon:SetPoint("TOPLEFT", rest, "BOTTOMLEFT", 0, -6)
	self.dungeonButton = dungeon
	local logout = ns.MakeButton(camp, 339, 28, ns:Trans("LID_LOGOUT"), "rune_of_teleportation_icon", function() UI:Logout() end)
	logout:SetPoint("LEFT", dungeon, "RIGHT", 8, 0)
	ns.Tooltip(logout, ns:Trans("LID_LOGOUT"), ns:Trans("LID_TIP_LOGOUT"))
	self.logoutButton = logout
	local battle = CreateFrame("Frame", nil, area)
	battle:SetAllPoints(area)
	battle:Hide()
	self.battleActions = battle
	local step = BATTLE_ICON + 8
	local abilityEnd = 4 + 4 * step - 8
	local fleeStart = SCENE_W - 4 - BATTLE_ICON
	local supplySpan = #ns.CONSUMABLES * step - 8
	local supplyStart = math.floor(abilityEnd + (fleeStart - abilityEnd - supplySpan) / 2)
	local function BattleIconSlot(button, index)
		button:SetPoint("TOPLEFT", 4 + (index - 1) * step, -2)
	end

	local function BattleSupplySlot(button, index)
		button:SetPoint("TOPLEFT", supplyStart + (index - 1) * step, -2)
	end

	local attack = ns.MakeSquareButton(battle, BATTLE_ICON, "INV_Sword_06", function() UI:PlayerStrike(function() C:Attack() end) end)
	BattleIconSlot(attack, 1)
	ns.Tooltip(attack, ns:Trans("LID_ACT_ATTACK"), ns:Trans("LID_ATTACK_DESC"))
	self.attackButton = attack
	self.abilityButtons = {}
	for i = 1, 3 do
		local b = ns.MakeSquareButton(battle, BATTLE_ICON, nil, function(self2) UI:CastAbility(self2.ability) end)
		BattleIconSlot(b, i + 1)
		self.abilityButtons[i] = b
	end

	self.supplyButtons = {}
	for i, supply in ipairs(ns.CONSUMABLES) do
		local b = ns.MakeSquareButton(battle, BATTLE_ICON, supply.icon, function() UI:SimpleAction(function() C:UseSupply(supply.id) end) end)
		BattleSupplySlot(b, i)
		b.supply = supply
		self.supplyButtons[i] = b
	end

	local flee = ns.MakeSquareButton(battle, BATTLE_ICON, "vanish", function() UI:SimpleAction(function() C:Flee() end) end)
	flee:SetPoint("TOPRIGHT", -4, -2)
	ns.Tooltip(flee, ns:Trans("LID_ACT_FLEE"), ns:Trans("LID_FLEE_DESC"))
	self.fleeButton = flee
	local victory = CreateFrame("Frame", nil, area)
	victory:SetAllPoints(area)
	victory:Hide()
	self.victoryActions = victory
	local back = ns.MakeButton(victory, 686, 28, ns:Trans("LID_RETURN_CAMP"), "Spell_nature_regeneration", function() UI:ReturnToCamp() end)
	back:SetPoint("TOPLEFT", 4, -104)
	ns.Tooltip(back, ns:Trans("LID_RETURN_CAMP"), ns:Trans("LID_TIP_RETURN"))
	self.returnButton = back
	local nextEnemy = ns.MakeButton(victory, 686, 28, ns:Trans("LID_NEXT_ENEMY"), "stealth", function() UI:NextEnemy() end)
	nextEnemy:SetPoint("TOPLEFT", 4, -70)
	ns.Tooltip(nextEnemy, ns:Trans("LID_NEXT_ENEMY"), ns:Trans("LID_TIP_NEXT"), ns:Trans("LID_STREAK_TIP"))
	self.nextEnemyButton = nextEnemy
	local dead = CreateFrame("Frame", nil, area)
	dead:SetAllPoints(area)
	dead:Hide()
	self.deadActions = dead
	local resurrect = ns.MakeButton(dead, 339, 28, ns:Trans("LID_RESURRECT"), "ancestralspirit", function() UI:DoResurrect() end)
	resurrect:SetPoint("TOP", 0, -18)
	ns.Tooltip(resurrect, ns:Trans("LID_RESURRECT"), ns:Trans("LID_TIP_RESURRECT"))
	self.resurrectButton = resurrect
end

function UI:SetSceneBG(file)
	if self.sceneBG then self.sceneBG:SetTexture(file) end
end

function UI:SetCampProps(shown)
	for _, prop in ipairs(self.campProps) do
		SetShown(prop, shown)
	end
end

function UI:HidePanels()
	self.campActions:Hide()
	self.battleActions:Hide()
	self.victoryActions:Hide()
	self.deadActions:Hide()
end

function UI:HideHealer()
	self.healer:Hide()
	self.healerName:Hide()
	self.healerHit:Hide()
end

function UI:EnterWorld(fresh)
	self.busy = false
	self.transition = false
	G.battle = nil
	G.turnLocked = false
	G.victory = false
	G.dungeon = false
	G:ResetStreak()
	self.mode = G.db.dead and "dead" or "camp"
	if self.mode == "dead" then
		self:ShowDead()
	else
		self:ShowCamp()
	end

	self:ShowPage("world")
	if fresh then
		self:Log(ns:Trans("LID_CAMP_TEXT"), 0.7, 0.8, 0.75)
		self:Log(ns:Trans("LID_CLICK_BRAKIL"), 0.6, 0.6, 0.6)
	end
end

function UI:FadeOutEnemy()
	self.enemy:StopMove()
	self.enemyName:Hide()
	self.enemyBar:Hide()
	if self.enemy:IsShown() then self.enemy:Fade(self.enemy:GetAlpha(), 0, 0.5, function(sp) sp:Hide() end) end
end

function UI:ShowCamp()
	self:HidePanels()
	self:HideHealer()
	self:SetSceneBG(ns.BG_CAMP)
	self.campActions:Show()
	self.campLabel:Show()
	self.brakil:Show()
	self.brakilName:Show()
	self.brakilHit:Show()
	self.merchant:Show()
	self.merchantName:Show()
	self.merchantHit:Show()
	self:SetCampProps(true)
	self:FadeOutEnemy()
	self.murk:StopMove()
	self.murk:SetAlpha(1)
	self.murk:SetTint(1, 1, 1)
	self.murk:SetPos(MURK_CAMP_X, GROUND)
	self.murk:SetFlip(false)
	self.murk:Play(ns.SPRITES.MURK_IDLE, 40, true)
end

function UI:EnterBattle(chained)
	self.busy = true
	self:HideWindows()
	self:HidePanels()
	self:HideHealer()
	self.battleActions:Show()
	self:SetSceneBG(G.dungeon and ns.BG_DUNGEON or ns.SCENE_SHORE)
	self.campLabel:Hide()
	self.brakil:Hide()
	self.brakilName:Hide()
	self.brakilHit:Hide()
	self.merchant:Hide()
	self.merchantName:Hide()
	self.merchantHit:Hide()
	self:SetCampProps(false)
	local enemy = G.battle
	self.enemy:StopMove()
	self.enemy:SetDisplaySize(SPRITE_SIZE * (enemy.scale or 1))
	self.enemy:SetPos(ENEMY_X, GROUND)
	self.enemy:Show()
	self.enemy:Play(ns.SPRITES[enemy.sprite], 10, true)
	self.enemy:Fade(0, 1, 0.4)
	self.enemyName:Show()
	self.enemyBar:Show()
	self.murk:SetAlpha(1)
	self.murk:SetTint(1, 1, 1)
	self.murk:SetFlip(false)
	if chained then
		self.murk:StopMove()
		self.murk:SetPos(MURK_FIGHT_X, GROUND)
		self.murk:Play(ns.SPRITES.MURK_IDLE, 40, true)
		C_Timer.After(0.45, function()
			UI.busy = false
			UI:Refresh()
		end)
	else
		self.murk:StopMove()
		self.murk:SetPos(-110, GROUND)
		self.murk:Play(ns.SPRITES.MURK_WALK, 16, true)
		self.murk:MoveTo(MURK_FIGHT_X, 1.1, function(sp)
			sp:Play(ns.SPRITES.MURK_IDLE, 10, true)
			UI.busy = false
			UI:Refresh()
		end)
	end
end

function UI:ShowVictory()
	self:HidePanels()
	self:HideHealer()
	self.victoryActions:Show()
	self:FadeOutEnemy()
end

function UI:ShowDead()
	self:HidePanels()
	self.deadActions:Show()
	self:SetSceneBG(ns.SCENE_SHORE)
	self:FadeOutEnemy()
	self.campLabel:Hide()
	self.brakil:Hide()
	self.brakilName:Hide()
	self.brakilHit:Hide()
	self.merchant:Hide()
	self.merchantName:Hide()
	self.merchantHit:Hide()
	self:SetCampProps(false)
	self.murk:StopMove()
	self.murk:SetPos(MURK_FIGHT_X, GROUND)
	self.murk:SetFlip(false)
	self.murk:Play(ns.SPRITES.MURK_IDLE, 40, true)
	self.murk:SetTint(0.55, 0.78, 1)
	self.murk:SetAlpha(0.55)
	self.healer:StopMove()
	self.healer:SetPos(ENEMY_X, GROUND)
	self.healer:SetTint(0.6, 0.88, 1)
	self.healer:Show()
	self.healer:Fade(0, 0.9, 0.8)
	self.healerName:Show()
	self.healerHit:Show()
	self.busy = false
end

function UI:EnterMode(mode)
	local previous = self.mode
	self.mode = mode
	self.fx:Hide()
	if mode == "battle" then
		self:EnterBattle(previous == "victory")
	elseif mode == "victory" then
		self:ShowVictory()
	elseif mode == "dead" then
		self:ShowDead()
	else
		self:ShowCamp()
	end
end

function UI:NextEnemy()
	if self.busy then return end
	C:Start()
end

function UI:Logout()
	if self.busy or self.transition then return end
	self:HidePanels()
	self:HideWindows()
	G.battle = nil
	G.turnLocked = false
	G.victory = false
	G.dungeon = false
	G:ResetStreak()
	self.mode = nil
	ns.Sound("IG_CHARACTER_INFO_CLOSE")
	self:ShowPage("menu")
end

function UI:ReturnToCamp()
	if self.busy then return end
	self.busy = true
	self.transition = true
	self:HidePanels()
	self.murk:SetFlip(true)
	self.murk:Play(ns.SPRITES.MURK_WALK, 16, true)
	self.murk:MoveTo(-100, 1.3, function()
		G.victory = false
		G.dungeon = false
		G:ResetStreak()
		UI.transition = false
		UI.busy = false
		UI:EnterMode("camp")
		UI:Refresh()
	end)
end

function UI:DoResurrect()
	if self.busy or not G.db.dead then return end
	self.busy = true
	self.transition = true
	self:HidePanels()
	G:Resurrect()
	self.healer:Fade(self.healer:GetAlpha(), 0, 0.6, function(sp) sp:Hide() end)
	self.healerName:Hide()
	self.healerHit:Hide()
	self.murk:SetTint(1, 1, 1)
	self.murk:Fade(0.55, 1, 0.6)
	self.murk:SetFlip(true)
	self.murk:Play(ns.SPRITES.MURK_WALK, 16, true)
	self.murk:MoveTo(-100, 1.3, function()
		UI.transition = false
		UI.busy = false
		UI:EnterMode("camp")
		UI:Refresh()
	end)
end

function UI:StartHunt()
	if self.busy or G.battle then return end
	self.busy = true
	self:HideWindows()
	self.murk:SetFlip(false)
	self.murk:Play(ns.SPRITES.MURK_WALK, 16, true)
	self.murk:MoveTo(SCENE_W + 100, 1.5, function() C:Start() end)
	self:Refresh()
end

function UI:StartDungeon()
	if self.busy or G.battle then return end
	if (G.db.level or 1) < ns.DUNGEON_LEVEL then return end
	G.dungeon = true
	self:Log(ns:Trans("LID_DUNGEON_TEXT"), 0.75, 0.6, 1)
	self:StartHunt()
end

function UI:Talk()
	if self.busy or G.battle then return end
	G:TalkToBrakil()
end

function UI:Rest()
	if self.busy or G.battle then return end
	G:Rest()
end

function UI:AttackSprite()
	if G:HasWeapon() then return ns.SPRITES.MURK_ATTACK_WEAPON end
	return ns.SPRITES.MURK_ATTACK
end

function UI:PlayEffect(ability)
	local def = ability.fx and ns.SPRITES[ability.fx]
	if not def then return end
	self.fx:StopMove()
	self.fx:SetPos(ability.kind == "heal" and MURK_FIGHT_X or ENEMY_X, GROUND + 16)
	self.fx:SetAlpha(1)
	self.fx:Show()
	self.fx:Play(def, 18, false, function(sp) sp:Hide() end)
end

function UI:CastAbility(ability)
	if not ability then return end
	if ability.school == "magic" then
		self:CastSpell(ability)
		return
	end

	self:PlayerStrike(function() C:UseAbility(ability) end)
end

function UI:CastSpell(ability)
	if self.busy or not C:CanAct() then return end
	self.busy = true
	self:Refresh()
	self.murk:Play(ns.SPRITES.MURK_CAST, 16, false, function(sp) sp:Play(ns.SPRITES.MURK_IDLE, 10, true) end)
	C_Timer.After(0.5, function()
		if not C:CanAct() then
			UI.busy = false
			UI:Refresh()
			return
		end

		UI:PlayEffect(ability)
		C:UseAbility(ability)
		if ability.kind ~= "heal" and UI.enemy:IsShown() then UI.enemy:Flash() end
		UI.busy = false
		UI:Refresh()
	end)
end

function UI:PlayerStrike(action)
	if self.busy or not C:CanAct() then return end
	self.busy = true
	self:Refresh()
	self.murk:Play(self:AttackSprite(), 20, false, function(sp) sp:Play(ns.SPRITES.MURK_IDLE, 10, true) end)
	self.murk:MoveTo(MURK_FIGHT_X + 90, 0.24, function()
		action()
		if UI.enemy:IsShown() then UI.enemy:Flash() end
		UI.murk:MoveTo(MURK_FIGHT_X, 0.34, function()
			UI.busy = false
			UI:Refresh()
		end)
	end)
end

function UI:SimpleAction(action)
	if self.busy or not C:CanAct() then return end
	action()
	self:Refresh()
end

function UI:EnemyLunge()
	if self.mode ~= "battle" or not self.enemy:IsShown() then return end
	self.enemy:MoveTo(ENEMY_X - 110, 0.18, function(sp)
		UI.murk:Flash()
		sp:MoveTo(ENEMY_X, 0.3)
	end)
end

function UI:RefreshAbilityButtons(canAct)
	local class = G:Class()
	for i, b in ipairs(self.abilityButtons) do
		local a = class and class.abilities[i]
		b.ability = a
		if not a then
			b:Hide()
		else
			b:Show()
			ns.SetIcon(b.icon, a.icon)
			local cost = G:AbilityCost(a)
			local known = G.db.level >= a.level
			if known then
				ns.Tooltip(b, ns:Trans(a.name), ns.AbilityDesc(a), format(ns:Trans("LID_COST"), cost))
				ns.Enable(b, canAct and G.db.mp >= cost)
			else
				ns.Tooltip(b, ns:Trans(a.name), ns.AbilityDesc(a), format(ns:Trans("LID_LOCKED"), a.level))
				ns.Enable(b, false)
			end

			ns.RefreshTooltip(b)
		end
	end
end

function UI:Refresh()
	if not self.frame or not G:HasSave() then return end
	local db = G.db
	local s = G:Stats()
	local mode = "camp"
	if G.battle then
		mode = "battle"
	elseif db.dead then
		mode = "dead"
	elseif G.victory then
		mode = "victory"
	end

	if mode ~= self.mode and not self.transition then self:EnterMode(mode) end
	local class = G:Class()
	local hardcoreTag = G:Hardcore() and format("  |cffff4040%s|r", ns:Trans("LID_HARDCORE")) or ""
	local charName = G:Name()
	self.nameText:SetText((class and format("%s  |cff9ad8ff%s|r", charName, ns:Trans(class.name)) or charName) .. hardcoreTag)
	self.levelText:SetText(format(ns:Trans("LID_LEVEL"), db.level))
	ns.SetBar(self.hpBar, db.hp, s.maxHP, format(ns:Trans("LID_BARTEXT"), db.hp, s.maxHP))
	ns.SetBar(self.mpBar, db.mp, s.maxMP, format(ns:Trans("LID_BARTEXT"), db.mp, s.maxMP))
	if G:IsMaxLevel() then
		ns.SetBar(self.xpBar, 1, 1, ns:Trans("LID_XP_MAX"))
	else
		ns.SetBar(self.xpBar, db.xp, G:XPMax(), format(ns:Trans("LID_XP"), db.xp, G:XPMax()))
	end

	self.moneyText:SetText(ns.MoneyText(G:Money()))
	self.bagText:SetText(format(ns:Trans("LID_BAG"), db.meat))
	local quest = G:CurrentQuest()
	if quest and db.quest == "active" then
		self.questText:SetText(format(ns:Trans("LID_Q_LINE"), ns.QuestText(quest, "NAME"), G:QuestProgress(), quest.need))
		if G:QuestReady() then
			self.questText:SetTextColor(0.4, 1, 0.4)
		else
			self.questText:SetTextColor(1, 0.82, 0)
		end
	elseif quest then
		self.questText:SetText(format(ns:Trans("LID_Q_LINE_NEW"), ns.QuestText(quest, "NAME")))
		self.questText:SetTextColor(1, 0.82, 0)
	else
		self.questText:SetText(ns:Trans("LID_Q_ALL_DONE"))
		self.questText:SetTextColor(0.6, 0.6, 0.6)
	end

	local idle = not self.busy
	local points = G:TalentPoints()
	ns.Enable(self.huntButton, idle)
	ns.Enable(self.restButton, idle)
	ns.Enable(self.talentsButton, idle)
	ns.Enable(self.characterButton, idle)
	ns.Enable(self.inventoryButton, idle)
	ns.Enable(self.shopButton, idle)
	local dungeonReady = (G.db.level or 1) >= ns.DUNGEON_LEVEL
	ns.Enable(self.dungeonButton, idle and dungeonReady)
	if dungeonReady then
		ns.Tooltip(self.dungeonButton, ns:Trans("LID_DUNGEON"), ns:Trans("LID_DUNGEON_DESC"))
	else
		ns.Tooltip(self.dungeonButton, ns:Trans("LID_DUNGEON"), ns:Trans("LID_DUNGEON_DESC"), format(ns:Trans("LID_ITEM_LEVEL"), ns.DUNGEON_LEVEL))
	end

	ns.Enable(self.nextEnemyButton, idle)
	ns.Enable(self.returnButton, idle)
	ns.Enable(self.resurrectButton, idle)
	if points > 0 then
		self.talentsButton:SetText(format("%s |cff20ff20(%d)|r", ns:Trans("LID_TALENTS"), points))
	else
		self.talentsButton:SetText(ns:Trans("LID_TALENTS"))
	end

	self:UpdateLogJump()
	local streak = G:Streak()
	if streak > 0 then
		self.streakText:SetText(format(ns:Trans("LID_STREAK"), streak, math.floor(ns.STREAK_STEP * streak * 100 + 0.5)))
		self.streakText:Show()
	else
		self.streakText:Hide()
	end

	local newItems = G:NewItems()
	local bagLabel = format("%s (%d/%d)", ns:Trans("LID_INVENTORY"), #G:Bag(), G:BagSize())
	if newItems > 0 then bagLabel = format("%s |cff20ff20(%s)|r", bagLabel, format(ns:Trans("LID_NEW_ITEMS"), newItems)) end
	self.inventoryButton:SetText(bagLabel)

	local enemy = G.battle
	if enemy then
		local eliteTag = enemy.elite and format("  |cffff8000%s|r", ns:Trans("LID_ELITE")) or ""
		self.enemyName:SetText(format("%s  (%s)%s", ns:Trans(enemy.name), format(ns:Trans("LID_LEVEL"), enemy.level), eliteTag))
		ns.SetBar(self.enemyBar, enemy.hp, enemy.maxHP, format(ns:Trans("LID_BARTEXT"), enemy.hp, enemy.maxHP))
	end

	local canAct = C:CanAct() and not self.busy
	ns.Enable(self.attackButton, canAct)
	ns.Enable(self.fleeButton, canAct)
	for _, b in ipairs(self.supplyButtons) do
		local count = G:SupplyCount(b.supply.id)
		ns.Enable(b, canAct and count > 0)
		b.count:SetText(count > 0 and count or "")
		ns.Tooltip(b, ns:Trans(b.supply.name), format(ns:Trans("LID_ITEM_DESC"), ns:Trans(b.supply.desc), count))
		ns.RefreshTooltip(b)
	end

	self:RefreshAbilityButtons(canAct)
	ns.Talents:Refresh()
	ns.Character:Refresh()
	ns.Inventory:Refresh()
	ns.Shop:Refresh()
end

function UI:Toggle()
	if not self.frame then return end
	if self.frame:IsShown() then
		self.frame:Hide()
		self:HideWindows()
	else
		self.frame:Show()
		if not self.current or self.current == "loading" then self:ShowPage("menu") end
	end
end
