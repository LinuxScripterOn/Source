local TweenService = game:GetService("TweenService")
local InputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local Linux = {}

local configFile = "LinuxConfig.json"
local configs = {}

function Linux.Instance(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

function Linux:SafeCallback(Function, ...)
    if not Function then
        return
    end
    local Success, Error = pcall(Function, ...)
    if not Success then
        self:Notify({
            Title = "Callback Error",
            Content = tostring(Error),
            Duration = 5
        })
    end
end

function Linux:SaveConfigs()
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(configs)
    end)
    if success then
        writefile(configFile, encoded)
    end
end

function Linux:LoadConfigs()
    if isfile(configFile) then
        local data = readfile(configFile)
        local success, parsed = pcall(function()
            return HttpService:JSONDecode(data)
        end)
        if success and parsed then
            configs = parsed
        end
    end
end

Linux:LoadConfigs()

function Linux:Notify(config)
    local isMobile = InputService.TouchEnabled and not InputService.KeyboardEnabled
    local notificationWidth = isMobile and 200 or 300
    local notificationHeight = config.SubContent and 80 or 60
    local startPosX = isMobile and 10 or 20

    local NotificationHolder = Linux.Instance("ScreenGui", {
        Name = "NotificationHolder",
        Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
        ResetOnSpawn = false,
        Enabled = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local Notification = Linux.Instance("Frame", {
        Parent = NotificationHolder,
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 2,
        Size = UDim2.new(0, notificationWidth, 0, notificationHeight),
        Position = UDim2.new(1, 10, 1, -notificationHeight - 10),
        ZIndex = 100
    })

    Linux.Instance("UICorner", {
        Parent = Notification,
        CornerRadius = UDim.new(0, 6)
    })

    Linux.Instance("TextLabel", {
        Parent = Notification,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 5),
        Font = Enum.Font.SourceSansBold,
        Text = config.Title or "Notification",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 101
    })

    Linux.Instance("TextLabel", {
        Parent = Notification,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 25),
        Font = Enum.Font.SourceSans,
        Text = config.Content or "Content",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 101
    })

    if config.SubContent then
        Linux.Instance("TextLabel", {
            Parent = Notification,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 20),
            Position = UDim2.new(0, 5, 0, 45),
            Font = Enum.Font.SourceSans,
            Text = config.SubContent,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 101
        })
    end

    local ProgressBar = Linux.Instance("Frame", {
        Parent = Notification,
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Size = UDim2.new(1, -10, 0, 4),
        Position = UDim2.new(0, 5, 1, -9),
        ZIndex = 101,
        BorderSizePixel = 0
    })

    Linux.Instance("UICorner", {
        Parent = ProgressBar,
        CornerRadius = UDim.new(0, 2)
    })

    local ProgressFill = Linux.Instance("Frame", {
        Parent = ProgressBar,
        BackgroundColor3 = Color3.fromRGB(0, 120, 255),
        Size = UDim2.new(0, 0, 1, 0),
        ZIndex = 101,
        BorderSizePixel = 0
    })

    Linux.Instance("UICorner", {
        Parent = ProgressFill,
        CornerRadius = UDim.new(0, 2)
    })

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(Notification, tweenInfo, {Position = UDim2.new(0, startPosX, 1, -notificationHeight - 10)}):Play()

    if config.Duration then
        local progressTweenInfo = TweenInfo.new(config.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
        TweenService:Create(ProgressFill, progressTweenInfo, {Size = UDim2.new(1, 0, 1, 0)}):Play()

        task.delay(config.Duration, function()
            TweenService:Create(Notification, tweenInfo, {Position = UDim2.new(1, 10, 1, -notificationHeight - 10)}):Play()
            task.wait(0.5)
            NotificationHolder:Destroy()
        end)
    end
end

function Linux.Create(config)
    local randomName = "UI_" .. tostring(math.random(100000, 999999))

    for _, v in pairs(game.CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name:match("^UI_%d+$") then
            v:Destroy()
        end
    end

    local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

    local LinuxUI = Linux.Instance("ScreenGui", {
        Name = randomName,
        Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
        ResetOnSpawn = false,
        Enabled = true
    })

    ProtectGui(LinuxUI)

    local isMobile = InputService.TouchEnabled and not InputService.KeyboardEnabled
    local uiSize = isMobile and (config.SizeMobile or UDim2.fromOffset(300, 500)) or (config.SizePC or UDim2.fromOffset(550, 355))

    local Main = Linux.Instance("Frame", {
        Parent = LinuxUI,
        BackgroundColor3 = Color3.fromRGB(19, 19, 19),
        BorderColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 2,
        Size = uiSize,
        Position = UDim2.new(0.5, -uiSize.X.Offset / 2, 0.5, -uiSize.Y.Offset / 2),
        Active = true,
        Draggable = true,
        ZIndex = 1
    })

    Linux.Instance("UICorner", {
        Parent = Main,
        CornerRadius = UDim.new(0, 10)
    })

    local TopBar = Linux.Instance("Frame", {
        Parent = Main,
        BackgroundColor3 = Color3.fromRGB(19, 19, 19),
        BorderColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 2,
        Size = UDim2.new(1, 0, 0, 25),
        ZIndex = 2
    })

    Linux.Instance("UICorner", {
        Parent = TopBar,
        CornerRadius = UDim.new(0, 6)
    })

    local TitleLabel = Linux.Instance("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        Font = Enum.Font.SourceSansBold,
        Text = config.Name or "Linux UI",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 2
    })

    local TabsBar = Linux.Instance("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 25),
        Size = UDim2.new(0, config.TabWidth or 110, 1, -25),
        ZIndex = 2,
        BorderSizePixel = 0
    })

    local TabHolder = Linux.Instance("ScrollingFrame", {
        Parent = TabsBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ZIndex = 2,
        BorderSizePixel = 0,
        ScrollingEnabled = true
    })

    Linux.Instance("UIListLayout", {
        Parent = TabHolder,
        Padding = UDim.new(0, 3),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Linux.Instance("UIPadding", {
        Parent = TabHolder,
        PaddingLeft = UDim.new(0, 5),
        PaddingTop = UDim.new(0, 5)
    })

    local Content = Linux.Instance("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, config.TabWidth or 110, 0, 25),
        Size = UDim2.new(1, -(config.TabWidth or 110), 1, -25),
        ZIndex = 1,
        BorderSizePixel = 2,
        BorderColor3 = Color3.fromRGB(50, 50, 50)
    })

    local isHidden = false

    InputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftAlt then
            isHidden = not isHidden
            Main.Visible = not isHidden
        end
    end)

    local LinuxLib = {}
    local Tabs = {}
    local CurrentTab = nil
    local tabOrder = 0

    function LinuxLib.Tab(config)
        tabOrder = tabOrder + 1
        local tabIndex = tabOrder

        local TabBtn = Linux.Instance("TextButton", {
            Parent = TabHolder,
            BackgroundColor3 = Color3.fromRGB(22, 22, 22),
            BorderColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 2,
            Size = UDim2.new(1, -5, 0, 28),
            Font = Enum.Font.SourceSans,
            Text = "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            ZIndex = 2,
            AutoButtonColor = false,
            LayoutOrder = tabIndex
        })

        Linux.Instance("UICorner", {
            Parent = TabBtn,
            CornerRadius = UDim.new(0, 6)
        })

        local TabGradient
        local TabIcon
        if config.Icon and config.Icon.Enabled then
            TabIcon = Linux.Instance("ImageLabel", {
                Parent = TabBtn,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 10, 0.5, -8),
                Image = config.Icon.Image or "rbxassetid://10747384394",
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 2
            })
        end

        local TabText = Linux.Instance("TextLabel", {
            Parent = TabBtn,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, config.Icon and config.Icon.Enabled and -31 or -15, 1, 0),
            Position = UDim2.new(0, config.Icon and config.Icon.Enabled and 31 or 10, 0, 0),
            Font = Enum.Font.SourceSans,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })

        local TabContent = Linux.Instance("Frame", {
            Parent = Content,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ZIndex = 1,
            BorderSizePixel = 0
        })

        local Container1 = Linux.Instance("ScrollingFrame", {
            Parent = TabContent,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -5, 1, -55),
            Position = UDim2.new(0, 5, 0, 30),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 0,
            ZIndex = 1,
            BorderSizePixel = 2,
            BorderColor3 = Color3.fromRGB(50, 50, 50),
            ScrollingEnabled = true,
            CanvasPosition = Vector2.new(0, 0)
        })

        Linux.Instance("UIListLayout", {
            Parent = Container1,
            Padding = UDim.new(0, 5),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Linux.Instance("UIPadding", {
            Parent = Container1,
            PaddingLeft = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 5)
        })

        local Container2 = Linux.Instance("ScrollingFrame", {
            Parent = TabContent,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -5, 1, -55),
            Position = UDim2.new(0.5, 0, 0, 30),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 0,
            ZIndex = 1,
            BorderSizePixel = 2,
            BorderColor3 = Color3.fromRGB(50, 50, 50),
            ScrollingEnabled = true,
            CanvasPosition = Vector2.new(0, 0)
        })

        Linux.Instance("UIListLayout", {
            Parent = Container2,
            Padding = UDim.new(0, 5),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Linux.Instance("UIPadding", {
            Parent = Container2,
            PaddingLeft = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 5)
        })

        local TitleFrame = Linux.Instance("Frame", {
            Parent = Content,
            BackgroundColor3 = Color3.fromRGB(19, 19, 19),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -5, 0, 30),
            Position = UDim2.new(0, 5, 0, 0),
            Visible = false,
            ZIndex = 3
        })

        local TitleLabel = Linux.Instance("TextLabel", {
            Parent = TitleFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Font = Enum.Font.SourceSansBold,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 26,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 4
        })

        local function SelectTab()
            for _, tab in pairs(Tabs) do
                tab.Content.Visible = false
                tab.TitleFrame.Visible = false
                tab.Text.TextColor3 = Color3.fromRGB(255, 255, 255)
                tab.Button.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                for _, child in pairs(tab.Button:GetChildren()) do
                    if child:IsA("UIGradient") then
                        child:Destroy()
                    end
                end
                if tab.Icon then
                    tab.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
            TabContent.Visible = true
            TitleFrame.Visible = true
            TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TabGradient = Linux.Instance("UIGradient", {
                Parent = TabBtn,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 139))
                }),
                Rotation = 45
            })
            if TabIcon then
                TabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
            CurrentTab = tabIndex
            Container1.CanvasPosition = Vector2.new(0, 0)
            Container2.CanvasPosition = Vector2.new(0, 0)
        end

        TabBtn.MouseButton1Click:Connect(SelectTab)

        Tabs[tabIndex] = {
            Name = config.Name,
            Button = TabBtn,
            Text = TabText,
            Icon = TabIcon,
            Content = TabContent,
            TitleFrame = TitleFrame,
            Gradient = TabGradient
        }

        if tabOrder == 1 then
            SelectTab()
        end

        local TabElements = {}
        local elementOrder1 = 0
        local elementOrder2 = 0

        function TabElements.Button(config)
            local container = config.Container == 2 and Container2 or Container1
            local elementOrder = config.Container == 2 and elementOrder2 or elementOrder1
            if config.Container == 2 then
                elementOrder2 = elementOrder2 + 1
            else
                elementOrder1 = elementOrder1 + 1
            end

            local BtnFrame = Linux.Instance("Frame", {
                Parent = container,
                BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                BorderColor3 = Color3.fromRGB(50, 50, 50),
                BorderSizePixel = 2,
                Size = UDim2.new(1, -5, 0, 34),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = BtnFrame,
                CornerRadius = UDim.new(0, 6)
            })

            local Btn = Linux.Instance("TextButton", {
                Parent = BtnFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 34),
                Position = UDim2.new(0, 0, 0, 0),
                Font = Enum.Font.Gotham,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2,
                AutoButtonColor = false
            })

            Linux.Instance("UIPadding", {
                Parent = Btn,
                PaddingLeft = UDim.new(0, 5)
            })

            local BtnIcon = Linux.Instance("ImageLabel", {
                Parent = BtnFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -20, 0.5, -7),
                Image = "rbxassetid://10709791437",
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 2
            })

            local hoverColor = Color3.fromRGB(40, 40, 40)
            local clickColor = Color3.fromRGB(0, 120, 255)
            local originalColor = Color3.fromRGB(22, 22, 22)
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            Btn.MouseEnter:Connect(function()
                TweenService:Create(BtnFrame, tweenInfo, {BackgroundColor3 = hoverColor}):Play()
            end)

            Btn.MouseLeave:Connect(function()
                TweenService:Create(BtnFrame, tweenInfo, {BackgroundColor3 = originalColor}):Play()
            end)

            Btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    TweenService:Create(BtnFrame, tweenInfo, {BackgroundColor3 = clickColor}):Play()
                end
            end)

            Btn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    TweenService:Create(BtnFrame, tweenInfo, {BackgroundColor3 = originalColor}):Play()
                end
            end)

            Btn.MouseButton1Click:Connect(function()
                spawn(function() Linux:SafeCallback(config.Callback) end)
            end)

            container.CanvasPosition = Vector2.new(0, 0)
            return Btn
        end

        function TabElements.Toggle(config)
            local container = config.Container == 2 and Container2 or Container1
            local elementOrder = config.Container == 2 and elementOrder2 or elementOrder1
            if config.Container == 2 then
                elementOrder2 = elementOrder2 + 1
            else
                elementOrder1 = elementOrder1 + 1
            end

            local toggleId = config.Id or (config.Name .. "_" .. tabIndex .. "_" .. elementOrder)
            local defaultState = config.Default or false
            if configs[toggleId] ~= nil then
                defaultState = configs[toggleId]
            end

            local Toggle = Linux.Instance("Frame", {
                Parent = container,
                BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                BorderColor3 = Color3.fromRGB(50, 50, 50),
                BorderSizePixel = 2,
                Size = UDim2.new(1, -5, 0, 34),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = Toggle,
                CornerRadius = UDim.new(0, 6)
            })

            Linux.Instance("TextLabel", {
                Parent = Toggle,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.8, 0, 0, 34),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.Gotham,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })

            local ToggleBox = Linux.Instance("Frame", {
                Parent = Toggle,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -25, 0, 7),
                ZIndex = 2,
                BorderSizePixel = 0
            })

            Linux.Instance("UICorner", {
                Parent = ToggleBox,
                CornerRadius = UDim.new(0, 6)
            })

            local CheckIcon = Linux.Instance("ImageLabel", {
                Parent = ToggleBox,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0.5, -7, 0.5, -7),
                Image = "rbxassetid://10709790644",
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                Visible = false,
                ZIndex = 3
            })

            local Gradient = Linux.Instance("UIGradient", {
                Parent = ToggleBox,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 139))
                }),
                Rotation = 45,
                Enabled = false
            })

            local State = defaultState
            local isToggling = false

            local function UpdateToggle()
                if isToggling then return end
                isToggling = true
                local tween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                if State then
                    CheckIcon.Visible = true
                    Gradient.Enabled = true
                    TweenService:Create(ToggleBox, tween, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                else
                    CheckIcon.Visible = false
                    Gradient.Enabled = false
                    TweenService:Create(ToggleBox, tween, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                end
                task.wait(0.2)
                isToggling = false
            end

            UpdateToggle()

            ToggleBox.InputBegan:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and not isToggling then
                    State = not State
                    configs[toggleId] = State
                    Linux:SaveConfigs()
                    UpdateToggle()
                    spawn(function() Linux:SafeCallback(config.Callback, State) end)
                end
            end)

            container.CanvasPosition = Vector2.new(0, 0)
            return Toggle
        end

        function TabElements.Dropdown(config)
            local container = config.Container == 2 and Container2 or Container1
            local elementOrder = config.Container == 2 and elementOrder2 or elementOrder1
            if config.Container == 2 then
                elementOrder2 = elementOrder2 + 1
            else
                elementOrder1 = elementOrder1 + 1
            end

            local Dropdown = Linux.Instance("Frame", {
                Parent = container,
                BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                BorderColor3 = Color3.fromRGB(50, 50, 50),
                BorderSizePixel = 2,
                Size = UDim2.new(1, -5, 0, 34),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = Dropdown,
                CornerRadius = UDim.new(0, 6)
            })

            local DropdownButton = Linux.Instance("TextButton", {
                Parent = Dropdown,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = "",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                ZIndex = 2,
                AutoButtonColor = false
            })

            Linux.Instance("TextLabel", {
                Parent = DropdownButton,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.8, 0, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.Gotham,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })

            local Selected = Linux.Instance("TextLabel", {
                Parent = DropdownButton,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -40, 1, 0),
                Font = Enum.Font.Gotham,
                Text = config.Default or (config.Options and config.Options[1]) or "None",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 2
            })

            local Arrow = Linux.Instance("ImageLabel", {
                Parent = DropdownButton,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -20, 0.5, -7),
                Image = "rbxassetid://10709767827",
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 2
            })

            local DropFrame = Linux.Instance("ScrollingFrame", {
                Parent = container,
                BackgroundColor3 = Color3.fromRGB(23, 23, 23),
                BorderColor3 = Color3.fromRGB(50, 50, 50),
                BorderSizePixel = 2,
                Size = UDim2.new(1, -5, 0, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 0,
                ScrollingEnabled = true,
                ZIndex = 3,
                LayoutOrder = elementOrder + 1
            })

            Linux.Instance("UICorner", {
                Parent = DropFrame,
                CornerRadius = UDim.new(0, 6)
            })

            Linux.Instance("UIListLayout", {
                Parent = DropFrame,
                Padding = UDim.new(0, 2),
                HorizontalAlignment = Enum.HorizontalAlignment.Left
            })

            Linux.Instance("UIPadding", {
                Parent = DropFrame,
                PaddingLeft = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 5)
            })

            local Options = config.Options or {}
            local IsOpen = false
            local SelectedValue = config.Default or (Options[1] or "None")

            local function UpdateDropSize()
                local optionHeight = 25
                local paddingBetween = 2
                local paddingTop = 5
                local maxHeight = 150
                local numOptions = #Options
                local calculatedHeight = numOptions * optionHeight + (numOptions > 0 and (numOptions - 1) * paddingBetween + paddingTop or 0)
                local finalHeight = math.min(calculatedHeight, maxHeight)

                local tween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                if IsOpen then
                    TweenService:Create(DropFrame, tween, {Size = UDim2.new(1, -5, 0, finalHeight)}):Play()
                else
                    TweenService:Create(DropFrame, tween, {Size = UDim2.new(1, -5, 0, 0)}):Play()
                end
                task.wait(0.2)
            end

            local function PopulateOptions()
                for _, child in pairs(DropFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                if IsOpen then
                    for _, opt in pairs(Options) do
                        local OptBtn = Linux.Instance("TextButton", {
                            Parent = DropFrame,
                            BackgroundColor3 = Color3.fromRGB(27, 27, 27),
                            BorderColor3 = Color3.fromRGB(50, 50, 50),
                            BorderSizePixel = 2,
                            Size = UDim2.new(1, -5, 0, 25),
                            Font = Enum.Font.Gotham,
                            Text = tostring(opt),
                            TextColor3 = opt == SelectedValue and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 255, 255),
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Center,
                            ZIndex = 3,
                            AutoButtonColor = false
                        })

                        Linux.Instance("UICorner", {
                            Parent = OptBtn,
                            CornerRadius = UDim.new(0, 6)
                        })

                        OptBtn.MouseButton1Click:Connect(function()
                            SelectedValue = opt
                            Selected.Text = tostring(opt)
                            for _, btn in pairs(DropFrame:GetChildren()) do
                                if btn:IsA("TextButton") then
                                    btn.TextColor3 = btn.Text == tostring(opt) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 255, 255)
                                end
                            end
                            PopulateOptions()
                            spawn(function() Linux:SafeCallback(config.Callback, opt) end)
                        end)
                    end
                end
                UpdateDropSize()
            end

            if #Options > 0 then
                PopulateOptions()
            end

            DropdownButton.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                PopulateOptions()
            end)

            local function SetOptions(newOptions)
                Options = newOptions or {}
                SelectedValue = Options[1] or "None"
                Selected.Text = tostring(SelectedValue)
                PopulateOptions()
            end

            local function SetValue(value)
                if table.find(Options, value) then
                    SelectedValue = value
                    Selected.Text = tostring(value)
                    for _, btn in pairs(DropFrame:GetChildren()) do
                        if btn:IsA("TextButton") then
                            btn.TextColor3 = btn.Text == tostring(value) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 255, 255)
                        end
                    end
                    spawn(function() Linux:SafeCallback(config.Callback, value) end)
                end
            end

            container.CanvasPosition = Vector2.new(0, 0)
            return {
                Instance = Dropdown,
                SetOptions = SetOptions,
                SetValue = SetValue,
                GetValue = function() return SelectedValue end
            }
        end

        function TabElements.Slider(config)
            local container = config.Container == 2 and Container2 or Container1
            local elementOrder = config.Container == 2 and elementOrder2 or elementOrder1
            if config.Container == 2 then
                elementOrder2 = elementOrder2 + 1
            else
                elementOrder1 = elementOrder1 + 1
            end

            local Slider = Linux.Instance("Frame", {
                Parent = container,
                BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                BorderColor3 = Color3.fromRGB(50, 50, 50),
                BorderSizePixel = 2,
                Size = UDim2.new(1, -5, 0, 34),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = Slider,
                CornerRadius = UDim.new(0, 6)
            })

            local TitleLabel = Linux.Instance("TextLabel", {
                Parent = Slider,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.4, 0, 0, 16),
                Position = UDim2.new(0, 5, 0, 2),
                Font = Enum.Font.Gotham,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })

            local SliderBar = Linux.Instance("Frame", {
                Parent = Slider,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Size = UDim2.new(1, -80, 0, 6),
                Position = UDim2.new(0, 65, 0, 20),
                ZIndex = 2,
                BorderSizePixel = 0
            })

            Linux.Instance("UICorner", {
                Parent = SliderBar,
                CornerRadius = UDim.new(1, 0)
            })

            local ValueLabel = Linux.Instance("TextLabel", {
                Parent = Slider,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 40, 0, 16),
                Position = UDim2.new(1, -50, 0, 2),
                Font = Enum.Font.Gotham,
                Text = "",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 2
            })

            local FillBar = Linux.Instance("Frame", {
                Parent = SliderBar,
                Size = UDim2.new(0, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                ZIndex = 2,
                BorderSizePixel = 0
            })

            Linux.Instance("UIGradient", {
                Parent = FillBar,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 100, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 80, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 60, 255))
                }),
                Rotation = 45
            })

            Linux.Instance("UICorner", {
                Parent = FillBar,
                CornerRadius = UDim.new(1, 0)
            })

            local Knob = Linux.Instance("Frame", {
                Parent = SliderBar,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, 0, 0, -3),
                ZIndex = 3,
                BorderSizePixel = 0
            })

            Linux.Instance("UICorner", {
                Parent = Knob,
                CornerRadius = UDim.new(1, 0)
            })

            local Min = config.Min or 0
            local Max = config.Max or 100
            local Default = config.Default or Min
            local Value = Default

            local function AnimateValueLabel()
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(ValueLabel, tweenInfo, {TextSize = 16}):Play()
                task.wait(0.2)
                TweenService:Create(ValueLabel, tweenInfo, {TextSize = 14}):Play()
            end

            local function UpdateSlider(pos)
                local barSize = SliderBar.AbsoluteSize.X
                local relativePos = math.clamp((pos - SliderBar.AbsolutePosition.X) / barSize, 0, 1)
                Value = Min + (Max - Min) * relativePos
                Value = math.floor(Value + 0.5)
                Knob.Position = UDim2.new(relativePos, -6, 0, -3)
                FillBar.Size = UDim2.new(relativePos, 0, 1, 0)
                local percentage = math.floor((Value - Min) / (Max - Min) * 100 + 0.5)
                ValueLabel.Text = tostring(percentage) .. "%"
                AnimateValueLabel()
                spawn(function() Linux:SafeCallback(config.Callback, Value) end)
            end

            local draggingSlider = false

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                    UpdateSlider(input.Position.X)
                end
            end)

            SliderBar.InputChanged:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and draggingSlider then
                    UpdateSlider(input.Position.X)
                end
            end)

            SliderBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)

            local function SetValue(newValue)
                newValue = math.clamp(newValue, Min, Max)
                Value = math.floor(newValue + 0.5)
                local relativePos = (Value - Min) / (Max - Min)
                Knob.Position = UDim2.new(relativePos, -6, 0, -3)
                FillBar.Size = UDim2.new(relativePos, 0, 1, 0)
                local percentage = math.floor((Value - Min) / (Max - Min) * 100 + 0.5)
                ValueLabel.Text = tostring(percentage) .. "%"
                AnimateValueLabel()
                spawn(function() Linux:SafeCallback(config.Callback, Value) end)
            end

            SetValue(Default)

            container.CanvasPosition = Vector2.new(0, 0)
            return {
                Instance = Slider,
                SetValue = SetValue,
                GetValue = function() return Value end
            }
        end

        function TabElements.Input(config)
            local container = config.Container == 2 and Container2 or Container1
            local elementOrder = config.Container == 2 and elementOrder2 or elementOrder1
            if config.Container == 2 then
                elementOrder2 = elementOrder2 + 1
            else
                elementOrder1 = elementOrder1 + 1
            end

            local Input = Linux.Instance("Frame", {
                Parent = container,
                BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                BorderColor3 = Color3.fromRGB(50, 50, 50),
                BorderSizePixel = 2,
                Size = UDim2.new(1, -5, 0, 34),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = Input,
                CornerRadius = UDim.new(0, 6)
            })

            Linux.Instance("TextLabel", {
                Parent = Input,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.Gotham,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })

            local TextBox = Linux.Instance("TextBox", {
                Parent = Input,
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                BorderSizePixel = 0,
                Size = UDim2.new(0.28, -5, 0, 26),
                Position = UDim2.new(1, -55, 0.5, -12),
                Font = Enum.Font.Gotham,
                Text = config.Default or "",
                PlaceholderText = config.Placeholder or "Text Here",
                PlaceholderColor3 = Color3.fromRGB(255, 255, 255),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextScaled = false,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Center,
                ClearTextOnFocus = false,
                ClipsDescendants = true,
                ZIndex = 3
            })

            Linux.Instance("UICorner", {
                Parent = TextBox,
                CornerRadius = UDim.new(0, 6)
            })

            local MaxLength = 50

            local function CheckTextBounds()
                if #TextBox.Text > MaxLength then
                    TextBox.Text = string.sub(TextBox.Text, 1, MaxLength)
                end
            end

            TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                CheckTextBounds()
            end)

            local function UpdateInput()
                CheckTextBounds()
                spawn(function() Linux:SafeCallback(config.Callback, TextBox.Text) end)
            end

            TextBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    UpdateInput()
                end
            end)

            TextBox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    TextBox:CaptureFocus()
                end
            end)

            local function SetValue(newValue)
                local text = tostring(newValue)
                if #text > MaxLength then
                    text = string.sub(text, 1, MaxLength)
                end
                TextBox.Text = text
                UpdateInput()
            end

            container.CanvasPosition = Vector2.new(0, 0)
            return {
                Instance = Input,
                SetValue = SetValue,
                GetValue = function() return TextBox.Text end
            }
        end

        function TabElements.Label(config)
            local container = config.Container == 2 and Container2 or Container1
            local elementOrder = config.Container == 2 and elementOrder2 or elementOrder1
            if config.Container == 2 then
                elementOrder2 = elementOrder2 + 1
            else
                elementOrder1 = elementOrder1 + 1
            end

            local LabelFrame = Linux.Instance("Frame", {
                Parent = container,
                BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                BorderColor3 = Color3.fromRGB(50, 50, 50),
                BorderSizePixel = 2,
                Size = UDim2.new(1, -5, 0, 34),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = LabelFrame,
                CornerRadius = UDim.new(0, 6)
            })

            local LabelText = Linux.Instance("TextLabel", {
                Parent = LabelFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.Gotham,
                Text = config.Text or "Label",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 2
            })

            local UpdateConnection = nil
            local lastUpdate = 0
            local updateInterval = 0.1

            local function StartUpdateLoop()
                if UpdateConnection then
                    UpdateConnection:Disconnect()
                end
                if config.UpdateCallback then
                    UpdateConnection = RunService.Heartbeat:Connect(function()
                        if not LabelFrame:IsDescendantOf(game) then
                            UpdateConnection:Disconnect()
                            return
                        end
                        local currentTime = tick()
                        if currentTime - lastUpdate >= updateInterval then
                            local success, newText = pcall(config.UpdateCallback)
                            if success and newText ~= nil then
                                LabelText.Text = tostring(newText)
                            end
                            lastUpdate = currentTime
                        end
                    end)
                end
            end

            local function SetText(newText)
                if config.UpdateCallback then
                    config.Text = tostring(newText)
                else
                    LabelText.Text = tostring(newText)
                end
            end

            if config.UpdateCallback then
                StartUpdateLoop()
            end

            container.CanvasPosition = Vector2.new(0, 0)
            return {
                Instance = LabelFrame,
                SetText = SetText,
                GetText = function() return LabelText.Text end
            }
        end

        function TabElements.Section(config)
            local container = config.Container == 2 and Container2 or Container1
            local elementOrder = config.Container == 2 and elementOrder2 or elementOrder1
            if config.Container == 2 then
                elementOrder2 = elementOrder2 + 1
            else
                elementOrder1 = elementOrder1 + 1
            end

            local Section = Linux.Instance("Frame", {
                Parent = container,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -5, 0, 24),
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 2,
                LayoutOrder = elementOrder,
                BorderSizePixel = 0
            })

            Linux.Instance("TextLabel", {
                Parent = Section,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.SourceSansBold,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 18,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })

            container.CanvasPosition = Vector2.new(0, 0)
            return Section
        end

        function TabElements.Paragraph(config)
            local container = config.Container == 2 and Container2 or Container1
            local elementOrder = config.Container == 2 and elementOrder2 or elementOrder1
            if config.Container == 2 then
                elementOrder2 = elementOrder2 + 1
            else
                elementOrder1 = elementOrder1 + 1
            end

            local ParagraphFrame = Linux.Instance("Frame", {
                Parent = container,
                BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                BorderColor3 = Color3.fromRGB(50, 50, 50),
                BorderSizePixel = 2,
                Size = UDim2.new(1, -5, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 2,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = ParagraphFrame,
                CornerRadius = UDim.new(0, 6)
            })

            Linux.Instance("TextLabel", {
                Parent = ParagraphFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 0, 20),
                Position = UDim2.new(0, 5, 0, 5),
                Font = Enum.Font.GothamBold,
                Text = config.Title or "Paragraph",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })

            local Content = Linux.Instance("TextLabel", {
                Parent = ParagraphFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 0, 0),
                Position = UDim2.new(0, 5, 0, 25),
                Font = Enum.Font.Gotham,
                Text = config.Content or "Content",
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 2
            })

            Linux.Instance("UIPadding", {
                Parent = ParagraphFrame,
                PaddingBottom = UDim.new(0, 5)
            })

            local function SetTitle(newTitle)
                ParagraphFrame:GetChildren()[1].Text = tostring(newTitle)
            end

            local function SetContent(newContent)
                Content.Text = tostring(newContent)
            end

            container.CanvasPosition = Vector2.new(0, 0)
            return {
                Instance = ParagraphFrame,
                SetTitle = SetTitle,
                SetContent = SetContent
            }
        end

        function TabElements.Notification(config)
            local container = config.Container == 2 and Container2 or Container1
            local elementOrder = config.Container == 2 and elementOrder2 or elementOrder1
            if config.Container == 2 then
                elementOrder2 = elementOrder2 + 1
            else
                elementOrder1 = elementOrder1 + 1
            end

            local NotificationFrame = Linux.Instance("Frame", {
                Parent = container,
                BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                BorderColor3 = Color3.fromRGB(50, 50, 50),
                BorderSizePixel = 2,
                Size = UDim2.new(1, -5, 0, 34),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = NotificationFrame,
                CornerRadius = UDim.new(0, 6)
            })

            Linux.Instance("TextLabel", {
                Parent = NotificationFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.Gotham,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })

            local NotificationText = Linux.Instance("TextLabel", {
                Parent = NotificationFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -10, 1, 0),
                Position = UDim2.new(0.5, 5, 0, 0),
                Font = Enum.Font.Gotham,
                Text = config.Default or "Notification",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 2
            })

            local function SetText(newText)
                NotificationText.Text = tostring(newText)
            end

            container.CanvasPosition = Vector2.new(0, 0)
            return {
                Instance = NotificationFrame,
                SetText = SetText,
                GetText = function() return NotificationText.Text end
            }
        end

        return TabElements
    end

    return LinuxLib
end

return Linux
