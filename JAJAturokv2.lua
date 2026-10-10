--[[
     _    _    _    _             _   _       _           
    | |  / \  | |  / \    __ _    | | | |_   _| |__  _   _ 
    | | / _ \ | | / _ \  / _` |   | |_| | | | | '_ \| | | |
    | |/ ___ \| |/ ___ \| (_| |   |  _  | |_| | |_) | |_| |
    |_/_/   \_\_/_/   \_\\__,_|   |_| |_|\__,_|_.__/ \__, |
                                                      |___/ 
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Approved Roblox Assets
local ANIMAL_LOGO = "rbxassetid://6534551122" -- Approved Roblox Cat / Paw Logo
local LOUD_EXECUTE_SOUND = "rbxassetid://9125298882" -- Loud approved Roblox sound effect
local CLICK_SOUND = "rbxassetid://9060469075"

-- Play Loud Sound immediately on Execution
local function PlayExecuteSound()
    local sound = Instance.new("Sound")
    sound.SoundId = LOUD_EXECUTE_SOUND
    sound.Volume = 2.5
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end
PlayExecuteSound()

local function PlayClickSound()
    local sound = Instance.new("Sound")
    sound.SoundId = CLICK_SOUND
    sound.Volume = 0.6
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Settings & Config
local AimEnabled = false
local ESPEnabled = false
local FOVCircleEnabled = false
local FOV = 120
local TrackingStrength = 0.20
local WallCheck = true
local TeamCheck = true
local ESPHighlights = {}
local ConfigFileName = "JAJAaHubConfig.json"

local function ReadSavedConfig()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then return end
    local ok, data = pcall(function()
        if not isfile(ConfigFileName) then return nil end
        return HttpService:JSONDecode(readfile(ConfigFileName))
    end)
    if ok and type(data) == "table" then
        if type(data.FOV) == "number" then FOV = math.clamp(data.FOV, 20, 300) end
        if type(data.TrackingStrength) == "number" then TrackingStrength = math.clamp(data.TrackingStrength, 0.01, 0.50) end
        if type(data.TeamCheck) == "boolean" then TeamCheck = data.TeamCheck end
        if type(data.AimEnabled) == "boolean" then AimEnabled = data.AimEnabled end
        if type(data.ESPEnabled) == "boolean" then ESPEnabled = data.ESPEnabled end
        if type(data.FOVCircleEnabled) == "boolean" then FOVCircleEnabled = data.FOVCircleEnabled end
    end
end
ReadSavedConfig()

-- Team Checking Logic
local TEAM_MARKERS = {"StageTeamSide", "Team", "TeamName", "TeamColor", "TeamId", "TeamID", "team"}
local function readTeamMarker(instance)
    if not instance then return nil end
    for _, name in ipairs(TEAM_MARKERS) do
        local attribute = instance:GetAttribute(name)
        if attribute ~= nil then return name .. "=" .. tostring(attribute) end
        local child = instance:FindFirstChild(name)
        if child and child:IsA("ValueBase") then return name .. "=" .. tostring(child.Value) end
    end
    return nil
end

local function getCustomTeamIdentity(targetPlayer)
    if not targetPlayer then return nil end
    local marker = readTeamMarker(targetPlayer) or readTeamMarker(targetPlayer.Character)
    if marker then return marker end
    local stats = targetPlayer:FindFirstChild("leaderstats")
    marker = readTeamMarker(stats)
    if marker then return marker end
    if not targetPlayer.Neutral then return "TeamColor=" .. tostring(targetPlayer.TeamColor) end
    return nil
end

local customTeamCache = { count = 0, at = 0 }
local function getCustomTeamCount()
    local now = os.clock()
    if now - customTeamCache.at > 0.5 then
        local seen, count = {}, 0
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            local identity = getCustomTeamIdentity(targetPlayer)
            if identity and not seen[identity] then
                seen[identity] = true
                count = count + 1
            end
        end
        customTeamCache.count = count
        customTeamCache.at = now
    end
    return customTeamCache.count
end

local function isTeammate(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return false end
    if LocalPlayer.Team and targetPlayer.Team then return LocalPlayer.Team == targetPlayer.Team end
    local localTeam = getCustomTeamIdentity(LocalPlayer)
    local targetTeam = getCustomTeamIdentity(targetPlayer)
    if not localTeam or not targetTeam then return false end
    return getCustomTeamCount() >= 2 and localTeam == targetTeam
end

-- ScreenGui Setup
local OldGui = PlayerGui:FindFirstChild("JAJAaHub")
if OldGui then OldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JAJAaHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
ScreenGui.Parent = PlayerGui

-- FOV Circle
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.Size = UDim2.fromOffset(FOV * 2, FOV * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = FOVCircleEnabled
FOVCircle.ZIndex = 2
FOVCircle.Parent = ScreenGui

local FOVCircleCorner = Instance.new("UICorner")
FOVCircleCorner.CornerRadius = UDim.new(1, 0)
FOVCircleCorner.Parent = FOVCircle

local FOVCircleStroke = Instance.new("UIStroke")
FOVCircleStroke.Color = Color3.fromRGB(0, 255, 150) -- Neon Emerald
FOVCircleStroke.Thickness = 1.5
FOVCircleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
FOVCircleStroke.Parent = FOVCircle

----------------------------------------------------
-- KEY SYSTEM UI
----------------------------------------------------
local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Size = UDim2.fromOffset(280, 200)
KeyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
KeyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
KeyFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
KeyFrame.Parent = ScreenGui

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 10)
KeyCorner.Parent = KeyFrame

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Thickness = 1.5
KeyStroke.Color = Color3.fromRGB(0, 255, 150)
KeyStroke.Parent = KeyFrame

local KeyLogo = Instance.new("ImageLabel")
KeyLogo.Size = UDim2.fromOffset(45, 45)
KeyLogo.Position = UDim2.new(0.5, -22, 0, 12)
KeyLogo.BackgroundTransparency = 1
KeyLogo.Image = ANIMAL_LOGO
KeyLogo.Parent = KeyFrame

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Position = UDim2.fromOffset(0, 60)
KeyTitle.Size = UDim2.new(1, 0, 0, 22)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Text = "JAJAa.a v1 hub Key System"
KeyTitle.TextColor3 = Color3.fromRGB(240, 240, 255)
KeyTitle.TextSize = 13
KeyTitle.Parent = KeyFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Position = UDim2.fromOffset(25, 95)
KeyInput.Size = UDim2.new(1, -50, 0, 32)
KeyInput.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
KeyInput.Font = Enum.Font.Gotham
KeyInput.PlaceholderText = "Enter Key (JA69)..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 12
KeyInput.Parent = KeyFrame

local KeyInputCorner = Instance.new("UICorner")
KeyInputCorner.CornerRadius = UDim.new(0, 6)
KeyInputCorner.Parent = KeyInput

local KeyInputStroke = Instance.new("UIStroke")
KeyInputStroke.Color = Color3.fromRGB(0, 180, 110)
KeyInputStroke.Thickness = 1
KeyInputStroke.Parent = KeyInput

local KeySubmit = Instance.new("TextButton")
KeySubmit.Position = UDim2.fromOffset(25, 138)
KeySubmit.Size = UDim2.new(1, -50, 0, 32)
KeySubmit.BackgroundColor3 = Color3.fromRGB(0, 150, 90)
KeySubmit.Font = Enum.Font.GothamBold
KeySubmit.Text = "Submit Key"
KeySubmit.TextColor3 = Color3.fromRGB(255, 255, 255)
KeySubmit.TextSize = 12
KeySubmit.Parent = KeyFrame

local KeySubmitCorner = Instance.new("UICorner")
KeySubmitCorner.CornerRadius = UDim.new(0, 6)
KeySubmitCorner.Parent = KeySubmit

----------------------------------------------------
-- MAIN HUB UI
----------------------------------------------------
local Menu = Instance.new("Frame")
Menu.Name = "MiniMenu"
Menu.Size = UDim2.fromOffset(220, 280)
Menu.AnchorPoint = Vector2.new(0.5, 0.5)
Menu.Position = UDim2.new(0.5, 0, 0.5, 0)
Menu.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
Menu.ClipsDescendants = true
Menu.Visible = false -- Hidden until Key verified
Menu.Active = true
Menu.Parent = ScreenGui

local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.fromOffset(48, 48)
ToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleButton.Position = UDim2.new(0.12, 0, 0.5, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
ToggleButton.Image = ANIMAL_LOGO
ToggleButton.ScaleType = Enum.ScaleType.Fit
ToggleButton.ZIndex = 10
ToggleButton.Visible = false -- Hidden until Key verified
ToggleButton.Active = true
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 1.5
ToggleStroke.Color = Color3.fromRGB(0, 255, 150)
ToggleStroke.Parent = ToggleButton

-- Key Validation Action
KeySubmit.Activated:Connect(function()
    PlayClickSound()
    if KeyInput.Text == "JA69" then
        KeyFrame:Destroy()
        Menu.Visible = true
        ToggleButton.Visible = true
    else
        KeySubmit.Text = "Incorrect Key!"
        KeySubmit.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        task.delay(1.5, function()
            if KeySubmit then
                KeySubmit.Text = "Submit Key"
                KeySubmit.BackgroundColor3 = Color3.fromRGB(0, 150, 90)
            end
        end)
    end
end)

-- Dragging Toggle Button
local ToggleDragging, ToggleDragStart, ToggleStartPosition, ToggleDragInput, ToggleMoved = false
ToggleButton.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		ToggleDragging = true
		ToggleMoved = false
		ToggleDragStart = Input.Position
		ToggleStartPosition = ToggleButton.Position
		Input.Changed:Connect(function()
			if Input.UserInputState == Enum.UserInputState.End then ToggleDragging = false end
		end)
	end
end)

ToggleButton.InputChanged:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
		ToggleDragInput = Input
	end
end)

UserInputService.InputChanged:Connect(function(Input)
	if Input == ToggleDragInput and ToggleDragging then
		local Delta = Input.Position - ToggleDragStart
		if Delta.Magnitude > 8 then ToggleMoved = true end
		ToggleButton.Position = ToggleButton.Position:Lerp(UDim2.new(
			ToggleStartPosition.X.Scale, ToggleStartPosition.X.Offset + Delta.X,
			ToggleStartPosition.Y.Scale, ToggleStartPosition.Y.Offset + Delta.Y
		), 0.35)
	end
end)

ToggleButton.Activated:Connect(function()
	if ToggleMoved then ToggleMoved = false; return end
    PlayClickSound()
	Menu.Visible = not Menu.Visible
end)

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Menu

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1.5
Stroke.Color = Color3.fromRGB(0, 255, 150)
Stroke.Parent = Menu

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(12, 8)
Title.Size = UDim2.new(1, -96, 0, 24)
Title.Font = Enum.Font.GothamBold
Title.Text = "JAJAa.a v1 hub"
Title.TextColor3 = Color3.fromRGB(240, 240, 255)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Menu

local SaveConfigButton = Instance.new("TextButton")
SaveConfigButton.Position = UDim2.new(1, -84, 0, 8)
SaveConfigButton.Size = UDim2.fromOffset(74, 22)
SaveConfigButton.BackgroundColor3 = Color3.fromRGB(15, 45, 30)
SaveConfigButton.Font = Enum.Font.GothamBold
SaveConfigButton.Text = "Save Config"
SaveConfigButton.TextColor3 = Color3.fromRGB(180, 255, 210)
SaveConfigButton.TextSize = 9
SaveConfigButton.Parent = Menu

local SaveConfigCorner = Instance.new("UICorner")
SaveConfigCorner.CornerRadius = UDim.new(0, 6)
SaveConfigCorner.Parent = SaveConfigButton

local SaveConfigStroke = Instance.new("UIStroke")
SaveConfigStroke.Color = Color3.fromRGB(0, 255, 150)
SaveConfigStroke.Thickness = 1
SaveConfigStroke.Transparency = 0.5
SaveConfigStroke.Parent = SaveConfigButton

SaveConfigButton.Activated:Connect(function()
    PlayClickSound()
    local Config = {
        FOV = FOV, TrackingStrength = TrackingStrength, TeamCheck = TeamCheck,
        AimEnabled = AimEnabled, ESPEnabled = ESPEnabled, FOVCircleEnabled = FOVCircleEnabled
    }
    if type(writefile) == "function" then
        pcall(function() writefile(ConfigFileName, HttpService:JSONEncode(Config)) end)
        SaveConfigButton.Text = "Saved!"
    else
        SaveConfigButton.Text = "No API"
    end
    task.delay(1.5, function()
        if SaveConfigButton and SaveConfigButton.Parent then SaveConfigButton.Text = "Save Config" end
    end)
end)

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.fromOffset(12, 28)
Subtitle.Size = UDim2.new(1, -20, 0, 14)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "by JAMOnagRant"
Subtitle.TextColor3 = Color3.fromRGB(0, 200, 130)
Subtitle.TextSize = 9
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Menu

local function CreateStyledButton(Name, Y, InitialText)
    local Btn = Instance.new("TextButton")
    Btn.Name = Name
    Btn.Position = UDim2.fromOffset(12, Y)
    Btn.Size = UDim2.new(1, -24, 0, 28)
    Btn.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = InitialText
    Btn.TextColor3 = Color3.fromRGB(230, 230, 245)
    Btn.TextSize = 11
    Btn.Parent = Menu

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 180, 110)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    Stroke.Parent = Btn

    return Btn
end

local AimButton = CreateStyledButton("AimAssistButton", 48, "Aim Assist: OFF")
local ESPButton = CreateStyledButton("ESPButton", 84, "ESP: OFF")
local TeamButton = CreateStyledButton("TeamCheckButton", 120, "Team Check: ON")

local function MakeSlider(Name, LabelText, Y, Minimum, Maximum, InitialValue, FormatValue, OnChanged)
    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.fromOffset(12, Y)
    Label.Size = UDim2.new(1, -24, 0, 16)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextColor3 = Color3.fromRGB(220, 220, 240)
    Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Menu

    local Track = Instance.new("TextButton")
    Track.Position = UDim2.fromOffset(12, Y + 16)
    Track.Size = UDim2.new(1, -24, 0, 10)
    Track.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
    Track.Text = ""
    Track.Parent = Menu

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((InitialValue - Minimum) / (Maximum - Minimum), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Fill.Parent = Track

    local Knob = Instance.new("Frame")
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new((InitialValue - Minimum) / (Maximum - Minimum), 0, 0.5, 0)
    Knob.Size = UDim2.fromOffset(12, 12)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.Parent = Track

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local Value = InitialValue
    local Sliding = false

    local function SetFromX(X)
        local Width = math.max(1, Track.AbsoluteSize.X)
        local Alpha = math.clamp((X - Track.AbsolutePosition.X) / Width, 0, 1)
        Value = Minimum + (Maximum - Minimum) * Alpha
        if Maximum > 10 then Value = math.floor(Value + 0.5) else Value = math.floor(Value * 100 + 0.5) / 100 end
        local Percent = (Value - Minimum) / (Maximum - Minimum)
        Fill.Size = UDim2.new(Percent, 0, 1, 0)
        Knob.Position = UDim2.new(Percent, 0, 0.5, 0)
        Label.Text = LabelText .. ": " .. FormatValue(Value)
        OnChanged(Value)
    end

    Label.Text = LabelText .. ": " .. FormatValue(InitialValue)

    Track.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Sliding = true
            SetFromX(Input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(Input)
        if Sliding and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            SetFromX(Input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Sliding = false
        end
    end)
end

MakeSlider("FOV", "FOV", 154, 20, 300, FOV, function(V) return tostring(V) .. " px" end, function(V)
    FOV = V
    FOVCircle.Size = UDim2.fromOffset(FOV * 2, FOV * 2)
end)

MakeSlider("Smoothness", "Smoothness", 196, 0.01, 0.50, TrackingStrength, function(V) return string.format("%.2f", V) end, function(V)
    TrackingStrength = V
end)

local FOVCircleButton = CreateStyledButton("FOVCircleButton", 238, "FOV Circle: OFF")

FOVCircleButton.Activated:Connect(function()
    PlayClickSound()
    FOVCircleEnabled = not FOVCircleEnabled
    FOVCircle.Visible = FOVCircleEnabled
    FOVCircleButton.Text = FOVCircleEnabled and "FOV Circle: ON" or "FOV Circle: OFF"
    FOVCircleButton.BackgroundColor3 = FOVCircleEnabled and Color3.fromRGB(0, 120, 75) or Color3.fromRGB(18, 22, 28)
end)

TeamButton.Activated:Connect(function()
    PlayClickSound()
    TeamCheck = not TeamCheck
    TeamButton.Text = TeamCheck and "Team Check: ON" or "Team Check: OFF"
    TeamButton.BackgroundColor3 = TeamCheck and Color3.fromRGB(0, 120, 75) or Color3.fromRGB(18, 22, 28)
end)

-- ESP Functions
local function RemoveESP(Player)
    local Highlight = ESPHighlights[Player]
    if Highlight then Highlight:Destroy(); ESPHighlights[Player] = nil end
end

local function CreateESP(Player)
    if Player == LocalPlayer then return end
    local Character = Player.Character
    if not Character then RemoveESP(Player); return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then RemoveESP(Player); return end
    
    local Highlight = ESPHighlights[Player]
    if not Highlight or Highlight.Parent ~= Character then
        RemoveESP(Player)
        Highlight = Instance.new("Highlight")
        Highlight.Name = "JAJAaHubESP"
        Highlight.Adornee = Character
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.FillTransparency = 1
        Highlight.OutlineTransparency = 0.3
        Highlight.Parent = Character
        ESPHighlights[Player] = Highlight
    end
    Highlight.OutlineColor = isTeammate(Player) and Color3.fromRGB(80, 180, 255) or Color3.fromRGB(0, 255, 150)
end

local function RefreshESP()
    if not ESPEnabled then
        for Player in pairs(ESPHighlights) do RemoveESP(Player) end
        return
    end
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then CreateESP(Player) end
    end
end

ESPButton.Activated:Connect(function()
    PlayClickSound()
    ESPEnabled = not ESPEnabled
    ESPButton.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
    ESPButton.BackgroundColor3 = ESPEnabled and Color3.fromRGB(0, 120, 75) or Color3.fromRGB(18, 22, 28)
    RefreshESP()
end)

Players.PlayerRemoving:Connect(RemoveESP)
Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function()
        task.wait(0.2)
        if ESPEnabled then CreateESP(Player) end
    end)
end)

-- Main Menu Dragging
local Dragging, DragStart, StartPosition, DragInput
Menu.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		Dragging = true
		DragStart = Input.Position
		StartPosition = Menu.Position
		Input.Changed:Connect(function()
			if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
		end)
	end
end)

Menu.InputChanged:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
		DragInput = Input
	end
end)

UserInputService.InputChanged:Connect(function(Input)
	if Input == DragInput and Dragging then
		local Delta = Input.Position - DragStart
		Menu.Position = Menu.Position:Lerp(UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y), 0.35)
	end
end)

-- Aim Assist Logic
local function GetTarget()
	local Camera = workspace.CurrentCamera
	if not Camera then return nil end
	local Viewport = Camera.ViewportSize
	local Center = Vector2.new(Viewport.X / 2, Viewport.Y / 2)
	local Closest = nil
	local ClosestDistance = FOV

	for _, Player in ipairs(Players:GetPlayers()) do
		if Player ~= LocalPlayer and not (TeamCheck and isTeammate(Player)) then
			local Character = Player.Character
			if Character then
				local Humanoid = Character:FindFirstChildOfClass("Humanoid")
				local Head = Character:FindFirstChild("Head")
				if Humanoid and Humanoid.Health > 0 and Head then
					local Position, OnScreen = Camera:WorldToViewportPoint(Head.Position)
					if OnScreen and Position.Z > 0 then
						local Point = Vector2.new(Position.X, Position.Y)
						local Distance = (Point - Center).Magnitude
						if Distance <= ClosestDistance then
							local Origin = Camera.CFrame.Position
							local Direction = Head.Position - Origin
							local Params = RaycastParams.new()
							Params.FilterType = Enum.RaycastFilterType.Exclude
							Params.FilterDescendantsInstances = {LocalPlayer.Character}
							Params.IgnoreWater = true
							local Result = workspace:Raycast(Origin, Direction, Params)
							local Visible = not WallCheck or (Result == nil or Result.Instance:IsDescendantOf(Character))
							if Visible then
								ClosestDistance = Distance
								Closest = Head
							end
						end
					end
				end
			end
		end
	end
	return Closest
end

AimButton.Activated:Connect(function()
    PlayClickSound()
	AimEnabled = not AimEnabled
	AimButton.Text = AimEnabled and "Aim Assist: ON" or "Aim Assist: OFF"
	AimButton.BackgroundColor3 = AimEnabled and Color3.fromRGB(0, 120, 75) or Color3.fromRGB(18, 22, 28)
end)

RunService.RenderStepped:Connect(function()
	RefreshESP()
	local Camera = workspace.CurrentCamera
	if not Camera or not AimEnabled then return end
	local Target = GetTarget()
	if not Target then return end
	Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, Target.Position), TrackingStrength)
end)
