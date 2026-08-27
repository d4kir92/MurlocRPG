local _, ns = ...
local G = ns.Game
local SLOT = 44
local STEP = 52
local COLS = 6
local BUY_ROWS = 5
local BLOCK_GAP = 26
local BUY_TOP = 78
local CATEGORIES = {"LID_SHOP_ARMOR", "LID_SHOP_WEAPONS", "LID_SHOP_BAGS", "LID_SHOP_SUPPLIES",}
local Shop = {}
ns.Shop = Shop
local function CategoryOf(item)
	if item.slotType == "BAG" then return 3 end
	if item.slotType == "MAINHAND" or item.slotType == "OFFHAND" then return 2 end
	return 1
end

local PER_BLOCK = COLS * BUY_ROWS
local BLOCK_WIDTH = COLS * STEP - (STEP - SLOT)
local function BlockLayout(count)
	local blocks = math.max(1, math.ceil(count / PER_BLOCK))
	local lastCols = math.max(1, math.min(COLS, count - (blocks - 1) * PER_BLOCK))
	local width = (blocks - 1) * (BLOCK_WIDTH + BLOCK_GAP) + lastCols * STEP - (STEP - SLOT)
	local rows = blocks > 1 and BUY_ROWS or math.max(1, math.ceil(count / COLS))
	return width, rows
end

local function SlotOffset(index)
	local inBlock = (index - 1) % PER_BLOCK
	local block = math.floor((index - 1) / PER_BLOCK)
	return block * (BLOCK_WIDTH + BLOCK_GAP) + (inBlock % COLS) * STEP, math.floor(inBlock / COLS) * STEP
end
function Shop:Create()
	if self.frame then return end
	local f = CreateFrame("Frame", "MurlocRPGShopFrame", UIParent)
	f:SetSize(300, 716)
	ns.LockScale(f)
	f:SetFrameStrata("DIALOG")
	f:SetClampedToScreen(true)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:Hide()
	ns.Fill(f, 0.05, 0.06, 0.09, 0.97)
	ns.Border(f, 0.45, 0.35, 0.15, 1)
	tinsert(UISpecialFrames, "MurlocRPGShopFrame")
	self.frame = f
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -3, -3)
	self.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.title:SetPoint("TOP", 0, -8)
	self.title:SetText(ns:Trans("LID_SHOP_TITLE"))
	self.money = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	self.money:SetPoint("TOP", 0, -32)
	self.catHeaders = {}
	for i, key in ipairs(CATEGORIES) do
		local header = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		header:SetPoint("TOPLEFT", 14, -56)
		header:SetText(ns:Trans(key))
		self.catHeaders[i] = header
	end

	self.buySlots = {}
	for i = 1, #ns.VENDOR_STOCK + #ns.VENDOR_BAGS do
		local b = ns.ItemSlot(f, SLOT, function(self2) Shop:OnBuy(self2.itemId, self2) end)
		b:SetPoint("TOPLEFT", 14 + ((i - 1) % COLS) * STEP, -78 - math.floor((i - 1) / COLS) * STEP)
		b:SetScript("OnEnter", function(self2)
			local item = ns.ITEM_BY_ID[self2.itemId]
			ns.ShowItemTooltip(self2, item, ns:Trans("LID_SHOP_BUY_HINT"), ns:Trans("LID_SHOP_COST"))
			ns.ShowCompare(item)
		end)
		self.buySlots[i] = b
	end

	self.empty = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	self.empty:SetPoint("TOPLEFT", 16, -82)
	self.empty:SetWidth(268)
	self.empty:SetJustifyH("LEFT")
	self.empty:SetText(ns:Trans("LID_SHOP_EMPTY"))
	self.supplySlots = {}
	for i, supply in ipairs(ns.CONSUMABLES) do
		local b = ns.ItemSlot(f, SLOT, function(self2) Shop:OnBuySupply(supply.id, self2) end)
		ns.SetIcon(b.icon, supply.icon)
		b:SetScript("OnEnter", function(self2)
			GameTooltip:SetOwner(self2, "ANCHOR_RIGHT")
			GameTooltip:AddLine(ns:Trans(supply.name), 1, 1, 1)
			GameTooltip:AddLine(ns:Trans(supply.desc), 0.2, 1, 0.2)
			GameTooltip:AddLine(format(ns:Trans("LID_SHOP_COST"), ns.MoneyText(supply.value)), 0.9, 0.85, 0.5)
			GameTooltip:AddLine(format(ns:Trans("LID_CONSUMABLE_OWNED"), G:SupplyCount(supply.id)), 0.7, 0.7, 0.7)
			GameTooltip:AddLine(ns:Trans("LID_SHOP_BUY_HINT"), 0.5, 0.5, 0.5, true)
			GameTooltip:Show()
		end)

		b.count = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		b.count:SetPoint("BOTTOMRIGHT", -3, 3)
		self.supplySlots[i] = b
	end

	self.sellHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.sellHeader:SetPoint("TOPLEFT", 14, -424)
	self.sellHeader:SetText(ns:Trans("LID_SHOP_SELL"))
	self.sellSlots = {}
	for i = 1, ns.BAG_MAX_SIZE do
		local b = ns.ItemSlot(f, SLOT, function(self2) Shop:OnSell(self2.bagIndex, self2) end)
		b.bagIndex = i
		b:SetScript("OnEnter", function(self2)
			local item = ns.ITEM_BY_ID[G:Bag()[self2.bagIndex]]
			ns.ShowItemTooltip(self2, item, ns:Trans("LID_SHOP_SELL_HINT"), ns:Trans("LID_SHOP_SELLS_FOR"))
			ns.ShowCompare(item)
		end)
		self.sellSlots[i] = b
	end

	self.sellHeaders = ns.MakeBagHeaders(f)
	self.hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	self.hint:SetPoint("BOTTOM", 0, 12)
	self.hint:SetWidth(276)
	self.hint:SetText(ns:Trans("LID_SHOP_SELL_HINT"))
end

function Shop:OnBuySupply(id, slot)
	if G:BuySupply(id) then
		self:Refresh()
		ns.UI:Refresh()
		ns.RefreshTooltip(slot)
	end
end

function Shop:OnBuy(itemId, slot)
	if not itemId then return end
	if G:Buy(itemId) then
		self:Refresh()
		ns.Inventory:Refresh()
		ns.UI:Refresh()
		ns.RefreshTooltip(slot)
	end
end

function Shop:OnSell(bagIndex, slot)
	if not G:Bag()[bagIndex] then return end
	if G:Sell(bagIndex) then
		self:Refresh()
		ns.Inventory:Refresh()
		ns.Character:Refresh()
		ns.UI:Refresh()
		ns.RefreshTooltip(slot)
	end
end

function Shop:Refresh()
	if not self.frame or not self.frame:IsShown() or not G:HasSave() then return end
	self.money:SetText(format(ns:Trans("LID_SHOP_MONEY"), ns.MoneyText(G:Money())))
	local stock = G:ShopStock()
	self.empty:SetShown(#stock == 0)
	local groups = {{}, {}, {},}
	for _, item in ipairs(stock) do
		local group = groups[CategoryOf(item)]
		group[#group + 1] = item
	end

	local x = 14
	local rows = 1
	local index = 0
	for category = 1, 3 do
		local items = groups[category]
		local header = self.catHeaders[category]
		if #items == 0 then
			header:Hide()
		else
			local width, blockRows = BlockLayout(#items)
			header:ClearAllPoints()
			header:SetPoint("TOPLEFT", x, -56)
			header:Show()
			for i, item in ipairs(items) do
				index = index + 1
				local b = self.buySlots[index]
				if b then
					local dx, dy = SlotOffset(i)
					b.itemId = item.id
					b:ClearAllPoints()
					b:SetPoint("TOPLEFT", x + dx, -BUY_TOP - dy)
					b:Show()
					ns.SetIcon(b.icon, item.icon)
					b.icon:SetVertexColor(G:CanAfford(item.value) and 1 or 0.9, G:CanAfford(item.value) and 1 or 0.4, G:CanAfford(item.value) and 1 or 0.4)
					ns.SetBorderColor(b, ns.ItemColor(item))
				end
			end

			rows = math.max(rows, blockRows)
			x = x + width + BLOCK_GAP
		end
	end

	for i = index + 1, #self.buySlots do
		self.buySlots[i].itemId = nil
		self.buySlots[i]:Hide()
	end

	local supplyWidth, supplyRows = BlockLayout(#self.supplySlots)
	local supplyHeader = self.catHeaders[4]
	supplyHeader:ClearAllPoints()
	supplyHeader:SetPoint("TOPLEFT", x, -56)
	supplyHeader:Show()
	for i, b in ipairs(self.supplySlots) do
		local supply = ns.CONSUMABLES[i]
		local dx, dy = SlotOffset(i)
		b:ClearAllPoints()
		b:SetPoint("TOPLEFT", x + dx, -BUY_TOP - dy)
		b.count:SetText(G:SupplyCount(supply.id))
		b.icon:SetVertexColor(1, G:CanAfford(supply.value) and 1 or 0.4, G:CanAfford(supply.value) and 1 or 0.4)
	end

	rows = math.max(rows, supplyRows)
	x = x + supplyWidth + BLOCK_GAP
	local buyWidth = x - 14 - BLOCK_GAP
	local buyBottom = BUY_TOP + (rows - 1) * STEP + SLOT + 20
	self.sellHeader:ClearAllPoints()
	self.sellHeader:SetPoint("TOPLEFT", 14, -buyBottom)
	local bag = G:Bag()
	local width, height = ns.LayoutBags(self.sellSlots, self.sellHeaders, 14, -(buyBottom + 22))
	self.frame:SetSize(math.max(300, width + 28, buyWidth + 28), buyBottom + 22 + height + 40)
	self.hint:SetWidth(math.max(276, width))
	for i, b in ipairs(self.sellSlots) do
		local item = ns.ITEM_BY_ID[bag[i]]
		if item then
			ns.SetIcon(b.icon, item.icon)
			b.icon:SetVertexColor(1, 1, 1)
			ns.SetBorderColor(b, ns.ItemColor(item))
		else
			ns.SetIcon(b.icon, "empty_inv_slot")
			b.icon:SetVertexColor(0.4, 0.4, 0.4)
			ns.SetBorderColor(b, 0.25, 0.25, 0.25, 1)
		end
	end
end

function Shop:Toggle()
	self:Create()
	if self.frame:IsShown() then
		self.frame:Hide()
		return
	end

	ns.Talents:Hide()
	ns.Inventory:Hide()
	ns.Character:Hide()
	ns.Quests:Hide()
	self.frame:ClearAllPoints()
	if ns.UI.frame and ns.UI.frame:IsShown() then
		self.frame:SetPoint("TOPLEFT", ns.UI.frame, "TOPRIGHT", 8, 0)
	else
		self.frame:SetPoint("CENTER")
	end

	self.frame:Show()
	self:Refresh()
end

function Shop:Hide()
	ns.HideCompare()
	if self.frame then self.frame:Hide() end
end
