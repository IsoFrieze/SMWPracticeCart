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

ORG $128000

; this code is run once on level load (during the black screen)
level_load:
		PHP
		PHB
		PHK
		PLB
		SEP #$20
		
		LDA !l_r_function
		BEQ .just_entered_level
		
		DEC A
		ASL A
		TAX
		JSR (l_r_functions,X)
		
	.just_entered_level:
		LDA $148F ; held item flag
		DEC A
		STA !held_item_slot
		STZ !dropped_frames
		STZ !dropped_frames+1
		STZ !l_r_function
		
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
		STA $0DBA ; yoshi color
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
		
		JSR restore_common_aspects
		
	.no_item:
		RTS

; prepare the level load if we just did a level reset
setup_level_reset:		
		STZ !spliced_run
		
		LDA !restore_level_powerup
		STA $19 ; powerup
		LDA !restore_level_itembox
		STA $0DC2 ; item box
		LDA !restore_level_yoshi
		STA $0DBA ; yoshi color
		STZ $0DBF ; coins
		STZ $149F ; takeoff
		LDA !restore_level_igt
		STA $0F31
		STZ $0F32
		STZ $0F33 ; in game timer
		STZ !level_timer_minutes
		STZ !level_timer_seconds
		STZ !level_timer_frames
		LDA #$FF
		STA $141A ; sublevel count
		
		LDX #$03
	.loop_tables:
		LDA !restore_level_boo_ring,X
		STA $0FAE,X ; boo ring angles
		STZ $148B,X ; rng
		DEX
		BPL .loop_tables
		
		JSR restore_common_aspects
		
		; ========
		; this block of code sucks, and needs to be moved to the level loading section
		LDA $13BF ; translevel
		CMP #$09
		BNE .done
		LDX #$07
	.loop_dp2:
		STZ $1A,X ; layer 1/2 x/y positions
		DEX
		BPL .loop_dp2
		; ========
		
	.done:
		RTS

; prepare the level load if we just did a room advance
setup_room_advance:
		LDA #$01
		STA !spliced_run
		
		; TODO
		
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