--[[
  ╔══════════════════════════════════════════════════════════════╗
  ║              ZIIQ UI Library v1.0 — By Dexq                ║
  ║  A premium dark-theme UI library for Roblox executors      ║
  ║  Supports: PC + Mobile (Delta, Volt, Potassium, etc.)      ║
  ╚══════════════════════════════════════════════════════════════╝
  
  Usage:
    local Ziiq = loadstring(game:HttpGet("https://raw.githubusercontent.com/Dekdexq/z/refs/heads/main/ZiiqLib.lua"))()
    local Window = Ziiq:CreateWindow({ Title = "My Hub", SubTitle = "v1.0" })
    local Tab = Window:AddTab({ Title = "Main", Icon = "7734068321" })
    Tab:AddToggle({ Title = "God Mode", Callback = function(v) end })
--]]

local ZiiqLib = {}
ZiiqLib.__index = ZiiqLib

-- ════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local TextService      = game:GetService("TextService")
local RunService       = game:GetService("RunService")

local lp     = Players.LocalPlayer

-- ════════════════════════════════════════
--  PALETTE
-- ════════════════════════════════════════
local function hex(h)
    h = h:gsub("#","")
    return Color3.fromRGB(
        tonumber(h:sub(1,2),16),
        tonumber(h:sub(3,4),16),
        tonumber(h:sub(5,6),16))
end

local C = {
    bg0=hex"07070a", bg1=hex"0d0d10", bg2=hex"131316",
    bg3=hex"1a1a1e", bg4=hex"222226",
    bd0=hex"1e1e23", bd1=hex"28282f", bd2=hex"34343d",
    t0=hex"eeeef2",  t1=hex"9898a8",  t2=hex"55555f",  t3=hex"30303a",
    accent=hex"5f8eff",
}

-- ════════════════════════════════════════
--  UTILS
-- ════════════════════════════════════════
local function tw(obj,props,dur,style,dir)
    TweenService:Create(obj,
        TweenInfo.new(dur or .18,style or Enum.EasingStyle.Quint,
                      dir  or Enum.EasingDirection.Out),props):Play()
end
local function corner(o,r)
    local u=Instance.new("UICorner"); u.CornerRadius=UDim.new(0,r or 8); u.Parent=o; return u
end
local function stroke(o,clr,t2)
    local s=Instance.new("UIStroke"); s.Color=clr or C.bd0
    s.Thickness=t2 or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    s.Parent=o; return s
end
local function F(p)
    local f=Instance.new(p.class or "Frame")
    f.BackgroundColor3=p.bg or C.bg1; f.BorderSizePixel=0
    f.Size=p.sz or UDim2.fromScale(1,1); f.Position=p.pos or UDim2.new()
    f.ZIndex=p.z or 1; f.ClipsDescendants=p.clip or false
    if p.parent then f.Parent=p.parent end; return f
end
local function L(p)
    local t=Instance.new("TextLabel")
    t.BackgroundTransparency=1; t.Text=p.text or ""
    t.TextColor3=p.color or C.t0; t.Font=p.font or Enum.Font.GothamBold
    t.TextSize=(p.ts or 11) + 1
    t.TextXAlignment=p.xa or Enum.TextXAlignment.Left
    t.TextYAlignment=p.ya or Enum.TextYAlignment.Center
    t.Size=p.sz or UDim2.fromScale(1,1); t.Position=p.pos or UDim2.new()
    t.ZIndex=p.z or 2; t.RichText=p.rich or false
    if p.parent then t.Parent=p.parent end; return t
end
local function B(p)
    local b=Instance.new("TextButton")
    b.BackgroundColor3=p.bg or C.bg4; b.BorderSizePixel=0
    b.Text=p.text or ""; b.TextColor3=p.color or C.t0
    b.Font=p.font or Enum.Font.GothamBold; b.TextSize=(p.ts or 11) + 1
    b.Size=p.sz or UDim2.fromOffset(80,28); b.Position=p.pos or UDim2.new()
    b.ZIndex=p.z or 3; b.AutoButtonColor=false
    b.TextXAlignment=p.xa or Enum.TextXAlignment.Center
    if p.parent then b.Parent=p.parent end; return b
end

local function getIcon(id)
    if type(id)=="number" or tonumber(id) then
        return "rbxassetid://"..tostring(id)
    end
    return id
end

local function isTouch(inp)
    return inp.UserInputType == Enum.UserInputType.Touch
end
local function isClick(inp)
    return inp.UserInputType == Enum.UserInputType.MouseButton1 or isTouch(inp)
end
local function isMove(inp)
    return inp.UserInputType == Enum.UserInputType.MouseMovement or isTouch(inp)
end

-- ════════════════════════════════════════
--  DROPDOWN FADE HELPER
-- ════════════════════════════════════════
local function fadeDrop(list, fadeOut, selectedText)
    local dur = 0.2
    for _, ch in ipairs(list:GetChildren()) do
        if ch:IsA("TextButton") then
            if fadeOut then
                tw(ch, {TextTransparency=1, BackgroundTransparency=1}, dur)
            else
                ch.TextTransparency=0; ch.BackgroundTransparency=0
                if ch.Text == selectedText then
                    ch.BackgroundColor3 = C.bg3; ch.TextColor3 = C.t0
                else
                    ch.BackgroundColor3 = C.bg2; ch.TextColor3 = C.t2
                end
            end
        elseif ch:IsA("UIStroke") then
            if fadeOut then tw(ch, {Transparency=1}, dur) else ch.Transparency=0 end
        end
    end
    if fadeOut then tw(list, {BackgroundTransparency=1}, dur) else list.BackgroundTransparency=0 end
end

-- ════════════════════════════════════════
--  WINDOW CLASS
-- ════════════════════════════════════════
local Window = {}
Window.__index = Window

-- ════════════════════════════════════════
--  TAB CLASS
-- ════════════════════════════════════════
local Tab = {}
Tab.__index = Tab

-- ════════════════════════════════════════
--  CREATE WINDOW
-- ════════════════════════════════════════
function ZiiqLib:CreateWindow(opts)
    opts = opts or {}
    local title    = opts.Title or "ZIIQ"
    local subTitle = opts.SubTitle or "By Dexq"
    local logoId   = opts.LogoId or nil
    local winSize  = opts.Size or UDim2.fromOffset(520, 380)
    local minKey   = opts.MinimizeKey or Enum.KeyCode.RightShift

    local self = setmetatable({}, Window)
    self._connections = {}
    self._tabs = {}
    self._navBtns = {}
    self._activeTab = nil
    self._panelMap = {}
    self._toggleStates = {}
    self._configurables = {}
    self._folderName = "ZiiqConfigs"

    -- Anti-cheat: randomize GUI name so it cant be detected
    local guiId = "Z_"..tostring(math.random(100000,999999))
    
    -- Destroy previous
    if gethui then
        for _,v in ipairs(gethui():GetChildren()) do
            if v.Name:sub(1,2) == "Z_" then v:Destroy() end
        end
    elseif game:GetService("CoreGui"):FindFirstChild("ZiiqUI") then
        game:GetService("CoreGui"):FindFirstChild("ZiiqUI"):Destroy()
    else
        for _,v in ipairs(lp.PlayerGui:GetChildren()) do
            if v.Name:sub(1,2) == "Z_" then v:Destroy() end
        end
    end

    -- ScreenGui (Anti-cheat safe placement)
    local sg = Instance.new("ScreenGui")
    sg.Name = guiId
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.ResetOnSpawn = false
    -- Priority: gethui > protect_gui+CoreGui > PlayerGui
    if gethui then
        sg.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(sg)
        sg.Parent = game:GetService("CoreGui")
    elseif cloneref then
        sg.Parent = cloneref(game:GetService("CoreGui"))
    else
        sg.Parent = lp.PlayerGui
    end
    self._sg = sg

    -- Window
    local WW, WH = winSize.X.Offset, winSize.Y.Offset
    local SBW = 130
    local win = F({bg=C.bg0, sz=winSize, pos=UDim2.new(0.5,-WW/2,0.5,-WH/2), parent=sg, z=2, clip=true})
    corner(win, 14)
    self._win = win
    self._WW = WW
    self._WH = WH
    self._SBW = SBW

    -- Top Bar
    local tbar = F({bg=C.bg1, sz=UDim2.new(1,0,0,44), parent=win, z=10})
    self._tbar = tbar

    -- Close Button
    local closeBtn = B({bg=C.bg0,text="X",color=C.t0,ts=16,font=Enum.Font.GothamBold,
        sz=UDim2.fromOffset(44,44),pos=UDim2.new(1,-44,0,0),parent=tbar,z=11})
    closeBtn.BackgroundTransparency = 1
    closeBtn.MouseButton1Click:Connect(function() self:_closeApp() end)
    closeBtn.MouseEnter:Connect(function() tw(closeBtn, {TextColor3=hex"ff4444"}, 0.1) end)
    closeBtn.MouseLeave:Connect(function() tw(closeBtn, {TextColor3=C.t0}, 0.1) end)

    -- Logo
    if logoId then
        local logoImg = Instance.new("ImageLabel")
        logoImg.BackgroundTransparency = 1
        logoImg.Size = UDim2.fromOffset(65, 65)
        logoImg.Position = UDim2.new(0, 0, 0, -6)
        logoImg.Image = "rbxthumb://type=Asset&id="..tostring(logoId).."&w=420&h=420"
        logoImg.Parent = tbar
        logoImg.ZIndex = 12
    end

    -- Title
    local titleX = logoId and 58 or 16
    L({text=title,color=C.t0,ts=12,font=Enum.Font.GothamBold,
        sz=UDim2.fromOffset(150,14),pos=UDim2.new(0,titleX,0,14),parent=tbar,z=11})
    L({text=subTitle,color=C.t2,ts=10,font=Enum.Font.GothamBold,
        sz=UDim2.fromOffset(150,12),pos=UDim2.new(0,titleX,0,27),parent=tbar,z=11})

    -- Sidebar
    local sb = F({bg=C.bg0,sz=UDim2.new(0,SBW,1,-44),pos=UDim2.new(0,0,0,44),parent=win,z=4})
    self._sb = sb
    self._navY = 16

    -- Content area
    self._contentArea = {
        pos = UDim2.new(0,SBW,0,44),
        sz = UDim2.new(1,-SBW,1,-44)
    }

    -- Drag
    self:_setupDrag(tbar, win)

    -- Resize Grip
    self:_setupResize(win)

    -- Keybind
    self._minimized = false
    self._minKey = minKey
    self._origPos = win.Position
    self._origSize = win.Size
    table.insert(self._connections, UserInputService.InputBegan:Connect(function(inp,gpe)
        if gpe then return end
        if inp.KeyCode == self._minKey then
            self:_toggleMinimize()
        end
    end))

    -- Mobile Toggle
    self:_setupMobileToggle(sg, win, logoId)

    -- Cleanup on destroy
    if shared.ZiiqUnload then pcall(shared.ZiiqUnload) end
    shared.ZiiqUnload = function()
        for _, c in ipairs(self._connections) do
            if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
        end
        table.clear(self._connections)
    end
    sg.Destroying:Connect(function() shared.ZiiqUnload() end)

    return self
end

-- ════════════════════════════════════════
--  WINDOW: ADD TAB
-- ════════════════════════════════════════
function Window:AddTab(opts)
    opts = opts or {}
    local id = opts.Title or ("Tab"..#self._tabs+1)
    local lbl = opts.Title or "Tab"
    local ico = opts.Icon

    -- Nav button
    local btnFrame = F({bg=C.bg0, sz=UDim2.new(1,-24,0,32), pos=UDim2.new(0,12,0,self._navY), parent=self._sb, z=5})
    corner(btnFrame, 8)
    btnFrame.BackgroundTransparency = 1

    local iconLabel
    local textX = 16
    if ico then
        local iconId = tonumber(ico)
        if iconId then
            iconLabel = Instance.new("ImageLabel")
            iconLabel.BackgroundTransparency = 1
            iconLabel.Image = getIcon(ico)
            iconLabel.ImageColor3 = C.t2
            iconLabel.Size = UDim2.fromOffset(18,18)
            iconLabel.Position = UDim2.new(0,10,0.5,-9)
            iconLabel.Parent = btnFrame
            iconLabel.ZIndex = 6
        else
            iconLabel = L({text=ico,color=C.t2,ts=14,font=Enum.Font.GothamBold,
                sz=UDim2.fromOffset(20,20),pos=UDim2.new(0,8,0.5,-10),parent=btnFrame,z=6})
        end
        textX = 34
    end

    local lblObj = L({text=lbl,color=C.t2,ts=11,font=Enum.Font.GothamBold,
        sz=UDim2.new(1,-textX-8,1,0),pos=UDim2.new(0,textX,0,0),parent=btnFrame,z=6})

    local btn = B({bg=hex"000000",sz=UDim2.fromScale(1,1),parent=btnFrame,z=7})
    btn.BackgroundTransparency=1

    self._navY = self._navY + 38

    -- Panel (ScrollingFrame)
    local panel = Instance.new("ScrollingFrame")
    panel.BackgroundColor3 = C.bg1
    panel.BorderSizePixel = 0
    panel.Size = self._contentArea.sz
    panel.Position = self._contentArea.pos
    panel.ScrollBarThickness = 3
    panel.ScrollBarImageColor3 = C.bd2
    panel.CanvasSize = UDim2.fromOffset(0,0)
    panel.Visible = false
    panel.ZIndex = 5
    panel.Parent = self._win

    -- List layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = panel

    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingTop = UDim.new(0, 13)
    uiPadding.PaddingBottom = UDim.new(0, 26)
    uiPadding.Parent = panel

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        panel.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 40)
    end)

    -- Store
    self._navBtns[id] = {btn=btnFrame, lbl=lblObj, img=iconLabel}
    self._panelMap[id] = panel
    table.insert(self._tabs, id)

    -- Wire nav
    btn.MouseButton1Click:Connect(function() self:_switchTab(id) end)
    btnFrame.MouseEnter:Connect(function()
        if self._activeTab ~= id then tw(btnFrame,{BackgroundTransparency=0,BackgroundColor3=C.bg1},0.12) end
    end)
    btnFrame.MouseLeave:Connect(function()
        if self._activeTab ~= id then tw(btnFrame,{BackgroundTransparency=1},0.16) end
    end)

    -- Auto-select first tab
    if #self._tabs == 1 then
        task.defer(function() self:_switchTab(id) end)
    end

    -- Return Tab object
    local tab = setmetatable({}, Tab)
    tab._panel = panel
    tab._window = self
    tab._sg = self._sg
    tab._id = id
    return tab
end

-- ════════════════════════════════════════
--  WINDOW: ADD SETTINGS TAB (Auto)
-- ════════════════════════════════════════
function Window:AddSettings(opts)
    opts = opts or {}
    local tab = self:AddTab({ Title = opts.Title or "Settings", Icon = opts.Icon or "7733920644" })

    -- Interface section
    tab:AddSection("Interface")

    -- Transparency toggle
    tab:AddToggle({
        Title = "Transparency",
        Description = "Makes the interface transparent.",
        Default = false,
        Callback = function(on)
            local win = self._win
            if on then
                tw(win, {BackgroundTransparency=0.35}, 0.25)
                for _, child in ipairs(win:GetDescendants()) do
                    if child:IsA("Frame") and child.BackgroundTransparency == 0 then
                        child:SetAttribute("_origBT", 0)
                        tw(child, {BackgroundTransparency=0.25}, 0.25)
                    end
                end
            else
                tw(win, {BackgroundTransparency=0}, 0.25)
                for _, child in ipairs(win:GetDescendants()) do
                    if child:IsA("Frame") and child:GetAttribute("_origBT") ~= nil then
                        tw(child, {BackgroundTransparency=0}, 0.25)
                        child:SetAttribute("_origBT", nil)
                    end
                end
            end
        end
    })

    -- Minimize Bind
    tab:AddKeybind({
        Title = "Minimize Bind",
        Default = "RightShift",
        Callback = function(key)
            self._minKey = key
        end
    })

    -- Configuration section
    tab:AddSection("Configuration")
    
    local HttpService = game:GetService("HttpService")
    local folderName = "ZiiqConfigs"
    
    local function initFolder()
        if makefolder and not isfolder(folderName) then
            makefolder(folderName)
        end
    end
    initFolder()

    local function getConfigs()
        local list = {}
        if listfiles and isfolder(folderName) then
            for _, file in ipairs(listfiles(folderName)) do
                if file:match(".json$") then
                    local name = file:match("([^/\\]+)%.json$")
                    if name then table.insert(list, name) end
                end
            end
        end
        if #list == 0 then return {"--"} end
        return list
    end

    local cfgInput = tab:AddTextbox({
        Title = "Config name",
        Placeholder = "config_name",
        Callback = function(text) end
    })

    local cfgDrop = tab:AddDropdown({
        Title = "Config list",
        Options = getConfigs(),
        Default = "--",
        Width = 120,
        Callback = function(selected)
            if selected ~= "--" then cfgInput.Set(selected) end
        end
    })

    tab:AddButton({
        Title = "Create / Save",
        ButtonText = "Save",
        Callback = function()
            local nm = cfgInput.Get()
            if nm == "" then nm = "default" end
            local data = {}
            for flag, comp in pairs(self._configurables) do
                pcall(function() data[flag] = comp.Get() end)
            end
            if writefile then
                initFolder()
                writefile(folderName .. "/" .. nm .. ".json", HttpService:JSONEncode(data))
                self:Notify({Title="Config Saved", Content="Saved " .. nm .. ".json", Duration=3})
                cfgDrop.Refresh(getConfigs())
                cfgDrop.Set(nm)
            else
                self:Notify({Title="Error", Content="Executor does not support saving", Duration=3})
            end
        end
    })

    tab:AddButton({
        Title = "Load config",
        ButtonText = "Load",
        Callback = function()
            local nm = cfgInput.Get()
            if nm == "" then return end
            if readfile and isfile and isfile(folderName .. "/" .. nm .. ".json") then
                local s, data = pcall(function() return HttpService:JSONDecode(readfile(folderName .. "/" .. nm .. ".json")) end)
                if s and type(data) == "table" then
                    for flag, val in pairs(data) do
                        if self._configurables[flag] then
                            pcall(function() self._configurables[flag].Set(val) end)
                        end
                    end
                    self:Notify({Title="Config Loaded", Content="Loaded " .. nm .. ".json", Duration=3})
                else
                    self:Notify({Title="Error", Content="Failed to decode config", Duration=3})
                end
            else
                self:Notify({Title="Error", Content="Config not found or unsupported", Duration=3})
            end
        end
    })

    tab:AddButton({
        Title = "Set as autoload",
        ButtonText = "Set",
        Callback = function()
            local nm = cfgInput.Get()
            if nm == "" then return end
            if writefile then
                initFolder()
                writefile(folderName .. "/autoload.txt", nm)
                self:Notify({Title="Autoload Set", Content="Will auto-load " .. nm .. ".json next time", Duration=3})
            end
        end
    })

    tab:AddButton({
        Title = "Delete config",
        ButtonText = "Delete",
        Callback = function()
            local nm = cfgInput.Get()
            if nm == "" then return end
            if delfile and isfile and isfile(folderName .. "/" .. nm .. ".json") then
                delfile(folderName .. "/" .. nm .. ".json")
                self:Notify({Title="Config Deleted", Content="Deleted " .. nm .. ".json", Duration=3})
                cfgDrop.Refresh(getConfigs())
                cfgDrop.Set("--")
                cfgInput.Set("")
            else
                self:Notify({Title="Error", Content="Config not found or cannot delete", Duration=3})
            end
        end
    })

    -- Auto-Load System (runs slightly after UI init)
    task.spawn(function()
        task.wait(1.5) -- Wait for all UI elements to be added to _configurables
        if isfile and isfile(folderName .. "/autoload.txt") then
            local autoName = readfile(folderName .. "/autoload.txt")
            if autoName and autoName ~= "" and isfile(folderName .. "/" .. autoName .. ".json") then
                local s, data = pcall(function() return HttpService:JSONDecode(readfile(folderName .. "/" .. autoName .. ".json")) end)
                if s and type(data) == "table" then
                    for flag, val in pairs(data) do
                        if self._configurables[flag] then
                            pcall(function() self._configurables[flag].Set(val) end)
                        end
                    end
                    self:Notify({Title="Autoloaded", Content="Automatically loaded " .. autoName, Duration=3})
                    cfgDrop.Set(autoName)
                    cfgInput.Set(autoName)
                end
            end
        end
    end)

    return tab
end

-- ════════════════════════════════════════
--  TAB: ADD SECTION
-- ════════════════════════════════════════
function Tab:AddSection(title)
    local secLabel = L({text=title:upper(),color=C.t3,ts=9,font=Enum.Font.GothamBold,
        sz=UDim2.new(1,-32,0,16),parent=self._panel,z=6})
    secLabel.TextXAlignment = Enum.TextXAlignment.Left
    return secLabel
end

-- ════════════════════════════════════════
--  TAB: ADD TOGGLE
-- ════════════════════════════════════════
function Tab:AddToggle(opts)
    opts = opts or {}
    local title = opts.Title or "Toggle"
    local desc = opts.Description or nil
    local default = opts.Default or false
    local cb = opts.Callback

    local h = desc and 46 or 36
    local r = F({bg=C.bg2,sz=UDim2.new(1,-24,0,h),parent=self._panel,z=6})
    corner(r,11)
    r.MouseEnter:Connect(function() tw(r,{BackgroundColor3=C.bg3},0.12) end)
    r.MouseLeave:Connect(function() tw(r,{BackgroundColor3=C.bg2},0.16) end)

    local yTitle = desc and 6 or math.floor((h-16)/2)
    L({text=title,color=hex"e2e4e9",ts=13,font=Enum.Font.GothamBold,
       sz=UDim2.new(1,-76,0,16),pos=UDim2.new(0,16,0,yTitle),parent=r,z=7})
    if desc then
        L({text=desc,color=hex"8a8f9c",ts=11,font=Enum.Font.GothamBold,
           sz=UDim2.new(1,-76,0,14),pos=UDim2.new(0,16,0,26),parent=r,z=7})
    end

    -- Pill toggle
    local wrap=F({bg=hex"1c1f26",sz=UDim2.fromOffset(36,20),pos=UDim2.new(1,-48,0.5,-10),parent=r,z=7})
    corner(wrap,10)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.t2), ColorSequenceKeypoint.new(1, C.t0)})
    grad.Parent = wrap; grad.Enabled = false
    local knob=F({bg=hex"2d313a",sz=UDim2.fromOffset(14,14),pos=UDim2.new(0,3,0.5,-7),parent=wrap,z=8})
    corner(knob,7)

    local state = default
    local flag = opts.Flag or title:gsub(" ","_"):lower()
    self._window._toggleStates[flag] = state

    local function setToggle(on)
        state = on
        self._window._toggleStates[flag] = on
        grad.Enabled = on
        tw(wrap,{BackgroundColor3=on and hex"ffffff" or hex"1c1f26"},0.22)
        tw(knob,{Position=on and UDim2.new(0,19,0.5,-7) or UDim2.new(0,3,0.5,-7),
                 BackgroundColor3=on and hex"14171c" or hex"2d313a"},0.28,Enum.EasingStyle.Back)
        if cb then cb(on) end
    end

    local tb=B({bg=hex"000000",sz=UDim2.fromScale(1,1),parent=wrap,z=9})
    tb.BackgroundTransparency=1
    tb.MouseButton1Click:Connect(function()
        setToggle(not state)
    end)

    if default then task.defer(function() setToggle(true) end) end

    local comp = { Set = setToggle, Get = function() return state end }
    self._window._configurables[flag] = comp
    return comp
end

-- ════════════════════════════════════════
--  TAB: ADD BUTTON
-- ════════════════════════════════════════
function Tab:AddButton(opts)
    opts = opts or {}
    local title = opts.Title or "Button"
    local desc = opts.Description or nil
    local cb = opts.Callback

    local h = desc and 46 or 36
    local r = F({bg=C.bg2,sz=UDim2.new(1,-24,0,h),parent=self._panel,z=6})
    corner(r,11)
    r.MouseEnter:Connect(function() tw(r,{BackgroundColor3=C.bg3},0.12) end)
    r.MouseLeave:Connect(function() tw(r,{BackgroundColor3=C.bg2},0.16) end)

    local yTitle = desc and 6 or math.floor((h-16)/2)
    L({text=title,color=hex"e2e4e9",ts=13,font=Enum.Font.GothamBold,
       sz=UDim2.new(1,-140,0,16),pos=UDim2.new(0,16,0,yTitle),parent=r,z=7})
    if desc then
        L({text=desc,color=hex"8a8f9c",ts=11,font=Enum.Font.GothamBold,
           sz=UDim2.new(1,-140,0,14),pos=UDim2.new(0,16,0,26),parent=r,z=7})
    end

    local bTrig = F({bg=C.bg0,sz=UDim2.fromOffset(100,26),pos=UDim2.new(1,-112,0.5,-13),parent=r,z=7})
    corner(bTrig,6); stroke(bTrig,C.bd1,1)
    local bLbl = L({text=opts.ButtonText or "Click",color=C.t0,ts=11,font=Enum.Font.GothamBold,
        sz=UDim2.fromScale(1,1),parent=bTrig,z=8,xa=Enum.TextXAlignment.Center})
    local bHit = B({bg=hex"000000",sz=UDim2.fromScale(1,1),parent=bTrig,z=9})
    bHit.BackgroundTransparency = 1
    bHit.MouseEnter:Connect(function() tw(bTrig,{BackgroundColor3=C.bg1},0.1) end)
    bHit.MouseLeave:Connect(function() tw(bTrig,{BackgroundColor3=C.bg0},0.1) end)
    bHit.MouseButton1Click:Connect(function()
        tw(bTrig,{BackgroundColor3=hex"2a2a30"},0.06)
        task.delay(0.08, function() tw(bTrig,{BackgroundColor3=C.bg0},0.15) end)
        if cb then cb() end
    end)
end

-- ════════════════════════════════════════
--  TAB: ADD SLIDER
-- ════════════════════════════════════════
function Tab:AddSlider(opts)
    opts = opts or {}
    local title = opts.Title or "Slider"
    local mn = opts.Min or 0
    local mx = opts.Max or 100
    local def = opts.Default or mn
    local cb = opts.Callback
    local suffix = opts.Suffix or ""

    local r = F({bg=C.bg2,sz=UDim2.new(1,-24,0,46),parent=self._panel,z=6})
    corner(r,11)
    r.MouseEnter:Connect(function() tw(r,{BackgroundColor3=C.bg3},0.12) end)
    r.MouseLeave:Connect(function() tw(r,{BackgroundColor3=C.bg2},0.16) end)

    L({text=title,color=C.t0,ts=11,font=Enum.Font.GothamBold,
       sz=UDim2.new(0,80,0,16),pos=UDim2.new(0,16,0.5,-8),parent=r,z=7})

    local TW2 = 108
    local trk=F({bg=C.bg4,sz=UDim2.fromOffset(TW2,5),pos=UDim2.new(1,-TW2-65,0.5,-2),parent=r,z=7})
    corner(trk,3)
    local fill=F({bg=Color3.new(1,1,1),sz=UDim2.fromOffset(0,5),parent=trk,z=8}); corner(fill,3)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.t2), ColorSequenceKeypoint.new(1, C.t0)})
    grad.Parent = fill
    local thumb=F({bg=hex"ffffff",sz=UDim2.fromOffset(13,13),pos=UDim2.new(0,-6,0.5,-6),parent=trk,z=9})
    corner(thumb,7)

    local numF=F({bg=C.bg0,sz=UDim2.fromOffset(40,24),pos=UDim2.new(1,-50,0.5,-12),parent=r,z=7})
    corner(numF,6); stroke(numF,C.bd1,1.5)
    local numL=Instance.new("TextBox")
    numL.BackgroundTransparency=1; numL.Text=tostring(def)..suffix; numL.TextColor3=C.t0
    numL.Font=Enum.Font.GothamBold; numL.TextSize=11; numL.Size=UDim2.fromScale(1,1); numL.Parent=numF; numL.ZIndex=8

    local drag=false
    local function updS(pct)
        pct=math.clamp(pct,0,1)
        local v=math.round(mn + pct*(mx-mn))
        numL.Text=tostring(v)..suffix
        fill.Size=UDim2.fromOffset(TW2*pct,5)
        thumb.Position=UDim2.new(0,TW2*pct-6,0.5,-6)
        if cb then cb(v) end
    end

    updS((def-mn)/(mx-mn))

    trk.InputBegan:Connect(function(inp)
        if isClick(inp) then drag=true; updS((inp.Position.X-trk.AbsolutePosition.X)/TW2) end
    end)
    trk.InputEnded:Connect(function(inp)
        if isClick(inp) then drag=false end
    end)
    numL.FocusLost:Connect(function()
        local cleaned = numL.Text:gsub(suffix,"")
        local val = tonumber(cleaned)
        if val then updS((val-mn)/(mx-mn)) else numL.Text = tostring(math.round(mn + (fill.Size.X.Offset/TW2)*(mx-mn)))..suffix end
    end)
    table.insert(self._window._connections, UserInputService.InputChanged:Connect(function(inp)
        if drag and isMove(inp) then updS((inp.Position.X-trk.AbsolutePosition.X)/TW2) end
    end))

    local comp = { Set = function(v) updS((v-mn)/(mx-mn)) end, Get = function() return math.round(mn + (fill.Size.X.Offset/TW2)*(mx-mn)) end }
    local flag = opts.Flag or title:gsub(" ","_"):lower()
    self._window._configurables[flag] = comp
    return comp
end

-- ════════════════════════════════════════
--  TAB: ADD DROPDOWN
-- ════════════════════════════════════════
function Tab:AddDropdown(opts)
    opts = opts or {}
    local title = opts.Title or "Dropdown"
    local options = opts.Options or {"Option 1","Option 2"}
    local isMulti = opts.Multi or false
    local default = opts.Default or (isMulti and {} or options[1])
    local cb = opts.Callback
    local fw = opts.Width

    local dr = F({bg=C.bg2,sz=UDim2.new(1,-24,0,46),parent=self._panel,z=6})
    corner(dr,11)
    dr.MouseEnter:Connect(function() tw(dr,{BackgroundColor3=C.bg3},0.12) end)
    dr.MouseLeave:Connect(function() tw(dr,{BackgroundColor3=C.bg2},0.16) end)

    L({text=title, color=C.t0, ts=11, font=Enum.Font.GothamBold,
       sz=UDim2.new(0,90,0,16), pos=UDim2.new(0,16,0,15), parent=dr, z=7})

    local initW = fw or 120
    local ddTrig=F({bg=C.bg1,sz=UDim2.fromOffset(initW,30),pos=UDim2.new(1,-initW-12,0,8),parent=dr,z=7})
    corner(ddTrig,6); stroke(ddTrig,C.bd0,1)
    
    local state = isMulti and (type(default)=="table" and default or {default}) or default
    local function getDisplayText()
        if not isMulti then return state end
        if #state == 0 then return "None" end
        if #state == 1 then return state[1] end
        if #state <= 2 then return table.concat(state, ", ") end
        return tostring(#state) .. " Selected"
    end

    local ddL=L({text=getDisplayText(),color=C.t0,ts=11,font=Enum.Font.GothamBold,
        sz=UDim2.new(1,-40,1,0),pos=UDim2.new(0,12,0,0),parent=ddTrig,z=8})
    ddL.ClipsDescendants = true
    local ddArr=L({text="▼",color=C.t0,ts=14,font=Enum.Font.Arial,xa=Enum.TextXAlignment.Center,
       sz=UDim2.fromOffset(20,20),pos=UDim2.new(1,-26,0.5,-10),parent=ddTrig,z=8})

    local ddOpen=false
    local ddList=F({bg=C.bg1,sz=UDim2.fromOffset(initW,0),parent=self._sg,z=50,clip=true})
    corner(ddList,6); stroke(ddList,C.bd0,1)
    ddList.Visible=false

    local ddb=B({bg=hex"000000",sz=UDim2.fromScale(1,1),parent=ddTrig,z=9})
    ddb.BackgroundTransparency=1

    local function updDropPos()
        local p = ddTrig.AbsolutePosition
        ddList.Position = UDim2.fromOffset(p.X, p.Y + ddTrig.AbsoluteSize.Y + 4)
    end

    local itemBtns = {}

    local function populate()
        for _,ch in ipairs(ddList:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end
        table.clear(itemBtns)
        local opts2 = type(options)=="function" and options() or options
        if #opts2==0 then return 0, initW end
        local ddW = fw or 120
        if not fw then
            for _,opt in ipairs(opts2) do
                local b = TextService:GetTextSize(opt, 11, Enum.Font.GothamBold, Vector2.new(1000, 20))
                if b.X + 48 > ddW then ddW = b.X + 48 end
            end
            ddW = math.clamp(ddW, 120, 300)
        end
        ddTrig.Size = UDim2.fromOffset(ddW,30)
        ddTrig.Position = UDim2.new(1,-ddW-12,0,8)
        local h = #opts2*30+8
        for i,opt in ipairs(opts2) do
            local isSel = false
            if isMulti then
                isSel = table.find(state, opt) ~= nil
            else
                isSel = (state == opt)
            end

            local item=B({bg=isSel and C.bg2 or C.bg1,text=opt,color=isSel and C.t0 or C.t1,ts=11,font=Enum.Font.GothamBold,
                sz=UDim2.new(1,-10,0,28),pos=UDim2.new(0,5,0,(i-1)*30+4),parent=ddList,z=51,xa=Enum.TextXAlignment.Left})
            corner(item,5)
            itemBtns[opt] = item
            
            item.MouseEnter:Connect(function() if ddOpen then tw(item,{BackgroundColor3=C.bg2,TextColor3=C.t0},0.1) end end)
            item.MouseLeave:Connect(function()
                if ddOpen then
                    local s = isMulti and table.find(state, opt) or (state == opt)
                    tw(item,{BackgroundColor3=s and C.bg2 or C.bg1,TextColor3=s and C.t0 or C.t1},0.1)
                end
            end)
            item.MouseButton1Click:Connect(function()
                if not ddOpen then return end
                if isMulti then
                    local idx = table.find(state, opt)
                    if idx then table.remove(state, idx) else table.insert(state, opt) end
                    ddL.Text = getDisplayText()
                    tw(item,{BackgroundColor3=table.find(state, opt) and C.bg2 or C.bg1,TextColor3=table.find(state, opt) and C.t0 or C.t1},0.1)
                    if cb then cb(state) end
                else
                    state = opt
                    ddL.Text = opt
                    ddOpen = false
                    ddArr.Text = "▼"
                    fadeDrop(ddList, true)
                    task.delay(0.25, function() if not ddOpen then ddList.Visible=false end end)
                    if cb then cb(state) end
                    -- Update visual colors for others
                    for o, btn in pairs(itemBtns) do
                        tw(btn,{BackgroundColor3=o==state and C.bg2 or C.bg1,TextColor3=o==state and C.t0 or C.t1},0.1)
                    end
                end
            end)
        end
        return h, ddW
    end

    ddb.MouseButton1Click:Connect(function()
        ddOpen=not ddOpen
        if ddOpen then
            local h, w = populate()
            if h==0 then ddOpen=false; return end
            updDropPos(); fadeDrop(ddList, false, nil)
            ddList.Visible=true; ddArr.Text="▲"
            ddList.Size=UDim2.fromOffset(w,0)
            tw(ddList,{Size=UDim2.fromOffset(w,h)},0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        else
            ddArr.Text="▼"; fadeDrop(ddList, true)
            task.delay(0.25, function() if not ddOpen then ddList.Visible=false end end)
        end
    end)

    self._panel = self._panel or self._panel
    if self._panel and self._panel.ClassName == "ScrollingFrame" then
        self._panel:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if ddOpen then updDropPos() end
        end)
    end

    populate()

    local comp = {
        Set = function(v) 
            if type(v) == "string" and v == "--" then
                -- This is a special edge case for empty string in generic string dropdowns
                if not isMulti then state = v; ddL.Text = v end
            else
                state = isMulti and (type(v)=="table" and v or {v}) or v
                ddL.Text = getDisplayText()
                if cb then cb(state) end 
            end
        end,
        Get = function() return state end,
        Refresh = function(newOpts) options = newOpts; populate() end,
    }
    local flag = opts.Flag or title:gsub(" ","_"):lower()
    self._window._configurables[flag] = comp
    return comp
end

-- ════════════════════════════════════════
--  TAB: ADD KEYBIND
-- ════════════════════════════════════════
function Tab:AddKeybind(opts)
    opts = opts or {}
    local title = opts.Title or "Keybind"
    local default = opts.Default or "RightShift"
    local cb = opts.Callback

    local r = F({bg=C.bg2,sz=UDim2.new(1,-24,0,36),parent=self._panel,z=6})
    corner(r,11)
    r.MouseEnter:Connect(function() tw(r,{BackgroundColor3=C.bg3},0.12) end)
    r.MouseLeave:Connect(function() tw(r,{BackgroundColor3=C.bg2},0.16) end)

    L({text=title,color=C.t0,ts=11,font=Enum.Font.GothamBold,
       sz=UDim2.new(1,-140,0,16),pos=UDim2.new(0,16,0.5,-8),parent=r,z=7})

    local kbF=F({bg=C.bg0,sz=UDim2.fromOffset(120,24),pos=UDim2.new(1,-132,0.5,-12),parent=r,z=7})
    corner(kbF,6); stroke(kbF,C.bd1,1)
    local kbL=L({text=default,color=C.t0,ts=11,font=Enum.Font.GothamBold,
        xa=Enum.TextXAlignment.Center,sz=UDim2.fromScale(1,1),parent=kbF,z=8})
    local listening=false
    local kbb=B({bg=hex"000000",sz=UDim2.fromScale(1,1),parent=kbF,z=9})
    kbb.BackgroundTransparency=1
    kbb.MouseButton1Click:Connect(function()
        if listening then return end
        listening=true; kbL.Text="···"; kbL.TextColor3=C.t2
        local conn; conn=UserInputService.InputBegan:Connect(function(inp,gpe)
            if gpe then return end
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                local nm=inp.KeyCode.Name
                kbL.Text=nm; kbL.TextColor3=C.t0
                listening=false; conn:Disconnect()
                if cb then cb(inp.KeyCode) end
            end
        end)
    end)
end

-- ════════════════════════════════════════
--  TAB: ADD PARAGRAPH
-- ════════════════════════════════════════
function Tab:AddParagraph(opts)
    opts = opts or {}
    local title = opts.Title or ""
    local content = opts.Content or ""

    local r = F({bg=C.bg2,sz=UDim2.new(1,-24,0,50),parent=self._panel,z=6})
    corner(r,11)

    if title ~= "" then
        L({text=title,color=C.t0,ts=13,font=Enum.Font.GothamBold,
           sz=UDim2.new(1,-32,0,16),pos=UDim2.new(0,16,0,8),parent=r,z=7})
    end
    if content ~= "" then
        local cL = L({text=content,color=C.t1,ts=11,font=Enum.Font.GothamMedium,
           sz=UDim2.new(1,-32,0,0),pos=UDim2.new(0,16,0,title~="" and 26 or 8),parent=r,z=7})
        cL.TextWrapped = true
        cL.AutomaticSize = Enum.AutomaticSize.Y
        task.defer(function()
            r.Size = UDim2.new(1,-24,0,(title~="" and 26 or 8) + cL.AbsoluteSize.Y + 10)
        end)
    end
end

-- ════════════════════════════════════════
--  TAB: ADD TEXTBOX
-- ════════════════════════════════════════
function Tab:AddTextbox(opts)
    opts = opts or {}
    local title = opts.Title or "Input"
    local placeholder = opts.Placeholder or ""
    local cb = opts.Callback

    local r = F({bg=C.bg2,sz=UDim2.new(1,-24,0,36),parent=self._panel,z=6})
    corner(r,11)
    r.MouseEnter:Connect(function() tw(r,{BackgroundColor3=C.bg3},0.12) end)
    r.MouseLeave:Connect(function() tw(r,{BackgroundColor3=C.bg2},0.16) end)

    L({text=title,color=C.t0,ts=11,font=Enum.Font.GothamBold,
       sz=UDim2.new(0.5,-16,0,16),pos=UDim2.new(0,16,0.5,-8),parent=r,z=7})

    local box = Instance.new("TextBox")
    box.BackgroundColor3 = C.bg0; box.BorderSizePixel = 0
    box.PlaceholderText = placeholder; box.Text = ""
    box.TextColor3 = C.t1; box.PlaceholderColor3 = C.t2
    box.Font = Enum.Font.GothamBold; box.TextSize = 13
    box.TextXAlignment = Enum.TextXAlignment.Center
    box.Size = UDim2.fromOffset(120,24)
    box.Position = UDim2.new(1,-132,0.5,-12)
    box.ZIndex = 7; box.Parent = r
    corner(box,6); stroke(box,C.bd1,1)

    box.FocusLost:Connect(function()
        if cb then cb(box.Text) end
    end)

    local comp = {
        Get = function() return box.Text end,
        Set = function(v) box.Text = v; if cb then cb(v) end end,
    }
    local flag = opts.Flag or title:gsub(" ","_"):lower()
    self._window._configurables[flag] = comp
    return comp
end

-- ════════════════════════════════════════
--  WINDOW INTERNALS
-- ════════════════════════════════════════
function Window:_switchTab(id)
    for k,p in pairs(self._panelMap) do p.Visible=(k==id) end
    for k,nd in pairs(self._navBtns) do
        local on=(k==id)
        tw(nd.btn,{BackgroundTransparency=on and 0 or 1, BackgroundColor3=on and C.bg2 or C.bg0},0.14)
        tw(nd.lbl,{TextColor3=on and C.t0 or C.t2},0.14)
        if nd.img then
            if nd.img:IsA("ImageLabel") then
                tw(nd.img,{ImageColor3=on and C.t0 or C.t2},0.14)
            elseif nd.img:IsA("TextLabel") then
                tw(nd.img,{TextColor3=on and C.t0 or C.t2},0.14)
            end
        end
    end
    self._activeTab=id
end

function Window:_closeApp()
    local win = self._win
    local sg = self._sg
    
    local cx = win.Position.X.Offset + self._WW/2
    local cy = win.Position.Y.Offset + self._WH/2
    
    tw(win, {
        Size=UDim2.fromOffset(self._WW*0.3, self._WH*0.3),
        Position=UDim2.new(win.Position.X.Scale, cx - self._WW*0.15, win.Position.Y.Scale, cy - self._WH*0.15),
        BackgroundTransparency=1
    }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    
    for _,ch in ipairs(win:GetDescendants()) do
        pcall(function()
            if ch:IsA("GuiObject") then tw(ch,{BackgroundTransparency=1},0.2) end
            if ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox") then tw(ch,{TextTransparency=1},0.2) end
            if ch:IsA("ImageLabel") or ch:IsA("ImageButton") then tw(ch,{ImageTransparency=1},0.2) end
            if ch:IsA("UIStroke") then tw(ch,{Transparency=1},0.2) end
            if ch:IsA("ScrollingFrame") then tw(ch,{ScrollBarImageTransparency=1},0.2) end
        end)
    end
    
    task.delay(0.35, function()
        for _, c in ipairs(self._connections) do
            if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
        end
        sg:Destroy()
    end)
end

function Window:_setupDrag(tbar, win)
    local dragging,ds,sp=false
    tbar.InputBegan:Connect(function(inp)
        if isClick(inp) then dragging=true; ds=inp.Position; sp=win.Position end
    end)
    tbar.InputEnded:Connect(function(inp)
        if isClick(inp) then dragging=false end
    end)
    table.insert(self._connections, UserInputService.InputChanged:Connect(function(inp)
        if dragging and isMove(inp) then
            local d=inp.Position-ds
            win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end))
end

function Window:_setupResize(win)
    local rGrip = B({bg=C.bg1, sz=UDim2.fromOffset(20,20), pos=UDim2.new(1,-20,1,-20), parent=win, z=30})
    rGrip.BackgroundTransparency = 1
    L({text="◢", color=C.t1, ts=14, sz=UDim2.fromScale(1,1), parent=rGrip, z=31, xa=Enum.TextXAlignment.Center})
    local resizing,rStartPos,rStartSize = false
    rGrip.InputBegan:Connect(function(inp)
        if isClick(inp) then resizing=true; rStartPos=inp.Position; rStartSize=win.AbsoluteSize end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if isClick(inp) then resizing=false end
    end)
    table.insert(self._connections, UserInputService.InputChanged:Connect(function(inp)
        if resizing and isMove(inp) then
            local delta = inp.Position - rStartPos
            local newW = math.clamp(rStartSize.X + delta.X, 300, 1000)
            local newH = math.clamp(rStartSize.Y + delta.Y, 250, 800)
            win.Size = UDim2.fromOffset(newW, newH)
            self._WW, self._WH = newW, newH
        end
    end))
end

function Window:_setupMobileToggle(sg, win, logoId)
    local mToggle = Instance.new("ImageButton")
    mToggle.Size = UDim2.fromOffset(42, 42)
    mToggle.AnchorPoint = Vector2.new(0.5, 0)
    mToggle.Position = UDim2.new(0.5, 0, 0, 12)
    mToggle.BackgroundColor3 = hex"222222"
    mToggle.BackgroundTransparency = 0.5
    mToggle.BorderSizePixel = 0
    mToggle.AutoButtonColor = false
    mToggle.Active = true
    mToggle.Selectable = true
    corner(mToggle, 21)
    mToggle.ClipsDescendants = true
    mToggle.Parent = sg
    mToggle.ZIndex = 999

    if logoId then
        local mLogo = Instance.new("ImageLabel")
        mLogo.BackgroundTransparency = 1
        mLogo.Size = UDim2.fromOffset(70,70)
        mLogo.Position = UDim2.new(0.5, -35, 0.5, -35)
        mLogo.Image = "rbxthumb://type=Asset&id="..tostring(logoId).."&w=420&h=420"
        mLogo.Parent = mToggle
    else
        L({text="Z",color=C.t0,ts=16,font=Enum.Font.GothamBold,
           xa=Enum.TextXAlignment.Center,sz=UDim2.fromScale(1,1),parent=mToggle,z=1000})
    end

    local tDrag, tStartPos, tDragStart, clickTime = false, nil, nil, 0
    table.insert(self._connections, mToggle.InputBegan:Connect(function(inp)
        if isClick(inp) then
            tDrag=true; tDragStart=inp.Position; tStartPos=mToggle.Position; clickTime=tick()
        end
    end))
    table.insert(self._connections, mToggle.InputEnded:Connect(function(inp)
        if isClick(inp) then
            tDrag=false
            if tick()-clickTime < 0.2 then self:_toggleMinimize() end
        end
    end))
    table.insert(self._connections, UserInputService.InputChanged:Connect(function(inp)
        if tDrag and isMove(inp) then
            local delta = inp.Position - tDragStart
            mToggle.Position = UDim2.new(
                tStartPos.X.Scale, tStartPos.X.Offset + delta.X,
                tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y
            )
        end
    end))
end


function Window:_toggleMinimize()
    local win = self._win
    if self._minimized then
        -- Restore: appear from center
        win.Visible = true
        local targetPos = self._origPos or UDim2.new(0.5,-self._WW/2,0.5,-self._WH/2)
        local targetSize = self._origSize or UDim2.fromOffset(self._WW, self._WH)
        tw(win, {Size=targetSize, Position=targetPos, BackgroundTransparency=0}, 0.3, Enum.EasingStyle.Back)
        for _,ch in ipairs(win:GetDescendants()) do
            pcall(function()
                if ch:IsA("GuiObject") then tw(ch,{BackgroundTransparency=ch:GetAttribute("_savedBT") or 0},0.2) end
                if ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox") then tw(ch,{TextTransparency=0},0.2) end
                if ch:IsA("ImageLabel") or ch:IsA("ImageButton") then tw(ch,{ImageTransparency=0},0.2) end
                if ch:IsA("UIStroke") then tw(ch,{Transparency=0},0.2) end
                if ch:IsA("ScrollingFrame") then tw(ch,{ScrollBarImageTransparency=0},0.2) end
            end)
        end
        self._minimized = false
    else
        -- Minimize: shrink to center and fade
        self._origPos = win.Position
        self._origSize = win.Size
        -- Save current transparencies
        for _,ch in ipairs(win:GetDescendants()) do
            pcall(function()
                if ch:IsA("GuiObject") then ch:SetAttribute("_savedBT", ch.BackgroundTransparency) end
            end)
        end
        local cx = win.Position.X.Offset + self._WW/2
        local cy = win.Position.Y.Offset + self._WH/2
        tw(win, {
            Size=UDim2.fromOffset(self._WW*0.3, self._WH*0.3),
            Position=UDim2.new(win.Position.X.Scale, cx - self._WW*0.15, win.Position.Y.Scale, cy - self._WH*0.15),
            BackgroundTransparency=1
        }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        for _,ch in ipairs(win:GetDescendants()) do
            pcall(function()
                if ch:IsA("GuiObject") then tw(ch,{BackgroundTransparency=1},0.2) end
                if ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox") then tw(ch,{TextTransparency=1},0.2) end
                if ch:IsA("ImageLabel") or ch:IsA("ImageButton") then tw(ch,{ImageTransparency=1},0.2) end
                if ch:IsA("UIStroke") then tw(ch,{Transparency=1},0.2) end
                if ch:IsA("ScrollingFrame") then tw(ch,{ScrollBarImageTransparency=1},0.2) end
            end)
        end
        task.delay(0.3, function() win.Visible = false end)
        self._minimized = true
    end
end
-- ════════════════════════════════════════
--  NOTIFICATION
-- ════════════════════════════════════════
function Window:Notify(opts)
    opts = opts or {}
    local title = opts.Title or "Notification"
    local content = opts.Content or ""
    local duration = opts.Duration or 5

    local nf = F({bg=C.bg2,sz=UDim2.fromOffset(280,60),pos=UDim2.new(1,300,1,-80),parent=self._sg,z=100})
    corner(nf,10); stroke(nf,C.bd1,1)
    L({text=title,color=C.t0,ts=12,font=Enum.Font.GothamBold,
       sz=UDim2.new(1,-20,0,16),pos=UDim2.new(0,12,0,10),parent=nf,z=101})
    L({text=content,color=C.t1,ts=10,font=Enum.Font.GothamMedium,
       sz=UDim2.new(1,-20,0,14),pos=UDim2.new(0,12,0,30),parent=nf,z=101})

    tw(nf, {Position=UDim2.new(1,-300,1,-80)}, 0.4, Enum.EasingStyle.Back)
    if duration > 0 then
        task.delay(duration, function()
            tw(nf, {Position=UDim2.new(1,300,1,-80)}, 0.3)
            task.delay(0.35, function() nf:Destroy() end)
        end)
    end
end

return ZiiqLib
