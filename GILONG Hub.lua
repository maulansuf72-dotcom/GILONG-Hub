-- Death Ball - GILONG Hub Script (Fixed & Optimized)
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
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- Global Variables
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

-- Cooldowns and Timing
local lastParry = 0
local parryCooldown = 0.3
local lastAttack = 0
local attackCooldown = 0.1
local lastAFK = 0
local afkInterval = 30

-- ESP Storage
local espObjects = {}

-- Utility Functions
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("Error in function: " .. tostring(result))
    end
    return success, result
end

local function getBalls()
    local balls = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (
            obj.Name:lower():find("ball") or 
            obj.Name:lower():find("football") or
            obj.Name:lower():find("sphere") or
            obj.Parent and obj.Parent.Name:lower():find("ball")
        ) then
            -- Additional checks for ball properties
            if obj.Size.Magnitude > 1 and obj.Size.Magnitude < 20 then
                table.insert(balls, obj)
            end
        end
    end
    return balls
end

local function getDistance(part1, part2)
    if not part1 or not part2 then return math.huge end
    return (part1.Position - part2.Position).Magnitude
end

local function predictBallPath(ball, character)
    if not ball or not character or not character:FindFirstChild("HumanoidRootPart") then 
        return nil, nil 
    end

    local velocity = Vector3.new(0, 0, 0)
    
    -- Try multiple ways to get ball velocity
    if ball:FindFirstChild("BodyVelocity") then
        velocity = ball.BodyVelocity.Velocity
    elseif ball:FindFirstChild("AssemblyLinearVelocity") then
        velocity = ball.AssemblyLinearVelocity
    elseif ball.Velocity then
        velocity = ball.Velocity
    end

    if velocity.Magnitude < 1 then return nil, nil end

    local playerPos = character.HumanoidRootPart.Position
    local ballPos = ball.Position
    local distance = (playerPos - ballPos).Magnitude
    local timeToReach = distance / math.max(velocity.Magnitude, 1)
    
    local predictedPos = ballPos + (velocity * timeToReach)
    return predictedPos, timeToReach
end

local function isPlayerFacingBall(character, ball)
    if not character or not character:FindFirstChild("HumanoidRootPart") or not ball then
        return false
    end
    
    local hrp = character.HumanoidRootPart
    local ballDirection = (ball.Position - hrp.Position).Unit
    local lookDirection = hrp.CFrame.LookVector
    
    return ballDirection:Dot(lookDirection) > 0.3
end

-- Auto Parry System
local function performParry()
    local currentTime = tick()
    if currentTime - lastParry < parryCooldown then return false end
    
    lastParry = currentTime
    
    -- Add humanized delay
    if _G.humanizedParry then
        local randomDelay = _G.parryDelay + (math.random() * 0.05)
        task.wait(randomDelay)
    else
        task.wait(_G.parryDelay)
    end
    
    -- Try multiple parry methods
    safeCall(function()
        -- Key press method
        UserInputService:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.05)
        UserInputService:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
    
    -- Remote event method
    safeCall(function()
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and (
                remote.Name:lower():find("parry") or
                remote.Name:lower():find("deflect") or
                remote.Name:lower():find("block")
            ) then
                remote:FireServer()
            end
        end
    end)
    
    return true
end

local function autoParry()
    if not _G.autoParry then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    
    for _, ball in pairs(getBalls()) do
        local distance = getDistance(ball, hrp)
        
        if distance <= _G.parryRange then
            local predictedPos, timeToReach = predictBallPath(ball, character)
            
            if predictedPos and timeToReach then
                -- Check if ball is moving towards player
                local ballToPlayer = (hrp.Position - ball.Position).Unit
                local ballVelocity = Vector3.new(0, 0, 0)
                
                if ball:FindFirstChild("BodyVelocity") then
                    ballVelocity = ball.BodyVelocity.Velocity.Unit
                elseif ball.AssemblyLinearVelocity then
                    ballVelocity = ball.AssemblyLinearVelocity.Unit
                end
                
                local dot = ballToPlayer:Dot(ballVelocity)
                
                -- Improved parry conditions
                if dot > 0.4 and timeToReach < 1.5 and timeToReach > 0.1 then
                    if performParry() then
                        break -- Only parry one ball at a time
                    end
                end
            end
        end
    end
end

-- ESP System
local function clearESP()
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    espObjects = {}
end

local function createBallESP()
    if not _G.ballESP then return end
    
    for _, ball in pairs(getBalls()) do
        if ball and not ball:FindFirstChild("BallESP") then
            safeCall(function()
                local highlight = Instance.new("Highlight")
                highlight.Name = "BallESP"
                highlight.Parent = ball
                highlight.FillColor = Color3.new(1, 0.2, 0.2)
                highlight.OutlineColor = Color3.new(1, 0, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                table.insert(espObjects, highlight)
                
                -- Distance label
                local gui = Instance.new("BillboardGui")
                gui.Name = "BallDistance"
                gui.Parent = ball
                gui.Size = UDim2.new(0, 100, 0, 50)
                gui.StudsOffset = Vector3.new(0, 2, 0)
                
                local label = Instance.new("TextLabel")
                label.Parent = gui
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = "Ball"
                label.TextColor3 = Color3.new(1, 1, 1)
                label.TextScaled = true
                label.Font = Enum.Font.SourceSansBold
                
                table.insert(espObjects, gui)
            end)
        end
    end
end

local function createPlayerESP()
    if not _G.playerESP then return end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local character = plr.Character
            local hrp = character.HumanoidRootPart
            
            if not hrp:FindFirstChild("PlayerESP") then
                safeCall(function()
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "PlayerESP"
                    highlight.Parent = character
                    highlight.FillColor = Color3.new(0.2, 1, 0.2)
                    highlight.OutlineColor = Color3.new(0, 1, 0)
                    highlight.FillTransparency = 0.7
                    highlight.OutlineTransparency = 0
                    table.insert(espObjects, highlight)
                    
                    -- Player name label
                    local gui = Instance.new("BillboardGui")
                    gui.Name = "PlayerName"
                    gui.Parent = hrp
                    gui.Size = UDim2.new(0, 200, 0, 50)
                    gui.StudsOffset = Vector3.new(0, 3, 0)
                    
                    local label = Instance.new("TextLabel")
                    label.Parent = gui
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = plr.Name
                    label.TextColor3 = Color3.new(1, 1, 1)
                    label.TextScaled = true
                    label.Font = Enum.Font.SourceSansBold
                    
                    table.insert(espObjects, gui)
                end)
            end
        end
    end
end

-- Combat Functions
local function spamAttack()
    if not _G.spamAttack then return end
    
    local currentTime = tick()
    if currentTime - lastAttack < attackCooldown then return end
    
    lastAttack = currentTime
    
    safeCall(function()
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and (
                remote.Name:lower():find("attack") or 
                remote.Name:lower():find("swing") or
                remote.Name:lower():find("hit") or
                remote.Name:lower():find("punch")
            ) then
                remote:FireServer()
            end
        end
    end)
end

-- Character Enhancements
local function applyCharacterEnhancements()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    safeCall(function()
        if _G.speedBoost then
            humanoid.WalkSpeed = _G.speedValue
        else
            humanoid.WalkSpeed = 16
        end
        
        if _G.jumpPower then
            if humanoid:FindFirstChild("JumpHeight") then
                humanoid.JumpHeight = _G.jumpValue
            else
                humanoid.JumpPower = _G.jumpValue
            end
        else
            if humanoid:FindFirstChild("JumpHeight") then
                humanoid.JumpHeight = 7.2
            else
                humanoid.JumpPower = 50
            end
        end
    end)
end

-- Anti-AFK System
local function antiAFK()
    if not _G.antiAFK then return end
    
    local currentTime = tick()
    if currentTime - lastAFK < afkInterval then return end
    
    lastAFK = currentTime
    
    safeCall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- Main Loop
local heartbeatConnection
heartbeatConnection = RunService.Heartbeat:Connect(function()
    safeCall(autoParry)
    safeCall(createBallESP)
    safeCall(createPlayerESP)
    safeCall(spamAttack)
    safeCall(applyCharacterEnhancements)
    safeCall(antiAFK)
end)

-- Cleanup on player leaving
Players.PlayerRemoving:Connect(function(plr)
    if plr == player then
        clearESP()
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
        end
    end
end)

-- GUI Elements
mainTab:CreateToggle({
   Name = "Auto Parry",
   CurrentValue = false,
   Flag = "AutoParry",
   Callback = function(value)
       _G.autoParry = value
   end
})

mainTab:CreateSlider({
   Name = "Parry Range",
   Range = {5, 50},
   Increment = 1,
   CurrentValue = 20,
   Flag = "ParryRange",
   Callback = function(value)
       _G.parryRange = value
   end
})

mainTab:CreateSlider({
   Name = "Parry Delay",
   Range = {0, 0.5},
   Increment = 0.01,
   CurrentValue = 0.1,
   Flag = "ParryDelay",
   Callback = function(value)
       _G.parryDelay = value
   end
})

mainTab:CreateToggle({
   Name = "Humanized Parry",
   CurrentValue = true,
   Flag = "HumanizedParry",
   Callback = function(value)
       _G.humanizedParry = value
   end
})

combatTab:CreateToggle({
   Name = "Spam Attack",
   CurrentValue = false,
   Flag = "SpamAttack",
   Callback = function(value)
       _G.spamAttack = value
   end
})

visualTab:CreateToggle({
   Name = "Ball ESP",
   CurrentValue = false,
   Flag = "BallESP",
   Callback = function(value)
       _G.ballESP = value
       if not value then
           clearESP()
       end
   end
})

visualTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "PlayerESP",
   Callback = function(value)
       _G.playerESP = value
       if not value then
           clearESP()
       end
   end
})

utilityTab:CreateToggle({
   Name = "Speed Boost",
   CurrentValue = false,
   Flag = "SpeedBoost",
   Callback = function(value)
       _G.speedBoost = value
   end
})

utilityTab:CreateSlider({
   Name = "Speed Value",
   Range = {16, 100},
   Increment = 1,
   CurrentValue = 50,
   Flag = "SpeedValue",
   Callback = function(value)
       _G.speedValue = value
   end
})

utilityTab:CreateToggle({
   Name = "Jump Power Boost",
   CurrentValue = false,
   Flag = "JumpPower",
   Callback = function(value)
       _G.jumpPower = value
   end
})

utilityTab:CreateSlider({
   Name = "Jump Value",
   Range = {50, 200},
   Increment = 1,
   CurrentValue = 120,
   Flag = "JumpValue",
   Callback = function(value)
       _G.jumpValue = value
   end
})

utilityTab:CreateToggle({
   Name = "Anti-AFK",
   CurrentValue = false,
   Flag = "AntiAFK",
   Callback = function(value)
       _G.antiAFK = value
   end
})

-- Notification
Rayfield:Notify({
   Title = "GILONG Hub Loaded!",
   Content = "Death Ball Script ready to use ✅",
   Duration = 5,
   Image = 4483362458,
   Actions = {
      Ignore = {
         Name = "Okay!",
         Callback = function()
            print("Script loaded successfully!")
         end
      },
   },
})

print("GILONG Hub Death Ball Script loaded successfully!")
