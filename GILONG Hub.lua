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

-- Create GUI Function with Orion-like design
local function createGUI()
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GILONGHub"
    screenGui.Parent = playerGui
    
    -- Main Frame (Orion-like dark theme)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
    mainFrame.Size = UDim2.new(0, 550, 0, 400)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Parent = mainFrame
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = titleBar
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Size = UDim2.new(0.8, 0, 1, 0)
    title.Text = "GILONG Hub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamSemibold
    
    -- Close Button (Orion style)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Parent = titleBar
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    
    closeBtn.MouseEnter:Connect(function()
        closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Tab Container (Left side like Orion)
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Parent = mainFrame
    tabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabContainer.BorderSizePixel = 0
    tabContainer.Position = UDim2.new(0, 0, 0, 35)
    tabContainer.Size = UDim2.new(0, 150, 1, -35)
    
    -- Content Container (Right side)
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Parent = mainFrame
    contentContainer.BackgroundTransparency = 1
    contentContainer.Position = UDim2.new(0, 150, 0, 35)
    contentContainer.Size = UDim2.new(1, -150, 1, -35)
    
    -- Tab System Variables
    local currentTab = "Combat"
    local tabFrames = {}
    
    -- Create Tab Button Function
    local function createTabButton(name, icon, yPos)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = name .. "Tab"
        tabBtn.Parent = tabContainer
        tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tabBtn.BorderSizePixel = 0
        tabBtn.Position = UDim2.new(0, 5, 0, yPos)
        tabBtn.Size = UDim2.new(1, -10, 0, 35)
        tabBtn.Text = icon .. " " .. name
        tabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        tabBtn.TextSize = 12
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.Font = Enum.Font.Gotham
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabBtn
        
        -- Tab Content Frame
        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Name = name .. "Frame"
        tabFrame.Parent = contentContainer
        tabFrame.BackgroundTransparency = 1
        tabFrame.Position = UDim2.new(0, 10, 0, 10)
        tabFrame.Size = UDim2.new(1, -20, 1, -20)
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
        tabFrame.ScrollBarThickness = 4
        tabFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        tabFrame.Visible = (name == "Combat")
        
        tabFrames[name] = tabFrame
        
        -- Tab Button Click
        tabBtn.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, frame in pairs(tabFrames) do
                frame.Visible = false
            end
            
            -- Reset all tab colors
            for _, child in pairs(tabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    child.TextColor3 = Color3.fromRGB(180, 180, 180)
                end
            end
            
            -- Show selected tab
            tabFrame.Visible = true
            tabBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            currentTab = name
        end)
        
        -- Set initial active tab
        if name == "Combat" then
            tabBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        return tabFrame
    end
    
    -- Create Tabs
    local combatFrame = createTabButton("Combat", "⚔️", 10)
    local farmingFrame = createTabButton("Farming", "🌲", 55)
    local itemsFrame = createTabButton("Items", "📦", 100)
    local playerFrame = createTabButton("Player", "👤", 145)
    local miscFrame = createTabButton("Misc", "⚙️", 190)
    
    -- Orion-style UI Element Functions
    local function createButton(parent, text, callback, yPos)
        local button = Instance.new("TextButton")
        button.Parent = parent
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.BorderSizePixel = 0
        button.Position = UDim2.new(0, 0, 0, yPos or 0)
        button.Size = UDim2.new(1, -10, 0, 30)
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 12
        button.Font = Enum.Font.Gotham
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = button
        
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end)
        
        button.MouseButton1Click:Connect(callback)
        return button
    end
    
    local function createToggle(parent, text, callback, yPos)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        frame.BorderSizePixel = 0
        frame.Position = UDim2.new(0, 0, 0, yPos or 0)
        frame.Size = UDim2.new(1, -10, 0, 35)
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 4)
        frameCorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 12, 0, 0)
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        
        -- Orion-style toggle switch
        local toggleBg = Instance.new("Frame")
        toggleBg.Parent = frame
        toggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        toggleBg.BorderSizePixel = 0
        toggleBg.Position = UDim2.new(1, -50, 0.5, -8)
        toggleBg.Size = UDim2.new(0, 40, 0, 16)
        
        local toggleBgCorner = Instance.new("UICorner")
        toggleBgCorner.CornerRadius = UDim.new(0, 8)
        toggleBgCorner.Parent = toggleBg
        
        local toggleBtn = Instance.new("Frame")
        toggleBtn.Parent = toggleBg
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        toggleBtn.BorderSizePixel = 0
        toggleBtn.Position = UDim2.new(0, 2, 0, 2)
        toggleBtn.Size = UDim2.new(0, 12, 0, 12)
        
        local toggleBtnCorner = Instance.new("UICorner")
        toggleBtnCorner.CornerRadius = UDim.new(0, 6)
        toggleBtnCorner.Parent = toggleBtn
        
        local clickDetector = Instance.new("TextButton")
        clickDetector.Parent = frame
        clickDetector.BackgroundTransparency = 1
        clickDetector.Size = UDim2.new(1, 0, 1, 0)
        clickDetector.Text = ""
        
        local isToggled = false
        
        clickDetector.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            if isToggled then
                toggleBg.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
                toggleBtn.Position = UDim2.new(1, -14, 0, 2)
                toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            else
                toggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                toggleBtn.Position = UDim2.new(0, 2, 0, 2)
                toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            end
            callback(isToggled)
        end)
        
        return frame
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
