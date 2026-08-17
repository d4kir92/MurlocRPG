local _, ns = ...

ns.MAX_LEVEL = 20

ns.MEDIA = "Interface\\AddOns\\MurlocRPG\\media\\"
ns.SCENE_SHORE = ns.MEDIA .. "scene_shore"
ns.BG_WORLD = ns.MEDIA .. "bg_world"
ns.BG_LOADING = ns.MEDIA .. "bg_loading"
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

ns.L = {
	TITLE = "Murloc RPG",
	SUBTITLE = "The tale of Murk",
	NEW_GAME = "New Game",
	LOAD_GAME = "Load",
	LOADING = "Loading...",
	ENTER_WORLD = "Enter World",
	CHOOSE_CLASS = "Choose your path",
	SKILLS = "Skills:",
	OVERWRITE = "Starting a new game overwrites your current character.",
	LEVEL = "Level %d",
	XP = "XP %d / %d",
	XP_MAX = "Max level",
	BARTEXT = "%d / %d",
	BAG = "Raw Meat: %d",
	CAMP_TITLE = "Murloc Camp",
	CAMP_TEXT = "Reeds rustle around the huts of your tribe. The warriors are hungry, and Chief Brakil keeps looking your way.",
	CLICK_BRAKIL = "Click Chief Brakil to talk to him.",
	TALENTS = "Talents",
	TALENT_POINTS = "Talent Points: %d",
	TALENT_RESET = "Reset",
	TALENT_SPENT = "%s: %d",
	TALENT_LEARNED = "Learned %s.",
	TALENT_NEED = "Requires %d points in %s.",
	TALENT_NONE = "No talent points left.",
	TALENT_CLEARED = "Your talents have been reset.",
	NEXT_ENEMY = "Next Enemy",
	RETURN_CAMP = "Return to Camp",
	RESURRECT = "Resurrect",
	SPIRIT_HEALER = "Spirit Healer",
	VICTORY_TITLE = "Victory",
	DEAD_TITLE = "You are dead",
	DEAD_TEXT = "A spirit healer drifts out of the reeds and waits for you.",
	RESURRECTED = "The spirit healer restores you to life.",
	HEALER_HINT = "Click to return to your body.",
	CHARACTER = "Character",
	INVENTORY = "Inventory",
	INVENTORY_TITLE = "Inventory  (%d / %d)",
	EQUIPPED_HINT = "Click to unequip.",
	BAG_HINT = "Click to equip.  Shift + right-click to destroy.",
	BAG_FULL = "Your bag is full.",
	ITEM_LEVEL = "Requires level %d.",
	ITEM_EQUIPPED = "Equipped %s.",
	ITEM_UNEQUIPPED = "Unequipped %s.",
	ITEM_DESTROYED = "Destroyed %s.",
	ITEM_DROP = "%s drops %s.",
	ITEM_DROP_LOST = "%s drops %s, but your bag is full.",
	ITEM_SLOT_REQ = "Requires level %d",
	STATS = "Stats",
	STAT_STR = "Strength",
	STAT_STM = "Stamina",
	STAT_INT = "Intellect",
	STAT_AGI = "Agility",
	STAT_HEALTH = "Health",
	STAT_MANA = "Energy",
	STAT_DAMAGE = "Damage",
	STAT_CRIT = "Crit",
	STAT_ARMOR = "Armor",
	STAT_REGEN = "Energy Regen",
	STAT_LIFESTEAL = "Life Steal",
	EMPTY_SLOT = "Empty",
	SHOP = "Merchant",
	SHOP_TITLE = "Blacksmith Frazzak",
	SHOP_BUY = "Wares",
	SHOP_SELL = "Your Bag",
	SHOP_MONEY = "Purse: %s",
	SHOP_COST = "Price: %s",
	SHOP_SELLS_FOR = "Sells for: %s",
	SHOP_BUY_HINT = "Click to buy.",
	SHOP_SELL_HINT = "Click to sell.",
	SHOP_NO_MONEY = "You cannot afford %s.",
	SHOP_BOUGHT = "Bought %s for %s.",
	SHOP_SOLD = "Sold %s for %s.",
	SHOP_WORTHLESS = "%s is worth nothing.",
	SHOP_EMPTY = "Frazzak has nothing for you yet.",
	CLICK_MERCHANT = "Click Frazzak to trade.",
	LOOT_MONEY = "You loot %s.",
	ITEM_VALUE = "Value: %s",
	TALK = "Talk to Brakil",
	HUNT = "Hunt on the Shore",
	REST = "Rest",
	RESTED = "You curl up in the reeds and feel refreshed.",
	ACT_ATTACK = "Attack",
	ACT_ITEM = "%s (%d)",
	SHOP_SUPPLIES = "Supplies",
	CONSUMABLE_OWNED = "You have %d.",
	CONSUMABLE_ENERGY = "You recover %d energy.",
	ACT_FLEE = "Flee",
	ATTACK_DESC = "A free swipe with your claws.",
	FLEE_DESC = "60% chance to escape. On failure the enemy strikes you.",
	ITEM_DESC = "%s  You have %d.",
	COST = "Costs %d energy.",
	LOCKED = "Unlocks at level %d.",
	BATTLE_START = "A %s lunges out of the water!",
	P_HIT = "You hit %s for %d.",
	P_CRIT = "Critical! You hit %s for %d.",
	P_CAST = "You use %s.",
	P_HEAL = "You recover %d health.",
	P_DRAIN = "You drain %d health.",
	E_HIT = "%s hits you for %d.",
	E_CRIT = "%s crits you for %d!",
	NO_MANA = "Not enough energy.",
	NO_ITEM = "You have none left.",
	USE_ITEM = "You use %s and recover %d health.",
	FLEE_OK = "You scurry back to camp.",
	FLEE_FAIL = "You cannot escape!",
	WIN = "%s dies. You gain %d experience.",
	LOOT = "You loot %d x %s.",
	DEAD = "You black out and wake up back at camp.",
	LEVELUP = "You reached level %d!",
	AT_MAX = "That is the end of the demo content for now.",
	LEARNED = "You learned %s!",
	POINT_GAINED = "You gained a talent point.",
	Q_ACCEPTED = "Quest accepted: %s",
	Q_REWARD = "Quest complete: %d experience.",
	Q_REWARD_MONEY = "Reward: %s",
	Q_REWARD_ITEM = "Reward: %s",
	Q_REWARD_SUPPLY = "Reward: %d x %s",
	Q_FINISHED = "Brakil: \"Nothing more for you today, Murk. Rest -- bigger things await.\"",
	Q_ALL_DONE = "All of Brakil's tasks are done.",
	Q_LINE = "Quest: %s  (%d / %d)",
	Q_LINE_DONE = "Quest: %s  (complete)",
	Q_LINE_NEW = "Brakil has a task: %s",
	LOADED = "|cff55d2ffMurloc RPG|r loaded. Type |cffffd100/murloc|r to play.",
}

ns.SPRITES = {
	MURK_IDLE = {file = "murk_idle", frames = 16, cols = 4, rows = 4},
	MURK_WALK = {file = "murk_walk", frames = 20, cols = 8, rows = 4},
	MURK_ATTACK = {file = "murk_attack", frames = 20, cols = 8, rows = 4},
	MURK_ATTACK_WEAPON = {file = "murk_attack_weapon", frames = 20, cols = 8, rows = 4},
	MURK_CAST = {file = "murk_cast", frames = 16, cols = 4, rows = 4},
	FX_FIREBALL = {file = "fx_fireball", frames = 16, cols = 4, rows = 4},
	FX_FROSTBOLT = {file = "fx_frostbolt", frames = 16, cols = 4, rows = 4},
	FX_DRAIN = {file = "fx_drain", frames = 16, cols = 4, rows = 4},
	FX_HEAL = {file = "fx_heal", frames = 16, cols = 4, rows = 4},
	BRAKIL_IDLE = {file = "brakil_idle", frames = 16, cols = 4, rows = 4},
	CRAB_IDLE = {file = "crab_idle", frames = 16, cols = 4, rows = 4},
	BOAR_IDLE = {file = "boar_idle", frames = 16, cols = 4, rows = 4},
	CROC_IDLE = {file = "croc_idle", frames = 16, cols = 4, rows = 4},
	GOBLIN_IDLE = {file = "goblin_idle", frames = 16, cols = 4, rows = 4},
}

ns.COPPER_PER_SILVER = 100
ns.SILVER_PER_GOLD = 100
ns.COPPER_PER_GOLD = ns.COPPER_PER_SILVER * ns.SILVER_PER_GOLD

function ns.MoneyText(copper)
	copper = math.max(0, math.floor(copper or 0))

	local gold = math.floor(copper / ns.COPPER_PER_GOLD)
	local silver = math.floor((copper % ns.COPPER_PER_GOLD) / ns.COPPER_PER_SILVER)
	local rest = copper % ns.COPPER_PER_SILVER
	local out = ""

	if gold > 0 then
		out = format("|cffffd700%d|rg ", gold)
	end

	if gold > 0 or silver > 0 then
		out = out .. format("|cffc7c7cf%d|rs ", silver)
	end

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
	MEAT = {name = "Raw Meat", icon = "wolf_meat"},
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
		supply = {id = "spiced_wolf_meat", count = 2},
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
		supply = {id = "magic_dust", count = 2},
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
		supply = {id = "spiced_wolf_meat", count = 3},
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
	RAIDER = {str = 12, stm = 10, int = 9, agi = 9},
	ORACLE = {str = 10, stm = 9, int = 9, agi = 12},
	TIDEHUNTER = {str = 9, stm = 12, int = 10, agi = 9},
	CLASSIC = {str = 9, stm = 9, int = 12, agi = 10},
}

ns.CRIT_ROLL = 95
ns.ARMOR_DIVISOR = 20
ns.XP_PER_MOB_LEVEL = 100

function ns.MaxHealth(stm, level)
	local hp = 85 + stm * 10

	if level > 1 then
		hp = hp + 48 * (level - 1) + 11
	end

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
