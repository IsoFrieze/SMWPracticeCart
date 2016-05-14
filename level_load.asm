!restore_level_powerup  = $19D8
!restore_level_itembox  = $19D9
!restore_level_yoshi    = $19DA
!restore_level_boo_ring = $19DB ; 4 bytes
!restore_level_igt      = $19DF
!restore_room_powerup   = $19E0
!restore_room_itembox   = $19E1
!restore_room_yoshi     = $19E2
!restore_room_boo_ring  = $19E3 ; 4 bytes
!restore_room_takeoff   = $19E7
!restore_room_item      = $19E8
!restore_room_rng       = $19E9 ; 4 bytes
!restore_room_coins     = $19ED
!restore_room_igt       = $19EE ; 3 bytes

!recent_screen_exit     = $0F1A
!recent_secondary_flag  = $0F1B
!l_r_function           = $0F1D

ORG $128000

; this code is run once on level load (during the black screen)
level_load:
		PHP
		PHB
		PHK
		PLB
		SEP #$20
		
		LDA !l_r_function
		BEQ .no_l_r_reset
		
		DEC A
		ASL A
		TAX
		JSR (l_r_functions,X)
		BRA .merge
		
	.no_l_r_reset:
		JSR save_room_properties
		
		LDA $141A ; sublevel count
		BNE .merge
		JSR save_level_properties
		
	.merge:
		LDA $148F ; held item flag
		DEC A
		STA !held_item_slot
		STZ !l_r_function
		STZ !freeze_timer_flag
		LDA #$28
		STA $0F30 ; igt timer
		
		PLB
		PLP
		RTL
		
l_r_functions:
		dw setup_room_reset
		dw setup_level_reset
		dw setup_room_advance

; prepare the level load if we just did a room reset
setup_room_reset:
		LDA #$01
		STA !spliced_run
		
		LDA !restore_room_powerup
		STA $19 ; powerup
		LDA !restore_room_itembox
		STA $0DC2 ; item box
		LDA !restore_room_yoshi
		STA $13C7 ; yoshi color
		STA $0DBA ; ow yoshi color
		STA $0DC1 ; persistent yoshi
		LDA !restore_room_coins
		STA $0DBF ; coins
		LDA !restore_room_takeoff
		STA $149F ; takeoff
		LDA !restore_room_igt
		STA $0F31
		LDA !restore_room_igt+1
		STA $0F32
		LDA !restore_room_igt+2
		STA $0F33 ; in game timer
		LDA !restore_level_timer_minutes
		STA !level_timer_minutes
		LDA !restore_level_timer_seconds
		STA !level_timer_seconds
		LDA !restore_level_timer_frames
		STA !level_timer_frames
		DEC $141A ; sublevel count
		
		LDX #$03
	.loop_tables:
		LDA !restore_room_boo_ring,X
		STA $0FAE,X ; boo ring angles
		LDA !restore_room_rng,X
		STA $148B,X ; rng
		DEX
		BPL .loop_tables
		
		LDA !restore_room_item
		BEQ .no_item
		STA $9E ; sprite 0 id
		LDA #$0B ; carried
		STA $14C8 ; sprite 0 status
		
	.no_item:
		JSR restore_common_aspects
		RTS

; prepare the level load if we just did a level reset
setup_level_reset:		
		STZ !spliced_run
		
		LDA !restore_level_powerup
		STA $19 ; powerup
		LDA !restore_level_itembox
		STA $0DC2 ; item box
		LDA !restore_level_yoshi
		STA $13C7 ; yoshi color
		STA $0DBA ; ow yoshi color
		STA $0DC1 ; persistent yoshi
		STZ $0DBF ; coins
		STZ $149F ; takeoff
		LDA !restore_level_igt
		STA $0F31
		STZ $0F32
		STZ $0F33 ; in game timer
		STZ !level_timer_minutes
		STZ !level_timer_seconds
		STZ !level_timer_frames
		
		; set msb so it's not 00, which is a special case for entering the level
		; we'll turn this byte into fnnnnnnn, f = 0 if just entered level, n = sublevel count
		LDA #$80 
		STA $141A ; sublevel count
		
		LDX #$03
	.loop_tables:
		LDA !restore_level_boo_ring,X
		STA $0FAE,X ; boo ring angles
		STZ $148B,X ; rng
		STZ $1A,X ; layer 1 x/y positions
		STZ $1E,X ; layer 2 x/y positions
		DEX
		BPL .loop_tables
		
		JSR restore_common_aspects
		
	.done:
		RTS

; prepare the level load if we just did a room advance
setup_room_advance:
		LDA #$01
		STA !spliced_run
		
		JSR save_room_properties
		JSR restore_common_aspects
		
		RTS

; restore things that are common to both room and level resets
restore_common_aspects:
		STZ $1420 ; dragon coins
		STZ $36
		STZ $37 ; mode 7 angle
		STZ $14AF ; on/off switch
		STZ $1432 ; coin snake
		STZ $1B9F ; reznor floor
		STZ $14B1
		STZ $14B6 ; bowser timers
		STZ $1884 ; bowser HP
		STZ $1496
		STZ $1497 ; mario animation timers
		LDA #$FF
		STA $1B9D ; layer 3 tide timer
		STZ $1B9A ; scrolling background
		STZ !room_timer_minutes
		STZ !room_timer_seconds
		STZ !room_timer_frames
		RTS
		
; save everything after entering a new room
save_room_properties:
		LDA $19 ; powerup
		STA !restore_room_powerup
		LDA $0DC2 ; item box
		STA !restore_room_itembox
		LDA $187A ; riding yoshi flag
		BNE .yoshi_exists
		STZ !restore_room_yoshi
		BRA .yoshi_done
	.yoshi_exists:
		LDA $13C7 ; yoshi color
		STA !restore_room_yoshi
	.yoshi_done:
		LDA $149F ; takeoff
		STA !restore_room_takeoff
		LDA $0DBF ; coins
		STA !restore_room_coins
		
		LDX #$0B
	.loop_item:
		LDA $14C8,X ; sprite status
		CMP #$0B ; carried
		BEQ .restore_item
		DEX
		BPL .loop_item
		BRA .item_done
	.restore_item:
		LDA $9E,X ; sprite id
		STA !restore_room_item
	.item_done:

		LDX #$03
	.loop_tables:
		LDA $0FAE,X ; boo ring angle
		STA !restore_room_boo_ring,X
		LDA $148B,X ; rng
		STA !restore_room_rng,X
		DEX
		BPL .loop_tables
		
		LDX #$02
	.loop_time:
		LDA $0F31,X ; timer
		STA !restore_room_igt,X
		DEX
		BPL .loop_time
		
		LDA !level_timer_minutes
		STA !restore_level_timer_minutes
		LDA !level_timer_seconds
		STA !restore_level_timer_seconds
		LDA !level_timer_frames
		STA !restore_level_timer_frames
		STZ !room_timer_minutes
		STZ !room_timer_seconds
		STZ !room_timer_frames
		
		RTS
		
; save everything after entering a new level
save_level_properties:
		LDA $19 ; powerup
		STA !restore_level_powerup
		LDA $0DC2 ; item box
		STA !restore_level_itembox
		LDA $187A ; riding yoshi flag
		BNE .yoshi_exists
		STZ !restore_level_yoshi
		BRA .yoshi_done
	.yoshi_exists:
		LDA $13C7 ; yoshi color
		STA !restore_level_yoshi
	.yoshi_done:
		
		LDX #$03
	.loop_tables:
		LDA $0FAE,X ; boo ring angle
		STA !restore_level_boo_ring,X
		DEX
		BPL .loop_tables
		
		STZ !level_timer_minutes
		STZ !level_timer_seconds
		STZ !level_timer_frames
		
		REP #$10
		LDX #$017F
	.loop_memory:
		STZ $19F8,X ; item memory
		DEX
		BPL .loop_memory
		SEP #$10
		
		RTS

; copy screen exit to backup registers
; this isn't done in the above code because $17BB is only available during the load routine
level_load_exit_table:
		LDA $1B93
		STA !recent_secondary_flag
		LDA $19B8,X ; exit table
		STA $17BB ; exit backup
		STA !recent_screen_exit
		RTL

; save starting time to backup register
; this isn't done in the above code because X is only the level index during the load routine
level_load_timer:
		LDA $0584D7,X ; timer table
		STA !restore_level_igt
		RTL