; point game mode 8 to start game
; this will skip all file and player menuing
ORG $009339
		dw $9E10

; disable routine that gets the number of exits
; and shows it on the screen
; we specifically nop out this routine because
; we use the now-free space for a routine below
ORG $009CB8
		NOP #3
		
; disable disabling sprite layer on title screen
ORG $009CA5
		NOP #3
	
; write overworld
; set mario's overworld position if it is saved in sram
ORG $009D38
set_marios_overworld_position:
		LDA #$01 ; submap
		STA $1F11
		LDA #$68 ; x low
		STA $1F17
		LDA #$00 ; x high
		STA $1F18
		LDA #$78 ; y low
		STA $1F19
		LDA #$00 ; y high
		STA $1F1A
		
		LDA #$00
		STA.L !disallow_save_states
		LDA #$AA
		STA $717FFF
		LDA #$BB
		STA $737FFF
		LDA $717FFF
		CMP #$AA
		BEQ .done
		
		LDA #$01
		STA.L !disallow_save_states
		
	.done:
		RTS

; this is broken
;=========================================
		LDA $700000
		CMP #$BD
		BEQ .already_set
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
		JSL delete_all_data
	.already_set:
		LDA $700001
		STA $1F11 ; submap
		LDA $700002
		STA $1F17 ; x low
		LDA $700003
		STA $1F18 ; x high
		LDA $700004
		STA $1F19 ; y low
		LDA $700005
		STA $1F1A ; y high
		RTS

; jump to above routine
; set all levels as beaten and enable all directions
; on all overworld tiles
ORG $009F0E
prepare_overworld:
		JSR set_marios_overworld_position
		LDA #$8F
		LDX #$5F
	.loop:
		STA $1EA2,X
		DEX
		BPL .loop
		RTS

; give the cartridge more SRAM
ORG $00FFD8
		db $07