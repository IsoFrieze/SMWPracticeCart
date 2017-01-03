ORG $158000

; this code is run on every frame during fades to and from the level game mode (game modes #$0F & #$13)
; TODO actually call this routine in a hijack
temp_fade_tick:
		PHP
		PHB
		PHK
		PLB
		
		JSR fade_and_in_level_common
		STZ !dropped_frames
		STZ !dropped_frames+1
		
		PLB
		PLP
		
		DEC $0DB1
		RTL

; this code is run on every frame during the level game mode (after fade in completes) (game mode #$14)
level_tick:
		PHP
		PHB
		PHK
		PLB
		
		; this makes sure we aren't on the title screen
		LDA $0100
		CMP #$14
		BNE .done
		
		JSR prepare_input
		JSR record_input
		
		JSR fade_and_in_level_common
		
		PEA !level_timer_minutes
		JSR tick_timer
		PEA !room_timer_minutes
		JSR tick_timer
		JSR test_ci2
		JSR test_reset
		JSR test_run_type
		JSR test_translevel_0_failsafe
		JSR wait_slowdown
		
	.done:
		PLB
		PLP
		RTL

; these routines are called on both level tick and level fade tick
fade_and_in_level_common:
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
		JSR display_memory
		JSR display_slowdown
		JSR display_movie_capacity
		JSR display_names
		JSR test_savestate
		JSR test_slowdown
		RTS

; slow down the game depending on how large the slowdown number is
wait_slowdown:
		LDA !slowdown_speed
		BEQ .done
		INC A
		TAX
	.loop:
		DEX
		BEQ .invalidate
		WAI ; wait for NMI
		WAI ; wait for IRQ
		BRA .loop
		
	.invalidate:
		LDA #$01
		STA.L !spliced_run
		
	.done:
		RTS

; draw the current dymeter to where it belongs on the screen
display_dynmeter:
		PHB
		PHK
		PLB
		LDA $0100 ; game mode
		CMP #$0B
		BCS .begin
		BRL .done
	
	.begin:	
		STZ $08
		STZ $09
		STZ $0A
		STZ $0B
		LDA.L !status_dynmeter
		ASL A
		TAX
		JMP (.dynmeter_types,X)
		
	.dynmeter_types:
		dw .done
		dw .mario_speed
		dw .mario_takeoff
		dw .mario_pmeter
		dw .mario_subpixel
		dw .yoshi_subpixel
		dw .item_subpixel
		dw .item_speed
		
	.mario_speed:
		LDA $7B ; speed
		BPL .positive_speed
		EOR #$FF
		INC A
		INC $08
		INC $09
	.positive_speed:
		JSL $00974C ; hex2dec
		STX $00 ; tens
		STA $01 ; ones
		LDA #$FF
		STA $02
		STA $03
		JMP .attach_to_mario
		
	.mario_takeoff:
		LDA $149F ; takeoff meter
		JSL $00974C ; hex2dec
		STX $00 ; tens
		STA $01 ; ones
		LDA #$FF
		STA $02
		STA $03
		JMP .attach_to_mario
		
	.mario_pmeter:
		LDA $13E4 ; pmeter
		AND #$0F
		STA $01 ; ones
		LDA $13E4 ; pmeter
		AND #$F0
		LSR #4
		STA $00 ; 16s
		LDA #$FF
		STA $02
		STA $03
		JMP .attach_to_mario
		
	.mario_subpixel:
		LDA $7A ; mario x subpixel
		LSR #4
		STA $00
		STZ $01
		LDA $7C ; mario y subpixel (?)
		LSR #4
		STA $02
		STZ $03
		JMP .attach_to_mario
		
	.yoshi_subpixel:
		LDA $18DF ; yoshi slot
		BNE .yoshi_continue
		BRL .done
	.yoshi_continue
		DEC A
		TAX
		LDA $14F8,X ; sprite x subpixel
		LSR #4
		STA $00
		STZ $01
		LDA $14EC,X ; sprite y subpixel
		LSR #4
		STA $02
		STZ $03
		JMP .attach_to_sprite
		
	.item_subpixel:
		LDA !held_item_slot
		BPL .item_continue
		BRL .done
	.item_continue
		TAX
		LDA $14F8,X ; sprite x subpixel
		LSR #4
		STA $00
		STZ $01
		LDA $14EC,X ; sprite y subpixel
		LSR #4
		STA $02
		STZ $03
		JMP .attach_to_sprite
		
	.item_speed:
		LDA !held_item_slot
		BPL .item_speed_continue
		BRL .done
	.item_speed_continue:
		TAX
		LDA $B6,X ; sprite x speed
		BPL .item_positive_x_speed
		EOR #$FF
		INC A
		INC $08
		INC $09
	.item_positive_x_speed:
		JSL $00974C ; hex2dec
		STX $00 ; tens
		STA $01 ; ones
		LDX !held_item_slot
		LDA $AA,X ; sprite y speed
		BPL .item_positive_y_speed
		EOR #$FF
		INC A
		INC $0A
		INC $0B
	.item_positive_y_speed:
		JSL $00974C ; hex2dec
		STX $02 ; tens
		STA $03 ; ones
		LDX !held_item_slot
		JMP .attach_to_sprite
	
	.attach_to_mario:
		REP #$20
		LDA $D1
		STA $04
		LDA $D3
		SEC
		SBC #$0008
		STA $06
		JMP .merge
	
	.attach_to_sprite:
		LDA $E4,X ; sprite x pos low
		STA $04
		LDA $14E0,X ; sprite x pos high
		STA $05
		LDA $D8,X ; sprite y pos low
		STA $06
		LDA $14D4,X ; sprite y pos high
		STA $07
		REP #$20
		LDA $06
		CLC
		ADC #$0012
		STA $06
		JMP .merge
		
	.merge:
		REP #$20
		LDA $04
		SEC
		SBC $1A ; layer 1 x pos
		STA $04
		LDA $06
		SEC
		SBC $1C ; layer 1 y pos
		STA $06
		
		LDA $04
		BMI .done
		CMP #$0F8
		BCS .done
		LDA $06
		BMI .done
		CMP #$00F0
		BCS .done
		
		SEP #$20
		LDY #$03
		LDX #$0C
	.draw_loop:
		LDA $0000,Y
		CMP #$10
		BCS .next_tile
		PHX
		TAX
		LDA sprite_numbers,X
		PLX
		STA $0232,X ; oam tile
		LDA #$32
		CLC
		ADC $0008,Y
		ADC $0008,Y
		STA $0233,X ; oam properties
		LDA $04
		CLC
		ADC tile_x_offsets,Y
		STA $0230,X ; oam x pos
		LDA $06
		CLC
		ADC tile_y_offsets,Y
		STA $0231,X ; oam y pos
		PHX
		TYX
		STZ $042C,X ; oam size
		PLX
	.next_tile:
		DEX #4
		DEY
		BPL .draw_loop		
		
	.done:
		SEP #$20
		PLB
		LDA $18DF
		STA $18E2
		RTL

tile_x_offsets:
		db $00,$08,$00,$08
tile_y_offsets:
		db $00,$00,$08,$08

; draw the current memory viewer bytes to the status bar
display_memory:
		LDA.L !status_memorylo
		STA $00
		LDA.L !status_memoryhi
		STA $01
		
		LDY #$01
		LDA ($00),Y
		LSR #4
		STA $1F7C
		LDA ($00),Y
		AND #$0F
		STA $1F7D
		
		DEY
		LDA ($00),Y
		LSR #4
		STA $1F7E
		LDA ($00),Y
		AND #$0F
		STA $1F7F
		RTS

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
		
; sad wrapper is sad
display_timer_wrapper:
		PHB
		PHK
		PLB
		JSR display_timers
		PLB
		RTL
		
; draw the level & room timers to the status bar
display_timers:
		LDA !level_timer_minutes
		JSL $00974C ; hex2dec
		STA $1F35 ; ones
		LDA !level_timer_seconds
		JSL $00974C ; hex2dec
		STX $1F37 ; tens
		STA $1F38 ; ones
		LDA.L !status_fractions
		BEQ .draw_level_fractions
		LDA !level_timer_frames
		JSL $00974C ; hex2dec
		STX $1F3A ; tens
		STA $1F3B ; ones
		LDA #$85
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
		LDA.L !status_fractions
		BEQ .draw_room_fractions
		LDA !room_timer_frames
		JSL $00974C ; hex2dec
		STX $1F58 ; tens
		STA $1F59 ; ones
		LDA #$85
		STA $1F57
		JMP .draw_clock
	.draw_room_fractions:
		LDX !room_timer_frames
		LDA fractional_seconds,X
		JSL $00974C ; hex2dec
		STX $1F58 ; tens
		STA $1F59 ; ones
		
	; draw flashing clock symbol if run was not spliced
	.draw_clock:
		LDA.L !spliced_run
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
		LSR #4
		STA $1F73 ; 0x1000's
		PLA
		AND #$0F
		STA $1F74 ; 0x100's
		LDA !dropped_frames
		PHA
		LSR #4
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
		LDA input_tile_no_button
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
		LSR #4
		LDX #$04
	.loop_cont_b:
		DEX
		BMI .done_cont
		LSR A
		PHA
		BCS .draw_cont_b
		LDA input_locs_2,X
		STA $00
		LDA input_tile_no_button
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
		db $87,$68,$84,$85,$46,$82,$63,$65
input_locs_2:
		db $6A,$4B,$48,$49
input_tiles_1:
		db $0B,$22,$44,$1C,$41,$42,$40,$43
input_tiles_2:
		db $0A,$21,$15,$1B
input_tile_no_button:
		db $27

; display the slowdown number if it is not zero to the status bar
display_slowdown:
		LDA !slowdown_speed
		BNE .not_zero
		LDA #$FC
		BRA .store
	.not_zero:
		INC A
	.store:
		STA $1F44
		RTS

; if yoshi is present, draw his x and y subpixels to the status bar
display_yoshi_subpixel:
		LDA $18DF ; yoshi slot
		BEQ .erase
		DEC A
		TAX
		LDA $14F8,X ; sprite x subpixel
		LSR #4
		STA $1F32
		LDA $14EC,X ; sprite y subpixel
		LSR #4
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
		LSR #4
		STA $1F50
		LDA $14EC,X ; sprite y subpixel
		LSR #4
		STA $1F51
		
	.done:
		RTS

; display a sprite's slot number next to it on the screen
; X = slot number
display_slot:
		PHB
		PHK
		PLB
		; don't display slots on title screen
		LDA $0100
		CMP #$0B
		BCC .done
		LDA.L !status_slots
		BEQ .done
		
		TXA
		ASL A
		ASL A
		TAY
		LDA $14C8,X ; sprite status
		BNE .not_dead
		LDA.L !status_slots
		CMP #$01
		BEQ .erase_tile
	.not_dead:
		JSR get_screen_y
		XBA
		CMP #$00
		BNE .erase_tile
		XBA
		STA $02B1,Y ; oam y position
		JSR get_screen_x
		XBA
		CMP #$00
		BNE .erase_tile
		XBA
		STA $02B0,Y ; oam x position
		LDA sprite_numbers,X
		STA $02B2,Y ; oam tile
		LDA #$38
		STA $02B3,Y ; oam properties
		STZ $044C,X ; oam size
		BRA .done
	.erase_tile:
		LDA #$F0
		STA $02B1,Y ; oam y position
		
	.done:
		PLB
		RTL

sprite_numbers:
		db $44,$45,$46,$47
		db $54,$55,$56,$57
		db $68,$69,$6A,$6B
		db $78,$79,$7A,$7B

get_screen_x:
		LDA $E4,X ; sprite x position, low byte
		XBA
		LDA $14E0,X ; sprite x position, high byte
		XBA
		REP #$20
		SEC
		SBC $1A ; layer 1 x position
		SEP #$20
		RTS

get_screen_y:
		LDA $D8,X ; sprite y position, low byte
		XBA
		LDA $14D4,X ; sprite y position, high byte
		XBA
		REP #$20
		SEC
		SBC $1C ; layer 1 y position
		SEP #$20
		RTS

; if recording, display red dot and capacity meter
display_movie_capacity:
		LDA #$FC
		STA $1F9F
		STA $1FA0
		STA $1FA1
		STA $1FA2
		STA $1FA3
		STA $1FA4
		STA $1FA5
		STA $1FA6
		LDA !in_record_mode
		ORA !in_playback_mode
		BNE .draw
		JMP .finish
	.draw:
		LDA $13
		ASL #3
		BCC .no_dot
		LDA !in_record_mode
		BEQ .triangle
		LDA #$CD
		BRA .icon
	.triangle:
		LDA #$1B
		STA $1FA0
		LDA #$0E
		STA $1FA1
		LDA #$19
		STA $1FA2
		LDA #$15
		STA $1FA3
		LDA #$0A
		STA $1FA4
		LDA #$22
		STA $1FA5
		LDA #$FC
		STA $1FA6
		LDA #$D2
	.icon:
		STA $1F9F
	.no_dot:
		LDA $0100 ; game mode
		CMP #$14
		BEQ .k
		JMP .finish
	.k:
		LDA !in_record_mode
		BNE .go
		JMP .finish
	.go:
		LDA #$CE
		STA $1FA0
		STA $1FA6
		LDA #$CF
		STA $1FA1
		STA $1FA2
		STA $1FA3
		STA $1FA4
		STA $1FA5
		REP #$30
		LDA.L !movie_location
		TAX
		SEP #$20
		CPX #$0100
		BCC .finish
		LDA #$D0
		STA $1FA0
		CPX #$0200
		BCC .finish
		LDA #$D1
		STA $1FA1
		CPX #$0300
		BCC .finish
		LDA #$D1
		STA $1FA2
		CPX #$0400
		BCC .finish
		LDA #$D1
		STA $1FA3
		CPX #$0500
		BCC .finish
		LDA #$D1
		STA $1FA4
		CPX #$0600
		BCC .finish
		LDA #$D1
		STA $1FA5
		CPX #$0700
		BCC .finish
		LDA #$D0
		STA $1FA6
		LDA $13
		ASL #4
		BCC .finish
		LDA #$FC
		LDX #$0006
	.loop_flash:
		STA $1FA0,X
		DEX
		BPL .loop_flash
	.finish:
		SEP #$10
		RTS

; display name under item box
display_names:
		LDA.L !player_name
		STA $1F89
		LDA.L !player_name+1
		STA $1F8A
		LDA.L !player_name+2
		STA $1F8B
		LDA.L !player_name+3
		STA $1F8C
		LDA !in_playback_mode
		BEQ .done
		LDA !movie_location+7
		STA $1F9A
		LDA !movie_location+8
		STA $1F9B
		LDA !movie_location+9
		STA $1F9C
		LDA !movie_location+10
		STA $1F9D
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

; rewrite CI2's weird screen exits so it's compatible with the level reset code
test_ci2:
		LDA $71 ; player animation
		CMP #$05
		BNE .done
		LDA $88 ; pipe animation
		BNE .done
		LDA $13BF ; translevel number
		CMP #$24
		BNE .done
		
		LDA $141A
		AND #$7F
		ASL A
		TAX
		LDY #$00
		JSR (ci2_room_exits,X)
		
	.done:
		RTS

ci2_room_exits:
		dw ci2_coins
		dw ci2_time
		dw ci2_dragon_coins
		dw ci2_goal ; this shouldn't happen, but just in case

ci2_coins:
		LDA $0DBF ; coins
		CMP #$15
		BCC .less_21
		LDA #$CF ; x >= 21 coins
		BRA .and_go
	.less_21:
		CMP #$09
		BCC .less_9
		LDA #$B9 ; 9 <= x < 21 coins
		BRA .and_go
	.less_9
		LDA #$B8 ; x < 9 coins
	.and_go:
		JSL set_global_exit
		RTS

ci2_time:
		LDA $0F31 ; timer hundreds
		CMP #$02
		BCS .ge_200
		LDA #$CE ; x < 200
		BRA .and_go
	.ge_200:
		LDA $0F32 ; timer tens
		ASL #4
		ORA $0F33 ; timer ones
		CMP #$35
		BCS .ge_235
		LDA #$CE ; 200 <= x < 235
		BRA .and_go
	.ge_235:
		CMP #$50
		BCS .ge_250
		LDA #$BB ; 235 <= x < 250
		BRA .and_go
	.ge_250
		LDA #$BA ; x >= 250
	.and_go:
		JSL set_global_exit
		RTS

ci2_dragon_coins:
		LDA $1420 ; dragon coins
		CMP #$04
		BCS .ge_4
		LDA #$BC ; x < 4 dragon coins
		BRA .and_go
	.ge_4:
		LDA #$CD ; x >= 4 dragon coins
	.and_go
		JSL set_global_exit
		RTS

ci2_goal:
		RTS
		

; test if a reset was activated, if so, call the appropriate routine
test_reset:
		LDA.L !status_lrreset
		BNE .done
		LDA $71 ; player animation
		CMP #$09
		BEQ .continue
		LDA $9D ; sprite lock flag
		ORA $1493 ; end level timer
		ORA $1434 ; keyhole timer
		ORA $1426 ; message block timer
		ORA $13D4 ; paused flag
		BNE .done
		
	.continue:
		LDA $0DA4 ; axlr----
		AND #%00110000
		CMP #%00110000
		BNE .done
		
		INC $9D ; sprite lock flag
		
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

; test if a savestate was activated, if so, call the appropriate routine
test_savestate:
		LDA.L !status_states
		BNE .done
		
		LDA $0D9B ; overworld flag
		CMP #$02
		BEQ .done
		
		LDA $0DA2 ; byetudlr
		AND #%00100000
		BEQ .done
		
		LDA $0DA4 ; axlr----
		AND #%00010000
		BEQ .test_load
		
		JSL activate_save_state
		BRA .done
		
	.test_load:
		LDA.L !save_state_exists
		CMP #$BD
		BNE .done
		LDA $0DA4 ; axlr----
		AND #%00100000
		BEQ .done
		
		JSL activate_load_state
	
	.done:
		RTS
		
; test if slowdown was activated, if so, update the register for that
test_slowdown:
		LDA !status_slowdown
		BNE .done
		
		LDA $0DA6 ; byetudlr frame
		AND #%00010000
		BEQ .done
		
		LDA $0DA4 ; axlr----
		AND #%00010000
		BEQ .test_undo
		
		LDA !slowdown_speed
		INC A
		CMP #$0F
		BCC .store_speed
		LDA #$0E
		BRA .store_speed
		
	.test_undo:
		LDA $0DA4 ; axlr----
		AND #%00100000
		BEQ .done
		
		LDA !slowdown_speed
		DEC A
		BPL .store_speed
		LDA #$00
	
	.store_speed:
		STA !slowdown_speed
		
	.done:
		RTS

; test if player used cape, powerup, yoshi, etc. to count towards record keeping
test_run_type:
		LDA $187A ; riding yoshi
		BNE .set_yoshi
		LDA $19 ; powerup
		BNE .deny_low
		LDA $1490 ; star
		BNE .deny_low
		LDA $13F3 ; p-balloon flag
		BEQ .check_cape
		
	.set_yoshi:
		LDA #%01000000
		STA !record_used_yoshi
	.deny_low:
		LDA #$01
		STA !record_used_powerup
	.check_cape:
		LDA $19 ; powerup
		CMP #$02
		BNE .check_ld
		LDA #$01
		STA !record_used_cape
		
	.check_ld:
		LDA $1420 ; dragon coin count
		CMP #$05
		BCC .done
		LDA $13BF ; translevel
		LDY #$07
	.loop:
		DEY
		BMI .success
		CMP levels_with_moons,Y
		BNE .loop
		LDA $13C5 ; collected moon flag
		BEQ .done
	.success:
		LDA #$01
		STA !record_lunar_dragon
		
	.done:
		RTS

levels_with_moons:
		db $29,$06,$2E,$0F,$41,$22,$36,$3A

; activate orb flag if level beaten with orb that came out of the item box
collect_orb:
		STZ $14C8,X ; sprite status
		LDA $9E,X ; sprite id
		CMP #$4A ; orb
		BNE .done
		LDA $1528,X ; misc table (used for original orb in level flag)
		BNE .done
		LDA #%00100000
		STA !record_used_orb
	.done:
		LDA #$FF
		RTL

; test if we should drop the item out of the item box
drop_item_box:
		LDA $16 ; byetudlr frame
		AND #%00100000
		BEQ .no_select
		LDA.L !status_drop
		BNE .yes_select
		LDA $17 ; axlr----
		AND #%00110000
		BEQ .yes_select
		
	.no_select:
		INC A
	.yes_select:
		RTL

; test the start button to see if we should pause the game (return 0 in A for no pause, pause otherwisxe)
test_pause:
		LDA $16 ; byetudlr frame
		AND #%00010000
		BEQ .done
		LDA.L !status_drop
		BNE .do_pause
		LDA $17 ; axlr----
		AND #%00110000
		BEQ .do_pause
		LDA #$00
		BRA .done
	.do_pause:
		LDA #$01		
	.done:
		RTL

; set the pause timer depending on our current setting
pause_timer:
		PHB
		PHK
		PLB
		
		LDA.L !status_pause
		TAX
		LDA pause_lengths,X
		STA $13D3 ; pause timer
		
		PLB
		RTL

pause_lengths:
		db $3C,$00
		
; play hurry up sound effect only if option is on
hurry_up:
		LDA.L !status_timedeath
		BNE .done
		LDA $0F31
		BNE .done
		ORA $0F32
		AND $0F33 ; timer
		CMP #$09
		BNE .done
		LDA #$FF
		STA $1DF9 ; apu i/o
	.done:
		RTL
		
; kill mario when time runs out only if option is on
; return 0 in A to kill mario
out_of_time:
		LDA $0F31
		ORA $0F32
		ORA $0F33 ; timer
		BNE .done
		LDA.L !status_timedeath
	.done:
		RTL

; display a score sprite only if sprite slot numbers are disabled
; return A = 0 if enabled
check_score_sprites:
		LDA.L !status_slots
		BNE .done
		LDA.L !status_dynmeter
		BNE .done
	.continue:
		LDA $16E7,X ; score sprite y position low byte
		SEC
		SBC $02
		STA $0201,Y ; oam tile
		STA $0205,Y ; oam tile
		LDA #$00
		RTL
	.done:
		LDA #$01
		RTL

; draw the level and room timers, but on the sprite layer instead if in the bowser fight
draw_bowser_timer:
		LDA $0D9B ; boss flag
		CMP #$C1 ; bowser fight
		BEQ .begin
		RTL
		
	.begin:
		PHB
		PHK
		PLB
		
		LDA #$69 ; empty tile
		STA $0256
		LDA.L !spliced_run
		BNE .spliced
		LDA $13 ; true frame
		AND #%00100000
		BEQ .spliced
		LDA #$F0 ; clock icon
		STA $0256
	.spliced:
		LDA !level_timer_minutes
		JSR hex_to_bowser
		STA $025A
		LDA !level_timer_seconds
		JSR hex_to_bowser
		STX $0262
		STA $0266
		LDA.L !status_fractions
		BEQ .draw_level_fractions
		LDA !level_timer_frames
		JSR hex_to_bowser
		STX $026E
		STA $0272
		LDA #$F1
		STA $026A
		JMP .set_level_positions
	.draw_level_fractions:
		LDX !level_timer_frames
		LDA fractional_seconds,X
		JSR hex_to_bowser
		STX $026E
		STA $0272
		LDA #$F2
		STA $026A
	.set_level_positions:
		LDA #$F1
		STA $025E
		
		LDY #$07
	.level_loop:
		TYX
		STZ $0435,X
		LDA timer_x,X
		PHA
		TYA
		ASL A
		ASL A
		TAX
		PLA
		STA $0254,X
		LDA #$10
		STA $0255,X
		LDA #$30
		STA $0257,X
		DEY
		BPL .level_loop
		
		LDA !room_timer_minutes
		JSR hex_to_bowser
		STA $03A2
		LDA !room_timer_seconds
		JSR hex_to_bowser
		STX $03AA
		STA $03AE
		LDA.L !status_fractions
		BEQ .draw_room_fractions
		LDA !level_timer_frames
		JSR hex_to_bowser
		STX $03B6
		STA $03BA
		LDA #$F1
		STA $03B2
		JMP .set_room_positions
	.draw_room_fractions:
		LDX !level_timer_frames
		LDA fractional_seconds,X
		JSR hex_to_bowser
		STX $03B6
		STA $03BA
		LDA #$F2
		STA $03B2
	.set_room_positions:
		LDA #$F1
		STA $03A6
		
		LDY #$06
	.room_loop:
		TYX
		STZ $0488,X
		INX
		LDA timer_x,X
		DEX
		PHA
		TYA
		ASL A
		ASL A
		TAX
		PLA
		STA $03A0,X
		LDA #$18
		STA $03A1,X
		LDA #$32
		STA $03A3,X
		DEY
		BPL .room_loop
		
		PLB
		RTL

; the x positions of each of the tiles in the bowser timer
timer_x:
		db $30,$38,$40,$48,$50,$58,$60,$68

; convert a hex number to decimal, then get tile numbers
hex_to_bowser:
		JSL $00974C ; hex2dec
		PHX
		TAX
		LDA bowser_numbers,X
		PLX
		PHA
		LDA bowser_numbers,X
		TAX
		PLA
		RTS
		
; tile numbers for each of the numbers 0-9 in the bowser timer
bowser_numbers:
		db $A8,$A9,$AA,$AB,$AC
		db $AD,$AE,$AF,$B0,$B1

; if mario finds himself in translevel 0, reset his overworld position as a fail safe
test_translevel_0_failsafe:
		LDA $0100 ; game mode
		CMP #$14
		BNE .done
		LDA $13BF ; translevel
		BNE .done
		JSL set_position_to_yoshis_house
	.done:
		RTS
		
; only reset layer 3 Y position if not in overworld menu
layer_3_y:
		LDA !in_overworld_menu
		BNE .copy
		STZ $2112
		STZ $2112
		BRA .done
	.copy:
		LDA $24
		STA $2112
		LDA $25
		STA $2112
	.done:
		RTL

; disable layer 3 priority if in overworld menu
layer_3_priority:
		LDA !in_overworld_menu
		BNE .disable
		LDA #$09
		BRA .merge
	.disable:
		LDA #$01
	.merge:
		STA $2105
		RTL

; record player input as a movie
record_input:
		PHP
		LDA !in_record_mode
		BNE .not_done
		JMP .skip
	.not_done:
		
		REP #$30
		LDA.L !movie_location
		CMP #$FFFF
		BEQ .start
		TAX
		SEP #$20
		LDA.L !movie_location+$43,X
		CMP $0DA2
		BNE .advance
		LDA.L !movie_location+$44,X
		AND #$F0
		CMP $0DA4
		BNE .advance
		LDA.L !movie_location+$44,X
		AND #$08
		BEQ .increment_sub
		BRA .increment_ext
	.advance:
		LDA.L !movie_location+$44,X
		AND #$08
		BEQ .only_2
		INX
	.only_2:
		INX #2
		BRA .record_new_byte
		
	.start:
		LDX #$0000
		SEP #$20
	.record_new_byte:
		LDA $0DA2
		STA.L !movie_location+$43,X
		LDA $0DA4
		AND #$F0
		STA.L !movie_location+$44,X
		BRA .done
	.increment_sub:
		LDA.L !movie_location+$44,X
		INC A
		STA.L !movie_location+$44,X
		AND #$08
		BEQ .done
	.create_ext:
		LDA.L !movie_location+$44,X
		AND #$0F
		STA.L !movie_location+$45,X
		BRA .done
	.increment_ext:
		LDA.L !movie_location+$45,X
		CMP #$FF
		BNE .easy
		INX #3
		BRA .record_new_byte
	.easy:
		INC A
		STA.L !movie_location+$45,X
		
	.done:
		REP #$30
		TXA
		STA.L !movie_location
		CPX #$07C0
		BCC .skip
		SEP #$20
		STZ !in_record_mode
	.skip:
		PLP
		RTS

; update the index into the movie
prepare_input:
		PHP
		LDA !in_playback_mode
		BNE .not_done
		JMP .done
	.not_done:
		
		REP #$30
		LDA.L !movie_location
		CMP #$FFFF
		BEQ .start
		TAX
		BRA .go
	
	.start:
		LDX #$0000
		SEP #$20
		LDA #$00
		STA.L !movie_location+2
	.go:
		SEP #$20
		LDA.L !movie_location+$44,X
		AND #$08
		BNE .check_ext
		LDA.L !movie_location+$44,X
		AND #$07
		BRA .merge_count
	.check_ext:
		LDA.L !movie_location+$45,X
	.merge_count:
		CMP.L !movie_location+2
		BEQ .advance_input
		BCC .advance_input
		BRA .use_this_input
	.advance_input:
		LDA.L !movie_location+$44,X
		AND #$08
		BEQ .only_2
		INX
	.only_2:
		INX #2
		LDA #$FF
		STA.L !movie_location+2
	.use_this_input:
		LDA.L !movie_location+2
		INC A
		STA.L !movie_location+2
		
		REP #$30
		TXA
		STA.L !movie_location
		
	.done:
		PLP
		RTS
		
; actually feed the input into the controller registers
play_input:
		PHP
		LDA !in_playback_mode
		BNE .not_done
		JMP .done
	.not_done:
		LDA $4219
		AND #$30
		CMP #$30
		BNE .no_cancel
		STZ !in_playback_mode
		BRA .done
	
	.no_cancel:	
		STZ $0DA3
		STZ $0DA5
		STZ $0DA7
		STZ $0DA9
		STZ $0DAB
		STZ $0DAD
		
		REP #$30
		LDA.L !movie_location
		TAX
		SEP #$20
		
		LDA.L !movie_location+$43,X
		STA $00
		LDA.L !movie_location+$44,X
		AND #$F0
		STA $01
		
		SEP #$30
		
		; this part copied from $008650
		LDA $01
		EOR $0DA4
		AND $01
		STA $0DA8
		LDA $01
		STA $0DA4
		
		LDA $00
		EOR $0DA2
		AND $00
		STA $0DA6
		LDA $00
		STA $0DA2
		
	.done:
		PLP
		RTL