local _, ns = ...
local G = ns.Game
local C = {}
ns.Combat = C
local CRIT_ENEMY = 8
local FLEE_CHANCE = 60
local TURN_DELAY = 0.9
local function Roll(minValue, maxValue)
	return math.random(minValue, maxValue)
end

local function Heal(amount)
	local s = G:Stats()
	local heal = math.min(amount, s.maxHP - G.db.hp)
	if heal > 0 then G.db.hp = G.db.hp + heal end
	return heal
end

function C:CanAct()
	return G.battle ~= nil and not G.turnLocked and G.db.hp > 0
end

local QUEST_TARGET_CHANCE = 70
local function EnemyById(id)
	for _, enemy in ipairs(ns.ENEMIES) do
		if enemy.id == id then return enemy end
	end
end

local function CurrentTrack()
	return G.dungeon and "dungeon" or "main"
end

local function QuestTarget()
	local track = CurrentTrack()
	local q = G:CurrentQuest(track)
	if not q or not G:QuestActive(track) or q.kind ~= "kill" then return end
	if G:QuestProgress(track) >= q.need then return end
	return EnemyById(q.enemy)
end

local function PickEnemy()
	local target = QuestTarget()
	if target and (target.unique or math.random(100) <= QUEST_TARGET_CHANCE) then return target end
	local level = G.db.level or 1
	local pool = {}
	for _, enemy in ipairs(ns.ENEMIES) do
		if not enemy.unique and (enemy.minLevel or 1) <= level then pool[#pool + 1] = enemy end
	end
	return pool[math.random(#pool)]
end

function C:Start()
	if G.battle then return end
	local template = PickEnemy()
	local enemy = {}
	for k, v in pairs(template) do
		enemy[k] = v
	end

	enemy.maxHP = template.hp
	ns.ScaleEnemy(enemy, G.db.level, G:Stats())
	ns.ApplyStreak(enemy, G:Streak())
	if G.dungeon then ns.MakeElite(enemy) end
	G.battle = enemy
	G.turnLocked = false
	G.victory = false
	ns.UI:Log(format(ns:Trans("LID_BATTLE_START"), ns:Trans(enemy.name)), 1, 0.6, 0.2)
	ns.UI:Refresh()
end

function C:ScheduleEnemyTurn()
	G.turnLocked = true
	ns.UI:Refresh()
	C_Timer.After(TURN_DELAY, function() C:EnemyTurn() end)
end

function C:DamageEnemy(damage, crit)
	local enemy = G.battle
	enemy.hp = math.max(0, enemy.hp - damage)
	ns.UI:Log(format(crit and ns:Trans("LID_P_CRIT") or ns:Trans("LID_P_HIT"), ns:Trans(enemy.name), damage), 1, 1, 0.6)
	local s = G:Stats()
	if s.lifesteal > 0 then
		local heal = Heal(math.floor(damage * s.lifesteal / 100 + 0.5))
		if heal > 0 then ns.UI:Log(format(ns:Trans("LID_P_HEAL"), heal), 0.4, 1, 0.4) end
	end

	ns.UI:Refresh()
	if enemy.hp <= 0 then
		self:Victory()
	else
		self:ScheduleEnemyTurn()
	end
end

function C:RollDamage(multiplier)
	local s = G:Stats()
	local low, high = s.minDmg, s.maxDmg
	if multiplier and multiplier ~= 1 then
		low = math.max(1, math.floor(low * multiplier + 0.5))
		high = math.max(1, math.floor(high * multiplier + 0.5))
	end

	local damage = Roll(low, math.max(low, high))
	local crit = math.random(0, ns.CRIT_ROLL - 1) <= s.crit
	if crit then damage = damage * 2 end
	return damage, crit
end

function C:Attack()
	if not self:CanAct() then return end
	self:DamageEnemy(self:RollDamage(1))
end

function C:UseAbility(ability)
	if not self:CanAct() then return end
	local cost = G:AbilityCost(ability)
	if G.db.mp < cost then
		ns.UI:Log(ns:Trans("LID_NO_MANA"), 1, 0.4, 0.4)
		return
	end

	G.db.mp = G.db.mp - cost
	ns.UI:Log(format(ns:Trans("LID_P_CAST"), ns:Trans(ability.name)), 0.4, 0.8, 1)
	ns.Sound("IG_ABILITY_ICON_DROP")
	local level = G.db.level or 1
	local bonus = (ability.mod or 0) * level
	if ability.kind == "heal" then
		local heal = Heal(bonus)
		ns.UI:Log(format(ns:Trans("LID_P_HEAL"), heal), 0.4, 1, 0.4)
		self:ScheduleEnemyTurn()
		return
	end

	local damage, crit
	if ability.school == "magic" then
		damage, crit = self:RollDamage((ability.mod or 0) / ns.SPELL_DIVISOR)
		damage = math.max(1, math.floor(damage * G:Stats().spellFactor + 0.5))
		if ability.kind == "critstrike" and not crit then
			crit = true
			damage = damage * 2
		end
	else
		damage, crit = self:RollDamage(1)
		damage = damage + bonus
		if ability.kind == "critstrike" and not crit then
			crit = true
			damage = damage * 2
		end
	end

	if ability.kind == "drain" then
		local heal = Heal(damage)
		if heal > 0 then ns.UI:Log(format(ns:Trans("LID_P_DRAIN"), heal), 0.4, 1, 0.4) end
	end

	self:DamageEnemy(damage, crit)
end

function C:UseSupply(id)
	if not self:CanAct() then return end
	local supply = ns.CONSUMABLE_BY_ID[id]
	if not supply or G:SupplyCount(id) <= 0 then
		ns.UI:Log(ns:Trans("LID_NO_ITEM"), 1, 0.4, 0.4)
		return
	end

	G:Supplies()[id] = G:SupplyCount(id) - 1
	if supply.kind == "energy" then
		local s = G:Stats()
		local gain = math.min(supply.amount, s.maxMP - G.db.mp)
		G.db.mp = G.db.mp + math.max(0, gain)
		ns.UI:Log(format(ns:Trans("LID_CONSUMABLE_ENERGY"), math.max(0, gain)), 0.4, 0.8, 1)
	else
		local heal = Heal(supply.amount)
		ns.UI:Log(format(ns:Trans("LID_USE_ITEM"), ns:Trans(supply.name), heal), 0.4, 1, 0.4)
	end

	self:ScheduleEnemyTurn()
end

function C:Flee()
	if not self:CanAct() then return end
	if math.random(100) <= FLEE_CHANCE then
		G.battle = nil
		G.turnLocked = false
		G.dungeon = false
		G:ResetStreak()
		ns.UI:Log(ns:Trans("LID_FLEE_OK"), 0.7, 0.7, 0.7)
		ns.UI:Refresh()
	else
		ns.UI:Log(ns:Trans("LID_FLEE_FAIL"), 1, 0.4, 0.4)
		self:ScheduleEnemyTurn()
	end
end

function C:EnemyTurn()
	local enemy = G.battle
	if not enemy then return end
	local s = G:Stats()
	local damage = Roll(enemy.minDmg, enemy.maxDmg)
	local crit = math.random(100) <= CRIT_ENEMY
	if crit then damage = damage * 2 end
	damage = math.max(0, damage - s.soak)
	G.db.hp = math.max(0, G.db.hp - damage)
	G.turnLocked = false
	ns.UI:EnemyLunge()
	ns.UI:Log(format(crit and ns:Trans("LID_E_CRIT") or ns:Trans("LID_E_HIT"), ns:Trans(enemy.name), damage), 1, 0.5, 0.5)
	if G.db.hp <= 0 then
		self:Defeat()
	else
		G.db.mp = math.min(s.maxMP, G.db.mp + s.regen)
		ns.UI:Refresh()
	end
end

function C:Victory()
	local enemy = G.battle
	G.battle = nil
	G.turnLocked = false
	G.victory = true
	local xp = ns.XPFromEnemy(enemy.level, G.db.level)
	if enemy.elite then xp = xp * ns.ELITE_XP end
	ns.UI:Log(format(ns:Trans("LID_WIN"), ns:Trans(enemy.name), xp), 0.4, 1, 0.4)
	if enemy.meat > 0 then
		G.db.meat = G.db.meat + enemy.meat
		ns.UI:Log(format(ns:Trans("LID_LOOT"), enemy.meat, ns:Trans(ns.ITEMS.MEAT.name)), 0.8, 0.8, 0.8)
	end

	G:AddKill()
	G.streak = G:Streak() + 1
	G:QuestKill(enemy.elite and "dungeon" or "main", enemy.id)
	local money = math.floor(ns.MoneyFromEnemy(enemy.level) * (enemy.elite and ns.ELITE_MONEY or 1) * G:StreakMult())
	if money > 0 then
		G:AddMoney(money)
		ns.UI:Log(format(ns:Trans("LID_LOOT_MONEY"), ns.MoneyText(money)), 0.9, 0.85, 0.5)
	end

	local bagDrop = ns.RollBagDrop(G.db.level, enemy.elite)
	if bagDrop then
		if G:AddItem(bagDrop.id) then
			ns.UI:Log(format(ns:Trans("LID_ITEM_DROP"), ns:Trans(enemy.name), ns.ItemLink(bagDrop)), 0.9, 0.9, 0.6)
			ns.Sound("IG_BACKPACK_OPEN")
		else
			ns.UI:Log(format(ns:Trans("LID_ITEM_DROP_LOST"), ns:Trans(enemy.name), ns.ItemLink(bagDrop)), 1, 0.4, 0.4)
		end
	end

	local drop = ns.RollDrop(G.db.level, enemy.elite, G:Streak())
	if drop then
		if G:AddItem(drop.id) then
			ns.UI:Log(format(ns:Trans("LID_ITEM_DROP"), ns:Trans(enemy.name), ns.ItemLink(drop)), 0.9, 0.9, 0.6)
			ns.Sound("IG_BACKPACK_OPEN")
		else
			ns.UI:Log(format(ns:Trans("LID_ITEM_DROP_LOST"), ns:Trans(enemy.name), ns.ItemLink(drop)), 1, 0.4, 0.4)
		end
	end

	G:AddXP(xp)
	ns.UI:Refresh()
end

function C:Defeat()
	local enemy = G.battle
	G.battle = nil
	G.turnLocked = false
	G.victory = false
	G:ResetStreak()
	G.db.hp = 0
	if G:Hardcore() then
		ns.UI:ShowGameOver(G:EndRun(enemy and enemy.name, true))

		return
	end

	G.db.dead = true
	ns.UI:Log(ns:Trans("LID_DEAD"), 1, 0.3, 0.3)
	ns.UI:Refresh()
end
