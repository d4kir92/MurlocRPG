local _, ns = ...
ns.BAG_SIZE = 25
ns.BAG_SLOT_ORDER = {"BAG1", "BAG2", "BAG3", "BAG4",}
ns.SLOT_ORDER = {"HEAD", "NECK", "SHOULDER", "BACK", "CHEST", "WRISTS", "HANDS", "WAIST", "LEGS", "FEET", "FINGER1", "FINGER2", "MAINHAND", "OFFHAND",}
ns.SLOTS = {
	HEAD = {
		name = "LID_SLOT_HEAD",
		empty = "UI-PaperDoll-Slot-Head",
		type = "HEAD"
	},
	NECK = {
		name = "LID_SLOT_NECK",
		empty = "UI-PaperDoll-Slot-Neck",
		type = "NECK"
	},
	SHOULDER = {
		name = "LID_SLOT_SHOULDER",
		empty = "UI-PaperDoll-Slot-Shoulder",
		type = "SHOULDER"
	},
	BACK = {
		name = "LID_SLOT_BACK",
		empty = "UI-PaperDoll-Slot-Chest",
		type = "BACK"
	},
	CHEST = {
		name = "LID_SLOT_CHEST",
		empty = "UI-PaperDoll-Slot-Chest",
		type = "CHEST"
	},
	WRISTS = {
		name = "LID_SLOT_WRISTS",
		empty = "UI-PaperDoll-Slot-Wrists",
		type = "WRISTS"
	},
	HANDS = {
		name = "LID_SLOT_HANDS",
		empty = "UI-PaperDoll-Slot-Hands",
		type = "HANDS"
	},
	WAIST = {
		name = "LID_SLOT_WAIST",
		empty = "UI-PaperDoll-Slot-Waist",
		type = "WAIST"
	},
	LEGS = {
		name = "LID_SLOT_LEGS",
		empty = "UI-PaperDoll-Slot-Legs",
		type = "LEGS"
	},
	FEET = {
		name = "LID_SLOT_FEET",
		empty = "UI-PaperDoll-Slot-Feet",
		type = "FEET"
	},
	FINGER1 = {
		name = "LID_SLOT_FINGER1",
		empty = "UI-PaperDoll-Slot-Finger",
		type = "FINGER"
	},
	FINGER2 = {
		name = "LID_SLOT_FINGER2",
		empty = "UI-PaperDoll-Slot-Finger",
		type = "FINGER"
	},
	MAINHAND = {
		name = "LID_SLOT_MAINHAND",
		empty = "UI-PaperDoll-Slot-MainHand",
		type = "MAINHAND"
	},
	OFFHAND = {
		name = "LID_SLOT_OFFHAND",
		empty = "UI-PaperDoll-Slot-SecondaryHand",
		type = "OFFHAND"
	},
	BAG1 = {
		name = "LID_SLOT_BAG",
		empty = "UI-PaperDoll-Slot-Bag",
		type = "BAG"
	},
	BAG2 = {
		name = "LID_SLOT_BAG",
		empty = "UI-PaperDoll-Slot-Bag",
		type = "BAG"
	},
	BAG3 = {
		name = "LID_SLOT_BAG",
		empty = "UI-PaperDoll-Slot-Bag",
		type = "BAG"
	},
	BAG4 = {
		name = "LID_SLOT_BAG",
		empty = "UI-PaperDoll-Slot-Bag",
		type = "BAG"
	},
}

ns.QUALITY = {
	[1] = {
		name = "LID_QUALITY_POOR",
		r = 0.62,
		g = 0.62,
		b = 0.62
	},
	[2] = {
		name = "LID_QUALITY_COMMON",
		r = 1,
		g = 1,
		b = 1
	},
	[3] = {
		name = "LID_QUALITY_UNCOMMON",
		r = 0.12,
		g = 1,
		b = 0
	},
	[4] = {
		name = "LID_QUALITY_RARE",
		r = 0,
		g = 0.44,
		b = 0.87
	},
	[5] = {
		name = "LID_QUALITY_EPIC",
		r = 0.64,
		g = 0.21,
		b = 0.93
	},
	[6] = {
		name = "LID_QUALITY_LEGENDARY",
		r = 1,
		g = 0.5,
		b = 0
	},
}

ns.STAT_LABEL = {
	str = "LID_STATLINE_STR",
	stm = "LID_STATLINE_STM",
	int = "LID_STATLINE_INT",
	agi = "LID_STATLINE_AGI",
	armor = "LID_STATLINE_ARMOR",
	slots = "LID_STATLINE_SLOTS",
}

local function Item(id, name, icon, slotType, quality, level, value, noDrop, stats)
	return {
		id = id,
		name = name,
		icon = icon,
		slotType = slotType,
		quality = quality,
		level = level,
		value = value,
		noDrop = noDrop,
		stats = stats,
	}
end

ns.ITEM_LIST = {
	Item("brawler_s_harness", "Brawler's Harness", "brawlers_harness", "CHEST", 2, 1, 5, false, {
		armor = 2
	}),
	Item("novice_s_robe", "Novice's Robe", "novices_robe", "CHEST", 2, 1, 5, false, {
		armor = 3
	}),
	Item("old_rag", "Old Rag", "old_rag", "CHEST", 2, 1, 1, false, {
		armor = 1
	}),
	Item("the_1_ring", "The 1 Ring", "the_one_ring", "FINGER", 3, 1, 100, true, {
		armor = 15
	}),
	Item("brawler_s_pants", "Brawler's Pants", "brawlers_pants", "LEGS", 2, 1, 20, false, {
		armor = 2
	}),
	Item("frayed_pants", "Frayed Pants", "frayed_pants", "LEGS", 2, 1, 5, false, {
		armor = 2
	}),
	Item("primitive_kilt", "Primitive Kilt", "brawlers_pants", "LEGS", 2, 1, 20, false, {
		armor = 14
	}),
	Item("northern_shortsword", "Northern Shortsword", "Inv_sword_20", "MAINHAND", 3, 1, 120, true, {
		minDmg = 4,
		maxDmg = 6,
		str = 4,
		agi = 4
	}),
	Item("small_dagger", "Small Dagger", "Inv_weapon_shortblade_05", "MAINHAND", 2, 1, 50, false, {
		minDmg = 2,
		maxDmg = 3
	}),
	Item("sulfuras_hand_of_ragnaros", "Sulfuras, Hand of Ragnaros", "sulfuras_hammer", "MAINHAND", 6, 1, 100, true, {
		minDmg = 223,
		maxDmg = 372
	}),
	Item("worn_dagger", "Worn Dagger", "Inv_weapon_shortblade_05", "MAINHAND", 2, 1, 30, false, {
		minDmg = 1,
		maxDmg = 2
	}),
	Item("worn_wooden_shield", "Worn Wooden Shield", "small_shield", "OFFHAND", 2, 1, 5, false, {
		armor = 5
	}),
	Item("frayed_belt", "Frayed Belt", "frayed_belt", "WAIST", 2, 1, 10, false, {
		armor = 3
	}),
	Item("disciples_gloves", "Disciples Gloves", "INV_Gauntlets_04", "HANDS", 2, 2, 55, false, {
		armor = 11
	}),
	Item("worn_shortsword", "Worn Shortsword", "worn_shortsword", "MAINHAND", 2, 2, 10, false, {
		minDmg = 1,
		maxDmg = 3
	}),
	Item("battered_buckler", "Battered Buckler", "small_shield", "OFFHAND", 2, 2, 10, false, {
		armor = 12
	}),
	Item("cloth_braces", "Cloth Braces", "Cloth_Braces", "WRISTS", 2, 2, 50, false, {
		armor = 10
	}),
	Item("small_shield", "Small Shield", "small_shield", "OFFHAND", 2, 3, 20, false, {
		armor = 29
	}),
	Item("cadet_cloak", "Cadet Cloak", "Cadet_Cloak", "BACK", 2, 5, 50, false, {
		armor = 15
	}),
	Item("wendigo_fur_cloak", "Wendigo Fur Cloak", "Wendigo_Fur_Cloak", "BACK", 2, 5, 50, false, {
		armor = 8
	}),
	Item("tarnished_chain_vest", "Tarnished Chain Vest", "tarnished_chain_vest", "CHEST", 2, 5, 35, false, {
		armor = 67
	}),
	Item("lucky_fishing_hat", "Lucky Fishing Hat", "lucky_fishing_hat", "HEAD", 3, 5, 200, true, {
		armor = 48
	}),
	Item("tarnished_chain_leggings", "Tarnished Chain Leggings", "tarnished_chain_leggings", "LEGS", 2, 5, 28, false, {
		armor = 58
	}),
	Item("ferocious_fang", "Ferocious Fang", "ferocious_fang", "MAINHAND", 3, 5, 200, true, {
		minDmg = 2,
		maxDmg = 4
	}),
	Item("stingy", "Stingy", "stingy", "MAINHAND", 4, 5, 100, true, {
		minDmg = 3,
		maxDmg = 5
	}),
	Item("rough_croc_hide_vest", "Rough Croc Hide Vest", "rough_croc_hide_vest", "CHEST", 3, 6, 125, true, {
		armor = 113
	}),
	Item("hide_of_the_princess", "Hide of The Princess", "hide_of_the_princess", "OFFHAND", 3, 6, 150, true, {
		armor = 110
	}),
	Item("ragged_leather_belt", "Ragged Leather Belt", "Ragged_Leather_Belt", "WAIST", 2, 6, 30, false, {
		armor = 18
	}),
	Item("flimsy_chain_bracers", "Flimsy Chain Bracers", "Flimsy_Chain_Bracers", "WRISTS", 2, 6, 70, false, {
		armor = 20
	}),
	Item("flimsy_chain_gloves", "Flimsy Chain Gloves", "Flimsy_Chain_Gloves", "HANDS", 2, 8, 60, false, {
		armor = 35
	}),
	Item("large_candlestick", "Large Candlestick", "large_candlestick", "MAINHAND", 4, 8, 300, true, {
		minDmg = 2,
		maxDmg = 3,
		stm = 2,
		int = 8
	}),
	Item("une_s_cape", "Une's Cape", "Unes_Cape", "BACK", 4, 10, 200, false, {
		str = 3,
		stm = 3,
		int = 3,
		agi = 3,
		armor = 20
	}),
	Item("cadet_vest", "Cadet Vest", "inv_chest_chain_05", "CHEST", 3, 10, 150, false, {
		str = 3,
		armor = 144
	}),
	Item("bounty_hunter_s_ring", "Bounty Hunter's Ring", "inv_jewelry_ring_01", "FINGER", 3, 10, 155, false, {
		str = 3,
		agi = 1
	}),
	Item("brewer_s_gloves", "Brewer's Gloves", "inv_gauntlets_06", "HANDS", 3, 10, 115, false, {
		stm = 2,
		int = 2,
		armor = 17
	}),
	Item("embossed_plate_gauntlets", "Embossed Plate Gauntlets", "plate_gloves", "HANDS", 3, 10, 5722, true, {
		armor = 139
	}),
	Item("gemmed_copper_gauntlets", "Gemmed Copper Gauntlets", "INV_Gauntlets_05", "HANDS", 3, 10, 105, false, {
		str = 3,
		armor = 90
	}),
	Item("brutal_helm", "Brutal Helm", "Inv_helmet_02", "HEAD", 3, 10, 103, true, {
		str = 4,
		agi = 4,
		armor = 75
	}),
	Item("embossed_plate_helmet", "Embossed Plate Helmet", "plate_helm", "HEAD", 3, 10, 5906, true, {
		str = 3,
		armor = 210
	}),
	Item("fate", "Fate", "destiny", "MAINHAND", 4, 10, 1000, true, {
		minDmg = 12,
		maxDmg = 14,
		str = 5,
		stm = 5
	}),
	Item("tarnished_silver_chain", "Tarnished Silver Chain", "tarnished_silver_chain", "NECK", 3, 10, 28, false, {
		agi = 5,
		armor = 20
	}),
	Item("raiders_shoulderpads", "Raiders Shoulderpads", "Raiders_Shoulderpads", "SHOULDER", 3, 10, 150, false, {
		armor = 25
	}),
	Item("bard_s_belt", "Bard's Belt", "inv_belt_03", "WAIST", 3, 10, 125, false, {
		agi = 3,
		armor = 39
	}),
	Item("flimsy_chain_belt", "Flimsy Chain Belt", "Flimsy_Chain_Belt", "WAIST", 3, 10, 95, false, {
		armor = 30
	}),
	Item("weathered_belt", "Weathered Belt", "Flimsy_Chain_Belt", "WAIST", 2, 10, 125, false, {
		armor = 33
	}),
	Item("bard_s_bracers", "Bard's Bracers", "inv_bracer_05", "WRISTS", 3, 10, 130, false, {
		agi = 3,
		armor = 30
	}),
	Item("beastmaster_s_bindings", "Beastmaster's Bindings", "inv_bracer_17", "WRISTS", 4, 10, 600, true, {
		str = 3,
		stm = 3,
		int = 3,
		agi = 3,
		armor = 95
	}),
	Item("burnt_hide_bracers", "Burnt Hide Bracers", "inv_bracer_08", "WRISTS", 2, 10, 125, false, {
		armor = 26
	}),
	Item("embossed_plate_bracers", "Embossed Plate Bracers", "Flimsy_Chain_Bracers", "WRISTS", 3, 10, 3432, true, {
		armor = 78
	}),
	Item("embossed_plate_girdle", "Embossed Plate Girdle", "plate_girdle", "WRISTS", 3, 10, 5432, true, {
		armor = 91
	}),
	Item("patched_cloak", "Patched Cloak", "inv_misc_cape_10", "BACK", 2, 11, 150, false, {
		armor = 13
	}),
	Item("embossed_plate_armor", "Embossed Plate Armor", "plate_chest", "CHEST", 3, 11, 1843, true, {
		str = 6,
		armor = 337
	}),
	Item("war_torn_tunic", "War Torn Tunic", "inv_chest_chain_07", "CHEST", 3, 11, 160, false, {
		agi = 4,
		armor = 151
	}),
	Item("bard_s_boots", "Bard's Boots", "INV_Boots_01", "FEET", 3, 11, 150, false, {
		int = 4,
		armor = 49
	}),
	Item("embossed_plate_boots", "Embossed Plate Boots", "plate_boots", "FEET", 3, 11, 11421, true, {
		str = 4,
		armor = 133
	}),
	Item("willow_gloves", "Willow Gloves", "inv_gauntlets_23", "HANDS", 3, 11, 305, true, {
		str = 3,
		stm = 2,
		armor = 18
	}),
	Item("barbaric_loincloth", "Barbaric Loincloth", "inv_pants_wolf", "LEGS", 3, 11, 205, true, {
		armor = 25
	}),
	Item("embossed_plate_leggings", "Embossed Plate Leggings", "plate_legs", "LEGS", 3, 11, 1932, true, {
		str = 5,
		armor = 275
	}),
	Item("elegant_shortsword", "Elegant Shortsword", "inv_sword_06", "MAINHAND", 3, 11, 140, false, {
		minDmg = 4,
		maxDmg = 6,
		stm = 3
	}),
	Item("embossed_plate_shield", "Embossed Plate Shield", "grandmarshal_aegis", "OFFHAND", 3, 11, 2724, true, {
		str = 2,
		armor = 675
	}),
	Item("simple_buckler", "Simple Buckler", "small_shield", "OFFHAND", 2, 11, 135, false, {
		armor = 297
	}),
	Item("embossed_plate_pauldrons", "Embossed Plate Pauldrons", "Raiders_Shoulderpads", "SHOULDER", 3, 11, 1537, true, {
		str = 4,
		armor = 186
	}),
	Item("soldier_s_girdle", "Soldier's Girdle", "inv_belt_25", "WAIST", 3, 11, 130, false, {
		armor = 85
	}),
	Item("clamshell_bracers", "Clamshell Bracers", "Flimsy_Chain_Bracers", "WRISTS", 2, 11, 560, true, {
		armor = 57
	}),
	Item("infantry_bracers", "Infantry Bracers", "Infantry_Bracers", "WRISTS", 2, 11, 125, false, {
		armor = 30
	}),
	Item("chainmail_armor", "Chainmail Armor", "tarnished_chain_vest", "CHEST", 2, 12, 205, false, {
		armor = 151
	}),
	Item("spellbinder_robe", "Spellbinder Robe", "inv_chest_cloth_22", "CHEST", 3, 12, 175, false, {
		int = 4,
		agi = 2,
		armor = 30
	}),
	Item("soldier_s_boots", "Soldier's Boots", "tracking_boots", "FEET", 3, 12, 825, true, {
		stm = 5,
		armor = 109
	}),
	Item("soldier_s_gauntlets", "Soldier's Gauntlets", "inv_gauntlets_12", "HANDS", 3, 12, 155, false, {
		str = 2,
		stm = 2,
		armor = 99
	}),
	Item("stretched_leather_trousers", "Stretched Leather Trousers", "plate_legs", "LEGS", 3, 12, 195, false, {
		str = 2,
		agi = 2,
		armor = 61
	}),
	Item("blackwater_cutlass", "Blackwater Cutlass", "inv_sword_24", "MAINHAND", 3, 12, 280, false, {
		minDmg = 5,
		maxDmg = 6,
		agi = 2
	}),
	Item("blade_of_cunning", "Blade of Cunning", "inv_weapon_shortblade_26", "MAINHAND", 3, 12, 255, false, {
		minDmg = 4,
		maxDmg = 6,
		str = 2
	}),
	Item("felvas_necklace", "Felvas Necklace", "hazzarahs_charm_of_magic", "NECK", 5, 12, 10000, true, {
		agi = 15
	}),
	Item("runic_cane", "Runic Cane", "inv_staff_02", "OFFHAND", 3, 12, 190, false, {
		int = 5
	}),
	Item("devout_mantle", "Devout Mantle", "Raiders_Shoulderpads", "SHOULDER", 4, 12, 3000, true, {
		int = 21,
		armor = 64
	}),
	Item("dalaran_wizard_s_robe", "Dalaran Wizard's Robe", "inv_chest_cloth_36", "CHEST", 2, 13, 120, true, {
		armor = 30
	}),
	Item("runed_copper_breastplate", "Runed Copper Breastplate", "inv_chest_plate03", "CHEST", 3, 13, 255, false, {
		str = 2,
		stm = 4,
		armor = 162
	}),
	Item("solstice_robe", "Solstice Robe", "inv_chest_cloth_17", "CHEST", 3, 13, 225, false, {
		int = 5,
		agi = 2,
		armor = 32
	}),
	Item("clergy_ring", "Clergy Ring", "inv_belt_33", "FINGER", 3, 13, 750, true, {
		stm = 1,
		int = 3
	}),
	Item("coif_of_the_elements", "Coif of the Elements", "coif_of_elements", "HEAD", 4, 13, 7000, true, {
		stm = 13,
		armor = 297
	}),
	Item("sea_dog_britches", "Sea Dog Britches", "brawlers_pants", "LEGS", 3, 13, 235, false, {
		str = 4,
		agi = 4,
		armor = 29
	}),
	Item("benediction", "Benediction", "benediction", "MAINHAND", 5, 13, 12000, true, {
		minDmg = 2,
		maxDmg = 4,
		int = 16
	}),
	Item("big_bronze_knife", "Big Bronze Knife", "inv_weapon_shortblade_04", "MAINHAND", 3, 13, 380, false, {
		minDmg = 5,
		maxDmg = 6,
		agi = 3
	}),
	Item("night_watch_shortsword", "Night Watch Shortsword", "inv_sword_26", "MAINHAND", 4, 13, 400, false, {
		minDmg = 6,
		maxDmg = 7,
		str = 4
	}),
	Item("bloodspattered_shield", "Bloodspattered Shield", "inv_shield_14", "OFFHAND", 3, 13, 100, true, {
		stm = 6,
		armor = 378
	}),
	Item("runed_copper_belt", "Runed Copper Belt", "inv_belt_03", "WAIST", 2, 13, 215, false, {
		armor = 86
	}),
	Item("ritual_bands", "Ritual Bands", "INV_Bracer_05", "WRISTS", 3, 13, 245, false, {
		stm = 3,
		int = 5,
		armor = 14
	}),
	Item("tunic_of_westfall", "Tunic of Westfall", "plate_chest", "CHEST", 4, 14, 505, true, {
		stm = 5,
		agi = 11,
		armor = 92
	}),
	Item("buccaneer_s_boots", "Buccaneer's Boots", "INV_Boots_01", "FEET", 3, 14, 350, false, {
		armor = 22
	}),
	Item("ring_of_iron_will", "Ring of Iron Will", "inv_belt_31", "FINGER", 3, 14, 405, false, {
		stm = 4,
		agi = 2
	}),
	Item("beaststalker_s_gloves", "Beaststalker's Gloves", "beaststalkers_gloves", "HANDS", 4, 14, 7500, true, {
		stm = 15,
		armor = 218
	}),
	Item("black_whelp_gloves", "Black Whelp Gloves", "inv_gauntlets_17", "HANDS", 3, 14, 285, false, {
		stm = 2,
		agi = 3,
		armor = 46
	}),
	Item("gloves_of_the_fang", "Gloves of the Fang", "inv_gauntlets_18", "HANDS", 4, 14, 320, false, {
		stm = 2,
		int = 4,
		armor = 47
	}),
	Item("magefist_gloves", "Magefist Gloves", "inv_gauntlets_27", "HANDS", 4, 14, 415, false, {
		stm = 3,
		int = 5,
		armor = 23
	}),
	Item("raider_s_gauntlets", "Raider's Gauntlets", "Flimsy_Chain_Gloves", "HANDS", 3, 14, 365, false, {
		str = 2,
		stm = 6,
		armor = 103
	}),
	Item("foror_s_eyepatch", "Foror's Eyepatch", "forors_eyepatch", "HEAD", 5, 14, 9000, true, {
		agi = 20,
		armor = 40
	}),
	Item("chausses_of_westfall", "Chausses of Westfall", "tarnished_chain_leggings", "LEGS", 4, 14, 230, true, {
		str = 5,
		stm = 11,
		int = 5,
		agi = 5,
		armor = 173
	}),
	Item("grunt_axe", "Grunt Axe", "inv_axe_12", "MAINHAND", 3, 14, 600, false, {
		minDmg = 7,
		maxDmg = 8,
		stm = 4
	}),
	Item("tail_spike", "Tail Spike", "inv_weapon_shortblade_10", "MAINHAND", 3, 14, 650, false, {
		minDmg = 7,
		maxDmg = 8,
		stm = 3,
		agi = 2
	}),
	Item("thief_s_blade", "Thief's Blade", "inv_sword_24", "MAINHAND", 3, 14, 625, false, {
		minDmg = 8,
		maxDmg = 9,
		agi = 3
	}),
	Item("spellbinder_orb", "Spellbinder Orb", "inv_misc_orb_01", "OFFHAND", 4, 14, 1100, true, {
		stm = 4,
		int = 4
	}),
	Item("willow_branch", "Willow Branch", "inv_staff_02", "OFFHAND", 3, 14, 1000, true, {
		int = 8
	}),
	Item("seer_s_mantle", "Seer's Mantle", "inv_shoulder_09", "SHOULDER", 4, 14, 450, false, {
		int = 5,
		armor = 25
	}),
	Item("outrunner_s_cord", "Outrunner's Cord", "inv_belt_29", "WAIST", 3, 14, 355, false, {
		agi = 6,
		armor = 93
	}),
	Item("wildheart_belt", "Wildheart Belt", "wildheart_belt", "WAIST", 4, 14, 8010, true, {
		int = 17,
		armor = 93
	}),
	Item("runed_copper_bracers", "Runed Copper Bracers", "Flimsy_Chain_Bracers", "WRISTS", 3, 14, 345, false, {
		armor = 68
	}),
	Item("feyscale_cloak", "Feyscale Cloak", "inv_misc_cape_02", "BACK", 4, 15, 545, false, {
		stm = 3,
		int = 4,
		armor = 17
	}),
	Item("dark_leather_tunic", "Dark Leather Tunic", "inv_chest_leather_03", "CHEST", 3, 15, 515, false, {
		agi = 6,
		armor = 78
	}),
	Item("lupine_vest", "Lupine Vest", "inv_chest_fur", "CHEST", 3, 15, 530, false, {
		agi = 7,
		armor = 78
	}),
	Item("agile_boots", "Agile Boots", "INV_Boots_06", "FEET", 3, 15, 505, false, {
		agi = 5,
		armor = 53
	}),
	Item("outrunner_s_slippers", "Outrunner's Slippers", "INV_Boots_01", "FEET", 3, 15, 480, false, {
		str = 2,
		agi = 8,
		armor = 115
	}),
	Item("defias_renegade_ring", "Defias Renegade Ring", "inv_jewelry_ring_02", "FINGER", 3, 15, 595, false, {
		str = 3,
		agi = 3
	}),
	Item("quartz_ring", "Quartz Ring", "inv_jewelry_ring_05", "FINGER", 3, 15, 590, false, {
		stm = 3,
		int = 3
	}),
	Item("the_ice_king_s_band", "The Ice King's Band", "inv_jewelry_ring_10", "FINGER", 4, 15, 640, false, {
		str = 6,
		stm = 6
	}),
	Item("hammerfist_gloves", "Hammerfist Gloves", "inv_gauntlets_05", "HANDS", 3, 15, 540, false, {
		str = 3,
		stm = 3,
		armor = 48
	}),
	Item("fire_hardened_coif", "Fire Hardened Coif", "inv_helmet_39", "HEAD", 3, 15, 525, false, {
		str = 8,
		agi = 7,
		armor = 115
	}),
	Item("hooded_cowl", "Hooded Cowl", "inv_helmet_34", "HEAD", 3, 15, 530, false, {
		stm = 7,
		int = 8,
		armor = 50
	}),
	Item("red_defias_mask", "Red Defias Mask", "inv_misc_bandana_03", "HEAD", 3, 15, 465, false, {
		stm = 8,
		agi = 9,
		armor = 80
	}),
	Item("sparkmetal_coif", "Sparkmetal Coif", "inv_helmet_02", "HEAD", 3, 15, 480, false, {
		str = 7,
		stm = 9,
		armor = 168
	}),
	Item("scarecrow_trousers", "Scarecrow Trousers", "brawlers_pants", "LEGS", 3, 15, 430, false, {
		stm = 6,
		armor = 29
	}),
	Item("seer_s_pants", "Seer's Pants", "INV_Pants_01", "LEGS", 3, 15, 435, false, {
		int = 5,
		agi = 3,
		armor = 29
	}),
	Item("advisor_s_gnarled_staff", "Advisor's Gnarled Staff", "Inv_staff_25", "MAINHAND", 4, 15, 845, true, {
		minDmg = 4,
		maxDmg = 5,
		stm = 4,
		int = 11
	}),
	Item("cruel_barb", "Cruel Barb", "inv_sword_24", "MAINHAND", 4, 15, 125, true, {
		minDmg = 8,
		maxDmg = 11,
		agi = 8
	}),
	Item("fang_of_venoxis", "Fang of Venoxis", "fang_of_venoxis", "MAINHAND", 5, 15, 2300, true, {
		minDmg = 4,
		maxDmg = 6,
		int = 15
	}),
	Item("legionnaire_s_sword", "Legionnaire's Sword", "inv_sword_31", "MAINHAND", 4, 15, 825, false, {
		minDmg = 7,
		maxDmg = 10,
		str = 2,
		stm = 4
	}),
	Item("perdition_s_blade", "Perdition's Blade", "perditions_blade", "MAINHAND", 5, 15, 3000, true, {
		minDmg = 10,
		maxDmg = 12,
		agi = 8
	}),
	Item("razor_s_edge", "Razor's Edge", "inv_weapon_halberd_08", "MAINHAND", 4, 15, 870, false, {
		minDmg = 8,
		maxDmg = 11,
		str = 6
	}),
	Item("hazza_rah_s_charm_of_magic", "Hazza'rah's Charm of Magic", "hazzarahs_charm_of_magic", "NECK", 5, 15, 20000, true, {
		str = 10,
		int = 24
	}),
	Item("scout_s_medallion", "Scout's Medallion", "inv_jewelry_necklace_14", "NECK", 4, 15, 10000, true, {
		str = 6,
		stm = 2
	}),
	Item("sentinel_s_medallion", "Sentinel's Medallion", "inv_jewelry_necklace_13", "NECK", 4, 15, 10000, true, {
		int = 2,
		agi = 6
	}),
	Item("kresh_s_back", "Kresh's Back", "inv_shield_18", "OFFHAND", 4, 15, 475, false, {
		str = 2,
		stm = 13,
		armor = 471
	}),
	Item("pulsating_hydra_heart", "Pulsating Hydra Heart", "inv_misc_orb_04", "OFFHAND", 4, 15, 495, false, {
		int = 15
	}),
	Item("zulian_defender", "Zulian Defender", "zulian_defender", "OFFHAND", 4, 15, 2200, true, {
		stm = 10,
		int = 8,
		armor = 800
	}),
	Item("bandit_shoulders", "Bandit Shoulders", "inv_shoulder_27", "SHOULDER", 4, 15, 515, false, {
		str = 5,
		armor = 58
	}),
	Item("patched_leather_shoulderpads", "Patched Leather Shoulderpads", "inv_shoulder_06", "SHOULDER", 2, 15, 470, false, {
		armor = 52
	}),
	Item("rugged_spaulders", "Rugged Spaulders", "inv_shoulder_08", "SHOULDER", 3, 15, 520, false, {
		armor = 55
	}),
	Item("blackened_defias_belt", "Blackened Defias Belt", "inv_belt_26", "WAIST", 3, 15, 475, false, {
		agi = 5,
		armor = 45
	}),
	Item("shimmering_bracers", "Shimmering Bracers", "Cloth_Braces", "WRISTS", 3, 15, 505, false, {
		stm = 3,
		armor = 15
	}),
	Item("bloodspattered_surcoat", "Bloodspattered Surcoat", "INV_Chest_Chain_07", "CHEST", 3, 16, 705, false, {
		str = 5,
		stm = 4,
		armor = 171
	}),
	Item("inscribed_leather_breastplate", "Inscribed Leather Breastplate", "inv_chest_leather_09", "CHEST", 3, 16, 635, false, {
		str = 3,
		agi = 5,
		armor = 79
	}),
	Item("seer_s_padded_armor", "Seer's Padded Armor", "INV_Shirt_02", "CHEST", 3, 16, 600, false, {
		stm = 3,
		int = 6,
		armor = 35
	}),
	Item("starsight_tunic", "Starsight Tunic", "Inv_chest_leather_10", "CHEST", 4, 16, 625, false, {
		stm = 4,
		int = 10,
		armor = 89
	}),
	Item("zandalar_illusionist_s_robe", "Zandalar Illusionist's Robe", "illusionist_robe", "CHEST", 5, 16, 10000, true, {
		int = 22,
		armor = 100
	}),
	Item("zandalar_madcap_s_tunic", "Zandalar Madcap's Tunic", "madcap_tunic", "CHEST", 5, 16, 10000, true, {
		agi = 16,
		armor = 225
	}),
	Item("zandalar_vindicator_s_plate", "Zandalar Vindicator's Plate", "vindicators_plate", "CHEST", 5, 16, 10000, true, {
		str = 20,
		armor = 350
	}),
	Item("defender_boots", "Defender Boots", "inv_boots_plate_01", "FEET", 3, 16, 605, false, {
		stm = 10,
		armor = 122
	}),
	Item("feet_of_the_lynx", "Feet of the Lynx", "inv_boots_wolf", "FEET", 4, 16, 605, false, {
		int = 3,
		agi = 8,
		armor = 63
	}),
	Item("footpads_of_the_fang", "Footpads of the Fang", "inv_boots_04", "FEET", 3, 16, 645, false, {
		stm = 4,
		agi = 4,
		armor = 57
	}),
	Item("gold_militia_boots", "Gold Militia Boots", "inv_boots_01", "FEET", 3, 16, 555, false, {
		str = 5,
		int = 3,
		armor = 126
	}),
	Item("savage_trodders", "Savage Trodders", "inv_boots_01", "FEET", 3, 16, 615, false, {
		str = 6,
		armor = 122
	}),
	Item("silver_linked_footguards", "Silver-linked Footguards", "inv_boots_01", "FEET", 4, 16, 625, false, {
		str = 3,
		stm = 7,
		armor = 129
	}),
	Item("drakeclaw_band", "Drakeclaw Band", "inv_jewelry_ring_04", "FINGER", 4, 16, 800, true, {
		str = 6,
		stm = 6
	}),
	Item("lavishly_jeweled_ring", "Lavishly Jeweled Ring", "inv_jewelry_ring_09", "FINGER", 4, 16, 740, false, {
		int = 6,
		agi = 2
	}),
	Item("seal_of_sylvanas", "Seal of Sylvanas", "inv_jewelry_ring_15", "FINGER", 4, 16, 800, false, {
		str = 3,
		stm = 8
	}),
	Item("deviate_scale_gloves", "Deviate Scale Gloves", "inv_gauntlets_05", "HANDS", 3, 16, 625, false, {
		str = 3,
		agi = 3,
		armor = 43
	}),
	Item("polar_gauntlets", "Polar Gauntlets", "inv_gauntlets_04", "HANDS", 3, 16, 620, false, {
		str = 5,
		armor = 109
	}),
	Item("darkweave_breeches", "Darkweave Breeches", "plate_legs", "LEGS", 4, 16, 570, false, {
		str = 7,
		stm = 3,
		agi = 6,
		armor = 35
	}),
	Item("outrunner_s_legguards", "Outrunner's Legguards", "tarnished_chain_leggings", "LEGS", 3, 16, 535, false, {
		str = 4,
		agi = 4,
		armor = 152
	}),
	Item("rough_bronze_leggings", "Rough Bronze Leggings", "tarnished_chain_leggings", "LEGS", 3, 16, 555, false, {
		str = 4,
		stm = 5,
		armor = 149
	}),
	Item("the_stoppable_force", "The Stoppable Force", "inv_hammer_16", "MAINHAND", 3, 16, 905, true, {
		minDmg = 8,
		maxDmg = 9,
		str = 3,
		stm = 5
	}),
	Item("blood_tailisman", "Blood Tailisman", "blood_tailisman", "NECK", 5, 16, 15000, true, {
		str = 12,
		stm = 12,
		int = 12,
		agi = 12
	}),
	Item("atal_ai_spaulders", "Atal'ai Spaulders", "inv_shoulder_18", "SHOULDER", 4, 16, 615, false, {
		str = 3,
		stm = 4,
		int = 5,
		agi = 2,
		armor = 60
	}),
	Item("outrunner_s_pauldrons", "Outrunner's Pauldrons", "inv_shoulder_28", "SHOULDER", 4, 16, 620, false, {
		stm = 5,
		armor = 128
	}),
	Item("belt_of_the_fang", "Belt of the Fang", "inv_belt_30", "WAIST", 3, 16, 565, false, {
		str = 1,
		stm = 1,
		int = 3,
		armor = 45
	}),
	Item("stormbringer_belt", "Stormbringer Belt", "wildheart_belt", "WAIST", 4, 16, 545, false, {
		str = 2,
		int = 5,
		armor = 104
	}),
	Item("scouting_bracers", "Scouting Bracers", "inv_bracer_07", "WRISTS", 3, 16, 630, false, {
		stm = 4,
		armor = 35
	}),
	Item("steel_clasped_bracers", "Steel-clasped Bracers", "inv_bracer_06", "WRISTS", 3, 16, 675, false, {
		str = 6,
		armor = 85
	}),
	Item("drakestone", "Drakestone", "inv_misc_orb_03", "BACK", 4, 17, 1100, true, {
		stm = 5,
		int = 5
	}),
	Item("featherskin_cape", "Featherskin Cape", "inv_misc_cape_05", "BACK", 4, 17, 1100, true, {
		str = 10,
		stm = 5,
		armor = 39
	}),
	Item("cured_leather_armor", "Cured Leather Armor", "Inv_chest_leather_10", "CHEST", 3, 17, 730, false, {
		armor = 77
	}),
	Item("grunt_vest", "Grunt Vest", "inv_shirt_07", "CHEST", 3, 17, 745, false, {
		str = 4,
		stm = 5,
		armor = 35
	}),
	Item("orcish_war_chain", "Orcish War Chain", "tarnished_chain_vest", "CHEST", 3, 17, 720, false, {
		str = 6,
		stm = 3,
		armor = 177
	}),
	Item("violet_scale_armor", "Violet Scale Armor", "INV_Chest_Chain_05", "CHEST", 3, 17, 715, false, {
		str = 1,
		stm = 6,
		armor = 172
	}),
	Item("brutal_gauntlets", "Brutal Gauntlets", "inv_gauntlets_04", "HANDS", 3, 17, 800, false, {
		str = 6,
		armor = 126
	}),
	Item("defender_gauntlets", "Defender Gauntlets", "inv_gauntlets_11", "HANDS", 3, 17, 825, false, {
		stm = 8,
		armor = 110
	}),
	Item("serpent_gloves", "Serpent Gloves", "inv_gauntlets_19", "HANDS", 3, 17, 710, false, {
		int = 4,
		agi = 4,
		armor = 24
	}),
	Item("thorbia_s_gauntlets", "Thorbia's Gauntlets", "inv_gauntlets_11", "HANDS", 4, 17, 770, false, {
		str = 3,
		stm = 8,
		armor = 123
	}),
	Item("defender_leggings", "Defender Leggings", "tarnished_chain_leggings", "LEGS", 3, 17, 705, false, {
		stm = 8,
		armor = 155
	}),
	Item("leggings_of_the_fang", "Leggings of the Fang", "inv_pants_11", "LEGS", 4, 17, 645, false, {
		stm = 6,
		int = 3,
		agi = 8,
		armor = 79
	}),
	Item("the_dragons_eye", "The Dragons Eye", "INV_Jewelry_Amulet_04", "NECK", 4, 17, 680, true, {
		stm = 6,
		int = 10,
		agi = 6
	}),
	Item("crest_of_supremacy", "Crest of Supremacy", "inv_shield_04", "OFFHAND", 4, 17, 1200, true, {
		str = 7,
		stm = 7,
		int = 7,
		armor = 650
	}),
	Item("deviate_scale_belt", "Deviate Scale Belt", "inv_belt_09", "WAIST", 4, 17, 655, false, {
		str = 6,
		stm = 3,
		int = 5,
		armor = 45
	}),
	Item("guardsman_belt", "Guardsman Belt", "frayed_belt", "WAIST", 3, 17, 685, false, {
		str = 4,
		stm = 4,
		armor = 47
	}),
	Item("pagan_belt", "Pagan Belt", "Ragged_Leather_Belt", "WAIST", 3, 17, 605, false, {
		stm = 4,
		armor = 20
	}),
	Item("defender_bracers", "Defender Bracers", "inv_bracer_14", "WRISTS", 3, 17, 760, false, {
		str = 5,
		armor = 76
	}),
	Item("mindthrust_bracers", "Mindthrust Bracers", "inv_bracer_07", "WRISTS", 4, 17, 755, false, {
		stm = 3,
		int = 9,
		armor = 17
	}),
	Item("armor_of_the_fang", "Armor of the Fang", "inv_shirt_16", "CHEST", 3, 18, 785, false, {
		str = 7,
		int = 7,
		armor = 82
	}),
	Item("defender_tunic", "Defender Tunic", "INV_Chest_Chain_05", "CHEST", 3, 18, 815, false, {
		str = 7,
		stm = 8,
		armor = 177
	}),
	Item("flowing_ritual_robes", "Flowing Ritual Robes", "flowing_ritual_robes", "CHEST", 5, 18, 2400, true, {
		int = 15,
		armor = 100
	}),
	Item("mystic_s_wrap", "Mystic's Wrap", "inv_shirt_13", "CHEST", 3, 18, 845, false, {
		stm = 3,
		int = 7,
		armor = 37
	}),
	Item("bright_belt", "Bright Belt", "plate_girdle", "WAIST", 3, 18, 775, false, {
		int = 4,
		agi = 4,
		armor = 21
	}),
	Item("forest_leather_bracers", "Forest Leather Bracers", "inv_bracer_06", "WRISTS", 3, 18, 800, false, {
		agi = 5,
		armor = 37
	}),
	Item("seal_of_jin", "Seal of Jin", "seal_of_jin", "FINGER", 5, 20, 2500, true, {
		str = 8,
		agi = 12,
		armor = 5
	}),
	Item("ashkandi_the_greatsword", "Ashkandi, the Greatsword", "ashkandi", "MAINHAND", 5, 20, 10000, true, {
		minDmg = 13,
		maxDmg = 16,
		str = 12
	}),
	Item("grand_marshal_s_claymore", "Grand Marshal's Claymore", "grandmarshal_claymore", "MAINHAND", 5, 20, 100000, true, {
		minDmg = 14,
		maxDmg = 17,
		str = 8,
		stm = 8
	}),
	Item("grand_marshal_s_dirk", "Grand Marshal's Dirk", "grandmarshal_dirk", "MAINHAND", 5, 20, 100000, true, {
		minDmg = 14,
		maxDmg = 17,
		agi = 12
	}),
	Item("grand_marshal_s_stave", "Grand Marshal's Stave", "grandmarshal_stave", "MAINHAND", 5, 20, 100000, true, {
		minDmg = 6,
		maxDmg = 11,
		int = 15
	}),
	Item("zin_rokh_destroyer_of_worlds", "Zin'rokh, Destroyer of Worlds", "zinrokh", "MAINHAND", 5, 20, 2600, true, {
		minDmg = 15,
		maxDmg = 18,
		str = 12,
		stm = 12
	}),
	Item("ancient_cornerstone_grimoire", "Ancient Cornerstone Grimoire", "ancient_cornerstone_grimoire", "OFFHAND", 5, 20, 20000, true, {
		int = 50
	}),
	Item("earthcalm_orb", "Earthcalm Orb", "earthcalm_orb", "OFFHAND", 5, 20, 5600, true, {
		stm = 5,
		int = 10,
		armor = 100
	}),
	Item("grand_marshal_s_aegis", "Grand Marshal's Aegis", "grandmarshal_aegis", "OFFHAND", 5, 20, 120000, true, {
		stm = 12,
		int = 12,
		armor = 1200
	}),
	Item("bloodsoaked_greaves", "Bloodsoaked Greaves", "bloodsoaked_greaves", "FEET", 5, 24, 2600, true, {
		stm = 14,
		armor = 180
	}),
	Item("short_sword", "Short Sword", "short_sword", "MAINHAND", 2, 100, 100, false, {
		minDmg = 2,
		maxDmg = 4,
		str = 4,
		stm = 3,
		int = 2,
		agi = 1
	}),
}

ns.VENDOR_STOCK = {"worn_shortsword", "small_shield", "tarnished_chain_vest", "tarnished_chain_leggings", "embossed_plate_helmet", "embossed_plate_girdle", "embossed_plate_gauntlets", "embossed_plate_bracers", "embossed_plate_armor", "embossed_plate_leggings", "embossed_plate_boots", "embossed_plate_pauldrons", "embossed_plate_shield", "barbaric_loincloth", "clamshell_bracers", "willow_gloves", "soldier_s_boots", "clergy_ring", "bloodspattered_shield", "dalaran_wizard_s_robe", "willow_branch", "the_ice_king_s_band", "scout_s_medallion", "sentinel_s_medallion", "zandalar_illusionist_s_robe", "zandalar_vindicator_s_plate", "zandalar_madcap_s_tunic", "blood_tailisman", "belt_of_the_fang", "footpads_of_the_fang", "leggings_of_the_fang", "serpent_gloves", "armor_of_the_fang", "grand_marshal_s_claymore", "grand_marshal_s_stave", "grand_marshal_s_aegis", "grand_marshal_s_dirk",}
ns.ITEM_BY_ID = {}
ns.BAG_ITEMS = {
	Item("linen_bag", "Linen Bag", 4238, "BAG", 2, 1, 500, true, {
		slots = 6
	}),
	Item("woolen_bag", "Woolen Bag", 4240, "BAG", 2, 4, 2500, true, {
		slots = 8
	}),
	Item("small_silk_pack", "Small Silk Pack", 4245, "BAG", 2, 8, 12500, true, {
		slots = 10
	}),
	Item("mageweave_bag", "Mageweave Bag", 10050, "BAG", 2, 12, 62500, true, {
		slots = 12
	}),
	Item("runecloth_bag", "Runecloth Bag", 14046, "BAG", 2, 16, 312500, true, {
		slots = 14
	}),
}

ns.VENDOR_BAGS = {
	{
		id = "linen_bag",
		level = 6
	},
	{
		id = "woolen_bag",
		level = 12
	},
}

ns.BAG_DROPS = {
	{
		id = "runecloth_bag",
		min = 16,
		chance = 1
	},
	{
		id = "mageweave_bag",
		min = 12,
		max = 18,
		chance = 2
	},
	{
		id = "small_silk_pack",
		min = 8,
		max = 14,
		chance = 4
	},
	{
		id = "woolen_bag",
		min = 4,
		max = 10,
		chance = 8
	},
	{
		id = "linen_bag",
		min = 1,
		max = 6,
		chance = 16
	},
}

local best = 0
for _, item in ipairs(ns.BAG_ITEMS) do
	ns.ITEM_LIST[#ns.ITEM_LIST + 1] = item
	best = math.max(best, item.stats.slots)
end

ns.BAG_MAX_SIZE = ns.BAG_SIZE + best * #ns.BAG_SLOT_ORDER

for _, item in ipairs(ns.ITEM_LIST) do
	ns.ITEM_BY_ID[item.id] = item
end

function ns.ItemColor(item)
	local q = ns.QUALITY[item.quality] or ns.QUALITY[2]
	return q.r, q.g, q.b
end

function ns.ItemLink(item)
	local r, g, b = ns.ItemColor(item)
	return format("|cff%02x%02x%02x[%s]|r", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), item.name)
end

function ns.ItemStatLines(item)
	local lines = {}
	local stats = item.stats
	if stats.maxDmg and stats.maxDmg > 0 then lines[#lines + 1] = format(ns:Trans("LID_STATLINE_DAMAGE"), stats.minDmg or 0, stats.maxDmg) end
	for _, key in ipairs({"str", "stm", "int", "agi", "armor", "slots"}) do
		local value = stats[key]
		if value and value ~= 0 then lines[#lines + 1] = format(ns:Trans(ns.STAT_LABEL[key]), value) end
	end
	return lines
end

function ns.RollBagDrop(playerLevel, dungeon)
	for _, entry in ipairs(ns.BAG_DROPS) do
		if playerLevel >= entry.min and (not entry.max or playerLevel <= entry.max) then
			local chance = entry.chance * (dungeon and 2 or 1)
			if math.random(100) <= chance then return ns.ITEM_BY_ID[entry.id] end
		end
	end
	return nil
end

function ns.RollDrop(playerLevel, elite, streak)
	local chance = (elite and 75 or 40) * (1 + ns.STREAK_STEP * (streak or 0))
	if math.random(100) > math.min(95, chance) then return nil end
	local pool = {}
	local top = playerLevel + (elite and 4 or 1)
	local bottom = playerLevel - 4
	for _, item in ipairs(ns.ITEM_LIST) do
		if not item.noDrop and item.level <= top and item.level >= bottom then
			local weight = elite and (item.quality - 1) or (7 - item.quality)
			for _ = 1, math.max(1, weight) do
				pool[#pool + 1] = item
			end
		end
	end

	if #pool == 0 then return nil end
	return pool[math.random(#pool)]
end
