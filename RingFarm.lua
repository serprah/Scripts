local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

_G.AutoPickupCrates = false
_G.GlobalAutoSell = false
_G.AutoBuy = false
_G.PlantMonsterFarm = false
_G.AutoHoney = false
_G.AutoUpgradePlant = false
_G.InfJump = false

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

localPlayer.CharacterAdded:Connect(function(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
end)

local Window = Rayfield:CreateWindow({
    Name = "CratesFarm",
    Icon = 0,
    LoadingTitle = "CratesFarm",
    LoadingSubtitle = "Loading...",
    ShowText = "CratesFarm",
    Theme = "Default",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "CratesFarm"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
})

task.spawn(function()
    while true do
        if _G.AutoPickupCrates then
            pcall(function()
                for _, object in ipairs(workspace:GetDescendants()) do
                    if object:IsA("ProximityPrompt") and object.Name == "CratesPickupPrompt" then
                        fireproximityprompt(object)
                    end
                end
            end)
        end
        task.wait(10)
    end
end)

task.spawn(function()
    while true do
        if _G.GlobalAutoSell then
            pcall(function()
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and v.Name == "SellCrates" then
                        fireproximityprompt(v)
                    end
                end
            end)
        end
        task.wait(10)
    end
end)

local items = {
    "Normal Pet Treat",
    "Normal Fertilizer",
    "Frozen Spray",
    "Autumn Spray",
    "Void Spray",
    "Super Fertilizer",
    "Radioactive Spray",
    "Strong Pet Treat",	
	"Strong Fertilizer",
    "Super Pet Treat",
    "Rainbow Spray",
    "Prismatic Fertilizer",
    "Cosmic Spray",
    "Bubblegum Spray",
    "Fire Spray",	
}

local TransactionEvent
pcall(function()
    TransactionEvent = ReplicatedStorage:WaitForChild("Remotes", 10):WaitForChild("Gear", 10):WaitForChild("Transaction", 10)
end)

local function getHoneyPrompt(honeycomb)
    local honeyPart = honeycomb:FindFirstChild("Honeycomb")
    if not honeyPart then return nil, nil end

    local prompt = honeyPart:FindFirstChild("CollectPrompt")
    if prompt and prompt:IsA("ProximityPrompt") then
        return honeyPart, prompt
    end

    return nil, nil
end

task.spawn(function()
    while true do
        if _G.AutoHoney then
            pcall(function()
                local folder = workspace.InteractiveEvents.QueenBee.RuntimeHoneycombs

                for _, honeycomb in ipairs(folder:GetChildren()) do
                    if not _G.AutoHoney then break end
                    if not honeycomb:IsDescendantOf(workspace) then continue end

                    local honeyPart, prompt = getHoneyPrompt(honeycomb)

                    if honeyPart and prompt then
                        while _G.AutoHoney
                            and honeycomb:IsDescendantOf(workspace)
                            and honeyPart:IsDescendantOf(workspace)
                            and prompt:IsDescendantOf(workspace) do

                            character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                            rootPart = character:WaitForChild("HumanoidRootPart")

                            rootPart.CFrame = honeyPart.CFrame * CFrame.new(0, 2, 0)

                            task.wait(0.25)

                            if prompt.Enabled then
                                fireproximityprompt(prompt, prompt.HoldDuration or 0)
                            end

                            task.wait(0.75)
                        end
                    end
                end
            end)
        end

        task.wait(0.2)
    end
end)

local runtimeFolder = workspace:WaitForChild("InteractiveEvents"):WaitForChild("PlantRush"):WaitForChild("Runtime")

local function setCharacterPhysics(char, shouldAnchor)
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.Anchored = shouldAnchor
        if shouldAnchor then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

local function lockAndTeleportToTarget(target)
    if not _G.PlantMonsterFarm then return end
    local monster = target:FindFirstChild("Monster_02") or target
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    setCharacterPhysics(char, true)
    while _G.PlantMonsterFarm and target and target:IsDescendantOf(workspace) and monster:IsDescendantOf(workspace) do
        char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        char:PivotTo(monster:GetPivot() * CFrame.new(0, 3, 0))
        task.wait(0.1)
    end
    if char then
        setCharacterPhysics(char, false)
    end
end

runtimeFolder.ChildAdded:Connect(function(newChild)
    if _G.PlantMonsterFarm then
        task.spawn(function()
            lockAndTeleportToTarget(newChild)
        end)
    end
end)

task.spawn(function()
    while true do
        if _G.PlantMonsterFarm then
            local targets = runtimeFolder:GetChildren()
            if #targets > 0 then
                for _, child in ipairs(targets) do
                    if not _G.PlantMonsterFarm then break end
                    lockAndTeleportToTarget(child)
                end
            else
                if localPlayer.Character then
                    setCharacterPhysics(localPlayer.Character, false)
                end
            end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if _G.AutoHoney then
            pcall(function()
                local honeycombs = workspace.InteractiveEvents.QueenBee.RuntimeHoneycombs:GetChildren()
                for _, honeycomb in ipairs(honeycombs) do
                    local prompt = honeycomb:FindFirstChild("Honeycomb") and honeycomb.Honeycomb:FindFirstChild("CollectPrompt")
                    if prompt and prompt:IsA("ProximityPrompt") then
                        local promptPart = prompt.Parent
                        if promptPart and promptPart:IsA("BasePart") and rootPart and rootPart.Parent then
                            rootPart.CFrame = promptPart.CFrame + Vector3.new(0, 3, 0)
                            fireproximityprompt(prompt)
                            task.wait(0.2)
                        end
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

local UpgradePlantEvent
pcall(function()
    UpgradePlantEvent = ReplicatedStorage:WaitForChild("Remotes", 10):WaitForChild("UpgradePlant", 10)
end)

task.spawn(function()
    while true do
        if _G.AutoUpgradePlant then
            local plots = workspace.Map.Plots:GetChildren()
            for _, plot in ipairs(plots) do
                if not _G.AutoUpgradePlant then break end
                local farmPlot = plot:FindFirstChild("FarmPlot")
                if farmPlot then
                    for _, child in ipairs(farmPlot:GetChildren()) do
                        if not _G.AutoUpgradePlant then break end
                        if child:IsA("Model") then
                            local dirt = child:FindFirstChild("Dirt")
                            if dirt then
                                pcall(function()
                                    UpgradePlantEvent:InvokeServer(dirt)
                                end)
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end
        end
        task.wait(1)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateSection("Crates")
MainTab:CreateToggle({
    Name = "Auto Pickup Crates",
    CurrentValue = false,
    Flag = "AutoPickupCrates",
    Callback = function(value)
        _G.AutoPickupCrates = value
    end,
})
MainTab:CreateToggle({
    Name = "Auto Sell Crates",
    CurrentValue = false,
    Flag = "GlobalAutoSell",
    Callback = function(value)
        _G.GlobalAutoSell = value
    end,
})
MainTab:CreateSection("Info")
MainTab:CreateLabel("Toggle UI: K")

local BuyTab = Window:CreateTab("Auto Buy", 4483362458)

BuyTab:CreateSection("Auto Buy")
BuyTab:CreateToggle({
    Name = "Auto Buy Items",
    CurrentValue = false,
    Flag = "AutoBuy",
    Callback = function(value)
        _G.AutoBuy = value
    end,
})
BuyTab:CreateSection("Items")
for _, item in ipairs(items) do
    BuyTab:CreateLabel(item)
end

local PlantTab = Window:CreateTab("Plant Monster", 4483362458)

PlantTab:CreateSection("Plant Monster Autofarm")
PlantTab:CreateToggle({
    Name = "Auto Farm Plant Monsters",
    CurrentValue = false,
    Flag = "PlantMonsterFarm",
    Callback = function(value)
        _G.PlantMonsterFarm = value
        if not value and localPlayer.Character then
            setCharacterPhysics(localPlayer.Character, false)
        end
    end,
})
PlantTab:CreateSection("Info")

local HoneyTab = Window:CreateTab("Honey", 4483362458)

HoneyTab:CreateSection("Queen Bee Honeycomb")
HoneyTab:CreateToggle({
    Name = "Auto Collect Honeycombs",
    CurrentValue = false,
    Flag = "AutoHoney",
    Callback = function(value)
        _G.AutoHoney = value
    end,
})
HoneyTab:CreateSection("Info")

local UpgradePlantTab = Window:CreateTab("Upgrade Plants", 4483362458)

UpgradePlantTab:CreateSection("Auto Upgrade Plants")
UpgradePlantTab:CreateToggle({
    Name = "Auto Upgrade All Plants",
    CurrentValue = false,
    Flag = "AutoUpgradePlant",
    Callback = function(value)
        _G.AutoUpgradePlant = value
    end,
})
UpgradePlantTab:CreateSection("Info")

local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateSection("Walk Speed")
PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(value)
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end,
})
PlayerTab:CreateSection("Jump")
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(value)
        _G.InfJump = value
    end,
})

Rayfield:Notify({
    Title = "CratesFarm",
    Content = "Loaded successfully! Toggle K to open/close.",
    Duration = 5,
    Image = 4483362458,
})
