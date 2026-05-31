--[[
	╔═══════════════════════════════════════════╗
	║        SELL LEMONS AUTOFARM               ║
	║        Made by Zeroh Scripts              ║
	╚═══════════════════════════════════════════╝
--]]

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

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

--// GUI Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZerohAutofarm"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

--// Color Palette
local Colors = {
	BG        = Color3.fromRGB(10, 10, 14),
	Panel     = Color3.fromRGB(16, 16, 22),
	Card      = Color3.fromRGB(22, 22, 30),
	Border    = Color3.fromRGB(35, 35, 50),
	Accent    = Color3.fromRGB(220, 200, 30),   -- lemon yellow
	AccentDim = Color3.fromRGB(120, 108, 10),
	Text      = Color3.fromRGB(230, 230, 230),
	SubText   = Color3.fromRGB(130, 130, 150),
	Success   = Color3.fromRGB(60, 210, 120),
	Danger    = Color3.fromRGB(220, 70, 70),
	Off       = Color3.fromRGB(50, 50, 65),
	OnGlow    = Color3.fromRGB(220, 200, 30),
}

--// Helper: UICorner
local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

--// Helper: UIStroke
local function stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Colors.Border
	s.Thickness = thickness or 1
	s.Parent = parent
	return s
end

--// Helper: Label
local function label(parent, text, size, color, font, xAlign)
	local l = Instance.new("TextLabel")
	l.Text = text
	l.TextSize = size or 14
	l.TextColor3 = color or Colors.Text
	l.Font = font or Enum.Font.GothamBold
	l.BackgroundTransparency = 1
	l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
	l.Size = UDim2.new(1, 0, 1, 0)
	l.Parent = parent
	return l
end

--// Helper: Frame
local function frame(parent, size, pos, color, zindex)
	local f = Instance.new("Frame")
	f.Size = size
	f.Position = pos or UDim2.new(0,0,0,0)
	f.BackgroundColor3 = color or Colors.Panel
	f.BorderSizePixel = 0
	if zindex then f.ZIndex = zindex end
	f.Parent = parent
	return f
end

--// Notification System
local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "Notifs"
NotifContainer.Size = UDim2.new(0, 280, 1, 0)
NotifContainer.Position = UDim2.new(1, -295, 0, 0)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.Parent = NotifContainer

local NotifPadding = Instance.new("UIPadding")
NotifPadding.PaddingBottom = UDim.new(0, 16)
NotifPadding.Parent = NotifContainer

local function notify(title, content, ntype)
	local accentColor = ntype == "success" and Colors.Success
		or ntype == "error" and Colors.Danger
		or Colors.Accent

	local notif = frame(NotifContainer, UDim2.new(1, 0, 0, 64), UDim2.new(0,0,0,0), Colors.Card)
	notif.ClipsDescendants = true
	corner(notif, 10)
	stroke(notif, accentColor, 1.2)

	-- left accent bar
	local bar = frame(notif, UDim2.new(0, 3, 1, 0), UDim2.new(0,0,0,0), accentColor)
	corner(bar, 2)

	-- icon dot
	local dot = frame(notif, UDim2.new(0, 8, 0, 8), UDim2.new(0, 16, 0.5, -4), accentColor)
	corner(dot, 4)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Text = title
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 13
	titleLabel.TextColor3 = Colors.Text
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -40, 0, 20)
	titleLabel.Position = UDim2.new(0, 32, 0, 10)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = notif

	local contentLabel = Instance.new("TextLabel")
	contentLabel.Text = content
	contentLabel.Font = Enum.Font.Gotham
	contentLabel.TextSize = 11
	contentLabel.TextColor3 = Colors.SubText
	contentLabel.BackgroundTransparency = 1
	contentLabel.Size = UDim2.new(1, -40, 0, 16)
	contentLabel.Position = UDim2.new(0, 32, 0, 32)
	contentLabel.TextXAlignment = Enum.TextXAlignment.Left
	contentLabel.Parent = notif

	-- animate in
	notif.Position = UDim2.new(1.2, 0, 0, 0)
	TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()

	task.delay(3.5, function()
		TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(1.2, 0, 0, 0)
		}):Play()
		task.wait(0.35)
		notif:Destroy()
	end)
end

--// Main Window
local MainFrame = frame(ScreenGui,
	UDim2.new(0, 340, 0, 420),
	UDim2.new(0.5, -170, 0.5, -210),
	Colors.BG
)
MainFrame.ClipsDescendants = false
corner(MainFrame, 14)
stroke(MainFrame, Colors.Border, 1.5)

-- Outer glow effect
local glow = Instance.new("ImageLabel")
glow.Image = "rbxassetid://5028857084"
glow.ImageColor3 = Colors.Accent
glow.ImageTransparency = 0.82
glow.BackgroundTransparency = 1
glow.Size = UDim2.new(1, 80, 1, 80)
glow.Position = UDim2.new(0, -40, 0, -40)
glow.ZIndex = 0
glow.Parent = MainFrame

-- Inner bg texture
local innerBg = frame(MainFrame, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Colors.BG)
innerBg.ZIndex = 1
corner(innerBg, 14)

--// Title Bar
local TitleBar = frame(innerBg, UDim2.new(1, 0, 0, 52), UDim2.new(0,0,0,0), Colors.Panel)
corner(TitleBar, 14)
TitleBar.ZIndex = 2

-- bottom fill to remove bottom radius on titlebar
local titleFill = frame(innerBg, UDim2.new(1, 0, 0, 14), UDim2.new(0,0,0,38), Colors.Panel)
titleFill.ZIndex = 2

-- accent line under title
local accentLine = frame(innerBg, UDim2.new(1, -24, 0, 2), UDim2.new(0, 12, 0, 52), Colors.Accent)
corner(accentLine, 2)
accentLine.ZIndex = 3

-- lemon icon area
local iconBg = frame(TitleBar, UDim2.new(0, 34, 0, 34), UDim2.new(0, 12, 0.5, -17), Colors.Card)
iconBg.ZIndex = 3
corner(iconBg, 8)
stroke(iconBg, Colors.AccentDim, 1)

local iconLabel = Instance.new("TextLabel")
iconLabel.Text = "🍋"
iconLabel.TextSize = 18
iconLabel.BackgroundTransparency = 1
iconLabel.Size = UDim2.new(1,0,1,0)
iconLabel.TextXAlignment = Enum.TextXAlignment.Center
iconLabel.TextYAlignment = Enum.TextYAlignment.Center
iconLabel.Parent = iconBg
iconLabel.ZIndex = 4

-- Title text
local titleText = Instance.new("TextLabel")
titleText.Text = "SELL LEMONS"
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.TextColor3 = Colors.Text
titleText.BackgroundTransparency = 1
titleText.Size = UDim2.new(0, 160, 0, 20)
titleText.Position = UDim2.new(0, 56, 0, 8)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.ZIndex = 4
titleText.Parent = TitleBar

local subText = Instance.new("TextLabel")
subText.Text = "AUTOFARM"
subText.Font = Enum.Font.Gotham
subText.TextSize = 10
subText.TextColor3 = Colors.Accent
subText.BackgroundTransparency = 1
subText.Size = UDim2.new(0, 160, 0, 14)
subText.Position = UDim2.new(0, 56, 0, 28)
subText.TextXAlignment = Enum.TextXAlignment.Left
subText.ZIndex = 4
subText.Parent = TitleBar

-- Close / minimize buttons
local function topBtn(xOff, color, icon)
	local btn = frame(TitleBar, UDim2.new(0, 14, 0, 14), UDim2.new(1, xOff, 0.5, -7), color)
	corner(btn, 7)
	btn.ZIndex = 4
	local lbl = Instance.new("TextLabel")
	lbl.Text = icon
	lbl.TextSize = 9
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.TextColor3 = Color3.new(0,0,0)
	lbl.Size = UDim2.new(1,0,1,0)
	lbl.ZIndex = 5
	lbl.Parent = btn
	return btn
end

local closeBtn   = topBtn(-22, Colors.Danger, "×")
local minimizeBtn = topBtn(-42, Colors.Accent, "−")

--// Content Area
local ContentArea = frame(innerBg, UDim2.new(1, -24, 0, 330), UDim2.new(0, 12, 0, 66))
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 2

local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 10)
Layout.Parent = ContentArea

--// Status Banner
local StatusBanner = frame(ContentArea, UDim2.new(1, 0, 0, 36), nil, Colors.Card)
corner(StatusBanner, 8)
stroke(StatusBanner, Colors.Border)
StatusBanner.ZIndex = 3

local statusDot = frame(StatusBanner, UDim2.new(0, 7, 0, 7), UDim2.new(0, 12, 0.5, -3.5),
	userTycoon and Colors.Success or Colors.Danger)
corner(statusDot, 4)
statusDot.ZIndex = 4

local statusText = Instance.new("TextLabel")
statusText.Text = userTycoon and ("Tycoon detected  ·  Ready") or "Tycoon NOT found — rejoin"
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 12
statusText.TextColor3 = userTycoon and Colors.Success or Colors.Danger
statusText.BackgroundTransparency = 1
statusText.Size = UDim2.new(1, -36, 1, 0)
statusText.Position = UDim2.new(0, 28, 0, 0)
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.ZIndex = 4
statusText.Parent = StatusBanner

--// Toggle Builder
local ToggleStates = {}

local function createToggle(parent, name, desc, flag, callback)
	local card = frame(parent, UDim2.new(1, 0, 0, 72), nil, Colors.Card)
	corner(card, 10)
	stroke(card, Colors.Border)
	card.ZIndex = 3

	-- feature name
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Text = name
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextSize = 13
	nameLbl.TextColor3 = Colors.Text
	nameLbl.BackgroundTransparency = 1
	nameLbl.Size = UDim2.new(1, -70, 0, 18)
	nameLbl.Position = UDim2.new(0, 14, 0, 12)
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.ZIndex = 4
	nameLbl.Parent = card

	-- desc
	local descLbl = Instance.new("TextLabel")
	descLbl.Text = desc
	descLbl.Font = Enum.Font.Gotham
	descLbl.TextSize = 11
	descLbl.TextColor3 = Colors.SubText
	descLbl.BackgroundTransparency = 1
	descLbl.Size = UDim2.new(1, -70, 0, 14)
	descLbl.Position = UDim2.new(0, 14, 0, 32)
	descLbl.TextXAlignment = Enum.TextXAlignment.Left
	descLbl.ZIndex = 4
	descLbl.Parent = card

	-- status pill
	local pill = frame(card, UDim2.new(0, 52, 0, 22), UDim2.new(0, 14, 1, -28), Colors.Off)
	corner(pill, 11)
	pill.ZIndex = 4

	local pillLabel = Instance.new("TextLabel")
	pillLabel.Text = "OFF"
	pillLabel.Font = Enum.Font.GothamBold
	pillLabel.TextSize = 10
	pillLabel.TextColor3 = Colors.SubText
	pillLabel.BackgroundTransparency = 1
	pillLabel.Size = UDim2.new(1,0,1,0)
	pillLabel.ZIndex = 5
	pillLabel.Parent = pill

	-- toggle knob track
	local track = frame(card, UDim2.new(0, 46, 0, 24), UDim2.new(1, -58, 0.5, -12), Colors.Off)
	corner(track, 12)
	track.ZIndex = 4

	local knob = frame(track, UDim2.new(0, 18, 0, 18), UDim2.new(0, 3, 0.5, -9), Color3.new(1,1,1))
	corner(knob, 9)
	knob.ZIndex = 5

	local state = false

	local function setState(val)
		state = val
		ToggleStates[flag] = val

		local targetPos = val and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		local targetTrack = val and Colors.Accent or Colors.Off
		local targetPill  = val and Colors.AccentDim or Colors.Off

		TweenService:Create(knob, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
		TweenService:Create(track, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {BackgroundColor3 = targetTrack}):Play()
		TweenService:Create(pill, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {BackgroundColor3 = targetPill}):Play()

		pillLabel.Text = val and "ON" or "OFF"
		pillLabel.TextColor3 = val and Colors.Accent or Colors.SubText

		if callback then callback(val) end
	end

	local btn = Instance.new("TextButton")
	btn.Text = ""
	btn.BackgroundTransparency = 1
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.ZIndex = 6
	btn.Parent = card

	btn.MouseButton1Click:Connect(function()
		setState(not state)
	end)

	-- hover effect
	btn.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28, 28, 38)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Card}):Play()
	end)

	return setState
end

--// Divider with label
local function divider(parent, text)
	local div = frame(parent, UDim2.new(1, 0, 0, 18), nil, Color3.fromRGB(0,0,0))
	div.BackgroundTransparency = 1
	div.ZIndex = 3

	local line = frame(div, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0.5, 0), Colors.Border)
	line.ZIndex = 3

	local lbl = Instance.new("TextLabel")
	lbl.Text = "  " .. text .. "  "
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 10
	lbl.TextColor3 = Colors.SubText
	lbl.BackgroundColor3 = Colors.BG
	lbl.BorderSizePixel = 0
	lbl.Size = UDim2.new(0, 100, 1, 0)
	lbl.Position = UDim2.new(0.5, -50, 0, 0)
	lbl.ZIndex = 4
	lbl.Parent = div
	return div
end

--// Variables
local AutoBuy     = false
local AutoUpgrade = false
local AutoFruit   = false
local Buying      = false

--// Logic (unchanged from original)
local function getButtons()
	local Buttons = {}
	if not userTycoon then return Buttons end
	for _, obj in ipairs(userTycoon.Purchases:GetDescendants()) do
		if obj:IsA("Model") then
			local shown = obj:GetAttribute("Shown")
			local purchased = obj:GetAttribute("Purchased")
			if shown == true and purchased ~= true then
				local buttonPart = obj:FindFirstChild("Button")
				if buttonPart and buttonPart:IsA("BasePart") then
					table.insert(Buttons, { Name = obj.Name, Button = buttonPart })
				end
			end
		end
	end
	return Buttons
end

local function buyButton(buttonData)
	if Buying then return end
	Buying = true
	local character = LocalPlayer.Character
	if not character then Buying = false return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then Buying = false return end
	pcall(function()
		firetouchinterest(hrp, buttonData.Button, 0)
		firetouchinterest(hrp, buttonData.Button, 1)
	end)
	Buying = false
end

task.spawn(function()
	while true do
		task.wait(0.0000001)
		if AutoBuy then
			local Buttons = getButtons()
			for _, button in ipairs(Buttons) do
				pcall(function() buyButton(button) end)
			end
		end
	end
end)

local function upgradeMachines()
	if not userTycoon then return end
	for _, obj in ipairs(userTycoon.Purchases:GetDescendants()) do
		if obj:IsA("RemoteFunction") and obj.Name == "Upgrade" then
			pcall(function()
				for level = 1, 100 do
					obj:InvokeServer(level)
				end
			end)
		end
	end
end

task.spawn(function()
	while true do
		task.wait(0.00001)
		if AutoUpgrade then
			pcall(function() upgradeMachines() end)
		end
	end
end)

local Trees = {}
local function addTree(obj)
	if obj:IsA("Model") and obj.Name == "LemonTree" then
		if not table.find(Trees, obj) then table.insert(Trees, obj) end
	end
end
local function removeTree(obj)
	local index = table.find(Trees, obj)
	if index then table.remove(Trees, index) end
end
for _, v in ipairs(workspace:GetDescendants()) do addTree(v) end
workspace.DescendantAdded:Connect(addTree)
workspace.DescendantRemoving:Connect(removeTree)

local function noCollisionTree(tree)
	for _, obj in ipairs(tree:GetDescendants()) do
		if obj:IsA("BasePart") then obj.CanCollide = false end
	end
end
local function teleportToTree(tree)
	local character = LocalPlayer.Character
	if not character then return false end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	hrp.CFrame = tree:GetPivot() + Vector3.new(0, 5, 0)
	return true
end
local function collectFruit(tree)
	noCollisionTree(tree)
	if not teleportToTree(tree) then return end
	for _, obj in ipairs(tree:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "Fruit" then
			obj.CanCollide = false
			local clickPart = obj:FindFirstChild("ClickPart")
			if clickPart then
				local detector = clickPart:FindFirstChildOfClass("ClickDetector")
				if detector then
					task.wait(0.45)
					pcall(function() fireclickdetector(detector) end)
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

--// Build Toggles in GUI
divider(ContentArea, "AUTOMATION")

createToggle(ContentArea, "Auto Buy", "Automatically purchase available tycoon items", "AutoBuy", function(val)
	AutoBuy = val
	notify("Auto Buy", val and "Feature enabled" or "Feature disabled", val and "success" or nil)
end)

createToggle(ContentArea, "Auto Upgrade", "Automatically upgrade all machines to max", "AutoUpgrade", function(val)
	AutoUpgrade = val
	notify("Auto Upgrade", val and "Feature enabled" or "Feature disabled", val and "success" or nil)
end)

createToggle(ContentArea, "Auto Fruit", "Teleports to trees and collects lemons", "AutoFruit", function(val)
	AutoFruit = val
	notify("Auto Fruit", val and "Feature enabled" or "Feature disabled", val and "success" or nil)
end)

--// Footer
local Footer = frame(innerBg, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 1, -30), Colors.Panel)
corner(Footer, 14)
Footer.ZIndex = 3

local footerFill = frame(innerBg, UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 1, -30), Colors.Panel)
footerFill.ZIndex = 3

local footerText = Instance.new("TextLabel")
footerText.Text = "made by zeroh scripts"
footerText.Font = Enum.Font.Gotham
footerText.TextSize = 11
footerText.TextColor3 = Colors.SubText
footerText.BackgroundTransparency = 1
footerText.Size = UDim2.new(1, 0, 1, 0)
footerText.ZIndex = 4
footerText.TextXAlignment = Enum.TextXAlignment.Center
footerText.Parent = Footer

local footerAccent = Instance.new("TextLabel")
footerAccent.Text = "🍋"
footerAccent.Font = Enum.Font.GothamBold
footerAccent.TextSize = 11
footerAccent.BackgroundTransparency = 1
footerAccent.Size = UDim2.new(0, 20, 1, 0)
footerAccent.Position = UDim2.new(0.5, 70, 0, 0)
footerAccent.TextXAlignment = Enum.TextXAlignment.Left
footerAccent.ZIndex = 4
footerAccent.Parent = Footer

--// Dragging
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		TweenService:Create(MainFrame, TweenInfo.new(0.05), {
			Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		}):Play()
	end
end)

--// Close / Minimize
closeBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset + 170,
				MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset + 210)
		}):Play()
		task.delay(0.3, function() ScreenGui:Destroy() end)
	end
end)

local minimized = false
minimizeBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		minimized = not minimized
		local targetSize = minimized and UDim2.new(0, 340, 0, 52) or UDim2.new(0, 340, 0, 420)
		TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
	end
end)

--// Pulse glow animation
task.spawn(function()
	while ScreenGui.Parent do
		TweenService:Create(glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			ImageTransparency = 0.75
		}):Play()
		task.wait(4)
	end
end)

--// Keybind: RightShift toggles visibility
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
		MainFrame.Visible = not MainFrame.Visible
	end
end)

--// Load notification
if not userTycoon then
	notify("Error", "Tycoon not found! Rejoin and try again.", "error")
else
	notify("Loaded", "Zeroh Autofarm ready  ·  Press RShift to hide", "success")
end
