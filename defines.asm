; the version of this patch Va.b.c
!version_a                   = $02
!version_b                   = $03
!version_c                   = $02

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
!apu_timer_difference        = $146E ; 2 bytes, 16-bit value

; stripe image buffer for the overworld record times on the border
; actually overwrites some sprite table, but that doesn't matter because this is only used on the overworld
!dynamic_stripe_image        = $1938 ; 19 bytes

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

; location of cape interaction table at $1FE2
!new_cape_interaction        = $0F5E

; status flags for each of the overworld menu options
!status_table                = $0EF9 ; $20 bytes
!status_yellow               = $0EF9
!status_green                = $0EFA
!status_red                  = $0EFB
!status_blue                 = $0EFC
!status_special              = $0EFD
!status_powerup              = $0EFE
!status_itembox              = $0EFF
!status_yoshi                = $0F00
!status_enemy                = $0F01
!status_erase                = $0F02
!status_slots                = $0F03
!status_fractions            = $0F04
!status_pause                = $0F05
!status_timedeath            = $0F06
!status_music                = $0F07
!status_drop                 = $0F08
!status_states               = $0F09
!status_dynmeter             = $0F0A
!status_exit                 = $0F0B
; $0F0C - $0F18 reserved for future expansion

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
!number_of_options           = 19
; the currently highlighted selection on the overworld menu
!current_selection           = $0F28
; flag to show "delete mode", that is, if the player presses select to delete data
!erase_records_flag          = $0F29
; the translevel mario is hovering over on the overworld
!potential_translevel        = $0F2A

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

; the entire revamped status bar
!status_bar                  = $1F2F ; 120 bytes

; oam slots for added objects
!oam_slot_sprite_slots       = $2C
!oam_slot_bowser_level_timer = $30
!oam_slot_bowser_room_timer  = $68

; flag = #$BD if save data exists
!save_data_exists            = $700000
; mario's overworld position
!save_overworld_submap       = $700001
!save_overworld_x            = $700002 ; 2 bytes, 16-bit value
!save_overworld_y            = $700004 ; 2 bytes, 16-bit value
!save_overworld_animation    = $700008
; flag = #$BD if a save state exists and to allow load state
!save_state_exists           = $700006
; flag if a save state or room reset/advance was used in this run
; used to detect when to not save the record (no cheating!)
!spliced_run                 = $700007
; flag = #$BD if it is detected that this platform does not support the needed sram
; for complete save states; this will prevent save states from being saved across
; levels and power cycles
!use_poverty_save_states     = $70001F

