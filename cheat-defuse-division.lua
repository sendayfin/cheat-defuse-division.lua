-- МОБИЛЬНЫЙ AIMBOT С КРУГОМ ПРИЦЕЛА
-- ОДНА КНОПКА ВКЛ/ВЫКЛ, ЦЕЛИТСЯ ЧЕРЕЗ СТЕНЫ

local aimEnabled = true
local showingCircle = true
local targetPart = "Head" -- Целимся в голову

-- Сервисы
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Создаем круг прицела
local circle = Instance.new("Frame")
circle.Size = UDim2.new(0, 60, 0, 60)
circle.Position = UDim2.new(0.5, -30, 0.5, -30)
circle.BackgroundTransparency = 1
circle.BorderSizePixel = 0

local outline = Instance.new("UICorner")
outline.CornerRadius = UDim.new(1, 0)
outline.Parent = circle

local innerCircle = Instance.new("Frame")
innerCircle.Size = UDim2.new(0, 50, 0, 50)
innerCircle.Position = UDim2.new(0.5, -25, 0.5, -25)
innerCircle.BackgroundTransparency = 0.7
innerCircle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
innerCircle.BorderSizePixel = 0

local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(1, 0)
innerCorner.Parent = innerCircle

-- Экранный интерфейс
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

circle.Parent = screenGui
innerCircle.Parent = circle

-- Кнопка вкл/выкл аимбота
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 120, 0, 50)
toggleButton.Position = UDim2.new(1, -130, 1, -60)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "AIM: ON"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 18
toggleButton.Parent = screenGui

-- Функция поиска ближайшего врага
local function findClosestEnemy()
    local closest = nil
    local closestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                -- Не целиться в свою команду
                if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then
                    continue
                end
                
                local distance = (Camera.CFrame.Position - head.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closest = player
                end
            end
        end
    end
    
    return closest
end

-- Функция аимбота
local function aimAtTarget()
    if not aimEnabled then return end
    if not LocalPlayer.Character then return end
    
    local enemy = findClosestEnemy()
    if not enemy or not enemy.Character then return end
    
    local target = enemy.Character:FindFirstChild(targetPart)
    if not target then
        target = enemy.Character:FindFirstChild("HumanoidRootPart")
    end
    if not target then return end
    
    -- Меняем цвет круга при наведении
    innerCircle.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    
    -- Прицеливаемся на цель
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
    
    return enemy
end

-- Основной цикл
RunService.RenderStepped:Connect(function()
    if aimEnabled then
        local target = aimAtTarget()
        if not target then
            innerCircle.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Красный если нет цели
        end
    else
        innerCircle.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Серый если выключен
    end
end)

-- Переключение аимбота
toggleButton.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    
    if aimEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        toggleButton.Text = "AIM: ON"
        innerCircle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        toggleButton.Text = "AIM: OFF"
        innerCircle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end)

-- Кнопка для скрытия/показа круга
local circleButton = Instance.new("TextButton")
circleButton.Size = UDim2.new(0, 120, 0, 50)
circleButton.Position = UDim2.new(1, -130, 1, -120)
circleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
circleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
circleButton.Text = "CIRCLE: ON"
circleButton.Font = Enum.Font.SourceSansBold
circleButton.TextSize = 16
circleButton.Parent = screenGui

circleButton.MouseButton1Click:Connect(function()
    showingCircle = not showingCircle
    circle.Visible = showingCircle
    
    if showingCircle then
        circleButton.Text = "CIRCLE: ON"
        circleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    else
        circleButton.Text = "CIRCLE: OFF"
        circleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end
end)

-- Информационная панель
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 200, 0, 30)
infoLabel.Position = UDim2.new(0.5, -100, 0, 10)
infoLabel.BackgroundTransparency = 0.7
infoLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
infoLabel.Text = "SWILL AIMBOT LOADED"
infoLabel.TextSize = 16
infoLabel.Parent = screenGui

-- Авто-обновление информации
spawn(function()
    while true do
        wait(2)
        if aimEnabled then
            local enemy = findClosestEnemy()
            if enemy then
                infoLabel.Text = "TARGET: " .. enemy.Name
            else
                infoLabel.Text = "NO TARGETS"
            end
        else
            infoLabel.Text = "AIMBOT OFF"
        end
    end
end)

-- Удаление скрипта
local unloadButton = Instance.new("TextButton")
unloadButton.Size = UDim2.new(0, 120, 0, 50)
unloadButton.Position = UDim2.new(0, 10, 1, -60)
unloadButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
unloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadButton.Text = "UNLOAD"
unloadButton.Font = Enum.Font.SourceSansBold
unloadButton.TextSize = 18
unloadButton.Parent = screenGui

unloadButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    print("Aimbot выключен")
end)

print("====================================")
print("SWILL MOBILE AIMBOT АКТИВИРОВАН")
print("Управление:")
print("1. Зеленая кнопка - AIM ON/OFF")
print("2. Синяя кнопка - круг прицела")
print("3. Красная кнопка - удалить скрипт")
print("====================================")
