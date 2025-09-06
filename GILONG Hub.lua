-- GILONG Hub for Blox Fruits
-- Using Fluent UI Library (Most Reliable)
-- Key: AyamGoreng!

wait(2)

-- Load Fluent UI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

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
    -- Create Window with Fluent UI
    local Window = Fluent:CreateWindow({
        Title = "GILONG Hub - Blox Fruits",
        SubTitle = "by GILONG",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })
    
    -- Tabs
    local Tabs = {
        AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "⚔️" }),
        Stats = Window:AddTab({ Title = "Stats", Icon = "📊" }),
        Combat = Window:AddTab({ Title = "Combat", Icon = "🗡️" }),
        Fruit = Window:AddTab({ Title = "Fruit", Icon = "🍎" }),
        Player = Window:AddTab({ Title = "Player", Icon = "👤" }),
        Teleports = Window:AddTab({ Title = "Teleports", Icon = "🌍" }),
        Misc = Window:AddTab({ Title = "Misc", Icon = "⚙️" })
    }
    
    -- Auto Farm Tab
    Tabs.AutoFarm:AddToggle("AutoFarmLevel", {
        Title = "Auto Farm Level",
        Description = "Automatically farm levels",
        Default = false,
        Callback = function(Value)
            autoFarm = Value
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
        end
    })
    
    Tabs.AutoFarm:AddToggle("AutoQuest", {
        Title = "Auto Quest",
        Description = "Automatically get and complete quests",
        Default = false,
        Callback = function(Value)
            autoQuest = Value
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
        end
    })
    
    Tabs.AutoFarm:AddSlider("KillAuraRange", {
        Title = "Kill Aura Range",
        Description = "Set kill aura range",
        Default = 50,
        Min = 1,
        Max = 500,
        Rounding = 1,
        Callback = function(Value)
            killAuraRange = Value
        end
    })
    
    -- Stats Tab
    Tabs.Stats:AddToggle("AutoStats", {
        Title = "Auto Stats",
        Description = "Automatically upgrade stats",
        Default = false,
        Callback = function(Value)
            autoStats = Value
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
        end
    })
    
    Tabs.Stats:AddDropdown("StatSelection", {
        Title = "Select Stat",
        Description = "Choose which stat to upgrade",
        Values = statsList,
        Default = 1,
        Multi = false,
        Callback = function(Value)
            selectedStat = Value
        end
    })
    
    -- Combat Tab
    Tabs.Combat:AddToggle("KillAura", {
        Title = "Kill Aura",
        Description = "Attack nearby enemies",
        Default = false,
        Callback = function(Value)
            killAura = Value
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
        end
    })
    
    -- Fruit Tab
    Tabs.Fruit:AddToggle("AutoRaid", {
        Title = "Auto Raid",
        Description = "Automatically do raids",
        Default = false,
        Callback = function(Value)
            autoRaid = Value
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
        end
    })
    
    Tabs.Fruit:AddToggle("BringFruit", {
        Title = "Bring Fruit",
        Description = "Bring fruits to you",
        Default = false,
        Callback = function(Value)
            bringFruit = Value
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
        end
    })
    
    -- Player Tab
    Tabs.Player:AddSlider("WalkSpeed", {
        Title = "Walk Speed",
        Description = "Change walk speed",
        Default = 16,
        Min = 16,
        Max = 200,
        Rounding = 1,
        Callback = function(Value)
            walkSpeed = Value
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = walkSpeed
                end
            end
        end
    })
    
    Tabs.Player:AddSlider("JumpPower", {
        Title = "Jump Power",
        Description = "Change jump power",
        Default = 50,
        Min = 50,
        Max = 300,
        Rounding = 1,
        Callback = function(Value)
            jumpPower = Value
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.JumpPower = jumpPower
                end
            end
        end
    })
    
    Tabs.Player:AddToggle("Noclip", {
        Title = "Noclip",
        Description = "Walk through walls",
        Default = false,
        Callback = function(Value)
            noclip = Value
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
        end
    })
    
    Tabs.Player:AddToggle("InfiniteEnergy", {
        Title = "Infinite Energy",
        Description = "Never run out of energy",
        Default = false,
        Callback = function(Value)
            infiniteEnergy = Value
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
        end
    })
    
    -- Teleports Tab
    Tabs.Teleports:AddButton({
        Title = "Teleport to Spawn",
        Description = "Teleport to spawn area",
        Callback = function()
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = CFrame.new(-7894.6176757813, 5547.1416015625, -380.29119873047)
                end
            end
        end
    })
    
    Tabs.Teleports:AddButton({
        Title = "Pirate Village",
        Description = "Teleport to Pirate Village",
        Callback = function()
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = CFrame.new(-1181.3093261719, 4.7514905929565, 3803.5456542969)
                end
            end
        end
    })
    
    Tabs.Teleports:AddButton({
        Title = "Marine Base",
        Description = "Teleport to Marine Base",
        Callback = function()
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = CFrame.new(-2573.3374023438, 6.8556680679321, 2046.99609375)
                end
            end
        end
    })
    
    -- Misc Tab
    Tabs.Misc:AddToggle("AntiAFK", {
        Title = "Anti AFK",
        Description = "Prevent getting kicked for being AFK",
        Default = false,
        Callback = function(Value)
            if Value then
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
        end
    })
    
    Tabs.Misc:AddButton({
        Title = "Rejoin Server",
        Description = "Rejoin current server",
        Callback = function()
            TeleportService:Teleport(game.PlaceId, player)
        end
    })
    
    Tabs.Misc:AddButton({
        Title = "Server Hop",
        Description = "Join different server",
        Callback = function()
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
        end
    })
    
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
    local KeyWindow = Fluent:CreateWindow({
        Title = "GILONG Hub - Key System",
        SubTitle = "Enter Key to Access",
        TabWidth = 160,
        Size = UDim2.fromOffset(460, 300),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })
    
    local KeyTab = KeyWindow:AddTab({ Title = "Key System", Icon = "🔑" })
    
    -- Key Input
    KeyTab:AddInput("KeyInput", {
        Title = "Enter Key",
        Description = "Input your key here",
        Default = "",
        Placeholder = "Enter key...",
        Numeric = false,
        Finished = false,
        Callback = function(Value)
            if Value == correctKey then
                Fluent:Notify({
                    Title = "GILONG Hub",
                    Content = "Key correct! Loading hub...",
                    Duration = 3
                })
                wait(1)
                KeyWindow:Destroy()
                loadMainHub()
            else
                Fluent:Notify({
                    Title = "GILONG Hub",
                    Content = "Wrong key! Please try again.",
                    Duration = 3
                })
            end
        end
    })
    
    -- Get Key Button
    KeyTab:AddButton({
        Title = "Get Key",
        Description = "Copy key link to clipboard",
        Callback = function()
            if copyToClipboard(keyLink) then
                Fluent:Notify({
                    Title = "GILONG Hub",
                    Content = "Key link copied to clipboard!",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "GILONG Hub",
                    Content = "Link: " .. keyLink,
                    Duration = 10
                })
            end
        end
    })
    
    -- Instructions
    KeyTab:AddParagraph({
        Title = "Instructions",
        Content = "1. Click 'Get Key' to copy the link\n2. Complete the key system\n3. Enter your key above\n4. Enjoy GILONG Hub for Blox Fruits!"
    })
end

-- Start with key system
createKeyGUI()
