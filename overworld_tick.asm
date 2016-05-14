ORG $148000

; this code is run on every frame during the overworld game mode (after fade in completes)
overworld_tick:
		JSR test_for_powerup
		JSR test_for_yoshi
		JSR test_for_swap
		JSR test_for_menu
		RTL

; if R is pressed, cycle through powerup
test_for_powerup:
		LDA $0DA8 ; frame axlr----
		AND #%00010000
		BEQ .done
		
		LDA $19
		INC A
		CMP #$04
		BNE .skip_0
		LDA #$00
	.skip_0:
		STA $19
		STA $0DB8
		
	.done:
		RTS

; if L is pressed, cycle through yoshi color
test_for_yoshi:
		LDA $0DA8 ; frame axlr----
		AND #%00100000
		BEQ .done
		
		LDA $0DBA ; ow yoshi color
	.loop:
		INC A
		INC A
		CMP #$02
		BEQ .loop
		CMP #$0C
		BNE .skip_0
		LDA #$00
	.skip_0:
		STA $13C7 ; yoshi color
		STA $0DBA ; ow yoshi color
		LDA #$01
		STA $0DC1 ; persistent yoshi flag
		
	.done:
		RTS

; if select is pressed, swap powerup and item box powerup (if applicable)
test_for_swap:
		LDA $0DA6 ; frame byetudlr
		AND #%00100000
		BEQ .done
		LDA $19 ; powerup
		AND #$FC
		BNE .done
		LDA $0DC2 ; itembox
		CMP #$03
		BEQ .done
		CMP #$04
		BNE .skip
		DEC A
	.skip:
		AND #$FC
		BNE .done
		
		LDA $19 ; powerup
		CMP #$02
		BNE .not_cape
		ASL A
	.not_cape:
		CMP #$03
		BNE .not_fire
		DEC A
	.not_fire:
		STA $00
		LDA $0DC2 ; itembox
		CMP #$02
		BNE .not_flower
		INC A
	.not_flower:
		CMP #$04
		BNE .not_feather
		LSR A
	.not_feather:
		STA $19 ; powerup
		STA $0DB8 ; ow powerup
		LDA $00
		STA $0DC2 ; itembox
		STA $0DBC ; ow itembox
		
	.done:
		RTS

; if start is pressed, go to menu
test_for_menu:
		LDA $0DA6 ; frame byetudlr
		AND #%00010000
		BEQ .done
		LDA $144E ; ow mario animation
		BNE .done
		LDA $1DF7 ; star warp timer
		BNE .done
		
		LDA #$1C ; switch block ding
		STA $1DFC ; apu i/o
		
		; TODO actually change the game mode to fade to menu load
		
	.done:
		RTS