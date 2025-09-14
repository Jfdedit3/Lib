--[[
	User Interface Library - Version Réinventée
	Par Late, modifié et réécrit
]]
--// Services & Initialisation
local GetService = game.GetService
local Connect = game.Loaded.Connect
local Wait = game.Loaded.Wait
local Clone = game.Clone
local Destroy = game.Destroy

if not game:IsLoaded() then
	game.Loaded:Wait()
end

--// Configuration Principale
local Setup = {
	Keybind = Enum.KeyCode.RightShift, -- Touche par défaut pour basculer la visibilité
	Transparency = 0, -- Transparence par défaut
	ThemeMode = "Dark", -- Thème par défaut
	Size = UDim2.new(0, 500, 0, 350), -- Taille par défaut
	MinSize = Vector2.new(300, 250), -- Taille minimale
	MaxSize = Vector2.new(1920, 1080), -- Taille maximale
}

--// Définitions des Thèmes
local ThemesDefinitions = {
	--// Thème Sombre (Dark)
	Dark = {
		Name = "Dark",
		--// Couleurs Principales
		Primary = Color3.fromRGB(25, 25, 25), -- Fond principal
		Secondary = Color3.fromRGB(35, 35, 35), -- Fond secondaire (contenu)
		Component = Color3.fromRGB(45, 45, 45), -- Fond des composants
		Interactables = Color3.fromRGB(55, 55, 55), -- Éléments interactifs (hover)
		Accent = Color3.fromRGB(80, 180, 255), -- Couleur d'accentuation
		--// Textes
		TextPrimary = Color3.fromRGB(240, 240, 240), -- Texte principal
		TextSecondary = Color3.fromRGB(200, 200, 200), -- Texte secondaire/description
		TextMuted = Color3.fromRGB(150, 150, 150), -- Texte atténué
		--// Contours et Ombres
		Border = Color3.fromRGB(60, 60, 60), -- Couleur des bordures
		Shadow = Color3.fromRGB(0, 0, 0), -- Couleur de l'ombre
		--// Images/Icones
		Icon = Color3.fromRGB(220, 220, 220), -- Couleur des icônes
	},
	--// Thème Clair (Light)
	Light = {
		Name = "Light",
		Primary = Color3.fromRGB(240, 240, 240),
		Secondary = Color3.fromRGB(255, 255, 255),
		Component = Color3.fromRGB(230, 230, 230),
		Interactables = Color3.fromRGB(220, 220, 220),
		Accent = Color3.fromRGB(30, 144, 255),
		TextPrimary = Color3.fromRGB(20, 20, 20),
		TextSecondary = Color3.fromRGB(60, 60, 60),
		TextMuted = Color3.fromRGB(120, 120, 120),
		Border = Color3.fromRGB(200, 200, 200),
		Shadow = Color3.fromRGB(200, 200, 200),
		Icon = Color3.fromRGB(80, 80, 80),
	},
	--// Thème Violet (Purple)
	Purple = {
		Name = "Purple",
		Primary = Color3.fromRGB(40, 10, 55),
		Secondary = Color3.fromRGB(50, 20, 70),
		Component = Color3.fromRGB(70, 35, 95),
		Interactables = Color3.fromRGB(90, 55, 120),
		Accent = Color3.fromRGB(180, 120, 255),
		TextPrimary = Color3.fromRGB(240, 220, 255),
		TextSecondary = Color3.fromRGB(210, 190, 240),
		TextMuted = Color3.fromRGB(180, 160, 210),
		Border = Color3.fromRGB(100, 70, 130),
		Shadow = Color3.fromRGB(0, 0, 0),
		Icon = Color3.fromRGB(220, 200, 255),
	},
	--// Thème Sombre Extrême (Void)
	Void = {
		Name = "Void",
		Primary = Color3.fromRGB(10, 10, 10),
		Secondary = Color3.fromRGB(20, 20, 20),
		Component = Color3.fromRGB(30, 30, 30),
		Interactables = Color3.fromRGB(40, 40, 40),
		Accent = Color3.fromRGB(100, 100, 255),
		TextPrimary = Color3.fromRGB(230, 230, 230),
		TextSecondary = Color3.fromRGB(190, 190, 190),
		TextMuted = Color3.fromRGB(150, 150, 150),
		Border = Color3.fromRGB(50, 50, 50),
		Shadow = Color3.fromRGB(0, 0, 0),
		Icon = Color3.fromRGB(200, 200, 200),
	}
}

--// Initialisation du Thème Actif
local Theme = ThemesDefinitions[Setup.ThemeMode] or ThemesDefinitions.Dark

--// Services Roblox
local LocalPlayer = GetService(game, "Players").LocalPlayer;
local Services = {
	Insert = GetService(game, "InsertService");
	Tween = GetService(game, "TweenService");
	Run = GetService(game, "RunService");
	Input = GetService(game, "UserInputService");
	-- ThumbnailService n'est pas utilisé ici
}

--// Raccourcis
local Player = {
	Mouse = LocalPlayer:GetMouse();
	GUI = LocalPlayer.PlayerGui;
}

--// Fonctions Utilitaires
local Tween = function(Object : Instance, Speed : number, Properties : {}, Info : { EasingStyle: Enum?, EasingDirection: Enum? })
	local Style = Info and Info.EasingStyle or Enum.EasingStyle.Quad
	local Direction = Info and Info.EasingDirection or Enum.EasingDirection.Out
	return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end

local SetProperty = function(Object: Instance, Properties: {})
	for Index, Property in next, Properties do
		Object[Index] = Property
	end
	return Object
end

local Multiply = function(Value, Amount)
	return UDim2.new(Value.X.Scale * Amount, Value.X.Offset * Amount, Value.Y.Scale * Amount, Value.Y.Offset * Amount)
end

--// Fonctionnalités UI
local DraggingElement = nil
local ResizeHandle = nil

local function StartDrag(Window)
	local DragInput
	local StartPosition
	local StartMousePos

	local function UpdatePosition(input)
		local delta = input.Position - StartMousePos
		Window.Position = UDim2.new(StartPosition.X.Scale, Position.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
	end

	Connect(Window.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not DraggingElement and not ResizeHandle then
			DraggingElement = Window
			StartMousePos = input.Position
			StartPosition = Window.Position

			Connect(input.Changed, function()
				if input.UserInputState == Enum.UserInputState.End then
					DraggingElement = nil
				end
			end)
		end
	end)

	Connect(Window.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and DraggingElement == Window then
			DragInput = input
		end
	end)

	Connect(Services.Input.InputChanged, function(input)
		if input == DragInput and DraggingElement == Window then
			UpdatePosition(input)
		end
	end)
end

local ResizeDirections = {
	TopLeft = { X = Vector2.new(-1, 0), Y = Vector2.new(0, -1) };
	TopRight = { X = Vector2.new(1, 0), Y = Vector2.new(0, -1) };
	BottomLeft = { X = Vector2.new(-1, 0), Y = Vector2.new(0, 1) };
	BottomRight = { X = Vector2.new(1, 0), Y = Vector2.new(0, 1) };
}

local function MakeResizable(Window)
	task.spawn(function()
		local MousePos, Size, UIPos = nil, nil, nil
		if Window and Window:FindFirstChild("ResizeHandles") then
			local Handles = Window:FindFirstChild("ResizeHandles")
			for _, Handle in next, Handles:GetChildren() do
				Connect(Handle.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						ResizeHandle = Handle
						MousePos = Vector2.new(Player.Mouse.X, Player.Mouse.Y)
						Size = Window.AbsoluteSize
						UIPos = Window.Position
					end
				end)
				Connect(Handle.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						ResizeHandle = nil
					end
				end)
			end
		end

		local function Resize(Delta)
			if ResizeHandle and MousePos and Size and UIPos and Window:FindFirstChild("ResizeHandles")[ResizeHandle.Name] == ResizeHandle then
				local Mode = ResizeDirections[ResizeHandle.Name]
				if not Mode then return end

				local NewSize = Vector2.new(Size.X + Delta.X * Mode.X.X, Size.Y + Delta.Y * Mode.Y.Y)
				NewSize = Vector2.new(math.clamp(NewSize.X, Setup.MinSize.X, Setup.MaxSize.X), math.clamp(NewSize.Y, Setup.MinSize.Y, Setup.MaxSize.Y))

				local AnchorOffset = Vector2.new(Window.AnchorPoint.X * Size.X, Window.AnchorPoint.Y * Size.Y)
				local NewAnchorOffset = Vector2.new(Window.AnchorPoint.X * NewSize.X, Window.AnchorPoint.Y * NewSize.Y)
				local DeltaAnchorOffset = NewAnchorOffset - AnchorOffset

				Window.Size = UDim2.new(0, NewSize.X, 0, NewSize.Y)
				local NewPosition = UDim2.new(
					UIPos.X.Scale,
					UIPos.X.Offset + DeltaAnchorOffset.X * Mode.X.X,
					UIPos.Y.Scale,
					UIPos.Y.Offset + DeltaAnchorOffset.Y * Mode.Y.Y
				)
				Window.Position = NewPosition
			end
		end

		Connect(Player.Mouse.Move, function()
			if ResizeHandle then
				Resize(Vector2.new(Player.Mouse.X, Player.Mouse.Y) - MousePos)
			end
		end)
	end)
end

--// Fonction de Flou Interne
local function CreateInternalBlur(ParentWindow)
	local BlurFrame = Instance.new("Frame")
	BlurFrame.Name = "InternalBlurOverlay"
	BlurFrame.Size = UDim2.new(1, 0, 1, 0)
	BlurFrame.Position = UDim2.new(0, 0, 0, 0)
	BlurFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	BlurFrame.BackgroundTransparency = 0.6
	BlurFrame.BorderSizePixel = 0
	BlurFrame.ZIndex = 1000
	BlurFrame.Visible = false
	BlurFrame.Parent = ParentWindow
	return BlurFrame
end

--// Configuration de l'UI
local Screen
if identifyexecutor then
	Screen = Services.Insert:LoadLocalAsset("rbxassetid://18490507748"); -- ID d'asset par défaut si nécessaire
else
	Screen = script.Parent
end

-- Création de l'UI principale si elle n'existe pas
if not Screen:FindFirstChild("Main") then
	local MainFrame = Instance.new("ScreenGui")
	MainFrame.Name = "UI_Library_Main"
	MainFrame.ResetOnSpawn = false
	MainFrame.Parent = Screen
	Screen = MainFrame
end

--// Tables pour les Données
local Animations = {}
local InternalBlurs = {}
local Components = Instance.new("Folder")
Components.Name = "UI_Components"
Components.Parent = Screen

-- Création des composants de base dans `Components` (simplifié ici, normalement chargé depuis un asset)
-- Pour cet exemple, nous les créons dynamiquement
local function CreateBaseComponents()
	local Notification = Instance.new("CanvasGroup")
	Notification.Name = "Notification"
	Notification.Size = UDim2.new(0, 300, 0, 80)
	Notification.Position = UDim2.new(0.5, -150, 1, 10)
	Notification.AnchorPoint = Vector2.new(0.5, 0)
	Notification.BackgroundTransparency = 1
	Notification.GroupTransparency = 1
	Notification.Visible = true

	local NotificationBG = Instance.new("Frame")
	NotificationBG.Name = "Background"
	NotificationBG.Size = UDim2.new(1, 0, 1, 0)
	NotificationBG.Position = UDim2.new(0, 0, 0, 0)
	NotificationBG.BorderSizePixel = 0
	NotificationBG.Parent = Notification

	local NotificationStroke = Instance.new("UIStroke")
	NotificationStroke.Name = "Stroke"
	NotificationStroke.Thickness = 1
	NotificationStroke.Parent = NotificationBG

	local NotificationLabels = Instance.new("Frame")
	NotificationLabels.Name = "Labels"
	NotificationLabels.Size = UDim2.new(1, -20, 1, -20)
	NotificationLabels.Position = UDim2.new(0, 10, 0, 10)
	NotificationLabels.BackgroundTransparency = 1
	NotificationLabels.Parent = Notification

	local NotificationTitle = Instance.new("TextLabel")
	NotificationTitle.Name = "Title"
	NotificationTitle.Size = UDim2.new(1, 0, 0, 20)
	NotificationTitle.Position = UDim2.new(0, 0, 0, 0)
	NotificationTitle.BackgroundTransparency = 1
	NotificationTitle.Font = Enum.Font.GothamBold
	NotificationTitle.TextSize = 16
	NotificationTitle.TextXAlignment = Enum.TextXAlignment.Left
	NotificationTitle.TextYAlignment = Enum.TextYAlignment.Top
	NotificationTitle.Parent = NotificationLabels

	local NotificationDesc = Instance.new("TextLabel")
	NotificationDesc.Name = "Description"
	NotificationDesc.Size = UDim2.new(1, 0, 1, -25)
	NotificationDesc.Position = UDim2.new(0, 0, 0, 25)
	NotificationDesc.BackgroundTransparency = 1
	NotificationDesc.Font = Enum.Font.Gotham
	NotificationDesc.TextSize = 14
	NotificationDesc.TextWrapped = true
	NotificationDesc.TextXAlignment = Enum.TextXAlignment.Left
	NotificationDesc.TextYAlignment = Enum.TextYAlignment.Top
	NotificationDesc.Parent = NotificationLabels

	local NotificationTimer = Instance.new("Frame")
	NotificationTimer.Name = "Timer"
	NotificationTimer.Size = UDim2.new(1, -4, 0, 3)
	NotificationTimer.Position = UDim2.new(0, 2, 1, -5)
	NotificationTimer.AnchorPoint = Vector2.new(0, 1)
	NotificationTimer.BorderSizePixel = 0
	NotificationTimer.Parent = Notification

	Notification.Parent = Components
end
CreateBaseComponents()

local Library = {};
local StoredInfo = {
	["Sections"] = {};
	["Tabs"] = {};
	["Windows"] = {};
}

--// Animations [Fenêtre & Notifications]
function Animations:OpenWindow(Window: Frame, Transparency: number)
	local OriginalSize = Window.Size
	local EnlargedSize = Multiply(OriginalSize, 1.05)
	local Shadow = Window:FindFirstChild("DropShadow") or Window:FindFirstChildOfClass("UIStroke")

	SetProperty(Window, { Size = EnlargedSize, Visible = true })
	if Shadow then SetProperty(Shadow, { Transparency = 1 }) end

	Tween(Window, 0.2, { Size = OriginalSize })
	if Shadow then Tween(Shadow, 0.2, { Transparency = 0.5 }) end
	Tween(Window, 0.2, { BackgroundTransparency = Transparency or 0 })
end

function Animations:CloseWindow(Window: Frame)
	local OriginalSize = Window.Size
	local EnlargedSize = Multiply(OriginalSize, 1.05)
	local Shadow = Window:FindFirstChild("DropShadow") or Window:FindFirstChildOfClass("UIStroke")

	Tween(Window, 0.2, { Size = EnlargedSize, BackgroundTransparency = 1 })
	if Shadow then Tween(Shadow, 0.2, { Transparency = 1 }) end

	task.delay(0.2, function()
		Window.Visible = false
		Window.Size = OriginalSize
	end)
end

function Animations:Hover(Component: GuiObject, ThemeRef)
	Connect(Component.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			Tween(Component, 0.15, { BackgroundColor3 = ThemeRef.Interactables })
		end
	end)
	Connect(Component.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			Tween(Component, 0.15, { BackgroundColor3 = ThemeRef.Component })
		end
	end)
end

function Animations:OpenNotification(Notification: CanvasGroup, Transparency: number)
	local OriginalPos = Notification.Position
	local HiddenPos = UDim2.new(0.5, -150, 1, 10)
	local VisiblePos = UDim2.new(0.5, -150, 1, -10)

	SetProperty(Notification, { Position = HiddenPos, Visible = true, GroupTransparency = 1 })
	Tween(Notification, 0.3, { Position = VisiblePos, GroupTransparency = Transparency or 0 })
end

function Animations:CloseNotification(Notification: CanvasGroup)
	local VisiblePos = Notification.Position
	local HiddenPos = UDim2.new(0.5, -150, 1, 10)

	Tween(Notification, 0.3, { Position = HiddenPos, GroupTransparency = 1 })
	task.delay(0.3, function()
		Notification.Visible = false
		Notification.Position = VisiblePos
	end)
end

--// Fonctions Principales de la Bibliothèque
function Library:CreateWindow(Settings: { Title: string, Size: UDim2?, Transparency: number?, MinimizeKeybind: Enum.KeyCode?, Blurring: boolean?, Theme: string? })
	local WindowContainer = Instance.new("ScreenGui")
	WindowContainer.Name = "UI_Window_" .. (Settings.Title or "Untitled")
	WindowContainer.ResetOnSpawn = false
	WindowContainer.Parent = Screen

	local Window = Instance.new("Frame")
	Window.Name = "MainWindow"
	Window.Size = Settings.Size or Setup.Size
	Window.Position = UDim2.new(0.5, -(Window.Size.X.Offset/2), 0.5, -(Window.Size.Y.Offset/2))
	Window.AnchorPoint = Vector2.new(0.5, 0.5)
	Window.BackgroundTransparency = 1
	Window.BorderSizePixel = 0
	Window.Active = true
	Window.Draggable = false -- Géré manuellement
	Window.Parent = WindowContainer

	local WindowBG = Instance.new("Frame")
	WindowBG.Name = "Background"
	WindowBG.Size = UDim2.new(1, 0, 1, 0)
	WindowBG.Position = UDim2.new(0, 0, 0, 0)
	WindowBG.BorderSizePixel = 0
	WindowBG.Parent = Window

	local WindowStroke = Instance.new("UIStroke")
	WindowStroke.Name = "Stroke"
	WindowStroke.Thickness = 1
	WindowStroke.Parent = WindowBG

	local WindowShadow = Instance.new("Frame")
	WindowShadow.Name = "DropShadow"
	WindowShadow.Size = UDim2.new(1, 6, 1, 6)
	WindowShadow.Position = UDim2.new(0, -3, 0, 3)
	WindowShadow.BackgroundTransparency = 0.5
	WindowShadow.BorderSizePixel = 0
	WindowShadow.ZIndex = 0
	WindowShadow.Parent = Window

	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, 30)
	TopBar.Position = UDim2.new(0, 0, 0, 0)
	TopBar.BackgroundTransparency = 1
	TopBar.BorderSizePixel = 0
	TopBar.Parent = Window

	local TopBarBG = Instance.new("Frame")
	TopBarBG.Name = "Background"
	TopBarBG.Size = UDim2.new(1, 0, 1, 0)
	TopBarBG.Position = UDim2.new(0, 0, 0, 0)
	TopBarBG.BorderSizePixel = 0
	TopBarBG.Parent = TopBar

	local TopBarStroke = Instance.new("UIStroke")
	TopBarStroke.Name = "Stroke"
	TopBarStroke.Thickness = 1
	TopBarStroke.Parent = TopBarBG

	local WindowTitle = Instance.new("TextLabel")
	WindowTitle.Name = "Title"
	WindowTitle.Size = UDim2.new(1, -100, 1, 0)
	WindowTitle.Position = UDim2.new(0, 10, 0, 0)
	WindowTitle.BackgroundTransparency = 1
	WindowTitle.Font = Enum.Font.GothamBold
	WindowTitle.TextSize = 16
	WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
	WindowTitle.TextYAlignment = Enum.TextYAlignment.Center
	WindowTitle.Text = Settings.Title or "UI Window"
	WindowTitle.Parent = TopBar

	local WindowButtons = Instance.new("Frame")
	WindowButtons.Name = "Buttons"
	WindowButtons.Size = UDim2.new(0, 90, 1, 0)
	WindowButtons.Position = UDim2.new(1, -95, 0, 0)
	WindowButtons.BackgroundTransparency = 1
	WindowButtons.Parent = TopBar

	local MinimizeButton = Instance.new("TextButton")
	MinimizeButton.Name = "Minimize"
	MinimizeButton.Size = UDim2.new(0, 25, 1, -10)
	MinimizeButton.Position = UDim2.new(0, 5, 0, 5)
	MinimizeButton.Text = "_"
	MinimizeButton.Font = Enum.Font.GothamBold
	MinimizeButton.TextSize = 18
	MinimizeButton.TextColor3 = Theme.TextPrimary
	MinimizeButton.BackgroundTransparency = 0.5
	MinimizeButton.BorderSizePixel = 0
	MinimizeButton.Parent = WindowButtons

	local MaximizeButton = Instance.new("TextButton")
	MaximizeButton.Name = "Maximize"
	MaximizeButton.Size = UDim2.new(0, 25, 1, -10)
	MaximizeButton.Position = UDim2.new(0, 35, 0, 5)
	MaximizeButton.Text = "□"
	MaximizeButton.Font = Enum.Font.GothamBold
	MaximizeButton.TextSize = 14
	MaximizeButton.TextColor3 = Theme.TextPrimary
	MaximizeButton.BackgroundTransparency = 0.5
	MaximizeButton.BorderSizePixel = 0
	MaximizeButton.Parent = WindowButtons

	local CloseButton = Instance.new("TextButton")
	CloseButton.Name = "Close"
	CloseButton.Size = UDim2.new(0, 25, 1, -10)
	CloseButton.Position = UDim2.new(0, 65, 0, 5)
	CloseButton.Text = "X"
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.TextSize = 14
	CloseButton.TextColor3 = Theme.TextPrimary
	CloseButton.BackgroundTransparency = 0.5
	CloseButton.BorderSizePixel = 0
	CloseButton.Parent = WindowButtons

	-- Appliquer le thème initial
	local function ApplyTheme(theme)
		WindowBG.BackgroundColor3 = theme.Primary
		WindowStroke.Color = theme.Border
		WindowShadow.BackgroundColor3 = theme.Shadow
		TopBarBG.BackgroundColor3 = theme.Secondary
		TopBarStroke.Color = theme.Border
		WindowTitle.TextColor3 = theme.TextPrimary
		MinimizeButton.TextColor3 = theme.TextPrimary
		MaximizeButton.TextColor3 = theme.TextPrimary
		CloseButton.TextColor3 = theme.TextPrimary
		MinimizeButton.BackgroundColor3 = theme.Component
		MaximizeButton.BackgroundColor3 = theme.Component
		CloseButton.BackgroundColor3 = theme.Component
	end
	ApplyTheme(Theme)

	-- Ajouter des effets hover aux boutons
	Animations:Hover(MinimizeButton, Theme)
	Animations:Hover(MaximizeButton, Theme)
	Animations:Hover(CloseButton, Theme)

	local ContentArea = Instance.new("Frame")
	ContentArea.Name = "ContentArea"
	ContentArea.Size = UDim2.new(1, -20, 1, -50)
	ContentArea.Position = UDim2.new(0, 10, 0, 40)
	ContentArea.BackgroundTransparency = 1
	ContentArea.ClipsDescendants = true
	ContentArea.Parent = Window

	local TabHolder = Instance.new("Frame")
	TabHolder.Name = "TabHolder"
	TabHolder.Size = UDim2.new(0, 120, 1, 0)
	TabHolder.Position = UDim2.new(0, 0, 0, 0)
	TabHolder.BackgroundTransparency = 1
	TabHolder.Parent = ContentArea

	local TabList = Instance.new("ScrollingFrame")
	TabList.Name = "TabList"
	TabList.Size = UDim2.new(1, -10, 1, 0)
	TabList.Position = UDim2.new(0, 5, 0, 0)
	TabList.BackgroundTransparency = 1
	TabList.BorderSizePixel = 0
	TabList.ScrollBarThickness = 4
	TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabList.Parent = TabHolder

	local TabListPadding = Instance.new("UIPadding")
	TabListPadding.PaddingTop = UDim.new(0, 5)
	TabListPadding.PaddingBottom = UDim.new(0, 5)
	TabListPadding.Parent = TabList

	local TabListLayout = Instance.new("UIListLayout")
	TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabListLayout.Padding = UDim.new(0, 5)
	TabListLayout.Parent = TabList

	local MainContent = Instance.new("Frame")
	MainContent.Name = "MainContent"
	MainContent.Size = UDim2.new(1, -130, 1, 0)
	MainContent.Position = UDim2.new(0, 130, 0, 0)
	MainContent.BackgroundTransparency = 1
	MainContent.Parent = ContentArea

	local MainContentBG = Instance.new("Frame")
	MainContentBG.Name = "Background"
	MainContentBG.Size = UDim2.new(1, 0, 1, 0)
	MainContentBG.Position = UDim2.new(0, 0, 0, 0)
	MainContentBG.BackgroundTransparency = 1
	MainContentBG.BorderSizePixel = 0
	MainContentBG.Parent = MainContent

	local MainContentStroke = Instance.new("UIStroke")
	MainContentStroke.Name = "Stroke"
	MainContentStroke.Thickness = 1
	MainContentStroke.Parent = MainContentBG

	local MainScrollingFrame = Instance.new("ScrollingFrame")
	MainScrollingFrame.Name = "ScrollingContent"
	MainScrollingFrame.Size = UDim2.new(1, -20, 1, -20)
	MainScrollingFrame.Position = UDim2.new(0, 10, 0, 10)
	MainScrollingFrame.BackgroundTransparency = 1
	MainScrollingFrame.BorderSizePixel = 0
	MainScrollingFrame.ScrollBarThickness = 6
	MainScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	MainScrollingFrame.Parent = MainContent

	local MainContentLayout = Instance.new("UIListLayout")
	MainContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	MainContentLayout.Padding = UDim.new(0, 10)
	MainContentLayout.Parent = MainScrollingFrame

	local MainContentPadding = Instance.new("UIPadding")
	MainContentPadding.PaddingTop = UDim.new(0, 10)
	MainContentPadding.PaddingBottom = UDim.new(0, 10)
	MainContentPadding.Parent = MainScrollingFrame

	-- Resize Handles
	local ResizeHandles = Instance.new("Folder")
	ResizeHandles.Name = "ResizeHandles"
	ResizeHandles.Parent = Window

	local HandleSize = 10
	for name, _ in pairs(ResizeDirections) do
		local handle = Instance.new("TextButton")
		handle.Name = name
		handle.Text = ""
		handle.BackgroundTransparency = 1
		handle.BorderSizePixel = 0
		handle.ZIndex = 10
		if name == "TopLeft" then
			handle.Size = UDim2.new(0, HandleSize, 0, HandleSize)
			handle.Position = UDim2.new(0, 0, 0, 0)
		elseif name == "TopRight" then
			handle.Size = UDim2.new(0, HandleSize, 0, HandleSize)
			handle.Position = UDim2.new(1, -HandleSize, 0, 0)
		elseif name == "BottomLeft" then
			handle.Size = UDim2.new(0, HandleSize, 0, HandleSize)
			handle.Position = UDim2.new(0, 0, 1, -HandleSize)
		elseif name == "BottomRight" then
			handle.Size = UDim2.new(0, HandleSize, 0, HandleSize)
			handle.Position = UDim2.new(1, -HandleSize, 1, -HandleSize)
		end
		handle.Parent = ResizeHandles
	end

	-- Internal Blur
	local BlurEnabled = Settings.Blurring or false
	local InternalBlurInstance = nil
	if BlurEnabled then
		InternalBlurInstance = CreateInternalBlur(Window)
		InternalBlurs[Settings.Title or "Untitled"] = InternalBlurInstance
	end

	-- Setup
	local WindowOptions = {}
	local IsOpen = true
	local IsMaximized = false
	local OriginalWindowSize = Window.Size
	local OriginalWindowPosition = Window.Position

	-- Drag & Resize
	StartDrag(Window)
	MakeResizable(Window)

	-- Button Logic
	Connect(MinimizeButton.MouseButton1Click, function()
		IsOpen = not IsOpen
		if IsOpen then
			Window.Visible = true
			Animations:OpenWindow(Window, Setup.Transparency)
			if BlurEnabled and InternalBlurInstance then
				InternalBlurInstance.Visible = true
			end
		else
			Animations:CloseWindow(Window)
			if BlurEnabled and InternalBlurInstance then
				InternalBlurInstance.Visible = false
			end
		end
	end)

	Connect(MaximizeButton.MouseButton1Click, function()
		IsMaximized = not IsMaximized
		if IsMaximized then
			OriginalWindowSize = Window.Size
			OriginalWindowPosition = Window.Position
			Tween(Window, 0.2, { Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10) })
		else
			Tween(Window, 0.2, { Size = OriginalWindowSize, Position = OriginalWindowPosition })
		end
	end)

	Connect(CloseButton.MouseButton1Click, function()
		Animations:CloseWindow(Window)
		if BlurEnabled and InternalBlurInstance then
			InternalBlurInstance.Visible = false
		end
		task.delay(0.3, function()
			WindowContainer:Destroy()
		end)
	end)

	-- Keybind Toggle
	local ToggleKey = Settings.MinimizeKeybind or Setup.Keybind
	Services.Input.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == ToggleKey then
			IsOpen = not IsOpen
			if IsOpen then
				Window.Visible = true
				Animations:OpenWindow(Window, Setup.Transparency)
				if BlurEnabled and InternalBlurInstance then InternalBlurInstance.Visible = true end
			else
				Animations:CloseWindow(Window)
				if BlurEnabled and InternalBlurInstance then InternalBlurInstance.Visible = false end
			end
		end
	end)

	-- Tab Logic
	local ActiveTab = nil
	function WindowOptions:SetTab(tabName)
		for _, tabButton in ipairs(TabList:GetChildren()) do
			if tabButton:IsA("TextButton") and tabButton.Name == tabName then
				tabButton.BackgroundTransparency = 0.2
				tabButton.TextColor3 = Theme.Accent
			else
				tabButton.BackgroundTransparency = 0.7
				tabButton.TextColor3 = Theme.TextSecondary
			end
		end

		for _, tabContent in ipairs(MainScrollingFrame:GetChildren()) do
			if tabContent:IsA("Frame") and tabContent.Name == tabName then
				tabContent.Visible = true
			else
				tabContent.Visible = false
			end
		end
		ActiveTab = tabName
	end

	function WindowOptions:AddTab(tabSettings)
		local tabName = tabSettings.Title or "Tab"
		local tabIcon = tabSettings.Icon -- Optionnel

		local tabButton = Instance.new("TextButton")
		tabButton.Name = tabName
		tabButton.Size = UDim2.new(1, -10, 0, 30)
		tabButton.Position = UDim2.new(0, 5, 0, 0) -- Will be handled by ListLayout
		tabButton.Text = tabName
		tabButton.Font = Enum.Font.Gotham
		tabButton.TextSize = 14
		tabButton.TextColor3 = Theme.TextSecondary
		tabButton.BackgroundTransparency = 0.7
		tabButton.BorderSizePixel = 0
		tabButton.LayoutOrder = #TabList:GetChildren()
		tabButton.Parent = TabList

		Animations:Hover(tabButton, Theme)

		Connect(tabButton.MouseButton1Click, function()
			WindowOptions:SetTab(tabName)
		end)

		local tabContent = Instance.new("Frame")
		tabContent.Name = tabName
		tabContent.Size = UDim2.new(1, 0, 0, 10) -- Will expand with content
		tabContent.BackgroundTransparency = 1
		tabContent.Visible = false
		tabContent.Parent = MainScrollingFrame

		local tabLayout = Instance.new("UIListLayout")
		tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabLayout.Padding = UDim.new(0, 10)
		tabLayout.Parent = tabContent

		Connect(tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			tabContent.Size = UDim2.new(1, 0, 0, tabLayout.AbsoluteContentSize.Y + 20)
			MainScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, MainContentLayout.AbsoluteContentSize.Y + 20)
		end)

		-- Set first tab as active
		if #TabList:GetChildren() == 1 then
			WindowOptions:SetTab(tabName)
		end

		return tabContent
	end

	-- Component Functions
	function WindowOptions:AddSection(sectionSettings)
		local parentTab = sectionSettings.Tab
		if not parentTab then return end

		local sectionFrame = Instance.new("Frame")
		sectionFrame.Name = "Section_" .. (sectionSettings.Name or "Unnamed")
		sectionFrame.Size = UDim2.new(1, 0, 0, 30)
		sectionFrame.BackgroundTransparency = 1
		sectionFrame.LayoutOrder = #parentTab:GetChildren()
		sectionFrame.Parent = parentTab

		local sectionLabel = Instance.new("TextLabel")
		sectionLabel.Name = "Label"
		sectionLabel.Size = UDim2.new(1, 0, 1, 0)
		sectionLabel.BackgroundTransparency = 1
		sectionLabel.Font = Enum.Font.GothamSemibold
		sectionLabel.TextSize = 16
		sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
		sectionLabel.TextColor3 = Theme.TextPrimary
		sectionLabel.Text = sectionSettings.Name or "Section"
		sectionLabel.Parent = sectionFrame

		local underline = Instance.new("Frame")
		underline.Name = "Underline"
		underline.Size = UDim2.new(1, 0, 0, 1)
		underline.Position = UDim2.new(0, 0, 1, -1)
		underline.BackgroundColor3 = Theme.Accent
		underline.BorderSizePixel = 0
		underline.Parent = sectionFrame
	end

	function WindowOptions:AddButton(buttonSettings)
		local parentTab = buttonSettings.Tab
		if not parentTab then return end

		local buttonFrame = Instance.new("TextButton")
		buttonFrame.Name = "Button_" .. (buttonSettings.Title or "Unnamed")
		buttonFrame.Size = UDim2.new(1, 0, 0, 40)
		buttonFrame.BackgroundTransparency = 0.3
		buttonFrame.BackgroundColor3 = Theme.Component
		buttonFrame.BorderSizePixel = 0
		buttonFrame.LayoutOrder = #parentTab:GetChildren()
		buttonFrame.Parent = parentTab

		local buttonStroke = Instance.new("UIStroke")
		buttonStroke.Thickness = 1
		buttonStroke.Color = Theme.Border
		buttonStroke.Parent = buttonFrame

		local buttonText = Instance.new("TextLabel")
		buttonText.Name = "Text"
		buttonText.Size = UDim2.new(1, -20, 1, 0)
		buttonText.Position = UDim2.new(0, 10, 0, 0)
		buttonText.BackgroundTransparency = 1
		buttonText.Font = Enum.Font.Gotham
		buttonText.TextSize = 15
		buttonText.TextXAlignment = Enum.TextXAlignment.Left
		buttonText.TextColor3 = Theme.TextPrimary
		buttonText.Text = buttonSettings.Title or "Button"
		buttonText.Parent = buttonFrame

		local buttonDesc = Instance.new("TextLabel")
		buttonDesc.Name = "Description"
		buttonDesc.Size = UDim2.new(1, -20, 0, 15)
		buttonDesc.Position = UDim2.new(0, 10, 1, -18)
		buttonDesc.BackgroundTransparency = 1
		buttonDesc.Font = Enum.Font.Gotham
		buttonDesc.TextSize = 12
		buttonDesc.TextXAlignment = Enum.TextXAlignment.Left
		buttonDesc.TextColor3 = Theme.TextMuted
		buttonDesc.Text = buttonSettings.Description or ""
		buttonDesc.Parent = buttonFrame

		Animations:Hover(buttonFrame, Theme)

		Connect(buttonFrame.MouseButton1Click, function()
			if buttonSettings.Callback then
				buttonSettings.Callback()
			end
		end)
	end

	function WindowOptions:AddToggle(toggleSettings)
		local parentTab = toggleSettings.Tab
		if not parentTab then return end

		local toggleFrame = Instance.new("Frame")
		toggleFrame.Name = "Toggle_" .. (toggleSettings.Title or "Unnamed")
		toggleFrame.Size = UDim2.new(1, 0, 0, 40)
		toggleFrame.BackgroundTransparency = 1
		toggleFrame.LayoutOrder = #parentTab:GetChildren()
		toggleFrame.Parent = parentTab

		local toggleTitle = Instance.new("TextLabel")
		toggleTitle.Name = "Title"
		toggleTitle.Size = UDim2.new(0.7, 0, 1, 0)
		toggleTitle.BackgroundTransparency = 1
		toggleTitle.Font = Enum.Font.Gotham
		toggleTitle.TextSize = 15
		toggleTitle.TextXAlignment = Enum.TextXAlignment.Left
		toggleTitle.TextColor3 = Theme.TextPrimary
		toggleTitle.Text = toggleSettings.Title or "Toggle"
		toggleTitle.Parent = toggleFrame

		local toggleDesc = Instance.new("TextLabel")
		toggleDesc.Name = "Description"
		toggleDesc.Size = UDim2.new(0.7, 0, 0, 15)
		toggleDesc.Position = UDim2.new(0, 0, 1, -18)
		toggleDesc.BackgroundTransparency = 1
		toggleDesc.Font = Enum.Font.Gotham
		toggleDesc.TextSize = 12
		toggleDesc.TextXAlignment = Enum.TextXAlignment.Left
		toggleDesc.TextColor3 = Theme.TextMuted
		toggleDesc.Text = toggleSettings.Description or ""
		toggleDesc.Parent = toggleTitle

		local toggleSwitch = Instance.new("Frame")
		toggleSwitch.Name = "Switch"
		toggleSwitch.Size = UDim2.new(0, 40, 0, 20)
		toggleSwitch.Position = UDim2.new(1, -50, 0.5, -10)
		toggleSwitch.BackgroundTransparency = 0.5
		toggleSwitch.BackgroundColor3 = Theme.Component
		toggleSwitch.BorderSizePixel = 0
		toggleSwitch.Parent = toggleFrame

		local toggleSwitchStroke = Instance.new("UIStroke")
		toggleSwitchStroke.Thickness = 1
		toggleSwitchStroke.Color = Theme.Border
		toggleSwitchStroke.Parent = toggleSwitch

		local toggleKnob = Instance.new("Frame")
		toggleKnob.Name = "Knob"
		toggleKnob.Size = UDim2.new(0, 16, 0, 16)
		toggleKnob.Position = UDim2.new(0, 2, 0.5, -8)
		toggleKnob.BackgroundTransparency = 0
		toggleKnob.BackgroundColor3 = Theme.Primary
		toggleKnob.BorderSizePixel = 0
		toggleKnob.Parent = toggleSwitch

		local toggleKnobCorner = Instance.new("UICorner")
		toggleKnobCorner.CornerRadius = UDim.new(1, 0)
		toggleKnobCorner.Parent = toggleKnob

		local toggleValue = Instance.new("BoolValue")
		toggleValue.Name = "Value"
		toggleValue.Value = toggleSettings.Default or false
		toggleValue.Parent = toggleFrame

		local function updateToggle(state)
			toggleValue.Value = state
			if state then
				Tween(toggleSwitch, 0.2, { BackgroundColor3 = Theme.Accent })
				Tween(toggleKnob, 0.2, { Position = UDim2.new(1, -18, 0.5, -8) })
			else
				Tween(toggleSwitch, 0.2, { BackgroundColor3 = Theme.Component })
				Tween(toggleKnob, 0.2, { Position = UDim2.new(0, 2, 0.5, -8) })
			end
		end

		updateToggle(toggleValue.Value)

		Connect(toggleFrame.MouseButton1Click, function()
			updateToggle(not toggleValue.Value)
			if toggleSettings.Callback then
				toggleSettings.Callback(toggleValue.Value)
			end
		end)
	end

	function WindowOptions:AddSlider(sliderSettings)
		local parentTab = sliderSettings.Tab
		if not parentTab then return end

		local sliderFrame = Instance.new("Frame")
		sliderFrame.Name = "Slider_" .. (sliderSettings.Title or "Unnamed")
		sliderFrame.Size = UDim2.new(1, 0, 0, 50)
		sliderFrame.BackgroundTransparency = 1
		sliderFrame.LayoutOrder = #parentTab:GetChildren()
		sliderFrame.Parent = parentTab

		local sliderTitle = Instance.new("TextLabel")
		sliderTitle.Name = "Title"
		sliderTitle.Size = UDim2.new(1, 0, 0, 20)
		sliderTitle.BackgroundTransparency = 1
		sliderTitle.Font = Enum.Font.Gotham
		sliderTitle.TextSize = 15
		sliderTitle.TextXAlignment = Enum.TextXAlignment.Left
		sliderTitle.TextColor3 = Theme.TextPrimary
		sliderTitle.Text = sliderSettings.Title or "Slider"
		sliderTitle.Parent = sliderFrame

		local sliderDesc = Instance.new("TextLabel")
		sliderDesc.Name = "Description"
		sliderDesc.Size = UDim2.new(1, 0, 0, 15)
		sliderDesc.Position = UDim2.new(0, 0, 0, 22)
		sliderDesc.BackgroundTransparency = 1
		sliderDesc.Font = Enum.Font.Gotham
		sliderDesc.TextSize = 12
		sliderDesc.TextXAlignment = Enum.TextXAlignment.Left
		sliderDesc.TextColor3 = Theme.TextMuted
		sliderDesc.Text = sliderSettings.Description or ""
		sliderDesc.Parent = sliderFrame

		local sliderTrack = Instance.new("Frame")
		sliderTrack.Name = "Track"
		sliderTrack.Size = UDim2.new(1, 0, 0, 4)
		sliderTrack.Position = UDim2.new(0, 0, 1, -15)
		sliderTrack.BackgroundTransparency = 0.5
		sliderTrack.BackgroundColor3 = Theme.Component
		sliderTrack.BorderSizePixel = 0
		sliderTrack.Parent = sliderFrame

		local sliderFill = Instance.new("Frame")
		sliderFill.Name = "Fill"
		sliderFill.Size = UDim2.new(0, 0, 1, 0)
		sliderFill.Position = UDim2.new(0, 0, 0, 0)
		sliderFill.BackgroundTransparency = 0
		sliderFill.BackgroundColor3 = Theme.Accent
		sliderFill.BorderSizePixel = 0
		sliderFill.Parent = sliderTrack

		local sliderHandle = Instance.new("Frame")
		sliderHandle.Name = "Handle"
		sliderHandle.Size = UDim2.new(0, 10, 0, 10)
		sliderHandle.Position = UDim2.new(0, -5, 0.5, -5)
		sliderHandle.BackgroundTransparency = 0
		sliderHandle.BackgroundColor3 = Theme.TextPrimary
		sliderHandle.BorderSizePixel = 0
		sliderHandle.Parent = sliderTrack

		local sliderHandleCorner = Instance.new("UICorner")
		sliderHandleCorner.CornerRadius = UDim.new(1, 0)
		sliderHandleCorner.Parent = sliderHandle

		local sliderValue = Instance.new("NumberValue")
		sliderValue.Name = "Value"
		sliderValue.Value = sliderSettings.Default or 0
		sliderValue.Parent = sliderFrame

		local maxValue = sliderSettings.MaxValue or 100
		local allowDecimals = sliderSettings.AllowDecimals or false
		local decimalPlaces = sliderSettings.DecimalAmount or 2

		local function updateSlider(value)
			value = math.clamp(value, 0, maxValue)
			if not allowDecimals then
				value = math.floor(value + 0.5)
			else
				local mult = 10 ^ decimalPlaces
				value = math.floor(value * mult + 0.5) / mult
			end
			sliderValue.Value = value
			local ratio = value / maxValue
			sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
			sliderHandle.Position = UDim2.new(ratio, -5, 0.5, -5)
		end

		updateSlider(sliderValue.Value)

		local isSliding = false
		Connect(sliderTrack.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isSliding = true
				local ratio = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
				updateSlider(ratio * maxValue)
				if sliderSettings.Callback then
					sliderSettings.Callback(sliderValue.Value)
				end
			end
		end)

		Connect(sliderTrack.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isSliding = false
			end
		end)

		Connect(Services.Input.InputChanged, function(input)
			if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
				local ratio = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
				updateSlider(ratio * maxValue)
				if sliderSettings.Callback then
					sliderSettings.Callback(sliderValue.Value)
				end
			end
		end)
	end

	function WindowOptions:Notify(notificationSettings)
		local Notification = Components:FindFirstChild("Notification")
		if not Notification then return end

		local NotifClone = Notification:Clone()
		NotifClone.Name = "NotificationInstance"
		NotifClone.Parent = Screen

		local title = NotifClone:FindFirstChild("Labels"):FindFirstChild("Title")
		local desc = NotifClone:FindFirstChild("Labels"):FindFirstChild("Description")
		local timer = NotifClone:FindFirstChild("Timer")

		if title then title.Text = notificationSettings.Title or "Notification" end
		if desc then desc.Text = notificationSettings.Description or "" end
		if timer then timer.BackgroundColor3 = Theme.Accent end

		-- Appliquer le thème à la notification
		local notifBG = NotifClone:FindFirstChild("Background")
		local notifStroke = notifBG and notifBG:FindFirstChild("Stroke")
		if notifBG then notifBG.BackgroundColor3 = Theme.Secondary end
		if notifStroke then notifStroke.Color = Theme.Border end
		if title then title.TextColor3 = Theme.TextPrimary end
		if desc then desc.TextColor3 = Theme.TextSecondary end

		Animations:OpenNotification(NotifClone, Setup.Transparency)

		local duration = notificationSettings.Duration or 3
		if timer then
			timer.Size = UDim2.new(1, -4, 0, 3)
			Tween(timer, duration, { Size = UDim2.new(0, 0, 0, 3) })
		end

		task.delay(duration, function()
			Animations:CloseNotification(NotifClone)
			task.delay(0.4, function()
				NotifClone:Destroy()
			end)
		end)
	end

	function WindowOptions:SetTheme(themeInfo)
		if type(themeInfo) == "string" and ThemesDefinitions[themeInfo] then
			Theme = ThemesDefinitions[themeInfo]
			Setup.ThemeMode = themeInfo
		elseif type(themeInfo) == "table" then
			Theme = themeInfo
		end
		ApplyTheme(Theme)
	end

	function WindowOptions:SetSetting(settingName, value)
		if settingName == "Transparency" then
			Setup.Transparency = value
			Tween(Window, 0.2, { BackgroundTransparency = value })
		elseif settingName == "Theme" then
			WindowOptions:SetTheme(value)
		elseif settingName == "Keybind" then
			ToggleKey = value
		elseif settingName == "Blur" then
			BlurEnabled = value
			if BlurEnabled and not InternalBlurInstance then
				InternalBlurInstance = CreateInternalBlur(Window)
				InternalBlurs[Settings.Title or "Untitled"] = InternalBlurInstance
			end
			if InternalBlurInstance then
				InternalBlurInstance.Visible = BlurEnabled and IsOpen
			end
		end
	end

	-- Finalize and Open
	Window.Visible = false
	Animations:OpenWindow(Window, Settings.Transparency or Setup.Transparency)

	StoredInfo["Windows"][Settings.Title or "Untitled"] = WindowOptions
	return WindowOptions
end

return Library