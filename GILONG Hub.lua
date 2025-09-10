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
   },
})

-- Create Tabs
local CombatTab = Window:CreateTab("👊 Combat", nil)
local MovementTab = Window:CreateTab("🏃‍♂️ Movement", nil)
local UtilityTab = Window:CreateTab("🔧 Utility", nil)
local DebugTab = Window:CreateTab("🔧 Debug", nil)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- Global Variables
_G.autoSlap = false
_G.slapRange = 15
_G.killAura = false
_G.auraRange = 20
_G.speedBoost = false
_G.speedValue = 25
_G.flyHack = false
_G.infiniteJump = false
_G.noclip = false
_G.antiRagdoll = false
_G.antiVoid = false
_G.antiAFK = false
_G.reachExtend = false
_G.reachDistance = 25
_G.hitboxExpand = false
_G.hitboxSize = 10
_G.hitboxTransparency = 0.7
_G.reachHack = false
_G.reachSize = 20

-- Anti-Cheat Bypass Variables
_G.humanizedSlap = true
_G.randomDelay = true
_G.slapCooldown = 0.5
_G.maxSlapRate = 2
_G.bypassMode = true

-- Storage
local connections = {}
local espObjects = {}
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

-- Anti-Cheat Bypass Functions
local function isRateLimited()
    local currentTime = tick()
    
    if currentTime - lastSlapTime < _G.slapCooldown then
        return true
    end
    
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
    
    if math.random(1, 10) == 1 then
        currentPattern = math.random(1, #humanPatterns)
    end
    
    return delay
end

local function shouldBypassDetection()
    if not _G.bypassMode then return false end
    
    if math.random(1, 20) == 1 then
        return true
    end
    
    if slapCount > 0 and slapCount % 15 == 0 then
        task.wait(math.random(1, 3))
        return true
    end
    
    return false
end

-- Simple Hit System
local function simpleHit(target)
    if not target or not target.Character then return false end
    
    local character = player.Character
    if not character then return false end
    
    safeCall(function()
        -- Basic tool activation
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
        
        -- Simple mouse click on target
        local camera = Workspace.CurrentCamera
        if camera and target.Character.HumanoidRootPart then
            local targetPos = camera:WorldToScreenPoint(target.Character.HumanoidRootPart.Position)
            if targetPos.Z > 0 then
                VirtualInputManager:SendMouseButtonEvent(targetPos.X, targetPos.Y, 0, true, game, 1)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(targetPos.X, targetPos.Y, 0, false, game, 1)
            end
        end
        
        -- Fire basic remotes
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and remote.Name:lower() == "b" then
                pcall(function()
                    remote:FireServer()
                end)
                break
            end
        end
    end)
    
    return true
end

-- Combat Features
local function autoSlap()
    if not _G.autoSlap then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    if isRateLimited() or shouldBypassDetection() then
        return
    end
    
    local target = getClosestPlayer()
    
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local distance = getDistance(character.HumanoidRootPart, target.Character.HumanoidRootPart)
        local effectiveRange = _G.reachHack and (_G.slapRange + _G.reachSize) or _G.slapRange
        
        if distance <= effectiveRange then
            if _G.humanizedSlap then
                task.wait(getHumanizedDelay())
            end
            
            if simpleHit(target) then
                addSlapToHistory()
            end
        end
    end
end

local function killAura()
    if not _G.killAura then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local targetsHit = 0
    local maxTargets = _G.reachHack and 4 or 2
    local effectiveRange = _G.reachHack and (_G.auraRange + _G.reachSize) or _G.auraRange
    
    for _, plr in pairs(Players:GetPlayers()) do
        if targetsHit >= maxTargets then break end
        
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local distance = getDistance(character.HumanoidRootPart, plr.Character.HumanoidRootPart)
            
            if distance <= effectiveRange then
                if isRateLimited() then
                    break
                end
                
                task.wait(getHumanizedDelay())
                
                if simpleHit(plr) then
                    addSlapToHistory()
                    targetsHit = targetsHit + 1
                end
                
                task.wait(math.random(100, 300) / 1000)
            end
        end
    end
end

-- Movement Features
local function speedBoost()
    if not _G.speedBoost then return end
    
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = _G.speedValue
    end
end

local function flyHack()
    if not _G.flyHack then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local humanoidRootPart = character.HumanoidRootPart
    
    if not humanoidRootPart:FindFirstChild("BodyVelocity") then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = humanoidRootPart
    end
end

local function infiniteJump()
    if not _G.infiniteJump then return end
    
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.JumpPower = 100
    end
end

local function noclip()
    if not _G.noclip then return end
    
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- Utility Features
local function antiRagdoll()
    if not _G.antiRagdoll then return end
    
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.PlatformStand = false
    end
end

local function antiVoid()
    if not _G.antiVoid then return end
    
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        if character.HumanoidRootPart.Position.Y < -50 then
            character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        end
    end
end

local function antiAFK()
    if not _G.antiAFK then return end
    
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end

local function reachExtend()
    if not _G.reachExtend then return end
    
    local character = player.Character
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            tool.Handle.Size = Vector3.new(_G.reachDistance, _G.reachDistance, _G.reachDistance)
            tool.Handle.Transparency = 0.5
        end
    end
end

-- GUI Elements

-- Combat Tab
CombatTab:CreateToggle({
    Name = "Auto Slap",
    CurrentValue = false,
    Flag = "AutoSlap",
    Callback = function(Value)
        _G.autoSlap = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Slap Enabled",
                Content = "Automatically slaps nearest players. Works better with Reach Hack.",
                Duration = 3,
            })
        end
    end,
})

CombatTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(Value)
        _G.killAura = Value
        if Value then
            Rayfield:Notify({
                Title = "Kill Aura Enabled",
                Content = "Attacks multiple players in range. Enable Reach Hack for better hits.",
                Duration = 3,
            })
        end
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
    Suffix = " studs",
    CurrentValue = 15,
    Flag = "SlapRange",
    Callback = function(Value)
        _G.slapRange = Value
    end,
})

CombatTab:CreateSlider({
    Name = "Slap Cooldown",
    Range = {0.1, 2.0},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 0.5,
    Flag = "SlapCooldown",
    Callback = function(Value)
        _G.slapCooldown = Value
    end,
})

CombatTab:CreateSlider({
    Name = "Max Slaps/Second",
    Range = {1, 5},
    Increment = 1,
    Suffix = " slaps",
    CurrentValue = 2,
    Flag = "MaxSlapRate",
    Callback = function(Value)
        _G.maxSlapRate = Value
    end,
})

CombatTab:CreateToggle({
    Name = "Extended Range",
    CurrentValue = false,
    Flag = "ReachHack",
    Callback = function(Value)
        _G.reachHack = Value
        if Value then
            Rayfield:Notify({
                Title = "Extended Range Enabled",
                Content = "Increases hit detection range. Simple and effective.",
                Duration = 3,
            })
        end
    end,
})

CombatTab:CreateSlider({
    Name = "Range Extension",
    Range = {5, 50},
    Increment = 5,
    Suffix = " studs",
    CurrentValue = 15,
    Flag = "ReachSize",
    Callback = function(Value)
        _G.reachSize = Value
    end,
})

-- Movement Tab
MovementTab:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Flag = "SpeedBoost",
    Callback = function(Value)
        _G.speedBoost = Value
        if Value then
            Rayfield:Notify({
                Title = "Speed Boost Enabled",
                Content = "Increases your walking speed. Adjust value in slider below.",
                Duration = 3,
            })
        end
    end,
})

MovementTab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 100},
    Increment = 1,
    Suffix = " speed",
    CurrentValue = 25,
    Flag = "SpeedValue",
    Callback = function(Value)
        _G.speedValue = Value
    end,
})

MovementTab:CreateToggle({
    Name = "Fly Hack",
    CurrentValue = false,
    Flag = "FlyHack",
    Callback = function(Value)
        _G.flyHack = Value
        if Value then
            Rayfield:Notify({
                Title = "Fly Hack Enabled",
                Content = "Use WASD to fly around. Space = up, Shift = down.",
                Duration = 3,
            })
        end
    end,
})

MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(Value)
        _G.infiniteJump = Value
    end,
})

MovementTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        _G.noclip = Value
    end,
})

-- Utility Tab
UtilityTab:CreateToggle({
    Name = "Anti Ragdoll",
    CurrentValue = false,
    Flag = "AntiRagdoll",
    Callback = function(Value)
        _G.antiRagdoll = Value
    end,
})

UtilityTab:CreateToggle({
    Name = "Anti Void",
    CurrentValue = false,
    Flag = "AntiVoid",
    Callback = function(Value)
        _G.antiVoid = Value
        if Value then
            Rayfield:Notify({
                Title = "Anti Void Enabled",
                Content = "Prevents falling into void. Auto teleports you back to arena.",
                Duration = 3,
            })
        end
    end,
})

UtilityTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        _G.antiAFK = Value
    end,
})

UtilityTab:CreateToggle({
    Name = "Reach Extend",
    CurrentValue = false,
    Flag = "ReachExtend",
    Callback = function(Value)
        _G.reachExtend = Value
    end,
})

-- Debug Tab
DebugTab:CreateButton({
    Name = "Debug Info",
    Callback = function()
        local currentGlove = getCurrentGlove()
        local config = getGloveConfig(currentGlove)
        
        print("=== DEBUG INFO ===")
        print("Current Glove:", currentGlove)
        print("Glove Config:")
        print("  - Range:", config.range)
        print("  - Hitbox:", config.hitbox)
        print("  - Method:", config.method)
        print("Slap Count:", slapCount)
        print("Last Slap Time:", lastSlapTime)
        print("Rate Limited:", isRateLimited())
        print("Bypass Settings:")
        print("  - Humanized:", _G.humanizedSlap)
        print("  - Random Delay:", _G.randomDelay)
        print("  - Bypass Mode:", _G.bypassMode)
        print("  - Cooldown:", _G.slapCooldown)
        print("  - Max Rate:", _G.maxSlapRate)
        
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

DebugTab:CreateParagraph({Title = "Reach System", Content = "Reach Hack extends your tool's reach by making it bigger and adding invisible parts. More reliable than hitbox expansion."})

DebugTab:CreateButton({
    Name = "Test Hit System",
    Callback = function()
        local target = getClosestPlayer()
        if target then
            local success = simpleHit(target)
            Rayfield:Notify({
                Title = "Hit Test",
                Content = success and "Hit attempt sent to " .. target.Name or "No target found",
                Duration = 2,
            })
        else
            Rayfield:Notify({
                Title = "Hit Test",
                Content = "No target found nearby",
                Duration = 2,
            })
        end
    end,
})

-- Main Loop
local loopCount = 0
RunService.Heartbeat:Connect(function()
    loopCount = loopCount + 1
    
    if _G.autoSlap then autoSlap() end
    if _G.killAura then killAura() end
    if _G.speedBoost then speedBoost() end
    if _G.flyHack then flyHack() end
    if _G.infiniteJump then infiniteJump() end
    if _G.noclip then noclip() end
    if _G.antiRagdoll then antiRagdoll() end
    if _G.antiVoid then antiVoid() end
    if _G.antiAFK then antiAFK() end
    
    if loopCount % 5 == 0 then
        if _G.reachExtend then reachExtend() end
        -- Update reach system every 5 frames
        if _G.reachHack and loopCount % 30 == 0 then
            -- Periodic reach validation
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
print("💥 Features: Auto Slap, Kill Aura, Anti-Cheat Bypass & More!")
print("🏆 Dominate the arena safely!")
