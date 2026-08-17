local _, ns = ...
ns.MAX_LEVEL = 20
ns.MEDIA = "Interface\\AddOns\\MurlocRPG\\media\\"
ns.SCENE_SHORE = ns.MEDIA .. "scene_shore"
ns.BG_WORLD = ns.MEDIA .. "bg_world"
ns.BG_LOADING = ns.MEDIA .. "bg_loading"
ns.BG_CAMP = ns.MEDIA .. "bg_camp"
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
		name = "Raw Meat",
		icon = "wolf_meat"
	},
}

ns.CONSUMABLES = {
	{
		id = "spiced_wolf_meat",
		name = "Spiced Wolf Meat",
		icon = "spiced_wolf_meat",
		desc = "Restores 150 Health.",
		kind = "heal",
		amount = 150,
		value = 100,
	},
	{
		id = "magic_dust",
		name = "Magic Dust",
		icon = "magic_dust",
		desc = "Restores 50 Energy.",
		kind = "energy",
		amount = 50,
		value = 60,
	},
	{
		id = "quality_health_potion",
		name = "Quality Health Potion",
		icon = "INV_Potion_51",
		desc = "Restores 300 Health.",
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
		name = "Forest Boar",
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
		name = "Beach Crawler",
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
		name = "Beach Crawler King",
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
		name = "Young Crocolisk",
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
		name = "Mother Crocolisk",
		level = 1,
		sprite = "CROC_IDLE",
		scale = 1.9,
		hp = 50,
		minDmg = 9,
		maxDmg = 10,
		meat = 2,
	},
}

ns.QUESTS = {
	{
		id = "BANQUET",
		name = "A Banquet for the Warriors",
		offer = "Brakil: \"Ah, Murk. There you are! The camp has grown empty ever since we sent our finest warriors against the Kobolds -- and word is, they won. We are holding a banquet for them. We need Tender Wolf Meat to cook, and with the warriors gone we are depending on you.\"",
		hint = "Brakil: \"Venture out to the shore and return with %d meat. Stay close to the camp -- the further you go, the more dangerous it is.\"",
		turnin = "Brakil: \"I see you have got the meat. Good work, Murk. Take this to Ketchin so he can prepare it for the banquet.\"",
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
		name = "Bait Thieves",
		offer = "Brakil: \"Fisherman Kagle came by, red in the face. Those damn crabs keep stealing his bait and he cannot land a single fish. Go fend them off -- we still need something for dessert.\"",
		hint = "Kagle: \"Keep it up, Murk! %d of %d crawlers down.\"",
		turnin = "Brakil: \"Kagle says you cleared the whole shoreline. We have enough fish to prepare dessert now.\"",
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
		name = "Hold Fast",
		offer = "Brakil: \"Kagle sent word again. One more crawler came out of the water after you left -- a big one. He says to hold fast and finish it before it takes his whole catch.\"",
		hint = "Kagle: \"Wait -- this one looks like it could be a big one. Hold fast!\"",
		turnin = "Brakil: \"That crawler was nearly your size, Murk. The camp is talking about it.\"",
		kind = "kill",
		enemy = "CRAB_KING",
		need = 1,
		xp = 900,
		money = 250,
		item = "small_shield",
	},
	{
		id = "BOARS",
		name = "Boars at the Tower",
		offer = "Brakil: \"One of the guards asked for you by name. Boars have swarmed the tower at the edge of the forest. He says he can make it worth your while -- talent recognises talent, apparently.\"",
		hint = "Guard: \"Stop talking to me and go put those boars in their place. %d of %d down.\"",
		turnin = "Brakil: \"The guard says you put those boars in their place. He sent your reward along.\"",
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
		name = "The Trip to the Princess",
		offer = "Brakil: \"Kagle is taking his boat out past the reeds and wants you aboard. He swears the waters are empty. He also swore the crabs were harmless, so bring your weapon.\"",
		hint = "Kagle: \"These empty waters are filled with Crocolisks, Murk. %d of %d handled.\"",
		turnin = "Brakil: \"Kagle made it back in one piece, which surprises everyone including Kagle.\"",
		kind = "kill",
		enemy = "CROC",
		need = 4,
		xp = 2200,
		money = 700,
		item = "tarnished_chain_vest",
	},
	{
		id = "MOTHER",
		name = "Mother of Crocolisks",
		offer = "Brakil: \"The young crocolisks did not crawl out of the water on their own, Murk. Something laid them. Kagle saw her in the shallows and has not been back on the water since. End it.\"",
		hint = "Brakil: \"She is still out there. Do not go alone if you are not ready.\"",
		turnin = "Brakil: \"Mrglglgl! The shore is ours again. Rest now, Murk -- bigger things await.\"",
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
