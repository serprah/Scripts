--[[
	╔═══════════════════════════════════════════╗
	║        SELL LEMONS AUTOFARM               ║
	║        Made by Zeroh Scripts              ║
	╚═══════════════════════════════════════════╝
	Press K to show/hide the GUI
--]]

--// Services
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

--// Find Tycoon
local userTycoon = (function()
	for _, v in pairs(workspace:GetChildren()) do
		if v:IsA("Folder") and v.Name:match("Tycoon%d") then
			if v:FindFirstChild("Owner") and v.Owner.Value == LocalPlayer then
				return v
			end
		end
	end
end)()

--// GUI Root
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZerohAutofarm"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

--// Palette
local C = {
	BG      = Color3.fromRGB(10,  10,  14),
	Panel   = Color3.fromRGB(16,  16,  22),
	Card    = Color3.fromRGB(22,  22,  32),
	Border  = Color3.fromRGB(40,  40,  58),
	Accent  = Color3.fromRGB(220, 200, 30),
	AccDim  = Color3.fromRGB(90,  80,  10),
	Text    = Color3.fromRGB(235, 235, 235),
	Sub     = Color3.fromRGB(120, 120, 145),
	Green   = Color3.fromRGB(55,  210, 110),
	Red     = Color3.fromRGB(220, 65,  65),
	TrackOff= Color3.fromRGB(45,  45,  62),
}

--// Helpers
local function mkCorner(p, r)
	local o = Instance.new("UICorner")
	o.CornerRadius = UDim.new(0, r or 8)
	o.Parent = p
end

local function mkStroke(p, col, thick)
	local o = Instance.new("UIStroke")
	o.Color = col or C.Border
	o.Thickness = thick or 1
	o.Parent = p
end

local function mkFrame(parent, size, pos, color)
	local f = Instance.new("Frame")
	f.Size = size
	f.Position = pos or UDim2.new(0,0,0,0)
	f.BackgroundColor3 = color or C.Panel
	f.BorderSizePixel = 0
	f.Parent = parent
	return f
end

local function mkLabel(parent, text, size, color, font, xalign)
	local l = Instance.new("TextLabel")
	l.Text = text
	l.TextSize = size or 14
	l.TextColor3 = color or C.Text
	l.Font = font or Enum.Font.GothamBold
	l.BackgroundTransparency = 1
	l.TextXAlignment = xalign or Enum.TextXAlignment.Left
	l.Size = UDim2.new(1,0,1,0)
	l.Parent = parent
	return l
end

-- ══════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ══════════════════════════════════════════
local NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.new(0, 290, 1, 0)
NotifHolder.Position = UDim2.new(1, -305, 0, 0)
NotifHolder.BackgroundTransparency = 1
NotifHolder.Parent = ScreenGui

local nLayout = Instance.new("UIListLayout")
nLayout.SortOrder = Enum.SortOrder.LayoutOrder
nLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
nLayout.Padding = UDim.new(0, 8)
nLayout.Parent = NotifHolder

local nPad = Instance.new("UIPadding")
nPad.PaddingBottom = UDim.new(0, 20)
nPad.Parent = NotifHolder

local function notify(title, body, kind)
	local col = kind == "success" and C.Green or kind == "error" and C.Red or C.Accent

	local card = mkFrame(NotifHolder, UDim2.new(1,0,0,68), UDim2.new(1.3,0,0,0), C.Card)
	card.ClipsDescendants = true
	mkCorner(card, 10)
	mkStroke(card, col, 1.2)

	local bar = mkFrame(card, UDim2.new(0,3,1,0), UDim2.new(0,0,0,0), col)
	mkCorner(bar, 2)

	local dot = mkFrame(card, UDim2.new(0,8,0,8), UDim2.new(0,16,0.5,-4), col)
	mkCorner(dot, 4)

	local t = mkLabel(card, title, 13, C.Text, Enum.Font.GothamBold)
	t.Size = UDim2.new(1,-36,0,20)
	t.Position = UDim2.new(0,32,0,10)

	local b = mkLabel(card, body, 11, C.Sub, Enum.Font.Gotham)
	b.Size = UDim2.new(1,-36,0,16)
	b.Position = UDim2.new(0,32,0,34)

	TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0,0,0,0)
	}):Play()

	task.delay(3.5, function()
		TweenService:Create(card, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(1.3,0,0,0)
		}):Play()
		task.wait(0.32)
		if card and card.Parent then card:Destroy() end
	end)
end

-- ══════════════════════════════════════════
--  MAIN WINDOW  (380 × 480)
-- ══════════════════════════════════════════
local WIN_W, WIN_H = 380, 480

local MainFrame = mkFrame(ScreenGui,
	UDim2.new(0, WIN_W, 0, WIN_H),
	UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
	C.BG
)
MainFrame.ClipsDescendants = true
mkCorner(MainFrame, 14)
mkStroke(MainFrame, C.Border, 1.5)

-- ── Title Bar ──────────────────────────────
local TitleBar = mkFrame(MainFrame, UDim2.new(1,0,0,58), UDim2.new(0,0,0,0), C.Panel)
-- square off bottom of title bar
local titleSquare = mkFrame(MainFrame, UDim2.new(1,0,0,14), UDim2.new(0,0,0,44), C.Panel)

-- accent rule
local rule = mkFrame(MainFrame, UDim2.new(1,-28,0,2), UDim2.new(0,14,0,57), C.Accent)
mkCorner(rule, 2)

-- lemon badge
local badge = mkFrame(TitleBar, UDim2.new(0,38,0,38), UDim2.new(0,14,0.5,-19), C.Card)
mkCorner(badge, 10)
mkStroke(badge, C.AccDim, 1)
local badgeLbl = mkLabel(badge, "🍋", 20, C.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
badgeLbl.TextYAlignment = Enum.TextYAlignment.Center

-- title + sub
local tTitle = mkLabel(TitleBar, "SELL LEMONS", 17, C.Text, Enum.Font.GothamBold)
tTitle.Size = UDim2.new(0,200,0,22)
tTitle.Position = UDim2.new(0,62,0,9)

local tSub = mkLabel(TitleBar, "AUTOFARM  ·  Press K to hide", 10, C.Accent, Enum.Font.Gotham)
tSub.Size = UDim2.new(0,230,0,14)
tSub.Position = UDim2.new(0,62,0,31)

-- ── Scroll / Content ───────────────────────
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1,-20,1,-78)
ScrollFrame.Position = UDim2.new(0,10,0,68)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = C.AccDim
ScrollFrame.CanvasSize = UDim2.new(0,0,0,0)   -- auto via layout
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0,10)
listLayout.Parent = ScrollFrame

local listPad = Instance.new("UIPadding")
listPad.PaddingTop    = UDim.new(0,6)
listPad.PaddingBottom = UDim.new(0,10)
listPad.Parent = ScrollFrame

-- ── Status card ────────────────────────────
local statusCard = mkFrame(ScrollFrame, UDim2.new(1,0,0,40), nil, C.Card)
mkCorner(statusCard, 9)
mkStroke(statusCard, C.Border)

local sDot = mkFrame(statusCard, UDim2.new(0,8,0,8), UDim2.new(0,12,0.5,-4),
	userTycoon and C.Green or C.Red)
mkCorner(sDot, 4)

local sLbl = mkLabel(statusCard,
	userTycoon and "Tycoon detected — ready to farm" or "⚠ Tycoon not found — please rejoin",
	12, userTycoon and C.Green or C.Red, Enum.Font.Gotham)
sLbl.Size  = UDim2.new(1,-30,1,0)
sLbl.Position = UDim2.new(0,26,0,0)

-- ── Section header ─────────────────────────
local function sectionHeader(text)
	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.new(1,0,0,24)
	wrap.BackgroundTransparency = 1
	wrap.Parent = ScrollFrame

	local lbl = mkLabel(wrap, text, 10, C.Sub, Enum.Font.GothamBold)
	lbl.Size = UDim2.new(1,0,1,0)
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	local sep = mkFrame(wrap, UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), C.Border)
end

-- ── Toggle card  (switch only, no pill) ────
local function createToggle(name, desc, callback)
	local card = mkFrame(ScrollFrame, UDim2.new(1,0,0,76), nil, C.Card)
	mkCorner(card, 10)
	mkStroke(card, C.Border)

	local nameLbl = mkLabel(card, name, 14, C.Text, Enum.Font.GothamBold)
	nameLbl.Size = UDim2.new(1,-70,0,20)
	nameLbl.Position = UDim2.new(0,14,0,14)

	local descLbl = mkLabel(card, desc, 11, C.Sub, Enum.Font.Gotham)
	descLbl.Size = UDim2.new(1,-70,0,16)
	descLbl.Position = UDim2.new(0,14,0,36)
	descLbl.TextWrapped = true

	-- Switch track
	local track = mkFrame(card, UDim2.new(0,48,0,26), UDim2.new(1,-62,0.5,-13), C.TrackOff)
	mkCorner(track, 13)

	-- Switch knob
	local knob = mkFrame(track, UDim2.new(0,20,0,20), UDim2.new(0,3,0.5,-10), Color3.new(1,1,1))
	mkCorner(knob, 10)

	local state = false

	local function applyState(val)
		state = val
		local knobTarget  = val and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
		local trackTarget = val and C.Accent or C.TrackOff
		TweenService:Create(knob,  TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = knobTarget}):Play()
		TweenService:Create(track, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = trackTarget}):Play()
		if callback then callback(val) end
	end

	-- Invisible click button over whole card
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1,0,1,0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.ZIndex = 10
	btn.Parent = card

	btn.MouseButton1Click:Connect(function()
		applyState(not state)
	end)

	btn.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.14), {BackgroundColor3 = Color3.fromRGB(28,28,40)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.14), {BackgroundColor3 = C.Card}):Play()
	end)

	return applyState
end

-- ── Footer ─────────────────────────────────
local function buildFooter()
	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.new(1,0,0,32)
	wrap.BackgroundTransparency = 1
	wrap.Parent = ScrollFrame

	local lbl = mkLabel(wrap, "🍋  made by zeroh scripts", 11, C.Sub, Enum.Font.Gotham, Enum.TextXAlignment.Center)
	lbl.Size = UDim2.new(1,0,1,0)
end

-- ══════════════════════════════════════════
--  BUILD LAYOUT
-- ══════════════════════════════════════════
sectionHeader("AUTOMATION")

-- ── Logic variables ────────────────────────
local AutoBuy     = false
local AutoUpgrade = false
local AutoFruit   = false
local Buying      = false

createToggle("Auto Buy", "Automatically purchase all available tycoon items", function(val)
	AutoBuy = val
	notify("Auto Buy", val and "Enabled" or "Disabled", val and "success" or nil)
end)

createToggle("Auto Upgrade", "Automatically upgrades all machines to max level", function(val)
	AutoUpgrade = val
	notify("Auto Upgrade", val and "Enabled" or "Disabled", val and "success" or nil)
end)

createToggle("Auto Fruit", "Teleports to each lemon tree and collects fruit", function(val)
	AutoFruit = val
	notify("Auto Fruit", val and "Enabled" or "Disabled", val and "success" or nil)
end)

buildFooter()

-- ══════════════════════════════════════════
--  GAME LOGIC  (identical to original)
-- ══════════════════════════════════════════

-- Auto Buy loop
local function getButtons()
	local out = {}
	if not userTycoon then return out end
	for _, obj in ipairs(userTycoon.Purchases:GetDescendants()) do
		if obj:IsA("Model") then
			if obj:GetAttribute("Shown") == true and obj:GetAttribute("Purchased") ~= true then
				local bp = obj:FindFirstChild("Button")
				if bp and bp:IsA("BasePart") then
					table.insert(out, {Name = obj.Name, Button = bp})
				end
			end
		end
	end
	return out
end

local function buyButton(data)
	if Buying then return end
	Buying = true
	local char = LocalPlayer.Character
	if not char then Buying = false return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then Buying = false return end
	pcall(function()
		firetouchinterest(hrp, data.Button, 0)
		firetouchinterest(hrp, data.Button, 1)
	end)
	Buying = false
end

task.spawn(function()
	while true do
		task.wait(0.0000001)
		if AutoBuy then
			for _, btn in ipairs(getButtons()) do
				pcall(function() buyButton(btn) end)
			end
		end
	end
end)

-- Auto Upgrade loop
local function upgradeMachines()
	if not userTycoon then return end
	for _, obj in ipairs(userTycoon.Purchases:GetDescendants()) do
		if obj:IsA("RemoteFunction") and obj.Name == "Upgrade" then
			pcall(function()
				for lvl = 1, 100 do obj:InvokeServer(lvl) end
			end)
		end
	end
end

task.spawn(function()
	while true do
		task.wait(0.00001)
		if AutoUpgrade then pcall(upgradeMachines) end
	end
end)

-- Tree tracking
local Trees = {}
local function addTree(obj)
	if obj:IsA("Model") and obj.Name == "LemonTree" then
		if not table.find(Trees, obj) then table.insert(Trees, obj) end
	end
end
local function removeTree(obj)
	local i = table.find(Trees, obj)
	if i then table.remove(Trees, i) end
end
for _, v in ipairs(workspace:GetDescendants()) do addTree(v) end
workspace.DescendantAdded:Connect(addTree)
workspace.DescendantRemoving:Connect(removeTree)

local function noCollide(tree)
	for _, p in ipairs(tree:GetDescendants()) do
		if p:IsA("BasePart") then p.CanCollide = false end
	end
end
local function tpToTree(tree)
	local char = LocalPlayer.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	hrp.CFrame = tree:GetPivot() + Vector3.new(0,5,0)
	return true
end
local function collectFruit(tree)
	noCollide(tree)
	if not tpToTree(tree) then return end
	for _, obj in ipairs(tree:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "Fruit" then
			obj.CanCollide = false
			local cp = obj:FindFirstChild("ClickPart")
			if cp then
				local det = cp:FindFirstChildOfClass("ClickDetector")
				if det then
					task.wait(0.45)
					pcall(function() fireclickdetector(det) end)
				end
			end
		end
	end
end

task.spawn(function()
	while true do
		task.wait(0.1)
		if AutoFruit then
			for _, tree in ipairs(Trees) do
				if not AutoFruit then break end
				if tree and tree.Parent then
					pcall(function() collectFruit(tree) end)
				end
			end
		end
	end
end)

-- ══════════════════════════════════════════
--  DRAGGING  (title bar only)
-- ══════════════════════════════════════════
local dragging = false
local dragStartMouse, dragStartFrame

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStartMouse = input.Position
		dragStartFrame = MainFrame.Position
	end
end)

TitleBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStartMouse
		MainFrame.Position = UDim2.new(
			dragStartFrame.X.Scale, dragStartFrame.X.Offset + delta.X,
			dragStartFrame.Y.Scale, dragStartFrame.Y.Offset + delta.Y
		)
	end
end)

-- ══════════════════════════════════════════
--  K  → TOGGLE VISIBILITY
-- ══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.K then
		MainFrame.Visible = not MainFrame.Visible
	end
end)

-- ══════════════════════════════════════════
--  STARTUP NOTIFICATION
-- ══════════════════════════════════════════
if userTycoon then
	notify("Loaded!", "Zeroh Autofarm ready  ·  Press K to hide", "success")
else
	notify("Error", "Tycoon not found — please rejoin", "error")
end
