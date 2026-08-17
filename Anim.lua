local _, ns = ...

local Sprite = {}

local function Apply(self)
	local def = self.def

	if not def then
		return
	end

	local col = self.index % def.cols
	local row = math.floor(self.index / def.cols)
	local l = col / def.cols
	local r = (col + 1) / def.cols
	local t = row / def.rows
	local b = (row + 1) / def.rows

	if self.flip then
		self.texture:SetTexCoord(r, t, r, b, l, t, l, b)
	else
		self.texture:SetTexCoord(l, t, l, b, r, t, r, b)
	end
end

local function StepAnim(self, elapsed)
	if not self.playing or not self.def then
		return
	end

	self.timer = self.timer + elapsed

	local step = 1 / self.fps

	while self.timer >= step do
		self.timer = self.timer - step

		if self.index + 1 >= self.def.frames then
			if self.loop then
				self.index = 0
			else
				self.index = self.def.frames - 1
				self.playing = false
				Apply(self)

				local cb = self.onFinish
				self.onFinish = nil

				if cb then
					cb(self)
				end

				return
			end
		else
			self.index = self.index + 1
		end

		Apply(self)
	end
end

local function StepMove(self, elapsed)
	if not self.moving then
		return
	end

	self.moveTime = self.moveTime + elapsed

	local p = self.moveTime / self.moveDur

	if p >= 1 then
		p = 1
		self.moving = false
	end

	self:SetPos(self.moveFrom + (self.moveTo - self.moveFrom) * p, self.posY)

	if not self.moving then
		local cb = self.moveDone
		self.moveDone = nil

		if cb then
			cb(self)
		end
	end
end

local function StepFade(self, elapsed)
	if not self.fading then
		return
	end

	self.fadeTime = self.fadeTime + elapsed

	local p = self.fadeTime / self.fadeDur

	if p >= 1 then
		p = 1
		self.fading = false
	end

	self:SetAlpha(self.fadeFrom + (self.fadeTo - self.fadeFrom) * p)

	if not self.fading then
		local cb = self.fadeDone
		self.fadeDone = nil

		if cb then
			cb(self)
		end
	end
end

local function StepFlash(self, elapsed)
	if not self.flashTimer then
		return
	end

	self.flashTimer = self.flashTimer - elapsed

	if self.flashTimer <= 0 then
		self.flashTimer = nil
		self.texture:SetVertexColor(self.tintR, self.tintG, self.tintB)
	end
end

local function OnUpdate(self, elapsed)
	StepAnim(self, elapsed)
	StepMove(self, elapsed)
	StepFade(self, elapsed)
	StepFlash(self, elapsed)
end

function Sprite:Play(def, fps, loop, onFinish)
	if not def then
		return
	end

	if self.def ~= def then
		self.texture:SetTexture(ns.MEDIA .. def.file)
		self.def = def
	end

	self.index = 0
	self.timer = 0
	self.fps = fps or 12
	self.loop = loop and true or false
	self.playing = true
	self.onFinish = onFinish

	Apply(self)
end

function Sprite:SetFlip(flip)
	self.flip = flip and true or false
	Apply(self)
end

function Sprite:SetPos(x, y)
	self.posX = x
	self.posY = y
	self:ClearAllPoints()
	self:SetPoint("BOTTOM", self:GetParent(), "BOTTOMLEFT", x, y)
end

function Sprite:MoveTo(x, duration, onDone)
	self.moveFrom = self.posX
	self.moveTo = x
	self.moveDur = math.max(0.01, duration or 0.5)
	self.moveTime = 0
	self.moving = true
	self.moveDone = onDone
end

function Sprite:StopMove()
	self.moving = false
	self.moveDone = nil
end

function Sprite:Fade(from, to, duration, onDone)
	self:SetAlpha(from)
	self.fadeFrom = from
	self.fadeTo = to
	self.fadeDur = math.max(0.01, duration or 0.3)
	self.fadeTime = 0
	self.fading = true
	self.fadeDone = onDone
end

function Sprite:Flash()
	self.texture:SetVertexColor(1, 0.35, 0.35)
	self.flashTimer = 0.2
end

function Sprite:SetTint(r, g, b)
	self.tintR, self.tintG, self.tintB = r, g, b
	self.flashTimer = nil
	self.texture:SetVertexColor(r, g, b)
end

function Sprite:SetDisplaySize(size)
	self:SetSize(size, size)
end

function ns.CreateSprite(parent, size)
	local f = CreateFrame("Frame", nil, parent)
	f:SetSize(size, size)

	local t = f:CreateTexture(nil, "ARTWORK")
	t:SetAllPoints(f)
	f.texture = t

	f.index = 0
	f.timer = 0
	f.fps = 12
	f.posX = 0
	f.posY = 0
	f.flip = false
	f.playing = false
	f.tintR, f.tintG, f.tintB = 1, 1, 1

	for k, v in pairs(Sprite) do
		f[k] = v
	end

	f:SetScript("OnUpdate", OnUpdate)

	return f
end
