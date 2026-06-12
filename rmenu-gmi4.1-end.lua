local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local Interface = {}
Interface.__index = Interface

local FONT_MAIN = Enum.Font.Gotham
local FONT_PIXEL = Enum.Font.Arcade
local PURPLE_ACCENT = Color3.fromRGB(145, 125, 190)
local COLOR_INACTIVE = Color3.fromRGB(120, 120, 120)
local COLOR_BG_DARK = Color3.fromRGB(12, 12, 12)
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

function Interface.new()
    local self = setmetatable({}, Interface)
    self.Colors = { Main = Color3.fromRGB(20, 20, 20), Accent = PURPLE_ACCENT }
    self.Enabled = false
    self.CurrentTab = nil
    self.Connections = {}
    
    self:BuildBase()
    self:SetupInput()
    return self
end

function Interface:Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self.Connections, connection)
    return connection
end

local function Tween(obj, props)
    TweenService:Create(obj, TWEEN_INFO, props):Play()
end

function Interface:BuildBase()
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "gmi41endrmenu"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = game:GetService("CoreGui")
    
    self.Blur = Instance.new("BlurEffect", Lighting)
    self.Blur.Size = 0
    
    self.MainFrame = Instance.new("CanvasGroup", self.ScreenGui)
    self.MainFrame.Size = UDim2.new(0, 750, 0, 520)
    self.MainFrame.Position = UDim2.new(0.5, -375, 0.5, -260)
    self.MainFrame.BackgroundColor3 = self.Colors.Main
    self.MainFrame.BackgroundTransparency = 0.15
    self.MainFrame.GroupTransparency = 1
    self.MainFrame.Visible = false
    
    Instance.new("UIStroke", self.MainFrame).Color = Color3.fromRGB(0, 0, 0)

    local TopLine = Instance.new("Frame", self.MainFrame)
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.BackgroundColor3 = self.Colors.Accent
    TopLine.BorderSizePixel = 0

    self.TabHolder = Instance.new("Frame", self.MainFrame)
    self.TabHolder.Size = UDim2.new(1, 0, 0, 45)
    self.TabHolder.Position = UDim2.new(0, 0, 0, 2)
    self.TabHolder.BackgroundTransparency = 1
    
    local TabList = Instance.new("UIListLayout", self.TabHolder)
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.VerticalAlignment = Enum.VerticalAlignment.Center
    TabList.Padding = UDim.new(0, 60)

    self.Container = Instance.new("Frame", self.MainFrame)
    self.Container.Size = UDim2.new(1, -20, 1, -70)
    self.Container.Position = UDim2.new(0, 10, 0, 60)
    self.Container.BackgroundTransparency = 1
end

function Interface:SetupInput()
    self:Connect(UserInputService.InputBegan, function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            self.Enabled = not self.Enabled
            if self.Enabled then
                self.MainFrame.Visible = true
                Tween(self.MainFrame, {GroupTransparency = 0})
                Tween(self.Blur, {Size = 20})
            else
                local t = TweenService:Create(self.MainFrame, TWEEN_INFO, {GroupTransparency = 1})
                t:Play()
                Tween(self.Blur, {Size = 0})
                t.Completed:Connect(function() if not self.Enabled then self.MainFrame.Visible = false end end)
            end
        end
    end)
end

function Interface:AddTab(name)
    local TabBtn = Instance.new("TextButton", self.TabHolder)
    TabBtn.Size = UDim2.new(0, 0, 1, 0); TabBtn.AutomaticSize = Enum.AutomaticSize.X
    TabBtn.BackgroundTransparency = 1; TabBtn.Text = name:upper()
    TabBtn.Font = FONT_PIXEL; TabBtn.TextSize = 16; TabBtn.TextColor3 = COLOR_INACTIVE
    
    local TabPage = Instance.new("CanvasGroup", self.Container)
    TabPage.Size = UDim2.new(1, 0, 1, 0); TabPage.BackgroundTransparency = 1
    TabPage.Visible = false; TabPage.GroupTransparency = 1
    
    local Scroll = Instance.new("ScrollingFrame", TabPage)
    Scroll.Size = UDim2.new(1, 0, 1, 0); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 0
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.CanvasSize = UDim2.new(0,0,0,0)
    
    local ColumnsWrapper = Instance.new("Frame", Scroll)
    ColumnsWrapper.Size = UDim2.new(1, 0, 0, 0); ColumnsWrapper.AutomaticSize = Enum.AutomaticSize.Y
    ColumnsWrapper.BackgroundTransparency = 1
    local clw = Instance.new("UIListLayout", ColumnsWrapper)
    clw.FillDirection = Enum.FillDirection.Horizontal; clw.Padding = UDim.new(0, 10)
    
    local Cols = {}
    for i = 1, 3 do
        local Col = Instance.new("Frame", ColumnsWrapper)
        Col.Size = UDim2.new(0.33, -7, 0, 0); Col.AutomaticSize = Enum.AutomaticSize.Y; Col.BackgroundTransparency = 1
        Instance.new("UIListLayout", Col).Padding = UDim.new(0, 20)
        Instance.new("UIPadding", Col).PaddingTop = UDim.new(0, 15)
        Cols[i] = Col
    end

    TabBtn.MouseButton1Click:Connect(function()
        if self.CurrentTab == TabBtn then return end
        for _, v in pairs(self.Container:GetChildren()) do if v:IsA("CanvasGroup") then v.Visible = false; v.GroupTransparency = 1 end end
        for _, v in pairs(self.TabHolder:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = COLOR_INACTIVE end end
        self.CurrentTab = TabBtn; TabPage.Visible = true
        Tween(TabPage, {GroupTransparency = 0}); Tween(TabBtn, {TextColor3 = self.Colors.Accent})
    end)
    
    if #self.TabHolder:GetChildren() == 2 then self.CurrentTab = TabBtn; TabPage.Visible = true; TabPage.GroupTransparency = 0; TabBtn.TextColor3 = self.Colors.Accent end
    
    local sectorIdx = 0
    return {
        AddSector = function(sectorName)
            sectorIdx = sectorIdx + 1
            local targetCol = Cols[((sectorIdx - 1) % 3) + 1]
            
            local SectorFrame = Instance.new("Frame", targetCol)
            SectorFrame.Size = UDim2.new(1, 0, 0, 0); SectorFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectorFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0); SectorFrame.BackgroundTransparency = 0.96; SectorFrame.BorderColor3 = Color3.fromRGB(45, 45, 45)
            
            local Title = Instance.new("TextLabel", SectorFrame)
            Title.Text = " " .. sectorName:upper() .. " "; Title.Font = FONT_PIXEL; Title.TextSize = 14
            Title.TextColor3 = PURPLE_ACCENT; Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            Title.AutomaticSize = Enum.AutomaticSize.X; Title.Position = UDim2.new(0.5, 0, 0, -8); Title.AnchorPoint = Vector2.new(0.5, 0); Title.ZIndex = 5

            local Content = Instance.new("Frame", SectorFrame)
            Content.Position = UDim2.new(0, 8, 0, 12); Content.Size = UDim2.new(1, -16, 0, 0); Content.AutomaticSize = Enum.AutomaticSize.Y; Content.BackgroundTransparency = 1
            
            local cl = Instance.new("UIListLayout", Content)
            cl.Padding = UDim.new(0, 8)
            cl.SortOrder = Enum.SortOrder.LayoutOrder
            
            Instance.new("UIPadding", Content).PaddingBottom = UDim.new(0, 10)
            return Content
        end
    }
end

function Interface:AddToggle(sector, text, callback)
    local Box = Instance.new("TextButton", sector)
    Box.Name = "Toggle_" .. text
    Box.LayoutOrder = #sector:GetChildren()
    Box.Size = UDim2.new(1, 0, 0, 18); Box.BackgroundTransparency = 1; Box.Text = ""; Box.AutoButtonColor = false
    
    local Ind = Instance.new("Frame", Box)
    Ind.Size = UDim2.new(0, 12, 0, 12); Ind.Position = UDim2.new(0, 0, 0.5, -6); Ind.BackgroundColor3 = COLOR_BG_DARK; Ind.BorderColor3 = Color3.fromRGB(0,0,0)
    
    local Label = Instance.new("TextLabel", Box)
    Label.Position = UDim2.new(0, 20, 0, 0); Label.Size = UDim2.new(1, -20, 1, 0)
    Label.Text = text; Label.Font = FONT_MAIN; Label.TextSize = 13; Label.TextColor3 = COLOR_INACTIVE
    Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1
    
    local on = false
    Box.MouseButton1Click:Connect(function()
        on = not on
        Tween(Ind, {BackgroundColor3 = on and PURPLE_ACCENT or COLOR_BG_DARK})
        Tween(Label, {TextColor3 = on and Color3.fromRGB(255,255,255) or COLOR_INACTIVE})
        callback(on)
    end)
end

function Interface:AddButton(sector, text, callback)
    local Btn = Instance.new("TextButton", sector)
    Btn.LayoutOrder = #sector:GetChildren()
    Btn.Size = UDim2.new(1, 0, 0, 22); Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Btn.BackgroundTransparency = 0.3
    Btn.BorderColor3 = Color3.fromRGB(0,0,0); Btn.Text = text:upper(); Btn.Font = FONT_PIXEL; Btn.TextSize = 13
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200); Btn.AutoButtonColor = false
    
    Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}) end)
    Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}) end)
    Btn.MouseButton1Click:Connect(function()
        local original = Btn.BackgroundColor3
        Tween(Btn, {BackgroundColor3 = PURPLE_ACCENT})
        task.delay(0.1, function() Tween(Btn, {BackgroundColor3 = original}) end)
        callback()
    end)
end

function Interface:AddSlider(sector, text, min, max, def, callback)
    local Frame = Instance.new("Frame", sector)
    Frame.LayoutOrder = #sector:GetChildren()
    Frame.Size = UDim2.new(1, 0, 0, 32); Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame); Label.Size = UDim2.new(1, 0, 0, 14); Label.Text = text
    Label.Font = FONT_MAIN; Label.TextSize = 12; Label.TextColor3 = COLOR_INACTIVE; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1
    
    local Main = Instance.new("TextButton", Frame); Main.Size = UDim2.new(1, 0, 0, 8); Main.Position = UDim2.new(0, 0, 0, 18)
    Main.BackgroundColor3 = COLOR_BG_DARK; Main.BorderColor3 = Color3.fromRGB(0,0,0); Main.Text = ""; Main.AutoButtonColor = false
    
    local Fill = Instance.new("Frame", Main); Fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = PURPLE_ACCENT; Fill.BorderSizePixel = 0

    local function update(input)
        local p = math.clamp((input.Position.X - Main.AbsolutePosition.X) / Main.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(p, 0, 1, 0)
        callback(math.floor(min + (max-min)*p))
    end
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local move = UserInputService.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
            local release; release = UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() release:Disconnect() end end)
            update(input)
        end
    end)
end

function Interface:AddDropdown(sector, text, options, multi, callback)
    local Frame = Instance.new("Frame", sector)
    Frame.LayoutOrder = #sector:GetChildren()
    Frame.Size = UDim2.new(1, 0, 0, 38)
    Frame.BackgroundTransparency = 1
    Frame.ZIndex = 1

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, 0, 0, 14)
    Label.Text = text
    Label.Font = FONT_MAIN
    Label.TextSize = 12
    Label.TextColor3 = COLOR_INACTIVE
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    
    local Main = Instance.new("TextButton", Frame)
    Main.Size = UDim2.new(1, 0, 0, 20)
    Main.Position = UDim2.new(0, 0, 0, 18)
    Main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Main.BackgroundTransparency = 0.3
    Main.BorderColor3 = Color3.fromRGB(0,0,0)
    Main.Text = "None"
    Main.Font = FONT_MAIN
    Main.TextSize = 12
    Main.TextColor3 = Color3.fromRGB(200,200,200)
    Main.AutoButtonColor = false
    Main.ZIndex = 2
    
    local List = Instance.new("Frame", Main)
    List.Size = UDim2.new(1, 0, 0, 0)
    List.Position = UDim2.new(0, 0, 1, 1)
    List.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    List.BorderColor3 = Color3.fromRGB(0,0,0)
    List.Visible = false
    List.ClipsDescendants = true
    List.ZIndex = 10
    
    local ll = Instance.new("UIListLayout", List)
    ll.SortOrder = Enum.SortOrder.LayoutOrder

    local selected = {}
    local function updateDisplay()
        local res = {}
        for k, v in pairs(selected) do if v then table.insert(res, k) end end
        Main.Text = #res > 0 and table.concat(res, ", ") or "None"
        callback(multi and selected or res[1])
    end

    local open = false
    Main.MouseButton1Click:Connect(function()
        open = not open
        
        Frame.ZIndex = open and 100 or 1
        
        if open then
            List.Visible = true
            Tween(List, {Size = UDim2.new(1, 0, 0, ll.AbsoluteContentSize.Y)})
        else
            local t = TweenService:Create(List, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, 0)})
            t:Play()
            t.Completed:Connect(function() if not open then List.Visible = false end end)
        end
    end)

    for i, opt in pairs(options) do
        local OptBtn = Instance.new("TextButton", List)
        OptBtn.LayoutOrder = i
        OptBtn.Size = UDim2.new(1, 0, 0, 20)
        OptBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = opt
        OptBtn.Font = FONT_MAIN
        OptBtn.TextSize = 12
        OptBtn.TextColor3 = COLOR_INACTIVE
        OptBtn.ZIndex = 11
        OptBtn.AutoButtonColor = false
        
        OptBtn.MouseButton1Click:Connect(function()
            if multi then
                selected[opt] = not selected[opt]
            else
                selected = {[opt] = true}
                open = false
                Frame.ZIndex = 1
                Tween(List, {Size = UDim2.new(1, 0, 0, 0)})
                task.delay(0.2, function() List.Visible = false end)
            end
            
            for _, btn in pairs(List:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, {TextColor3 = selected[btn.Text] and PURPLE_ACCENT or COLOR_INACTIVE})
                end
            end
            updateDisplay()
        end)
    end
end

function Interface:AddTextBox(sector, text, placeholder, callback)
    local Frame = Instance.new("Frame", sector)
    Frame.LayoutOrder = #sector:GetChildren()
    Frame.Size = UDim2.new(1, 0, 0, 38); Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame); Label.Size = UDim2.new(1, 0, 0, 14); Label.Text = text; Label.Font = FONT_MAIN
    Label.TextSize = 12; Label.TextColor3 = COLOR_INACTIVE; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1
    
    local Box = Instance.new("TextBox", Frame); Box.Size = UDim2.new(1, 0, 0, 20); Box.Position = UDim2.new(0, 0, 0, 18)
    Box.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Box.BackgroundTransparency = 0.3; Box.BorderColor3 = Color3.fromRGB(0,0,0)
    Box.Text = ""; Box.PlaceholderText = placeholder; Box.Font = FONT_MAIN; Box.TextSize = 12; Box.TextColor3 = Color3.fromRGB(255,255,255)
    
    Box.FocusLost:Connect(function(enter) if enter then callback(Box.Text) end end)
end

function Interface:AddKeybind(sector, text, default, callback)
    local Frame = Instance.new("Frame", sector)
    Frame.LayoutOrder = #sector:GetChildren()
    Frame.Size = UDim2.new(1, 0, 0, 18); Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame); Label.Size = UDim2.new(1, 0, 1, 0); Label.Text = text; Label.Font = FONT_MAIN
    Label.TextSize = 13; Label.TextColor3 = COLOR_INACTIVE; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1
    
    local BindBtn = Instance.new("TextButton", Frame); BindBtn.Size = UDim2.new(0, 50, 1, 0); BindBtn.Position = UDim2.new(1, -50, 0, 0)
    BindBtn.BackgroundTransparency = 1; BindBtn.Text = "["..default.Name.."]"; BindBtn.Font = FONT_PIXEL; BindBtn.TextSize = 13; BindBtn.TextColor3 = PURPLE_ACCENT; BindBtn.TextXAlignment = Enum.TextXAlignment.Right
    
    local binding = false
    BindBtn.MouseButton1Click:Connect(function() binding = true; BindBtn.Text = "[...]" end)
    
    self:Connect(UserInputService.InputBegan, function(input)
        if binding and input.UserInputType == Enum.UserInputType.Keyboard then
            binding = false; BindBtn.Text = "["..input.KeyCode.Name.."]"; callback(input.KeyCode)
        end
    end)
end

function Interface:Unload()
    for _, connection in ipairs(self.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    self.Connections = {}

    if self.Blur then
        TweenService:Create(self.Blur, TweenInfo.new(0.5), {Size = 0}):Play()
        task.delay(0.5, function() self.Blur:Destroy() end)
    end

    if self.MainFrame then
        local t = TweenService:Create(self.MainFrame, TWEEN_INFO, {GroupTransparency = 1, Size = UDim2.new(0, 700, 0, 480)})
        t:Play()
        t.Completed:Connect(function()
            self.ScreenGui:Destroy()
        end)
    else
        self.ScreenGui:Destroy()
    end
    
    -- Очищаем ссылку на объект
    setmetatable(self, nil)
end

return Interface
