; the version of this patch Va.b.c
!version_a                   = $03
!version_b                   = $27
!version_c                   = $0A

; practice cart data exists!
!version_alpha_code          = $BD
!version_beta_code           = $67

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

; the scanline at which the gameplay loop ends
!lagometer_line              = $0F2D

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
!restore_room_tide           = $19F6
!restore_room_rng_index      = $0DDB ; 3 bytes
!restore_item_memory         = $7F9C7B

; rng index
!rng_index                   = $1487 ; 3 bytes

; determines when to load state from different level
!load_state_timer            = $0EF9
!load_state_delay            = $40

; determines when to start scrolling fast through options
!fast_scroll_timer           = $0EF9
!fast_scroll_delay           = $20
; timer to display the text on the overworld menu
!text_timer                  = $0EFA

; the number of frames to skip for the slowdown feature (0 = normal)
!slowdown_speed              = $7E0EFB

; flag that is set if we are in the overworld menu
!in_overworld_menu           = $0EFC
!overworld_menu_mode         = $0EFD
!current_meter_selection     = $0EFE

; the number of options in the overworld menu
!number_of_options_pg1       = 32
!number_of_options_pg2       = 16
!number_of_options           = !number_of_options_pg1+!number_of_options_pg2
; status flags for each of the overworld menu options
!status_table                = $705000 ; $37 bytes
!status_yellow               = !status_table+$00 ; off | on
!status_green                = !status_table+$01 ; off | on
!status_red                  = !status_table+$02 ; off | on
!status_blue                 = !status_table+$03 ; off | on
!status_special              = !status_table+$04 ; disable | enable
!status_powerup              = !status_table+$05 ; small | big | cape | fire | ...
!status_itembox              = !status_table+$06 ; empty | mush | fire | star | cape | ...
!status_yoshi                = !status_table+$07 ; none | yellow | blue | red | green | ...
!status_enemy                = !status_table+$08 ;
!status_erase                = !status_table+$09 ; all | level | slots... | statusbars...
!status_slots                = !status_table+$0a ; none | onscreen | offscreen | all | bounce
!status_controller           = !status_table+$0b ; 1P | 1/2 P | 2P
!status_pause                = !status_table+$0c ; disable | enable
!status_timedeath            = !status_table+$0d ; death | life
!status_music                = !status_table+$0e ; music | mute
!status_drop                 = !status_table+$0f ; disable | normal
!status_states               = !status_table+$10 ; disable | enable | exclude RNG/framerule
!status_statedelay           = !status_table+$11 ; count...
!status_dynmeter             = !status_table+$12 ; none | speed | takeout | pmeter | spx | yoshispx | itemspx | itemspeed
!status_slowdown             = !status_table+$13 ; enable | disable
!status_layout               = !status_table+$14 ; default | lagcalibrated | empty | custom1 | custom2 | custom3
!status_lrreset              = !status_table+$15 ; enable | disable
!status_scorelag             = !status_table+$16 ; none | count...
!status_lagometer            = !status_table+$17 ; off | on
!status_moviesave            = !status_table+$18 ; sram1 | sram2
!status_movieload            = !status_table+$19 ; sram1 | sram2 | demo1 | demo2
!status_playername           = !status_table+$1a ; 4 bytes
!status_region               = !status_table+$1e ; J | U | E1.0 | E1.1
!status_fast_mode            = !status_table+$1f

!status_fast_mode_yellow         = !status_table+$20 ; off | on
!status_fast_mode_green          = !status_table+$21 ; off | on
!status_fast_mode_red            = !status_table+$22 ; off | on
!status_fast_mode_blue           = !status_table+$23 ; off | on
!status_fast_mode_special        = !status_table+$24 ; disable | enable
!status_fast_mode_start_powerup  = !status_table+$25 ; small | big | cape | fire | ...
!status_fast_mode_start_item     = !status_table+$26 ; empty | mush | fire | star | cape | ...
!status_fast_mode_start_yoshi    = !status_table+$27 ; none | yellow | blue | red | green | ...
!status_fast_mode_end_powerup    = !status_table+$28 ; small | big | cape | fire | ...
!status_fast_mode_end_item       = !status_table+$29 ; empty | mush | fire | star | cape | ...
!status_fast_mode_end_yoshi      = !status_table+$2A ; none | yellow | blue | red | green | ...
!status_fast_mode_midway         = !status_table+$2B ; start | midway
!status_fast_mode_exit_type      = !status_table+$2C ; normal | secret | Ss | Death | 
!status_fast_mode_timer          = !status_table+$2D ; none | brief | always
!status_fast_mode_heads_up       = !status_table+$2E ; none | exit | all
!status_fast_mode_delete         = !status_table+$2F ; delete | add

!backup_status_table         = $705100 ; $20 bytes

; table for status bar meters
!statusbar_meters            = $704D50 ; $120 bytes (4x24)x3
!statusbar_layout_ptr        = $F8 ; 3 bytes

; location of cape interaction table at $1FE2
!new_cape_interaction        = $0F5E

; the number of the most recent primary/secondary exit used
; technically applicable on level enter, but not used
!recent_screen_exit          = $0F19
; flag whether !recent_screen_exit is a primary or secondary exit number
!recent_secondary_flag       = $0F1A
; the slot of the currently carried sprite
; obviously if 2+ items are held, this only holds the highest slot number
!held_item_slot              = $7E0F1B
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
!record_used_foreign_item    = $0F2E
!record_lunar_dragon         = $0F27


; the currently highlighted selection on the overworld menu
!current_selection           = $0F28
; flag to show "delete mode", that is, if the player presses select to delete data
!erase_records_flag          = $0F29
; the translevel mario is hovering over on the overworld
!potential_translevel        = $0F2A

; if set, reset yoshi status after returning from a no-yoshi level on the overworld
!give_yoshi_back             = $F6

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
!status_bar                  = $1F30 ; 160 bytes

; oam slots for added objects
!oam_slot_sprite_slots       = $2C

; translevels that have swapped exits
!translevel_swap_exit_A      = $04 ; dgh
!translevel_swap_exit_B      = $41 ; fgh

; the number of intentional exit types completed upon system boot
!exit_type_count             = $0DF5
; sum of all intentional exit type times (only valid if all exit types completed)
; also used to keep track of a fast mode run time
!total_frames                = $0DF6
!total_seconds               = $0DF7
!total_minutes               = $0DF8
!total_hours                 = $0DF9

; the translevels of the current movies, 00 = no movie
!level_movie_slots           = $0695 ; 3 bytes
; x and y positions of the levels in above table
!level_movie_x_pos           = $0698 ; 3 bytes
!level_movie_y_pos           = $069B ; 3 bytes
; which times to display on the overworld
!ow_display_times            = $069E

; temporary table used by the break handler
!break_value_table           = $0703

; y position of layer1 for bowser fight
!bowser_layer1_y_pos         = $1415

; bowser fight phase for phase advance
!bowser_phase_tracker        = $F7

; flag = #$BD if save data exists
!save_data_exists            = $700000
; mario's overworld position
!save_overworld_submap       = $700001
!save_overworld_x            = $700002 ; 2 bytes, 16-bit value
!save_overworld_y            = $700004 ; 2 bytes, 16-bit value
!save_overworld_animation    = $700008
; flag = #$BD if a save state exists and to allow load state
!save_state_exists           = $700006
; flag if a save state or room reset/advance or slowdown or lagless was used in this run
; used to detect when to not save the record (no cheating!)
!spliced_run                 = $700007
; flag = #$BD if the RTC is available on this system
!clock_available             = $700009

!menu_screen_moved           = $0AFD
!menu_tile_upload_bytes      = $0AFE
!menu_tile_upload_location   = $0B00

!loram_savestate_location      = $7023A0 ;$705000? loram savestate in wram?
!restore_status_from_backup    = $70000A
!level_enter_flag              = $58
!fast_mode_save_current_header = $06B0
!fast_mode_save_current_level  = $06C0
!most_recent_exit              = $06C1
!level_is_no_yoshi             = $06A5
!midway_enable_flag            = $06A4
!fast_mode_tile_timer          = $06A3   ; Timer for flashing route tiles
!fast_mode_start_play          = $06A2   ; Used to determine if play should start on next overworld load
!fast_mode_current_level       = $06A0   ; 

!fast_mode_max_route_length    = (!fast_mode_save_2_header-!fast_mode_save_1)/10
!fast_mode_header_length       = $10
!fast_mode_save_1_header       = $705200 ; #Levels
!fast_mode_save_1              = !fast_mode_save_1_header+!fast_mode_header_length

!fast_mode_save_2_header       = $705600 ; #Levels
!fast_mode_save_2              = !fast_mode_save_2_header+!fast_mode_header_length

!fast_mode_save_3_header       = $705A00 ; #Levels
!fast_mode_save_3              = !fast_mode_save_3_header+!fast_mode_header_length
