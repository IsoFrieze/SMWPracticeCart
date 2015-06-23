;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SMW Practice Cart - Version 4.4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!cont_all_a                  = $0DA2
!cont_all_b                  = $0DA4
!cont_frame_a                = $0DA6
!cont_frame_b                = $0DA8

!status_table                = $0F5E
!yellow_status               = $0F5E
!green_status                = $0F5F
!red_status                  = $0F60
!blue_status                 = $0F61
!special_status              = $0F62
!yoshi_status                = $0F63
!powerup_status              = $0F64
!itembox_status              = $0F65
!erase_status                = $0F66

!curr_selection              = $0F68
!curr_drawing                = $0F69

!timer_min                   = $0F6A
!timer_sec                   = $0F6B
!timer_frames                = $0F6C
!timer_flag                  = $0F6D
!timer_save_low              = $0F6E
!timer_save_high             = $0F6F
!timer_save_bank             = $0F70

!dynamic_stripe              = $1938

!potential_translevel        = $1F2F
!erase_records_flag          = $1F30
!l_r_reset_flag              = $1F31
!coins_this_level            = $1F32
!yoshi_flag                  = $1F34
!orb_flag                    = $1F35
!room_timer_min              = $1F36
!room_timer_sec              = $1F37
!room_timer_frames           = $1F38
!recent_secondary_exit       = $1F39
!reset_room_flag             = $1F3A
!tick_rta_timer_flag         = $1F3B
!restore_room_powerup        = $1F3C
!restore_room_yoshi          = $1F3D
!restore_room_itembox        = $1F3E

!restore_powerup             = $1FEE
!restore_yoshi               = $1FEF
!restore_itembox             = $1FF0
!restore_time                = $1FF1
!restore_boo_ring            = $1FF2 ; 4 bytes
!restore_rng                 = $1FF6 ; 4 bytes


;;;;;;;;;;;;;;;;
; Hex edits
;;;;;;;;;;;;;;;;

; NMI hijack
ORG $0081AA
    JSL NMIHijack
    NOP

; stripe image pointers
ORG $0084F1
    dw !dynamic_stripe
    db $7E
    dl #save_confirm_message
    dl #new_record_message

; status bar tilemap
ORG $008C89
    db $76,$3C,$27,$3C,$27,$3C,$85,$3C
    db $27,$3C,$27,$3C,$86,$3C,$27,$3C
    db $27,$3C,$FC,$3C,$27,$2C,$27,$2C
ORG $008CAB
    db $2E,$3C,$FC,$38,$00,$38,$FC,$3C
    db $FC,$3C,$FC,$28,$FC,$28,$FC,$28
    db $FC,$28,$FC,$28,$FC,$28
ORG $008CC1
    db $27,$38,$27,$38,$85,$38,$27,$38
    db $27,$38,$86,$38,$27,$38,$27,$38
ORG $008CEB
    db $FC,$28,$FC,$28,$FC,$28,$FC,$28
    db $FC,$28,$FC,$28
ORG $008293
    db $26    ; 26 scanlines tall

; don't kill Mario after time is up
ORG $008E69
    db $EA,$EA,$EA,$EA,$EA,$EA
    
; keep count of how many coins collected this level
ORG $008F25
    JSR $C578
ORG $00C578
    INC $0DBF
    INC !coins_this_level
    RTS

; don't draw lives to the status bar
ORG $008F55
    db $EA,$EA,$EA,$EA,$EA,$EA

; don't go to bonus game
ORG $008F67
    db $EA,$EA,$EA

; subtract 1 star when you hit 100
ORG $008F6F
    db $01

; don't draw score to status bar
ORG $008EDB
    db $EA,$EA,$EA

; don't draw bonus stars to status bar
ORG $008FA4
    db $EA,$EA,$EA,$EA,$EA,$EA
ORG $008FB7
    db $EA,$EA,$EA
ORG $008FBD
    db $EA,$EA,$EA
ORG $008FEF
    db $EA,$EA,$EA

; draw coins to status bar in different spot
ORG $008F7E
    STA $0F0C
    STX $0F0B

; don't draw lives to status bar
ORG $009053
    db $EA,$EA,$EA
ORG $009068
    db $EA,$EA,$EA

; new game modes
ORG $00933F
    dw $FFAC
ORG $009347
    dw $FFB8
ORG $00934F
    dw $FFB8
ORG $009351
    dw $A249
ORG $00935B
    dw $9510
ORG $00936B
    dw $FFB0
ORG $00936F
    dw $FFB4

; load credits differently
ORG $009510
    LDA #$08
    STA $13C6
    JMP $9468

; remove original save function
ORG $009BC9
    db $6B

; skip intro level
ORG $009CB1
    db $00

; start with 99 lives
ORG $009E25
    db $62
    
; disable file erase
ORG $009E6C
    db $03
    
; disable 2-player game
ORG $009E6E
    db $01
    
; level mode hijack
ORG $00A249
    JSL precise_timer
    JMP $A1DA
    
; load level will add 40 frames to timer
ORG $00A5AB
    JSL level_load_penalty
    
; disable fade out at level end
ORG $00AF35
    JMP $B091
    NOP
ORG $00B091
fade_out:
    LDA $13C6
    BEQ .return
    LDA $13
    AND #$03
    JMP $AF39
.return:
    RTS

; disable midway points
ORG $00CA2C
    db $00

; don't decrement lives on death
ORG $00D0D8
    db $EA,$EA,$EA

; activate ! blocks every time
ORG $00EEB1
    db $EA,$EA
ORG $0DEC9A
    db $EA,$EA
    
; don't remember 1ups, moons, or dragon coins
ORG $00F2BB
    db $EA,$EA,$EA
ORG $00F325
    db $EA,$EA,$EA
ORG $00F354
    db $EA,$EA,$EA
ORG $0DA5A7
    LDA #$00
    NOP
ORG $0DA59C
    LDA #$00
    NOP
ORG $0DB2D7
    LDA #$00
    NOP

; quick death
ORG $00F61C
    db $10

; death flag
ORG $00F625
    INC $188A
    
; new game mode hijacks
ORG $00FFAC
    JML yoshi_wings
    JML load_menu
    JML overworld_menu
    JSL tmpfade_timer
    JML $009F37

; more SRAM
ORG $00FFD8
    db $04

; finish levels faster
ORG $00EECD        ; switch palace
    db $01
ORG $00C962
    ;db $10
ORG $01877C        ; orb
    db $01
ORG $01C0FA        ; goal tape
    db $01
ORG $01D04B        ; Morton & Roy
    db $EE
ORG $01FB29        ; Iggy & Larry
    db $01
ORG $038098        ; Big Boo
    db $01
ORG $0398E2        ; Reznor
    db $01
ORG $03AC12        ; Bowser
    db $93,$14
ORG $03C7A2        ; Lemmy & Wendy
    db $01
ORG $03CE95        ; Ludwig
    db $01
    
; orb sets flag
ORG $018778
    JSR $C062
ORG $01C062
    STZ $14C8,X
    LDA $9E,X
    CMP #$4A    ; orb
    BNE not_orb
    LDA #$20
    STA !orb_flag
not_orb:
    RTS
    
; fix enemy direction spawning
ORG $01AD30
    JSL sub_horiz_pos
    RTS
    
; overworld controls hijack
ORG $048244
    JSL overworld_controls

; vertical level names
ORG $03BB49
    db $80,$25
ORG $03BB4F
    db $50,$C1

; disable overworld panning
ORG $048380
    db $00

; faster star road warp
ORG $049E5E
    db $01
ORG $049E69
    LDA #$FF
    STA $1DF7
    db $EA,$EA,$EA,$EA,$EA
    db $EA,$EA,$EA,$EA,$EA
    
; overworld border
ORG $04A484
    db $50,$2D,$00,$01,$A0,$39
ORG $04A48A
    db $50,$4D,$00,$01,$B0,$39
ORG $04A490
    db $50,$6D,$00,$01,$C0,$39
ORG $04A49C
    db $50,$8D,$00,$01,$D0,$39
ORG $04A4A2
    db $50,$55,$00,$01,$FE,$38
ORG $04A52C
    db $50,$87,$00,$01,$FE,$38
ORG $05DC16
    LDA #$FE
    STA $7F8383
    LDA #$38
ORG $05DC24
    LDA #$FE
    STA $7F8381
    LDA #$38

; remove save prompt
ORG $04E5E6
    db $00,$00,$00,$00,$00,$00,$00,$00

; disable no-yoshi intros
ORG $05DA19
    JMP $DAD7

; disable chocolate island 2 weirdness
ORG $05DAE5
    db $00
    
; level load store level number
ORG $05D7C0
    JSL took_secondary_exit
    NOP
    
; file select stripe images
ORG $05B801
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
ORG $05B825
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
ORG $05B849
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
ORG $05B85D
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
ORG $05B8AC
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
    db $FC,$38
    
; load credits differently
ORG $0C9F16
    JSL load_record
ORG $0C9F6C
    JSL credits_records
    LDX #$00
    NOP
    NOP
ORG $0C9F88
    db $EA,$EA,$EA,$EA,$EA,$EA
ORG $0C9F68
    db $FF,$FF
ORG $0C9FB3
    db $EA,$EA

reset bytes

;;;;;;;;;;;;;;;;
; NMI Hijack
;;;;;;;;;;;;;;;;

ORG $16F000
NMIHijack:
        LDA #$80
        STA $2100                            ; force blank
        LDA $0100
        CMP #$23
        BNE .done
        
        LDX !curr_selection
        JSL update_graphics_menu
        PHX
        DEX
        CPX #$FF
        BNE .go_on
        LDX #$0B
    .go_on:
        JSL update_graphics_menu
        PLX
        INX
        CPX #$0C
        BNE .go_on2
        LDX #$00
    .go_on2:
        JSL update_graphics_menu
        
    .done:
        RTL

;;;;;;;;;;;;;;;;
; Overworld controls
;;;;;;;;;;;;;;;;

ORG $178000
overworld_controls:
        PHP
        PHB
        PHK
        PLB
        REP #$30
        
        LDA $1F1F                            ; set potential translevel
        AND #$000F                           ; (code taken from $05D850)
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
        SEP #$30
        
        LDA $010A
        AND #$03
        ASL A
        ASL A
        ASL A
        ASL A
        STA !timer_save_high
        LDA !potential_translevel
        AND #$7F
        LSR A
        LSR A
        LSR A
        TSB !timer_save_high
        LDA !potential_translevel
        ASL A
        ASL A
        ASL A
        ASL A
        ASL A
        STA !timer_save_low
        LDA #$70                            ; clear save pointer
        STA !timer_save_bank
        LDA !timer_save_low
        STA $00
        LDA !timer_save_high
        STA $01
        LDA !timer_save_bank
        STA $02
        
        LDA $13D9
        CMP #$03
        BNE .be_done
        LDA $144E
        BNE .do_records_display
    .be_done:
        JMP .done_times
    
    .do_records_display:        
        LDY #$08
    .loop_display_time:
        DEY
        BMI .done_times
        JSR load_unran_time
        TYA
        ASL A
        ASL A
        PHY
        TAY
        LDA [$00],Y                            ; get first byte of time
        CMP #$FF
        BEQ .draw_unran
        
        PHX
        LDA [$00],Y
        JSL $00974C                            ; hex -> dec
        TAX
        LDA tile_numbers,X
        STA !dynamic_stripe+4
        INY
        LDA [$00],Y
        JSL $00974C                            ; hex -> dec
        PHA
        LDA tile_numbers,X
        STA !dynamic_stripe+8
        PLA
        TAX
        LDA tile_numbers,X
        STA !dynamic_stripe+10
        INY
        LDA [$00],Y
        JSL $00974C                            ; hex -> dec
        PHA
        LDA tile_numbers,X
        STA !dynamic_stripe+14
        PLA
        TAX
        LDA tile_numbers,X
        STA !dynamic_stripe+16
        PLX
        JSR load_stripe_from_buffer
        PLY
        BRA .loop_display_time
        
    .draw_unran
        PLY
        LDA !potential_translevel
        TAX
        LDA translevel_types,X
        CPY #$04
        BCC .no_shift
        LSR A
    .no_shift:
        AND #$01
        BEQ .draw_blank
        JSR load_stripe_from_buffer
        BRA .loop_display_time
    .draw_blank
        JSR load_blank_time
        JSR load_stripe_from_buffer
        BRA .loop_display_time
        
    .done_times:
        LDA $0DB2
        BEQ .testL                            ; return if in 2-player mode
        RTL
        
    .testL:                                    ; L = Yoshi color
        LDA !cont_frame_b
        AND #$20
        BEQ .testR
        LDA $0DBA
        
    .loopA:
        INC A
        INC A
        CMP #$02
        BEQ .loopA
        CMP #$0C
        BNE .skip0A
        LDA #$00
    .skip0A:
        STA $13C7
        STA $0DBA
        INC $0DC1
        
    .testR:                                    ; R = powerup
        LDA !cont_frame_b
        AND #$10
        BEQ .testSTART
        LDA $19
        INC A
        CMP #$04
        BNE .skip0B
        LDA #$00
    .skip0B:
        STA $19
        STA $0DB8
        
    .testSTART:                                ; START = menu
        LDA $144E
        BNE .save_lvl_states                ; make sure Mario is facing forward
        LDA $1DF7
        BNE .save_lvl_states                ; and he's not warping off star road
        LDA !cont_frame_a
        AND #$10
        BEQ .save_lvl_states
        LDA #$1C                            ; play sound
        STA $1DFC
        LDA #$20                            ; set game mode
        STA $0100
        
    .save_lvl_states:
        LDX #$04
    .loop_boo_ring:
        DEX
        BMI .save_rng
        LDA $0FAE,X
        STA !restore_boo_ring,X
        BRA .loop_boo_ring
        
    .save_rng:
        LDX #$04
    .loop_rng:
        DEX
        BMI .relax_timer
        LDA $148B,X
        STA !restore_rng,X
        BRA .loop_rng
        
    .relax_timer:
        LDA #$FF
        STA !curr_selection                  ; set pointer to unused state
        STZ !timer_min                       ; clear timer
        STZ !timer_sec
        STZ !timer_frames
        STZ !room_timer_min                  ; clear timer
        STZ !room_timer_sec
        STZ !room_timer_frames
        STZ !timer_flag                      ; clear timer lock
        STZ !coins_this_level                ; clear coin counter
        STZ !yoshi_flag
        STZ !orb_flag
        STZ !tick_rta_timer_flag
        STZ $1DF7                            ; clear star road warp speed
        STZ $13C5                            ; clear 3up moon counter
        STZ $0DB6                            ; clear coin counter
        
        LDA $0DBA
        STA !restore_yoshi
        STA !restore_room_yoshi
        LDA $19
        STA !restore_powerup
        STA !restore_room_powerup
        LDA $0DC2
        STA !restore_itembox
        STA !restore_room_itembox
        
        LDX #$05
        LDA $13C1                            ; current overworld tile
    .find_no_yoshi:
        DEX
        BMI .not_found
        CMP no_yoshi_intros,X
        BEQ .found
        BRA .find_no_yoshi
        
    .found:
        LDA #$01
        STA $1B9B
        BRA .done
    .not_found:
        STZ $1B9B
        
    .done:
        PLB
        PLP
        RTL
        
load_unran_time:
        PHY
        LDY #$13
    .loop:
        DEY
        BMI .done
        LDA default_time_stripe,Y
        STA !dynamic_stripe,Y
        BRA .loop
    .done:
        PLY
        LDA times_position,Y
        STA !dynamic_stripe+1
        RTS
        
load_blank_time:
        PHY
        LDY #$13
    .loop:
        DEY
        BMI .done
        LDA blank_stripe,Y
        STA !dynamic_stripe,Y
        BRA .loop
    .done:
        PLY
        LDA times_position,Y
        STA !dynamic_stripe+1
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
        LDA !dynamic_stripe,Y
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
        
no_yoshi_intros:
        db $5D,$63,$58,$60,$61                ; castles, ghost houses, bowser
        
times_position:                                ; byte 2 of stripe image header
        db $2F,$4F,$6F,$8F
        db $37,$57,$77,$97
        
default_time_stripe:                        ; stripe -'--"--
        db $50,$FF,$00,$0D
        db $A8,$39,$A6,$39
        db $A8,$39,$A8,$39
        db $A7,$39,$A8,$39
        db $A8,$39,$FF
        
blank_stripe:                                ; stripe _______
        db $50,$FF,$00,$0D
        db $FE,$38,$FE,$38
        db $FE,$38,$FE,$38
        db $FE,$38,$FE,$38
        db $FE,$38,$FF

tile_numbers:                                ; 0-9
        db $22,$23,$24,$25,$26
        db $27,$28,$29,$2A,$2B
        
translevel_types:                            ; ------sn, s = display secret exit times, n = display normal exit times
        db $00,$01,$01,$00
        db $03,$01,$01,$01
        db $01,$03,$03,$01
        db $01,$01,$01,$03
        db $01,$01,$00,$03
        db $01,$03,$00,$00
        db $01,$00,$01,$01
        db $01,$01,$00,$01
        db $01,$01,$01,$03
        db $03,$01,$01,$01
        db $00,$01,$01,$01
        db $00,$03,$01,$01
        db $00,$01,$01,$03
        db $01,$01,$00,$01
        db $03,$03,$01,$01
        db $03,$01,$03,$01
        db $01,$03,$03,$03
        db $03,$01,$01,$03
        db $01,$00,$01,$01                    ; funky
        db $01,$00,$01,$01
        db $01,$01,$00,$00
        db $03,$00,$03,$00
        db $03,$03,$03,$00
        db $00

;;;;;;;;;;;;;;;;
; Load Overworld Menu
;;;;;;;;;;;;;;;;

ORG $188000
load_menu:
        PHP
        PHB
        PHK
        PLB
        
    .begin:
        LDA #$09                            ; play sound
        STA $1DFB
        
    .green:
        LDA $1F27
        BNE .loadgreen
        STZ !green_status
        BRA .yellow
    .loadgreen
        LDA #$01
        STA !green_status
        
    .yellow:
        LDA $1F28
        BNE .loadyellow
        STZ !yellow_status
        BRA .blue
    .loadyellow
        LDA #$01
        STA !yellow_status
        
    .blue:
        LDA $1F29
        BNE .loadblue
        STZ !blue_status
        BRA .red
    .loadblue:
        LDA #$01
        STA !blue_status
        
    .red:
        LDA $1F2A
        BNE .loadred
        STZ !red_status
        BRA .special
    .loadred:
        LDA #$01
        STA !red_status
        
    .special:
        LDA $1EEB
        ROL A
        AND #$00
        ROL A
        STA !special_status
        
    .yoshi:
        LDA $0DBA
        LSR A
        BEQ .skip_dec
        DEC A
    .skip_dec
        STA !yoshi_status
        
    .powerup:
        LDA $19
        STA !powerup_status
        
    .itembox:
        LDA $0DC2
        STA !itembox_status
        STZ $0F66
        STZ $0F67
    
    .testDMAVRAM:
        PHP
        LDA #$80
        STA $2100                             ; force blank
        REP #$10
        SEP #$20                              ; 8-bit accum, 16-bit index
        
        LDA #$80
        STA $2115
        LDX #$0000                            ; layer 2 tiles @$0000
        STX $2116
        PHK
        PLA
        LDX #Tiles                            ; layer 2 tiles
        LDY #$1000                            ; number of bytes
        JSL LoadVRAM
        LDX #$2000                            ; layer 2 tilemap @$2000
        STX $2116
        PHK
        PLA
        LDX #TileMapLayer2                    ; layer 2 tilemap
        LDY #$0800                            ; number of bytes
        JSL LoadVRAM
        LDX #$5000                            ; layer 3 tilemap @$5000
        STX $2116
        PHK
        PLA
        LDX #TileMapLayer3                    ; layer 2 tilemap
        LDY #$0800                            ; number of bytes
        JSL LoadVRAM
        
        LDA #$40
        STA $2121                             ; palette at $40
        PHK
        PLA
        LDX #Palette
        LDY #$0080
        JSL LoadCGRAM
        
        LDA #$23                              ; layer 2 tilemap -> $2000, 64x64
        STA $2108
        STZ $210B                             ; layer 2 tiles -> $0000
        LDA #$06                              ; layer 2 & layer 3 only
        STA $212C
        STZ $1E
        STZ $1F
        LDA #$04
        STA $20
        STZ $21                               ; layer 2 position
        LDX #$A445
        STX $0701                             ; background color
        PLP
        
        LDX #$0C
    .loop_item:
        DEX
        BMI .done_item
        JSL update_graphics_menu
        BRA .loop_item
        
    .done_item:        
        STZ $2100                             ; exit force blank
        STZ !erase_records_flag
        STZ !curr_selection
        INC $0100
        PLB
        PLP
        JML $008494
        
update_graphics_menu:                         ; requires v/f-blank
        JSL draw_menu_selection
        RTL

draw_menu_selection:                          ; X = index of option
        PHP
        PHB
        PHK
        PLB
        SEP #$10
        PHX
        PHX
        TXA
        ASL A
        TAX
        REP #$10
        LDY graphics_position,X
        STY $2116
        SEP #$10
        PLX
    .cont:
        TXA
        ASL A
        TAX
        REP #$20
        LDA menu_table_offset,X
        PHA
        TXA
        LSR A
        TAX
        PLA
        CPX #$09
        BCS .no_add
        SEP #$20
        CLC
        ADC !status_table,X
        XBA
        ADC #$00
        XBA
    .no_add:
        REP #$30
        ASL A
        ASL A
        ASL A
        ASL A
        CLC
        ADC #graphics_tile_data
        CPX !curr_selection
        BNE .not_sel
        CLC
        ADC #$30F0    
    .not_sel:
        TAX
        SEP #$20
        LDA #$1A
        LDY #$0008
        JSL LoadVRAM
        REP #$10
        PHX
        SEP #$10
        LDA $03,S
        ASL A
        TAX
        REP #$20
        LDA graphics_position,X
        CLC
        ADC #$0020
        STA $2116
        SEP #$20
        REP #$10
        PLX
        INX
        INX
        INX
        INX
        INX
        INX
        INX
        INX
        LDA #$1A
        LDY #$0008
        JSL LoadVRAM
        SEP #$10
    .done:
        PLX
        PLB
        PLP
        RTL
    
menu_table_offset:
        dw $0000,$0002,$0004,$0006,$0008,$000A,$010A,$020A,$030A,$030C,$030D,$030E

graphics_position:
        dw $2058,$2098,$20D8,$2118
        dw $2158,$2198,$21D8,$2218
        dw $2258,$2298,$22D8,$2318

LoadVRAM:                                    ; A|X = address of data, Y = number of bytes (Mx)
        PHP
        
        STX $4302
        STA $4304
        STY $4305
        
        LDA #$01
        STA $4300
        LDA #$18
        STA $4301
        LDA #$01
        STA $420B
        
        PLP
        RTL
        

LoadCGRAM:                                    ; A|X = address of data, Y = number of bytes (Mx)
        PHP
        
        STX $4302
        STA $4304
        STY $4305
        
        STZ $4300
        LDA #$22
        STA $4301
        LDA #$01
        STA $420B
        
        PLP
        RTL
        
Tiles:
        incbin "bin_tiles.bin"

TileMapLayer2:
        incbin "bin_tilemap_layer2.bin"

TileMapLayer3:
        incbin "bin_tilemap_layer3.bin"

Palette:
        incbin "bin_palette.bin"
        

;;;;;;;;;;;;;;;;
; Overworld Menu
;;;;;;;;;;;;;;;;

ORG $198000
overworld_menu:
        PHB
        PHK
        PLB
        SEP #$30
        INC $14
        
    .testUP:
        LDA !cont_frame_a
        AND #$08
        BEQ .testDOWN
        LDA !curr_selection
        DEC A
        CMP #$FF
        BNE .nowrap
        LDA #$0B
    .nowrap:
        STA !curr_selection
        JMP .finish_sound
        
    .testDOWN:
        LDA !cont_frame_a
        AND #$04
        BEQ .testLEFT
        LDA !curr_selection
        INC A
        CMP #$0C
        BNE .nowrap2
        AND #$00
    .nowrap2:
        STA !curr_selection
        JMP .finish_sound
        
    .testLEFT:
        LDA !cont_frame_a
        AND #$02
        BNE .goLEFT
        LDA !cont_all_b
        AND #$20
        BEQ .testRIGHT
    .goLEFT:
        LDX !curr_selection
        CPX #$09
        BCS .testRIGHT
        DEC !status_table,X
        LDA #$00
        JSR check_bounds
        JMP .finish_sound
        
    .testRIGHT:
        LDA !cont_frame_a
        AND #$01
        BNE .goRIGHT
        LDA !cont_all_b
        AND #$10
        BEQ .test_selection
    .goRIGHT:
        LDX !curr_selection
        CPX #$09
        BCS .test_selection
        INC !status_table,X
        LDA #$01
        JSR check_bounds
        JMP .finish_sound
    
    .test_selection:
        LDA !cont_frame_a
        AND #$90                            ; START / B
        BNE .which_selection
        LDA !cont_frame_b
        AND #$80                            ; A
        BEQ .never_mind
        
    .which_selection:
        LDA !curr_selection
        ASL A
        TAX
        JMP (.jump_table,X)
        
    .jump_table:
        dw .j_yellow
        dw .j_green
        dw .j_red
        dw .j_blue
        dw .j_special
        dw .j_yoshi
        dw .j_powerup
        dw .j_itembox
        dw .j_records
        dw .j_enemy
        dw .j_cancel
        dw .j_save
        
    .j_yoshi:
        LDA #$1F                            ; play sound
        STA $1DFC        
    .j_yellow:
    .j_green:
    .j_red:
    .j_blue:
    .j_special:
    .j_powerup:
    .j_itembox:
        JMP .finish_no_sound
    .j_records:
        LDA #$24
        STA $12
        LDA !erase_status
        INC A
        STA !erase_records_flag                ; #$01 = all, #$02 = this level
        LDA #$0B                            ; play sound
        STA $1DFC        
        JMP .finish_no_sound
    .j_enemy:
        LDA #$01                            ; play sound
        STA $1DFC
        JSL reset_enemy_states
        JMP .finish_no_sound
    .j_save:
        LDA #$29                            ; play sound
        STA $1DFC
        LDA !erase_records_flag
        BEQ .no_erase
        CMP #$01
        BEQ .del_all
        LDA !potential_translevel
        JSL delete_this_level
        BRA .no_erase
    .del_all
        JSL delete_all_records
    .no_erase:
        JMP .save_and_quit
    .j_cancel:
        LDA #$2A                            ; play sound
        STA $1DFC        
        JMP .quit
    
    .never_mind:
        JMP .finish_no_sound
        
    .save_and_quit:
        LDA !green_status
        STA $1F27
        LDA !yellow_status
        STA $1F28
        LDA !blue_status
        STA $1F29
        LDA !red_status
        STA $1F2A
        LDA !special_status
        CLC
        ROR A
        ROR A
        STA $1EEB
        LDA !yoshi_status
        BEQ .no_inc
        INC A
    .no_inc:
        ASL A
        STA $13C7
        STA !restore_yoshi
        INC $0DC1
        LDA !powerup_status
        STA !restore_powerup
        STA $19
        LDA !itembox_status
        STA !restore_itembox
        STA $0DC2
    .quit:
        LDA #$0B
        STA $0100
        BRA .finish_no_sound
        
    .finish_sound:
        LDA #$06                            ; play sound
        STA $1DFC
        
    .finish_no_sound:
        ;JSR menu_graphics
        PLB
        JML $008494

check_bounds:
        PHP
        PHY
        LDY !status_table,X
        REP #$10
        PHY
        PHA
        LDA !cont_all_a                        ; hold X/Y to override
        ORA !cont_all_b
        AND #$40
        BEQ .not_extended
        LDA min_selection_extended,X
        BRA .merge
    .not_extended:
        LDA min_selection_normal,X
    .merge:
        REP #$20
        AND #$00FF
        CMP $02,S
        SEP #$30
        BPL .out
        PLY
        BNE .increasing
        STA !status_table,X
        BRA .done
    .increasing:
        STZ !status_table,X
        BRA .done
    .out:
        PLY
    .done:
        PLY
        PLY
        PLY
        PLP
        RTS

min_selection_normal:
    db $01,$01,$01,$01,$01,$04,$03,$04,$01,$00,$00,$00

min_selection_extended:
    db $01,$01,$01,$01,$01,$FF,$FF,$FF,$01,$00,$00,$00
    
reset_enemy_states:
        PHP
        REP #$30
        PHX
        STZ $0FAE                            ; boo ring angles
        STZ $0FB0
        
        LDX #$0050
    .loop_boo_cloud:                        ; boo cloud positions
        DEX
        DEX
        BMI .done_boo_cloud
        STZ $1E52,X
        BRA .loop_boo_cloud
    
    .done_boo_cloud:
        PLX
        PLP
        RTL

;;;;;;;;;;;;;;;;
; Credits Records
;;;;;;;;;;;;;;;;

ORG $1A8000        
credits_records:
        LDA #$FF80
        STA $1446                            ; background scrolling
        
    .try_move:
        LDA $24
        CMP #$0580
        BCS    .no_move
        LDA !cont_all_a
        AND #$0004                            ; down
        BEQ .no_move
        LDA #$0100
        STA $1448
        BRA .try_delete
    
    .no_move:
        STZ $1448
        
    .try_delete:
        LDA !cont_all_a
        AND #$00F0
        CMP #$00F0                            ; B Y SELECT START
        BNE .done
        LDA !cont_all_b
        AND #$00F0
        CMP #$00F0                            ; A X L R
        BEQ .delete_all
    
    .done:
        RTL
        
    .delete_all:
        JSL delete_all_records
        
    .finish:
        SEP #$10
        RTL
        
load_record:
        PHB
        PHK
        PLB
        LDA $138008,X
        SEP #$20
        CMP #$27
        BEQ .replace_tile
        REP #$20
        PLB
        RTL
        
    .replace_tile:
        XBA
        PHA
        XBA
        PHX
        PHY
        LDA #$70
        STA $05                                ; bank
        LDA $7E010A
        ASL A
        ASL A
        ASL A
        ASL A
        STA $04                                ; file
        TXA
        AND #$40
        LSR A
        LSR A
        STA $03                                ; exit
        TXA
        INC A
        INC A
        AND #$30
        CMP #$30
        BEQ .forward
        CMP #$20
        BNE .level
        LDA #$04
        BRA .continue
    .forward:
        LDA #$08
    .continue:
        TSB $03                                ; kind
    .level:
        REP #$20
        TXA
        XBA
        DEC A
        CLC
        ROL A
        BCC .skip_inc
        INC A
    .skip_inc:
        AND #$00FF
        TAY
        SEP #$20
        PHX
        TYX
        LDA translevels,X
        AND #$7F
        LSR A
        LSR A
        LSR A
        TSB $04                                ; level
        LDA translevels,X
        ASL A
        ASL A
        ASL A
        ASL A
        ASL A
        TSB $03                                ; level
        PLX
        
    .look_behind:
        DEX
        DEX
        LDA $138008,X
        INX
        INX
        CMP #$78                            ; colon
        BNE .look_ahead
        TXA
        LSR A
        AND #$01
        BEQ .frame
        LDY #$0001
        BRA .second
    .frame:
        LDY #$0002
    .second:
        JMP .do_tens
        
    .look_ahead:
        INX
        INX
        LDA $138008,X
        DEX
        DEX
        CMP #$FC
        BNE .double_check
        LDY #$0002
        JMP .do_ones
    .double_check:
        TXA
        LSR A
        AND #$01
        BEQ .second2
        LDY #$0000
        BRA .minute
    .second2:
        LDY #$0001
    .minute:
        JMP .do_ones
        
    .do_tens:
        LDA [$03],Y
        CMP #$FF
        BNE .time_present
        LDA #$27
        JMP .done
    .time_present:
        SEP #$10
        JSL $00974C
        REP #$10
        TXA
        JMP .done
        
    .do_ones:
        LDA [$03],Y
        CMP #$FF
        BNE .time_present2
        LDA #$27
        JMP .done
    .time_present2:
        SEP #$10
        JSL $00974C
        REP #$10
        JMP .done
        
    .done:
        PLY
        PLX
        XBA
        PLA
        XBA
        REP #$20
        PLB
        RTL
        
translevels:
    db $28,$29,$2A,$27,$26,$15,$09,$05
    db $06,$0A,$2F,$04,$13,$03,$3E,$3C
    db $2E,$3D,$2D,$01,$02,$2B,$0B,$0C
    db $0D,$0F,$10,$11,$42,$44,$47,$43
    db $46,$41,$1F,$22,$24,$23,$1D,$1C
    db $3B,$21,$1B,$18,$3A,$39,$37,$33
    db $38,$35,$25,$07,$40,$0E,$20,$1A
    db $34,$31,$32,$14,$08,$3F,$45,$58
    db $54,$56,$59,$5A,$4E,$4F,$50,$51
    db $4C,$4B,$4A,$48
    
delete_all_records:
        PHP
        REP #$20
        SEP #$10
        LDX #$70
        STX $05
        LDA $7E010A
        AND #$00FF
        ASL A
        ASL A
        ASL A
        ASL A
        XBA
        STA $03
        
        REP #$10
        LDA #$FEFF
        LDY #$0000
        
    .loop:
        CPY #$1000
        BEQ .finish
        STA [$03],Y
        INY
        INY
        BRA .loop
        
    .finish
        PLP
        RTL

delete_this_level:                                ; A (8-bit) has translevel
        PHP
        REP #$30
        AND #$00FF
        ASL A
        ASL A
        ASL A
        ASL A
        ASL A
        TAY
        
        LDX #$0070
        STX $05
        LDA $7E010A
        AND #$00FF
        ASL A
        ASL A
        ASL A
        ASL A
        XBA
        STA $03
        
        LDA #$FEFF
        LDX #$0000
        
    .loop:
        CPX #$0020
        BEQ .finish
        STA [$03],Y
        INY
        INY
        INX
        INX
        BRA .loop
        
    .finish
        PLP
        RTL
        
save_confirm_message:
    db $52,$46,$00,$1D
    db $1C,$3C,$0A,$3C
    db $1F,$3C,$0E,$3C
    db $FC,$3C,$1D,$3C
    db $18,$3C,$FC,$3C
    db $0C,$3C,$18,$3C
    db $17,$3C,$0F,$3C
    db $12,$3C,$1B,$3C
    db $16,$3C,$FF
        
new_record_message:
    db $50,$82,$00,$15
    db $17,$28,$0E,$28
    db $20,$28,$FC,$28
    db $1B,$28,$0E,$28
    db $0C,$28,$18,$28
    db $1B,$28,$0D,$28
    db $28,$28,$FF
    

graphics_tile_data:
        incbin "bin_tilemap_options.bin"

;;;;;;;;;;;;;;;;
; Precise Timer
;;;;;;;;;;;;;;;;
        
ORG $1B8000
level_load_penalty:
        JSL $05809E
        
        LDA $141A
        BNE .goto_loops
        INC $141A                            ; index starting at 1 instead of 0
    .goto_loops:
    
        LDX #$28                            ; penalty = 40 frames
        
        LDA !timer_min                        ; don't tick if timer is 0
        ORA !timer_sec                        ; (used for begining of level)
        ORA !timer_frames
        BNE .loop
        RTL
        
    .loop:
        CPX #$00
        BEQ .done
        DEX
        PHX
        JSL precise_timer
        PLX
        BRA .loop
        
    .done
        STZ !room_timer_min                    ; clear room timer
        STZ !room_timer_sec
        STZ !room_timer_frames
        RTL
        
set_global_exit:                            ; for use by CI2 exits only
        LDX #$20
    .loop_exits:
        DEX
        STA $19B8,X
        BNE .loop_exits
        PHA
        LDA #$06
        LDX #$20
    .loop_secondary:
        DEX
        STA $19D8,X
        BNE .loop_secondary
        PLA
        RTS
        
precise_timer:
        LDA $71
        CMP #$05
        BNE time_restore
        LDA $88
        BNE time_restore
        LDA $13BF
        CMP #$24                            ; re-writing CI2's weird exits
        BNE time_restore
        LDA $141A                            ; which exit we are on
        ASL A
        TAX
        JMP (ci2_room_exits,X)
        
ci2_room_exits:
        dw ci2_coins_prep
        dw ci2_coins
        dw ci2_time
        dw ci2_dragon_coins
        dw time_restore
        
ci2_coins_prep:
        INC $141A                            ; in case 0 ever happens (it shouldn't)
        
ci2_coins:
        LDA !coins_this_level
        CMP #$15
        BCC .less_21
        LDA #$CF                            ; x >= 21 coins
        BRA .and_go
    .less_21:
        CMP #$09
        BCC .less_9
        LDA #$B7                            ; 9 <= x < 21 coins
        BRA .and_go
    .less_9
        LDA #$B8                            ; x < 9 coins
    .and_go:
        JSR set_global_exit
        JMP time_restore
        
ci2_time:
        LDA $0F31
        CMP #$02
        BCS .ge_200
        LDA #$CE                            ; x < 200
        BRA .and_go
    .ge_200:
        LDA $0F32
        ASL A
        ASL A
        ASL A
        ASL A
        ORA $0F33
        CMP #$35
        BCS .ge_235
        LDA #$CE                            ; 200 <= x < 235
        BRA .and_go
    .ge_235:
        CMP #$50
        BCS .ge_250
        LDA #$BA                            ; 235 <= x < 250
        BRA .and_go
    .ge_250
        LDA #$B9                            ; x >= 250
    .and_go:
        JSR set_global_exit
        JMP time_restore
        
ci2_dragon_coins:
        LDA $1420
        CMP #$04
        BCS .ge_4
        LDA #$BB                            ; x < 4 dragon coins
        BRA .and_go
    .ge_4:
        LDA #$CD                            ; x >= 4 dragon coins
    .and_go
        JSR set_global_exit
        JMP time_restore        
        
time_restore:
        LDA $0F31
        CMP !restore_time
        BCC .testLR
        STA !restore_time
        
    .testLR:
        LDA $188A
        BNE .testLR_2
        LDA $1493                            ; no reset if keyhole
        ORA $1434                            ; no reset if level beaten
        ORA $9D                                ; no reset if sprites locked
        ORA $1426                            ; no reset if message block
        BEQ .testLR_2
        JMP .timer
        
    .testLR_2:
        LDA !cont_all_b
        AND #$30                            ; L R
        CMP #$30
        BEQ .testLR_3
        JMP .timer
        
    .testLR_3:
        LDA $141A
        CMP #$01
        BEQ .test_translevel
        LDA !cont_all_a
        AND #$80                            ; B
        BEQ .test_secondary
        LDA !cont_all_b
        AND #$80                            ; A
        BEQ .test_secondary
        
    .test_translevel:
        LDA $13BF
        CMP #$25
        BCC .skip_translevel
        SEC
        SBC #$24
        STZ !tick_rta_timer_flag
        BRA .skip_translevel
        
    .test_secondary:
        INC !reset_room_flag
        INC !tick_rta_timer_flag
        LDA !recent_secondary_exit
    .skip_translevel:
        
        INC $9D                                ; lock sprites
        LDX #$20        
    .loop_exits:
        DEX
        STA $19B8,X
        BNE .loop_exits
        
        LDX #$04
        
        LDA !reset_room_flag
        BEQ .not_secondary_exit
        INX
        INX
    .not_secondary_exit
        LDA $13BF
        CMP #$25
        BCC .begin_secondary
        INX
    .begin_secondary:
        TXA
        LDX #$20        
    .loop_exit_secondary:
        DEX
        STA $19D8,X
        BNE .loop_exit_secondary
        
        LDA #$05
        STA $71
        STZ $88
        STZ $89
        
        LDX #$03        
    .loop_timer:
        DEX
        STZ !timer_min,X
        STZ !room_timer_min,X
        BNE .loop_timer
        
        STZ !timer_flag
        STZ !timer_save_low
        STZ !timer_save_high
        
        LDX #$04
    .loop_boo_ring
        DEX
        BMI .save_rng
        LDA !restore_boo_ring,X
        STA $0FAE,X
        BRA .loop_boo_ring
        
    .save_rng:
        LDX #$04
    .loop_rng:
        DEX
        BMI .item_mem
        LDA !restore_rng,X
        STA $148B,X
        BRA .loop_rng
        
    .item_mem:
        REP #$10
        LDX #$0180
    .loop_memory:
        DEX
        STZ $19F8,X
        BNE .loop_memory
        SEP #$10
        LDA !reset_room_flag
        BEQ .whole_level
        DEC $141A
        BRA .out_exits
    .whole_level:
        STZ $141A                            ; clear number of exits
        STZ !recent_secondary_exit
    .out_exits:
        INC !l_r_reset_flag
        LDA #$54                            ; play sound
        STA $1DFC
        RTL
        
    .timer:
        LDA $010A
        ASL A
        ASL A
        ASL A
        ASL A
        TSB !timer_save_high
        LDA $13BF
        AND #$7F
        LSR A
        LSR A
        LSR A
        TSB !timer_save_high
        LDA $13BF
        ASL A
        ASL A
        ASL A
        ASL A
        ASL A
        TSB !timer_save_low
        
        LDA !timer_save_low
        AND #$0C
        CMP #$08
        BEQ .shortcut
        LDA $19
        CMP #$02
        BNE .check_powerup
        LDA !timer_save_low
        ORA #$08
        AND #$FB
        STA !timer_save_low
    .shortcut:
        BRL not_loading
        
    .check_powerup:
        LDA $19                                ; powerup
        BNE .deny_low
        LDA $1490                            ; star timer
        BNE .deny_low
        LDA $187A                            ; yoshi flag
        BNE .set_yoshi
        LDA $13F3                            ; p-balloon flag
        BNE .deny_low
        BRL not_loading
        
    .set_yoshi:
        LDA #$40
        STA !yoshi_flag
    .deny_low:
        LDA !timer_save_low
        ORA #$04
        STA !timer_save_low
        BRL not_loading
        
l_r_reset_fade:
        LDA !reset_room_flag
        BNE .restore_room
        LDA !restore_powerup
        STA $19
        LDA !restore_yoshi
        STA $13C7
        STA $0DBA
        STA $0DC1
        LDA !restore_itembox
        STA $0DC2
        BRA .merge
        
    .restore_room:
        LDA !restore_room_powerup
        STA $19
        LDA !restore_room_yoshi
        STA $13C7
        STA $0DBA
        STA $0DC1
        LDA !restore_room_itembox
        STA $0DC2
        
    .merge:
        STZ $1420                            ; clear dragon coins
        STZ $1422
        LDA !restore_time
        STA $0F31
        STZ $0F32
        STZ $0F33
        STZ $36
        STZ $37                                ; clear mode 7 rotation
        STZ $14AF                            ; on/off switch
        STZ $1432                            ; coin snake
        STZ !coins_this_level                ; coins for ci2
        STZ $149F                            ; clear P-speed (tsk tsk for not doing this originally)
        STZ $0DBF                            ; clear coin counter
    
;        LDX #$0C
;    .loop_yoshi:
;        DEX
;        STZ $C2,X
;        BNE .loop_yoshi
        
        LDA $13BF
        CMP #$09
        BNE .not_dp2
        LDX #$08
    .loop_dp2:
        DEX
        BMI .not_dp2
        STZ $1A,X
        BRA .loop_dp2                        ; hack-y way of fixing dp2 (eventually we'll do this for all levels when we actually zero stuff out during fade out instead of instantly)
    .not_dp2:
        STZ $1B9A                            ; clear scrolling background
        RTL
        
tmpfade_timer:
        LDA !l_r_reset_flag
        BEQ .no_reset
        JSL l_r_reset_fade
    .no_reset:
        LDA !timer_min
        ORA !timer_sec
        ORA !timer_frames
        BNE not_loading
        RTL
        
not_loading:
        STZ !l_r_reset_flag
        LDA !timer_flag
        BEQ .begin
        RTL
        
    .begin:
        LDX $141C                            ; exit
        LDA $9E
        CMP #$C5                            ; special check for big boo
        BNE .not_big_boo
        LDX #$01
    .not_big_boo:
        LDA $1493                            ; goal tape, orb, koopaling
        BNE .save
        LDA $190D                            ; bowser
        BNE .save
        LDX #$01                            ; secret exit
        LDA $1434                            ; keyhole
        BEQ .try_tick
        
    .save:
        INC !timer_flag
        JSR try_save_value
        LDA !timer_save_low                    ; cascading save - i.e. low% also counts as nocape, etc.
        CLC
        ADC #$04
        STA !timer_save_low
        AND #$0C
        CMP #$0C
        BNE .save
        LDA $1420                            ; check if Lunar Dragon (yoshi coins)
        CMP #$05
        BCC .no_ld
        LDA $13BF
        LDY #$07
    .loop_moon:                                ; check if Lunar Dragon (moon)
        DEY
        BMI .yes_ld                            ; if level has no moon, we good
        CMP moon_lvls,Y
        BNE .loop_moon
        LDA $13C5                            ; if level has moon, check if it was collected
        BEQ .no_ld
    .yes_ld:
        JSR try_save_value                        ; save that record
    .no_ld:
        BRA .display
    
    .try_tick:
        LDA !tick_rta_timer_flag
        BNE .tick_room
        STZ !timer_flag
        LDA !timer_min
        CMP #$09
        BNE .tick
        LDA !timer_sec
        CMP #$3B
        BNE .tick
        LDA !timer_frames
        CMP #$3B
        BEQ .tick_room
        
    .tick:
        INC !timer_frames
        LDA !timer_frames
        CMP #$3C
        BNE .tick_room
        STZ !timer_frames
        INC !timer_sec
        LDA !timer_sec
        CMP #$3C
        BNE .tick_room
        STZ !timer_sec
        INC !timer_min
        
    .tick_room:
        LDA $71
        CMP #$05
        BEQ .display
        CMP #$06
        BEQ .display
        CMP #$08
        BEQ .display
        CMP #$0D
        BEQ .display
        INC !room_timer_frames
        LDA !room_timer_frames
        CMP #$3C
        BNE .display
        STZ !room_timer_frames
        INC !room_timer_sec
        LDA !room_timer_sec
        CMP #$3C
        BNE .display
        STZ !room_timer_sec
        INC !room_timer_min        
        
    .display:
        LDA !tick_rta_timer_flag
        BNE .no_rta_timer
        LDA !timer_min
        JSL $00974C
        STX $0EFA
        STA $0EFB
        LDA !timer_sec
        JSL $00974C
        STX $0EFD
        STA $0EFE
        LDA !timer_frames
        JSL $00974C
        STX $0F00
        STA $0F01
        BRA .display_room
    .no_rta_timer:
        LDA #$27
        STA $0EFA
        STA $0EFB
        STA $0EFD
        STA $0EFE
        STA $0F00
        STA $0F01
        LDA #$FF
        STA !timer_min
        STA !timer_sec
        STA !timer_frames
    .display_room:
        LDA !room_timer_min
        JSL $00974C
        STX $0F15
        STA $0F16
        LDA !room_timer_sec
        JSL $00974C
        STX $0F18
        STA $0F19
        LDA !room_timer_frames
        JSL $00974C
        STX $0F1B
        STA $0F1C
        
    .display_speed:
        LDA $7B
        BPL .positive_speed
        EOR #$FF
        INC A
    .positive_speed:
        JSL $00974C
        STX $0F03
        STA $0F04
        
    .display_input:
        PHB
        PHK
        PLB
        LDA #$7E
        STA $02
        LDA #$0F
        STA $01
        LDA !cont_all_a
        LDX #$08
    .loop_cont_a:
        DEX
        BMI .next_cont
        LSR A
        PHA
        BCS .draw_cont_a
        LDA input_locs_1,X
        STA $00
        LDA #$FC
        BRA .finish_cont_a
    .draw_cont_a:
        LDA input_locs_1,X
        STA $00
        LDA input_tiles_1,X
    .finish_cont_a:
        STA [$00]        
        PLA
        BRA .loop_cont_a
    .next_cont:
        LDA !cont_all_b
        LSR A
        LSR A
        LSR A
        LSR A
        LDX #$04
    .loop_cont_b:
        DEX
        BMI .done_cont
        LSR A
        PHA
        BCS .draw_cont_b
        LDA input_locs_2,X
        STA $00
        LDA #$FC
        BRA .finish_cont_b
    .draw_cont_b:
        LDA input_locs_2,X
        STA $00
        LDA input_tiles_2,X
    .finish_cont_b:
        STA [$00]        
        PLA
        BRA .loop_cont_b
        
    .done_cont:
        PLB
        STZ !reset_room_flag
        RTL

moon_lvls:
        db $29,$06,$2E,$0F,$41,$22,$3A
        
input_locs_1:
        db $2D,$2F,$14,$13,$10,$11,$0F,$12
input_locs_2:
        db $2C,$2E,$2A,$2B
input_tiles_1:
        db $0B,$22,$44,$1C,$41,$42,$40,$43
input_tiles_2:
        db $0A,$21,$15,$1B
        
try_save_value:
        TXA
        ASL A
        ASL A
        ASL A
        ASL A
        TSB !timer_save_low
        
        LDY #$00
        LDA !timer_save_low
        STA $00
        LDA !timer_save_high
        STA $01
        LDA !timer_save_bank
        STA $02
        
        LDA !tick_rta_timer_flag
        BNE .no_save
        
        PHY
        LDY #$03
        LDA [$00],Y
        PLY
        AND #$10
        BEQ .check_prev_orb                        ; if the previous time was saved on an old version,
        LDA !orb_flag                            ; never save the time if you beat level with orb
        BEQ .loop_check                            ; (this fucks up sunken ghost ship)
        BRA .no_save
        
    .check_prev_orb:
        PHY
        LDY #$03
        LDA [$00],Y
        PLY
        AND #$20
        CMP !orb_flag                            ; if you beat the level with orb, only replace if previous time was orb
        BEQ .loop_check                            ; if you beat the level without orb, overwrite if previous time was orb
        CMP #$00
        BEQ .no_save
        BRA .new_record
        
    .loop_check:
        CPY #$03
        BEQ .no_save
        LDA [$00],Y
        CMP #$FF
        BEQ .new_record
        CMP !timer_min,Y
        BEQ .keep_at_it
        BMI .no_save
        BPL .new_record
    .keep_at_it:
        INY
        BRA .loop_check
        
    .new_record:
        LDA #$27
        STA $12                                    ; "NEW RECORD!"
        LDY #$00
    .loop_do:
        CPY #$03
        BEQ .save_attributes
        LDA !timer_min,Y
        STA [$00],Y
        INY
        BRA .loop_do
        
    .save_attributes:                            ; shozygrb, ygrb = ! blocks, s = special, h = yoshi, o = orb
        LDA $1F28                                ; z = 0 if these values are known, 1 if unknown (a time saved on prev ver)
        ASL A
        ORA $1F27
        ASL A
        ORA $1F2A
        ASL A
        ORA $1F29
        STA $04
        LDA $1EEB
        AND #$80
        TSB $04
        LDA !yoshi_flag
        TSB $04
        LDA !orb_flag
        TSB $04
        
        LDA $04
        STA [$00],Y
        
    .no_save:
        RTS
        
yoshi_wings:
        LDA $1B95
        CMP #$02
        BNE .no_yoshi_level
        INC $1493
        JSL precise_timer
        STZ $1B95
        
    .no_yoshi_level:
        JML $009F6F

sub_horiz_pos:
        LDY #$00
        LDA !l_r_reset_flag
        BEQ .no_reset1
        LDA !reset_room_flag
        BNE .no_reset1
        LDA $94
        BRA .low
    .no_reset1:
        LDA $D1
    .low:
        SEC
        SBC $E4,X
        STA $0F
        LDA !l_r_reset_flag
        BEQ .no_reset2
        LDA !reset_room_flag
        BNE .no_reset2
        LDA $95
        BRA .high
    .no_reset2:
        LDA $D2
    .high:
        SBC $14E0,X
        BPL .no_inc
        INY
    .no_inc:
        RTL

took_secondary_exit:
        STA $17BB
        STA !recent_secondary_exit
        STA $0E
        LDA $187A
        BNE .yoshi_exists
        STZ !restore_room_yoshi
        BRA .yoshi_done
    .yoshi_exists:
        LDA $13C7
        STA !restore_room_yoshi
    .yoshi_done:
        LDA $19
        STA !restore_room_powerup
        LDA $0DC2
        STA !restore_room_itembox
        RTL
        
print "Bytes inserted: ", bytes