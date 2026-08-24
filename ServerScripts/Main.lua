-- ============================================================================
-- ROBLOX FPS GAME - MAIN SERVER SCRIPT
-- Script: ServerScriptService
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- CONFIGURAÇÕES
local ROUND_TIME = 180
local LOBBY_TIME = 30
local MIN_PLAYERS = 1
local PLAYER_HEALTH = 100

-- ESTADO DO JOGO
local GameState = {
	Status = "Lobby",
	Round = 0,
	RoundTime = 0,
}

local PlayerData = {}

-- ============================================================================
-- SETUP REMOTES
-- ============================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
if ReplicatedStorage:FindFirstChild("Events") then
	ReplicatedStorage:FindFirstChild("Events"):Destroy()
end

local Events = Instance.new("Folder")
Events.Name = "Events"
Events.Parent = ReplicatedStorage

local fireEvent = Instance.new("RemoteEvent")
fireEvent.Name = "Fire"
fireEvent.Parent = Events

local damageEvent = Instance.new("RemoteEvent")
damageEvent.Name = "Damage"
damageEvent.Parent = Events

local updateStateEvent = Instance.new("RemoteEvent")
updateStateEvent.Name = "UpdateState"
updateStateEvent.Parent = Events

local deathEvent = Instance.new("RemoteEvent")
deathEvent.Name = "Death"
deathEvent.Parent = Events

-- ============================================================================
-- BUILD MAP
-- ============================================================================

local function BuildMap()
	if game.Workspace:FindFirstChild("GameMap") then
		game.Workspace:FindFirstChild("GameMap"):Destroy()
	end

	local GameMap = Instance.new("Folder")
	GameMap.Name = "GameMap"
	GameMap.Parent = game.Workspace

	-- Chão
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Shape = Enum.PartType.Block
	floor.Size = Vector3.new(200, 1, 200)
	floor.TopSurface = Enum.SurfaceType.Smooth
	floor.BottomSurface = Enum.SurfaceType.Smooth
	floor.BrickColor = BrickColor.new("Dark stone grey")
	floor.Material = Enum.Material.Concrete
	floor.CanCollide = true
	floor.Anchored = true
	floor.CFrame = CFrame.new(0, 0, 0)
	floor.Parent = GameMap

	-- Paredes
	local wall1 = Instance.new("Part")
	wall1.Name = "Wall1"
	wall1.Shape = Enum.PartType.Block
	wall1.Size = Vector3.new(200, 20, 1)
	wall1.BrickColor = BrickColor.new("Medium stone grey")
	wall1.Material = Enum.Material.Brick
	wall1.CanCollide = true
	wall1.Anchored = true
	wall1.CFrame = CFrame.new(0, 10, -99.5)
	wall1.Parent = GameMap

	local wall2 = Instance.new("Part")
	wall2.Name = "Wall2"
	wall2.Shape = Enum.PartType.Block
	wall2.Size = Vector3.new(200, 20, 1)
	wall2.BrickColor = BrickColor.new("Medium stone grey")
	wall2.Material = Enum.Material.Brick
	wall2.CanCollide = true
	wall2.Anchored = true
	wall2.CFrame = CFrame.new(0, 10, 99.5)
	wall2.Parent = GameMap

	local wall3 = Instance.new("Part")
	wall3.Name = "Wall3"
	wall3.Shape = Enum.PartType.Block
	wall3.Size = Vector3.new(1, 20, 200)
	wall3.BrickColor = BrickColor.new("Medium stone grey")
	wall3.Material = Enum.Material.Brick
	wall3.CanCollide = true
	wall3.Anchored = true
	wall3.CFrame = CFrame.new(-99.5, 10, 0)
	wall3.Parent = GameMap

	local wall4 = Instance.new("Part")
	wall4.Name = "Wall4"
	wall4.Shape = Enum.PartType.Block
	wall4.Size = Vector3.new(1, 20, 200)
	wall4.BrickColor = BrickColor.new("Medium stone grey")
	wall4.Material = Enum.Material.Brick
	wall4.CanCollide = true
	wall4.Anchored = true
	wall4.CFrame = CFrame.new(99.5, 10, 0)
	wall4.Parent = GameMap

	-- Spawn T (Esquerda)
	local spawnT = Instance.new("Folder")
	spawnT.Name = "SpawnT"
	spawnT.Parent = GameMap

	for i = 1, 3 do
		local sp = Instance.new("Part")
		sp.Name = "Spawn" .. i
		sp.Shape = Enum.PartType.Block
		sp.Size = Vector3.new(5, 0.5, 5)
		sp.Transparency = 1
		sp.CanCollide = false
		sp.Anchored = true
		sp.CFrame = CFrame.new(-40 + (i * 15), 2, -60)
		sp.Parent = spawnT
	end

	-- Spawn CT (Direita)
	local spawnCT = Instance.new("Folder")
	spawnCT.Name = "SpawnCT"
	spawnCT.Parent = GameMap

	for i = 1, 3 do
		local sp = Instance.new("Part")
		sp.Name = "Spawn" .. i
		sp.Shape = Enum.PartType.Block
		sp.Size = Vector3.new(5, 0.5, 5)
		sp.Transparency = 1
		sp.CanCollide = false
		sp.Anchored = true
		sp.CFrame = CFrame.new(40 - (i * 15), 2, 60)
		sp.Parent = spawnCT
	end

	print("✓ Mapa criado")
end

-- ============================================================================
-- PLAYER INITIALIZATION
-- ============================================================================

local function InitPlayer(player)
	PlayerData[player.UserId] = {
		Player = player,
		Health = PLAYER_HEALTH,
		Team = nil,
		Alive = false,
		Kills = 0,
		Deaths = 0,
	}
end

-- ============================================================================
-- SPAWN PLAYER
-- ============================================================================

local function SpawnPlayer(player, team)
	local data = PlayerData[player.UserId]
	data.Team = team
	data.Health = PLAYER_HEALTH
	data.Alive = true

	if player.Character then
		player.Character:Destroy()
	end

	-- Criar modelo básico
	local character = Instance.new("Model")
	character.Name = player.Name
	character.Parent = game.Workspace

	-- HumanoidRootPart
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Shape = Enum.PartType.Block
	root.Size = Vector3.new(2, 2, 1)
	root.CanCollide = false
	root.TopSurface = Enum.SurfaceType.Smooth
	root.BottomSurface = Enum.SurfaceType.Smooth
	root.Parent = character

	-- Head
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(2, 1, 1)
	head.BrickColor = BrickColor.new("Pastel brown")
	head.TopSurface = Enum.SurfaceType.Smooth
	head.BottomSurface = Enum.SurfaceType.Smooth
	head.Parent = character

	-- Weld head ao root
	local neck = Instance.new("Weld")
	neck.Name = "Neck"
	neck.Part0 = root
	neck.Part1 = head
	neck.C0 = CFrame.new(0, 1, 0)
	neck.Parent = root

	-- Humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = PLAYER_HEALTH
	humanoid.Parent = character

	-- Escolher spawn
	local spawnFolder = game.Workspace.GameMap:FindFirstChild(team == "T" and "SpawnT" or "SpawnCT")
	local spawns = spawnFolder:GetChildren()
	local randomSpawn = spawns[math.random(1, #spawns)]

	character:MoveTo(randomSpawn.Position + Vector3.new(0, 3, 0))
	player.Character = character

	-- Humanoid hit
	humanoid.Died:Connect(function()
		data.Alive = false
		data.Deaths = data.Deaths + 1
	end)

	print("✓ " .. player.Name .. " spawn na equipe " .. team)
end

-- ============================================================================
-- FIRE RAYCAST
-- ============================================================================

fireEvent.OnServerEvent:Connect(function(player, origin, direction)
	local data = PlayerData[player.UserId]
	if not data or not data.Alive then return end

	-- Raycast
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {player.Character}

	local result = game.Workspace:Raycast(origin, direction * 1000, rayParams)

	if result then
		local hit = result.Instance
		local hitCharacter = hit.Parent
		local hitPlayer = Players:GetPlayerFromCharacter(hitCharacter)

		if hitPlayer and hitPlayer ~= player then
			local victimData = PlayerData[hitPlayer.UserId]
			if victimData then
				local damage = hit.Name == "Head" and 50 or 25
				victimData.Health = victimData.Health - damage

				if victimData.Health <= 0 then
					data.Kills = data.Kills + 1
					victimData.Alive = false
					if hitCharacter:FindFirstChild("Humanoid") then
						hitCharacter.Humanoid.Health = 0
					end
					print("💀 " .. player.Name .. " matou " .. hitPlayer.Name)
				end

				damageEvent:FireAllClients(hitPlayer.UserId, victimData.Health)
			end
		end
	end
end)

-- ============================================================================
-- ROUND MANAGEMENT
-- ============================================================================

local function StartRound()
	GameState.Status = "Playing"
	GameState.Round = GameState.Round + 1
	GameState.RoundTime = ROUND_TIME

	updateStateEvent:FireAllClients(GameState)

	local players = Players:GetPlayers()
	local tCount = 0

	for _, p in pairs(players) do
		if tCount < #players / 2 then
			SpawnPlayer(p, "T")
			tCount = tCount + 1
		else
			SpawnPlayer(p, "CT")
		end
	end

	print("🎮 Round " .. GameState.Round .. " iniciado")

	-- Countdown de tempo
	for i = ROUND_TIME, 1, -1 do
		GameState.RoundTime = i
		updateStateEvent:FireAllClients(GameState)
		wait(1)
	end

	GameState.Status = "RoundEnd"
	updateStateEvent:FireAllClients(GameState)
	wait(5)
	GameState.Status = "Lobby"
end

local function GameLoop()
	while true do
		if GameState.Status == "Lobby" then
			if #Players:GetPlayers() >= MIN_PLAYERS then
				wait(LOBBY_TIME)
				StartRound()
			end
		end
		wait(1)
	end
end

-- ============================================================================
-- PLAYER EVENTS
-- ============================================================================

Players.PlayerAdded:Connect(function(player)
	InitPlayer(player)
	print("✓ " .. player.Name .. " entrou")
end)

Players.PlayerRemoving:Connect(function(player)
	PlayerData[player.UserId] = nil
	print("✗ " .. player.Name .. " saiu")
end)

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

print("🚀 Iniciando FPS...")
BuildMap()
GameLoop()
