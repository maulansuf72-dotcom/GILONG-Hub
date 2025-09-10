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
    
    -- Death Ball specific ball detection
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            -- Check for Death Ball specific names and properties
            local name = obj.Name:lower()
            if name:find("ball") or name:find("football") or name:find("sphere") or 
               name == "part" or name == "union" or name == "meshpart" then
                
                -- Death Ball balls usually have these properties
                local hasVelocity = obj:FindFirstChild("BodyVelocity") or 
                                  obj:FindFirstChild("BodyPosition") or 
                                  obj:FindFirstChild("BodyAngularVelocity") or
                                  obj.AssemblyLinearVelocity.Magnitude > 0
                
                -- Size check for Death Ball (usually around 4-8 studs)
                local sizeCheck = obj.Size.Magnitude > 2 and obj.Size.Magnitude < 15
                
                -- Material check (Death Ball balls are often Neon or ForceField)
                local materialCheck = obj.Material == Enum.Material.Neon or 
                                    obj.Material == Enum.Material.ForceField or
                                    obj.Material == Enum.Material.Glass
                
                -- Color check (Death Ball balls are often bright colors)
                local colorCheck = obj.Color.R > 0.5 or obj.Color.G > 0.5 or obj.Color.B > 0.5
                
                if (hasVelocity or materialCheck or colorCheck) and sizeCheck then
                    table.insert(balls, obj)
                end
            end
        end
    end
    
    -- Fallback: check Workspace.Balls folder if exists
    if Workspace:FindFirstChild("Balls") then
        for _, ball in pairs(Workspace.Balls:GetChildren()) do
            if ball:IsA("BasePart") then
                table.insert(balls, ball)
            end
        end
    end
    
    -- Another fallback: check for moving parts
    if #balls == 0 then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.AssemblyLinearVelocity.Magnitude > 10 then
                local size = obj.Size.Magnitude
                if size > 2 and size < 15 then
                    table.insert(balls, obj)
                end
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
    
    -- Try multiple ways to get ball velocity (Death Ball specific)
    if ball:FindFirstChild("BodyVelocity") then
        velocity = ball.BodyVelocity.Velocity
    elseif ball:FindFirstChild("BodyPosition") then
        -- Some Death Ball versions use BodyPosition
        local bodyPos = ball.BodyPosition
        local currentPos = ball.Position
        velocity = (bodyPos.Position - currentPos) * 2 -- Estimate velocity
    elseif ball.AssemblyLinearVelocity then
        velocity = ball.AssemblyLinearVelocity
    elseif ball.Velocity then
        velocity = ball.Velocity
    else
        -- Fallback: calculate velocity from position change
        if not ball:GetAttribute("LastPosition") then
            ball:SetAttribute("LastPosition", ball.Position)
            return nil, nil
        end
        
        local lastPos = ball:GetAttribute("LastPosition")
        local currentPos = ball.Position
        velocity = (currentPos - lastPos) * 60 -- Assuming 60 FPS
        ball:SetAttribute("LastPosition", currentPos)
    end

    if velocity.Magnitude < 5 then return nil, nil end -- Increased minimum velocity

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
    
    -- Try multiple parry methods for Death Ball
    safeCall(function()
        -- Key press method (F key for parry)
        UserInputService:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.05)
        UserInputService:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
    
    -- Death Ball specific remote events
    safeCall(function()
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:find("parry") or name:find("deflect") or name:find("block") or
                   name:find("counter") or name:find("reflect") or name == "remote" or
                   name == "re" or name == "r" or name:find("ball") then
                    remote:FireServer()
                    remote:FireServer(true)
                    remote:FireServer("parry")
                    remote:FireServer({["parry"] = true})
                end
            end
        end
    end)
    
    -- Try ReplicatedFirst remotes
    safeCall(function()
        local repFirst = game:GetService("ReplicatedFirst")
        for _, remote in pairs(repFirst:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:find("parry") or name:find("deflect") or name:find("block") then
                    remote:FireServer()
                end
            end
        end
    end)
    
    -- Try StarterPlayer remotes
    safeCall(function()
        local starterPlayer = game:GetService("StarterPlayer")
        for _, remote in pairs(starterPlayer:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:find("parry") or name:find("deflect") or name:find("block") then
                    remote:FireServer()
                end
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
                -- Check if ball is moving towards player (Death Ball specific)
                local ballToPlayer = (hrp.Position - ball.Position).Unit
                local ballVelocity = Vector3.new(0, 0, 0)
                
                if ball:FindFirstChild("BodyVelocity") then
                    ballVelocity = ball.BodyVelocity.Velocity
                elseif ball.AssemblyLinearVelocity then
                    ballVelocity = ball.AssemblyLinearVelocity
                elseif ball:GetAttribute("LastPosition") then
                    local lastPos = ball:GetAttribute("LastPosition")
                    ballVelocity = (ball.Position - lastPos) * 60
                end
                
                if ballVelocity.Magnitude > 0 then
                    ballVelocity = ballVelocity.Unit
                    local dot = ballToPlayer:Dot(ballVelocity)
                    
                    -- More lenient parry conditions for Death Ball
                    local distanceCondition = distance <= _G.parryRange
                    local velocityCondition = dot > 0.2 -- More lenient angle
                    local timeCondition = timeToReach < 2 and timeToReach > 0.05
                    local speedCondition = ballVelocity.Magnitude > 0.1
                    
                    if distanceCondition and (velocityCondition or distance < 8) and timeCondition then
                        if performParry() then
                            break -- Only parry one ball at a time
                        end
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
        -- Death Ball specific attack remotes
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:find("attack") or name:find("swing") or name:find("hit") or
                   name:find("punch") or name:find("kick") or name:find("shoot") or
                   name == "remote" or name == "re" or name == "r" then
                    remote:FireServer()
                    remote:FireServer("attack")
                    remote:FireServer(true)
                end
            end
        end
        
        -- Try key press for attack (usually Space or Click)
        UserInputService:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        UserInputService:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
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

-- Debug function to help identify issues
local function debugInfo()
    if not _G.autoParry then return end
    
    local balls = getBalls()
    if #balls > 0 then
        print("[DEBUG] Found", #balls, "balls")
        for i, ball in pairs(balls) do
            print("[DEBUG] Ball", i, ":", ball.Name, "Position:", ball.Position, "Velocity:", ball.AssemblyLinearVelocity.Magnitude)
        end
    else
        print("[DEBUG] No balls detected")
    end
    
    -- Check for remotes
    local remoteCount = 0
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            remoteCount = remoteCount + 1
        end
    end
    print("[DEBUG] Found", remoteCount, "RemoteEvents in ReplicatedStorage")
end

-- Main Loop
local heartbeatConnection
local debugTimer = 0
heartbeatConnection = RunService.Heartbeat:Connect(function()
    safeCall(autoParry)
    safeCall(createBallESP)
    safeCall(createPlayerESP)
    safeCall(spamAttack)
    safeCall(applyCharacterEnhancements)
    safeCall(antiAFK)
    
    -- Debug info every 5 seconds
    debugTimer = debugTimer + 1
    if debugTimer >= 300 then -- 60 FPS * 5 seconds
        debugTimer = 0
        safeCall(debugInfo)
    end
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

utilityTab:CreateButton({
   Name = "Debug Info",
   Callback = function()
       debugInfo()
       
       -- Print all RemoteEvents for manual inspection
       print("=== ALL REMOTE EVENTS ===")
       for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
           if remote:IsA("RemoteEvent") then
               print("Remote:", remote.Name, "Path:", remote:GetFullName())
           end
       end
       print("========================")
   end
})

utilityTab:CreateButton({
   Name = "Force Parry Test",
   Callback = function()
       print("[TEST] Attempting force parry...")
       performParry()
       print("[TEST] Force parry completed")
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
print("[INFO] Use Debug Info button to check ball detection")
print("[INFO] Use Force Parry Test to test parry function")
print("[INFO] Auto debug info will print every 5 seconds when Auto Parry is enabled")
