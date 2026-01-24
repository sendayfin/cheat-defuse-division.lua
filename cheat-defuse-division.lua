-- ================================================
-- МОБИЛЬНЫЙ AIMBOT ДЛЯ DEFUSE DIVISION
-- SWILL MOBILE AIM ASSIST
-- ================================================

-- Настройки
local aimbotEnabled = true
local aimKey = "Enum.KeyCode.ButtonR2" -- Кнопка для прицеливания (R2 на геймпаде)
local aimAtHead = true
local smoothAim = true
local smoothness = 0.3 -- Плавность (0.1 - резко, 0.9 - плавно)
local maxDistance = 500 -- Максимальная дистанция
local showStatus = true -- Показывать статус

-- Сервисы
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

-- Локальные переменные
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local connection = nil

-- Интерфейс
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 200, 0, 40)
statusLabel.Position = UDim2.new(0.5, -100, 0, 10)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Text = "Aimbot: ВКЛ"
statusLabel.Visible = showStatus
statusLabel.Parent = screenGui

-- Функция для переключения аимбота
local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        statusLabel.Text = "Aimbot: ВКЛ"
        statusLabel.BackgroundColor3 = Color3.fromRGB(40, 255, 40)
    else
        statusLabel.Text = "Aimbot: ВЫКЛ"
        statusLabel.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
    end
end

-- Кнопка для выключения/включения
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 150, 0, 50)
toggleButton.Position = UDim2.new(0.5, -75, 1, -60)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "ВКЛ/ВЫКЛ AIM"
toggleButton.Parent = screenGui

toggleButton.MouseButton1Click:Connect(toggleAimbot)

-- Функция поиска ближайшего врага
local function findClosestEnemy()
    local closest = nil
    local shortestDistance = maxDistance
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                -- Проверка команды (не целиться в своих)
                if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then
                    continue
                end
                
                -- Проверка расстояния
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = player
                end
            end
        end
    end
    
    return closest
end

-- Основная функция аимбота
local function aimAtTarget()
    if not aimbotEnabled then return end
    if not LocalPlayer.Character then return end
    if not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local enemy = findClosestEnemy()
    if not enemy or not enemy.Character then return end
    
    local targetPart = enemy.Character:FindFirstChild("Head")
    if not targetPart then
        targetPart = enemy.Character:FindFirstChild("HumanoidRootPart")
    end
    if not targetPart then return end
    
    -- Наведение на голову
    local camera = Workspace.CurrentCamera
    local targetPosition = targetPart.Position
    
    if smoothAim then
        -- Плавное наведение
        local currentCFrame = camera.CFrame
        local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPosition)
        camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothness)
    else
        -- Резкое наведение
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPosition)
    end
end

-- Управление через кнопки на экране
local aimButton = Instance.new("TextButton")
aimButton.Size = UDim2.new(0, 100, 0, 100)
aimButton.Position = UDim2.new(1, -120, 1, -120)
aimButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
aimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
aimButton.Text = "AIM"
aimButton.Parent = screenGui

local aiming = false

aimButton.MouseButton1Down:Connect(function()
    aiming = true
    aimButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
end)

aimButton.MouseButton1Up:Connect(function()
    aiming = false
    aimButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
end)

-- Основной цикл
connection = RunService.RenderStepped:Connect(function()
    if aiming and aimbotEnabled then
        aimAtTarget()
    end
end)

-- Управление через свайпы (дополнительно)
local touchStartPosition = nil
local touchInput = nil

UserInputService.TouchStarted:Connect(function(input)
    touchStartPosition = input.Position
    touchInput = input
end)

UserInputService.TouchEnded:Connect(function(input)
    if touchInput == input then
        -- Быстрый свайп вверх включает/выключает
        if touchStartPosition and (touchStartPosition.Y - input.Position.Y) > 100 then
            toggleAimbot()
        end
        touchStartPosition = nil
        touchInput = nil
    end
end)

-- Горячие клавиши (для подключенной клавиатуры)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F1 then
        toggleAimbot()
    elseif input.KeyCode == Enum.KeyCode.F2 then
        smoothAim = not smoothAim
        statusLabel.Text = "Smooth: " .. (smoothAim and "ВКЛ" or "ВЫКЛ")
    end
end)

-- Авто-прицеливание при стрельбе (опционально)
local function autoAimWhenShooting()
    local weapon = nil
    
    -- Ищем оружие в руках
    if LocalPlayer.Character then
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("gun") or tool.Name:lower():find("rifle") then
                weapon = tool
                break
            end
        end
    end
    
    if weapon then
        -- При активации оружия включаем авто-аим
        weapon.Activated:Connect(function()
            if aimbotEnabled then
                aimAtTarget()
            end
        end)
    end
end

-- Запускаем авто-прицеливание
spawn(autoAimWhenShooting)

-- Сообщение об успешной загрузке
print("========================================")
print("SWILL MOBILE AIMBOT ЗАГРУЖЕН")
print("Управление:")
print("1. Кнопка AIM - прицеливание")
print("2. Кнопка ВКЛ/ВЫКЛ - переключение")
print("3. Свайп вверх - быстрое переключение")
print("4. F1 - вкл/выкл")
print("5. F2 - плавность")
print("========================================")

-- Функция для выключения скрипта
local function unloadScript()
    if connection then
        connection:Disconnect()
    end
    screenGui:Destroy()
    print("Aimbot выключен")
end

-- Кнопка для выключения всего скрипта
local unloadButton = Instance.new("TextButton")
unloadButton.Size = UDim2.new(0, 150, 0, 50)
unloadButton.Position = UDim2.new(0, 10, 1, -60)
unloadButton.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
unloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadButton.Text = "ВЫКЛЮЧИТЬ СКРИПТ"
unloadButton.Parent = screenGui

unloadButton.MouseButton1Click:Connect(unloadScript)

-- Автоматическое обновление прицела
while true do
    wait(0.5)
    if aimbotEnabled and showStatus then
        local enemy = findClosestEnemy()
        if enemy then
            statusLabel.Text = "Цель: " .. enemy.Name
        else
            statusLabel.Text = "Aimbot: ВКЛ (нет целей)"
        end
    end
end
