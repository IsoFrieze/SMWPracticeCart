; status bar default tiles and properties for each tile
ORG !_F+$008C59
	
; DMA 4 lines of status bar tile properties+default tiles
DMA_Status_Bar:		
		JSL init_statusbar_properties
		JSR default_status_bar
		JSR DMA_Status_Bar_Tiles
		RTS

; DMA 5 lines of status bar tiles based on !status_bar
DMA_Status_Bar_Tiles:
		LDX #$04
	.loop_tile_lines:
		LDA #$00
		STA $4310
		LDA #$18
		STA $4311
		LDA #$00
		STA $4314
		LDA #$20
		STA $4315
		LDA #$00
		STA $4316
		
		STZ $2115
		LDA .line_pos,X
		STA $2116
		LDA #$50
		STA $2117
		LDA .tiles_low,X
		STA $4312
		LDA .tiles_high,X
		STA $4313
		LDA #$02
		STA $420B
		DEX
		BPL .loop_tile_lines
		RTS
		
	.line_pos:
		db $00,$20,$40,$60,$80
	.tiles_high:
		db $1F,$1F,$1F,$1F,$1F
	.tiles_low:
		db $30,$50,$70,$90,$B0

; clear the status bar
default_status_bar:
		LDA #$FC
		LDX #$A0
	.loop:
		STA !status_bar-1,X
		DEX
		BNE .loop
		RTS

; number of scanlines used by layer 3 in normal level mode
ORG !_F+$008293
		db $26

; relocate calls to above routines
ORG !_F+$00985A
		JSR DMA_Status_Bar
ORG !_F+$00A5A8
		JSR DMA_Status_Bar
ORG !_F+$0081F4
		JSR DMA_Status_Bar_Tiles
ORG !_F+$0082E8
		JSR DMA_Status_Bar_Tiles
	
; disable all the old status bar counters
; lives, coins, score, bonus stars, dragon coins
; also draw the bowser timer
ORG !_F+$008E81
		JSL draw_bowser_timer
		JMP $8F1D
ORG !_F+$008F3B
		JSR $9079 ; draw item in itembox
		RTS

; draw the time to the status bar
; in a hijack to preserve the one-frame latency
ORG !_F+$008E6F
	;	JSL display_time ; TODO fix latency
		JMP $8E81
ORG !_F+$008E8C
		STA $1F4E,X