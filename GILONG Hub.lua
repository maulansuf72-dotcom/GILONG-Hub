-- GILONG Hub - Minimal Version
-- Key: AyamGoreng!

wait(2) -- Wait for game to fully load

-- Try to load Orion with basic error handling
local OrionLib
pcall(function()
    OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
end)

-- If Orion failed to load, show error and stop
if not OrionLib then
    warn("Failed to load Orion Library!")
    return
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

-- Key System
local correctKey = "AyamGoreng!"
local keyLink = "https://link-hub.net/1392772/AfVHcFNYkLMx"

-- Copy function
local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
        return true
    end
    return false
end

-- Main Hub Function
local function loadMainHub()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    -- Variables
    local killAura = false
    local killAuraRange = 50
    local autoChopTree = false
    local chopTreeType = "All"
    local chopTreeRange = 50
    local bringItems = false
    local selectedItems = {}
    local connections = {}

    -- Item list
    local itemList = {
        "Wood", "Stone", "Berry", "Mushroom", "Water", "Meat", "Fish", "Apple",
        "Stick", "Rope", "Cloth", "Metal", "Coal", "Oil", "Bandage", "Medicine",
        "Axe", "Pickaxe", "Hammer", "Knife", "Sword", "Bow", "Arrow", "Spear"
    }

    -- Create Window
    local Window = OrionLib:MakeWindow({
        Name = "GILONG Hub",
        HidePremium = false,
        SaveConfig = false
    })

    -- Combat Tab
    local CombatTab = Window:MakeTab({
        Name = "Combat",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Kill Aura
    CombatTab:AddToggle({
        Name = "Kill Aura",
        Default = false,
        Callback = function(Value)
            killAura = Value
            if killAura then
                connections.killAura = RunService.Heartbeat:Connect(function()
                    if not killAura then return end
                    pcall(function()
                        for _, obj in pairs(Workspace:GetChildren()) do
                            if obj:FindFirstChild("Humanoid") and obj ~= character then
                                local enemyRoot = obj:FindFirstChild("HumanoidRootPart")
                                if enemyRoot then
                                    local distance = (rootPart.Position - enemyRoot.Position).Magnitude
                                    if distance <= killAuraRange then
                                        local attackRemote = ReplicatedStorage:FindFirstChild("Attack")
                                        if attackRemote then
                                            attackRemote:FireServer(obj)
                                        end
                                        wait(0.1)
                                        break
                                    end
                                end
                            end
                        end
                    end)
                end)
            else
                if connections.killAura then
                    connections.killAura:Disconnect()
                end
            end
        end
    })

    -- Kill Aura Range
    CombatTab:AddSlider({
        Name = "Kill Aura Range",
        Min = 1,
        Max = 500,
        Default = 50,
        Increment = 1,
        Callback = function(Value)
            killAuraRange = Value
        end
    })

    -- Farming Tab
    local FarmingTab = Window:MakeTab({
        Name = "Farming",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Auto Chop Tree
    FarmingTab:AddToggle({
        Name = "Auto Chop Tree",
        Default = false,
        Callback = function(Value)
            autoChopTree = Value
            if autoChopTree then
                connections.autoChopTree = RunService.Heartbeat:Connect(function()
                    if not autoChopTree then return end
                    pcall(function()
                        for _, obj in pairs(Workspace:GetChildren()) do
                            if obj.Name:lower():find("tree") and obj:FindFirstChild("Part") then
                                local treePart = obj:FindFirstChild("Part")
                                local distance = (rootPart.Position - treePart.Position).Magnitude
                                if distance <= chopTreeRange then
                                    local chopRemote = ReplicatedStorage:FindFirstChild("ChopTree")
                                    if chopRemote then
                                        chopRemote:FireServer(obj)
                                    end
                                    wait(0.2)
                                    break
                                end
                            end
                        end
                    end)
                end)
            else
                if connections.autoChopTree then
                    connections.autoChopTree:Disconnect()
                end
            end
        end
    })

    -- Chop Tree Range
    FarmingTab:AddSlider({
        Name = "Chop Tree Range",
        Min = 1,
        Max = 500,
        Default = 50,
        Increment = 1,
        Callback = function(Value)
            chopTreeRange = Value
        end
    })

    -- Items Tab
    local ItemsTab = Window:MakeTab({
        Name = "Items",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Bring Items
    ItemsTab:AddToggle({
        Name = "Bring Items",
        Default = false,
        Callback = function(Value)
            bringItems = Value
            if bringItems then
                connections.bringItems = RunService.Heartbeat:Connect(function()
                    if not bringItems then return end
                    pcall(function()
                        for _, itemName in pairs(selectedItems) do
                            for _, obj in pairs(Workspace:GetChildren()) do
                                if obj.Name:lower():find(itemName:lower()) and obj:FindFirstChild("Part") then
                                    local itemPart = obj:FindFirstChild("Part")
                                    itemPart.CFrame = rootPart.CFrame * CFrame.new(0, 2, 0)
                                    wait(0.05)
                                end
                            end
                        end
                    end)
                end)
            else
                if connections.bringItems then
                    connections.bringItems:Disconnect()
                end
            end
        end
    })

    -- Item Selection
    ItemsTab:AddDropdown({
        Name = "Select Items",
        Default = "Wood",
        Options = itemList,
        Callback = function(Value)
            if not table.find(selectedItems, Value) then
                table.insert(selectedItems, Value)
            end
        end
    })

    -- Clear Items
    ItemsTab:AddButton({
        Name = "Clear Selected Items",
        Callback = function()
            selectedItems = {}
        end
    })

    -- Player Tab
    local PlayerTab = Window:MakeTab({
        Name = "Player",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Walk Speed
    PlayerTab:AddSlider({
        Name = "Walk Speed",
        Min = 16,
        Max = 200,
        Default = 16,
        Increment = 1,
        Callback = function(Value)
            humanoid.WalkSpeed = Value
        end
    })

    -- Jump Power
    PlayerTab:AddSlider({
        Name = "Jump Power",
        Min = 50,
        Max = 300,
        Default = 50,
        Increment = 1,
        Callback = function(Value)
            humanoid.JumpPower = Value
        end
    })

    -- Misc Tab
    local MiscTab = Window:MakeTab({
        Name = "Misc",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Rejoin
    MiscTab:AddButton({
        Name = "Rejoin Server",
        Callback = function()
            TeleportService:Teleport(game.PlaceId, player)
        end
    })

    OrionLib:Init()
end

-- Key Window
local KeyWindow = OrionLib:MakeWindow({
    Name = "GILONG Hub - Key System",
    HidePremium = false,
    SaveConfig = false
})

local KeyTab = KeyWindow:MakeTab({
    Name = "Key System",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Key Input
KeyTab:AddTextbox({
    Name = "Enter Key",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        if Value == correctKey then
            KeyWindow:Destroy()
            loadMainHub()
        end
    end
})

-- Get Key Button
KeyTab:AddButton({
    Name = "Get Key",
    Callback = function()
        if copyToClipboard(keyLink) then
            print("Key link copied!")
        else
            print("Link: " .. keyLink)
        end
    end
})

OrionLib:Init()
