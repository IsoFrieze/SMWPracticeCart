!level_timer_minutes         = $0F3A
!level_timer_seconds         = $0F3B
!level_timer_frames          = $0F3C
!restore_level_timer_minutes = $0F3D
!restore_level_timer_seconds = $0F3E
!restore_level_timer_frames  = $0F3F
!room_timer_minutes          = $0F42
!room_timer_seconds          = $0F43
!room_timer_frames           = $0F44
!spliced_run                 = $0F19
!held_item_slot              = $0F1C
!freeze_timer_flag           = $0F1E

ORG $158000

; this code is run on every frame during the level game mode (after fade in completes)
level_tick:
		PHP
		PHB
		PHK
		PLB
		JSR display_coins
;		JSR display_time ; already done in original status bar routine
		JSR display_speed
		JSR display_takeoff
		JSR display_pmeter
		JSR display_timers
		JSR display_dropped_frames
		JSR display_input
		JSR display_yoshi_subpixel
		JSR display_held_subpixel
		PEA !level_timer_minutes
		JSR tick_timer
		PEA !room_timer_minutes
		JSR tick_timer
		JSR test_reset
		PLB
		PLP
		RTL

; draw the current amount of coins collected this level to the status bar
display_coins:
		LDA $0DBF ; coins
		JSL $00974C ; hex2dec
		STA $1F42 ; ones
		CPX #$00
		BNE .not_zero
		LDX #$FC
	.not_zero:
		STX $1F41 ; tens
		RTS
		
; draw the absolute value of the player's current speed to the status bar
display_speed:
		LDA $7B ; speed
		BPL .positive_speed
		EOR #$FF
		INC A
	.positive_speed:
		JSL $00974C ; hex2dec
		STX $1F2F ; tens
		STA $1F30 ; ones
		RTS
		
; draw the player's takeoff meter to the status bar
display_takeoff:
		LDA $19 ; powerup
		CMP #$02 ; cape
		BNE .clear_takeoff
		LDA $149F ; takeoff meter
		JSL $00974C ; hex2dec
		STX $1F4D ; tens
	.merge:
		STA $1F4E ; ones
		RTS
	.clear_takeoff:
		LDA #$FC ; empty tile
		STA $1F4D ; tens
		JMP .merge

; draw the player's p meter to the status bar
; p meter goes from #$00 to #$70, but we only show tens place because ones place changes too much to be useful
display_pmeter:
		LDA $13E4 ; pmeter
		AND #$F0
		LSR A
		LSR A
		LSR A
		LSR A
		STA $1F6C ; ones
		RTS
		
; draw the level & room timers to the status bar
display_timers:
		LDA !level_timer_minutes
		JSL $00974C ; hex2dec
		STA $1F35 ; ones
		LDA !level_timer_seconds
		JSL $00974C ; hex2dec
		STX $1F37 ; tens
		STA $1F38 ; ones
		LDA !status_fractions
		BEQ .draw_level_fractions
		LDA !level_timer_frames
		JSL $00974C ; hex2dec
		STX $1F3A ; tens
		STA $1F3B ; ones
		LDA #$0F
		STA $1F39
		JMP .display_room_timer
	.draw_level_fractions:
		LDX !level_timer_frames
		LDA fractional_seconds,X
		JSL $00974C ; hex2dec
		STX $1F3A ; tens
		STA $1F3B ; ones
		
	.display_room_timer:
		LDA !room_timer_minutes
		JSL $00974C ; hex2dec
		STA $1F53 ; ones
		LDA !room_timer_seconds
		JSL $00974C ; hex2dec
		STX $1F55 ; tens
		STA $1F56 ; ones
		LDA !status_fractions
		BEQ .draw_room_fractions
		LDA !room_timer_frames
		JSL $00974C ; hex2dec
		STX $1F58 ; tens
		STA $1F59 ; ones
		LDA #$0F
		STA $1F57
		JMP .merge
	.draw_room_fractions:
		LDX !room_timer_frames
		LDA fractional_seconds,X
		JSL $00974C ; hex2dec
		STX $1F58 ; tens
		STA $1F59 ; ones
		
	; draw flashing clock symbol if run was not spliced
		LDA !spliced_run
		BNE .merge
		LDA $13 ; true frame
		AND #%00100000
		BEQ .merge
		LDA #$76
		STA $1F34
		BRA .done
	.merge:
		LDA #$FC
		STA $1F34
	.done:
		RTS

; table to convert frames into hundredths of seconds
fractional_seconds:
		db $00,$01,$03,$05,$07,$08,$0A,$0B,$0D,$0F,$11,$12
		db $14,$15,$17,$19,$1B,$1C,$1E,$1F,$21,$23,$25,$26
		db $28,$29,$2B,$2D,$2F,$30,$32,$33,$35,$37,$39,$3A
		db $3C,$3D,$3F,$41,$43,$44,$46,$47,$49,$4B,$4D,$4E
		db $50,$51,$53,$55,$57,$58,$5A,$5B,$5D,$5F,$61,$62

; draw the number of dropped frames to the status bar
; this number will stay in hex because it can get large and lag the game itself!
display_dropped_frames:
		LDA !dropped_frames+1
		PHA
		LSR A
		LSR A
		LSR A
		LSR A
		STA $1F73 ; 0x1000's
		PLA
		AND #$0F
		STA $1F74 ; 0x100's
		LDA !dropped_frames
		PHA
		LSR A
		LSR A
		LSR A
		LSR A
		STA $1F75 ; 0x10's
		PLA
		AND #$0F
		STA $1F76 ; 0x01's

		LDX #$00 ; replace 0's with spaces cause it looks better for a 4 digit number
	.loop:
		LDA $1F73,X
		BNE .done
		LDA #$FC
		STA $1F73,X
		INX
		CPX #$03
		BNE .loop
	.done:
		LDA #$11
		STA $1F77
		RTS
		
; draw the current controller input to the status bar
display_input:
		LDA #$7E
		STA $02
		LDA #$1F
		STA $01
		
		LDA $0DA2 ; byetudlr
		LDX #$08
	.loop_cont_a:
		DEX
		BMI .next_cont
		LSR A
		PHA
		BCS .draw_cont_a
		LDA input_locs_1,X
		STA $00
		LDA #$FC
		BRA .finish_cont_a
	.draw_cont_a:
		LDA input_locs_1,X
		STA $00
		LDA input_tiles_1,X
	.finish_cont_a:
		STA [$00]
		PLA
		BRA .loop_cont_a
		
	.next_cont:
		LDA $0DA4 ; axlr----
		LSR A
		LSR A
		LSR A
		LSR A
		LDX #$04
	.loop_cont_b:
		DEX
		BMI .done_cont
		LSR A
		PHA
		BCS .draw_cont_b
		LDA input_locs_2,X
		STA $00
		LDA #$FC
		BRA .finish_cont_b
	.draw_cont_b:
		LDA input_locs_2,X
		STA $00
		LDA input_tiles_2,X
	.finish_cont_b:
		STA [$00]
		PLA
		BRA .loop_cont_b

	.done_cont:
		RTS

input_locs_1:
		db $A5,$87,$A4,$86,$4C,$A6,$6A,$88
input_locs_2:
		db $69,$4B,$4A,$68
input_tiles_1:
		db $0B,$22,$0E,$1C,$1E,$0D,$15,$1B
input_tiles_2:
		db $0A,$21,$15,$1B

; if yoshi is present, draw his x and y subpixels to the status bar
display_yoshi_subpixel:
		LDA $18DF ; yoshi slot
		BEQ .erase
		DEC A
		TAX
		LDA $14F8,X ; sprite x subpixel
		LSR A
		LSR A
		LSR A
		LSR A
		STA $1F32
		LDA $14EC,X ; sprite y subpixel
		LSR A
		LSR A
		LSR A
		LSR A
		STA $1F33
		BRA .done
	.erase:
		LDA #$FC
		STA $1F32
		STA $1F33
	.done:
		RTS

; if an item is held, draw its x and y subpixels to the status bar
display_held_subpixel:
		LDA !held_item_slot
		BMI .done_check_despawn
		; check if item has despawned, and if so, erase the numbers
		TAX
		LDA $14C8,X ; sprite status
		CMP #$07
		BCS .done_check_despawn
		LDA #$FF
		STA !held_item_slot
		LDA #$FC
		STA $1F50
		STA $1F51
		
	.done_check_despawn:
		LDA $148F ; held item flag
		BEQ .done_check_hold
		LDX #$0B
	.loop:
		LDA $14C8,X ; sprite status
		CMP #$0B
		BEQ .store_held
		DEX
		BPL .loop
		BRA .done_check_hold
	.store_held:
		STX !held_item_slot
		
	.done_check_hold:
		LDA !held_item_slot
		BMI .done
		TAX
		LDA $14F8,X ; sprite x subpixel
		LSR A
		LSR A
		LSR A
		LSR A
		STA $1F50
		LDA $14EC,X ; sprite y subpixel
		LSR A
		LSR A
		LSR A
		LSR A
		STA $1F51
		
	.done:
		RTS
		
; increment the timer located at address at top of stack by the number of frames elapsed this execution frame
tick_timer:
		PLX ; grab timer address off of the stack and restore return address
		PLY
		PLA
		STA $00
		PLA
		STA $01
		PHY
		PHX
		
		LDA !freeze_timer_flag
		BNE .done
		
		LDY #$02
		LDA ($00),Y
		CLC
		ADC !real_frames
		CMP #$3C
		BCC .frames_less
		SEC
		SBC #$3C
		STA ($00),Y
		DEY
		LDA ($00),Y
		INC A
		CMP #$3C
		BCC .seconds_less
		SEC
		SBC #$3C
		STA ($00),Y
		DEY
		LDA ($00),Y
		INC A
		CMP #$0A
		BCS .minutes_max
		STA ($00),Y
	.done:
		RTS
	.frames_less:
		STA ($00),Y
		BRA .done
	.seconds_less:
		STA ($00),Y
		BRA .done
	.minutes_max:
		LDA #$3B
		INY
		STA ($00),Y
		INY
		STA ($00),Y
		BRA .done

; test if a reset was activated, if so, call the appropriate routine
test_reset:
		LDA $0DA4 ; axlr----
		AND #%00110000
		CMP #%00110000
		BNE .done
		
		; test X + Y for advance room
		LDA $0DA4 ; axlr----
		AND #%01000000
		BEQ .test_ab
		LDA $0DA2 ; byetudlr
		AND #%01000000
		BEQ .test_ab
		JSL activate_room_advance
		JMP .done
		
		; test A + B for level reset
	.test_ab:
		LDA $0DA4 ; axlr----
		AND #%10000000
		BEQ .room_reset
		LDA $0DA2 ; byetudlr
		AND #%10000000
		BEQ .room_reset
		JSL activate_level_reset
		JMP .done
	
	.room_reset:
		JSL activate_room_reset
		
	.done:
		RTS