extends AnimationPlayer

# Load constants file
onready var C = constants

onready var animationTree = get_parent().get_node("AnimationTree")
onready var animationState = animationTree.get(C.playback)
onready var animationRoot = animationTree.get("tree_root")

func advance_node():
	animationState.travel("HoldBow")
	
func set_carry():
	animationRoot.get_node("DrawBow").blend_mode = 2
	print(animationRoot.get_node("DrawBow").blend_mode)
