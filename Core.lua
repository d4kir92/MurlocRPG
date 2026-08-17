local _, ns = ...
MurlocRPGDB = MurlocRPGDB or {}
local G = {}
ns.Game = G
local SAVE_VERSION = 7
function ns.Sound(key)
	if SOUNDKIT and PlaySound and SOUNDKIT[key] then pcall(PlaySound, SOUNDKIT[key]) end
end

function G:Init()
	if type(MurlocRPGDB) ~= "table" then MurlocRPGDB = {} end
	if MurlocRPGDB.version ~= SAVE_VERSION then wipe(MurlocRPGDB) end
	self.db = MurlocRPGDB
	self.battle = nil
	self.turnLocked = false
	self.victory = false
end

function G:HasSave()
	return self.db.version == SAVE_VERSION and self.db.class ~= nil
end

function G:NewGame(classId, hardcore)
	wipe(self.db)
	self.db.version = SAVE_VERSION
	self.db.class = classId
	self.db.hardcore = hardcore and true or false
	self.db.kills = 0
	self.db.earned = 0
	self.db.level = 1
	self.db.xp = 0
	self.db.meat = 0
	self.db.supplies = {
		spiced_wolf_meat = 1
	}

	self.db.quest = "none"
	self.db.questIndex = 1
	self.db.questProgress = 0
	self.db.talents = {}
	self.db.bag = {"worn_dagger"}
	self.db.equipped = {
		CHEST = "old_rag"
	}

	self.db.money = 0
	self.db.dead = false
	local s = self:Stats()
	self.db.hp = s.maxHP
	self.db.mp = s.maxMP
	self.battle = nil
	self.turnLocked = false
	self.victory = false
end

function G:Streak()
	return self.streak or 0
end

function G:StreakMult()
	return 1 + ns.STREAK_STEP * self:Streak()
end

function G:ResetStreak()
	self.streak = 0
end

function G:Hardcore()
	return self.db.hardcore and true or false
end

function G:AddKill()
	self.db.kills = (self.db.kills or 0) + 1
end

function G:RunScore()
	local questsDone = math.max(0, (self.db.questIndex or 1) - 1)
	return (self.db.level or 1) * 100 + questsDone * 250 + (self.db.kills or 0) * 10 + math.floor((self.db.earned or 0) / 100)
end

function G:EndRun(killedBy)
	local summary = {
		level = self.db.level or 1,
		xp = self.db.xp or 0,
		questsDone = math.max(0, (self.db.questIndex or 1) - 1),
		questTotal = #ns.QUESTS,
		kills = self.db.kills or 0,
		earned = self.db.earned or 0,
		killedBy = killedBy,
		score = self:RunScore(),
	}

	wipe(self.db)
	self.battle = nil
	self.turnLocked = false
	self.victory = false
	return summary
end

function G:Resurrect()
	local s = self:Stats()
	self.db.dead = false
	self.db.hp = math.max(1, math.ceil(s.maxHP * 0.35))
	self.db.mp = math.ceil(s.maxMP * 0.35)
	ns.UI:Log(ns:Trans("LID_RESURRECTED"), 0.6, 0.9, 0.6)
	ns.Sound("IG_QUEST_LIST_COMPLETE")
end

function G:Class()
	return ns.CLASS_BY_ID[self.db.class]
end

function G:Mods()
	local m = {
		str = 0,
		stm = 0,
		int = 0,
		agi = 0,
		dmg = 0,
		crit = 0,
		armor = 0,
		regen = 0,
		cost = 0,
		lifesteal = 0
	}

	local class = self:Class()
	if not class then return m end
	local base = ns.BASE_STATS[self.db.class]
	if base then
		m.str = base.str
		m.stm = base.stm
		m.int = base.int
		m.agi = base.agi
	end

	if type(self.db.talents) == "table" then
		for treeIndex, tree in ipairs(class.trees) do
			local learned = self.db.talents[treeIndex]
			if type(learned) == "table" then
				for i in pairs(learned) do
					local talent = tree.talents[i]
					if talent and m[talent.stat] then m[talent.stat] = m[talent.stat] + talent.value end
				end
			end
		end
	end

	if type(self.db.equipped) == "table" then
		for _, slotKey in ipairs(ns.SLOT_ORDER) do
			local item = ns.ITEM_BY_ID[self.db.equipped[slotKey]]
			if item then
				for key, value in pairs(item.stats) do
					if m[key] then m[key] = m[key] + value end
				end
			end
		end
	end
	return m
end

function G:Weapon()
	return ns.ITEM_BY_ID[self:Equipped().MAINHAND]
end

function G:Stats()
	local level = self.db.level or 1
	local m = self:Mods()
	local dmgFactor = 1 + m.dmg / 100
	local weapon = self:Weapon()
	local wMin, wMax = 1, 2
	if weapon then
		wMin = weapon.stats.minDmg or 0
		wMax = weapon.stats.maxDmg or 0
	end

	local lowMult, highMult = 1, 1
	if weapon then
		lowMult = math.floor(m.str / 4) + 1
		highMult = math.floor(m.str / 4) + level
	end
	return {
		str = m.str,
		stm = m.stm,
		int = m.int,
		agi = m.agi,
		maxHP = ns.MaxHealth(m.stm, level),
		maxMP = ns.MaxMana(m.int),
		minDmg = math.max(1, math.floor(lowMult * wMin * dmgFactor + 0.5)),
		maxDmg = math.max(1, math.floor(highMult * wMax * dmgFactor + 0.5)),
		spellFactor = 1 + m.int / 100,
		crit = math.min(95, m.agi + m.crit),
		armor = m.armor,
		soak = math.floor(m.armor / ns.ARMOR_DIVISOR),
		regen = 2 + m.regen,
		lifesteal = m.lifesteal,
		costMod = math.max(0.4, 1 - m.cost / 100),
	}
end

function G:IsMaxLevel()
	return (self.db.level or 1) >= ns.MAX_LEVEL
end

function G:XPMax()
	return ns.XPToLevel(self.db.level or 1)
end

function G:Abilities()
	local class = self:Class()
	local list = {}
	if not class then return list end
	for _, a in ipairs(class.abilities) do
		if self.db.level >= a.level then list[#list + 1] = a end
	end
	return list
end

function G:AbilityCost(ability)
	return math.max(1, math.floor(ability.cost * self:Stats().costMod + 0.5))
end

function G:TalentSpent()
	local n = 0
	if type(self.db.talents) ~= "table" then return 0 end
	for _, tree in pairs(self.db.talents) do
		if type(tree) == "table" then
			for _ in pairs(tree) do
				n = n + 1
			end
		end
	end
	return n
end

function G:TreeSpent(treeIndex)
	local tree = self.db.talents and self.db.talents[treeIndex]
	local n = 0
	if type(tree) == "table" then
		for _ in pairs(tree) do
			n = n + 1
		end
	end
	return n
end

function G:TalentPoints()
	return (self.db.level or 1) - self:TalentSpent()
end

function G:HasTalent(treeIndex, talentIndex)
	local tree = self.db.talents and self.db.talents[treeIndex]
	return type(tree) == "table" and tree[talentIndex] == true
end

function G:CanLearn(treeIndex, talent)
	if self:HasTalent(treeIndex, talent.index) then return false, "known" end
	if self:TalentPoints() <= 0 then return false, "points" end
	if self:TreeSpent(treeIndex) < talent.tier - 1 then return false, "tier" end
	return true
end

function G:LearnTalent(treeIndex, talent)
	local ok, reason = self:CanLearn(treeIndex, talent)
	if not ok then
		if reason == "points" then
			ns.UI:Log(ns:Trans("LID_TALENT_NONE"), 1, 0.4, 0.4)
		elseif reason == "tier" then
			local tree = self:Class().trees[treeIndex]
			ns.UI:Log(format(ns:Trans("LID_TALENT_NEED"), talent.tier - 1, ns:Trans(tree.name)), 1, 0.4, 0.4)
		end
		return false
	end

	self.db.talents[treeIndex] = self.db.talents[treeIndex] or {}
	self.db.talents[treeIndex][talent.index] = true
	local s = self:Stats()
	self.db.hp = math.min(self.db.hp, s.maxHP)
	self.db.mp = math.min(self.db.mp, s.maxMP)
	ns.UI:Log(format(ns:Trans("LID_TALENT_LEARNED"), ns:Trans(talent.name)), 0.4, 0.8, 1)
	ns.Sound("IG_CHARACTER_INFO_TAB")
	return true
end

function G:ResetTalents()
	self.db.talents = {}
	local s = self:Stats()
	self.db.hp = math.min(self.db.hp, s.maxHP)
	self.db.mp = math.min(self.db.mp, s.maxMP)
	ns.UI:Log(ns:Trans("LID_TALENT_CLEARED"), 0.7, 0.7, 0.7)
end

function G:Bag()
	if type(self.db.bag) ~= "table" then self.db.bag = {} end
	return self.db.bag
end

function G:Equipped()
	if type(self.db.equipped) ~= "table" then self.db.equipped = {} end
	return self.db.equipped
end

function G:HasWeapon()
	return self:Equipped().MAINHAND ~= nil
end

function G:BagSize()
	local size = ns.BAG_SIZE
	local equipped = self:Equipped()
	for _, slotKey in ipairs(ns.BAG_SLOT_ORDER) do
		local item = ns.ITEM_BY_ID[equipped[slotKey]]
		if item then size = size + (item.stats.slots or 0) end
	end
	return size
end

function G:BagFull()
	return #self:Bag() >= self:BagSize()
end

function G:BagFits(removedId, addedItem, extraItems)
	local removed = ns.ITEM_BY_ID[removedId]
	local size = self:BagSize()
	if removed then size = size - (removed.stats.slots or 0) end
	if addedItem then size = size + (addedItem.stats.slots or 0) end
	return #self:Bag() + (extraItems or 0) <= size
end

function G:AddItem(itemId)
	if self:BagFull() then return false end
	tinsert(self:Bag(), itemId)
	self.db.newItems = (self.db.newItems or 0) + 1
	return true
end

function G:NewItems()
	return math.min(self.db.newItems or 0, #self:Bag())
end

function G:ClearNewItems()
	self.db.newItems = 0
end

function G:ClampVitals()
	local s = self:Stats()
	self.db.hp = math.min(self.db.hp or s.maxHP, s.maxHP)
	self.db.mp = math.min(self.db.mp or s.maxMP, s.maxMP)
end

function G:TargetSlot(item)
	local equipped = self:Equipped()
	if item.slotType == "BAG" then
		local weakest, weakestSlots
		for _, slotKey in ipairs(ns.BAG_SLOT_ORDER) do
			local current = ns.ITEM_BY_ID[equipped[slotKey]]
			if not current then return slotKey end
			local slots = current.stats.slots or 0
			if not weakestSlots or slots < weakestSlots then
				weakest = slotKey
				weakestSlots = slots
			end
		end
		return weakest
	end

	if item.slotType ~= "FINGER" then return item.slotType end
	if not equipped.FINGER1 then return "FINGER1" end
	if not equipped.FINGER2 then return "FINGER2" end
	return "FINGER1"
end

function G:Money()
	if type(self.db.money) ~= "number" then self.db.money = 0 end
	return self.db.money
end

function G:AddMoney(copper)
	local gain = math.max(0, math.floor(copper or 0))
	self.db.money = self:Money() + gain
	self.db.earned = (self.db.earned or 0) + gain
end

function G:CanAfford(copper)
	return self:Money() >= copper
end

function G:Supplies()
	if type(self.db.supplies) ~= "table" then self.db.supplies = {} end
	return self.db.supplies
end

function G:SupplyCount(id)
	return self:Supplies()[id] or 0
end

function G:AddSupply(id, count)
	local supplies = self:Supplies()
	supplies[id] = (supplies[id] or 0) + (count or 1)
end

function G:BuySupply(id)
	local supply = ns.CONSUMABLE_BY_ID[id]
	if not supply then return false end
	if not self:CanAfford(supply.value) then
		ns.UI:Log(format(ns:Trans("LID_SHOP_NO_MONEY"), ns:Trans(supply.name)), 1, 0.4, 0.4)
		return false
	end

	self.db.money = self:Money() - supply.value
	self:AddSupply(id, 1)
	ns.UI:Log(format(ns:Trans("LID_SHOP_BOUGHT"), ns:Trans(supply.name), ns.MoneyText(supply.value)), 0.8, 0.8, 0.8)
	ns.Sound("IG_BACKPACK_OPEN")
	return true
end

function G:ShopStock()
	local list = {}
	for _, itemId in ipairs(ns.VENDOR_STOCK) do
		local item = ns.ITEM_BY_ID[itemId]
		if item and item.level <= (self.db.level or 1) + 2 then list[#list + 1] = item end
	end

	for _, entry in ipairs(ns.VENDOR_BAGS) do
		local item = ns.ITEM_BY_ID[entry.id]
		if item and (self.db.level or 1) >= entry.level then list[#list + 1] = item end
	end
	return list
end

function G:Buy(itemId)
	local item = ns.ITEM_BY_ID[itemId]
	if not item then return false end
	if not self:CanAfford(item.value) then
		ns.UI:Log(format(ns:Trans("LID_SHOP_NO_MONEY"), ns.ItemLink(item)), 1, 0.4, 0.4)
		return false
	end

	if not self:AddItem(item.id) then
		ns.UI:Log(ns:Trans("LID_BAG_FULL"), 1, 0.4, 0.4)
		return false
	end

	self.db.money = self:Money() - item.value
	ns.UI:Log(format(ns:Trans("LID_SHOP_BOUGHT"), ns.ItemLink(item), ns.MoneyText(item.value)), 0.8, 0.8, 0.8)
	ns.Sound("IG_BACKPACK_OPEN")
	return true
end

function G:Sell(bagIndex)
	local bag = self:Bag()
	local item = ns.ITEM_BY_ID[bag[bagIndex]]
	if not item then return false end
	if item.value <= 0 then
		ns.UI:Log(format(ns:Trans("LID_SHOP_WORTHLESS"), ns.ItemLink(item)), 1, 0.4, 0.4)
		return false
	end

	tremove(bag, bagIndex)
	self:AddMoney(item.value)
	ns.UI:Log(format(ns:Trans("LID_SHOP_SOLD"), ns.ItemLink(item), ns.MoneyText(item.value)), 0.8, 0.8, 0.8)
	ns.Sound("IG_BACKPACK_OPEN")
	return true
end

function G:Equip(bagIndex)
	local bag = self:Bag()
	local item = ns.ITEM_BY_ID[bag[bagIndex]]
	if not item then return false end
	if self.db.level < item.level then
		ns.UI:Log(format(ns:Trans("LID_ITEM_LEVEL"), item.level), 1, 0.4, 0.4)
		return false
	end

	local slotKey = self:TargetSlot(item)
	local equipped = self:Equipped()
	local previous = equipped[slotKey]
	if item.slotType == "BAG" and not self:BagFits(previous, item) then
		ns.UI:Log(ns:Trans("LID_BAG_KEEP"), 1, 0.4, 0.4)
		return false
	end

	tremove(bag, bagIndex)
	equipped[slotKey] = item.id
	if previous then tinsert(bag, previous) end
	self:ClampVitals()
	ns.UI:Log(format(ns:Trans("LID_ITEM_EQUIPPED"), ns.ItemLink(item)), 0.8, 0.8, 0.8)
	ns.Sound("IG_BACKPACK_OPEN")
	return true
end

function G:Unequip(slotKey)
	local equipped = self:Equipped()
	local item = ns.ITEM_BY_ID[equipped[slotKey]]
	if not item then return false end
	if self:BagFull() then
		ns.UI:Log(ns:Trans("LID_BAG_FULL"), 1, 0.4, 0.4)
		return false
	end

	if item.slotType == "BAG" and not self:BagFits(item.id, nil, 1) then
		ns.UI:Log(ns:Trans("LID_BAG_KEEP"), 1, 0.4, 0.4)
		return false
	end

	equipped[slotKey] = nil
	tinsert(self:Bag(), item.id)
	self:ClampVitals()
	ns.UI:Log(format(ns:Trans("LID_ITEM_UNEQUIPPED"), ns.ItemLink(item)), 0.8, 0.8, 0.8)
	return true
end

function G:DestroyItem(bagIndex)
	local bag = self:Bag()
	local item = ns.ITEM_BY_ID[bag[bagIndex]]
	if not item then return false end
	tremove(bag, bagIndex)
	ns.UI:Log(format(ns:Trans("LID_ITEM_DESTROYED"), ns.ItemLink(item)), 0.7, 0.7, 0.7)
	return true
end

function G:Restore()
	local s = self:Stats()
	self.db.hp = s.maxHP
	self.db.mp = s.maxMP
end

function G:AddXP(amount)
	local db = self.db
	if self:IsMaxLevel() then return end
	db.xp = db.xp + amount
	while not self:IsMaxLevel() and db.xp >= self:XPMax() do
		db.xp = db.xp - self:XPMax()
		db.level = db.level + 1
		self:Restore()
		ns.UI:Log(format(ns:Trans("LID_LEVELUP"), db.level), 1, 0.85, 0.2)
		ns.UI:Log(ns:Trans("LID_POINT_GAINED"), 0.4, 0.8, 1)
		ns.Sound("IG_CHARACTER_INFO_TAB")
		local class = self:Class()
		if class then
			for _, a in ipairs(class.abilities) do
				if a.level == db.level then ns.UI:Log(format(ns:Trans("LID_LEARNED"), ns:Trans(a.name)), 0.4, 0.8, 1) end
			end
		end
	end

	if self:IsMaxLevel() then
		db.xp = 0
		ns.UI:Log(ns:Trans("LID_AT_MAX"), 0.7, 0.7, 0.7)
	end
end

function G:QuestIndex()
	local i = self.db.questIndex
	if type(i) ~= "number" or i < 1 then
		i = 1
		self.db.questIndex = i
	end
	return i
end

function G:CurrentQuest()
	if self.db.quest == "all_done" then return nil end
	return ns.QUESTS[self:QuestIndex()]
end

function G:QuestProgress()
	local q = self:CurrentQuest()
	if not q then return 0 end
	if q.kind == "meat" then return math.min(self.db.meat or 0, q.need) end
	return math.min(self.db.questProgress or 0, q.need)
end

function G:QuestReady()
	local q = self:CurrentQuest()
	return q ~= nil and self:QuestProgress() >= q.need
end

function G:QuestKill(enemyId)
	local q = self:CurrentQuest()
	if not q or self.db.quest ~= "active" or q.kind ~= "kill" or q.enemy ~= enemyId then return end
	self.db.questProgress = math.min((self.db.questProgress or 0) + 1, q.need)
end

function G:GiveQuestReward(q)
	self:AddMoney(q.money or 0)
	ns.UI:Log(format(ns:Trans("LID_Q_REWARD"), q.xp), 0.4, 1, 0.4)
	if q.money and q.money > 0 then ns.UI:Log(format(ns:Trans("LID_Q_REWARD_MONEY"), ns.MoneyText(q.money)), 0.9, 0.85, 0.5) end
	if q.supply then
		local supply = ns.CONSUMABLE_BY_ID[q.supply.id]
		if supply then
			self:AddSupply(supply.id, q.supply.count)
			ns.UI:Log(format(ns:Trans("LID_Q_REWARD_SUPPLY"), q.supply.count, ns:Trans(supply.name)), 0.9, 0.85, 0.5)
		end
	end

	if q.item then
		local item = ns.ITEM_BY_ID[q.item]
		if item then
			if self:AddItem(item.id) then
				ns.UI:Log(format(ns:Trans("LID_Q_REWARD_ITEM"), ns.ItemLink(item)), 0.9, 0.85, 0.5)
			else
				ns.UI:Log(ns:Trans("LID_BAG_FULL"), 1, 0.4, 0.4)
			end
		end
	end

	self:AddXP(q.xp)
end

function G:TalkToBrakil()
	local db = self.db
	local q = self:CurrentQuest()
	if not q then
		ns.UI:Log(ns:Trans("LID_Q_FINISHED"), 1, 0.85, 0.2)
		ns.UI:Refresh()
		return
	end

	if db.quest ~= "active" then
		db.quest = "active"
		db.questProgress = 0
		ns.UI:Log(ns.QuestText(q, "OFFER"), 1, 0.85, 0.2)
		ns.UI:Log(format(ns:Trans("LID_Q_ACCEPTED"), ns.QuestText(q, "NAME")), 0.4, 1, 0.4)
		ns.UI:Refresh()
		return
	end

	if not self:QuestReady() then
		if q.kind == "meat" then
			ns.UI:Log(format(ns.QuestText(q, "HINT"), self:QuestProgress(), q.need), 1, 0.85, 0.2)
		elseif q.need > 1 then
			ns.UI:Log(format(ns.QuestText(q, "HINT"), self:QuestProgress(), q.need), 1, 0.85, 0.2)
		else
			ns.UI:Log(ns.QuestText(q, "HINT"), 1, 0.85, 0.2)
		end

		ns.UI:Refresh()
		return
	end

	if q.kind == "meat" then db.meat = db.meat - q.need end
	ns.UI:Log(ns.QuestText(q, "TURNIN"), 1, 0.85, 0.2)
	ns.Sound("IG_QUEST_LIST_COMPLETE")
	self:GiveQuestReward(q)
	db.questProgress = 0
	db.questIndex = self:QuestIndex() + 1
	if ns.QUESTS[db.questIndex] then
		db.quest = "ready"
	else
		db.quest = "all_done"
		ns.UI:Log(ns:Trans("LID_Q_ALL_DONE"), 0.6, 0.6, 0.6)
	end

	ns.UI:Refresh()
end

function G:Rest()
	self:Restore()
	ns.UI:Log(ns:Trans("LID_RESTED"), 0.6, 0.9, 0.6)
	ns.UI:Refresh()
end

SLASH_MURLOCRPG1 = "/murloc"
SLASH_MURLOCRPG2 = "/mrpg"
SLASH_MURLOCRPG3 = "/멀록"
SLASH_MURLOCRPG4 = "/鱼人"
SLASH_MURLOCRPG5 = "/魚人"
SLASH_MURLOCRPG6 = "/мурлок"
SlashCmdList["MURLOCRPG"] = function() ns.UI:Toggle() end
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_LOGIN")
	ns:SetAddonOutput("MurlocRPG", 134169)
	ns:SetVersion(134169, "0.4.0")
	G:Init()
	ns.UI:Create()
	print(ns:Trans("LID_LOADED"))
end)
