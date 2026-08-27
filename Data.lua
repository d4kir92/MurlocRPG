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
ns.QUEST_ICONS = ns.MEDIA .. "questicons"
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
	if type(name) == "number" then
		local lookup = C_Item and C_Item.GetItemIconByID or GetItemIcon
		texture:SetTexture(lookup and lookup(name) or nil)
		texture:SetTexCoord(0, 1, 0, 1)
		return
	end

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
	{
		id = "TIDE_CRAB",
		minLevel = 6,
		rounds = 5.5,
		share = 0.09,
		name = "LID_ENEMY_TIDE_CRAB",
		level = 1,
		sprite = "CRAB_IDLE",
		scale = 1.1,
		tint = {0.6, 0.85, 1},
		hp = 34,
		minDmg = 6,
		maxDmg = 8,
		meat = 1,
	},
	{
		id = "SAND_CRAWLER",
		minLevel = 8,
		rounds = 5,
		share = 0.085,
		name = "LID_ENEMY_SAND_CRAWLER",
		level = 1,
		sprite = "CRAB_IDLE",
		scale = 1.05,
		tint = {1, 0.9, 0.6},
		hp = 32,
		minDmg = 6,
		maxDmg = 7,
		meat = 1,
	},
	{
		id = "RAZORTUSK",
		minLevel = 8,
		rounds = 5,
		share = 0.085,
		name = "LID_ENEMY_RAZORTUSK",
		level = 1,
		sprite = "BOAR_IDLE",
		scale = 1.3,
		tint = {0.75, 0.6, 0.55},
		hp = 33,
		minDmg = 6,
		maxDmg = 8,
		meat = 2,
	},
	{
		id = "BOG_BOAR",
		minLevel = 9,
		rounds = 5.5,
		share = 0.09,
		name = "LID_ENEMY_BOG_BOAR",
		level = 1,
		sprite = "BOAR_IDLE",
		scale = 1.25,
		tint = {0.6, 0.7, 0.5},
		hp = 36,
		minDmg = 7,
		maxDmg = 8,
		meat = 2,
	},
	{
		id = "GOBLIN_POACHER",
		minLevel = 11,
		rounds = 6,
		share = 0.095,
		name = "LID_ENEMY_GOBLIN_POACHER",
		level = 1,
		sprite = "GOBLIN_IDLE",
		scale = 1.05,
		hp = 38,
		minDmg = 7,
		maxDmg = 9,
		meat = 0,
	},
	{
		id = "MARSH_CROC",
		minLevel = 12,
		rounds = 6.5,
		share = 0.095,
		name = "LID_ENEMY_MARSH_CROC",
		level = 1,
		sprite = "CROC_IDLE",
		scale = 1.55,
		tint = {0.7, 0.9, 0.6},
		hp = 42,
		minDmg = 7,
		maxDmg = 8,
		meat = 2,
	},
	{
		id = "MURLOC_RENEGADE",
		minLevel = 14,
		rounds = 6,
		share = 0.1,
		name = "LID_ENEMY_MURLOC_RENEGADE",
		level = 1,
		sprite = "BRAKIL_IDLE",
		scale = 1.1,
		tint = {1, 0.55, 0.55},
		hp = 40,
		minDmg = 8,
		maxDmg = 9,
		meat = 0,
	},
	{
		id = "REEF_LURKER",
		minLevel = 15,
		rounds = 7,
		share = 0.1,
		name = "LID_ENEMY_REEF_LURKER",
		level = 1,
		sprite = "CROC_IDLE",
		scale = 1.65,
		tint = {0.5, 0.7, 0.95},
		hp = 46,
		minDmg = 8,
		maxDmg = 9,
		meat = 1,
	},
	{
		id = "DEEP_MATRIARCH",
		unique = true,
		rounds = 8,
		share = 0.115,
		name = "LID_ENEMY_DEEP_MATRIARCH",
		level = 1,
		sprite = "CRAB_IDLE",
		scale = 1.55,
		tint = {0.8, 0.55, 1},
		hp = 52,
		minDmg = 9,
		maxDmg = 10,
		meat = 2,
	},
	{
		id = "CAVE_TUSKLORD",
		unique = true,
		rounds = 8.5,
		share = 0.12,
		name = "LID_ENEMY_CAVE_TUSKLORD",
		level = 1,
		sprite = "BOAR_IDLE",
		scale = 1.55,
		tint = {0.55, 0.5, 0.45},
		hp = 55,
		minDmg = 9,
		maxDmg = 11,
		meat = 3,
	},
	{
		id = "GOBLIN_SLAVER",
		unique = true,
		rounds = 8.5,
		share = 0.12,
		name = "LID_ENEMY_GOBLIN_SLAVER",
		level = 1,
		sprite = "GOBLIN_IDLE",
		scale = 1.35,
		tint = {1, 0.6, 0.45},
		hp = 55,
		minDmg = 10,
		maxDmg = 11,
		meat = 0,
	},
	{
		id = "BRINE_TYRANT",
		unique = true,
		rounds = 9,
		share = 0.125,
		name = "LID_ENEMY_BRINE_TYRANT",
		level = 1,
		sprite = "CROC_IDLE",
		scale = 2,
		tint = {0.45, 0.6, 0.8},
		hp = 58,
		minDmg = 10,
		maxDmg = 12,
		meat = 3,
	},
	{
		id = "DROWNED_PRIEST",
		unique = true,
		rounds = 9,
		share = 0.13,
		name = "LID_ENEMY_DROWNED_PRIEST",
		level = 1,
		sprite = "BRAKIL_IDLE",
		scale = 1.35,
		tint = {0.5, 0.95, 0.85},
		hp = 60,
		minDmg = 11,
		maxDmg = 12,
		meat = 0,
	},
	{
		id = "SHORE_TYRANT",
		unique = true,
		rounds = 9,
		share = 0.13,
		name = "LID_ENEMY_SHORE_TYRANT",
		level = 1,
		sprite = "BRAKIL_IDLE",
		scale = 1.5,
		tint = {1, 0.85, 0.35},
		hp = 60,
		minDmg = 10,
		maxDmg = 12,
		meat = 3,
	},
}

function ns.QuestText(quest, field)
	return ns:Trans(format("LID_QUEST_%s_%s", quest.id, field))
end

ns.QUESTS = {
	{
		id = "BANQUET",
		level = 1,
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
		level = 2,
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
		level = 3,
		kind = "kill",
		enemy = "CRAB_KING",
		need = 1,
		xp = 900,
		money = 250,
		item = "small_shield",
	},
	{
		id = "BOARS",
		level = 4,
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
		level = 5,
		kind = "kill",
		enemy = "CROC",
		need = 4,
		xp = 2200,
		money = 700,
		item = "tarnished_chain_vest",
	},
	{
		id = "MOTHER",
		level = 6,
		kind = "kill",
		enemy = "CROC_MOTHER",
		need = 1,
		xp = 3600,
		money = 1500,
		item = "tarnished_chain_leggings",
	},
	{
		id = "TIDEPOOLS",
		level = 7,
		kind = "kill",
		enemy = "TIDE_CRAB",
		need = 5,
		xp = 4000,
		money = 1600,
		item = "cadet_cloak",
	},
	{
		id = "SANDS",
		level = 8,
		kind = "kill",
		enemy = "SAND_CRAWLER",
		need = 6,
		xp = 5000,
		money = 1750,
		supply = {
			id = "quality_health_potion",
			count = 2
		},
	},
	{
		id = "TUSKS",
		level = 9,
		kind = "kill",
		enemy = "RAZORTUSK",
		need = 5,
		xp = 5400,
		money = 1900,
		item = "flimsy_chain_gloves",
	},
	{
		id = "LARDER",
		level = 10,
		kind = "meat",
		need = 12,
		xp = 6600,
		money = 2050,
		item = "tarnished_silver_chain",
	},
	{
		id = "BOGSIDE",
		level = 11,
		kind = "kill",
		enemy = "BOG_BOAR",
		need = 6,
		xp = 7900,
		money = 2200,
		item = "soldier_s_girdle",
	},
	{
		id = "MARSHES",
		level = 12,
		kind = "kill",
		enemy = "MARSH_CROC",
		need = 6,
		xp = 9350,
		money = 2400,
		item = "blade_of_cunning",
	},
	{
		id = "POACHERS",
		level = 13,
		kind = "kill",
		enemy = "GOBLIN_POACHER",
		need = 5,
		xp = 10900,
		money = 2600,
		item = "runed_copper_breastplate",
	},
	{
		id = "RENEGADES",
		level = 14,
		kind = "kill",
		enemy = "MURLOC_RENEGADE",
		need = 5,
		xp = 12600,
		money = 2800,
		item = "raider_s_gauntlets",
	},
	{
		id = "REEF",
		level = 15,
		kind = "kill",
		enemy = "REEF_LURKER",
		need = 6,
		xp = 14400,
		money = 3000,
		item = "agile_boots",
	},
	{
		id = "FEAST",
		level = 16,
		kind = "meat",
		need = 18,
		xp = 16300,
		money = 5800,
		supply = {
			id = "quality_health_potion",
			count = 4
		},
	},
	{
		id = "PATROL",
		level = 17,
		kind = "hunt",
		need = 10,
		xp = 18350,
		money = 6100,
		item = "orcish_war_chain",
	},
	{
		id = "CULL",
		level = 18,
		kind = "kill",
		enemy = "MARSH_CROC",
		need = 8,
		xp = 20500,
		money = 6500,
		item = "armor_of_the_fang",
	},
	{
		id = "WARBAND",
		level = 19,
		kind = "hunt",
		need = 12,
		xp = 22800,
		money = 6800,
		item = "leggings_of_the_fang",
	},
	{
		id = "TYRANT",
		level = 20,
		kind = "kill",
		enemy = "SHORE_TYRANT",
		need = 1,
		xp = 25200,
		money = 7200,
		item = "ashkandi_the_greatsword",
	},
}

ns.DUNGEON_QUESTS = {
	{
		id = "D_FIRST_DELVE",
		level = 5,
		kind = "hunt",
		need = 3,
		xp = 1200,
		money = 1200,
		supply = {
			id = "quality_health_potion",
			count = 2
		},
	},
	{
		id = "D_DEEP_CRABS",
		level = 6,
		kind = "kill",
		enemy = "TIDE_CRAB",
		need = 4,
		xp = 1700,
		money = 1500,
		item = "ragged_leather_belt",
	},
	{
		id = "D_MATRIARCH",
		level = 7,
		kind = "kill",
		enemy = "DEEP_MATRIARCH",
		need = 1,
		xp = 2250,
		money = 1800,
		item = "raiders_shoulderpads",
	},
	{
		id = "D_TUSKS",
		level = 8,
		kind = "kill",
		enemy = "RAZORTUSK",
		need = 4,
		xp = 2900,
		money = 2100,
		item = "bounty_hunter_s_ring",
	},
	{
		id = "D_BOGGED",
		level = 9,
		kind = "kill",
		enemy = "BOG_BOAR",
		need = 4,
		xp = 3600,
		money = 2400,
		item = "brewer_s_gloves",
	},
	{
		id = "D_TUSKLORD",
		level = 10,
		kind = "kill",
		enemy = "CAVE_TUSKLORD",
		need = 1,
		xp = 4400,
		money = 2700,
		item = "une_s_cape",
	},
	{
		id = "D_SLAVERS",
		level = 11,
		kind = "kill",
		enemy = "GOBLIN_POACHER",
		need = 5,
		xp = 5300,
		money = 3300,
		item = "elegant_shortsword",
	},
	{
		id = "D_SLAVER",
		level = 12,
		kind = "kill",
		enemy = "GOBLIN_SLAVER",
		need = 1,
		xp = 6250,
		money = 3600,
		item = "runic_cane",
	},
	{
		id = "D_DEEP_HUNT",
		level = 13,
		kind = "hunt",
		need = 6,
		xp = 7300,
		money = 3900,
		item = "night_watch_shortsword",
	},
	{
		id = "D_MARSH",
		level = 14,
		kind = "kill",
		enemy = "MARSH_CROC",
		need = 6,
		xp = 8400,
		money = 4200,
		item = "magefist_gloves",
	},
	{
		id = "D_BRINE",
		level = 15,
		kind = "kill",
		enemy = "BRINE_TYRANT",
		need = 1,
		xp = 9600,
		money = 4500,
		item = "the_ice_king_s_band",
	},
	{
		id = "D_REEF",
		level = 16,
		kind = "kill",
		enemy = "REEF_LURKER",
		need = 6,
		xp = 10900,
		money = 9600,
		item = "starsight_tunic",
	},
	{
		id = "D_RENEGADES",
		level = 17,
		kind = "kill",
		enemy = "MURLOC_RENEGADE",
		need = 6,
		xp = 12250,
		money = 10200,
		item = "crest_of_supremacy",
	},
	{
		id = "D_DROWNED",
		level = 18,
		kind = "kill",
		enemy = "DROWNED_PRIEST",
		need = 1,
		xp = 13700,
		money = 10800,
		item = "flowing_ritual_robes",
	},
	{
		id = "D_GAUNTLET",
		level = 19,
		kind = "hunt",
		need = 10,
		xp = 15200,
		money = 11400,
		item = "the_dragons_eye",
	},
	{
		id = "D_ENDLESS",
		level = 20,
		kind = "hunt",
		need = 12,
		xp = 16800,
		money = 12000,
		item = "grand_marshal_s_aegis",
	},
}

ns.QUEST_TRACKS = {
	main = {
		id = "main",
		list = ns.QUESTS,
		state = "quest",
		index = "questIndex",
		progress = "questProgress",
		elite = false,
	},
	dungeon = {
		id = "dungeon",
		list = ns.DUNGEON_QUESTS,
		state = "dquest",
		index = "dquestIndex",
		progress = "dquestProgress",
		elite = true,
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
ns.SPELL_DIVISOR = 4
ns.XP_PER_MOB_LEVEL = 100
ns.DUNGEON_LEVEL = 5
ns.MOB_HP = 0.5
ns.STREAK_STEP = 0.05
ns.ELITE_HP = 2
ns.ELITE_DMG = 2
ns.ELITE_XP = 2
ns.ELITE_MONEY = 3
function ns.MaxHealth(stm, level)
	local hp = 85 + stm * 10
	if level > 1 then hp = hp + 48 * (level - 1) + 11 end
	return hp
end

function ns.MaxMana(int)
	return 100 + (int - 9) * 2
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
		local ramp = math.min(1, 0.45 + 0.55 * (playerLevel - 1) / 3)
		local hit = stats.maxHP * enemy.share * ramp
		enemy.hp = math.max(enemy.hp, math.floor(stats.maxHP * ns.MOB_HP + 0.5))
		enemy.minDmg = math.max(1, math.floor(hit + 0.5))
		enemy.maxDmg = math.max(enemy.minDmg, math.floor(hit * 1.18 + 0.5))
	else
		enemy.hp = math.floor(enemy.hp * ns.MOB_HP + 0.5)
	end

	enemy.maxHP = enemy.hp
end

function ns.ApplyStreak(enemy, streak)
	if not streak or streak <= 0 then return end
	local mult = 1 + ns.STREAK_STEP * streak
	enemy.hp = math.floor(enemy.hp * mult + 0.5)
	enemy.maxHP = enemy.hp
	enemy.minDmg = math.max(1, math.floor(enemy.minDmg * mult + 0.5))
	enemy.maxDmg = math.max(enemy.minDmg, math.floor(enemy.maxDmg * mult + 0.5))
	enemy.streak = streak
end

function ns.MakeElite(enemy)
	enemy.elite = true
	enemy.hp = enemy.hp * ns.ELITE_HP
	enemy.maxHP = enemy.hp
	enemy.minDmg = enemy.minDmg * ns.ELITE_DMG
	enemy.maxDmg = enemy.maxDmg * ns.ELITE_DMG
end
