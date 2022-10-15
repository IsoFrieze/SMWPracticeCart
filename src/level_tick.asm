ORG !_F+$158000

reset bytes

; this code is run on every frame during fades to and from the level game mode (game modes #$0F & #$13)
temp_fade_tick:
        PHP
        PHB
        PHK
        PLB
        
        JSR fade_and_in_level_common
        STZ !dropped_frames
        STZ !dropped_frames+1
        
        PLB
        PLP
        
        DEC $0DB1
        RTL

; this code is run on every frame during the level game mode (after fade in completes) (game mode #$14)
level_tick:
        PHP
        PHB
        PHK
        PLB
        
        ; this makes sure we aren't on the title screen
        LDA $0100
        CMP #$14
        BNE .done
        
        JSR setup_layer3_bg
        JSR prepare_input
        JSR record_input
        JSR emulate_score_lag
        
        JSR fade_and_in_level_common
        
        LDA $13D4 ; pause flag
        BNE +
        PEA !pause_timer_minutes
        JSR tick_timer
      + PEA !level_timer_minutes
        JSR tick_timer
        PEA !room_timer_minutes
        JSR tick_timer
        JSR test_ci2
        JSR test_reset
        JSR test_run_type
        JSR test_translevel_0_failsafe
        JSR wait_slowdown
        
    .done:
        PLB
        PLP
        RTL

; these routines are called on both level tick and level fade tick
fade_and_in_level_common:
        JSR display_meters
        JSR test_savestate
        JSR test_slowdown
        RTS

; emulate score lag by iterating through a useless loop
emulate_score_lag:
        PHP
        LDA.L !status_scorelag
        BEQ .done
        
        ; calibrate linear
        DEC A
        TAX
    -   DEX
        BMI +
if !_F == $800000
        LDY #$0C
else
        LDY #$03
endif
    --  DEY
        BNE --
        BRA -
        
if !_F == $800000
        ; calibrate dc
    +   LDX #$2F
    -   DEX
        BMI .done
        LDY #$10
    --  DEY
        BNE --
        BRA -
endif
    
    .done:
        PLP
        RTS

; sad wrapper is sad
display_meters_wrapper:
        PHB
        PHK
        PLB
        JSR display_meters
        PLB
        RTL

; display all the selected statusbar meters
display_meters:
        PHP
        SEP #$30
        
        LDA #$7E
        STA $02
        LDA #$1F
        STA $01
        
        LDY #$5C
        
      - LDA [!statusbar_layout_ptr],Y
        BEQ ++
        CMP #$14
        BCS ++
        INY #3
        LDA [!statusbar_layout_ptr],Y
        DEY #3
        CLC
        ADC.B #!status_bar
        STA $00
        
        LDA [!statusbar_layout_ptr],Y
        ASL A
        TAX
        INY
        LDA.L $0100 ; game mode
        CMP #$14 ; level
        BEQ +
        LDA.L $0DB0 ; mosaic
        CMP #$F0
        BEQ +
        JSR (.meter_fade,X)
        DEY
        BRA ++
      + JSR (.meter_level,X)
        DEY
     ++ DEY #4
        BPL -
        
        PLP
    .nothing:
        RTS
    
    .meter_level:
        dw .nothing
        dw meter_item_box
        dw meter_mario_speed
        dw meter_mario_takeoff
        dw meter_mario_pmeter
        dw meter_yoshi_subpixel
        dw meter_held_subpixel
        dw meter_lag_frames
        dw meter_timer_level
        dw meter_timer_room
        dw meter_timer_stopwatch
        dw meter_coin_count
        dw meter_in_game_time
        dw meter_slowdown
        dw meter_input_display
        dw meter_name
        dw meter_movie_recording
        dw meter_memory_7e
        dw meter_memory_7f
        dw meter_rng
    
    .meter_fade:
        dw .nothing
        dw .nothing
        dw .nothing
        dw .nothing
        dw .nothing
        dw .nothing
        dw .nothing
        dw .nothing
        dw .nothing
        dw .nothing
        dw .nothing
        dw .nothing
        dw .nothing
        dw .nothing
        dw meter_input_display
        dw .nothing
        dw .nothing
        dw meter_memory_7e
        dw meter_memory_7f
        dw meter_rng

; draw the item box meter (fixed position)
meter_item_box:
        LDA #$3A
        STA !status_bar+$2E
        STA !status_bar+$31
        STA !status_bar+$8E
        STA !status_bar+$91
        LDA #$3B
        STA !status_bar+$2F
        STA !status_bar+$30
        STA !status_bar+$8F
        STA !status_bar+$90
        LDA #$4A
        STA !status_bar+$4E
        STA !status_bar+$51
        STA !status_bar+$6E
        STA !status_bar+$71
        RTS

; draw the mario speed meter
meter_mario_speed:
        LDA $7B ; mario speed
        BPL +
        EOR #$FF
        INC A
      + JSL !_F+$00974C ; hex2dec
        PHA
        TXA
        STA [$00]
        INC $00
        PLA
        STA [$00]
        
        RTS

; draw the mario takeoff meter
meter_mario_takeoff:
        LDA $149F ; takeoff meter
        JSL !_F+$00974C ; hex2dec
        PHA
        TXA
        STA [$00]
        INC $00
        PLA
        STA [$00]
        
        RTS

; draw the mario p meter
meter_mario_pmeter:
        LDA [!statusbar_layout_ptr],Y
        ASL A
        TAX
        JMP (.pmeter_type,X)
        
    .pmeter_type:
        dw .Px
        dw .xx
        
    .Px:
        LDA #$19
        STA [$00]
        INC $00
        LDA $13E4 ; p meter
        LSR #4
        STA [$00]
        RTS
        
    .xx:
        LDA $13E4 ; p meter
        PHA
        LSR #4
        STA [$00]
        INC $00
        PLA
        AND #$0F
        STA [$00]
        RTS

; draw the yoshi subpixel meter
meter_yoshi_subpixel:
        LDA $18DF ; yoshi slot
        BNE +
        JMP .erase
      + LDA [!statusbar_layout_ptr],Y
        ASL A
        TAX
        JMP (.yoshi_subpixel_type,X)
        
    .yoshi_subpixel_type:
        dw .XY
        dw .Xx
        dw .Yy
        
    .XY:
        LDA $18DF ; yoshi slot
        DEC A
        TAX
        LDA $14F8,X ; sprite x subpixel
        LSR #4
        STA [$00]
        INC $00
        LDA $14EC,X ; sprite y subpixel
        LSR #4
        STA [$00]
        RTS
        
    .Xx:
        LDA $18DF ; yoshi slot
        DEC A
        TAX
        LDA $14F8,X ; sprite x subpixel
        JMP +
        
    .Yy:
        LDA $18DF ; yoshi slot
        DEC A
        TAX
        LDA $14EC,X ; sprite y subpixel
      + PHA
        LSR #4
        STA [$00]
        INC $00
        PLA
        AND #$0F
        STA [$00]
        RTS
    
    .erase:
        LDA #$FC
        STA [$00]
        INC $00
        STA [$00]
        RTS

; draw the held item subpixel meter
meter_held_subpixel:
        LDA !held_item_slot
        BMI +
        ; check if item has despawned, and if so, erase the meter
        TAX
        LDA $14C8,X ; sprite status
        CMP #$07
        BCS +
        LDA #$FF
        STA !held_item_slot
        
      + LDA $148F ; held item flag
        BEQ .done_check_hold
        
        LDX #$0B
      - LDA $14C8,X ; sprite status
        CMP #$0B
        BEQ +
        DEX
        BPL -
        BRA .done_check_hold
      + TXA
        STA !held_item_slot
        
    .done_check_hold:
        LDA !held_item_slot
        BPL +
        JMP .erase
    
      + LDA [!statusbar_layout_ptr],Y
        ASL A
        TAX
        JMP (.held_subpixel_type,X)
        
    .held_subpixel_type:
        dw .XY
        dw .Xx
        dw .Yy
        
    .XY:
        LDA !held_item_slot
        TAX
        LDA $14F8,X ; sprite x subpixel
        LSR #4
        STA [$00]
        INC $00
        LDA $14EC,X ; sprite y subpixel
        LSR #4
        STA [$00]
        RTS
        
    .Xx:
        LDA !held_item_slot
        TAX
        LDA $14F8,X ; sprite x subpixel
        JMP +
        
    .Yy:
        LDA !held_item_slot
        TAX
        LDA $14EC,X ; sprite y subpixel
      + PHA
        LSR #4
        STA [$00]
        INC $00
        PLA
        AND #$0F
        STA [$00]
        RTS
    
    .erase:
        LDA #$FC
        STA [$00]
        INC $00
        STA [$00]
        RTS

; draw the lag frame counter meter
meter_lag_frames:
        LDA $00
        PHA
        
        LDA !dropped_frames+1
        PHA
        LSR #4
        STA [$00]
        INC $00
        PLA
        AND #$0F
        STA [$00]
        INC $00
        LDA !dropped_frames
        PHA
        LSR #4
        STA [$00]
        INC $00
        PLA
        AND #$0F
        STA [$00]
        INC $00
        LDA #$D7
        STA [$00]
        
        PLA
        STA $00
        
        LDX #$00 ; replace 0's with spaces cause it looks better for a 4 digit number
      - LDA [$00]
        BNE +
        LDA #$FC
        STA [$00]
        INC $00
        INX
        CPX #$03
        BNE -
        
      + RTS

; draw the level timer meter
meter_timer_level:
        LDA !spliced_run
        BNE +
        LDA $13 ; true frame
        AND #%00100000
        BEQ +
        LDA #$76
        BRA ++
      + LDA #$FC
     ++ STA [$00]
        INC $00
        
        LDA #$7E
        STA $05
        LDA #$0F
        STA $04
        LDA #$3C ; !level_timer_frames
        STA $03
        JSR meter_timer_all
        RTS

; draw the room timer meter
meter_timer_room:
        LDA #$7E
        STA $05
        LDA #$0F
        STA $04
        LDA #$44 ; !room_timer_frames
        STA $03
        JSR meter_timer_all
        RTS

; draw the stopwatch meter
meter_timer_stopwatch:
        LDA #$7E
        STA $05
        LDA #$0F
        STA $04
        LDA #$47 ; !pause_timer_frames
        STA $03
        JSR meter_timer_all
        RTS

; draw a generic timer, where timer frame address is in $03
meter_timer_all:
        LDA [!statusbar_layout_ptr],Y
        ASL A
        TAX
        JMP (.timer_type,X)
        
    .timer_type:
        dw .sec_decimal
        dw .sec_frame
        dw .framecount
        
    .sec_decimal:
        LDA $00
        CLC
        ADC #$06
        STA $00
        LDA [$03]
        DEC $03
        TAX
        PHX
        LDA.L !status_region
        CMP #$02
        BCS .pal
        LDA.L fractional_seconds,X
        BRA +
    .pal:
        LDA.L fractional_seconds_pal,X
      + PLX
        JSL !_F+$00974C ; hex2dec
        STA [$00]
        DEC $00
        TXA
        STA [$00]
        DEC $00
        LDA #$24
        BRA +
    
    .sec_frame:
        LDA $00
        CLC
        ADC #$06
        STA $00
        LDA [$03]
        DEC $03
        JSL !_F+$00974C ; hex2dec
        STA [$00]
        DEC $00
        TXA
        STA [$00]
        DEC $00
        LDA #$86
      + STA [$00]
        DEC $00
        
        LDA [$03]
        DEC $03
        JSL !_F+$00974C ; hex2dec
        STA [$00]
        DEC $00
        TXA
        STA [$00]
        DEC $00
        LDA #$85
        STA [$00]
        DEC $00
        
        LDA [$03]
        STA [$00]
        
        RTS
    
    .framecount:
        INC $00
        INC $00
        INC $00
        INC $00
        LDA #$D7
        STA [$00]
        DEC $00
        
        LDA [$03] ; frames
        DEC $03
        STA $06
        STZ $07
        LDA.L !status_region
        TAX
        LDA.L frames_in_a_second,X
        STA $4202 ; mult A
        LDA [$03] ; seconds
        DEC $03
        STA $4203 ; mult B
        REP #$20
        LDA [$03]
        TAY
        LDA.L !status_region
        ASL A
        TAX
        LDA #$0000
        CPY #$00
      - BEQ +
        CLC
        ADC frames_in_a_minute,X
        DEY
        BRA -
      + CLC
        ADC $4216 ; mult result
        CLC
        ADC $06
        SEP #$20
        PHA
        AND #$0F
        STA [$00]
        DEC $00
        PLA
        LSR #4
        STA [$00]
        DEC $00
        XBA
        PHA
        AND #$0F
        STA [$00]
        DEC $00
        PLA
        LSR #4
        STA [$00]
        
        RTS
        
frames_in_a_second:
        db $3C,$3C,$32,$32
frames_in_a_minute:
        dw $0E10,$0E10,$0BB8,$0BB8

; table to convert frames into hundredths of seconds
fractional_seconds:
        db $00,$01,$03,$05,$07,$08,$0A,$0B,$0D,$0F,$11,$12
        db $14,$15,$17,$19,$1B,$1C,$1E,$1F,$21,$23,$25,$26
        db $28,$29,$2B,$2D,$2F,$30,$32,$33,$35,$37,$39,$3A
        db $3C,$3D,$3F,$41,$43,$44,$46,$47,$49,$4B,$4D,$4E
        db $50,$51,$53,$55,$57,$58,$5A,$5B,$5D,$5F,$61,$62
fractional_seconds_pal:
        db $00,$02,$04,$06,$08,$0A,$0C,$0E,$10,$12
        db $14,$16,$18,$1A,$1C,$1E,$20,$22,$24,$26
        db $28,$2A,$2C,$2E,$30,$32,$34,$36,$38,$3A
        db $3C,$3E,$40,$42,$44,$46,$48,$4A,$4C,$4E
        db $50,$52,$54,$56,$58,$5A,$5C,$5E,$60,$62

; display the coin count meter
meter_coin_count:
        LDA #$2E
        STA [$00]
        INC $00
        
        LDA [!statusbar_layout_ptr],Y
        ASL A
        TAX
        JMP (.coin_types,X)
        
    .coin_types:
        dw .normal
        dw .dragon
        
    .normal:
        LDA $0DBF ; coins
        JSL !_F+$00974C ; hex2dec
        PHA
        TXA
        BNE +
        LDA #$FC
      + STA [$00]
        INC $00
        PLA
        STA [$00]
        RTS
        
    .dragon:
        LDA $1420 ; dragon coins
        STA [$00]
        RTS

; draw the in game timer meter
meter_in_game_time:
        LDA $0F31 ; hundreds
        STA $03
        LDA $0F32 ; tens
        STA $04
        LDA $0F33 ; ones
        STA $05
        LDA $0F30 ; frames
        STA $06
        
        LDA $1493 ; end level timer
        ORA $9D ; sprite lock
        BNE .no_latency
        
        ; subtract one frame because this used to be done before the status bar was uploaded to VRAM!
        DEC $06
        BPL +
        LDA.L !status_region
        TAX
        LDA.L frames_in_igt_second,X
        STA $06
        DEC $05
        BPL +
        LDA #$09
        STA $05
        DEC $04
        BPL +
        LDA #$09
        STA $04
        DEC $03
        BPL +
        STZ $03
        
    .no_latency:
      + LDA $03 ; hundreds
        STA [$00]
        INC $00
        LDA $04 ; tens
        STA [$00]
        INC $00
        LDA $05 ; ones
        STA [$00]
        INC $00
        
        LDA [!statusbar_layout_ptr],Y
        ASL A
        TAX
        JMP (.igt_types,X)
        
    .igt_types:
        dw .nothing
        dw .decimal
        dw .symbolic
        
    .decimal:
        LDA $06 ; igt fraction
        JSL !_F+$00974C ; hex2dec
        PHA
        TXA
        STA [$00]
        INC $00
        PLA
        STA [$00]
        RTS
        
    .symbolic:
        LDA $06 ; igt fraction
        CMP #$26
        BCC +
        CLC
        ADC #$50
      + STA [$00]
        
    .nothing:
        RTS

; draw the slowdown meter
meter_slowdown:
        LDA !slowdown_speed
        BNE +
        LDA #$FB
      + INC A
        STA [$00]
        RTS

; draw the input display
meter_input_display:
        PHP
        REP #$20
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        STA $03
        ASL A
        CLC
        ADC $03
        ASL #2
        CLC
        ADC #layout_locations
        STA $03
        SEP #$20
        PHK
        PLA
        STA $05
        PHY
        PHB
        PHK
        PLB
        JSR input_display_type
        PLB
        PLY
        PLP
        RTS
    
input_display_type:
        LDA !util_axlr_hold
        LDX #$04
        LDY #$08
        JSR .button
        LDA !util_byetudlr_hold
        LDX #$08
        LDY #$00
        
    .button:
        DEX
        BMI .exit
        ASL A
        PHA
        LDA $00
        PHA
        PHP
        LDA [$03],Y
        CLC
        ADC $00
        STA $00
        LDA no_button_tile
        PLP
        BCC +
        LDA layout_tiles,Y
      + INY
        STA [$00]
        PLA
        STA $00
        PLA
        BRA .button
        
    .exit:
        RTS

layout_tiles: ; byetudlraxlr
        db $0B,$22,$44,$1C,$41,$42,$40,$43,$0A,$21,$15,$1B
no_button_tile:
        db $27
layout_locations:
        db $46,$25,$43,$44,$01,$41,$20,$22,$27,$06,$03,$04 ; standard
        db $24,$04,$22,$23,$00,$20,$01,$21,$25,$05,$02,$03 ; compact horizontal 1
        db $25,$24,$02,$03,$21,$22,$20,$23,$05,$04,$00,$01 ; compact horizontal 2
        db $61,$41,$60,$40,$01,$21,$20,$22,$62,$42,$00,$02 ; compact vertical 1
        db $61,$41,$60,$40,$02,$62,$22,$42,$21,$01,$00,$20 ; compact vertical 2

; display the name meter
meter_name:
        LDA !in_playback_mode
        BNE +
        
        LDA.L !status_playername
        STA [$00]
        INC $00
        LDA.L !status_playername+1
        STA [$00]
        INC $00
        LDA.L !status_playername+2
        STA [$00]
        INC $00
        LDA.L !status_playername+3
        STA [$00]
        RTS
    
      + LDA.L !movie_location+7
        STA [$00]
        INC $00
        LDA.L !movie_location+8
        STA [$00]
        INC $00
        LDA.L !movie_location+9
        STA [$00]
        INC $00
        LDA.L !movie_location+10
        STA [$00]
        RTS

; display the movie recording meter
meter_movie_recording:
        LDA [!statusbar_layout_ptr],Y
        ASL A
        TAX
        JMP (.recording_types,X)
        
    .recording_types:
        dw .bar
        dw .hex
        
    .bar:
        PHB
        PHK
        PLB
        LDA !in_record_mode
        BEQ .erase
        
        LDA.L !movie_location+1
		CMP #$FF
		BEQ .erase
        CMP #$07
        BNE +
        LDA $13 ; true frame
        ASL #4
        BCS .erase
        
      + LDX #$00
      - TXA
        CMP.L !movie_location+1
        PHP
        LDA #$CE
        PLP
        BCS +
        INC #2
      + CPX #$00
        BEQ +
        CPX #$06
        BEQ +
        INC A
      + STA [$00]
        INC $00    
        INX
        CPX #$07
        BCC -
        
        PLB
        RTS
    
    .erase:
        LDA #$FC
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        INC $00
      - STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        PLB
        RTS
    
    .hex:
        PHB
        PHK
        PLB
        LDA !in_record_mode
        PHP
        LDA #$FC
        PLP
        BEQ -
        PHP
        REP #$20
        LDA #$07C0
        SEC
        SBC.L !movie_location
        SEP #$20
        XBA
        AND #$0F
        STA [$00]
        INC $00
        XBA
        PHA
        LSR #4
        STA [$00]
        INC $00
        PLA
        AND #$0F
        STA [$00]
        INC $00
        LDA #$D7
        STA [$00]
        PLP
        PLB
        RTS

; draw the bank 7E memory viewer meter
meter_memory_7e:
        LDA #$7E
        STA $05
        JSR meter_memory_all
        RTS
        
; draw the bank 7F memory viewer meter
meter_memory_7f:
        LDA #$7F
        STA $05
        JSR meter_memory_all
        RTS

; draw a generic memory viewer where the bank is in $05
meter_memory_all:
        INY
        LDA [!statusbar_layout_ptr],Y
        DEY
        STA $04
        LDA [!statusbar_layout_ptr],Y
        STA $03
        LDA [$03]
        PHA
        LSR #4
        STA [$00]
        INC $00
        PLA
        AND #$0F
        STA [$00]
        RTS

; draw the random number generator
meter_rng:
        LDA [!statusbar_layout_ptr],Y
        ASL A
        TAX
        JMP (.rng_type,X)
        
    .rng_type
        dw .index
        dw .value
        dw .seed
        
    .index
        LDA $00
        PHA
        
        LDA !rng_index+2
        AND #$0F
        STA [$00]
        INC $00
        LDA !rng_index+1
        PHA
        LSR #4
        STA [$00]
        INC $00
        PLA
        AND #$0F
        STA [$00]
        INC $00
        LDA !rng_index
        PHA
        LSR #4
        STA [$00]
        INC $00
        PLA
        AND #$0F
        STA [$00]
        
        PLA
        STA $00
        
        LDX #$00 ; replace 0's with spaces cause it looks better for a 5 digit number
      - LDA [$00]
        BNE +
        LDA #$FC
        STA [$00]
        INC $00
        INX
        CPX #$04
        BNE -
        
      + RTS
        
    .seed
        LDA $148B
        PHA
        LSR #4
        STA [$00]
        INC $00
        PLA
        AND #$0F
        STA [$00]
        INC $00
        LDA $148C
        PHA
        LSR #4
        STA [$00]
        INC $00
        PLA
        AND #$0F
        STA [$00]
        RTS
    .value
        LDA $148D
        PHA
        LSR #4
        STA [$00]
        INC $00
        PLA
        AND #$0F
        STA [$00]
        INC $00
        LDA $148E
        PHA
        LSR #4
        STA [$00]
        INC $00
        PLA
        AND #$0F
        STA [$00]
        RTS
        
; slow down the game depending on how large the slowdown number is
wait_slowdown:
        LDA.W !slowdown_speed
        BEQ .done
        INC A
        TAX
      - DEX
        BEQ +
        WAI ; wait for NMI
        WAI ; wait for IRQ
        BRA -
        
      + LDA #$01
        STA.L !spliced_run
        
    .done:
        RTS

; draw the current dymeter to where it belongs on the screen
display_dynmeter:
        PHB
        PHK
        PLB
        LDA $0100 ; game mode
        CMP #$0B
        BCS .begin
        BRL .done
    
    .begin:    
        STZ $08
        STZ $09
        STZ $0A
        STZ $0B
        LDA.L !status_dynmeter
        ASL A
        TAX
        JMP (.dynmeter_types,X)
        
    .dynmeter_types:
        dw .done
        dw .mario_speed
        dw .mario_takeoff
        dw .mario_pmeter
        dw .mario_subpixel
        dw .yoshi_subpixel
        dw .item_subpixel
        dw .item_speed
        
    .mario_speed:
        LDA $7B ; speed
        BPL +
        EOR #$FF
        INC A
        INC $08
        INC $09
      + JSL !_F+$00974C ; hex2dec
        STX $00 ; tens
        STA $01 ; ones
        LDA #$FF
        STA $02
        STA $03
        JMP .attach_to_mario
        
    .mario_takeoff:
        LDA $149F ; takeoff meter
        JSL !_F+$00974C ; hex2dec
        STX $00 ; tens
        STA $01 ; ones
        LDA #$FF
        STA $02
        STA $03
        JMP .attach_to_mario
        
    .mario_pmeter:
        LDA $13E4 ; pmeter
        AND #$0F
        STA $01 ; ones
        LDA $13E4 ; pmeter
        AND #$F0
        LSR #4
        STA $00 ; 16s
        LDA #$FF
        STA $02
        STA $03
        JMP .attach_to_mario
        
    .mario_subpixel:
        LDA $7A ; mario x subpixel
        LSR #4
        STA $00
        STZ $01
        LDA $7C ; mario y subpixel (?)
        LSR #4
        STA $02
        STZ $03
        JMP .attach_to_mario
        
    .yoshi_subpixel:
        LDA $18DF ; yoshi slot
        BNE +
        BRL .done
      + DEC A
        TAX
        LDA $14F8,X ; sprite x subpixel
        LSR #4
        STA $00
        STZ $01
        LDA $14EC,X ; sprite y subpixel
        LSR #4
        STA $02
        STZ $03
        JMP .attach_to_sprite
        
    .item_subpixel:
        LDA.W !held_item_slot
        BPL +
        BRL .done
      + TAX
        LDA $14F8,X ; sprite x subpixel
        LSR #4
        STA $00
        STZ $01
        LDA $14EC,X ; sprite y subpixel
        LSR #4
        STA $02
        STZ $03
        JMP .attach_to_sprite
        
    .item_speed:
        LDA.W !held_item_slot
        BPL +
        BRL .done
      + TAX
        LDA $B6,X ; sprite x speed
        BPL +
        EOR #$FF
        INC A
        INC $08
        INC $09
      + JSL !_F+$00974C ; hex2dec
        STX $00 ; tens
        STA $01 ; ones
        LDX.W !held_item_slot
        LDA $AA,X ; sprite y speed
        BPL +
        EOR #$FF
        INC A
        INC $0A
        INC $0B
      + JSL !_F+$00974C ; hex2dec
        STX $02 ; tens
        STA $03 ; ones
        LDX.W !held_item_slot
        JMP .attach_to_sprite
    
    .attach_to_mario:
        REP #$20
        LDA $D1
        STA $04
        LDA $D3
        SEC
        SBC #$0008
        STA $06
        JMP .merge
    
    .attach_to_sprite:
        LDA $E4,X ; sprite x pos low
        STA $04
        LDA $14E0,X ; sprite x pos high
        STA $05
        LDA $D8,X ; sprite y pos low
        STA $06
        LDA $14D4,X ; sprite y pos high
        STA $07
        REP #$20
        LDA $06
        CLC
        ADC #$0012
        STA $06
        JMP .merge
        
    .merge:
        REP #$20
        LDA $04
        SEC
        SBC $1A ; layer 1 x pos
        STA $04
        LDA $06
        SEC
        SBC $1C ; layer 1 y pos
        STA $06
        
        LDA $04
        BMI .done
        CMP #$0F8
        BCS .done
        LDA $06
        BMI .done
        CMP #$00F0
        BCS .done
        
        SEP #$20
        LDY #$03
        LDX #$0C
      - LDA $0000,Y
        CMP #$10
        BCS +
        PHX
        TAX
        LDA sprite_numbers,X
        PLX
        STA $0232,X ; oam tile
        LDA #$32
        CLC
        ADC $0008,Y
        ADC $0008,Y
        STA $0233,X ; oam properties
        LDA $04
        CLC
        ADC tile_x_offsets,Y
        STA $0230,X ; oam x pos
        LDA $06
        CLC
        ADC tile_y_offsets,Y
        STA $0231,X ; oam y pos
        PHX
        TYX
        STZ $042C,X ; oam size
        PLX
      + DEX #4
        DEY
        BPL -    
        
    .done:
        SEP #$20
        PLB
        JSR display_replay_star
        LDA $18DF
        STA $18E2
        RTL

tile_x_offsets:
        db $00,$08,$00,$08
tile_y_offsets:
        db $00,$00,$08,$08
        
; display a bounce sprite's slot number on it on the screen
display_bounce_slot:
        PHB
        PHK
        PLB
        LDA.L !status_slots
        CMP #$04
        BNE .done
        LDA $0100
        CMP #$0B
        BCC .done
        
        TXA
        ASL #2
        TAY
        
        LDA $1699,X
        CMP #$07
        BNE .erase_tile
        
        LDA $16A1,X ; bounce sprite y position, low byte
        XBA
        LDA $16A9,X ; bounce sprite y position, high byte
        XBA
        REP #$20
        SEC
        SBC $1C ; layer 1 y position
        SEP #$20
        
        XBA
        CMP #$00
        BNE .erase_tile
        XBA
        STA $02B1,Y ; oam y position
        
        LDA $16A5,X ; bounce sprite x position, low byte
        XBA
        LDA $16AD,X ; bounce sprite x position, high byte
        XBA
        REP #$20
        SEC
        SBC $1A ; layer 1 x position
        SEP #$20
        
        XBA
        CMP #$00
        BNE .erase_tile
        XBA
        INC #2
        STA $02B0,Y ; oam x position
        LDA sprite_numbers,X
        STA $02B2,Y ; oam tile
        TXA
        INC A
        AND #$03
        CMP $18CD
        BNE ++
        LDA #$38
        BRA +
     ++ LDA #$32
      + STA $02B3,Y ; oam properties
        STZ $044C,X ; oam size
        BRA .done
    .erase_tile:
        LDA #$F0
        STA $02B1,Y ; oam y position
        
    .done:
        PLB
        RTL
        
; display a sprite's slot number next to it on the screen
; X = slot number
display_slot:
        PHB
        PHK
        PLB
        LDA.L !status_slots
        BNE +
        JMP .done
      + CMP #$04 ; this is for bounce sprites
        BNE +
        JMP .done
        ; don't display slots on title screen
      + LDA $0100
        CMP #$0B
        BCS +
        JMP .done
        
      + TXA
        ASL A
        ASL A
        TAY
        LDA $14C8,X ; sprite status
        BNE +
        LDA.L !status_slots
        CMP #$03
        BCC .erase_tile
      + LDA #$38
        STA $00
        
        LDA $D8,X ; sprite y position, low byte
        XBA
        LDA $14D4,X ; sprite y position, high byte
        XBA
        REP #$20
        SEC
        SBC $1C ; layer 1 y position
        BMI .above
        CMP #$00D8
        BCC .vert_good
    .below:
        SEP #$20
        LDA.L !status_slots
        CMP #$01
        BEQ .erase_tile
        LDA #$34
        STA $00
        LDA #$D8
        BRA .vert_good
    .above:
        SEP #$20
        LDA.L !status_slots
        CMP #$01
        BEQ .erase_tile
        LDA #$34
        STA $00
        LDA #$00
    .vert_good:
        SEP #$20
        STA $02B1,Y ; oam y position
        JMP .check_horiz
        
    .erase_tile:
        LDA #$F0
        STA $02B1,Y ; oam y position
        JMP .done
        
    .check_horiz:
        LDA $E4,X ; sprite x position, low byte
        XBA
        LDA $14E0,X ; sprite x position, high byte
        XBA
        REP #$20
        SEC
        SBC $1A ; layer 1 x position
        BMI .left
        CMP #$00F8
        BCC .horiz_good
    .right:
        SEP #$20
        LDA.L !status_slots
        CMP #$01
        BEQ .erase_tile
        LDA #$34
        STA $00
        LDA #$F8
        BRA .horiz_good
    .left:
        SEP #$20
        LDA.L !status_slots
        CMP #$01
        BEQ .erase_tile
        LDA #$34
        STA $00
        LDA #$00
    .horiz_good:
        SEP #$20
        STA $02B0,Y ; oam x position
        
        LDA sprite_numbers,X
        STA $02B2,Y ; oam tile
        LDA $00
        STA $02B3,Y ; oam properties
        STZ $044C,X ; oam size
        
    .done:
        PLB
        RTL

sprite_numbers:
        db $44,$45,$46,$47
        db $54,$55,$56,$57
        db $68,$69,$6A,$6B
        db $78,$79,$7A,$7B
        
; increment the timer located at address at top of stack by the number of frames elapsed this execution frame
tick_timer:
        PLX ; grab timer address off of the stack and restore return address
        PLY
        PLA
        STA $00
        PLA
        STA $01
        PHY
        PHX
        
        LDA !freeze_timer_flag
        BNE .done
        
        LDA.L !status_region
        TAX
        
        LDY #$02
        LDA ($00),Y
        CLC
        ADC !real_frames
        CMP.L frames_in_a_second,X
        BCC .frames_less
        SEC
        SBC.L frames_in_a_second,X
        STA ($00),Y
        DEY
        LDA ($00),Y
        INC A
        CMP.L frames_in_a_second,X
        BCC .seconds_less
        SEC
        SBC.L frames_in_a_second,X
        STA ($00),Y
        DEY
        LDA ($00),Y
        INC A
        CMP #$0A
        BCS .minutes_max
        STA ($00),Y
    .done:
        RTS
    .frames_less:
        STA ($00),Y
        BRA .done
    .seconds_less:
        STA ($00),Y
        BRA .done
    .minutes_max:
        LDA.L frames_in_a_second,X
        DEC A
        INY
        STA ($00),Y
        INY
        STA ($00),Y
        BRA .done

; rewrite CI2's weird screen exits so it's compatible with the level reset code
test_ci2:
        LDA $71 ; player animation
        CMP #$05
        BNE .done
        LDA $88 ; pipe animation
        BNE .done
        LDA $13BF ; translevel number
        CMP #$24
        BNE .done
        
        LDA $141A
        AND #$7F
        CMP #$03
        BCC +
        LDA #$03
      + ASL A
        TAX
        LDY #$00
        JSR (ci2_room_exits,X)
        
    .done:
        RTS

ci2_room_exits:
        dw ci2_coins
        dw ci2_time
        dw ci2_dragon_coins
        dw ci2_goal ; this shouldn't happen, but just in case

ci2_coins:
        LDA $0DBF ; coins
        CMP #$15
        BCC +
        LDA #$CF ; x >= 21 coins
        BRA .and_go
      + CMP #$09
        BCC +
        LDA #$B9 ; 9 <= x < 21 coins
        BRA .and_go
      + LDA #$B8 ; x < 9 coins
    .and_go:
        JSL set_global_exit
        RTS

ci2_time:
        LDA $0F31 ; timer hundreds
        CMP #$02
        BCS +
        LDA #$CE ; x < 200
        BRA .and_go
      + LDA $0F32 ; timer tens
        ASL #4
        ORA $0F33 ; timer ones
        CMP #$35
        BCS +
        LDA #$CE ; 200 <= x < 235
        BRA .and_go
      + CMP #$50
        BCS +
        LDA #$BB ; 235 <= x < 250
        BRA .and_go
      + LDA #$BA ; x >= 250
    .and_go:
        JSL set_global_exit
        RTS

ci2_dragon_coins:
        LDA $1420 ; dragon coins
        CMP #$04
        BCS +
        LDA #$BC ; x < 4 dragon coins
        BRA .and_go
      + LDA #$CD ; x >= 4 dragon coins
    .and_go
        JSL set_global_exit
        RTS

ci2_goal:
        RTS
        

; test if a reset was activated, if so, call the appropriate routine
test_reset:
        LDA.L !status_lrreset
        BNE .done
        LDA $71 ; player animation
        CMP #$09
        BEQ +
        LDA $9D ; sprite lock flag
        ORA $1493 ; end level timer
        ORA $1434 ; keyhole timer
        ORA $1426 ; message block timer
        ORA $13D4 ; paused flag
        BNE .done
        
      + LDA !util_axlr_hold
        AND #%00110000
        CMP #%00110000
        BNE .done
        
        INC $9D ; sprite lock flag
        
        ; test X + Y for advance room
        LDA !util_axlr_hold
        AND #%01000000
        BEQ +
        LDA !util_byetudlr_hold
        AND #%01000000
        BEQ +
        JSL activate_room_advance
        JMP .done
        
        ; test A + B for level reset
      + LDA !util_axlr_hold
        AND #%10000000
        BEQ +
        LDA !util_byetudlr_hold
        AND #%10000000
        BEQ +
        JSL activate_level_reset
        JMP .done
    
      + JSL activate_room_reset
        
    .done:
        RTS

; test if a savestate was activated, if so, call the appropriate routine
test_savestate:
        LDA.L !status_states
        BEQ .done
        
        LDA $0D9B ; overworld flag
        CMP #$02
        BEQ .done
                
        LDA !util_byetudlr_hold
        AND #%00100000
        BEQ .no_load
        
        LDA !util_axlr_hold
        AND #%00010000
        BEQ +
        
        JSL activate_save_state
        BRA .no_load
        
      + LDA.L !save_state_exists
        CMP #$BD
        BNE .no_load
        LDA !util_axlr_hold
        AND #%00100000
        BEQ .no_load
        
        LDA $705000+!in_record_mode ; save state was in movie
        CMP !in_record_mode
        BNE .make_sound
        
        LDA $705000+$13BF ; save state translevel
        CMP $13BF
        BEQ .go
        
    .make_sound:
        LDA !load_state_timer
        AND #$07
        BNE +
        LDA #$1A ; grinder sound
        STA $1DF9 ; apu i/o    
      + LDA !load_state_timer
        BEQ +
        CMP #$01
        BEQ .go
        DEC !load_state_timer
        JMP .done
      + LDA #!load_state_delay
        STA !load_state_timer
        BRA .done
    
    .go:
        JSL activate_load_state
    .no_load:
        STZ !load_state_timer
    .done:
        RTS
        
; test if slowdown was activated, if so, update the register for that
test_slowdown:
        LDA !status_slowdown
        BNE .done
        
        LDA !util_byetudlr_frame
        AND #%00010000
        BEQ .done
        
        LDA !util_axlr_hold
        AND #%00010000
        BEQ .test_undo
        
        LDA.W !slowdown_speed
        INC A
        CMP #$0F
        BCC .store_speed
        LDA #$0E
        BRA .store_speed
        
    .test_undo:
        LDA !util_axlr_hold
        AND #%00100000
        BEQ .done
        
        LDA.W !slowdown_speed
        DEC A
        BPL .store_speed
        LDA #$00
    
    .store_speed:
        STA.W !slowdown_speed
        
    .done:
        RTS

; test if player used cape, powerup, yoshi, etc. to count towards record keeping
test_run_type:
        LDA $187A ; riding yoshi
        BNE .set_yoshi
        LDA $19 ; powerup
        BNE .deny_low
        LDA $1490 ; star
        BNE .deny_low
        LDA $13F3 ; p-balloon flag
        BEQ .check_cape
        
    .set_yoshi:
        LDA #%01000000
        STA !record_used_yoshi
    .deny_low:
        LDA #$01
        STA !record_used_powerup
    .check_cape:
        LDA $19 ; powerup
        CMP #$02
        BNE .check_ld
        LDA #$01
        STA !record_used_cape
        
    .check_ld:
        LDA $1420 ; dragon coin count
        CMP #$05
        BCC .done
        
        LDA $13BF ; translevel
        LDY #$07
      - DEY
        BMI +
        CMP levels_with_moons,Y
        BNE -
        LDA $13C5 ; collected moon flag
        BEQ .done
      + LDA #$01
        STA !record_lunar_dragon
        
    .done:
        RTS

levels_with_moons:
        db $29,$06,$2E,$0F,$41,$22,$36,$3A

; 'fix' powerup incrementation by adjust all the values that mess with the stack
; the 5 values of interest should be shifted back 4 because the stack is 4 bytes higher here
fix_powerup_incrementation:
        PHP
        CPY #$FF
        BEQ .fixit
        PLP
        STA $00E4,Y
        LDY $157C,X
        RTL
    .fixit:
        PLP
        STA $00E4-4,Y ; this is probably the only one that matters
        PLA
        PLA
        PLA ; remove old return address
        LDY $157C,X
        LDA $14E0,X
        ADC $F307,Y
        PLY
        STA $14E0,Y
        LDA $D8,X
        STA $00D8-4,Y
        LDA $14D4,X
        STA $14D4,Y
        LDA #$00
        STA $00C2-4,Y
        STA $15D0,Y
        STA $1626,Y
        LDA $18DC
        CMP #$01
        LDA #$0A
        BCC +
        LDA #$09
      + STA $14C8,Y
        PHX
        LDA $157C,X
        STA $157C,Y
        TAX
        BCC +
        INX
        INX
      + LDA $F301,X
        STA $00B6-4,Y
        LDA #$00
        STA $00AA-4,Y
        PLX
        
        ; skip the original routine and return to a later part
        LDA #$81
        PHA
        PEA $F24F-1
        RTL

; fix item swap bug by reverting the program bank if pointer index is out of bounds
; open bus behavior requires program bank to be $01, not $81
fix_item_swap_bug:
        CMP #$06
        BCC .done
        PHA
        LDA $04,S
        AND #$7F
        STA $04,S
        PLA
    .done:
        JML !_F+$0086DF ; ExecutePtr

; activate orb flag if level beaten with orb that came out of the item box
collect_orb:
        STZ $14C8,X ; sprite status
        LDA $9E,X ; sprite id
        CMP #$4A ; orb
        BNE +
        LDA $1528,X ; misc table (used for original orb in level flag)
        BNE +
        LDA #%00100000
        STA !record_used_orb
      + LDA #$FF
        RTL

; test if we should drop the item out of the item box
drop_item_box:
        LDA $16 ; byetudlr frame
        AND #%00100000
        BEQ .no_select
        LDA.L !status_drop
        BNE .yes_select
        LDA $17 ; axlr----
        AND #%00110000
        BEQ .yes_select
        
    .no_select:
        INC A
    .yes_select:
        RTL

; test the start button to see if we should pause the game (return 0 in A for no pause, pause otherwisxe)
test_pause:
        LDA $16 ; byetudlr frame
        AND #%00010000
        BEQ .done
        LDA.L !status_drop
        BNE +
        LDA $17 ; axlr----
        AND #%00110000
        BEQ +
        LDA #$00
        BRA .done
      + LDA $13D4 ; pause flag
        BEQ +
        STZ !pause_timer_minutes
        STZ !pause_timer_seconds
        STZ !pause_timer_frames
      + LDA #$01        
    .done:
        RTL

; set the pause timer depending on our current setting
pause_timer:
        PHB
        PHK
        PLB
        
        LDA.L !status_pause
        TAX
        LDA pause_lengths,X
        STA $13D3 ; pause timer
        
        PLB
        RTL

pause_lengths:
        db $3C,$00
        
; play hurry up sound effect only if option is on
hurry_up:
        LDA.L !status_timedeath
        BNE +
        LDA $0F31
        BNE +
        ORA $0F32
        AND $0F33 ; timer
        CMP #$09
        BNE +
        LDA #$FF
        STA $1DF9 ; apu i/o
      + RTL
        
; kill mario when time runs out only if option is on
; return 0 in A to kill mario
out_of_time:
        LDA $0F31
        ORA $0F32
        ORA $0F33 ; timer
        BNE +
        LDA.L !status_timedeath
      + RTL

; display a score sprite only if sprite slot numbers are disabled
; return A = 0 if enabled
check_score_sprites:
        LDA.L !status_slots
        BNE +
        LDA.L !status_dynmeter
        BNE +
        LDA $16E7,X ; score sprite y position low byte
        SEC
        SBC $02
        STA $0201,Y ; oam tile
        STA $0205,Y ; oam tile
        LDA #$00
        RTL
        
      + LDA #$01
        RTL

; draw a green star on the screen if playing a movie
display_replay_star:
        LDA !in_playback_mode
        BEQ +
        LDA #$F0
        STA $0205 ; ypos
        LDA $13 ; true frame
        AND #%00100000
        BEQ +
        
        LDA #$48 ; star
        STA $0206 ; tile
        LDA #$08
        STA $0204 ; xpos
        LDA #$C8
        STA $0205 ; ypos
        LDA #$3A
        STA $0207 ; prop
        LDA #$02
        STA $0421 ; size
        
      + RTS

; draw the level and room timers, but on the sprite layer instead if in the bowser fight
draw_bowser_timer:
        LDA $0D9B ; boss flag
        CMP #$C1 ; bowser fight
        BEQ +
        RTL
        
      + PHB
        PHK
        PLB
        
        LDA #$69 ; empty tile
        STA !sbbowser_leveltimer+2-(4*1)
        LDA.L !spliced_run
        BNE +
        LDA $13 ; true frame
        AND #%00100000
        BEQ +
        LDA #$98 ; clock icon
        STA !sbbowser_leveltimer+2-(4*1)
      + LDA #$00;.L !status_fractions
        CMP #$02
        BEQ .draw_level_framecount
        LDA !level_timer_minutes
        JSR hex_to_bowser
        STA !sbbowser_leveltimer+2+(4*0)
        LDA !level_timer_seconds
        JSR hex_to_bowser
        STX !sbbowser_leveltimer+2+(4*2)
        STA !sbbowser_leveltimer+2+(4*3)
        LDA #$00;.L !status_fractions
        BEQ .draw_level_fractions
        LDA !level_timer_frames
        JSR hex_to_bowser
        STX !sbbowser_leveltimer+2+(4*5)
        STA !sbbowser_leveltimer+2+(4*6)
        LDA #$99
        STA !sbbowser_leveltimer+2+(4*4)
        JMP .set_level_positions
    .draw_level_fractions:
        LDX !level_timer_frames
        LDA fractional_seconds,X
        JSR hex_to_bowser
        STX !sbbowser_leveltimer+2+(4*5)
        STA !sbbowser_leveltimer+2+(4*6)
        LDA #$9A
        STA !sbbowser_leveltimer+2+(4*4)
    .set_level_positions:
        LDA #$99
        STA !sbbowser_leveltimer+2+(4*1)
        JMP .level_attr
    .draw_level_framecount:
        LDA !level_timer_frames
        STA $00
        STZ $01
        LDA #$3C ; frames in a second
        STA $4202 ; mult A
        LDA !level_timer_seconds
        STA $4203 ; mult B
        REP #$20
        LDA #$0000
        LDX !level_timer_minutes
      - BEQ +
        CLC
        ADC #$0E10 ; frames in a minute
        DEX
        BRA -
      + CLC
        ADC $4216 ; mult result
        CLC
        ADC $00
        SEP #$20
        PHA
        AND #$0F
        JSR dec_to_bowser
        STA !sbbowser_leveltimer+2+(4*4)
        PLA
        LSR #4
        JSR dec_to_bowser
        STA !sbbowser_leveltimer+2+(4*3)
        XBA
        PHA
        AND #$0F
        JSR dec_to_bowser
        STA !sbbowser_leveltimer+2+(4*2)
        PLA
        LSR #4
        JSR dec_to_bowser
        STA !sbbowser_leveltimer+2+(4*1)
        LDA #$69
        STA !sbbowser_leveltimer+2+(4*5)
        STA !sbbowser_leveltimer+2+(4*0)
        LDA #$9B
        STA !sbbowser_leveltimer+2+(4*6) ; h
        
    .level_attr:
        LDY #$07
      - TYX
        STZ !sbbowser_leveltimer_2-1,X
        LDA timer_x,X
        PHA
        TYA
        ASL A
        ASL A
        TAX
        PLA
        STA !sbbowser_leveltimer+0-(4*1),X
        LDA #$08
        STA !sbbowser_leveltimer+1-(4*1),X
        LDA #$30
        STA !sbbowser_leveltimer+3-(4*1),X
        DEY
        BPL -
        
        LDA #$00;.L !status_fractions
        CMP #$02
        BEQ .draw_room_framecount
        LDA !room_timer_minutes
        JSR hex_to_bowser
        STA !sbbowser_roomtimer+2+(4*0)
        LDA !room_timer_seconds
        JSR hex_to_bowser
        STX !sbbowser_roomtimer+2+(4*2)
        STA !sbbowser_roomtimer+2+(4*3)
        LDA #$00;.L !status_fractions
        BEQ .draw_room_fractions
        LDA !level_timer_frames
        JSR hex_to_bowser
        STX !sbbowser_roomtimer+2+(4*5)
        STA !sbbowser_roomtimer+2+(4*6)
        LDA #$99
        STA !sbbowser_roomtimer+2+(4*4)
        JMP .set_room_positions
    .draw_room_fractions:
        LDX !level_timer_frames
        LDA fractional_seconds,X
        JSR hex_to_bowser
        STX !sbbowser_roomtimer+2+(4*5)
        STA !sbbowser_roomtimer+2+(4*6)
        LDA #$9A
        STA !sbbowser_roomtimer+2+(4*4)
    .set_room_positions:
        LDA #$99
        STA !sbbowser_roomtimer+2+(4*1)
        JMP .room_attr
    .draw_room_framecount:
        LDA !room_timer_frames
        STA $00
        STZ $01
        LDA #$3C ; frames in a second
        STA $4202 ; mult A
        LDA !room_timer_seconds
        STA $4203 ; mult B
        REP #$20
        LDA #$0000
        LDX !room_timer_minutes
      - BEQ +
        CLC
        ADC #$0E10 ; frames in a minute
        DEX
        BRA -
      + CLC
        ADC $4216 ; mult result
        CLC
        ADC $00
        SEP #$20
        PHA
        AND #$0F
        JSR dec_to_bowser
        STA !sbbowser_roomtimer+2+(4*4)
        PLA
        LSR #4
        JSR dec_to_bowser
        STA !sbbowser_roomtimer+2+(4*3)
        XBA
        PHA
        AND #$0F
        JSR dec_to_bowser
        STA !sbbowser_roomtimer+2+(4*2)
        PLA
        LSR #4
        JSR dec_to_bowser
        STA !sbbowser_roomtimer+2+(4*1)
        LDA #$69
        STA !sbbowser_roomtimer+2+(4*5)
        STA !sbbowser_roomtimer+2+(4*0)
        LDA #$9B
        STA !sbbowser_roomtimer+2+(4*6) ; h
        
    .room_attr:
        LDY #$06
      - TYX
        STZ !sbbowser_roomtimer_2,X
        INX
        LDA timer_x,X
        DEX
        PHA
        TYA
        ASL A
        ASL A
        TAX
        PLA
        STA !sbbowser_roomtimer+0,X
        LDA #$10
        STA !sbbowser_roomtimer+1,X
        LDA #$32
        STA !sbbowser_roomtimer+3,X
        DEY
        BPL -
        
        LDA #$00;.L !status_fractions
        CMP #$02
        BEQ .draw_pause_framecount
        LDA !pause_timer_minutes
        JSR hex_to_bowser
        STA !sbbowser_pausetimer+2+(4*0)
        LDA !pause_timer_seconds
        JSR hex_to_bowser
        STX !sbbowser_pausetimer+2+(4*2)
        STA !sbbowser_pausetimer+2+(4*3)
        LDA #$00;.L !status_fractions
        BEQ .draw_pause_fractions
        LDA !level_timer_frames
        JSR hex_to_bowser
        STX !sbbowser_pausetimer+2+(4*5)
        STA !sbbowser_pausetimer+2+(4*6)
        LDA #$99
        STA !sbbowser_pausetimer+2+(4*4)
        JMP .set_pause_positions
    .draw_pause_fractions:
        LDX !level_timer_frames
        LDA fractional_seconds,X
        JSR hex_to_bowser
        STX !sbbowser_pausetimer+2+(4*5)
        STA !sbbowser_pausetimer+2+(4*6)
        LDA #$9A
        STA !sbbowser_pausetimer+2+(4*4)
    .set_pause_positions:
        LDA #$99
        STA !sbbowser_pausetimer+2+(4*1)
        JMP .pause_attr
    .draw_pause_framecount:
        LDA !pause_timer_frames
        STA $00
        STZ $01
        LDA #$3C ; frames in a second
        STA $4202 ; mult A
        LDA !pause_timer_seconds
        STA $4203 ; mult B
        REP #$20
        LDA #$0000
        LDX !pause_timer_minutes
      - BEQ +
        CLC
        ADC #$0E10 ; frames in a minute
        DEX
        BRA -
      + CLC
        ADC $4216 ; mult result
        CLC
        ADC $00
        SEP #$20
        PHA
        AND #$0F
        JSR dec_to_bowser
        STA !sbbowser_pausetimer+2+(4*4)
        PLA
        LSR #4
        JSR dec_to_bowser
        STA !sbbowser_pausetimer+2+(4*3)
        XBA
        PHA
        AND #$0F
        JSR dec_to_bowser
        STA !sbbowser_pausetimer+2+(4*2)
        PLA
        LSR #4
        JSR dec_to_bowser
        STA !sbbowser_pausetimer+2+(4*1)
        LDA #$69
        STA !sbbowser_pausetimer+2+(4*5)
        STA !sbbowser_pausetimer+2+(4*0)
        LDA #$9B
        STA !sbbowser_pausetimer+2+(4*6) ; h
        
    .pause_attr:        
        LDY #$06
      - TYX
        STZ !sbbowser_pausetimer_2,X
        INX
        LDA timer_x,X
        DEX
        PHA
        TYA
        ASL A
        ASL A
        TAX
        PLA
        STA !sbbowser_pausetimer+0,X
        LDA #$18
        STA !sbbowser_pausetimer+1,X
        LDA #$3A
        STA !sbbowser_pausetimer+3,X
        DEY
        BPL -
        
        PLB
        RTL

; the x positions of each of the tiles in the bowser timer
timer_x:
        db $30,$38,$40,$48,$50,$58,$60,$68

; convert a hex number to decimal, then get tile numbers
hex_to_bowser:
        JSL !_F+$00974C ; hex2dec
dec_to_bowser:
        PHX
        TAX
        LDA bowser_numbers,X
        PLX
        PHA
        LDA bowser_numbers,X
        TAX
        PLA
        RTS
        
; tile numbers for each of the numbers 0-9 in the bowser timer
bowser_numbers:
        db $A8,$A9,$AA,$AB,$AC
        db $AD,$AE,$AF,$B0,$B1
        db $B8,$B9,$BA,$BB,$BC,$BD
        
; if sprite slots are enabled, don't draw background in morton, roy, ludwig
boss_sprite_background:
        LDA.L !status_slots
        BEQ .draw
        LDA $13FC
        CMP #$02
        BEQ +
        CPY #$0026*4
        BCC .draw
        CPY #$0036*4
        BCS .draw
        BRA .dont_draw
        
      + CPX #$0021
        BCC .draw
    .dont_draw:
        LDA #$F0
        RTL
    .draw:
        LDA.L !_F+$0281CF,X
        RTL

; if mario finds himself in translevel 0, reset his overworld position as a fail safe
test_translevel_0_failsafe:
        LDA $0100 ; game mode
        CMP #$14
        BNE +
        LDA $13BF ; translevel
        BNE +
        JSL set_position_to_yoshis_house
      + RTS
        
; only reset layer 3 Y position if not in overworld menu
layer_3_y:
        LDA !in_overworld_menu
        BNE +
        STZ $2112
        STZ $2112
        RTL
        
      + LDA $24
        STA $2112
        LDA $25
        STA $2112
        RTL
        
; prepare layer 3 background x position
; this must be done before IRQ fires!
setup_layer3_bg:
        PHP
        REP #$20
        SEP #$10
        LDX $13D5 ; layer 3 lock
        BNE .done
        LDX $1403 ; layer 3 tide setting
        BNE .done
        LDX $1BE3 ; layer 3 type
        CPX #$03
        BNE .done
        
        LDX $1931 ; tileset
        CPX #$03
        BEQ +
        CPX #$01
        BNE .done
        
      + LDA $1A ; layer 1 future x pos
        LSR A
        STA $22 ; layer 3 x pos
        
    .done:
        PLP
        RTS

; disable layer 3 priority if in overworld menu
layer_3_priority:
        LDA !in_overworld_menu
        BNE +
        LDA #$09
        BRA ++
      + LDA #$01
     ++ STA $2105
        RTL

; record player input as a movie
record_input:
        PHP
        LDA !in_record_mode
        BNE +
        JMP .skip
        
      + REP #$30
        LDA.L !movie_location
        CMP #$FFFF
        BEQ .start
        TAX
        SEP #$20
        LDA.L !movie_location+$43,X
        CMP !util_byetudlr_hold
        BNE +
        LDA.L !movie_location+$44,X
        AND #$F0
        CMP !util_axlr_hold
        BNE +
        LDA.L !movie_location+$44,X
        AND #$08
        BEQ .increment_sub
        BRA .increment_ext
      + LDA.L !movie_location+$44,X
        AND #$08
        BEQ +
        INX
      + INX #2
        BRA .record_new_byte
        
    .start:
        LDX #$0000
        SEP #$20
    .record_new_byte:
        LDA !util_byetudlr_hold
        STA.L !movie_location+$43,X
        LDA !util_axlr_hold
        AND #$F0
        STA.L !movie_location+$44,X
        BRA .done
    .increment_sub:
        LDA.L !movie_location+$44,X
        INC A
        STA.L !movie_location+$44,X
        AND #$08
        BEQ .done
    .create_ext:
        LDA.L !movie_location+$44,X
        AND #$0F
        STA.L !movie_location+$45,X
        BRA .done
    .increment_ext:
        LDA.L !movie_location+$45,X
        CMP #$FF
        BNE +
        INX #3
        BRA .record_new_byte
      + INC A
        STA.L !movie_location+$45,X
        
    .done:
        REP #$30
        TXA
        STA.L !movie_location
        CPX #$07C0
        BCC .skip
        SEP #$20
        STZ !in_record_mode
    .skip:
        PLP
        RTS

; update the index into the movie
prepare_input:
        PHP
        LDA !in_playback_mode
        BNE +
        JMP .done
        
      + REP #$30
        LDA.L !movie_location
        CMP #$FFFF
        BEQ +
        TAX
        BRA .go
    
      + LDX #$0000
        SEP #$20
        LDA #$00
        STA.L !movie_location+2
    .go:
        SEP #$20
        LDA.L !movie_location+$44,X
        AND #$08
        BNE .check_ext
        LDA.L !movie_location+$44,X
        AND #$07
        BRA .merge_count
    .check_ext:
        LDA.L !movie_location+$45,X
    .merge_count:
        CMP.L !movie_location+2
        BEQ .advance_input
        BCC .advance_input
        BRA .use_this_input
    .advance_input:
        LDA.L !movie_location+$44,X
        AND #$08
        BEQ +
        INX
      + INX #2
        LDA #$FF
        STA.L !movie_location+2
    .use_this_input:
        LDA.L !movie_location+2
        INC A
        STA.L !movie_location+2
        
        REP #$30
        TXA
        STA.L !movie_location
        
    .done:
        PLP
        RTS
        
; actually feed the input into the controller registers
play_input:
        PHP
        LDA !in_playback_mode
        BNE +
        JMP .done
      + LDA $0103
        CMP #$0F ; overworld gfx
        BNE +
        JMP .done
      + LDA $4219 ; byetudlr hardware
        AND #%00110000
        CMP #%00110000
        BNE +
        LDA $0DB0 ; mosaic size
        BNE +
        
        LDA #$0B
        STA $0100 ; game mode
        LDA #$11 ; pause sound
        STA $1DF9 ; apu i/o
        BRA .done
      
      + STZ !util_byetudlr_hold+1
        STZ !util_axlr_hold+1
        STZ !util_byetudlr_frame+1
        STZ !util_axlr_frame+1
        STZ !util_byetudlr_mask+1
        STZ !util_axlr_mask
        
        REP #$30
        LDA.L !movie_location
        TAX
        SEP #$20
        
        LDA.L !movie_location+$43,X
        STA $00
        LDA.L !movie_location+$44,X
        AND #$F0
        STA $01
        
        SEP #$30
        
        ; this part copied from $008650
        LDA $01
        EOR !util_axlr_hold
        AND $01
        STA !util_axlr_frame
        LDA $01
        STA !util_axlr_hold
        
        LDA $00
        EOR !util_byetudlr_hold
        AND $00
        STA !util_byetudlr_frame
        LDA $00
        STA !util_byetudlr_hold
        
    .done:
        PLP
        RTL
        
count_rng_index:
        REP #$21            ; 16bit, C=0
        LDA $148B           ; seed
        BNE +
        STZ !rng_index		; if seed is zero, reset index
        STZ !rng_index+1
      + SED
        LDA !rng_index
        ADC #$0001
        STA !rng_index
        SEP #$20            ; 8bit
        LDA !rng_index+2
        ADC #$00
        STA !rng_index+2
        CLD
        JML !_F+$01AD07

incsrc "region_differences.asm"

print "inserted ", bytes, "/32768 bytes into bank $15"