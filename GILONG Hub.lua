-- Ink Game (Squid Game) - Ultimate Script Hub
-- Created by GILONG Hub | Optimized for All Challenges

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "GILONG Hub | Ink Game",
   Icon = 0,
   LoadingTitle = "Ink Game Script",
   LoadingSubtitle = "Squid Game Survival Domination",
   ShowText = "GILONG Hub",
   Theme = "DarkBlue",
   ToggleUIKeybind = Enum.KeyCode.RightControl,
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "GILONGHub",
      FileName = "InkGame_Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "GILONG Hub | Ink Game",
      Subtitle = "Enter Access Key",
      Note = "https://link-hub.net/1392772/AfVHcFNYkLMx",
      FileName = "GILONGHub_InkGame",
      SaveKey = true,
      GrabKeyFromSite = true,
      Key = {"SquidGame2024!"}
   }
})

-- Create Tabs
local gameTab = Window:CreateTab("🎮 Game Assists", nil)
local movementTab = Window:CreateTab("🏃‍♂️ Movement", nil)
local combatTab = Window:CreateTab("⚔️ Combat", nil)
local farmTab = Window:CreateTab("💰 Farming", nil)
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
_G.redLightAssist = false
_G.autoFreeze = false
_G.dalgonaAssist = false
_G.autoTrace = false
_G.tugsWarAssist = false
_G.autoClick = false
_G.glassAssist = false
_G.safePathESP = false
_G.hideSeekAssist = false
_G.autoHide = false
_G.speedBoost = false
_G.speedValue = 25
_G.autoDash = false
_G.dashTiming = false
_G.infiniteStamina = false
_G.noclip = false
_G.flyHack = false
_G.flySpeed = 50
_G.autoFarm = false
_G.afkFarm = false
_G.playerESP = false
_G.guardESP = false
_G.antiAFK = false
_G.autoVote = false
_G.voteChoice = "rebel"

-- Storage
local connections = {}
local espObjects = {}
local originalValues = {}

-- Utility Functions
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[Ink Game] Error: " .. tostring(result))
    end
    return success, result
end

local function getDistance(part1, part2)
    if not part1 or not part2 then return math.huge end
    return (part1.Position - part2.Position).Magnitude
end

-- Game Detection Functions
local function isRedLightActive()
    -- Check for red light indicators
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Sound") and obj.Name:lower():find("red") then
            return obj.IsPlaying
        elseif obj:IsA("StringValue") and obj.Value:lower():find("red") then
            return true
        end
    end
    return false
end

local function getCurrentChallenge()
    local gui = player:FindFirstChild("PlayerGui")
    if gui then
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local text = obj.Text:lower()
                if text:find("red light") or text:find("green light") then
                    return "redlight"
                elseif text:find("dalgona") or text:find("cookie") then
                    return "dalgona"
                elseif text:find("tug") or text:find("war") then
                    return "tugwar"
                elseif text:find("glass") or text:find("bridge") then
                    return "glass"
                elseif text:find("hide") or text:find("seek") then
                    return "hideseek"
                elseif text:find("lights out") then
                    return "lightsout"
                end
            end
        end
    end
    return "unknown"
end

-- Red Light Green Light Assist
local function redLightAssist()
    if not _G.redLightAssist then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    if isRedLightActive() and _G.autoFreeze then
        character.Humanoid.WalkSpeed = 0
        character.Humanoid.JumpPower = 0
    else
        character.Humanoid.WalkSpeed = _G.speedBoost and _G.speedValue or 16
        character.Humanoid.JumpPower = 50
    end
end

-- Dalgona Cookie Assist
local function dalgonaAssist()
    if not _G.dalgonaAssist then return end
    
    local character = player.Character
    if not character then return end
    
    if getCurrentChallenge() == "dalgona" and _G.autoTrace then
        safeCall(function()
            -- Find cookie tracing interface
            local gui = player.PlayerGui
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("Frame") and obj.Name:lower():find("cookie") then
                    -- Auto trace cookie outline
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end
        end)
    end
end

-- Tug of War Assist
local function tugWarAssist()
    if not _G.tugsWarAssist then return end
    
    if getCurrentChallenge() == "tugwar" and _G.autoClick then
        safeCall(function()
            -- Auto click for tug of war
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
end

-- Glass Bridge Assist
local function glassAssist()
    if not _G.glassAssist then return end
    
    if getCurrentChallenge() == "glass" then
        safeCall(function()
            -- ESP for safe glass panels
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("glass") then
                    if not obj:FindFirstChild("GlassESP") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "GlassESP"
                        highlight.Parent = obj
                        
                        -- Green for safe, red for fake
                        if obj.Transparency > 0.5 then
                            highlight.FillColor = Color3.new(1, 0, 0) -- Red for fake
                        else
                            highlight.FillColor = Color3.new(0, 1, 0) -- Green for safe
                        end
                        
                        highlight.OutlineColor = Color3.new(1, 1, 1)
                        highlight.FillTransparency = 0.5
                        table.insert(espObjects, highlight)
                    end
                end
            end
        end)
    end
end

-- Hide and Seek Assist
local function hideSeekAssist()
    if not _G.hideSeekAssist then return end
    
    local character = player.Character
    if not character then return end
    
    if getCurrentChallenge() == "hideseek" and _G.autoHide then
        safeCall(function()
            -- Find hiding spots
            local bestHidingSpot = nil
            local maxDistance = 0
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Size.Y > 5 and obj.CanCollide then
                    local distance = getDistance(obj, character.HumanoidRootPart)
                    if distance > maxDistance and distance < 100 then
                        maxDistance = distance
                        bestHidingSpot = obj
                    end
                end
            end
            
            if bestHidingSpot then
                character.Humanoid:MoveTo(bestHidingSpot.Position + Vector3.new(0, 0, 5))
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

local function autoDash()
    if not _G.autoDash then return end
    
    local character = player.Character
    if not character then return end
    
    if _G.dashTiming then
        local challenge = getCurrentChallenge()
        if challenge == "redlight" and isRedLightActive() then
            -- Don't dash during red light
            return
        elseif challenge == "glass" then
            -- Smart dash on glass bridge
            VirtualInputManager:SendKeyEvent(Enum.KeyCode.Q, true, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(Enum.KeyCode.Q, false, game)
        end
    end
end

-- Combat Features (Lights Out)
local function combatAssist()
    if getCurrentChallenge() == "lightsout" then
        safeCall(function()
            -- Find nearest enemy
            local character = player.Character
            if not character then return end
            
            local nearestEnemy = nil
            local nearestDistance = math.huge
            
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = getDistance(character.HumanoidRootPart, plr.Character.HumanoidRootPart)
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestEnemy = plr
                    end
                end
            end
            
            if nearestEnemy and nearestDistance < 20 then
                -- Auto attack
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end
        end)
    end
end

-- Farming Features
local function autoFarm()
    if not _G.autoFarm then return end
    
    safeCall(function()
        -- Auto collect Won and items
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (
                obj.Name:lower():find("won") or
                obj.Name:lower():find("coin") or
                obj.Name:lower():find("money")
            ) then
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local distance = getDistance(obj, character.HumanoidRootPart)
                    if distance < 50 then
                        character.HumanoidRootPart.CFrame = CFrame.new(obj.Position)
                        task.wait(0.1)
                    end
                end
            end
        end
    end)
end

local function afkFarm()
    if not _G.afkFarm then return end
    
    safeCall(function()
        -- Navigate to AFK World
        local gui = player.PlayerGui
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextButton") and obj.Text:lower():find("afk") then
                obj.MouseButton1Click:Fire()
                break
            end
        end
    end)
end

-- ESP Features
local function createPlayerESP()
    if not _G.playerESP then return end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and not plr.Character:FindFirstChild("PlayerESP") then
            safeCall(function()
                local highlight = Instance.new("Highlight")
                highlight.Name = "PlayerESP"
                highlight.Parent = plr.Character
                highlight.FillColor = Color3.new(0, 0.5, 1)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.7
                table.insert(espObjects, highlight)
            end)
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

-- Main Loop
local heartbeatConnection
heartbeatConnection = RunService.Heartbeat:Connect(function()
    safeCall(redLightAssist)
    safeCall(dalgonaAssist)
    safeCall(tugWarAssist)
    safeCall(glassAssist)
    safeCall(hideSeekAssist)
    safeCall(applySpeedBoost)
    safeCall(autoDash)
    safeCall(combatAssist)
    safeCall(autoFarm)
    safeCall(createPlayerESP)
    safeCall(noclip)
    safeCall(antiAFK)
end)

-- GUI Elements

-- Game Assists Tab
gameTab:CreateToggle({
   Name = "Red Light Green Light Assist",
   CurrentValue = false,
   Flag = "RedLightAssist",
   Callback = function(value)
       _G.redLightAssist = value
   end
})

gameTab:CreateToggle({
   Name = "Auto Freeze (Red Light)",
   CurrentValue = false,
   Flag = "AutoFreeze",
   Callback = function(value)
       _G.autoFreeze = value
   end
})

gameTab:CreateToggle({
   Name = "Dalgona Cookie Assist",
   CurrentValue = false,
   Flag = "DalgonaAssist",
   Callback = function(value)
       _G.dalgonaAssist = value
   end
})

gameTab:CreateToggle({
   Name = "Tug of War Assist",
   CurrentValue = false,
   Flag = "TugWarAssist",
   Callback = function(value)
       _G.tugsWarAssist = value
   end
})

gameTab:CreateToggle({
   Name = "Glass Bridge ESP",
   CurrentValue = false,
   Flag = "GlassAssist",
   Callback = function(value)
       _G.glassAssist = value
   end
})

gameTab:CreateToggle({
   Name = "Hide & Seek Assist",
   CurrentValue = false,
   Flag = "HideSeekAssist",
   Callback = function(value)
       _G.hideSeekAssist = value
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
   Name = "Auto Dash",
   CurrentValue = false,
   Flag = "AutoDash",
   Callback = function(value)
       _G.autoDash = value
   end
})

movementTab:CreateToggle({
   Name = "Smart Dash Timing",
   CurrentValue = false,
   Flag = "DashTiming",
   Callback = function(value)
       _G.dashTiming = value
   end
})

-- Farming Tab
farmTab:CreateToggle({
   Name = "Auto Farm Won",
   CurrentValue = false,
   Flag = "AutoFarm",
   Callback = function(value)
       _G.autoFarm = value
   end
})

farmTab:CreateButton({
   Name = "Go to AFK World",
   Callback = function()
       afkFarm()
   end
})

farmTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "PlayerESP",
   Callback = function(value)
       _G.playerESP = value
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
   Name = "Anti AFK",
   CurrentValue = false,
   Flag = "AntiAFK",
   Callback = function(value)
       _G.antiAFK = value
   end
})

utilityTab:CreateButton({
   Name = "Clear ESP",
   Callback = function()
       for _, obj in pairs(espObjects) do
           if obj and obj.Parent then
               obj:Destroy()
           end
       end
       espObjects = {}
   end
})

-- Notification
Rayfield:Notify({
   Title = "GILONG Hub Loaded!",
   Content = "Ink Game Script Ready! 🦑🎮",
   Duration = 5,
   Image = 4483362458,
   Actions = {
      Ignore = {
         Name = "Survive & Win!",
         Callback = function()
            print("Ink Game Script Loaded Successfully!")
         end
      },
   },
})

print("🦑 GILONG Hub - Ink Game Script Loaded!")
print("🎮 Features: Challenge Assists, Auto Farm, ESP & More!")
print("🏆 Survive all challenges and dominate the game!")
