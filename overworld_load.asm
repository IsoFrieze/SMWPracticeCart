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
		LDA #$FF
		STA !save_timer_address+2
		JSL $04DAAD ; layer 2 tilemap upload routine
		RTL
		
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
		LDA !status_special
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

; set sram to an 'acceptable' value as a temporary measure against flashcarts that don't support more than 32kB of sram
emergency_clear:
		LDA $0DA4 ; byetudlr
		AND #%00001000
		BEQ .done
		LDA $0DA4 ; axlr----
		AND #%00010000
		BEQ .done
		LDA $0DA6 ; byetudlr frame
		AND #%00010000
		BEQ .done
		
		LDA #$BD
		STA $700000
		LDA #$01 ; submap
		STA $700001
		LDA #$68 ; x low
		STA $700002
		LDA #$00 ; x high
		STA $700003
		LDA #$78 ; y low
		STA $700004
		LDA #$00 ; y high
		STA $700005
	
	.done:
		RTL