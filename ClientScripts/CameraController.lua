-- ============================================================================
-- ROBLOX FPS COMPLETE GAME - CLIENT CAMERA & INPUT (SHIFT LOCK)
-- Local Script: StarterPlayer > StarterCharacterScripts > CameraController
-- ============================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local head = character:WaitForChild("Head")
local mouse = player:GetMouse()

local camera = workspace.CurrentCamera
camera.FieldOfView = 90

-- ============================================================================
-- SHIFT LOCK STATE
-- ============================================================================

local shiftLockActive = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		shiftLockActive = true
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		shiftLockActive = false
	end
end)

-- ============================================================================
-- CAMERA ANGLES
-- ============================================================================

local cameraX = 0 -- Rotação horizontal (Yaw)
local cameraY = 0 -- Rotação vertical (Pitch)

local sensitivity = 0.005
local maxPitch = math.rad(85)
local minPitch = math.rad(-85)

-- ============================================================================
-- INPUT STATE
-- ============================================================================

local moveInput = Vector3.new(0, 0, 0)
local isCrouching = false
local currentWeapon = "AK47"

-- ============================================================================
-- MOUSE MOVEMENT
-- ============================================================================

local lastMousePos = Vector2.new(0, 0)
local firstMouse = true

mouse.Move:Connect(function()
	if not shiftLockActive then return end
	
	local currentMousePos = Vector2.new(mouse.X, mouse.Y)
	
	if not firstMouse then
		local delta = currentMousePos - lastMousePos
		
		cameraX = cameraX - (delta.X * sensitivity)
		cameraY = math.clamp(cameraY - (delta.Y * sensitivity), minPitch, maxPitch)
	end
	
	firstMouse = false
	lastMousePos = currentMousePos
end)

-- ============================================================================
-- KEYBOARD INPUT
-- ============================================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.W then
		moveInput = moveInput + Vector3.new(0, 0, -1)
	elseif input.KeyCode == Enum.KeyCode.S then
		moveInput = moveInput + Vector3.new(0, 0, 1)
	elseif input.KeyCode == Enum.KeyCode.A then
		moveInput = moveInput + Vector3.new(-1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.D then
		moveInput = moveInput + Vector3.new(1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		isCrouching = true
	elseif input.KeyCode == Enum.KeyCode.Space then
		if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	elseif input.KeyCode == Enum.KeyCode.R then
		local GameEvents = game.ReplicatedStorage:FindFirstChild("GameEvents")
		if GameEvents then
			GameEvents.ReloadWeapon:FireServer(currentWeapon)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.W then
		moveInput = moveInput - Vector3.new(0, 0, -1)
	elseif input.KeyCode == Enum.KeyCode.S then
		moveInput = moveInput - Vector3.new(0, 0, 1)
	elseif input.KeyCode == Enum.KeyCode.A then
		moveInput = moveInput - Vector3.new(-1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.D then
		moveInput = moveInput - Vector3.new(1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		isCrouching = false
	end
end)

-- ============================================================================
-- WEAPON SWITCHING (1-5 keys)
-- ============================================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.Key1 then
		currentWeapon = "Knife"
		print("✓ Switched to: " .. currentWeapon)
	elseif input.KeyCode == Enum.KeyCode.Key2 then
		currentWeapon = "Deagle"
		print("✓ Switched to: " .. currentWeapon)
	elseif input.KeyCode == Enum.KeyCode.Key3 then
		currentWeapon = "AK47"
		print("✓ Switched to: " .. currentWeapon)
	elseif input.KeyCode == Enum.KeyCode.Key4 then
		currentWeapon = "M4A1"
		print("✓ Switched to: " .. currentWeapon)
	elseif input.KeyCode == Enum.KeyCode.Key5 then
		currentWeapon = "AWP"
		print("✓ Switched to: " .. currentWeapon)
	end
end)

-- ============================================================================
-- WEAPON FIRE
-- ============================================================================

local canFire = true

mouse.Button1Down:Connect(function()
	if not canFire or not character.Parent or humanoid.Health <= 0 or not shiftLockActive then
		return
	end
	
	canFire = false
	
	local origin = head.CFrame.Position + head.CFrame.LookVector * 0.5
	local direction = head.CFrame.LookVector
	
	local GameEvents = game.ReplicatedStorage:FindFirstChild("GameEvents")
	if GameEvents then
		GameEvents.FireWeapon:FireServer(origin, direction, currentWeapon)
	end
	
	wait(0.1)
	canFire = true
end)

-- ============================================================================
-- UPDATE CHARACTER ROTATION
-- ============================================================================

local function UpdateCharacterRotation()
	if not shiftLockActive or not character.Parent then return end
	
	-- Aplicar rotação horizontal ao corpo (Yaw)
	local yawCFrame = CFrame.Angles(0, -cameraX, 0)
	rootPart.CFrame = rootPart.CFrame:ToWorldSpace(CFrame.new() * yawCFrame:Inverse())
	
	-- Aplicar rotação vertical à cabeça (Pitch)
	local headCurrentCFrame = head.CFrame
	head.CFrame = rootPart.CFrame * CFrame.new(0, 0.5, 0) * CFrame.Angles(-cameraY, -cameraX, 0)
end

-- ============================================================================
-- UPDATE CAMERA POSITION
-- ============================================================================

local function UpdateCamera()
	if not character.Parent then return end
	
	local headPos = head.Position
	local headCFrame = head.CFrame
	
	if shiftLockActive then
		-- Camera offset para shift lock (lado da cabeça)
		local offset = headCFrame.RightVector * 0.5 + headCFrame.UpVector * 0.2
		local cameraPos = headPos + offset
		
		camera.CFrame = CFrame.new(cameraPos, cameraPos + headCFrame.LookVector)
	else
		-- Camera padrão
		camera.CFrame = CFrame.new(headPos + head.CFrame.LookVector * 0.1, headPos + head.CFrame.LookVector)
	end
end

-- ============================================================================
-- MOVEMENT
-- ============================================================================

RunService.Heartbeat:Connect(function()
	if not character.Parent or humanoid.Health <= 0 then
		return
	end
	
	local moveDir = moveInput
	if moveDir.Magnitude > 0 then
		moveDir = moveDir.Unit
		
		local speed = 16 -- Caminhada padrão
		if shiftLockActive then
			speed = 24 -- Sprint
		end
		if isCrouching then
			speed = 8 -- Agachado
		end
		
		humanoid.WalkSpeed = speed
		
		if shiftLockActive then
			-- Com shift lock, movimento relativo à câmera
			local cameraCFrame = camera.CFrame
			local forwardDir = -cameraCFrame.LookVector
			local rightDir = cameraCFrame.RightVector
			
			local worldMoveDir = (rightDir * moveDir.X + forwardDir * moveDir.Z).Unit
			humanoid:Move(worldMoveDir, false)
		else
			-- Sem shift lock, movimento padrão
			humanoid:Move(moveDir, false)
		end
	else
		humanoid:Move(Vector3.new(0, 0, 0), false)
	end
end)

-- ============================================================================
-- MAIN RENDER LOOP
-- ============================================================================

RunService.RenderStepped:Connect(function()
	if not character.Parent or humanoid.Health <= 0 then
		return
	end
	
	UpdateCharacterRotation()
	UpdateCamera()
end)

print("✓ Camera controller with Shift Lock loaded")
