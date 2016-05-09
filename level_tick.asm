ORG $158000
level_tick:
		JSR display_coins
		; JSR display_time ; already done in original status bar routine
		JSR display_speed
		JSR display_takeoff
		JSR display_pmeter
		RTL

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