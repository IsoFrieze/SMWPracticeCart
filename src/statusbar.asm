ORG !_F+$008C59

DMA_Status_Bar_Wrapper:
        PHB
        PHK
        PLB
        JSL init_statusbar_properties
        JSR DMA_Status_Bar_Tiles
        PLB
        RTL
    
; DMA 4 lines of status bar tile properties+default tiles
DMA_Status_Bar:        
        JSL init_statusbar_properties
        JSL default_status_bar
        JSR DMA_Status_Bar_Tiles
        RTS

; DMA 5 lines of status bar tiles based on !status_bar
DMA_Status_Bar_Tiles:
        LDA $0100
        CMP #$1D ; load overworld menu
        BCS +
        LDA #$00
        STA $2116
        LDA #$50
        STA $2117
        BRA .merge
      + LDA #$A0
        STA $2116
        LDA #$53
        STA $2117
        
    .merge:
        LDX #$00
      - LDA #$00
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
        LDA .tiles_low,X
        STA $4312
        LDA .tiles_high,X
        STA $4313
        LDA #$02
        STA $420B
        INX
        CPX #$05
        BNE -
        RTS
        
    .tiles_high:
        db $1F,$1F,$1F,$1F,$1F
    .tiles_low:
        db $30,$50,$70,$90,$B0

; clear the status bar
default_status_bar:
        LDA #$FC
        LDX #$A0
      - STA !status_bar-1,X
        DEX
        BNE -
        RTL

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
ORG !_F+$0082E6
        NOP
        NOP
        JSR DMA_Status_Bar_Tiles
    
; disable all the old status bar counters
; lives, coins, score, bonus stars, dragon coins
ORG !_F+$008E81
        JMP $8F1D
ORG !_F+$008F3B
        JSR $9079 ; draw item in itembox
        RTS
ORG !_F+$008E6F
        JMP $8E81
ORG !_F+$008E8C
        STA $1F4E,X
        JMP $8E95
