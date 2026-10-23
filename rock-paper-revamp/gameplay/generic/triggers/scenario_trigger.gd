extends GameplayTrigger
class_name ScenarioTrigger

## The scenario to check for. Note that this checks last round's scenario.
@export var target_scenario: GameStats.ResolutionScenario

func is_met(game_stats: GameStats):
	return game_stats.last_scenario == target_scenario
