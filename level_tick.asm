!level_timer_minutes        = $0F5E
!level_timer_seconds        = $0F5F
!level_timer_frames         = $0F60
!backup_level_timer_minutes = $0F61
!backup_level_timer_seconds = $0F62
!backup_level_timer_frames  = $0F63
!room_timer_minutes         = $0F64
!room_timer_seconds         = $0F65
!room_timer_frames          = $0F66

ORG $158000

; this code is run on every frame during the level game mode (after fade in completes)
level_tick:
		PHP
		PHB
		PHK
		PLB
		JSR display_coins
;		JSR display_time ; already done in original status bar routine
		JSR display_speed
		JSR display_takeoff
		JSR display_pmeter
		JSR display_timers
		JSR display_dropped_frames
		PLB
		PLP
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
		LDA #$0F
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
		LDA #$0F
		STA $1F57
		JMP .merge
	.draw_room_fractions:
		LDX !room_timer_frames
		LDA fractional_seconds,X
		JSL $00974C ; hex2dec
		STX $1F58 ; tens
		STA $1F59 ; ones
		
	.merge:
		RTS

; table to convert frames into hundredths of seconds
fractional_seconds:
		db $00,$01,$03,$05,$07,$08,$0A,$0B,$0D,$0F,$11,$12
		db $14,$15,$17,$19,$1B,$1C,$1E,$1F,$21,$23,$25,$26
		db $28,$29,$2B,$2D,$2F,$30,$32,$33,$35,$37,$39,$3A
		db $3C,$3D,$3F,$41,$43,$44,$46,$47,$49,$4B,$4D,$4E
		db $50,$51,$53,$55,$57,$58,$5A,$5B,$5D,$5F,$61,$62

; draw the number of dropped frames to the status bar
display_dropped_frames:
		LDA $FC ; lag
		JSL $00974C ; hex2dec
		STX $1F76 ; tens
		STA $1F77 ; ones
		RTS