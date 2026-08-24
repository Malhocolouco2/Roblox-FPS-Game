-- ============================================================================
-- ROBLOX FPS GAME - CLIENT CAMERA & CONTROLS (CAMERA FIXED)
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
-- VARIÁVEIS DE CÂMERA
-- ============================================================================

local cameraX = 0
local cameraY = 0
local sensitivity = 0.003
local maxLookAngle = math.rad(85)

local shiftLocked = false

-- ============================================================================
-- SHIFT LOCK DETECTOR
-- ============================================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		shiftLocked = true
		mouse.Icon = ""
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		shiftLocked = false
		mouse.Icon = ""
	end
end)

-- ============================================================================
-- MOVIMENTO
-- ============================================================================

local moveForward = false
local moveBackward = false
local moveLeft = false
local moveRight = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.W then
		moveForward = true
	elseif input.KeyCode == Enum.KeyCode.S then
		moveBackward = true
	elseif input.KeyCode == Enum.KeyCode.A then
		moveLeft = true
	elseif input.KeyCode == Enum.KeyCode.D then
		moveRight = true
	elseif input.KeyCode == Enum.KeyCode.Space then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.W then
		moveForward = false
	elseif input.KeyCode == Enum.KeyCode.S then
		moveBackward = false
	elseif input.KeyCode == Enum.KeyCode.A then
		moveLeft = false
	elseif input.KeyCode == Enum.KeyCode.D then
		moveRight = false
	end
end)

-- ============================================================================
-- TIRO
-- ============================================================================

local canFire = true

mouse.Button1Down:Connect(function()
	if not canFire or not character.Parent or humanoid.Health <= 0 or not shiftLocked then
		return
	end

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
-- MAIN LOOP - CAMERA ROTATION
-- ============================================================================

local lastMouseX = 0
local lastMouseY = 0

RunService.RenderStepped:Connect(function()
	if not character.Parent or not shiftLocked then return end

	-- OBTER POSIÇÃO DO MOUSE AGORA
	local mouseX = mouse.X
	local mouseY = mouse.Y

	-- CALCULAR DIFERENÇA
	local deltaX = mouseX - lastMouseX
	local deltaY = mouseY - lastMouseY

	-- ATUALIZAR ÚLTIMA POSIÇÃO
	lastMouseX = mouseX
	lastMouseY = mouseY

	-- APLICAR ROTAÇÃO
	if deltaX ~= 0 or deltaY ~= 0 then
		cameraX = cameraX - (deltaX * sensitivity)
		cameraY = math.clamp(cameraY - (deltaY * sensitivity), -maxLookAngle, maxLookAngle)
	end

	-- APLICAR ROTAÇÃO AO PERSONAGEM
	local yaw = CFrame.Angles(0, -cameraX, 0)
	local pitch = CFrame.Angles(-cameraY, 0, 0)

	rootPart.CFrame = CFrame.new(rootPart.Position) * yaw
	head.CFrame = rootPart.CFrame * CFrame.new(0, 0.5, 0) * pitch

	-- POSICIONAR CÂMERA (lado da cabeça)
	local cameraOffset = head.CFrame.RightVector * 0.5 + head.CFrame.UpVector * 0.2
	local cameraPos = head.Position + cameraOffset

	camera.CFrame = CFrame.new(cameraPos, cameraPos + head.CFrame.LookVector)
end)

-- ============================================================================
-- MOVIMENTO LOOP
-- ============================================================================

RunService.Heartbeat:Connect(function()
	if not character.Parent or humanoid.Health <= 0 then
		return
	end

	local moveDir = Vector3.new(0, 0, 0)

	if moveForward then
		moveDir = moveDir + rootPart.CFrame.LookVector
	end
	if moveBackward then
		moveDir = moveDir - rootPart.CFrame.LookVector
	end
	if moveLeft then
		moveDir = moveDir - rootPart.CFrame.RightVector
	end
	if moveRight then
		moveDir = moveDir + rootPart.CFrame.RightVector
	end

	humanoid.WalkSpeed = shiftLocked and 20 or 16

	if moveDir.Magnitude > 0 then
		humanoid:Move(moveDir.Unit, false)
	else
		humanoid:Move(Vector3.new(0, 0, 0), false)
	end
end)

print("✓ Client loaded - Camera FIXED")
