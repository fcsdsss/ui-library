--[[
    GET/REQUEST UPDATES HERE: https://discord.gg/rc3TDqKmjN
    Creator: linenhs (discord.com)

    [ * Links:
         Documentation: https://reallinen.gitbook.io/3d-ui-linui-documentation/
         V3rmillion Thread: https://v3rm.net/threads/linui-3d-roblox-ui-library.6666/
    ]

    This automatically deletes connections on re-execution, basically reducing lag [ You shouldn't lag with this UI Library ]
    PLS Credit me If ur going to use OR Fork or Do anything rlly, this was kinda hard to make and took over 3 days

    * The Y, Z, R AND G Parameters save on re-execute. To change or remove them, open exploit workspace fodler -> LinenModule -> (GAME_PLACE_ID).txt
    * UI Config saves per game, not globally
]]

-- 2000+ Lines, crazy isn't it?
-- Version: 2.1.1 (UI Polish)
STRING = "Fixes:"
--[[
	* Fixed UI click-related bugs
	* Fixed/Added breathing
	* Fixed Toggles inverting wrong callback
	* Made more hard to detect
	* Fixed Colorpicker overriding screen
    * Fixed top-right buttons not hiding with main panel
    * Fixed Color Picker on mobile
    * Fixed screen blur issue in certain games by deferring parent assignment
]]

STRING = "Updates:"
--[[
    * Adjusted the minimized bar's drag handle to 3/10 of its width.
    * Implemented an optimized minimized state: a draggable, semi-transparent bar.
    * Restored the Minimize (yellow) button to trigger the new minimized state.
    * The global toggle key now intelligently switches between open and minimized states.
    * Added Core Tab functionality; content now displays in the main center panel.
    * Enlarged the Exit (red) and Fullscreen buttons for better usability.
	* Added Colorpicker
    * Patched for mobile experience (Slider, UI hiding, and smooth tilting)
    * Replaced resizer handle with a corner triangle
]]

local __original_require = require
local function require(link)

    if type(link)=="number" then return __original_require(link) end
    if type(link)~="string" then return nil; end
    local suc,err = pcall(function() return game:HttpGet(link) end)
    -- >.< Deku Demz Is Gay  --
    if suc then return err; end
    return nil

end

pcall(loadstring(require("https://api.irisapp.ca/Scripts/IrisInstanceProtect.lua"))) -- Basically try to make it undetectable

local LinenModule: { print: "function( ... )", Loop: "function( func, seconds, yeild, ... )" } = loadstring(require("https://reallinen.github.io/Files/Scripts/LinenModule.lua"))()
local Storage: { Data: {}, Load: "function( folder_name: string )" }, Http: { GET: "function( link: string )" }, Cache: { add: "function( name: string, object: anything/dynamic )", del: "function( name: string )" } = LinenModule["Storage"], LinenModule["Http"], LinenModule["Cache"]
   
for i,v in next, LinenModule do
    if i=="print" then continue; end
    getgenv()[i] = v
end

LinenModule:Load()
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local TS, UIS = game:GetService("TweenService"), game:GetService("UserInputService")
local Player = game:GetService("Players").LocalPlayer

local Character: Model, Head: Part, HumanoidRootPart: Part, Humanoid: Humanoid, Torso: Part, PlayerGui: PlayerGui = Player.Character or Player.CharacterAdded:Wait(), nil, nil, nil, nil, Player:FindFirstChild("PlayerGui");
local pm_mouse = Player:GetMouse()

Loop(function() 
    Character = Player.Character or nil
    if typeof(Character)~="Instance" then return; end;     
    Head, HumanoidRootPart, Humanoid, Torso, PlayerGui = Character:FindFirstChild("Head"), Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid"), (Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("LowerTorso")), Player:FindFirstChild("PlayerGui"); 
end)

Storage.Load()
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Modules
local Path, Mouse = {}, {}

Path.Index = function(inst, ...: string)
	if typeof(inst)~="Instance" then return false, "First Argument must be an Instance"; end
	local base = inst

	for i,v in next, {...} do
		if type(v)~="nil" then
			local indexedSuccessfully, result = pcall(function()
				return base[v]
			end)

			if indexedSuccessfully and type(result)~="nil" then
				base = result
			else
				base = nil
				break;
			end
		end
	end

	return base
end
Path.findPath = function(str: string)
	if type(str)~="string" then return"First argument must be a string" end

	local gameInstances = {
		["game"] = game,
		["Workspace"] = workspace,
		["Players"] = game:GetService("Players"),
		["Lighting"] = game:GetService("Lighting"),
		["NetworkClient"] = game:GetService("NetworkClient"),
		["ReplicatedFirst"] = game:GetService("ReplicatedFirst"),
		["ReplicatedStorage"] = game:GetService("ReplicatedStorage"),
		["StarterGui"] = game:GetService("StarterGui"),
		["StarterPack"] = game:GetService("StarterPack"),
		["Teams"] = game:GetService("Teams"),
		["SoundService"] = game:GetService("SoundService"),
	}	

	for i,v in next, gameInstances do local storedName, storedValue = i, v;gameInstances[i] = nil;gameInstances[storedName:lower()] = storedValue end
	local parsed = string.split(str, ".")
	local base = game;

	for i,v in next, parsed do
		if not base then break; end
		if type(v)=="string" then

			if gameInstances[v:lower()] then
				base = gameInstances[v:lower()]
				continue;
			end
			-- ~~~~~~~~~~~~~~~~~~~~		
			local foundObj = Path.Index(base, v)			
			if not foundObj then
				return nil
			else
				base = foundObj
			end	
		end
	end

	return base
end

function Mouse:MouseBetweenPoints(pointA,pointB)
	local mouseVector = Vector2.new(pm_mouse.X, pm_mouse.Y)
	local pointAVector = Vector2.new(pointA.X.Offset,pointA.Y.Offset)
	local pointBVector = Vector2.new(pointB.X.Offset,pointB.Y.Offset)
	return ((mouseVector.X > pointAVector.X and mouseVector.Y > pointAVector.Y) and (mouseVector.X < pointBVector.X and mouseVector.Y < pointBVector.Y))
end

function Mouse:MouseInFrame(frame)
	local pointAVector = frame.AbsolutePosition
	local pointBVector = frame.AbsolutePosition + frame.AbsoluteSize
	return Mouse:MouseBetweenPoints(UDim2.fromOffset(pointAVector.X,pointAVector.Y),UDim2.fromOffset(pointBVector.X,pointBVector.Y))
end

Mouse["Mouse"] = pm_mouse
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Part: Creator
local generatedName = "LU_"..HttpService:GenerateGUID()
getgenv()["Linui"] = getgenv()["Linui"] or "_"..math.random(1, 9)..math.random(1, 9)..math.random(1, 9)..math.random(1, 9)..math.random(1, 9)..math.random(1, 9)..math.random(1, 9)..math.random(1, 9)..math.random(1, 9)

local Part = Instance.new("Part")
Part.Name = generatedName
Part.Anchored = true
Part.CanCollide = false
Part.Locked = true
Part.Transparency = 1
Part.Size = Vector3.new(22.517, 11.59, 2)

if type(ProtectInstance)=="function" then -- If ur exploit doesn't support and you get detected, oh well, read documentation to see what ur exploit has to support to avoid most detections
    ProtectInstance(Part) -- Thanks Iris <3
end

Part.Parent = workspace

local Objects = Instance.new("Folder")
local Examples = Instance.new("Folder")

Objects.Name = "Objects"
Objects.Parent = Part

Examples.Name = "Examples"
Examples.Parent = Part

Cache.add(Objects)
Cache.add(Part)

local UI, Frame, OpenButton, MinimizedBar = nil, nil, nil, nil;
local Config = { ["Keys"] = {}, ["Cooldowns"] = {}, ["UI"] = {}, Breathing = true, ToggleKey = Enum.KeyCode.RightShift, ActiveTab = nil }
local Library = { }

local function HandleEvent(BindableEvent, callback)
	return BindableEvent and type(callback)=="function" and (function() local event = BindableEvent:Connect(callback); Cache.add(event); return event end)() or (function() Cache.add(BindableEvent);return BindableEvent end)()
end
local function WrapFunction(callback, ...)
	return typeof(callback)=="function" and coroutine.wrap(callback)(...) or false
end

local handleChildSize; handleChildSize = function(child: Instance, Frame, ...) -- Written by the one and only Linen#3485 | Basically makes sure the ScrollingFrame is auto-scaled to the size of the elements inside

	local arg = {...}
	local WhitelistedNames = {
		["ImageButton"] = true,
		["ImageLabel"] = true,
		["Button"] = true,
		["TextLabel"] = true,
		["Frame"] = true,
		["ScrollingFrame"] = true
	}

	if WhitelistedNames[child.ClassName] then
		child:GetPropertyChangedSignal("Size"):Connect(function()
			if typeof(Frame)=="Instance" and Frame:IsA("ScrollingFrame") then
				Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			end
		end)
	end

	local Cached = {}
	HandleEvent(child.ChildAdded:Connect(function(_child)
		Cached[_child] = _child
		handleChildSize(_child, Frame, unpack(arg))
	end))

	for a, b in next, child:GetDescendants() do
		if not Cached[b] then
			Cached[b] = b
			handleChildSize(b, Frame, unpack(arg))
		end
	end
end

do -- Main UI
	UI = Instance.new("SurfaceGui")

	UI["ResetOnSpawn"] = false
	UI["Face"] = Enum.NormalId.Back
	UI["SizingMode"] = Enum.SurfaceGuiSizingMode.PixelsPerStud
	UI["ClipsDescendants"] = true
	UI["Adornee"] = Part
	UI["Name"] = "UI"
	UI["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling
	UI["AlwaysOnTop"] = true
    
    -- [[ FIX: Screen Blur ]]
    -- Defer parenting to avoid affecting game's core UI on startup
    task.spawn(function()
        pcall(function() UI.Parent = Part end)
    end)
    -- [[ END FIX ]]

    Frame = Instance.new("ImageButton")
	Frame["BorderSizePixel"] = 0
	Frame["Name"] = "Frame"
	Frame["BackgroundColor3"] = Color3.fromRGB(30, 30, 30)
	Frame["Image"] = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	Frame["Size"] = UDim2.new(1, 0, 1, 0) -- Full size container
	Frame["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Frame["ImageTransparency"] = 1
	Frame["Position"] = UDim2.new(0, 0, 0, 0)
	Frame["BackgroundTransparency"] = 1
	Frame["Parent"] = UI
	
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint["AspectRatio"] = 1.75
	UIAspectRatioConstraint["Parent"] = Frame
	
	local UICorner = Instance.new("UICorner")
	UICorner["CornerRadius"] = UDim.new(0, 8) -- Rounded corners
	UICorner["Parent"] = Frame
	
    -- Main container for all UI elements, allowing for easy hiding/showing
    local MainContainer = Instance.new("Frame")
    MainContainer.Name = "MainContainer"
    MainContainer.Size = UDim2.new(1,0,1,0)
    MainContainer.BackgroundTransparency = 1
    MainContainer.Parent = Frame
    
	local MainPanel = Instance.new("ImageLabel")
	MainPanel["BorderSizePixel"] = 0
	MainPanel["ScaleType"] = Enum.ScaleType.Slice
    MainPanel["SliceCenter"] = Rect.new(10, 10, 118, 118)
	MainPanel["BackgroundColor3"] = Color3.fromRGB(16, 16, 16)
	MainPanel["Name"] = "MainPanel"
	MainPanel["Image"] = "rbxassetid://14228549334"
	MainPanel["Size"] = UDim2.new(1, -10, 1, -10) -- Padding
	MainPanel["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	MainPanel["BackgroundTransparency"] = 0.2
	MainPanel["Position"] = UDim2.new(0.5, 0, 0.5, 0)
    MainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	MainPanel["Parent"] = MainContainer

    local MainPanelCorner = Instance.new("UICorner")
    MainPanelCorner.CornerRadius = UDim.new(0, 6)
    MainPanelCorner.Parent = MainPanel

	local LeftPanel = Instance.new("Frame")
	LeftPanel["BorderSizePixel"] = 0
	LeftPanel["BackgroundColor3"] = Color3.fromRGB(10, 10, 10)
	LeftPanel["Name"] = "LeftPanel"
	LeftPanel["Size"] = UDim2.new(0.25, 0, 1, -45)
	LeftPanel["BackgroundTransparency"] = 0.4
	LeftPanel["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	LeftPanel["Position"] = UDim2.new(0, 5, 1, -5)
    LeftPanel.AnchorPoint = Vector2.new(0, 1)
	LeftPanel["Parent"] = MainPanel
    
    local LeftPanelCorner = Instance.new("UICorner")
    LeftPanelCorner.CornerRadius = UDim.new(0, 4)
    LeftPanelCorner.Parent = LeftPanel

	local TabsContainer = Instance.new("ScrollingFrame")
	TabsContainer["Active"] = true
	TabsContainer["BorderSizePixel"] = 0
	TabsContainer["Name"] = "TabsContainer"
	TabsContainer["Size"] = UDim2.new(1, -10, 1, -10)
	TabsContainer["ScrollBarImageColor3"] = Color3.fromRGB(255, 255, 255)
	TabsContainer["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	TabsContainer["ScrollBarThickness"] = 4
	TabsContainer["BackgroundTransparency"] = 1
	TabsContainer["Position"] = UDim2.new(0.5, 0, 0.5, 0)
    TabsContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	TabsContainer["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	TabsContainer["Parent"] = LeftPanel
	
	local UIListLayout_Tabs = Instance.new("UIListLayout")
	UIListLayout_Tabs["HorizontalAlignment"] = Enum.HorizontalAlignment.Center
	UIListLayout_Tabs["Padding"] = UDim.new(0, 5)
	UIListLayout_Tabs["SortOrder"] = Enum.SortOrder.LayoutOrder
	UIListLayout_Tabs["Parent"] = TabsContainer
	
	local ContentPanel = Instance.new("Frame")
	ContentPanel["BorderSizePixel"] = 0
	ContentPanel["BackgroundColor3"] = Color3.fromRGB(10, 10, 10)
	ContentPanel["Name"] = "ContentPanel"
	ContentPanel["Size"] = UDim2.new(0.75, -15, 1, -45)
	ContentPanel["BackgroundTransparency"] = 0.4
	ContentPanel["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	ContentPanel["Position"] = UDim2.new(1, -5, 1, -5)
    ContentPanel.AnchorPoint = Vector2.new(1, 1)
	ContentPanel["Parent"] = MainPanel

    local ContentPanelCorner = Instance.new("UICorner")
    ContentPanelCorner.CornerRadius = UDim.new(0, 4)
    ContentPanelCorner.Parent = ContentPanel

    -- Header (Top Bar)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.Position = UDim2.new(0,0,0,0)
    Header.BackgroundTransparency = 1
    Header.Parent = MainPanel

	local PlayerName = Instance.new("TextLabel")
	PlayerName["TextWrapped"] = true
	PlayerName["BorderSizePixel"] = 0
	PlayerName["RichText"] = true
	PlayerName["Name"] = "PlayerName"
	PlayerName["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	PlayerName["FontFace"] = Font.new("rbxassetid://12187370000", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	PlayerName["Size"] = UDim2.new(0.3, 0, 0.8, 0)
	PlayerName["Position"] = UDim2.new(0.02, 0, 0.5, 0)
    PlayerName.AnchorPoint = Vector2.new(0, 0.5)
	PlayerName["TextColor3"] = Color3.fromRGB(255, 255, 255)
	PlayerName["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	PlayerName["Text"] = "Linui"
	PlayerName["BackgroundTransparency"] = 1
	PlayerName["TextSize"] = 22
    PlayerName.TextXAlignment = Enum.TextXAlignment.Left
	PlayerName["Parent"] = Header
	
    -- Container for top-right buttons
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Name = "ButtonContainer"
    ButtonContainer.Size = UDim2.new(0, 100, 1, 0)
    ButtonContainer.Position = UDim2.new(1, -5, 0.5, 0)
    ButtonContainer.AnchorPoint = Vector2.new(1, 0.5)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Parent = Header

    local ButtonLayout = Instance.new("UIListLayout")
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ButtonLayout.Padding = UDim.new(0, 8)
    ButtonLayout.Parent = ButtonContainer

    -- [[ FEATURE: Fullscreen Button ]]
    local FULLSCREEN = Instance.new("ImageButton")
    FULLSCREEN.Name = "FULLSCREEN"
    FULLSCREEN.LayoutOrder = 1
    FULLSCREEN.BackgroundTransparency = 1
    FULLSCREEN.Size = UDim2.new(0, 18, 0, 18) -- Enlarged
    FULLSCREEN.Image = "http://www.roblox.com/asset/?id=284412499" -- Expand icon
    FULLSCREEN.ImageColor3 = Color3.fromRGB(220, 220, 220)
    FULLSCREEN.Parent = ButtonContainer
	
	local MINIMIZE = Instance.new("TextButton")
	MINIMIZE["BorderSizePixel"] = 0
    MINIMIZE.LayoutOrder = 2
	MINIMIZE["Name"] = "MINIMIZE"
	MINIMIZE["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	MINIMIZE["Size"] = UDim2.new(0, 18, 0, 18) -- Enlarged
	MINIMIZE["TextColor3"] = Color3.fromRGB(0, 0, 0)
	MINIMIZE["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	MINIMIZE["Text"] = ""
	MINIMIZE["Parent"] = ButtonContainer
	
	local UICorner_3 = Instance.new("UICorner")
	UICorner_3["CornerRadius"] = UDim.new(1, 0)
	UICorner_3["Parent"] = MINIMIZE
	
	local UIGradient = Instance.new("UIGradient")
	UIGradient["Color"] = ColorSequence.new({  ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)) , ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 190, 0)) })
	UIGradient["Parent"] = MINIMIZE
	
	local EXIT = Instance.new("TextButton")
	EXIT["BorderSizePixel"] = 0
    EXIT.LayoutOrder = 3
	EXIT["Name"] = "EXIT"
	EXIT["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	EXIT["Size"] = UDim2.new(0, 18, 0, 18) -- Enlarged
	EXIT["TextColor3"] = Color3.fromRGB(0, 0, 0)
	EXIT["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	EXIT["Text"] = ""
	EXIT["Parent"] = ButtonContainer
	
	local UICorner_4 = Instance.new("UICorner")
	UICorner_4["CornerRadius"] = UDim.new(1, 0)
	UICorner_4["Parent"] = EXIT
	
	local UIGradient_1 = Instance.new("UIGradient")
	UIGradient_1["Color"] = ColorSequence.new({  ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 100)) , ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 40, 40)) })
	UIGradient_1["Parent"] = EXIT
	
    -- [[ FEATURE: Resizer Handle (Triangle) ]]
    local ResizeHandle = Instance.new("ImageLabel")
    ResizeHandle.Name = "ResizeHandle"
    ResizeHandle.Image = "rbxassetid://5406592965" -- Triangle image
    ResizeHandle.ImageColor3 = Color3.fromRGB(100, 100, 100)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Rotation = 45
    ResizeHandle.AnchorPoint = Vector2.new(1, 1)
    ResizeHandle.Position = UDim2.new(1, 0, 1, 0) -- Stick to corner
    ResizeHandle.Size = UDim2.new(0, 22, 0, 22)
    ResizeHandle.ZIndex = 10
    ResizeHandle.Parent = Frame
    
	-- [[ FEATURE: Optimized Minimized Bar ]]
    local ScreenGui = Instance.new("ScreenGui", PlayerGui)
    Cache.add(ScreenGui)
    MinimizedBar = Instance.new("Frame", ScreenGui)
    MinimizedBar.Size = UDim2.new(0, 200, 0, 35)
    MinimizedBar.Position = UDim2.new(0.5, -100, 0, 15)
    MinimizedBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MinimizedBar.BackgroundTransparency = 0.2
    MinimizedBar.Visible = false
    MinimizedBar.ZIndex = 9999
    MinimizedBar.ClipsDescendants = true

    local mbCorner = Instance.new("UICorner", MinimizedBar)
    mbCorner.CornerRadius = UDim.new(0, 6)
    local mbStroke = Instance.new("UIStroke", MinimizedBar)
    mbStroke.Color = Color3.fromRGB(80, 80, 80)
    mbStroke.Thickness = 1.5

    -- Draggable Handle (Left 3/10)
    local DragHandle = Instance.new("Frame", MinimizedBar)
    DragHandle.Size = UDim2.new(0.3, 0, 1, 0)
    DragHandle.BackgroundTransparency = 1
    DragHandle.Active = true
    DragHandle.Draggable = true

    -- Expand Button (Right 7/10)
    local ExpandButton = Instance.new("TextButton", MinimizedBar)
    ExpandButton.Size = UDim2.new(0.7, 0, 1, 0)
    ExpandButton.Position = UDim2.new(0.3, 0, 0, 0)
    ExpandButton.BackgroundTransparency = 1
    ExpandButton.Text = "Expand"
    ExpandButton.Font = Enum.Font.GothamSemibold
    ExpandButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    ExpandButton.TextSize = 16

    local expandIcon = Instance.new("ImageLabel", ExpandButton)
    expandIcon.Size = UDim2.new(0, 16, 0, 16)
    expandIcon.Position = UDim2.new(1, -25, 0.5, 0)
    expandIcon.AnchorPoint = Vector2.new(1, 0.5)
    expandIcon.BackgroundTransparency = 1
    expandIcon.Image = "http://www.roblox.com/asset/?id=1435223490" -- Up Arrow
    expandIcon.ImageColor3 = Color3.fromRGB(220, 220, 220)
    ExpandButton.Parent = MinimizedBar
end

do -- UI Elements

	local UI_Examples = Examples
	local Keybind = Instance.new("Frame")
	Keybind["BorderSizePixel"] = 0
	Keybind["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
	Keybind["Name"] = "Keybind"
	Keybind["Size"] = UDim2.new(0, 272, 0, 41)
	Keybind["BackgroundTransparency"] = 1
	Keybind["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Keybind["Position"] = UDim2.new(0.08406495302915573, 0, 4.501474037965636e-08, 0)
	Keybind["Parent"] = UI_Examples
	
	local ViewKeybind = Instance.new("ImageButton")
	ViewKeybind["BorderSizePixel"] = 0
	ViewKeybind["Name"] = "ViewKeybind"
	ViewKeybind["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	ViewKeybind["Image"] = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	ViewKeybind["Size"] = UDim2.new(0.31966525316238403, 0, 0.5718939900398254, 0)
	ViewKeybind["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	ViewKeybind["ImageTransparency"] = 1
	ViewKeybind["Position"] = UDim2.new(0.5060985684394836, 0, 0.21320509910583496, 0)
	ViewKeybind["Parent"] = Keybind
	
	local Label = Instance.new("TextLabel")
	Label["TextWrapped"] = true
	Label["BorderSizePixel"] = 0
	Label["Name"] = "Label"
	Label["TextScaled"] = true
	Label["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Label["FontFace"] = Font.new("rbxassetid://12187360881", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	Label["Size"] = UDim2.new(1.74003267288208, 0, 1.2190746068954468, 0)
	Label["Position"] = UDim2.new(-1.829146385192871, 0, -0.13377799093723297, 0)
	Label["LayoutOrder"] = 100
	Label["TextColor3"] = Color3.fromRGB(255, 255, 255)
	Label["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Label["Text"] = "Example Keybind"
	Label["BackgroundTransparency"] = 1
	Label["TextXAlignment"] = Enum.TextXAlignment.Right
	Label["TextSize"] = 11
	Label["Parent"] = ViewKeybind
	
	local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint["MaxTextSize"] = 17
	UITextSizeConstraint["Parent"] = Label
	
	local UIGradient = Instance.new("UIGradient")
	UIGradient["Color"] = ColorSequence.new({  ColorSequenceKeypoint.new(0, Color3.fromRGB(20.000000707805157, 20.000000707805157, 20.000000707805157)) , ColorSequenceKeypoint.new(1, Color3.fromRGB(10.000000353902578, 10.000000353902578, 10.000000353902578)) })
	UIGradient["Parent"] = ViewKeybind
	
	local UICorner = Instance.new("UICorner")
	UICorner["CornerRadius"] = UDim.new(0, 4)
	UICorner["Parent"] = ViewKeybind
	
	local Button = Instance.new("TextButton")
	Button["TextWrapped"] = true
	Button["BorderSizePixel"] = 0
	Button["RichText"] = true
	Button["Name"] = "Button"
	Button["TextSize"] = 15
	Button["TextScaled"] = true
	Button["BackgroundColor3"] = Color3.fromRGB(107.00000122189522, 107.00000122189522, 107.00000122189522)
	Button["FontFace"] = Font.new("rbxasset://fonts/families/Jura.json", Enum.FontWeight.Regular, Enum.FontStyle.Italic)
	Button["Size"] = UDim2.new(0.9151746034622192, 0, 0.9446877837181091, 0)
	Button["Position"] = UDim2.new(0.03450300544500351, 0, 0.012664435431361198, 0)
	Button["TextColor3"] = Color3.fromRGB(255, 255, 255)
	Button["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Button["Text"] = "..."
	Button["BackgroundTransparency"] = 1
	Button["Parent"] = ViewKeybind
	
	local UITextSizeConstraint_1 = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint_1["MaxTextSize"] = 15
	UITextSizeConstraint_1["Parent"] = Button
	
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint["AspectRatio"] = 3.5923664569854736
	UIAspectRatioConstraint["Parent"] = Button
	
	local UIAspectRatioConstraint_1 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_1["AspectRatio"] = 3.7082154750823975
	UIAspectRatioConstraint_1["Parent"] = ViewKeybind
	
	local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_2["AspectRatio"] = 6.634146213531494
	UIAspectRatioConstraint_2["Parent"] = Keybind
	
	local Label_1 = Instance.new("Frame")
	Label_1["BorderSizePixel"] = 0
	Label_1["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Label_1["Name"] = "Label"
	Label_1["Size"] = UDim2.new(0, 181, 0, 25)
	Label_1["BackgroundTransparency"] = 0.10000000149011612
	Label_1["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Label_1["Position"] = UDim2.new(0.2133532166481018, 0, 0.15854917466640472, 0)
	Label_1["Parent"] = UI_Examples
	
	local UICorner_1 = Instance.new("UICorner")
	UICorner_1["CornerRadius"] = UDim.new(0, 4)
	UICorner_1["Parent"] = Label_1
	
	local UIGradient_1 = Instance.new("UIGradient")
	UIGradient_1["Color"] = ColorSequence.new({  ColorSequenceKeypoint.new(0, Color3.fromRGB(20.000000707805157, 20.000000707805157, 20.000000707805157)) , ColorSequenceKeypoint.new(1, Color3.fromRGB(10.000000353902578, 10.000000353902578, 10.000000353902578)) })
	UIGradient_1["Parent"] = Label_1
	
	local Label_2 = Instance.new("TextLabel")
	Label_2["TextWrapped"] = true
	Label_2["BorderSizePixel"] = 0
	Label_2["RichText"] = true
	Label_2["Name"] = "Label"
	Label_2["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Label_2["FontFace"] = Font.new("rbxassetid://12187360881", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	Label_2["Size"] = UDim2.new(0.9079903364181519, 0, 0.5775953531265259, 0)
	Label_2["Position"] = UDim2.new(0.04080722853541374, 0, 0.1931622326374054, 0)
	Label_2["TextColor3"] = Color3.fromRGB(255, 255, 255)
	Label_2["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Label_2["Text"] = "Example"
	Label_2["BackgroundTransparency"] = 1
	Label_2["TextSize"] = 14
	Label_2["Parent"] = Label_1
	
	local UITextSizeConstraint_2 = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint_2["MaxTextSize"] = 17
	UITextSizeConstraint_2["Parent"] = Label_2
	
	local Slider = Instance.new("Frame")
	Slider["BorderSizePixel"] = 0
	Slider["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Slider["Name"] = "Slider"
	Slider["Size"] = UDim2.new(0, 305, 0, 52)
	Slider["BackgroundTransparency"] = 1
	Slider["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Slider["Position"] = UDim2.new(0.033602237701416016, 0, 0.0649019330739975, 0)
	Slider["Parent"] = UI_Examples
	
	local ViewSlider = Instance.new("ImageButton")
	ViewSlider["BorderSizePixel"] = 0
	ViewSlider["Name"] = "ViewSlider"
	ViewSlider["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	ViewSlider["Image"] = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	ViewSlider["Size"] = UDim2.new(0.5929999947547913, 0, 0.4350000023841858, 0)
	ViewSlider["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	ViewSlider["ImageTransparency"] = 1
	ViewSlider["Position"] = UDim2.new(0.20327869057655334, 0, 0.49191224575042725, 0)
	ViewSlider["Parent"] = Slider
	
	local Label_3 = Instance.new("TextLabel")
	Label_3["TextWrapped"] = true
	Label_3["BorderSizePixel"] = 0
	Label_3["Name"] = "Label"
	Label_3["TextScaled"] = true
	Label_3["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Label_3["FontFace"] = Font.new("rbxassetid://12187360881", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	Label_3["Size"] = UDim2.new(1.0000004768371582, 0, 1.0139235258102417, 0)
	Label_3["Position"] = UDim2.new(-0.005524936132133007, 0, -1.1642091274261475, 0)
	Label_3["LayoutOrder"] = 100
	Label_3["TextColor3"] = Color3.fromRGB(255, 255, 255)
	Label_3["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Label_3["Text"] = "View"
	Label_3["BackgroundTransparency"] = 1
	Label_3["TextSize"] = 17
	Label_3["Parent"] = ViewSlider
	
	local UITextSizeConstraint_3 = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint_3["MaxTextSize"] = 17
	UITextSizeConstraint_3["Parent"] = Label_3
	
	local Button_1 = Instance.new("ImageButton")
	Button_1["BorderSizePixel"] = 0
	Button_1["Name"] = "Button"
	Button_1["BackgroundColor3"] = Color3.fromRGB(107.00000122189522, 107.00000122189522, 107.00000122189522)
	Button_1["Image"] = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	Button_1["Size"] = UDim2.new(0.5703652501106262, 0, 1.0141061544418335, 0)
	Button_1["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Button_1["Position"] = UDim2.new(-6.744216420884186e-07, 0, -0.019752129912376404, 0)
	Button_1["LayoutOrder"] = 1
	Button_1["Parent"] = ViewSlider
	
	local UIGradient_2 = Instance.new("UIGradient")
	UIGradient_2["Color"] = ColorSequence.new({  ColorSequenceKeypoint.new(0, Color3.fromRGB(60.00000022351742, 164.00000542402267, 255)) , ColorSequenceKeypoint.new(1, Color3.fromRGB(35.00000171363354, 105.00000134110451, 255)) })
	UIGradient_2["Parent"] = Button_1
	
	local UICorner_2 = Instance.new("UICorner")
	UICorner_2["CornerRadius"] = UDim.new(0, 4)
	UICorner_2["Parent"] = Button_1
	
	local UIGradient_3 = Instance.new("UIGradient")
	UIGradient_3["Color"] = ColorSequence.new({  ColorSequenceKeypoint.new(0, Color3.fromRGB(20.000000707805157, 20.000000707805157, 20.000000707805157)) , ColorSequenceKeypoint.new(1, Color3.fromRGB(10.000000353902578, 10.000000353902578, 10.000000353902578)) })
	UIGradient_3["Parent"] = ViewSlider
	
	local UICorner_3 = Instance.new("UICorner")
	UICorner_3["CornerRadius"] = UDim.new(0, 4)
	UICorner_3["Parent"] = ViewSlider
	
	local Value = Instance.new("TextLabel")
	Value["TextWrapped"] = true
	Value["BorderSizePixel"] = 0
	Value["Name"] = "Value"
	Value["TextScaled"] = true
	Value["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Value["FontFace"] = Font.new("rbxassetid://12187368843", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	Value["Size"] = UDim2.new(0.42130911350250244, 0, 0.9000000357627869, 0)
	Value["Position"] = UDim2.new(0.28419923782348633, 0, 0, 0)
	Value["LayoutOrder"] = 100
	Value["TextColor3"] = Color3.fromRGB(255, 255, 255)
	Value["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Value["Text"] = "1/100"
	Value["BackgroundTransparency"] = 1
	Value["TextSize"] = 17
	Value["Parent"] = ViewSlider
	
	local UITextSizeConstraint_4 = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint_4["MaxTextSize"] = 16
	UITextSizeConstraint_4["Parent"] = Value
	
	local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_3["AspectRatio"] = 7.995800018310547
	UIAspectRatioConstraint_3["Parent"] = ViewSlider
	
	local UIAspectRatioConstraint_4 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_4["AspectRatio"] = 5.865384578704834
	UIAspectRatioConstraint_4["Parent"] = Slider
	
	local Toggle = Instance.new("Frame")
	Toggle["BorderSizePixel"] = 0
	Toggle["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Toggle["Name"] = "Toggle"
	Toggle["Size"] = UDim2.new(0, 305, 0, 35)
	Toggle["BackgroundTransparency"] = 1
	Toggle["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Toggle["Position"] = UDim2.new(0.033602237701416016, 0, 0.17700520157814026, 0)
	Toggle["Parent"] = UI_Examples
	
	local ViewToggle = Instance.new("ImageButton")
	ViewToggle["BorderSizePixel"] = 0
	ViewToggle["Name"] = "ViewToggle"
	ViewToggle["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	ViewToggle["Image"] = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	ViewToggle["Size"] = UDim2.new(0.16853027045726776, 0, 0.5778570771217346, 0)
	ViewToggle["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	ViewToggle["ImageTransparency"] = 1
	ViewToggle["Position"] = UDim2.new(0.6262291073799133, 0, 0.08806588500738144, 0)
	ViewToggle["Parent"] = Toggle
	
	local Label_4 = Instance.new("TextLabel")
	Label_4["TextWrapped"] = true
	Label_4["BorderSizePixel"] = 0
	Label_4["Name"] = "Label"
	Label_4["TextScaled"] = true
	Label_4["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Label_4["FontFace"] = Font.new("rbxassetid://12187360881", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	Label_4["Size"] = UDim2.new(2.33683705329895, 0, 1.5443432331085205, 0)
	Label_4["Position"] = UDim2.new(-2.529090404510498, 0, -0.27982988953590393, 0)
	Label_4["LayoutOrder"] = 100
	Label_4["TextColor3"] = Color3.fromRGB(255, 255, 255)
	Label_4["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Label_4["Text"] = "Fly"
	Label_4["BackgroundTransparency"] = 1
	Label_4["TextSize"] = 17
	Label_4["Parent"] = ViewToggle
	
	local UITextSizeConstraint_5 = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint_5["MaxTextSize"] = 17
	UITextSizeConstraint_5["Parent"] = Label_4
	
	local Button_2 = Instance.new("ImageButton")
	Button_2["BorderSizePixel"] = 0
	Button_2["Name"] = "Button"
	Button_2["BackgroundColor3"] = Color3.fromRGB(107.00000122189522, 107.00000122189522, 107.00000122189522)
	Button_2["Image"] = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	Button_2["Size"] = UDim2.new(0.4749999940395355, 0, 1.0140000581741333, 0)
	Button_2["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Button_2["ImageTransparency"] = 0.20000000298023224
	Button_2["Position"] = UDim2.new(0.5249999761581421, 0, -0.019999999552965164, 0)
	Button_2["LayoutOrder"] = 1
	Button_2["Parent"] = ViewToggle
	
	local UIGradient_4 = Instance.new("UIGradient")
	UIGradient_4["Color"] = ColorSequence.new({  ColorSequenceKeypoint.new(0, Color3.fromRGB(60.00000022351742, 164.00000542402267, 255)) , ColorSequenceKeypoint.new(1, Color3.fromRGB(35.00000171363354, 105.00000134110451, 255)) })
	UIGradient_4["Parent"] = Button_2
	
	local UICorner_4 = Instance.new("UICorner")
	UICorner_4["CornerRadius"] = UDim.new(0, 4)
	UICorner_4["Parent"] = Button_2
	
	local UIAspectRatioConstraint_5 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_5["AspectRatio"] = 1.190542459487915
	UIAspectRatioConstraint_5["Parent"] = Button_2
	
	local UIGradient_5 = Instance.new("UIGradient")
	UIGradient_5["Color"] = ColorSequence.new({  ColorSequenceKeypoint.new(0, Color3.fromRGB(20.000000707805157, 20.000000707805157, 20.000000707805157)) , ColorSequenceKeypoint.new(1, Color3.fromRGB(10.000000353902578, 10.000000353902578, 10.000000353902578)) })
	UIGradient_5["Parent"] = ViewToggle
	
	local UICorner_5 = Instance.new("UICorner")
	UICorner_5["CornerRadius"] = UDim.new(0, 4)
	UICorner_5["Parent"] = ViewToggle
	
	local UIAspectRatioConstraint_6 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_6["AspectRatio"] = 2.5414950847625732
	UIAspectRatioConstraint_6["Parent"] = ViewToggle
	
	local UIAspectRatioConstraint_7 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_7["AspectRatio"] = 8.714285850524902
	UIAspectRatioConstraint_7["Parent"] = Toggle
	
	local Button_3 = Instance.new("ImageButton")
	Button_3["BorderSizePixel"] = 0
	Button_3["Name"] = "Button"
	Button_3["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Button_3["Image"] = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	Button_3["Size"] = UDim2.new(0, 181, 0, 25)
	Button_3["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Button_3["ImageTransparency"] = 1
	Button_3["BackgroundTransparency"] = 0.10000000149011612
	Button_3["Parent"] = UI_Examples
	
	local Label_5 = Instance.new("TextLabel")
	Label_5["TextWrapped"] = true
	Label_5["BorderSizePixel"] = 0
	Label_5["Name"] = "Label"
	Label_5["TextScaled"] = true
	Label_5["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Label_5["FontFace"] = Font.new("rbxassetid://12187360881", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	Label_5["Size"] = UDim2.new(0.45495179295539856, 0, 0.5775954127311707, 0)
	Label_5["Position"] = UDim2.new(0.2673265039920807, 0, 0.19316236674785614, 0)
	Label_5["TextColor3"] = Color3.fromRGB(255, 255, 255)
	Label_5["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Label_5["Text"] = "Click Me"
	Label_5["BackgroundTransparency"] = 1
	Label_5["TextSize"] = 17
	Label_5["Parent"] = Button_3
	
	local UITextSizeConstraint_6 = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint_6["MaxTextSize"] = 17
	UITextSizeConstraint_6["Parent"] = Label_5
	
	local UIGradient_6 = Instance.new("UIGradient")
	UIGradient_6["Color"] = ColorSequence.new({  ColorSequenceKeypoint.new(0, Color3.fromRGB(20.000000707805157, 20.000000707805157, 20.000000707805157)) , ColorSequenceKeypoint.new(1, Color3.fromRGB(10.000000353902578, 10.000000353902578, 10.000000353902578)) })
	UIGradient_6["Parent"] = Button_3
	
	local UICorner_6 = Instance.new("UICorner")
	UICorner_6["CornerRadius"] = UDim.new(0, 4)
	UICorner_6["Parent"] = Button_3
	
	local UIAspectRatioConstraint_8 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_8["AspectRatio"] = 7.239999771118164
	UIAspectRatioConstraint_8["Parent"] = Button_3
	
	local Section = Instance.new("Frame")
	Section["BorderSizePixel"] = 0
	Section["BackgroundColor3"] = Color3.fromRGB(10.000000353902578, 10.000000353902578, 10.000000353902578)
	Section["Name"] = "Section"
	Section["Size"] = UDim2.new(1.0000001192092896, 0, 0.2596045434474945, 0)
	Section["BackgroundTransparency"] = 0.4000000059604645
	Section["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Section["Position"] = UDim2.new(-4.314098589475179e-08, 0, -1.0403466532693528e-08, 0)
	Section["Parent"] = UI_Examples
	
	local UICorner_7 = Instance.new("UICorner")
	UICorner_7["CornerRadius"] = UDim.new(0, 0)
	UICorner_7["Parent"] = Section
	
	local _Frame = Instance.new("ScrollingFrame")
	_Frame["Active"] = true
	_Frame["BorderSizePixel"] = 0
	_Frame["Name"] = "_Frame"
	_Frame["Size"] = UDim2.new(0.9612776041030884, 0, 0.88478022813797, 0)
	_Frame["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0)
	_Frame["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	_Frame["ScrollBarThickness"] = 1
	_Frame["BackgroundTransparency"] = 1
	_Frame["Position"] = UDim2.new(0.019791053608059883, 0, 0.09656893461942673, 0)
	_Frame["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
	_Frame["Parent"] = Section
	handleChildSize(_Frame, _Frame)

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout["HorizontalAlignment"] = Enum.HorizontalAlignment.Center
	UIListLayout["Padding"] = UDim.new(0, 1)
	UIListLayout["SortOrder"] = Enum.SortOrder.LayoutOrder
	UIListLayout["Parent"] = _Frame
	
	local Label_6 = Instance.new("TextButton")
	Label_6["TextWrapped"] = true
	Label_6["BorderSizePixel"] = 0
	Label_6["Name"] = "Label"
	Label_6["TextSize"] = 15
	Label_6["TextScaled"] = true
	Label_6["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Label_6["FontFace"] = Font.new("rbxassetid://12187360881", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	Label_6["Size"] = UDim2.new(0.8821135759353638, 0, 0.057419367134571075, 0)
	Label_6["Position"] = UDim2.new(0.05654578655958176, 0, 0.013049855828285217, 0)
	Label_6["TextColor3"] = Color3.fromRGB(255, 255, 255)
	Label_6["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Label_6["Text"] = "Home Tab"
	Label_6["BackgroundTransparency"] = 1
	Label_6["Parent"] = Section
	
	local UITextSizeConstraint_7 = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint_7["MaxTextSize"] = 15
	UITextSizeConstraint_7["Parent"] = Label_6
	
	local Line = Instance.new("Frame")
	Line["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
	Line["Name"] = "Line"
	Line["Size"] = UDim2.new(0.29216468334198, 0, 0.0013550135772675276, 0)
	Line["BorderColor3"] = Color3.fromRGB(255, 255, 255)
	Line["Position"] = UDim2.new(0.353349506855011, 0, 0.07307261973619461, 0)
	Line["Parent"] = Section

	local TabExample = Instance.new("TextButton")
    TabExample.Name = "TabExample"
    TabExample.Size = UDim2.new(1, -10, 0, 35)
    TabExample.BackgroundColor3 = Color3.fromRGB(45,45,45)
    TabExample.Text = "Tab"
    TabExample.TextColor3 = Color3.fromRGB(200,200,200)
    TabExample.Font = Enum.Font.GothamSemibold
    TabExample.TextSize = 15
    TabExample.Parent = Examples
    
    local TabCorner = Instance.new("UICorner", TabExample)
    TabCorner.CornerRadius = UDim.new(0, 4)

    local TabStroke = Instance.new("UIStroke", TabExample)
    TabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    TabStroke.Color = Color3.fromRGB(60,60,60)
    TabStroke.Thickness = 1.5
    TabStroke.Transparency = 0
	
	-------------------------------------------

	local ColorPicker = Instance.new("Frame")
	ColorPicker["BorderSizePixel"] = 0
	ColorPicker["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	ColorPicker["Name"] = "ColorPicker"
	ColorPicker["Size"] = UDim2.new(0, 186, 0, 33)
	ColorPicker["BackgroundTransparency"] = 1
	ColorPicker["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	ColorPicker["Position"] = UDim2.new(0.21557384729385376, 0, 0.2920585572719574, 0)
	ColorPicker["Parent"] = Examples
	
	local ViewColor = Instance.new("ImageButton")
	ViewColor["BorderSizePixel"] = 0
	ViewColor["Name"] = "ViewColor"
	ViewColor["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	ViewColor["Image"] = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	ViewColor["Size"] = UDim2.new(0, 181, 0, 102)
	ViewColor["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	ViewColor["ImageTransparency"] = 1
	ViewColor["Position"] = UDim2.new(0, 2, 0, 6)
	ViewColor["BackgroundTransparency"] = 0.10000000149011612
	ViewColor["Parent"] = ColorPicker
	
	local Label = Instance.new("TextLabel")
	Label["TextWrapped"] = true
	Label["BorderSizePixel"] = 0
	Label["Name"] = "Label"
	Label["TextScaled"] = true
	Label["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Label["FontFace"] = Font.new("rbxassetid://12187360881", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	Label["Size"] = UDim2.new(0.7607182264328003, 0, 0.5775953531265259, 0)
	Label["Position"] = UDim2.new(0.04080655425786972, 0, 0.19316284358501434, 0)
	Label["TextColor3"] = Color3.fromRGB(255, 255, 255)
	Label["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Label["Text"] = "Color Picker"
	Label["BackgroundTransparency"] = 1
	Label["TextXAlignment"] = Enum.TextXAlignment.Left
	Label["TextSize"] = 17
	Label["Parent"] = ViewColor
	
	local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint["MaxTextSize"] = 17
	UITextSizeConstraint["Parent"] = Label
	
	local UIGradient = Instance.new("UIGradient")
	UIGradient["Color"] = ColorSequence.new({  ColorSequenceKeypoint.new(0, Color3.fromRGB(20.000000707805157, 20.000000707805157, 20.000000707805157)) , ColorSequenceKeypoint.new(1, Color3.fromRGB(10.000000353902578, 10.000000353902578, 10.000000353902578)) })
	UIGradient["Parent"] = ViewColor
	
	local UICorner = Instance.new("UICorner")
	UICorner["CornerRadius"] = UDim.new(0, 2)
	UICorner["Parent"] = ViewColor
	
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint["AspectRatio"] = 7.239999771118164
	UIAspectRatioConstraint["Parent"] = ViewColor
	
	local Frame = Instance.new("Frame")
	Frame["BorderSizePixel"] = 0
	Frame["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Frame["Size"] = UDim2.new(0, 181, 0, 1)
	Frame["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Frame["Visible"] = false
	Frame["Position"] = UDim2.new(-0.0027583844494074583, 0, 0.9709985256195068, 0)
	Frame["Parent"] = ViewColor
	
	local UIGradient_1 = Instance.new("UIGradient")
	UIGradient_1["Color"] = ColorSequence.new({  ColorSequenceKeypoint.new(0, Color3.fromRGB(20.000000707805157, 20.000000707805157, 20.000000707805157)) , ColorSequenceKeypoint.new(1, Color3.fromRGB(10.000000353902578, 10.000000353902578, 10.000000353902578)) })
	UIGradient_1["Parent"] = Frame
	
	local UICorner_1 = Instance.new("UICorner")
	UICorner_1["CornerRadius"] = UDim.new(0, 0)
	UICorner_1["Parent"] = Frame
	
	local ColourWheel = Instance.new("ImageButton")
	ColourWheel["Active"] = false
	ColourWheel["BorderSizePixel"] = 0
	ColourWheel["Name"] = "ColourWheel"
	ColourWheel["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	ColourWheel["Selectable"] = false
	ColourWheel["AnchorPoint"] = Vector2.new(0.5, 0.5)
	ColourWheel["Image"] = "http://www.roblox.com/asset/?id=6020299385"
	ColourWheel["Size"] = UDim2.new(0.4989059567451477, 0, 0.576551616191864, 0)
	ColourWheel["ImageTransparency"] = 0.20000000298023224
	ColourWheel["Position"] = UDim2.new(0.3513452708721161, 0, 0.38342663645744324, 0)
	ColourWheel["BackgroundTransparency"] = 1
	ColourWheel["Parent"] = Frame
	
	local UIAspectRatioConstraint_1 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_1["AspectRatio"] = 0.9999999403953552
	UIAspectRatioConstraint_1["Parent"] = ColourWheel
	
	local Picker = Instance.new("ImageLabel")
	Picker["BorderSizePixel"] = 0
	Picker["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Picker["Name"] = "Picker"
	Picker["AnchorPoint"] = Vector2.new(0.5, 0.5)
	Picker["Image"] = "http://www.roblox.com/asset/?id=3678860011"
	Picker["Size"] = UDim2.new(0.09002578258514404, 0, 0.09002579748630524, 0)
	Picker["BackgroundTransparency"] = 1
	Picker["Position"] = UDim2.new(0.5000001192092896, 0, 0.4915757179260254, 0)
	Picker["Parent"] = ColourWheel
	
	local DarknessPicker = Instance.new("ImageButton")
	DarknessPicker["BorderSizePixel"] = 0
	DarknessPicker["Name"] = "DarknessPicker"
	DarknessPicker["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	DarknessPicker["Image"] = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	DarknessPicker["Size"] = UDim2.new(0.09908635914325714, 0, 0.5836986303329468, 0)
	DarknessPicker["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	DarknessPicker["ImageTransparency"] = 1
	DarknessPicker["Position"] = UDim2.new(0.7619521021842957, 0, 0.1122029647231102, 0)
	DarknessPicker["Parent"] = Frame
	
	local Slider = Instance.new("ImageLabel")
	Slider["ZIndex"] = 2
	Slider["BorderSizePixel"] = 0
	Slider["SliceCenter"] = Rect.new(100, 100, 100, 100)
	Slider["ScaleType"] = Enum.ScaleType.Slice
	Slider["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Slider["Name"] = "Slider"
	Slider["ImageTransparency"] = 0.20000000298023224
	Slider["AnchorPoint"] = Vector2.new(0.5, 0.5)
	Slider["Image"] = "rbxassetid://3570695787"
	Slider["Size"] = UDim2.new(1.000001072883606, 0, 0.02650105394423008, 0)
	Slider["ImageColor3"] = Color3.fromRGB(86.00000247359276, 86.00000247359276, 86.00000247359276)
	Slider["BackgroundTransparency"] = 1
	Slider["Position"] = UDim2.new(0.5000037550926208, 0, 0.07336077094078064, 0)
	Slider["SliceScale"] = 0.11999999731779099
	Slider["Parent"] = DarknessPicker
	
	local UIGradient_2 = Instance.new("UIGradient")
	UIGradient_2["Color"] = ColorSequence.new({  ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)) , ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)) })
	UIGradient_2["Rotation"] = 90
	UIGradient_2["Parent"] = DarknessPicker
	
	local UICorner_2 = Instance.new("UICorner")
	UICorner_2["CornerRadius"] = UDim.new(0, 4)
	UICorner_2["Parent"] = DarknessPicker
	
	local R = Instance.new("TextBox")
	R["BorderSizePixel"] = 0
	R["TextEditable"] = false
	R["Name"] = "R"
	R["BackgroundColor3"] = Color3.fromRGB(20.000000707805157, 20.000000707805157, 20.000000707805157)
	R["FontFace"] = Font.new("rbxassetid://12187368843", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	R["Size"] = UDim2.new(0, 32, 0, 17)
	R["Position"] = UDim2.new(0.14917127788066864, 0, 0.8080062866210938, 0)
	R["TextSize"] = 13
	R["TextColor3"] = Color3.fromRGB(255, 255, 255)
	R["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	R["Text"] = "255"
	R["ClearTextOnFocus"] = false
	R["Parent"] = Frame
	
	local TextLabel = Instance.new("TextLabel")
	TextLabel["BorderSizePixel"] = 0
	TextLabel["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	TextLabel["FontFace"] = Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	TextLabel["Size"] = UDim2.new(0, 19, 0, 17)
	TextLabel["Position"] = UDim2.new(-0.7738265991210938, 0, 0, 0)
	TextLabel["TextColor3"] = Color3.fromRGB(255, 255, 255)
	TextLabel["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	TextLabel["Text"] = "R"
	TextLabel["Font"] = Enum.Font.Fantasy
	TextLabel["BackgroundTransparency"] = 1
	TextLabel["TextSize"] = 16
	TextLabel["Parent"] = R
	
	local G = Instance.new("TextBox")
	G["BorderSizePixel"] = 0
	G["TextEditable"] = false
	G["Name"] = "G"
	G["BackgroundColor3"] = Color3.fromRGB(20.000000707805157, 20.000000707805157, 20.000000707805157)
	G["FontFace"] = Font.new("rbxassetid://12187368843", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	G["Size"] = UDim2.new(0, 32, 0, 17)
	G["Position"] = UDim2.new(0.49000000953674316, 0, 0.8080000281333923, 0)
	G["TextSize"] = 13
	G["TextColor3"] = Color3.fromRGB(255, 255, 255)
	G["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	G["Text"] = "255"
	G["ClearTextOnFocus"] = false
	G["Parent"] = Frame
	
	local TextLabel_1 = Instance.new("TextLabel")
	TextLabel_1["BorderSizePixel"] = 0
	TextLabel_1["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	TextLabel_1["FontFace"] = Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	TextLabel_1["Size"] = UDim2.new(0, 19, 0, 17)
	TextLabel_1["Position"] = UDim2.new(-0.7738265991210938, 0, 0, 0)
	TextLabel_1["TextColor3"] = Color3.fromRGB(255, 255, 255)
	TextLabel_1["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	TextLabel_1["Text"] = "G"
	TextLabel_1["Font"] = Enum.Font.Fantasy
	TextLabel_1["BackgroundTransparency"] = 1
	TextLabel_1["TextSize"] = 16
	TextLabel_1["Parent"] = G
	
	local B = Instance.new("TextBox")
	B["BorderSizePixel"] = 0
	B["TextEditable"] = false
	B["Name"] = "B"
	B["BackgroundColor3"] = Color3.fromRGB(20.000000707805157, 20.000000707805157, 20.000000707805157)
	B["FontFace"] = Font.new("rbxassetid://12187368843", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	B["Size"] = UDim2.new(0, 32, 0, 17)
	B["Position"] = UDim2.new(0.7979999780654907, 0, 0.8080000281333923, 0)
	B["TextSize"] = 13
	B["TextColor3"] = Color3.fromRGB(255, 255, 255)
	B["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	B["Text"] = "255"
	B["ClearTextOnFocus"] = false
	B["Parent"] = Frame
	
	local TextLabel_2 = Instance.new("TextLabel")
	TextLabel_2["BorderSizePixel"] = 0
	TextLabel_2["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	TextLabel_2["FontFace"] = Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	TextLabel_2["Size"] = UDim2.new(0, 19, 0, 17)
	TextLabel_2["Position"] = UDim2.new(-0.7738265991210938, 0, 0, 0)
	TextLabel_2["TextColor3"] = Color3.fromRGB(255, 255, 255)
	TextLabel_2["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	TextLabel_2["Text"] = "B"
	TextLabel_2["Font"] = Enum.Font.Fantasy
	TextLabel_2["BackgroundTransparency"] = 1
	TextLabel_2["TextSize"] = 16
	TextLabel_2["Parent"] = B
	
	local ColorDisplay = Instance.new("ImageLabel")
	ColorDisplay["BorderSizePixel"] = 0
	ColorDisplay["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	ColorDisplay["Name"] = "ColorDisplay"
	ColorDisplay["ImageTransparency"] = 1
	ColorDisplay["Image"] = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	ColorDisplay["Size"] = UDim2.new(0, 24, 0, 17)
	ColorDisplay["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	ColorDisplay["Position"] = UDim2.new(0.8313602209091187, 0, 0.15369506180286407, 0)
	ColorDisplay["Parent"] = ViewColor
	
	local UICorner_3 = Instance.new("UICorner")
	UICorner_3["CornerRadius"] = UDim.new(0, 4)
	UICorner_3["Parent"] = ColorDisplay
	
	local Line = Instance.new("Frame")
	Line["BorderSizePixel"] = 0
	Line["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
	Line["Name"] = "Line"
	Line["Size"] = UDim2.new(0, 178, 0, 1)
	Line["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Line["Position"] = UDim2.new(0.01104770042002201, 0, 0.9709985256195068, 0)
	Line["Parent"] = ViewColor
	
	------------------------------------------------


	local Dropdown = Instance.new("Frame")
	Dropdown["BorderSizePixel"] = 0
	Dropdown["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Dropdown["Name"] = "Dropdown"
	Dropdown["Size"] = UDim2.new(0, 186, 0, 32)
	Dropdown["BackgroundTransparency"] = 1
	Dropdown["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Dropdown["Position"] = UDim2.new(0.21557384729385376, 0, 0.2920585572719574, 0)
	Dropdown["Parent"] = Examples
	
	local ViewDropdown = Instance.new("ImageButton")
	ViewDropdown["BorderSizePixel"] = 0
	ViewDropdown["Name"] = "ViewDropdown"
	ViewDropdown["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	ViewDropdown["Image"] = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	ViewDropdown["Size"] = UDim2.new(0, 181, 0, 102)
	ViewDropdown["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	ViewDropdown["ImageTransparency"] = 1
	ViewDropdown["Position"] = UDim2.new(0, 2, 0, 6)
	ViewDropdown["BackgroundTransparency"] = 0.10000000149011612
	ViewDropdown["Parent"] = Dropdown
	
	local Label = Instance.new("TextLabel")
	Label["TextWrapped"] = true
	Label["BorderSizePixel"] = 0
	Label["Name"] = "Label"
	Label["TextScaled"] = true
	Label["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Label["FontFace"] = Font.new("rbxassetid://12187360881", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	Label["Size"] = UDim2.new(0.7767943739891052, 0, 0.5775953531265259, 0)
	Label["Position"] = UDim2.new(0.04080655425786972, 0, 0.19316284358501434, 0)
	Label["TextColor3"] = Color3.fromRGB(255, 255, 255)
	Label["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Label["Text"] = "Dropdown"
	Label["BackgroundTransparency"] = 1
	Label["TextXAlignment"] = Enum.TextXAlignment.Left
	Label["TextSize"] = 17
	Label["Parent"] = ViewDropdown
	
	local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint["MaxTextSize"] = 17
	UITextSizeConstraint["Parent"] = Label
	
	local UIGradient = Instance.new("UIGradient")
	UIGradient["Color"] = ColorSequence.new({  ColorSequenceKeypoint.new(0, Color3.fromRGB(20.000000707805157, 20.000000707805157, 20.000000707805157)) , ColorSequenceKeypoint.new(1, Color3.fromRGB(10.000000353902578, 10.000000353902578, 10.000000353902578)) })
	UIGradient["Parent"] = ViewDropdown
	
	local UICorner = Instance.new("UICorner")
	UICorner["CornerRadius"] = UDim.new(0, 2)
	UICorner["Parent"] = ViewDropdown
	
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint["AspectRatio"] = 7.239999771118164
	UIAspectRatioConstraint["Parent"] = ViewDropdown
	
	local Symbol = Instance.new("TextLabel")
	Symbol["TextWrapped"] = true
	Symbol["BorderSizePixel"] = 0
	Symbol["Name"] = "Symbol"
	Symbol["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Symbol["FontFace"] = Font.new("rbxassetid://12187360881", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	Symbol["Size"] = UDim2.new(0.09944687783718109, 0, 0.5775953531265259, 0)
	Symbol["Position"] = UDim2.new(0.9004735946655273, 0, 0.19316284358501434, 0)
	Symbol["TextColor3"] = Color3.fromRGB(255, 255, 255)
	Symbol["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Symbol["Text"] = ">"
	Symbol["BackgroundTransparency"] = 1
	Symbol["TextXAlignment"] = Enum.TextXAlignment.Left
	Symbol["TextSize"] = 16
	Symbol["Parent"] = ViewDropdown
	
	local UITextSizeConstraint_1 = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint_1["MaxTextSize"] = 17
	UITextSizeConstraint_1["Parent"] = Symbol
	
	local Frame = Instance.new("Frame")
	Frame["BorderSizePixel"] = 0
	Frame["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Frame["Size"] = UDim2.new(0, 181, 0, 0)
	Frame["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Frame["Visible"] = false
	Frame["Position"] = UDim2.new(-0.002761082025244832, 0, 0.9710034132003784, 0)
	Frame["Parent"] = ViewDropdown
	
	local UIGradient_1 = Instance.new("UIGradient")
	UIGradient_1["Color"] = ColorSequence.new({  ColorSequenceKeypoint.new(0, Color3.fromRGB(20.000000707805157, 20.000000707805157, 20.000000707805157)) , ColorSequenceKeypoint.new(1, Color3.fromRGB(10.000000353902578, 10.000000353902578, 10.000000353902578)) })
	UIGradient_1["Parent"] = Frame
	
	local UICorner_1 = Instance.new("UICorner")
	UICorner_1["CornerRadius"] = UDim.new(0, 0)
	UICorner_1["Parent"] = Frame
	
	local Button = Instance.new("TextButton")
	Button["BorderSizePixel"] = 0
	Button["Name"] = "Button"
	Button["TextSize"] = 17
	Button["TextYAlignment"] = Enum.TextYAlignment.Bottom
	Button["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
	Button["FontFace"] = Font.new("rbxassetid://12187373592", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	Button["Size"] = UDim2.new(0, 180, 0, 21)
	Button["TextColor3"] = Color3.fromRGB(17.00000088661909, 117.00000062584877, 167.00000524520874)
	Button["BorderColor3"] = Color3.fromRGB(0, 0, 0)
	Button["BackgroundTransparency"] = 1
	Button["Parent"] = Frame
	
	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout["Padding"] = UDim.new(0, 2)
	UIListLayout["SortOrder"] = Enum.SortOrder.LayoutOrder
	UIListLayout["Parent"] = Frame	
	
	
end

do -- UI Functions

	local _UIExist = tick()
	local UIExist = function()
		return (pcall(function()return Part.Name, Part.Parent~=nil and Part or error() end))
	end

    function Library:Tab( Data: { Name: string, Active: boolean } )
        Data = type(Data)=="table" and Data or {}
		Data.Name = Data.Name or "Tab"

        local tabButton = Examples.TabExample:Clone()
        tabButton.Name = Data.Name
        tabButton.Text = Data.Name
        tabButton.Parent = UI.Frame.MainContainer.MainPanel.LeftPanel.TabsContainer

        local contentFrame = Instance.new("ScrollingFrame")
        contentFrame.Name = Data.Name
        contentFrame.Size = UDim2.new(1, -10, 1, -10)
        contentFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        contentFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        contentFrame.BackgroundTransparency = 1
        contentFrame.BorderSizePixel = 0
        contentFrame.ScrollBarThickness = 6
        contentFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
        contentFrame.Visible = false
        contentFrame.Parent = UI.Frame.MainContainer.MainPanel.ContentPanel

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 5)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        contentLayout.Parent = contentFrame

        handleChildSize(contentFrame, contentFrame)

        local tabLib = { Object = tabButton, Content = contentFrame }

        local function switchTab()
            if Config.ActiveTab == tabLib then return end
            
            -- Deactivate old tab
            if Config.ActiveTab then
                Config.ActiveTab.Object:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(60,60,60)
                Config.ActiveTab.Object.TextColor3 = Color3.fromRGB(200,200,200)
                Config.ActiveTab.Content.Visible = false
            end
            
            -- Activate new tab
            tabButton:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(120, 180, 255)
            tabButton.TextColor3 = Color3.fromRGB(255,255,255)
            contentFrame.Visible = true
            Config.ActiveTab = tabLib
        end

        HandleEvent(tabButton.MouseButton1Click, switchTab)

        function tabLib:Slider(...)
            local args = {...}
            args[1].Tab = contentFrame
            return Library:Slider(unpack(args))
        end

        function tabLib:Label(...)
            local args = {...}
            args[1].Tab = contentFrame
            return Library:Label(unpack(args))
        end

        function tabLib:Button(...)
            local args = {...}
            args[1].Tab = contentFrame
            return Library:Button(unpack(args))
        end

        function tabLib:Toggle(...)
            local args = {...}
            args[1].Tab = contentFrame
            return Library:Toggle(unpack(args))
        end

        function tabLib:Keybind(...)
            local args = {...}
            args[1].Tab = contentFrame
            return Library:Keybind(unpack(args))
        end

        function tabLib:Dropdown(...)
            local args = {...}
            args[1].Tab = contentFrame
            return Library:Dropdown(unpack(args))
        end

        function tabLib:Color(...)
            local args = {...}
            args[1].Tab = contentFrame
            return Library:Color(unpack(args))
        end

        function tabLib:Section(name)
            local section = Library:Section(name)
            section:SetParent(contentFrame)
            return section
        end
        
        if Data.Active then
            switchTab()
        end

        return tabLib
    end

	function Library:Slider( Data: { Text: string, Tab: Frame, Callback: { text: string } }, Min: number, Max: number, Minimum: number, Maximum: number )

		Data = type(Data)=="table" and Data or {}
		Data.Name = Data.Name or Data.Text or "Example"
		Data.Tab = Data.Tab or UI.Frame.MainContainer.MainPanel.ContentPanel.Visible and UI.Frame.MainContainer.MainPanel.ContentPanel or nil
	
		Data.Min = Data.Min or Data.Minimum or Data.min or Data.minimum or 1
		Data.Max = Data.Max or Data.Maximum or Data.max or Data.maximum or 10
	
		Data.Min = Data.Min > -1 and Data.Min or 1
		Data.Max = Data.Max > Data.Min and Data.Max or Data.Min + 10
		Data.Value = Data.Value and ( Data.Value >= Data.Min and Data.Value <= Data.Max ) and Data.Value or math.random(Data.Min, Data.Max)
	
		Data.Position = Data.Position or nil
		Data.Callback = Data.Callback or function() end
		Data.Step = Data.Step and Data.Step/100 or 0.01
	
		local SliderExample = Examples:FindFirstChild("Slider")
		if not SliderExample then return; end
	
		SliderExample = SliderExample:Clone()
		SliderExample.Name = Data.Name
		SliderExample.Visible = true
	
		SliderExample.ViewSlider.Label.Text = Data.Name
		SliderExample.ViewSlider.Value.Text = `{Data.Min}/{Data.Max}`
		SliderExample.ViewSlider.Position = Data.Position or SliderExample.ViewSlider.Position
		SliderExample.Parent = Data.Tab
	
		local bar = SliderExample
		local viewSlider = bar.ViewSlider
		
		local isDragging = false
		local prevalue = Data.Value
	
		-- 统一处理值更新和UI表现的函数
		local function updateSlider(inputValue)
			if not UIExist() then return; end
			
			local percent = (inputValue - Data.Min) / (Data.Max - Data.Min)
			percent = math.clamp(percent, 0, 1)
			
			Data.Value = inputValue
			viewSlider.Value.Text = `{inputValue}/{Data.Max}`
			TS:Create(viewSlider.Button, TweenInfo.new(0.1), { Size = UDim2.new(percent, 0, 1, 0) }):Play()
			
			if not Data.WaitForMouse then
				if inputValue ~= prevalue then
					local called, message = pcall(Data.Callback, tonumber(inputValue), Data, prevalue)
					if not called then
						warn("[ Linui Library: Slider Bug ] "..Data.Name..": "..message)
					end
					prevalue = tonumber(inputValue)
				end
			end
		end
	
		-- 监听输入开始（鼠标按下或触摸开始）
		HandleEvent(viewSlider.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isDragging = true
				-- 立即更新一次位置，以响应单击
				local percent = (input.Position.X - viewSlider.AbsolutePosition.X) / viewSlider.AbsoluteSize.X
				percent = math.clamp(percent, 0, 1)
				local value = math.floor(Data.Min + (Data.Max - Data.Min) * percent + 0.5) -- +0.5用于四舍五入
				updateSlider(value)
			end
		end))
	
		-- 监听输入变化（鼠标移动或手指拖动）
		HandleEvent(viewSlider.InputChanged:Connect(function(input)
			if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local percent = (input.Position.X - viewSlider.AbsolutePosition.X) / viewSlider.AbsoluteSize.X
				percent = math.clamp(percent, 0, 1)
				local value = math.floor(Data.Min + (Data.Max - Data.Min) * percent + 0.5) -- +0.5用于四舍五入
				updateSlider(value)
			end
		end))
	
		-- 监听输入结束（鼠标松开或触摸结束）
		HandleEvent(viewSlider.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if isDragging and Data.WaitForMouse then
					-- 在拖动结束后，如果设置了WaitForMouse，则触发回调
					pcall(Data.Callback, tonumber(Data.Value), prevalue)
					prevalue = tonumber(Data.Value)
				end
				isDragging = false
			end
		end))
		
		--=====================================
		local SliderTable = { Object = viewSlider }
	
		function SliderTable:Set(value, nocall)
			if not UIExist() then return; end
			value = type(value)=="number" and value or Data.Value or Data.Min
			local clampedValue = math.clamp(value, Data.Min, Data.Max)
	
			local percent = (clampedValue - Data.Min) / (Data.Max - Data.Min)
			
			viewSlider.Value.Text = `{clampedValue}/{Data.Max}`
			TS:Create(viewSlider.Button, TweenInfo.new(0.1), { Size = UDim2.new(percent, 0, 1, 0) }):Play()
			
			if not nocall then
				local called, message = pcall(Data.Callback, tonumber(clampedValue), prevalue)
				if not called then
					warn("[ Linui Library: Slider Bug ] "..Data.Name..": "..message)
				end
			end
		end
	
		function SliderTable:Get()
			return Data.Value or Data.Min or 1
		end
	
		function SliderTable:Text(value)
			if not UIExist() then return; end
			value = type(value)=="string" and value or nil
			if value then
				viewSlider.Label.Text = value
			end
		end
		
		SliderTable:Set(Data.Value, Data.NoCall)
		return SliderTable
	end	
	
	function Library:Label( Data: { Text: string, Tab: Frame } )
		
		Data = type(Data)=="table" and Data or {}
		Data.Text = Data.Text or Data.Name or "Example"
		Data.Tab = Data.Tab or UI.Frame.MainContainer.MainPanel.ContentPanel.Visible and UI.Frame.MainContainer.MainPanel.ContentPanel or nil
	
		local LabelExample = Examples:FindFirstChild('Label')
		if not LabelExample then return; end
		
		LabelExample = LabelExample:Clone()
		LabelExample.Label.Text = Data.Text
		LabelExample.Parent = Data.Tab
		
		local LabelTable = { Object = LabelExample.Label }
		
		function LabelTable:Get(value)
			if not UIExist() then return ""; end
			return LabelExample.Label.Text	
		end
		
		function LabelTable:Text(value)
			if not UIExist() then return; end
			value = type(value)=="string" and value or nil
			if value then
				LabelExample.Label.Text = value
			end
		end
		
		return LabelTable
	end
	
	function Library:Button( Data: { Text: string, Tab: Frame, Callback: {} } )
	
		Data = type(Data)=="table" and Data or {}
		Data.Text = Data.Text or Data.Name or "Example"
		Data.Tab = Data.Tab or UI.Frame.MainContainer.MainPanel.ContentPanel.Visible and UI.Frame.MainContainer.MainPanel.ContentPanel or nil
		Data.Callback = type(Data.Callback)=="function" and Data.Callback or function() end
	
		local ButtonExample = Examples:FindFirstChild('Button')
		if not ButtonExample then return; end
	
		ButtonExample = ButtonExample:Clone()
		ButtonExample.Label.Text = Data.Text
		local event = HandleEvent(ButtonExample.MouseButton1Click:Connect(Data.Callback))
		ButtonExample.Parent = Data.Tab
	
		local ButtonTable = { Object = ButtonExample.Label }
		
		function ButtonTable:Callback()
			if Data.Callback then
				local suc, message = pcall(Data.Callback)
				if not suc then
					warn("[ Linui Library: Button Bug ] "..Data.Text.." | "..message)
				end
			end
		end
		
		function ButtonTable:Change(callback)
			if not UIExist() then return; end
			callback = type(callback)=="function" and callback or nil
			if callback then
				Data.Callback = callback
				if event then event:Disconnect() end
				event = ButtonExample.MouseButton1Click:Connect(Data.Callback)
			end
		end
		
		function ButtonTable:Text(value)
			if not UIExist() then return; end
			value = type(value)=="string" and value or nil
			if value then
				ButtonExample.Label.Text = value
			end
		end
	
		return ButtonTable
	end
	
	function Library:Toggle( Data: { Text: string, Tab: Frame, Value: boolean } )
		
		Data = type(Data)=="table" and Data or {}
		Data.Text = Data.Text or Data.Name or "Example"
		Data.Tab = Data.Tab or UI.Frame.MainContainer.MainPanel.ContentPanel.Visible and UI.Frame.MainContainer.MainPanel.ContentPanel or nil
		Data.Value = (type(Data.Value)=="boolean" or false) and Data.Value or false
		Data.Callback = type(Data.Callback)=="function" and Data.Callback or function() end
	
		local ToggleExample = Examples:FindFirstChild('Toggle')
		if not ToggleExample then return; end
		
		local Tweening = false
		local State = Data.Value
		
		ToggleExample = ToggleExample:Clone()
		ToggleExample.ViewToggle.Label.Text = Data.Text
		ToggleExample.Parent = Data.Tab
		
		local ToggleConfig = {
			
			["true"] = function()
				-- Position: {0, 0},{-0.02, 0}
				-- Size: {0.475, 0},{1.014, 0}
				-- ImageTransparency: 0.6
				if Tweening then return; end
				if not UIExist() then return; end
				Tweening = true
	
				if(pcall(function()return ToggleExample.ViewToggle.Button end)) then
					TS:Create(ToggleExample.ViewToggle.Button, TweenInfo.new(.2, Enum.EasingStyle.Sine), {
						Position = UDim2.new(unpack{ 0, 0, -0.02, 0 }),
						Size = UDim2.new(unpack{ 0.534, 0, 1.014, 0 }),
						ImageTransparency = .6
					}):Play()
				end
	
				task.wait(.2)
				State = not State
				Tweening = false
	
				return State
			end,
			
			["false"] = function()
				-- Position: {0.525, 0},{-0.02, 0}
				-- Size: {0.475, 0},{1.014, 0}
				-- ImageTransparency: .2
				if Tweening then return; end
				if not UIExist() then return; end
				Tweening = true
				
				if(pcall(function()return ToggleExample.ViewToggle.Button end)) then
					TS:Create(ToggleExample.ViewToggle.Button, TweenInfo.new(.2, Enum.EasingStyle.Sine), {
						Position = UDim2.new(unpack{ 0.525, 0, -0.02, 0 }),
						Size = UDim2.new(unpack{ 0.475, 0, 1.014, 0 }),
						ImageTransparency = .2
					}):Play()
				end
				
				task.wait(.2)
				State = not State
				Tweening = false
				
				return State
			end,
			
		}
		
		ToggleConfig["nil"] = ToggleConfig["false"]
		--------------
		local ToggleHandler = (function(nocall)
			local OldState = State
			if State then -- True, toggling false
			    local called, message = pcall(ToggleConfig["true"])
				if not called then
					State = not State
					warn("[ Linui Library: Toggle 'State' Bug ] "..Data.Name..": "..message)
				end


		    else -- False, toggling true
			    local called, message = pcall(ToggleConfig["false"])
				if not called then
					State = not State
					warn("[ Linui Library: Toggle 'State' Bug ] "..Data.Name..": "..message)
				end
			end

			if State ~= OldState and not nocall then
				local called, message = pcall(Data.Callback, State, OldState)
				if not called then
					warn("[ Linui Library: Toggle Bug ] "..Data.Name..": "..message)
				end
			end
		end)
		
		State = not State
		ToggleHandler(true, Data.NoCall)
		
		if not UIExist() or not (pcall(function()return ToggleExample.ViewToggle.MouseButton1Click end)) then return; end
		HandleEvent(ToggleExample.ViewToggle.MouseButton1Click, ToggleHandler)
		HandleEvent(ToggleExample.ViewToggle.Button.MouseButton1Click, ToggleHandler)
		--------------
		local ToggleLibrary = { Object = ToggleExample.ViewToggle }
		
		function ToggleLibrary:Set(value)
			if type(value)=="boolean" then
				ToggleHandler(not value)
			end
		end
		
		function ToggleLibrary:Get()
			repeat task.wait() until not Tweening -- Waits incase player toggles the toggle
			return State
		end
		
		function ToggleLibrary:Toggle()
			repeat task.wait() until not Tweening -- Waits incase player toggles the toggle
			ToggleHandler(State)
		end
		--------------
		return ToggleLibrary
	end
	
	function Library:Keybind( Data: { Text: string, Tab: Frame, Value: Enum | string } )
		
		Data = type(Data)=="table" and Data or {}
		Data.Text = Data.Text or Data.Name or "Test Keybind"
		Data.Tab = Data.Tab or UI.Frame.MainContainer.MainPanel.ContentPanel.Visible and UI.Frame.MainContainer.MainPanel.ContentPanel or nil
		Data.Value = (typeof(Data.Value)=="Enum" and Data.Value.Name) or (typeof(Data.Value)=="string" and Data.Value) or nil
		Data.Value = type(Data.Value)=="string" and Data.Value or "K"
		
		Data.OnChange = type(Data.OnChange)=="function" and Data.OnChange or function() end
		Data.Callback = type(Data.Callback)=="function" and Data.Callback or function() end
		
		local KeybindExample = Examples:FindFirstChild('Keybind')
		if not KeybindExample then return; end
		
		local WaitingForKey = false
		local KeyCooldown = false
		
		local CurrentKey = Data.Value
		local LoopExist = false
	
		KeybindExample = KeybindExample:Clone()
		KeybindExample.ViewKeybind.Label.Text = Data.Text
		KeybindExample.ViewKeybind.Button.Text = Data.Value
		KeybindExample.Parent = Data.Tab


		HandleEvent(UIS.InputBegan:Connect(function(keycode, chat)
			if chat or KeyCooldown then return; end
			KeyCooldown = true
			-------------------------------------
	
			local keyname = (keycode["KeyCode"]["Name"] or ""):lower();
			local real_keyname = (keycode["KeyCode"]["Name"] or "")
			if keyname=="unknown" then
				for i,v in next, Enum.UserInputType:GetEnumItems() do
					if keycode.UserInputType==v and v and type(v["Name"])=='string' then
						keyname = v["Name"]:lower()
						real_keyname = v["Name"]
					end
				end
			end
			
			if keyname=="unknown" then
				KeyCooldown = false
				return;
			end
			-------------------------------------
			local upper = {}
			local KBName = ""
			
			local generate = function(...)
				for i , v in next, {...} do
					KBName ..= tostring(v)
				end
			end
			
			for i = 1, #real_keyname do
				local key = string.sub(real_keyname, i, i)
				if key == key:upper() then
					upper[#upper+1] = key
				 end
			end
			if #upper >= 3 then
				generate(unpack(upper))
			else
				KBName = real_keyname
			end
			-------------------------------------		
			if not UIExist() then return; end
			if WaitingForKey then			
				
				if keyname:find("movement") or keyname:find("space") then return end -- Disgard any movement functions
	
				KeybindExample.ViewKeybind.Button.Text = KBName
				local oldCurrentKey = CurrentKey

				CurrentKey = KBName
				WaitingForKey = false
				KeyCooldown = false
				LoopExist = false
	
				local called, message = pcall(Data.OnChange, real_keyname, (oldCurrentKey or KBName), KBName)
				if not called then
					warn("[ Linui Library: Keybind 'OnChange' Bug ] "..Data.Name..": "..message)
				end
			else
				
				KeybindExample.ViewKeybind.Button.Text = CurrentKey
				CurrentKey = CurrentKey
				KeyCooldown = false
	
				if KBName == CurrentKey then
					local called, message = pcall(Data.Callback, real_keyname, KBName)
					if not called then
						warn("[ Linui Library: Keybind Bug ] "..Data.Name..": "..message)
					end
				end
			end		
			
		end))
		
		HandleEvent(KeybindExample.ViewKeybind.Button.MouseButton1Click:Connect(function()
	
			WaitingForKey = not WaitingForKey
			if WaitingForKey and not LoopExist then
				
				local start = ""
				LoopExist = true
				
				local currentTime = tick()
				KeybindExample.ViewKeybind.Button.Text = "."
				
				while task.wait() and Frame and LoopExist and UIExist() do
					
					if #start >= 3 then start = "." else start ..= "." end
					if (tick() - currentTime) >= .2 then
						WaitingForKey = true
						currentTime = tick()
						if not UIExist() then return; end
						KeybindExample.ViewKeybind.Button.Text = start
					end
				end
				
				WaitingForKey = false
				LoopExist = false
			end
			
		end))
		
		local KeybindLib = { Object = KeybindExample.ViewKeybind }
		return KeybindLib
	end
	
	function Library:Dropdown( Data: { Text: string, Tab: Frame, Data: {} } ) 

		Data = type(Data)=="table" and Data or {}
		Data.Text = Data.Text or Data.Name or "Test Dropdown"
		Data.Data = type(Data.Data)=="table" and Data.Data or {}
		Data.Tab = Data.Tab or UI.Frame.MainContainer.MainPanel.ContentPanel.Visible and UI.Frame.MainContainer.MainPanel.ContentPanel or nil
		Data.Callback = Data.Callback or function() end

		local DropdownExample = Examples:FindFirstChild("Dropdown")
		if not DropdownExample then return; end

		DropdownExample = DropdownExample:Clone()
		DropdownExample.Parent = Data.Tab
		
		local Dropdown = DropdownExample.ViewDropdown
		Dropdown.Label.Text = Data.Text

		local Frame = Dropdown.Frame
		local ExampleButton = Frame.Button:Clone()
		local Symbol = Dropdown.Symbol
		local parentFrame = Dropdown.Parent
		
		local Toggled, Cooldown = false, false
		local parentFrame_Size = parentFrame.Size
		local addSize = 26
		local dropdownLib = { Object = Dropdown, Data = {} }
		
		HandleEvent(Dropdown.MouseButton1Click:Connect(function()
	
			if Cooldown then return; end
			Cooldown = true
			if Toggled then		

				Symbol.Text = "<"
				local ObjInFrame = 0

				for _, child: Frame in next, Frame:GetChildren() do
					if (pcall(function() return child.Name, child.Position, child.Size, child.BackgroundColor3 end)) then
						TS:Create(child, TweenInfo.new(.5), { TextTransparency = 1, Size = UDim2.fromOffset(child.Size.X.Offset, 0) }):Play()
						ObjInFrame += 1
					end
				end

				pcall(function()
					Frame:TweenSize(UDim2.fromOffset(Frame.Size.X.Offset, 0), nil, nil, .5)
					parentFrame:TweenSize(parentFrame_Size, nil, nil, .5)
				end)
				
				task.wait(.5)
				Frame.Visible = false
			else
				
				local ObjInFrame = 0
				Frame.Visible = true
				
				for _, child: Frame in next, Frame:GetChildren() do
					if (pcall(function() return child.Name, child.Position, child.Size, child.BackgroundColor3 end)) then
						TS:Create(child, TweenInfo.new(.5), { TextTransparency = 0, Size = UDim2.fromOffset(child.Size.X.Offset, ExampleButton.Size.Y.Offset) }):Play()
						ObjInFrame += 1
					end
				end
				
				Symbol.Text = ">"
				Frame:TweenSize(UDim2.fromOffset(Frame.Size.X.Offset, addSize * ObjInFrame), nil, nil, .5)
				parentFrame:TweenSize(UDim2.fromOffset(parentFrame_Size.X.Offset, parentFrame_Size.Y.Offset + (addSize * ObjInFrame)), nil, nil, .5)
				task.wait(.5)
				
			end
			
			Cooldown = false
			Toggled = not Toggled
		end))
		
		HandleEvent(Frame.ChildAdded:Connect(function(child)
			if (pcall(function() return child.Name, child.Position, child.Size, child.BackgroundColor3 end)) then
				Frame.Size = UDim2.fromOffset(Frame.Size.X.Offset, Frame.Size.Y.Offset + addSize)
				dropdownLib.Data[child.Name] = child

				if Toggled then

					local ObjInFrame = 0
					Frame.Visible = true
					
					for _, child in next, Frame:GetChildren() do
						if (pcall(function() return child.Name, child.Position, child.Size, child.BackgroundColor3 end)) then
							ObjInFrame += 1
						end
					end

					pcall(function()
						parentFrame:TweenSize(UDim2.fromOffset(parentFrame_Size.X.Offset, parentFrame_Size.Y.Offset + (addSize * ObjInFrame)), nil, nil, .5)
					end)

				end
			end
		end))
		
		HandleEvent(Frame.ChildRemoved:Connect(function(child)
			if (pcall(function() return child.Name, child.Position, child.Size, child.BackgroundColor3 end)) then
				Frame.Size = UDim2.fromOffset(Frame.Size.X.Offset, Frame.Size.Y.Offset - addSize)
				dropdownLib.Data[child.Name] = nil

				if Toggled then

					local ObjInFrame = 0
					Frame.Visible = true
					
					for _, child in next, Frame:GetChildren() do
						if (pcall(function() return child.Name, child.Position, child.Size, child.BackgroundColor3 end)) then
							ObjInFrame += 1
						end
					end

					pcall(function()
						parentFrame:TweenSize(UDim2.fromOffset(parentFrame_Size.X.Offset, parentFrame_Size.Y.Offset + (addSize * ObjInFrame)), nil, nil, .5)
					end)
					
				end
			end
		end))
		
		Symbol.Text = "<"
		Frame.Visible = false
		Frame.Size = UDim2.fromOffset(Frame.Size.X.Offset, 0)

		local Selected = nil

		function dropdownLib:Remove( value )
			for i, child in next, Frame:GetChildren() do
				if (pcall(function() return child.Name, child.Position, child.Size, child.BackgroundColor3 end)) then
					if not value then
						child:Destroy()
					else
						if child.Name == value then
							child:Destroy()
						end
					end
				end
			end
			dropdownLib:Refresh()
		end
		
		function dropdownLib:Delete(...)
			return dropdownLib:Remove(...)
		end

		function dropdownLib:Add( value: string )
			if type(value)=="string" then

				local btn: TextButton = ExampleButton:Clone()
				btn.Text = value
				btn.Name = value
				btn.Parent = Frame
				
				HandleEvent(btn.MouseButton1Click, function()

					btn.TextColor3 = Color3.fromRGB()
					local oldSelName = Selected and Selected.Name or ""
					
					if oldSelName~="" then
						local Stroke: UIStroke = Selected:FindFirstChildOfClass("UIStroke")
						if Stroke then Stroke:Destroy() end
						Selected.TextColor3 = Color3.fromRGB(17, 117, 167)
					end

					local UIStroke = Instance.new("UIStroke")
					UIStroke["Color"] = Color3.fromRGB(255, 255, 255)
					UIStroke["Thickness"] = 0.20000000298023224
					UIStroke["Parent"] = btn

					btn.TextColor3 = Color3.fromRGB(26, 177, 252)
					Selected = btn

					if not Data.KeepText then
						pcall(function() Dropdown.Label.Text = value end) -- IDK, ITS 4 AM
					end

					local passed, message = pcall(Data.Callback, value, oldSelName)
					if not passed then
						warn("[ Linui Library: Dropdown Bug ] "..Data.Name..": "..message)
					end
				end)
			else
				return;
			end
		end

		function dropdownLib:Get( value: string ) 
			for i, child in next, Frame:GetChildren() do
				if (pcall(function() return child.Name, child.Position, child.Size, child.BackgroundColor3 end)) then
					if not value then
						return nil;
					else
						if child.Name == value then
							return child
						end
					end
				end
			end
			return nil
		end

		function dropdownLib:All()
			return dropdownLib.Data
		end

		function dropdownLib:Refresh(data: {})

			task.spawn(function()
				if type(data)=="table" then
					dropdownLib:Remove()
					for i,v in next, data do
						dropdownLib:Add(v)
					end
					return;
				end
				---------------
				repeat task.wait() until not Cooldown
				Cooldown = true
	
				if not Toggled then		
					Symbol.Text = "<"

					pcall(function()
						Frame:TweenSize(UDim2.fromOffset(Frame.Size.X.Offset, 0), nil, nil, .5)
						parentFrame:TweenSize(parentFrame_Size, nil, nil, .5)
					end)
					
					task.wait(.5)
					Frame.Visible = false
				else
					
					local ObjInFrame = 0
					Frame.Visible = true
					
					for _, child in next, Frame:GetChildren() do
						if (pcall(function() return child.Name, child.Position, child.Size, child.BackgroundColor3 end)) then
							ObjInFrame += 1
						end
					end
					
					Symbol.Text = ">"
					pcall(function()
						Frame:TweenSize(UDim2.fromOffset(Frame.Size.X.Offset, addSize * ObjInFrame), nil, nil, .5)
						parentFrame:TweenSize(UDim2.fromOffset(parentFrame_Size.X.Offset, parentFrame_Size.Y.Offset + (addSize * ObjInFrame)), nil, nil, .5)
					end)
					task.wait(.5)
					
				end
				Cooldown = false
			end)
		end

		dropdownLib:Refresh(Data.Data)

		if Frame:FindFirstChild("Button") then
			Frame.Button:Destroy()
		end

		return dropdownLib
	end

	function Library:Color( Data: { Text: string, Tab: Frame, Data: {} } ) 

		Data = type(Data)=="table" and Data or {}
		Data.Text = Data.Text or Data.Name or "Test Color"
		Data.Data = type(Data.Data)=="table" and Data.Data or {}
		Data.Tab = Data.Tab or UI.Frame.MainContainer.MainPanel.ContentPanel.Visible and UI.Frame.MainContainer.MainPanel.ContentPanel or nil
		Data.Callback = Data.Callback or function() end

		local ColorExample = Examples:FindFirstChild("ColorPicker")
		if not ColorExample then return; end

		ColorExample = ColorExample:Clone()
		ColorExample.Parent = Data.Tab
		
		local ViewColor = ColorExample:FindFirstChild("ViewColor")
		ViewColor.Label.Text = Data.Text

		local frame = ViewColor:FindFirstChild("Frame")
		
		local colourWheel: ImageButton = frame:WaitForChild("ColourWheel")
		local wheelPicker: ImageLabel = colourWheel:WaitForChild("Picker")
		
		local darknessPicker = frame:WaitForChild("DarknessPicker")
		local darknessSlider: ImageLabel = darknessPicker:WaitForChild("Slider")
		
		local colourDisplay = ViewColor:WaitForChild("ColorDisplay")
		
		local R, G, B = frame:FindFirstChild("R"), frame:FindFirstChild("G"), frame:FindFirstChild("B")
        
        -- [[ MOBILE PATCH START: Color Picker Input ]]
		local isDraggingWheel = false
        local isDraggingDarkness = false
        -- [[ MOBILE PATCH END: Color Picker Input ]]
        
		local colorlib = {}

		local function updateMouse(inputPos)
			local centreOfWheel = Vector2.new(colourWheel.AbsolutePosition.X + (colourWheel.AbsoluteSize.X/2), colourWheel.AbsolutePosition.Y + (colourWheel.AbsoluteSize.Y/2))
			
            if isDraggingWheel then
    			local distanceFromWheel = (inputPos - centreOfWheel).Magnitude
			    if distanceFromWheel <= colourWheel.AbsoluteSize.X/2 then
				    wheelPicker:TweenPosition(UDim2.new(0, inputPos.X - colourWheel.AbsolutePosition.X, 0, inputPos.Y - colourWheel.AbsolutePosition.Y), nil, nil, .05)
			    end
            end
			
			if isDraggingDarkness then
				darknessSlider:TweenPosition(UDim2.new(darknessSlider.Position.X.Scale, 0, 0, 
					math.clamp(
						inputPos.Y - darknessPicker.AbsolutePosition.Y, 
						0, 
						darknessPicker.AbsoluteSize.Y)
					)	, nil, nil, .05)
			end
			
			return centreOfWheel
		end
		
		local function updateColour(centreOfWheel)
			local colourPickerCentre = Vector2.new(
				wheelPicker.AbsolutePosition.X + (wheelPicker.AbsoluteSize.X/2),
				wheelPicker.AbsolutePosition.Y + (wheelPicker.AbsoluteSize.Y/2)
			)
			
			local h = (math.pi - math.atan2(colourPickerCentre.Y - centreOfWheel.Y, colourPickerCentre.X - centreOfWheel.X)) / (math.pi * 2)
			local s = (centreOfWheel - colourPickerCentre).Magnitude / (colourWheel.AbsoluteSize.X/2)
			local v = math.abs((darknessSlider.AbsolutePosition.Y - darknessPicker.AbsolutePosition.Y) / darknessPicker.AbsoluteSize.Y - 1)
			local hsv = Color3.fromHSV(math.clamp(h, 0, 1), math.clamp(s, 0, 1), math.clamp(v, 0, 1))
			
			TS:Create(colourDisplay, TweenInfo.new( (isDraggingWheel or isDraggingDarkness) and .05 or .1 ), { 
				BackgroundColor3 = hsv
			}):Play()
			
			darknessPicker.UIGradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromHSV(h, s, 1)), -- Use full brightness for the gradient
				ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
			}
			
			TS:Create(darknessSlider, TweenInfo.new( (isDraggingWheel or isDraggingDarkness) and .05 or .1 ), { 
				ImageColor3 = hsv
			}):Play()
			
			colorlib:Set(hsv)
		end	
		
		local ShowCooldown = false
		local originalSize = frame.Size
		local _originalSize = ColorExample.Size

		HandleEvent(ViewColor.MouseButton1Click:Connect(function()
			if ShowCooldown then return; end
			ShowCooldown = true

			if not frame.Visible then
				frame.Size = UDim2.fromOffset(frame.Size.X.Offset, 0)
				ColorExample.Size = frame.Size
				frame.Visible = true
				ColorExample:TweenSize(UDim2.new(0, 181, 0, 180), nil, nil, .5)
				frame:TweenSize(UDim2.new(0, 181, 0, 144), nil, nil, .5)
				task.wait(.6)
			else
				frame.Size = UDim2.new(0, 181, 0, 144)
				ColorExample.Size = UDim2.new(0, 181, 0, 160)
				frame.Visible = true
				ColorExample:TweenSize(_originalSize, nil, nil, .5)
				frame:TweenSize(UDim2.fromOffset(frame.Size.X.Offset, 0), nil, nil, .5)
				task.wait(.6)
				frame.Visible = false
			end

			ShowCooldown = false
		end))
        
        -- [[ MOBILE PATCH START: Color Picker Input Logic ]]
        HandleEvent(colourWheel.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDraggingWheel = true
                updateColour(updateMouse(input.Position))
            end
        end)
        
        HandleEvent(darknessPicker.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDraggingDarkness = true
                updateColour(updateMouse(input.Position))
            end
        end)
        
        HandleEvent(UIS.InputChanged, function(input)
            if not (isDraggingWheel or isDraggingDarkness) then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                updateColour(updateMouse(input.Position))
            end
        end)
        
        HandleEvent(UIS.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDraggingWheel = false
                isDraggingDarkness = false
            end
        end)
        -- [[ MOBILE PATCH END: Color Picker Input Logic ]]

		----------------------------------------
		function colorlib:Set( color: Color3, nocall: boolean )
			if typeof(color)=="Color3" then

				TS:Create(colourDisplay, TweenInfo.new( (isDraggingWheel or isDraggingDarkness) and .05 or .1 ), { 
					BackgroundColor3 = color
				}):Play()

				local _R, _G, _B = color.R * 255, color.G * 255, color.B * 255 -- I love complicating my code [ Im joking I did this for fun ]
				_R, _G, _B = tostring(math.floor(_R + 0.5)), tostring(math.floor(_G + 0.5)), tostring(math.floor(_B + 0.5))
	
				if typeof(R)=="Instance" and R.ClassName:match("Text") then R.Text = _R end
				if typeof(G)=="Instance" and G.ClassName:match("Text") then G.Text = _G end
				if typeof(B)=="Instance" and B.ClassName:match("Text") then B.Text = _B end

				if not nocall then
					local called, message = pcall(Data.Callback, color)
					if not called then
						warn("[ Linui Library: ColorPicker Bug ] "..Data.Name..": "..message)
					end
				end
			end
		end

		function colorlib:Text( value: string )
			if type(value)=="string" then
				ViewColor.Label.Text = value
			end
		end

		function colorlib:Get()
			repeat task.wait(.06) until not (isDraggingWheel or isDraggingDarkness) -- If they're picking a color, wait for them to be finished
			return colourDisplay.BackgroundColor3
		end

		if Data.Color then
			colorlib:Set(Data.Color, Data.nocall)
		end

		frame.Visible = Data.Hide
		return colorlib
	end

	function Library:Section(name) 
		
		name = type(name)=="string" and name or "ExmapleSection"
		local sectionLib = {}
		local HideCooldown = false
		
		local Section = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local _Frame = Instance.new("ScrollingFrame")
	
		local Label = Instance.new("TextButton")
		local Line = Instance.new("Frame")
		
		local UIListLayout = Instance.new("UIListLayout")
		local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
	
		--Properties:
	
		Section.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
		Section.BackgroundTransparency = 0.400
		Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Section.BorderSizePixel = 0
		Section.Position = UDim2.new(-4.31409859e-08, 0, -1.04034665e-08, 0)
		Section.Size = UDim2.new(1.00000012, 0, 0.259604543, 0)
	
		UICorner.CornerRadius = UDim.new(0, 0)
		UICorner.Parent = Section
	
		_Frame.Name = "_Frame"
		_Frame.Parent = Section
		_Frame.Active = true
		_Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		_Frame.BackgroundTransparency = 1.000
		_Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		_Frame.BorderSizePixel = 0
		_Frame.Position = UDim2.new(0.0197910536, 0, 0.0965689346, 0)
		_Frame.Size = UDim2.new(0.961277604, 0, 0.884780228, 0)
		_Frame.ScrollBarThickness = 1
	
		Label.Name = "Label"
		Label.Parent = Section
		Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Label.BackgroundTransparency = 1.000
		Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Label.BorderSizePixel = 0
		Label.Position = UDim2.new(0.0565457866, 0, 0.0130498558, 0)
		Label.Size = UDim2.new(0.882113576, 0, 0.0574193671, 0)
		Label.Text = name
		Label.TextColor3 = Color3.fromRGB(255, 255, 255)
		Label.TextScaled = true
		Label.TextSize = 15.000
		Label.TextWrapped = true
	
		UITextSizeConstraint.Parent = Label
		UITextSizeConstraint.MaxTextSize = 14
		
		UIListLayout.Padding = UDim.new(0, 1)
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout.Parent = _Frame
		
		Line.Name = "Line"
		Line.Parent = Section
		Line.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		Line.BorderColor3 = Color3.fromRGB(255, 255, 255)
		Line.Position = UDim2.new(0.353349507, 0, 0.0730726197, 0)
		Line.Size = UDim2.new(0.292164683, 0, 0.00135501358, 0)
		
		local ParentFrame
		
        function sectionLib:SetParent(parent)
            if typeof(parent) == "Instance" and parent:IsA("GuiObject") then
                Section.Parent = parent
                ParentFrame = parent
                handleChildSize(_Frame, _Frame)
            end
        end

		function sectionLib:Slider(Data)
			Data = type(Data)=="table" and Data or {}
			Data.Tab = _Frame
			return Library:Slider(Data)
		end
		
		function sectionLib:Label(Data)
			Data = type(Data)=="table" and Data or {}
			Data.Tab = _Frame
			return Library:Label(Data)
		end
		
		function sectionLib:Button(Data)
			Data = type(Data)=="table" and Data or {}
			Data.Tab = _Frame
			return Library:Button(Data)
		end
		function sectionLib:Toggle(Data)
			Data = type(Data)=="table" and Data or {}
			Data.Tab = _Frame
			return Library:Toggle(Data)
		end
		function sectionLib:Keybind(Data)
			Data = type(Data)=="table" and Data or {}
			Data.Tab = _Frame
			return Library:Keybind(Data)
		end
		function sectionLib:Dropdown(Data)
			Data = type(Data)=="table" and Data or {}
			Data.Tab = _Frame
			return Library:Dropdown(Data)
		end
		function sectionLib:Color(Data)
			Data = type(Data)=="table" and Data or {}
			Data.Tab = _Frame
			return Library:Color(Data)
		end
		function sectionLib:Hide()
			Section.Parent = nil
		end
		
		function sectionLib:Show()
			Section.Parent = ParentFrame
		end

		return sectionLib
	end

	Loop(function()
		local exist = pcall(function() return Part.Name, Part.Parent~=nil and Part or error(), Part.Size end)
		if not exist then _UIExist = false end
		_UIExist = tick()
	end)
end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local SCALE = 0.01
local LookView = Vector3.new(0, .1, -11)

local StoredTransparency = {}
local PartIncreased = false

-- [[ MOBILE PATCH START: SMOOTH UI TILT ]]
local currentTiltX = 0
local currentTiltY = 0
local smoothingFactor = 0.1 -- 平滑系数。值越小，过渡越平滑 (推荐 0.05 到 0.2)

Cache.add(game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
	local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    if not Frame.Visible then return end -- Only tilt when visible

	-- 1. 计算目标倾斜角度
	local targetTiltX = (mouse.X - mouse.ViewSizeX/2) * SCALE
	local targetTiltY = (mouse.Y - mouse.ViewSizeY/2) * SCALE
	
	-- 2. 使用线性插值 (Lerp) 平滑地更新当前倾斜角度
	currentTiltX = currentTiltX + (targetTiltX - currentTiltX) * smoothingFactor
	currentTiltY = currentTiltY + (targetTiltY - currentTiltY) * smoothingFactor
	
	-- 3. 使用平滑后的角度来更新UI的CFrame
	Part.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(LookView.X, LookView.Y, LookView.Z) * CFrame.Angles(0, math.rad(currentTiltX), 0) * CFrame.Angles(math.rad(currentTiltY) , 0 , 0)
	
end))
-- [[ MOBILE PATCH END: SMOOTH UI TILT ]]


-------------------------------------- Main Section
local MainPanel = UI.Frame.MainContainer.MainPanel
local PlayerName = MainPanel.Header.PlayerName

do -- PlayerName Hover Effect (Disabled for now to simplify)
	-- The rich text hover effect can be re-enabled here if desired.
    -- For now, we keep the name static.
end

-------------------------------------- UI: Breathing, Config
local AllFrames = Frame:GetChildren()

-- [[ FEATURE: Fullscreen, Resizer, and Visibility Logic ]]
local isFullScreen = false
local originalState = {}
local fullscreenIcon = "http://www.roblox.com/asset/?id=284412499" -- Expand
local normalIcon = "http://www.roblox.com/asset/?id=284412574" -- Shrink

HandleEvent(UI.Frame.MainContainer.MainPanel.Header.ButtonContainer.FULLSCREEN.MouseButton1Click, function()
    isFullScreen = not isFullScreen
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    if isFullScreen then
        -- Save original state
        originalState.LookView = LookView
        originalState.Size = Part.Size
        originalState.Scale = SCALE
        
        -- Animate to fullscreen
        local fullscreenProperties = {
            Size = Vector3.new(45, 25, 2) -- Fullscreen size
        }
        TS:Create(Part, tweenInfo, fullscreenProperties):Play()
        LookView = Vector3.new(0, 0, -2.5) -- Move closer to camera
        SCALE = 0 -- Disable tilt
        UI.Frame.MainContainer.MainPanel.Header.ButtonContainer.FULLSCREEN.Image = normalIcon
    else
        -- Animate back to original state
        TS:Create(Part, tweenInfo, {Size = originalState.Size}):Play()
        LookView = originalState.LookView
        SCALE = originalState.Scale
        UI.Frame.MainContainer.MainPanel.Header.ButtonContainer.FULLSCREEN.Image = fullscreenIcon
    end
end)

local isResizing = false
local initialMousePos, initialSize
local minSize = Vector3.new(18, 10, 2)
local maxSize = Vector3.new(50, 30, 2)
HandleEvent(UI.Frame.ResizeHandle.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = true
        initialMousePos = Vector2.new(input.Position.X, input.Position.Y)
        initialSize = Part.Size
        Config["FrameCooldown"] = true
    end
end)
HandleEvent(UIS.InputChanged, function(input)
    if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local currentMousePos = Vector2.new(input.Position.X, input.Position.Y)
        local delta = currentMousePos - initialMousePos
        
        local newSize = initialSize + Vector3.new(delta.X * 0.05, -delta.Y * 0.05, 0)
        
        newSize = Vector3.new(
            math.clamp(newSize.X, minSize.X, maxSize.X),
            math.clamp(newSize.Y, minSize.Y, maxSize.Y),
            Part.Size.Z
        )
        Part.Size = newSize
    end
end)
HandleEvent(UIS.InputEnded, function(input)
    if isResizing and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        isResizing = false
        Config["FrameCooldown"] = false
    end
end)

-- [[ FEATURE: New Minimize/Transparency Logic ]]
HandleEvent(UI.Frame.MainContainer.MainPanel.Header.ButtonContainer.MINIMIZE.MouseButton1Click, function()
    Frame.Visible = false
    MinimizedBar.Visible = true
end)

HandleEvent(MinimizedBar:FindFirstChild("ExpandButton").MouseButton1Click, function()
    Frame.Visible = true
    MinimizedBar.Visible = false
end)


HandleEvent(UI.Frame.MainContainer.MainPanel.Header.ButtonContainer.EXIT.MouseButton1Click, function()
    Frame.Visible = false
    MinimizedBar.Visible = false -- also hide the minimized bar
    if OpenButton then OpenButton.Visible = true end
end)


do -- Breathing
	
	local X, Y, Z = .1, .1, .1
	local waitTime = 1
	local started = PartIncreased
	
	WrapFunction(function()
		Loop(function()
			if not Config.Breathing and started==PartIncreased then return; end
            if isFullScreen or not Frame.Visible then return end -- Don't breathe in fullscreen or when hidden
			TS:Create(Part, TweenInfo.new(waitTime), { Size = Part.Size + (PartIncreased and Vector3.new(-X, -Y, -Z) or Vector3.new(X, Y, Z)) }):Play()
			task.wait(waitTime)
			PartIncreased = not PartIncreased
		end, 1.1, true)
	end)

end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
setmetatable(Library, { -- Config Manager
	__index = function(self, value)
		if(value=="config") then
			return Config
		end
		return rawget(Config, value)
	end,
	__newindex = function(self, base, value)
		if base == "Text" and type(value)=="string" then
			return pcall(function()
				UI.Frame.MainContainer.MainPanel.Header.PlayerName.Text = value
                if OpenButton then OpenButton.Text = value end
			end)
		end
		return rawset(Library, base, value)
	end
})
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Library:Init()
	
    local settingsTab = self:Tab({Name = "Settings", Active = true})
	settingsTab:Toggle({ Text = "Breathing", Value = type(Storage.Data["LinenLib_Breathing"])=="nil" and true or Storage.Data["LinenLib_Breathing"], Callback = function(value) Storage.Data["LinenLib_Breathing"] = value; Config.Breathing = value end })
	settingsTab:Toggle({ Text = "Always On Top", Value = type(Storage.Data["LinenLib_AOT"])=="nil" and true or Storage.Data["LinenLib_AOT"], Callback = function(value) Storage.Data["LinenLib_AOT"] = value;UI["AlwaysOnTop"] = value end })
	settingsTab:Keybind({ Text = "Toggle Key", Value = Storage.Data["LinenLib_Toggle"] or "RightShift", Callback = function() end, OnChange = function(key) Config.ToggleKey = Enum.KeyCode[key] or Enum.KeyCode.RightShift end })
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	settingsTab:Slider({
		Text = "Z", -- Text of Slider
	
		Min = 1,
		Value = Storage.Data["LinenLib_Z"] or math.abs(LookView.Z),
		Max = 40,
	
		WaitForMouse = true,
	
		Callback = function(value, prevalue)
			Storage.Data["LinenLib_Z"]  = value
			LookView = Vector3.new(LookView.X, LookView.Y, -value)
		end,
	})
	
	settingsTab:Slider({
		Text = "Y",
	
		Min = 0,
		Value = Storage.Data["LinenLib_Y"] or 0,
		Max = 5,
	
		WaitForMouse = true,
	
		Callback = function(value, prevalue)
			Storage.Data["LinenLib_Y"] = value
			if value~=prevalue then
				LookView = Vector3.new(LookView.X, value, LookView.Z)
			end
		end,
	}):Set(Storage.Data["LinenLib_Y"])
	
	settingsTab:Slider({
	
		Text = "R", -- Text of Slider
		Step = 1,
	
		Min = ( 0.01 * 100 ),
		Value = Storage.Data["LinenLib_R"] or SCALE * 100,
		Max = 21,
	
		WaitForMouse = true,
	
		Callback = function(value)
			Storage.Data["LinenLib_R"] = value
			SCALE = value/100
		end,
	
	})
	
	settingsTab:Slider({
	
		Text = "G",
		Step = 1,
	
		Min = 1,
		Value = Storage.Data["LinenLib_G"] or 6,
		Max = 20,
	
		Callback = function(value, prevalue)
			Storage.Data["LinenLib_G"] = value
			for i,v in next, AllFrames do
				if v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ImageButton") or v:IsA("ScrollingFrame") then
					local Layout;
	
					for a, b in next, v:GetDescendants() do
						if b:IsA("UIListLayout") then
							Layout = b
							break;
						end
					end
	
					if Layout then
						Layout.Padding = UDim.new(0, value)
					end
				end
			end
		end,
	
	})
	return Library
end

Library.Frame = Frame
Library.Storage = Storage
Library:Init() -- Loads settings

-- [[ WindUI Style Open Button ]]
local ScreenGui = MinimizedBar.Parent
OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Text = "Linui"
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 150, 0, 40)
OpenButton.Position = UDim2.new(0, 20, 0.5, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Font = Enum.Font.GothamSemibold
OpenButton.TextSize = 16
OpenButton.Visible = false -- Initially hidden
OpenButton.Draggable = true
OpenButton.Active = true

local obCorner = Instance.new("UICorner", OpenButton)
obCorner.CornerRadius = UDim.new(0, 8)
local obStroke = Instance.new("UIStroke", OpenButton)
obStroke.Color = Color3.fromRGB(80, 80, 80)

HandleEvent(OpenButton.MouseButton1Click, function()
    Frame.Visible = true
    OpenButton.Visible = false
end)

-- Global Toggle Logic
HandleEvent(UIS.InputBegan, function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Config.ToggleKey then
        -- If main frame is visible, minimize it.
        if Frame.Visible then
            Frame.Visible = false
            MinimizedBar.Visible = true
        -- If only minimized bar is visible, expand it.
        elseif MinimizedBar.Visible then
            Frame.Visible = true
            MinimizedBar.Visible = false
        -- If both are hidden (i.e. toggled from open button), show main frame.
        else
            Frame.Visible = true
            OpenButton.Visible = false
        end
    end
end)


-- .<(:D _^_ D:)>.
return Library
