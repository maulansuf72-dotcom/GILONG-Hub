-- GILONG Hub for Blox Fruits
-- Using Kavo UI Library (Most Reliable)
-- Key: AyamGoreng!

wait(2)

-- Load Kavo UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- Key System
local correctKey = "AyamGoreng!"
local keyLink = "https://link-hub.net/1392772/AfVHcFNYkLMx"

-- Copy function
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

-- Variables
local autoFarm = false
local autoQuest = false
local autoStats = false
local selectedStat = "Melee"
local killAura = false
local killAuraRange = 50
local autoRaid = false
local bringFruit = false
local walkSpeed = 16
local jumpPower = 50
local noclip = false
local infiniteEnergy = false
local connections = {}

-- Stats list
local statsList = {"Melee", "Defense", "Sword", "Gun", "Blox Fruit"}

-- Main Hub Function
local function loadMainHub()
    -- Create Window
    local Window = Library.CreateLib("GILONG Hub - Blox Fruits", "DarkTheme")
    
    -- Auto Farm Tab
    local AutoFarmTab = Window:NewTab("Auto Farm")
    local AutoFarmSection = AutoFarmTab:NewSection("Farming")
    
    -- Auto Farm Level
    AutoFarmSection:NewToggle("Auto Farm Level", "Automatically farm levels", function(state)
        autoFarm = state
        if autoFarm then
            connections.autoFarm = RunService.Heartbeat:Connect(function()
                if not autoFarm then return end
                
                pcall(function()
                    local character = player.Character
                    if not character then return end
                    local humanoid = character:FindFirstChild("Humanoid")
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if not humanoid or not rootPart then return end
                    
                    -- Find nearest enemy
                    local nearestEnemy = nil
                    local shortestDistance = math.huge
                    
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            local distance = (rootPart.Position - v.HumanoidRootPart.Position).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                nearestEnemy = v
                            end
                        end
                    end
                    
                    if nearestEnemy then
                        -- Teleport to enemy
                        rootPart.CFrame = nearestEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                        
                        -- Attack enemy
                        local combat = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("CommF_")
                        if combat then
                            combat:InvokeServer("requestEntrance", Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
                        end
                        
                        wait(0.1)
                    end
                end)
            end)
        else
            if connections.autoFarm then
                connections.autoFarm:Disconnect()
            end
        end
    end)
    
    -- Auto Quest
    AutoFarmSection:NewToggle("Auto Quest", "Automatically get and complete quests", function(state)
        autoQuest = state
        if autoQuest then
            connections.autoQuest = RunService.Heartbeat:Connect(function()
                if not autoQuest then return end
                
                pcall(function()
                    local character = player.Character
                    if not character then return end
                    
                    -- Auto quest logic here
                    local questGiver = Workspace:FindFirstChild("QuestGiver")
                    if questGiver then
                        -- Get quest logic
                    end
                end)
            end)
        else
            if connections.autoQuest then
                connections.autoQuest:Disconnect()
            end
        end
    end)
    
    -- Kill Aura Range Slider
    AutoFarmSection:NewSlider("Kill Aura Range", "Set kill aura range", 500, 1, function(s)
        killAuraRange = s
    end)
    
    -- Stats Tab
    local StatsTab = Window:NewTab("Stats")
    local StatsSection = StatsTab:NewSection("Auto Stats")
    
    -- Auto Stats Toggle
    StatsSection:NewToggle("Auto Stats", "Automatically upgrade stats", function(state)
        autoStats = state
        if autoStats then
            connections.autoStats = RunService.Heartbeat:Connect(function()
                if not autoStats then return end
                
                pcall(function()
                    local combat = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("CommF_")
                    if combat then
                        combat:InvokeServer("AddPoint", selectedStat, 1)
                    end
                    wait(0.1)
                end)
            end)
        else
            if connections.autoStats then
                connections.autoStats:Disconnect()
            end
        end
    end)
    
    -- Stats Selection Dropdown
    StatsSection:NewDropdown("Select Stat", "Choose which stat to upgrade", statsList, function(currentOption)
        selectedStat = currentOption
    end)
    
    -- Combat Tab
    local CombatTab = Window:NewTab("Combat")
    local CombatSection = CombatTab:NewSection("Combat Features")
    
    -- Kill Aura
    CombatSection:NewToggle("Kill Aura", "Attack nearby enemies", function(state)
        killAura = state
        if killAura then
            connections.killAura = RunService.Heartbeat:Connect(function()
                if not killAura then return end
                
                pcall(function()
                    local character = player.Character
                    if not character then return end
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then return end
                    
                    for _, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            local distance = (rootPart.Position - v.HumanoidRootPart.Position).Magnitude
                            if distance <= killAuraRange then
                                -- Attack logic
                                local combat = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("CommF_")
                                if combat then
                                    combat:InvokeServer("requestEntrance", Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
                                end
                                break
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
    end)
    
    -- Fruit Tab
    local FruitTab = Window:NewTab("Fruit")
    local FruitSection = FruitTab:NewSection("Fruit Features")
    
    -- Auto Raid
    FruitSection:NewToggle("Auto Raid", "Automatically do raids", function(state)
        autoRaid = state
        if autoRaid then
            connections.autoRaid = RunService.Heartbeat:Connect(function()
                if not autoRaid then return end
                
                pcall(function()
                    -- Auto raid logic
                    local combat = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("CommF_")
                    if combat then
                        -- Raid logic here
                    end
                end)
            end)
        else
            if connections.autoRaid then
                connections.autoRaid:Disconnect()
            end
        end
    end)
    
    -- Bring Fruit
    FruitSection:NewToggle("Bring Fruit", "Bring fruits to you", function(state)
        bringFruit = state
        if bringFruit then
            connections.bringFruit = RunService.Heartbeat:Connect(function()
                if not bringFruit then return end
                
                pcall(function()
                    local character = player.Character
                    if not character then return end
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then return end
                    
                    for _, v in pairs(Workspace:GetChildren()) do
                        if string.find(v.Name, "Fruit") and v:FindFirstChild("Handle") then
                            v.Handle.CFrame = rootPart.CFrame
                        end
                    end
                end)
            end)
        else
            if connections.bringFruit then
                connections.bringFruit:Disconnect()
            end
        end
    end)
    
    -- Player Tab
    local PlayerTab = Window:NewTab("Player")
    local PlayerSection = PlayerTab:NewSection("Player Modifications")
    
    -- Walk Speed Slider
    PlayerSection:NewSlider("Walk Speed", "Change walk speed", 200, 16, function(s)
        walkSpeed = s
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = walkSpeed
            end
        end
    end)
    
    -- Jump Power Slider
    PlayerSection:NewSlider("Jump Power", "Change jump power", 300, 50, function(s)
        jumpPower = s
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = jumpPower
            end
        end
    end)
    
    -- Noclip Toggle
    PlayerSection:NewToggle("Noclip", "Walk through walls", function(state)
        noclip = state
        if noclip then
            connections.noclip = RunService.Heartbeat:Connect(function()
                if not noclip then return end
                
                pcall(function()
                    local character = player.Character
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
            end
            
            pcall(function()
                local character = player.Character
                if character then
                    for _, part in pairs(character:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = true
                        end
                    end
                end
            end)
        end
    end)
    
    -- Infinite Energy
    PlayerSection:NewToggle("Infinite Energy", "Never run out of energy", function(state)
        infiniteEnergy = state
        if infiniteEnergy then
            connections.infiniteEnergy = RunService.Heartbeat:Connect(function()
                if not infiniteEnergy then return end
                
                pcall(function()
                    local character = player.Character
                    if character then
                        local humanoid = character:FindFirstChild("Humanoid")
                        if humanoid then
                            -- Set energy to max
                            local playerGui = player:FindFirstChild("PlayerGui")
                            if playerGui then
                                local energyBar = playerGui:FindFirstChild("Main"):FindFirstChild("Energy")
                                if energyBar then
                                    energyBar.Value = energyBar.MaxValue
                                end
                            end
                        end
                    end
                end)
            end)
        else
            if connections.infiniteEnergy then
                connections.infiniteEnergy:Disconnect()
            end
        end
    end)
    
    -- Teleports Tab
    local TeleportTab = Window:NewTab("Teleports")
    local TeleportSection = TeleportTab:NewSection("Teleport Locations")
    
    -- Spawn Teleport
    TeleportSection:NewButton("Teleport to Spawn", "Teleport to spawn area", function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(-7894.6176757813, 5547.1416015625, -380.29119873047)
            end
        end
    end)
    
    -- First Sea Teleports
    TeleportSection:NewButton("Pirate Village", "Teleport to Pirate Village", function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(-1181.3093261719, 4.7514905929565, 3803.5456542969)
            end
        end
    end)
    
    TeleportSection:NewButton("Marine Base", "Teleport to Marine Base", function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(-2573.3374023438, 6.8556680679321, 2046.99609375)
            end
        end
    end)
    
    -- Misc Tab
    local MiscTab = Window:NewTab("Misc")
    local MiscSection = MiscTab:NewSection("Miscellaneous")
    
    -- Anti AFK
    MiscSection:NewToggle("Anti AFK", "Prevent getting kicked for being AFK", function(state)
        if state then
            connections.antiAFK = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            end)
        else
            if connections.antiAFK then
                connections.antiAFK:Disconnect()
            end
        end
    end)
    
    -- Rejoin Server
    MiscSection:NewButton("Rejoin Server", "Rejoin current server", function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
    
    -- Server Hop
    MiscSection:NewButton("Server Hop", "Join different server", function()
        local servers = {}
        local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local body = game:GetService("HttpService"):JSONDecode(req)
        
        for i, v in next, body.data do
            if v.playing ~= v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, v.id)
            end
        end
        
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], player)
        end
    end)
    
    -- Character respawn handling
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = walkSpeed
        humanoid.JumpPower = jumpPower
    end)
    
    -- Cleanup function
    local function cleanup()
        for name, connection in pairs(connections) do
            if connection then
                connection:Disconnect()
            end
        end
        connections = {}
    end
    
    -- Cleanup on leave
    game.Players.PlayerRemoving:Connect(function(plr)
        if plr == player then
            cleanup()
        end
    end)
end

-- Key System GUI
local function createKeyGUI()
    local KeyWindow = Library.CreateLib("GILONG Hub - Key System", "DarkTheme")
    local KeyTab = KeyWindow:NewTab("Key System")
    local KeySection = KeyTab:NewSection("Enter Key")
    
    -- Key Input
    KeySection:NewTextBox("Enter Key", "Input your key here", function(txt)
        if txt == correctKey then
            KeyWindow:Destroy()
            wait(0.5)
            loadMainHub()
        else
            -- Show error message
            game.StarterGui:SetCore("SendNotification", {
                Title = "GILONG Hub";
                Text = "Wrong Key! Please try again.";
                Duration = 3;
            })
        end
    end)
    
    -- Get Key Button
    KeySection:NewButton("Get Key", "Copy key link to clipboard", function()
        if copyToClipboard(keyLink) then
            game.StarterGui:SetCore("SendNotification", {
                Title = "GILONG Hub";
                Text = "Key link copied to clipboard!";
                Duration = 3;
            })
        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "GILONG Hub";
                Text = "Link: " .. keyLink;
                Duration = 10;
            })
        end
    end)
    
    -- Instructions
    KeySection:NewLabel("1. Click 'Get Key' to copy the link")
    KeySection:NewLabel("2. Complete the key system")
    KeySection:NewLabel("3. Enter your key above")
    KeySection:NewLabel("4. Enjoy GILONG Hub for Blox Fruits!")
end

-- Start with key system
createKeyGUI()
