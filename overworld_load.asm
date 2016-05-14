ORG $118000

; this code is run once on overworld load
overworld_load:
		LDA $0DD5 ; level exit type
		CMP #$80 ; type = death or start/select
		BEQ .done
		LDA !save_timer_address+2
		BMI .done ; bank >= 80 -> no record
		
		; TODO save the time
		
	.done:
		RTL