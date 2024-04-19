###################################################
# Part of Bosca Ceoil Blue                        #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

extends Node

signal song_loaded()
signal song_pattern_changed()

var voice_manager: VoiceManager = null
var music_player: MusicPlayer = null

## Current edited song.
var current_song: Song = null
## Current edited pattern in the song, by index.
var current_pattern_index: int = -1
## Current edited instrument in the song, by index.
var current_instrument_index: int = -1

var instrument_themes: Dictionary = {
	ColorPalette.PALETTE_BLUE:   preload("res://gui/theme/instrument_theme_blue.tres"),
	ColorPalette.PALETTE_PURPLE: preload("res://gui/theme/instrument_theme_purple.tres"),
	ColorPalette.PALETTE_RED:    preload("res://gui/theme/instrument_theme_red.tres"),
	ColorPalette.PALETTE_ORANGE: preload("res://gui/theme/instrument_theme_orange.tres"),
	ColorPalette.PALETTE_GREEN:  preload("res://gui/theme/instrument_theme_green.tres"),
	ColorPalette.PALETTE_CYAN:   preload("res://gui/theme/instrument_theme_cyan.tres"),
	ColorPalette.PALETTE_GRAY:   preload("res://gui/theme/instrument_theme_gray.tres"),
}


func _init() -> void:
	voice_manager = VoiceManager.new()
	music_player = MusicPlayer.new(self)


func _ready() -> void:
	# Driver must be ready by this time.

	music_player.initialize()
	create_new_song()


# Song management.

func create_new_song() -> void:
	if music_player.is_playing():
		music_player.stop_playback()
	
	current_song = Song.create_default_song()
	current_pattern_index = 0
	current_instrument_index = 0
	
	music_player.reset_driver()
	music_player.start_playback()
	
	song_loaded.emit()


func load_ceol_song() -> void:
	pass


func save_ceol_song() -> void:
	pass


# Song editing.

func get_current_pattern() -> Pattern:
	if not current_song:
		return null
	if current_pattern_index < 0 || current_pattern_index >= current_song.patterns.size():
		return null
	
	return current_song.patterns[current_pattern_index]


func get_current_instrument() -> Instrument:
	if not current_song:
		return null
	if current_instrument_index < 0 || current_instrument_index >= current_song.instruments.size():
		return null
	
	return current_song.instruments[current_instrument_index]


func get_current_instrument_theme() -> Theme:
	var current_instrument := get_current_instrument()
	if not current_instrument || not instrument_themes.has(current_instrument.color_palette):
		return instrument_themes[ColorPalette.PALETTE_GRAY]
	
	return instrument_themes[current_instrument.color_palette]


func get_instrument_theme(instrument: Instrument) -> Theme:
	if not instrument_themes.has(instrument.color_palette):
		return instrument_themes[ColorPalette.PALETTE_GRAY]
	
	return instrument_themes[instrument.color_palette]


func set_pattern_size(value: int) -> void:
	if not current_song:
		return
	
	current_song.pattern_size = value
	song_pattern_changed.emit()


func set_bar_size(value: int) -> void:
	if not current_song:
		return
	
	current_song.bar_size = value
	song_pattern_changed.emit()


func set_bpm(value: int) -> void:
	if not current_song:
		return
	
	current_song.bpm = value
	music_player.update_driver_bpm()
