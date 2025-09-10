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

-- Anti-Cheat Bypass Variables
_G.humanizedSlap = true
_G.randomDelay = true
_G.slapCooldown = 0.5
_G.maxSlapRate = 2
_G.bypassMode = true

-- Storage
local connections = {}
local espObjects = {}
local originalValues = {}
local targetPlayer = nil

-- Anti-Cheat Bypass Storage
local lastSlapTime = 0
local slapCount = 0
local slapHistory = {}
local humanPatterns = {
    {0.3, 0.7}, {0.4, 0.9}, {0.5, 1.2}, {0.2, 0.8}, {0.6, 1.1}
}
local currentPattern = 1

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

-- Anti-Cheat Bypass Functions
local function isRateLimited()
    local currentTime = tick()
    
    -- Check cooldown
    if currentTime - lastSlapTime < _G.slapCooldown then
        return true
    end
    
    -- Check rate limiting (slaps per second)
    local recentSlaps = 0
    for i = #slapHistory, 1, -1 do
        if currentTime - slapHistory[i] <= 1 then
            recentSlaps = recentSlaps + 1
        else
            break
        end
    end
    
    if recentSlaps >= _G.maxSlapRate then
        return true
    end
    
    return false
end

local function addSlapToHistory()
    local currentTime = tick()
    table.insert(slapHistory, currentTime)
    lastSlapTime = currentTime
    slapCount = slapCount + 1
    
    -- Clean old entries (keep only last 10 seconds)
    for i = #slapHistory, 1, -1 do
        if currentTime - slapHistory[i] > 10 then
            table.remove(slapHistory, i)
        end
    end
end

local function getHumanizedDelay()
    if not _G.randomDelay then return 0.1 end
    
    local pattern = humanPatterns[currentPattern]
    local delay = math.random(pattern[1] * 100, pattern[2] * 100) / 100
    
    -- Change pattern occasionally
    if math.random(1, 10) == 1 then
        currentPattern = math.random(1, #humanPatterns)
    end
    
    return delay
end

local function shouldBypassDetection()
    if not _G.bypassMode then return false end
    
    -- Skip slap occasionally to seem more human
    if math.random(1, 20) == 1 then
        return true
    end
    
    -- Skip if too many recent slaps
    if slapCount > 0 and slapCount % 15 == 0 then
        task.wait(math.random(1, 3))
        return true
    end
    
    return false
end

-- Combat Features
local function autoSlap()
    if not _G.autoSlap then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    -- Anti-cheat checks
    if isRateLimited() or shouldBypassDetection() then
        return
    end
    
    local target = getClosestPlayer()
    
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local distance = getDistance(character.HumanoidRootPart, target.Character.HumanoidRootPart)
        
        if distance <= _G.slapRange then
            safeCall(function()
                -- Add humanized delay before slapping
                if _G.humanizedSlap then
                    task.wait(getHumanizedDelay())
                end
                -- Method 1: Direct tool activation (most reliable)
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                    
                    -- Humanized delay between tool activation and remote calls
                    if _G.humanizedSlap then
                        task.wait(math.random(10, 50) / 1000) -- 10-50ms delay
                    end
                    
                    -- Try firing tool's remotes with limited attempts
                    local attempts = 0
                    for _, obj in pairs(tool:GetDescendants()) do
                        if obj:IsA("RemoteEvent") and attempts < 2 then
                            pcall(function()
                                obj:FireServer()
                                obj:FireServer(target.Character.HumanoidRootPart)
                            end)
                            attempts = attempts + 1
                        end
                    end
                end
                
                -- Method 2: Mouse simulation with slight randomization
                local camera = Workspace.CurrentCamera
                local targetPos = camera:WorldToScreenPoint(target.Character.HumanoidRootPart.Position)
                
                -- Add slight randomization to mouse position
                local offsetX = math.random(-5, 5)
                local offsetY = math.random(-5, 5)
                
                VirtualInputManager:SendMouseButtonEvent(targetPos.X + offsetX, targetPos.Y + offsetY, 0, true, game, 1)
                task.wait(math.random(15, 35) / 1000) -- Randomized click duration
                VirtualInputManager:SendMouseButtonEvent(targetPos.X + offsetX, targetPos.Y + offsetY, 0, false, game, 1)
                
                -- Method 3: Limited remote attempts to avoid detection
                local remoteAttempts = 0
                local maxRemoteAttempts = 3
                
                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") and remoteAttempts < maxRemoteAttempts then
                        local name = remote.Name:lower()
                        if name == "b" or name == "slap" or name == "hit" or name == "swing" or
                           name == "remote" or name:find("glove") or name:find("attack") or
                           (name:len() == 1 and math.random(1, 3) == 1) then -- Randomize single letter attempts
                            pcall(function()
                                -- Only send most likely to work parameters
                                remote:FireServer()
                                if math.random(1, 2) == 1 then
                                    remote:FireServer(target.Character)
                                end
                            end)
                            remoteAttempts = remoteAttempts + 1
                            
                            -- Small delay between remote calls
                            if _G.humanizedSlap then
                                task.wait(math.random(5, 15) / 1000)
                            end
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
                
                -- Method 5: Limited key simulation
                if math.random(1, 4) == 1 then -- Only 25% chance to use keys
                    local key = Enum.KeyCode.E -- Only use E key to be less suspicious
                    UserInputService:SendKeyEvent(true, key, false, game)
                    task.wait(math.random(20, 60) / 1000) -- Humanized key hold time
                    UserInputService:SendKeyEvent(false, key, false, game)
                end
                
                -- Record this slap attempt
                addSlapToHistory()
            end)
        end
    end
end

local function killAura()
    if not _G.killAura then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    -- Anti-cheat: Limit aura to fewer targets and add delays
    local targetsHit = 0
    local maxTargets = 2 -- Limit simultaneous targets
    
    for _, plr in pairs(Players:GetPlayers()) do
        if targetsHit >= maxTargets then break end
        
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local distance = getDistance(character.HumanoidRootPart, plr.Character.HumanoidRootPart)
            
            if distance <= _G.auraRange then
                -- Check rate limiting per target
                if isRateLimited() then
                    break
                end
                
                safeCall(function()
                    -- Humanized delay before each target
                    task.wait(getHumanizedDelay())
                    
                    -- Method 1: Tool activation with chance
                    if math.random(1, 3) <= 2 then -- 66% chance
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                        end
                    end
                    
                    -- Method 2: Limited remote attempts
                    local attempts = 0
                    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and attempts < 1 then
                            local name = remote.Name:lower()
                            if name == "b" or name:find("slap") then
                                pcall(function()
                                    -- Only send most likely to work parameters
                                    remote:FireServer()
                                end)
                                attempts = attempts + 1
                            end
                        end
                    end
{{ ... }}
            end
        end
    end
end)

-- Main Loop with reduced frequency for some features
local loopCount = 0
RunService.Heartbeat:Connect(function()
    loopCount = loopCount + 1
    
    -- High frequency features (every frame)
    if _G.autoSlap then autoSlap() end
    if _G.killAura then killAura() end
    if _G.speedBoost then speedBoost() end
    if _G.flyHack then flyHack() end
    if _G.infiniteJump then infiniteJump() end
    if _G.noclip then noclip() end
    if _G.antiRagdoll then antiRagdoll() end
    if _G.antiVoid then antiVoid() end
    if _G.antiAFK then antiAFK() end
    
    -- Lower frequency features (every 10 frames to reduce load)
    if loopCount % 10 == 0 then
        if _G.autoFarm then autoFarm() end
        if _G.reachExtend then reachExtend() end
        if _G.autoEquip then autoEquipGlove() end
    end
end)

-- GUI Elements

-- Combat Tab
CombatTab:CreateToggle({
    Name = "Auto Slap",
    CurrentValue = false,
    Flag = "AutoSlap",
    Callback = function(Value)
        _G.autoSlap = Value
    end,
})

CombatTab:CreateToggle({
    Name = "Humanized Slapping",
    CurrentValue = true,
    Flag = "HumanizedSlap",
    Callback = function(Value)
        _G.humanizedSlap = Value
    end,
})

CombatTab:CreateToggle({
    Name = "Random Delays",
    CurrentValue = true,
    Flag = "RandomDelay",
    Callback = function(Value)
        _G.randomDelay = Value
    end,
})

CombatTab:CreateToggle({
    Name = "Bypass Mode",
    CurrentValue = true,
    Flag = "BypassMode",
    Callback = function(Value)
        _G.bypassMode = Value
    end,
})

CombatTab:CreateSlider({
    Name = "Slap Range",
    Range = {5, 50},
    Increment = 1,
{{ ... }}
           end
       end)
   end
})

-- Debug Tab
DebugTab:CreateButton({
    Name = "Debug Info",
    Callback = function()
        local character = player.Character
        local currentGlove = getCurrentGlove()
        local availableGloves = getAvailableGloves()
        
        print("=== DEBUG INFO ===")
        print("Current Glove:", currentGlove)
        print("Available Gloves:", table.concat(availableGloves, ", "))
        print("Slap Count:", slapCount)
        print("Last Slap Time:", lastSlapTime)
        print("Rate Limited:", isRateLimited())
        print("Bypass Settings:")
        print("  - Humanized:", _G.humanizedSlap)
        print("  - Random Delay:", _G.randomDelay)
        print("  - Bypass Mode:", _G.bypassMode)
        print("  - Cooldown:", _G.slapCooldown)
        print("  - Max Rate:", _G.maxSlapRate)
        
        if character then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                print("Tool Children:")
                for _, child in pairs(tool:GetChildren()) do
                    print("  -", child.Name, "(", child.ClassName, ")")
                end
            end
        end
        
        print("Remote Events:")
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                print("  -", remote.Name)
            end
        end
        print("=================")
    end,
})

DebugTab:CreateButton({
    Name = "Reset Slap History",
    Callback = function()
        slapHistory = {}
        slapCount = 0
        lastSlapTime = 0
        print("[Slap Battles] Slap history reset!")
    end,
})

DebugTab:CreateButton({
    Name = "Teleport to Arena Center",
    Callback = function()
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
            print("[Slap Battles] Teleported to arena center!")
        end
    end,
})

DebugTab:CreateLabel("Anti-Cheat Status")

DebugTab:CreateParagraph({Title = "Bypass Info", Content = "Humanized slapping uses random delays and patterns to avoid detection. Lower cooldown = higher risk. Max 2 slaps/second recommended."})

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
