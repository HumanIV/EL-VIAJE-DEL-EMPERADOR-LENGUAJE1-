extends Node
var initialized = false
var max_health = 3
var max_lives = 3
var current_health = 3
var current_lives = 3

func initialize(initial_health, initial_lives):
	max_health = initial_health
	max_lives = initial_lives
	current_health = initial_health
	current_lives = initial_lives
	initialized = true

func reset():
	current_health = max_health
	current_lives = max_lives

func reset_health():
	current_health=max_health
