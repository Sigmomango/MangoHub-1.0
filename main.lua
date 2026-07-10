--[[
    🥭 MANGOHUB V1 by xenvix
    Функции: Невидимость | Спидхак | Полет | Ноклип | ESP | Aimbot | Телепорт
    Открыть меню: F1
]]

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera

local isInvis = false
local isFly = false
local isNoclip = false
local isESP = false
local isAimbot = false
local flySpeed = 50
local espList = {}
local aimbotSmoothness = 0.3

-- НЕВИДИМОСТЬ
local function toggleInvis()
    isInvis = not isInvis
    local c = player.Character or player.CharacterAdded:Wait()
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = isInvis and 1 or 0
            v.CanCollide = not isInvis
        end
    end
    for _, acc in pairs(c:GetChildren()) do
        if acc:IsA("Accessory") then
            for _, part in pairs(acc:GetDescendants()) do
                if part:IsA("BasePart") then part.Transparency = isInvis and 1 or 0 end
            end
        end
    end
end

-- СПИДХАК
local function setSpeed(mult)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 * mult end
end

-- ПОЛЕТ
local flyEnabled = false
local bf = nil
local function toggleFly()
    flyEnabled = not flyEnabled
    local hum = char:FindFirstChildOfClass("Humanoid")
    if flyEnabled then
        bf = Instance.new("BodyVelocity")
        bf.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bf.Velocity = Vector3.new(0, 0, 0)
        bf.Parent = char.HumanoidRootPart
        hum.PlatformStand = true
    else
        if bf then bf:Destroy() end
        hum.PlatformStand = false
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    if flyEnabled and char and char.HumanoidRootPart and bf then
        local move = Vector3.new(0, 0, 0)
        local uis = game:GetService("UserInputService")
        if uis:IsKeyDown(Enum.KeyCode.W) then move = move + char.HumanoidRootPart.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then move = move - char.HumanoidRootPart.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then move = move - char.HumanoidRootPart.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then move = move + char.HumanoidRootPart.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        if move.Magnitude > 0 then bf.Velocity = move.Unit * flySpeed else bf.Velocity = Vector3.new(0, 0, 0) end
    end
end)

-- НОКЛИП
local function toggleNoclip()
    isNoclip = not isNoclip
    local c = player.Character or player.CharacterAdded:Wait()
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = not isNoclip end
    end
end

-- ESP
local function toggleESP()
    isESP = not isESP
    if isESP then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player then createESP(p) end
        end
        game.Players.PlayerAdded:Connect(function(p)
            if isESP and p ~= player then createESP(p) end
        end)
    else
        for _, v in pairs(espList) do
            if v and v.Parent then v:Destroy() end
        end
        espList = {}
    end
end

function createESP(p)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP"
    highlight.Adornee = p.Character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = p.Character or p.CharacterAdded:Wait()
    table.insert(espList, highlight)
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameESP"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Adornee = p.Character and p.Character.HumanoidRootPart
    billboard.Parent = p.Character or p.CharacterAdded:Wait()
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = p.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard
    table.insert(espList, billboard)
end

-- AIMBOT
local function getClosestPlayer()
    local closest = nil
    local shortestDist = math.huge
    local center = camera.CFrame.Position
    
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character.HumanoidRootPart then
            local targetPos = p.Character.HumanoidRootPart.Position
            local dist = (targetPos - center).Magnitude
            if dist < shortestDist and dist < 300 then
                local dir = (targetPos - center).Unit
                local look = camera.CFrame.LookVector
                if dir:Dot(look) > 0 then
                    closest = p
                    shortestDist = dist
                end
            end
        end
    end
    return closest
end

local function aimbot()
    if not isAimbot then return end
    local target = getClosestPlayer()
    if target and target.Character and target.Character.HumanoidRootPart then
        local targetPos = target.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
        local currentCF = camera.CFrame
        local newCF = CFrame.new(currentCF.Position, targetPos)
        camera.CFrame = currentCF:Lerp(newCF, aimbotSmoothness)
    end
end

local function toggleAimbot()
    isAimbot = not isAimbot
    print(isAimbot and "🎯 Aimbot ON" or "🎯 Aimbot OFF")
end

game:GetService("RunService").RenderStepped:Connect(function()
    if isAimbot then aimbot() end
end)

-- ТЕЛЕПОРТ
local function teleportTo(target)
    if target and target.Character and target.Character.HumanoidRootPart then
        char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    end
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MangoHub"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 520)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
title.Text = "🥭 MANGOHUB V1 by xenvix"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local function createButton(text, callback, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 38)
    btn.Position = UDim2.new(0.1, 0, yPos, 0)
    btn.BackgroundColor3 = color or Color3.fromRGB(50, 50, 80)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = mainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local buttons = {
    {"👻 Невидимость", toggleInvis, 0.08, Color3.fromRGB(60, 40, 120)},
    {"💨 Спидхак x2", function() setSpeed(2) end, 0.17, Color3.fromRGB(40, 80, 140)},
    {"💨 Спидхак x5", function() setSpeed(5) end, 0.26, Color3.fromRGB(40, 80, 140)},
    {"✈️ Полет", toggleFly, 0.35, Color3.fromRGB(30, 100, 100)},
    {"🧱 Ноклип", toggleNoclip, 0.44, Color3.fromRGB(100, 80, 40)},
    {"👁️ ESP", toggleESP, 0.53, Color3.fromRGB(120, 40, 40)},
    {"🎯 Aimbot", toggleAimbot, 0.62, Color3.fromRGB(150, 30, 30)},
}

for _, btnData in ipairs(buttons) do
    createButton(btnData[1], btnData[2], btnData[3], btnData[4])
end

-- Телепорт
local teleLabel = Instance.new("TextLabel")
teleLabel.Size = UDim2.new(0.8, 0, 0, 20)
teleLabel.Position = UDim2.new(0.1, 0, 0.73, 0)
teleLabel.BackgroundTransparency = 1
teleLabel.Text = "🎯 Телепорт к игроку"
teleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
teleLabel.TextScaled = true
teleLabel.Font = Enum.Font.Gotham
teleLabel.Parent = mainFrame

local teleInput = Instance.new("TextBox")
teleInput.Size = UDim2.new(0.6, 0, 0, 30)
teleInput.Position = UDim2.new(0.2, 0, 0.8, 0)
teleInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
teleInput.Text = "Ник игрока"
teleInput.TextColor3 = Color3.fromRGB(200, 200, 200)
teleInput.TextScaled = true
teleInput.Font = Enum.Font.Gotham
teleInput.Parent = mainFrame

local teleBtn = Instance.new("TextButton")
teleBtn.Size = UDim2.new(0.6, 0, 0, 30)
teleBtn.Position = UDim2.new(0.2, 0, 0.88, 0)
teleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
teleBtn.Text = "🚀 ТЕЛЕПОРТ"
teleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleBtn.TextScaled = true
teleBtn.Font = Enum.Font.GothamBold
teleBtn.Parent = mainFrame

teleBtn.MouseButton1Click:Connect(function()
    local target = game.Players:FindFirstChild(teleInput.Text)
    if target then
        teleportTo(target)
        teleInput.Text = "✅ Телепорт!"
    else
        teleInput.Text = "❌ Игрок не найден"
    end
    wait(1)
    teleInput.Text = "Ник игрока"
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(0.9, 0, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, isTyping)
    if not isTyping and input.KeyCode == Enum.KeyCode.F1 then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

print("🥭 MANGOHUB V1 загружен! Нажми F1")
