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

local camera = workspace.CurrentCamera
camera.FieldOfView = 90

-- ============================================================================
-- SHIFT LOCK SETUP
-- ============================================================================

local shiftLockActive = false
local shiftLockOffset = Vector3.new(0.5, 0, 0)

-- Detectar Shift para ativar Shift Lock
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.LeftShift and not gameProcessed then
		shiftLockActive = true
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		shiftLockActive = false
	end
end)

-- ============================================================================
-- CAMERA VARIABLES
-- ============================================================================

local camX = 0
local camY = 0
local sensitivity = 0.005
local maxLookDown = math.rad(85)
local maxLookUp = math.rad(85)

-- ============================================================================
-- INPUT VARIABLES
-- ============================================================================

local moveDirection = Vector3.new(0, 0, 0)
local isSprintng = false
local isCrouching = false
local currentWeapon = "AK47"

-- ============================================================================
-- CAMERA ROTATION
-- ============================================================================

local lastMousePos = UserInputService:GetMouseLocation()

local function UpdateCameraRotation()
	local currentMousePos = UserInputService:GetMouseLocation()
	local mouseDelta = currentMousePos - lastMousePos
	lastMousePos = currentMousePos
	
	if shiftLockActive then
		camX = camX - (mouseDelta.X * sensitivity)
		camY = math.clamp(camY - (mouseDelta.Y * sensitivity), -maxLookUp, maxLookDown)
	end
end

local function UpdateCameraPosition()
	if not character.Parent then return end
	
	local headPos = head.Position
	local headCFrame = head.CFrame
	
	if shiftLockActive then
		-- Camera offset para shift lock (lado direito da cabeça)
		local cameraPos = headPos + headCFrame.RightVector * shiftLockOffset.X + headCFrame.UpVector * 0.3
		camera.CFrame = CFrame.new(cameraPos, cameraPos + headCFrame.LookVector)
	else
		-- Camera normal seguindo a cabeça sem rotation
		camera.CFrame = CFrame.new(headPos + head.CFrame.LookVector * 0.1, headPos + headCFrame.LookVector)
	end
end

-- ============================================================================
-- APPLY CAMERA ROTATION TO CHARACTER
-- ============================================================================

local function ApplyCharacterRotation()
	if shiftLockActive then
		local yawCFrame = CFrame.Angles(0, -camX, 0)
		local pitchCFrame = CFrame.Angles(-camY, 0, 0)
		
		-- Aplicar apenas yaw ao corpo (rotação horizontal)
		rootPart.CFrame = rootPart.CFrame:ToWorldSpace(CFrame.new() * yawCFrame:Inverse())
		
		-- Aplicar pitch à cabeça (rotação vertical)
		local neckWeld = head:FindFirstChild("Neck") or rootPart:FindFirstChild("Neck")
		if neckWeld and neckWeld:IsA("Weld") then
			-- Armazenar o C0 padrão se ainda não estiver armazenado
			if not neckWeld:GetAttribute("DefaultC0") then
				neckWeld:SetAttribute("DefaultC0", neckWeld.C0)
			end
			local defaultC0 = neckWeld:GetAttribute("DefaultC0")
			neckWeld.C0 = defaultC0 * pitchCFrame
		end
	end
end

-- ============================================================================
-- KEYBOARD INPUT
-- ============================================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.W then
		moveDirection = moveDirection + Vector3.new(0, 0, -1)
	elseif input.KeyCode == Enum.KeyCode.S then
		moveDirection = moveDirection + Vector3.new(0, 0, 1)
	elseif input.KeyCode == Enum.KeyCode.A then
		moveDirection = moveDirection + Vector3.new(-1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.D then
		moveDirection = moveDirection + Vector3.new(1, 0, 0)
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
		moveDirection = moveDirection - Vector3.new(0, 0, -1)
	elseif input.KeyCode == Enum.KeyCode.S then
		moveDirection = moveDirection - Vector3.new(0, 0, 1)
	elseif input.KeyCode == Enum.KeyCode.A then
		moveDirection = moveDirection - Vector3.new(-1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.D then
		moveDirection = moveDirection - Vector3.new(1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		isCrouching = false
	end
end)

-- ============================================================================
-- WEAPON FIRE
-- ============================================================================

local canFire = true
local fireRate = 0.1
local mouse = player:GetMouse()

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
	
	wait(fireRate)
	canFire = true
end)

-- ============================================================================
-- WEAPON SWITCHING
-- ============================================================================

for i = 1, 5 do
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode["Key" .. i] then
			local weapons = {"Knife", "Deagle", "AK47", "M4A1", "AWP"}
			currentWeapon = weapons[i] or currentWeapon
			print("✓ Switched to: " .. currentWeapon)
		end
	end)
end

-- ============================================================================
-- MOVEMENT
-- ============================================================================

RunService.Heartbeat:Connect(function()
	if not character.Parent or humanoid.Health <= 0 then
		return
	end
	
	local moveDir = moveDirection
	if moveDir.Magnitude > 0 then
		moveDir = moveDir.Unit
		
		-- Determinar velocidade
		local speed = 16 -- Caminhada padrão
		if shiftLockActive then
			speed = 24 -- Sprint com shift lock
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
	
	if shiftLockActive then
		UpdateCameraRotation()
		ApplyCharacterRotation()
	end
	
	UpdateCameraPosition()
end)

print("✓ Camera controller with Shift Lock loaded")
