local _, ns = ...
local BAR_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"
function ns.Fill(frame, r, g, b, a)
	local t = frame:CreateTexture(nil, "BACKGROUND")
	t:SetAllPoints(frame)
	t:SetColorTexture(r, g, b, a)
	return t
end

function ns.Border(frame, r, g, b, a, layer)
	local edges = {{"TOPLEFT", "TOPRIGHT", false}, {"BOTTOMLEFT", "BOTTOMRIGHT", false}, {"TOPLEFT", "BOTTOMLEFT", true}, {"TOPRIGHT", "BOTTOMRIGHT", true},}
	frame.borderTextures = {}
	for _, e in ipairs(edges) do
		local t = frame:CreateTexture(nil, layer or "OVERLAY")
		t:SetColorTexture(r, g, b, a)
		t:SetPoint(e[1])
		t:SetPoint(e[2])
		if e[3] then
			t:SetWidth(1)
		else
			t:SetHeight(1)
		end

		frame.borderTextures[#frame.borderTextures + 1] = t
	end
	return frame.borderTextures
end

function ns.SetBorderColor(frame, r, g, b, a)
	if not frame.borderTextures then return end
	for _, t in ipairs(frame.borderTextures) do
		t:SetColorTexture(r, g, b, a or 1)
	end
end

function ns.Bar(parent, w, h, r, g, b)
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetSize(w, h)
	bar:SetStatusBarTexture(BAR_TEXTURE)
	bar:SetStatusBarColor(r, g, b)
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(1)
	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(bar)
	bg:SetColorTexture(0, 0, 0, 0.7)
	bar.label = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	bar.label:SetPoint("CENTER")
	return bar
end

function ns.SetBar(bar, value, maxValue, text)
	bar:SetMinMaxValues(0, math.max(1, maxValue))
	bar:SetValue(value)
	bar.label:SetText(text)
end

function ns.Enable(button, enabled)
	if enabled then
		button:Enable()
	else
		button:Disable()
	end
end

function ns.Tooltip(button, title, text, extra)
	button.tipTitle = title
	button.tipText = text
	button.tipExtra = extra
	if button.tipInstalled then return end
	button.tipInstalled = true
	button:SetScript("OnEnter", function(self)
		if not self.tipTitle then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(self.tipTitle, 1, 0.82, 0)
		if self.tipText then GameTooltip:AddLine(self.tipText, 1, 1, 1, true) end
		if self.tipExtra then GameTooltip:AddLine(self.tipExtra, 0.6, 0.6, 0.6, true) end
		GameTooltip:Show()
	end)

	button:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function ns.RefreshTooltip(button)
	if not button or not button:IsShown() or not button:IsMouseOver() then return end
	local onEnter = button:GetScript("OnEnter")
	if onEnter then onEnter(button) end
end

function ns.AddonVersion()
	local getter = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
	local version = getter and getter("MurlocRPG", "Version")
	return version and format("v%s", version) or ""
end

function ns.SetAtlasIcon(texture, atlas)
	if not texture then return false end
	local info = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas)
	if info and (info.file or info.filename) then
		texture:SetTexture(info.file or info.filename)
		texture:SetTexCoord(info.leftTexCoord, info.rightTexCoord, info.topTexCoord, info.bottomTexCoord)
		texture:SetDesaturated(false)
		return true
	end

	if not texture.SetAtlas then return false end
	texture:SetTexCoord(0, 1, 0, 1)
	texture:SetAtlas(atlas)
	return true
end

function ns.MakeButton(parent, w, h, text, iconName, onClick)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetSize(w, h)
	if b.SetMotionScriptsWhileDisabled then b:SetMotionScriptsWhileDisabled(true) end
	b:SetText(text)
	b:SetScript("OnClick", onClick)
	b.icon = b:CreateTexture(nil, "OVERLAY")
	b.icon:SetSize(h - 8, h - 8)
	b.icon:SetPoint("LEFT", 4, 0)
	ns.SetIcon(b.icon, iconName)
	return b
end

function ns.MakeSquareButton(parent, size, iconName, onClick)
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(size, size)
	if b.SetMotionScriptsWhileDisabled then b:SetMotionScriptsWhileDisabled(true) end
	b:SetScript("OnClick", onClick)
	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetPoint("TOPLEFT", 1, -1)
	b.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	ns.SetIcon(b.icon, iconName)
	ns.Border(b, 0, 0, 0, 1)
	b.count = b:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	b.count:SetPoint("BOTTOMRIGHT", -3, 3)
	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	b:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	b:SetScript("OnEnable", function(self) self.icon:SetDesaturated(false) end)
	b:SetScript("OnDisable", function(self) self.icon:SetDesaturated(true) end)
	return b
end

function ns.IconButton(parent, size, iconName, onClick)
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(size, size)
	if b.SetMotionScriptsWhileDisabled then b:SetMotionScriptsWhileDisabled(true) end
	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetPoint("TOPLEFT", 2, -2)
	b.icon:SetPoint("BOTTOMRIGHT", -2, 2)
	ns.SetIcon(b.icon, iconName)
	ns.Fill(b, 0, 0, 0, 1)
	ns.Border(b, 0.35, 0.35, 0.35, 1)
	if onClick then b:SetScript("OnClick", onClick) end
	return b
end

local SLIDER_TEMPLATES = {"MinimalSliderTemplate", "UISliderTemplate", "OptionsSliderTemplate"}
local function SliderTemplate()
	if not DoesTemplateExist then return "OptionsSliderTemplate" end
	for _, name in ipairs(SLIDER_TEMPLATES) do
		if DoesTemplateExist(name) then return name end
	end

	return "OptionsSliderTemplate"
end

function ns.MakeSlider(parent, name, width, minValue, maxValue, step, labelFormat, onChange)
	local slider = CreateFrame("Slider", name, parent, SliderTemplate())
	slider:SetSize(width, 16)
	slider:SetOrientation("HORIZONTAL")
	slider:SetMinMaxValues(minValue, maxValue)
	slider:SetValueStep(step)
	if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
	for _, suffix in ipairs({"Low", "High", "Text"}) do
		local fs = _G[name .. suffix]
		if fs then fs:SetText("") end
	end

	slider.label = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	slider.label:SetPoint("LEFT", slider, "RIGHT", 8, 0)
	slider:HookScript("OnValueChanged", function(self, value)
		value = math.max(minValue, math.min(maxValue, tonumber(format("%.2f", value)) or minValue))
		self.pending = value
		self.label:SetText(format(labelFormat, value))
	end)

	slider:HookScript("OnMouseUp", function(self)
		if onChange and self.pending then onChange(self.pending) end
	end)

	slider:SetValue(minValue)
	slider.label:SetText(format(labelFormat, minValue))
	return slider
end

local REFERENCE_UI_SCALE = 0.65
local userScale = 1
local scaledFrames = {}
local function ApplyLockedScale(frame)
	local parent = frame:GetParent() or UIParent
	local scale = parent:GetEffectiveScale()
	if not scale or scale <= 0 then return end
	frame:SetScale(REFERENCE_UI_SCALE * userScale / scale)
end

function ns.SetUserScale(value)
	userScale = math.max(0.75, math.min(1.5, tonumber(value) or 1))
	for _, frame in ipairs(scaledFrames) do
		ApplyLockedScale(frame)
	end
end

function ns.LockScale(frame)
	if not frame then return end
	scaledFrames[#scaledFrames + 1] = frame
	ApplyLockedScale(frame)
end

local scaleWatcher = CreateFrame("Frame")
pcall(scaleWatcher.RegisterEvent, scaleWatcher, "UI_SCALE_CHANGED")
pcall(scaleWatcher.RegisterEvent, scaleWatcher, "DISPLAY_SIZE_CHANGED")
scaleWatcher:SetScript("OnEvent", function()
	for _, frame in ipairs(scaledFrames) do
		ApplyLockedScale(frame)
	end
end)
