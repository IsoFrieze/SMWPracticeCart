ORG $118000

; this code is run once on overworld load
overworld_load:
		LDA !save_timer_address+2
		BMI .done ; bank >= 80 -> no record
		LDA !record_used_orb
		BEQ .continue
		
		; if you used an orb to complete the level, you must let the parade play out for it to count
		LDA $0DD5 ; level exit type
		CMP #$80 ; type = death or start/select
		BEQ .done
		
	.continue:
		; failsafe: if level was beaten in under 1 second, just discard the time, it was probably a glitch
		LDA !level_timer_minutes
		ORA !level_timer_seconds
		BEQ .done
	
		LDA !record_used_powerup
		BNE .deny_low
		JSR attempt_timer_save
	.deny_low:
		LDA !save_timer_address
		CLC
		ADC #$04
		STA !save_timer_address
		
		LDA !record_used_cape
		BNE .deny_nocape
		JSR attempt_timer_save
	.deny_nocape:
		LDA !save_timer_address
		CLC
		ADC #$04
		STA !save_timer_address
		
		JSR attempt_timer_save
		LDA !save_timer_address
		CLC
		ADC #$04
		STA !save_timer_address
		
		LDA !record_lunar_dragon
		BEQ .done
		JSR attempt_timer_save
		
	.done:
		LDA.L !use_poverty_save_states
		BEQ .keep_state
		LDA #$00
		STA.L !save_state_exists
	.keep_state:
		LDA #$FF
		STA !save_timer_address+2
		STZ !l_r_function
		STZ !slowdown_speed
		STZ !in_overworld_menu
		JSL $04DAAD ; layer 2 tilemap upload routine
		
		RTL

; this code is run once on overworld load, but after everything else has loaded already
late_overworld_load:
		PHP
		SEP #$20
		REP #$10
		
		LDA #$80
		STA $2115 ; vram increment
		LDX #$4490
		STX $2116 ; vram address
		PHK
		PLA ; #bank of overworld_layer_3_tiles
		LDX #overworld_layer_3_tiles
		LDY #$0030
		JSL load_vram
		
		LDX #$46A0
		STX $2116 ; vram address
		PHK
		PLA ; #bank of overworld_layer_3_tiles
		LDX #overworld_layer_3_tiles+$30
		LDY #$0030
		JSL load_vram
		
		LDX #$4200
		STX $2116 ; vram address
		PHK
		PLA ; #bank of overworld_layer_3_tiles
		LDX #overworld_layer_3_tiles+$60
		LDY #$0050
		JSL load_vram
		
		LDX #$4D30
		STX $2116 ; vram address
		PHK
		PLA ; #bank of overworld_layer_3_tiles
		LDX #overworld_layer_3_tiles+$B0
		LDY #$0040
		JSL load_vram
		
		PLP
		RTL

overworld_layer_3_tiles:
		incbin "bin/overworld_layer3_tiles.bin"
		
; compare the timer stored at !save_timer_address against the current time, and save it if it is faster
attempt_timer_save:
		LDA !save_timer_address
		STA $00
		LDA !save_timer_address+1
		STA $01
		LDA !save_timer_address+2
		STA $02
		
		LDY #$03
		LDA [$00],Y
		AND #$20
		CMP !record_used_orb
		BEQ .check_time
		CMP #$00
		BEQ .done
		BRA .new_record
		
	.check_time:
		LDY #$00
	.check_loop:
		CPY #$03
		BEQ .done
		LDA [$00],Y
		CMP #$FF
		BEQ .new_record
		CMP !level_timer_minutes,Y
		BEQ .continue
		BMI .done
		BPL .new_record
	.continue:
		INY
		BRA .check_loop
		
	.new_record:
		LDY #$00
	.save_loop:
		CPY #$03
		BEQ .save_attributes
		LDA !level_timer_minutes,Y
		STA [$00],Y
		INY
		BRA .save_loop
	
	.save_attributes:
		LDA $1F28 ; yellow switch blocks
		ASL A
		ORA $1F27 ; green switch blocks
		ASL A
		ORA $1F2A ; red switch blocks
		ASL A
		ORA $1F29 ; blue switch blocks
		STA $04
		CLC
		LDA.L !status_special
		ROR A
		ROR A
		TSB $04
		LDA !record_used_yoshi
		TSB $04
		LDA !record_used_orb
		TSB $04
		
		LDA $04
		STA [$00],Y
		
	.done:
		RTS

; this will run when exiting the title screen
prepare_file:
		JSR set_overworld_position
		RTL

; initialize mario on the overworld
set_overworld_position:
		LDA !save_data_exists
		CMP #$BD
		BEQ .already_exists
		JSL delete_all_data
	.reset:
		JSL set_position_to_yoshis_house
		BRA .merge
	.already_exists:
		LDA.L !save_overworld_submap
		CMP #$07
		BCS .reset
		STA $1F11
		LDA.L !save_overworld_x
		STA $1F17
		LDA.L !save_overworld_x+1
		CMP #$02
		BCS .reset
		STA $1F18
		LDA.L !save_overworld_y
		STA $1F19
		LDA.L !save_overworld_y+1
		CMP #$02
		BCS .reset
		STA $1F1A
		LDA.L !save_overworld_animation
		STA $1F13
		JSL update_ow_position_pointers
		
	.merge:
		LDA #$00
		STA.L !use_poverty_save_states
		LDA #$AA
		STA $717FFF
		LDA #$BB
		STA $737FFF
		LDA $717FFF
		CMP #$AA
		BEQ .done
		
		LDA #$BD
		STA.L !use_poverty_save_states
		
	.done:
		RTS

; set marios position on the overworld to yoshi's house
set_position_to_yoshis_house:
		LDA #$BD
		STA.L !save_data_exists
		LDA #$01
		STA.L !save_overworld_submap
		STA $1F11
		LDA #$68
		STA.L !save_overworld_x
		STA $1F17
		LDA #$00
		STA.L !save_overworld_x+1
		STA $1F18
		LDA #$78
		STA.L !save_overworld_y
		STA $1F19
		LDA #$00
		STA.L !save_overworld_y+1
		STA $1F1A
		LDA #$02
		STA.L !save_overworld_animation
		STA $1F13
		JSL update_ow_position_pointers
		RTL

; update the pointers to overworld poitions
update_ow_position_pointers:
		REP #$20
		LDX #$06
	.loop:
		LDA $1F17,X
		LSR #4
		STA $1F1F,X
		DEX #2
		BPL .loop
		SEP #$20
		RTL