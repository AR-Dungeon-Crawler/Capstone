extends Node

# UI Elements
var arrows = 1
var speed = 0
var accuracy = 0

var player
var ACCELERATION = 500
var MAX_SPEED = 50
var FRICTION = 500

# Screen dimensions (type: int)
var width = ProjectSettings.get("display/window/size/width")
var height = ProjectSettings.get("display/window/size/height")

# Strings
const playback = "parameters/playback"
const up = "ui_up"
const down = "ui_down"
const left = "ui_left"
const right = "ui_right"
const idleBlend = "parameters/Idle/blend_position"
const moveBlend = "parameters/Move/blend_position"
const moveReverseBlend = "parameters/MoveReverse/blend_position"
const drawBowBlend = "parameters/DrawBow/blend_position"
const holdBowBlend = "parameters/HoldBow/blend_position"
