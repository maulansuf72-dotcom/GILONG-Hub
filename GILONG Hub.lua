-- Death Ball - GILONG Hub Script
-- Auto Parry System with Advanced Features

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "GILONG Hub",
   Icon = 0,
   LoadingTitle = "Death Ball Script",
   LoadingSubtitle = "by GILONG Hub",
   ShowText = "Rayfield",
   Theme = "Default",
   ToggleUIKeybind = "K",
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
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Global Variables
_G.autoParry = false
_G.parryRange = 20
_G.parryDelay = 0.1
_G.humanizedParry = true
_G.ballESP = false
_G.playerESP = false
_G.trajectoryLines = false
_G.spamAttack = false
_G.autoDodge = false
_G.speedBoost = false
_G.jumpPower = false
_G.antiRagdoll = false
_G.speedValue = 50
_G.jumpValue = 120

-- Utility Functions
local function getBalls()
    local balls = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("ball") and obj:IsA("BasePart") and obj:FindFirstChild("BodyVelocity") then
            table.insert(balls, obj)
        elseif obj.Name == "DeathBall" or obj.Name == "Ball" then
            table.insert(balls, obj)
        end
    end
    return balls
end

local function getDistance(part1, part2)
    if not part1 or not part2 then return math.huge end
    return (part1.Position - part2.Position).Magnitude
end

local function predictBallPath(ball)
    if not ball or not ball:FindFirstChild("BodyVelocity") then return nil end
    
    local velocity = ball.BodyVelocity.Velocity
    local currentPos = ball.Position
    local character = player.Character
    
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local playerPos = character.HumanoidRootPart.Position
    
    -- Simple prediction - where ball will be in next frame
    local timeToReach = getDistance(ball, character.HumanoidRootPart) / velocity.Magnitude
    local predictedPos = currentPos + (velocity * timeToReach)
    
    return predictedPos, timeToReach
end

-- Auto Parry System
local function autoParry()
    if not _G.autoParry then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local balls = getBalls()
    
    for _, ball in pairs(balls) do
        if ball and ball.Parent then
            local distance = getDistance(ball, character.HumanoidRootPart)
            
            if distance <= _G.parryRange then
                local predictedPos, timeToReach = predictBallPath(ball)
                
                if predictedPos and timeToReach then
                    -- Check if ball is heading towards player
                    local ballToPlayer = (character.HumanoidRootPart.Position - ball.Position).Unit
                    local ballVelocity = ball.BodyVelocity and ball.BodyVelocity.Velocity.Unit or Vector3.new(0,0,0)
                    local dot = ballToPlayer:Dot(ballVelocity)
                    
                    if dot > 0.5 and timeToReach < 1 then -- Ball is coming towards player
                        -- Add humanized delay if enabled
                        if _G.humanizedParry then
                            wait(_G.parryDelay + math.random(0, 0.05))
                        else
                            wait(_G.parryDelay)
                        end
                        
                        -- Execute parry
                        UserInputService:SimulateKeyPress(Enum.KeyCode.F)
                        
                        -- Try alternative parry methods
                        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                            if remote:IsA("RemoteEvent") and remote.Name:lower():find("parry") then
                                pcall(function()
                                    remote:FireServer()
                                end)
                            end
                        end
                        
                        -- Visual feedback
                        if _G.ballESP then
                            ball.BrickColor = BrickColor.new("Bright green")
                            ball.Material = Enum.Material.Neon
                        end
                        
                        break -- Only parry one ball at a time
                    end
                end
            end
        end
    end
end

-- Ball ESP
local function ballESP()
    if not _G.ballESP then return end
    
    local balls = getBalls()
    
    for _, ball in pairs(balls) do
        if ball and not ball:FindFirstChild("BallESP") then
            -- Create highlight
            local highlight = Instance.new("Highlight")
            highlight.Name = "BallESP"
            highlight.Parent = ball
            highlight.FillColor = Color3.new(1, 0, 0)
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            
            -- Create distance label
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Name = "BallDistance"
            billboardGui.Parent = ball
            billboardGui.Size = UDim2.new(0, 100, 0, 50)
            billboardGui.StudsOffset = Vector3.new(0, 2, 0)
            billboardGui.AlwaysOnTop = true
            
            local label = Instance.new("TextLabel")
            label.Parent = billboardGui
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "BALL"
            label.TextColor3 = Color3.new(1, 0, 0)
            label.TextScaled = true
            label.Font = Enum.Font.GothamBold
            
            -- Update distance
            spawn(function()
                while ball and ball.Parent and _G.ballESP do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = math.floor(getDistance(ball, player.Character.HumanoidRootPart))
                        label.Text = "BALL\n" .. distance .. "m"
                        
                        -- Color based on distance
                        if distance < _G.parryRange then
                            highlight.FillColor = Color3.new(1, 1, 0) -- Yellow when in range
                            label.TextColor3 = Color3.new(1, 1, 0)
                        else
                            highlight.FillColor = Color3.new(1, 0, 0) -- Red when far
                            label.TextColor3 = Color3.new(1, 0, 0)
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
end

-- Remove ESP
local function removeESP()
    for _, obj in pairs(Workspace:GetDescendants()) do
        local esp = obj:FindFirstChild("BallESP")
        local distance = obj:FindFirstChild("BallDistance")
        local playerESP = obj:FindFirstChild("PlayerESP")
        
        if esp then esp:Destroy() end
        if distance then distance:Destroy() end
        if playerESP then playerESP:Destroy() end
    end
end

-- Player ESP
local function playerESP()
    if not _G.playerESP then return end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local character = plr.Character
            local humanoidRootPart = character.HumanoidRootPart
            
            if not humanoidRootPart:FindFirstChild("PlayerESP") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "PlayerESP"
                highlight.Parent = character
                highlight.FillColor = Color3.new(0, 1, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.7
                
                local billboardGui = Instance.new("BillboardGui")
                billboardGui.Name = "PlayerName"
                billboardGui.Parent = humanoidRootPart
                billboardGui.Size = UDim2.new(0, 100, 0, 30)
                billboardGui.StudsOffset = Vector3.new(0, 3, 0)
                billboardGui.AlwaysOnTop = true
                
                local label = Instance.new("TextLabel")
                label.Parent = billboardGui
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = plr.Name
                label.TextColor3 = Color3.new(0, 1, 0)
                label.TextScaled = true
                label.Font = Enum.Font.Gotham
            end
        end
    end
end

-- Spam Attack
local function spamAttack()
    if not _G.spamAttack then return end
    
    -- Hold E for attack spam
    UserInputService:SimulateKeyPress(Enum.KeyCode.E)
    
    -- Try remote events for attacks
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:find("attack") or name:find("swing") or name:find("hit") then
                pcall(function()
                    remote:FireServer()
                end)
            end
        end
    end
end

-- Auto Dodge
local function autoDodge()
    if not _G.autoDodge then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local balls = getBalls()
    
    for _, ball in pairs(balls) do
        if ball then
            local distance = getDistance(ball, character.HumanoidRootPart)
            
            if distance < 15 then -- Dodge when ball is very close
                local predictedPos, timeToReach = predictBallPath(ball)
                
                if predictedPos and timeToReach < 0.5 then
                    -- Dodge by moving perpendicular to ball direction
                    local ballDirection = (ball.Position - character.HumanoidRootPart.Position).Unit
                    local dodgeDirection = Vector3.new(-ballDirection.Z, 0, ballDirection.X) -- Perpendicular
                    
                    local dodgePosition = character.HumanoidRootPart.Position + (dodgeDirection * 10)
                    character.HumanoidRootPart.CFrame = CFrame.new(dodgePosition)
                end
            end
        end
    end
end

-- Character Enhancements
local function characterEnhancements()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid then
        -- Speed boost
        if _G.speedBoost then
            humanoid.WalkSpeed = _G.speedValue
        else
            humanoid.WalkSpeed = 16
        end
        
        -- Jump power
        if _G.jumpPower then
            humanoid.JumpPower = _G.jumpValue
        else
            humanoid.JumpPower = 50
        end
    end
    
    -- Anti-ragdoll
    if _G.antiRagdoll and humanoidRootPart then
        humanoidRootPart.Anchored = false
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part ~= humanoidRootPart then
                part.CanCollide = false
            end
        end
    end
end

-- Main Loop
local function mainLoop()
    _G.mainConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            autoParry()
            ballESP()
            playerESP()
            spamAttack()
            autoDodge()
            characterEnhancements()
        end)
    end)
end

-- GUI Elements

-- Auto Parry Tab
local parryToggle = mainTab:CreateToggle({
   Name = "Auto Parry",
   CurrentValue = false,
   Flag = "AutoParryToggle",
   Callback = function(Value)
       _G.autoParry = Value
       if Value then
           Rayfield:Notify({
               Title = "Auto Parry Enabled!",
               Content = "Frame-perfect parrying activated",
               Duration = 3,
           })
       else
           Rayfield:Notify({
               Title = "Auto Parry Disabled",
               Content = "Manual parrying required",
               Duration = 3,
           })
       end
   end,
})

local parryRangeSlider = mainTab:CreateSlider({
    Name = "Parry Range",
    Range = {5, 50},
    Increment = 5,
    Suffix = " studs",
    CurrentValue = 20,
    Flag = "ParryRangeSlider",
    Callback = function(Value)
        _G.parryRange = Value
    end,
})

local parryDelaySlider = mainTab:CreateSlider({
    Name = "Parry Delay",
    Range = {0, 0.5},
    Increment = 0.01,
    Suffix = " seconds",
    CurrentValue = 0.1,
    Flag = "ParryDelaySlider",
    Callback = function(Value)
        _G.parryDelay = Value
    end,
})

local humanizedToggle = mainTab:CreateToggle({
   Name = "Humanized Parry",
   CurrentValue = true,
   Flag = "HumanizedToggle",
   Callback = function(Value)
       _G.humanizedParry = Value
   end,
})

-- Combat Tab
local spamToggle = combatTab:CreateToggle({
   Name = "Spam Attack",
   CurrentValue = false,
   Flag = "SpamToggle",
   Callback = function(Value)
       _G.spamAttack = Value
       if Value then
           Rayfield:Notify({
               Title = "Spam Attack Enabled",
               Content = "Rapid attacking activated",
               Duration = 3,
           })
       end
   end,
})

local dodgeToggle = combatTab:CreateToggle({
   Name = "Auto Dodge",
   CurrentValue = false,
   Flag = "DodgeToggle",
   Callback = function(Value)
       _G.autoDodge = Value
       if Value then
           Rayfield:Notify({
               Title = "Auto Dodge Enabled",
               Content = "Smart dodging activated",
               Duration = 3,
           })
       end
   end,
})

-- Visual Tab
local ballESPToggle = visualTab:CreateToggle({
   Name = "Ball ESP",
   CurrentValue = false,
   Flag = "BallESPToggle",
   Callback = function(Value)
       _G.ballESP = Value
       if not Value then
           removeESP()
       end
   end,
})

local playerESPToggle = visualTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "PlayerESPToggle",
   Callback = function(Value)
       _G.playerESP = Value
       if not Value then
           removeESP()
       end
   end,
})

-- Utility Tab
local speedToggle = utilityTab:CreateToggle({
   Name = "Speed Boost",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
       _G.speedBoost = Value
   end,
})

local speedSlider = utilityTab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 100},
    Increment = 5,
    Suffix = " Speed",
    CurrentValue = 50,
    Flag = "SpeedSlider",
    Callback = function(Value)
        _G.speedValue = Value
    end,
})

local jumpToggle = utilityTab:CreateToggle({
   Name = "Jump Power",
   CurrentValue = false,
   Flag = "JumpToggle",
   Callback = function(Value)
       _G.jumpPower = Value
   end,
})

local jumpSlider = utilityTab:CreateSlider({
    Name = "Jump Value",
    Range = {50, 200},
    Increment = 10,
    Suffix = " Power",
    CurrentValue = 120,
    Flag = "JumpSlider",
    Callback = function(Value)
        _G.jumpValue = Value
    end,
})

local ragdollToggle = utilityTab:CreateToggle({
   Name = "Anti-Ragdoll",
   CurrentValue = false,
   Flag = "RagdollToggle",
   Callback = function(Value)
       _G.antiRagdoll = Value
       if Value then
           Rayfield:Notify({
               Title = "Anti-Ragdoll Enabled",
               Content = "Ragdoll protection activated",
               Duration = 3,
           })
       end
   end,
})

-- Anti-AFK
local afkToggle = utilityTab:CreateToggle({
   Name = "Anti-AFK",
   CurrentValue = false,
   Flag = "AFKToggle",
   Callback = function(Value)
       if Value then
           _G.afkConnection = RunService.Heartbeat:Connect(function()
               local VirtualUser = game:GetService("VirtualUser")
               VirtualUser:CaptureController()
               VirtualUser:ClickButton2(Vector2.new())
           end)
       else
           if _G.afkConnection then
               _G.afkConnection:Disconnect()
           end
       end
   end,
})

-- Start main loop
mainLoop()

-- Handle character respawning
player.CharacterAdded:Connect(function()
    wait(1) -- Wait for character to fully load
    if _G.mainConnection then
        _G.mainConnection:Disconnect()
    end
    mainLoop()
end)

Rayfield:Notify({
   Title = "GILONG Hub Loaded!",
   Content = "Death Ball script ready - Auto Parry activated",
   Duration = 5,
})
