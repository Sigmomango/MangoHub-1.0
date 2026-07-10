--[[
    🥭 MANGOHUB V1 by Sigmomango
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

-- ФУНКЦИИ
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

local function setSpeed(mult)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 * mult end
end

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

local function toggleNoclip()
    isNoclip = not isNoclip
    local c = player.Character or player.CharacterAdded:Wait()
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = not isNoclip end
    end
end

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

local function teleportTo(target)
    if target and target.Character and target.Character.HumanoidRootPart then
        char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    end
end

-- ============================================
-- GUI
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MangoHub"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 500)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 150, 0)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

mainFrame:TweenPosition(UDim2.new(0.5, -190, 0.4, -250), "Out", "Back", 0.5, true)

local title = Instance.new("Frame")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
title.BorderSizePixel = 0
title.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -50, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🥭 MANGOHUB V1 by Sigmomango"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextScaled = true
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = title

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = title
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

local function createButton(text, callback, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 38)
    btn.Position = UDim2.new(0.075, 0, yPos, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(255, 150, 0)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = mainFrame
    
    btn.MouseEnter:Connect(function()
        btn:TweenSize(UDim2.new(0.9, 0, 0, 42), "Out", "Sine", 0.15, true)
        btn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)
    btn.MouseLeave:Connect(function()
        btn:TweenSize(UDim2.new(0.85, 0, 0, 38), "Out", "Sine", 0.15, true)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createButton("👻 Невидимость", toggleInvis, 0.12)
createButton("💨 Спидхак x2", function() setSpeed(2) end, 0.21)
createButton("💨 Спидхак x5", function() setSpeed(5) end, 0.30)
createButton("✈️ Полет", toggleFly, 0.39)
createButton("🧱 Ноклип", toggleNoclip, 0.48)
createButton("👁️ ESP", toggleESP, 0.57)
createButton("🎯 Aimbot", toggleAimbot, 0.66)

local teleFrame = Instance.new("Frame")
teleFrame.Size = UDim2.new(0.85, 0, 0, 70)
teleFrame.Position = UDim2.new(0.075, 0, 0.76, 0)
teleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
teleFrame.BackgroundTransparency = 0.3
teleFrame.BorderSizePixel = 1
teleFrame.BorderColor3 = Color3.fromRGB(255, 150, 0)
teleFrame.Parent = mainFrame

local teleLabel = Instance.new("TextLabel")
teleLabel.Size = UDim2.new(1, 0, 0, 20)
teleLabel.Position = UDim2.new(0, 0, 0, 5)
teleLabel.BackgroundTransparency = 1
teleLabel.Text = "🎯 Телепорт к игроку"
teleLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
teleLabel.TextScaled = true
teleLabel.Font = Enum.Font.Gotham
teleLabel.Parent = teleFrame

local teleInput = Instance.new("TextBox")
teleInput.Size = UDim2.new(0.6, 0, 0, 28)
teleInput.Position = UDim2.new(0, 0, 0, 30)
teleInput.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
teleInput.BackgroundTransparency = 0.5
teleInput.Text = "Ник"
teleInput.TextColor3 = Color3.fromRGB(200, 200, 200)
teleInput.TextScaled = true
teleInput.Font = Enum.Font.Gotham
teleInput.BorderSizePixel = 1
teleInput.BorderColor3 = Color3.fromRGB(255, 150, 0)
teleInput.Parent = teleFrame

local teleBtn = Instance.new("TextButton")
teleBtn.Size = UDim2.new(0.25, 0, 0, 28)
teleBtn.Position = UDim2.new(0.68, 0, 0, 30)
teleBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
teleBtn.Text = "🚀"
teleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleBtn.TextScaled = true
teleBtn.Font = Enum.Font.GothamBold
teleBtn.BorderSizePixel = 0
teleBtn.Parent = teleFrame
teleBtn.MouseButton1Click:Connect(function()
    local target = game.Players:FindFirstChild(teleInput.Text)
    if target then
        teleportTo(target)
        teleInput.Text = "✅"
    else
        teleInput.Text = "❌"
    end
    wait(1)
    teleInput.Text = "Ник"
end)

local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0.85, 0, 0, 28)
statusFrame.Position = UDim2.new(0.075, 0, 0.91, 0)
statusFrame.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
statusFrame.BackgroundTransparency = 0.2
statusFrame.BorderSizePixel = 1
statusFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
statusFrame.Parent = mainFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 1, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "✅ Статус: Подключен  |  Версия: 1.0.0"
statusText.TextColor3 = Color3.fromRGB(0, 255, 100)
statusText.TextScaled = true
statusText.Font = Enum.Font.Gotham
statusText.Parent = statusFrame

game:GetService("UserInputService").InputBegan:Connect(function(input, isTyping)
    if not isTyping and input.KeyCode == Enum.KeyCode.F1 then
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then
            mainFrame:TweenPosition(UDim2.new(0.5, -190, 0.5, -250), "Out", "Back", 0.5, true)
        end
    end
end)

print("🥭 MANGOHUB V1 by Sigmomango загружен! Нажми F1")
print("✅ Статус: Подключен | Версия: 1.0.0")
