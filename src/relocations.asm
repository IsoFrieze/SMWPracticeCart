; empty/unreachable bytes overwritten:
; $00B091 - 15 / 15 bytes
; $01FFBF -  5 / 65 bytes
; $02FFE2 -  6 / 30 bytes
; $0CFFDF -  5 / 33 bytes

; 1FE2 cape interaction table
ORG !_F+$00FCC2
        STA !new_cape_interaction,X
ORG !_F+$01810E
        LDA !new_cape_interaction,X
ORG !_F+$018113
        DEC !new_cape_interaction,X
ORG !_F+$0191FB
        ORA !new_cape_interaction,X
ORG !_F+$0195D8
        STA !new_cape_interaction,X
ORG !_F+$0199CF
        STA !new_cape_interaction,X
ORG !_F+$01D2CA
        LDA !new_cape_interaction,X
ORG !_F+$01D2D1
        STA !new_cape_interaction,X
ORG !_F+$01EDA0
        STA !new_cape_interaction,X
ORG !_F+$0293C9
        ORA !new_cape_interaction,X
ORG !_F+$02A9D4
        STA !new_cape_interaction,X
ORG !_F+$02C4F3
        LDA !new_cape_interaction,X
ORG !_F+$02C4FF
        STA !new_cape_interaction,X
ORG !_F+$02DDC1
        STA !new_cape_interaction,X
ORG !_F+$02DEBC
        LDA !new_cape_interaction,X
ORG !_F+$039569
        LDA !new_cape_interaction,X
ORG !_F+$0395C3
        STA !new_cape_interaction,X
ORG !_F+$039688
        LDA !new_cape_interaction,X
ORG !_F+$07F74B
        STZ !new_cape_interaction,X
    
; clear unused table
ORG !_F+$07F782
        NOP #3
    
; clear moons, dragon coins, 1ups tables
ORG !_F+$00F2B8
        NOP #6
ORG !_F+$00F322
        NOP #6
ORG !_F+$00F351
        NOP #6
ORG !_F+$0DA59C
        LDA #$00
        NOP
ORG !_F+$0DA5A7
        LDA #$00
        NOP
ORG !_F+$0DB2D7
        LDA #$00
        NOP

; clear save file buffer table
ORG !_F+$009BC9
        RTL
ORG !_F+$009D18
        NOP #3
ORG !_F+$00A19A
        NOP #6
ORG !_F+$01E765
        NOP #3
ORG !_F+$049046
        NOP #3

; change special effects flag to use the new one we made instead of checking if Funky is beaten
ORG !_F+$00AA73
        JSR load_special_8_bank_0
        db $F0 ; BEQ
ORG !_F+$00AD2A
        JSR load_special_16
        db $F0 ; BEQ
ORG !_F+$019825
        JSR load_special_8_bank_1
        db $D0 ; BNE
ORG !_F+$01B9CC
        JSR load_special_8_bank_1
        db $F0 ; BEQ
ORG !_F+$02A985
        JSR load_special_8_bank_2_y
        db $F0 ; BEQ
ORG !_F+$0CAE0E
        JSR load_special_8_bank_c
        db $F0 ; BEQ
    
ORG !_F+$00B091
load_special_16:
        LDA.L !status_special
        AND #$00FF
        RTS
load_special_8_bank_0:
        LDA.L !status_special
        RTS
ORG !_F+$01FFBF
load_special_8_bank_1:
        LDA.L !status_special
        RTS
ORG !_F+$02FFE2
; terrible hack to disable special effects on title screen
load_special_8_bank_2_y:
        PHA
        LDY #$00
        LDA $0100
        CMP #$0B
        BCC +
        LDA.L !status_special
        TAY
      + PLA
        CPY #$00
        RTS
ORG !_F+$0CFFDF
load_special_8_bank_c:
        LDA.L !status_special
        RTS

; clear unused exit table
ORG !_F+$0DA533
        NOP #3

; move layer 3 border data from $04A400 to $04A200
; insert new overworld tilemap, which is slightly larger than the original
ORG !_F+$04A200
overworld_layer3_stripe:
        incbin "bin/overworld_layer3_stripe.bin"
overworld_layer2_tiles:
        incbin "bin/overworld_layer2_tiles_compressed.bin"
overworld_layer2_properties:
        incbin "bin/overworld_layer2_properties_compressed.bin"
        
ORG !_F+$0084D6
        dl overworld_layer3_stripe
ORG !_F+$04DC72
        dw overworld_layer2_tiles
ORG !_F+$04DC8D
        dw overworld_layer2_properties
        
ORG !_F+$05D000
        incbin "bin/overworld_layer1_characters.bin"
ORG !_F+$0CF7DF
        incbin "bin/overworld_layer1_tiles.bin"

; update music upload routine
ORG !_F+$00810E
        LDX #$00
        JSL set_music_bank
        JMP $811D
ORG !_F+$008148
        LDX #$01
        JSL set_music_bank
        JMP $8157
ORG !_F+$008159
        LDX #$02
        JSL set_music_bank
        JMP $8168

; relocate modified spc engine
ORG !_F+$0080F3
        db $1F
ORG !_F+$1F8000
        incbin "bin/spc_engine.bin"
        
; SPC700 modification
;ORG !_F+$0577 ; @0x7B - 3F3E13
;        CALL $133E
;ORG $133E ; @0xE42 - 6D2DBA44DAF4AEEE6084496F
;        PUSH Y
;        PUSH A
;        MOVW YA, $44
;        MOVW $F4, YA
;        POP A
;        POP Y
;        CLRC
;        ADC A, $49
;        RET
; @0x00 - 4A