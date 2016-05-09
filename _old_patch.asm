;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The old version of the
; SMW Practice Cart - Version 6.4B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!cont_all_a                  = $0DA2
!cont_all_b                  = $0DA4
!cont_frame_a                = $0DA6
!cont_frame_b                = $0DA8

!restore_timer_min           = $0F3A
!restore_timer_sec           = $0F3B
!restore_timer_frames        = $0F3C
!restore_timer_flag          = $0F3D

!curr_selection              = $0F3E
!curr_drawing                = $0F3F

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
!speedometer_status          = $0F67
!drop_item_status            = $0F68
!show_slots_status           = $0F69
!enemy_status                = $0F6A

!timer_min                   = $0F6B
!timer_sec                   = $0F6C
!timer_frames                = $0F6D
!timer_flag                  = $0F6E
!timer_save_low              = $0F6F
!timer_save_high             = $0F70
!timer_save_bank             = $0F71

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
!speedometer_flag            = $1F3F
!restore_room_pspeed         = $1F40
!restore_room_item           = $1F41
!drop_item_flag              = $1F42
!show_slots_flag             = $1F43
!slot_gfx_loaded             = $1F44
!restore_igt_hundreds        = $1F45
!restore_igt_tens            = $1F46
!restore_igt_ones            = $1F47
!slot_held                   = $1F48

!restore_powerup             = $1FEE
!restore_yoshi               = $1FEF
!restore_itembox             = $1FF0
!initial_level_time          = $1FF1
!restore_boo_ring            = $1FF2 ; 4 bytes
!restore_rng                 = $1FF6 ; 4 bytes


;;;;;;;;;;;;;;;;
; Hex edits
;;;;;;;;;;;;;;;;

ORG $00FFC0
	db "SMW PRACTICE CART    "

; NMI hijack
ORG $0081AA
    JSL NMIHijack
    NOP

; nintendo presents sound
ORG $0093C1
	db $05

; stripe image pointers
ORG $0084F1
    dw !dynamic_stripe
    db $7E
    dl #save_confirm_message
    dl #new_record_message

; status bar tilemap
ORG $008C89
    db $FC,$3C,$FC,$2C,$FC,$2C,$FC,$3C
    db $FC,$3C,$27,$3C,$85,$3C,$27,$3C
    db $27,$3C,$86,$3C,$27,$3C,$27,$3C
ORG $008CAB
    db $2E,$3C,$FC,$38,$00,$38,$FC,$3C
    db $FC,$3C,$FC,$28,$FC,$28,$FC,$28
    db $FC,$28,$FC,$28,$FC,$28
ORG $008CC1
    db $FC,$38,$FC,$38,$FC,$3C,$FC,$38
    db $27,$38,$85,$38,$27,$38,$27,$38
	db $86,$38,$27,$38,$27,$38
ORG $008CEB
    db $FC,$28,$FC,$28,$FC,$28,$FC,$28
    db $FC,$28,$FC,$28
ORG $008293
    db $26    ; 26 scanlines tall

; disable tempo hike at 99 seconds
ORG $008E59
	db $80

; disable death at 0 seconds
ORG $008E69
	db $80

; keep count of how many coins collected this level
ORG $008F25
    JSR $C57A
ORG $00C57A
    INC $0DBF
    INC !coins_this_level
    RTS

; don't draw lives to the status bar, and bowser timer
ORG $008F55
    NOP
	NOP
	JSL display_bowser_timers

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

; reload music on death
ORG $00F610
	db $00

; save file indices
ORG $009CCB
	db $00,$10,$20
	db $00,$00,$00

; disable something about overwriting sram
ORG $009CF7
	STZ $0109
	JMP $9D22

; display 3 digits for number of times gotten
ORG $009D66
	REP #$20
	LDA $700005,X
	SEP #$10
	JSL HexToDec16
	TXY
	LDX $00
	STA $7F8383,X
	TYA
	JSL HexToDec16
	TXY
	LDX $00
	STA $7F8381,X
	TYA
	STA $7F837F,X
	SEP #$20
	LDA #$38
	STA $7F8380,X
	STA $7F8382,X
	STA $7F8384,X
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP

; how to tell if a file is new or not
ORG $009DB5
	LDA $9CCB,X
	XBA
	LDA $9CCE,X
	REP #$30
	TAX
	PHX
	LDA #$0070
	STA $08
	STX $06
	LDY #$1000
	LDA #$0000
	PHA
loop:
	DEY
	DEY
	DEY
	DEY
	CPY #$0020
	BCC done
	LDA [$06],Y
	CMP #$FFFF
	BEQ loop
	PLA
	INC A
	PHA
	BRA loop
done:
	PLA
	PLX
	STA $700005,X
	LDA $700001,X       ; $700001,file = 0000 if not new
	SEP #$20
	RTS

; start with 99 lives
ORG $009E25
    db $62

; disable file erase
ORG $009E6C
    db $03

; disable 2-player game
ORG $009E6E
    db $01

; relax timer on intro startup
ORG $00A09C
	db $08

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

; modify drop item from item box
ORG $00C56C
	JSL drop_item_box
	CMP #$00
	BNE .no_drop
	JMP $C585
.no_drop:
	JMP $C58F

; disable midway points
ORG $00CA2C
    db $00

; don't decrement lives on death
ORG $00D0D8
    db $EA,$EA,$EA

; use this address for free ram
ORG $00D94F
	NOP
	NOP
	NOP

; activate ! blocks every time
ORG $00EEB1
    db $EA,$EA
ORG $0DEC9A
    db $EA,$EA

; update position of star and splash in GFX00
ORG $01C60B
	db $68
ORG $028D42
	db $6A,$6A

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
    ;db $01
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

; draw slot sprite
ORG $0180AF
	JSR $CD1E
ORG $01CD1E
	JSR $8127
	JSL draw_slot_sprite
	RTS

; disable score sprites if show slots is enabled
ORG $02AEA5
	JSL check_score_sprites
	BEQ .not_disabled
	RTS
.not_disabled:
	NOP
	NOP
	NOP
	NOP
	NOP

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

; rewrite how initial time is worked
ORG $058587
	JSR $D680
ORG $05D680
	STA $0F31
	STA !initial_level_time
	RTS

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
        BNE .check_lvl_start

        LDX !curr_selection
        JSL update_graphics_menu
        PHX
        DEX
        CPX #$FF
        BNE .go_on
        LDX #$0E
    .go_on:
        JSL update_graphics_menu
        PLX
        INX
        CPX #$0F
        BNE .go_on2
        LDX #$00
    .go_on2:
        JSL update_graphics_menu
		BRA .done

	.check_lvl_start:
		CMP #$14
		BNE .clear_load_flag
		JSL load_slots_gfx
		LDA #$01
		STA !slot_gfx_loaded
		BRA .done
	.clear_load_flag
		STZ !slot_gfx_loaded
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
        BMI .be_done
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
		STA $0D
        JSL $00974C                            ; hex -> dec
        TAX
        LDA tile_numbers,X
        STA !dynamic_stripe+4
        INY
        LDA [$00],Y
		STA $0E
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
		STA $0F
        JSL $00974C                            ; hex -> dec
        PHA
        LDA tile_numbers,X
        STA !dynamic_stripe+14
        PLA
        TAX
        LDA tile_numbers,X
        STA !dynamic_stripe+16
        PLX
		JSR comp_to_gold
        JSR load_stripe_from_buffer
        PLY
        BRA .loop_display_time

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
        JMP .loop_display_time
    .draw_blank
        JSR load_blank_time
        JSR load_stripe_from_buffer
        JMP .loop_display_time

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
        BNE .testSELECT                     ; make sure Mario is facing forward
        LDA $1DF7
        BNE .testSELECT                     ; and he's not warping off star road
        LDA !cont_frame_a
        AND #$10
        BEQ .testSELECT
        LDA #$1C                            ; play sound
        STA $1DFC
        LDA #$20                            ; set game mode
        STA $0100

	.testSELECT:                                 ; SELECT = swap powerup / item box
		LDA !cont_frame_a
		AND #$20
		BEQ .save_lvl_states
		LDA $19
		AND #$FC                                  ; powerup must be 0,1,3,2
		BNE .save_lvl_states
		LDA $0DC2
		CMP #$03
		BEQ .save_lvl_states
		CMP #$04
		BNE .stupid_inc
		DEC A
	.stupid_inc:
		AND #$FC
		BNE .save_lvl_states                    ; item box must be 0,1,2,4
		JSR swap_powerup_item_box

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
		STZ !restore_timer_min               ; clear timer
		STZ !restore_timer_sec
		STZ !restore_timer_frames
        STZ !timer_flag                      ; clear timer lock
        STZ !coins_this_level                ; clear coin counter
        STZ !yoshi_flag
        STZ !orb_flag
        STZ !tick_rta_timer_flag
		STZ !restore_room_item
		STZ !recent_secondary_exit
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

swap_powerup_item_box:
		LDA $19
		CMP #$02
		BNE .not_cape_mario
		ASL A
	.not_cape_mario:
		CMP #$03
		BNE .not_fire_mario
		DEC A
	.not_fire_mario:
		STA $00

		LDA $0DC2
		CMP #$02
		BNE .not_flower
		INC A
	.not_flower:
		CMP #$04
		BNE .not_feather
		LSR A
	.not_feather:
		STA $19
		STA $0DB8

		LDA $00
		STA $0DC2
		STA $0DBC
		RTS


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

comp_to_gold:
		PHB
		PHK
		PLB
		PHX
		PHY                                 ; [$00],Y-2 = pointer to time to compare
		PHP

		REP #$30
		LDA $00
		AND #$0FFF
		TAX
		SEP #$20
		INY
		LDA [$00],Y
		AND #$20
		BNE .no_gold                          ; orb used = no gold whatsoever
		DEY
		DEY
		DEY

		LDA [$00],Y                           ; unwrapped loop because I am lazy.
		CMP GoldTimes,X
		BCC .yes_gold
		BNE .no_gold
		INY
		INX

		LDA [$00],Y
		CMP GoldTimes,X
		BCC .yes_gold
		BNE .no_gold
		INY
		INX

		LDA [$00],Y
		CMP GoldTimes,X
		BCC .yes_gold
		BRA .no_gold

	.yes_gold:
		LDA #$29
        STA !dynamic_stripe+5
        STA !dynamic_stripe+7
        STA !dynamic_stripe+9
        STA !dynamic_stripe+11
        STA !dynamic_stripe+13
        STA !dynamic_stripe+15
        STA !dynamic_stripe+17

	.no_gold:
		PLP
		PLY
		PLX
		PLB
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

translevel_types:                            ; 76543210 - display times:
        db $00,$0F,$0F,$00                   ; 0 4
        db $77,$0F,$0F,$07                   ; 1 5
        db $07,$7F,$FF,$07                   ; 2 6
        db $0F,$0F,$07,$FF                   ; 3 7
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
        db $0F,$00,$0F,$0F                    ; funky
        db $0F,$00,$0F,$0F
        db $0F,$0F,$00,$00
        db $77,$00,$77,$00
        db $EE,$77,$77,$00
        db $00

GoldTimes:
        incbin "bin_gold_times.bin"

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

	.speedometer:
		LDA !speedometer_flag
		STA !speedometer_status

	.drop_item:
		LDA !drop_item_flag
		STA !drop_item_status

	.sprite_slots:
		LDA !show_slots_flag
		STA !show_slots_status

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
        LDY #$4000                            ; number of bytes
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

        LDA #$00
        STA $2121                             ; palette at $00
        PHK
        PLA
        LDX #Palette
        LDY #$0100
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

        LDX #$0F
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
        CPX #$0C
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
        ADC #$3180
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
        dw $0000,$0002,$0004,$0006,$0008,$000A,$010A
		dw $020A,$030A,$030C,$030E,$0312,$0315,$0316
		dw $0317

graphics_position:
        dw $20CC,$210C,$214C,$218C
        dw $21CC,$220C,$224C,$228C
        dw $20D0,$2110,$2150,$2190
		dw $21D0,      $2250,$2290

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
        LDA #$0E
    .nowrap:
        STA !curr_selection
        JMP .finish_sound

    .testDOWN:
        LDA !cont_frame_a
        AND #$04
        BEQ .testLEFT
        LDA !curr_selection
        INC A
        CMP #$0F
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
        CPX #$0C
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
        CPX #$0C
        BCS .test_selection
        INC !status_table,X
        LDA #$01
        JSR check_bounds
        JMP .finish_sound

    .test_selection:
        LDA !cont_frame_a
        AND #$80                            ; B
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
        dw .j_speed
        dw .j_drop
        dw .j_slots
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
	.j_speed:
	.j_drop:
        JMP .finish_no_sound
    .j_records:
        LDA #$24
        STA $12
        LDA !erase_status
        INC A
        STA !erase_records_flag                ; #$01 = all, #$02 = this level
        LDA #$0B                            ; play sound
        STA $1DFC
	.j_slots:
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
        LDA !cont_frame_a
        AND #$10                            ; START
        BEQ .no_start_either
		JMP .j_save
	.no_start_either
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
		LDA !speedometer_status
		STA !speedometer_flag
		LDA !drop_item_status
		STA !drop_item_flag
		LDA !show_slots_status
		STA !show_slots_flag
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
    db $01,$01,$01,$01,$01,$04,$03,$04,$01,$01,$03,$02,$00,$00,$00

min_selection_extended:
    db $01,$01,$01,$01,$01,$FF,$FF,$FF,$01,$01,$03,$02,$00,$00,$00

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
        BCS .no_move
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

		SEP #$20
		LDA #$FF
		STA [$03]

        REP #$30
        LDA #$FFFF
        LDY #$0020

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
		CMP #$00                                  ; don't clear level 00 it contains important file info!
		BEQ .finish

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

        LDA #$FFFF
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
    db $50,$54,$00,$0D
    db $1C,$38,$0A,$38
    db $1F,$38,$0E,$38
    db $FC,$38,$1D,$38
    db $18,$38
    db $50,$74,$00,$0D
	db $0C,$38,$18,$38
    db $17,$38,$0F,$38
    db $12,$38,$1B,$38
    db $16,$38
    db $50,$94,$00,$13
	db $0D,$38,$0A,$38
    db $1D,$38,$0A,$38
    db $FC,$38,$0E,$38
    db $1B,$38,$0A,$38
    db $1C,$38,$0E,$38
	db $FF

new_record_message:
    db $50,$83,$00,$15
    db $17,$28,$0E,$28
    db $20,$28,$FC,$28
    db $1B,$28,$0E,$28
    db $0C,$28,$18,$28
    db $1B,$28,$0D,$28
    db $28,$28,$FF


graphics_tile_data:
        incbin "bin_tilemap_options.bin"
slots_gfx_low:
        incbin "bin_slots_low.bin"
slots_gfx_high:
        incbin "bin_slots_high.bin"

;;;;;;;;;;;;;;;;
; Precise Timer
;;;;;;;;;;;;;;;;

ORG $1B8000
level_load_penalty:
        JSL $05809E

		LDA $0109                            ; erase all records if first time playing file
		CMP #$E9
		BNE .not_intro
		JSL delete_all_records
		REP #$30
		LDA $010A
		AND #$0003
		CLC
		ROR A
		ROR A
		ROR A
		ROR A
		ROR A
		TAX
		LDA #$0000
		STA $700001,X                        ; mark file as used
		SEP #$30
		INC $0109

	.not_intro:
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
    .testLR:
        LDA $188A
        BNE .testLR_2
        LDA $1493                            ; no reset if keyhole
        ORA $1434                            ; no reset if level beaten
        ORA $9D                                ; no reset if sprites locked
        ORA $1426                            ; no reset if message block
		ORA $13D4                            ; no reset if paused
        BEQ .testLR_2
        JMP .timer

    .testLR_2:
        LDA !cont_all_b
        AND #$30                            ; L R
        CMP #$30
        BEQ .testLR_3
        JMP .timer

    .testLR_3:
		LDA !cont_all_a
		AND #$40                            ; Y
		BEQ .testLR_4
		LDA !cont_all_b
		AND #$40                            ; X
		BNE .test_next_secondary
	.testLR_4:
        LDA $141A
        CMP #$01                 ; if at the first room of level, just level reset
        BEQ .test_translevel
        LDA !cont_all_a
        AND #$80                            ; B
        BEQ .test_secondary
        LDA !cont_all_b
        AND #$80                            ; A
        BEQ .test_secondary

    .test_translevel:                       ; LEVEL RESET
        STZ !tick_rta_timer_flag
        STZ !reset_room_flag
		STZ !restore_room_item
		LDA !initial_level_time
		STA $0F31
		STZ $0F32
		STZ $0F33
        LDA $13BF
        CMP #$25
        BCC .skip_translevel
        SEC
        SBC #$24
        BRA .skip_translevel

	.test_next_secondary:                     ; ROOM ADVANCE
		LDA #$02
        STA !reset_room_flag
        INC !tick_rta_timer_flag
		LDA $141A
		CMP #$02
		BCC .base_translevel
        LDA !recent_secondary_exit
		TAX
		LDA $13BF
		CMP #$25
		BCS .base_secondary_1
		LDA.L adv_secondary0_exit_table,X
		BEQ .abort_advance_room  ; if no next sublevel, just room reset
		BRA .complete_advance
	.base_secondary_1:
		LDA.L adv_secondary1_exit_table,X
		BEQ .abort_advance_room  ; if no next sublevel, just room reset
		BRA .complete_advance
	.base_translevel:
		LDA $13BF
		TAX
		LDA.L adv_translevel_table,X
		BEQ .test_translevel    ; if level has no next room, just level reset

	.complete_advance:
		INC $141A
		BRA .skip_translevel

    .test_secondary:                          ; ROOM RESET
        INC !tick_rta_timer_flag
	.abort_advance_room:
		LDA #$01
        STA !reset_room_flag
        LDA !recent_secondary_exit
    .skip_translevel:

		STZ $188A
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

		LDA !reset_room_flag
		CMP #$02
		BEQ .wrap_up_reset

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

	.wrap_up_reset:
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

adv_secondary0_exit_table:
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$D7,$BE,$EA,$C0,$E2
		db $00,$FD,$00,$00,$C1,$BF,$00,$CE,$CE,$00,$CD,$00,$00,$C0,$D0,$B5
		db $AE,$B4,$C6,$D3,$00,$C3,$C2,$00,$00,$00,$00,$00,$00,$00,$CD,$CE
		db $BE,$AC,$D3,$D2,$B0,$00,$D5,$AB,$D9,$D8,$DC,$B6,$DB,$E4,$EB,$00
		db $DF,$DF,$00,$FD,$DD,$00,$E7,$E5,$E7,$FF,$AD,$00,$ED,$B2,$ED,$CA
		db $00,$F2,$B2,$00,$F5,$F4,$D0,$00,$F7,$EB,$F9,$00,$FB,$E3,$DE,$00
adv_secondary1_exit_table:
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$DD,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$C9,$E0,$F8,$BC,$C1,$EF,$F5
		db $C3,$C0,$E4,$BB,$BF,$C6,$F7,$CA,$CB,$FD,$BE,$B3,$AB,$C7,$FF,$B4
		db $ED,$DF,$F7,$B0,$00,$00,$B5,$00,$00,$A9,$B7,$B8,$BD,$BD,$BD,$BD
		db $CD,$D0,$D0,$D0,$D0,$00,$00,$00,$00,$DD,$00,$DD,$DD,$DB,$00,$00
		db $E1,$00,$00,$E2,$E5,$00,$00,$00,$FA,$FA,$F9,$00,$EE,$EC,$00,$00
		db $00,$00,$00,$F2,$F3,$AF,$00,$C2,$AB,$00,$E9,$EA,$F6,$B9,$EB,$00
adv_translevel_table:
        db $00,$D9,$CB,$00,$F9,$F5,$D3,$E8,$C9,$E9,$C6,$E0,$F3,$E4,$DC,$B5
		db $B4,$B3,$00,$ED,$CA,$E3,$00,$00,$F8,$00,$D4,$AF,$BD,$AD,$00,$D6
		db $CC,$FC,$F6,$AB,$CF
		db     $FC,$BA,$B9,$00,$B8,$B7,$EA,$00,$F0,$C2,$B5,$00,$D3,$C7,$B4
		db $FE,$DE,$00,$B3,$DD,$E3,$B2,$ED,$B0,$AF,$AE,$D8,$F4,$FA,$00,$AD
		db $00,$D7,$00,$AB,$00,$00,$00,$AA,$00,$00,$C4,$00,$A9,$00,$00,$00
		db $D5,$00,$00,$00,$D6,$00,$00

l_r_reset_fade:
        LDA !reset_room_flag
		BEQ .restore_level
		CMP #$01
        BEQ .restore_room
		RTL       ; advance sublevel
	.restore_level:
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
		LDA !restore_timer_min
		STA !timer_min
		LDA !restore_timer_sec
		STA !timer_sec
		LDA !restore_timer_frames
		STA !timer_frames
		LDA !restore_igt_hundreds
		STA $0F31
		LDA !restore_igt_tens
		STA $0F32
		LDA !restore_igt_ones
		STA $0F33

    .merge:
        STZ $1420                            ; clear dragon coins
        STZ $1422
        STZ $36
        STZ $37                                ; clear mode 7 rotation
        STZ $14AF                            ; on/off switch
        STZ $1432                            ; coin snake
        STZ !coins_this_level                ; coins for ci2
		LDA !restore_room_pspeed
        STA $149F                            ; clear P-speed (tsk tsk for not doing this originally)
        STZ $0DBF                            ; clear coin counter
		STZ $1B9F                            ; clear reznor floor
		STZ $14B1
		STZ $14B6                            ; clear bowser timers
		STZ $1884                            ; clear bowser HP
		STZ $1496
		STZ $1497                            ; clear Mario animation timers
		LDA #$FF
		STA $1B9D                            ; layer 3 tide timer
		LDA !restore_room_item
		BEQ .fix_dp2
		STA $9E
		LDA #$0B
		STA $14C8

;        LDX #$0C
;    .loop_yoshi:
;        DEX
;        STZ $C2,X
;        BNE .loop_yoshi

	.fix_dp2:

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
        BEQ .try_tick            ; $0DD5 = 01 when $1B95 = #$02

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

		PHB
		PHK
		PLB
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
		PLB
        JMP .display

    .try_tick:
        LDA !tick_rta_timer_flag
    ;   BNE .try_tick_room
        STZ !timer_flag
        LDA !timer_min
        CMP #$09
        BNE .tick
        LDA !timer_sec
        CMP #$3B
        BNE .tick
        LDA !timer_frames
        CMP #$3B
        BEQ .try_tick_room

    .tick:
        INC !timer_frames
        LDA !timer_frames
        CMP #$3C
        BNE .try_tick_room
        STZ !timer_frames
        INC !timer_sec
        LDA !timer_sec
        CMP #$3C
        BNE .try_tick_room
        STZ !timer_sec
        INC !timer_min

    .try_tick_room:
        LDA !room_timer_min
        CMP #$09
        BNE .tick_room
        LDA !room_timer_sec
        CMP #$3B
        BNE .tick_room
        LDA !room_timer_frames
        CMP #$3B
        BEQ .display

	.tick_room:
        LDA $71
        CMP #$05
        BEQ .in_transition
        CMP #$06
        BEQ .in_transition
        CMP #$08
        BEQ .in_transition
        CMP #$0D
        BEQ .in_transition
		STZ !restore_timer_flag
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
		BRA .display

	.in_transition:
		LDA !restore_timer_flag
		BNE .display
		LDA $88                                       ; going through pipe timer
		BNE .display
		LDA !timer_min
		STA !restore_timer_min
		LDA !timer_sec
		STA !restore_timer_sec
		LDA !timer_frames
		STA !restore_timer_frames
		LDA $0F31
		STA !restore_igt_hundreds
		LDA $0F32
		STA !restore_igt_tens
		LDA $0F33
		STA !restore_igt_ones
		INC !restore_timer_flag

    .display:
		LDA #$FC
		STA $0EFD
        LDA !tick_rta_timer_flag
        BNE .rta_timer
		LDA $13
		AND #$20
		BEQ .rta_timer
		LDA #$76
		STA $0EFD
	.rta_timer:
        LDA !timer_min
        JSL $00974C
    ;   STX $0EFD
        STA $0EFE
        LDA !timer_sec
        JSL $00974C
        STX $0F00
        STA $0F01
        LDA !timer_frames
        JSL $00974C
        STX $0F03
        STA $0F04
    .display_room:
        LDA !room_timer_min
        JSL $00974C
    ;   STX $0F18
        STA $0F19
        LDA !room_timer_sec
        JSL $00974C
        STX $0F1B
        STA $0F1C
        LDA !room_timer_frames
        JSL $00974C
        STX $0F1E
        STA $0F1F

    .display_speed:
;		LDA !speedometer_flag
;		BNE .display_input
;        LDA $7B
;        BPL .positive_speed
;        EOR #$FF
;        INC A
;    .positive_speed:
;        JSL $00974C
;        STX $0EFA
;        STA $0EFB

    .display_pmeter:
;        LDA $13E4
;		AND #$F0
;		LSR A
;		LSR A
;		LSR A
;		LSR A
 ;       STA $0F17

    .display_takeoff:

			LDA $148F
			BEQ .out_takeoff

			LDX #$0B
		.loop_takeoff:
			LDA $14C8,X
			CMP #$0B
			BEQ .store_held
			DEX
			BPL .loop_takeoff
			BRA .out_takeoff

		.store_held:
			STX !slot_held

		.out_takeoff:
			LDX !slot_held
			LDA $14F8,X
			LSR A
			LSR A
			LSR A
			LSR A
			STA $0EFA
			LDA $14F8,X
			AND #$0F
			STA $0EFB

			LDA $14EC,X
			LSR A
			LSR A
			LSR A
			LSR A
			STA $0F15
			LDA $14EC,X
			AND #$0F
			STA $0F16

			BRA .display_input
		;LDA $19
		;CMP #$02
		;BNE .clear_takeoff
        ;LDA $149F
        ;JSL $00974C
        ;STX $0F15
        ;STA $0F16
		;JMP .display_input
	.clear_takeoff:
		;LDA #$FC
		;STA $0F15
		;STA $0F16

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
        db $29,$06,$2E,$0F,$41,$22,$36,$3A

input_locs_1:
        db $2D,$2F,$14,$13,$10,$11,$0F,$12
input_locs_2:
        db $2C,$2E,$2A,$2B
input_tiles_1:
        db $0B,$22,$44,$1C,$41,$42,$40,$43
input_tiles_2:
        db $0A,$21,$15,$1B

try_save_value:
		LDA !tick_rta_timer_flag
		BEQ .not_spliced
		RTS
	.not_spliced:
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

    .save_attributes:                            ; sho-ygrb, ygrb = ! blocks, s = special, h = yoshi, o = orb
        LDA $1F28                                ;
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
		LDA $0DD5
		CMP #$80
		BEQ .no_yoshi_level
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

HexToDec16:
		LDX #$00
	.loop:
		CMP #$000A
		BCC .done
		SBC #$000A
		INX
		BRA .loop
	.done:
		RTL

took_secondary_exit:
		PHP
		PHX
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
        LDA $149F
        STA !restore_room_pspeed

		SEP #$20
		LDX #$0B
	.loop_sprites:
		LDA $14C8,X
		CMP #$0B
		BEQ .restore_item
		DEX
		BPL .loop_sprites
		BRA .restore_done
	.restore_item:
		LDA $9E,X
		STA !restore_room_item
	.restore_done:
		PLX
		PLP
        RTL

drop_item_box:
		PHB
		PHK
		PLB
		PHX

		LDA $16
		AND #$20
		BEQ .no_select
		LDA !drop_item_flag
        TAX
		LDA $15
		AND button_masks,X
		EOR button_masks,X
		BRA .yes_select

	.no_select:
		INC A
	.yes_select:
		PLX
		PLB
		RTL

button_masks:
		db $20,$28,$24,$60

display_bowser_timers:
		LDA $0D9B
		CMP #$C1                         ; in Bowser fight
		BEQ .begin
		RTL

	.begin:
		PHB
		PHK
		PLB
		PHY
		LDA #$69
		STA $02C2
        LDA !tick_rta_timer_flag
        BNE .rta_timer
		LDA $13
		AND #$20
		BEQ .rta_timer
		LDA #$8E
		STA $02C2
	.rta_timer:
        LDA !timer_min
        JSL $00974C
		JSR dec_to_bowser
        STA $02C6
        LDA !timer_sec
        JSL $00974C
		JSR dec_to_bowser
        STX $02CE
        STA $02D2
        LDA !timer_frames
        JSL $00974C
		JSR dec_to_bowser
        STX $02DA
        STA $02DE
		LDA #$9D
		STA $02CA
		LDA #$9E
		STA $02D6

		LDY #$08
	.rta_loop:
		DEY
		BMI .display_room
		TYX
		STZ $0450,X
		LDA timer_x,X
		PHA
		TYA
		ASL A
		ASL A
		TAX
		PLA
		STA $02C0,X
		LDA #$10
		STA $02C1,X
		LDA #$30
		STA $02C3,X
		BRA .rta_loop

    .display_room:
        LDA !room_timer_min
        JSL $00974C
		JSR dec_to_bowser
        STA $03A2
        LDA !room_timer_sec
        JSL $00974C
		JSR dec_to_bowser
        STX $03AA
        STA $03AE
        LDA !room_timer_frames
        JSL $00974C
		JSR dec_to_bowser
        STX $03B6
        STA $03BA
		LDA #$9D
		STA $03A6
		LDA #$9E
		STA $03B2

		LDY #$07
	.room_loop:
		DEY
		BMI .done
		TYX
		STZ $0488,X
		INX
		LDA timer_x,X
		DEX
		PHA
		TYA
		ASL A
		ASL A
		TAX
		PLA
		STA $03A0,X
		LDA #$18
		STA $03A1,X
		LDA #$32
		STA $03A3,X
		BRA .room_loop

	.done:
		PLY
		PLB
		RTL

timer_x:
	db $30,$38,$40,$48,$50,$58,$60,$68

dec_to_bowser:                               ; X = tens, A = ones
		PHX
		TAX
		LDA bowser_numbers,X
		PLX
		PHA
		LDA bowser_numbers,X
		TAX
		PLA
		RTS

bowser_numbers:
	db $88,$89,$8A,$8B,$8C
	db $98,$99,$9A,$9B,$9C

check_score_sprites:
		LDA !show_slots_flag
		CMP #$00
		PHP
		BNE .done
		LDA $16E7,X
		SEC
		SBC $02
		STA $0201,Y
		STA $0205,Y
	.done:
		PLP
		RTL

slot_sprite_nums:
	db $44,$45,$46,$47,$48,$49
	db $54,$55,$56,$57,$58,$59

draw_slot_sprite:
		PHB
		PHK
		PLB
		PHY

		LDA !show_slots_flag
		BEQ .done
		TXA
		ASL A
		ASL A
		TAY
		LDA $14C8,X
		BNE .not_dead
		LDA !show_slots_flag
		CMP #$01
		BEQ .erase_tile
	.not_dead:
		JSR get_screen_y
		XBA
		CMP #$00
		BNE .erase_tile
		XBA
		STA $02B1,Y
		JSR get_screen_x
		XBA
		CMP #$00
		BNE .erase_tile
		XBA
		STA $02B0,Y
		LDA slot_sprite_nums,X
		STA $02B2,Y
		LDA #$38
		STA $02B3,Y
		STZ $044C,X
		BRA .done
	.erase_tile:
		LDA #$F0
		STA $02B1,Y
	.done:

		PLY
		PLB
		RTL

get_screen_x:
		LDA $E4,X
		XBA
		LDA $14E0,X
		XBA
		REP #$20
		SEC
		SBC $1A
		SEP #$20
		RTS

get_screen_y:
		LDA $D8,X
		XBA
		LDA $14D4,X
		XBA
		REP #$20
		SEC
		SBC $1C
		SEP #$20
		RTS

load_slots_gfx:                             ; requires v/f-blank
		LDA !show_slots_flag
		BEQ .done
		LDA !slot_gfx_loaded
		BNE .done

		REP #$10

		LDA #$80
		STA $2100

		LDX #$6440
		STX $2116
		LDY #$00C0
		LDA #$1A
		LDX #slots_gfx_low
		JSL LoadVRAM

		LDX #$6540
		STX $2116
		LDY #$00C0
		LDA #$1A
		LDX #slots_gfx_high
		JSL LoadVRAM

		SEP #$10
	.done:
		RTL

print "Bytes inserted: ", bytes
