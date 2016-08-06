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
		
		JSR fade_and_in_level_common
		
		PEA !level_timer_minutes
		JSR tick_timer
		PEA !room_timer_minutes
		JSR tick_timer
		JSR test_ci2
		JSR test_reset
		JSR test_run_type
		JSR test_grab_wings
		JSR test_translevel_0_failsafe
		
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
		JSR display_rng
		JSR test_savestate
		RTS

; draw the current dymeter to where it belongs on the screen
display_dynmeter:
		PHB
		PHK
		PLB
		LDA !status_dynmeter
		ASL A
		TAX
		JMP (.dynmeter_types,X)
		
	.dynmeter_types:
		dw .done
		dw .mario_speed
		dw .mario_takeoff
		dw .mario_pmeter
		dw .yoshi_subpixel
		dw .item_subpixel
		
	.mario_speed:
		LDA $7B ; speed
		BPL .positive_speed
		EOR #$FF
		INC A
	.positive_speed:
		JSL $00974C ; hex2dec
		STX $00 ; tens
		STA $01 ; ones
		JMP .attach_to_mario
		
	.mario_takeoff:
		LDA $149F ; takeoff meter
		JSL $00974C ; hex2dec
		STX $00 ; tens
		STA $01 ; ones
		JMP .attach_to_mario
		
	.mario_pmeter:
		LDA $13E4 ; pmeter
		AND #$0F
		STA $01 ; ones
		LDA $13E4 ; pmeter
		AND #$F0
		LSR #4
		STA $00 ; 16s
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
		LDA $14EC,X ; sprite y subpixel
		LSR #4
		STA $01
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
		LDA $14EC,X ; sprite y subpixel
		LSR #4
		STA $01
		JMP .attach_to_sprite
	
	.attach_to_mario:
		REP #$20
		LDA $D1
		STA $02
		LDA $D3
		SEC
		SBC #$0008
		STA $04
		JMP .merge
	
	.attach_to_sprite:
		LDA $E4,X ; sprite x pos low
		STA $02
		LDA $14E0,X ; sprite x pos high
		STA $03
		LDA $D8,X ; sprite y pos low
		STA $04
		LDA $14D4,X ; sprite y pos high
		STA $05
		REP #$20
		LDA $04
		CLC
		ADC #$0012
		STA $04
		JMP .merge
		
	.merge:
		REP #$20
		LDA $02
		SEC
		SBC $1A ; layer 1 x pos
		STA $02
		LDA $04
		SEC
		SBC $1C ; layer 1 y pos
		STA $04
		
		LDA $02
		BMI .done
		CMP #$0F8
		BCS .done
		LDA $04
		BMI .done
		CMP #$00F0
		BCS .done
		
		SEP #$20
	.draw:
		LDA $02
		STA $0200+(0*4) ; oam slot 0 x pos
		CLC
		ADC #$08
		STA $0200+(1*4) ; oam slot 1 x pos
		LDA $04
		STA $0201+(0*4) ; oam slot 0 y pos
		STA $0201+(1*4) ; oam slot 1 y pos
		LDA #$38
		STA $0203+(0*4) ; oam slot 0 properties
		STA $0203+(1*4) ; oam slot 1 properties
		LDA $00
		TAX
		LDA sprite_numbers,X
		STA $0202+(0*4) ; oam slot 0 tile
		LDA $01
		TAX
		LDA sprite_numbers,X
		STA $0202+(1*4) ; oam slot 1 tile
		STZ $0420+(0) ; oam slot 0 size
		STZ $0420+(1) ; oam slot 1 size
	.done:
		PLB
		LDA $18DF
		STA $18E2
		RTL

; draw the current rng output to the status bar
display_rng: ; 1f44 1f62
		LDA $148D ; rng output 1
		LSR #4
		STA $1F44
		LDA $148B
		AND #$0F
		STA $1F45
		
		LDA $148E ; rng output 2
		LSR #4
		STA $1F62
		LDA $148C
		AND #$0F
		STA $1F63
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
		LDA !status_fractions
		BEQ .draw_room_fractions
		LDA !room_timer_frames
		JSL $00974C ; hex2dec
		STX $1F58 ; tens
		STA $1F59 ; ones
		LDA #$85
		STA $1F57
		JMP .merge
	.draw_room_fractions:
		LDX !room_timer_frames
		LDA fractional_seconds,X
		JSL $00974C ; hex2dec
		STX $1F58 ; tens
		STA $1F59 ; ones
		
	; draw flashing clock symbol if run was not spliced
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
		LDA !status_slots
		BEQ .done
		
		TXA
		ASL A
		ASL A
		TAY
		LDA $14C8,X ; sprite status
		BNE .not_dead
		LDA !status_slots
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
		ASL A
		ASL A
		ASL A
		ASL A
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
		LDA !status_states
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

; test if player grabbed wings
test_grab_wings:
		LDA $71 ; player animation
		CMP #$08
		BNE .done
		LDX #$00
		JSL set_time_save_address
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
		LDA !status_drop
		BEQ .yes_select
		LDA $17 ; axlr----
		AND #%00110000
		BEQ .yes_select
		
	.no_select:
		INC A
	.yes_select:
		RTL

; set the pause timer depending on our current setting
pause_timer:
		PHB
		PHK
		PLB
		
		LDA !status_pause
		TAX
		LDA pause_lengths,X
		STA $13D3 ; pause timer
		
		PLB
		RTL

pause_lengths:
		db $3C,$00
		
; play hurry up sound effect only if option is on
hurry_up:
		LDA !status_timedeath
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
		LDA !status_timedeath
	.done:
		RTL

; display a score sprite only if sprite slot numbers are disabled
check_score_sprites:
		LDA !status_slots
		ORA !status_dynmeter
		CMP #$00
		PHP
		BNE .done
		LDA $16E7,X ; score sprite y position low byte
		SEC
		SBC $02
		STA $0201,Y ; oam tile
		STA $0205,Y ; oam tile
	.done:
		PLP
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
		LDA !status_fractions
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
		LDA !status_fractions
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
		