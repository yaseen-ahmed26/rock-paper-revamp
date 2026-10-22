extends RefCounted
class_name RoundStats

var house_bank: int = 0
var house_suit: CardBase.Suit = CardBase.Suit.ROCK
var next_house_suit: CardBase.Suit = CardBase.Suit.PAPER

var outcome: GameStats.RoundOutcome = GameStats.RoundOutcome.CLEARED
var scenario: GameStats.ResolutionScenario = GameStats.ResolutionScenario.NONE
var round_activated_modifiers: Array[StringName] = []

var current_round: int = 0
var current_streak: int = 0

var player_raw_damage_taken: int = 0
var player_damage_blocked: int
var player_actual_points_lost: int
var player_defense_broken: bool
var player_ignored_defense: bool
var player_bank_gained: int
var player_bank: int
var player_defense: int
var player_overshield: int
var player_lead_card: CardBase
var player_chain_card: CardBase
var player_special_card: CardBase

var computer_raw_damage_taken: int = 0
var computer_damage_blocked: int
var computer_actual_points_lost: int
var computer_defense_broken: bool
var computer_ignored_defense: bool
var computer_bank_gained: int
var computer_bank: int
var computer_defense: int
var computer_overshield: int
var computer_lead_card: CardBase
var computer_chain_card: CardBase
var computer_special_card: CardBase
