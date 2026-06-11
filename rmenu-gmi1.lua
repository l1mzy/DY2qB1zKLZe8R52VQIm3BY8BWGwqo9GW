local Interface = {}
Interface.__index = Interface

Interface = {
    Service = {
        Tween = game:GetService("TweenService"),
        UserInput = game:GetService("UserInputService"),
        CoreGui = game:GetService("CoreGui"),
        Lighting = game:GetService("Lighting"),
        Run = game:GetService("RunService"),
        Players = game:GetService("Players")
    },
    
    Theme = {
        Main = Color3.fromRGB(12, 12, 12),
        Outline = Color3.fromRGB(45, 45, 45),
        Accent = Color3.fromRGB(150, 100, 255),
        TextActive = Color3.fromRGB(255, 255, 255),
        TextInactive = Color3.fromRGB(140, 140, 140),
        SectionBG = Color3.fromRGB(20, 20, 20),
        ElementBG = Color3.fromRGB(28, 28, 28),
        Font = Enum.Font.Arcade 
    },
    
    Tabs = {},
    Connections = {}, 
    IsVisible = true,
    IsDestroyed = false,
    Root = nil,
    MainFrame = nil,
    Blur = nil
}

function Interface:Init(title)
    if self.Root then self:Destroy() end

    self.Root = Instance.new("ScreenGui")
    self.Root.Name = "UI_PistolArena_v2"
    self.Root.Parent = self.Service.Players.LocalPlayer:WaitForChild("PlayerGui")
    self.Root.IgnoreGuiInset = true
    self.Root.ResetOnSpawn = false
    self.Root.DisplayOrder = 999999999

    self.Blur = Instance.new("BlurEffect")
    self.Blur.Size = 10
    self.Blur.Enabled = true
    self.Blur.Parent = self.Service.Lighting

    self.MainFrame = Instance.new("CanvasGroup")
    self.MainFrame.Size = UDim2.new(0, 580, 0, 480)
    self.MainFrame.Position = UDim2.new(0.5, -290, 0.5, -240)
    self.MainFrame.BackgroundColor3 = self.Theme.Main
    self.MainFrame.BorderSizePixel = 1
    self.MainFrame.BorderColor3 = self.Theme.Outline
    self.MainFrame.Parent = self.Root

    local Border = Instance.new("Frame")
    Border.Size = UDim2.new(1, 4, 1, 4)
    Border.Position = UDim2.new(0, -2, 0, -2)
    Border.BackgroundColor3 = Color3.new(0,0,0)
    Border.ZIndex = 0
    Border.Parent = self.MainFrame

    self.TopBar = Instance.new("Frame")
    self.TopBar.Size = UDim2.new(1, 0, 0, 30)
    self.TopBar.BackgroundColor3 = self.Theme.Main
    self.TopBar.BorderSizePixel = 1
    self.TopBar.BorderColor3 = self.Theme.Outline
    self.TopBar.Parent = self.MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = title or "Interface"
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = self.Theme.TextActive
    Title.TextSize = 14
    Title.Font = self.Theme.Font
    Title.Parent = self.TopBar

    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Size = UDim2.new(1, 0, 0, 35)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 30)
    self.TabContainer.BackgroundColor3 = self.Theme.Main
    self.TabContainer.BorderSizePixel = 1
    self.TabContainer.BorderColor3 = self.Theme.Outline
    self.TabContainer.Parent = self.MainFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = self.TabContainer

    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Size = UDim2.new(1, 0, 1, -65)
    self.ContentArea.Position = UDim2.new(0, 0, 0, 65)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Parent = self.MainFrame

    self:SetupInputListeners()
    self:MakeDraggable(self.MainFrame, self.TopBar)
    
    return self
end

function Interface:SetupInputListeners()
    local inputConn = self.Service.UserInput.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            self:Toggle()
        elseif input.KeyCode == Enum.KeyCode.Delete then
            self:Destroy()
        end
    end)
    table.insert(self.Connections, inputConn)
end

function Interface:Toggle()
    self.IsVisible = not self.IsVisible
    if self.MainFrame then self.MainFrame.Visible = self.IsVisible end
    if self.Blur then self.Blur.Enabled = self.IsVisible end
end

function Interface:Destroy()
    if self.IsDestroyed then return end
    self.IsDestroyed = true
    for i, conn in ipairs(self.Connections) do
        if conn then conn:Disconnect() end
    end
    if self.Root then self.Root:Destroy() end
    if self.Blur then self.Blur:Destroy() end
    print("> Interface Unloaded.")
end

function Interface:MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    local beginConn = handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    local changeConn = self.Service.UserInput.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    local endConn = self.Service.UserInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    table.insert(self.Connections, beginConn)
    table.insert(self.Connections, changeConn)
    table.insert(self.Connections, endConn)
end

function Interface:CreateTab(name)
    local Tab = { Sections = {} }
    local isFirst = (#self.Tabs == 0)

    Tab.Button = Instance.new("TextButton")
    Tab.Button.Size = UDim2.new(0, 110, 1, 0)
    Tab.Button.BackgroundColor3 = self.Theme.Main
    Tab.Button.BorderSizePixel = 0
    Tab.Button.Text = name:upper()
    Tab.Button.TextColor3 = isFirst and self.Theme.TextActive or self.Theme.TextInactive
    Tab.Button.TextSize = 14
    Tab.Button.Font = self.Theme.Font
    Tab.Button.Parent = self.TabContainer

    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 1, -2)
    AccentLine.BackgroundColor3 = self.Theme.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.Visible = isFirst
    AccentLine.Parent = Tab.Button

    Tab.Page = Instance.new("ScrollingFrame")
    Tab.Page.Size = UDim2.new(1, 0, 1, 0)
    Tab.Page.BackgroundTransparency = 1
    Tab.Page.Visible = isFirst
    Tab.Page.ScrollBarThickness = 0
    Tab.Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Tab.Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Tab.Page.Parent = self.ContentArea
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 20)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageLayout.Parent = Tab.Page

    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 15)
    PagePadding.Parent = Tab.Page

    local btnConn = Tab.Button.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            t.Button.TextColor3 = self.Theme.TextInactive
            t.Button:FindFirstChild("Frame").Visible = false
        end
        Tab.Page.Visible = true
        Tab.Button.TextColor3 = self.Theme.TextActive
        AccentLine.Visible = true
    end)
    table.insert(self.Connections, btnConn)

    function Tab:AddSection(sName)
        local Section = {}
        local SectionFrame = Instance.new("Frame")
        SectionFrame.Size = UDim2.new(0.92, 0, 0, 50)
        SectionFrame.BackgroundColor3 = Interface.Theme.SectionBG
        SectionFrame.BorderColor3 = Interface.Theme.Outline
        SectionFrame.Parent = Tab.Page

        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Text = " " .. sName:upper() .. " "
        SectionTitle.AnchorPoint = Vector2.new(0.5, 0.5)
        SectionTitle.Position = UDim2.new(0.5, 0, 0, 0) 
        SectionTitle.Size = UDim2.new(0, 0, 0, 16)
        SectionTitle.AutomaticSize = Enum.AutomaticSize.X
        SectionTitle.BackgroundColor3 = Interface.Theme.Main
        SectionTitle.TextColor3 = Interface.Theme.TextActive
        SectionTitle.Font = Interface.Theme.Font
        SectionTitle.TextSize = 12
        SectionTitle.ZIndex = 3
        SectionTitle.Parent = SectionFrame

        local SectionContent = Instance.new("Frame")
        SectionContent.Size = UDim2.new(1, -20, 1, -20)
        SectionContent.Position = UDim2.new(0, 10, 0, 15)
        SectionContent.BackgroundTransparency = 1
        SectionContent.Parent = SectionFrame
        
        local SectionLayout = Instance.new("UIListLayout")
        SectionLayout.Padding = UDim.new(0, 10)
        SectionLayout.Parent = SectionContent

        local sizeConn = SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            SectionFrame.Size = UDim2.new(0.92, 0, 0, SectionLayout.AbsoluteContentSize.Y + 30)
        end)
        table.insert(Interface.Connections, sizeConn)

        function Section:AddButton(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 22)
            Btn.BackgroundColor3 = Interface.Theme.ElementBG
            Btn.BorderColor3 = Interface.Theme.Outline
            Btn.Font = Interface.Theme.Font
            Btn.Text = text
            Btn.TextColor3 = Interface.Theme.TextActive
            Btn.TextSize = 14
            Btn.Parent = SectionContent

            local clickConn = Btn.MouseButton1Click:Connect(callback)
            table.insert(Interface.Connections, clickConn)
        end

        function Section:AddInput(text, placeholder, callback)
            local InputFrame = Instance.new("Frame")
            InputFrame.Size = UDim2.new(1, 0, 0, 38)
            InputFrame.BackgroundTransparency = 1
            InputFrame.Parent = SectionContent

            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Size = UDim2.new(1, 0, 0, 15)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Interface.Theme.TextInactive
            Label.Font = Interface.Theme.Font
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = InputFrame

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(1, 0, 0, 18)
            Box.Position = UDim2.new(0, 0, 0, 20)
            Box.BackgroundColor3 = Interface.Theme.ElementBG
            Box.BorderColor3 = Interface.Theme.Outline
            Box.Font = Interface.Theme.Font
            Box.PlaceholderText = placeholder or "Enter text..."
            Box.Text = ""
            Box.TextColor3 = Interface.Theme.TextActive
            Box.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
            Box.TextSize = 13
            Box.Parent = InputFrame

            local focusConn = Box.FocusLost:Connect(function(enter)
                callback(Box.Text)
            end)
            table.insert(Interface.Connections, focusConn)
        end

        function Section:AddToggle(text, default, callback)
            local state = default or false
            local Tgl = Instance.new("TextButton")
            Tgl.Size = UDim2.new(1, 0, 0, 18)
            Tgl.BackgroundTransparency = 1
            Tgl.Text = ""
            Tgl.Parent = SectionContent

            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(0, 14, 0, 14)
            Box.Position = UDim2.new(0, 0, 0.5, -7)
            Box.BackgroundColor3 = state and Interface.Theme.Accent or Interface.Theme.ElementBG
            Box.BorderColor3 = Interface.Theme.Outline
            Box.Parent = Tgl

            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Position = UDim2.new(0, 22, 0, 0)
            Label.Size = UDim2.new(1, -22, 1, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = state and Interface.Theme.TextActive or Interface.Theme.TextInactive
            Label.Font = Interface.Theme.Font
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Tgl

            local tglConn = Tgl.MouseButton1Click:Connect(function()
                state = not state
                Box.BackgroundColor3 = state and Interface.Theme.Accent or Interface.Theme.ElementBG
                Label.TextColor3 = state and Interface.Theme.TextActive or Interface.Theme.TextInactive
                callback(state)
            end)
            table.insert(Interface.Connections, tglConn)
        end

        function Section:AddSlider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 35)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.Parent = SectionContent

            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Size = UDim2.new(1, 0, 0, 15)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Interface.Theme.TextInactive
            Label.Font = Interface.Theme.Font
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame

            local Back = Instance.new("Frame")
            Back.Size = UDim2.new(1, 0, 0, 10)
            Back.Position = UDim2.new(0, 0, 0, 18)
            Back.BackgroundColor3 = Interface.Theme.ElementBG
            Back.BorderColor3 = Interface.Theme.Outline
            Back.Parent = SliderFrame

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
            Fill.BackgroundColor3 = Interface.Theme.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Back
            
            local ValLabel = Instance.new("TextLabel")
            ValLabel.Text = tostring(default)
            ValLabel.Size = UDim2.new(1, 0, 1, 0)
            ValLabel.BackgroundTransparency = 1
            ValLabel.TextColor3 = Color3.new(1,1,1)
            ValLabel.Font = Interface.Theme.Font
            ValLabel.TextSize = 10
            ValLabel.ZIndex = 2
            ValLabel.Parent = Back

            local function Update(input)
                local pos = math.clamp((input.Position.X - Back.AbsolutePosition.X) / Back.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                ValLabel.Text = tostring(val)
                callback(val)
            end

            local sliderConn = Back.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Update(input)
                    local moveConn; moveConn = Interface.Service.UserInput.InputChanged:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end
                    end)
                    local endCon; endCon = Interface.Service.UserInput.InputEnded:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 then
                            moveConn:Disconnect(); endCon:Disconnect()
                        end
                    end)
                end
            end)
            table.insert(Interface.Connections, sliderConn)
        end

        function Section:AddDropdown(text, options, isMulti, callback)
            local selected = {}
            
            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, 0, 0, 30)
            DropFrame.BackgroundTransparency = 1
            DropFrame.Parent = SectionContent

            local DropButton = Instance.new("TextButton")
            DropButton.Size = UDim2.new(1, 0, 0, 25)
            DropButton.BackgroundColor3 = Interface.Theme.ElementBG
            DropButton.BorderColor3 = Interface.Theme.Outline
            DropButton.Font = Interface.Theme.Font
            DropButton.Text = text
            DropButton.TextColor3 = Interface.Theme.TextActive
            DropButton.Parent = DropFrame

            local ListFrame = Instance.new("ScrollingFrame")
            ListFrame.Size = UDim2.new(1, 0, 0, 100)
            ListFrame.Position = UDim2.new(0, 0, 0, 30)
            ListFrame.Visible = false
            ListFrame.BackgroundColor3 = Interface.Theme.Main
            ListFrame.Parent = DropFrame

            DropButton.MouseButton1Click:Connect(function()
                ListFrame.Visible = not ListFrame.Visible
            end)

            for _, opt in pairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 20)
                OptBtn.Text = opt
                OptBtn.Parent = ListFrame
                
                OptBtn.MouseButton1Click:Connect(function()
                    if isMulti then
                        selected[opt] = not selected[opt]
                        OptBtn.TextColor3 = selected[opt] and Interface.Theme.Accent or Interface.Theme.TextActive
                    else
                        selected = {[opt] = true}
                        ListFrame.Visible = false
                    end
                    callback(selected)
                end)
            end
        end

        return Section
    end

    table.insert(self.Tabs, Tab)
    return Tab
end

return Interface
