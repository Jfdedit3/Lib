-- UI Library - Tout en un
local UI = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Création de la librairie principale
function UI.new(name)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = name or "CustomUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = screenGui
    
    local lib = {
        ScreenGui = screenGui,
        Container = container
    }
    
    -- Fonction pour créer un bouton
    function lib.Button(props)
        props = props or {}
        
        local button = Instance.new("TextButton")
        button.Size = props.Size or UDim2.new(0, 100, 0, 30)
        button.Position = props.Position or UDim2.new(0, 0, 0, 0)
        button.Text = props.Text or "Button"
        button.BackgroundColor3 = props.BackgroundColor or Color3.fromRGB(40, 40, 40)
        button.TextColor3 = props.TextColor or Color3.fromRGB(255, 255, 255)
        button.BorderSizePixel = 0
        button.TextSize = props.TextSize or 14
        button.Font = props.Font or Enum.Font.SourceSans
        button.AutoButtonColor = false
        button.Parent = container
        
        -- Effets hover
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = props.HoverColor or Color3.fromRGB(60, 60, 60)
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = props.BackgroundColor or Color3.fromRGB(40, 40, 40)
        end)
        
        -- Clic
        if props.OnClick then
            button.MouseButton1Click:Connect(props.OnClick)
        end
        
        return button
    end
    
    -- Fonction pour créer un cadre
    function lib.Frame(props)
        props = props or {}
        
        local frame = Instance.new("Frame")
        frame.Size = props.Size or UDim2.new(0, 100, 0, 100)
        frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
        frame.BackgroundColor3 = props.BackgroundColor or Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = props.BorderSize or 0
        frame.BorderColor3 = props.BorderColor or Color3.fromRGB(0, 0, 0)
        frame.BackgroundTransparency = props.Transparency or 0
        frame.Parent = container
        
        return frame
    end
    
    -- Fonction pour créer un label/texte
    function lib.Label(props)
        props = props or {}
        
        local label = Instance.new("TextLabel")
        label.Size = props.Size or UDim2.new(0, 100, 0, 30)
        label.Position = props.Position or UDim2.new(0, 0, 0, 0)
        label.Text = props.Text or "Label"
        label.BackgroundColor3 = props.BackgroundColor or Color3.fromRGB(255, 255, 255)
        label.BackgroundTransparency = props.BackgroundTransparency or 1
        label.TextColor3 = props.TextColor or Color3.fromRGB(255, 255, 255)
        label.TextSize = props.TextSize or 14
        label.Font = props.Font or Enum.Font.SourceSans
        label.TextWrapped = props.TextWrapped or false
        label.Parent = container
        
        return label
    end
    
    -- Fonction pour créer un slider
    function lib.Slider(props)
        props = props or {}
        
        local frame = Instance.new("Frame")
        frame.Size = props.Size or UDim2.new(0, 200, 0, 30)
        frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
        frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        frame.BorderSizePixel = 0
        frame.Parent = container
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = props.FillColor or Color3.fromRGB(0, 150, 255)
        fill.BorderSizePixel = 0
        fill.Parent = frame
        
        local sliderButton = Instance.new("TextButton")
        sliderButton.Size = UDim2.new(0, 10, 1, 0)
        sliderButton.BackgroundColor3 = props.ButtonColor or Color3.fromRGB(255, 255, 255)
        sliderButton.BorderSizePixel = 0
        sliderButton.Text = ""
        sliderButton.Parent = fill
        
        local value = 0
        local dragging = false
        
        sliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        frame.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        local function updateSlider(x)
            local pos = math.clamp(x - frame.AbsolutePosition.X, 0, frame.AbsoluteSize.X)
            local percent = pos / frame.AbsoluteSize.X
            fill.Size = UDim2.new(percent, 0, 1, 0)
            value = math.floor(percent * 100)
            
            if props.OnChange then
                props.OnChange(value)
            end
        end
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input.Position.X)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        return {
            Frame = frame,
            Value = function() return value end,
            SetValue = function(val)
                value = math.clamp(val, 0, 100)
                fill.Size = UDim2.new(value/100, 0, 1, 0)
                if props.OnChange then
                    props.OnChange(value)
                end
            end
        }
    end
    
    -- Fonction pour créer un toggle
    function lib.Toggle(props)
        props = props or {}
        
        local frame = Instance.new("Frame")
        frame.Size = props.Size or UDim2.new(0, 50, 0, 25)
        frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = container
        
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, 0, 1, 0)
        toggleFrame.BackgroundColor3 = props.BackgroundColor or Color3.fromRGB(50, 50, 50)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = frame
        
        local toggleButton = Instance.new("Frame")
        toggleButton.Size = UDim2.new(0, 20, 1, -4)
        toggleButton.Position = UDim2.new(0, 2, 0, 2)
        toggleButton.BackgroundColor3 = props.ButtonColor or Color3.fromRGB(255, 255, 255)
        toggleButton.BorderSizePixel = 0
        toggleButton.Parent = toggleFrame
        
        local toggled = false
        
        local function updateToggle()
            if toggled then
                toggleButton:TweenPosition(UDim2.new(1, -22, 0, 2), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                toggleFrame.BackgroundColor3 = props.ActiveColor or Color3.fromRGB(0, 150, 255)
            else
                toggleButton:TweenPosition(UDim2.new(0, 2, 0, 2), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                toggleFrame.BackgroundColor3 = props.BackgroundColor or Color3.fromRGB(50, 50, 50)
            end
            
            if props.OnChange then
                props.OnChange(toggled)
            end
        end
        
        frame.MouseButton1Click:Connect(function()
            toggled = not toggled
            updateToggle()
        end)
        
        return {
            Frame = frame,
            IsToggled = function() return toggled end,
            SetToggled = function(state)
                toggled = state
                updateToggle()
            end
        }
    end
    
    -- Fonction pour créer une dropdown
    function lib.Dropdown(props)
        props = props or {}
        
        local frame = Instance.new("Frame")
        frame.Size = props.Size or UDim2.new(0, 150, 0, 30)
        frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
        frame.BackgroundColor3 = props.BackgroundColor or Color3.fromRGB(40, 40, 40)
        frame.BorderSizePixel = 0
        frame.Parent = container
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -30, 1, 0)
        label.Position = UDim2.new(0, 5, 0, 0)
        label.Text = props.Placeholder or "Select..."
        label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        label.BackgroundTransparency = 1
        label.TextColor3 = props.TextColor or Color3.fromRGB(255, 255, 255)
        label.TextSize = props.TextSize or 14
        label.Font = Enum.Font.SourceSans
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -25, 0, 0)
        arrow.Text = "▼"
        arrow.BackgroundTransparency = 1
        arrow.TextColor3 = props.TextColor or Color3.fromRGB(255, 255, 255)
        arrow.TextSize = 12
        arrow.Parent = frame
        
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
        dropdownFrame.Position = UDim2.new(0, 0, 1, 0)
        dropdownFrame.BackgroundColor3 = props.BackgroundColor or Color3.fromRGB(40, 40, 40)
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.Visible = false
        dropdownFrame.Parent = frame
        
        local uiListLayout = Instance.new("UIListLayout")
        uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        uiListLayout.Parent = dropdownFrame
        
        local selectedValue = nil
        local isOpen = false
        
        local function toggleDropdown()
            isOpen = not isOpen
            dropdownFrame.Visible = isOpen
            arrow.Text = isOpen and "▲" or "▼"
            
            if isOpen then
                local height = #props.Options * 25
                dropdownFrame:TweenSize(UDim2.new(1, 0, 0, height), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            else
                dropdownFrame:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            end
        end
        
        frame.MouseButton1Click:Connect(toggleDropdown)
        
        for i, option in ipairs(props.Options or {}) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, 0, 0, 25)
            optionButton.Text = option
            optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            optionButton.TextColor3 = props.TextColor or Color3.fromRGB(255, 255, 255)
            optionButton.BorderSizePixel = 0
            optionButton.TextSize = 12
            optionButton.LayoutOrder = i
            optionButton.Parent = dropdownFrame
            
            optionButton.MouseButton1Click:Connect(function()
                selectedValue = option
                label.Text = option
                toggleDropdown()
                
                if props.OnSelect then
                    props.OnSelect(option)
                end
            end)
        end
        
        return {
            Frame = frame,
            GetValue = function() return selectedValue end,
            SetValue = function(value)
                selectedValue = value
                label.Text = value or props.Placeholder or "Select..."
            end
        }
    end
    
    -- Fonction pour créer un textbox
    function lib.TextBox(props)
        props = props or {}
        
        local textBox = Instance.new("TextBox")
        textBox.Size = props.Size or UDim2.new(0, 150, 0, 30)
        textBox.Position = props.Position or UDim2.new(0, 0, 0, 0)
        textBox.BackgroundColor3 = props.BackgroundColor or Color3.fromRGB(40, 40, 40)
        textBox.TextColor3 = props.TextColor or Color3.fromRGB(255, 255, 255)
        textBox.BorderSizePixel = 0
        textBox.Text = props.Placeholder or ""
        textBox.PlaceholderColor3 = props.PlaceholderColor or Color3.fromRGB(150, 150, 150)
        textBox.TextSize = props.TextSize or 14
        textBox.Font = props.Font or Enum.Font.SourceSans
        textBox.ClearTextOnFocus = props.ClearOnFocus or false
        textBox.Parent = container
        
        return textBox
    end
    
    -- Fonction pour créer une notification
    function lib.Notification(props)
        props = props or {}
        
        local notification = Instance.new("Frame")
        notification.Size = UDim2.new(0, 250, 0, 60)
        notification.Position = props.Position or UDim2.new(1, -260, 0, 20)
        notification.BackgroundColor3 = props.BackgroundColor or Color3.fromRGB(30, 30, 30)
        notification.BorderSizePixel = 0
        notification.Parent = container
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -10, 0, 20)
        title.Position = UDim2.new(0, 5, 0, 5)
        title.Text = props.Title or "Notification"
        title.BackgroundTransparency = 1
        title.TextColor3 = props.TitleColor or Color3.fromRGB(255, 255, 255)
        title.TextSize = 16
        title.Font = Enum.Font.SourceSansBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = notification
        
        local message = Instance.new("TextLabel")
        message.Size = UDim2.new(1, -10, 0, 30)
        message.Position = UDim2.new(0, 5, 0, 25)
        message.Text = props.Message or "Message"
        message.BackgroundTransparency = 1
        message.TextColor3 = props.MessageColor or Color3.fromRGB(200, 200, 200)
        message.TextSize = 14
        message.Font = Enum.Font.SourceSans
        message.TextWrapped = true
        message.TextXAlignment = Enum.TextXAlignment.Left
        message.TextYAlignment = Enum.TextYAlignment.Top
        message.Parent = notification
        
        -- Animation d'entrée
        notification.Position = UDim2.new(1, 10, 0, 20)
        notification:TweenPosition(props.Position or UDim2.new(1, -260, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
        
        -- Auto-fermeture
        local duration = props.Duration or 3
        game:GetService("Debris"):AddItem(notification, duration)
        
        return notification
    end
    
    -- Fonction pour créer une progress bar
    function lib.ProgressBar(props)
        props = props or {}
        
        local frame = Instance.new("Frame")
        frame.Size = props.Size or UDim2.new(0, 200, 0, 20)
        frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
        frame.BackgroundColor3 = props.BackgroundColor or Color3.fromRGB(50, 50, 50)
        frame.BorderSizePixel = 0
        frame.Parent = container
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = props.FillColor or Color3.fromRGB(0, 150, 255)
        fill.BorderSizePixel = 0
        fill.Parent = frame
        
        local value = 0
        
        return {
            Frame = frame,
            SetValue = function(percent)
                value = math.clamp(percent, 0, 100)
                fill.Size = UDim2.new(value/100, 0, 1, 0)
            end,
            GetValue = function() return value end
        }
    end
    
    -- Fonction pour créer un séparateur
    function lib.Separator(props)
        props = props or {}
        
        local frame = Instance.new("Frame")
        frame.Size = props.Size or UDim2.new(0, 200, 0, 1)
        frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
        frame.BackgroundColor3 = props.Color or Color3.fromRGB(100, 100, 100)
        frame.BorderSizePixel = 0
        frame.Parent = container
        
        return frame
    end
    
    -- Fonction pour créer un panel avec scroll
    function lib.ScrollPanel(props)
        props = props or {}
        
        local frame = Instance.new("Frame")
        frame.Size = props.Size or UDim2.new(0, 300, 0, 200)
        frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
        frame.BackgroundColor3 = props.BackgroundColor or Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = 0
        frame.Parent = container
        
        local canvas = Instance.new("ScrollingFrame")
        canvas.Size = UDim2.new(1, -10, 1, 0)
        canvas.Position = UDim2.new(0, 0, 0, 0)
        canvas.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        canvas.BackgroundTransparency = 1
        canvas.BorderSizePixel = 0
        canvas.CanvasSize = UDim2.new(0, 0, 0, 0)
        canvas.ScrollBarThickness = 6
        canvas.Parent = frame
        
        local uiListLayout = Instance.new("UIListLayout")
        uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        uiListLayout.Padding = UDim.new(0, 5)
        uiListLayout.Parent = canvas
        
        return {
            Frame = frame,
            Canvas = canvas,
            AddItem = function(item)
                item.Parent = canvas
                canvas.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
            end
        }
    end
    
    -- Mettre à jour la progress bar
    -- progressBar.SetValue(75)
    
    -- Créer un séparateur
    -- local separator = myUI.Separator({
    --     Position = UDim2.new(0, 100, 0, 430),
    --     Size = UDim2.new(0, 200, 0, 1)
    -- })
    
    -- Créer un panel scrollable
    -- local scrollPanel = myUI.ScrollPanel({
    --     Position = UDim2.new(0, 350, 0, 100),
    --     Size = UDim2.new(0, 200, 0, 150)
    -- })
    
    -- Ajouter des éléments au panel
    -- for i = 1, 20 do
    --     local label = myUI.Label({
    --         Text = "Item " .. i,
    --         Size = UDim2.new(1, -10, 0, 20)
    --     })
    --     scrollPanel.AddItem(label)
    -- end
    
    return lib
end

return UI