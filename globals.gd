extends Node

enum Goal {
	MOVED_CURSOR,
	PUSHED_BOX,
	PUSHED_BOX_INTO_CONTAINER,
	PUSHED_BOX_OUT_OF_CONTAINER,
	SOLVED_EQUATION,
	MATCHED_SHAPES,
}

var goal_achieved: Dictionary = {
	Goal.MOVED_CURSOR: false,
	Goal.PUSHED_BOX: false,
	Goal.PUSHED_BOX_INTO_CONTAINER: false,
	Goal.PUSHED_BOX_OUT_OF_CONTAINER: false,
	Goal.SOLVED_EQUATION: false,
	Goal.MATCHED_SHAPES: false,
}

signal achieved_goal(goal: Goal)

signal volume_changed(volume_db: float)


#func clear_goals() -> void:
	#for goal in goal_achieved:
		#goal_achieved[goal] = false
