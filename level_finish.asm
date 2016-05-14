!save_timer_address = $0F20 ; 3 bytes

ORG $138000

; this code is run once on the frame that the level is completed
; X = 1 if the secret exit was activated, 0 otherwise
level_finish:
		LDA #$01
		STA !freeze_timer_flag
		RTL