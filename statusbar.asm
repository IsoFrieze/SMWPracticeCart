!status_bar = $1F2F

; status bar default tiles and properties for each tile
ORG $008C59
Status_bar_tiles:
	db $00,$2C,$00,$2C,$FC,$3C,$FC,$3C,$FC,$3C,$76,$3C,$27,$3C,$85,$3C,$27,$3C,$27,$3C,$86,$3C,$27,$3C,$27,$3C,$3A,$38,$3B,$38,$3B,$38,$3A,$78,$2E,$3C,$FC,$38,$00,$38,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$15,$28,$21,$28,$1E,$28
	db $FC,$38,$FC,$38,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$27,$38,$85,$38,$27,$38,$27,$38,$86,$38,$27,$38,$27,$38,$4A,$38,$FC,$3C,$FC,$3C,$4A,$78,$FC,$3C,$FC,$3C,$00,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$1B,$28,$0A,$28,$15,$28
	db $19,$3C,$00,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$4A,$38,$FC,$3C,$FC,$3C,$4A,$78,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$1C,$28,$22,$28,$1B,$28
	db $FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$3A,$B8,$3B,$B8,$3B,$B8,$3A,$F8,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$0E,$28,$0B,$28,$0D,$28
	
; DMA 4 lines of status bar tile properties+default tiles
DMA_Status_Bar:		
		LDX #$03
	.loop_property_lines:
		LDA #$01
		STA $4310
		LDA #$18
		STA $4311
		LDA #$00
		STA $4314
		LDA #$3C
		STA $4315
		LDA #$00
		STA $4316
		
		LDA #$80
		STA $2115
		LDA line_pos,X
		STA $2116
		LDA #$50
		STA $2117
		LDA properties_low,X
		STA $4312
		LDA properties_high,X
		STA $4313
		LDA #$02
		STA $420B
		DEX
		BPL .loop_property_lines
		
		JSR DMA_Status_Bar_Tiles
		JSR default_status_bar
		RTS
		
	line_pos:
		db $21,$41,$61,$81
	tiles_high:
		db $1F,$1F,$1F,$1F
	tiles_low:
		db $2F,$4D,$6B,$89
	properties_high:
		db $8C,$8C,$8C,$8D
	properties_low:
		db $59,$95,$D1,$0D

; DMA 4 lines of status bar tiles based on !status_bar
DMA_Status_Bar_Tiles:
		LDX #$03
	.loop_tile_lines:
		LDA #$00
		STA $4310
		LDA #$18
		STA $4311
		LDA #$00
		STA $4314
		LDA #$1E
		STA $4315
		LDA #$00
		STA $4316
		
		STZ $2115
		LDA line_pos,X
		STA $2116
		LDA #$50
		STA $2117
		LDA tiles_low,X
		STA $4312
		LDA tiles_high,X
		STA $4313
		LDA #$02
		STA $420B
		DEX
		BPL .loop_tile_lines
		RTS

; initialize !status_bar with default tiles in tilemap
default_status_bar:
		LDX #$EE
		LDY #$77
	.loop:
		LDA Status_bar_tiles,X
		STA !status_bar,Y
		DEX
		DEX
		DEY
		BPL .loop
		RTS

; number of scanlines used by layer 3 in normal level mode
ORG $008293
	db $28

; relocate calls to above routines
ORG $00985A
	JSR DMA_Status_Bar
ORG $00A5A8
	JSR DMA_Status_Bar
ORG $0081F4
	JSR DMA_Status_Bar_Tiles
ORG $0082E8
	JSR DMA_Status_Bar_Tiles
	
; disable all the old status bar counters
; lives, coins, score, bonus stars, dragon coins
ORG $008E81
		JMP $8F1D
ORG $008F3B
		RTS

; relocate the time counter
ORG $008E6F
	LDA $0F31
	STA $1F5E
	LDA $0F32
	STA $1F5F
	LDA $0F33
	STA $1F60
ORG $008E8C
	STA $1F4E,X