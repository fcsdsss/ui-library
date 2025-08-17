-- // Library Tables
local library = {}
local utility = {}
local obelus = {connections = {}}

-- // Services
local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local cre = game:GetService("CoreGui")

-- // Indexing
library.__index = library

-- // Notifications
local notificationQueue = {}
local isNotifying = false
local notificationGui

-- // Utility
do
	function utility:Create(info)
		info = info or {}
		local inst = Instance.new(info.Type)
		if info.Properties then
			for k,v in pairs(info.Properties) do
				inst[k] = v
			end
		end
		return inst
	end
	function utility:Connection(info)
		local conn = info.Type:Connect(info.Callback)
		table.insert(obelus.connections, conn)
		return conn
	end
	function utility:RemoveConnection(info)
		for i,v in ipairs(obelus.connections) do
			if v == info.Connection then
				v:Disconnect()
				table.remove(obelus.connections,i)
				break
			end
		end
	end
end

-- // Window
do
	function library:Window(windowInfo)
		local info = windowInfo or {}
		local window = {
			Pages = {},
			Dragging = false,
			Delta = UDim2.new(),
			Delta2 = Vector3.new(),
			activeDropdown = nil
		}

		local screen = utility:Create{Type="ScreenGui", Properties={
			Parent=cre, Name="obleus", DisplayOrder=8888, ResetOnSpawn=false,
			IgnoreGuiInset=true, ZIndexBehavior="Global"}}

		local main = utility:Create{Type="Frame", Properties={
			Parent=screen, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.new(.5,0,.5,0),
			Size=UDim2.new(0,516,0,390), BackgroundColor3=Color3.fromRGB(50,50,50),
			BorderMode="Inset", ClipsDescendants=true, Visible=false}}

		-- Toggle btn
		local toggleButton = utility:Create{Type="TextButton", Properties={
			Parent=screen, Size=UDim2.new(0,80,0,30), Position=UDim2.new(0,10,0,10),
			BackgroundColor3=Color3.fromRGB(30,30,30), BorderColor3=Color3.fromRGB(170,85,235),
			Text="Toggle UI", TextColor3=Color3.new(1,1,1), Font="Code", TextSize=14, ZIndex=9999}}
		local open=false
		local animating=false
		toggleButton.Activated:Connect(function()
			if animating then return end
			animating=true
			open=not open
			main.Visible=true
			local goal={Size=open and UDim2.new(0,516,0,390) or UDim2.new(0,516,0,0)}
			local tween=ts:Create(main,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),goal)
			tween.Completed:Connect(function()
				if not open then main.Visible=false end
				animating=false
			end)
			tween:Play()
		end)

		-- Movable
		local titleBar = utility:Create{Type="TextButton", Properties={
			Parent=main, Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0,0), Text="", BackgroundTransparency=1}}
		utility:Connection{Type=titleBar.InputBegan, Callback=function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				window.Dragging=true
				window.Delta=main.Position
				window.Delta2=input.Position
			end
		end}
		utility:Connection{Type=uis.InputChanged, Callback=function(input)
			if window.Dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
				local delta=input.Position-window.Delta2
				main.Position=UDim2.new(window.Delta.X.Scale, window.Delta.X.Offset+delta.X, window.Delta.Y.Scale, window.Delta.Y.Offset+delta.Y)
			end
		end}
		utility:Connection{Type=uis.InputEnded, Callback=function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				window.Dragging=false
			end
		end}

		-- Tabs
		local tabs = utility:Create{Type="Frame", Properties={
			Parent=main, Position=UDim2.new(0,0,0,20), Size=UDim2.new(1,0,0,30), BackgroundColor3=Color3.fromRGB(40,40,40)}}
		local pagesFolder = utility:Create{Type="Folder", Properties={Parent=main}}

		function window:RefreshTabs()
			for i,p in ipairs(window.Pages) do
				p.Tab.Size=UDim2.new(1/#window.Pages,0,1,0)
			end
		end

		function window:Page(pageInfo)
			local page={}
			-- Tab
			local tab=utility:Create{Type="TextButton", Properties={
				Parent=tabs, Text=pageInfo.Name or "Tab", BackgroundColor3=Color3.fromRGB(60,60,60),
				Size=UDim2.new(0,100,1,0)}}
			-- Content
			local frame=utility:Create{Type="Frame", Properties={
				Parent=pagesFolder, Size=UDim2.new(1,-10,1,-60), Position=UDim2.new(0,5,0,50),
				Visible=false, BackgroundTransparency=0, BackgroundColor3=Color3.fromRGB(20,20,20)}}
			page.Content=frame; page.Tab=tab

			function page:Turn(state)
				frame.Visible=state
			end
			tab.Activated:Connect(function()
				for _,p in ipairs(window.Pages) do
					p:Turn(false)
				end
				page:Turn(true)
			end)

			function page:Section(secInfo)
				local section={}
				local holder=utility:Create{Type="Frame", Properties={
					Parent=frame, Size=UDim2.new(0.5,-5,1,0), BackgroundTransparency=1,
					Position=(secInfo.Side=="Right") and UDim2.new(0.5,5,0,0) or UDim2.new(0,0,0,0)}}
				local scroll=utility:Create{Type="ScrollingFrame", Properties={
					Parent=holder, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
					AutomaticCanvasSize="Y", CanvasSize=UDim2.new(), BorderSizePixel=0, ScrollBarThickness=4}}
				utility:Create{Type="UIListLayout", Properties={Parent=scroll, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,4)}}

				function section:Label(labelInfo)
					local lbl=utility:Create{Type="TextLabel", Properties={
						Parent=scroll, Text=labelInfo.Text or "Label", Size=UDim2.new(1,0,0,20),
						BackgroundTransparency=1, TextColor3=Color3.fromRGB(200,200,200)}}
					return {Remove=function()lbl:Destroy()end}
				end

				function section:Button(btnInfo)
					local holder=utility:Create{Type="TextButton", Properties={
						Parent=scroll, Text="", Size=UDim2.new(1,0,0,30), BackgroundTransparency=1}}
					local bframe=utility:Create{Type="Frame", Properties={
						Parent=holder, Size=UDim2.new(1,-10,1,0), Position=UDim2.new(0,5,0,0),
						BackgroundColor3=Color3.fromRGB(45,45,45)}}
					utility:Create{Type="TextLabel", Properties={
						Parent=bframe, Text=btnInfo.Text or "Button", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
						TextColor3=Color3.fromRGB(200,200,200)}}
					holder.Activated:Connect(function()btnInfo.Callback()end)
				end

				function section:Toggle(tInfo)
					local state=tInfo.Default or false
					local holder=utility:Create{Type="TextButton", Properties={
						Parent=scroll, Text="", Size=UDim2.new(1,0,0,20), BackgroundTransparency=1}}
					local box=utility:Create{Type="Frame", Properties={
						Parent=holder, BackgroundColor3=state and Color3.fromRGB(170,85,235) or Color3.fromRGB(80,80,80),
						Size=UDim2.new(0,16,0,16), Position=UDim2.new(0,0,0,.5), AnchorPoint=Vector2.new(0,.5)}}
					utility:Create{Type="TextLabel", Properties={
						Parent=holder, Text=tInfo.Text or "Toggle", Position=UDim2.new(0,20,0,0),
						Size=UDim2.new(1,-20,1,0), BackgroundTransparency=1, TextColor3=Color3.fromRGB(200,200,200)}}
					holder.Activated:Connect(function()
						state=not state
						box.BackgroundColor3= state and Color3.fromRGB(170,85,235) or Color3.fromRGB(80,80,80)
						tInfo.Callback(state)
					end)
				end

				function section:Dropdown(dInfo)
					local options=dInfo.Options or {}
					local cur=dInfo.Default or options[1]
					local holder=utility:Create{Type="Frame", Properties={
						Parent=scroll, Size=UDim2.new(1,0,0,30), BackgroundTransparency=1}}
					local mainBtn=utility:Create{Type="TextButton", Properties={
						Parent=holder, Size=UDim2.new(1,0,0,30), Text="", BackgroundColor3=Color3.fromRGB(45,45,45)}}
					local lbl=utility:Create{Type="TextLabel", Properties={
						Parent=mainBtn, Size=UDim2.new(1,0,1,0), Text=cur, BackgroundTransparency=1,
						TextColor3=Color3.fromRGB(200,200,200)}}
					local list=utility:Create{Type="Frame", Properties={
						Parent=holder, Position=UDim2.new(0,0,0,30), Size=UDim2.new(1,0,0,0), ClipsDescendants=true,
						BackgroundColor3=Color3.fromRGB(35,35,35)}}
					utility:Create{Type="UIListLayout", Properties={Parent=list, SortOrder=Enum.SortOrder.LayoutOrder}}

					local function toggle(state)
						ts:Create(list,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Size=state and UDim2.new(1,0,0,#options*20) or UDim2.new(1,0,0,0)}):Play()
					end
					mainBtn.Activated:Connect(function()toggle(list.Size.Y.Offset==0)end)
					for _,opt in ipairs(options) do
						local btn=utility:Create{Type="TextButton", Properties={Parent=list, Size=UDim2.new(1,0,0,20), Text=opt, BackgroundColor3=Color3.fromRGB(50,50,50)}}
						btn.Activated:Connect(function()
							cur=opt
							lbl.Text=opt
							toggle(false)
							dInfo.Callback(opt)
						end)
					end
				end
				return section
			end

			table.insert(window.Pages,page)
			window:RefreshTabs()
			return page
		end

		return window
	end
end

-- // Notifications
function library:Notify(info)
	if not notificationGui then
		notificationGui=utility:Create{Type="ScreenGui", Properties={
			Parent=cre, Name="Obelus_Notifications", DisplayOrder=9999, ResetOnSpawn=false, ZIndexBehavior="Global"}}
	end
	table.insert(notificationQueue,info)
	coroutine.wrap(function()
		if isNotifying then return end
		isNotifying=true
		while #notificationQueue>0 do
			local cur=table.remove(notificationQueue,1)
			local duration=cur.Duration or 5
			local frm=utility:Create{Type="Frame", Properties={
				Parent=notificationGui, Size=UDim2.new(0,300,0,40), AnchorPoint=Vector2.new(.5,0),
				Position=UDim2.new(.5,0,0,-50), BackgroundColor3=Color3.fromRGB(30,30,30)}}
			local bar=utility:Create{Type="Frame", Properties={
				Parent=frm, Size=UDim2.new(1,0,0,4), Position=UDim2.new(0,0,1,-4),
				BackgroundColor3= cur.Color or Color3.fromRGB(170,85,235)}}
			utility:Create{Type="TextLabel", Properties={
				Parent=frm, Size=UDim2.new(1,-10,1,-4), Position=UDim2.new(0,5,0,2),
				Text=(cur.Title or "Notice")..": "..(cur.Text or ""), BackgroundTransparency=1, TextColor3=Color3.new(1,1,1)}}

			ts:Create(frm,TweenInfo.new(0.4,Enum.EasingStyle.Quint),{Position=UDim2.new(.5,0,0,10)}):Play()
			for i=duration,0,-0.05 do
				bar.Size=UDim2.new(i/duration,0,0,4)
				wait(0.05)
			end
			local ot=ts:Create(frm,TweenInfo.new(0.4,Enum.EasingStyle.Quint),{Position=UDim2.new(.5,0,0,-50)})
			ot:Play();ot.Completed:Wait()
			frm:Destroy()
		end
		isNotifying=false
	end)()
end

return library
