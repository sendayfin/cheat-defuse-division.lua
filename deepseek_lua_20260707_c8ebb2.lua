-- ============================================================
-- 🔥 HvH ULTRA FIXED v3.0 (MM2) — Mobile
-- ============================================================

local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInput = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP
local Char
local Gui
local Humanoid
local RootPart

local function GetCharacter()
    LP = Players.LocalPlayer
    if not LP then return end
    Char = LP.Character
    if not Char then return end
    Humanoid = Char:FindFirstChildOfClass("Humanoid")
    RootPart = Char:FindFirstChild("HumanoidRootPart")
    Gui = LP:FindFirstChild("PlayerGui")
end

GetCharacter()

-- === ПЕРЕЗАГРУЗКА ПРИ ПОЯВЛЕНИИ ===
LP.CharacterAdded:Connect(function(newChar)
    Char = newChar
    Humanoid = Char:FindFirstChildOfClass("Humanoid")
    RootPart = Char:FindFirstChild("HumanoidRootPart")
    Gui = LP:FindFirstChild("PlayerGui")
    -- Пересоздаём GUI
    if ScreenGui then ScreenGui:Destroy() end
    CreateMenu()
    Settings.Aimbot = false
    Settings.AutoShoot = false
    Settings.Bunnyhop = false
    Settings.Skybox = false
    Settings.Ring = false
    Settings.FastWalk = false
    Settings.Fly = false
    Settings.Spin = false
    -- Пересоздаём кнопку автошота
    if AutoShootButton then AutoShootButton:Destroy() end
    print("✅ Персонаж перезагружен, настройки сброшены.")
end)

-- === НАСТРОЙКИ ===
local Settings = {
    Smooth = 0.3,
    FOV = 120,
    Aimbot = false,
    AutoShoot = false,
    Bunnyhop = false,
    Skybox = false,
    SkyboxType = "Обычное",
    Ring = false,
    RingSize = 3,
    FastWalk = false,
    Fly = false,
    Spin = false,
    SpinSpeed = 5,
}

-- === ФУНКЦИИ СКАЙБОКСОВ ===
local SkyboxTextures = {
    ["Обычное"] = nil,
    ["Чёрное"] = "rbxassetid://9999999999", -- заглушка, замени на реальный ID
    ["Зелёное (Zromakey)"] = "rbxassetid://8888888888",
    ["Реалистичное"] = "rbxassetid://7777777777",
    ["Сакура"] = "rbxassetid://6666666666",
}

local function ApplySkybox(type)
    local sky = Lighting:FindFirstChild("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = Lighting
    end
    if type == "Обычное" then
        sky.SkyboxBk = "rbxassetid://"
        sky.SkyboxDn = "rbxassetid://"
        sky.SkyboxFt = "rbxassetid://"
        sky.SkyboxLf = "rbxassetid://"
        sky.SkyboxRt = "rbxassetid://"
        sky.SkyboxUp = "rbxassetid://"
    else
        local tex = SkyboxTextures[type]
        if tex then
            sky.SkyboxBk = tex
            sky.SkyboxDn = tex
            sky.SkyboxFt = tex
            sky.SkyboxLf = tex
            sky.SkyboxRt = tex
            sky.SkyboxUp = tex
        end
    end
end

-- === СОЗДАНИЕ ГЛАВНОГО МЕНЮ ===
local ScreenGui
local Main
local function CreateMenu()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = Gui
    ScreenGui.Name = "HvH_Menu"
    ScreenGui.ResetOnSpawn = false

    Main = Instance.new("Frame")
    Main.Parent = ScreenGui
    Main.Size = UDim2.new(0.65, 0, 0.85, 0)
    Main.Position = UDim2.new(0.175, 0, 0.075, 0)
    Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Main.BackgroundTransparency = 0.25
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Visible = false
    local Corner = Instance.new("UICorner")
    Corner.Parent = Main
    Corner.CornerRadius = UDim.new(0, 20)

    -- Плавающие картинки
    local ParticleContainer = Instance.new("Frame")
    ParticleContainer.Parent = Main
    ParticleContainer.Size = UDim2.new(1, 0, 1, 0)
    ParticleContainer.BackgroundTransparency = 1
    ParticleContainer.ZIndex = 0

    local Floats = {}
    for i = 1, 25 do
        local img = Instance.new("ImageLabel")
        img.Parent = ParticleContainer
        img.Size = UDim2.new(0, math.random(8, 18), 0, math.random(8, 18))
        img.Position = UDim2.new(math.random(5, 90)/100, 0, math.random(5, 90)/100, 0)
        img.BackgroundTransparency = 1
        img.Image = "rbxassetid://3040518533"
        img.ImageTransparency = 0.3 + math.random() * 0.5
        img.ZIndex = 0
        local data = {
            frame = img,
            phase = math.random() * 2 * math.pi,
            baseX = img.Position.X.Scale,
            baseY = img.Position.Y.Scale,
            rotSpeed = math.random() * 2 - 1
        }
        table.insert(Floats, data)
    end

    RunService.Heartbeat:Connect(function(dt)
        if not Main.Visible then return end
        for _, f in ipairs(Floats) do
            local x = f.baseX + math.sin(tick() * 0.5 + f.phase) * 0.03
            local y = f.baseY + math.cos(tick() * 0.6 + f.phase * 0.7) * 0.03
            f.frame.Position = UDim2.new(x, 0, y, 0)
            f.frame.Rotation = f.frame.Rotation + f.rotSpeed * dt * 20
            local trans = 0.3 + 0.5 * (0.5 + 0.5 * math.sin(tick() * 0.7 + f.phase))
            f.frame.ImageTransparency = trans
        end
    end)

    -- Заголовок
    local Header = Instance.new("Frame")
    Header.Parent = Main
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
    Header.BackgroundTransparency = 0.3
    Header.BorderSizePixel = 0
    local HCorner = Instance.new("UICorner")
    HCorner.Parent = Header
    HCorner.CornerRadius = UDim.new(0, 20)

    local Title = Instance.new("TextLabel")
    Title.Parent = Header
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.Position = UDim2.new(0.05, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "✦ HvH ULTRA ✦"
    Title.TextColor3 = Color3.fromRGB(40, 40, 60)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold

    local HideBtn = Instance.new("TextButton")
    HideBtn.Parent = Header
    HideBtn.Size = UDim2.new(0, 55, 0, 30)
    HideBtn.Position = UDim2.new(1, -60, 0, 5)
    HideBtn.Text = "Скрыть"
    HideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    HideBtn.TextScaled = true
    HideBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 180)
    HideBtn.BackgroundTransparency = 0.2
    HideBtn.BorderSizePixel = 0
    local HBCorner = Instance.new("UICorner")
    HBCorner.Parent = HideBtn
    HBCorner.CornerRadius = UDim.new(0, 10)

    -- Снежинка
    local Snowflake = Instance.new("TextButton")
    Snowflake.Parent = ScreenGui
    Snowflake.Size = UDim2.new(0, 50, 0, 50)
    Snowflake.Position = UDim2.new(0.85, 0, 0.85, 0)
    Snowflake.Text = "❄️"
    Snowflake.TextColor3 = Color3.fromRGB(80, 80, 120)
    Snowflake.TextScaled = true
    Snowflake.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
    Snowflake.BackgroundTransparency = 0.2
    Snowflake.BorderSizePixel = 1
    Snowflake.BorderColor3 = Color3.fromRGB(180, 180, 200)
    local SCorner = Instance.new("UICorner")
    SCorner.Parent = Snowflake
    SCorner.CornerRadius = UDim.new(0, 25)
    Snowflake.Visible = false

    -- Анимации окна
    local function AnimateOpen()
        Main.Visible = true
        Main.Size = UDim2.new(0.65, 0, 0.85, 0)
        local startSize = UDim2.new(0.65, 0, 0.01, 0)
        local startTrans = 0.7
        Main.Size = startSize
        Main.BackgroundTransparency = startTrans
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local goal = {Size = UDim2.new(0.65, 0, 0.85, 0), BackgroundTransparency = 0.25}
        local tween = TweenService:Create(Main, tweenInfo, goal)
        tween:Play()
    end

    local function AnimateClose()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local goal = {Size = UDim2.new(0.65, 0, 0.01, 0), BackgroundTransparency = 0.7}
        local tween = TweenService:Create(Main, tweenInfo, goal)
        tween:Play()
        tween.Completed:Connect(function()
            Main.Visible = false
        end)
    end

    local function HideMenu()
        AnimateClose()
        Snowflake.Visible = true
    end

    local function ShowMenu()
        Snowflake.Visible = false
        AnimateOpen()
    end

    HideBtn.Activated:Connect(HideMenu)
    Snowflake.Activated:Connect(ShowMenu)
    AnimateOpen()

    -- Перетаскивание
    local Drag, DragStart, StartPos = false
    Header.InputBegan:Connect(function(I)
        if I.UserInputType == Enum.UserInputType.Touch then
            Drag = true
            DragStart = I.Position
            StartPos = Main.Position
        end
    end)
    Header.InputEnded:Connect(function() Drag = false end)
    UserInput.InputChanged:Connect(function(I)
        if Drag and I.UserInputType == Enum.UserInputType.Touch then
            local Delta = I.Position - DragStart
            Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)

    -- Вкладки
    local TabBar = Instance.new("Frame")
    TabBar.Parent = Main
    TabBar.Size = UDim2.new(1, 0, 0, 35)
    TabBar.Position = UDim2.new(0, 0, 0, 40)
    TabBar.BackgroundTransparency = 1
    TabBar.BorderSizePixel = 0

    local Tabs = {"Aimbot", "Visuals", "Misc"}
    local TabButtons = {}

    for i, name in ipairs(Tabs) do
        local btn = Instance.new("TextButton")
        btn.Parent = TabBar
        btn.Size = UDim2.new(1/3, 0, 1, 0)
        btn.Position = UDim2.new((i-1)/3, 0, 0, 0)
        btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(200, 200, 220) or Color3.fromRGB(230, 230, 240)
        btn.BackgroundTransparency = 0.2
        btn.Text = name
        btn.TextColor3 = (i == 1) and Color3.fromRGB(30, 30, 50) or Color3.fromRGB(100, 100, 120)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        local c = Instance.new("UICorner")
        c.Parent = btn
        c.CornerRadius = UDim.new(0, 6)
        table.insert(TabButtons, btn)
    end

    -- Контейнеры вкладок
    local Content = Instance.new("Frame")
    Content.Parent = Main
    Content.Size = UDim2.new(1, 0, 1, -75)
    Content.Position = UDim2.new(0, 0, 0, 75)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0

    local function MakeScrollTab()
        local sc = Instance.new("ScrollingFrame")
        sc.Parent = Content
        sc.Size = UDim2.new(1, 0, 1, 0)
        sc.BackgroundTransparency = 1
        sc.BorderSizePixel = 0
        sc.ScrollBarThickness = 3
        sc.ScrollBarImageColor3 = Color3.fromRGB(160, 160, 180)
        sc.CanvasSize = UDim2.new(0, 0, 0, 600)
        return sc
    end

    local TabAimbot = MakeScrollTab()
    local TabVisuals = MakeScrollTab()
    local TabMisc = MakeScrollTab()
    TabVisuals.Visible = false
    TabMisc.Visible = false

    for i, btn in ipairs(TabButtons) do
        btn.Activated:Connect(function()
            for _, b in pairs(TabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
                b.TextColor3 = Color3.fromRGB(100, 100, 120)
            end
            btn.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
            btn.TextColor3 = Color3.fromRGB(30, 30, 50)
            TabAimbot.Visible = (i == 1)
            TabVisuals.Visible = (i == 2)
            TabMisc.Visible = (i == 3)
        end)
    end

    -- === ЭЛЕМЕНТЫ UI ===

    -- Анимированный переключатель (свитч)
    local function AddToggleSwitch(Parent, Label, Default, Callback, Y)
        local f = Instance.new("Frame")
        f.Parent = Parent
        f.Size = UDim2.new(1, 0, 0, 40)
        f.Position = UDim2.new(0, 0, 0, Y)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0

        local lbl = Instance.new("TextLabel")
        lbl.Parent = f
        lbl.Size = UDim2.new(0.7, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = Label
        lbl.TextColor3 = Color3.fromRGB(40, 40, 60)
        lbl.TextSize = 16
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local switch = Instance.new("Frame")
        switch.Parent = f
        switch.Size = UDim2.new(0, 50, 0, 28)
        switch.Position = UDim2.new(0.85, 0, 0.15, 0)
        switch.BackgroundColor3 = Default and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(180, 180, 190)
        switch.BorderSizePixel = 0
        local swCorner = Instance.new("UICorner")
        swCorner.Parent = switch
        swCorner.CornerRadius = UDim.new(0, 14)

        local knob = Instance.new("Frame")
        knob.Parent = switch
        knob.Size = UDim2.new(0, 22, 0, 22)
        knob.Position = Default and UDim2.new(0, 26, 0, 3) or UDim2.new(0, 3, 0, 3)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        local knCorner = Instance.new("UICorner")
        knCorner.Parent = knob
        knCorner.CornerRadius = UDim.new(0, 11)

        local state = Default
        local function UpdateSwitch(newState)
            state = newState
            local bgGoal = {BackgroundColor3 = state and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(180, 180, 190)}
            local bgTween = TweenService:Create(switch, TweenInfo.new(0.15, Enum.EasingStyle.Quad), bgGoal)
            bgTween:Play()
            local knobGoal = {Position = state and UDim2.new(0, 26, 0, 3) or UDim2.new(0, 3, 0, 3)}
            local knobTween = TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), knobGoal)
            knobTween:Play()
            Callback(state)
        end
        switch.InputBegan:Connect(function(I)
            if I.UserInputType == Enum.UserInputType.Touch then
                UpdateSwitch(not state)
            end
        end)
        UpdateSwitch(Default)
        return switch
    end

    -- Слайдер
    local function AddSlider(Parent, Label, Min, Max, Default, Callback, Y)
        local f = Instance.new("Frame")
        f.Parent = Parent
        f.Size = UDim2.new(1, 0, 0, 55)
        f.Position = UDim2.new(0, 0, 0, Y)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0

        local lbl = Instance.new("TextLabel")
        lbl.Parent = f
        lbl.Size = UDim2.new(1, 0, 0, 22)
        lbl.Position = UDim2.new(0, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = Label .. ": " .. tostring(Default)
        lbl.TextColor3 = Color3.fromRGB(40, 40, 60)
        lbl.TextSize = 16
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local track = Instance.new("Frame")
        track.Parent = f
        track.Size = UDim2.new(0.9, 0, 0, 12)
        track.Position = UDim2.new(0.05, 0, 0.45, 0)
        track.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
        track.BorderSizePixel = 0
        local trc = Instance.new("UICorner")
        trc.Parent = track
        trc.CornerRadius = UDim.new(0, 6)

        local fill = Instance.new("Frame")
        fill.Parent = track
        fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(80, 150, 220)
        fill.BorderSizePixel = 0
        local fic = Instance.new("UICorner")
        fic.Parent = fill
        fic.CornerRadius = UDim.new(0, 6)

        local val = Default
        local function Update(x)
            local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            val = Min + (Max - Min) * rel
            fill.Size = UDim2.new(rel, 0, 1, 0)
            lbl.Text = Label .. ": " .. string.format("%.1f", val)
            Callback(val)
        end

        track.InputBegan:Connect(function(I)
            if I.UserInputType == Enum.UserInputType.Touch then Update(I.Position.X) end
        end)
        track.InputChanged:Connect(function(I)
            if I.UserInputType == Enum.UserInputType.Touch and I.Position then Update(I.Position.X) end
        end)
        return f
    end

    -- Выпадающий список (Dropdown)
    local function AddDropdown(Parent, Label, Options, Default, Callback, Y)
        local f = Instance.new("Frame")
        f.Parent = Parent
        f.Size = UDim2.new(1, 0, 0, 50)
        f.Position = UDim2.new(0, 0, 0, Y)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0

        local lbl = Instance.new("TextLabel")
        lbl.Parent = f
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = Label
        lbl.TextColor3 = Color3.fromRGB(40, 40, 60)
        lbl.TextSize = 16
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton")
        btn.Parent = f
        btn.Size = UDim2.new(0.4, 0, 0.8, 0)
        btn.Position = UDim2.new(0.55, 0, 0.1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
        btn.Text = Default
        btn.TextColor3 = Color3.fromRGB(40, 40, 60)
        btn.TextScaled = true
        btn.BorderSizePixel = 0
        local btnCorner = Instance.new("UICorner")
        btnCorner.Parent = btn
        btnCorner.CornerRadius = UDim.new(0, 6)

        local list = Instance.new("Frame")
        list.Parent = f
        list.Size = UDim2.new(0.4, 0, 0, 0)
        list.Position = UDim2.new(0.55, 0, 0.9, 0)
        list.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
        list.BackgroundTransparency = 0.1
        list.BorderSizePixel = 1
        list.BorderColor3 = Color3.fromRGB(180, 180, 200)
        list.ClipsDescendants = true
        list.Visible = false
        local listCorner = Instance.new("UICorner")
        listCorner.Parent = list
        listCorner.CornerRadius = UDim.new(0, 6)

        local uiList = Instance.new("UIListLayout")
        uiList.Parent = list
        uiList.SortOrder = Enum.SortOrder.LayoutOrder
        uiList.Padding = UDim.new(0, 2)

        local current = Default
        local function Select(option)
            current = option
            btn.Text = option
            Callback(option)
            list.Visible = false
            list.Size = UDim2.new(0.4, 0, 0, 0)
        end

        for _, opt in ipairs(Options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Parent = list
            optBtn.Size = UDim2.new(1, 0, 0, 30)
            optBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
            optBtn.BackgroundTransparency = 0.2
            optBtn.Text = opt
            optBtn.TextColor3 = Color3.fromRGB(40, 40, 60)
            optBtn.TextSize = 14
            optBtn.BorderSizePixel = 0
            optBtn.Activated:Connect(function()
                Select(opt)
            end)
        end

        btn.Activated:Connect(function()
            list.Visible = not list.Visible
            if list.Visible then
                list.Size = UDim2.new(0.4, 0, 0, #Options * 32 + 10)
            else
                list.Size = UDim2.new(0.4, 0, 0, 0)
            end
        end)

        return btn
    end

    -- === ЗАПОЛНЕНИЕ ВКЛАДОК ===
    local y = 0
    AddSlider(TabAimbot, "Smoothness", 0, 1, 0.3, function(v) Settings.Smooth = v end, y); y = y + 60
    AddSlider(TabAimbot, "FOV", 60, 180, 120, function(v) Settings.FOV = v; Camera.FieldOfView = v end, y); y = y + 60
    AddSlider(TabAimbot, "Spin Speed", 0, 20, 5, function(v) Settings.SpinSpeed = v end, y); y = y + 60
    AddToggleSwitch(TabAimbot, "Aimbot", false, function(v) Settings.Aimbot = v end, y); y = y + 45
    AddToggleSwitch(TabAimbot, "AutoShoot", false, function(v) 
        Settings.AutoShoot = v
        if v then
            CreateAutoShootButton()
        else
            if AutoShootButton then AutoShootButton:Destroy() end
        end
    end, y); y = y + 45
    AddToggleSwitch(TabAimbot, "Bunnyhop", false, function(v) Settings.Bunnyhop = v end, y); y = y + 45
    AddToggleSwitch(TabAimbot, "Spin", false, function(v) Settings.Spin = v end, y); y = y + 45
    TabAimbot.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    y = 0
    AddToggleSwitch(TabVisuals, "Skybox", false, function(v) 
        Settings.Skybox = v
        if v then
            ApplySkybox(Settings.SkyboxType)
        else
            ApplySkybox("Обычное")
        end
    end, y); y = y + 45
    AddDropdown(TabVisuals, "Skybox Type", {"Обычное", "Чёрное", "Зелёное", "Реалистичное", "Сакура"}, "Обычное", function(v)
        Settings.SkyboxType = v
        if Settings.Skybox then
            ApplySkybox(v)
        end
    end, y); y = y + 55
    AddToggleSwitch(TabVisuals, "Ring", false, function(v) Settings.Ring = v end, y); y = y + 45
    AddSlider(TabVisuals, "Ring Size", 1, 5, 3, function(v) Settings.RingSize = v end, y); y = y + 60
    TabVisuals.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    y = 0
    AddToggleSwitch(TabMisc, "Fast Walk", false, function(v) Settings.FastWalk = v end, y); y = y + 45
    AddToggleSwitch(TabMisc, "Fly", false, function(v) Settings.Fly = v end, y); y = y + 45
    TabMisc.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    -- Информационная строка
    local Info = Instance.new("TextLabel")
    Info.Parent = Main
    Info.Size = UDim2.new(1, 0, 0, 22)
    Info.Position = UDim2.new(0, 0, 1, -22)
    Info.BackgroundTransparency = 1
    Info.Text = "owner - tgk: @sendayfin"
    Info.TextColor3 = Color3.fromRGB(100, 100, 120)
    Info.TextSize = 14
    Info.TextScaled = true
    Info.Font = Enum.Font.Gotham

    print("✅ Меню загружено. Все функции выключены.")
end

if Gui then CreateMenu() else print("GUI не найден") end

-- === КНОПКА АВТОШОТА ===
local AutoShootButton
local function CreateAutoShootButton()
    if AutoShootButton then AutoShootButton:Destroy() end
    AutoShootButton = Instance.new("TextButton")
    AutoShootButton.Parent = ScreenGui
    AutoShootButton.Size = UDim2.new(0, 80, 0, 40)
    AutoShootButton.Position = UDim2.new(0.02, 0, 0.5, 0)
    AutoShootButton.Text = "🔫 Fire"
    AutoShootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoShootButton.TextScaled = true
    AutoShootButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    AutoShootButton.BorderSizePixel = 0
    local btnCorner = Instance.new("UICorner")
    btnCorner.Parent = AutoShootButton
    btnCorner.CornerRadius = UDim.new(0, 10)
    AutoShootButton.Visible = true

    AutoShootButton.Activated:Connect(function()
        if not Settings.AutoShoot then return end
        if not Char or not RootPart then return end
        -- Определяем роль
        local myRole = GetRoleFromCharacter(Char)
        if not myRole or (myRole ~= "Sheriff" and myRole ~= "Murderer") then return end
        local target = GetClosestEnemy(myRole)
        if not target then return end
        -- Выстрел/кидок
        local myTool = Char:FindFirstChild("RightHand") and Char.RightHand:FindFirstChildOfClass("Tool")
        if myTool then
            local name = myTool.Name:lower()
            if name:find("gun") or name:find("pistol") then
                VirtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                wait(0.05)
                VirtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            elseif name:find("knife") or name:find("blade") then
                VirtualInput:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                wait(0.05)
                VirtualInput:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
            end
        end
    end)
end

-- === ФУНКЦИИ ОПРЕДЕЛЕНИЯ РОЛЕЙ ===
function GetRoleFromCharacter(character)
    if not character then return nil end
    local rightHand = character:FindFirstChild("RightHand")
    if not rightHand then return nil end
    local tool = rightHand:FindFirstChildOfClass("Tool")
    if not tool then return "Innocent" end
    local name = tool.Name:lower()
    if name:find("knife") or name:find("murder") or name:find("blade") then
        return "Murderer"
    elseif name:find("gun") or name:find("pistol") or name:find("sheriff") then
        return "Sheriff"
    end
    return "Innocent"
end

-- === ESP (отображение ролей) ===
local RoleLabels = {}
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local role = GetRoleFromCharacter(char)
                local label = RoleLabels[player]
                if not label then
                    local bill = Instance.new("BillboardGui")
                    bill.Parent = char.HumanoidRootPart
                    bill.Size = UDim2.new(0, 80, 0, 30)
                    bill.AlwaysOnTop = true
                    local text = Instance.new("TextLabel", bill)
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.TextScaled = true
                    text.TextStrokeTransparency = 0.3
                    label = bill
                    RoleLabels[player] = label
                end
                local textLabel = label:FindFirstChildOfClass("TextLabel")
                if textLabel then
                    local color = Color3.fromRGB(200,200,200)
                    if role == "Sheriff" then
                        color = Color3.fromRGB(0, 200, 255)
                    elseif role == "Murderer" then
                        color = Color3.fromRGB(255, 50, 50)
                    end
                    textLabel.Text = role or "Unknown"
                    textLabel.TextColor3 = color
                end
                if label.Parent ~= char.HumanoidRootPart then
                    label.Parent = char.HumanoidRootPart
                end
            else
                if RoleLabels[player] then
                    RoleLabels[player]:Destroy()
                    RoleLabels[player] = nil
                end
            end
        end
    end
end

spawn(function()
    while wait(1) do
        pcall(UpdateESP)
    end
end)

-- === ПОИСК ЦЕЛИ ДЛЯ АИМА ===
function GetClosestEnemy(myRole)
    local best = nil
    local bestDist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local role = GetRoleFromCharacter(char)
            if (myRole == "Sheriff" and role == "Murderer") or (myRole == "Murderer" and role == "Sheriff") then
                local root = char.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (root.Position - Camera.CFrame.Position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = player
                    end
                end
            end
        end
    end
    return best
end

-- === АИМБОТ, СПИН, АВТОШОТ ===
RunService.RenderStepped:Connect(function()
    if not Settings.Aimbot and not Settings.Spin then return end
    if not Char or not RootPart then return end
    local myRole = GetRoleFromCharacter(Char)
    if not myRole or (myRole ~= "Sheriff" and myRole ~= "Murderer") then
        return
    end

    local target = GetClosestEnemy(myRole)
    if target then
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then
            local aimPos = tRoot.Position + Vector3.new(0, 1.5, 0)
            local newCFrame = CFrame.new(Camera.CFrame.Position, aimPos)
            if Settings.Aimbot then
                Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Settings.Smooth)
            end
            if Settings.Spin then
                -- Крутилка: вращаем персонажа вокруг своей оси
                local spinSpeed = Settings.SpinSpeed * 0.1
                RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
            end
        end
    end
end)

-- === БАНИХОП ===
local JumpCooldown = 0
RunService.Heartbeat:Connect(function(dt)
    if not Settings.Bunnyhop then return end
    if not Char or not Humanoid then return end
    if Humanoid.MoveDirection.Magnitude > 0.5 and Humanoid.FloorMaterial ~= Enum.Material.Air then
        if tick() - JumpCooldown > 0.12 then
            VirtualInput:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            wait(0.02)
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            JumpCooldown = tick()
        end
    end
end)

-- === RING ===
local RingPart = nil
RunService.Heartbeat:Connect(function()
    if Settings.Ring then
        if not RingPart then
            RingPart = Instance.new("Part")
            RingPart.Shape = Enum.PartType.Cylinder
            RingPart.Material = Enum.Material.Neon
            RingPart.Size = Vector3.new(Settings.RingSize * 1.2, 0.1, Settings.RingSize * 1.2)
            RingPart.CanCollide = false
            RingPart.Anchored = true
            RingPart.Transparency = 0.5
            RingPart.BrickColor = BrickColor.new("Bright blue")
            RingPart.Parent = workspace
        else
            RingPart.Size = Vector3.new(Settings.RingSize * 1.2, 0.1, Settings.RingSize * 1.2)
        end
        if Char and RootPart then
            RingPart.CFrame = CFrame.new(RootPart.Position.X, 0.2, RootPart.Position.Z)
            RingPart.Rotation = RingPart.Rotation + Vector3.new(0, 3, 0)
        end
    else
        if RingPart then
            RingPart:Destroy()
            RingPart = nil
        end
    end
end)

-- === FAST WALK ===
RunService.Heartbeat:Connect(function()
    if not Char or not Humanoid then return end
    if Settings.FastWalk then
        Humanoid.WalkSpeed = 30
    else
        Humanoid.WalkSpeed = 16
    end
end)

-- === FLY ===
local FlyEnabled = false
RunService.Heartbeat:Connect(function()
    if not Char or not Humanoid then return end
    if Settings.Fly then
        if not FlyEnabled then
            Humanoid.PlatformStand = true
            FlyEnabled = true
        end
    else
        if FlyEnabled then
            Humanoid.PlatformStand = false
            FlyEnabled = false
        end
    end
end)

print("✅ Все функции загружены и исправлены.")