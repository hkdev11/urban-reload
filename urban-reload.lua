-- Urban Reload | ESP + Silent Aim + No Recoil + Auto Farm + HUD Toggle
-- Xeno Executor Ready | HUD Toggle: H (modifiable)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- =============================================
-- CONFIG
-- =============================================
local CONFIG = {
    ESP_Enabled = true,
    ESP_Distance = 1000,
    ESP_BoxColor = Color3.fromRGB(255, 50, 50),
    ESP_NameColor = Color3.fromRGB(255, 255, 255),
    ESP_HealthColor = Color3.fromRGB(50, 255, 50),
    ESP_TracerColor = Color3.fromRGB(255, 50, 50),
    ESP_Tracers = true,
    ESP_Boxes = true,
    ESP_Names = true,
    ESP_Health = true,

    SilentAim_Enabled = true,
    SilentAim_FOV = 250,
    SilentAim_TargetPart = "Head",
    SilentAim_TeamCheck = true,

    NoRecoil_Enabled = false,

    AutoFarm_Enabled = false,
    AutoFarm_Delay = 0.1,

    Keys = {
        ESP       = Enum.KeyCode.E,
        SilentAim = Enum.KeyCode.T,
        NoRecoil  = Enum.KeyCode.N,
        AutoFarm  = Enum.KeyCode.F,
        HUD       = Enum.KeyCode.H,
    }
}

-- =============================================
-- UI / HUD
-- =============================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "UrbanReloadCheats"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local HUDFrame = Instance.new("Frame")
HUDFrame.Name = "HUD"
HUDFrame.Size = UDim2.new(0, 200, 0, 145)
HUDFrame.Position = UDim2.new(0, 10, 0, 10)
HUDFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
HUDFrame.BackgroundTransparency = 0.2
HUDFrame.BorderSizePixel = 0
HUDFrame.Parent = Gui
Instance.new("UICorner", HUDFrame).CornerRadius = UDim.new(0, 8)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 24)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = HUDFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🎯 Urban Reload | [H] Hide"
TitleLabel.Parent = TitleBar

local function makeRow(text, yPos, color)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 24)
    row.Position = UDim2.new(0, 8, 0, yPos)
    row.BackgroundTransparency = 1
    row.Parent = HUDFrame

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0, 0, 0.5, -4)
    dot.BackgroundColor3 = color or Color3.fromRGB(80, 255, 80)
    dot.BorderSizePixel = 0
    dot.Parent = row
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = row

    return dot, lbl
end

local dotESP, lblESP = makeRow("ESP [E]: ON",        30)
local dotSA,  lblSA  = makeRow("SilentAim [T]: ON",  58)
local dotNR,  lblNR  = makeRow("NoRecoil [N]: ON",   86)
local dotAF,  lblAF  = makeRow("AutoFarm [F]: OFF",  114, Color3.fromRGB(255, 70, 70))

local HintLabel = Instance.new("TextLabel")
HintLabel.Size = UDim2.new(0, 200, 0, 18)
HintLabel.Position = UDim2.new(0, 10, 0, 158)
HintLabel.BackgroundTransparency = 1
HintLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
HintLabel.TextScaled = true
HintLabel.Font = Enum.Font.Gotham
HintLabel.Text = "Appuie sur [H] pour cacher le HUD"
HintLabel.Parent = Gui

-- Separate screen coordinates keep the circle aligned with GetMouseLocation.
local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "UrbanReloadFOV"
FOVGui.IgnoreGuiInset = true
FOVGui.ResetOnSpawn = false
FOVGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Size = UDim2.fromOffset(CONFIG.SilentAim_FOV * 2, CONFIG.SilentAim_FOV * 2)
FOVCircle.Parent = FOVGui
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(0.5, 0)
local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Thickness = 1
FOVStroke.Parent = FOVCircle
RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera
    local mouse = UserInputService:GetMouseLocation()
    FOVCircle.Position = UDim2.fromOffset(mouse.X, mouse.Y)
    FOVCircle.Visible = CONFIG.SilentAim_Enabled
end)

local HUDVisible = true

local function updateUI()
    local function col(b) return b and Color3.fromRGB(80,255,80) or Color3.fromRGB(255,70,70) end
    local function st(b) return b and "ON" or "OFF" end

    dotESP.BackgroundColor3 = col(CONFIG.ESP_Enabled)
    lblESP.Text = "ESP [E]: "..st(CONFIG.ESP_Enabled)

    dotSA.BackgroundColor3 = col(CONFIG.SilentAim_Enabled)
    lblSA.Text = "SilentAim [T]: "..st(CONFIG.SilentAim_Enabled)

    dotNR.BackgroundColor3 = col(CONFIG.NoRecoil_Enabled)
    lblNR.Text = "NoRecoil [N]: "..st(CONFIG.NoRecoil_Enabled)

    dotAF.BackgroundColor3 = col(CONFIG.AutoFarm_Enabled)
    lblAF.Text = "AutoFarm [F]: "..st(CONFIG.AutoFarm_Enabled)
end

local function toggleHUD()
    HUDVisible = not HUDVisible
    HUDFrame.Visible = HUDVisible
    HintLabel.Text = HUDVisible
        and "Appuie sur [H] pour cacher le HUD"
        or  "Appuie sur [H] pour afficher le HUD"
end

-- =============================================
-- ESP
-- =============================================
local ESPObjects = {}

local function removeESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj and obj.Parent then obj:Remove() end
        end
        ESPObjects[player] = nil
    end
end

local function createESP(player)
    if player == LocalPlayer then return end
    removeESP(player)
    local objects = {}

    if CONFIG.ESP_Boxes then
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(4, 6, 4)
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Color3 = CONFIG.ESP_BoxColor
        box.Transparency = 0.5
        objects.Box = box
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = CONFIG.ESP_Distance

    if CONFIG.ESP_Names then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = CONFIG.ESP_NameColor
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Text = player.Name
        nameLabel.Parent = billboard
        objects.NameLabel = nameLabel
    end

    if CONFIG.ESP_Health then
        local hpLabel = Instance.new("TextLabel")
        hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
        hpLabel.Position = UDim2.new(0, 0, 0.5, 0)
        hpLabel.BackgroundTransparency = 1
        hpLabel.TextColor3 = CONFIG.ESP_HealthColor
        hpLabel.TextScaled = true
        hpLabel.Font = Enum.Font.Gotham
        hpLabel.Text = "HP: ?"
        hpLabel.Parent = billboard
        objects.HPLabel = hpLabel
    end

    objects.Billboard = billboard

    if CONFIG.ESP_Tracers then
        local line = Instance.new("LineHandleAdornment")
        line.Length = 0
        line.AlwaysOnTop = true
        line.ZIndex = 5
        line.Color3 = CONFIG.ESP_TracerColor
        line.Thickness = 1.5
        objects.Tracer = line
    end

    ESPObjects[player] = objects
end

local function updateESP()
    if not CONFIG.ESP_Enabled then
        for player, _ in pairs(ESPObjects) do removeESP(player) end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local root  = char:FindFirstChild("HumanoidRootPart")
                local human = char:FindFirstChildOfClass("Humanoid")

                if root and human then
                    if not ESPObjects[player] then createESP(player) end
                    local objs = ESPObjects[player]
                    if not objs then continue end

                    local dist = (RootPart.Position - root.Position).Magnitude
                    if dist > CONFIG.ESP_Distance then removeESP(player) continue end

                    if objs.Box then
                        objs.Box.Adornee = root
                        objs.Box.Parent  = root
                    end
                    if objs.Billboard then
                        objs.Billboard.Adornee = root
                        objs.Billboard.Parent  = root
                    end
                    if objs.HPLabel then
                        local ratio = human.Health / human.MaxHealth
                        objs.HPLabel.Text = "HP: "..math.floor(human.Health).."/"..math.floor(human.MaxHealth)
                        objs.HPLabel.TextColor3 = Color3.fromRGB(
                            math.floor(255*(1-ratio)),
                            math.floor(255*ratio), 0)
                    end
                    if objs.Tracer then
                        objs.Tracer.Adornee = root
                        objs.Tracer.Parent  = root
                    end
                else
                    removeESP(player)
                end
            else
                removeESP(player)
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

-- =============================================
-- SILENT AIM
-- =============================================
local function getClosestToMouse()
    local mousePos   = UserInputService:GetMouseLocation()
    local closest    = nil
    local closestDst = CONFIG.SilentAim_FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if CONFIG.SilentAim_TeamCheck and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team then continue end
        local char = player.Character
        if not char then continue end
        local part  = char:FindFirstChild(CONFIG.SilentAim_TargetPart) or char:FindFirstChild("HumanoidRootPart")
        local human = char:FindFirstChildOfClass("Humanoid")
        if part and human and human.Health > 0 then
            local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local d = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                if d < closestDst then closestDst = d; closest = part end
            end
        end
    end
    return closest
end

local isShooting = false
UserInputService.InputBegan:Connect(function(i, gp)
    if not gp and i.UserInputType == Enum.UserInputType.MouseButton1 then isShooting = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then isShooting = false end
end)

RunService.RenderStepped:Connect(function()
    if CONFIG.SilentAim_Enabled and isShooting then
        local t = getClosestToMouse()
        if t then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, t.Position) end
    end
end)

-- =============================================
-- NO RECOIL
-- =============================================
RunService.RenderStepped:Connect(function()
    if CONFIG.NoRecoil_Enabled then
        local cf = Camera.CFrame
        local x, y, z = cf:ToEulerAnglesXYZ()
        Camera.CFrame = cf:Lerp(
            CFrame.new(cf.Position) * CFrame.Angles(x * 0.85, y, z), 0.3)
    end
end)

-- =============================================
-- AUTO FARM
-- =============================================
local function getClosestEnemy()
    local closest, closestDst = nil, 500
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if CONFIG.SilentAim_TeamCheck and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team then continue end
        local char = player.Character
        if not char then continue end
        local root  = char:FindFirstChild("HumanoidRootPart")
        local human = char:FindFirstChildOfClass("Humanoid")
        if root and human and human.Health > 0 then
            local d = (RootPart.Position - root.Position).Magnitude
            if d < closestDst then closestDst = d; closest = player end
        end
    end
    return closest
end

local function autoFarmLoop()
    while CONFIG.AutoFarm_Enabled do
        local enemy = getClosestEnemy()
        if enemy and enemy.Character then
            local eRoot = enemy.Character:FindFirstChild("HumanoidRootPart")
            if eRoot then
                RootPart.CFrame = CFrame.new(eRoot.Position + Vector3.new(0, 0, 2))
                local rs = game:GetService("ReplicatedStorage")
                for _, name in ipairs({"Shoot","Fire","Attack","DamagePlayer"}) do
                    local re = rs:FindFirstChild(name, true)
                    if re and re:IsA("RemoteEvent") then re:FireServer(enemy.Character) break end
                end
            end
        end
        task.wait(CONFIG.AutoFarm_Delay)
    end
end

-- =============================================
-- KEYBINDS
-- =============================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == CONFIG.Keys.HUD then
        toggleHUD()
    elseif input.KeyCode == CONFIG.Keys.ESP then
        CONFIG.ESP_Enabled = not CONFIG.ESP_Enabled
        if not CONFIG.ESP_Enabled then
            for p in pairs(ESPObjects) do removeESP(p) end
        end
    elseif input.KeyCode == CONFIG.Keys.SilentAim then
        CONFIG.SilentAim_Enabled = not CONFIG.SilentAim_Enabled
    elseif input.KeyCode == CONFIG.Keys.NoRecoil then
        CONFIG.NoRecoil_Enabled = not CONFIG.NoRecoil_Enabled
    elseif input.KeyCode == CONFIG.Keys.AutoFarm then
        CONFIG.AutoFarm_Enabled = not CONFIG.AutoFarm_Enabled
        if CONFIG.AutoFarm_Enabled then task.spawn(autoFarmLoop) end
    end

    updateUI()
end)

-- =============================================
-- MAIN LOOP
-- =============================================
RunService.Heartbeat:Connect(function()
    updateESP()
end)

LocalPlayer.CharacterAdded:Connect(function(c)
    Character = c
    RootPart  = c:WaitForChild("HumanoidRootPart")
    Humanoid  = c:WaitForChild("Humanoid")
end)

updateUI()
print("[UrbanReload] Loaded 🎯 | E=ESP | T=SilentAim | N=NoRecoil | F=AutoFarm | H=HUD")