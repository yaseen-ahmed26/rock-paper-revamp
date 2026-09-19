extends ModifierEffect
class_name EditMoveEffect

enum MoveTarget {
	## Target Rock
	ROCK,
	## Target Paper
	PAPER,
	## Target Scissors
	SCISSORS,
	## Target what the player used last round
	PLAYER_LAST_USED,
	## Target what the AI used last round
	AI_LAST_USED,
	## Pick a random move
	RANDOMISE
}

## The move to target for the change
@export var move_target: MoveTarget
## The new text to display
@export var new_display_text: String
## Disable the move from being used
@export var lock_move: bool = false
## Swap the actual value of the move buttom. Does not need to be the same as the display text.
@export var swap_value_to: String

func apply(game_stats: GameStats):
	var move_to_replace: String
	
	match move_target:
		MoveTarget.ROCK, MoveTarget.PAPER, MoveTarget.SCISSORS:
			move_to_replace = MoveTarget.keys()[move_target].to_lower()
		MoveTarget.PLAYER_LAST_USED:
			move_to_replace = game_stats.player_history[-1]
		MoveTarget.AI_LAST_USED:
			move_to_replace = game_stats.computer_history[-1]
		MoveTarget.RANDOMISE:
			move_to_replace = game_stats.DEFAULT_MOVES.pick_random().to_lower()
	
	var new_move_stat: MoveStat = MoveStat.new(
		new_display_text if not new_display_text.is_empty() else move_to_replace.capitalize(), 
		swap_value_to.to_lower() if not swap_value_to.is_empty() else move_to_replace, 
		lock_move
	)

	game_stats.btn_stats[move_to_replace] = new_move_stat
