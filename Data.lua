local _, ns = ...
ns.MAX_LEVEL = 20
ns.MEDIA = "Interface\\AddOns\\MurlocRPG\\media\\"
ns.SCENE_SHORE = ns.MEDIA .. "scene_shore"
ns.BG_WORLD = ns.MEDIA .. "bg_world"
ns.BG_LOADING = ns.MEDIA .. "bg_loading"
ns.BG_CAMP = ns.MEDIA .. "bg_camp"
ns.BG_DUNGEON = ns.MEDIA .. "bg_dungeon"
ns.TITLE_ART = ns.MEDIA .. "title"
ns.CAMP_HUT = ns.MEDIA .. "camp_hut"
ns.CAMP_TENT = ns.MEDIA .. "camp_tent"
local iconSlots
function ns.IconSlot(name)
	if not iconSlots then
		iconSlots = {}
		for key, slot in pairs(ns.ICON_INDEX) do
			iconSlots[key:lower()] = slot
		end
	end
	return name and iconSlots[name:lower()]
end

function ns.SetIcon(texture, name)
	local i = ns.IconSlot(name)
	if not i then
		texture:SetTexture(nil)
		return
	end

	local cols, rows = ns.ICON_ATLAS_COLS, ns.ICON_ATLAS_ROWS
	local col, row = i % cols, math.floor(i / cols)
	texture:SetTexture(ns.MEDIA .. "icons")
	texture:SetTexCoord(col / cols, (col + 1) / cols, row / rows, (row + 1) / rows)
end

ns.SPRITES = {
	MURK_IDLE = {
		file = "murk_idle",
		frames = 32,
		cols = 4,
		rows = 8
	},
	MURK_WALK = {
		file = "murk_walk",
		frames = 20,
		cols = 8,
		rows = 4
	},
	MURK_ATTACK = {
		file = "murk_attack",
		frames = 20,
		cols = 8,
		rows = 4
	},
	MURK_ATTACK_WEAPON = {
		file = "murk_attack_weapon",
		frames = 20,
		cols = 8,
		rows = 4
	},
	MURK_CAST = {
		file = "murk_cast",
		frames = 16,
		cols = 4,
		rows = 4
	},
	FX_FIREBALL = {
		file = "fx_fireball",
		frames = 16,
		cols = 4,
		rows = 4
	},
	FX_FROSTBOLT = {
		file = "fx_frostbolt",
		frames = 16,
		cols = 4,
		rows = 4
	},
	FX_DRAIN = {
		file = "fx_drain",
		frames = 16,
		cols = 4,
		rows = 4
	},
	FX_HEAL = {
		file = "fx_heal",
		frames = 16,
		cols = 4,
		rows = 4
	},
	BRAKIL_IDLE = {
		file = "brakil_idle",
		frames = 16,
		cols = 4,
		rows = 4
	},
	CRAB_IDLE = {
		file = "crab_idle",
		frames = 16,
		cols = 4,
		rows = 4
	},
	BOAR_IDLE = {
		file = "boar_idle",
		frames = 16,
		cols = 4,
		rows = 4
	},
	CROC_IDLE = {
		file = "croc_idle",
		frames = 16,
		cols = 4,
		rows = 4
	},
	GOBLIN_IDLE = {
		file = "goblin_idle",
		frames = 16,
		cols = 4,
		rows = 4
	},
}

ns.COPPER_PER_SILVER = 100
ns.SILVER_PER_GOLD = 100
ns.COPPER_PER_GOLD = ns.COPPER_PER_SILVER * ns.SILVER_PER_GOLD
function ns.MoneyText(copper)
	copper = math.max(0, math.floor(copper or 0))
	if GetCoinTextureString then return GetCoinTextureString(copper) end
	local gold = math.floor(copper / ns.COPPER_PER_GOLD)
	local silver = math.floor((copper % ns.COPPER_PER_GOLD) / ns.COPPER_PER_SILVER)
	local rest = copper % ns.COPPER_PER_SILVER
	local out = ""
	if gold > 0 then out = format("|cffffd700%d|rg ", gold) end
	if gold > 0 or silver > 0 then out = out .. format("|cffc7c7cf%d|rs ", silver) end
	return out .. format("|cffeda55f%d|rc", rest)
end

function ns.MoneyFromEnemy(level)
	if level <= 5 then
		return level * 3
	elseif level <= 10 then
		return level * 6
	elseif level <= 15 then
		return level * 12
	elseif level <= 20 then
		return level * 24
	end
	return level * 48
end

ns.ITEMS = {
	MEAT = {
		name = "LID_ITEM_RAW_MEAT",
		icon = "wolf_meat"
	},
}

ns.CONSUMABLES = {
	{
		id = "spiced_wolf_meat",
		name = "LID_SUPPLY_SPICED_WOLF_MEAT",
		icon = "spiced_wolf_meat",
		desc = "LID_SUPPLY_SPICED_WOLF_MEAT_DESC",
		kind = "heal",
		amount = 150,
		value = 100,
	},
	{
		id = "magic_dust",
		name = "LID_SUPPLY_MAGIC_DUST",
		icon = "magic_dust",
		desc = "LID_SUPPLY_MAGIC_DUST_DESC",
		kind = "energy",
		amount = 50,
		value = 60,
	},
	{
		id = "quality_health_potion",
		name = "LID_SUPPLY_QUALITY_HEALTH_POTION",
		icon = "INV_Potion_51",
		desc = "LID_SUPPLY_QUALITY_HEALTH_POTION_DESC",
		kind = "heal",
		amount = 300,
		value = 500,
	},
}

ns.CONSUMABLE_BY_ID = {}
for _, c in ipairs(ns.CONSUMABLES) do
	ns.CONSUMABLE_BY_ID[c.id] = c
end

ns.ENEMIES = {
	{
		id = "BOAR",
		rounds = 4,
		share = 0.075,
		name = "LID_ENEMY_BOAR",
		level = 1,
		sprite = "BOAR_IDLE",
		scale = 1.15,
		hp = 25,
		minDmg = 5,
		maxDmg = 6,
		meat = 2,
	},
	{
		id = "CRAB",
		rounds = 5,
		share = 0.085,
		name = "LID_ENEMY_CRAB",
		level = 1,
		sprite = "CRAB_IDLE",
		scale = 1.0,
		hp = 30,
		minDmg = 6,
		maxDmg = 7,
		meat = 1,
	},
	{
		id = "CRAB_KING",
		unique = true,
		rounds = 6.5,
		share = 0.105,
		name = "LID_ENEMY_CRAB_KING",
		level = 1,
		sprite = "CRAB_IDLE",
		scale = 1.3,
		hp = 40,
		minDmg = 7,
		maxDmg = 8,
		meat = 2,
	},
	{
		id = "CROC",
		rounds = 7.5,
		share = 0.09,
		name = "LID_ENEMY_CROC",
		level = 1,
		sprite = "CROC_IDLE",
		scale = 1.6,
		hp = 45,
		minDmg = 6,
		maxDmg = 7,
		meat = 1,
	},
	{
		id = "CROC_MOTHER",
		unique = true,
		rounds = 8,
		share = 0.125,
		name = "LID_ENEMY_CROC_MOTHER",
		level = 1,
		sprite = "CROC_IDLE",
		scale = 1.9,
		hp = 50,
		minDmg = 9,
		maxDmg = 10,
		meat = 2,
	},
}

function ns.QuestText(quest, field)
	return ns:Trans(format("LID_QUEST_%s_%s", quest.id, field))
end

ns.QUESTS = {
	{
		id = "BANQUET",
		kind = "meat",
		need = 6,
		xp = 300,
		money = 40,
		supply = {
			id = "spiced_wolf_meat",
			count = 2
		},
	},
	{
		id = "BAIT",
		kind = "kill",
		enemy = "CRAB",
		need = 4,
		xp = 600,
		money = 120,
		supply = {
			id = "magic_dust",
			count = 2
		},
	},
	{
		id = "HOLD_FAST",
		kind = "kill",
		enemy = "CRAB_KING",
		need = 1,
		xp = 900,
		money = 250,
		item = "small_shield",
	},
	{
		id = "BOARS",
		kind = "kill",
		enemy = "BOAR",
		need = 5,
		xp = 1400,
		money = 400,
		supply = {
			id = "spiced_wolf_meat",
			count = 3
		},
	},
	{
		id = "CROCS",
		kind = "kill",
		enemy = "CROC",
		need = 4,
		xp = 2200,
		money = 700,
		item = "tarnished_chain_vest",
	},
	{
		id = "MOTHER",
		kind = "kill",
		enemy = "CROC_MOTHER",
		need = 1,
		xp = 3600,
		money = 1500,
		item = "tarnished_chain_leggings",
	},
}

ns.BASE_STATS = {
	RAIDER = {
		str = 12,
		stm = 10,
		int = 9,
		agi = 9
	},
	ORACLE = {
		str = 10,
		stm = 9,
		int = 9,
		agi = 12
	},
	TIDEHUNTER = {
		str = 9,
		stm = 12,
		int = 10,
		agi = 9
	},
	CLASSIC = {
		str = 9,
		stm = 9,
		int = 12,
		agi = 10
	},
}

ns.CRIT_ROLL = 95
ns.ARMOR_DIVISOR = 20
ns.XP_PER_MOB_LEVEL = 100
ns.DUNGEON_LEVEL = 5
ns.ELITE_HP = 2
ns.ELITE_DMG = 2
ns.ELITE_XP = 2
ns.ELITE_MONEY = 3
function ns.MaxHealth(stm, level)
	local hp = 85 + stm * 10
	if level > 1 then hp = hp + 48 * (level - 1) + 11 end
	return hp
end

function ns.MaxEnergy(agi)
	return 100 + (agi - 9) * 2
end

function ns.XPToLevel(level)
	return level * (level + 1) * 100
end

function ns.XPFromEnemy(enemyLevel, playerLevel)
	local xp = enemyLevel * ns.XP_PER_MOB_LEVEL
	local diff = playerLevel - enemyLevel
	if diff >= 3 then
		xp = xp - 70
	elseif diff == 2 then
		xp = xp - 35
	end
	return math.max(0, xp)
end

function ns.ScaleEnemy(enemy, playerLevel, stats)
	enemy.level = playerLevel
	if stats then
		local avg = (stats.minDmg + stats.maxDmg) / 2
		local ramp = math.min(1, 0.45 + 0.55 * (playerLevel - 1) / 3)
		local hit = stats.maxHP * enemy.share * ramp
		enemy.hp = math.max(enemy.hp, math.floor(avg * enemy.rounds + 0.5))
		enemy.minDmg = math.max(1, math.floor(hit + 0.5))
		enemy.maxDmg = math.max(enemy.minDmg, math.floor(hit * 1.18 + 0.5))
	end

	enemy.maxHP = enemy.hp
end

function ns.MakeElite(enemy)
	enemy.elite = true
	enemy.hp = enemy.hp * ns.ELITE_HP
	enemy.maxHP = enemy.hp
	enemy.minDmg = enemy.minDmg * ns.ELITE_DMG
	enemy.maxDmg = enemy.maxDmg * ns.ELITE_DMG
end
