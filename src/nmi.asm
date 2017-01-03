ORG $168000

; this code is run on every NMI; therefore, it is guaranteed to run 60 times per second, even if the game is lagging
nmi_expand:
		INC !counter_sixty_hz
		
		LDA $0100
		CMP #$13 ; level fade in
		BNE .done
		JSL load_slots_graphics
		
	.done:
		RTL
		
controller_update:
		LDA !in_playback_mode
		BNE .skip
		
		LDA.W $4218
		AND.B #$F0 
		STA.W $0DA4
		TAY        
		EOR.W $0DAC
		AND.W $0DA4
		STA.W $0DA8
		STY.W $0DAC
		LDA.W $4219
		STA.W $0DA2
		TAY        
		EOR.W $0DAA
		AND.W $0DA2
		STA.W $0DA6
		STY.W $0DAA
		LDA.W $421A
		AND.B #$F0 
		STA.W $0DA5
		TAY        
		EOR.W $0DAD
		AND.W $0DA5
		STA.W $0DA9
		STY.W $0DAD
		LDA.W $421B
		STA.W $0DA3
		TAY        
		EOR.W $0DAB
		AND.W $0DA3
		STA.W $0DA7
		STY.W $0DAB
	.skip:
		
		JSL empty_controller_regs
		LDX #$01
	.loop:
		LDA $0DA4,X
		AND #$C0
		ORA $0DA2,X
		TSB $15
		LDA $0DA4,X
		TSB $17
		LDA $0DA8,X
		AND #$40
		ORA $0DA6,X
		TSB $16
		LDA $0DA8,X
		TSB $18
		DEX
		BPL .loop
		RTL

; runs on BRK
break:
		SEI
		LDA #$80
		STA $2100 ; force blank
		
		LDA #$00
		STA $4200 ; disable nmi, controller
		
		LDA #$1A
		STA $2142 ; spooky music
		LDA #$00
		STA $2105 ; bgmode
		LDA #$20
		STA $2107 ; bg1sc
		LDA #$00
		STA $210B ; bg12nba
		LDA #$00
		STA $210D
		STA $210D ; bg1hofs
		STA $210E
		STA $210E ; bg1vofs
		LDA #$00
		STA $212C ; tm
		LDA #$00
		STA $212D ; ts
		LDA #$32
		STA $2130 ; cgswsel
		LDA #$60
		STA $2132
		LDA #$9F
		STA $2132 ; coldata
		LDA #$21
		STA $2131 ; cgadsub
		
		LDA #$00
		STA $2121 ; cgadd
		STA $2122
		LDA #$7C
		STA $2122
		LDA #$7F
		LDX #$FF
		STX $2122
		STA $2122
		STX $2122
		STA $2122
		STX $2122
		STA $2122 ; cgdata
		
		REP #$10
		LDX #$0000
		STX $2116
		PHK
		PLA
		LDX #break_tiles
		LDY #$2000
		JSL load_vram
		
		LDX #$2000
		STX $2116
		PHK
		PLA
		LDX #break_tilemap
		LDY #$0800
		JSL load_vram
		
		LDX #$2085
		STX $2116 ; vram address
		LDA #$00
		XBA
		LDA $07,S
		TAX
		STX $2118 ; vram data
		LDA $06,S
		TAX
		STX $2118 ; vram data
		LDA $05,S
		DEC #2
		TAX
		STX $2118 ; vram data
		
		REP #$20
		LDA #$0100
		STA $00
		LDX #$2122
	.loop_row:
		STX $2116 ; vram address
		LDY #$0000
	.loop_byte:
		LDA ($00)
		AND #$00FF
		STA $2118 ; vram data
		INC $00
		INY
		CPY #$0010
		BNE .loop_byte
		TXA
		CLC
		ADC #$0020
		TAX		
		CPX #$2322
		BNE .loop_row
		
		LDX #$2350
		STX $2116 ; vram address
		TSX
		TXA
		XBA
		AND #$00FF
		STA $2118 ; vram data
		TXA
		AND #$00FF
		STA $2118 ; vram data
		
		SEP #$20
		LDA #$0F
		STA $2100 ; exit force blank
		
		LDY #$0006
		LDX #$0000
	.loop:
		DEX
		BNE .loop
		DEY
		BNE .loop
		
		LDA #$80
		STA $2100 ; force blank
		LDA #$01
		STA $212C ; tm
		LDA #$0F
		STA $2100 ; exit force blank
		
		LDY #$0030
		LDX #$0000
	.loop_2:
		DEX
		BNE .loop_2
	.wait_for_vblank:
		LDA $4212
		BPL .wait_for_vblank
		LDA #$80
		STA $2100 ; force blank
		
		CPY #$001C
		BCS .no_number
		REP #$20
		TYA
		LSR #2
		CLC
		ADC #$0130
		PHX
		LDX #$2056
		STX $2116 ; vram address
		STA $2118 ; vram data
		PLX
		SEP #$20
		
	.no_number:
		LDA #$0F
		STA $2100 ; exit force blank
				
		DEY
		BNE .loop_2
		
	.escape:
		LDA #$81
		STA $4200 ; enable nmi, controller
		CLI
		RTL

break_tiles:
		incbin "bin/break_bg_tiles.bin"
break_tilemap:
		incbin "bin/break_bg_tilemap.bin"
		