extends RefCounted
class_name RoundStats

var house_bank: int = 0
var house_suit: CardBase.Suit
var next_house_suit: CardBase.Suit

var outcome: GameStats.RoundOutcome = GameStats.RoundOutcome.CLEARED
var scenario: GameStats.ResolutionScenario = GameStats.ResolutionScenario.NONE
var round_activated_modifiers: Array[StringName] = []

var current_round: int = 0
var current_streak: int = 0

var player_raw_damage_taken: int = 0
var player_damage_blocked: int = 0
var player_actual_points_lost: int = 0
var player_defense_broken: bool = false
var player_ignored_defense: bool = false
var player_bank_gained: int = 0
var player_bank: int = 0
var player_defense: int = 0
var player_overshield: int = 0
var player_lead_card: CardBase = null
var player_chain_card: CardBase = null
var player_special_card: CardBase = null
var player_played_honest: bool = false

var computer_raw_damage_taken: int = 0
var computer_damage_blocked: int = 0
var computer_actual_points_lost: int = 0
var computer_defense_broken: bool = false
var computer_ignored_defense: bool = false
var computer_bank_gained: int = 0
var computer_bank: int = 0
var computer_defense: int = 0
var computer_overshield: int = 0
var computer_lead_card: CardBase = null
var computer_chain_card: CardBase = null
var computer_special_card: CardBase = null
var computer_played_honest: bool = false
