ORG $178000

; this code is run on every single frame of execution
every_frame:
		PHP
		SEP #$20
		JSR update_dropped_frames
		
		LDA !in_overworld_menu
		BEQ .done
		JSL update_background
		
	.done:
		PLP
		RTL
		
; get the number of frames dropped this execution frame, and update the total
update_dropped_frames:
		LDA !counter_sixty_hz
		SEC
		SBC !previous_sixty_hz
		STA !real_frames
		DEC A
		REP #$20
		AND #$00FF
		CLC
		ADC !dropped_frames
		STA !dropped_frames
		SEP #$20
		LDA !counter_sixty_hz
		STA !previous_sixty_hz
		RTS