ORG !_F+$168000

reset bytes

; this code is run on every NMI; therefore, it is guaranteed to run 60 times per second, even if the game is lagging
nmi_expand:
        INC !counter_sixty_hz
        LDA $0100
        CMP #$13 ; level fade in
        BNE +
        JSL load_slots_graphics
      + RTL
        
controller_update:
        LDA !in_playback_mode
        BEQ +
        JMP .skip
        
      + LDA.W $4218
        AND.B #$F0 
        STA.W !util_axlr_hold
        TAY
        EOR.W !util_axlr_mask
        AND.W !util_axlr_hold
        STA.W !util_axlr_frame
        STY.W !util_axlr_mask
        LDA.W $4219
        STA.W !util_byetudlr_hold
        TAY
        EOR.W !util_byetudlr_mask
        AND.W !util_byetudlr_hold
        STA.W !util_byetudlr_frame
        STY.W !util_byetudlr_mask
        
        STZ !util_byetudlr_hold+1
        STZ !util_byetudlr_frame+1
        STZ !util_axlr_hold+1
        STZ !util_axlr_frame+1
        
        LDA.L !status_controller
        BEQ .skip
        
        LDA.W $421A
        AND.B #$F0 
        STA.W !util_axlr_hold+1
        TAY
        EOR.W !util_axlr_mask+1
        AND.W !util_axlr_hold+1
        STA.W !util_axlr_frame+1
        STY.W !util_axlr_mask+1
        LDA.W $421B
        STA.W !util_byetudlr_hold+1
        TAY
        EOR.W !util_byetudlr_mask+1
        AND.W !util_byetudlr_hold+1
        STA.W !util_byetudlr_frame+1
        STY.W !util_byetudlr_mask+1
        
        LDA.L !status_controller
        CMP #$02
        BNE .skip
        LDA !util_byetudlr_hold+1
        TSB !util_byetudlr_hold
        LDA !util_byetudlr_frame+1
        TSB !util_byetudlr_frame
        LDA !util_axlr_hold+1
        TSB !util_axlr_hold
        LDA !util_axlr_frame+1
        TSB !util_axlr_frame
    .skip:
        
        JSL empty_controller_regs
        LDX #$01
      - LDA !util_axlr_hold,X
        AND #$C0
        ORA !util_byetudlr_hold,X
        TSB !mario_byetudlr_hold
        LDA !util_axlr_hold,X
        TSB !mario_axlr_hold
        LDA !util_axlr_frame,X
        AND #$40
        ORA !util_byetudlr_frame,X
        TSB !mario_byetudlr_frame
        LDA !util_axlr_frame,X
        TSB !mario_axlr_frame
        DEX
        BPL -
        RTL

; runs on BRK
break:
        PHP
        PHB
        PHD
        REP #$30
        PHA
        PHX
        PHY
        SEI
        SEP #$30
        
        LDA #$80
        STA $2100 ; force blank
        
        LDA #$00
        STA $4200 ; disable nmi, controller
        
        LDA #$1A
        STA $2142 ; spooky music
        LDA #$05
        STA $2105 ; bgmode
        STZ $2106 ; mosaic
        LDA #$20
        STA $2107 ; bg1sc
        LDA #$24
        STA $2108 ; bg2sc
        LDA #$00
        STA $210B ; bg12nba
        LDA #$04
        STA $210D
        STA $210D ; bg1hofs
        LDA #$00
        STA $210E
        STA $210E ; bg1vofs
        STA $210F
        STA $210F ; bg2hofs
        STA $2110
        STA $2110 ; bg2vofs
        LDA #$00
        STA $212C ; tm
        STA $212D ; ts
        STA $212E ; tmw
        STA $212F ; tsw
        LDA #$32
        STA $2130 ; cgswsel
        LDA #$60
        STA $2132
        LDA #$9F
        STA $2132 ; coldata
        LDA #$22
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
        LDX #break_bg1_tilemap
        LDY #$0800
        JSL load_vram
        
        LDX #$2400
        STX $2116
        LDX #break_bg2_tilemap
        LDY #$0800
        JSL load_vram
        
        ; store K and PC
        LDX #$2098
        STX !break_value_table
        INX
        STX !break_value_table+3
        INX
        STX !break_value_table+6
        LDX #$22B8
        STX !break_value_table+9
        LDX #$22BD
        STX !break_value_table+12
        INX
        STX !break_value_table+15
        LDA $11,S
        STA !break_value_table+2
        STA !break_value_table+11
        LDA $10,S
        XBA
        LDA $0F,S
        TAX
        DEX #2
        TXA
        STA !break_value_table+8
        STA !break_value_table+17
        XBA
        STA !break_value_table+5
        STA !break_value_table+14
        
        ; store B
        LDX #$2298
        STX !break_value_table+18
        LDA $09,S
        STA !break_value_table+20
        
        ; store D
        LDX #$229D
        STX !break_value_table+21
        INX
        STX !break_value_table+24
        LDA $08,S
        STA !break_value_table+23
        LDA $07,S
        STA !break_value_table+26
        
        ; store S
        LDX #$22D7
        STX !break_value_table+27
        INX
        STX !break_value_table+30
        TSC
        REP #$20
        CLC
        ADC #$0011
        SEP #$20
        STA !break_value_table+32
        XBA
        STA !break_value_table+29
        
        ; store A
        LDX #$22DD
        STX !break_value_table+33
        INX
        STX !break_value_table+36
        LDA $06,S
        STA !break_value_table+35
        LDA $05,S
        STA !break_value_table+38
        
        ; store X
        LDX #$22F7
        STX !break_value_table+39
        INX
        STX !break_value_table+42
        LDA $04,S
        STA !break_value_table+41
        LDA $03,S
        STA !break_value_table+44
        
        ; store Y
        LDX #$22FD
        STX !break_value_table+45
        INX
        STX !break_value_table+48
        LDA $02,S
        STA !break_value_table+47
        LDA $01,S
        STA !break_value_table+50
        
        ; store P
        LDX #$2318
        STX !break_value_table+51
        LDA $0A,S
        STA !break_value_table+53
        
        LDA #$FF
        STA !break_value_table+54
        STA !break_value_table+55
        
        REP #$30
        LDA $7F837B ; stripe image counter
        TAX
        
        LDA #!break_value_table
        STA $00
      - LDA ($00)
        BMI +
        INC $00
        INC $00
        JSR stripe_store_word_be
        TAY
        LDA #$0001
        JSR stripe_store_word_be
        LDA ($00)
        INC $00
        AND #$00FF
        PHA
        AND #$000F
        ASL A
        JSR stripe_store_word_le
        TYA
        CLC
        ADC #$03FF
        JSR stripe_store_word_be
        LDA #$0001
        JSR stripe_store_word_be
        PLA
        AND #$00F0
        LSR #2
        JSR stripe_store_word_le
        BRA -
        
      + LDA #$FFFF
        STA $7F837D,X
        TXA
        STA $7F837B ; stripe image counter
        
        SEP #$30
        JSL !_F+$0084C8 ; draw stripe
        
        ; store stack dump
        ; layer 1 4bpp upper nybble
        REP #$30
        LDA #$0100
        STA $00
        LDX #$2122
     -- STX $2116 ; vram address
        LDY #$0000
      - LDA ($00)
        AND #$00F0
        LSR #3
        STA $2118 ; vram data
        INC $00
        INY
        CPY #$0010
        BNE -
        TXA
        CLC
        ADC #$0020
        TAX        
        CPX #$2322
        BNE --
        
        ; layer 2 2bpp lower nybble
        REP #$20
        LDA #$0100
        STA $00
        LDX #$2522
     -- STX $2116 ; vram address
        LDY #$0000
      - LDA ($00)
        AND #$000F
        ASL #2
        STA $2118 ; vram data
        INC $00
        INY
        CPY #$0010
        BNE -
        TXA
        CLC
        ADC #$0020
        TAX        
        CPX #$2722
        BNE --
        
        ; highlight stack pointer in stack dump
        TSC
        CLC
        ADC #$0011
        CMP #$0100
        BCC +
        CMP #$0200
        BCS +
        AND #$00FF
        TAX
        AND #$000F
        STA $00
        TXA
        AND #$00F0
        ASL A
        CLC
        ADC $00
        TAY
        CLC
        ADC #$2122
        STA $2116 ; vram address
        LDA $0100,X
        AND #$00F0
        LSR #3
        CLC
        ADC #$00E0
        STA $2118 ; vram data
        TYA
        CLC
        ADC #$2522
        STA $2116 ; vram address
        LDA $0100,X
        AND #$000F
        ASL #2
        CLC
        ADC #$01C0
        STA $2118 ; vram data
        
        
        ; store processor flags in nvmxdizce order
        SEP #$20
        LDA $0A,S
        PHA
        LDY #$0000
      - PLA
        ROL A
        PHA
        BCC +
        REP #$20
        TYA
        ASL A
        TAX
        LDA.L nvmxdizce_addrs,X
        STA $2116 ; vram address
        TYX
        LDA.L nvmxdizce_tiles,X
        AND #$00FF
        STA $2118 ; vram data
        
        SEP #$20
      + INY
        CPY #$0008
        BNE -
        PLA
        
        LDA #$0F
        STA $2100 ; exit force blank
        
        LDY #$0006 ; delay before showing text
        LDX #$0000
      - DEX
        BNE -
        DEY
        BNE -
        
        LDA #$80
        STA $2100 ; force blank
        LDA #$03
        STA $212C ; tm
        STA $212D ; ts
        LDA #$0F
        STA $2100 ; exit force blank
        
        LDA.L !save_state_exists
        CMP #$BD
    .forever:
        BNE .forever
        
        LDY #$0030 ; delay before attempting countdown
        LDX #$0000
    .loop_2:
        DEX
        BNE .loop_2
      - LDA $4212
        BPL -
        LDA #$80
        STA $2100 ; force blank
        
        CPY #$001C
        BCS +
        REP #$20
        TYA
        LSR A
        AND #$00FE
        PHX
        LDX #$2056
        STX $2116 ; vram address
        STA $2118 ; vram data
        PLX
        SEP #$20
        
      + LDA #$0F
        STA $2100 ; exit force blank
                
        DEY
        BNE .loop_2
        
    .escape:
        LDA #$81
        STA $4200 ; enable nmi, controller
        CLI
        
        REP #$30
        PLY
        PLX
        PLA
        PLD
        PLB
        PLP
        CLC
        RTL
        
stripe_store_word:
    .be:
        XBA
        STA $7F837D,X
        XBA
        BRA +
    .le:
        STA $7F837D,X
      + INX
        INX
        RTS
        
nvmxdizce:
    .tiles:
        db $2E,$7C,$2C,$84,$1A,$48,$46,$30,$1C
    .addrs:
        dw $231A,$271A,$231B,$271B,$231C,$271C,$231D,$271D,$231E

break_tiles:
        incbin "bin/break_bg_tiles.bin"
break_bg1_tilemap:
        incbin "bin/break_bg1_tilemap.bin"
break_bg2_tilemap:
        incbin "bin/break_bg2_tilemap.bin"

print "inserted ", bytes, "/32768 bytes into bank $16"