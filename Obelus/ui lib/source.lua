-- // Library Tables
local library = {}
local utility = {}
local obelus = {
    connections = {}
}
-- // Services & Variables
local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local cre = game:GetService("CoreGui")
local soundService = game:GetService("SoundService") -- Ajouté pour les notifications
-- // Indexing
library.__index = library

-- // Notification Queue
local notificationQueue = {}
local isNotifying = false
local notificationGui

-- // Fonctions
do
    function utility:Create(createInfo)
        local createInfo = createInfo or {}
        if createInfo.Type then
            local instance = Instance.new(createInfo.Type)
            if createInfo.Properties and typeof(createInfo.Properties) == "table" then
                for property, value in pairs(createInfo.Properties) do
                    instance[property] = value
                end
            end
            return instance
        end
    end
    
    function utility:Connection(connectionInfo)
        local connectionInfo = connectionInfo or {}
        if connectionInfo.Type then
            local connection = connectionInfo.Type:Connect(connectionInfo.Callback or function() end)
            table.insert(obelus.connections, connection)
            return connection
        end
    end
    
    function utility:RemoveConnection(connectionInfo)
        local connectionInfo = connectionInfo or {}
        if connectionInfo.Connection then
            local found = table.find(obelus.connections, connectionInfo.Connection)
            if found then
                connectionInfo.Connection:Disconnect()
                table.remove(obelus.connections, found)
            end
        end
    end
end
-- // Ui Functions
do
    function library:Window(windowInfo)
        -- // Variables
        local info = windowInfo or {}
        local window = {Pages = {}, Dragging = false, Delta = UDim2.new(), Delta2 = Vector3.new(), activeDropdown = nil}
        local toggleDragging, toggleDelta, toggleDelta2 = false, UDim2.new(), Vector3.new()
        local isPotentialClick = false
        
        local isWindowOpen = false
        local isWindowAnimating = false

        -- // Utilisation
        local screen = utility:Create({Type = "ScreenGui", Properties = {
            Parent = cre,
            DisplayOrder = 8888,
            IgnoreGuiInset = true,
            Name = "obleus",
            ZIndexBehavior = "Global",
            ResetOnSpawn = false
        }})

        local main = utility:Create({Type = "Frame", Properties = {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(51, 51, 51),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderMode = "Inset",
            BorderSizePixel = 1,
            Parent = screen,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 516, 0, 390),
            Visible = false,
            ClipsDescendants = true
        }})

        local toggleButton = utility:Create({Type = "TextButton", Properties = {
            Parent = screen,
            Size = UDim2.new(0, 80, 0, 30),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderColor3 = Color3.fromRGB(170, 85, 235),
            Text = "Toggle UI",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = "Code",
            TextSize = 14,
            ZIndex = 9999
        }})
        
        toggleButton.MouseButton1Click:Connect(function()
            if isPotentialClick and not isWindowAnimating then
                isWindowAnimating = true
                isWindowOpen = not isWindowOpen
                local openSize = UDim2.new(0, 516, 0, 390)
                local closedSize = UDim2.new(0, 516, 0, 0)
                local animInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                local goal = {}
                if isWindowOpen then
                    goal.Size = openSize
                    main.Visible = true
                else
                    goal.Size = closedSize
                end
                local tween = ts:Create(main, animInfo, goal)
                tween.Completed:Connect(function()
                    if not isWindowOpen then main.Visible = false end
                    isWindowAnimating = false
                end)
                tween:Play()
            end
        end)

        utility:Connection({Type = toggleButton.InputBegan, Callback = function(Input)
            if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                toggleDragging = true
                isPotentialClick = true
                toggleDelta = toggleButton.Position
                toggleDelta2 = Input.Position
            end
        end})
        
        local frame = utility:Create({Type = "Frame", Properties = {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            BorderSizePixel = 0,
            Parent = main,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -2, 1, -2),
        }})

        local draggingButton = utility:Create({Type = "TextButton", Properties = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = frame,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 24),
            Text = ""
        }})
        
        local title = utility:Create({Type = "TextLabel", Properties = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = frame,
            Position = UDim2.new(0, 9, 0, 6),
            Size = UDim2.new(1, -16, 0, 15),
            Font = "Code",
            RichText = true,
            Text = info.Name or info.name or "obleus",
            TextColor3 = Color3.fromRGB(142, 142, 142),
            TextStrokeTransparency = 0.5,
            TextSize = 13,
            TextXAlignment = "Left"
        }})
        
        local accent = utility:Create({Type = "Frame", Properties = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = frame,
            Position = UDim2.new(0, 8, 0, 22),
            Size = UDim2.new(1, -16, 0, 2)
        }})
        
        utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(170, 85, 235), BorderSizePixel = 0, Parent = accent, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0, 1) }})
        utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(101, 51, 141), BorderSizePixel = 0, Parent = accent, Position = UDim2.new(0, 0, 0, 1), Size = UDim2.new(1, 0, 0, 1) }})
        
        local tabs = utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(1, 1, 1), BorderSizePixel = 0, Parent = frame, Position = UDim2.new(0, 8, 0, 29), Size = UDim2.new(1, -16, 0, 30) }})
        local tabsInline = utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(1, 1, 1), BorderSizePixel = 0, Parent = tabs, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, -1, 1, 0) }})
        utility:Create({Type = "UIListLayout", Properties = { Padding = UDim.new(0, 0), Parent = tabsInline, FillDirection = "Horizontal" }})
        
        local pagesHolder = utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(51, 51, 51), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderMode = "Inset", BorderSizePixel = 1, Parent = frame, Position = UDim2.new(0, 8, 0, 65), Size = UDim2.new(1, -16, 1, -76) }})
        local pagesFrame = utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(13, 13, 13), BorderSizePixel = 0, Parent = pagesHolder, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2) }})
        local pagesFolder = utility:Create({Type = "Folder", Properties = { Parent = pagesFrame }})
        
        utility:Connection({Type = draggingButton.InputBegan, Callback = function(Input)
            if not window.Dragging and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                window.Dragging = true
                window.Delta = main.Position
                window.Delta2 = Input.Position
            end
        end})
        
        utility:Connection({Type = uis.InputEnded, Callback = function(Input)
            if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                if window.Dragging then window.Dragging = false end
                if toggleDragging then toggleDragging = false end
            end
        end})
        
        utility:Connection({Type = uis.InputChanged, Callback = function(Input)
            if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                if window.Dragging then
                    local Delta = Input.Position - window.Delta2
                    main.Position = UDim2.new(window.Delta.X.Scale, window.Delta.X.Offset + Delta.X, window.Delta.Y.Scale, window.Delta.Y.Offset + Delta.Y)
                elseif toggleDragging then
                    isPotentialClick = false 
                    local Delta = Input.Position - toggleDelta2
                    toggleButton.Position = UDim2.new(toggleDelta.X.Scale, toggleDelta.X.Offset + Delta.X, toggleDelta.Y.Scale, toggleDelta.Y.Offset + Delta.Y)
                end
            end
        end})

        utility:Connection({Type = uis.InputBegan, Callback = function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and window.activeDropdown then
                if not window.activeDropdown.Menu.Visible or (not window.activeDropdown.Menu:IsAncestorOf(input.GuiObject) and not window.activeDropdown.Holder:IsAncestorOf(input.GuiObject)) then
                    window.activeDropdown:Close()
                end
            end
        end})

        function window:RefreshTabs()
            for index, page in pairs(window.Pages) do
                page.Tab.Size = UDim2.new(1 / (#window.Pages), 0, 1, 0)
            end
        end
        
        function window:Page(pageInfo)
            local info = pageInfo or {}
            local page = {Open = false}
            
            local tab = utility:Create({Type = "Frame", Properties = { BackgroundTransparency = 1, BorderSizePixel = 0, Parent = tabsInline, Size = UDim2.new(1, 0, 1, 0) }})
            local tabButton = utility:Create({Type = "TextButton", Properties = { BackgroundTransparency = 1, BorderSizePixel = 0, Parent = tab, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0) }})
            local tabInline = utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(41, 41, 41), BorderSizePixel = 0, Parent = tab, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -1, 1, -2) }})
            local tabInlineGradient = utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(41, 41, 41), BorderSizePixel = 0, Parent = tabInline, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2) }})
            local tabGradient = utility:Create({Type = "UIGradient", Properties = { Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100))}), Rotation = 90, Parent = tabInlineGradient }})
            local tabTitle = utility:Create({Type = "TextLabel", Properties = { AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = tabInlineGradient, Position = UDim2.new(0, 4, 0.5, 0), Size = UDim2.new(1, -8, 0, 15), Font = "Code", RichText = true, Text = info.Name or info.name or "tab", TextColor3 = Color3.fromRGB(142, 142, 142), TextStrokeTransparency = 0.5, TextSize = 13, TextXAlignment = "Center" }})
            local pageHolder = utility:Create({Type = "Frame", Properties = { BackgroundTransparency = 1, BorderSizePixel = 0, Parent = pagesFolder, Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(1, -20, 1, -20), Visible = false }})
            local leftHolder = utility:Create({Type = "Frame", Properties = { BackgroundTransparency = 1, BorderSizePixel = 0, Parent = pageHolder, Position = UDim2.new(0, 0, 0 ,0), Size = UDim2.new(0.5, -5, 1, 0) }})
            local rightHolder = utility:Create({Type = "Frame", Properties = { AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = pageHolder, Position = UDim2.new(1, 0, 0 ,0), Size = UDim2.new(0.5, -5, 1, 0) }})
            
            utility:Connection({Type = tabButton.MouseButton1Down, Callback = function()
                if not page.Open then
                    for index, other_page in pairs(window.Pages) do
                        if other_page ~= page then other_page:Turn(false) end
                    end
                end
                page:Turn(true)
            end})
            
            function page:Turn(state)
                tabTitle.TextColor3 = state and Color3.fromRGB(170, 85, 235) or Color3.fromRGB(142, 142, 142)
                tabGradient.Color = state and ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(155, 155, 155))}) or ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100))})
                page.PageHolder.Visible = state
                page.Open = state
            end
            
            function page:Section(sectionInfo)
                local info = sectionInfo or {}
                local section = {}
                
                local sectionMain = utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(45, 45, 45), BorderColor3 = Color3.fromRGB(13, 13, 13), BorderMode = "Inset", BorderSizePixel = 1, Parent = page[((info.Side and info.Side:lower() == "right") or (info.side and info.side:lower() == "right")) and "Right" or "Left"], Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0, (info.Size or info.size or 200) + 4) }})
                local sectionFrame = utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(19, 19, 19), BorderSizePixel = 0, Parent = sectionMain, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2) }})
                local sectionTitle = utility:Create({Type = "TextLabel", Properties = { AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = sectionMain, Position = UDim2.new(0, 13, 0, 0), Size = UDim2.new(1, -26, 0, 15), Font = "Code", RichText = true, Text = info.Name or info.name or "new section", TextColor3 = Color3.fromRGB(205, 205, 205), TextStrokeTransparency = 0.5, TextSize = 13, TextXAlignment = "Left", ZIndex = 2 }})
                utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(19, 19, 19), BorderSizePixel = 0, Parent = sectionMain, Position = UDim2.new(0, 9, 0, 0), Size = UDim2.new(0, sectionTitle.TextBounds.X + 6, 0, 1) }})
                
                local sectionContentHolder = utility:Create({Type = "ScrollingFrame", Properties = { BackgroundTransparency = 1, BorderSizePixel = 0, Parent = sectionFrame, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0), ZIndex = 4, AutomaticCanvasSize = "Y", CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65), ScrollBarThickness = 4, BorderMode = "Inset" }})
                utility:Create({Type = "UIPadding", Properties = { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), Parent = sectionContentHolder }})
                
                utility:Create({Type = "UIListLayout", Properties = {
                    Padding = UDim.new(0, 5),
                    Parent = sectionContentHolder,
                    FillDirection = "Vertical",
                    SortOrder = Enum.SortOrder.LayoutOrder
                }})
                
                function section:Label(labelInfo)
                    local info = labelInfo or {}
                    local label = {}
                    local contentHolder = utility:Create({Type = "Frame", Properties = { BackgroundTransparency = 1, BorderSizePixel = 0, Parent = sectionContentHolder, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = info.Order or 0 }})
                    utility:Create({Type = "TextLabel", Properties = { AnchorPoint = Vector2.new(0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = contentHolder, Size = UDim2.new(1, -(info.Offset or 36), 1, 0), Position = UDim2.new(0, info.Offset or 36, 0, 0), Font = "Code", RichText = true, Text = info.Name or info.name or info.Text or info.text or "new label", TextColor3 = Color3.fromRGB(180, 180, 180), TextStrokeTransparency = 0.5, TextSize = 13, TextXAlignment = "Left" }})
                    function label:Remove() contentHolder:Remove(); label = nil end
                    return label
                end
                
                function section:Toggle(toggleInfo)
                    local info = toggleInfo or {}
                    local toggle = { state = info.Default or false, callback = info.Callback or function() end }
                    local contentHolder = utility:Create({Type = "Frame", Properties = { BackgroundTransparency = 1, BorderSizePixel = 0, Parent = sectionContentHolder, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = info.Order or 0 }})
                    local toggleButton = utility:Create({Type = "TextButton", Properties = { BackgroundTransparency = 1, BorderSizePixel = 0, Parent = contentHolder, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0), Text = "" }})
                    utility:Create({Type = "TextLabel", Properties = { AnchorPoint = Vector2.new(0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = contentHolder, Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 36, 0, 0), Font = "Code", RichText = true, Text = info.Name or info.name or "new toggle", TextColor3 = Color3.fromRGB(180, 180, 180), TextStrokeTransparency = 0.5, TextSize = 13, TextXAlignment = "Left" }})
                    local toggleFrame = utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(1, 1, 1), BorderSizePixel = 0, Parent = contentHolder, Position = UDim2.new(0, 16, 0, 2), Size = UDim2.new(0, 10, 0, 10) }})
                    local toggleInlineGradient = utility:Create({Type = "Frame", Properties = { BackgroundColor3 = toggle.state and Color3.fromRGB(170, 85, 235) or Color3.fromRGB(63, 63, 63), BorderSizePixel = 0, Parent = toggleFrame, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2) }})
                    utility:Create({Type = "UIGradient", Properties = { Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 125, 125))}), Rotation = 90, Parent = toggleInlineGradient }})
                    local connection = utility:Connection({Type = toggleButton.MouseButton1Down, Callback = function() toggle:Set(not toggle.state, true) end})
                    function toggle:Remove() contentHolder:Remove(); utility:RemoveConnection({Connection = connection}); toggle = nil end
                    function toggle:Get() return toggle.state end
                    function toggle:Set(value, runCallback)
                        if typeof(value) == "boolean" then
                            toggle.state = value
                            toggleInlineGradient.BackgroundColor3 = toggle.state and Color3.fromRGB(170, 85, 235) or Color3.fromRGB(63, 63, 63)
                            if runCallback then toggle.callback(toggle.state) end
                        end
                    end
                    return toggle
                end
                
                function section:Button(buttonInfo)
                    local info = buttonInfo or {}
                    local button = { callback = info.Callback or function() end }
                    local contentHolder = utility:Create({Type = "Frame", Properties = { BackgroundTransparency = 1, BorderSizePixel = 0, Parent = sectionContentHolder, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = info.Order or 0 }})
                    local buttonButton = utility:Create({Type = "TextButton", Properties = { BackgroundTransparency = 1, BorderSizePixel = 0, Parent = contentHolder, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0), Text = "" }})
                    local buttonFrame = utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(45, 45, 45), BorderColor3 = Color3.fromRGB(1, 1, 1), BorderMode = "Inset", BorderSizePixel = 1, Parent = contentHolder, Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -32, 1, 0) }})
                    local buttonInline = utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(25, 25, 25), BorderSizePixel = 0, Parent = buttonFrame, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2) }})
                    utility:Create({Type = "TextLabel", Properties = { BackgroundTransparency = 1, BorderSizePixel = 0, Parent = contentHolder, Size = UDim2.new(1, -32, 1, 0), Position = UDim2.new(0, 16, 0, 0), Font = "Code", RichText = true, Text = info.Name or info.name or "new button", TextColor3 = Color3.fromRGB(180, 180, 180), TextStrokeTransparency = 0.5, TextSize = 13, TextXAlignment = "Center" }})
                    
                    local originalColor = buttonInline.BackgroundColor3
                    local pressedColor = Color3.new(originalColor.r * 0.7, originalColor.g * 0.7, originalColor.b * 0.7)
                    
                    local connection = utility:Connection({Type = buttonButton.MouseButton1Down, Callback = function()
                        buttonInline.BackgroundColor3 = pressedColor
                        button.callback()
                        task.wait(0.1)
                        buttonInline.BackgroundColor3 = originalColor
                    end})

                    function button:Remove() contentHolder:Remove(); utility:RemoveConnection({Connection = connection}); button = nil end
                    return button
                end
                
                function section:Slider(sliderInfo)
                    local info = sliderInfo or {}
                    local slider = { state = info.Default or 0, min = info.Minimum or 0, max = info.Maximum or 10, decimals = 1 / (info.Decimals or 0.25), suffix = info.Suffix or "", callback = info.Callback or function() end, holding = false }
                    local contentHolder = utility:Create({Type = "Frame", Properties = { BackgroundTransparency = 1, BorderSizePixel = 0, Parent = sectionContentHolder, Size = UDim2.new(1, 0, 0, (info.Name or info.name) and 24 or 10), LayoutOrder = info.Order or 0 }})
                    local sliderButton = utility:Create({Type = "TextButton", Properties = { BackgroundTransparency = 1, BorderSizePixel = 0, Parent = contentHolder, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0), Text = "" }})
                    if (info.Name or info.name) then utility:Create({Type = "TextLabel", Properties = { AnchorPoint = Vector2.new(0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = contentHolder, Size = UDim2.new(1, -16, 0, 14), Position = UDim2.new(0, 16, 0, 0), Font = "Code", RichText = true, Text = (info.Name or info.name), TextColor3 = Color3.fromRGB(180, 180, 180), TextStrokeTransparency = 0.5, TextSize = 13, TextXAlignment = "Left" }}) end
                    local sliderFrame = utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(1, 1, 1), BorderSizePixel = 0, Parent = contentHolder, Position = UDim2.new(0, 16, 0, (info.Name or info.name) and 14 or 0), Size = UDim2.new(1, -32, 0, 10) }})
                    local sliderInlineGradient = utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(63, 63, 63), BorderSizePixel = 0, Parent = sliderFrame, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2) }})
                    utility:Create({Type = "UIGradient", Properties = { Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 125, 125))}), Rotation = 90, Parent = sliderInlineGradient }})
                    local sliderSlideHolder = utility:Create({Type = "Frame", Properties = { BackgroundTransparency = 1, BorderSizePixel = 0, Parent = sliderFrame, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2) }})
                    local sliderSlide = utility:Create({Type = "Frame", Properties = { BackgroundColor3 = Color3.fromRGB(170, 85, 235), BorderSizePixel = 0, Parent = sliderSlideHolder, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0.5, 0, 1, 0) }})
                    utility:Create({Type = "UIGradient", Properties = { Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 125, 125))}), Rotation = 90, Parent = sliderSlide }})
                    local sliderValue = utility:Create({Type = "TextLabel", Properties = { AnchorPoint = Vector2.new(0.5, 0.25), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = sliderSlide, Size = UDim2.new(0, 10, 0, 14), Position = UDim2.new(1, 0, 0.5, 0), Font = "Code", RichText = true, Text = tostring(slider.state) .. tostring(slider.suffix), TextColor3 = Color3.fromRGB(180, 180, 180), TextStrokeTransparency = 0.5, TextSize = 13, TextXAlignment = "Left" }})
                    local c1 = utility:Connection({Type = sliderButton.MouseButton1Down, Callback = function() slider.holding = true; slider:Refresh() end})
                    local c2 = utility:Connection({Type = uis.InputEnded, Callback = function() slider.holding = false end})
                    local c3 = utility:Connection({Type = uis.InputChanged, Callback = function() if slider.holding then slider:Refresh() end end})
                    function slider:Remove() contentHolder:Remove(); utility:RemoveConnection({Connection=c1}); utility:RemoveConnection({Connection=c2}); utility:RemoveConnection({Connection=c3}); slider = nil end
                    function slider:Get() return slider.state end
                    function slider:Set(value, runCallback)
                        slider.state = math.clamp(math.round(value * slider.decimals) / slider.decimals, slider.min, slider.max)
                        sliderSlide.Size = UDim2.new((slider.state - slider.min) / (slider.max - slider.min), 0, 1, 0)
                        sliderValue.Text = tostring(slider.state) .. tostring(slider.suffix)
                        if runCallback then pcall(slider.callback, slider.state) end
                    end
                    function slider:Refresh()
                        if slider.holding then
                            local mouseLocation = uis:GetMouseLocation()
                            local percent = math.clamp((mouseLocation.X - sliderSlideHolder.AbsolutePosition.X) / sliderSlideHolder.AbsoluteSize.X, 0, 1)
                            local value = slider.min + (slider.max - slider.min) * percent
                            slider:Set(value, true)
                        end
                    end
                    slider:Set(slider.state)
                    return slider
                end

                --- [ NOUVELLE FONCTION DROPDOWN - Remplacée par le style Obsidian ] ---
                function section:Dropdown(dropdownInfo)
                    local info = dropdownInfo or {}
                    local dropdown = {
                        Text = info.Name or info.name or "Dropdown",
                        Value = info.Default or nil,
                        Values = info.Options or {},
                        Callback = info.Callback or function() end,
                        open = false
                    }

                    local contentHolder = utility:Create({Type = "Frame", Properties = {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, dropdown.Text and 39 or 21),
                        Visible = true,
                        Parent = sectionContentHolder,
                        LayoutOrder = info.Order or 0
                    }})

                    local label = utility:Create({Type = "TextLabel", Properties = {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 14),
                        Text = dropdown.Text,
                        Font = "Code",
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Visible = not not dropdown.Text,
                        Parent = contentHolder
                    }})

                    local display = utility:Create({Type = "TextButton", Properties = {
                        Active = true,
                        AnchorPoint = Vector2.new(0, 1),
                        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                        BorderColor3 = Color3.fromRGB(40, 40, 40),
                        BorderSizePixel = 1,
                        Position = UDim2.fromScale(0, 1),
                        Size = UDim2.new(1, 0, 0, 21),
                        Text = "---",
                        Font = "Code",
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = contentHolder
                    }})
                    
                    utility:Create({Type = "UIPadding", Properties = {
                        PaddingLeft = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 4),
                        Parent = display
                    }})

                    local arrowImage = utility:Create({Type = "ImageLabel", Properties = {
                        AnchorPoint = Vector2.new(1, 0.5),
                        Image = "rbxassetid://13420234828", -- Chevron-up icon
                        ImageColor3 = Color3.fromRGB(255, 255, 255),
                        ImageTransparency = 0.5,
                        Position = UDim2.fromScale(1, 0.5),
                        Rotation = 0,
                        Size = UDim2.fromOffset(16, 16),
                        Parent = display,
                        BackgroundTransparency = 1
                    }})
                    
                    local menu = utility:Create({Type = "ScrollingFrame", Properties = {
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
                        BorderColor3 = Color3.fromRGB(40, 40, 40),
                        BorderSizePixel = 1,
                        ScrollBarImageColor3 = Color3.fromRGB(40, 40, 40),
                        ScrollBarThickness = 2,
                        Visible = false,
                        ZIndex = 9998,
                        Parent = screen
                    }})
                    
                    utility:Create({Type = "UIListLayout", Properties = { Parent = menu }})
                    
                    local optionButtons = {}

                    function dropdown:BuildList()
                        for _, btn in pairs(optionButtons) do btn:Destroy() end
                        table.clear(optionButtons)

                        for _, optionName in ipairs(dropdown.Values) do
                            local optionButton = utility:Create({Type = "TextButton", Properties = {
                                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                                BackgroundTransparency = 1,
                                Size = UDim2.new(1, 0, 0, 21),
                                Text = tostring(optionName),
                                Font = "Code",
                                TextSize = 14,
                                TextColor3 = Color3.fromRGB(255, 255, 255),
                                TextTransparency = 0.5,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Parent = menu,
                                AutoButtonColor = false
                            }})

                            utility:Create({Type = "UIPadding", Properties = {
                                PaddingLeft = UDim.new(0, 7),
                                PaddingRight = UDim.new(0, 7),
                                Parent = optionButton
                            }})

                            local function updateButtonVisuals()
                                local selected = (dropdown.Value == optionName)
                                optionButton.BackgroundTransparency = selected and 0 or 1
                                optionButton.TextTransparency = selected and 0 or 0.5
                            end
                            
                            utility:Connection({Type = optionButton.MouseButton1Click, Callback = function()
                                dropdown:Set(optionName, true)
                                dropdown:Close()
                            end})

                            table.insert(optionButtons, {Button = optionButton, Update = updateButtonVisuals})
                            updateButtonVisuals()
                        end
                    end
                    
                    function dropdown:UpdateDisplay()
                        local str = dropdown.Value and tostring(dropdown.Value) or ""
                        if #str > 25 then str = str:sub(1, 22) .. "..." end
                        display.Text = (str == "" and "---" or str)
                    end
                    
                    function dropdown:Close()
                        if not dropdown.open then return end
                        dropdown.open = false
                        menu.Visible = false
                        arrowImage.Rotation = 0
                        arrowImage.ImageTransparency = 0.5
                        window.activeDropdown = nil
                    end

                    function dropdown:Open()
                        if dropdown.open then return end
                        if window.activeDropdown then window.activeDropdown:Close() end

                        dropdown.open = true
                        dropdown:BuildList()
                        
                        local maxItems = 8
                        local ySize = math.min(#dropdown.Values * 21, maxItems * 21)
                        
                        menu.Position = UDim2.fromOffset(display.AbsolutePosition.X + 0.5, display.AbsolutePosition.Y + display.AbsoluteSize.Y + 1.5)
                        menu.Size = UDim2.fromOffset(display.AbsoluteSize.X, ySize)
                        menu.Visible = true
                        
                        arrowImage.Rotation = 180
                        arrowImage.ImageTransparency = 0
                        
                        window.activeDropdown = dropdown
                    end
                    
                    utility:Connection({Type = display.MouseButton1Click, Callback = function()
                        if dropdown.open then dropdown:Close() else dropdown:Open() end
                    end})

                    function dropdown:Get() return dropdown.Value end
                    function dropdown:Set(value, runCallback)
                        if table.find(dropdown.Values, value) or value == nil then
                            dropdown.Value = value
                            dropdown:UpdateDisplay()
                            
                            for _, btnInfo in pairs(optionButtons) do
                                btnInfo.Update()
                            end

                            if runCallback then pcall(dropdown.Callback, dropdown.Value) end
                        end
                    end

                    function dropdown:Remove()
                        contentHolder:Destroy()
                        menu:Destroy()
                        dropdown = nil
                    end

                    -- Pour la fonctionnalité "cliquer à l'extérieur pour fermer"
                    dropdown.Menu = menu
                    dropdown.Holder = display

                    dropdown:Set(dropdown.Value, false) -- Définir la valeur initiale
                    
                    return dropdown
                end
                
                return section
            end
            
            page.Tab = tab; page.PageHolder = pageHolder; page.Left = leftHolder; page.Right = rightHolder;
            window.Pages[#window.Pages + 1] = page
            window:RefreshTabs()
            return page
        end
        return window
    end
end

-- // [NOUVEAU SYSTÈME DE NOTIFICATION - Remplacé par le style Obsidian]
function library:Notify(info)
    info = info or {}
    local data = {
        Title = info.Title,
        Description = info.Text or info.Description or "",
        Time = info.Duration or 5,
        SoundId = info.SoundId,
        Persist = info.Persist,
        Destroyed = false
    }

    if not notificationGui then
        notificationGui = utility:Create({Type = "ScreenGui", Properties = { Parent = cre, DisplayOrder = 9999, Name = "Obelus_Notifications", ZIndexBehavior = "Global", ResetOnSpawn = false }})
        utility:Create({Type = "UIListLayout", Properties = {
            Parent = notificationGui,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6)
        }})
        notificationGui.AnchorPoint = Vector2.new(1, 0)
        notificationGui.Position = UDim2.new(1, -6, 0, 6)
        notificationGui.Size = UDim2.new(0, 300, 1, -6)
    end
    
    local fakeBackground = utility:Create({Type = "Frame", Properties = {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        Visible = false,
        Parent = notificationGui,
    }})

    -- Fonction 'MakeOutline' recréée
    local background
    do
        local holder = utility:Create({Type = "Frame", Properties = {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            Position = UDim2.fromOffset(-2, -2),
            Size = UDim2.new(1, 4, 1, 4),
            ZIndex = 5,
            Parent = fakeBackground
        }})
        utility:Create({Type = "UICorner", Properties = { CornerRadius = UDim.new(0, 4 + 1), Parent = holder }})
        
        background = utility:Create({Type = "Frame", Properties = {
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Position = UDim2.fromOffset(1, 1),
            Size = UDim2.new(1, -2, 1, -2),
            ZIndex = 5,
            Parent = holder
        }})
        utility:Create({Type = "UICorner", Properties = { CornerRadius = UDim.new(0, 4), Parent = background }})
        background.AutomaticSize = Enum.AutomaticSize.Y
        background.Position = UDim2.new(1, 6, 0, -2)
        background.Size = UDim2.fromScale(1, 0)
    end
    
    local holder = utility:Create({Type = "Frame", Properties = {
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.new(1, -4, 1, -4),
        Parent = background
    }})
    utility:Create({Type = "UICorner", Properties = { CornerRadius = UDim.new(0, 4 - 1), Parent = holder }})
    utility:Create({Type = "UIListLayout", Properties = { Padding = UDim.new(0, 4), Parent = holder }})
    utility:Create({Type = "UIPadding", Properties = {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = holder
    }})
    
    if data.Title then
        utility:Create({Type = "TextLabel", Properties = {
            BackgroundTransparency = 1,
            Text = data.Title,
            Font = "Code",
            TextSize = 15,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            AutomaticSize = "Y",
            Size = UDim2.new(1,0,0,0),
            Parent = holder,
        }})
    end

    if data.Description then
        utility:Create({Type = "TextLabel", Properties = {
            BackgroundTransparency = 1,
            Text = data.Description,
            Font = "Code",
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            AutomaticSize = "Y",
            Size = UDim2.new(1,0,0,0),
            Parent = holder,
        }})
    end
    
    local timerHolder = utility:Create({Type = "Frame", Properties = {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 7),
        Visible = not data.Persist,
        Parent = holder,
    }})
    local timerBar = utility:Create({Type = "Frame", Properties = {
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 1,
        Position = UDim2.fromOffset(0, 3),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = timerHolder,
    }})
    local timerFill = utility:Create({Type = "Frame", Properties = {
        BackgroundColor3 = Color3.fromRGB(125, 85, 255),
        Size = UDim2.fromScale(1, 1),
        Parent = timerBar,
    }})
    
    function data:Destroy()
        if data.Destroyed then return end
        data.Destroyed = true
        
        local tweenOut = ts:Create(background, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, 6, 0, -2)})
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            fakeBackground:Destroy()
        end)
    end
    
    if data.SoundId then
        local soundIdStr = (typeof(data.SoundId) == "number") and `rbxassetid://{data.SoundId}` or data.SoundId
        utility:Create({Type = "Sound", Properties = {
            SoundId = soundIdStr,
            Volume = 3,
            PlayOnRemove = true,
            Parent = soundService,
        }}):Destroy()
    end
    
    fakeBackground.Visible = true
    local tweenIn = ts:Create(background, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(-2, -2)})
    tweenIn:Play()

    task.delay(0.25, function()
        if not data.Persist then
            local timerTween = ts:Create(timerFill, TweenInfo.new(data.Time, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0, 1)})
            timerTween:Play()
            task.wait(data.Time)
            data:Destroy()
        end
    end)
    
    return data
end


return library
