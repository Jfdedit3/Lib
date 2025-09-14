--[[
	User Interface Library
	Made by Late
	Modified to include internal Blur, Purple Theme, and UI Toggle Button
]]
--// Connections
local GetService = game.GetService
local Connect = game.Loaded.Connect
local Wait = game.Loaded.Wait
local Clone = game.Clone
local Destroy = game.Destroy
if (not game:IsLoaded()) then
	local Loaded = game.Loaded
	Loaded.Wait(Loaded);
end
--// Important
local Setup = {
	Keybind = Enum.KeyCode.LeftControl,
	Transparency = 0.2,
	ThemeMode = "Dark", -- Définir sur "Purple" pour utiliser le thème violet
	Size = nil,
}
--// Themes
local ThemesDefinitions = {
	--// (Dark Theme)
	Dark = {
		--// Frames:
		Primary = Color3.fromRGB(30, 30, 30),
		Secondary = Color3.fromRGB(35, 35, 35),
		Component = Color3.fromRGB(40, 40, 40),
		Interactables = Color3.fromRGB(45, 45, 45),
		--// Text:
		Tab = Color3.fromRGB(200, 200, 200),
		Title = Color3.fromRGB(240,240,240),
		Description = Color3.fromRGB(200,200,200),
		--// Outlines:
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(40, 40, 40),
		--// Image:
		Icon = Color3.fromRGB(220, 220, 220),
	},
	--// (Light Theme)
	Light = {
		--// Frames:
		Primary = Color3.fromRGB(232, 232, 232),
		Secondary = Color3.fromRGB(255, 255, 255),
		Component = Color3.fromRGB(245, 245, 245),
		Interactables = Color3.fromRGB(235, 235, 235),
		--// Text:
		Tab = Color3.fromRGB(50, 50, 50),
		Title = Color3.fromRGB(0, 0, 0),
		Description = Color3.fromRGB(100, 100, 100),
		--// Outlines:
		Shadow = Color3.fromRGB(255, 255, 255),
		Outline = Color3.fromRGB(210, 210, 210),
		--// Image:
		Icon = Color3.fromRGB(100, 100, 100),
	},
	--// (Void Theme)
	Void = {
		--// Frames:
		Primary = Color3.fromRGB(15, 15, 15),
		Secondary = Color3.fromRGB(20, 20, 20),
		Component = Color3.fromRGB(25, 25, 25),
		Interactables = Color3.fromRGB(30, 30, 30),
		--// Text:
		Tab = Color3.fromRGB(200, 200, 200),
		Title = Color3.fromRGB(240,240,240),
		Description = Color3.fromRGB(200,200,200),
		--// Outlines:
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(40, 40, 40),
		--// Image:
		Icon = Color3.fromRGB(220, 220, 220),
	},
	--// (Purple Theme)
	Purple = {
		--// Frames:
		Primary = Color3.fromRGB(35, 15, 50),       -- Fond principal très foncé violet
		Secondary = Color3.fromRGB(45, 25, 65),     -- Fond secondaire légèrement plus clair
		Component = Color3.fromRGB(60, 35, 85),     -- Composants (boutons, etc.)
		Interactables = Color3.fromRGB(80, 50, 110),-- Éléments interactifs (toggles, sliders)
		--// Text:
		Tab = Color3.fromRGB(200, 180, 220),        -- Texte des onglets
		Title = Color3.fromRGB(230, 210, 255),      -- Titres
		Description = Color3.fromRGB(210, 190, 240),-- Descriptions
		--// Outlines:
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(90, 60, 120),      -- Contours
		--// Image:
		Icon = Color3.fromRGB(220, 200, 255),       -- Icônes
		--// Accents (for active states, etc.)
		Accent = Color3.fromRGB(180, 120, 255),     -- Couleur d'accentuation (toggle on, etc.)
	}
}

--// Initialize Theme based on Setup.ThemeMode
local Theme = ThemesDefinitions[Setup.ThemeMode] or ThemesDefinitions.Dark

--// Services & Functions
local Type = nil
local LocalPlayer = GetService(game, "Players").LocalPlayer;
local Services = {
	Insert = GetService(game, "InsertService");
	Tween = GetService(game, "TweenService");
	Run = GetService(game, "RunService");
	Input = GetService(game, "UserInputService");
}
local Player = {
	Mouse = LocalPlayer:GetMouse();
	GUI = LocalPlayer.PlayerGui;
}

--// Internal Blur Function
local function CreateInternalBlur(ParentWindow)
	local BlurFrame = Instance.new("Frame")
	BlurFrame.Name = "InternalBlurOverlay"
	BlurFrame.Size = UDim2.new(1, 0, 1, 0)
	BlurFrame.Position = UDim2.new(0, 0, 0, 0)
	BlurFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	BlurFrame.BackgroundTransparency = 0.7
	BlurFrame.BorderSizePixel = 0
	BlurFrame.ZIndex = 1000
	BlurFrame.Visible = false
	BlurFrame.Parent = ParentWindow
	return BlurFrame
end

local Tween = function(Object : Instance, Speed : number, Properties : {},  Info : { EasingStyle: Enum?, EasingDirection: Enum? })
	local Style, Direction
	if Info then
		Style, Direction = Info["EasingStyle"], Info["EasingDirection"]
	else
		Style, Direction = Enum.EasingStyle.Sine, Enum.EasingDirection.Out
	end
	return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end
local SetProperty = function(Object: Instance, Properties: {})
	for Index, Property in next, Properties do
		Object[Index] = (Property);
	end
	return Object
end
local Multiply = function(Value, Amount)
	local New = {
		Value.X.Scale * Amount;
		Value.X.Offset * Amount;
		Value.Y.Scale * Amount;
		Value.Y.Offset * Amount;
	}
	return UDim2.new(unpack(New))
end
local Color = function(Color, Factor, Mode)
	Mode = Mode or Setup.ThemeMode
	local baseTheme = ThemesDefinitions[Mode] or ThemesDefinitions.Dark
	if Mode == "Light" then
		return Color3.fromRGB((Color.R * 255) - Factor, (Color.G * 255) - Factor, (Color.B * 255) - Factor)
	else
		return Color3.fromRGB((Color.R * 255) + Factor, (Color.G * 255) + Factor, (Color.B * 255) + Factor)
	end
end
local Drag = function(Canvas)
	if Canvas then
		local Dragging;
		local DragInput;
		local Start;
		local StartPosition;
		local function Update(input)
			local delta = input.Position - Start
			Canvas.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
		end
		Connect(Canvas.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				Dragging = true
				Start = Input.Position
				StartPosition = Canvas.Position
				Connect(Input.Changed, function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		Connect(Canvas.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				DragInput = Input
			end
		end)
		Connect(Services.Input.InputChanged, function(Input)
			if Input == DragInput and Dragging and not Type then
				Update(Input)
			end
		end)
	end
end
Resizing = {
	TopLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, -1)};
	TopRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, -1)};
	BottomLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, 1)};
	BottomRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, 1)};
}
Resizeable = function(Tab, Minimum, Maximum)
	task.spawn(function()
		local MousePos, Size, UIPos = nil, nil, nil
		if Tab and Tab:FindFirstChild("Resize") then
			local Positions = Tab:FindFirstChild("Resize")
			for Index, Types in next, Positions:GetChildren() do
				Connect(Types.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = Types
						MousePos = Vector2.new(Player.Mouse.X, Player.Mouse.Y)
						Size = Tab.AbsoluteSize
						UIPos = Tab.Position
					end
				end)
				Connect(Types.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = nil
					end
				end)
			end
		end
		local Resize = function(Delta)
			if Type and MousePos and Size and UIPos and Tab:FindFirstChild("Resize")[Type.Name] == Type then
				local Mode = Resizing[Type.Name]
				local NewSize = Vector2.new(Size.X + Delta.X * Mode.X.X, Size.Y + Delta.Y * Mode.Y.Y)
				NewSize = Vector2.new(math.clamp(NewSize.X, Minimum.X, Maximum.X), math.clamp(NewSize.Y, Minimum.Y, Maximum.Y))
				local AnchorOffset = Vector2.new(Tab.AnchorPoint.X * Size.X, Tab.AnchorPoint.Y * Size.Y)
				local NewAnchorOffset = Vector2.new(Tab.AnchorPoint.X * NewSize.X, Tab.AnchorPoint.Y * NewSize.Y)
				local DeltaAnchorOffset = NewAnchorOffset - AnchorOffset
				Tab.Size = UDim2.new(0, NewSize.X, 0, NewSize.Y)
				local NewPosition = UDim2.new(
					UIPos.X.Scale,
					UIPos.X.Offset + DeltaAnchorOffset.X * Mode.X.X,
					UIPos.Y.Scale,
					UIPos.Y.Offset + DeltaAnchorOffset.Y * Mode.Y.Y
				)
				Tab.Position = NewPosition
			end
		end
		Connect(Player.Mouse.Move, function()
			if Type then
				Resize(Vector2.new(Player.Mouse.X, Player.Mouse.Y) - MousePos)
			end
		end)
	end)
end
--// Setup [UI]
local Screen
if (identifyexecutor) then
	Screen = Services.Insert:LoadLocalAsset("rbxassetid://18490507748");
	-- Blur géré en interne
else
	Screen = (script.Parent);
	-- Blur géré en interne
end
Screen.Main.Visible = false
xpcall(function()
	Screen.Parent = game.CoreGui
end, function()
	Screen.Parent = Player.GUI
end)
--// Tables for Data
local Animations = {}
local InternalBlurs = {} -- Stockera les instances de Frame de flou interne
local Components = (Screen:FindFirstChild("Components"));
local Library = {};
local StoredInfo = {
	["Sections"] = {};
	["Tabs"] = {}
};
--// Animations [Window]
function Animations:Open(Window: CanvasGroup, Transparency: number, UseCurrentSize: boolean)
	local Original = (UseCurrentSize and Window.Size) or Setup.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")
	SetProperty(Shadow, { Transparency = 1 })
	SetProperty(Window, {
		Size = Multiplied,
		GroupTransparency = 1,
		Visible = true,
	})
	Tween(Shadow, .25, { Transparency = 0.5 })
	Tween(Window, .25, {
		Size = Original,
		GroupTransparency = Transparency or 0,
	})
end
function Animations:Close(Window: CanvasGroup)
	local Original = Window.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")
	SetProperty(Window, {
		Size = Original,
	})
	Tween(Shadow, .25, { Transparency = 1 })
	Tween(Window, .25, {
		Size = Multiplied,
		GroupTransparency = 1,
	})
	task.wait(.25)
	Window.Size = Original
	Window.Visible = false
end
function Animations:Component(Component: any, Custom: boolean)
	Connect(Component.InputBegan, function()
		if Custom then
			Tween(Component, .25, { Transparency = .85 });
		else
			local currentColor = Component.BackgroundColor3
			local hoverColor = Color(currentColor, 10, Setup.ThemeMode)
			Tween(Component, .25, { BackgroundColor3 = hoverColor });
		end
	end)
	Connect(Component.InputEnded, function()
		if Custom then
			Tween(Component, .25, { Transparency = 1 });
		else
			Tween(Component, .25, { BackgroundColor3 = Theme.Component });
		end
	end)
end
--// Library [Window]
function Library:CreateWindow(Settings: { Title: string, Size: UDim2, Transparency: number, MinimizeKeybind: Enum.KeyCode?, Blurring: boolean, Theme: string })
	local Window = Clone(Screen:WaitForChild("Main"));
	local Sidebar = Window:FindFirstChild("Sidebar");
	local Holder = Window:FindFirstChild("Main");
	local BG = Window:FindFirstChild("BackgroundShadow");
	local Tab = Sidebar:FindFirstChild("Tab");
	local Options = {};
	local Examples = {};
	local Opened = true; -- État de la fenêtre (ouverte/fermée via Minimize/Maximize)
	local IsUIVisible = true; -- État de l'UI (visible/invisible via Toggle UI)
	local Maximized = false;
	local BlurEnabled = false

	--// Update Theme if specified in Settings
	if Settings.Theme and ThemesDefinitions[Settings.Theme] then
		Setup.ThemeMode = Settings.Theme
		Theme = ThemesDefinitions[Settings.Theme]
	elseif Setup.ThemeMode and ThemesDefinitions[Setup.ThemeMode] then
		Theme = ThemesDefinitions[Setup.ThemeMode]
	else
		Theme = ThemesDefinitions.Dark
	end

	--// Création du bouton Toggle UI
	local ToggleUIButton = Instance.new("TextButton")
	ToggleUIButton.Name = "ToggleUI"
	ToggleUIButton.Size = UDim2.new(0, 25, 1, -10)
	ToggleUIButton.Position = UDim2.new(0, 95, 0, 5) -- Ajusté pour être à gauche des autres boutons
	ToggleUIButton.Text = "👁" -- Symbole pour "oeil" (visible/invisible)
	ToggleUIButton.Font = Enum.Font.GothamBold
	ToggleUIButton.TextSize = 14
	ToggleUIButton.TextColor3 = Theme.Title -- Couleur du texte selon le thème
	ToggleUIButton.BackgroundTransparency = 0.5
	ToggleUIButton.BackgroundColor3 = Theme.Component -- Couleur de fond selon le thème
	ToggleUIButton.BorderSizePixel = 0
	ToggleUIButton.Parent = Sidebar.Top.Buttons

	-- Ajouter un effet hover au bouton Toggle UI
	Animations:Component(ToggleUIButton, false) -- false pour indiquer que c'est un bouton standard

	for Index, Example in next, Window:GetDescendants() do
		if Example.Name:find("Example") and not Examples[Example.Name] then
			Examples[Example.Name] = Example
		end
	end
	--// UI Blur & More
	Drag(Window);
	Resizeable(Window, Vector2.new(411, 271), Vector2.new(9e9, 9e9));
	Setup.Transparency = Settings.Transparency or 0
	Setup.Size = Settings.Size
	-- Setup.ThemeMode is set above
	if Settings.Blurring then
		-- Utiliser la fonction interne pour créer le flou
		InternalBlurs[Settings.Title] = CreateInternalBlur(Window)
		BlurEnabled = true
	end
	if Settings.MinimizeKeybind then
		Setup.Keybind = Settings.MinimizeKeybind
	end
	--// Animate
	local function ToggleUIVisibility()
		IsUIVisible = not IsUIVisible
		if IsUIVisible then
			-- Rendre l'UI visible
			Window.Visible = true
			Animations:Open(Window, Setup.Transparency)
			if BlurEnabled then
				local blurFrame = InternalBlurs[Settings.Title]
				if blurFrame then
					blurFrame.Visible = Opened -- Visible seulement si la fenêtre est "ouverte"
				end
			end
		else
			-- Cacher l'UI
			Animations:Close(Window)
			if BlurEnabled then
				local blurFrame = InternalBlurs[Settings.Title]
				if blurFrame then
					blurFrame.Visible = false
				end
			end
			-- Attendre la fin de l'animation pour cacher complètement
			task.delay(0.3, function()
				if not IsUIVisible then -- Vérifier à nouveau, au cas où elle a été réactivée
					Window.Visible = false
				end
			end)
		end
	end

	local Close = function()
		if Opened then
			-- Fermer la fenêtre (minimiser)
			Opened = false
			if BlurEnabled then
				local blurFrame = InternalBlurs[Settings.Title]
				if blurFrame then
					blurFrame.Visible = false
				end
			end
			Animations:Close(Window)
			-- Ne pas cacher Window.Visible ici, car l'UI elle-même est toujours "visible"
		else
			-- Ouvrir la fenêtre (maximiser/restaurer)
			Opened = true
			Animations:Open(Window, Setup.Transparency)
			if BlurEnabled then
				local blurFrame = InternalBlurs[Settings.Title]
				if blurFrame and IsUIVisible then -- Ne montrer le flou que si l'UI est visible
					blurFrame.Visible = true
				end
			end
		end
	end
	for Index, Button in next, Sidebar.Top.Buttons:GetChildren() do
		if Button:IsA("TextButton") and Button ~= ToggleUIButton then -- Exclure le ToggleUIButton de cette boucle
			local Name = Button.Name
			Animations:Component(Button, true)
			Connect(Button.MouseButton1Click, function()
				if Name == "Close" then
					Close()
				elseif Name == "Maximize" then
					if Maximized then
						Maximized = false
						Tween(Window, .15, { Size = Setup.Size });
					else
						Maximized = true
						Tween(Window, .15, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5 )});
					end
				elseif Name == "Minimize" then
					Opened = false
					-- Window.Visible = false -- Supprimé, géré par ToggleUI
					if BlurEnabled then
						local blurFrame = InternalBlurs[Settings.Title]
						if blurFrame then
							blurFrame.Visible = false
						end
					end
				end
			end)
		end
	end

	-- Connecter le bouton Toggle UI
	Connect(ToggleUIButton.MouseButton1Click, ToggleUIVisibility)

	Services.Input.InputBegan:Connect(function(Input, Focused)
		if (Input == Setup.Keybind or Input.KeyCode == Setup.Keybind) and not Focused then
			Close() -- Utilise la logique de fermeture/minimisation existante
		end
	end)
	--// Tab Functions
	function Options:SetTab(Name: string)
		for Index, Button in next, Tab:GetChildren() do
			if Button:IsA("TextButton") then
				local Opened, SameName = Button.Value, (Button.Name == Name);
				local Padding = Button:FindFirstChildOfClass("UIPadding");
				if SameName and not Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 25) });
					Tween(Button, .25, { BackgroundTransparency = 0.9, Size = UDim2.new(1, -15, 0, 30) });
					SetProperty(Opened, { Value = true });
				elseif not SameName and Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 20) });
					Tween(Button, .25, { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 0, 30) });
					SetProperty(Opened, { Value = false });
				end
			end
		end
		for Index, Main in next, Holder:GetChildren() do
			if Main:IsA("CanvasGroup") then
				local Opened, SameName = Main.Value, (Main.Name == Name);
				local Scroll = Main:FindFirstChild("ScrollingFrame");
				if SameName and not Opened.Value then
					Opened.Value = true
					Main.Visible = true
					Tween(Main, .3, { GroupTransparency = 0 });
					Tween(Scroll["UIPadding"], .3, { PaddingTop = UDim.new(0, 5) });
				elseif not SameName and Opened.Value then
					Opened.Value = false
					Tween(Main, .15, { GroupTransparency = 1 });
					Tween(Scroll["UIPadding"], .15, { PaddingTop = UDim.new(0, 15) });
					task.delay(.2, function()
						Main.Visible = false
					end)
				end
			end
		end
	end
	function Options:AddTabSection(Settings: { Name: string, Order: number })
		local Example = Examples["SectionExample"];
		local Section = Clone(Example);
		StoredInfo["Sections"][Settings.Name] = (Settings.Order);
		SetProperty(Section, {
			Parent = Example.Parent,
			Text = Settings.Name,
			Name = Settings.Name,
			LayoutOrder = Settings.Order,
			Visible = true
		});
	end
	function Options:AddTab(Settings: { Title: string, Icon: string, Section: string? })
		if StoredInfo["Tabs"][Settings.Title] then
			error("[UI LIB]: A tab with the same name has already been created")
		end
		local Example, MainExample = Examples["TabButtonExample"], Examples["MainExample"];
		local Section = StoredInfo["Sections"][Settings.Section];
		local Main = Clone(MainExample);
		local Tab = Clone(Example);
		if not Settings.Icon then
			Destroy(Tab["ICO"]);
		else
			SetProperty(Tab["ICO"], { Image = Settings.Icon });
		end
		StoredInfo["Tabs"][Settings.Title] = { Tab }
		SetProperty(Tab["TextLabel"], { Text = Settings.Title });
		SetProperty(Main, {
			Parent = MainExample.Parent,
			Name = Settings.Title;
		});
		SetProperty(Tab, {
			Parent = Example.Parent,
			LayoutOrder = Section or #StoredInfo["Sections"] + 1,
			Name = Settings.Title;
			Visible = true;
		});
		Tab.MouseButton1Click:Connect(function()
			Options:SetTab(Tab.Name);
		end)
		return Main.ScrollingFrame
	end
	--// Notifications
	function Options:Notify(Settings: { Title: string, Description: string, Duration: number })
		local Notification = Clone(Components["Notification"]);
		local Title, Description = Options:GetLabels(Notification);
		local Timer = Notification["Timer"];
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Notification, {
			Parent = Screen["Frame"],
		})
		task.spawn(function()
			local Duration = Settings.Duration or 2
			local Wait = task.wait;
			Animations:Open(Notification, Setup.Transparency, true); Tween(Timer, Duration, { Size = UDim2.new(0, 0, 0, 4) });
			Wait(Duration);
			Animations:Close(Notification);
			Wait(1);
			Notification:Destroy();
		end)
	end
	--// Component Functions
	function Options:GetLabels(Component)
		local Labels = Component:FindFirstChild("Labels")
		return Labels.Title, Labels.Description
	end
	function Options:AddSection(Settings: { Name: string, Tab: Instance })
		local Section = Clone(Components["Section"]);
		SetProperty(Section, {
			Text = Settings.Name,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	function Options:AddButton(Settings: { Title: string, Description: string, Tab: Instance, Callback: any })
		local Button = Clone(Components["Button"]);
		local Title, Description = Options:GetLabels(Button);
		Connect(Button.MouseButton1Click, Settings.Callback)
		Animations:Component(Button)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Button, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	function Options:AddInput(Settings: { Title: string, Description: string, Tab: Instance, Callback: any })
		local Input = Clone(Components["Input"]);
		local Title, Description = Options:GetLabels(Input);
		local TextBox = Input["Main"]["Input"];
		Connect(Input.MouseButton1Click, function()
			TextBox:CaptureFocus()
		end)
		Connect(TextBox.FocusLost, function()
			Settings.Callback(TextBox.Text)
		end)
		Animations:Component(Input)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Input, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	function Options:AddToggle(Settings: { Title: string, Description: string, Default: boolean, Tab: Instance, Callback: any })
		local Toggle = Clone(Components["Toggle"]);
		local Title, Description = Options:GetLabels(Toggle);
		local On = Toggle["Value"];
		local Main = Toggle["Main"];
		local Circle = Main["Circle"];
		local Set = function(Value)
			if Value then
				-- Utiliser la couleur d'accentuation pour le toggle activé si définie dans le thème
				local accentColor = Theme.Accent or Color3.fromRGB(153, 155, 255)
				Tween(Main,   .2, { BackgroundColor3 = accentColor });
				Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) });
			else
				Tween(Main,   .2, { BackgroundColor3 = Theme.Interactables });
				Tween(Circle, .2, { BackgroundColor3 = Theme.Primary, Position = UDim2.new(0, 3, 0.5, 0) });
			end
			On.Value = Value
		end
		Connect(Toggle.MouseButton1Click, function()
			local Value = not On.Value
			Set(Value)
			Settings.Callback(Value)
		end)
		Animations:Component(Toggle);
		Set(Settings.Default);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Toggle, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	function Options:AddKeybind(Settings: { Title: string, Description: string, Tab: Instance, Callback: any })
		local Dropdown = Clone(Components["Keybind"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Bind = Dropdown["Main"].Options;
		local Mouse = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 };
		local Types = {
			["Mouse"] = "Enum.UserInputType.MouseButton",
			["Key"] = "Enum.KeyCode."
		}
		Connect(Dropdown.MouseButton1Click, function()
			local Time = tick();
			local Detect, Finished
			SetProperty(Bind, { Text = "..." });
			Detect = Connect(game.UserInputService.InputBegan, function(Key, Focused)
				local InputType = (Key.UserInputType);
				if not Finished and not Focused then
					Finished = (true)
					if table.find(Mouse, InputType) then
						Settings.Callback(Key);
						SetProperty(Bind, {
							Text = tostring(InputType):gsub(Types.Mouse, "MB")
						})
					elseif InputType == Enum.UserInputType.Keyboard then
						Settings.Callback(Key);
						SetProperty(Bind, {
							Text = tostring(Key.KeyCode):gsub(Types.Key, "")
						})
					end
				end
			end)
		end)
		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	function Options:AddDropdown(Settings: { Title: string, Description: string, Options: {}, Tab: Instance, Callback: any })
		local Dropdown = Clone(Components["Dropdown"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Text = Dropdown["Main"].Options;
		Connect(Dropdown.MouseButton1Click, function()
			local Example = Clone(Examples["DropdownExample"]);
			local Buttons = Example["Top"]["Buttons"];
			Tween(BG, .25, { BackgroundTransparency = 0.6 });
			SetProperty(Example, { Parent = Window });
			Animations:Open(Example, 0, true)
			for Index, Button in next, Buttons:GetChildren() do
				if Button:IsA("TextButton") then
					Animations:Component(Button, true)
					Connect(Button.MouseButton1Click, function()
						Tween(BG, .25, { BackgroundTransparency = 1 });
						Animations:Close(Example);
						task.wait(2)
						Destroy(Example);
					end)
				end
			end
			for Index, Option in next, Settings.Options do
				local Button = Clone(Examples["DropdownButtonExample"]);
				local Title, Description = Options:GetLabels(Button);
				local Selected = Button["Value"];
				Animations:Component(Button);
				SetProperty(Title, { Text = Index });
				SetProperty(Button, { Parent = Example.ScrollingFrame, Visible = true });
				Destroy(Description);
				Connect(Button.MouseButton1Click, function()
					local NewValue = not Selected.Value
					if NewValue then
						-- Utiliser la couleur d'interactables pour l'élément sélectionné
						Tween(Button, .25, { BackgroundColor3 = Theme.Interactables });
						Settings.Callback(Option)
						Text.Text = Index
						for _, Others in next, Example:GetChildren() do
							if Others:IsA("TextButton") and Others ~= Button then
								-- Réinitialiser les autres éléments
								Others.BackgroundColor3 = Theme.Component
							end
						end
					else
						-- Réinitialiser si désélectionné (peut-être pas applicable ici)
						Tween(Button, .25, { BackgroundColor3 = Theme.Component });
					end
					Selected.Value = NewValue
					Tween(BG, .25, { BackgroundTransparency = 1 });
					Animations:Close(Example);
					task.wait(2)
					Destroy(Example);
				end)
			end
		end)
		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	function Options:AddSlider(Settings: { Title: string, Description: string, MaxValue: number, AllowDecimals: boolean, DecimalAmount: number, Tab: Instance, Callback: any })
		local Slider = Clone(Components["Slider"]);
		local Title, Description = Options:GetLabels(Slider);
		local Main = Slider["Slider"];
		local Amount = Main["Main"].Input;
		local Slide = Main["Slide"];
		local Fire = Slide["Fire"];
		local Fill = Slide["Highlight"];
		local Circle = Fill["Circle"];
		local Active = false
		local Value = 0
		local SetNumber = function(Number)
			if Settings.AllowDecimals then
				local Power = 10 ^ (Settings.DecimalAmount or 2)
				Number = math.floor(Number * Power + 0.5) / Power
			else
				Number = math.round(Number)
			end
			return Number
		end
		local Update = function(Number)
			local Scale = (Player.Mouse.X - Slide.AbsolutePosition.X) / Slide.AbsoluteSize.X
			Scale = (Scale > 1 and 1) or (Scale < 0 and 0) or Scale
			if Number then
				Number = (Number > Settings.MaxValue and Settings.MaxValue) or (Number < 0 and 0) or Number
			end
			Value = SetNumber(Number or (Scale * Settings.MaxValue))
			Amount.Text = Value
			Fill.Size = UDim2.fromScale((Number and Number / Settings.MaxValue) or Scale, 1)
			Settings.Callback(Value)
		end
		local Activate = function()
			Active = true
			repeat task.wait()
				Update()
			until not Active
		end
		Connect(Amount.FocusLost, function()
			Update(tonumber(Amount.Text) or 0)
		end)
		Connect(Fire.MouseButton1Down, Activate)
		Connect(Services.Input.InputEnded, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Active = false
			end
		end)
		-- Utiliser la couleur d'accentuation pour le remplissage du slider si définie
		local accentColor = Theme.Accent or Color3.fromRGB(153, 155, 255)
		Fill.BackgroundColor3 = accentColor
		Fill.Size = UDim2.fromScale(Value, 1);
		Animations:Component(Slider);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Slider, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	function Options:AddParagraph(Settings: { Title: string, Description: string, Tab: Instance })
		local Paragraph = Clone(Components["Paragraph"]);
		local Title, Description = Options:GetLabels(Paragraph);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Paragraph, {
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	local Themes = {
		Names = {
			["Paragraph"] = function(Label)
				if Label:IsA("TextButton") then
					Label.BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode);
				end
			end,
			["Title"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,
			["Description"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Description
				end
			end,
			["Section"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,
			["Options"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
				end
			end,
			["Notification"] = function(Label)
				if Label:IsA("CanvasGroup") then
					Label.BackgroundColor3 = Theme.Primary
					Label.UIStroke.Color = Theme.Outline
				end
			end,
			["TextLabel"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent:FindFirstChild("List") then
					Label.TextColor3 = Theme.Tab
				end
			end,
			["Main"] = function(Label)
				if Label:IsA("Frame") then
					if Label.Parent == Window then
						Label.BackgroundColor3 = Theme.Secondary
					elseif Label.Parent:FindFirstChild("Value") then
						local Toggle = Label.Parent.Value
						local Circle = Label:FindFirstChild("Circle")
						if not Toggle.Value then
							Label.BackgroundColor3 = Theme.Interactables
							if Circle then Circle.BackgroundColor3 = Theme.Primary end
						end
					else
						Label.BackgroundColor3 = Theme.Interactables
					end
				elseif Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
				end
			end,
			["Amount"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,
			["Slide"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,
			["Input"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				elseif Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				elseif Label:IsA("TextBox") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
					Label.PlaceholderColor3 = Color3.new(0.7, 0.7, 0.7) -- Placeholder gris
				end
			end,
			["Outline"] = function(Stroke)
				if Stroke:IsA("UIStroke") then
					Stroke.Color = Theme.Outline
				end
			end,
			["DropdownExample"] = function(Label)
				Label.BackgroundColor3 = Theme.Secondary
			end,
			["Underline"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Outline
				end
			end,
			-- Mise à jour du thème pour le bouton Toggle UI
			["ToggleUI"] = function(Button) -- Nouvelle entrée pour le bouton Toggle UI
				if Button:IsA("TextButton") and Button.Name == "ToggleUI" then
					Button.TextColor3 = Theme.Title
					Button.BackgroundColor3 = Theme.Component
				end
			end,
		},
		Classes = {
			["ImageLabel"] = function(Label)
				if Label.Image ~= "rbxassetid://6644618143" then
					Label.ImageColor3 = Theme.Icon
				end
			end,
			["TextLabel"] = function(Label)
				if Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
				end
			end,
			["TextButton"] = function(Label)
				if Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				end
			end,
			["ScrollingFrame"] = function(Label)
				Label.ScrollBarImageColor3 = Theme.Component
			end,
		},
	}
	function Options:SetTheme(Info)
		-- Update internal Theme reference
		if type(Info) == "table" then
			Theme = Info
		elseif type(Info) == "string" and ThemesDefinitions[Info] then
			Setup.ThemeMode = Info
			Theme = ThemesDefinitions[Info]
		else
			Theme = ThemesDefinitions.Dark
		end

		-- Apply theme colors
		Window.BackgroundColor3 = Theme.Primary
		Holder.BackgroundColor3 = Theme.Secondary
		Window.UIStroke.Color = Theme.Shadow
		for Index, Descendant in next, Screen:GetDescendants() do
			local Name, Class =  Themes.Names[Descendant.Name],  Themes.Classes[Descendant.ClassName]
			if Name then
				Name(Descendant);
			elseif Class then
				Class(Descendant);
			end
		end
	end
	--// Changing Settings
	function Options:SetSetting(Setting, Value) --// Available settings - Size, Transparency, Blur, Theme
		if Setting == "Size" then
			Window.Size = Value
			Setup.Size = Value
		elseif Setting == "Transparency" then
			Window.GroupTransparency = Value
			Setup.Transparency = Value
			for Index, Notification in next, Screen:GetDescendants() do
				if Notification:IsA("CanvasGroup") and Notification.Name == "Notification" then
					Notification.GroupTransparency = Value
				end
			end
		elseif Setting == "Blur" then
			local blurFrame = InternalBlurs[Settings.Title]
			if Value and not blurFrame then
				-- Créer le flou si activé et non existant
				InternalBlurs[Settings.Title] = CreateInternalBlur(Window)
				BlurEnabled = true
				-- Afficher si la fenêtre est ouverte ET l'UI est visible
				if Opened and IsUIVisible then
					InternalBlurs[Settings.Title].Visible = true
				end
			elseif Value and blurFrame then
				-- Activer le flou existant
				blurFrame.Visible = Opened and IsUIVisible -- Visible seulement si la fenêtre est ouverte et l'UI visible
				BlurEnabled = true
			elseif not Value and blurFrame then
				-- Désactiver et cacher le flou
				blurFrame.Visible = false
				BlurEnabled = false
			end
		elseif Setting == "Theme" then -- Accepter une table ou une string
			Options:SetTheme(Value)
		elseif Setting == "Keybind" then
			Setup.Keybind = Value
		else
			warn("Tried to change a setting that doesn't exist or isn't available to change.")
		end
	end
	--// Nouvelle fonction pour basculer l'UI
	function Options:ToggleUI()
		ToggleUIVisibility()
	end
	SetProperty(Window, { Size = Settings.Size, Visible = true, Parent = Screen });
	Animations:Open(Window, Settings.Transparency or 0)

	-- Apply initial theme after window is set up
	Options:SetTheme(Setup.ThemeMode or Settings.Theme)

	return Options
end
return Library
