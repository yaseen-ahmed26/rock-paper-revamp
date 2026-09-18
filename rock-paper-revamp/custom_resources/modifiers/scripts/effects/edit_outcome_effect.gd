extends ModifierEffect
class_name EditOutcomeEffect

const SHOW_IF: Dictionary = {
	"force_outcome": "force_specific_outcome"
}

## Invert the outcome. Wins become losses and losses become wins.
@export var invert: bool = false
## Cancel out the current outcome.
@export var discard: bool = false
## Override the round outcome and set a new one.
@export var force_specific_outcome: bool = false
## How many times to apply the current outcome. Resets on new round.
@export var multiply: int = 1 
## The new outcome if force_specific_outcome is True.
@export var new_outcome: GameStats.RoundOutcome = GameStats.RoundOutcome.DRAW

func apply(game_stats: GameStats) -> void:
	if force_specific_outcome:
		game_stats.outcome = new_outcome
	elif discard:
		game_stats.outcome = GameStats.RoundOutcome.DISCARD
	elif invert:
		if game_stats.outcome == GameStats.RoundOutcome.WIN:
			game_stats.outcome = GameStats.RoundOutcome.LOSS
		elif game_stats.outcome == GameStats.RoundOutcome.LOSS:
			game_stats.outcome = GameStats.RoundOutcome.WIN
			
	if multiply != 1:
		game_stats.outcome_multiplier = multiply
