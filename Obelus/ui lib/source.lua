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
-- // Indexing
library.__index = library

-- // System-wide state
local notificationQueue = {}
local isNotifying = false
local notificationGui
local activeDropdown = nil

-- // Functions
do
	function utility:Create(createInfo) local createInfo = createInfo or {}; if createInfo.Type then local i = Instance.new(createInfo.Type); if createInfo.Properties and typeof(createInfo.Properties) == "table" then for p, v in pairs(createInfo.Properties) do i[p] = v end end; return i end end
	function utility:Connection(connectionInfo) local connectionInfo = connectionInfo or {}; if connectionInfo.Type then local c = connectionInfo.Type:Connect(connectionInfo.Callback or function() end); table.insert(obelus.connections, c); return c end end
	function utility:RemoveConnection(connectionInfo) local connectionInfo = connectionInfo or {}; if connectionInfo.Connection then local f = table.find(obelus.connections, connectionInfo.Connection); if f then connectionInfo.Connection:Disconnect(); table.remove(obelus.connections, f) end end end
end
-- // Ui Functions
do
	function library:Window(windowInfo)
		-- // Variables
		local info = windowInfo or {}
		local window = {Pages = {}, Dragging = false, Delta = UDim2.new(), Delta2 = Vector3.new()}
        local toggleDragging, toggleDelta, toggleDelta2 = false, UDim2.new(), Vector3.new()
        local isPotentialClick = false
		local isWindowOpen = false
		local isWindowAnimating = false
		local isPageAnimating = false

		-- // Utilisation
		local screen = utility:Create({Type = "ScreenGui", Properties = {Parent = cre, DisplayOrder = 8888, IgnoreGuiInset = true, Name = "obleus", ZIndexBehavior = "Global", ResetOnSpawn = false}})
		local main = utility:Create({Type = "Frame", Properties = {AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(51, 51, 51), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderMode = "Inset", BorderSizePixel = 1, Parent = screen, Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 516, 0, 390), Visible = false, ClipsDescendants = true}})
        local toggleButton = utility:Create({Type = "TextButton", Properties = {Parent = screen, Size = UDim2.new(0, 80, 0, 30), Position = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderColor3 = Color3.fromRGB(170, 85, 235), Text = "Toggle UI", TextColor3 = Color3.fromRGB(255, 255, 255), Font = "Code", TextSize = 14, ZIndex = 9999}})
		
		toggleButton.MouseButton1Click:Connect(function()
            if isPotentialClick and not isWindowAnimating then
				isWindowAnimating = true; isWindowOpen = not isWindowOpen
				local openSize, closedSize = UDim2.new(0, 516, 0, 390), UDim2.new(0, 516, 0, 0)
				local animInfo, goal = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {}
				if isWindowOpen then goal.Size = openSize; main.Visible = true else goal.Size = closedSize end
				local tween = ts:Create(main, animInfo, goal)
				tween.Completed:Connect(function() if not isWindowOpen then main.Visible = false end; isWindowAnimating = false end)
				tween:Play()
            end
        end)

		utility:Connection({Type = toggleButton.InputBegan, Callback = function(Input) if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then toggleDragging = true; isPotentialClick = true; toggleDelta = toggleButton.Position; toggleDelta2 = Input.Position end end})
		
		local frame = utility:Create({Type = "Frame", Properties = {AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(12, 12, 12), BorderSizePixel = 0, Parent = main, Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, -2, 1, -2)}})
		local draggingButton = utility:Create({Type = "TextButton", Properties = {BackgroundTransparency = 1, BorderSizePixel = 0, Parent = frame, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0, 24), Text = ""}})
		local title = utility:Create({Type = "TextLabel", Properties = {BackgroundTransparency = 1, BorderSizePixel = 0, Parent = frame, Position = UDim2.new(0, 9, 0, 6), Size = UDim2.new(1, -16, 0, 15), Font = "Code", RichText = true, Text = info.Name or info.name or "obleus", TextColor3 = Color3.fromRGB(142, 142, 142), TextStrokeTransparency = 0.5, TextSize = 13, TextXAlignment = "Left"}})
		local accent = utility:Create({Type = "Frame", Properties = {BackgroundTransparency = 1, BorderSizePixel = 0, Parent = frame, Position = UDim2.new(0, 8, 0, 22), Size = UDim2.new(1, -16, 0, 2)}})
		utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(170, 85, 235), BorderSizePixel = 0, Parent = accent, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0, 1)}})
		utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(101, 51, 141), BorderSizePixel = 0, Parent = accent, Position = UDim2.new(0, 0, 0, 1), Size = UDim2.new(1, 0, 0, 1)}})
		local tabs = utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(1, 1, 1), BorderSizePixel = 0, Parent = frame, Position = UDim2.new(0, 8, 0, 29), Size = UDim2.new(1, -16, 0, 30)}})
		local tabsInline = utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(1, 1, 1), BorderSizePixel = 0, Parent = tabs, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, -1, 1, 0)}})
		utility:Create({Type = "UIListLayout", Properties = {Padding = UDim.new(0, 0), Parent = tabsInline, FillDirection = "Horizontal"}})
		local pagesHolder = utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(51, 51, 51), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderMode = "Inset", BorderSizePixel = 1, Parent = frame, Position = UDim2.new(0, 8, 0, 65), Size = UDim2.new(1, -16, 1, -76)}})
		local pagesFrame = utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(13, 13, 13), BorderSizePixel = 0, Parent = pagesHolder, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2)}})
		local pagesFolder = utility:Create({Type = "Folder", Properties = {Parent = pagesFrame}})
		
		utility:Connection({Type = draggingButton.InputBegan, Callback = function(Input) if not window.Dragging and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then window.Dragging = true; window.Delta = main.Position; window.Delta2 = Input.Position; end end})
		utility:Connection({Type = uis.InputEnded, Callback = function(Input) if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then if window.Dragging then window.Dragging = false; end; if toggleDragging then toggleDragging = false; end; end end})
		utility:Connection({Type = uis.InputChanged, Callback = function(Input) if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then if window.Dragging then local Delta = Input.Position - window.Delta2; main.Position = UDim2.new(window.Delta.X.Scale, window.Delta.X.Offset + Delta.X, window.Delta.Y.Scale, window.Delta.Y.Offset + Delta.Y); elseif toggleDragging then isPotentialClick = false; local Delta = Input.Position - toggleDelta2; toggleButton.Position = UDim2.new(toggleDelta.X.Scale, toggleDelta.X.Offset + Delta.X, toggleDelta.Y.Scale, toggleDelta.Y.Offset + Delta.Y); end; end end})
		
		function window:RefreshTabs() for _, page in pairs(window.Pages) do page.Tab.Size = UDim2.new(1 / (#window.Pages), 0, 1, 0); end end
		
		function window:Page(pageInfo)
			local info, page = pageInfo or {}, {Open = false}
			local tab = utility:Create({Type = "Frame", Properties = {BackgroundTransparency = 1, BorderSizePixel = 0, Parent = tabsInline, Size = UDim2.new(1, 0, 1, 0)}})
			local tabButton = utility:Create({Type = "TextButton", Properties = {BackgroundTransparency = 1, BorderSizePixel = 0, Parent = tab, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0)}})
			local tabInline = utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(41, 41, 41), BorderSizePixel = 0, Parent = tab, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -1, 1, -2)}})
			local tabInlineGradient = utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(41, 41, 41), BorderSizePixel = 0, Parent = tabInline, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2)}})
			local tabGradient = utility:Create({Type = "UIGradient", Properties = {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100))}), Rotation = 90, Parent = tabInlineGradient}})
			local tabTitle = utility:Create({Type = "TextLabel", Properties = {AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = tabInlineGradient, Position = UDim2.new(0, 4, 0.5, 0), Size = UDim2.new(1, -8, 0, 15), Font = "Code", RichText = true, Text = info.Name or info.name or "tab", TextColor3 = Color3.fromRGB(142, 142, 142), TextStrokeTransparency = 0.5, TextSize = 13, TextXAlignment = "Center"}})
			local pageHolder = utility:Create({Type = "Frame", Properties = {BackgroundTransparency = 1, BorderSizePixel = 0, Parent = pagesFolder, Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(1, -20, 1, -20), Visible = false}})
			utility:Create({Type = "CanvasGroup", Properties = {Parent = pageHolder, GroupTransparency = 1}})
			local leftHolder = utility:Create({Type = "Frame", Properties = {BackgroundTransparency = 1, BorderSizePixel = 0, Parent = pageHolder, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0.5, -5, 1, 0)}})
			local rightHolder = utility:Create({Type = "Frame", Properties = {AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = pageHolder, Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0.5, -5, 1, 0)}})
			
			utility:Connection({Type = tabButton.MouseButton1Down, Callback = function() if isPageAnimating or page.Open then return end; isPageAnimating = true; for _, other_page in pairs(window.Pages) do if other_page.Open then other_page:Turn(false) end end; task.wait(0.2); page:Turn(true); end})
			local animInfo = TweenInfo.new(0.1); utility:Connection({Type = tabButton.InputBegan, Callback = function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local c = tabInline.BackgroundColor3; ts:Create(tabInline, animInfo, {BackgroundColor3 = Color3.new(c.r*0.7, c.g*0.7, c.b*0.7)}):Play() end end}); utility:Connection({Type = tabButton.InputEnded, Callback = function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then ts:Create(tabInline, animInfo, {BackgroundColor3 = Color3.fromRGB(41,41,41)}):Play() end end})

			function page:Turn(state)
				page.Open = state; tabTitle.TextColor3 = state and Color3.fromRGB(170, 85, 235) or Color3.fromRGB(142, 142, 142); tabGradient.Color = state and ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(155, 155, 155))}) or ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100))})
				local anim = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out); local tween;
				if state then page.PageHolder.Visible = true; tween = ts:Create(page.PageHolder.CanvasGroup, anim, {GroupTransparency = 0}) else tween = ts:Create(page.PageHolder.CanvasGroup, anim, {GroupTransparency = 1}) end
				tween.Completed:Connect(function() if not state then page.PageHolder.Visible = false end; isPageAnimating = false end)
				tween:Play()
			end
			
			function page:Section(sectionInfo)
				local info, section = sectionInfo or {}, {}
				local sectionMain = utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(45, 45, 45), BorderColor3 = Color3.fromRGB(13, 13, 13), BorderMode = "Inset", BorderSizePixel = 1, Parent = page[((info.Side and info.Side:lower() == "right") or (info.side and info.side:lower() == "right")) and "Right" or "Left"], Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0, (info.Size or info.size or 200) + 4)}})
				local sectionFrame = utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(19, 19, 19), BorderSizePixel = 0, Parent = sectionMain, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2)}})
				local sectionTitle = utility:Create({Type = "TextLabel", Properties = {AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = sectionMain, Position = UDim2.new(0, 13, 0, 0), Size = UDim2.new(1, -26, 0, 15), Font = "Code", RichText = true, Text = info.Name or info.name or "new section", TextColor3 = Color3.fromRGB(205, 205, 205), TextStrokeTransparency = 0.5, TextSize = 13, TextXAlignment = "Left", ZIndex = 2}})
				utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(19, 19, 19), BorderSizePixel = 0, Parent = sectionMain, Position = UDim2.new(0, 9, 0, 0), Size = UDim2.new(0, sectionTitle.TextBounds.X + 6, 0, 1)}})
				local sectionContentHolder = utility:Create({Type = "ScrollingFrame", Properties = {BackgroundTransparency = 1, BorderSizePixel = 0, Parent = sectionFrame, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0), ZIndex = 4, AutomaticCanvasSize = "Y", ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65), ScrollBarThickness = 4}})
				utility:Create({Type = "UIListLayout", Properties = {Padding = UDim.new(0, 5), Parent = sectionContentHolder, FillDirection = "Vertical"}})
				utility:Create({Type = "UIPadding", Properties = {Parent = sectionContentHolder, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)}})
				
				function section:Label(labelInfo) local info = labelInfo or {}; local label = {}; local h = utility:Create({Type = "Frame", Properties = {BackgroundTransparency = 1, BorderSizePixel = 0, Parent = sectionContentHolder, Size = UDim2.new(1, 0, 0, 14)}}); utility:Create({Type = "TextLabel", Properties = {AnchorPoint = Vector2.new(0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = h, Size = UDim2.new(1, -(info.Offset or 36), 1, 0), Position = UDim2.new(0, info.Offset or 36, 0, 0), Font = "Code", RichText = true, Text = info.Name or "new label", TextColor3 = Color3.fromRGB(180, 180, 180), TextStrokeTransparency = 0.5, TextSize = 13, TextXAlignment = "Left"}}); function label:Remove() h:Destroy() end; return label; end
				function section:Toggle(toggleInfo) local info = toggleInfo or {}; local toggle = { state = (info.Default or false), callback = (info.Callback or function() end) }; local h = utility:Create({Type = "Frame", Properties = {BackgroundTransparency = 1, Parent = sectionContentHolder, Size = UDim2.new(1, 0, 0, 14)}}); local b = utility:Create({Type = "TextButton", Properties = {BackgroundTransparency = 1, Parent = h, Size = UDim2.new(1, 0, 1, 0), Text = ""}}); utility:Create({Type = "TextLabel", Properties = { BackgroundTransparency = 1, Parent = h, Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 36, 0, 0), Font = "Code", Text = info.Name or "new toggle", TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 13, TextXAlignment = "Left"}}); local f = utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(1, 1, 1), Parent = h, Position = UDim2.new(0, 16, 0, 2), Size = UDim2.new(0, 10, 0, 10)}}); local i = utility:Create({Type = "Frame", Properties = {BackgroundColor3 = toggle.state and Color3.fromRGB(170, 85, 235) or Color3.fromRGB(63, 63, 63), Parent = f, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2)}}); utility:Create({Type = "UIGradient", Properties = {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 125, 125))}), Parent = i}}); local c = utility:Connection({Type = b.MouseButton1Down, Callback = function() toggle.state = not toggle.state; i.BackgroundColor3 = toggle.state and Color3.fromRGB(170, 85, 235) or Color3.fromRGB(63, 63, 63); toggle.callback(toggle.state) end}); function toggle:Remove() h:Destroy(); utility:RemoveConnection({Connection = c}) end; function toggle:Get() return toggle.state end; function toggle:Set(v) if typeof(v) == "boolean" then toggle.state = v; i.BackgroundColor3 = v and Color3.fromRGB(170, 85, 235) or Color3.fromRGB(63, 63, 63) end end; return toggle; end
				function section:Button(buttonInfo) local info = buttonInfo or {}; local button = {callback = (info.Callback or function() end)}; local h = utility:Create({Type = "Frame", Properties = {BackgroundTransparency = 1, Parent = sectionContentHolder, Size = UDim2.new(1, 0, 0, 20)}}); local b = utility:Create({Type = "TextButton", Properties = {BackgroundTransparency = 1, Parent = h, Size = UDim2.new(1, 0, 1, 0), Text = ""}}); local f = utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(45, 45, 45), BorderColor3 = Color3.fromRGB(1, 1, 1), Parent = h, Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -32, 1, 0)}}); local i = utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(25, 25, 25), Parent = f, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2)}}); utility:Create({Type = "TextLabel", Properties = {BackgroundTransparency = 1, Parent = h, Size = UDim2.new(1, -32, 1, 0), Position = UDim2.new(0, 16, 0, 0), Font = "Code", Text = info.Name or "new button", TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 13, TextXAlignment = "Center"}}); local oC, pC = i.BackgroundColor3, Color3.new(i.BackgroundColor3.r * 0.7, i.BackgroundColor3.g * 0.7, i.BackgroundColor3.b * 0.7); local aI = TweenInfo.new(0.1); utility:Connection({Type = b.InputBegan, Callback = function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then ts:Create(i, aI, {BackgroundColor3 = pC}):Play() end end}); utility:Connection({Type = b.InputEnded, Callback = function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then ts:Create(i, aI, {BackgroundColor3 = oC}):Play() end end}); local c = utility:Connection({Type = b.MouseButton1Down, Callback = button.callback}); function button:Remove() h:Destroy(); utility:RemoveConnection({Connection = c}); end; return button; end
				function section:Slider(sliderInfo) local info = sliderInfo or {}; local slider = { state = (info.Default or 0), min = (info.Minimum or 0), max = (info.Maximum or 10), decimals = (1 / (info.Decimals or 0.25)), suffix = (info.Suffix or ""), callback = (info.Callback or function() end), holding = false }; local h = utility:Create({Type = "Frame", Properties = {BackgroundTransparency = 1, Parent = sectionContentHolder, Size = UDim2.new(1, 0, 0, (info.Name and 24 or 10))}}); local b = utility:Create({Type = "TextButton", Properties = {BackgroundTransparency = 1, Parent = h, Size = UDim2.new(1, 0, 1, 0), Text = ""}}); if info.Name then utility:Create({Type = "TextLabel", Properties = {BackgroundTransparency = 1, Parent = h, Size = UDim2.new(1, -16, 0, 14), Position = UDim2.new(0, 16, 0, 0), Font = "Code", Text = info.Name, TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 13, TextXAlignment = "Left"}}); end; local f = utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(1, 1, 1), Parent = h, Position = UDim2.new(0, 16, 0, (info.Name and 14 or 0)), Size = UDim2.new(1, -32, 0, 10)}}); local i = utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(63, 63, 63), Parent = f, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2)}}); utility:Create({Type = "UIGradient", Properties = {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 125, 125))}), Parent = i}}); local sh = utility:Create({Type = "Frame", Properties = {BackgroundTransparency = 1, Parent = f, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2)}}); local s = utility:Create({Type = "Frame", Properties = {BackgroundColor3 = Color3.fromRGB(170, 85, 235), Parent = sh, Size = UDim2.new(0.5, 0, 1, 0)}}); utility:Create({Type = "UIGradient", Properties = {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 125, 125))}), Parent = s}}); local v = utility:Create({Type = "TextLabel", Properties = {AnchorPoint = Vector2.new(0.5, 0.25), BackgroundTransparency = 1, Parent = s, Size = UDim2.new(0, 10, 0, 14), Position = UDim2.new(1, 0, 0.5, 0), Font = "Code", Text = tostring(slider.state)..slider.suffix, TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 13, TextXAlignment = "Left"}}); local c1 = utility:Connection({Type = b.MouseButton1Down, Callback = function() slider.holding = true; slider:Refresh(); end}); local c2 = utility:Connection({Type = uis.InputEnded, Callback = function() slider.holding = false; end}); local c3 = utility:Connection({Type = uis.InputChanged, Callback = function() if slider.holding then slider:Refresh(); end; end}); function slider:Remove() h:Destroy(); utility:RemoveConnection({Connection = c1}); utility:RemoveConnection({Connection = c2}); utility:RemoveConnection({Connection = c3}); end; function slider:Get() return slider.state; end; function slider:Set(val) slider.state = math.clamp(math.round(val * slider.decimals) / slider.decimals, slider.min, slider.max); s.Size = UDim2.new(math.clamp((slider.state - slider.min) / (slider.max - slider.min), 0, 1), 0, 1, 0); v.Text = tostring(slider.state) .. slider.suffix; pcall(slider.callback, slider.state); end; function slider:Refresh() if slider.holding then local m = uis:GetMouseLocation(); slider:Set((slider.min + (slider.max - slider.min) * (math.clamp(m.X - sh.AbsolutePosition.X, 0, sh.AbsoluteSize.X) / sh.AbsoluteSize.X))); end; end; slider:Set(slider.state); return slider; end
				function section:Dropdown(dropdownInfo)
					local info, dropdown = dropdownInfo or {}, {}; local options = info.Options or {"Option 1"}; local callback = info.Callback or function() end; local default = info.Default or options[1]; dropdown.state = default; local isOpen = false
					local h = utility:Create({Type = "Frame", Properties = {BackgroundTransparency = 1, Parent = sectionContentHolder, Size = UDim2.new(1, 0, 0, 34), ZIndex = 2}});
					if info.Name then utility:Create({Type = "TextLabel", Properties = {BackgroundTransparency = 1, Parent = h, Size = UDim2.new(1, -16, 0, 14), Position = UDim2.new(0, 16, 0, 0), Font = "Code", Text = info.Name, TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 13, TextXAlignment = "Left"}}); end
					local mainButton = utility:Create({Type = "TextButton", Properties = {BackgroundTransparency = 1, Parent = h, Size = UDim2.new(1, -32, 0, 20), Position = UDim2.new(0, 16, 0, 14), Text = ""}})
					local mainFrame = utility:Create({Type = "Frame", Properties = {Parent = mainButton, BackgroundColor3 = Color3.fromRGB(25, 25, 25), BorderColor3 = Color3.fromRGB(1, 1, 1), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1, 0, 1, 0)}})
					local currentLabel = utility:Create({Type = "TextLabel", Properties = {Parent = mainFrame, Size = UDim2.new(1, -25, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Font = "Code", Text = dropdown.state, TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 13, TextXAlignment = "Left"}})
					local arrowLabel = utility:Create({Type = "TextLabel", Properties = {Parent = mainFrame, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 0), Size = UDim2.new(0, 20, 1, 0), BackgroundTransparency = 1, Font = "Code", Text = "▼", TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 13}})
					local optionsHolder = utility:Create({Type = "ScrollingFrame", Properties = {Parent = pagesFrame, BackgroundColor3 = Color3.fromRGB(45, 45, 45), BorderColor3 = Color3.fromRGB(1, 1, 1), BorderSizePixel = 1, ClipsDescendants = true, Visible = false, ZIndex = 100, ScrollBarThickness = 4}})
					utility:Create({Type = "UIListLayout", Properties = {Parent = optionsHolder, SortOrder = "LayoutOrder"}})
					local scrim = utility:Create({Type = "TextButton", Properties = {Parent = screen, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 99, Visible = false}})
					
					local function closeDropdown() isOpen = false; optionsHolder.Visible = false; scrim.Visible = false; ts:Create(arrowLabel, TweenInfo.new(0.2), {Rotation = 0}):Play(); end
					local function openDropdown() if activeDropdown and activeDropdown ~= dropdown then activeDropdown:Close() end; activeDropdown = dropdown; isOpen = true; optionsHolder.Visible = true; scrim.Visible = true; local sizeY = math.min(#options * 20, 100); optionsHolder.Size = UDim2.new(0, mainButton.AbsoluteSize.X, 0, sizeY); optionsHolder.Position = UDim2.fromOffset(mainButton.AbsolutePosition.X, mainButton.AbsolutePosition.Y + mainButton.AbsoluteSize.Y); ts:Create(arrowLabel, TweenInfo.new(0.2), {Rotation = 180}):Play(); end
					
					scrim.MouseButton1Click:Connect(closeDropdown)
					for _, optionName in ipairs(options) do local optionButton = utility:Create({Type = "TextButton", Properties = {Parent = optionsHolder, Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = Color3.fromRGB(35, 35, 35), BorderSizePixel = 0, Font = "Code", Text = "  " .. optionName, TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 13, TextXAlignment = "Left"}}); optionButton.MouseButton1Click:Connect(function() dropdown.state = optionName; currentLabel.Text = optionName; callback(optionName); closeDropdown() end) end
					mainButton.MouseButton1Click:Connect(function() if isOpen then closeDropdown() else openDropdown() end end)
					
					function dropdown:Get() return dropdown.state end
					function dropdown:Set(newValue) local isValid = table.find(options, newValue); if isValid then dropdown.state = newValue; currentLabel.Text = newValue; callback(newValue) end end
					function dropdown:Close() closeDropdown() end

					return dropdown
				end
				return section
			end
			page.Tab = tab; page.PageHolder = pageHolder; page.Left = leftHolder; page.Right = rightHolder; table.insert(window.Pages, page); window:RefreshTabs(); return page
		end
		return window
	end
end

-- // [IMPROVED] Notification System
local function processNotificationQueue()
	if #notificationQueue == 0 or isNotifying then return end
	isNotifying = true; local info = table.remove(notificationQueue, 1); local title, text, duration, color = info.Title or "Notification", info.Text or "", info.Duration or 5, info.Color or Color3.fromRGB(170, 85, 235)
	local frame = utility:Create({Type = "Frame", Properties = {Parent = notificationGui, Size = UDim2.new(0, 300, 0, 60), AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 310, 1, -10), BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderColor3 = Color3.fromRGB(10, 10, 10), BorderSizePixel = 2}})
	local accent = utility:Create({Type = "Frame", Properties = {Parent = frame, Size = UDim2.new(1, 0, 0, 4), BackgroundColor3 = color, BorderSizePixel = 0}})
	utility:Create({Type = "TextLabel", Properties = {Parent = frame, Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 5, 0, 5), Font = "Code", Text = title, TextColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = "Left", BackgroundTransparency = 1, TextSize = 16}})
	utility:Create({Type = "TextLabel", Properties = {Parent = frame, Size = UDim2.new(1, -10, 1, -28), Position = UDim2.new(0, 5, 0, 28), Font = "Code", Text = text, TextColor3 = Color3.fromRGB(200, 200, 200), TextXAlignment = "Left", TextYAlignment = "Top", TextWrapped = true, BackgroundTransparency = 1, TextSize = 14}})
	local animInfo, animIn, animOut = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), ts:Create(frame, animInfo, {Position = UDim2.new(1, -10, 1, -10)}), ts:Create(frame, animInfo, {Position = UDim2.new(1, 310, 1, -10)})
	local timerAnim = ts:Create(accent, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 4)})
	animIn:Play(); animIn.Completed:Wait(); timerAnim:Play(); timerAnim.Completed:Wait(); animOut:Play(); animOut.Completed:Wait()
	frame:Destroy(); isNotifying = false; task.wait(); processNotificationQueue()
end

function library:Notify(info)
	if not notificationGui then notificationGui = utility:Create({Type = "ScreenGui", Properties = {Parent = cre, DisplayOrder = 9999, Name = "Obelus_Notifications", ZIndexBehavior = "Global", ResetOnSpawn = false}}) end
	table.insert(notificationQueue, info)
	task.spawn(processNotificationQueue)
end

return library
