-- 99 Nights in the Forest - Complete Voidware Script
-- All-in-One Script - Just Copy & Paste

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "GILONG Hub",
   LoadingTitle = "99 Nights in the Forest",
   LoadingSubtitle = "GILONG Hub All Features",
   KeySystem = false
})

local mainTab = Window:CreateTab("Main", nil)
local combatTab = Window:CreateTab("Combat", nil)
local voidwareTab = Window:CreateTab("Voidware", nil)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Globals
_G.killAura = false
_G.killAuraRange = 20
_G.bringItems = false
_G.bringRange = 50
_G.autoFeedFire = false
_G.autoCollect = false
_G.speedHack = false
_G.speedValue = 50
_G.freezeEntities = false
_G.esp = false
_G.fullbright = false

-- Utility Functions
local function teleportTo(pos)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function findNearest(name, range)
    local nearest = nil
    local distance = range or math.huge
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return nil end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find(name:lower()) then
            local pos = obj:IsA("BasePart") and obj.Position or (obj:FindFirstChild("HumanoidRootPart") and obj.HumanoidRootPart.Position)
            if pos then
                local dist = (player.Character.HumanoidRootPart.Position - pos).Magnitude
                if dist < distance then
                    distance = dist
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

-- Kill Aura
local function killAura()
    if not _G.killAura then return end
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local enemies = {"Deer", "Wolf", "Bear", "Cultist", "Alien", "Mammoth"}
    
    for _, enemyName in pairs(enemies) do
        for _, enemy in pairs(Workspace:GetDescendants()) do
            if enemy.Name:lower():find(enemyName:lower()) and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                local distance = (char.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                if distance <= _G.killAuraRange and enemy.Humanoid.Health > 0 then
                    -- Attack methods
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                    
                    -- Remote events
                    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") then
                            local name = remote.Name:lower()
                            if name:find("attack") or name:find("damage") or name:find("hit") then
                                pcall(function() remote:FireServer(enemy) end)
                            end
                        end
                    end
                    
                    -- Key presses
                    UserInputService:SimulateKeyPress(Enum.KeyCode.E)
                    UserInputService:SimulateKeyPress(Enum.KeyCode.F)
                end
            end
        end
    end
end

-- Bring Items
local function bringItems()
    if not _G.bringItems then return end
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local items = {"Gun", "Rifle", "Food", "Medkit", "Ammo", "Wood", "Stone", "Key", "Fuel", "Armor"}
    
    for _, itemName in pairs(items) do
        for _, item in pairs(Workspace:GetDescendants()) do
            if item.Name:lower():find(itemName:lower()) and item:IsA("BasePart") then
                local distance = (char.HumanoidRootPart.Position - item.Position).Magnitude
                if distance <= _G.bringRange then
                    item.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
                    item.CanCollide = false
                    if item:FindFirstChild("ClickDetector") then
                        fireclickdetector(item.ClickDetector)
                    elseif item:FindFirstChild("ProximityPrompt") then
                        fireproximityprompt(item.ProximityPrompt)
                    end
                end
            end
        end
    end
end

-- Auto Feed Campfire
local function autoFeedCampfire()
    if not _G.autoFeedFire then return end
    local campfire = findNearest("campfire", 100)
    local wood = findNearest("wood", 200)
    
    if campfire and wood then
        teleportTo(wood.Position)
        wait(0.3)
        if wood:FindFirstChild("ProximityPrompt") then
            fireproximityprompt(wood.ProximityPrompt)
        elseif wood:FindFirstChild("ClickDetector") then
            fireclickdetector(wood.ClickDetector)
        end
        wait(0.5)
        teleportTo(campfire.Position)
        wait(0.3)
        if campfire:FindFirstChild("ProximityPrompt") then
            fireproximityprompt(campfire.ProximityPrompt)
        end
    end
end

-- Auto Collect Resources
local function autoCollect()
    if not _G.autoCollect then return end
    local resources = {"Wood", "Stone", "Berry", "Branch", "Log", "Food"}
    
    for _, resourceName in pairs(resources) do
        local resource = findNearest(resourceName, 150)
        if resource then
            teleportTo(resource.Position)
            wait(0.2)
            if resource:FindFirstChild("ClickDetector") then
                fireclickdetector(resource.ClickDetector)
            elseif resource:FindFirstChild("ProximityPrompt") then
                fireproximityprompt(resource.ProximityPrompt)
            end
        end
    end
end

-- Speed Hack
local function speedHack()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = _G.speedHack and _G.speedValue or 16
    end
end

-- Freeze Entities
local function freezeEntities()
    local entities = {"Deer", "Wolf", "Bear", "Cultist", "Alien"}
    for _, entityName in pairs(entities) do
        for _, entity in pairs(Workspace:GetDescendants()) do
            if entity.Name:lower():find(entityName:lower()) and entity:FindFirstChild("HumanoidRootPart") then
                entity.HumanoidRootPart.Anchored = _G.freezeEntities
                if _G.freezeEntities then
                    entity.HumanoidRootPart.BrickColor = BrickColor.new("Bright blue")
                else
                    entity.HumanoidRootPart.BrickColor = BrickColor.new("Medium stone grey")
                end
            end
        end
    end
end

-- ESP
local function createESP()
    if not _G.esp then return end
    
    -- Enemy ESP
    local enemies = {"Deer", "Wolf", "Bear", "Cultist"}
    for _, enemyName in pairs(enemies) do
        for _, enemy in pairs(Workspace:GetDescendants()) do
            if enemy.Name:lower():find(enemyName:lower()) and enemy:FindFirstChild("HumanoidRootPart") then
                local part = enemy.HumanoidRootPart
                if not part:FindFirstChild("ESP_Highlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ESP_Highlight"
                    highlight.Parent = part
                    highlight.FillColor = Color3.new(1, 0, 0)
                    highlight.FillTransparency = 0.5
                    
                    local gui = Instance.new("BillboardGui")
                    gui.Name = "ESP_Label"
                    gui.Parent = part
                    gui.Size = UDim2.new(0, 100, 0, 30)
                    gui.StudsOffset = Vector3.new(0, 3, 0)
                    gui.AlwaysOnTop = true
                    
                    local label = Instance.new("TextLabel")
                    label.Parent = gui
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = enemyName:upper()
                    label.TextColor3 = Color3.new(1, 0, 0)
                    label.TextScaled = true
                    label.Font = Enum.Font.GothamBold
                end
            end
        end
    end
    
    -- Item ESP
    local items = {"Gun", "Rifle", "Food", "Medkit", "Ammo"}
    for _, itemName in pairs(items) do
        for _, item in pairs(Workspace:GetDescendants()) do
            if item.Name:lower():find(itemName:lower()) and item:IsA("BasePart") then
                if not item:FindFirstChild("ESP_Highlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ESP_Highlight"
                    highlight.Parent = item
                    highlight.FillColor = Color3.new(1, 1, 0)
                    highlight.FillTransparency = 0.5
                end
            end
        end
    end
end

-- Remove ESP
local function removeESP()
    for _, obj in pairs(Workspace:GetDescendants()) do
        local highlight = obj:FindFirstChild("ESP_Highlight")
        local label = obj:FindFirstChild("ESP_Label")
        if highlight then highlight:Destroy() end
        if label then label:Destroy() end
    end
end

-- Fullbright
local function fullbright()
    local lighting = game:GetService("Lighting")
    if _G.fullbright then
        lighting.FogEnd = 100000
        lighting.FogStart = 0
        lighting.Brightness = 2
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        lighting.FogEnd = 500
        lighting.FogStart = 100
        lighting.Brightness = 1
        lighting.Ambient = Color3.fromRGB(70, 70, 70)
    end
end

-- Teleport All Trees
local function teleportAllTrees()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local trees = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("tree") and obj:IsA("BasePart") then
            table.insert(trees, obj)
        end
    end
    
    for i, tree in pairs(trees) do
        local offset = Vector3.new((i % 10) * 5, 0, math.floor(i / 10) * 5)
        tree.CFrame = CFrame.new(char.HumanoidRootPart.Position + offset + Vector3.new(0, 2, 0))
        tree.CanCollide = false
    end
    
    Rayfield:Notify({Title = "Success!", Content = "Brought " .. #trees .. " trees", Duration = 3})
end

-- Main Loop
local function mainLoop()
    _G.mainConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            killAura()
            bringItems()
            autoFeedCampfire()
            autoCollect()
            speedHack()
            if _G.esp then createESP() end
            if _G.freezeEntities then freezeEntities() end
        end)
    end)
end

-- GUI Elements

-- Main Tab
mainTab:CreateToggle({
   Name = "Auto Feed Campfire",
   CurrentValue = false,
   Callback = function(Value) _G.autoFeedFire = Value end,
})

mainTab:CreateToggle({
   Name = "Auto Collect Resources",
   CurrentValue = false,
   Callback = function(Value) _G.autoCollect = Value end,
})

mainTab:CreateToggle({
   Name = "ESP (Enemies & Items)",
   CurrentValue = false,
   Callback = function(Value) 
       _G.esp = Value 
       if not Value then removeESP() end
   end,
})

mainTab:CreateToggle({
   Name = "Fullbright",
   CurrentValue = false,
   Callback = function(Value) 
       _G.fullbright = Value 
       fullbright()
   end,
})

mainTab:CreateButton({
   Name = "Teleport to Spawn",
   Callback = function()
       teleportTo(Vector3.new(0, 5, 0))
   end,
})

-- Combat Tab
combatTab:CreateToggle({
   Name = "Kill Aura",
   CurrentValue = false,
   Callback = function(Value) _G.killAura = Value end,
})

combatTab:CreateSlider({
    Name = "Kill Aura Range",
    Range = {5, 100},
    Increment = 5,
    CurrentValue = 20,
    Callback = function(Value) _G.killAuraRange = Value end,
})

combatTab:CreateToggle({
   Name = "Freeze Entities",
   CurrentValue = false,
   Callback = function(Value) 
       _G.freezeEntities = Value 
       freezeEntities()
   end,
})

-- Voidware Tab
voidwareTab:CreateToggle({
   Name = "Bring Items",
   CurrentValue = false,
   Callback = function(Value) _G.bringItems = Value end,
})

voidwareTab:CreateSlider({
    Name = "Bring Range",
    Range = {10, 200},
    Increment = 10,
    CurrentValue = 50,
    Callback = function(Value) _G.bringRange = Value end,
})

voidwareTab:CreateToggle({
   Name = "Speed Hack",
   CurrentValue = false,
   Callback = function(Value) _G.speedHack = Value end,
})

voidwareTab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 200},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(Value) _G.speedValue = Value end,
})

voidwareTab:CreateButton({
   Name = "Teleport All Trees",
   Callback = function() teleportAllTrees() end,
})

voidwareTab:CreateButton({
   Name = "Find Lost Children",
   Callback = function()
       local child = findNearest("child", 1000)
       if child then
           local pos = child:IsA("BasePart") and child.Position or child.HumanoidRootPart.Position
           teleportTo(pos)
           Rayfield:Notify({Title = "Found!", Content = "Teleported to lost child", Duration = 3})
       else
           Rayfield:Notify({Title = "Not Found", Content = "No children found", Duration = 3})
       end
   end,
})

-- Anti-AFK
voidwareTab:CreateToggle({
   Name = "Anti-AFK",
   CurrentValue = false,
   Callback = function(Value)
       if Value then
           _G.afkConnection = RunService.Heartbeat:Connect(function()
               game:GetService("VirtualUser"):CaptureController()
               game:GetService("VirtualUser"):ClickButton2(Vector2.new())
           end)
       else
           if _G.afkConnection then _G.afkConnection:Disconnect() end
       end
   end,
})

-- Start everything
mainLoop()

Rayfield:Notify({
   Title = "GILONG Hub Loaded!",
   Content = "All features ready - 99 Nights Forest",
   Duration = 5,
})
