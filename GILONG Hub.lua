-- Blue Lock Rivals - Ultimate Script Hub
-- Created by GILONG Hub | All Features Included

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "GILONG Hub | Blue Lock Rivals",
   Icon = 0,
   LoadingTitle = "Blue Lock Rivals Script",
   LoadingSubtitle = "Ultimate Soccer Domination",
   ShowText = "GILONG Hub",
   Theme = "Ocean",
   ToggleUIKeybind = Enum.KeyCode.RightControl,
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "GILONGHub",
      FileName = "BlueLockRivals_Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "GILONG Hub | Blue Lock Rivals",
      Subtitle = "Enter Access Key",
      Note = "Get your key from: https://link-hub.net/1392772/BlueLockKey",
      FileName = "GILONGHub_BlueLock",
      SaveKey = true,
      GrabKeyFromSite = true,
      Key = {"BlueLockChampion2024!", "SoccerKing123", "GoalMaster456"}
   }
})

-- Create Tabs
local ballTab = Window:CreateTab("⚽ Ball Control", nil)
local movementTab = Window:CreateTab("🏃‍♂️ Movement", nil)
local shootingTab = Window:CreateTab("🥅 Shooting", nil)
local playerTab = Window:CreateTab("👥 Players", nil)
local autoTab = Window:CreateTab("🤖 Automation", nil)
local utilityTab = Window:CreateTab("🔧 Utility", nil)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Global Variables
_G.ballMagnet = false
_G.ballMagnetRange = 15
_G.autoShoot = false
_G.perfectAim = false
_G.ballESP = false
_G.autoSteal = false
_G.speedBoost = false
_G.speedValue = 25
_G.infiniteStamina = false
_G.autoSprint = false
_G.teleportToBall = false
_G.playerESP = false
_G.teamESP = false
_G.goalESP = false
_G.autoPlay = false
_G.autoDefend = false
_G.flyHack = false
_G.flySpeed = 50
_G.noclip = false
_G.clickTP = false
_G.skillSpam = false
_G.antiAFK = false
_G.powerShot = false
_G.autoPass = false
_G.positionLock = false

-- Storage
local espObjects = {}
local connections = {}
local originalValues = {}

-- Utility Functions
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[Blue Lock] Error: " .. tostring(result))
    end
    return success, result
end

local function getDistance(part1, part2)
    if not part1 or not part2 then return math.huge end
    return (part1.Position - part2.Position).Magnitude
end

local function getBall()
    -- Multiple ways to find the ball in Blue Lock Rivals
    local ball = nil
    
    -- Method 1: Check for common ball names
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (
            obj.Name:lower():find("ball") or
            obj.Name:lower():find("football") or
            obj.Name:lower():find("soccer")
        ) then
            if obj.Size.Magnitude > 1 and obj.Size.Magnitude < 10 then
                ball = obj
                break
            end
        end
    end
    
    -- Method 2: Check for moving spherical objects
    if not ball then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Shape == Enum.PartType.Ball then
                if obj.Size.X > 1 and obj.Size.X < 5 then
                    ball = obj
                    break
                end
            end
        end
    end
    
    -- Method 3: Check Workspace.Ball or similar folders
    local ballFolder = Workspace:FindFirstChild("Ball") or Workspace:FindFirstChild("Balls")
    if ballFolder and not ball then
        for _, obj in pairs(ballFolder:GetChildren()) do
            if obj:IsA("BasePart") then
                ball = obj
                break
            end
        end
    end
    
    return ball
end

local function getGoals()
    local goals = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (
            obj.Name:lower():find("goal") or
            obj.Name:lower():find("net") or
            obj.Parent and obj.Parent.Name:lower():find("goal")
        ) then
            table.insert(goals, obj)
        end
    end
    return goals
end

local function getPlayers()
    local playersList = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(playersList, plr)
        end
    end
    return playersList
end

-- Ball Control Features
local function ballMagnet()
    if not _G.ballMagnet then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local ball = getBall()
    if not ball then return end
    
    local distance = getDistance(ball, character.HumanoidRootPart)
    if distance <= _G.ballMagnetRange then
        safeCall(function()
            local direction = (character.HumanoidRootPart.Position - ball.Position).Unit
            local targetPos = character.HumanoidRootPart.Position + (direction * 3)
            
            if ball:FindFirstChild("BodyVelocity") then
                ball.BodyVelocity.Velocity = direction * 20
            else
                local bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
                bodyVel.Velocity = direction * 20
                bodyVel.Parent = ball
                
                game:GetService("Debris"):AddItem(bodyVel, 0.1)
            end
        end)
    end
end

local function autoSteal()
    if not _G.autoSteal then return end
    
    local character = player.Character
    if not character then return end
    
    local ball = getBall()
    if not ball then return end
    
    -- Find closest opponent with ball
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, plr in pairs(getPlayers()) do
        local distance = getDistance(ball, plr.Character.HumanoidRootPart)
        if distance < 10 and distance < closestDistance then
            closestDistance = distance
            closestPlayer = plr
        end
    end
    
    if closestPlayer then
        safeCall(function()
            -- Try to find steal/tackle remotes
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and (
                    remote.Name:lower():find("steal") or
                    remote.Name:lower():find("tackle") or
                    remote.Name:lower():find("slide")
                ) then
                    remote:FireServer()
                end
            end
        end)
    end
end

-- Movement Features
local function applySpeedBoost()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if _G.speedBoost then
        humanoid.WalkSpeed = _G.speedValue
    else
        humanoid.WalkSpeed = 16
    end
end

local function infiniteStamina()
    if not _G.infiniteStamina then return end
    
    local character = player.Character
    if not character then return end
    
    -- Try to find stamina-related values
    safeCall(function()
        for _, obj in pairs(character:GetDescendants()) do
            if obj:IsA("NumberValue") and (
                obj.Name:lower():find("stamina") or
                obj.Name:lower():find("energy") or
                obj.Name:lower():find("endurance")
            ) then
                obj.Value = obj.MaxValue or 100
            end
        end
    end)
end

local function flyHack()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    
    if _G.flyHack then
        if not hrp:FindFirstChild("FlyBodyVelocity") then
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Name = "FlyBodyVelocity"
            bodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVel.Velocity = Vector3.new(0, 0, 0)
            bodyVel.Parent = hrp
            
            local bodyPos = Instance.new("BodyPosition")
            bodyPos.Name = "FlyBodyPosition"
            bodyPos.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyPos.Position = hrp.Position
            bodyPos.Parent = hrp
        end
        
        local bodyVel = hrp:FindFirstChild("FlyBodyVelocity")
        local bodyPos = hrp:FindFirstChild("FlyBodyPosition")
        
        if bodyVel and bodyPos then
            local moveVector = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + (Workspace.CurrentCamera.CFrame.LookVector * _G.flySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector - (Workspace.CurrentCamera.CFrame.LookVector * _G.flySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector - (Workspace.CurrentCamera.CFrame.RightVector * _G.flySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + (Workspace.CurrentCamera.CFrame.RightVector * _G.flySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveVector = moveVector + Vector3.new(0, _G.flySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveVector = moveVector - Vector3.new(0, _G.flySpeed, 0)
            end
            
            bodyVel.Velocity = moveVector
            bodyPos.Position = hrp.Position + (moveVector * 0.1)
        end
    else
        if hrp:FindFirstChild("FlyBodyVelocity") then
            hrp.FlyBodyVelocity:Destroy()
        end
        if hrp:FindFirstChild("FlyBodyPosition") then
            hrp.FlyBodyPosition:Destroy()
        end
    end
end

-- Shooting Features
local function autoShoot()
    if not _G.autoShoot then return end
    
    local character = player.Character
    if not character then return end
    
    local ball = getBall()
    if not ball then return end
    
    local distance = getDistance(ball, character.HumanoidRootPart)
    if distance <= 8 then
        local goals = getGoals()
        if #goals > 0 then
            safeCall(function()
                -- Try to find shoot remotes
                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") and (
                        remote.Name:lower():find("shoot") or
                        remote.Name:lower():find("kick") or
                        remote.Name:lower():find("shot")
                    ) then
                        remote:FireServer()
                        if _G.powerShot then
                            remote:FireServer("power")
                            remote:FireServer(100) -- Max power
                        end
                    end
                end
            end)
        end
    end
end

local function perfectAim()
    if not _G.perfectAim then return end
    
    local character = player.Character
    if not character then return end
    
    local ball = getBall()
    local goals = getGoals()
    
    if ball and #goals > 0 then
        local closestGoal = goals[1]
        local closestDistance = getDistance(ball, closestGoal)
        
        for _, goal in pairs(goals) do
            local distance = getDistance(ball, goal)
            if distance < closestDistance then
                closestDistance = distance
                closestGoal = goal
            end
        end
        
        -- Aim ball towards goal
        safeCall(function()
            local direction = (closestGoal.Position - ball.Position).Unit
            if ball:FindFirstChild("BodyVelocity") then
                ball.BodyVelocity.Velocity = direction * 50
            end
        end)
    end
end

-- ESP Features
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
    
    local ball = getBall()
    if ball and not ball:FindFirstChild("BallESP") then
        safeCall(function()
            local highlight = Instance.new("Highlight")
            highlight.Name = "BallESP"
            highlight.Parent = ball
            highlight.FillColor = Color3.new(1, 0.5, 0)
            highlight.OutlineColor = Color3.new(1, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            table.insert(espObjects, highlight)
            
            local gui = Instance.new("BillboardGui")
            gui.Name = "BallDistance"
            gui.Parent = ball
            gui.Size = UDim2.new(0, 100, 0, 50)
            gui.StudsOffset = Vector3.new(0, 3, 0)
            
            local label = Instance.new("TextLabel")
            label.Parent = gui
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "⚽ BALL"
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextScaled = true
            label.Font = Enum.Font.SourceSansBold
            
            table.insert(espObjects, gui)
        end)
    end
end

local function createPlayerESP()
    if not _G.playerESP then return end
    
    for _, plr in pairs(getPlayers()) do
        local character = plr.Character
        if character and not character:FindFirstChild("PlayerESP") then
            safeCall(function()
                local highlight = Instance.new("Highlight")
                highlight.Name = "PlayerESP"
                highlight.Parent = character
                
                if _G.teamESP then
                    -- Different colors for team/enemy (basic implementation)
                    if plr.TeamColor == player.TeamColor then
                        highlight.FillColor = Color3.new(0, 1, 0) -- Green for teammates
                    else
                        highlight.FillColor = Color3.new(1, 0, 0) -- Red for enemies
                    end
                else
                    highlight.FillColor = Color3.new(0, 0.5, 1) -- Blue for all players
                end
                
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.7
                highlight.OutlineTransparency = 0
                table.insert(espObjects, highlight)
                
                local gui = Instance.new("BillboardGui")
                gui.Name = "PlayerName"
                gui.Parent = character.HumanoidRootPart
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
                
                table.insert(espObjects, label)
            end)
        end
    end
end

local function createGoalESP()
    if not _G.goalESP then return end
    
    local goals = getGoals()
    for _, goal in pairs(goals) do
        if not goal:FindFirstChild("GoalESP") then
            safeCall(function()
                local highlight = Instance.new("Highlight")
                highlight.Name = "GoalESP"
                highlight.Parent = goal
                highlight.FillColor = Color3.new(1, 1, 0)
                highlight.OutlineColor = Color3.new(1, 0.5, 0)
                highlight.FillTransparency = 0.3
                highlight.OutlineTransparency = 0
                table.insert(espObjects, highlight)
            end)
        end
    end
end

-- Automation Features
local function autoPlay()
    if not _G.autoPlay then return end
    
    local character = player.Character
    if not character then return end
    
    local ball = getBall()
    if not ball then return end
    
    local distance = getDistance(ball, character.HumanoidRootPart)
    
    -- Basic AI: Move towards ball, shoot when close to goal
    if distance > 10 then
        -- Move towards ball
        local direction = (ball.Position - character.HumanoidRootPart.Position).Unit
        character.Humanoid:MoveTo(ball.Position)
    else
        -- Check if close to goal and shoot
        local goals = getGoals()
        if #goals > 0 then
            local closestGoal = goals[1]
            local goalDistance = getDistance(character.HumanoidRootPart, closestGoal)
            
            if goalDistance < 30 then
                -- Shoot
                safeCall(function()
                    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and remote.Name:lower():find("shoot") then
                            remote:FireServer()
                        end
                    end
                end)
            end
        end
    end
end

-- Utility Features
local function noclip()
    local character = player.Character
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not _G.noclip
        end
    end
end

local function antiAFK()
    if not _G.antiAFK then return end
    
    safeCall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- Click TP
local function setupClickTP()
    if _G.clickTP then
        if not connections.clickTP then
            connections.clickTP = mouse.Button1Down:Connect(function()
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 5, 0))
                end
            end)
        end
    else
        if connections.clickTP then
            connections.clickTP:Disconnect()
            connections.clickTP = nil
        end
    end
end

-- Main Loop
local heartbeatConnection = RunService.Heartbeat:Connect(function()
    safeCall(ballMagnet)
    safeCall(autoSteal)
    safeCall(applySpeedBoost)
    safeCall(infiniteStamina)
    safeCall(flyHack)
    safeCall(autoShoot)
    safeCall(perfectAim)
    safeCall(createBallESP)
    safeCall(createPlayerESP)
    safeCall(createGoalESP)
    safeCall(autoPlay)
    safeCall(noclip)
    safeCall(antiAFK)
end)

-- GUI Elements

-- Ball Control Tab
ballTab:CreateToggle({
   Name = "Ball Magnet",
   CurrentValue = false,
   Flag = "BallMagnet",
   Callback = function(value)
       _G.ballMagnet = value
   end
})

ballTab:CreateSlider({
   Name = "Magnet Range",
   Range = {5, 30},
   Increment = 1,
   CurrentValue = 15,
   Flag = "MagnetRange",
   Callback = function(value)
       _G.ballMagnetRange = value
   end
})

ballTab:CreateToggle({
   Name = "Auto Steal",
   CurrentValue = false,
   Flag = "AutoSteal",
   Callback = function(value)
       _G.autoSteal = value
   end
})

ballTab:CreateToggle({
   Name = "Ball ESP",
   CurrentValue = false,
   Flag = "BallESP",
   Callback = function(value)
       _G.ballESP = value
       if not value then clearESP() end
   end
})

ballTab:CreateButton({
   Name = "Teleport to Ball",
   Callback = function()
       local ball = getBall()
       local character = player.Character
       if ball and character and character:FindFirstChild("HumanoidRootPart") then
           character.HumanoidRootPart.CFrame = CFrame.new(ball.Position + Vector3.new(0, 5, 0))
       end
   end
})

-- Movement Tab
movementTab:CreateToggle({
   Name = "Speed Boost",
   CurrentValue = false,
   Flag = "SpeedBoost",
   Callback = function(value)
       _G.speedBoost = value
   end
})

movementTab:CreateSlider({
   Name = "Speed Value",
   Range = {16, 100},
   Increment = 1,
   CurrentValue = 25,
   Flag = "SpeedValue",
   Callback = function(value)
       _G.speedValue = value
   end
})

movementTab:CreateToggle({
   Name = "Infinite Stamina",
   CurrentValue = false,
   Flag = "InfiniteStamina",
   Callback = function(value)
       _G.infiniteStamina = value
   end
})

movementTab:CreateToggle({
   Name = "Fly Hack",
   CurrentValue = false,
   Flag = "FlyHack",
   Callback = function(value)
       _G.flyHack = value
   end
})

movementTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 100},
   Increment = 1,
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(value)
       _G.flySpeed = value
   end
})

-- Shooting Tab
shootingTab:CreateToggle({
   Name = "Auto Shoot",
   CurrentValue = false,
   Flag = "AutoShoot",
   Callback = function(value)
       _G.autoShoot = value
   end
})

shootingTab:CreateToggle({
   Name = "Perfect Aim",
   CurrentValue = false,
   Flag = "PerfectAim",
   Callback = function(value)
       _G.perfectAim = value
   end
})

shootingTab:CreateToggle({
   Name = "Power Shot",
   CurrentValue = false,
   Flag = "PowerShot",
   Callback = function(value)
       _G.powerShot = value
   end
})

shootingTab:CreateToggle({
   Name = "Goal ESP",
   CurrentValue = false,
   Flag = "GoalESP",
   Callback = function(value)
       _G.goalESP = value
       if not value then clearESP() end
   end
})

-- Player Tab
playerTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "PlayerESP",
   Callback = function(value)
       _G.playerESP = value
       if not value then clearESP() end
   end
})

playerTab:CreateToggle({
   Name = "Team ESP",
   CurrentValue = false,
   Flag = "TeamESP",
   Callback = function(value)
       _G.teamESP = value
   end
})

-- Automation Tab
autoTab:CreateToggle({
   Name = "Auto Play",
   CurrentValue = false,
   Flag = "AutoPlay",
   Callback = function(value)
       _G.autoPlay = value
   end
})

autoTab:CreateToggle({
   Name = "Auto Defend",
   CurrentValue = false,
   Flag = "AutoDefend",
   Callback = function(value)
       _G.autoDefend = value
   end
})

-- Utility Tab
utilityTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "Noclip",
   Callback = function(value)
       _G.noclip = value
   end
})

utilityTab:CreateToggle({
   Name = "Click TP",
   CurrentValue = false,
   Flag = "ClickTP",
   Callback = function(value)
       _G.clickTP = value
       setupClickTP()
   end
})

utilityTab:CreateToggle({
   Name = "Anti AFK",
   CurrentValue = false,
   Flag = "AntiAFK",
   Callback = function(value)
       _G.antiAFK = value
   end
})

utilityTab:CreateButton({
   Name = "Clear All ESP",
   Callback = function()
       clearESP()
   end
})

-- Cleanup
Players.PlayerRemoving:Connect(function(plr)
    if plr == player then
        clearESP()
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
        end
        for _, connection in pairs(connections) do
            if connection then
                connection:Disconnect()
            end
        end
    end
end)

-- Notification
Rayfield:Notify({
   Title = "GILONG Hub Loaded!",
   Content = "Blue Lock Rivals Script Ready! ⚽🔥",
   Duration = 5,
   Image = 4483362458,
   Actions = {
      Ignore = {
         Name = "Let's Dominate!",
         Callback = function()
            print("Blue Lock Rivals Script Loaded Successfully!")
         end
      },
   },
})

print("🔥 GILONG Hub - Blue Lock Rivals Script Loaded!")
print("⚽ Features: Ball Control, Auto Shoot, ESP, Fly, Speed Boost & More!")
print("🎯 Use responsibly and dominate the field!")
