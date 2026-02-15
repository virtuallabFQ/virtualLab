extends Node

@warning_ignore("unused_signal")
signal interaction_focused(context: String, new_icon: Texture2D, override_icon: bool)
@warning_ignore("unused_signal")
signal interaction_unfocused()

@warning_ignore("unused_signal")
signal toggle_game_paused(is_paused: bool)
