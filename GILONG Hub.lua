-- GILONG Hub - No Orion Version
-- Key: AyamGoreng!
-- Pure Roblox GUI Implementation

wait(2)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Key System
local correctKey = "AyamGoreng!"
local keyLink = "https://link-hub.net/1392772/AfVHcFNYkLMx"

-- Variables
local killAura = false
local killAuraRange = 50
local autoChopTree = false
local chopTreeRange = 50
local bringItems = false
local selectedItems = {}
local connections = {}

-- Copy function
local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
        return true
    end
    return false
end

-- Create GUI Function
local function createGUI()
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GILONGHub"
    screenGui.Parent = playerGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = mainFrame
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "GILONG Hub - 99 Night Forest"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Parent = mainFrame
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 5)
    closeBtnCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Scroll Frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Parent = mainFrame
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    scrollFrame.ScrollBarThickness = 5
    
    local yPos = 0
    
    -- Function to create button
    local function createButton(text, callback)
        local button = Instance.new("TextButton")
        button.Parent = scrollFrame
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.Position = UDim2.new(0, 0, 0, yPos)
        button.Size = UDim2.new(1, -10, 0, 35)
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.Gotham
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 5)
        buttonCorner.Parent = button
        
        button.MouseButton1Click:Connect(callback)
        
        yPos = yPos + 45
        return button
    end
    
    -- Function to create toggle
    local function createToggle(text, callback)
        local frame = Instance.new("Frame")
        frame.Parent = scrollFrame
        frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.Size = UDim2.new(1, -10, 0, 35)
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 5)
        frameCorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        
        local toggle = Instance.new("TextButton")
        toggle.Parent = frame
        toggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        toggle.Position = UDim2.new(1, -60, 0, 5)
        toggle.Size = UDim2.new(0, 50, 0, 25)
        toggle.Text = "OFF"
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextScaled = true
        toggle.Font = Enum.Font.GothamBold
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 5)
        toggleCorner.Parent = toggle
        
        local isToggled = false
        
        toggle.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            if isToggled then
                toggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                toggle.Text = "ON"
            else
                toggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                toggle.Text = "OFF"
            end
            callback(isToggled)
        end)
        
        yPos = yPos + 45
        return toggle
    end
    
    -- Function to create slider
    local function createSlider(text, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Parent = scrollFrame
        frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.Size = UDim2.new(1, -10, 0, 50)
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 5)
        frameCorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Size = UDim2.new(1, -20, 0, 25)
        label.Text = text .. ": " .. default
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Parent = frame
        sliderFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        sliderFrame.Position = UDim2.new(0, 10, 0, 30)
        sliderFrame.Size = UDim2.new(1, -20, 0, 10)
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 5)
        sliderCorner.Parent = sliderFrame
        
        local sliderButton = Instance.new("TextButton")
        sliderButton.Parent = sliderFrame
        sliderButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        sliderButton.Position = UDim2.new(0, 0, 0, 0)
        sliderButton.Size = UDim2.new(0, 20, 1, 0)
        sliderButton.Text = ""
        
        local sliderBtnCorner = Instance.new("UICorner")
        sliderBtnCorner.CornerRadius = UDim.new(0, 5)
        sliderBtnCorner.Parent = sliderButton
        
        local dragging = false
        local currentValue = default
        
        sliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouse = UserInputService:GetMouseLocation()
                local framePos = sliderFrame.AbsolutePosition.X
                local frameSize = sliderFrame.AbsoluteSize.X
                local relativePos = math.clamp((mouse.X - framePos) / frameSize, 0, 1)
                
                sliderButton.Position = UDim2.new(relativePos, -10, 0, 0)
                currentValue = math.floor(min + (max - min) * relativePos)
                label.Text = text .. ": " .. currentValue
                callback(currentValue)
            end
        end)
        
        yPos = yPos + 60
        return sliderButton
    end
    
    -- Create GUI Elements
    
    -- Combat Section
    local combatLabel = Instance.new("TextLabel")
    combatLabel.Parent = scrollFrame
    combatLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    combatLabel.Position = UDim2.new(0, 0, 0, yPos)
    combatLabel.Size = UDim2.new(1, -10, 0, 30)
    combatLabel.Text = "🗡️ COMBAT"
    combatLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    combatLabel.TextScaled = true
    combatLabel.Font = Enum.Font.GothamBold
    
    local combatCorner = Instance.new("UICorner")
    combatCorner.CornerRadius = UDim.new(0, 5)
    combatCorner.Parent = combatLabel
    
    yPos = yPos + 40
    
    -- Kill Aura Toggle
    createToggle("Kill Aura", function(value)
        killAura = value
        if killAura then
            connections.killAura = RunService.Heartbeat:Connect(function()
                if not killAura then return end
                pcall(function()
                    local character = player.Character
                    if not character then return end
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then return end
                    
                    for _, obj in pairs(Workspace:GetChildren()) do
                        if obj:FindFirstChild("Humanoid") and obj ~= character then
                            local enemyRoot = obj:FindFirstChild("HumanoidRootPart")
                            if enemyRoot then
                                local distance = (rootPart.Position - enemyRoot.Position).Magnitude
                                if distance <= killAuraRange then
                                    local attackRemote = ReplicatedStorage:FindFirstChild("Attack")
                                    if attackRemote then
                                        attackRemote:FireServer(obj)
                                    end
                                    wait(0.1)
                                    break
                                end
                            end
                        end
                    end
                end)
            end)
        else
            if connections.killAura then
                connections.killAura:Disconnect()
            end
        end
    end)
    
    -- Kill Aura Range
    createSlider("Kill Aura Range", 1, 500, 50, function(value)
        killAuraRange = value
    end)
    
    -- Farming Section
    local farmLabel = Instance.new("TextLabel")
    farmLabel.Parent = scrollFrame
    farmLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    farmLabel.Position = UDim2.new(0, 0, 0, yPos)
    farmLabel.Size = UDim2.new(1, -10, 0, 30)
    farmLabel.Text = "🌲 FARMING"
    farmLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    farmLabel.TextScaled = true
    farmLabel.Font = Enum.Font.GothamBold
    
    local farmCorner = Instance.new("UICorner")
    farmCorner.CornerRadius = UDim.new(0, 5)
    farmCorner.Parent = farmLabel
    
    yPos = yPos + 40
    
    -- Auto Chop Tree
    createToggle("Auto Chop Tree", function(value)
        autoChopTree = value
        if autoChopTree then
            connections.autoChopTree = RunService.Heartbeat:Connect(function()
                if not autoChopTree then return end
                pcall(function()
                    local character = player.Character
                    if not character then return end
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then return end
                    
                    for _, obj in pairs(Workspace:GetChildren()) do
                        if obj.Name:lower():find("tree") and obj:FindFirstChild("Part") then
                            local treePart = obj:FindFirstChild("Part")
                            local distance = (rootPart.Position - treePart.Position).Magnitude
                            if distance <= chopTreeRange then
                                local chopRemote = ReplicatedStorage:FindFirstChild("ChopTree")
                                if chopRemote then
                                    chopRemote:FireServer(obj)
                                end
                                wait(0.2)
                                break
                            end
                        end
                    end
                end)
            end)
        else
            if connections.autoChopTree then
                connections.autoChopTree:Disconnect()
            end
        end
    end)
    
    -- Chop Tree Range
    createSlider("Chop Tree Range", 1, 500, 50, function(value)
        chopTreeRange = value
    end)
    
    -- Items Section
    local itemLabel = Instance.new("TextLabel")
    itemLabel.Parent = scrollFrame
    itemLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    itemLabel.Position = UDim2.new(0, 0, 0, yPos)
    itemLabel.Size = UDim2.new(1, -10, 0, 30)
    itemLabel.Text = "📦 ITEMS"
    itemLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    itemLabel.TextScaled = true
    itemLabel.Font = Enum.Font.GothamBold
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 5)
    itemCorner.Parent = itemLabel
    
    yPos = yPos + 40
    
    -- Bring Items
    createToggle("Bring Items", function(value)
        bringItems = value
        if bringItems then
            connections.bringItems = RunService.Heartbeat:Connect(function()
                if not bringItems then return end
                pcall(function()
                    local character = player.Character
                    if not character then return end
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then return end
                    
                    for _, obj in pairs(Workspace:GetChildren()) do
                        if obj.Name:lower():find("wood") and obj:FindFirstChild("Part") then
                            local itemPart = obj:FindFirstChild("Part")
                            itemPart.CFrame = rootPart.CFrame * CFrame.new(0, 2, 0)
                            wait(0.05)
                        end
                    end
                end)
            end)
        else
            if connections.bringItems then
                connections.bringItems:Disconnect()
            end
        end
    end)
    
    -- Player Section
    local playerLabel = Instance.new("TextLabel")
    playerLabel.Parent = scrollFrame
    playerLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    playerLabel.Position = UDim2.new(0, 0, 0, yPos)
    playerLabel.Size = UDim2.new(1, -10, 0, 30)
    playerLabel.Text = "👤 PLAYER"
    playerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerLabel.TextScaled = true
    playerLabel.Font = Enum.Font.GothamBold
    
    local playerCorner = Instance.new("UICorner")
    playerCorner.CornerRadius = UDim.new(0, 5)
    playerCorner.Parent = playerLabel
    
    yPos = yPos + 40
    
    -- Walk Speed
    createSlider("Walk Speed", 16, 200, 16, function(value)
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end)
    
    -- Jump Power
    createSlider("Jump Power", 50, 300, 50, function(value)
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = value
            end
        end
    end)
    
    -- Misc Section
    local miscLabel = Instance.new("TextLabel")
    miscLabel.Parent = scrollFrame
    miscLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    miscLabel.Position = UDim2.new(0, 0, 0, yPos)
    miscLabel.Size = UDim2.new(1, -10, 0, 30)
    miscLabel.Text = "⚙️ MISC"
    miscLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    miscLabel.TextScaled = true
    miscLabel.Font = Enum.Font.GothamBold
    
    local miscCorner = Instance.new("UICorner")
    miscCorner.CornerRadius = UDim.new(0, 5)
    miscCorner.Parent = miscLabel
    
    yPos = yPos + 40
    
    -- Rejoin Button
    createButton("Rejoin Server", function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
end

-- Key System GUI
local function createKeyGUI()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "GILONGKeySystem"
    keyGui.Parent = playerGui
    
    local keyFrame = Instance.new("Frame")
    keyFrame.Parent = keyGui
    keyFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    keyFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    keyFrame.Size = UDim2.new(0, 400, 0, 300)
    keyFrame.BorderSizePixel = 0
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 10)
    keyCorner.Parent = keyFrame
    
    local keyTitle = Instance.new("TextLabel")
    keyTitle.Parent = keyFrame
    keyTitle.BackgroundTransparency = 1
    keyTitle.Position = UDim2.new(0, 0, 0, 10)
    keyTitle.Size = UDim2.new(1, 0, 0, 50)
    keyTitle.Text = "GILONG Hub - Key System"
    keyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyTitle.TextScaled = true
    keyTitle.Font = Enum.Font.GothamBold
    
    local keyBox = Instance.new("TextBox")
    keyBox.Parent = keyFrame
    keyBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    keyBox.Position = UDim2.new(0, 50, 0, 100)
    keyBox.Size = UDim2.new(0, 300, 0, 40)
    keyBox.PlaceholderText = "Enter Key Here..."
    keyBox.Text = ""
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.TextScaled = true
    keyBox.Font = Enum.Font.Gotham
    
    local keyBoxCorner = Instance.new("UICorner")
    keyBoxCorner.CornerRadius = UDim.new(0, 5)
    keyBoxCorner.Parent = keyBox
    
    local submitBtn = Instance.new("TextButton")
    submitBtn.Parent = keyFrame
    submitBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    submitBtn.Position = UDim2.new(0, 50, 0, 160)
    submitBtn.Size = UDim2.new(0, 140, 0, 40)
    submitBtn.Text = "Submit Key"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.TextScaled = true
    submitBtn.Font = Enum.Font.GothamBold
    
    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 5)
    submitCorner.Parent = submitBtn
    
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Parent = keyFrame
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    getKeyBtn.Position = UDim2.new(0, 210, 0, 160)
    getKeyBtn.Size = UDim2.new(0, 140, 0, 40)
    getKeyBtn.Text = "Get Key"
    getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyBtn.TextScaled = true
    getKeyBtn.Font = Enum.Font.GothamBold
    
    local getKeyCorner = Instance.new("UICorner")
    getKeyCorner.CornerRadius = UDim.new(0, 5)
    getKeyCorner.Parent = getKeyBtn
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Parent = keyFrame
    statusLabel.BackgroundTransparency = 1
    statusLabel.Position = UDim2.new(0, 0, 0, 220)
    statusLabel.Size = UDim2.new(1, 0, 0, 60)
    statusLabel.Text = "Enter the key to access GILONG Hub"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    
    submitBtn.MouseButton1Click:Connect(function()
        if keyBox.Text == correctKey then
            statusLabel.Text = "Key Correct! Loading Hub..."
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            wait(1)
            keyGui:Destroy()
            createGUI()
        else
            statusLabel.Text = "Wrong Key! Try Again."
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)
    
    getKeyBtn.MouseButton1Click:Connect(function()
        if copyToClipboard(keyLink) then
            statusLabel.Text = "Key link copied to clipboard!"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            statusLabel.Text = "Link: " .. keyLink
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        end
    end)
end

-- Start with key system
createKeyGUI()
