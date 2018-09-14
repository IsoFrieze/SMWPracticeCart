ORG !_F+$148000

; this code is run on every frame during the overworld game mode (after fade in completes)
overworld_tick:
        PHP
        PHB
        PHK
        PLB
        
        JSL $7F8000
        JSR update_potential_translevel
        JSR test_for_powerup
        JSR test_for_yoshi
        JSR test_for_swap
        JSR test_for_menu
        JSR test_for_time_toggle
        JSR try_draw_times
        JSR save_marios_position
        JSR test_for_enter_level
        JSR draw_movie_slots
        
        LDA #$40
        TSB $0D9F ; hdmaen mirror
        
        PLB
        PLP
        RTL

; set the translevel of the tile mario is currently standing on
; (code taken from $05D850)
update_potential_translevel:
        PHP
        REP #$30

        LDA $1F1F
        AND #$000F
        STA $00
        LDA $1F21
        AND #$000F
        ASL #4
        STA $02
        LDA $1F1F
        AND #$0010
        ASL #4
        ORA $00
        STA $00
        LDA $1F21
        AND #$0010
        ASL #5
        ORA $02
        ORA $00
        TAX
        LDA $1F11
        AND #$00FF
        BEQ +
        TXA
        CLC
        ADC #$0400
        TAX
      + SEP #$20
        LDA $7ED000,X
        STA !potential_translevel
        
        PLP
        RTS
        
; check if entering level, and do stuff
test_for_enter_level:
        LDA !potential_translevel
        BNE +
        JMP .done
      + LDA !util_axlr_frame
        ORA !util_byetudlr_frame
        AND #$C0
        BNE +
        JMP .done
        
      + STZ !in_record_mode
        STZ !in_playback_mode
        STZ $1496 ; player animation timer
        
        LDA !util_axlr_frame
        AND #$40
        BNE +
        JMP .no_record
      + INC !in_record_mode
        
        LDA #$FF
        STA !movie_location
        STA !movie_location+1
        LDA #!movie_version
        STA !movie_location+$03
        LDA !potential_translevel
        STA !movie_location+$04
        LDA.L !status_playername
        STA !movie_location+$07
        LDA.L !status_playername+1
        STA !movie_location+$08
        LDA.L !status_playername+2
        STA !movie_location+$09
        LDA.L !status_playername+3
        STA !movie_location+$0A
        LDA #$00
        STA !movie_location+$0E
        LDA.L !status_yellow
        STA !movie_location+$13
        LDA.L !status_green
        STA !movie_location+$14
        LDA.L !status_red
        STA !movie_location+$15
        LDA.L !status_blue
        STA !movie_location+$16
        LDA.L !status_special
        STA !movie_location+$17
        LDA $0DB8
        STA !movie_location+$18
        LDA $0DBC
        STA !movie_location+$19
        LDA $0DBA
        STA !movie_location+$1A
        LDA $0FAE
        STA !movie_location+$23
        LDA $0FAF
        STA !movie_location+$24
        LDA $0FB0
        STA !movie_location+$25
        LDA $0FB1
        STA !movie_location+$26
        LDA $13
        STA !movie_location+$27
        LDA $14
        STA !movie_location+$28
        LDA.L !status_drop
        STA !movie_location+$33
        LDA.L !status_lrreset
        STA !movie_location+$34
        LDA.L !status_slowdown
        STA !movie_location+$35
        LDA.L !status_timedeath
        STA !movie_location+$36
        LDA.L !status_pause
        STA !movie_location+$37
        LDA.L !status_region
        STA !movie_location+$38
        JMP .finish
    .no_record:
        LDA !util_byetudlr_frame
        AND #$40
        BNE +
    .exit:
        JMP .finish
      + LDA !movie_location+$04
        CMP !potential_translevel
        BNE .exit
        
        ; integrity check
        REP #$30
        LDA !movie_location+$05
        TAX
        DEX
        SEP #$20
        LDA #$00
      - CLC
        ADC !movie_location+$43,X
        DEX
        BPL -
        CMP !movie_location+$0C
        BNE .exit
        LDA !movie_location+$0D
        CMP #$BD
        BNE .exit
        
        SEP #$30
        
        ; backup settings
        LDX #$1F
      - LDA.L !status_table,X
        STA.L !backup_status_table,X
        DEX
        BPL -
        
        INC !in_playback_mode    
        LDA #$01
        STA.L !spliced_run
        
        LDA #$00
        STA !movie_location
        STA !movie_location+1
        STA !movie_location+2
        
        LDA !movie_location+$0E
        EOR #$01
        STA.L !status_states
        LDA !movie_location+$13
        STA $1F28
        LDA !movie_location+$14
        STA $1F27
        LDA !movie_location+$15
        STA $1F2A
        LDA !movie_location+$16
        STA $1F29
        LDA !movie_location+$17
        STA.L !status_special
        LDA !movie_location+$18
        STA $0DB8
        LDA !movie_location+$19
        STA $0DBC
        LDA !movie_location+$1A
        STA $0DBA
        STA $13C7
        LDA #$01
        STA $0DC1
        LDA !movie_location+$23
        STA $0FAE
        LDA !movie_location+$24
        STA $0FAF
        LDA !movie_location+$25
        STA $0FB0
        LDA !movie_location+$26
        STA $0FB1
        LDA !movie_location+$27
        STA $13
        LDA !movie_location+$28
        STA $14
        LDA !movie_location+$33
        STA.L !status_drop
        LDA !movie_location+$34
        STA.L !status_lrreset
        LDA !movie_location+$35
        STA.L !status_slowdown
        LDA !movie_location+$36
        STA.L !status_timedeath
        LDA !movie_location+$37
        STA.L !status_pause
        LDA !movie_location+$38
        STA.L !status_region
        
    .finish:
    .done:
        RTS

; if R is pressed, cycle through powerup
test_for_powerup:
        LDA !util_axlr_frame
        AND #%00010000
        BEQ .done
        LDA !util_axlr_hold
        AND #%00100000
        BNE .done
        
        LDA $19
        INC A
        CMP #$04
        BNE +
        LDA #$00
      + STA $19
        STA $0DB8
        STA.L !status_powerup
        
    .done:
        RTS

; if L is pressed, cycle through yoshi color
test_for_yoshi:
        LDA !util_axlr_frame
        AND #%00100000
        BEQ .done
        LDA !util_axlr_hold
        AND #%00010000
        BNE .done
        
        LDA $0DBA ; ow yoshi color
      - INC A
        INC A
        CMP #$02
        BEQ -
        CMP #$0C
        BNE +
        LDA #$00
      + STA $13C7 ; yoshi color
        STA $0DBA ; ow yoshi color
        JSL load_yoshi_color
        LDA #$01
        STA $0DC1 ; persistent yoshi flag
        
    .done:
        RTS

; if select is pressed, swap powerup and item box powerup (if applicable)
test_for_swap:
        LDA !util_byetudlr_frame
        AND #%00100000
        BEQ .done
        LDA $19 ; powerup
        AND #$FC
        BNE .done
        LDA $0DC2 ; itembox
        CMP #$03
        BEQ .done
        CMP #$04
        BNE +
        DEC A
      + AND #$FC
        BNE .done
        
        LDA $19 ; powerup
        CMP #$02
        BNE +
        ASL A
      + CMP #$03
        BNE +
        DEC A
      + STA $00
        LDA $0DC2 ; itembox
        CMP #$02
        BNE +
        INC A
      + CMP #$04
        BNE +
        LSR A
      + STA $19 ; powerup
        STA $0DB8 ; ow powerup
        STA.L !status_powerup
        LDA $00
        STA $0DC2 ; itembox
        STA $0DBC ; ow itembox
        STA.L !status_itembox
        
    .done:
        RTS

; if start is pressed, go to menu
test_for_menu:
        LDA !util_byetudlr_frame
        AND #%00010000
        BEQ +
        LDA $144E ; ow mario animation
        BNE +
        
        LDA #$1C ; switch block ding
        STA $1DFC ; apu i/o
        
        LDA #$1C ; fade to overworld load
        STA $0100
        
      + RTS

; if x, toggle the times
test_for_time_toggle:
        LDA !util_axlr_hold
        AND #%00110000
        CMP #%00110000
        BNE .done
        LDA !util_axlr_frame
        AND #%00110000
        BEQ .done
        LDA !ow_display_times
        INC A
        CMP #$03
        BNE +
        LDA #$00
      + STA !ow_display_times
        JSR draw_times
    .done:
        RTS

; call the movement function a lot
iterate_overworld_movement:
        LDX #$07
      - PHX
        JSR test_movement
        PLX
        DEX
        BPL -
        
        RTL

; only call the movement function at appropriate times
; this snippet taken from WhiteYoshiEgg & carol's OW Speed Changer patch
test_movement:
        LDA $13D9 ; overworld process
        CMP #$04
        BNE .done
        PHK
        PEA .done-1
        PEA $8575-1
        JML $04945D ; movement routine
    .done:
        RTS
        
; try to draw the times onto the overworld border
try_draw_times:
        LDA $144E ; overworld forward timer
        CMP #$0E
        BNE +
        JSR draw_times
      + RTS

; draw record times onto the overworld border
draw_times:
        PHB
        PHK
        PLB
        
        LDA !ow_display_times
        STA $00
        ASL A
        CLC
        ADC $00
        TAX
        
        REP #$20
        LDA !potential_translevel
        AND #$007F
        ASL #5
        CLC
        ADC times_ptrs,X
        STA $00
        SEP #$20
        LDA times_ptrs+2,X
        STA $02
        
        LDY #$07
    .loop:
        JSR load_unran_time
        TYA
        ASL A
        ASL A
        PHY
        TAY
        LDA [$00],Y
        CMP #$FF
        BNE +
        JMP .draw_unran
      + LDA !potential_translevel
        BNE +
        JMP .draw_unran
        
      + PHX
        LDA #$00;.L !status_fractions
        CMP #$02
        BEQ .in_framecount
        LDA [$00],Y
        STA $0D
        JSL !_F+$00974C ; hex2dec
        TAX
        LDA tile_numbers,X
        STA !dynamic_stripe_image+4
        INY
        LDA [$00],Y
        STA $0E
        JSL !_F+$00974C ; hex2dec
        PHA
        LDA tile_numbers,X
        STA !dynamic_stripe_image+8
        PLA
        TAX
        LDA tile_numbers,X
        STA !dynamic_stripe_image+10
        INY
        LDA [$00],Y
        STA $0F
        JSR get_fractions_of_time
        PHA
        LDA tile_numbers,X
        STA !dynamic_stripe_image+14
        PLA
        TAX
        LDA tile_numbers,X
        STA !dynamic_stripe_image+16
        JMP .merge_draw
    .in_framecount:
        LDA [$00],Y
        STA $0D
        STA $08
        LDA #$3C ; frames in a second
        STA $4202 ; mult A
        INY
        LDA [$00],Y
        STA $0E
        STA $4203 ; mult B
        INY
        LDA [$00],Y
        STA $0F
        STA $06
        STZ $07
        REP #$20
        LDA #$0000
        LDX $08
      - BEQ +
        CLC
        ADC #$0E10 ; frames in a minute
        DEX
        BRA -
      + CLC
        ADC $4216 ; mult result
        CLC
        ADC $06
        SEP #$20
        PHA
        AND #$0F
        TAX
        LDA tile_numbers,X
        STA !dynamic_stripe_image+12
        PLA
        LSR #4
        TAX
        LDA tile_numbers,X
        STA !dynamic_stripe_image+10
        XBA
        PHA
        AND #$0F
        TAX
        LDA tile_numbers,X
        STA !dynamic_stripe_image+8
        PLA
        LSR #4
        TAX
        LDA tile_numbers,X
        STA !dynamic_stripe_image+6
        LDA #$1F
        STA !dynamic_stripe_image+4
        STA !dynamic_stripe_image+14
        
    .merge_draw
        PLX
        JSR compare_to_gold
        JSR compare_to_platinum
        JSR check_if_used_orb
        JSR load_stripe_from_buffer
        PLY
    
    .continue:
        DEY
        BMI .done
        JMP .loop
        
    .done:
        PLB
        JSR draw_icons
        RTS
    
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
        JMP .continue
    .draw_blank:
        JSR load_blank_time
        JSR load_stripe_from_buffer
        JMP .continue

times_ptrs:
        dl $700000,gold_times,platinum_times
        
get_fractions_of_time:
        PHA
        LDA #$00;.L !status_fractions
        BNE +
        PLA
        TAX
        LDA.L fractional_seconds,X
        BRA ++
      + PLA
     ++ JSL !_F+$00974C ; hex2dec
        RTS
        
load_unran_time:
        PHY
        LDY #$12
      - LDA #$00;.L !status_fractions
        CMP #$02
        BEQ +
        LDA default_time_stripe,Y
        BRA ++
      + LDA default_framecount_stripe,Y
     ++ STA !dynamic_stripe_image,Y
        DEY
        BPL -
        
        PLY
        LDA !potential_translevel
        CMP #!translevel_swap_exit_A
        BEQ +
        CMP #!translevel_swap_exit_B
        BEQ +
        BRA .noshift
      + LDA times_position+4,Y
        BRA .merge
    .noshift:
        LDA times_position,Y
    .merge:
        STA !dynamic_stripe_image+1
        LDA #$00;.L !status_fractions
        CMP #$01
        BNE +
        LDA #$5D
        STA !dynamic_stripe_image+12
      + RTS

load_blank_time:
        PHY
        LDY #$12
      - LDA blank_stripe,Y
        STA !dynamic_stripe_image,Y
        DEY
        BPL -
        
        PLY
        LDA !potential_translevel
        CMP #!translevel_swap_exit_A
        BEQ +
        CMP #!translevel_swap_exit_B
        BEQ +
        BRA .noshift
      + LDA times_position+4,Y
        BRA .merge
    .noshift:
        LDA times_position,Y
    .merge:
        STA !dynamic_stripe_image+1
        RTS

load_stripe_from_buffer:
        PHY
        PHX
        REP #$30
        LDA $7F837B
        TAX
        SEP #$20
        
        LDY #$0000
      - CPY #$0013
        BCS +
        LDA !dynamic_stripe_image,Y
        STA $7F837D,X
        INY
        INX
        BRA -
        
      + REP #$20
        DEX
        TXA
        STA $7F837B
        SEP #$30
        PLX
        PLY
        RTS

compare_to_gold:
        PHB
        PHK
        PLB
        PHX
        PHY
        PHP
        
        REP #$30
        STY $03
        LDA !potential_translevel
        AND #$007F
        ASL #5
        CLC
        ADC $03
        TAX
        DEX
        DEX
        SEP #$20
        INY
        LDA [$00],Y
        AND #%00100000
        BNE .no_gold
        DEY #3
        
        LDA [$00],Y
        CMP gold_times,X
        BCC .yes_gold
        BNE .no_gold
        INY
        INX
        
        LDA [$00],Y
        CMP gold_times,X
        BCC .yes_gold
        BNE .no_gold
        INY
        INX
        
        LDA [$00],Y
        CMP gold_times,X
        BEQ .yes_gold
        BCC .yes_gold
        BRA .no_gold
        
    .yes_gold:
        LDA #$29
        STA !dynamic_stripe_image+5
        STA !dynamic_stripe_image+7
        STA !dynamic_stripe_image+9
        STA !dynamic_stripe_image+11
        STA !dynamic_stripe_image+13
        STA !dynamic_stripe_image+15
        STA !dynamic_stripe_image+17
        
    .no_gold:
        PLP
        PLY
        PLX
        PLB
        RTS

compare_to_platinum:
        PHB
        PHK
        PLB
        PHX
        PHY
        PHP
        
        REP #$30
        STY $03
        LDA !potential_translevel
        AND #$007F
        ASL #5
        CLC
        ADC $03
        TAX
        DEX
        DEX
        SEP #$20
        INY
        LDA [$00],Y
        AND #%00100000
        BNE .no_platinum
        DEY #3
        
        LDA [$00],Y
        CMP platinum_times,X
        BCC .yes_platinum
        BNE .no_platinum
        INY
        INX
        
        LDA [$00],Y
        CMP platinum_times,X
        BCC .yes_platinum
        BNE .no_platinum
        INY
        INX
        
        LDA [$00],Y
        CMP platinum_times,X
        BEQ .yes_platinum
        BCC .yes_platinum
        BRA .no_platinum
        
    .yes_platinum:
        LDA #$2D
        STA !dynamic_stripe_image+5
        STA !dynamic_stripe_image+7
        STA !dynamic_stripe_image+9
        STA !dynamic_stripe_image+11
        STA !dynamic_stripe_image+13
        STA !dynamic_stripe_image+15
        STA !dynamic_stripe_image+17
        
    .no_platinum:
        PLP
        PLY
        PLX
        PLB
        RTS

check_if_used_orb:
        PHB
        PHK
        PLB
        PHX
        PHY
        PHP
        
        REP #$30
        STY $03
        LDA $00
        CLC
        ADC $03
        TAX
        DEX
        DEX
        SEP #$20
        INY
        LDA [$00],Y
        AND #%00100000
        BEQ .no_orb
        
    .yes_orb:
        LDA #$3D
        STA !dynamic_stripe_image+5
        STA !dynamic_stripe_image+7
        STA !dynamic_stripe_image+9
        STA !dynamic_stripe_image+11
        STA !dynamic_stripe_image+13
        STA !dynamic_stripe_image+15
        STA !dynamic_stripe_image+17
        
    .no_orb:
        PLP
        PLY
        PLX
        PLB
        RTS

; draw the little icons for each time type
draw_icons:
        LDA #$50
        STA !dynamic_stripe_image
        LDA #$2D
        STA !dynamic_stripe_image+1
        LDA #$80
        STA !dynamic_stripe_image+2
        LDA #$07
        STA !dynamic_stripe_image+3
        LDA #$A6
        STA !dynamic_stripe_image+4
        LDA #$A7
        STA !dynamic_stripe_image+6
        LDA #$A8
        STA !dynamic_stripe_image+8
        LDA #$A9
        STA !dynamic_stripe_image+10
        LDA !ow_display_times
        TAX
        LDA icon_properties,X
        STA !dynamic_stripe_image+5
        STA !dynamic_stripe_image+7
        STA !dynamic_stripe_image+9
        STA !dynamic_stripe_image+11
        LDA #$FF
        STA !dynamic_stripe_image+12
        JSR load_stripe_from_buffer
        RTS

icon_properties:
        db $39,$29,$2D

; tiles for numbers 0-9,A-F
tile_numbers:
        db $22,$23,$24,$25,$26
        db $27,$28,$29,$2A,$2B
        db $6F,$70,$71,$72,$73,$74

; flags to tell which times to show by default for each level
translevel_types:
        db $00,$0F,$0F,$00
        db $77,$0F,$0F,$07
        db $07,$7F,$FF,$07
        db $0F,$0F,$07,$FF
        db $0F,$0F,$00,$77
        db $07,$FF,$00,$00
        db $0F,$00,$07,$07
        db $0F,$0F,$00,$07
        db $0F,$07,$0F,$FF
        db $7F,$07,$0F,$0F
        db $00,$0F,$0F,$0F
        db $00,$FF,$0F,$0F
        db $00,$07,$07,$77
        db $0F,$07,$0F,$0F
        db $FF,$7F,$0F,$07
        db $FF,$0F,$FF,$07
        db $07,$7F,$77,$FF
        db $FF,$07,$0F,$FF
        db $00,$0F,$0F,$0F
        db $0F,$00,$0F,$0F
        db $0F,$0F,$00,$00
        db $77,$00,$77,$00
        db $EE,$77,$77,$00
        db $00

; the 2nd byte of the stripe image header
times_position:                                
        db $2F,$4F,$6F,$8F
        db $37,$57,$77,$97
        db $2F,$4F,$6F,$8F

; a stripe image that shows -'--.--
default_time_stripe:
        db $50,$FF,$00,$0D
        db $1C,$39,$5D,$39
        db $1C,$39,$1C,$39
        db $1B,$39,$1C,$39
        db $1C,$39,$FF

; a stripe image that shows _----_h
default_framecount_stripe:
        db $50,$FF,$00,$0D
        db $1F,$39,$1C,$39
        db $1C,$39,$1C,$39
        db $1C,$39,$1F,$39
        db $6E,$39,$FF

; a stripe image that shows completely blank
blank_stripe:
        db $50,$FF,$00,$0D
        db $FE,$38,$FE,$38
        db $FE,$38,$FE,$38
        db $FE,$38,$FE,$38
        db $FE,$38,$FF

; a complete set of times for each level for each kind
; having a time better than the one here will result in a gold time
gold_times:
        incbin "bin/overworld_gold_times.bin"

; having a time better than the one here will result in a platinum time
platinum_times:
        incbin "bin/overworld_platinum_times.bin"

; save mario's position on the overworld to sram
save_marios_position:
        LDA $144E ; overworld forward timer
        CMP #$0E
        BNE +
        LDA $1F11
        STA.L !save_overworld_submap
        LDA $1F17
        STA.L !save_overworld_x
        LDA $1F18
        STA.L !save_overworld_x+1
        LDA $1F19
        STA.L !save_overworld_y
        LDA $1F1A
        STA.L !save_overworld_y+1
        LDA $1F13
        STA.L !save_overworld_animation
      + RTS

; draw the icons that represent a saved movie
draw_movie_slots:
        PHP
        PHB
        PHK
        PLB
        
        JSR locate_levels
        
        LDX #$02
      - LDA !level_movie_slots,X
        BEQ .continue
        
        TXA
        ASL #2
        TAY
        LDA slot_tiles,X
        STA $03C2,Y ; tile
        REP #$20
        LDA !level_movie_x_pos,X
        AND #$001F
        ASL #4
        CLC
        ADC slot_offsets,Y
        SEC
        SBC $1E
        BMI .continue
        CMP #$0100
        BCS .continue
        SEP #$20
        STA $03C0,Y ; x
        LDA !level_movie_y_pos,X
        AND #$20
        BEQ +
        LDA $1F11 ; submap
        BEQ .continue
        BRA ++
      + LDA $1F11 ; submap
        BNE .continue
     ++ REP #$20
        LDA !level_movie_y_pos,X
        AND #$001F
        ASL #4
        CLC
        ADC slot_offsets+2,Y
        SEC
        SBC $20
        BMI .continue
        CMP #$00E0
        BCS .continue
        SEP #$20
        STA $03C1,Y ; y
        TXA
        INC A
        ASL A
        ORA #$30
        STA $03C3,Y ; properties
        LDA #$00
        STA $0490,X ; size
        
    .continue:
        SEP #$20
        DEX
        BPL -
        
        PLB
        PLP
        RTS

slot_tiles:
        db $BD,$BE,$BF
slot_offsets:
        dw $0008,$000C,$000F,$0005,$FFFF,$0009

; find the x and y locations of each level that has a movie
locate_levels:
        PHB
        PHK
        PLB
        LDY #$02
      - LDA !level_movie_slots,Y
        BEQ +
        ASL A
        TAX
        LDA translevel_locations,X
        STA !level_movie_y_pos,Y
        LDA translevel_locations+1,X
        STA !level_movie_x_pos,Y
      + DEY
        BPL -
        PLB
        RTS

translevel_locations:
        dw $0000,$0C03,$0E03,$0508,$050A,$090A,$0B0C,$0D0C
        dw $010D,$030D,$050E,$1003,$1403,$1603,$1A03,$1405
        dw $1705,$1408,$100F,$0710,$0211,$0511,$0712,$0517
        dw $0E17,$0319,$0C1B,$0F1B,$0C1D,$0F1D,$1410,$1610
        dw $1812,$1516,$1816,$131B,$151B,$0922,$0B24,$0926
        dw $0627,$0328,$0928,$082C,$002E,$032E,$0C2E,$1021
        dw $1423,$1723,$1923,$1425,$1725,$1925,$1227,$1427
        dw $1727,$1927,$1B27,$1729,$0830,$0C30,$0532,$0A32
        dw $0C32,$0637,$0837,$043A,$0A3A,$0C3A,$043C,$083C
        dw $1131,$1331,$1631,$1931,$1C31,$1133,$1333,$1633
        dw $1933,$1C33,$1736,$1238,$1538,$1738,$1938,$1C38
        dw $143A,$1A3A,$173B,$123D,$1C3D
