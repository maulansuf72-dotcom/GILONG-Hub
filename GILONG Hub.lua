-- GILONG Hub Script untuk 99 Night in the Forest
-- Menggunakan Orion Library untuk GUI
-- Key System: AyamGoreng!
-- Version: Final Release

-- Load Orion Library with error handling
local OrionLib
local success, result = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
end)

if success then
    OrionLib = result
else
    -- Fallback to alternative Orion source
    OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/ionlyusegithubformcmods/1-Line-Scripts/main/Orion%20Lib'))()
end

-- Key System Variables
local keyCorrect = false
local correctKey = "AyamGoreng!"
local keyLink = "https://link-hub.net/1392772/AfVHcFNYkLMx"

-- Global Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- Function untuk copy link ke clipboard
local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
        return true
    elseif syn and syn.write_clipboard then
        syn.write_clipboard(text)
        return true
    elseif Clipboard and Clipboard.set then
        Clipboard.set(text)
        return true
    end
    return false
end

-- Function untuk safe wait
local function safeWait(duration)
    local startTime = tick()
    while tick() - startTime < duration do
        RunService.Heartbeat:Wait()
    end
end

-- Function untuk load main hub
local function loadMainHub()
    -- Wait for character to load properly
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    local rootPart = character:WaitForChild("HumanoidRootPart", 10)
    
    if not humanoid or not rootPart then
        OrionLib:MakeNotification({
            Name = "GILONG Hub",
            Content = "Failed to load character! Please rejoin.",
            Image = "rbxassetid://79608248053265",
            Time = 5
        })
        return
    end

    -- Variables untuk features
    local killAura = false
    local killAuraRange = 50
    local autoChopTree = false
    local chopTreeType = "All"
    local chopTreeRange = 50
    local bringItems = false
    local selectedItems = {}
    local lagProtection = true
    local walkSpeed = humanoid.WalkSpeed or 16
    local jumpPower = humanoid.JumpPower or 50
    local noclip = false
    local godMode = false
    local infiniteStamina = false
    local nightVision = false

    -- Connection storage for cleanup
    local connections = {}

    -- Item list untuk 99 Night in the Forest
    local itemList = {
        "Wood", "Stone", "Berry", "Mushroom", "Water", "Meat", "Fish", "Apple",
        "Stick", "Rope", "Cloth", "Metal", "Coal", "Oil", "Bandage", "Medicine",
        "Axe", "Pickaxe", "Hammer", "Knife", "Sword", "Bow", "Arrow", "Spear",
        "Torch", "Lantern", "Campfire", "Tent", "Sleeping Bag", "Backpack",
        "Bottle", "Can", "Box", "Chest", "Key", "Map", "Compass", "Watch",
        "Battery", "Flashlight", "Radio", "Phone", "Camera", "Binoculars"
    }

    -- Tree types
    local treeTypes = {"All", "Small", "Big", "Snowy"}

    -- Membuat Window utama
    local Window = OrionLib:MakeWindow({
        Name = "GILONG Hub", 
        HidePremium = false, 
        SaveConfig = true, 
        ConfigFolder = "GILONGHub99Night",
        IntroEnabled = true,
        IntroText = "GILONG Hub - 99 Night in the Forest",
        IntroIcon = "rbxassetid://79608248053265"
    })

    -- Tab Combat
    local CombatTab = Window:MakeTab({
        Name = "Combat",
        Icon = "rbxassetid://79608248053265",
        PremiumOnly = false
    })

    -- Kill Aura Toggle
    CombatTab:AddToggle({
        Name = "Kill Aura",
        Default = false,
        Callback = function(Value)
            killAura = Value
            if killAura then
                connections.killAura = RunService.Heartbeat:Connect(function()
                    if not killAura then return end
                    
                    pcall(function()
                        if not character or not character.Parent or not rootPart or not rootPart.Parent then
                            character = player.Character
                            if character then
                                rootPart = character:FindFirstChild("HumanoidRootPart")
                            end
                            return
                        end
                        
                        -- Find enemies/monsters in range
                        for _, obj in pairs(Workspace:GetChildren()) do
                            if obj:FindFirstChild("Humanoid") and obj ~= character and obj.Name ~= player.Name then
                                local enemyRoot = obj:FindFirstChild("HumanoidRootPart")
                                local enemyHumanoid = obj:FindFirstChild("Humanoid")
                                
                                if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
                                    local distance = (rootPart.Position - enemyRoot.Position).Magnitude
                                    if distance <= killAuraRange then
                                        -- Attack enemy using different methods
                                        local attackRemote = ReplicatedStorage:FindFirstChild("Attack") or 
                                                            ReplicatedStorage:FindFirstChild("Combat") or
                                                            ReplicatedStorage:FindFirstChild("Hit") or
                                                            ReplicatedStorage:FindFirstChild("Damage")
                                        if attackRemote and attackRemote:IsA("RemoteEvent") then
                                            attackRemote:FireServer(obj)
                                        elseif attackRemote and attackRemote:IsA("RemoteFunction") then
                                            attackRemote:InvokeServer(obj)
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
                    connections.killAura = nil
                end
            end
        end    
    })

    -- Kill Aura Range Slider
    CombatTab:AddSlider({
        Name = "Kill Aura Range",
        Min = 1,
        Max = 500,
        Default = 50,
        Color = Color3.fromRGB(255,0,0),
        Increment = 1,
        ValueName = "Range",
        Callback = function(Value)
            killAuraRange = Value
        end    
    })

    -- Tab Farming
    local FarmingTab = Window:MakeTab({
        Name = "Farming",
        Icon = "rbxassetid://79608248053265",
        PremiumOnly = false
    })

    -- Auto Chop Tree Toggle
    FarmingTab:AddToggle({
        Name = "Auto Chop Tree",
        Default = false,
        Callback = function(Value)
            autoChopTree = Value
            if autoChopTree then
                connections.autoChopTree = RunService.Heartbeat:Connect(function()
                    if not autoChopTree then return end
                    
                    pcall(function()
                        if not character or not character.Parent or not rootPart or not rootPart.Parent then
                            character = player.Character
                            if character then
                                rootPart = character:FindFirstChild("HumanoidRootPart")
                            end
                            return
                        end
                        
                        -- Find trees in range
                        local function searchInFolder(folder)
                            for _, obj in pairs(folder:GetChildren()) do
                                local isValidTree = false
                                local treeName = obj.Name:lower()
                                
                                -- Check tree type with more patterns
                                if chopTreeType == "All" then
                                    isValidTree = treeName:find("tree") or treeName:find("wood") or treeName:find("log") or 
                                                 treeName:find("oak") or treeName:find("pine") or treeName:find("birch")
                                elseif chopTreeType == "Small" then
                                    isValidTree = (treeName:find("small") or treeName:find("little")) and 
                                                 (treeName:find("tree") or treeName:find("wood"))
                                elseif chopTreeType == "Big" then
                                    isValidTree = (treeName:find("big") or treeName:find("large") or treeName:find("huge")) and 
                                                 (treeName:find("tree") or treeName:find("wood"))
                                elseif chopTreeType == "Snowy" then
                                    isValidTree = (treeName:find("snowy") or treeName:find("snow") or treeName:find("winter")) and 
                                                 (treeName:find("tree") or treeName:find("wood"))
                                end
                                
                                if isValidTree then
                                    local treePart = obj:FindFirstChild("Part") or obj:FindFirstChild("Trunk") or 
                                                    obj:FindFirstChild("Base") or obj.PrimaryPart
                                    if treePart then
                                        local distance = (rootPart.Position - treePart.Position).Magnitude
                                        if distance <= chopTreeRange then
                                            -- Chop tree using different methods
                                            local chopRemote = ReplicatedStorage:FindFirstChild("ChopTree") or 
                                                             ReplicatedStorage:FindFirstChild("Chop") or
                                                             ReplicatedStorage:FindFirstChild("Cut") or
                                                             ReplicatedStorage:FindFirstChild("HarvestTree")
                                            if chopRemote and chopRemote:IsA("RemoteEvent") then
                                                chopRemote:FireServer(obj)
                                            elseif chopRemote and chopRemote:IsA("RemoteFunction") then
                                                chopRemote:InvokeServer(obj)
                                            end
                                            wait(0.2)
                                            return true
                                        end
                                    end
                                end
                                
                                -- Search in subfolders
                                if obj:IsA("Folder") or obj:IsA("Model") then
                                    if searchInFolder(obj) then
                                        return true
                                    end
                                end
                            end
                            return false
                        end
                        
                        searchInFolder(Workspace)
                    end)
                end)
            else
                if connections.autoChopTree then
                    connections.autoChopTree:Disconnect()
                    connections.autoChopTree = nil
                end
            end
        end    
    })

    -- Tree Type Dropdown
    FarmingTab:AddDropdown({
        Name = "Tree Type",
        Default = "All",
        Options = treeTypes,
        Callback = function(Value)
            chopTreeType = Value
        end    
    })

    -- Chop Tree Range Slider
    FarmingTab:AddSlider({
        Name = "Chop Tree Range",
        Min = 1,
        Max = 500,
        Default = 50,
        Color = Color3.fromRGB(0,255,0),
        Increment = 1,
        ValueName = "Range",
        Callback = function(Value)
            chopTreeRange = Value
        end    
    })

    -- Tab Items
    local ItemsTab = Window:MakeTab({
        Name = "Items",
        Icon = "rbxassetid://79608248053265",
        PremiumOnly = false
    })

    -- Bring Items Toggle
    ItemsTab:AddToggle({
        Name = "Bring Items",
        Default = false,
        Callback = function(Value)
            bringItems = Value
            if bringItems then
                connections.bringItems = RunService.Heartbeat:Connect(function()
                    if not bringItems then return end
                    
                    pcall(function()
                        if not character or not character.Parent or not rootPart or not rootPart.Parent then
                            character = player.Character
                            if character then
                                rootPart = character:FindFirstChild("HumanoidRootPart")
                            end
                            return
                        end
                        
                        -- Check for lag protection
                        if lagProtection then
                            local fps = 1 / RunService.Heartbeat:Wait()
                            if fps < 30 then -- If FPS drops below 30
                                bringItems = false
                                OrionLib:MakeNotification({
                                    Name = "GILONG Hub",
                                    Content = "Bring Items disabled due to lag protection!",
                                    Image = "rbxassetid://79608248053265",
                                    Time = 3
                                })
                                return
                            end
                        end
                        
                        -- Bring selected items
                        local function searchForItems(folder)
                            for _, obj in pairs(folder:GetChildren()) do
                                for _, itemName in pairs(selectedItems) do
                                    if obj.Name:lower():find(itemName:lower()) then
                                        local itemPart = obj:FindFirstChild("Part") or obj:FindFirstChild("Handle") or 
                                                        obj:FindFirstChild("Base") or obj.PrimaryPart
                                        if itemPart and itemPart:IsA("BasePart") then
                                            -- Safe teleport with collision check
                                            local targetPos = rootPart.CFrame * CFrame.new(math.random(-3,3), 2, math.random(-3,3))
                                            itemPart.CFrame = targetPos
                                            itemPart.Velocity = Vector3.new(0, 0, 0)
                                            itemPart.AngularVelocity = Vector3.new(0, 0, 0)
                                            wait(0.05)
                                        end
                                    end
                                end
                                
                                -- Search in subfolders
                                if obj:IsA("Folder") or obj:IsA("Model") then
                                    searchForItems(obj)
                                end
                            end
                        end
                        
                        searchForItems(Workspace)
                    end)
                end)
            else
                if connections.bringItems then
                    connections.bringItems:Disconnect()
                    connections.bringItems = nil
                end
            end
        end    
    })

    -- Item Selection Dropdown
    ItemsTab:AddDropdown({
        Name = "Select Items to Bring",
        Default = "Wood",
        Options = itemList,
        Callback = function(Value)
            if not table.find(selectedItems, Value) then
                table.insert(selectedItems, Value)
                OrionLib:MakeNotification({
                    Name = "GILONG Hub",
                    Content = Value .. " added to bring list!",
                    Image = "rbxassetid://79608248053265",
                    Time = 2
                })
            end
        end    
    })

    -- Clear Selected Items Button
    ItemsTab:AddButton({
        Name = "Clear Selected Items",
        Callback = function()
            selectedItems = {}
            OrionLib:MakeNotification({
                Name = "GILONG Hub",
                Content = "Selected items cleared!",
                Image = "rbxassetid://79608248053265",
                Time = 2
            })
        end    
    })

    -- Lag Protection Toggle
    ItemsTab:AddToggle({
        Name = "Lag Protection",
        Default = true,
        Callback = function(Value)
            lagProtection = Value
        end    
    })

    -- Tab Player
    local PlayerTab = Window:MakeTab({
        Name = "Player",
        Icon = "rbxassetid://79608248053265",
        PremiumOnly = false
    })

    -- Walk Speed Slider
    PlayerTab:AddSlider({
        Name = "Walk Speed",
        Min = 16,
        Max = 200,
        Default = walkSpeed,
        Color = Color3.fromRGB(255,255,255),
        Increment = 1,
        ValueName = "Speed",
        Callback = function(Value)
            walkSpeed = Value
            pcall(function()
                if humanoid then
                    humanoid.WalkSpeed = walkSpeed
                end
            end)
        end    
    })

    -- Jump Power Slider
    PlayerTab:AddSlider({
        Name = "Jump Power",
        Min = 50,
        Max = 300,
        Default = jumpPower,
        Color = Color3.fromRGB(255,255,255),
        Increment = 1,
        ValueName = "Power",
        Callback = function(Value)
            jumpPower = Value
            pcall(function()
                if humanoid then
                    humanoid.JumpPower = jumpPower
                end
            end)
        end    
    })

    -- Noclip Toggle
    PlayerTab:AddToggle({
        Name = "Noclip",
        Default = false,
        Callback = function(Value)
            noclip = Value
            if noclip then
                connections.noclip = RunService.Heartbeat:Connect(function()
                    if not noclip then return end
                    
                    pcall(function()
                        if character then
                            for _, part in pairs(character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                end)
            else
                if connections.noclip then
                    connections.noclip:Disconnect()
                    connections.noclip = nil
                end
                
                pcall(function()
                    if character then
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                part.CanCollide = true
                            end
                        end
                    end
                end)
            end
        end    
    })

    -- God Mode Toggle
    PlayerTab:AddToggle({
        Name = "God Mode",
        Default = false,
        Callback = function(Value)
            godMode = Value
            if godMode then
                connections.godMode = RunService.Heartbeat:Connect(function()
                    if not godMode then return end
                    
                    pcall(function()
                        if humanoid and humanoid.Health < humanoid.MaxHealth then
                            humanoid.Health = humanoid.MaxHealth
                        end
                    end)
                end)
            else
                if connections.godMode then
                    connections.godMode:Disconnect()
                    connections.godMode = nil
                end
            end
        end    
    })

    -- Infinite Stamina Toggle
    PlayerTab:AddToggle({
        Name = "Infinite Stamina",
        Default = false,
        Callback = function(Value)
            infiniteStamina = Value
            if infiniteStamina then
                connections.infiniteStamina = RunService.Heartbeat:Connect(function()
                    if not infiniteStamina then return end
                    
                    pcall(function()
                        -- Find stamina GUI or value
                        local playerGui = player:FindFirstChild("PlayerGui")
                        if playerGui then
                            local staminaGui = playerGui:FindFirstChild("Stamina") or playerGui:FindFirstChild("Energy")
                            if staminaGui then
                                local staminaValue = staminaGui:FindFirstChild("Value") or staminaGui:FindFirstChild("Current")
                                if staminaValue then
                                    staminaValue.Value = 100
                                end
                            end
                        end
                    end)
                end)
            else
                if connections.infiniteStamina then
                    connections.infiniteStamina:Disconnect()
                    connections.infiniteStamina = nil
                end
            end
        end    
    })

    -- Tab Visual
    local VisualTab = Window:MakeTab({
        Name = "Visual",
        Icon = "rbxassetid://79608248053265",
        PremiumOnly = false
    })

    -- Night Vision Toggle
    VisualTab:AddToggle({
        Name = "Night Vision",
        Default = false,
        Callback = function(Value)
            nightVision = Value
            pcall(function()
                if nightVision then
                    game.Lighting.Brightness = 2
                    game.Lighting.ClockTime = 14
                    game.Lighting.FogEnd = 100000
                    game.Lighting.GlobalShadows = false
                    game.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                else
                    game.Lighting.Brightness = 1
                    game.Lighting.ClockTime = 0
                    game.Lighting.FogEnd = 500
                    game.Lighting.GlobalShadows = true
                    game.Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
                end
            end)
        end    
    })

    -- Remove Fog Button
    VisualTab:AddButton({
        Name = "Remove Fog",
        Callback = function()
            pcall(function()
                game.Lighting.FogEnd = 100000
                game.Lighting.FogStart = 0
            end)
        end    
    })

    -- Tab Misc
    local MiscTab = Window:MakeTab({
        Name = "Misc",
        Icon = "rbxassetid://79608248053265",
        PremiumOnly = false
    })

    -- Rejoin Server Button
    MiscTab:AddButton({
        Name = "Rejoin Server",
        Callback = function()
            pcall(function()
                TeleportService:Teleport(game.PlaceId, player)
            end)
        end    
    })

    -- Character Management
    local function setupCharacter(newCharacter)
        character = newCharacter
        humanoid = character:WaitForChild("Humanoid", 10)
        rootPart = character:WaitForChild("HumanoidRootPart", 10)
        
        if humanoid and rootPart then
            -- Reapply settings
            humanoid.WalkSpeed = walkSpeed
            humanoid.JumpPower = jumpPower
        end
    end

    -- Character respawn handling
    connections.characterAdded = player.CharacterAdded:Connect(setupCharacter)

    -- Cleanup function
    local function cleanup()
        for name, connection in pairs(connections) do
            if connection then
                if typeof(connection) == "RBXScriptConnection" then
                    connection:Disconnect()
                elseif typeof(connection) == "thread" then
                    task.cancel(connection)
                end
            end
        end
        connections = {}
    end

    -- Cleanup on window close
    game:GetService("CoreGui").ChildRemoved:Connect(function(child)
        if child.Name == "Orion" then
            cleanup()
        end
    end)

    -- Success notification
    OrionLib:MakeNotification({
        Name = "GILONG Hub",
        Content = "Hub loaded successfully! Ready to survive 99 nights!",
        Image = "rbxassetid://79608248053265",
        Time = 5
    })

    -- Initialize Orion
    OrionLib:Init()

end -- End of loadMainHub function

-- Key Window
local KeyWindow = OrionLib:MakeWindow({
    Name = "GILONG Hub - Key System", 
    HidePremium = false, 
    SaveConfig = false,
    IntroEnabled = true,
    IntroText = "GILONG Hub Key System",
    IntroIcon = "rbxassetid://79608248053265"
})

local KeyTab = KeyWindow:MakeTab({
    Name = "Key System",
    Icon = "rbxassetid://79608248053265",
    PremiumOnly = false
})

-- Key Input
KeyTab:AddTextbox({
    Name = "Enter Key",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        if Value == correctKey then
            keyCorrect = true
            OrionLib:MakeNotification({
                Name = "GILONG Hub",
                Content = "Key correct! Loading hub...",
                Image = "rbxassetid://79608248053265",
                Time = 3
            })
            safeWait(1)
            KeyWindow:Destroy()
            loadMainHub()
        else
            OrionLib:MakeNotification({
                Name = "GILONG Hub",
                Content = "Wrong key! Please try again.",
                Image = "rbxassetid://79608248053265",
                Time = 3
            })
        end
    end      
})

-- Get Key Button
KeyTab:AddButton({
    Name = "Get Key (Copy Link)",
    Callback = function()
        if copyToClipboard(keyLink) then
            OrionLib:MakeNotification({
                Name = "GILONG Hub",
                Content = "Key link copied to clipboard!",
                Image = "rbxassetid://79608248053265",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "GILONG Hub",
                Content = "Link: " .. keyLink,
                Image = "rbxassetid://79608248053265",
                Time = 10
            })
        end
    end    
})

-- Key Instructions
KeyTab:AddParagraph("Instructions", "1. Click 'Get Key' to copy the link\n2. Complete the key system\n3. Enter your key above\n4. Enjoy GILONG Hub for 99 Night in the Forest!")

-- Initialize Key System
OrionLib:Init()
