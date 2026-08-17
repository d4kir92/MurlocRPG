local _, ns = ...
local G = ns.Game
local SLOT = 44
local STEP = 52
local COLS = 5
local BUY_ROWS = 5
local SELL_ROWS = 5
local Shop = {}
ns.Shop = Shop
function Shop:Create()
	if self.frame then return end
	local f = CreateFrame("Frame", "MurlocRPGShopFrame", UIParent)
	f:SetSize(300, 716)
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
	local buyHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	buyHeader:SetPoint("TOPLEFT", 14, -56)
	buyHeader:SetText(ns:Trans("LID_SHOP_BUY"))
	self.buySlots = {}
	for i = 1, COLS * BUY_ROWS do
		local col = (i - 1) % COLS
		local row = math.floor((i - 1) / COLS)
		local b = ns.ItemSlot(f, SLOT, function(self2) Shop:OnBuy(self2.itemId, self2) end)
		b:SetPoint("TOPLEFT", 14 + col * STEP, -78 - row * STEP)
		b:SetScript("OnEnter", function(self2) ns.ShowItemTooltip(self2, ns.ITEM_BY_ID[self2.itemId], ns:Trans("LID_SHOP_BUY_HINT"), ns:Trans("LID_SHOP_COST")) end)
		self.buySlots[i] = b
	end

	self.empty = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	self.empty:SetPoint("TOPLEFT", 16, -82)
	self.empty:SetWidth(268)
	self.empty:SetJustifyH("LEFT")
	self.empty:SetText(ns:Trans("LID_SHOP_EMPTY"))
	local supplyHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	supplyHeader:SetPoint("TOPLEFT", 14, -344)
	supplyHeader:SetText(ns:Trans("LID_SHOP_SUPPLIES"))
	self.supplySlots = {}
	for i, supply in ipairs(ns.CONSUMABLES) do
		local b = ns.ItemSlot(f, SLOT, function(self2) Shop:OnBuySupply(supply.id, self2) end)
		b:SetPoint("TOPLEFT", 14 + (i - 1) * STEP, -366)
		ns.SetIcon(b.icon, supply.icon)
		b:SetScript("OnEnter", function(self2)
			GameTooltip:SetOwner(self2, "ANCHOR_RIGHT")
			GameTooltip:AddLine(supply.name, 1, 1, 1)
			GameTooltip:AddLine(supply.desc, 0.2, 1, 0.2)
			GameTooltip:AddLine(format(ns:Trans("LID_SHOP_COST"), ns.MoneyText(supply.value)), 0.9, 0.85, 0.5)
			GameTooltip:AddLine(format(ns:Trans("LID_CONSUMABLE_OWNED"), G:SupplyCount(supply.id)), 0.7, 0.7, 0.7)
			GameTooltip:AddLine(ns:Trans("LID_SHOP_BUY_HINT"), 0.5, 0.5, 0.5, true)
			GameTooltip:Show()
		end)

		b.count = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		b.count:SetPoint("BOTTOMRIGHT", -3, 3)
		self.supplySlots[i] = b
	end

	local sellHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	sellHeader:SetPoint("TOPLEFT", 14, -424)
	sellHeader:SetText(ns:Trans("LID_SHOP_SELL"))
	self.sellSlots = {}
	for i = 1, COLS * SELL_ROWS do
		local col = (i - 1) % COLS
		local row = math.floor((i - 1) / COLS)
		local b = ns.ItemSlot(f, SLOT, function(self2) Shop:OnSell(self2.bagIndex, self2) end)
		b:SetPoint("TOPLEFT", 14 + col * STEP, -446 - row * STEP)
		b.bagIndex = i
		b:SetScript("OnEnter", function(self2) ns.ShowItemTooltip(self2, ns.ITEM_BY_ID[G:Bag()[self2.bagIndex]], ns:Trans("LID_SHOP_SELL_HINT"), ns:Trans("LID_SHOP_SELLS_FOR")) end)
		self.sellSlots[i] = b
	end

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
	for i, b in ipairs(self.buySlots) do
		local item = stock[i]
		b.itemId = item and item.id or nil
		if item then
			b:Show()
			ns.SetIcon(b.icon, item.icon)
			b.icon:SetVertexColor(G:CanAfford(item.value) and 1 or 0.9, G:CanAfford(item.value) and 1 or 0.4, G:CanAfford(item.value) and 1 or 0.4)
			ns.SetBorderColor(b, ns.ItemColor(item))
		else
			b:Hide()
		end
	end

	for i, b in ipairs(self.supplySlots) do
		local supply = ns.CONSUMABLES[i]
		b.count:SetText(G:SupplyCount(supply.id))
		b.icon:SetVertexColor(1, G:CanAfford(supply.value) and 1 or 0.4, G:CanAfford(supply.value) and 1 or 0.4)
	end

	local bag = G:Bag()
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
	if self.frame then self.frame:Hide() end
end
