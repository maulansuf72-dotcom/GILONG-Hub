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
    if character then
        for _, obj in pairs(character:GetChildren()) do
            if obj:IsA("Tool") and obj.Name:lower():find("glove") then
                table.insert(gloves, obj.Name)
            end
        end
    end
    
    -- Also check backpack
    for _, obj in pairs(player.Backpack:GetChildren()) do
        if obj:IsA("Tool") and obj.Name:lower():find("glove") then
            table.insert(gloves, obj.Name)
        end
    end
    
    return gloves
end

-- Combat Features
local function autoSlap()
    if not _G.autoSlap then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local target = nil
    if _G.autoTarget then
        if _G.targetMode == "nearest" then
            target = getClosestPlayer()
        elseif targetPlayer and targetPlayer.Character then
            target = targetPlayer
        end
    else
        target = getClosestPlayer()
    end
    
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local distance = getDistance(character.HumanoidRootPart, target.Character.HumanoidRootPart)
        
        if distance <= _G.slapRange then
            safeCall(function()
                -- Method 1: Mouse click simulation
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                
                -- Method 2: Try to find slap remotes
                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local name = remote.Name:lower()
                        if name:find("slap") or name:find("hit") or name:find("attack") or
                           name == "b" or name == "remote" or name == "re" then
                            remote:FireServer()
                            remote:FireServer(target.Character)
                            remote:FireServer({target = target.Character})
                        end
                    end
                end
                
                -- Method 3: Tool activation
                local tool = character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    tool:Activate()
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
                    -- Auto slap all players in range
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.02)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    
                    -- Try remotes
                    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and remote.Name:lower():find("slap") then
                            remote:FireServer(plr.Character)
                        end
                    end
                end)
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
            local originalSize = handle.Size
            
            -- Extend reach by increasing handle size
            handle.Size = Vector3.new(_G.reachDistance, _G.reachDistance, _G.reachDistance)
            handle.Transparency = 1
            
            -- Reset after short time
            task.wait(0.1)
            handle.Size = originalSize
            handle.Transparency = 0
        end)
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
        if target and target.Character then
            local distance = getDistance(character.HumanoidRootPart, target.Character.HumanoidRootPart)
            
            if distance > 15 then
                -- Move closer to target
                character.Humanoid:MoveTo(target.Character.HumanoidRootPart.Position)
            else
                -- Slap target
                autoSlap()
            end
        end
    end
    
    -- Auto collect items/badges
    if _G.autoBadge then
        safeCall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (
                    obj.Name:lower():find("badge") or
                    obj.Name:lower():find("orb") or
                    obj.Name:lower():find("collect")
                ) then
                    local distance = getDistance(obj, character.HumanoidRootPart)
                    if distance < 50 then
                        character.HumanoidRootPart.CFrame = CFrame.new(obj.Position)
                        task.wait(0.1)
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
            bodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVel.Velocity = Vector3.new(0, 0, 0)
            bodyVel.Parent = hrp
        end
        
        local bodyVel = hrp:FindFirstChild("FlyBodyVelocity")
        if bodyVel then
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
        end
    else
        if hrp:FindFirstChild("FlyBodyVelocity") then
            hrp.FlyBodyVelocity:Destroy()
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
    if not _G.playerESP then return end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and not plr.Character:FindFirstChild("PlayerESP") then
            safeCall(function()
                local highlight = Instance.new("Highlight")
                highlight.Name = "PlayerESP"
                highlight.Parent = plr.Character
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.7
                table.insert(espObjects, highlight)
                
                local gui = Instance.new("BillboardGui")
                gui.Name = "PlayerName"
                gui.Parent = plr.Character.HumanoidRootPart
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
    
    if character.HumanoidRootPart.Position.Y < -100 then
        character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
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
    
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == _G.selectedGlove then
            character.Humanoid:EquipTool(tool)
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
        safeCall(reachExtend)
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
       player.Character.Humanoid.Health = 0
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
