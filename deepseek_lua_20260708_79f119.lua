-- ============================================================
-- 🔥 HvH ULTRA — РАСТЯГ + КНОПКИ + ESP
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

local LP = Players.LocalPlayer
local Char, Gui

local function updateChar()
    Char = LP.Character
    Gui = LP:FindFirstChild("PlayerGui")
end
updateChar()
LP.CharacterAdded:Connect(updateChar)

-- === НАСТРОЙКИ ===
local Settings = {
    ESP = false,
    Smooth = 0.3,
    AimFOV = 120,          -- для аимбота (радиус)
    ScreenStretch = 70,    -- растяг (будет менять FOV камеры)
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
    -- Кнопки
    ButtonSpeed = false,
    ButtonWall = false,
    ButtonHop = false,
    ButtonThrow = false,
    ButtonDress = false,
    ButtonGhost = false,
    -- Прицел
    Crosshair = "Крестик",
}

-- === РАСТЯГ (изменяем FOV камеры) ===
local function applyStretch()
    Camera.FieldOfView = Settings.ScreenStretch
end

-- === ОПРЕДЕЛЕНИЕ РОЛИ ===
local function getRole(player)
    if player == LP then return nil end
    local role = player:GetAttribute("Role") or player:GetAttribute("Team")
    if role then
        if role == "Murderer" or role == "Sheriff" or role == "Innocent" then
            return role
        end
    end
    local gui = player.PlayerGui
    if gui then
        local tag = gui:FindFirstChild("Tags") or gui:FindFirstChild("RoleTag")
        if tag then
            local text = tag:FindFirstChildOfClass("TextLabel")
            if text then
                local txt = text.Text
                if txt:find("Murderer") then return "Murderer"
                elseif txt:find("Sheriff") then return "Sheriff"
                else return "Innocent" end
            end
        end
    end
    return "Innocent"
end

-- === ESP ===
local espLabels = {}
local function updateESP()
    if not Settings.ESP then
        for _, label in pairs(espLabels) do
            if label then label:Destroy() end
        end
        espLabels = {}
        return
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local role = getRole(player)
                local label = espLabels[player]
                if not label then
                    local bill = Instance.new("BillboardGui")
                    bill.Parent = char.HumanoidRootPart
                    bill.Size = UDim2.new(0, 120, 0, 40)
                    bill.AlwaysOnTop = true
                    local text = Instance.new("TextLabel", bill)
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.TextScaled = true
                    text.TextStrokeTransparency = 0.3
                    label = bill
                    espLabels[player] = label
                end
                local textLabel = label:FindFirstChildOfClass("TextLabel")
                if textLabel then
                    local color = Color3.fromRGB(200,200,200)
                    if role == "Sheriff" then color = Color3.fromRGB(0, 200, 255)
                    elseif role == "Murderer" then color = Color3.fromRGB(255, 50, 50) end
                    textLabel.Text = role or "Innocent"
                    textLabel.TextColor3 = color
                end
                if label.Parent ~= char.HumanoidRootPart then
                    label.Parent = char.HumanoidRootPart
                end
            else
                if espLabels[player] then
                    espLabels[player]:Destroy()
                    espLabels[player] = nil
                end
            end
        end
    end
end

spawn(function()
    while wait(0.3) do pcall(updateESP) end
end)

-- === КНОПКИ НА ЭКРАНЕ (стиль как на скрине) ===
local buttonFrames = {}
local function createButton(name, text, posX, posY)
    if buttonFrames[name] then buttonFrames[name]:Destroy() end
    local btn = Instance.new("TextButton")
    btn.Parent = Gui
    btn.Size = UDim2.new(0, 120, 0, 45)
    btn.Position = UDim2.new(posX, 0, posY, 0)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    btn.BackgroundTransparency = 0.25
    btn.BorderSizePixel = 0
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 12)
    -- тень
    local shadow = Instance.new("ImageLabel", btn)
    shadow.Size = UDim2.new(1.05, 0, 1.05, 0)
    shadow.Position = UDim2.new(-0.025, 0, -0.025, 0)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1318779509"
    shadow.ImageTransparency = 0.6
    shadow.ZIndex = 0
    btn.ZIndex = 1
    btn.Visible = false
    buttonFrames[name] = btn
    return btn
end

-- Создаём кнопки
local btnSpeed = createButton("Speed", "SPEED", 0.02, 0.1)
local btnWall = createButton("Wall", "WALL", 0.02, 0.2)
local btnHop = createButton("Hop", "HOP", 0.02, 0.3)
local btnThrow = createButton("Throw", "THROW", 0.02, 0.4)
local btnDress = createButton("Dress", "Надеть", 0.02, 0.5)
local btnGhost = createButton("Ghost", "Призрак", 0.02, 0.6)

local function updateButtons()
    btnSpeed.Visible = Settings.ButtonSpeed
    btnWall.Visible = Settings.ButtonWall
    btnHop.Visible = Settings.ButtonHop
    btnThrow.Visible = Settings.ButtonThrow
    btnDress.Visible = Settings.ButtonDress
    btnGhost.Visible = Settings.ButtonGhost
end

-- === ПРИЦЕЛ ===
local crosshair = nil
local function updateCrosshair()
    if crosshair then crosshair:Destroy() crosshair = nil end
    local size = 30
    local img = ""
    if Settings.Crosshair == "Крестик" then
        img = "rbxassetid://11048432998"
    elseif Settings.Crosshair == "Сердечко" then
        img = "rbxassetid://11048432999"
    elseif Settings.Crosshair == "Точка" then
        img = "rbxassetid://11048433000"
    elseif Settings.Crosshair == "Круг" then
        img = "rbxassetid://11048433001"
    end
    if img ~= "" then
        local imgLabel = Instance.new("ImageLabel")
        imgLabel.Parent = Gui
        imgLabel.Size = UDim2.new(0, size, 0, size)
        imgLabel.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
        imgLabel.BackgroundTransparency = 1
        imgLabel.Image = img
        imgLabel.ZIndex = 10
        crosshair = imgLabel
    end
end

-- === МЕНЮ ===
local function createMenu()
    if not Gui then return end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = Gui
    screenGui.Name = "HvH_Menu"
    screenGui.ResetOnSpawn = false

    local main = Instance.new("Frame")
    main.Parent = screenGui
    main.Size = UDim2.new(0.7, 0, 0.85, 0)
    main.Position = UDim2.new(0.15, 0, 0.075, 0)
    main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    main.BackgroundTransparency = 0.2
    main.BorderSizePixel = 0
    local corner = Instance.new("UICorner", main)
    corner.CornerRadius = UDim.new(0, 20)

    -- Заголовок
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
    header.BackgroundTransparency = 0.3
    local hCorner = Instance.new("UICorner", header)
    hCorner.CornerRadius = UDim.new(0, 20)

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.05, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "✦ HvH ULTRA ✦"
    title.TextColor3 = Color3.fromRGB(40, 40, 60)
    title.TextScaled = true

    local hideBtn = Instance.new("TextButton", header)
    hideBtn.Size = UDim2.new(0, 55, 0, 30)
    hideBtn.Position = UDim2.new(1, -60, 0, 5)
    hideBtn.Text = "Скрыть"
    hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    hideBtn.TextScaled = true
    hideBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 180)
    hideBtn.BackgroundTransparency = 0.2
    local hbc = Instance.new("UICorner", hideBtn)
    hbc.CornerRadius = UDim.new(0, 10)

    local snow = Instance.new("TextButton", screenGui)
    snow.Size = UDim2.new(0, 50, 0, 50)
    snow.Position = UDim2.new(0.85, 0, 0.85, 0)
    snow.Text = "❄️"
    snow.TextScaled = true
    snow.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
    snow.BackgroundTransparency = 0.2
    snow.BorderSizePixel = 1
    snow.BorderColor3 = Color3.fromRGB(180, 180, 200)
    local sc = Instance.new("UICorner", snow)
    sc.CornerRadius = UDim.new(0, 25)
    snow.Visible = false

    hideBtn.Activated:Connect(function()
        main.Visible = false
        snow.Visible = true
    end)
    snow.Activated:Connect(function()
        main.Visible = true
        snow.Visible = false
    end)

    -- Вкладки
    local tabs = {"Aimbot", "Visuals", "Misc", "Button"}
    local tabBar = Instance.new("Frame", main)
    tabBar.Size = UDim2.new(1, 0, 0, 35)
    tabBar.Position = UDim2.new(0, 0, 0, 40)
    tabBar.BackgroundTransparency = 1

    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, 0, 1, -75)
    content.Position = UDim2.new(0, 0, 0, 75)
    content.BackgroundTransparency = 1

    local function makeTab()
        local sc = Instance.new("ScrollingFrame", content)
        sc.Size = UDim2.new(1, 0, 1, 0)
        sc.BackgroundTransparency = 1
        sc.ScrollBarThickness = 3
        sc.ScrollBarImageColor3 = Color3.fromRGB(160, 160, 180)
        sc.CanvasSize = UDim2.new(0, 0, 0, 600)
        return sc
    end

    local tabAimbot = makeTab()
    local tabVisuals = makeTab()
    local tabMisc = makeTab()
    local tabButton = makeTab()
    tabVisuals.Visible = false
    tabMisc.Visible = false
    tabButton.Visible = false

    local tabButtons = {}
    local function switchTab(name)
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
            b.TextColor3 = Color3.fromRGB(100, 100, 120)
        end
        for i, b in pairs(tabButtons) do
            if tabs[i] == name then
                b.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
                b.TextColor3 = Color3.fromRGB(30, 30, 50)
            end
        end
        tabAimbot.Visible = (name == "Aimbot")
        tabVisuals.Visible = (name == "Visuals")
        tabMisc.Visible = (name == "Misc")
        tabButton.Visible = (name == "Button")
    end

    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton", tabBar)
        btn.Size = UDim2.new(1/4, 0, 1, 0)
        btn.Position = UDim2.new((i-1)/4, 0, 0, 0)
        btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(200, 200, 220) or Color3.fromRGB(230, 230, 240)
        btn.BackgroundTransparency = 0.2
        btn.Text = name
        btn.TextColor3 = (i == 1) and Color3.fromRGB(30, 30, 50) or Color3.fromRGB(100, 100, 120)
        btn.TextScaled = true
        btn.BorderSizePixel = 0
        local bc = Instance.new("UICorner", btn)
        bc.CornerRadius = UDim.new(0, 6)
        btn.Activated:Connect(function() switchTab(name) end)
        tabButtons[i] = btn
    end

    -- === UI ЭЛЕМЕНТЫ ===
    local function addSwitch(parent, label, default, callback, y)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, 40)
        f.Position = UDim2.new(0, 0, 0, y)
        f.BackgroundTransparency = 1

        local lbl = Instance.new("TextLabel", f)
        lbl.Size = UDim2.new(0.7, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(40, 40, 60)
        lbl.TextSize = 16
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local sw = Instance.new("Frame", f)
        sw.Size = UDim2.new(0, 50, 0, 28)
        sw.Position = UDim2.new(0.85, 0, 0.15, 0)
        sw.BackgroundColor3 = default and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(180, 180, 190)
        local swc = Instance.new("UICorner", sw)
        swc.CornerRadius = UDim.new(0, 14)

        local knob = Instance.new("Frame", sw)
        knob.Size = UDim2.new(0, 22, 0, 22)
        knob.Position = default and UDim2.new(0, 26, 0, 3) or UDim2.new(0, 3, 0, 3)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        local kc = Instance.new("UICorner", knob)
        kc.CornerRadius = UDim.new(0, 11)

        local state = default
        local function update(newState)
            state = newState
            TweenService:Create(sw, TweenInfo.new(0.15), {BackgroundColor3 = state and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(180, 180, 190)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {Position = state and UDim2.new(0, 26, 0, 3) or UDim2.new(0, 3, 0, 3)}):Play()
            callback(state)
        end
        sw.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch then update(not state) end
        end)
        update(default)
        return sw
    end

    local function addSlider(parent, label, min, max, default, callback, y)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, 55)
        f.Position = UDim2.new(0, 0, 0, y)
        f.BackgroundTransparency = 1

        local lbl = Instance.new("TextLabel", f)
        lbl.Size = UDim2.new(1, 0, 0, 22)
        lbl.BackgroundTransparency = 1
        lbl.Text = label .. ": " .. tostring(default)
        lbl.TextColor3 = Color3.fromRGB(40, 40, 60)
        lbl.TextSize = 16
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local track = Instance.new("Frame", f)
        track.Size = UDim2.new(0.9, 0, 0, 12)
        track.Position = UDim2.new(0.05, 0, 0.45, 0)
        track.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
        local tc = Instance.new("UICorner", track)
        tc.CornerRadius = UDim.new(0, 6)

        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(80, 150, 220)
        local fc = Instance.new("UICorner", fill)
        fc.CornerRadius = UDim.new(0, 6)

        local val = default
        local function update(x)
            local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            val = min + (max - min) * rel
            fill.Size = UDim2.new(rel, 0, 1, 0)
            lbl.Text = label .. ": " .. string.format("%.1f", val)
            callback(val)
        end
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch then update(i.Position.X) end
        end)
        track.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch and i.Position then update(i.Position.X) end
        end)
        return track
    end

    local function addDropdown(parent, label, options, default, callback, y)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, 50)
        f.Position = UDim2.new(0, 0, 0, y)
        f.BackgroundTransparency = 1

        local lbl = Instance.new("TextLabel", f)
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(40, 40, 60)
        lbl.TextSize = 16
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(0.4, 0, 0.8, 0)
        btn.Position = UDim2.new(0.55, 0, 0.1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
        btn.Text = default
        btn.TextColor3 = Color3.fromRGB(40, 40, 60)
        btn.TextScaled = true
        btn.BorderSizePixel = 0
        local bc = Instance.new("UICorner", btn)
        bc.CornerRadius = UDim.new(0, 6)

        local list = Instance.new("Frame", f)
        list.Size = UDim2.new(0.4, 0, 0, 0)
        list.Position = UDim2.new(0.55, 0, 0.9, 0)
        list.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
        list.BackgroundTransparency = 0.1
        list.BorderSizePixel = 1
        list.BorderColor3 = Color3.fromRGB(180, 180, 200)
        list.Visible = false
        local lc = Instance.new("UICorner", list)
        lc.CornerRadius = UDim.new(0, 6)
        local layout = Instance.new("UIListLayout", list)

        local current = default
        local function select(opt)
            current = opt
            btn.Text = opt
            callback(opt)
            list.Visible = false
            list.Size = UDim2.new(0.4, 0, 0, 0)
        end

        for _, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton", list)
            optBtn.Size = UDim2.new(1, 0, 0, 30)
            optBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
            optBtn.BackgroundTransparency = 0.2
            optBtn.Text = opt
            optBtn.TextColor3 = Color3.fromRGB(40, 40, 60)
            optBtn.TextSize = 14
            optBtn.BorderSizePixel = 0
            optBtn.Activated:Connect(function() select(opt) end)
        end

        btn.Activated:Connect(function()
            list.Visible = not list.Visible
            list.Size = list.Visible and UDim2.new(0.4, 0, 0, #options * 32 + 10) or UDim2.new(0.4, 0, 0, 0)
        end)
        return btn
    end

    -- === ЗАПОЛНЕНИЕ ВКЛАДОК ===

    -- Aimbot (заглушки, только сохранение)
    local y = 0
    addSlider(tabAimbot, "Smooth", 0, 1, 0.3, function(v) Settings.Smooth = v end, y); y = y + 60
    addSlider(tabAimbot, "Aim FOV", 30, 180, 120, function(v) Settings.AimFOV = v end, y); y = y + 60
    addSlider(tabAimbot, "Spin Speed", 0, 20, 5, function(v) Settings.SpinSpeed = v end, y); y = y + 60
    addSwitch(tabAimbot, "Aimbot", false, function(v) Settings.Aimbot = v end, y); y = y + 45
    addSwitch(tabAimbot, "AutoShoot", false, function(v) Settings.AutoShoot = v end, y); y = y + 45
    addSwitch(tabAimbot, "Bunnyhop", false, function(v) Settings.Bunnyhop = v end, y); y = y + 45
    addSwitch(tabAimbot, "Spin", false, function(v) Settings.Spin = v end, y); y = y + 45
    tabAimbot.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    -- Visuals (ESP работает, растяг – отдельный слайдер)
    y = 0
    addSwitch(tabVisuals, "ESP (Wallhack)", false, function(v) Settings.ESP = v end, y); y = y + 45
    addSlider(tabVisuals, "Растяг", 60, 180, 70, function(v)
        Settings.ScreenStretch = v
        applyStretch()
    end, y); y = y + 60
    addSwitch(tabVisuals, "Skybox", false, function(v) Settings.Skybox = v end, y); y = y + 45
    addDropdown(tabVisuals, "Skybox Type", {"Обычное","Чёрное","Зелёное","Реалистичное","Сакура"}, "Обычное", function(v)
        Settings.SkyboxType = v
    end, y); y = y + 55
    addSwitch(tabVisuals, "Ring", false, function(v) Settings.Ring = v end, y); y = y + 45
    addSlider(tabVisuals, "Ring Size", 1, 5, 3, function(v) Settings.RingSize = v end, y); y = y + 60
    addDropdown(tabVisuals, "Crosshair", {"Крестик", "Сердечко", "Точка", "Круг"}, "Крестик", function(v)
        Settings.Crosshair = v
        updateCrosshair()
    end, y); y = y + 55
    tabVisuals.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    -- Misc (заглушки)
    y = 0
    addSwitch(tabMisc, "Fast Walk", false, function(v) Settings.FastWalk = v end, y); y = y + 45
    addSwitch(tabMisc, "Fly", false, function(v) Settings.Fly = v end, y); y = y + 45
    tabMisc.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    -- Button (переключатели кнопок)
    y = 0
    addSwitch(tabButton, "Speed Button", false, function(v) Settings.ButtonSpeed = v; updateButtons() end, y); y = y + 45
    addSwitch(tabButton, "Wall Button", false, function(v) Settings.ButtonWall = v; updateButtons() end, y); y = y + 45
    addSwitch(tabButton, "Hop Button", false, function(v) Settings.ButtonHop = v; updateButtons() end, y); y = y + 45
    addSwitch(tabButton, "Throw Button", false, function(v) Settings.ButtonThrow = v; updateButtons() end, y); y = y + 45
    addSwitch(tabButton, "Dress Button", false, function(v) Settings.ButtonDress = v; updateButtons() end, y); y = y + 45
    addSwitch(tabButton, "Ghost Button", false, function(v) Settings.ButtonGhost = v; updateButtons() end, y); y = y + 45
    tabButton.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    -- Информация
    local info = Instance.new("TextLabel", main)
    info.Size = UDim2.new(1, 0, 0, 22)
    info.Position = UDim2.new(0, 0, 1, -22)
    info.BackgroundTransparency = 1
    info.Text = "owner - tgk: @sendayfin"
    info.TextColor3 = Color3.fromRGB(100, 100, 120)
    info.TextScaled = true

    updateCrosshair()
end

createMenu()
applyStretch()  -- применяем начальный растяг
print("✅ Скрипт загружен. Растяг работает.")