local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local themeColor = Color3.fromRGB(0, 150, 255)
local Lighting = game:GetService("Lighting")

-- ========================================================
-- SUPER POTATO GRAPHICS (ระบบภาพกากขั้นสุด + แสงเคลียร์)
-- ========================================================
local function AtivarAntiLag()
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
    end)
    
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    Lighting.Brightness = 3 
    Lighting.Ambient = Color3.fromRGB(255, 255, 255) 
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("Atmosphere") or v:IsA("BloomEffect")
        or v:IsA("BlurEffect") or v:IsA("SunRaysEffect")
        or v:IsA("DepthOfFieldEffect") or v:IsA("ColorCorrectionEffect")
        or v:IsA("Clouds") then
            v:Destroy()
        end
    end
    
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end
    
    local function optimizePart(v)
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic 
            v.Reflectance = 0
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Texture = ""
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") 
        or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v:Destroy()
        elseif v:IsA("MeshPart") or v:IsA("SpecialMesh") then
            pcall(function() v.RenderFidelity = Enum.RenderFidelity.Performance end)
        end
    end

    for _, v in pairs(workspace:GetDescendants()) do
        optimizePart(v)
    end
    
    workspace.DescendantAdded:Connect(optimizePart)
end

-- ========================================================
-- FPS WINDOW (หน้าต่างแสดงผลตัวเลขจริง + ปุ่ม X แบบโปร่งใสเนียนตา)
-- ========================================================
local fpsGui = Instance.new("ScreenGui")
fpsGui.Name = "WackShop_FPS_Counter"
fpsGui.IgnoreGuiInset = true
fpsGui.ResetOnSpawn = false
fpsGui.Parent = CoreGui

local fpsFrame = Instance.new("Frame", fpsGui)
fpsFrame.Size = UDim2.fromOffset(145, 44)
fpsFrame.AnchorPoint = Vector2.new(0, 0.5)
fpsFrame.Position = UDim2.new(0, 20, 0.3, 0)
fpsFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
fpsFrame.BorderSizePixel = 0
fpsFrame.ZIndex = 10
Instance.new("UICorner", fpsFrame).CornerRadius = UDim.new(0, 10)
local fpsStroke = Instance.new("UIStroke", fpsFrame)
fpsStroke.Color = themeColor
fpsStroke.Thickness = 1.2

local fpsBG = Instance.new("UIGradient", fpsFrame)
fpsBG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 14))
})

local fpsLabel = Instance.new("TextLabel", fpsFrame)
fpsLabel.Size = UDim2.new(1, 0, 1, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "🖥️ FPS : --"
fpsLabel.TextColor3 = themeColor
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 14
fpsLabel.ZIndex = 11

-- [ปรับแต่งปุ่ม X ให้พื้นหลังโปร่งใสเนียนไปกับกล่อง]
local closeFpsBtn = Instance.new("TextButton", fpsFrame)
closeFpsBtn.Size = UDim2.fromOffset(18, 18)
closeFpsBtn.Position = UDim2.new(1, -22, 0, 4)
closeFpsBtn.BackgroundTransparency = 1 
closeFpsBtn.Text = "X"
closeFpsBtn.TextColor3 = Color3.fromRGB(150, 150, 160) 
closeFpsBtn.Font = Enum.Font.GothamBold
closeFpsBtn.TextSize = 10 
closeFpsBtn.ZIndex = 12
closeFpsBtn.BorderSizePixel = 0

local updateMainToggleState = nil 

closeFpsBtn.MouseButton1Click:Connect(function()
    fpsFrame.Visible = false
    if updateMainToggleState then
        updateMainToggleState(false) 
    end
end)

local fd2, fs2, fp2
fpsFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fd2 = true fs2 = input.Position fp2 = fpsFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if fd2 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - fs2
        fpsFrame.Position = UDim2.new(fp2.X.Scale, fp2.X.Offset + d.X, fp2.Y.Scale, fp2.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then fd2 = false end
end)

local lastTime = os.clock()
local frameCount = 0

RunService.RenderStepped:Connect(function()
    if not fpsFrame.Visible then return end
    frameCount = frameCount + 1
    local now = os.clock()
    local delta = now - lastTime
    
    if delta >= 0.25 then
        local calculatedFps = math.floor(frameCount / delta)
        local engineFps = math.floor(workspace:GetRealPhysicsFPS())
        local fps = calculatedFps
        if math.abs(calculatedFps - engineFps) > 30 and engineFps > 0 then
            fps = engineFps
        end
        
        local color = fps >= 144
            and Color3.fromRGB(0, 255, 255)
            or fps >= 60
            and Color3.fromRGB(0, 220, 120)
            or fps >= 30
            and Color3.fromRGB(255, 180, 0)
            or Color3.fromRGB(255, 60, 60)
            
        fpsLabel.Text = "🖥️ FPS : " .. fps
        fpsLabel.TextColor3 = color
        fpsStroke.Color = color
        
        lastTime = now
        frameCount = 0
    end
end)

-- ========================================================
-- MAIN GUI & BUTTON W
-- ========================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WackShop_FPS"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local Main = Instance.new("Frame", screenGui)
Main.Size = UDim2.fromOffset(210, 165)
Main.AnchorPoint = Vector2.new(1, 0.5)
Main.Position = UDim2.new(1, -20, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BorderSizePixel = 0
Main.ZIndex = 10
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Thickness = 1.5
mainStroke.Color = Color3.fromRGB(60, 60, 80)

local BG = Instance.new("UIGradient", Main)
BG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 14))
})
BG.Rotation = 135

local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 10
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local TopLine = Instance.new("Frame", TitleBar)
TopLine.Size = UDim2.new(1, 0, 0, 1)
TopLine.Position = UDim2.new(0, 0, 1, -1)
TopLine.BackgroundColor3 = themeColor
TopLine.BackgroundTransparency = 0.5
TopLine.BorderSizePixel = 0
TopLine.ZIndex = 11

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, -45, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ WackShop FPS"
TitleLabel.TextColor3 = themeColor
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 10

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.fromOffset(28, 28)
CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
CloseBtn.Position = UDim2.new(1, -8, 0.5, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.AutoButtonColor = false
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 20
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- ปุ่มลอยตัว "W"
local FloatBtn = Instance.new("TextButton", screenGui)
FloatBtn.Size = UDim2.fromOffset(44, 44)
FloatBtn.AnchorPoint = Vector2.new(0, 0.5)
FloatBtn.Position = UDim2.new(0, 20, 0.5, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
FloatBtn.Text = "W"
FloatBtn.TextColor3 = themeColor
FloatBtn.TextSize = 18
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.AutoButtonColor = false
FloatBtn.BorderSizePixel = 0
FloatBtn.ZIndex = 20
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

local floatStroke = Instance.new("UIStroke", FloatBtn)
floatStroke.Color = themeColor
floatStroke.Thickness = 1.5

local fd, fs, fp
FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fd = true fs = input.Position fp = FloatBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if fd and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - fs
        FloatBtn.Position = UDim2.new(fp.X.Scale, fp.X.Offset + d.X, fp.Y.Scale, fp.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then fd = false end
end)

local mainVisible = true
FloatBtn.MouseButton1Click:Connect(function()
    mainVisible = not mainVisible
    Main.Visible = mainVisible
    floatStroke.Color = themeColor 
end)

-- ========================================================
-- CONFIRMATION NOTIFICATION & ONE-TIME CLICK SYSTEM
-- ========================================================
local function createOneTimeButton(yPos)
    local container = Instance.new("Frame", Main)
    container.Size = UDim2.new(1, -16, 0, 48)
    container.Position = UDim2.new(0, 8, 0, yPos)
    container.BackgroundColor3 = Color3.fromRGB(16, 16, 26)
    container.BorderSizePixel = 0
    container.ZIndex = 10
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    
    local cStroke = Instance.new("UIStroke", container)
    cStroke.Color = Color3.fromRGB(80, 80, 100)
    cStroke.Thickness = 1
    cStroke.Transparency = 0.4

    local actionBtn = Instance.new("TextButton", container)
    actionBtn.Size = UDim2.new(1, -16, 1, -14)
    actionBtn.Position = UDim2.new(0, 8, 0, 7)
    actionBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    actionBtn.Text = "🚀 กดเพื่อบูสต์ FPS (ภาพกาก)"
    actionBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.TextSize = 12
    actionBtn.BorderSizePixel = 0
    actionBtn.ZIndex = 12
    Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 8)

    actionBtn.MouseButton1Click:Connect(function()
        local alertFrame = Instance.new("Frame", screenGui)
        alertFrame.Size = UDim2.fromOffset(260, 140)
        alertFrame.Position = UDim2.new(0.5, -130, 0.5, -70)
        alertFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 12)
        alertFrame.BorderSizePixel = 0
        alertFrame.ZIndex = 100
        Instance.new("UICorner", alertFrame).CornerRadius = UDim.new(0, 12)
        
        local alertStroke = Instance.new("UIStroke", alertFrame)
        alertStroke.Color = Color3.fromRGB(230, 50, 50)
        alertStroke.Thickness = 1.5

        local alertTitle = Instance.new("TextLabel", alertFrame)
        alertTitle.Size = UDim2.new(1, 0, 0, 30)
        alertTitle.Position = UDim2.new(0, 0, 0, 10)
        alertTitle.BackgroundTransparency = 1
        alertTitle.Text = "⚠️ คำเตือนระบบภาพกาก"
        alertTitle.TextColor3 = Color3.fromRGB(250, 60, 60)
        alertTitle.Font = Enum.Font.GothamBold
        alertTitle.TextSize = 13
        alertTitle.ZIndex = 101

        local alertDesc = Instance.new("TextLabel", alertFrame)
        alertDesc.Size = UDim2.new(1, -20, 0, 40)
        alertDesc.Position = UDim2.new(0, 10, 0, 40)
        alertDesc.BackgroundTransparency = 1
        alertDesc.Text = "หากเปิดระบบแล้วภาพจะกากทันที\nและจะไม่สามารถกดปิดระบบได้!"
        alertDesc.TextColor3 = Color3.fromRGB(180, 180, 190)
        alertDesc.Font = Enum.Font.Gotham
        alertDesc.TextSize = 11
        alertDesc.ZIndex = 101

        local cancelBtn = Instance.new("TextButton", alertFrame)
        cancelBtn.Size = UDim2.fromOffset(105, 30)
        cancelBtn.Position = UDim2.new(0, 15, 1, -45)
        cancelBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        cancelBtn.Text = "ยกเลิก"
        cancelBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        cancelBtn.Font = Enum.Font.GothamBold
        cancelBtn.TextSize = 12
        cancelBtn.BorderSizePixel = 0
        cancelBtn.ZIndex = 101
        Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 6)

        local confirmBtn = Instance.new("TextButton", alertFrame)
        confirmBtn.Size = UDim2.fromOffset(105, 30)
        confirmBtn.Position = UDim2.new(1, -120, 1, -45)
        confirmBtn.BackgroundColor3 = Color3.fromRGB(210, 40, 40)
        confirmBtn.Text = "ยืนยันการเปิด"
        confirmBtn.TextColor3 = Color3.new(1, 1, 1)
        confirmBtn.Font = Enum.Font.GothamBold
        confirmBtn.TextSize = 12
        confirmBtn.BorderSizePixel = 0
        confirmBtn.ZIndex = 101
        Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 6)

        cancelBtn.MouseButton1Click:Connect(function()
            alertFrame:Destroy()
        end)

        confirmBtn.MouseButton1Click:Connect(function()
            alertFrame:Destroy()
            actionBtn:Destroy()
            
            AtivarAntiLag()
            
            cStroke.Color = themeColor
            cStroke.Transparency = 0
            mainStroke.Color = themeColor
            
            local statusLabel = Instance.new("TextLabel", container)
            statusLabel.Size = UDim2.new(1, 0, 1, 0)
            statusLabel.BackgroundTransparency = 1
            statusLabel.Text = "⚠️ ระบบเปิดแล้ว (ไม่สามารถปิดได้)"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150) 
            statusLabel.Font = Enum.Font.GothamBold
            statusLabel.TextSize = 11 
            statusLabel.ZIndex = 11
        end)
    end)
end

-- ========================================================
-- STANDARD TOGGLE (หน้าต่าง FPS)
-- ========================================================
local function createNormalToggle(text, desc, yPos, onCallback, offCallback)
    local box = Instance.new("Frame", Main)
    box.Size = UDim2.new(1, -16, 0, 48)
    box.Position = UDim2.new(0, 8, 0, yPos)
    box.BackgroundColor3 = Color3.fromRGB(16, 16, 26)
    box.BorderSizePixel = 0
    box.ZIndex = 10
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
    local bs = Instance.new("UIStroke", box)
    bs.Color = themeColor
    bs.Thickness = 1
    bs.Transparency = 0.6

    local lbl = Instance.new("TextLabel", box)
    lbl.Size = UDim2.new(1, -60, 0, 22)
    lbl.Position = UDim2.new(0, 10, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 10

    local dlbl = Instance.new("TextLabel", box)
    dlbl.Size = UDim2.new(1, -60, 0, 16)
    dlbl.Position = UDim2.new(0, 10, 0, 27)
    dlbl.BackgroundTransparency = 1
    dlbl.Text = desc
    dlbl.TextColor3 = Color3.fromRGB(90, 100, 130)
    dlbl.Font = Enum.Font.Gotham
    dlbl.TextSize = 11
    dlbl.TextXAlignment = Enum.TextXAlignment.Left
    dlbl.ZIndex = 10

    local swBG = Instance.new("Frame", box)
    swBG.Size = UDim2.fromOffset(44, 24)
    swBG.Position = UDim2.new(1, -54, 0.5, -12)
    swBG.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    swBG.BorderSizePixel = 0
    swBG.ZIndex = 10
    Instance.new("UICorner", swBG).CornerRadius = UDim.new(1, 0)

    local swKnob = Instance.new("Frame", swBG)
    swKnob.Size = UDim2.fromOffset(18, 18)
    swKnob.Position = UDim2.new(0, 3, 0.5, -9)
    swKnob.BackgroundColor3 = Color3.fromRGB(160, 160, 180)
    swKnob.BorderSizePixel = 0
    swKnob.ZIndex = 11
    Instance.new("UICorner", swKnob).CornerRadius = UDim.new(1, 0)

    local clickArea = Instance.new("TextButton", box)
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 12

    local state = false
    local function update()
        TweenService:Create(swBG, TweenInfo.new(0.2), {
            BackgroundColor3 = state and themeColor or Color3.fromRGB(40, 40, 55)
        }):Play()
        TweenService:Create(swKnob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
            BackgroundColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,160,180)
        }):Play()
        bs.Transparency = state and 0 or 0.6
        lbl.TextColor3 = state and themeColor or Color3.fromRGB(220, 220, 220)
        dlbl.Text = state and "✅ เปิดอยู่" or desc
        if state then onCallback() else offCallback() end
    end

    clickArea.MouseButton1Click:Connect(function()
        state = not state
        update()
    end)
    
    updateMainToggleState = function(newState)
        state = newState
        TweenService:Create(swBG, TweenInfo.new(0.2), {
            BackgroundColor3 = state and themeColor or Color3.fromRGB(40, 40, 55)
        }):Play()
        TweenService:Create(swKnob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
            BackgroundColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,160,180)
        }):Play()
        bs.Transparency = state and 0 or 0.6
        lbl.TextColor3 = state and themeColor or Color3.fromRGB(220, 220, 220)
        dlbl.Text = state and "✅ เปิดอยู่" or desc
    end
end

createOneTimeButton(50)

createNormalToggle(
    "🖥️ FPS Counter",
    "แสดงหน้าต่าง FPS",
    106,
    function() fpsFrame.Visible = true end,
    function() fpsFrame.Visible = false end
)

fpsFrame.Visible = false

local Credit = Instance.new("TextLabel", Main)
Credit.Position = UDim2.new(0, 0, 1, -20)
Credit.Size = UDim2.new(1, 0, 0, 18)
Credit.BackgroundTransparency = 1
Credit.Text = "WackShop — Permanent Anti-Lag"
Credit.TextColor3 = Color3.fromRGB(40, 40, 60)
Credit.Font = Enum.Font.Gotham
Credit.TextSize = 10

print("✅ WackShop Final UI Code Loaded Successfully!")
