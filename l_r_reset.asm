!recent_screen_exit     = $0F1A
!recent_secondary_flag  = $0F1B
!l_r_function           = $0F1D

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

ORG $1A8000

; this code is run when the player presses L + R in a level to reset the current room
activate_room_reset:
		; if we are in first room of level, just level reset
		LDA $141A ; sublevel count
		BNE .room_reset
		JSL activate_level_reset
		RTL
		
		LDA #$01
		STA !l_r_function
		
	.room_reset:
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
		
	.no_item:
		JSR restore_common_aspects
		
		RTL

; this code is run when the player presses L + R + A + B in a level to reset the entire level
activate_level_reset:
		LDA #$02
		STA !l_r_function
		
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
		JSR get_level_low_byte
		LDY #$00
		JSR set_global_exit
		JSR trigger_screen_exit
		
		RTL

; this code is run when the player presses L + R + X + Y in a level to advance to the next room
activate_room_advance:
		LDA #$03
		STA !l_r_function
		
		LDA #$01
		STA !spliced_run
		RTL

; set the screen exit for all screens to be set to the exit number in A
; Y = 1 iff this exit is a secondary exit
set_global_exit:
		LDX #$20
	.loop_exits:
		DEX
		STA $19B8,X ; exit table
		BNE .loop_exits
		STY $1B93 ; secondary exit flag
		RTS

; get the low byte of the level number, not the translevel number
get_level_low_byte:
		LDA $13BF ; translevel number
		CMP #$25
		BCC .done
		SEC
		SBC #$24
	.done:
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

; actually trigger the screen exit
trigger_screen_exit:
		LDA #$05
		STA $71 ; player animation trigger
		STZ $88
		STZ $89 ; pipe timers
		RTS