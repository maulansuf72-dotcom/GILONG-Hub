-- Slap Battles - Ultimate Script Hub
-- Created by GILONG Hub | Optimized for Maximum Slaps

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "GILONG Hub | Slap Battles",
   Icon = 0,
   LoadingTitle = "Slap Battles Script",
   LoadingSubtitle = "By RYXu",
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
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

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
_G.esp = false
_G.teleportToPlayers = false
_G.showHP = false
_G.lowHPAlert = false
_G.lowHPThreshold = 20

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

-- HP System
local hpGui = nil
local hpLabel = nil

local function createHPDisplay()
    if hpGui then return end
    
    hpGui = Instance.new("ScreenGui")
    hpGui.Name = "HPDisplay"
    hpGui.Parent = player.PlayerGui
    
    local frame = Instance.new("Frame")
    -- Mobile-friendly sizing
    if isMobile then
        frame.Size = UDim2.new(0, 250, 0, 80)
        frame.Position = UDim2.new(0, 10, 0, 150)
    else
        frame.Size = UDim2.new(0, 200, 0, 60)
        frame.Position = UDim2.new(0, 10, 0, 100)
    end
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = hpGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    hpLabel = Instance.new("TextLabel")
    hpLabel.Size = UDim2.new(1, 0, 1, 0)
    hpLabel.Position = UDim2.new(0, 0, 0, 0)
    hpLabel.BackgroundTransparency = 1
    hpLabel.Text = "HP: 100/100"
    hpLabel.TextColor3 = Color3.new(0, 1, 0)
    hpLabel.TextScaled = true
    hpLabel.Font = Enum.Font.GothamBold
    hpLabel.Parent = frame
end

local function removeHPDisplay()
    if hpGui then
        hpGui:Destroy()
        hpGui = nil
        hpLabel = nil
    end
end

local function updateHP()
    if not _G.showHP or not hpLabel then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local humanoid = character.Humanoid
    local currentHP = math.floor(humanoid.Health)
    local maxHP = math.floor(humanoid.MaxHealth)
    
    hpLabel.Text = "HP: " .. currentHP .. "/" .. maxHP
    
    -- Color based on HP percentage
    local hpPercent = (currentHP / maxHP) * 100
    if hpPercent > 70 then
        hpLabel.TextColor3 = Color3.new(0, 1, 0) -- Green
    elseif hpPercent > 30 then
        hpLabel.TextColor3 = Color3.new(1, 1, 0) -- Yellow
    else
        hpLabel.TextColor3 = Color3.new(1, 0, 0) -- Red
    end
    
    -- Low HP Alert
    if _G.lowHPAlert and hpPercent <= _G.lowHPThreshold then
        Rayfield:Notify({
            Title = "⚠️ LOW HP WARNING!",
            Content = "Health: " .. currentHP .. "/" .. maxHP .. " (" .. math.floor(hpPercent) .. "%)",
            Duration = 2,
        })
    end
end

-- ESP + Click TP System (Fixed Template)
local mouse = player:GetMouse()
local espConnections = {}
local playerJoinConnection
local clickTeleportConnection

-- Add ESP to character (Multiple Methods for Compatibility)
local function addESP(char)
    if not char or not _G.esp then return end
    
    -- Remove existing ESP
    local existingHighlight = char:FindFirstChild("ESP_Highlight")
    local existingBox = char:FindFirstChild("ESP_Box")
    local existingBillboard = char:FindFirstChild("ESP_Name")
    
    if existingHighlight then existingHighlight:Destroy() end
    if existingBox then existingBox:Destroy() end
    if existingBillboard then existingBillboard:Destroy() end
    
    -- Method 1: Highlight (Primary)
    pcall(function()
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Parent = char
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Bright green
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- White
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end)
    
    -- Method 2: SelectionBox (Fallback)
    pcall(function()
        local box = Instance.new("SelectionBox")
        box.Name = "ESP_Box"
        box.Parent = char
        box.Adornee = char
        box.Color3 = Color3.fromRGB(0, 255, 0) -- Green
        box.LineThickness = 0.15
        box.Transparency = 0.3
    end)
    
    -- Method 3: Name Billboard (Always works)
    pcall(function()
        local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESP_Name"
            billboard.Parent = humanoidRootPart
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Parent = billboard
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = "[ESP] " .. Players:GetPlayerFromCharacter(char).Name
            nameLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green text
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        end
    end)
end

-- Remove ESP from character
local function removeESPFromChar(char)
    if char then
        local highlight = char:FindFirstChild("ESP_Highlight")
        local box = char:FindFirstChild("ESP_Box")
        local billboard = char:FindFirstChild("ESP_Name")
        
        if highlight then highlight:Destroy() end
        if box then box:Destroy() end
        if billboard then billboard:Destroy() end
        
        -- Also check HumanoidRootPart for billboard
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local hbillboard = hrp:FindFirstChild("ESP_Name")
            if hbillboard then hbillboard:Destroy() end
        end
    end
end

-- Setup ESP for all players with auto-refresh
local function setupESP()
    if not _G.esp then return end
    
    -- Add ESP to existing players
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            addESP(plr.Character)
        end
        
        -- Connect to new characters (respawn)
        if not espConnections[plr] then
            espConnections[plr] = plr.CharacterAdded:Connect(function(char)
                if plr ~= player and _G.esp then
                    task.wait(0.5) -- Wait for character to load
                    addESP(char)
                end
            end)
        end
    end
    
    -- Setup auto-refresh for new players joining
    if not playerJoinConnection then
        playerJoinConnection = Players.PlayerAdded:Connect(function(newPlayer)
            if _G.esp and newPlayer ~= player then
                -- Connect to character spawn
                espConnections[newPlayer] = newPlayer.CharacterAdded:Connect(function(char)
                    if newPlayer ~= player and _G.esp then
                        task.wait(0.5)
                        addESP(char)
                    end
                end)
                
                -- If character already exists
                if newPlayer.Character then
                    task.wait(0.5)
                    addESP(newPlayer.Character)
                end
            end
        end)
    end
end

-- Remove all ESP
local function removeAllESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            removeESPFromChar(plr.Character)
        end
    end
    
    -- Disconnect all connections
    for plr, connection in pairs(espConnections) do
        if connection then
            connection:Disconnect()
        end
        espConnections[plr] = nil
    end
    
    -- Disconnect player join connection
    if playerJoinConnection then
        playerJoinConnection:Disconnect()
        playerJoinConnection = nil
    end
    
    -- Disconnect click teleport
    if clickTeleportConnection then
        clickTeleportConnection:Disconnect()
        clickTeleportConnection = nil
    end
end

-- Click to teleport function (Fixed)
local function setupClickTeleport()
    if clickTeleportConnection then
        clickTeleportConnection:Disconnect()
        clickTeleportConnection = nil
    end
    
    if _G.teleportToPlayers then
        clickTeleportConnection = mouse.Button1Down:Connect(function()
            if mouse.Target and mouse.Target.Parent then
                local targetPlayer = Players:GetPlayerFromCharacter(mouse.Target.Parent)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                        Rayfield:Notify({
                            Title = "Teleported!",
                            Content = "Teleported to " .. targetPlayer.Name,
                            Duration = 2,
                        })
                    end
                end
            end
        end)
    end
end

local function basicHit(target)
    if not target or not target.Character then return end
    
    local character = player.Character
    if not character then return end
    
    -- Simple tool activation
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
    
    -- Fire the main remote
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name == "b" then
            v:FireServer()
            break
        end
    end
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
        local effectiveRange = _G.slapRange
        
        if distance <= effectiveRange then
            if _G.humanizedSlap then
                task.wait(getHumanizedDelay())
            end
            
            basicHit(target)
            addSlapToHistory()
        end
    end
end

local function killAura()
    if not _G.killAura then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local targetsHit = 0
    local maxTargets = _G.reachHack and 4 or 2
    local effectiveRange = _G.auraRange
    
    for _, plr in pairs(Players:GetPlayers()) do
        if targetsHit >= maxTargets then break end
        
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local distance = getDistance(character.HumanoidRootPart, plr.Character.HumanoidRootPart)
            
            if distance <= effectiveRange then
                if isRateLimited() then
                    break
                end
                
                task.wait(getHumanizedDelay())
                
                basicHit(plr)
                addSlapToHistory()
                targetsHit = targetsHit + 1
                
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
                Content = "Automatically slaps nearest players. Use ESP to see all players!",
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
                Content = "Attacks multiple players in range. Use ESP to locate targets!",
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
    Name = "ESP (Player Highlight)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        _G.esp = Value
        if Value then
            setupESP()
            Rayfield:Notify({
                Title = "ESP Enabled",
                Content = "Players highlighted in green! Click to teleport if enabled.",
                Duration = 3,
            })
        else
            removeAllESP()
        end
    end,
})

CombatTab:CreateToggle({
    Name = "Click to Teleport",
    CurrentValue = false,
    Flag = "TeleportToPlayers",
    Callback = function(Value)
        _G.teleportToPlayers = Value
        setupClickTeleport()
        if Value then
            Rayfield:Notify({
                Title = "Click Teleport Enabled",
                Content = "Click on any player to teleport to them!",
                Duration = 3,
            })
        else
            if clickTeleportConnection then
                clickTeleportConnection:Disconnect()
                clickTeleportConnection = nil
            end
        end
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

DebugTab:CreateParagraph({Title = "ESP System", Content = "ESP highlights all players with red boxes and shows their names. Teleport feature allows you to click on players to teleport to them instantly."})

DebugTab:CreateButton({
    Name = "Teleport to Closest Player",
    Callback = function()
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                Rayfield:Notify({
                    Title = "Teleported",
                    Content = "Teleported to " .. target.Name,
                    Duration = 2,
                })
            end
        else
            Rayfield:Notify({
                Title = "Teleport Failed",
                Content = "No players nearby",
                Duration = 2,
            })
        end
    end,
})

DebugTab:CreateButton({
    Name = "Refresh ESP",
    Callback = function()
        removeAllESP()
        if _G.esp then
            setupESP()
        end
        Rayfield:Notify({
            Title = "ESP Refreshed",
            Content = "ESP system refreshed for all players",
            Duration = 2,
        })
    end,
})

-- HP Tab
local HPTab = Window:CreateTab("🩺 HP System", 4483362458)

HPTab:CreateToggle({
    Name = "Show HP Display",
    CurrentValue = false,
    Flag = "ShowHP",
    Callback = function(Value)
        _G.showHP = Value
        if Value then
            createHPDisplay()
            Rayfield:Notify({
                Title = "HP Display Enabled",
                Content = "Health display is now visible on screen",
                Duration = 3,
            })
        else
            removeHPDisplay()
        end
    end,
})

HPTab:CreateToggle({
    Name = "Low HP Alert",
    CurrentValue = false,
    Flag = "LowHPAlert",
    Callback = function(Value)
        _G.lowHPAlert = Value
        if Value then
            Rayfield:Notify({
                Title = "Low HP Alert Enabled",
                Content = "You'll get notified when HP is low",
                Duration = 3,
            })
        end
    end,
})

HPTab:CreateSlider({
    Name = "Low HP Threshold",
    Range = {10, 50},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 20,
    Flag = "LowHPThreshold",
    Callback = function(Value)
        _G.lowHPThreshold = Value
    end,
})

HPTab:CreateButton({
    Name = "Check Current HP",
    Callback = function()
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            local currentHP = math.floor(humanoid.Health)
            local maxHP = math.floor(humanoid.MaxHealth)
            local hpPercent = math.floor((currentHP / maxHP) * 100)
            
            Rayfield:Notify({
                Title = "Current Health Status",
                Content = "HP: " .. currentHP .. "/" .. maxHP .. " (" .. hpPercent .. "%)",
                Duration = 4,
            })
        else
            Rayfield:Notify({
                Title = "Health Check Failed",
                Content = "Cannot read health - character not found",
                Duration = 3,
            })
        end
    end,
})

HPTab:CreateParagraph({Title = "HP System Info", Content = "Monitor your health in real-time. The HP display shows current/max health with color coding: Green (70%+), Yellow (30-70%), Red (<30%). Low HP alerts will notify you when health drops below the threshold."})

HPTab:CreateParagraph({Title = "HP Glove Support", Content = "The Hitbox Expander fully supports HP glove! When using HP glove, the hitbox becomes 1.5x larger for better healing range, and the hit system uses special healing parameters for optimal performance."})

HPTab:CreateParagraph({Title = "Mobile Support", Content = "This script is fully compatible with mobile devices! Touch controls are automatically detected and used. The HP display is optimized for mobile screens, and all features work seamlessly on both PC and mobile."})

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
    
    -- Update HP display
    if _G.showHP and loopCount % 30 == 0 then
        updateHP()
    end
    
    if loopCount % 5 == 0 then
        if _G.reachExtend then reachExtend() end
        if _G.esp and loopCount % 120 == 0 then
            setupESP()
        end
    end
end)

-- Notification
Rayfield:Notify({
   Title = "GILONG Hub Loaded!",
   Content = "Slap Battles Script Ready! " .. (isMobile and "📱 Mobile Mode" or "💻 PC Mode") .. " 👊💥",
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

