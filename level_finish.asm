ORG $138000

; this code is run once on the frame that the level is completed
; X = 1 if the secret exit was activated, 0 otherwise
level_finish:
		PHP
		LDA #$01
		STA !freeze_timer_flag
		STA !level_finished
		JSL set_time_save_address
		PLP
		RTL

; set the appropriate pointer corresponding to this level and exit
; X = 1 if the secret exit was activated, 0 otherwise
set_time_save_address:
		LDA.L !spliced_run
		BEQ .continue
		LDA #$FF
		STA !save_timer_address+2
		BRA .done
	.continue:
		LDA #$70
		STA !save_timer_address+2
		REP #$20
		STZ !save_timer_address
		LDA $13BF ; translevel
		AND #$007F
		ASL A
		ASL A
		ASL A
		ASL A
		ASL A
		TSB !save_timer_address ; apply level number
		SEP #$20
		TXA
		ASL A
		ASL A
		ASL A
		ASL A
		TSB !save_timer_address ; apply exit
	.done:
		RTL