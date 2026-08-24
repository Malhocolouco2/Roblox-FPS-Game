-- ============================================================================
-- ROBLOX FPS GAME - CLIENT CAMERA & CONTROLS
-- Local Script: StarterPlayer > StarterCharacterScripts
-- ============================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = script.Parent
local mouse = player:GetMouse()

-- Aguardar componentes
local rootPart = character:WaitForChild("HumanoidRootPart")
local head = character:WaitForChild("Head")
local humanoid = character:WaitForChild("Humanoid")

local camera = workspace.CurrentCamera

-- ============================================================================
-- SHIFT LOCK VARIABLES
-- ============================================================================

local shiftLocked = false
local mouseX = 0
local mouseY = 0
local lastMouseX = 0
local lastMouseY = 0
local sensitivity = 0.002

-- ============================================================================
-- MOVIMENTO
-- ============================================================================

local moveForward = false
local moveBackward = false
local moveLeft = false
local moveRight = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.W then moveForward = true
	elseif input.KeyCode == Enum.KeyCode.S then moveBackward = true
	elseif input.KeyCode == Enum.KeyCode.A then moveLeft = true
	elseif input.KeyCode == Enum.KeyCode.D then moveRight = true
	elseif input.KeyCode == Enum.KeyCode.LeftShift then shiftLocked = true
	elseif input.KeyCode == Enum.KeyCode.Space then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.W then moveForward = false
	elseif input.KeyCode == Enum.KeyCode.S then moveBackward = false
	elseif input.KeyCode == Enum.KeyCode.A then moveLeft = false
	elseif input.KeyCode == Enum.KeyCode.D then moveRight = false
	elseif input.KeyCode == Enum.KeyCode.LeftShift then shiftLocked = false
	end
end)

-- ============================================================================
-- TIRO
-- ============================================================================

local canFire = true

mouse.Button1Down:Connect(function()
	if not canFire or not character.Parent or humanoid.Health <= 0 or not shiftLocked then return end

	canFire = false

	local origin = head.CFrame.Position + head.CFrame.LookVector
	local direction = head.CFrame.LookVector

	local Events = game.ReplicatedStorage:FindFirstChild("Events")
	if Events then
		Events.Fire:FireServer(origin, direction)
	end

	wait(0.1)
	canFire = true
end)

-- ============================================================================
-- CAMERA LOOP
-- ============================================================================

RunService.RenderStepped:Connect(function()
	if not character.Parent then return end

	-- Pegar posição atual do mouse
	mouseX = mouse.X
	mouseY = mouse.Y

	if shiftLocked then
		-- Calcular delta
		local deltaX = mouseX - lastMouseX
		local deltaY = mouseY - lastMouseY

		-- Atualizar rotação
		local newYaw = rootPart.CFrame:ToEulerAnglesYXZ() + Vector3.new(0, -deltaX * sensitivity, 0)
		local pitchX = head.CFrame:ToEulerAnglesYXZ()
		local newPitch = math.clamp(pitchX - deltaY * sensitivity, -math.rad(80), math.rad(80))

		-- Aplicar rotação
		rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, newYaw.Y, 0)
		head.CFrame = rootPart.CFrame * CFrame.new(0, 0.5, 0) * CFrame.Angles(newPitch, newYaw.Y, 0)

		-- Camera offset
		local offset = rootPart.CFrame.RightVector * 0.4
		camera.CFrame = CFrame.new(head.Position + offset, head.Position + head.CFrame.LookVector)
	else
		-- Camera normal
		camera.CFrame = CFrame.new(head.Position, head.Position + head.CFrame.LookVector)
	end

	lastMouseX = mouseX
	lastMouseY = mouseY
end)

-- ============================================================================
-- MOVIMENTO LOOP
-- ============================================================================

RunService.Heartbeat:Connect(function()
	if not character.Parent or humanoid.Health <= 0 then return end

	local direction = Vector3.new(0, 0, 0)

	if moveForward then direction = direction + rootPart.CFrame.LookVector end
	if moveBackward then direction = direction - rootPart.CFrame.LookVector end
	if moveLeft then direction = direction - rootPart.CFrame.RightVector end
	if moveRight then direction = direction + rootPart.CFrame.RightVector end

	local speed = shiftLocked and 20 or 16
	humanoid.WalkSpeed = speed

	if direction.Magnitude > 0 then
		humanoid:Move(direction.Unit, false)
	else
		humanoid:Move(Vector3.new(0, 0, 0), false)
	end
end)

print("✓ Client loaded")
