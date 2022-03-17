; switch to pal music if set
nintendo_presents:
        LDA.L !status_region
        CMP #$02
        BCC +
        LDA #$4D
        STA $1DFC ; apu i/o 3
        
      + LDA #$40
        STA $1DF5 ; various timer
        RTL

; number of frames in an igt second per region
frames_in_igt_second:
        db $28,$28,$22,$22
        
; don't disable generators on J version
goal_tape_trigger:
        STZ $18DD
        LDA.L !status_region
        BEQ +
        STZ $18B9
      + RTL

; load the right number of frames into the igt
reset_igt_frames:
        LDA.L !status_region
        TAX
        LDA.L frames_in_igt_second,X
        STA $0F30 ; igt frames
        RTL

; load a different sprite pointer depending on region
load_level_sprite_ptr:
        LDA $EC00,Y
        STA $CE
        LDA $EC01,Y
        STA $CF
        LDA #$07
        STA $D0
        LDA.L !status_region
        BNE +
        CPY #$01EE ; ghost ship
        BNE +
        LDA #$3F
        STA $CE
        LDA #$F9
        STA $CF
        LDA #$12
        STA $D0
      + RTL
        
; load a different layer 1 pointer depending on region
load_level_layer1_ptr:
        LDA.L !status_region
        BEQ .j
        LDA $E000,Y
        STA $65
        LDA $E001,Y
        STA $66
        LDA $E002,Y
        STA $67
        BRA .done
    .j:
        PHX
        TYX
        LDA.L j_level_layer1_ptrs,X
        STA $65
        LDA.L j_level_layer1_ptrs+1,X
        STA $66
        LDA.L j_level_layer1_ptrs+2,X
        STA $67
        PLX
    .done:
        RTL
        
; load from a different table for edible dolphins on J
load_tweaker_1686:
        LDA.L !status_region
        BEQ +
        LDA.L !_F+$07F590,X
        RTL
        
      + LDA.L sprite_1686_J,X
        RTL

sprite_1686_J:
        db $00,$00,$00,$00,$02,$02,$02,$02,$42,$52,$52,$52,$52,$00,$09,$00
        db $40,$00,$01,$00,$00,$10,$10,$90,$90,$01,$10,$10,$90,$00,$11,$01
        db $01,$08,$00,$00,$00,$00,$01,$01,$19,$80,$00,$39,$09,$09,$10,$0A
        db $09,$09,$09,$99,$18,$29,$08,$19,$19,$19,$11,$11,$15,$10,$0A,$40
        db $40,$8C,$8C,$8C,$11,$18,$11,$80,$00,$29,$29,$10,$10,$10,$10,$00
        db $00,$10,$29,$20,$29,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9
        db $29,$29,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$29,$19,$29,$29,$59,$59,$18
        db $18,$10,$10,$50,$28,$28,$28,$28,$08,$29,$29,$39,$39,$29,$28,$28
        db $3A,$28,$29,$31,$31,$29,$00,$29,$29,$29,$29,$29,$29,$29,$29,$29
        db $11,$11,$11,$11,$11,$11,$11,$11,$11,$10,$11,$01,$39,$10,$19,$19
        db $19,$19,$01,$29,$98,$14,$14,$10,$18,$18,$18,$00,$19,$19,$19,$19
        db $19,$1D,$1D,$19,$19,$18,$18,$19,$19,$19,$1D,$19,$18,$00,$10,$00
        db $99,$99,$10,$90,$A9,$B9,$FF,$39,$19
        
; process title screen input movie
; return C=1 if we ended the movie
title_screen_input:
        LDX $1DF4 ; title input index
        
        LDA.L !status_region
        CMP #$02
        BCS +
        LDA.L $009C1F,X
        STA $00
        LDA.L $009C1F+1,X
        STA $01
        LDA.L $009C1F-2,X
        BRA ++
      + LDA.L intro_sequence_pal,X
        STA $00
        LDA.L intro_sequence_pal+1,X
        STA $01
        LDA.L intro_sequence_pal-2,X
     ++ STA $02
        
        DEC $1DF5 ; prompt timer
        BNE +
        LDA $01
        STA $1DF5
        INX #2
        STX $1DF4
        LDA $00
        STA $02
      + LDA $02
        CMP #$FF
        BNE +
        LDY #$02
        STY $0100
        SEC
        RTL
        
      + AND #$DF
        STA $15 ; byetudlr hold
        CMP $02
        BNE +
        AND #$9F
      + STA $16 ; byetudlr frame
        CLC
        RTL

intro_sequence_pal:
        db $41,$0D,$C1,$30,$00,$10,$42,$26 
        db $41,$58,$81,$17,$00,$7A,$82,$0C 
        db $00,$34,$C1,$2A,$41,$50,$C1,$0C 
        db $00,$30,$01,$20,$E1,$01,$00,$60 
        db $41,$30,$80,$10,$00,$30,$41,$4E 
        db $00,$20,$60,$01,$00,$30,$60,$01 
        db $00,$30,$60,$01,$00,$30,$60,$01 
        db $00,$30,$60,$01,$00,$30,$41,$15 
        db $C1,$30,$00,$30,$FF

; check to play pswitch, coinsnake running out sfx
; Z=1 to play sfx
check_pswitch_runout:
        CMP #$FF
        BEQ +
        LDA.L !status_region
        TAX
        LDA.L pswitch_runout_times,X
        STA $00
        CPY $00
        RTL
        
      + LDA #$01
        RTL

; check to play star running out sfx
check_star_runout:
        LDA.L !status_region
        TAX
        LDA.L pswitch_runout_times,X
        STA $00
        LDA $13 ; true frame
        CPY $00
        RTL
        
pswitch_runout_times:
        db $1E,$1E,$18,$18
        
; adjust physics for grabbing yoshi wings
grab_yoshi_wings_phsyics:
        PHA
        LDA.L !status_region
        TAX
        PLA
        SEC
        SBC.L yoshi_wings_physics,X
        STA $7D
        RTL
        
yoshi_wings_physics:
        db $0D,$0D,$0F,$0F
        
; adjust physics for mario holding out arms
mario_holding_out_arms:
        PHA
        PHX
        LDA.L !status_region
        TAX
        LDA.L mario_arms_speeds,X
        STA $00
        PLX
        PLA
        CPX $00
        BCC +
        ADC #$03
      + RTL
      
mario_arms_speeds:
        db $2F,$2F,$3A,$3A

calc_wall_triangle_y:
        PHA
        LDA $EAB9,Y
        BRA calc_wall_triangle_x_merge
calc_wall_triangle_x:
        PHA
        LDA $EAB9,X
    .merge:
        STA $00
        
        LDA.L !status_region
        CMP #$02
        BCC +
        LDA $00
        EOR #$08
        STA $00
        
      + PLA
        SEC
        SBC $00
        EOR $00
        RTL
        
wall_triangle_in_block:
        PHX
        LDA !status_region
        TAX
        LDA $92 ; player x pos in block
        BCC +
        EOR #$0F
      + CMP.L triangle_in_block_offsets,X
        PLX
        RTL

triangle_in_block_offsets:
        db $08,$08,$09,$09

; return Z=0 to branch
physics_hijack_1:
        LDA $7B ; player x speed
        BEQ .skip
        
        PHA
        LDA.L !status_region
        CMP #$02
        BCS + 
        LDA $D345+1,X
        BRA ++
      + LDA.L PAL_MarioAccel+1,X
     ++ STA $08
        PLA
        
        EOR $08
        BPL .skip
        LDA $14A1 ; skid turn timer
        RTL
        
    .skip:
        LDA #$01
        RTL

; return C=1 to branch to $D76B
; return C=0 to branch to $D7A0
physics_hijack_2:
        PHB
        LDA.L !status_region
        CMP #$02
        BCS .pal
        
        LDA $7B ; player X speed
        SEC
        SBC $D535,Y
        BEQ .d76b
        EOR $D535,Y
        BPL .d76b
        REP #$20
        LDA $D345,X
        LDY $86 ; level is slippery
        BEQ +
        LDY $72 ; player in air
        BNE +
        LDA $D43D,X
      + CLC
        ADC $7A ; player x pos spx
        BRA .exit
        
    .pal:
        PHK
        PLB
        LDA $7B ; player X speed
        SEC
        SBC PAL_DATA_00D535,Y
        BEQ .d76b
        EOR PAL_DATA_00D535,Y
        BPL .d76b
        REP #$20
        LDA PAL_MarioAccel,X
        LDY $86 ; level is slippery
        BEQ +
        LDY $72 ; player in air
        BNE +
        LDA PAL_DATA_00D43D,X
      + CLC
        ADC $7A ; player x pos spx
    .exit:
        PLB
        CLC
        RTL
        
    .d76b:
        PLB
        SEC
        RTL
        
; return C=1 to branch to $D7A0
; return C=0 to branch to $D7A2
physics_hijack_3:
        PHB
        LDA.L !status_region
        CMP #$02
        BCS .pal
        
        LDA $7B ; player x speed
        SEC
        SBC $D5C9+1,X
        BPL +
        INY #2
      + LDA $1493 ; end level timer
        ORA $72 ; player in air
        REP #$20
        BNE ++
        LDA $D309,Y
        BIT $85 ; level is water
        BMI +
     ++ LDA $D2CD,Y
      + CLC
        ADC $7A ; player x pos spx
        STA $7A ; player x pos spx
        SEC
        SBC $D5C9,X
        EOR $D2CD,Y
        BMI .d7a2
        LDA $D5C9,X
        BRA .d7a0
        
    .pal:
        PHK
        PLB
        LDA $7B ; player x speed
        SEC
        SBC PAL_DATA_00D5C9+1,X
        BPL +
        INY #2
      + LDA $1493 ; end level timer
        ORA $72 ; player in air
        REP #$20
        BNE ++
        LDA PAL_DATA_00D309,Y
        BIT $85 ; level is water
        BMI +
     ++ LDA PAL_DATA_00D2CD,Y
      + CLC
        ADC $7A ; player x pos spx
        STA $7A ; player x pos spx
        SEC
        SBC PAL_DATA_00D5C9,X
        EOR PAL_DATA_00D2CD,Y
        BMI .d7a2
        LDA PAL_DATA_00D5C9,X
        
    .d7a0:
        PLB
        SEC
        RTL
        
    .d7a2:
        PLB
        CLC
        RTL

; p meter comparison
physics_hijack_4:
        PHA
        LDA.L !status_region
        TAX
        LDA.L mario_pmeter_max,X
        STA $08
        PLA
        
        LDY $13E4 ; player p meter
        CPY $08
        RTL
      
mario_pmeter_max:
        db $70,$70,$40,$68

; fluttery legs
physics_hijack_5:
        PHX
        LDA.L !status_region
        TAX
        LDA.L mario_flutter_speeds,X
        STA $08
        PLX
        
        LDA $7B ; player X speed
        BPL +
        EOR #$FF
        INC A
      + CMP $08
        RTL
      
mario_flutter_speeds:
        db $23,$23,$2C,$2C
        
physics_hijack_6:
        STX $1408 ; next flight phase
        
        LDA.L !status_region
        CMP #$02
        BCS +
        LDY $1407 ; flight phase
        RTL
        
      + PLA
        PLA
        PLA
        PHB
        PHK
        PLB
        
        LDY $1407 ; flight phase
        BEQ .d8cd
        PHY
        TYA
        ASL A
        TAY
        REP #$20
        LDA $7C ; player Y pos spx
        BPL ++
        CMP #$00C8
        BCS +
        LDA #$00C8
        BRA +
     ++ CMP PAL_DATA_00D7C8-1,Y
        BCC +
        LDA PAL_DATA_00D7C8-1,Y
      + PLY
        PHA
        SEP #$20
        CPY #$01
        BNE .a
        LDX $1409 ; max stage of flight
        BEQ .b
        LDA $7D ; player y speed
        BMI .c
        LDA #$09
        STA $1DF9 ; spcio 0
        BRA +
    .c:
        CMP $1409 ; max stage of flight
        BCS +
        STX $7D ; player y speed
        STZ $1409 ; max stage of flight
      + LDX $76 ; player direction
        LDA $7B ; player x speed
        BEQ .b
        EOR PAL_DATA_00D535,X
        BPL .a
    .b:
        LDY #$02
    .a:
        INY #3
        TYA
        ASL A
        TAY
        REP #$20
        PLA
        JMP .d948
        
    .d8cd:
        LDA $72 ; player in air
        BEQ .d928
        LDX #$00
        LDA $187A ; player riding yoshi
        BEQ .d8e7
        LDA $141E ; yoshi has wings event
        LSR A
        BEQ .d8e7
        LDY #$02
        CPY $19 ; powerup
        BEQ +
        INX
      + BRA .d8ff
      
    .d8e7:
        LDA $19 ; powerup
        CMP #$02
        BNE .d928
        LDA $72 ; player in air
        CMP #$0C
        BNE +
        LDY #$01
        CPY $149F ; takeoff timer
        BCC .d8ff
        INC $149F ; takeoff timer
      + LDY #$00
    .d8ff:
        LDA $14A5 ; cape float timer
        BNE +
        LDA $15,X ; byetudlr hold
        BPL .d924
        LDA #$10
        STA $14A5 ; cape float timer
      + LDA $7D ; player y speed
        BPL +
        LDX PAL_DATA_00D7B9,Y
        BPL .d924
        CMP PAL_DATA_00D7B9,Y
        BCC .d924
      + LDA PAL_DATA_00D7B9,Y
        CMP $7D ; player y speed
        BEQ .d94c
        BMI .d94c
    .d924:
        CPY #$02
        BEQ +
    .d928:
        LDY #$01
        LDA $15 ; byetudlr hold
        BMI +
        LDY #$00
      + TYA
        ASL A
        TAY
        REP #$20
        LDA $7C ; player y pos spx
        BMI .d948
        CMP PAL_DATA_00D7AF,Y
        BCC +
        LDA PAL_DATA_00D7AF,Y
      + LDX $72 ; player in air
        BEQ .d948
        CPX #$0B
        BNE .d948
        LDX #$24
        STX $72 ; player in air
    .d948:
        CLC
        ADC PAL_DATA_00D7A5,Y
        SEP #$20
        STA $7C ; player y pos spx
        XBA
    .d94c:
        STA $7D ; player y speed
        
        PLB
        JML !_F+$00D94E

physics_hijack_7:
        PHX
        LDA.L !status_region
        TAX
        
        LDA $D5EB,Y
        CMP #$02
        BNE +
        LDA #$03
      + CLC
        ADC $13E4 ; player p meter
        BPL +
        LDA #$00
      + CMP.L mario_pmeter_max,X
        BCC +
        INY
        LDA.L mario_pmeter_max,X
      + STA $13E4 ; player p meter
      
        PLX
        RTL

physics_hijack_8:
        LDA.L !status_region
        CMP #$02
        BCS .pal
        
        LDA $7B,X ; player x speed
        ASL #4
        CLC
        ADC $13DA,X ; player x speed spx
        STA $13DA,X
        REP #$20
        PHP
        LDA $7B,X
        LSR #4
        AND #$000F
        CMP #$0008
        BCC +
        ORA #$FFF0
      + PLP
        ADC $94,X ; player x pos next
        STA $94,X
        SEP #$20
        RTL
        
    .pal:
        LDA $7B,X ; player x speed
        BPL +
        EOR #$FF
        INC A
      + STA $01
        STZ $00
        STA $4202 ; hw mult A
        TXA
        BEQ +
        LDA #$28
      + STA $4203 ; hw mult B
        NOP
        REP #$20
        LDA $00
        CLC
        ADC $4216 ; hw mult product
        LSR #4
        STZ $02
        BIT $7A,X ; player x pos spx
        BPL +
        DEC $02
        EOR #$FFFF
        INC A
      + STA $00
        SEP #$20
        CLC
        ADC $13DA,X ; player x speed spx
        STA $13DA,X
        REP #$20
        LDA $01
        ADC $94,X ; player x pos next
        STA $94,X
        SEP #$20
        RTL
        
physics_hijack_9:
        LDA.L !status_region
        TAX
        LDA $7B ; player x speed
        BPL +
        EOR #$FF
        INC A
      + CMP.L slope_speed_thresholds,X
        RTL
        
slope_speed_thresholds:
        db $28,$28,$34,$34
        
get_animation_frame:
        PHX
        TAX
        LDA.L !status_region
        CMP #$02
        BCC .ntsc
        BEQ .pal10
    .pal11:
        LDA.L PAL11_DATA_00DC7C,X
        BRA .done
    .pal10:
        LDA.L PAL10_DATA_00DC7C,X
        BRA .done
    .ntsc:
        LDA.L !_F+$00DC7C,X
    .done
        TXY
        PLX
        RTL

PAL_DATA_00D2CD:
        dw $FEC0,$0140,$FEC0,$0140
        dw $FEC0,$0140,$FE20,$00F0
        dw $FF10,$01E0,$FD80,$0050
        dw $FFB0,$0280,$FD80,$0050
        dw $FD80,$0050,$FFB0,$0280
        dw $FFB0,$0280,$FB00,$FEC0
        dw $0140,$0500,$FEC0,$0140
        dw $FEC0,$0140
        
PAL_DATA_00D309:
        dw $FFD8,$0028,$FFD8,$0028
        dw $FFD8,$0028,$FFB0,$0028
        dw $FFD8,$0050,$FF60,$0028
        dw $FFD8,$00A0,$FF60,$0028
        dw $FF60,$0028,$FFD8,$00A0
        dw $FFD8,$00A0,$FD80,$FF60
        dw $00A0,$0280,$FEC0,$0140
        dw $FEC0,$0140
        
PAL_MarioAccel:
        dw $FE20,$FE20,$01E0,$01E0
        dw $FE20,$FE20,$01E0,$01E0
        dw $FE20,$FE20,$01E0,$01E0
        dw $FE20,$FE20,$0190,$0190
        dw $FE70,$FE70,$01E0,$01E0
        dw $FE20,$FE20,$0140,$0140
        dw $FEC0,$FEC0,$01E0,$01E0
        dw $FE20,$FE20,$0140,$0140
        dw $FE20,$FE20,$0140,$0140
        dw $FEC0,$FEC0,$01E0,$01E0
        dw $FEC0,$FEC0,$01E0,$01E0
        dw $FB00,$FB00,$FC40,$FC40
        dw $03C0,$03C0,$0500,$0500
        dw $FB00,$FB00,$0780,$0780
        dw $F880,$F880,$0500,$0500
        dw $FF60,$00A0,$FEC0,$0140
        dw $FE20,$01E0,$FE20,$FE20
        dw $01E0,$01E0,$FE20,$0320
        dw $FCE0,$F9C0,$0320,$0640
        dw $FCE0,$F9C0,$0320,$0640
        dw $FCE0,$F9C0,$0320,$0640
        dw $FC90,$F920,$02D0,$05A0
        dw $FDC0,$F920,$0370,$06E0
        dw $FC40,$F880,$0280,$0500
        dw $FD80,$FB00,$03C0,$0780
        dw $FC40,$F880,$0280,$0500
        dw $FC40,$F880,$0280,$0500
        dw $FD80,$FB00,$03C0,$0780
        dw $FD80,$FB00,$03C0,$0780
        dw $FC40,$F880,$FC40,$F880
        dw $03C0,$0780,$03C0,$0780
        
PAL_DATA_00D43D:
        dw $FF60,$FE20,$00A0,$01E0
        dw $FF60,$FE20,$00A0,$01E0
        dw $FF60,$FE20,$00A0,$01E0
        dw $FE20,$FE20,$00A0,$0190
        dw $FF60,$FE70,$01E0,$01E0
        dw $FE20,$FE20,$00A0,$0140
        dw $FF60,$FEC0,$01E0,$01E0
        dw $FE20,$FE20,$00A0,$0140
        dw $FE20,$FE20,$00A0,$0140
        dw $FF60,$FEC0,$01E0,$01E0
        dw $FF60,$FEC0,$01E0,$01E0
        dw $FB00,$FB00,$FD80,$FC40
        dw $03C0,$03C0,$0500,$0500
        dw $FB00,$FB00,$00A0,$00A0
        dw $FF60,$FF60,$0500,$0500
        dw $FF60,$00A0,$FEC0,$0140
        dw $FE20,$01E0,$FE20,$FE20
        dw $01E0,$01E0,$FE20,$0320
        dw $FFB0,$FCE0,$0050,$0320
        dw $FFB0,$FCE0,$0050,$0320
        dw $FFB0,$FCE0,$0050,$0320
        dw $FF60,$FC90,$0050,$02D0
        dw $FFB0,$FD30,$00A0,$0370
        dw $FC40,$FC40,$0050,$0280
        dw $FFB0,$FD80,$03C0,$03C0
        dw $FC40,$FC40,$0050,$0280
        dw $FC40,$FC40,$0050,$0280
        dw $FFB0,$FD80,$03C0,$03C0
        dw $FFB0,$FD80,$03C0,$03C0
        dw $FC40,$FC40,$FC40,$FC40
        dw $03C0,$03C0,$03C0,$03C0
        
PAL_DATA_00D535:
        db $E7,$19,$D3,$2D,$D3,$2D,$C4,$3C
        db $E7,$19,$D3,$2D,$D3,$2D,$C4,$3C
        db $E7,$19,$D3,$2D,$D3,$2D,$C4,$3C
        db $E2,$16,$D3,$28,$D3,$28,$C4,$38
        db $EA,$1E,$D8,$2D,$D8,$2D,$C8,$3C
        db $D3,$14,$D3,$23,$D3,$23,$C4,$34
        db $EC,$2D,$DD,$2D,$DD,$2D,$CC,$3C
        db $D3,$14,$D3,$23,$D3,$23,$C4,$34
        db $D3,$14,$D3,$23,$D3,$23,$C4,$34
        db $EC,$2D,$DD,$2D,$DD,$2D,$CC,$3C
        db $EC,$2D,$DD,$2D,$DD,$2D,$CC,$3C
        db $D3,$EC,$D3,$F6,$D3,$F6,$C4,$FC
        db $14,$2D,$0A,$2D,$0A,$2D,$05,$3C
        db $C4,$0A,$C4,$0A,$C4,$0A,$C4,$0A
        db $F6,$3C,$F6,$3C,$F6,$3C,$F6,$3C
        db $F6,$0A,$EC,$14,$F1,$05,$E2,$0A
        db $EC,$14,$D8,$28,$E7,$0F,$CE,$1E
        db $CE,$32,$C9,$37,$C4,$3C,$C4,$C4
        db $3C,$3C,$D8,$28
        
PAL_DATA_00D5C9:
        db $00,$00,$00,$00,$00,$00,$00,$00
        db $00,$00,$00,$EC,$00,$14,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$D8
        db $00,$28,$00,$00,$00,$00,$00,$EC
        db $00,$F6


PAL_DATA_00D7A5:
        dw $06E6,$0373,$0499,$1266
        dw $F220,$0126,$0373,$0499
        dw $05C0,$06E6
        
PAL_DATA_00D7AF:
        dw $4000,$4000,$2000,$4000
        dw $4000,$4000,$4000,$4000
        dw $4000,$4000
        
PAL_DATA_00D7B9:
        db $10,$C8,$E0,$02,$03,$03,$04,$03
        db $02,$00,$01,$00,$00,$00,$00
        
PAL_DATA_00D7C8:
        dw $0001,$0010,$0030,$0030
        dw $0038,$0038
        db $40
        
PAL10_DATA_00DC7C:
        db $09,$08,$06,$05,$04,$03,$03,$02
        db $09,$08,$06,$05,$04,$03,$03,$02
        db $09,$08,$06,$05,$04,$03,$03,$02
        db $07,$06,$05,$04,$03,$03,$02,$01
        db $07,$06,$05,$04,$03,$03,$02,$01
        db $05,$04,$04,$03,$03,$02,$01,$01
        db $05,$04,$03,$03,$02,$02,$01,$01
        db $05,$04,$03,$03,$02,$02,$01,$01
        db $05,$04,$03,$03,$02,$02,$01,$01
        db $05,$04,$03,$03,$02,$02,$01,$01
        db $05,$04,$03,$03,$02,$02,$01,$01
        db $04,$03,$03,$02,$02,$01,$01,$01
        db $04,$03,$03,$02,$02,$01,$01,$01
        db $02,$02,$02,$02,$02,$02,$02,$02

PAL11_DATA_00DC7C:
        db $0A,$08,$07,$06,$05,$04,$03,$02
        db $0A,$08,$07,$06,$05,$04,$03,$02
        db $0A,$08,$07,$06,$05,$04,$03,$02
        db $08,$07,$06,$05,$04,$03,$02,$01
        db $08,$07,$06,$05,$04,$03,$02,$01
        db $05,$04,$04,$03,$03,$02,$01,$01
        db $05,$04,$03,$03,$02,$02,$01,$01
        db $05,$04,$03,$03,$02,$02,$01,$01
        db $05,$04,$03,$03,$02,$02,$01,$01
        db $05,$04,$03,$03,$02,$02,$01,$01
        db $05,$04,$03,$03,$02,$02,$01,$01
        db $04,$03,$03,$02,$02,$01,$01,$01
        db $04,$03,$03,$02,$02,$01,$01,$01
        db $02,$02,$02,$02,$02,$02,$02,$02

set_shell_speed_lda:
        LDA.L !status_region
        CMP #$02
        BCS .pal
        LDA $9F6B,Y
        BRA +
    .pal:
        PHX
        TYX
        LDA.L pal_shell_speeds,X
        PLX
        
      + STA $B6,X
        RTL

set_shell_speed_adc:
        PHA
        LDA.L !status_region
        CMP #$02
        BCS .pal
        LDA $9F6B,Y
        BRA +
    .pal:
        PHX
        TYX
        LDA.L pal_shell_speeds,X
        PLX
        
      + STA $00
        PLA
        
        CLC
        ADC $00
        STA $B6,X
        RTL
        
pal_shell_speeds:
        db $C9,$37,$C2,$3E


set_roulette_speed:
        LDA $15D0,X ; sprite on yoshi tongue
        BNE +
        LDA.L !status_region
        CMP #$02
        BCC .ntsc
        INC $187B,X ; roulette item timer
    .ntsc:
        INC $187B,X
      + LDA $187B,X
        RTL
        
pal_brown_swinging_platform:
        LDA.L !status_region
        CMP #$02
        BCS .pal
        
        LDA $13 ; true frame
        LSR A
        BCC .return
        LDA $151C,X
        CLC
        ADC #$80
        LDA $1528,X
        ADC #$00
        AND #$01
        TAY
        BRA .merge
        
    .pal:
        LDA $151C,X
        CLC
        ADC #$80
        LDA $1528,X
        ADC #$00
        AND #$01
        TAY
        LDA $1504,X
        BEQ .merge
        EOR $C9D8,Y
        BPL .merge
        LDA $13 ; true frame
        LSR A
        BCC .return
        
    .merge:
        LDA $1504,X
        CMP $C9D8,Y
        BEQ .return
        CLC
        ADC $C9D6,Y
        STA $1504,X
    
    .return:
        RTL
        
pal_castle_crusher_1:
        PHX
        LDA.L !status_region
        TAX
        LDA.L pal_crusher_data_1,X
        PLX
        STA $1540,X
        RTL
        
pal_castle_crusher_2:
        PHX
        LDA.L !status_region
        TAX
        LDA.L pal_crusher_data_2,X
        PLX
        STA $AA,X ; sprite Y speed
        RTL
        
pal_castle_crusher_3:
        PHX
        LDA.L !status_region
        TAX
        LDA.L pal_crusher_data_3a,X
        STA $00
        LDA.L pal_crusher_data_3b,X
        STA $01
        PLX

        LDA $AA,X ; sprite Y speed
        BMI +
        CMP $00
        BCS ++
      + CLC
        ADC $01
        STA $AA,X
     ++ RTL
        
pal_castle_crusher_4:
        PHX
        LDA.L !status_region
        TAX
        LDA.L pal_crusher_data_4,X
        PLX
        STA $AA,X ; sprite Y speed
        RTL
        
pal_castle_crusher_5:
        PHX
        LDA.L !status_region
        TAX
        LDA.L pal_crusher_data_5,X
        PLX
        STA $1540,X
        RTL
        
pal_crusher_data_1:
        db $80,$80,$68,$68
        
pal_crusher_data_2:
        db $04,$04,$06,$06
        
pal_crusher_data_3a:
        db $40,$40,$70,$70
        
pal_crusher_data_3b:
        db $07,$07,$0A,$0A
        
pal_crusher_data_4:
        db $E0,$E0,$D8,$D8
        
pal_crusher_data_5:
        db $A0,$A0,$88,$88
        
pal_shaking_dorito:
        PHX
        LDA.L !status_region
        TAX
        LDA.L pal_shaking_dorito_data,X
        PLX
        STA $1540,X
        RTL
        
pal_shaking_dorito_data:
        db $40,$40,$20,$20
        
pal_boss_1:
        CPX #$C0
        BNE .exit
        LDX #$D0
        LDA.L !status_region
        CMP #$03
        BNE +
        LDA $13FC ; active boss
        CMP #$03 ; bowser
        BNE +
        LDX #$E0
      + REP #$02
    .exit:
        RTL

pal_boss_2:
        PHP
        LDX #$C0
        LDY #$A0
        LDA.L !status_region
        CMP #$03
        BNE +
        LDA $13FC ; active boss
        CMP #$03 ; bowser
        BNE +
        LDX #$D0
        LDY #$B0
      + TYA 
        PLP
        RTL
        
pal_bowser_1:
        PHX
        LDA.L !status_region
        TAX
        LDA.L pal_bowser_data_1,X
        PLX
        STA $AA,X
        RTL
        
pal_bowser_2:
        PHX
        LDA.L !status_region
        TAX
        LDA.L pal_bowser_data_2,X
        PLX
        STA $154C,X
        RTL
        
pal_bowser_3:
        PHX
        LDA.L !status_region
        TAX
        LDA.L pal_bowser_data_3,X
        STA $00
        PLX
        LDA $D8,X
        CMP $00
        RTL
        
pal_bowser_4:
        PHX
        LDA.L !status_region
        TAX
        LDA.L pal_bowser_data_4,X
        PLX
        STA $1540,X
        RTL

pal_bowser_5:
        PHA
        PHX
        LDA.L !status_region
        TAX
        LDA.L pal_bowser_data_5a,X
        STA $00
        LDA.L pal_bowser_data_5b,X
        STA $01
        PLX
        PLA
        
        CMP $00
        BCC +
        CMP $01
      + RTL
      
pal_bowser_6:
        PHX
        LDA.L !status_region
        TAX
        LDA.L pal_bowser_data_6,X
        PLX
        STA $00
        
        LDA $D8,X ; sprite y pos low
        CMP $00
        BCC +
        LDA $00
        SEC
      + RTL
      
pal_bowser_7:
        PHX
        LDA.L !status_region
        TAX
        LDA.L pal_bowser_data_6,X
        PLX
        CLC
        ADC #$10
        SEC
        SBC $1C ; layer 1 y pos
        RTL
        
pal_bowser_8:
        PHX
        LDA.L !status_region
        INC A
        AND #$04
        ASL #2
        STA $00
        PLX
        LDA $B49C,X
        CLC
        ADC $00
        SEC
        RTL
        

pal_bowser_data_1:
        db $04,$04,$05,$05
        
pal_bowser_data_2:
        db $24,$24,$15,$15
        
pal_bowser_data_3:
        db $64,$64,$64,$74
        
pal_bowser_data_4:
        db $60,$60,$50,$50
        
pal_bowser_data_5a:
        db $40,$40,$30,$30
        
pal_bowser_data_5b:
        db $5E,$5E,$4A,$4A
        
pal_bowser_data_6:
        db $B0,$B0,$B0,$C0
        
pal_l2_1:
        PHA
        LDA.L !status_region
        CMP #$02
        PLA
        BCC +
        CLC
        ADC $C818,Y
      + CLC
        ADC $C818,Y
        RTL

pal_l2_2:
        LDA.L !status_region
        CMP #$02
        BCC +
        LDA.L PAL_DATA_05C934,X
        BRA ++
      + LDA $C934,X
     ++ STA $1444 ; scroll timer
        RTL

pal_l2_3:
        PHA
        LDA.L !status_region
        AND #$00FF
        CMP #$0002
        PLA
        TAY
        BCC +
        PHX
        TYX
        LDA.L PAL_DATA_05CBF5,X
        PLX
        RTL
        
      + LDA $CBF5,Y
        RTL

pal_l2_4:
        PHA
        LDA.L !status_region
        AND #$00FF
        CMP #$0002
        PLA
        TAY
        BCC +
        PHX
        TYX
        LDA.L PAL_DATA_05CBF5+1,X
        PLX
        RTL
        
      + LDA $CBF5+1,Y
        RTL
        
PAL_DATA_05C934:
        db $66,$33,$01,$66,$00,$00,$66,$00
        db $33,$00,$00,$19,$33,$00,$19,$00
        db $00,$19,$66,$66,$19,$66,$66,$19
        db $00,$00,$80
        
PAL_DATA_05CBF5:
        db $90,$72,$60,$42,$22,$02,$40,$22,$20,$10
        db $8B