--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║         ULTIMATE ADMIN PANEL - CLIENT SIDE ONLY               ║
    ║              Created by JasonProDev                           ║
    ║                    2000+ Lines Edition                        ║
    ╚═══════════════════════════════════════════════════════════════╝
    
    FEATURES:
    - Fly Mode avec contrôles avancés
    - Noclip système
    - ESP Players avec distance et health
    - Teleportation système
    - Speed & Jump modifications
    - FOV & Camera controls
    - Lighting controls
    - Workspace modifications
    - Character animations
    - Particle effects
    - Time control
    - Weather effects
    - Et bien plus encore!
    
    CONTROLS:
    - INSERT ou RIGHT CTRL pour ouvrir/fermer
    - Draggable interface
--]]

-- ════════════════════════════════════════════════════════════════
-- SERVICES & VARIABLES
-- ════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- ════════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ════════════════════════════════════════════════════════════════

local CONFIG = {
    -- UI Colors
    COLORS = {
        PRIMARY = Color3.fromRGB(20, 20, 30),
        SECONDARY = Color3.fromRGB(30, 30, 45),
        ACCENT = Color3.fromRGB(100, 200, 255),
        SUCCESS = Color3.fromRGB(50, 150, 80),
        DANGER = Color3.fromRGB(220, 50, 60),
        WARNING = Color3.fromRGB(255, 200, 50),
        BUTTON_DEFAULT = Color3.fromRGB(40, 40, 60),
        BUTTON_HOVER = Color3.fromRGB(55, 55, 80),
        TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
        TEXT_SECONDARY = Color3.fromRGB(150, 150, 170),
    },
    
    -- Default Values
    DEFAULT_SPEED = 16,
    DEFAULT_JUMP = 50,
    DEFAULT_FOV = 70,
    DEFAULT_GRAVITY = 196.2,
    
    -- Fly Settings
    FLY_SPEED = 50,
    FLY_SPEED_FAST = 150,
    FLY_SPEED_SLOW = 25,
    
    -- Animation
    TWEEN_TIME = 0.3,
    OPEN_TWEEN_TIME = 0.4,
}

-- ════════════════════════════════════════════════════════════════
-- STATE MANAGEMENT
-- ════════════════════════════════════════════════════════════════

local STATE = {
    -- Toggle States
    flying = false,
    noclipping = false,
    invisible = false,
    espEnabled = false,
    fullbright = false,
    infiniteJump = false,
    noGravity = false,
    clickTP = false,
    xRay = false,
    speedHack = false,
    autoSprint = false,
    antiAFK = false,
    
    -- Numeric Values
    currentSpeed = CONFIG.DEFAULT_SPEED,
    currentJump = CONFIG.DEFAULT_JUMP,
    currentFOV = CONFIG.DEFAULT_FOV,
    flySpeed = CONFIG.FLY_SPEED,
    
    -- Objects
    bodyVelocity = nil,
    bodyGyro = nil,
    noclipConnection = nil,
    espConnections = {},
    particles = {},
    trails = {},
    
    -- UI State
    isOpen = false,
    currentTab = "main",
    
    -- Statistics
    startTime = tick(),
    totalCommands = 0,
}

-- ════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════════════

local Utils = {}

function Utils.getCharacter()
    return player.Character
end

function Utils.getHumanoid()
    local character = Utils.getCharacter()
    if character then
        return character:FindFirstChild("Humanoid")
    end
    return nil
end

function Utils.getRootPart()
    local character = Utils.getCharacter()
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

function Utils.notify(message, duration, color)
    duration = duration or 3
    color = color or CONFIG.COLORS.ACCENT
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 60)
    notif.Position = UDim2.new(1, -320, 1, -80)
    notif.BackgroundColor3 = CONFIG.COLORS.SECONDARY
    notif.BorderSizePixel = 0
    notif.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = notif
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    accent.Parent = notif
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 10)
    accentCorner.Parent = accent
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, -10)
    text.Position = UDim2.new(0, 15, 0, 5)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = CONFIG.COLORS.TEXT_PRIMARY
    text.TextSize = 14
    text.Font = Enum.Font.Gotham
    text.TextWrapped = true
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = notif
    
    notif.Position = UDim2.new(1, 20, 1, -80)
    TweenService:Create(notif, TweenInfo.new(0.3), {
        Position = UDim2.new(1, -320, 1, -80)
    }):Play()
    
    task.wait(duration)
    
    TweenService:Create(notif, TweenInfo.new(0.3), {
        Position = UDim2.new(1, 20, 1, -80)
    }):Play()
    
    task.wait(0.3)
    notif:Destroy()
end

function Utils.formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function Utils.tween(object, properties, time, style, direction)
    time = time or CONFIG.TWEEN_TIME
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(object, TweenInfo.new(time, style, direction), properties)
    tween:Play()
    return tween
end

-- ════════════════════════════════════════════════════════════════
-- GUI CREATION
-- ════════════════════════════════════════════════════════════════

-- Créer le ScreenGui principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltimateAdminPanel"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Frame principale (DRAGGABLE)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 700, 0, 550)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -275)
mainFrame.BackgroundColor3 = CONFIG.COLORS.PRIMARY
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

-- Ombre portée
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0, -20, 0, -20)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.ZIndex = -1
shadow.Parent = mainFrame

-- ════════════════════════════════════════════════════════════════
-- HEADER
-- ════════════════════════════════════════════════════════════════

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = CONFIG.COLORS.SECONDARY
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 15)
headerCorner.Parent = header

-- Barre d'accent en haut
local accentBar = Instance.new("Frame")
accentBar.Name = "AccentBar"
accentBar.Size = UDim2.new(1, 0, 0, 3)
accentBar.BackgroundColor3 = CONFIG.COLORS.ACCENT
accentBar.BorderSizePixel = 0
accentBar.Parent = header

-- Titre principal
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(0.5, -20, 0, 25)
title.Position = UDim2.new(0, 20, 0, 10)
title.BackgroundTransparency = 1
title.Text = "⚡ ULTIMATE ADMIN PANEL"
title.TextColor3 = CONFIG.COLORS.ACCENT
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Sous-titre
local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.new(0.5, -20, 0, 18)
subtitle.Position = UDim2.new(0, 20, 0, 35)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Client-Side • Draggable • 1500+ Lines"
subtitle.TextColor3 = CONFIG.COLORS.TEXT_SECONDARY
subtitle.TextSize = 11
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

-- Statistiques en temps réel
local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "StatsLabel"
statsLabel.Size = UDim2.new(0, 200, 0, 45)
statsLabel.Position = UDim2.new(1, -260, 0, 7)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "Uptime: 00:00:00\nCommands: 0"
statsLabel.TextColor3 = CONFIG.COLORS.TEXT_SECONDARY
statsLabel.TextSize = 11
statsLabel.Font = Enum.Font.GothamMedium
statsLabel.TextXAlignment = Enum.TextXAlignment.Right
statsLabel.Parent = header

-- Bouton de fermeture
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 50, 0, 50)
closeButton.Position = UDim2.new(1, -55, 0, 5)
closeButton.BackgroundColor3 = CONFIG.COLORS.DANGER
closeButton.Text = "✕"
closeButton.TextColor3 = CONFIG.COLORS.TEXT_PRIMARY
closeButton.TextSize = 22
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.AutoButtonColor = false
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeButton

-- ════════════════════════════════════════════════════════════════
-- TAB SYSTEM
-- ════════════════════════════════════════════════════════════════

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, -30, 0, 45)
tabBar.Position = UDim2.new(0, 15, 0, 70)
tabBar.BackgroundColor3 = CONFIG.COLORS.SECONDARY
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame

local tabBarCorner = Instance.new("UICorner")
tabBarCorner.CornerRadius = UDim.new(0, 10)
tabBarCorner.Parent = tabBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingLeft = UDim.new(0, 5)
tabPadding.PaddingRight = UDim.new(0, 5)
tabPadding.PaddingTop = UDim.new(0, 5)
tabPadding.PaddingBottom = UDim.new(0, 5)
tabPadding.Parent = tabBar

-- Container pour les contenus des tabs
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -30, 1, -135)
contentFrame.Position = UDim2.new(0, 15, 0, 125)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

-- ════════════════════════════════════════════════════════════════
-- TAB CONTENT FRAMES
-- ════════════════════════════════════════════════════════════════

local tabs = {}

-- Fonction pour créer un tab
local function createTab(name, icon, order)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(0, 120, 1, 0)
    tabButton.BackgroundColor3 = CONFIG.COLORS.BUTTON_DEFAULT
    tabButton.Text = ""
    tabButton.BorderSizePixel = 0
    tabButton.AutoButtonColor = false
    tabButton.LayoutOrder = order
    tabButton.Parent = tabBar
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabButton
    
    local tabLabel = Instance.new("TextLabel")
    tabLabel.Size = UDim2.new(1, -10, 1, 0)
    tabLabel.Position = UDim2.new(0, 5, 0, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = icon .. " " .. name
    tabLabel.TextColor3 = CONFIG.COLORS.TEXT_PRIMARY
    tabLabel.TextSize = 13
    tabLabel.Font = Enum.Font.GothamBold
    tabLabel.Parent = tabButton
    
    -- Content frame pour ce tab
    local tabContent = Instance.new("Frame")
    tabContent.Name = name .. "Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.Parent = contentFrame
    
    -- Créer deux colonnes pour ce tab
    local leftColumn = Instance.new("ScrollingFrame")
    leftColumn.Name = "LeftColumn"
    leftColumn.Size = UDim2.new(0.48, 0, 1, 0)
    leftColumn.Position = UDim2.new(0, 0, 0, 0)
    leftColumn.BackgroundTransparency = 1
    leftColumn.BorderSizePixel = 0
    leftColumn.ScrollBarThickness = 4
    leftColumn.ScrollBarImageColor3 = CONFIG.COLORS.ACCENT
    leftColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
    leftColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
    leftColumn.Parent = tabContent
    
    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Padding = UDim.new(0, 8)
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Parent = leftColumn
    
    local rightColumn = Instance.new("ScrollingFrame")
    rightColumn.Name = "RightColumn"
    rightColumn.Size = UDim2.new(0.48, 0, 1, 0)
    rightColumn.Position = UDim2.new(0.52, 0, 0, 0)
    rightColumn.BackgroundTransparency = 1
    rightColumn.BorderSizePixel = 0
    rightColumn.ScrollBarThickness = 4
    rightColumn.ScrollBarImageColor3 = CONFIG.COLORS.ACCENT
    rightColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
    rightColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
    rightColumn.Parent = tabContent
    
    local rightLayout = Instance.new("UIListLayout")
    rightLayout.Padding = UDim.new(0, 8)
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Parent = rightColumn
    
    tabs[name] = {
        button = tabButton,
        content = tabContent,
        leftColumn = leftColumn,
        rightColumn = rightColumn,
    }
    
    -- Event pour changer de tab
    tabButton.MouseButton1Click:Connect(function()
        for tabName, tabData in pairs(tabs) do
            tabData.content.Visible = false
            Utils.tween(tabData.button, {BackgroundColor3 = CONFIG.COLORS.BUTTON_DEFAULT})
        end
        
        tabContent.Visible = true
        Utils.tween(tabButton, {BackgroundColor3 = CONFIG.COLORS.ACCENT})
        STATE.currentTab = name
    end)
    
    tabButton.MouseEnter:Connect(function()
        if STATE.currentTab ~= name then
            Utils.tween(tabButton, {BackgroundColor3 = CONFIG.COLORS.BUTTON_HOVER})
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if STATE.currentTab ~= name then
            Utils.tween(tabButton, {BackgroundColor3 = CONFIG.COLORS.BUTTON_DEFAULT})
        end
    end)
    
    return tabs[name]
end

-- Créer les tabs
createTab("Main", "🏠", 1)
createTab("Movement", "🏃", 2)
createTab("Visual", "👁️", 3)
createTab("World", "🌍", 4)
createTab("Fun", "🎮", 5)

-- Activer le premier tab par défaut
tabs["Main"].content.Visible = true
Utils.tween(tabs["Main"].button, {BackgroundColor3 = CONFIG.COLORS.ACCENT})
STATE.currentTab = "Main"

-- ════════════════════════════════════════════════════════════════
-- BUTTON CREATION FUNCTIONS
-- ════════════════════════════════════════════════════════════════

local function createToggleButton(parent, text, icon, state, callback)
    STATE.totalCommands = STATE.totalCommands + 1
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 42)
    button.BackgroundColor3 = state and CONFIG.COLORS.SUCCESS or CONFIG.COLORS.BUTTON_DEFAULT
    button.Text = ""
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Parent = parent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    local buttonLabel = Instance.new("TextLabel")
    buttonLabel.Size = UDim2.new(1, -45, 1, 0)
    buttonLabel.Position = UDim2.new(0, 10, 0, 0)
    buttonLabel.BackgroundTransparency = 1
    buttonLabel.Text = icon .. " " .. text
    buttonLabel.TextColor3 = CONFIG.COLORS.TEXT_PRIMARY
    buttonLabel.TextSize = 14
    buttonLabel.Font = Enum.Font.GothamSemibold
    buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
    buttonLabel.Parent = button
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 28, 0, 28)
    indicator.Position = UDim2.new(1, -35, 0.5, -14)
    indicator.BackgroundColor3 = state and Color3.fromRGB(100, 255, 150) or CONFIG.COLORS.TEXT_SECONDARY
    indicator.BorderSizePixel = 0
    indicator.Parent = button
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    local checkmark = Instance.new("TextLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = state and "✓" or ""
    checkmark.TextColor3 = CONFIG.COLORS.PRIMARY
    checkmark.TextSize = 18
    checkmark.Font = Enum.Font.GothamBold
    checkmark.Parent = indicator
    
    button.MouseEnter:Connect(function()
        Utils.tween(button, {
            BackgroundColor3 = state and Color3.fromRGB(60, 170, 100) or CONFIG.COLORS.BUTTON_HOVER
        })
    end)
    
    button.MouseLeave:Connect(function()
        Utils.tween(button, {
            BackgroundColor3 = state and CONFIG.COLORS.SUCCESS or CONFIG.COLORS.BUTTON_DEFAULT
        })
    end)
    
    button.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        
        Utils.tween(button, {
            BackgroundColor3 = state and CONFIG.COLORS.SUCCESS or CONFIG.COLORS.BUTTON_DEFAULT
        })
        
        Utils.tween(indicator, {
            BackgroundColor3 = state and Color3.fromRGB(100, 255, 150) or CONFIG.COLORS.TEXT_SECONDARY
        })
        
        checkmark.Text = state and "✓" or ""
    end)
    
    return button
end

local function createButton(parent, text, icon, callback)
    STATE.totalCommands = STATE.totalCommands + 1
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 42)
    button.BackgroundColor3 = CONFIG.COLORS.BUTTON_DEFAULT
    button.Text = ""
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Parent = parent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    local buttonLabel = Instance.new("TextLabel")
    buttonLabel.Size = UDim2.new(1, -20, 1, 0)
    buttonLabel.Position = UDim2.new(0, 10, 0, 0)
    buttonLabel.BackgroundTransparency = 1
    buttonLabel.Text = icon .. " " .. text
    buttonLabel.TextColor3 = CONFIG.COLORS.TEXT_PRIMARY
    buttonLabel.TextSize = 14
    buttonLabel.Font = Enum.Font.GothamSemibold
    buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
    buttonLabel.Parent = button
    
    button.MouseEnter:Connect(function()
        Utils.tween(button, {BackgroundColor3 = CONFIG.COLORS.BUTTON_HOVER})
    end)
    
    button.MouseLeave:Connect(function()
        Utils.tween(button, {BackgroundColor3 = CONFIG.COLORS.BUTTON_DEFAULT})
    end)
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

local function createSlider(parent, text, icon, minVal, maxVal, defaultVal, callback)
    STATE.totalCommands = STATE.totalCommands + 1
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 65)
    container.BackgroundColor3 = CONFIG.COLORS.BUTTON_DEFAULT
    container.BorderSizePixel = 0
    container.Parent = parent
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 8)
    containerCorner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = icon .. " " .. text
    label.TextColor3 = CONFIG.COLORS.TEXT_PRIMARY
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 60, 0, 25)
    valueLabel.Position = UDim2.new(1, -70, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultVal)
    valueLabel.TextColor3 = CONFIG.COLORS.ACCENT
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    local sliderBack = Instance.new("Frame")
    sliderBack.Size = UDim2.new(1, -20, 0, 6)
    sliderBack.Position = UDim2.new(0, 10, 0, 40)
    sliderBack.BackgroundColor3 = CONFIG.COLORS.PRIMARY
    sliderBack.BorderSizePixel = 0
    sliderBack.Parent = container
    
    local sliderBackCorner = Instance.new("UICorner")
    sliderBackCorner.CornerRadius = UDim.new(1, 0)
    sliderBackCorner.Parent = sliderBack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    sliderFill.BackgroundColor3 = CONFIG.COLORS.ACCENT
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBack
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(1, 0)
    sliderFillCorner.Parent = sliderFill
    
    local dragging = false
    
    local function updateSlider(input)
        local pos = (input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X
        pos = math.clamp(pos, 0, 1)
        
        local value = math.floor(minVal + (maxVal - minVal) * pos)
        valueLabel.Text = tostring(value)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        
        callback(value)
    end
    
    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    sliderBack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return container
end

local function createInfoBox(parent, text, icon, color)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, 50)
    box.BackgroundColor3 = color or CONFIG.COLORS.ACCENT
    box.BorderSizePixel = 0
    box.Parent = parent
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 8)
    boxCorner.Parent = box
    
    local boxLabel = Instance.new("TextLabel")
    boxLabel.Size = UDim2.new(1, -20, 1, -10)
    boxLabel.Position = UDim2.new(0, 10, 0, 5)
    boxLabel.BackgroundTransparency = 1
    boxLabel.Text = icon .. " " .. text
    boxLabel.TextColor3 = CONFIG.COLORS.TEXT_PRIMARY
    boxLabel.TextSize = 13
    boxLabel.Font = Enum.Font.GothamMedium
    boxLabel.TextWrapped = true
    boxLabel.TextXAlignment = Enum.TextXAlignment.Left
    boxLabel.Parent = box
    
    return box
end

-- ════════════════════════════════════════════════════════════════
-- CORE FUNCTIONS - FLY SYSTEM
-- ════════════════════════════════════════════════════════════════

local function toggleFly(state)
    STATE.flying = state
    local character = Utils.getCharacter()
    if not character then return end
    
    local humanoid = Utils.getHumanoid()
    local rootPart = Utils.getRootPart()
    
    if not rootPart then return end
    
    if STATE.flying then
        -- Créer les objets de vol
        STATE.bodyVelocity = Instance.new("BodyVelocity")
        STATE.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        STATE.bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        STATE.bodyVelocity.Parent = rootPart
        
        STATE.bodyGyro = Instance.new("BodyGyro")
        STATE.bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        STATE.bodyGyro.P = 9e4
        STATE.bodyGyro.Parent = rootPart
        
        -- Boucle de vol
        RunService.RenderStepped:Connect(function()
            if not STATE.flying then return end
            
            local moveDirection = Vector3.new()
            local speed = STATE.flySpeed
            
            -- Contrôles de direction
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            -- Vitesse turbo avec LeftControl
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                speed = CONFIG.FLY_SPEED_FAST
            end
            
            if STATE.bodyVelocity and STATE.bodyVelocity.Parent then
                STATE.bodyVelocity.Velocity = moveDirection * speed
            end
            if STATE.bodyGyro and STATE.bodyGyro.Parent then
                STATE.bodyGyro.CFrame = camera.CFrame
            end
        end)
        
        Utils.notify("✈️ Fly Mode activé! CTRL = Turbo", 3, CONFIG.COLORS.SUCCESS)
    else
        if STATE.bodyVelocity then STATE.bodyVelocity:Destroy() end
        if STATE.bodyGyro then STATE.bodyGyro:Destroy() end
        Utils.notify("Fly Mode désactivé", 2, CONFIG.COLORS.WARNING)
    end
end

-- ════════════════════════════════════════════════════════════════
-- CORE FUNCTIONS - NOCLIP SYSTEM
-- ════════════════════════════════════════════════════════════════

local function toggleNoclip(state)
    STATE.noclipping = state
    local character = Utils.getCharacter()
    if not character then return end
    
    if STATE.noclipping then
        STATE.noclipConnection = RunService.Stepped:Connect(function()
            if not STATE.noclipping then return end
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        Utils.notify("👻 Noclip activé!", 2, CONFIG.COLORS.SUCCESS)
    else
        if STATE.noclipConnection then
            STATE.noclipConnection:Disconnect()
        end
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
        Utils.notify("Noclip désactivé", 2, CONFIG.COLORS.WARNING)
    end
end

-- ════════════════════════════════════════════════════════════════
-- CORE FUNCTIONS - INVISIBILITY
-- ════════════════════════════════════════════════════════════════

local function toggleInvisible(state)
    STATE.invisible = state
    local character = Utils.getCharacter()
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if part.Name == "HumanoidRootPart" then
                part.Transparency = 1
            else
                part.Transparency = state and 1 or 0
            end
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = state and 1 or 0
        end
    end
    
    for _, accessory in pairs(character:GetChildren()) do
        if accessory:IsA("Accessory") and accessory:FindFirstChild("Handle") then
            accessory.Handle.Transparency = state and 1 or 0
        end
    end
    
    if state then
        Utils.notify("🕶️ Vous êtes invisible!", 2, CONFIG.COLORS.SUCCESS)
    else
        Utils.notify("Visibilité restaurée", 2, CONFIG.COLORS.WARNING)
    end
end

-- ════════════════════════════════════════════════════════════════
-- CORE FUNCTIONS - ESP SYSTEM
-- ════════════════════════════════════════════════════════════════

local function createESP(targetPlayer)
    if targetPlayer == player then return end
    
    local function addESP(character)
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not rootPart or not humanoid then return end
        
        -- Billboard GUI
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 120, 0, 80)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Parent = rootPart
        
        -- Nom du joueur
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = targetPlayer.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Parent = billboard
        
        -- Distance
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Size = UDim2.new(1, 0, 0.3, 0)
        distanceLabel.Position = UDim2.new(0, 0, 0.35, 0)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        distanceLabel.TextStrokeTransparency = 0.3
        distanceLabel.Font = Enum.Font.Gotham
        distanceLabel.TextSize = 12
        distanceLabel.Parent = billboard
        
        -- Health bar
        local healthFrame = Instance.new("Frame")
        healthFrame.Size = UDim2.new(0.8, 0, 0.15, 0)
        healthFrame.Position = UDim2.new(0.1, 0, 0.7, 0)
        healthFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        healthFrame.BorderSizePixel = 0
        healthFrame.Parent = billboard
        
        local healthCorner = Instance.new("UICorner")
        healthCorner.CornerRadius = UDim.new(0, 4)
        healthCorner.Parent = healthFrame
        
        local healthBar = Instance.new("Frame")
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthBar.BorderSizePixel = 0
        healthBar.Parent = healthFrame
        
        local healthBarCorner = Instance.new("UICorner")
        healthBarCorner.CornerRadius = UDim.new(0, 4)
        healthBarCorner.Parent = healthBar
        
        -- Highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.7
        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
        highlight.OutlineTransparency = 0
        highlight.Parent = character
        
        -- Update loop
        local updateConnection
        updateConnection = RunService.RenderStepped:Connect(function()
            if not STATE.espEnabled or not rootPart or not rootPart.Parent or not humanoid then
                if billboard then billboard:Destroy() end
                if highlight then highlight:Destroy() end
                if updateConnection then updateConnection:Disconnect() end
                return
            end
            
            local myChar = Utils.getCharacter()
            local myRoot = Utils.getRootPart()
            if myChar and myRoot then
                local distance = (myRoot.Position - rootPart.Position).Magnitude
                distanceLabel.Text = string.format("%.1f studs", distance)
                
                -- Update health bar
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
                
                if healthPercent > 0.6 then
                    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                elseif healthPercent > 0.3 then
                    healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                else
                    healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
        end)
        
        table.insert(STATE.espConnections, updateConnection)
    end
    
    if targetPlayer.Character then
        addESP(targetPlayer.Character)
    end
    
    targetPlayer.CharacterAdded:Connect(function(character)
        if STATE.espEnabled then
            task.wait(0.5)
            addESP(character)
        end
    end)
end

local function toggleESP(state)
    STATE.espEnabled = state
    
    if state then
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            createESP(targetPlayer)
        end
        
        Players.PlayerAdded:Connect(function(targetPlayer)
            if STATE.espEnabled then
                createESP(targetPlayer)
            end
        end)
        
        Utils.notify("👁️ ESP activé pour tous les joueurs!", 3, CONFIG.COLORS.SUCCESS)
    else
        for _, connection in pairs(STATE.espConnections) do
            if connection then
                connection:Disconnect()
            end
        end
        STATE.espConnections = {}
        
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer.Character then
                local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local billboard = rootPart:FindFirstChild("ESP")
                    if billboard then billboard:Destroy() end
                end
                local highlight = targetPlayer.Character:FindFirstChild("ESPHighlight")
                if highlight then highlight:Destroy() end
            end
        end
        
        Utils.notify("ESP désactivé", 2, CONFIG.COLORS.WARNING)
    end
end

-- ════════════════════════════════════════════════════════════════
-- CORE FUNCTIONS - FULLBRIGHT
-- ════════════════════════════════════════════════════════════════

local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

local function toggleFullbright(state)
    STATE.fullbright = state
    
    if state then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        
        Utils.notify("💡 Fullbright activé!", 2, CONFIG.COLORS.SUCCESS)
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        
        Utils.notify("Lighting normal restauré", 2, CONFIG.COLORS.WARNING)
    end
end

-- ════════════════════════════════════════════════════════════════
-- CORE FUNCTIONS - INFINITE JUMP
-- ════════════════════════════════════════════════════════════════

local function toggleInfiniteJump(state)
    STATE.infiniteJump = state
    
    if state then
        UserInputService.JumpRequest:Connect(function()
            if STATE.infiniteJump then
                local humanoid = Utils.getHumanoid()
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        Utils.notify("🦘 Infinite Jump activé!", 2, CONFIG.COLORS.SUCCESS)
    else
        Utils.notify("Infinite Jump désactivé", 2, CONFIG.COLORS.WARNING)
    end
end

-- ════════════════════════════════════════════════════════════════
-- CORE FUNCTIONS - CLICK TELEPORT
-- ════════════════════════════════════════════════════════════════

local function toggleClickTP(state)
    STATE.clickTP = state
    
    if state then
        mouse.Button1Down:Connect(function()
            if STATE.clickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                local rootPart = Utils.getRootPart()
                if rootPart and mouse.Target then
                    rootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                    Utils.notify("📍 Téléporté!", 1.5, CONFIG.COLORS.SUCCESS)
                end
            end
        end)
        Utils.notify("🎯 Click TP activé! CTRL + Click", 3, CONFIG.COLORS.SUCCESS)
    else
        Utils.notify("Click TP désactivé", 2, CONFIG.COLORS.WARNING)
    end
end

-- ════════════════════════════════════════════════════════════════
-- CORE FUNCTIONS - X-RAY VISION
-- ════════════════════════════════════════════════════════════════

local originalTransparencies = {}

local function toggleXRay(state)
    STATE.xRay = state
    
    if state then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") then
                originalTransparencies[obj] = obj.Transparency
                obj.Transparency = 0.7
            end
        end
        Utils.notify("🔍 X-Ray activé!", 2, CONFIG.COLORS.SUCCESS)
    else
        for obj, transparency in pairs(originalTransparencies) do
            if obj and obj.Parent then
                obj.Transparency = transparency
            end
        end
        originalTransparencies = {}
        Utils.notify("X-Ray désactivé", 2, CONFIG.COLORS.WARNING)
    end
end

-- ════════════════════════════════════════════════════════════════
-- CORE FUNCTIONS - ANTI AFK
-- ════════════════════════════════════════════════════════════════

local function toggleAntiAFK(state)
    STATE.antiAFK = state
    
    if state then
        local vu = game:GetService("VirtualUser")
        player.Idled:Connect(function()
            if STATE.antiAFK then
                vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end
        end)
        Utils.notify("⏰ Anti-AFK activé!", 2, CONFIG.COLORS.SUCCESS)
    else
        Utils.notify("Anti-AFK désactivé", 2, CONFIG.COLORS.WARNING)
    end
end

-- ════════════════════════════════════════════════════════════════
-- CORE FUNCTIONS - SPEED & MOVEMENT
-- ════════════════════════════════════════════════════════════════

local function setSpeed(speed)
    STATE.currentSpeed = speed
    local humanoid = Utils.getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = speed
        Utils.notify(string.format("⚡ Vitesse: %d", speed), 2, CONFIG.COLORS.ACCENT)
    end
end

local function setJumpPower(power)
    STATE.currentJump = power
    local humanoid = Utils.getHumanoid()
    if humanoid then
        humanoid.JumpPower = power
        Utils.notify(string.format("🦘 Jump Power: %d", power), 2, CONFIG.COLORS.ACCENT)
    end
end

local function setFOV(fov)
    STATE.currentFOV = fov
    camera.FieldOfView = fov
    Utils.notify(string.format("📷 FOV: %d", fov), 2, CONFIG.COLORS.ACCENT)
end

local function setGravity(gravity)
    workspace.Gravity = gravity
    Utils.notify(string.format("🌍 Gravité: %.1f", gravity), 2, CONFIG.COLORS.ACCENT)
end

-- ════════════════════════════════════════════════════════════════
-- CORE FUNCTIONS - PARTICLES & EFFECTS
-- ════════════════════════════════════════════════════════════════

local function addParticles(particleType)
    local rootPart = Utils.getRootPart()
    if not rootPart then return end
    
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "AdminParticle"
    
    if particleType == "fire" then
        emitter.Texture = "rbxasset://textures/particles/fire_main.dds"
        emitter.Color = ColorSequence.new(Color3.fromRGB(255, 100, 50))
        emitter.Size = NumberSequence.new(2)
        emitter.Rate = 50
    elseif particleType == "sparkles" then
        emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        emitter.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255))
        emitter.Size = NumberSequence.new(1)
        emitter.Rate = 100
    elseif particleType == "smoke" then
        emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
        emitter.Color = ColorSequence.new(Color3.fromRGB(100, 100, 100))
        emitter.Size = NumberSequence.new(3)
        emitter.Rate = 30
    end
    
    emitter.Lifetime = NumberRange.new(1, 2)
    emitter.Speed = NumberRange.new(5)
    emitter.Parent = rootPart
    
    table.insert(STATE.particles, emitter)
    Utils.notify("✨ Particules ajoutées: " .. particleType, 2, CONFIG.COLORS.SUCCESS)
end

local function removeAllParticles()
    for _, emitter in pairs(STATE.particles) do
        if emitter and emitter.Parent then
            emitter:Destroy()
        end
    end
    STATE.particles = {}
    Utils.notify("Particules supprimées", 2, CONFIG.COLORS.WARNING)
end

local function addTrail()
    local rootPart = Utils.getRootPart()
    if not rootPart then return end
    
    local attachment0 = Instance.new("Attachment", rootPart)
    local attachment1 = Instance.new("Attachment", rootPart)
    attachment1.Position = Vector3.new(0, -2, 0)
    
    local trail = Instance.new("Trail")
    trail.Attachment0 = attachment0
    trail.Attachment1 = attachment1
    trail.Color = ColorSequence.new(CONFIG.COLORS.ACCENT)
    trail.Lifetime = 2
    trail.MinLength = 0
    trail.Transparency = NumberSequence.new(0, 1)
    trail.WidthScale = NumberSequence.new(1)
    trail.Parent = rootPart
    
    table.insert(STATE.trails, trail)
    Utils.notify("🌟 Trail ajouté!", 2, CONFIG.COLORS.SUCCESS)
end

local function removeAllTrails()
    for _, trail in pairs(STATE.trails) do
        if trail and trail.Parent then
            trail:Destroy()
        end
    end
    STATE.trails = {}
    Utils.notify("Trails supprimés", 2, CONFIG.COLORS.WARNING)
end

-- ════════════════════════════════════════════════════════════════
-- CORE FUNCTIONS - TELEPORTATION
-- ════════════════════════════════════════════════════════════════

local function teleportToPlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character then
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = Utils.getRootPart()
        if targetRoot and myRoot then
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
            Utils.notify("📍 Téléporté à " .. targetPlayer.Name, 2, CONFIG.COLORS.SUCCESS)
        end
    end
end

local function teleportAllPlayers()
    local myRoot = Utils.getRootPart()
    if not myRoot then return end
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                targetRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, 3)
            end
        end
    end
    Utils.notify("🎯 Tous les joueurs téléportés!", 2, CONFIG.COLORS.SUCCESS)
end

-- ════════════════════════════════════════════════════════════════
-- CORE FUNCTIONS - WORLD MODIFICATIONS
-- ════════════════════════════════════════════════════════════════

local function setTimeOfDay(time)
    Lighting.ClockTime = time
    Utils.notify(string.format("🕐 Heure: %d:00", time), 2, CONFIG.COLORS.ACCENT)
end

local function createExplosion()
    local rootPart = Utils.getRootPart()
    if not rootPart then return end
    
    local explosion = Instance.new("Explosion")
    explosion.Position = rootPart.Position
    explosion.BlastRadius = 20
    explosion.BlastPressure = 500000
    explosion.Parent = workspace
    
    Utils.notify("💥 Explosion créée!", 2, CONFIG.COLORS.WARNING)
end

local function removeSeats()
    local character = Utils.getCharacter()
    if character then
        local humanoid = Utils.getHumanoid()
        if humanoid and humanoid.Sit then
            humanoid.Sit = false
            Utils.notify("💺 Sorti du siège!", 2, CONFIG.COLORS.SUCCESS)
        end
    end
end

-- ════════════════════════════════════════════════════════════════
-- CORE FUNCTIONS - CHARACTER MODIFICATIONS
-- ════════════════════════════════════════════════════════════════

local function godMode()
    local humanoid = Utils.getHumanoid()
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        Utils.notify("🛡️ God Mode activé! (Client)", 3, CONFIG.COLORS.SUCCESS)
    end
end

local function resetCharacter()
    local humanoid = Utils.getHumanoid()
    if humanoid then
        humanoid.Health = 0
        Utils.notify("💀 Respawn...", 2, CONFIG.COLORS.WARNING)
    end
end

local function removeAccessories()
    local character = Utils.getCharacter()
    if character then
        for _, child in pairs(character:GetChildren()) do
            if child:IsA("Accessory") then
                child:Destroy()
            end
        end
        Utils.notify("🎩 Accessoires supprimés!", 2, CONFIG.COLORS.SUCCESS)
    end
end

local function bigHead()
    local character = Utils.getCharacter()
    if character and character:FindFirstChild("Head") then
        character.Head.Size = Vector3.new(5, 5, 5)
        Utils.notify("🤯 Big Head activé!", 2, CONFIG.COLORS.SUCCESS)
    end
end

local function normalHead()
    local character = Utils.getCharacter()
    if character and character:FindFirstChild("Head") then
        character.Head.Size = Vector3.new(2, 1, 1)
        Utils.notify("Tête normale restaurée", 2, CONFIG.COLORS.SUCCESS)
    end
end

-- ════════════════════════════════════════════════════════════════
-- POPULATE TABS WITH BUTTONS
-- ════════════════════════════════════════════════════════════════

-- TAB: MAIN
createInfoBox(tabs["Main"].leftColumn, "Panneau d'administration client-side complet avec plus de 50 commandes!", "ℹ️", CONFIG.COLORS.ACCENT)

createToggleButton(tabs["Main"].leftColumn, "Fly Mode", "✈️", false, toggleFly)
createToggleButton(tabs["Main"].leftColumn, "Noclip", "👻", false, toggleNoclip)
createToggleButton(tabs["Main"].leftColumn, "Invisible", "🕶️", false, toggleInvisible)
createToggleButton(tabs["Main"].leftColumn, "ESP Players", "👁️", false, toggleESP)
createToggleButton(tabs["Main"].leftColumn, "Fullbright", "💡", false, toggleFullbright)
createToggleButton(tabs["Main"].leftColumn, "Infinite Jump", "🦘", false, toggleInfiniteJump)

createSlider(tabs["Main"].rightColumn, "Fly Speed", "✈️", 25, 200, CONFIG.FLY_SPEED, function(value)
    STATE.flySpeed = value
end)

createButton(tabs["Main"].rightColumn, "God Mode", "🛡️", godMode)
createButton(tabs["Main"].rightColumn, "Reset Character", "💀", resetCharacter)
createButton(tabs["Main"].rightColumn, "Remove Seat", "💺", removeSeats)
createButton(tabs["Main"].rightColumn, "Rejoin Game", "🔁", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end)

-- TAB: MOVEMENT
createInfoBox(tabs["Movement"].leftColumn, "Contrôlez votre vitesse, saut et autres paramètres de mouvement", "ℹ️", CONFIG.COLORS.ACCENT)

createSlider(tabs["Movement"].leftColumn, "Walk Speed", "⚡", 16, 200, CONFIG.DEFAULT_SPEED, setSpeed)
createSlider(tabs["Movement"].leftColumn, "Jump Power", "🦘", 50, 300, CONFIG.DEFAULT_JUMP, setJumpPower)
createSlider(tabs["Movement"].leftColumn, "Gravity", "🌍", 0, 400, CONFIG.DEFAULT_GRAVITY, setGravity)

createButton(tabs["Movement"].leftColumn, "Speed x2", "⚡", function() setSpeed(32) end)
createButton(tabs["Movement"].leftColumn, "Speed x5", "⚡⚡", function() setSpeed(80) end)
createButton(tabs["Movement"].leftColumn, "Super Jump", "🚀", function() setJumpPower(150) end)
createButton(tabs["Movement"].leftColumn, "Reset Movement", "🔄", function()
    setSpeed(CONFIG.DEFAULT_SPEED)
    setJumpPower(CONFIG.DEFAULT_JUMP)
    setGravity(CONFIG.DEFAULT_GRAVITY)
end)

createToggleButton(tabs["Movement"].rightColumn, "Click Teleport", "🎯", false, toggleClickTP)
createToggleButton(tabs["Movement"].rightColumn, "No Gravity", "🌙", false, function(state)
    if state then
        setGravity(0)
    else
        setGravity(CONFIG.DEFAULT_GRAVITY)
    end
end)

createButton(tabs["Movement"].rightColumn, "TP to Random Player", "🎲", function()
    local allPlayers = Players:GetPlayers()
    if #allPlayers > 1 then
        local randomPlayer = allPlayers[math.random(1, #allPlayers)]
        if randomPlayer ~= player then
            teleportToPlayer(randomPlayer)
        end
    end
end)

createButton(tabs["Movement"].rightColumn, "Bring All Players", "📍", teleportAllPlayers)
createButton(tabs["Movement"].rightColumn, "Remove Ragdoll", "🦴", function()
    local character = Utils.getCharacter()
    if character then
        for _, joint in pairs(character:GetDescendants()) do
            if joint:IsA("BallSocketConstraint") or joint:IsA("HingeConstraint") then
                joint:Destroy()
            end
        end
        Utils.notify("Ragdoll supprimé!", 2, CONFIG.COLORS.SUCCESS)
    end
end)

-- TAB: VISUAL
createInfoBox(tabs["Visual"].leftColumn, "Modifications visuelles et effets pour votre personnage", "ℹ️", CONFIG.COLORS.ACCENT)

createSlider(tabs["Visual"].leftColumn, "Camera FOV", "📷", 30, 120, CONFIG.DEFAULT_FOV, setFOV)

createButton(tabs["Visual"].leftColumn, "FOV 70 (Default)", "📷", function() setFOV(70) end)
createButton(tabs["Visual"].leftColumn, "FOV 90", "📷", function() setFOV(90) end)
createButton(tabs["Visual"].leftColumn, "FOV 120 (Wide)", "📷📷", function() setFOV(120) end)

createToggleButton(tabs["Visual"].leftColumn, "X-Ray Vision", "🔍", false, toggleXRay)
createToggleButton(tabs["Visual"].leftColumn, "Anti-AFK", "⏰", false, toggleAntiAFK)

createButton(tabs["Visual"].rightColumn, "Fire Particles", "🔥", function() addParticles("fire") end)
createButton(tabs["Visual"].rightColumn, "Sparkle Particles", "✨", function() addParticles("sparkles") end)
createButton(tabs["Visual"].rightColumn, "Smoke Particles", "💨", function() addParticles("smoke") end)
createButton(tabs["Visual"].rightColumn, "Add Trail", "🌟", addTrail)
createButton(tabs["Visual"].rightColumn, "Remove All Effects", "🗑️", function()
    removeAllParticles()
    removeAllTrails()
end)

createButton(tabs["Visual"].rightColumn, "Big Head", "🤯", bigHead)
createButton(tabs["Visual"].rightColumn, "Normal Head", "😊", normalHead)
createButton(tabs["Visual"].rightColumn, "Remove Accessories", "🎩", removeAccessories)

-- TAB: WORLD
createInfoBox(tabs["World"].leftColumn, "Modifiez l'environnement et le monde autour de vous", "ℹ️", CONFIG.COLORS.ACCENT)

createSlider(tabs["World"].leftColumn, "Time of Day", "🕐", 0, 24, 14, setTimeOfDay)

createButton(tabs["World"].leftColumn, "Morning (6:00)", "🌅", function() setTimeOfDay(6) end)
createButton(tabs["World"].leftColumn, "Noon (12:00)", "☀️", function() setTimeOfDay(12) end)
createButton(tabs["World"].leftColumn, "Evening (18:00)", "🌆", function() setTimeOfDay(18) end)
createButton(tabs["World"].leftColumn, "Night (0:00)", "🌙", function() setTimeOfDay(0) end)

createButton(tabs["World"].leftColumn, "Remove Fog", "🌫️", function()
    Lighting.FogEnd = 100000
    Utils.notify("Brouillard supprimé!", 2, CONFIG.COLORS.SUCCESS)
end)

createButton(tabs["World"].rightColumn, "Create Explosion", "💥", createExplosion)
createButton(tabs["World"].rightColumn, "Delete Barriers", "🚧", function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("barrier") or obj.Name:lower():find("wall") then
            if obj:IsA("BasePart") then
                obj.CanCollide = false
                obj.Transparency = 0.8
            end
        end
    end
    Utils.notify("Barrières désactivées!", 2, CONFIG.COLORS.SUCCESS)
end)

createButton(tabs["World"].rightColumn, "Remove Kill Bricks", "☠️", function()
    local removed = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("kill") then
            obj:Destroy()
            removed = removed + 1
        end
    end
    Utils.notify(string.format("🗑️ %d kill bricks supprimés!", removed), 2, CONFIG.COLORS.SUCCESS)
end)

createButton(tabs["World"].rightColumn, "Disable Spawn Points", "🚩", function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            obj.Enabled = false
        end
    end
    Utils.notify("Spawn points désactivés!", 2, CONFIG.COLORS.SUCCESS)
end)

createButton(tabs["World"].rightColumn, "Ambient Red", "🔴", function()
    Lighting.Ambient = Color3.fromRGB(255, 0, 0)
    Utils.notify("Ambiance rouge!", 2, CONFIG.COLORS.DANGER)
end)

createButton(tabs["World"].rightColumn, "Ambient Blue", "🔵", function()
    Lighting.Ambient = Color3.fromRGB(0, 100, 255)
    Utils.notify("Ambiance bleue!", 2, CONFIG.COLORS.ACCENT)
end)

-- TAB: FUN
createInfoBox(tabs["Fun"].leftColumn, "Commandes fun et expérimentales pour vous amuser!", "ℹ️", CONFIG.COLORS.WARNING)

createButton(tabs["Fun"].leftColumn, "Rainbow Character", "🌈", function()
    local character = Utils.getCharacter()
    if not character then return end
    
    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 127, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(139, 0, 255),
    }
    
    local colorIndex = 1
    RunService.RenderStepped:Connect(function()
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Color = colors[colorIndex]
            end
        end
        task.wait(0.1)
        colorIndex = colorIndex + 1
        if colorIndex > #colors then colorIndex = 1 end
    end)
    
    Utils.notify("🌈 Rainbow Mode activé!", 2, CONFIG.COLORS.SUCCESS)
end)

createButton(tabs["Fun"].leftColumn, "Spin Character", "🌀", function()
    local rootPart = Utils.getRootPart()
    if not rootPart then return end
    
    local spinning = true
    spawn(function()
        while spinning and rootPart and rootPart.Parent do
            rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(10), 0)
            task.wait()
        end
    end)
    
    task.wait(5)
    spinning = false
    Utils.notify("🌀 Spin terminé!", 2, CONFIG.COLORS.SUCCESS)
end)

createButton(tabs["Fun"].leftColumn, "Fling", "🚀", function()
    local rootPart = Utils.getRootPart()
    if not rootPart then return end
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
    bodyVelocity.Velocity = Vector3.new(math.random(-100, 100), 200, math.random(-100, 100))
    bodyVelocity.Parent = rootPart
    
    task.wait(0.5)
    bodyVelocity:Destroy()
    
    Utils.notify("🚀 Fling!", 2, CONFIG.COLORS.SUCCESS)
end)

createButton(tabs["Fun"].leftColumn, "Freeze Character", "🧊", function()
    local character = Utils.getCharacter()
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
    
    Utils.notify("🧊 Personnage gelé! Re-cliquez pour dégeler", 2, CONFIG.COLORS.ACCENT)
end)

createButton(tabs["Fun"].leftColumn, "Unfreeze Character", "♨️", function()
    local character = Utils.getCharacter()
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Anchored = false
        end
    end
    
    Utils.notify("♨️ Personnage dégelé!", 2, CONFIG.COLORS.SUCCESS)
end)

createButton(tabs["Fun"].rightColumn, "Giant Character", "🗿", function()
    local character = Utils.getCharacter()
    if not character then return end
    
    local humanoid = Utils.getHumanoid()
    if humanoid then
        for _, obj in pairs(character:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Size = obj.Size * 3
            elseif obj:IsA("Humanoid") then
                obj.HipHeight = obj.HipHeight * 3
            end
        end
        Utils.notify("🗿 Vous êtes ÉNORME!", 2, CONFIG.COLORS.SUCCESS)
    end
end)

createButton(tabs["Fun"].rightColumn, "Tiny Character", "🐜", function()
    local character = Utils.getCharacter()
    if not character then return end
    
    local humanoid = Utils.getHumanoid()
    if humanoid then
        for _, obj in pairs(character:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Size = obj.Size * 0.3
            elseif obj:IsA("Humanoid") then
                obj.HipHeight = obj.HipHeight * 0.3
            end
        end
        Utils.notify("🐜 Vous êtes minuscule!", 2, CONFIG.COLORS.SUCCESS)
    end
end)

createButton(tabs["Fun"].rightColumn, "Backwards Walk", "🔄", function()
    local humanoid = Utils.getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = -humanoid.WalkSpeed
        Utils.notify("🔄 Marche arrière activée!", 2, CONFIG.COLORS.SUCCESS)
    end
end)

createButton(tabs["Fun"].rightColumn, "Platform Below", "🎮", function()
    local rootPart = Utils.getRootPart()
    if not rootPart then return end
    
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(20, 1, 20)
    platform.Position = rootPart.Position - Vector3.new(0, 5, 0)
    platform.Anchored = true
    platform.BrickColor = BrickColor.new("Bright blue")
    platform.Material = Enum.Material.Neon
    platform.Parent = workspace
    
    local corner = Instance.new("CornerWedgePart")
    
    Utils.notify("🎮 Plateforme créée!", 2, CONFIG.COLORS.SUCCESS)
end)

createButton(tabs["Fun"].rightColumn, "ESP All Objects", "🔦", function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 255, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = obj
        end
    end
    Utils.notify("🔦 Highlight sur tous les objets!", 2, CONFIG.COLORS.SUCCESS)
end)

createButton(tabs["Fun"].rightColumn, "Remove All Highlights", "💡", function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Highlight") then
            obj:Destroy()
        end
    end
    Utils.notify("Highlights supprimés!", 2, CONFIG.COLORS.WARNING)
end)

createButton(tabs["Fun"].rightColumn, "Spam Jump", "🦘", function()
    local humanoid = Utils.getHumanoid()
    if not humanoid then return end
    
    for i = 1, 20 do
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.1)
    end
    Utils.notify("🦘 Jump spam terminé!", 2, CONFIG.COLORS.SUCCESS)
end)

-- ════════════════════════════════════════════════════════════════
-- UI ANIMATIONS & INTERACTIONS
-- ════════════════════════════════════════════════════════════════

-- Animation hover pour le bouton de fermeture
closeButton.MouseEnter:Connect(function()
    Utils.tween(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 70, 80)})
    Utils.tween(closeButton, {Rotation = 90}, 0.3)
end)

closeButton.MouseLeave:Connect(function()
    Utils.tween(closeButton, {BackgroundColor3 = CONFIG.COLORS.DANGER})
    Utils.tween(closeButton, {Rotation = 0}, 0.3)
end)

-- ════════════════════════════════════════════════════════════════
-- PANEL TOGGLE SYSTEM
-- ════════════════════════════════════════════════════════════════

local function togglePanel()
    STATE.isOpen = not STATE.isOpen
    
    if STATE.isOpen then
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        Utils.tween(mainFrame, {
            Size = UDim2.new(0, 700, 0, 550),
            Position = UDim2.new(0.5, -350, 0.5, -275)
        }, CONFIG.OPEN_TWEEN_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        Utils.notify("⚡ Admin Panel ouvert!", 1.5, CONFIG.COLORS.SUCCESS)
    else
        Utils.tween(mainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, CONFIG.TWEEN_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        task.wait(CONFIG.TWEEN_TIME)
        mainFrame.Visible = false
    end
end

closeButton.MouseButton1Click:Connect(togglePanel)

-- ════════════════════════════════════════════════════════════════
-- KEYBIND SYSTEM
-- ════════════════════════════════════════════════════════════════

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle panel avec INSERT ou RIGHT CONTROL
    if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightControl then
        togglePanel()
    end
    
    -- Quick commands
    if STATE.isOpen then
        if input.KeyCode == Enum.KeyCode.F1 then
            toggleFly(not STATE.flying)
        elseif input.KeyCode == Enum.KeyCode.F2 then
            toggleNoclip(not STATE.noclipping)
        elseif input.KeyCode == Enum.KeyCode.F3 then
            toggleESP(not STATE.espEnabled)
        elseif input.KeyCode == Enum.KeyCode.F4 then
            toggleFullbright(not STATE.fullbright)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
-- STATISTICS UPDATE LOOP
-- ════════════════════════════════════════════════════════════════

spawn(function()
    while true do
        task.wait(1)
        local uptime = tick() - STATE.startTime
        statsLabel.Text = string.format(
            "Uptime: %s\nCommands: %d",
            Utils.formatTime(uptime),
            STATE.totalCommands
        )
    end
end)

-- ════════════════════════════════════════════════════════════════
-- WELCOME NOTIFICATION SYSTEM
-- ════════════════════════════════════════════════════════════════

task.wait(1)

local welcomeFrame = Instance.new("Frame")
welcomeFrame.Size = UDim2.new(0, 400, 0, 120)
welcomeFrame.Position = UDim2.new(1, -420, 1, -140)
welcomeFrame.BackgroundColor3 = CONFIG.COLORS.SECONDARY
welcomeFrame.BorderSizePixel = 0
welcomeFrame.Parent = screenGui

local welcomeCorner = Instance.new("UICorner")
welcomeCorner.CornerRadius = UDim.new(0, 12)
welcomeCorner.Parent = welcomeFrame

local welcomeAccent = Instance.new("Frame")
welcomeAccent.Size = UDim2.new(1, 0, 0, 4)
welcomeAccent.BackgroundColor3 = CONFIG.COLORS.ACCENT
welcomeAccent.BorderSizePixel = 0
welcomeAccent.Parent = welcomeFrame

local welcomeTitle = Instance.new("TextLabel")
welcomeTitle.Size = UDim2.new(1, -30, 0, 30)
welcomeTitle.Position = UDim2.new(0, 15, 0, 10)
welcomeTitle.BackgroundTransparency = 1
welcomeTitle.Text = "⚡ ULTIMATE ADMIN PANEL"
welcomeTitle.TextColor3 = CONFIG.COLORS.ACCENT
welcomeTitle.TextSize = 18
welcomeTitle.Font = Enum.Font.GothamBold
welcomeTitle.TextXAlignment = Enum.TextXAlignment.Left
welcomeTitle.Parent = welcomeFrame

local welcomeText = Instance.new("TextLabel")
welcomeText.Size = UDim2.new(1, -30, 0, 70)
welcomeText.Position = UDim2.new(0, 15, 0, 40)
welcomeText.BackgroundTransparency = 1
welcomeText.Text = "Chargé avec succès!\n\n🔑 Appuyez sur INSERT ou RIGHT CTRL\n⚡ Raccourcis: F1-F4 pour commandes rapides"
welcomeText.TextColor3 = CONFIG.COLORS.TEXT_PRIMARY
welcomeText.TextSize = 13
welcomeText.Font = Enum.Font.Gotham
welcomeText.TextWrapped = true
welcomeText.TextXAlignment = Enum.TextXAlignment.Left
welcomeText.TextYAlignment = Enum.TextYAlignment.Top
welcomeText.Parent = welcomeFrame

-- Animation d'entrée
welcomeFrame.Position = UDim2.new(1, 50, 1, -140)
Utils.tween(welcomeFrame, {
    Position = UDim2.new(1, -420, 1, -140)
}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

task.wait(5)

-- Animation de sortie
Utils.tween(welcomeFrame, {
    Position = UDim2.new(1, 50, 1, -140)
}, 0.5)

task.wait(0.5)
welcomeFrame:Destroy()

-- ════════════════════════════════════════════════════════════════
-- QUICK ACCESS INDICATOR
-- ════════════════════════════════════════════════════════════════

local quickIndicator = Instance.new("TextLabel")
quickIndicator.Size = UDim2.new(0, 200, 0, 30)
quickIndicator.Position = UDim2.new(0.5, -100, 1, -40)
quickIndicator.BackgroundColor3 = CONFIG.COLORS.SECONDARY
quickIndicator.BackgroundTransparency = 0.3
quickIndicator.BorderSizePixel = 0
quickIndicator.Text = "Press INSERT to open"
quickIndicator.TextColor3 = CONFIG.COLORS.TEXT_PRIMARY
quickIndicator.TextSize = 12
quickIndicator.Font = Enum.Font.GothamBold
quickIndicator.Parent = screenGui

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(0, 8)
indicatorCorner.Parent = quickIndicator

-- Pulse animation
spawn(function()
    while true do
        Utils.tween(quickIndicator, {
            BackgroundTransparency = 0.6
        }, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1)
        Utils.tween(quickIndicator, {
            BackgroundTransparency = 0.3
        }, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1)
    end
end)

-- Hide indicator when panel is open
spawn(function()
    while true do
        task.wait(0.1)
        quickIndicator.Visible = not STATE.isOpen
    end
end)

-- ════════════════════════════════════════════════════════════════
-- CHARACTER RESPAWN HANDLER
-- ════════════════════════════════════════════════════════════════

player.CharacterAdded:Connect(function(character)
    task.wait(1)
    
    -- Réappliquer les états actifs
    if STATE.flying then
        task.wait(0.5)
        toggleFly(false)
        Utils.notify("⚠️ Fly désactivé après respawn", 2, CONFIG.COLORS.WARNING)
    end
    
    if STATE.noclipping then
        task.wait(0.5)
        toggleNoclip(true)
        Utils.notify("👻 Noclip réactivé", 2, CONFIG.COLORS.SUCCESS)
    end
    
    if STATE.currentSpeed ~= CONFIG.DEFAULT_SPEED then
        task.wait(0.5)
        setSpeed(STATE.currentSpeed)
    end
    
    if STATE.currentJump ~= CONFIG.DEFAULT_JUMP then
        task.wait(0.5)
        setJumpPower(STATE.currentJump)
    end
end)

-- ════════════════════════════════════════════════════════════════
-- CLEANUP ON SCRIPT REMOVAL
-- ════════════════════════════════════════════════════════════════

screenGui.Destroying:Connect(function()
    -- Cleanup all connections
    if STATE.noclipConnection then
        STATE.noclipConnection:Disconnect()
    end
    
    for _, connection in pairs(STATE.espConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Restore original values
    if STATE.fullbright then
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    end
    
    workspace.Gravity = CONFIG.DEFAULT_GRAVITY
    camera.FieldOfView = CONFIG.DEFAULT_FOV
end)

-- ════════════════════════════════════════════════════════════════
-- CONSOLE LOG
-- ════════════════════════════════════════════════════════════════

print("═══════════════════════════════════════════════════════════")
print("  ULTIMATE ADMIN PANEL - CLIENT SIDE")
print("  Successfully loaded!")
print("  Version: 2.0 - 1500+ Lines Edition")
print("  Total Commands: " .. STATE.totalCommands)
print("═══════════════════════════════════════════════════════════")
print("")
print("Controls:")
print("  - INSERT or RIGHT CTRL: Toggle Panel")
print("  - F1: Quick Fly Toggle")
print("  - F2: Quick Noclip Toggle")
print("  - F3: Quick ESP Toggle")
print("  - F4: Quick Fullbright Toggle")
print("  - CTRL + Left Click: Teleport (when Click TP is on)")
print("")
print("Features:")
print("  ✓ 50+ Client-Side Commands")
print("  ✓ Draggable Interface")
print("  ✓ 5 Different Categories")
print("  ✓ Real-time Statistics")
print("  ✓ Smooth Animations")
print("  ✓ ESP System with Health Bars")
print("  ✓ Fly Mode with Turbo")
print("  ✓ Noclip System")
print("  ✓ Visual Effects")
print("  ✓ World Modifications")
print("  ✓ Fun Commands")
print("")
print("═══════════════════════════════════════════════════════════")

--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                     END OF SCRIPT                             ║
    ║                  Total Lines: 2000+                           ║
    ║              Created by JasonProDev                           ║
    ╚═══════════════════════════════════════════════════════════════╝
--]]
