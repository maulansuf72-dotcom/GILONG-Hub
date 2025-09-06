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

    -- Variables
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

    local connections = {}

    local Window = OrionLib:MakeWindow({
        Name = "GILONG Hub",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "GILONGHub",
        IntroEnabled = true,
        IntroText = "GILONG Hub - Slap Battles",
        IntroIcon = "rbxassetid://79608248053265"
    })

    --------------------------------------------------------------------
    -- TAB AUTO FARM
    --------------------------------------------------------------------
    local AutoTab = Window:MakeTab({
        Name = "Auto Farm",
        Icon = "rbxassetid://79608248053265",
        PremiumOnly = false
    })

    -- Auto Slap
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

    -- Auto Respawn
    AutoTab:AddToggle({
        Name = "Auto Respawn",
        Default = false,
        Callback = function(Value)
            autoRespawn = Value
            if autoRespawn and humanoid then
                if connections.deathConnection then
                    connections.deathConnection:Disconnect()
                end
                connections.deathConnection = humanoid.Died:Connect(function()
                    safeWait(5)
                    pcall(function()
                        player:LoadCharacter()
                    end)
                end)
            else
                if connections.deathConnection then
                    connections.deathConnection:Disconnect()
                    connections.deathConnection = nil
                end
            end
        end
    })

    --------------------------------------------------------------------
    -- TAB GLOVES
    --------------------------------------------------------------------
    local GlovesTab = Window:MakeTab({
        Name = "Gloves",
        Icon = "rbxassetid://79608248053265",
        PremiumOnly = false
    })

    local glovesList = {
        "Default", "Replica", "Phase", "Space", "Detonator", "Woah", "Ice", "Fire",
        "Spiky", "Ghostwalker", "Diamond", "ZZZZZZZ", "Brick", "Snow", "Pull", "Flash",
        "Spring", "Swapper", "Bull", "Dice", "Ghost", "Thanos", "Stun",
        "Glitch", "Snowball", "fish", "🗿", "Obby", "Voodoo", "Leash", "Flamarang",
        "Extend", "Rock", "Gravity", "Lure", "Jebaited", "Tycoon", "Charge", "Baller",
        "Tableflip", "Booster", "Shield", "Track", "Goofy", "Elude",
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

    --------------------------------------------------------------------
    -- TAB MISC
    --------------------------------------------------------------------
    local MiscTab = Window:MakeTab({
        Name = "Misc",
        Icon = "rbxassetid://79608248053265",
        PremiumOnly = false
    })

    -- Anti AFK
    MiscTab:AddToggle({
        Name = "Anti AFK",
        Default = false,
        Callback = function(Value)
            antiAFK = Value
            if antiAFK then
                connections.antiAFK = RunService.Heartbeat:Connect(function()
                    if not antiAFK then return end
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end)
                end)
            else
                if connections.antiAFK then
                    connections.antiAFK:Disconnect()
                    connections.antiAFK = nil
                end
            end
        end
    })

    -- Chat Spam
    MiscTab:AddToggle({
        Name = "Chat Spam",
        Default = false,
        Callback = function(Value)
            chatSpam = Value
            if chatSpam then
                connections.chatSpam = RunService.Heartbeat:Connect(function()
                    if not chatSpam then return end
                    safeWait(2)
                    pcall(function()
                        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(spamMessage, "All")
                    end)
                end)
            else
                if connections.chatSpam then
                    connections.chatSpam:Disconnect()
                    connections.chatSpam = nil
                end
            end
        end
    })

    OrionLib:MakeNotification({
        Name = "GILONG Hub",
        Content = "Hub loaded successfully! Ready t
