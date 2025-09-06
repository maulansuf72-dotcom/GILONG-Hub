-- GILONG Hub Script untuk Slap Battles
-- Menggunakan Orion Library untuk GUI
-- Key System: AyamGoreng!
-- Version: Final Release

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

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

    -- Variables untuk auto features dengan proper initialization
    local autoSlap = false
    local autoFarm = false
    local antiRagdoll = false
    local walkSpeed = humanoid.WalkSpeed or 20
    local jumpPower = humanoid.JumpPower or 50
    local noclip = false
    local autoRespawn = false
    local infiniteJump = false
    local godMode = false
    local antiAFK = false
    local chatSpam = false
    local spamMessage = "GILONG Hub"

    -- Connection storage for cleanup
    local connections = {}

    -- Membuat Window utama
    local Window = OrionLib:MakeWindow({
        Name = "GILONG Hub", 
        HidePremium = false, 
        SaveConfig = true, 
        ConfigFolder = "GILONGHub",
        IntroEnabled = true,
        IntroText = "GILONG Hub - Slap Battles",
        IntroIcon = "rbxassetid://79608248053265"
    })

    -- Tab Auto Farm
    local AutoTab = Window:MakeTab({
        Name = "Auto Farm",
        Icon = "rbxassetid://79608248053265",
        PremiumOnly = false
    })

    -- Auto Slap Toggle
    AutoTab:AddToggle({
        Name = "Auto Slap",
        Default = false,
        Callback = function(Value)
            autoSlap = Value
            if autoSlap then
                connections.autoSlap = RunService.Heartbeat:Connect(function()
                    if not autoSlap then return end
                    
                    pcall(function()
                        if not character or not character.Parent or not rootPart or not rootPart.Parent then
                            character = player.Character
                            if character then
                                rootPart = character:FindFirstChild("HumanoidRootPart")
                            end
                            return
                        end
                        
                        for _, target in pairs(Players:GetPlayers()) do
                            if target ~= player and target.Character then
                                local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                                local targetHumanoid = target.Character:FindFirstChild("Humanoid")
                                
                                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                                    local distance = (rootPart.Position - targetRoot.Position).Magnitude
                                    if distance <= 25 then
                                        local slapRemote = ReplicatedStorage:FindFirstChild("b")
                                        if slapRemote then
                                            slapRemote:FireServer(target.Character:FindFirstChild("Head"))
                                        end
                                        safeWait(0.15)
                                        break
                                    end
                                end
                            end
                        end
                    end)
                end)
            else
                if connections.autoSlap then
                    connections.autoSlap:Disconnect()
                    connections.autoSlap = nil
                end
            end
        end    
    })

    -- Auto Farm Kills
    AutoTab:AddToggle({
        Name = "Auto Farm Kills",
        Default = false,
        Callback = function(Value)
            autoFarm = Value
            if autoFarm then
                connections.autoFarm = RunService.Heartbeat:Connect(function()
                    if not autoFarm then return end
                    
                    pcall(function()
                        if not character or not character.Parent or not rootPart or not rootPart.Parent then
                            character = player.Character
                            if character then
                                rootPart = character:FindFirstChild("HumanoidRootPart")
                            end
                            return
                        end
                        
                        local nearestTarget = nil
                        local nearestDistance = math.huge
                        
                        for _, target in pairs(Players:GetPlayers()) do
                            if target ~= player and target.Character then
                                local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                                local targetHumanoid = target.Character:FindFirstChild("Humanoid")
                                
                                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                                    local distance = (rootPart.Position - targetRoot.Position).Magnitude
                                    if distance < nearestDistance then
                                        nearestDistance = distance
                                        nearestTarget = target
                                    end
                                end
                            end
                        end
                        
                        if nearestTarget and nearestTarget.Character then
                            local targetRoot = nearestTarget.Character:FindFirstChild("HumanoidRootPart")
                            if targetRoot then
                                rootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -4)
                                safeWait(0.1)
                                
                                local slapRemote = ReplicatedStorage:FindFirstChild("b")
                                if slapRemote then
                                    slapRemote:FireServer(nearestTarget.Character:FindFirstChild("Head"))
                                end
                                safeWait(0.2)
                            end
                        end
                    end)
                end)
            else
                if connections.autoFarm then
                    connections.autoFarm:Disconnect()
                    connections.autoFarm = nil
                end
            end
        end    
    })

    -- Anti Ragdoll
    AutoTab:AddToggle({
        Name = "Anti Ragdoll",
        Default = false,
        Callback = function(Value)
            antiRagdoll = Value
            if antiRagdoll then
                connections.antiRagdoll = RunService.Heartbeat:Connect(function()
                    if not antiRagdoll then return end
                    
                    pcall(function()
                        if character and character:FindFirstChild("Humanoid") then
                            character.Humanoid.PlatformStand = false
                            for _, part in pairs(character:GetChildren()) do
                                if part:IsA("BasePart") and part ~= rootPart then
                                    part.Velocity = Vector3.new(0, 0, 0)
                                    part.AngularVelocity = Vector3.new(0, 0, 0)
                                end
                            end
                        end
                    end)
                end)
            else
                if connections.antiRagdoll then
                    connections.antiRagdoll:Disconnect()
                    connections.antiRagdoll = nil
                end
            end
        end    
    })

    -- Auto Respawn
    AutoTab:AddToggle({
        Name = "Auto Respawn",
        Default = false,
        Callback = function(Value)
            autoRespawn = Value
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
        Max = 500,
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
        Max = 500,
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

    -- Infinite Jump
    PlayerTab:AddToggle({
        Name = "Infinite Jump",
        Default = false,
        Callback = function(Value)
            infiniteJump = Value
        end    
    })

    -- Infinite Jump Logic
    connections.infiniteJump = UserInputService.JumpRequest:Connect(function()
        if infiniteJump then
            pcall(function()
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end)

    -- God Mode
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

    -- Tab Teleports
    local TeleportTab = Window:MakeTab({
        Name = "Teleports",
        Icon = "rbxassetid://79608248053265",
        PremiumOnly = false
    })

    -- Safe teleport function
    local function safeTeleport(position)
        pcall(function()
            if rootPart then
                rootPart.CFrame = CFrame.new(position)
            end
        end)
    end

    -- Teleport Buttons
    TeleportTab:AddButton({
        Name = "Teleport to Arena",
        Callback = function()
            safeTeleport(Vector3.new(0, 10, 0))
        end    
    })

    TeleportTab:AddButton({
        Name = "Teleport to Safe Zone",
        Callback = function()
            safeTeleport(Vector3.new(-800, 328, 10))
        end    
    })

    TeleportTab:AddButton({
        Name = "Teleport to Moai Island",
        Callback = function()
            safeTeleport(Vector3.new(215, -15.5, 0.5))
        end    
    })

    TeleportTab:AddButton({
        Name = "Teleport to Slapple Island",
        Callback = function()
            safeTeleport(Vector3.new(-2500, -7.5, -1500))
        end    
    })

    TeleportTab:AddButton({
        Name = "Teleport to Plate (Rob Badge)",
        Callback = function()
            safeTeleport(Vector3.new(25.5, 26000, 25.5))
        end    
    })

    TeleportTab:AddButton({
        Name = "Teleport to Cannon Island",
        Callback = function()
            safeTeleport(Vector3.new(250, 50, 250))
        end    
    })

    -- Player Teleport Dropdown
    local function updatePlayerList()
        local playerList = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(playerList, plr.Name)
            end
        end
        return playerList
    end

    TeleportTab:AddDropdown({
        Name = "Teleport to Player",
        Default = "Select Player",
        Options = updatePlayerList(),
        Callback = function(Value)
            pcall(function()
                local targetPlayer = Players:FindFirstChild(Value)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    rootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                end
            end)
        end    
    })

    -- Tab Gloves
    local GlovesTab = Window:MakeTab({
        Name = "Gloves",
        Icon = "rbxassetid://79608248053265",
        PremiumOnly = false
    })

    -- Comprehensive glove list
    local glovesList = {
        "Default", "Replica", "Phase", "Space", "Detonator", "Woah", "Ice", "Fire", 
        "Spiky", "Ghostwalker", "Diamond", "ZZZZZZZ", "Brick", "Snow", "Pull", "Flash", 
        "Spring", "Swapper", "Bull", "Dice", "Ghost", "Thanos", "Stun", "Confusion", 
        "Glitch", "Snowball", "fish", "🗿", "Obby", "Voodoo", "Leash", "Flamarang", 
        "Extend", "Rock", "Gravity", "Lure", "Jebaited", "Tycoon", "Charge", "Baller", 
        "Tableflip", "Booster", "Shield", "Track", "Goofy", "Confusion", "Elude", 
        "Pusher", "Hive", "Disarm", "Plague", "Psycho", "Kraken", "Conveyor", "Magnet"
    }

    GlovesTab:AddDropdown({
        Name = "Equip Glove",
        Default = "Default",
        Options = glovesList,
        Callback = function(Value)
            pcall(function()
                local equipRemote = ReplicatedStorage:FindFirstChild("Rockremote")
                if equipRemote then
                    equipRemote:FireServer(Value)
                end
            end)
        end    
    })

    -- Tab Misc
    local MiscTab = Window:MakeTab({
        Name = "Misc",
        Icon = "rbxassetid://79608248053265",
        PremiumOnly = false
    })

    -- Visual Enhancements
    MiscTab:AddButton({
        Name = "Remove Fog",
        Callback = function()
            pcall(function()
                game.Lighting.FogEnd = 100000
                game.Lighting.FogStart = 0
            end)
        end    
    })

    MiscTab:AddButton({
        Name = "Fullbright",
        Callback = function()
            pcall(function()
                game.Lighting.Brightness = 2
                game.Lighting.ClockTime = 14
                game.Lighting.FogEnd = 100000
                game.Lighting.GlobalShadows = false
                game.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            end)
        end    
    })

    -- Anti AFK
    MiscTab:AddToggle({
        Name = "Anti AFK",
        Default = false,
        Callback = function(Value)
            antiAFK = Value
            if antiAFK then
                connections.antiAFK = task.spawn(function()
                    while antiAFK do
                        safeWait(300) -- 5 minutes
                        pcall(function()
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton2(Vector2.new())
                        end)
                    end
                end)
            else
                if connections.antiAFK then
                    task.cancel(connections.antiAFK)
                    connections.antiAFK = nil
                end
            end
        end    
    })

    -- Chat Spam
    MiscTab:AddTextbox({
        Name = "Spam Message",
        Default = "GILONG Hub",
        TextDisappear = false,
        Callback = function(Value)
            spamMessage = Value
        end      
    })

    MiscTab:AddToggle({
        Name = "Chat Spam",
        Default = false,
        Callback = function(Value)
            chatSpam = Value
            if chatSpam then
                connections.chatSpam = task.spawn(function()
                    while chatSpam do
                        safeWait(2)
                        pcall(function()
                            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(spamMessage, "All")
                        end)
                    end
                end)
            else
                if connections.chatSpam then
                    task.cancel(connections.chatSpam)
                    connections.chatSpam = nil
                end
            end
        end    
    })

    -- Server Management
    MiscTab:AddButton({
        Name = "Rejoin Server",
        Callback = function()
            pcall(function()
                TeleportService:Teleport(game.PlaceId, player)
            end)
        end    
    })

    MiscTab:AddButton({
        Name = "Server Hop",
        Callback = function()
            pcall(function()
                local servers = {}
                local success, result = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
                end)
                
                if success and result.data then
                    for _, server in pairs(result.data) do
                        if server.playing < server.maxPlayers and server.id ~= game.JobId then
                            table.insert(servers, server.id)
                        end
                    end
                    
                    if #servers > 0 then
                        local randomServer = servers[math.random(1, #servers)]
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, player)
                    end
                end
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
            
            -- Auto respawn logic
            if autoRespawn then
                connections.deathConnection = humanoid.Died:Connect(function()
                    safeWait(5)
                    pcall(function()
                        player:LoadCharacter()
                    end)
                end)
            end
        end
    end

    -- Character respawn handling
    connections.characterAdded = player.CharacterAdded:Connect(setupCharacter)

    -- Player list update
    connections.playerAdded = Players.PlayerAdded:Connect(function()
        safeWait(1)
        -- Update player dropdown if needed
    end)

    connections.playerRemoving = Players.PlayerRemoving:Connect(function()
        safeWait(1)
        -- Update player dropdown if needed
    end)

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
        Content = "Hub loaded successfully! Ready to dominate Slap Battles!",
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
KeyTab:AddParagraph("Instructions", "1. Click 'Get Key' to copy the link\n2. Complete the key system\n3. Enter your key above\n4. Enjoy GILONG Hub!")

-- Initialize Key System
OrionLib:Init()
