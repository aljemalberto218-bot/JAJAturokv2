--[[
     _    _    _    _             _   _       _           
    | |  / \  | |  / \    __ _    | | | |_   _| |__  _   _ 
    | | / _ \ | | / _ \  / _` |   | |_| | | | | '_ \| | | |
    | |/ ___ \| |/ ___ \| (_| |   |  _  | |_| | |_) | |_| |
    |_/_/   \_\_/_/   \_\\__,_|   |_| |_|\__,_|_.__/ \__, |
                                                      |___/ 
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Approved Roblox Assets
local ANIMAL_LOGO = "rbxassetid://6534551122" 
local SASUKE_IMAGE = "rbxassetid://6810237996" -- Approved Roblox Sasuke Image Asset
local LOUD_EXECUTE_SOUND = "rbxassetid://9125298882" 
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

local function runPrerequisite(url, name)
    local ok, result = pcall(function()
        local source = game:HttpGet(url)
        local runner = loadstring(source)
        assert(type(runner) == "function", name .. " source did not return executable code")
        return runner()
    end)
    if not ok then
        warn("[JAJAaHub] " .. name .. " failed to initialize: " .. tostring(result))
    end
    return ok
end

do
    local ANTI_KICK_URL = "https://raw.githubusercontent.com/SUUUUUS00000/MEGGD-Anti-kick/refs/heads/main/MEGGD%20Best%20Anti-kick.lua"
    runPrerequisite(ANTI_KICK_URL, "Anti-kick")
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

----------------------------------------------------
-- SASUKE INTRO SCREEN (WITH PICTURE)
----------------------------------------------------
local IntroFrame = Instance.new("Frame")
IntroFrame.Size = UDim2.fromScale(1, 1)
IntroFrame.BackgroundColor3 = Color3.fromRGB(5, 7, 10)
IntroFrame.ZIndex = 50
IntroFrame.Parent = ScreenGui

local SasukePic = Instance.new("ImageLabel")
SasukePic.Size = UDim2.fromOffset(140, 140)
SasukePic.AnchorPoint = Vector2.new(0.5, 0.5)
SasukePic.Position = UDim2.fromScale(0.5, 0.4)
SasukePic.BackgroundTransparency = 1
SasukePic.Image = SASUKE_IMAGE
SasukePic.ScaleType = Enum.ScaleType.Fit
SasukePic.ZIndex = 51
SasukePic.Parent = IntroFrame

local IntroCorner = Instance.new("UICorner")
IntroCorner.CornerRadius = UDim.new(0, 16)
IntroCorner.Parent = SasukePic

local IntroText = Instance.new("TextLabel")
IntroText.Size = UDim2.new(1, 0, 0, 40)
IntroText.AnchorPoint = Vector2.new(0.5, 0.5)
IntroText.Position = UDim2.fromScale(0.5, 0.6)
IntroText.BackgroundTransparency = 1
IntroText.Font = Enum.Font.GothamBold
IntroText.Text = "⚡ SASUKE MODE ACTIVATED ⚡"
IntroText.TextColor3 = Color3.fromRGB(0, 255, 150)
IntroText.TextSize = 20
IntroText.ZIndex = 51
IntroText.Parent = IntroFrame

task.delay(2.5, function()
    if IntroFrame and IntroFrame.Parent then
        IntroFrame:Destroy()
    end
end)

----------------------------------------------------
-- FAKE PC CLIENT PROMPT
----------------------------------------------------
local promptGui = Instance.new("ScreenGui")
promptGui.Name = "JAJAaHubPCClientPrompt"
promptGui.ResetOnSpawn = false
promptGui.IgnoreGuiInset = true
promptGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
promptGui.Parent = PlayerGui

local overlay = Instance.new("Frame")
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.4
overlay.BorderSizePixel = 0
overlay.ZIndex = 40
overlay.Parent = promptGui

local box = Instance.new("Frame")
box.AnchorPoint = Vector2.new(0.5, 0.5)
box.Position = UDim2.fromScale(0.5, 0.5)
box.Size = UDim2.fromOffset(330, 190)
box.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
box.BorderSizePixel = 0
box.ZIndex = 41
box.Parent = overlay

Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 255, 150)
stroke.Thickness = 1.5
stroke.Parent = box

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(20, 18)
title.Size = UDim2.new(1, -40, 0, 25)
title.BackgroundTransparency = 1
title.Text = "Fake PC Client"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.ZIndex = 42
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = box

local message = Instance.new("TextLabel")
message.Position = UDim2.fromOffset(20, 52)
message.Size = UDim2.new(1, -40, 0, 48)
message.BackgroundTransparency = 1
message.Text = "Do you want to use the Fake PC Client (Device Spoofer)?"
message.TextColor3 = Color3.fromRGB(190, 195, 210)
message.Font = Enum.Font.Gotham
message.TextSize = 11
message.ZIndex = 42
message.TextWrapped = true
message.TextXAlignment = Enum.TextXAlignment.Left
message.Parent = box

local yes = Instance.new("TextButton")
yes.Position = UDim2.fromOffset(20, 122)
yes.Size = UDim2.new(0.5, -25, 0, 42)
yes.BackgroundColor3 = Color3.fromRGB(0, 150, 90)
yes.BorderSizePixel = 0
yes.AutoButtonColor = false
yes.Text = "YES"
yes.TextColor3 = Color3.fromRGB(255, 255, 255)
yes.Font = Enum.Font.GothamBold
yes.TextSize = 12
yes.ZIndex = 42
yes.Parent = box
Instance.new("UICorner", yes).CornerRadius = UDim.new(0, 8)

local no = Instance.new("TextButton")
no.Position = UDim2.new(0.5, 5, 0, 122)
no.Size = UDim2.new(0.5, -25, 0, 42)
no.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
no.BorderSizePixel = 0
no.AutoButtonColor = false
no.Text = "NO"
no.TextColor3 = Color3.fromRGB(255, 255, 255)
no.Font = Enum.Font.GothamBold
no.TextSize = 12
no.ZIndex = 42
no.Parent = box
Instance.new("UICorner", no).CornerRadius = UDim.new(0, 8)

local choice = nil
yes.MouseButton1Click:Connect(function() PlayClickSound(); choice = true end)
no.MouseButton1Click:Connect(function() PlayClickSound(); choice = false end)
repeat task.wait() until choice ~= nil
promptGui:Destroy()
if choice then
    local DEVICE_SPOOFER_URL = "https://raw.githubusercontent.com/yBloodz/Free-scripts/refs/heads/main/MVSD-DEVICE-SPOOFER"
    runPrerequisite(DEVICE_SPOOFER_URL, "Device Spoofer")
end

----------------------------------------------------
-- KEY SYSTEM UI
----------------------------------------------------
local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Size = UDim2.fromOffset(280, 200)
KeyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
KeyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
KeyFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
KeyFrame.ZIndex = 30
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
KeyLogo.ZIndex = 31
KeyLogo.Parent = KeyFrame

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Position = UDim2.fromOffset(0, 60)
KeyTitle.Size = UDim2.new(1, 0, 0, 22)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Text = "JAJAa.a v1 hub Key System"
KeyTitle.TextColor3 = Color3.fromRGB(240, 240, 255)
KeyTitle.TextSize = 13
KeyTitle.ZIndex = 31
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
KeyInput.ZIndex = 31
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
KeySubmit.ZIndex = 31
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
Menu.Visible = false 
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
ToggleButton.Visible = false 
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

local ConfigFileName = "JAJAaHubConfig.json"
SaveConfigButton.Activated:Connect(function()
    PlayClickSound()
    local Config = {
        FOV = 120, TrackingStrength = 0.20, TeamCheck = true,
        AimEnabled = false, ESPEnabled = false, FOVCircleEnabled = false
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

-- Menu Dragging
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
