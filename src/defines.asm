; the version of this patch Va.b.c
!version_a                   = $03
!version_b                   = $00
!version_c                   = $00

; controller regs
!mario_byetudlr_hold         = $15
!mario_byetudlr_frame        = $16
!mario_axlr_hold             = $17
!mario_axlr_frame            = $18
!util_byetudlr_hold          = $0DA2
!util_byetudlr_frame         = $0DA6
!util_byetudlr_mask          = $0DAA
!util_axlr_hold              = $0DA4
!util_axlr_frame             = $0DA8
!util_axlr_mask              = $0DAC

; number of frames dropped this execution frame
!dropped_frames              = $FB ; 2 bytes, 16-bit value
; number of frames used this execution frame (basically !dropped_frames + 1)
!real_frames                 = $FD
; copy of 60Hz counter used to calculate lag frames
!previous_sixty_hz           = $FE
; 60Hz counter, resistant to lag frames
!counter_sixty_hz            = $FF
; the timer copied from the apu
!apu_timer_latch             = $146C ; 2 bytes, 16-bit value
!apu_timer_difference        = $146E

; stripe image buffer for the overworld record times on the border
; actually overwrites some sprite table, but that doesn't matter because this is only used on the overworld
!dynamic_stripe_image        = $1938 ; 19 bytes

; flag to tell whether to start level midway or not
!start_midway                = $13C8

; variables that are restored upon a level reset
!restore_level_powerup       = $19D8
!restore_level_itembox       = $19D9
!restore_level_yoshi         = $19DA
!restore_level_boo_ring      = $19DB ; 4 bytes
!restore_level_igt           = $19DF
!restore_level_xpos          = $19E0 ; 2 bytes, 16-bit value
; variables that are restored upon a room reset
!restore_room_powerup        = $19E2
!restore_room_itembox        = $19E3
!restore_room_yoshi          = $19E4
!restore_room_boo_ring       = $19E5 ; 4 bytes
!restore_room_takeoff        = $19E9
!restore_room_item           = $19EA
!restore_room_rng            = $19EB ; 4 bytes
!restore_room_coins          = $19EF
!restore_room_igt            = $19F0 ; 3 bytes
!restore_room_xpos           = $19F3 ; 2 bytes, 16-bit value
!restore_room_dragoncoins    = $19F5

; determines when to load state from different level
!load_state_timer            = $0EF9
!load_state_delay            = $40

; determines when to start scrolling fast through options
!fast_scroll_timer           = $0EF9
!fast_scroll_delay           = $20
; timer to display the text on the overworld menu
!text_timer                  = $0EFA

; the number of frames to skip for the slowdown feature (0 = normal)
!slowdown_speed              = $0EFB

; flag that is set if we are in the overworld menu
!in_overworld_menu           = $0EFC

; status flags for each of the overworld menu options
!status_table                = $700320 ; $20 bytes
!status_yellow               = $700320
!status_green                = $700321
!status_red                  = $700322
!status_blue                 = $700323
!status_special              = $700324
!status_powerup              = $700325
!status_itembox              = $700326
!status_yoshi                = $700327
!status_enemy                = $700328
!status_erase                = $700329
!status_slots                = $70032A
!status_controller           = $70032B
!status_pause                = $70032C
!status_timedeath            = $70032D
!status_music                = $70032E
!status_drop                 = $70032F
!status_states               = $700330
!status_statedelay           = $700331
!status_dynmeter             = $700332
!status_slowdown             = $700333
!status_help                 = $700334
!status_lrreset              = $700335
!status_memoryhi             = $700336 ; x
!status_memorylo             = $700337 ; x
!status_moviesave            = $700338
!status_movieload            = $700339
!status_playername           = $70033A ; 4 bytes
!status_region               = $70033E
; $7003FF reserved for future expansion
!backup_status_table         = $7006C0 ; $20 bytes


; location of cape interaction table at $1FE2
!new_cape_interaction        = $0F5E

; the number of the most recent primary/secondary exit used
; technically applicable on level enter, but not used
!recent_screen_exit          = $0F19
; flag whether !recent_screen_exit is a primary or secondary exit number
!recent_secondary_flag       = $0F1A
; the slot of the currently carried sprite
; obviously if 2+ items are held, this only holds the highest slot number
!held_item_slot              = $0F1B
; what action to take upon pressing L+R (level reset, room reset, room advance)
!l_r_function                = $0F1C
; when set, the timers will not tick
!freeze_timer_flag           = $0F1D
; flag to show the level has loaded (used for level_load hijack)
!level_loaded                = $0F1E
; flag to show if the level has been completed
!level_finished              = $0F1F
; pointer into sram to tell what exit to store records to
!save_timer_address          = $0F20 ; 3 bytes

; flags used to determine which record(s) to save to and to store record properties
!record_used_powerup         = $0F23
!record_used_cape            = $0F24
!record_used_yoshi           = $0F25
!record_used_orb             = $0F26
!record_lunar_dragon         = $0F27

; the number of options in the overworld menu
!number_of_options           = 31
; the currently highlighted selection on the overworld menu
!current_selection           = $0F28
; flag to show "delete mode", that is, if the player presses select to delete data
!erase_records_flag          = $0F29
; the translevel mario is hovering over on the overworld
!potential_translevel        = $0F2A

; if we are currently in movie playback mode
!in_playback_mode            = $0F2B
; if we are currently in movie record mode
!in_record_mode              = $0F2C
; movie version
!movie_version               = $00
; movie location
!movie_location              = $7FA000

; level and room timers
!level_timer_minutes         = $0F3A
!level_timer_seconds         = $0F3B
!level_timer_frames          = $0F3C
!restore_level_timer_minutes = $0F3D
!restore_level_timer_seconds = $0F3E
!restore_level_timer_frames  = $0F3F
!room_timer_minutes          = $0F42
!room_timer_seconds          = $0F43
!room_timer_frames           = $0F44
!pause_timer_minutes         = $0F45
!pause_timer_seconds         = $0F46
!pause_timer_frames          = $0F47

; the entire revamped status bar
!status_bar                  = $1F2F ; 120 bytes

; status bar meters
!sb_mariox                   = $1F2F ; 2 bytes
!sb_takeoff                  = $1F4D ; 2 bytes
!sb_pmeter                   = $1F6B ; 2 bytes
!sb_name                     = $1F89 ; 4 bytes
!sb_yoshisp                  = $1F32 ; 2 bytes
!sb_itemsp                   = $1F50 ; 2 bytes
!sb_leveltimer               = $1F35 ; 7 bytes
!sb_roomtimer                = $1F53 ; 7 bytes
!sb_pausetimer               = $1F71 ; 7 bytes
!sb_lag                      = $1F90 ; 6 bytes
!sb_coins                    = $1F40 ; 3 bytes
!sb_memory                   = $1F5E ; 4 bytes
!sb_igt                      = $1F7C ; 5 bytes
!sb_movie                    = $1F9A ; 13 bytes
!sb_slowdown                 = $1F44 ; 1 byte
!sb_input                    = $1F45 ; 8x3 bytes

!sbbowser_leveltimer         = $0258 ; 7x4 bytes
!sbbowser_leveltimer_2       = $0436 ; 7 bytes
!sbbowser_roomtimer          = $03A0 ; 7x4 bytes
!sbbowser_roomtimer_2        = $0488 ; 7 bytes
!sbbowser_pausetimer         = $02C0 ; 7x4 bytes
!sbbowser_pausetimer_2       = $0450 ; 7 bytes

; oam slots for added objects
!oam_slot_sprite_slots       = $2C
!oam_slot_bowser_level_timer = $30
!oam_slot_bowser_room_timer  = $68

; translevels that have swapped exits
!translevel_swap_exit_A      = $04 ; dgh
!translevel_swap_exit_B      = $41 ; fgh

; the translevels of the current movies, 00 = no movie
!level_movie_slots           = $0695 ; 3 bytes
; x and y positions of the levels in above table
!level_movie_x_pos           = $0698 ; 3 bytes
!level_movie_y_pos           = $069B ; 3 bytes
; which times to display on the overworld
!ow_display_times            = $069E

; flag = #$BD if save data exists
!save_data_exists            = $700000
; mario's overworld position
!save_overworld_submap       = $700001
!save_overworld_x            = $700002 ; 2 bytes, 16-bit value
!save_overworld_y            = $700004 ; 2 bytes, 16-bit value
!save_overworld_animation    = $700008
; flag = #$BD if a save state exists and to allow load state
!save_state_exists           = $700006
; flag if a save state or room reset/advance or slowdown was used in this run
; used to detect when to not save the record (no cheating!)
!spliced_run                 = $700007
; player name
!player_name                 = $70000C ; 4 bytes

