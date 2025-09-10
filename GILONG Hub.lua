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
      Note = "https://link-hub.net/1392772/AfVHcFNYkLMx",
      FileName = "GILONGHub_BlueLock",
      SaveKey = true,
      GrabKeyFromSite = true,
      Key = {"AyamGoreng!"}
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
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

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
    local ball = nil
    
    -- Method 1: Check specific Blue Lock Rivals ball locations
    local possiblePaths = {
        Workspace:FindFirstChild("Ball"),
        Workspace:FindFirstChild("Football"),
        Workspace:FindFirstChild("SoccerBall"),
        Workspace:FindFirstChild("ball"),
        Workspace:FindFirstChild("football")
    }
    
    for _, path in pairs(possiblePaths) do
        if path and path:IsA("BasePart") and path.CanCollide then
            ball = path
            break
        end
    end
    
    -- Method 2: Search in game-specific folders
    local possibleFolders = {
        Workspace:FindFirstChild("Game"),
        Workspace:FindFirstChild("Match"),
        Workspace:FindFirstChild("Field"),
        Workspace:FindFirstChild("Stadium"),
        Workspace:FindFirstChild("Arena")
    }
    
    if not ball then
        for _, gameFolder in pairs(possibleFolders) do
            if gameFolder then
                for _, obj in pairs(gameFolder:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.CanCollide and (
                        obj.Name:lower():find("ball") or
                        obj.Name:lower():find("football") or
                        obj.Name == "Ball" or obj.Name == "Football" or
                        obj.Name == "SoccerBall"
                    ) then
                        ball = obj
                        break
                    end
                end
                if ball then break end
            end
        end
    end
    
    -- Method 3: Check for spherical objects with specific properties
    if not ball then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = obj.Name:lower()
                local isSpherical = obj.Shape == Enum.PartType.Ball or 
                                  (obj.Size.X == obj.Size.Y and obj.Size.Y == obj.Size.Z)
                local rightSize = obj.Size.X > 1 and obj.Size.X < 8
                local hasPhysics = obj.AssemblyLinearVelocity.Magnitude > 0 or 
                                 obj:FindFirstChild("BodyVelocity") or
                                 obj:FindFirstChild("BodyPosition")
                
                if (name:find("ball") or name:find("football") or isSpherical) and rightSize then
                    ball = obj
                    break
                end
            end
        end
    end
    
    -- Method 4: Fallback - find any moving spherical object
    if not ball then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.AssemblyLinearVelocity.Magnitude > 5 then
                local size = obj.Size.Magnitude
                if size > 2 and size < 12 and obj.Shape == Enum.PartType.Ball then
                    ball = obj
                    break
                end
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
            local magnetForce = 25
            
            -- Try multiple methods to move ball
            if ball:FindFirstChild("BodyVelocity") then
                ball.BodyVelocity.Velocity = direction * magnetForce
            elseif ball:FindFirstChild("BodyPosition") then
                ball.BodyPosition.Position = character.HumanoidRootPart.Position + (direction * 4)
            else
                -- Create temporary BodyVelocity
                local bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVel.Velocity = direction * magnetForce
                bodyVel.Parent = ball
                
                -- Also try AssemblyLinearVelocity (safer approach)
                pcall(function()
                    ball.AssemblyLinearVelocity = direction * magnetForce
                end)
                
                -- Try BodyPosition as backup
                local bodyPos = Instance.new("BodyPosition")
                bodyPos.MaxForce = Vector3.new(4000, 4000, 4000)
                bodyPos.Position = character.HumanoidRootPart.Position + (direction * 3)
                bodyPos.Parent = ball
                
                game:GetService("Debris"):AddItem(bodyVel, 0.2)
                game:GetService("Debris"):AddItem(bodyPos, 0.2)
            end
            
            -- Alternative: Direct position manipulation
            if distance < 5 then
                ball.CFrame = CFrame.new(character.HumanoidRootPart.Position + (direction * 3))
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
        if distance < 15 and distance < closestDistance then
            closestDistance = distance
            closestPlayer = plr
        end
    end
    
    if closestPlayer or getDistance(ball, character.HumanoidRootPart) < 10 then
        safeCall(function()
            -- Method 1: Key simulation (E for slide tackle)
            local virtualInputManager = game:GetService("VirtualInputManager")
            virtualInputManager:SendKeyEvent(Enum.KeyCode.E, true, game)
            task.wait(0.05)
            virtualInputManager:SendKeyEvent(Enum.KeyCode.E, false, game)
            
            -- Method 2: Try to find steal/tackle remotes
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    local name = remote.Name:lower()
                    if name:find("steal") or name:find("tackle") or name:find("slide") or
                       name:find("defend") or name == "remote" or name == "re" then
                        safeCall(function()
                            remote:FireServer()
                            remote:FireServer(true)
                            remote:FireServer("slide")
                            remote:FireServer({action = "tackle"})
                        end)
                    end
                end
            end
            
            -- Method 3: Try dribble (Q key) as counter
            virtualInputManager:SendKeyEvent(Enum.KeyCode.Q, true, game)
            task.wait(0.05)
            virtualInputManager:SendKeyEvent(Enum.KeyCode.Q, false, game)
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
        -- Check character descendants
        for _, obj in pairs(character:GetDescendants()) do
            if obj:IsA("NumberValue") and (
                obj.Name:lower():find("stamina") or
                obj.Name:lower():find("energy") or
                obj.Name:lower():find("endurance") or
                obj.Name:lower():find("sprint")
            ) then
                obj.Value = math.max(obj.Value, obj.MaxValue or 100)
            elseif obj:IsA("IntValue") and obj.Name:lower():find("stamina") then
                obj.Value = 100
            end
        end
        
        -- Check PlayerGui for stamina bars
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            for _, obj in pairs(playerGui:GetDescendants()) do
                if obj:IsA("NumberValue") and obj.Name:lower():find("stamina") then
                    obj.Value = 100
                end
            end
        end
        
        -- Try humanoid properties
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            -- Some games use custom attributes
            pcall(function()
                humanoid:SetAttribute("Stamina", 100)
                humanoid:SetAttribute("Energy", 100)
            end)
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
    if distance <= 12 then
        local goals = getGoals()
        if #goals > 0 then
            safeCall(function()
                -- Method 1: Mouse button simulation (proper way)
                local mouse = player:GetMouse()
                mouse.Button1Down:Connect(function() end)
                mouse.Button1Up:Connect(function() end)
                
                -- Simulate mouse click
                local virtualInputManager = game:GetService("VirtualInputManager")
                virtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.05)
                virtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                
                -- Method 2: UserInputService simulation (fixed)
                UserInputService:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.05)
                UserInputService:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                
                -- Method 3: Try to find shoot remotes
                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local name = remote.Name:lower()
                        if name:find("shoot") or name:find("kick") or name:find("shot") or
                           name:find("fire") or name == "remote" or name == "re" then
                            safeCall(function()
                                remote:FireServer()
                                remote:FireServer(true)
                                remote:FireServer({action = "shoot"})
                                if _G.powerShot then
                                    remote:FireServer("power")
                                    remote:FireServer(100)
                                    remote:FireServer({power = 100, type = "power"})
                                end
                            end)
                        end
                    end
                end
                
                -- Method 4: Try StarterPlayer and other services
                for _, service in pairs({game:GetService("StarterPlayer"), game:GetService("StarterGui")}) do
                    for _, remote in pairs(service:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and remote.Name:lower():find("shoot") then
                            safeCall(function()
                                remote:FireServer()
                                remote:FireServer({action = "shoot"})
                            end)
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
        safeCall(function()
            if obj and obj.Parent then
                obj:Destroy()
            end
        end)
    end
    espObjects = {}
    
    -- Also clear existing ESP objects in workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "BallESP" or obj.Name == "PlayerESP" or obj.Name == "GoalESP" or 
           obj.Name == "BallDistance" or obj.Name == "PlayerName" then
            safeCall(function()
                obj:Destroy()
            end)
        end
    end
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
        safeCall(function()
            local direction = (ball.Position - character.HumanoidRootPart.Position).Unit
            character.Humanoid:MoveTo(ball.Position)
            
            -- Also try pathfinding for better movement
            local pathfindingService = game:GetService("PathfindingService")
            local path = pathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true
            })
            
            pcall(function()
                path:ComputeAsync(character.HumanoidRootPart.Position, ball.Position)
                local waypoints = path:GetWaypoints()
                if #waypoints > 1 then
                    character.Humanoid:MoveTo(waypoints[2].Position)
                end
            end)
        end)
    else
        -- Check if close to goal and shoot
        local goals = getGoals()
        if #goals > 0 then
            local closestGoal = goals[1]
            local goalDistance = getDistance(character.HumanoidRootPart, closestGoal)
            
            if goalDistance < 30 then
                -- Shoot
                safeCall(function()
                    -- Try multiple shoot methods
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    
                    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and remote.Name:lower():find("shoot") then
                            remote:FireServer()
                            remote:FireServer({action = "shoot"})
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

-- Debug function
local function debugInfo()
    local ball = getBall()
    if ball then
        print("[DEBUG] Ball found:", ball.Name, "Position:", ball.Position)
        print("[DEBUG] Ball velocity:", ball.AssemblyLinearVelocity.Magnitude)
    else
        print("[DEBUG] No ball detected")
    end
    
    local remoteCount = 0
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            remoteCount = remoteCount + 1
        end
    end
    print("[DEBUG] Found", remoteCount, "RemoteEvents")
end

-- Main Loop with improved timing
local heartbeatConnection
local frameCount = 0
heartbeatConnection = RunService.Heartbeat:Connect(function()
    frameCount = frameCount + 1
    
    -- Run every frame
    safeCall(applySpeedBoost)
    safeCall(flyHack)
    safeCall(noclip)
    
    -- Run every 2 frames (30 FPS equivalent)
    if frameCount % 2 == 0 then
        safeCall(ballMagnet)
        safeCall(autoShoot)
        safeCall(autoSteal)
        safeCall(perfectAim)
        safeCall(autoPlay)
    end
    
    -- Run every 5 frames (12 FPS equivalent)
    if frameCount % 5 == 0 then
        safeCall(infiniteStamina)
        safeCall(createBallESP)
        safeCall(createPlayerESP)
        safeCall(createGoalESP)
    end
    
    -- Run every 60 frames (1 FPS equivalent)
    if frameCount % 60 == 0 then
        safeCall(antiAFK)
    end
    
    -- Debug every 300 frames (5 seconds)
    if frameCount % 300 == 0 and (_G.ballMagnet or _G.autoShoot) then
        safeCall(debugInfo)
    end
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

utilityTab:CreateButton({
   Name = "Debug Info",
   Callback = function()
       debugInfo()
       
       -- Print all RemoteEvents
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
   Name = "Force Shoot Test",
   Callback = function()
       print("[TEST] Testing shoot function...")
       _G.autoShoot = true
       autoShoot()
       _G.autoShoot = false
       print("[TEST] Shoot test completed")
   end
})

utilityTab:CreateButton({
   Name = "Find Ball Test",
   Callback = function()
       local ball = getBall()
       if ball then
           print("[TEST] Ball found:", ball.Name, "at", ball.Position)
           print("[TEST] Ball properties - Size:", ball.Size, "Shape:", ball.Shape)
           print("[TEST] Ball velocity:", ball.AssemblyLinearVelocity.Magnitude)
           local character = player.Character
           if character and character:FindFirstChild("HumanoidRootPart") then
               character.HumanoidRootPart.CFrame = CFrame.new(ball.Position + Vector3.new(0, 5, 0))
           end
       else
           print("[TEST] No ball found - searching all workspace objects...")
           for _, obj in pairs(Workspace:GetDescendants()) do
               if obj:IsA("BasePart") and obj.Name:lower():find("ball") then
                   print("[TEST] Found potential ball:", obj.Name, "Path:", obj:GetFullName())
               end
           end
       end
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
