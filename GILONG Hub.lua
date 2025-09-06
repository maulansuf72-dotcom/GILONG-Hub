-- GILONG Hub Script untuk Slap Battles
-- Menggunakan Orion Library untuk GUI
-- Key System: AyamGoreng!

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Key System Variables
local keyCorrect = false
local correctKey = "AyamGoreng!"
local keyLink = "https://link-hub.net/1392772/AfVHcFNYkLMx"

-- Function untuk copy link ke clipboard
local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
        return true
    end
    return false
end

-- Function untuk load main hub
local function loadMainHub()
    -- Variables untuk player dan services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    -- Variables untuk auto features
    local autoSlap = false
    local autoFarm = false
    local antiRagdoll = false
    local walkSpeed = 20
    local jumpPower = 50
    local noclip = false
    local autoRespawn = false

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
            spawn(function()
                while autoSlap do
                    wait(0.1)
                    -- Logic auto slap
                    for _, target in pairs(Players:GetPlayers()) do
                        if target ~= player and target.Character then
                            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                            local targetHumanoid = target.Character:FindFirstChild("Humanoid")
                            
                            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                                local distance = (rootPart.Position - targetRoot.Position).Magnitude
                                if distance <= 20 then -- Jarak slap
                                    -- Trigger slap
                                    local slapRemote = ReplicatedStorage:FindFirstChild("b")
                                    if slapRemote then
                                        slapRemote:FireServer(target.Character:FindFirstChild("Head"))
                                    end
                                    wait(0.2)
                                end
                            end
                        end
                    end
                end
            end)
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
            spawn(function()
                while autoFarm do
                    wait(0.1)
                    -- Cari target terdekat
                    local nearestTarget = nil
                    local nearestDistance = math.huge
                    
                    for _, target in pairs(Players:GetPlayers()) do
                        if target ~= player and target.Character then
                            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                            if targetRoot then
                                local distance = (rootPart.Position - targetRoot.Position).Magnitude
                                if distance < nearestDistance then
                                    nearestDistance = distance
                                    nearestTarget = target
                                end
                            end
                        end
                    end
                    
                    -- Teleport dan slap target terdekat
                    if nearestTarget and nearestTarget.Character then
                        local targetRoot = nearestTarget.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot and rootPart then
                            rootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -5)
                            wait(0.1)
                            
                            -- Slap target
                            local slapRemote = ReplicatedStorage:FindFirstChild("b")
                            if slapRemote then
                                slapRemote:FireServer(nearestTarget.Character:FindFirstChild("Head"))
                            end
                        end
                    end
                end
            end)
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
            spawn(function()
                while antiRagdoll do
                    wait()
                    if character and character:FindFirstChild("Humanoid") then
                        character.Humanoid.PlatformStand = false
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Velocity = Vector3.new(0, 0, 0)
                                part.AngularVelocity = Vector3.new(0, 0, 0)
                            end
                        end
                    end
                end
            end)
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
    Min = 20,
    Max = 500,
    Default = 20,
    Color = Color3.fromRGB(255,255,255),
    Increment = 5,
    ValueName = "Speed",
    Callback = function(Value)
        walkSpeed = Value
        if humanoid then
            humanoid.WalkSpeed = walkSpeed
        end
    end    
})

    -- Jump Power Slider
    PlayerTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 5,
    ValueName = "Power",
    Callback = function(Value)
        jumpPower = Value
        if humanoid then
            humanoid.JumpPower = jumpPower
        end
    end    
})

    -- Noclip Toggle
    PlayerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        noclip = Value
        if noclip then
            spawn(function()
                while noclip do
                    wait()
                    for _, part in pairs(character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end    
})

    -- Infinite Jump
    local infiniteJump = false
    PlayerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        infiniteJump = Value
    end    
})

    -- Infinite Jump Logic
    UserInputService.JumpRequest:Connect(function()
    if infiniteJump and humanoid then
        humanoid:ChangeState("Jumping")
    end
end)

    -- God Mode (Anti Death)
    PlayerTab:AddToggle({
    Name = "God Mode",
    Default = false,
    Callback = function(Value)
        if Value then
            spawn(function()
                while Value do
                    wait()
                    if humanoid then
                        humanoid.Health = humanoid.MaxHealth
                    end
                end
            end)
        end
    end    
})

    -- Tab Teleports
    local TeleportTab = Window:MakeTab({
    Name = "Teleports",
    Icon = "rbxassetid://79608248053265",
    PremiumOnly = false
})

    -- Teleport to Arena
    TeleportTab:AddButton({
    Name = "Teleport to Arena",
    Callback = function()
        if rootPart then
            rootPart.CFrame = CFrame.new(0, 10, 0) -- Arena utama
        end
    end    
})

    -- Teleport to Safe Zone
    TeleportTab:AddButton({
    Name = "Teleport to Safe Zone",
    Callback = function()
        if rootPart then
            rootPart.CFrame = CFrame.new(-800, 328, 10) -- Safe zone coordinates
        end
    end    
})

    -- Teleport to Moai Island
    TeleportTab:AddButton({
    Name = "Teleport to Moai Island",
    Callback = function()
        if rootPart then
            rootPart.CFrame = CFrame.new(215, -15.5, 0.5) -- Moai island
        end
    end    
})

    -- Teleport to Slapple Island
    TeleportTab:AddButton({
    Name = "Teleport to Slapple Island",
    Callback = function()
        if rootPart then
            rootPart.CFrame = CFrame.new(-2500, -7.5, -1500) -- Slapple island
        end
    end    
})

    -- Teleport to Plate
    TeleportTab:AddButton({
    Name = "Teleport to Plate",
    Callback = function()
        if rootPart then
            rootPart.CFrame = CFrame.new(25.5, 26000, 25.5) -- Plate for Rob badge
        end
    end    
})

    -- Teleport to Players
    local playerDropdown = {}
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= player then
        table.insert(playerDropdown, plr.Name)
    end
end

    TeleportTab:AddDropdown({
    Name = "Teleport to Player",
    Default = "Select Player",
    Options = playerDropdown,
    Callback = function(Value)
        local targetPlayer = Players:FindFirstChild(Value)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            rootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
        end
    end    
})

    -- Tab Gloves
    local GlovesTab = Window:MakeTab({
    Name = "Gloves",
    Icon = "rbxassetid://79608248053265",
    PremiumOnly = false
})

    -- Equip Gloves
    local glovesList = {"Default", "Replica", "Phase", "Space", "Detonator", "Woah", "Ice", "Fire", "Spiky", "Ghostwalker", "Diamond", "ZZZZZZZ", "Brick", "Snow", "Pull", "Flash", "Spring", "Swapper", "Bull", "Dice", "Ghost", "Thanos", "Stun", "Confusion", "Glitch", "Snowball", "fish", "🗿", "Obby", "Voodoo", "Leash", "Flamarang", "Extend", "Rock", "Gravity", "Lure", "Jebaited", "Tycoon", "Charge", "Baller", "Tableflip", "Booster", "Shield", "Track", "Goofy", "Confusion", "Elude", "Glitch", "Snowball", "fish", "🗿", "Obby", "Voodoo", "Leash", "Flamarang", "Extend", "Rock", "Gravity", "Lure", "Jebaited", "Tycoon", "Charge", "Baller", "Tableflip", "Booster", "Shield", "Track", "Goofy"}

    GlovesTab:AddDropdown({
    Name = "Equip Glove",
    Default = "Default",
    Options = glovesList,
    Callback = function(Value)
        local equipRemote = ReplicatedStorage:FindFirstChild("Rockremote")
        if equipRemote then
            equipRemote:FireServer(Value)
        end
    end    
})

    -- Tab Misc
    local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://79608248053265",
    PremiumOnly = false
})

    -- Remove Fog
    MiscTab:AddButton({
    Name = "Remove Fog",
    Callback = function()
        game.Lighting.FogEnd = 100000
        game.Lighting.FogStart = 0
    end    
})

    -- Fullbright
    MiscTab:AddButton({
    Name = "Fullbright",
    Callback = function()
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
        game.Lighting.FogEnd = 100000
        game.Lighting.GlobalShadows = false
        game.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end    
})

    -- Anti AFK
    local antiAFK = false
    MiscTab:AddToggle({
    Name = "Anti AFK",
    Default = false,
    Callback = function(Value)
        antiAFK = Value
        if antiAFK then
            spawn(function()
                while antiAFK do
                    wait(300) -- 5 menit
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
                end
            end)
        end
    end    
})

    -- Chat Spam
    local chatSpam = false
    local spamMessage = "GG"
    MiscTab:AddTextbox({
    Name = "Spam Message",
    Default = "GG",
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
            spawn(function()
                while chatSpam do
                    wait(1)
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(spamMessage, "All")
                end
            end)
        end
    end    
})

    -- Rejoin Server
    MiscTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    end    
})

    -- Server Hop
    MiscTab:AddButton({
    Name = "Server Hop",
    Callback = function()
        local servers = {}
        local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local body = game:GetService("HttpService"):JSONDecode(req)
        
        for i, v in next, body.data do
            if v.playing ~= v.maxPlayers and v.id ~= game.JobId then
                servers[#servers + 1] = v.id
            end
        end
        
        if #servers > 0 then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], player)
        end
    end    
})

    -- Update character ketika respawn
    player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Reapply settings
    humanoid.WalkSpeed = walkSpeed
    humanoid.JumpPower = jumpPower
    
    -- Auto respawn logic
    if autoRespawn then
        wait(1)
        if humanoid.Health <= 0 then
            wait(5)
            player:LoadCharacter()
        end
    end
end)

    -- Handle death for auto respawn
    humanoid.Died:Connect(function()
    if autoRespawn then
        wait(5)
        player:LoadCharacter()
    end
end)

    -- Update player list for teleport dropdown
    Players.PlayerAdded:Connect(function()
    wait(1)
    playerDropdown = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(playerDropdown, plr.Name)
        end
    end
end)

    Players.PlayerRemoving:Connect(function()
    wait(1)
    playerDropdown = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(playerDropdown, plr.Name)
        end
    end
end)

    -- Notification saat script loaded
    OrionLib:MakeNotification({
    Name = "GILONG Hub",
    Content = "Hub loaded successfully! Ready to slap!",
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
            wait(1)
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

-- Discord Button
KeyTab:AddButton({
    Name = "Join Discord",
    Callback = function()
        local discordLink = "https://discord.gg/gilonghub"
        if copyToClipboard(discordLink) then
            OrionLib:MakeNotification({
                Name = "GILONG Hub",
                Content = "Discord link copied!",
                Image = "rbxassetid://79608248053265",
                Time = 3
            })
        end
    end    
})

-- Initialize Key System
OrionLib:Init()
