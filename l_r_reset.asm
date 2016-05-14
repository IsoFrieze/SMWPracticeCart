ORG $1A8000

; this code is run when the player presses L + R in a level to reset the current room
activate_room_reset:
		; if we are in first room of level, just level reset
		LDA $141A ; sublevel count
		AND #$7F
		BNE .room_reset
		JSL activate_level_reset
		RTL
		
	.room_reset:
		LDA #$01
		STA !l_r_function
		
		LDA !recent_screen_exit
		LDY !recent_secondary_flag
		JSL set_global_exit
		JSR trigger_screen_exit
		
		RTL

; this code is run when the player presses L + R + A + B in a level to reset the entire level
activate_level_reset:
		LDA #$02
		STA !l_r_function
		
		JSR get_level_low_byte
		LDY #$00
		JSL set_global_exit
		JSR trigger_screen_exit
		
		RTL

; this code is run when the player presses L + R + X + Y in a level to advance to the next room
activate_room_advance:
		LDA #$03
		STA !l_r_function
		
		; X = level bank
		LDX #$00
		LDA $13BF ; translevel number
		CMP #$25
		BCC .low_level_bank
		INX
	.low_level_bank:
		
		LDA $141A ; sublevel count
		AND #$7F
			;STA $1F2B
		BNE .load_from_backup
		
		; we just entered the level, so backup may not be available
		; we know we entered via screen exit, not from secondary exit
		JSR get_level_low_byte
		LDY #$00
		BRA .merge
	.load_from_backup:
		; we are in some sublevel, so backup is available
		LDA !recent_screen_exit
		LDY !recent_secondary_flag
	
	.merge:
		JSR get_next_sensible_exit
		JSL set_global_exit
		JSR trigger_screen_exit
		
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
		RTL

; get the low byte of the level number, not the translevel number
get_level_low_byte:
		LDA $13BF ; translevel number
		CMP #$25
		BCC .done
		SEC
		SBC #$24
	.done:
		RTS

; actually trigger the screen exit
trigger_screen_exit:
		LDA #$05
		STA $71 ; player animation trigger
		STZ $88
		STZ $89 ; pipe timers
		
		LDA #$20 ; bow sound
		STA $1DF9 ; apu i/o
		RTS

; given the current sub/level, return a sub/level that 'advances' one room forward
; given A = level number low byte, X = level number high byte, Y = secondary exit flag
; return A = level number low byte / secondary exit number, Y = secondary exit flag
get_next_sensible_exit:
		PHP
		PHB
		PHK
		PLB
		CPX #$00
		BEQ .low_bank
		TAX
		CPY #$00
		BEQ .high_level_number
		LDA room_advance_table+$000,X
		LDY room_advance_table+$100,X
		BRA .done
	.high_level_number:
		LDA room_advance_table+$200,X
		LDY room_advance_table+$300,X
		BRA .done
		
	.low_bank:
		TAX
		CPY #$00
		BEQ .low_level_number
		LDA room_advance_table+$400,X
		LDY room_advance_table+$500,X
		BRA .done
	.low_level_number:
		LDA room_advance_table+$600,X
		LDY room_advance_table+$700,X
		
	.done:
		PLB
		PLP
		RTS
		
room_advance_table:
		; =======================================
		; This bin file contains 8 tables that hold screen exit data to be used
		; by the advance room function. Each table is 0x100 bytes long.
		; Table 1: exit number to take if last exit was a secondary exit, bank 1
		; Table 2: secondary exit flag for above table number
		; Table 3: exit number to take if last exit was a level exit, bank 1
		; Table 4: secondary exit flag for above table number
		; Table 5: exit number to take if last exit was a secondary exit, bank 0
		; Table 6: secondary exit flag for above table number
		; Table 7: exit number to take if last exit was a level exit, bank 0
		; Table 8: secondary exit flag for above table number
		incbin "room_advance_table.bin"
		; =======================================