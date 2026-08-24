-- ============================================================================
-- ROBLOX FPS GAME - HUD DISPLAY
-- Local Script: StarterGui
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- ============================================================================
-- CROSSHAIR
-- ============================================================================

local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.new(0, 30, 0, 30)
crosshair.Position = UDim2.new(0.5, -15, 0.5, -15)
crosshair.BackgroundTransparency = 1
crosshair.Parent = screenGui

-- Linhas
local line1 = Instance.new("Frame")
line1.Size = UDim2.new(0, 15, 0, 1)
line1.Position = UDim2.new(0.5, -7, 0.5, 0)
line1.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
line1.BorderSizePixel = 0
line1.Parent = crosshair

local line2 = Instance.new("Frame")
line2.Size = UDim2.new(0, 1, 0, 15)
line2.Position = UDim2.new(0.5, 0, 0.5, -7)
line2.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
line2.BorderSizePixel = 0
line2.Parent = crosshair

-- ============================================================================
-- HEALTH BAR
-- ============================================================================

local healthFrame = Instance.new("Frame")
healthFrame.Name = "Health"
healthFrame.Size = UDim2.new(0, 200, 0, 30)
healthFrame.Position = UDim2.new(0, 20, 1, -50)
healthFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
healthFrame.BorderSizePixel = 0
healthFrame.Parent = screenGui

local healthBar = Instance.new("Frame")
healthBar.Name = "Bar"
healthBar.Size = UDim2.new(1, 0, 1, 0)
healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
healthBar.BorderSizePixel = 0
healthBar.Parent = healthFrame

local healthText = Instance.new("TextLabel")
healthText.Name = "Text"
healthText.Text = "100/100"
healthText.TextSize = 14
healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
healthText.BackgroundTransparency = 1
healthText.Size = UDim2.new(1, 0, 1, 0)
healthText.Parent = healthFrame

-- ============================================================================
-- TIMER
-- ============================================================================

local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "Timer"
timerLabel.Text = "3:00"
timerLabel.TextSize = 32
timerLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
timerLabel.BackgroundTransparency = 1
timerLabel.Size = UDim2.new(0, 100, 0, 50)
timerLabel.Position = UDim2.new(0.5, -50, 0, 20)
timerLabel.Parent = screenGui

-- ============================================================================
-- KILLS
-- ============================================================================

local killsLabel = Instance.new("TextLabel")
killsLabel.Name = "Kills"
killsLabel.Text = "Kills: 0"
killsLabel.TextSize = 18
killsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
killsLabel.BackgroundTransparency = 1
killsLabel.Size = UDim2.new(0, 150, 0, 30)
killsLabel.Position = UDim2.new(1, -170, 0, 20)
killsLabel.Parent = screenGui

-- ============================================================================
-- REMOTE EVENTS
-- ============================================================================

local Events = game.ReplicatedStorage:WaitForChild("Events")

Events.UpdateState.OnClientEvent:Connect(function(state)
	if state.Status == "Playing" then
		local minutes = math.floor(state.RoundTime / 60)
		local seconds = state.RoundTime % 60
		timerLabel.Text = string.format("%d:%02d", minutes, seconds)
	end
end)

Events.Damage.OnClientEvent:Connect(function(playerId, health)
	if playerId == player.UserId then
		healthBar.Size = UDim2.new(math.clamp(health / 100, 0, 1), 0, 1, 0)
		healthText.Text = math.floor(health) .. "/100"

		if health > 66 then
			healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		elseif health > 33 then
			healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
		else
			healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		end
	end
end)

-- ============================================================================
-- UPDATE HEALTH LOOP
-- ============================================================================

RunService.RenderStepped:Connect(function()
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			healthBar.Size = UDim2.new(math.clamp(humanoid.Health / 100, 0, 1), 0, 1, 0)
			healthText.Text = math.floor(humanoid.Health) .. "/100"

			if humanoid.Health > 66 then
				healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			elseif humanoid.Health > 33 then
				healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
			else
				healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			end
		end
	end
end)

print("✓ HUD loaded")
