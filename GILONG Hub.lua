-- Death Ball - GILONG Hub Script (Optimized)
-- Auto Parry System with Advanced Features

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "GILONG Hub",
   Icon = 0,
   LoadingTitle = "Death Ball Script",
   LoadingSubtitle = "by GILONG Hub",
   ShowText = "Rayfield",
   Theme = "Default",
   ToggleUIKeybind = Enum.KeyCode.K,
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "GILONGHub_DeathBall"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "GILONG Hub | Key",
      Subtitle = "Key System",
      Note = "https://link-hub.net/1392772/AfVHcFNYkLMx",
      FileName = "GILONGHubKey",
      SaveKey = false,
      GrabKeyFromSite = true,
      Key = {"AyamGoreng!"}
   }
})

-- Tabs
local mainTab = Window:CreateTab("Auto Parry", nil)
local combatTab = Window:CreateTab("Combat", nil)
local visualTab = Window:CreateTab("Visuals", nil)
local utilityTab = Window:CreateTab("Utility", nil)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Global Vars
_G.autoParry = false
_G.parryRange = 20
_G.parryDelay = 0.1
_G.humanizedParry = true
_G.ballESP = false
_G.playerESP = false
_G.spamAttack = false
_G.autoDodge = false
_G.speedBoost = false
_G.jumpPower = false
_G.antiRagdoll = false
_G.speedValue = 50
_G.jumpValue = 120
_G.antiAFK = false

-- Cooldowns
local lastParry = 0
local parryCooldown = 0.3

-- Utils
local function getBalls()
    local balls = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("ball") then
            table.insert(balls, obj)
        end
    end
    return balls
end

local function getDistance(part1, part2)
    if not part1 or not part2 then return math.huge end
    return (part1.Position - part2.Position).Magnitude
end

local function predictBallPath(ball, character)
    if not ball or not ball:FindFirstChild("BodyVelocity") then return nil end
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

    local velocity = ball.BodyVelocity.Velocity
    local playerPos = character.HumanoidRootPart.Position
    local timeToReach = getDistance(ball, character.HumanoidRootPart) / math.max(velocity.Magnitude, 1)
    return ball.Position + (velocity * timeToReach), timeToReach
end

-- Auto Parry
local function autoParry()
    if not _G.autoParry then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    for _, ball in pairs(getBalls()) do
        local distance = getDistance(ball, character.HumanoidRootPart)
        if distance <= _G.parryRange then
            local predictedPos, timeToReach = predictBallPath(ball, character)
            if predictedPos and timeToReach and tick() - lastParry > parryCooldown then
                local ballDir = (character.HumanoidRootPart.Position - ball.Position).Unit
                local ballVel = (ball.BodyVelocity and ball.BodyVelocity.Velocity.Unit) or Vector3.zero
                local dot = ballDir:Dot(ballVel)

                if dot > 0.5 and timeToReach < 1 then
                    lastParry = tick()
                    if _G.humanizedParry then
                        task.wait(_G.parryDelay + math.random() * 0.05)
                    else
                        task.wait(_G.parryDelay)
                    end
                    -- Key press
                    pcall(function()
                        UserInputService:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                        task.wait(0.05)
                        UserInputService:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                    end)
                    -- Remote Parry
                    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and remote.Name:lower():find("parry") then
                            pcall(function() remote:FireServer() end)
                        end
                    end
                    break
                end
            end
        end
    end
end

-- ESP Manager
local function clearESP()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Highlight") or v:IsA("BillboardGui") then
            if v.Name == "BallESP" or v.Name == "PlayerESP" or v.Name == "BallDistance" or v.Name == "PlayerName" then
                v:Destroy()
            end
        end
    end
end

local function ballESP()
    if not _G.ballESP then return end
    for _, ball in pairs(getBalls()) do
        if ball and not ball:FindFirstChild("BallESP") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "BallESP"
            highlight.Parent = ball
            highlight.FillColor = Color3.new(1, 0, 0)
            highlight.FillTransparency = 0.5
        end
    end
end

local function playerESP()
    if not _G.playerESP then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            if not hrp:FindFirstChild("PlayerESP") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "PlayerESP"
                highlight.Parent = hrp
                highlight.FillColor = Color3.new(0, 1, 0)
                highlight.FillTransparency = 0.7
            end
        end
    end
end

-- Spam Attack
local function spamAttack()
    if not _G.spamAttack then return end
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (remote.Name:lower():find("attack") or remote.Name:lower():find("swing")) then
            pcall(function() remote:FireServer() end)
        end
    end
end

-- Enhancements
local function characterEnhancements()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")

    if humanoid then
        humanoid.WalkSpeed = _G.speedBoost and _G.speedValue or 16
        humanoid.JumpPower = _G.jumpPower and _G.jumpValue or 50
    end
end

-- Anti-AFK
local function antiAFK()
    if not _G.antiAFK then return end
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end

-- Main Loop
RunService.Heartbeat:Connect(function()
    pcall(function()
        autoParry()
        ballESP()
        playerESP()
        spamAttack()
        characterEnhancements()
        antiAFK()
    end)
end)

-- GUI (contoh toggle & slider)
mainTab:CreateToggle({
   Name = "Auto Parry",
   CurrentValue = false,
   Callback = function(v) _G.autoParry = v end
})
mainTab:CreateSlider({
   Name = "Parry Range",
   Range = {5, 50},
   CurrentValue = 20,
   Callback = function(v) _G.parryRange = v end
})
mainTab:CreateSlider({
   Name = "Parry Delay",
   Range = {0, 0.5},
   Increment = 0.01,
   CurrentValue = 0.1,
   Callback = function(v) _G.parryDelay = v end
})
mainTab:CreateToggle({
   Name = "Humanized Parry",
   CurrentValue = true,
   Callback = function(v) _G.humanizedParry = v end
})

combatTab:CreateToggle({
   Name = "Spam Attack",
   CurrentValue = false,
   Callback = function(v) _G.spamAttack = v end
})

visualTab:CreateToggle({
   Name = "Ball ESP",
   CurrentValue = false,
   Callback = function(v) _G.ballESP = v if not v then clearESP() end end
})
visualTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Callback = function(v) _G.playerESP = v if not v then clearESP() end end
})

utilityTab:CreateToggle({
   Name = "Speed Boost",
   CurrentValue = false,
   Callback = function(v) _G.speedBoost = v end
})
utilityTab:CreateSlider({
   Name = "Speed Value",
   Range = {16, 100},
   CurrentValue = 50,
   Callback = function(v) _G.speedValue = v end
})
utilityTab:CreateToggle({
   Name = "Jump Power",
   CurrentValue = false,
   Callback = function(v) _G.jumpPower = v end
})
utilityTab:CreateSlider({
   Name = "Jump Value",
   Range = {50, 200},
   CurrentValue = 120,
   Callback = function(v) _G.jumpValue = v end
})
utilityTab:CreateToggle({
   Name = "Anti-AFK",
   CurrentValue = false,
   Callback = function(v) _G.antiAFK = v end
})

Rayfield:Notify({
   Title = "GILONG Hub Loaded!",
   Content = "Death Ball Script siap dipakai ✅",
   Duration = 5,
})
