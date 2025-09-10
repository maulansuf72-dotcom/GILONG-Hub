-- Slap Battles - Ultimate Script Hub
-- Created by GILONG Hub | Optimized for Maximum Slaps

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "GILONG Hub | Slap Battles",
   Icon = 0,
   LoadingTitle = "Slap Battles Script",
   LoadingSubtitle = "Ultimate Slapping Domination",
   ShowText = "GILONG Hub",
   Theme = "Amethyst",
   ToggleUIKeybind = Enum.KeyCode.RightControl,
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "GILONGHub",
      FileName = "SlapBattles_Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "GILONG Hub | Slap Battles",
      Subtitle = "Enter Access Key",
      Note = "https://link-hub.net/1392772/AfVHcFNYkLMx",
      FileName = "GILONGHub_SlapBattles",
      SaveKey = true,
      GrabKeyFromSite = true,
      Key = {"SlapKing2025!"}
   }
})

-- Create Tabs
local combatTab = Window:CreateTab("👊 Combat", nil)
local farmTab = Window:CreateTab("💰 Farming", nil)
local movementTab = Window:CreateTab("🏃‍♂️ Movement", nil)
local visualTab = Window:CreateTab("👁️ Visuals", nil)
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
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Global Variables
_G.autoSlap = false
_G.slapRange = 15
_G.autoTarget = false
_G.targetMode = "nearest"
_G.autoFarm = false
_G.farmSlaps = false
_G.autoBadge = false
_G.speedBoost = false
_G.speedValue = 25
_G.flyHack = false
_G.flySpeed = 50
_G.infiniteJump = false
_G.noclip = false
_G.playerESP = false
_G.gloveESP = false
_G.antiRagdoll = false
_G.antiVoid = false
_G.autoRespawn = false
_G.killAura = false
_G.auraRange = 20
_G.reachExtend = false
_G.reachDistance = 25
_G.antiAFK = false
_G.autoEquip = false
_G.selectedGlove = "Default"

-- Storage
local connections = {}
local espObjects = {}
local originalValues = {}
local targetPlayer = nil

-- Utility Functions
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[Slap Battles] Error: " .. tostring(result))
    end
    return success, result
end

local function getDistance(part1, part2)
    if not part1 or not part2 then return math.huge end
    return (part1.Position - part2.Position).Magnitude
end

local function getClosestPlayer()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local distance = getDistance(character.HumanoidRootPart, plr.Character.HumanoidRootPart)
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = plr
            end
        end
    end
    
    return closestPlayer
end

local function getGloves()
    local gloves = {}
    local character = player.Character
    
    -- Check equipped tools
    if character then
        for _, obj in pairs(character:GetChildren()) do
            if obj:IsA("Tool") then
                table.insert(gloves, obj.Name)
            end
        end
    end
    
    -- Check backpack
    for _, obj in pairs(player.Backpack:GetChildren()) do
        if obj:IsA("Tool") then
            table.insert(gloves, obj.Name)
        end
    end
    
    return gloves
end

local function getCurrentGlove()
    local character = player.Character
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            return tool.Name
        end
    end
    return "None"
end

-- Combat Features
local function autoSlap()
    if not _G.autoSlap then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local target = getClosestPlayer()
    
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local distance = getDistance(character.HumanoidRootPart, target.Character.HumanoidRootPart)
        
        if distance <= _G.slapRange then
            safeCall(function()
                -- Method 1: Direct tool activation (most reliable)
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                    
                    -- Also try firing tool's remotes
                    for _, obj in pairs(tool:GetDescendants()) do
                        if obj:IsA("RemoteEvent") then
                            obj:FireServer()
                            obj:FireServer(target.Character.HumanoidRootPart)
                        end
                    end
                end
                
                -- Method 2: Mouse simulation with proper coordinates
                local camera = Workspace.CurrentCamera
                local targetPos = camera:WorldToScreenPoint(target.Character.HumanoidRootPart.Position)
                VirtualInputManager:SendMouseButtonEvent(targetPos.X, targetPos.Y, 0, true, game, 1)
                task.wait(0.02)
                VirtualInputManager:SendMouseButtonEvent(targetPos.X, targetPos.Y, 0, false, game, 1)
                
                -- Method 3: Try common Slap Battles remotes (improved detection)
                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local name = remote.Name:lower()
                        if name == "b" or name == "slap" or name == "hit" or name == "swing" or
                           name == "remote" or name:find("glove") or name:find("attack") or
                           name:len() == 1 then -- Single letter remotes are common
                            pcall(function()
                                remote:FireServer()
                                remote:FireServer(target.Character)
                                remote:FireServer(target.Character.HumanoidRootPart)
                                remote:FireServer({Target = target.Character})
                                remote:FireServer(target.Character.HumanoidRootPart.Position)
                                remote:FireServer("Slap")
                            end)
                        end
                    end
                end
                
                -- Method 4: Try StarterPlayer remotes
                for _, remote in pairs(game:GetService("StarterPlayer"):GetDescendants()) do
                    if remote:IsA("RemoteEvent") and remote.Name:lower():find("slap") then
                        pcall(function()
                            remote:FireServer(target.Character)
                        end)
                    end
                end
                
                -- Method 5: Key simulation (multiple keys)
                local keys = {Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.Q, Enum.KeyCode.R}
                for _, key in pairs(keys) do
                    UserInputService:SendKeyEvent(true, key, false, game)
                    task.wait(0.01)
                    UserInputService:SendKeyEvent(false, key, false, game)
                end
            end)
        end
    end
end

local function killAura()
    if not _G.killAura then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local distance = getDistance(character.HumanoidRootPart, plr.Character.HumanoidRootPart)
            
            if distance <= _G.auraRange then
                safeCall(function()
                    -- Method 1: Tool activation
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                    
                    -- Method 2: Mouse click with target position
                    local camera = Workspace.CurrentCamera
                    local targetPos = camera:WorldToScreenPoint(plr.Character.HumanoidRootPart.Position)
                    VirtualInputManager:SendMouseButtonEvent(targetPos.X, targetPos.Y, 0, true, game, 1)
                    task.wait(0.01)
                    VirtualInputManager:SendMouseButtonEvent(targetPos.X, targetPos.Y, 0, false, game, 1)
                    
                    -- Method 3: Try remotes with multiple parameters
                    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") then
                            local name = remote.Name:lower()
                            if name == "b" or name:find("slap") or name:find("hit") then
                                remote:FireServer()
                                remote:FireServer(plr.Character)
                                remote:FireServer(plr.Character.HumanoidRootPart)
                            end
                        end
                    end
                end)
                task.wait(0.05) -- Small delay between targets
            end
        end
    end
end

local function reachExtend()
    if not _G.reachExtend then return end
    
    local character = player.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        safeCall(function()
            local handle = tool.Handle
            
            -- Store original values if not already stored
            if not originalValues[handle] then
                originalValues[handle] = {
                    Size = handle.Size,
                    Transparency = handle.Transparency
                }
            end
            
            -- Extend reach by modifying handle properties
            handle.Size = Vector3.new(_G.reachDistance, _G.reachDistance, _G.reachDistance)
            handle.Transparency = 0.8
            handle.CanCollide = false
            
            -- Also try to modify tool's reach property if it exists
            if tool:FindFirstChild("Reach") then
                tool.Reach.Value = _G.reachDistance
            end
        end)
    end
end

local function resetReach()
    local character = player.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        local handle = tool.Handle
        if originalValues[handle] then
            handle.Size = originalValues[handle].Size
            handle.Transparency = originalValues[handle].Transparency
        end
    end
end

-- Farming Features
local function autoFarm()
    if not _G.autoFarm then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    if _G.farmSlaps then
        -- Find players to farm slaps from
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local distance = getDistance(character.HumanoidRootPart, target.Character.HumanoidRootPart)
            
            if distance > _G.slapRange then
                -- Move closer to target using pathfinding
                safeCall(function()
                    local path = PathfindingService:CreatePath({
                        AgentRadius = 2,
                        AgentHeight = 5,
                        AgentCanJump = true
                    })
                    
                    path:ComputeAsync(character.HumanoidRootPart.Position, target.Character.HumanoidRootPart.Position)
                    local waypoints = path:GetWaypoints()
                    
                    if #waypoints > 1 then
                        character.Humanoid:MoveTo(waypoints[2].Position)
                    else
                        character.Humanoid:MoveTo(target.Character.HumanoidRootPart.Position)
                    end
                end)
            end
        end
    end
    
    -- Auto collect items/badges with better detection
    if _G.autoBadge then
        safeCall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Parent and (
                    obj.Name:lower():find("badge") or
                    obj.Name:lower():find("orb") or
                    obj.Name:lower():find("collect") or
                    obj.Name:lower():find("coin") or
                    obj.Name:lower():find("pickup") or
                    (obj.BrickColor == BrickColor.new("Bright yellow") and obj.Shape == Enum.PartType.Ball)
                ) then
                    local distance = getDistance(obj, character.HumanoidRootPart)
                    if distance < 100 and distance > 5 then
                        character.HumanoidRootPart.CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0))
                        task.wait(0.2)
                        break
                    end
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

local function flyHack()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    
    if _G.flyHack then
        if not hrp:FindFirstChild("FlyBodyVelocity") then
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Name = "FlyBodyVelocity"
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
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

local function infiniteJump()
    if not _G.infiniteJump then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.JumpHeight = 50
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

-- Visual Features
local function createPlayerESP()
    if not _G.playerESP then 
        clearESP()
        return 
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and not plr.Character:FindFirstChild("PlayerESP") then
            safeCall(function()
                local highlight = Instance.new("Highlight")
                highlight.Name = "PlayerESP"
                highlight.Parent = plr.Character
                highlight.FillColor = Color3.new(1, 0.2, 0.2)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.6
                highlight.OutlineTransparency = 0
                table.insert(espObjects, highlight)
                
                local gui = Instance.new("BillboardGui")
                gui.Name = "PlayerName"
                gui.Parent = plr.Character.HumanoidRootPart
                gui.Size = UDim2.new(0, 200, 0, 50)
                gui.StudsOffset = Vector3.new(0, 4, 0)
                gui.AlwaysOnTop = true
                
                local label = Instance.new("TextLabel")
                label.Parent = gui
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = plr.Name .. " [" .. math.floor(getDistance(player.Character.HumanoidRootPart, plr.Character.HumanoidRootPart)) .. "m]"
                label.TextColor3 = Color3.new(1, 1, 1)
                label.TextScaled = true
                label.Font = Enum.Font.SourceSansBold
                label.TextStrokeTransparency = 0
                label.TextStrokeColor3 = Color3.new(0, 0, 0)
                
                table.insert(espObjects, gui)
            end)
        end
    end
end

local function createGloveESP()
    if not _G.gloveESP then return end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj.Name:lower():find("glove") and not obj:FindFirstChild("GloveESP") then
            safeCall(function()
                local highlight = Instance.new("Highlight")
                highlight.Name = "GloveESP"
                highlight.Parent = obj
                highlight.FillColor = Color3.new(0, 1, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.5
                table.insert(espObjects, highlight)
            end)
        end
    end
end

-- Utility Features
local function antiRagdoll()
    if not _G.antiRagdoll then return end
    
    local character = player.Character
    if not character then return end
    
    safeCall(function()
        for _, obj in pairs(character:GetDescendants()) do
            if obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint") then
                obj:Destroy()
            end
        end
    end)
end

local function antiVoid()
    if not _G.antiVoid then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    if hrp.Position.Y < -50 then
        -- Find a safe spawn point
        local spawnPoints = {
            Vector3.new(0, 50, 0),
            Vector3.new(100, 50, 0),
            Vector3.new(-100, 50, 0),
            Vector3.new(0, 50, 100),
            Vector3.new(0, 50, -100)
        }
        
        -- Try to find the main arena/platform
        local safestPoint = spawnPoints[1]
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("BasePart") and obj.Size.X > 50 and obj.Size.Z > 50 and obj.Position.Y > 0 then
                safestPoint = obj.Position + Vector3.new(0, 10, 0)
                break
            end
        end
        
        hrp.CFrame = CFrame.new(safestPoint)
        hrp.Velocity = Vector3.new(0, 0, 0)
    end
end

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

local function autoEquip()
    if not _G.autoEquip then return end
    
    local character = player.Character
    if not character then return end
    
    -- Check if already equipped
    local currentTool = character:FindFirstChildOfClass("Tool")
    if currentTool and currentTool.Name == _G.selectedGlove then
        return
    end
    
    -- Try to equip from backpack
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == _G.selectedGlove then
            safeCall(function()
                character.Humanoid:EquipTool(tool)
            end)
            break
        end
    end
end

-- Clear ESP Function
local function clearESP()
    for _, obj in pairs(espObjects) do
        safeCall(function()
            if obj and obj.Parent then
                obj:Destroy()
            end
        end)
    end
    espObjects = {}
    
    -- Also clear existing ESP objects
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "PlayerESP" or obj.Name == "GloveESP" or obj.Name == "PlayerName" then
            safeCall(function()
                obj:Destroy()
            end)
        end
    end
end

-- Main Loop
local heartbeatConnection
local frameCount = 0
heartbeatConnection = RunService.Heartbeat:Connect(function()
    frameCount = frameCount + 1
    
    -- Run every frame
    safeCall(applySpeedBoost)
    safeCall(flyHack)
    safeCall(infiniteJump)
    safeCall(noclip)
    safeCall(antiRagdoll)
    safeCall(antiVoid)
    
    -- Run every 2 frames
    if frameCount % 2 == 0 then
        safeCall(autoSlap)
        safeCall(killAura)
        if _G.reachExtend then
            safeCall(reachExtend)
        else
            safeCall(resetReach)
        end
        safeCall(autoFarm)
    end
    
    -- Run every 5 frames
    if frameCount % 5 == 0 then
        safeCall(createPlayerESP)
        safeCall(createGloveESP)
        safeCall(autoEquip)
    end
    
    -- Run every 60 frames
    if frameCount % 60 == 0 then
        safeCall(antiAFK)
    end
end)

-- GUI Elements

-- Combat Tab
combatTab:CreateToggle({
   Name = "Auto Slap",
   CurrentValue = false,
   Flag = "AutoSlap",
   Callback = function(value)
       _G.autoSlap = value
   end
})

combatTab:CreateSlider({
   Name = "Slap Range",
   Range = {5, 50},
   Increment = 1,
   CurrentValue = 15,
   Flag = "SlapRange",
   Callback = function(value)
       _G.slapRange = value
   end
})

combatTab:CreateToggle({
   Name = "Kill Aura",
   CurrentValue = false,
   Flag = "KillAura",
   Callback = function(value)
       _G.killAura = value
   end
})

combatTab:CreateSlider({
   Name = "Aura Range",
   Range = {10, 50},
   Increment = 1,
   CurrentValue = 20,
   Flag = "AuraRange",
   Callback = function(value)
       _G.auraRange = value
   end
})

combatTab:CreateToggle({
   Name = "Reach Extend",
   CurrentValue = false,
   Flag = "ReachExtend",
   Callback = function(value)
       _G.reachExtend = value
   end
})

combatTab:CreateSlider({
   Name = "Reach Distance",
   Range = {15, 100},
   Increment = 1,
   CurrentValue = 25,
   Flag = "ReachDistance",
   Callback = function(value)
       _G.reachDistance = value
   end
})

-- Farming Tab
farmTab:CreateToggle({
   Name = "Auto Farm",
   CurrentValue = false,
   Flag = "AutoFarm",
   Callback = function(value)
       _G.autoFarm = value
   end
})

farmTab:CreateToggle({
   Name = "Farm Slaps",
   CurrentValue = false,
   Flag = "FarmSlaps",
   Callback = function(value)
       _G.farmSlaps = value
   end
})

farmTab:CreateToggle({
   Name = "Auto Badge Collect",
   CurrentValue = false,
   Flag = "AutoBadge",
   Callback = function(value)
       _G.autoBadge = value
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

movementTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJump",
   Callback = function(value)
       _G.infiniteJump = value
   end
})

-- Visual Tab
visualTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "PlayerESP",
   Callback = function(value)
       _G.playerESP = value
       if not value then clearESP() end
   end
})

visualTab:CreateToggle({
   Name = "Glove ESP",
   CurrentValue = false,
   Flag = "GloveESP",
   Callback = function(value)
       _G.gloveESP = value
   end
})

-- Utility Tab
utilityTab:CreateToggle({
   Name = "Anti Ragdoll",
   CurrentValue = false,
   Flag = "AntiRagdoll",
   Callback = function(value)
       _G.antiRagdoll = value
   end
})

utilityTab:CreateToggle({
   Name = "Anti Void",
   CurrentValue = false,
   Flag = "AntiVoid",
   Callback = function(value)
       _G.antiVoid = value
   end
})

utilityTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "Noclip",
   Callback = function(value)
       _G.noclip = value
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
   Name = "Respawn",
   Callback = function()
       safeCall(function()
           if player.Character and player.Character:FindFirstChild("Humanoid") then
               player.Character.Humanoid.Health = 0
           end
       end)
   end
})

utilityTab:CreateButton({
   Name = "Debug Info",
   Callback = function()
       local character = player.Character
       if character then
           print("[DEBUG] Current Glove:", getCurrentGlove())
           print("[DEBUG] Available Gloves:", table.concat(getGloves(), ", "))
           
           local tool = character:FindFirstChildOfClass("Tool")
           if tool then
               print("[DEBUG] Tool Name:", tool.Name)
               print("[DEBUG] Tool Children:")
               for _, child in pairs(tool:GetChildren()) do
                   print("  -", child.Name, child.ClassName)
               end
           end
           
           print("[DEBUG] RemoteEvents found:")
           local count = 0
           for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
               if remote:IsA("RemoteEvent") then
                   count = count + 1
                   if count <= 10 then -- Limit output
                       print("  -", remote.Name, remote:GetFullName())
                   end
               end
           end
           print("[DEBUG] Total RemoteEvents:", count)
       end
   end
})

utilityTab:CreateButton({
   Name = "Test Slap",
   Callback = function()
       print("[TEST] Testing slap function...")
       local oldValue = _G.autoSlap
       _G.autoSlap = true
       autoSlap()
       _G.autoSlap = oldValue
       print("[TEST] Slap test completed")
   end
})

utilityTab:CreateButton({
   Name = "Force Equip Default",
   Callback = function()
       local character = player.Character
       if character then
           for _, tool in pairs(player.Backpack:GetChildren()) do
               if tool:IsA("Tool") and (tool.Name == "Default" or tool.Name:lower():find("default")) then
                   character.Humanoid:EquipTool(tool)
                   print("[INFO] Equipped:", tool.Name)
                   break
               end
           end
       end
   end
})

utilityTab:CreateButton({
   Name = "Teleport to Arena Center",
   Callback = function()
       local character = player.Character
       if character and character:FindFirstChild("HumanoidRootPart") then
           character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
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
   Content = "Slap Battles Script Ready! 👊💥",
   Duration = 5,
   Image = 4483362458,
   Actions = {
      Ignore = {
         Name = "Let's Slap!",
         Callback = function()
            print("Slap Battles Script Loaded Successfully!")
         end
      },
   },
})

print("👊 GILONG Hub - Slap Battles Script Loaded!")
print("💥 Features: Auto Slap, Kill Aura, Farming, ESP & More!")
print("🏆 Dominate the arena and collect all gloves!")
