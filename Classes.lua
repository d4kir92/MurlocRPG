local _, ns = ...

local STAT_TEXT = {
	str = "Increases Strength by %d.",
	stm = "Increases Stamina by %d.",
	int = "Increases Intellect by %d.",
	agi = "Increases Agility by %d.",
	dmg = "Increases your damage by %d%%.",
	crit = "Increases your critical strike chance by %d%%.",
	armor = "Increases Armor by %d.",
	regen = "Restores %d additional energy each round.",
	cost = "Reduces ability energy cost by %d%%.",
	lifesteal = "Heals you for %d%% of the damage you deal.",
}

function ns.TalentDesc(talent)
	local fmt = STAT_TEXT[talent.stat]

	if not fmt then
		return ""
	end

	return format(fmt, talent.value)
end

function ns.AbilityDesc(ability)
	local mod = ability.mod or 0

	if ability.kind == "heal" then
		return format("Restores %d health per level.", mod)
	end

	if ability.school == "magic" then
		if ability.kind == "drain" then
			return format("Deals %d damage per level and heals you for the same amount.", mod)
		end

		return format("Deals %d damage per level.", mod)
	end

	if ability.kind == "critstrike" then
		return format("A weapon strike with %d bonus damage per level that always critically strikes.", mod)
	end

	if ability.kind == "drain" then
		return format("A weapon strike with %d bonus damage per level that heals you for the damage dealt.", mod)
	end

	return format("A weapon strike with %d bonus damage per level.", mod)
end

ns.CLASSES = {
	{
		id = "RAIDER",
		name = "Raider",
		icon = "Raider",
		desc = "Weapon masters, bloodthirsty berserker's, and defenders of the weak. Raiders are a force to be reckoned with on the battlefield.",
		abilities = {
			{id = "CHARGE", name = "Charge", icon = "charge", level = 1, cost = 20, kind = "damage", mod = 3},
			{id = "MORTALSTRIKE", name = "Mortal Strike", icon = "mortalstrike", level = 3, cost = 15, kind = "damage", mod = 7},
			{id = "EXECUTE", name = "Execute", icon = "execute_icon", level = 5, cost = 25, kind = "damage", mod = 6},
		},
		trees = {
			{
				name = "Protection",
				icon = "shieldblock",
				talents = {
					{name = "Toughness", icon = "toughness", stat = "stm", value = 8},
					{name = "Shield Specialization", icon = "shieldblock", stat = "armor", value = 80},
					{name = "Iron Will", icon = "Spell_Holy_SealOfProtection", stat = "stm", value = 10},
					{name = "Anticipation", icon = "INV_Shield_04", stat = "armor", value = 100},
					{name = "Improved Revenge", icon = "revenge", stat = "dmg", value = 5},
					{name = "Defiance", icon = "shieldbash", stat = "armor", value = 100},
					{name = "Last Stand", icon = "laststand", stat = "stm", value = 14},
					{name = "Shield Slam", icon = "shieldslam", stat = "dmg", value = 8},
					{name = "Concussion Blow", icon = "pummel", stat = "crit", value = 4},
					{name = "Shield Wall", icon = "shieldwall", stat = "armor", value = 160},
				},
			},
			{
				name = "Arms",
				icon = "mortalstrike",
				talents = {
					{name = "Improved Heroic Strike", icon = "heroicstrike", stat = "cost", value = 12},
					{name = "Deflection", icon = "Ability_Warrior_Disarm", stat = "crit", value = 3},
					{name = "Deep Wounds", icon = "deepwounds", stat = "dmg", value = 6},
					{name = "Impale", icon = "rend", stat = "crit", value = 4},
					{name = "Battle Shout", icon = "battleshout", stat = "dmg", value = 6},
					{name = "Sweeping Strikes", icon = "thunderclap", stat = "dmg", value = 7},
					{name = "Poleaxe Specialization", icon = "INV_Sword_06", stat = "crit", value = 5},
					{name = "Improved Overpower", icon = "overpower", stat = "dmg", value = 8},
					{name = "Death Wish", icon = "recklessness", stat = "dmg", value = 10},
					{name = "Mortal Strike", icon = "mortalstrike", stat = "dmg", value = 12},
				},
			},
		},
	},
	{
		id = "ORACLE",
		name = "Oracle",
		icon = "Oracle",
		desc = "Knowledgeable and powerful, oracles can assault their foes with raw arcane magic, burn their foes to ash with powerful fire magic, and chill and freeze their enemies to the bone with extremely cold frost magic.",
		abilities = {
			{id = "FROSTSHOCK", name = "Frost Shock", icon = "frostshock", level = 1, cost = 20, kind = "damage", mod = 6, school = "magic", fx = "FX_FROSTBOLT"},
			{id = "DRAINLIFE", name = "Drain Life", icon = "Spell_shadow_lifedrain02", level = 3, cost = 25, kind = "drain", mod = 6, school = "magic", fx = "FX_DRAIN"},
			{id = "PYROBLAST", name = "Pyroblast", icon = "pyroblast_icon", level = 5, cost = 55, kind = "damage", mod = 16, school = "magic", fx = "FX_FIREBALL"},
		},
		trees = {
			{
				name = "Fire",
				icon = "pyroblast_icon",
				talents = {
					{name = "Improved Fireball", icon = "pyroblast_icon", stat = "cost", value = 12},
					{name = "Ignite", icon = "flameshock", stat = "dmg", value = 6},
					{name = "Incineration", icon = "searingtotem", stat = "crit", value = 4},
					{name = "Burning Soul", icon = "Spell_shadow_bloodboil", stat = "agi", value = 5},
					{name = "Fire Power", icon = "firenovatotem", stat = "dmg", value = 8},
					{name = "Pyroblast", icon = "Ability_Creature_Cursed_01", stat = "dmg", value = 10},
					{name = "Blast Wave", icon = "Ability_Creature_Cursed_02", stat = "dmg", value = 7},
					{name = "Combustion", icon = "bloodlust", stat = "crit", value = 6},
					{name = "Master of Elements", icon = "elementalmastery", stat = "regen", value = 1},
					{name = "Living Bomb", icon = "Spell_shadow_curse", stat = "dmg", value = 12},
				},
			},
			{
				name = "Frost",
				icon = "forstnova_icon",
				talents = {
					{name = "Frostbite", icon = "frostshock", stat = "dmg", value = 5},
					{name = "Elemental Precision", icon = "Ability_Marksmanship", stat = "crit", value = 3},
					{name = "Ice Shards", icon = "forstnova_icon", stat = "crit", value = 5},
					{name = "Frost Channeling", icon = "manaspring", stat = "cost", value = 12},
					{name = "Shatter", icon = "Spell_polymorph_icon", stat = "crit", value = 6},
					{name = "Ice Barrier", icon = "elementalshield", stat = "armor", value = 120},
					{name = "Arctic Reach", icon = "Spell_nature_earthbindtotem", stat = "dmg", value = 7},
					{name = "Cold Snap", icon = "naturesswiftness", stat = "agi", value = 8},
					{name = "Winter's Chill", icon = "INV_Misc_Orb_01", stat = "dmg", value = 9},
					{name = "Ice Block", icon = "hex", stat = "armor", value = 160},
				},
			},
		},
	},
	{
		id = "TIDEHUNTER",
		name = "Tide Hunter",
		icon = "Tide_Hunter",
		desc = "Swift hunters of the shallows. Tide hunters strike from ambush with poisoned blades and finish a fight before the tide turns.",
		abilities = {
			{id = "EVISCERATE", name = "Eviscerate", icon = "Ability_rogue_eviscerate", level = 1, cost = 15, kind = "damage", mod = 4},
			{id = "COLDBLOOD", name = "Cold Blood", icon = "cold_blood_icon", level = 3, cost = 20, kind = "critstrike", mod = 2},
			{id = "AMBUSH", name = "Ambush", icon = "Ability_rogue_ambush", level = 5, cost = 60, kind = "damage", mod = 6},
		},
		trees = {
			{
				name = "Assassination",
				icon = "deadlypoison",
				talents = {
					{name = "Malice", icon = "coldblood", stat = "crit", value = 3},
					{name = "Improved Eviscerate", icon = "eviscerate", stat = "dmg", value = 6},
					{name = "Lethality", icon = "Ability_rogue_eviscerate", stat = "crit", value = 5},
					{name = "Vile Poisons", icon = "instantpoison", stat = "dmg", value = 7},
					{name = "Improved Poisons", icon = "deadlypoison", stat = "dmg", value = 8},
					{name = "Cold Blood", icon = "cold_blood_icon", stat = "crit", value = 6},
					{name = "Murder", icon = "backstab", stat = "dmg", value = 8},
					{name = "Seal Fate", icon = "destiny", stat = "crit", value = 5},
					{name = "Vigor", icon = "vigor", stat = "agi", value = 8},
					{name = "Mutilate", icon = "ambush", stat = "dmg", value = 12},
				},
			},
			{
				name = "Combat",
				icon = "sinisterstrike",
				talents = {
					{name = "Improved Sinister Strike", icon = "sinisterstrike", stat = "cost", value = 12},
					{name = "Lightning Reflexes", icon = "evasion", stat = "armor", value = 80},
					{name = "Riposte", icon = "kick", stat = "armor", value = 100},
					{name = "Precision", icon = "Ability_rogue_ambush", stat = "crit", value = 4},
					{name = "Endurance", icon = "preparation", stat = "stm", value = 10},
					{name = "Blade Flurry", icon = "hemorage", stat = "dmg", value = 8},
					{name = "Dual Wield Specialization", icon = "INV_Sword_06", stat = "dmg", value = 7},
					{name = "Aggression", icon = "bloodcraze", stat = "dmg", value = 8},
					{name = "Adrenaline Rush", icon = "adrenaline_icon", stat = "regen", value = 1},
					{name = "Weapon Expertise", icon = "addrenalinerush", stat = "lifesteal", value = 10},
				},
			},
		},
	},
	{
		id = "CLASSIC",
		name = "Classic",
		icon = "Classic",
		desc = "Murk's original combat skills, a true classic blend between magic, energy and rage. Still making use of the improved combat system this class will guarantee that nostalgic feeling.",
		abilities = {
			{id = "HEROIC_STRIKE", name = "Heroic Strike", icon = "heroicstrike", level = 1, cost = 15, kind = "damage", mod = 4},
			{id = "HEAL", name = "Heal", icon = "Spell_holy_heal", level = 3, cost = 45, kind = "heal", mod = 60, school = "magic", fx = "FX_HEAL"},
			{id = "DRAINLIFE", name = "Drain Life", icon = "Spell_shadow_lifedrain02", level = 5, cost = 25, kind = "drain", mod = 6, school = "magic", fx = "FX_DRAIN"},
		},
		trees = {
			{
				name = "Fury",
				icon = "bloodrage_icon",
				talents = {
					{name = "Cruelty", icon = "bloodrage_icon", stat = "crit", value = 3},
					{name = "Unbridled Wrath", icon = "bloodrage", stat = "regen", value = 1},
					{name = "Improved Heroic Strike", icon = "heroicstrike", stat = "cost", value = 12},
					{name = "Blood Craze", icon = "bloodcraze", stat = "lifesteal", value = 8},
					{name = "Piercing Howl", icon = "Ability_GhoulFrenzy", stat = "dmg", value = 6},
					{name = "Enrage", icon = "Bloodpower", stat = "dmg", value = 8},
					{name = "Death Wish", icon = "recklessness", stat = "dmg", value = 10},
					{name = "Flurry", icon = "windfurytotem", stat = "crit", value = 5},
					{name = "Bloodthirst", icon = "Spell_shadow_bloodboil", stat = "lifesteal", value = 12},
					{name = "Rampage", icon = "bloodlust", stat = "dmg", value = 12},
				},
			},
			{
				name = "Restoration",
				icon = "Spell_holy_heal",
				talents = {
					{name = "Improved Heal", icon = "Spell_holy_heal", stat = "cost", value = 12},
					{name = "Spirit Tap", icon = "Spell_nature_regeneration", stat = "agi", value = 5},
					{name = "Healing Focus", icon = "healingstream", stat = "stm", value = 10},
					{name = "Improved Drain Life", icon = "Spell_shadow_lifedrain02", stat = "lifesteal", value = 10},
					{name = "Meditation", icon = "magic_dust", stat = "regen", value = 1},
					{name = "Renew", icon = "renew_icon", stat = "stm", value = 12},
					{name = "Power Word: Shield", icon = "powerwordshield_icon", stat = "armor", value = 120},
					{name = "Healing Wave", icon = "healingwave", stat = "stm", value = 14},
					{name = "Chain Heal", icon = "chainheal", stat = "lifesteal", value = 12},
					{name = "Ancestral Spirit", icon = "ancestralspirit", stat = "armor", value = 160},
				},
			},
		},
	},
}

ns.CLASS_BY_ID = {}

for _, class in ipairs(ns.CLASSES) do
	ns.CLASS_BY_ID[class.id] = class

	for index, tree in ipairs(class.trees) do
		tree.index = index

		for i, talent in ipairs(tree.talents) do
			talent.index = i
			talent.tier = math.ceil(i / 2)
			talent.column = (i - 1) % 2
			talent.tree = tree
		end
	end
end
