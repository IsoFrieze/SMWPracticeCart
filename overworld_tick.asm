ORG $148000

; this code is run on every frame during the overworld game mode (after fade in completes)
overworld_tick:
		PHP
		PHB
		PHK
		PLB
		JSR update_potential_translevel
		JSR test_for_powerup
		JSR test_for_yoshi
		JSR test_for_swap
		JSR test_for_menu
		JSR draw_times
		PLB
		PLP
		RTL

; set the translevel of the tile mario is currently standing on
; (code taken from $05D850)
update_potential_translevel:
		PHP
		REP #$30

		LDA $1F1F
		AND #$000F
		STA $00
		LDA $1F21
		AND #$000F
		ASL A
		ASL A
		ASL A
		ASL A
		STA $02
		LDA $1F1F
		AND #$0010
		ASL A
		ASL A
		ASL A
		ASL A
		ORA $00
		STA $00
		LDA $1F21
		AND #$0010
		ASL A
		ASL A
		ASL A
		ASL A
		ASL A
		ORA $02
		ORA $00
		TAX
		LDA $1F11
		AND #$00FF
		BEQ .no_add
		TXA
		CLC
		ADC #$0400
		TAX
	.no_add:
		SEP #$20
		LDA $7ED000,X
		STA !potential_translevel
		
		PLP
		RTS

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
		
		LDA #$1C ; switch block ding
		STA $1DFC ; apu i/o
		
		LDA #$1C ; fade to overworld load
		STA $0100
		
	.done:
		RTS

; call the movement function a lot
iterate_overworld_movement:
		LDX #$07
	.loop:
		PHX
		JSR test_movement
		PLX
		DEX
		BPL .loop
		
		RTL

; only call the movement function at appropriate times
; this snippet taken from WhiteYoshiEgg & carol's OW Speed Changer patch
test_movement:
		LDA $13D9 ; overworld process
		CMP #$04
		BNE .done
		PHK
		PEA .done-1
		PEA $8575-1
		JML $04945D ; movement routine
	.done:
		RTS

; draw record times onto the overworld border
draw_times:
		LDA $144E ; overworld forward timer
		CMP #$0E
		BNE .done
		
		REP #$20
		LDA !potential_translevel
		AND #$007F
		ASL A
		ASL A
		ASL A
		ASL A
		ASL A
		STA $00
		SEP #$20
		LDA #$70
		STA $02
		
		LDY #$07
	.loop:
		JSR load_unran_time
		TYA
		ASL A
		ASL A
		PHY
		TAY
		LDA [$00],Y
		CMP #$FF
		BEQ .draw_unran
		LDA !potential_translevel
		BEQ .draw_unran
		
		PHX
		LDA [$00],Y
		STA $0D
		JSL $00974C ; hex2dec
		TAX
		LDA tile_numbers,X
		STA !dynamic_stripe_image+4
		INY
		LDA [$00],Y
		STA $0E
		JSL $00974C ; hex2dec
		PHA
		LDA tile_numbers,X
		STA !dynamic_stripe_image+8
		PLA
		TAX
		LDA tile_numbers,X
		STA !dynamic_stripe_image+10
		INY
		LDA [$00],Y
		STA $0F
		JSR get_fractions_of_time
		PHA
		LDA tile_numbers,X
		STA !dynamic_stripe_image+14
		PLA
		TAX
		LDA tile_numbers,X
		STA !dynamic_stripe_image+16
		PLX
		JSR compare_to_gold
		JSR load_stripe_from_buffer
		PLY
	
	.continue:
		DEY
		BPL .loop
		
	.done:
		RTS
	
	.draw_unran:
		PLY
		LDA !potential_translevel
		TAX
		LDA translevel_types,X
		PHY
	.shift_loop:
		CPY #$00
		BEQ .no_shift
		LSR A
		DEY
		BRA .shift_loop
	.no_shift:
		PLY
		AND #$01
		BEQ .draw_blank
		JSR load_stripe_from_buffer
		JMP .continue
	.draw_blank:
		JSR load_blank_time
		JSR load_stripe_from_buffer
		JMP .continue
		
get_fractions_of_time:
		PHA
		LDA !status_fractions
		BNE .frames
		PLA
		TAX
		LDA.L fractional_seconds,X
		BRA .done
	.frames:
		PLA
	.done:
		JSL $00974C ; hex2dec
		RTS
		
load_unran_time:
		PHY
		LDY #$12
	.loop:
		LDA default_time_stripe,Y
		STA !dynamic_stripe_image,Y
		DEY
		BPL .loop
		PLY
		LDA times_position,Y
		STA !dynamic_stripe_image+1
		LDA !status_fractions
		BEQ .done
		LDA #$5D
		STA !dynamic_stripe_image+12
	.done:
		RTS

load_blank_time:
		PHY
		LDY #$12
	.loop:
		LDA blank_stripe,Y
		STA !dynamic_stripe_image,Y
		DEY
		BPL .loop
		PLY
		LDA times_position,Y
		STA !dynamic_stripe_image+1
		RTS

load_stripe_from_buffer:
		PHY
		PHX
		REP #$30
		LDA $7F837B
		TAX
		SEP #$20
		
		LDY #$0000
	.loop:
		CPY #$0013
		BCS .done
		LDA !dynamic_stripe_image,Y
		STA $7F837D,X
		INY
		INX
		BRA .loop
	.done:
		REP #$20
		DEX
		TXA
		STA $7F837B
		SEP #$30
		PLX
		PLY
		RTS

compare_to_gold:
		PHB
		PHK
		PLB
		PHX
		PHY
		PHP
		
		REP #$30
		LDA $00
		AND #$0FFF
		TAX
		SEP #$20
		INY
		LDA [$00],Y
		AND #$20
		BNE .no_gold
		DEY
		DEY
		DEY
		
		LDA [$00],Y
		CMP gold_times,X
		BCC .yes_gold
		BNE .no_gold
		INY
		INX
		
		LDA [$00],Y
		CMP gold_times,X
		BCC .yes_gold
		BNE .no_gold
		INY
		INX
		
		LDA [$00],Y
		CMP gold_times,X
		BCC .yes_gold
		BRA .no_gold
		
	.yes_gold:
		LDA #$29
		STA !dynamic_stripe_image+5
		STA !dynamic_stripe_image+7
		STA !dynamic_stripe_image+9
		STA !dynamic_stripe_image+11
		STA !dynamic_stripe_image+13
		STA !dynamic_stripe_image+15
		STA !dynamic_stripe_image+17
		
	.no_gold:
		PLP
		PLY
		PLX
		PLB
		RTS

; tiles for numbers 0-9
tile_numbers:
		db $22,$23,$24,$25,$26
		db $27,$28,$29,$2A,$2B

; flags to tell which times to show by default for each level
translevel_types:
		db $00,$0F,$0F,$00
		db $77,$0F,$0F,$07
		db $07,$7F,$FF,$07
		db $0F,$0F,$07,$FF
		db $0F,$0F,$00,$77
		db $07,$FF,$00,$00
		db $0E,$00,$07,$07
		db $0F,$0F,$00,$07
		db $0F,$07,$0F,$FF
		db $7F,$07,$0F,$0F
		db $00,$0F,$0F,$0F
		db $00,$FF,$0F,$0F
		db $00,$07,$07,$77
		db $0F,$07,$0F,$0F
		db $FF,$7F,$0F,$07
		db $FF,$0F,$FF,$07
		db $07,$F7,$77,$FF
		db $FF,$07,$0F,$FF
		db $0F,$00,$0F,$0F
		db $0F,$00,$0F,$0F
		db $0F,$0F,$00,$00
		db $77,$00,$77,$00
		db $EE,$77,$77,$00
		db $00

; the 2nd byte of the stripe image header
times_position:                                
        db $2F,$4F,$6F,$8F
        db $37,$57,$77,$97

; a stripe image that shows -'--.--
default_time_stripe:
        db $50,$FF,$00,$0D
        db $1C,$39,$5D,$39
        db $1C,$39,$1C,$39
        db $1B,$39,$1C,$39
        db $1C,$39,$FF

; a stripe image that shows completely blank
blank_stripe:
        db $50,$FF,$00,$0D
        db $FE,$38,$FE,$38
        db $FE,$38,$FE,$38
        db $FE,$38,$FE,$38
        db $FE,$38,$FF

; a complete set of times for each level for each kind
; having a time better than the one here will result in a gold time
gold_times:
		incbin "bin/overworld_gold_times.bin"