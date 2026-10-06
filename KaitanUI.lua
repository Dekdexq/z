local KaitanLib = {}
KaitanLib.__index = KaitanLib

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function tw(obj, props, dur, style)
    dur = dur or 0.2
    style = style or Enum.EasingStyle.Quad
    local t = TweenService:Create(obj, TweenInfo.new(dur, style, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

function KaitanLib:Create(opts)
    opts = opts or {}
    local self = setmetatable({}, KaitanLib)
    self._stats = {}
    
    local title = opts.Title or "KAITAN HUB"
    local logoId = opts.Logo or "104723298306512"

    local sg = Instance.new("ScreenGui")
    sg.Name = "ZIIQ_Kaitan"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if getgenv().KaitanUI_Instance then
        pcall(function() getgenv().KaitanUI_Instance:Destroy() end)
    end
    getgenv().KaitanUI_Instance = sg
    
    if gethui then sg.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(sg); sg.Parent = CoreGui
    elseif cloneref then sg.Parent = cloneref(CoreGui)
    else sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    
    self._sg = sg
    
    -- Main Board (Minimalist Dark)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromOffset(320, 420)
    bg.Position = UDim2.new(0.5, -160, 0.5, -210)
    bg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    bg.BackgroundTransparency = 0
    bg.BorderSizePixel = 0
    bg.ClipsDescendants = true
    bg.Parent = sg
    
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 14)
    uic.Parent = bg
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(40, 40, 40)
    stroke.Thickness = 1
    stroke.Parent = bg
    
    self._bg = bg
    
    -- Logo
    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.fromOffset(70, 70)
    logo.Position = UDim2.new(0.5, -35, 0, 25)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxthumb://type=Asset&id="..logoId.."&w=420&h=420"
    logo.ImageColor3 = Color3.fromRGB(230, 230, 230)
    logo.Parent = bg
    
    -- Spin Logo infinitely
    local tinfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
    TweenService:Create(logo, tinfo, {Rotation = 360}):Play()
    
    -- Title
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 24)
    titleLbl.Position = UDim2.new(0, 0, 0, 110)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.Font = Enum.Font.GothamBlack
    titleLbl.TextSize = 20
    titleLbl.Parent = bg
    
    -- Line separator
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -40, 0, 1)
    line.Position = UDim2.new(0, 20, 0, 145)
    line.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    line.BorderSizePixel = 0
    line.Parent = bg
    
    -- Stats Container
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -20, 1, -165)
    container.Position = UDim2.new(0, 10, 0, 155)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 2
    container.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    container.Parent = bg
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = container
    
    self._container = container
    self._list = list
    
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
    end)
    
    -- Draggable
    local dragToggle, dragInput, dragStart, startPos
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = bg.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            local delta = input.Position - dragStart
            bg.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    bg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = false
        end
    end)

    -- Mobile Toggle
    local mToggle = Instance.new("ImageButton")
    mToggle.Size = UDim2.fromOffset(42, 42)
    mToggle.AnchorPoint = Vector2.new(0, 0.5)
    mToggle.Position = UDim2.new(0, 10, 0.5, 0)
    mToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mToggle.BorderSizePixel = 0
    mToggle.AutoButtonColor = false
    mToggle.ClipsDescendants = true
    mToggle.Parent = sg
    
    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(1, 0)
    mCorner.Parent = mToggle
    
    local mStroke = Instance.new("UIStroke")
    mStroke.Color = Color3.fromRGB(150, 150, 150)
    mStroke.Thickness = 1
    mStroke.Transparency = 0.5
    mStroke.Parent = mToggle

    local mLogo = Instance.new("ImageLabel")
    mLogo.Size = UDim2.fromScale(0.7, 0.7)
    mLogo.AnchorPoint = Vector2.new(0.5, 0.5)
    mLogo.Position = UDim2.fromScale(0.5, 0.5)
    mLogo.BackgroundTransparency = 1
    mLogo.Image = "rbxthumb://type=Asset&id="..logoId.."&w=420&h=420"
    mLogo.ImageColor3 = Color3.fromRGB(200, 200, 200)
    mLogo.Parent = mToggle
    
    TweenService:Create(mLogo, tinfo, {Rotation = 360}):Play()

    local isVisible = true
    
    local function toggleUI()
        isVisible = not isVisible
        if isVisible then
            bg.Visible = true
            tw(bg, {Size = UDim2.fromOffset(320, 420), BackgroundTransparency = 0}, 0.25, Enum.EasingStyle.Quad)
            for _, v in ipairs(bg:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("ImageLabel") then
                    tw(v, {TextTransparency = 0, ImageTransparency = 0}, 0.2)
                elseif v:IsA("UIStroke") then
                    tw(v, {Transparency = 0}, 0.2)
                end
            end
        else
            tw(bg, {Size = UDim2.fromOffset(320, 0), BackgroundTransparency = 1}, 0.25, Enum.EasingStyle.Quad)
            for _, v in ipairs(bg:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("ImageLabel") then
                    tw(v, {TextTransparency = 1, ImageTransparency = 1}, 0.1)
                elseif v:IsA("UIStroke") then
                    tw(v, {Transparency = 1}, 0.1)
                end
            end
            task.delay(0.25, function() if not isVisible then bg.Visible = false end end)
        end
    end
    
    mToggle.MouseButton1Click:Connect(toggleUI)
    
    -- PC Toggle with RightControl
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
            toggleUI()
        end
    end)

    return self
end

function KaitanLib:AddStat(id, title, initialValue)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 6)
    uic.Parent = frame
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5, -10, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    titleLbl.Font = Enum.Font.GothamBlack
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = frame
    
    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.5, -12, 1, 0)
    valLbl.Position = UDim2.new(0.5, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(initialValue)
    valLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    valLbl.Font = Enum.Font.GothamBlack
    valLbl.TextSize = 14
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = frame
    
    frame.Parent = self._container
    self._stats[id] = { Frame = frame, Title = titleLbl, Value = valLbl }
end

function KaitanLib:UpdateStat(id, newValue, color)
    local stat = self._stats[id]
    if stat then
        stat.Value.Text = tostring(newValue)
        if color then
            stat.Value.TextColor3 = color
        else
            stat.Value.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
end

function KaitanLib:Destroy()
    if self._sg then self._sg:Destroy() end
end

return KaitanLib
