-- Configurações globais do jogo
local GameConfig = {}

-- Configurações de Rounds
GameConfig.RoundDuration = 180 -- segundos
GameConfig.LobbyDuration = 30
GameConfig.CountdownDuration = 5
GameConfig.MinPlayersToStart = 2
GameConfig.MaxPlayersPerTeam = 10
GameConfig.MaxPlayersTotal = 20

-- Configurações de Saúde
GameConfig.PlayerHealth = 100
GameConfig.HeadHealthMultiplier = 2.5

-- Configurações de Armas
GameConfig.DefaultWeapon = "AK47"
GameConfig.WeaponSlots = 5
GameConfig.SwitchWeaponCooldown = 0.5

-- Configurações de Munição
GameConfig.MaxAmmoCarried = 300
GameConfig.MaxMagazineSize = 30

-- Configurações de Movimento
GameConfig.WalkSpeed = 16
GameConfig.SprintSpeed = 24
GameConfig.CrouchSpeed = 8
GameConfig.JumpPower = 50

-- Configurações de Equipes
GameConfig.Teams = {
	Terrorists = {Name = "Terrorists", Color = BrickColor.new("Bright red")},
	CounterTerrorists = {Name = "Counter-Terrorists", Color = BrickColor.new("Bright blue")},
}

-- Configurações de Matchmaking
GameConfig.EnableAutoBalance = true
GameConfig.EnableFriendlyFire = false

-- Configurações de Anti-Exploit
GameConfig.MaxMovementSpeed = 50
GameConfig.MaxJumpHeight = 100
GameConfig.KickOnSuspiciousActivity = true
GameConfig.LogSuspiciousActivity = true

-- Configurações de DataStore
GameConfig.SaveDataInterval = 30 -- segundos
GameConfig.DataStoreRetries = 3

-- Configurações de Economia
GameConfig.KillReward = 250
GameConfig.HeadshotReward = 500
GameConfig.AssistReward = 100
GameConfig.RoundWinReward = 1000
GameConfig.RoundLossReward = 250
GameConfig.InitialMoney = 2400
GameConfig.MoneyPerRound = 800

-- Configurações de Mapa
GameConfig.MapSize = 256
GameConfig.SpawnHeight = 50
GameConfig.PhysicsTickrate = 1/60

-- Configurações de HUD
GameConfig.ShowCrosshair = true
GameConfig.ShowDamageIndicators = true
GameConfig.ShowKillFeed = true
GameConfig.KillFeedDuration = 5

-- Configurações de Rede
GameConfig.PacketLossThreshold = 0.15
GameConfig.PingWarningThreshold = 250

return GameConfig
