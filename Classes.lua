local _, ns = ...
local STAT_TEXT = {
	str = "LID_TDESC_STR",
	stm = "LID_TDESC_STM",
	int = "LID_TDESC_INT",
	agi = "LID_TDESC_AGI",
	dmg = "LID_TDESC_DMG",
	crit = "LID_TDESC_CRIT",
	armor = "LID_TDESC_ARMOR",
	regen = "LID_TDESC_REGEN",
	cost = "LID_TDESC_COST",
	lifesteal = "LID_TDESC_LIFESTEAL",
}

function ns.TalentDesc(talent)
	local key = STAT_TEXT[talent.stat]
	if not key then return "" end
	return format(ns:Trans(key), talent.value)
end

function ns.AbilityDesc(ability)
	local mod = ability.mod or 0
	if ability.kind == "heal" then return format(ns:Trans("LID_ADESC_HEAL"), mod) end
	if ability.school == "magic" then
		if ability.kind == "drain" then return format(ns:Trans("LID_ADESC_MAGIC_DRAIN"), mod) end
		return format(ns:Trans("LID_ADESC_MAGIC"), mod)
	end

	if ability.kind == "critstrike" then return format(ns:Trans("LID_ADESC_CRIT"), mod) end
	if ability.kind == "drain" then return format(ns:Trans("LID_ADESC_DRAIN"), mod) end
	return format(ns:Trans("LID_ADESC_WEAPON"), mod)
end

ns.CLASSES = {
	{
		id = "RAIDER",
		name = "LID_CLASS_RAIDER",
		icon = "Raider",
		desc = "LID_CLASS_RAIDER_DESC",
		abilities = {
			{
				id = "CHARGE",
				name = "LID_ABILITY_CHARGE",
				icon = "charge",
				level = 1,
				cost = 10,
				kind = "damage",
				mod = 3
			},
			{
				id = "MORTALSTRIKE",
				name = "LID_ABILITY_MORTAL_STRIKE",
				icon = "mortalstrike",
				level = 3,
				cost = 15,
				kind = "damage",
				mod = 6
			},
			{
				id = "EXECUTE",
				name = "LID_ABILITY_EXECUTE",
				icon = "execute_icon",
				level = 5,
				cost = 25,
				kind = "damage",
				mod = 12
			},
		},
		trees = {
			{
				name = "LID_TREE_PROTECTION",
				icon = "shieldblock",
				talents = {
					{
						name = "LID_TALENT_TOUGHNESS",
						icon = "toughness",
						stat = "stm",
						value = 8
					},
					{
						name = "LID_TALENT_SHIELD_SPECIALIZATION",
						icon = "shieldblock",
						stat = "armor",
						value = 80
					},
					{
						name = "LID_TALENT_IRON_WILL",
						icon = "Spell_Holy_SealOfProtection",
						stat = "stm",
						value = 10
					},
					{
						name = "LID_TALENT_ANTICIPATION",
						icon = "INV_Shield_04",
						stat = "armor",
						value = 100
					},
					{
						name = "LID_TALENT_IMPROVED_REVENGE",
						icon = "revenge",
						stat = "dmg",
						value = 5
					},
					{
						name = "LID_TALENT_DEFIANCE",
						icon = "shieldbash",
						stat = "armor",
						value = 100
					},
					{
						name = "LID_TALENT_LAST_STAND",
						icon = "laststand",
						stat = "stm",
						value = 14
					},
					{
						name = "LID_TALENT_SHIELD_SLAM",
						icon = "shieldslam",
						stat = "dmg",
						value = 8
					},
					{
						name = "LID_TALENT_CONCUSSION_BLOW",
						icon = "pummel",
						stat = "crit",
						value = 4
					},
					{
						name = "LID_TALENT_SHIELD_WALL",
						icon = "shieldwall",
						stat = "armor",
						value = 160
					},
				},
			},
			{
				name = "LID_TREE_ARMS",
				icon = "mortalstrike",
				talents = {
					{
						name = "LID_TALENT_IMPROVED_HEROIC_STRIKE",
						icon = "heroicstrike",
						stat = "cost",
						value = 12
					},
					{
						name = "LID_TALENT_DEFLECTION",
						icon = "Ability_Warrior_Disarm",
						stat = "crit",
						value = 3
					},
					{
						name = "LID_TALENT_DEEP_WOUNDS",
						icon = "deepwounds",
						stat = "dmg",
						value = 6
					},
					{
						name = "LID_TALENT_IMPALE",
						icon = "rend",
						stat = "crit",
						value = 4
					},
					{
						name = "LID_TALENT_BATTLE_SHOUT",
						icon = "battleshout",
						stat = "dmg",
						value = 6
					},
					{
						name = "LID_TALENT_SWEEPING_STRIKES",
						icon = "thunderclap",
						stat = "dmg",
						value = 7
					},
					{
						name = "LID_TALENT_POLEAXE_SPECIALIZATION",
						icon = "INV_Sword_06",
						stat = "crit",
						value = 5
					},
					{
						name = "LID_TALENT_IMPROVED_OVERPOWER",
						icon = "overpower",
						stat = "dmg",
						value = 8
					},
					{
						name = "LID_TALENT_DEATH_WISH",
						icon = "recklessness",
						stat = "dmg",
						value = 10
					},
					{
						name = "LID_TALENT_MORTAL_STRIKE",
						icon = "mortalstrike",
						stat = "dmg",
						value = 12
					},
				},
			},
		},
	},
	{
		id = "ORACLE",
		name = "LID_CLASS_ORACLE",
		icon = "Oracle",
		desc = "LID_CLASS_ORACLE_DESC",
		abilities = {
			{
				id = "FROSTSHOCK",
				name = "LID_ABILITY_FROST_SHOCK",
				icon = "frostshock",
				level = 1,
				cost = 20,
				kind = "damage",
				mod = 6,
				school = "magic",
				fx = "FX_FROSTBOLT"
			},
			{
				id = "DRAINLIFE",
				name = "LID_ABILITY_DRAIN_LIFE",
				icon = "Spell_shadow_lifedrain02",
				level = 3,
				cost = 25,
				kind = "drain",
				mod = 6,
				school = "magic",
				fx = "FX_DRAIN"
			},
			{
				id = "PYROBLAST",
				name = "LID_ABILITY_PYROBLAST",
				icon = "pyroblast_icon",
				level = 5,
				cost = 55,
				kind = "damage",
				mod = 16,
				school = "magic",
				fx = "FX_FIREBALL"
			},
		},
		trees = {
			{
				name = "LID_TREE_FIRE",
				icon = "pyroblast_icon",
				talents = {
					{
						name = "LID_TALENT_IMPROVED_FIREBALL",
						icon = "pyroblast_icon",
						stat = "cost",
						value = 12
					},
					{
						name = "LID_TALENT_IGNITE",
						icon = "flameshock",
						stat = "dmg",
						value = 6
					},
					{
						name = "LID_TALENT_INCINERATION",
						icon = "searingtotem",
						stat = "crit",
						value = 4
					},
					{
						name = "LID_TALENT_BURNING_SOUL",
						icon = "Spell_shadow_bloodboil",
						stat = "agi",
						value = 5
					},
					{
						name = "LID_TALENT_FIRE_POWER",
						icon = "firenovatotem",
						stat = "dmg",
						value = 8
					},
					{
						name = "LID_TALENT_PYROBLAST",
						icon = "Ability_Creature_Cursed_01",
						stat = "dmg",
						value = 10
					},
					{
						name = "LID_TALENT_BLAST_WAVE",
						icon = "Ability_Creature_Cursed_02",
						stat = "dmg",
						value = 7
					},
					{
						name = "LID_TALENT_COMBUSTION",
						icon = "bloodlust",
						stat = "crit",
						value = 6
					},
					{
						name = "LID_TALENT_MASTER_OF_ELEMENTS",
						icon = "elementalmastery",
						stat = "regen",
						value = 1
					},
					{
						name = "LID_TALENT_LIVING_BOMB",
						icon = "Spell_shadow_curse",
						stat = "dmg",
						value = 12
					},
				},
			},
			{
				name = "LID_TREE_FROST",
				icon = "forstnova_icon",
				talents = {
					{
						name = "LID_TALENT_FROSTBITE",
						icon = "frostshock",
						stat = "dmg",
						value = 5
					},
					{
						name = "LID_TALENT_ELEMENTAL_PRECISION",
						icon = "Ability_Marksmanship",
						stat = "crit",
						value = 3
					},
					{
						name = "LID_TALENT_ICE_SHARDS",
						icon = "forstnova_icon",
						stat = "crit",
						value = 5
					},
					{
						name = "LID_TALENT_FROST_CHANNELING",
						icon = "manaspring",
						stat = "cost",
						value = 12
					},
					{
						name = "LID_TALENT_SHATTER",
						icon = "Spell_polymorph_icon",
						stat = "crit",
						value = 6
					},
					{
						name = "LID_TALENT_ICE_BARRIER",
						icon = "elementalshield",
						stat = "armor",
						value = 120
					},
					{
						name = "LID_TALENT_ARCTIC_REACH",
						icon = "Spell_nature_earthbindtotem",
						stat = "dmg",
						value = 7
					},
					{
						name = "LID_TALENT_COLD_SNAP",
						icon = "naturesswiftness",
						stat = "agi",
						value = 8
					},
					{
						name = "LID_TALENT_WINTER_S_CHILL",
						icon = "INV_Misc_Orb_01",
						stat = "dmg",
						value = 9
					},
					{
						name = "LID_TALENT_ICE_BLOCK",
						icon = "hex",
						stat = "armor",
						value = 160
					},
				},
			},
		},
	},
	{
		id = "TIDEHUNTER",
		name = "LID_CLASS_TIDEHUNTER",
		icon = "Tide_Hunter",
		desc = "LID_CLASS_TIDEHUNTER_DESC",
		abilities = {
			{
				id = "EVISCERATE",
				name = "LID_ABILITY_EVISCERATE",
				icon = "Ability_rogue_eviscerate",
				level = 1,
				cost = 15,
				kind = "damage",
				mod = 4
			},
			{
				id = "COLDBLOOD",
				name = "LID_ABILITY_COLD_BLOOD",
				icon = "cold_blood_icon",
				level = 3,
				cost = 20,
				kind = "critstrike",
				mod = 2
			},
			{
				id = "AMBUSH",
				name = "LID_ABILITY_AMBUSH",
				icon = "Ability_rogue_ambush",
				level = 5,
				cost = 50,
				kind = "damage",
				mod = 12
			},
		},
		trees = {
			{
				name = "LID_TREE_ASSASSINATION",
				icon = "deadlypoison",
				talents = {
					{
						name = "LID_TALENT_MALICE",
						icon = "coldblood",
						stat = "crit",
						value = 3
					},
					{
						name = "LID_TALENT_IMPROVED_EVISCERATE",
						icon = "eviscerate",
						stat = "dmg",
						value = 6
					},
					{
						name = "LID_TALENT_LETHALITY",
						icon = "Ability_rogue_eviscerate",
						stat = "crit",
						value = 5
					},
					{
						name = "LID_TALENT_VILE_POISONS",
						icon = "instantpoison",
						stat = "dmg",
						value = 7
					},
					{
						name = "LID_TALENT_IMPROVED_POISONS",
						icon = "deadlypoison",
						stat = "dmg",
						value = 8
					},
					{
						name = "LID_TALENT_COLD_BLOOD",
						icon = "cold_blood_icon",
						stat = "crit",
						value = 6
					},
					{
						name = "LID_TALENT_MURDER",
						icon = "backstab",
						stat = "dmg",
						value = 8
					},
					{
						name = "LID_TALENT_SEAL_FATE",
						icon = "destiny",
						stat = "crit",
						value = 5
					},
					{
						name = "LID_TALENT_VIGOR",
						icon = "vigor",
						stat = "agi",
						value = 8
					},
					{
						name = "LID_TALENT_MUTILATE",
						icon = "ambush",
						stat = "dmg",
						value = 12
					},
				},
			},
			{
				name = "LID_TREE_COMBAT",
				icon = "sinisterstrike",
				talents = {
					{
						name = "LID_TALENT_IMPROVED_SINISTER_STRIKE",
						icon = "sinisterstrike",
						stat = "cost",
						value = 12
					},
					{
						name = "LID_TALENT_LIGHTNING_REFLEXES",
						icon = "evasion",
						stat = "armor",
						value = 80
					},
					{
						name = "LID_TALENT_RIPOSTE",
						icon = "kick",
						stat = "armor",
						value = 100
					},
					{
						name = "LID_TALENT_PRECISION",
						icon = "Ability_rogue_ambush",
						stat = "crit",
						value = 4
					},
					{
						name = "LID_TALENT_ENDURANCE",
						icon = "preparation",
						stat = "stm",
						value = 10
					},
					{
						name = "LID_TALENT_BLADE_FLURRY",
						icon = "hemorage",
						stat = "dmg",
						value = 8
					},
					{
						name = "LID_TALENT_DUAL_WIELD_SPECIALIZATION",
						icon = "INV_Sword_06",
						stat = "dmg",
						value = 7
					},
					{
						name = "LID_TALENT_AGGRESSION",
						icon = "bloodcraze",
						stat = "dmg",
						value = 8
					},
					{
						name = "LID_TALENT_ADRENALINE_RUSH",
						icon = "adrenaline_icon",
						stat = "regen",
						value = 1
					},
					{
						name = "LID_TALENT_WEAPON_EXPERTISE",
						icon = "addrenalinerush",
						stat = "lifesteal",
						value = 10
					},
				},
			},
		},
	},
	{
		id = "CLASSIC",
		name = "LID_CLASS_CLASSIC",
		icon = "Classic",
		desc = "LID_CLASS_CLASSIC_DESC",
		abilities = {
			{
				id = "HEROIC_STRIKE",
				name = "LID_ABILITY_HEROIC_STRIKE",
				icon = "heroicstrike",
				level = 1,
				cost = 15,
				kind = "damage",
				mod = 4
			},
			{
				id = "HEAL",
				name = "LID_ABILITY_HEAL",
				icon = "Spell_holy_heal",
				level = 3,
				cost = 45,
				kind = "heal",
				mod = 60,
				school = "magic",
				fx = "FX_HEAL"
			},
			{
				id = "DRAINLIFE",
				name = "LID_ABILITY_DRAIN_LIFE",
				icon = "Spell_shadow_lifedrain02",
				level = 5,
				cost = 25,
				kind = "drain",
				mod = 6,
				school = "magic",
				fx = "FX_DRAIN"
			},
		},
		trees = {
			{
				name = "LID_TREE_FURY",
				icon = "bloodrage_icon",
				talents = {
					{
						name = "LID_TALENT_CRUELTY",
						icon = "bloodrage_icon",
						stat = "crit",
						value = 3
					},
					{
						name = "LID_TALENT_UNBRIDLED_WRATH",
						icon = "bloodrage",
						stat = "regen",
						value = 1
					},
					{
						name = "LID_TALENT_IMPROVED_HEROIC_STRIKE",
						icon = "heroicstrike",
						stat = "cost",
						value = 12
					},
					{
						name = "LID_TALENT_BLOOD_CRAZE",
						icon = "bloodcraze",
						stat = "lifesteal",
						value = 8
					},
					{
						name = "LID_TALENT_PIERCING_HOWL",
						icon = "Ability_GhoulFrenzy",
						stat = "dmg",
						value = 6
					},
					{
						name = "LID_TALENT_ENRAGE",
						icon = "Bloodpower",
						stat = "dmg",
						value = 8
					},
					{
						name = "LID_TALENT_DEATH_WISH",
						icon = "recklessness",
						stat = "dmg",
						value = 10
					},
					{
						name = "LID_TALENT_FLURRY",
						icon = "windfurytotem",
						stat = "crit",
						value = 5
					},
					{
						name = "LID_TALENT_BLOODTHIRST",
						icon = "Spell_shadow_bloodboil",
						stat = "lifesteal",
						value = 12
					},
					{
						name = "LID_TALENT_RAMPAGE",
						icon = "bloodlust",
						stat = "dmg",
						value = 12
					},
				},
			},
			{
				name = "LID_TREE_RESTORATION",
				icon = "Spell_holy_heal",
				talents = {
					{
						name = "LID_TALENT_IMPROVED_HEAL",
						icon = "Spell_holy_heal",
						stat = "cost",
						value = 12
					},
					{
						name = "LID_TALENT_SPIRIT_TAP",
						icon = "Spell_nature_regeneration",
						stat = "agi",
						value = 5
					},
					{
						name = "LID_TALENT_HEALING_FOCUS",
						icon = "healingstream",
						stat = "stm",
						value = 10
					},
					{
						name = "LID_TALENT_IMPROVED_DRAIN_LIFE",
						icon = "Spell_shadow_lifedrain02",
						stat = "lifesteal",
						value = 10
					},
					{
						name = "LID_TALENT_MEDITATION",
						icon = "magic_dust",
						stat = "regen",
						value = 1
					},
					{
						name = "LID_TALENT_RENEW",
						icon = "renew_icon",
						stat = "stm",
						value = 12
					},
					{
						name = "LID_TALENT_POWER_WORD_SHIELD",
						icon = "powerwordshield_icon",
						stat = "armor",
						value = 120
					},
					{
						name = "LID_TALENT_HEALING_WAVE",
						icon = "healingwave",
						stat = "stm",
						value = 14
					},
					{
						name = "LID_TALENT_CHAIN_HEAL",
						icon = "chainheal",
						stat = "lifesteal",
						value = 12
					},
					{
						name = "LID_TALENT_ANCESTRAL_SPIRIT",
						icon = "ancestralspirit",
						stat = "armor",
						value = 160
					},
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
