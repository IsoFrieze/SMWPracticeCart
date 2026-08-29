FastMode_header_locations:
        dd !fast_mode_save_1_header
        dd !fast_mode_save_2_header
        dd !fast_mode_save_3_header
        dd #ALL_CASTLES_SAVE

FastMode_save_locations:
        dd !fast_mode_save_1
        dd !fast_mode_save_2
        dd !fast_mode_save_3
        dd #ALL_CASTLES_SAVE+$10

ALL_CASTLES_SAVE:
        incbin "bin/routes/AllCastles.smwroute"

reset_header:
        PHB
        PHK
        PLB
        LDX #$0F
        LDA !status_fast_mode
        CMP #$01
        BNE +
        
      - LDA #$00
        STA !fast_mode_save_1_header,X
        STA !fast_mode_save_current_header,X
        DEX
        BPL -
        JMP .done
        
      + CMP #$02
        BNE +
        
      - LDA #$00
        STA !fast_mode_save_2_header,X
        STA !fast_mode_save_current_header,X
        DEX
        BPL -
        JMP .done
        
      + CMP #$03
        BNE +
        
      - LDA #$00
        STA !fast_mode_save_3_header,X
        STA !fast_mode_save_current_header,X
        DEX
        BPL -
        JMP .done
        
      + 
      - LDA #$0
        STA !fast_mode_save_1_header,X
        STA !fast_mode_save_2_header,X
        STA !fast_mode_save_3_header,X
        DEX
        BPL -
        
    .done:
        PLB
        RTL


; Retrieves current header from either save 1,2,3 based on status_fastmode
; stores to FastMode_save_current_header
; on exit: A=0, if invalid, a=1 if valid
;          x = 0 if save 1 -- 4 if save 2 -- 8 if save 3
retrieve_current_header:
        PHB
        PHK
        PLB
        LDA !status_fast_mode
        BNE +
        JMP .done_fail

      + DEC 
        ASL #2
        TAX
        LDA FastMode_header_locations+0,X
        STA $00
        LDA FastMode_header_locations+1,X
        STA $01
        LDA FastMode_header_locations+2,X
        STA $02

        LDY #$0F
      - LDA [$00],Y
        STA !fast_mode_save_current_header,Y
        DEY
        BPL -
        
    .done_success:
        PLB
        LDA #$01
        RTL
    .done_fail:
        PLB
        LDA #$00
        RTL

;Also retrieves header while called
retrieve_current_level:
        PHB
        PHK
        PLB
        JSL retrieve_current_header
        BNE +
        JMP .done_fail
        
      + LDA FastMode_save_locations,X
        STA $00
        LDA FastMode_save_locations+1,X
        STA $01
        LDA FastMode_save_locations+2,X
        STA $02

        LDA !fast_mode_current_level
        CMP !fast_mode_save_current_header+0
        BCC +
        JMP .done_fail
        
      + REP #$30
        AND #$00FF
        STA $03
        ASL #2
        CLC
        ADC $03
        ASL A ; x10
        TAY
        SEP #$20

        LDA [$00],Y ; translevel
        STA !fast_mode_save_current_level+0
        
        INY
        LDA [$00],Y ; item box start
        STA !fast_mode_save_current_level+1

        INY
        LDA [$00],Y ; item box end
        STA !fast_mode_save_current_level+2

        INY
        LDA [$00],Y ; powerup start
        STA !fast_mode_save_current_level+3

        INY
        LDA [$00],Y ; powerup end
        STA !fast_mode_save_current_level+4

        INY
        LDA [$00],Y ; yoshi start
        STA !fast_mode_save_current_level+5

        INY
        LDA [$00],Y ; yoshi end
        STA !fast_mode_save_current_level+6

        INY 
        LDA [$00],Y ; --msgybr
        TAX
        AND #$01
        STA !fast_mode_save_current_level+7
        TXA : LSR : TAX : AND #$01
        STA !fast_mode_save_current_level+8
        TXA : LSR : TAX : AND #$01
        STA !fast_mode_save_current_level+9
        TXA : LSR : TAX : AND #$01
        STA !fast_mode_save_current_level+10
        TXA : LSR : TAX : AND #$01
        STA !fast_mode_save_current_level+11
        TXA : LSR : TAX : AND #$01
        STA !fast_mode_save_current_level+12
        
        INY
        LDA [$00],Y ; eeeexpyi
        TAX
        AND #$01
        STA !fast_mode_save_current_level+14
        TXA : LSR : TAX : AND #$01
        STA !fast_mode_save_current_level+15
        TXA : LSR : TAX : AND #$01
        STA !fast_mode_save_current_level+16
        TXA : LSR : TAX : AND #$01
        STA !fast_mode_save_current_level+17
        TXA : LSR
        STA !fast_mode_save_current_level+13

;        INY
;        LDA [$00],Y ; reserved
        
    .done_success:
        SEP #$30
        PLB
        LDA #$01
        RTL
        
    .done_fail:
        SEP #$30
        PLB
        LDA #$00
        RTL

store_current_header:
        PHB
        PHK
        PLB
        LDA !status_fast_mode
        BNE +
        JMP .done_fail
            
      + DEC 
        ASL #2
        TAX
        LDA FastMode_header_locations+0,X
        STA $00
        LDA FastMode_header_locations+1,X
        STA $01
        LDA FastMode_header_locations+2,X
        STA $02

        LDY #$0F
      - LDA !fast_mode_save_current_header,Y
        STA [$00],Y
        DEY
        BPL -

    .done_success:
        PLB
        LDA #$01
        RTL
        
    .done_fail
        PLB
        LDA #$00
        RTL

; Also stores header while called
store_current_level:
        PHB
        PHK
        PLB
        JSL store_current_header
        BNE +
        JMP .done_fail
        
      + LDA FastMode_save_locations,X
        STA $00
        LDA FastMode_save_locations+1,X
        STA $01
        LDA FastMode_save_locations+2,X
        STA $02

        LDA !fast_mode_current_level
        REP #$30
        AND #$00FF
        STA $03
        ASL #2
        CLC
        ADC $03
        ASL A ; x10
        TAY
        SEP #$20

        LDA !fast_mode_save_current_level+0 ; translevel
        STA [$00],Y

        INY
        LDA !fast_mode_save_current_level+1 ; item box start
        STA [$00],Y

        INY
        LDA !fast_mode_save_current_level+2 ; item box end
        STA [$00],Y

        INY
        LDA !fast_mode_save_current_level+3 ; powerup start
        STA [$00],Y

        INY
        LDA !fast_mode_save_current_level+4 ; powerup end
        STA [$00],Y

        INY
        LDA !fast_mode_save_current_level+5 ; yoshi start
        STA [$00],Y

        INY
        LDA !fast_mode_save_current_level+6 ; yoshi end
        STA [$00],Y

        LDA !fast_mode_save_current_level+12 ; midway
        AND #$01 : ASL : STA $03
        LDA !fast_mode_save_current_level+11 ; special
        AND #$01 : ORA $03 : ASL : STA $03
        LDA !fast_mode_save_current_level+10 ; green
        AND #$01 : ORA $03 : ASL : STA $03
        LDA !fast_mode_save_current_level+09 ; yellow
        AND #$01 : ORA $03 : ASL : STA $03
        LDA !fast_mode_save_current_level+08 ; blue
        AND #$01 : ORA $03 : ASL : STA $03
        LDA !fast_mode_save_current_level+07 ; red
        AND #$01 : ORA $03 : STA $03
        INY
        STA [$00],Y

        LDA !fast_mode_save_current_level+13 ; exit type
        ASL : STA $03
        LDA !fast_mode_save_current_level+17 ; exit type required
        AND #$01 : ORA $03 : ASL : STA $03
        LDA !fast_mode_save_current_level+16 ; powerup required
        AND #$01 : ORA $03 : ASL : STA $03
        LDA !fast_mode_save_current_level+15 ; yoshi required
        AND #$01 : ORA $03 : ASL : STA $03
        LDA !fast_mode_save_current_level+14 ; item box required
        AND #$01 : ORA $03 : STA $03
        INY
        STA [$00],Y

    .done_success:
        SEP #$30
        PLB
        LDA #$01
        RTL
        
    .done_fail:
        SEP #$30
        PLB
        LDA #$00
        RTL

menu_nmi_draw_tiles:
        LDA #$80
        STA $2115  
        REP #$10
        LDX #!menu_tile_upload_location ;Source Offset into source bank
        STX $4302       ;Set Source address lower 16-bits
        LDA #00         ;Source bank
        STA $4304       ;Set Source address upper 8-bits
        LDX !menu_tile_upload_bytes   ;# of bytes to copy (16k)
        BEQ .done
        STX $4305       ;Set DMA transfer size
        LDA #$16        ;$2118 is the destination, so
        STA $4301       ;  set lower 8-bits of destination to $18
        LDA #$04        ;Set DMA transfer mode: auto address increment
        STA $4300       ;  using write mode 1 (meaning write a word to $2118/$2119)
        LDA #$01        ;The registers we've been setting are for channel 0
        STA $420B       ;  so Start DMA transfer on channel 0 (LSB of $420B)
    .done:
        SEP #$30
        STZ !menu_tile_upload_bytes
        STZ !menu_tile_upload_bytes+1
        RTL

FastMode_add_level:
        LDA !potential_translevel
        BNE +
        BRL .done
        
      + PHX
        JSL retrieve_current_header
        PLX
        
        LDA !fast_mode_save_current_header+0
        CMP.B #!fast_mode_max_route_length ; full
        BCC +
        LDA #$2A ; wrong sound
        STA $1DFC ; apu i/o
        BRL .done
        
      + STA !fast_mode_current_level
        INC !fast_mode_save_current_header+0
        
        LDA !potential_translevel
        STA !fast_mode_save_current_level+0

        LDA !status_itembox
        STA !fast_mode_save_current_level+1

        LDA #$00 ; end itembox
        STA !fast_mode_save_current_level+2
        
        LDA !status_powerup
        STA !fast_mode_save_current_level+3
        
        LDA #$00 ; end powerup
        STA !fast_mode_save_current_level+4

        LDA !status_yoshi
        STA !fast_mode_save_current_level+5

        LDA #$00 ; end yoshi
        STA !fast_mode_save_current_level+6

        LDA $1F2A
        STA !fast_mode_save_current_level+7

        LDA $1F29
        STA !fast_mode_save_current_level+8

        LDA $1F28
        STA !fast_mode_save_current_level+9
        
        LDA $1F27
        STA !fast_mode_save_current_level+10

        LDA !status_special
        STA !fast_mode_save_current_level+11

        LDA #$00
        STA !fast_mode_save_current_level+12 ; midway
        STA !fast_mode_save_current_level+14 ; item box required
        STA !fast_mode_save_current_level+15 ; yoshi required
        STA !fast_mode_save_current_level+16 ; powerup required
        
        LDA #$01
        STA !fast_mode_save_current_level+17 ; exit type required

        ; exit type
        STX !fast_mode_save_current_level+13
        
        JSL store_current_level

        LDA #$02 ; bop sound
        STA $1DF9 ; apu i/o
        
    .done:
        SEP #$30
        RTL

submap_table:
        db $ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        db $00,$00,$ff,$00,$00,$00,$00,$ff,$00,$ff,$00,$00,$00,$00,$ff,$00
        db $00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$04
        db $04,$04,$04,$04,$04,$04,$ff,$04,$04,$04,$04,$04,$02,$02,$02,$02
        db $02,$03,$03,$03,$03,$03,$03,$03,$05,$05,$05,$05,$05,$05,$05,$05
        db $05,$05,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06

ResetLevel:
        JSL retrieve_current_level

        LDA !fast_mode_save_current_level+1
        STA $0DC2 ;Item

        LDA !fast_mode_save_current_level+2
        STA !status_fast_mode_end_item

        LDA !fast_mode_save_current_level+3
        STA $19 ;Powerup

        LDA !fast_mode_save_current_level+4
        STA !status_fast_mode_end_powerup

        LDA !fast_mode_save_current_level+5
        STA !status_yoshi
        STA $0DC1 ; Yoshi
        STZ !level_is_no_yoshi
        LDX #$12
        
      - LDA.L no_yoshi_translevels,X
        CMP !fast_mode_save_current_level+0
        BEQ .remove_yoshi
        DEX
        BPL -
        BRA +
        
    .remove_yoshi:
        STZ $0DBA
        STZ $0DC1
        INC !level_is_no_yoshi
        
      + JSL save_yoshi_color

        LDA !fast_mode_save_current_level+6
        STA !status_fast_mode_end_yoshi

        LDA !fast_mode_save_current_level+7
        STA $1F2A

        LDA !fast_mode_save_current_level+8
        STA $1F29

        LDA !fast_mode_save_current_level+9
        STA $1F28

        LDA !fast_mode_save_current_level+10
        STA $1F27

        LDA !fast_mode_save_current_level+11
        STA !status_special

        LDA !fast_mode_save_current_level+12
        STA !midway_enable_flag

        LDA !fast_mode_save_current_level+13
        STA !status_fast_mode_exit_type

        LDA #$07    ;\
        STA $1F21   ; | Set Mario's overworld position to a known value.
        LDA #$06    ; |  
        STA $1F1F   ;/

        LDA.L !fast_mode_save_current_level+0   ;translevel
        STA $13BF
        STA $7ED076    ; Overworld tile used in level loading routine. Main map/submap
        STA $7ED476    ; Address calculated from Mario's overworld position

        TAX
        LDA.L submap_table,X   ; Submap
        STA $13C3
        STA $1F11

        STZ $0DDA
        STZ $13C6
        STZ $0109
        STZ $141A
        STZ $141D
        STZ $0DD5
        LDA #$FF
        STA $0101
        STA $0102
        STA $0103

        RTL

attempt_level_advance:
        LDA !fast_mode_start_play
        BEQ .no_advance_hop
        
        LDA #$00; !status_fast_mode_difficulty
        CMP #$00
        BEQ .check_advance_mode_0
        CMP #$01
        BEQ .check_advance_mode_1
        CMP #$02
        BEQ .check_advance_mode_2
        BRA .next_level_hop

    .check_advance_mode_0:
        LDA !level_finished
        BNE .next_level_hop
        LDA !status_fast_mode_exit_type
        CMP #$02
        BEQ .start_select
        CMP #$03
        BEQ .death
        BRA .no_advance_hop
        
    .start_select:
        LDA $0DD5
        CMP #$81
        BEQ .next_level_hop
        BRA .no_advance_hop
    .death:
        LDA $0DD5
        CMP #$82
        BEQ .next_level_hop
        BRA .no_advance_hop
        
    .check_advance_mode_1:
        LDA !status_fast_mode_exit_type
        CMP #$00
        BNE +
        LDA !level_finished
        BEQ .no_advance_hop
        LDA !most_recent_exit
        CMP #$00
        BNE .no_advance_hop
        BRA .next_level_hop
        
      + CMP #$01
        BNE +
        LDA !level_finished
        BEQ .no_advance_hop
        LDA !most_recent_exit
        CMP #$01
        BNE .no_advance_hop
        BRA .next_level_hop
        
      + CMP #$02
        BNE +
        LDA $0DD5
        CMP #$81
        BNE .no_advance_hop
        
    .next_level_hop:
        BRA .next_level
        
      + CMP #$03
        BNE .next_level ; shouldn't happen
        LDA $0DD5
        CMP #$82
        BEQ .next_level
        
    .no_advance_hop:
        BRA .no_advance

    .check_advance_mode_2:
        LDA !status_fast_mode_end_item
        BEQ +
        CMP $0dc2
        BNE .no_advance
        
      + LDA !status_fast_mode_end_powerup
        BEQ +
        CMP $19
        BNE .no_advance
        
      + LDA !status_fast_mode_end_yoshi
        BEQ +
        LDA !level_is_no_yoshi
        BNE +
        LDA $187a
        BEQ .no_advance
        
      + LDA !status_fast_mode_exit_type 
        CMP #$00
        BNE +
        LDA !level_finished
        BEQ .no_advance
        LDA !most_recent_exit
        CMP #$00
        BNE .no_advance
        BRA .next_level
        
      + CMP #$01
        BNE +
        LDA !level_finished
        BEQ .no_advance
        LDA !most_recent_exit
        CMP #$01
        BNE .no_advance
        BRA .next_level
            
      + CMP #$02
        BNE +
        LDA $0dd5
        CMP #$81
        BNE .no_advance
        BRA .next_level
        
      + CMP #$03
        BNE .next_level
        LDA $0dd5
        CMP #$82
        BNE .no_advance
        BRA .next_level

    .next_level:
        INC !fast_mode_current_level   ; Next level
        LDA !fast_mode_current_level   
        CMP !fast_mode_save_current_header+0
        BCC .finished
        LDA #00
        RTL
        
    .finished:
    .no_advance:
        LDA #$01
        RTL


fade_to_overworld:
        LDA !status_fast_mode
        BEQ .done
        
        LDA !fast_mode_start_play
        BEQ .done
        
        LDA !util_byetudlr_hold
        AND #$10 ; hold start to exit the run early
        BEQ .start_play
        
        LDA #$FF
        STA !total_frames ; don't show the final time if you quit
        
        BRA .stop_play
    .start_play:
        JSL attempt_level_advance
        BEQ .stop_play
        
        LDA #$E9
        STA $0109
        RTL
        
    .stop_play:
        LDA #$00
        STA !fast_mode_start_play
        STA !midway_enable_flag
        STA $0109
        JSL set_overworld_position   
        
    .done:
        LDA !restore_status_from_backup
        BEQ +
        LDA #$00
        STA !restore_status_from_backup
        LDX #!number_of_options
      - LDA.L !backup_status_table,X
        STA.L !status_table,X
        DEX
        BPL -
        JSL restore_basic_settings

      + RTL


pre_level_loading:
        LDA $0109
        CMP #$E9
        BNE .done
;        LDA #$01
;        STA !status_fast_mode

        JSL ResetLevel
    .done:
        RTL

draw_original_statusbar:
        RTL

draw_FastMode_level_tiles:
        PHP
        PHB
        PHK
        PLB
        
;        JSR locate_levels
        
        LDA !status_fast_mode
        BNE +
        JMP .done
        
      + LDA !fast_mode_save_1_header+0
        BNE +
        JMP .done
            
      + LDA !fast_mode_tile_timer 
        CMP !fast_mode_save_1_header+0
        BCC .counter_overflow
        LDA #$00
        STA !fast_mode_tile_timer
        BRA +
        
    .counter_overflow:
        LDA !fast_mode_tile_timer
        INC !fast_mode_tile_timer

      + REP #$30                          ; A, X/Y 16 bit
        AND #$00FF
;        BEQ .done
        ASL #3
        TAX                               ; X <- FastMode Level Index
        SEP #$20                          ; A: 8 bit X/Y 16 bit
        LDA !fast_mode_save_1+0,X            ; Load Translevel to A
        LDY #$0000                        ; Clear upper byte of Y
        ASL
        TAY                               
        LDA translevel_locations_2+1,Y        ;$00 -> X Pos
        STA $00
        LDA translevel_locations_2+0,Y        ;$01 -> Y Pos
        STA $01

        LDA slot_tiles
        STA $03C2 ; tile
        REP #$20
        LDA $00
        AND #$001F
        ASL #4
        CLC
        ADC slot_offsets
        SEC
        SBC $1E
        BMI .continue
        CMP #$0100
        BCS .continue
        SEP #$20
        STA $03C0 ; x
        LDA $01
        AND #$20
        BEQ +
        LDA $1F11 ; submap
        BEQ .continue
        BRA ++
      + LDA $1F11 ; submap
        BNE .continue
     ++ REP #$20
        LDA $01
        AND #$001F
        ASL #4
        CLC
        ADC slot_offsets+2
        SEC
        SBC $20
        BMI .continue
        CMP #$00E0
        BCS .continue
        SEP #$20
        STA $03C1 ; y
        TXA
        INC A
        ASL A
        ORA #$30
        STA $03C3 ; properties
        LDA #$00
        STA $0490 ; size
    .continue:
    .done:
        SEP #$30
        
        PLB
        PLP
        RTL

translevel_locations_2:
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

; add the time of the current level to the run timer
; no matter how the level was exited
accumulate_fastmode_time:
        LDA.L !status_region
        CMP #$02
        BCS .pal_frames
    .ntsc_frames:
        LDA !level_timer_frames
        CLC
        ADC !total_frames
        CMP #60
        BCC .seconds
        SBC #60
        BRA .seconds
        
    .pal_frames:
        LDA !level_timer_frames
        CLC
        ADC !total_frames
        CMP #50
        BCC .seconds
        SBC #50
        BRA .seconds
    
    .seconds:
        STA !total_frames
        
        LDA !level_timer_seconds
        ADC !total_seconds
        CMP #60
        BCC .minutes
        SBC #60
        
    .minutes:
        STA !total_seconds
        
        LDA !level_timer_minutes
        ADC !total_minutes
        CMP #60
        BCC .hours
        SBC #60
        
    .hours:
        STA !total_minutes
        
        LDA #$00
        ADC !total_hours
        STA !total_hours
        
        RTL

; display the run time front and center
display_fastmode_run_time:
        LDA !total_hours
        JSL !_F+$00974C ; hex2dec
        STX !status_bar+$22
        STA !status_bar+$23
        
        LDA !total_minutes
        JSL !_F+$00974C ; hex2dec
        STX !status_bar+$25
        STA !status_bar+$26
        
        LDA !total_seconds
        JSL !_F+$00974C ; hex2dec
        STX !status_bar+$28
        STA !status_bar+$29
        
        LDA !total_frames
        JSL convert_frames_to_centiseconds
        JSL !_F+$00974C ; hex2dec
        STX !status_bar+$2B
        STA !status_bar+$2C
        
        LDA #$78
        STA !status_bar+$24
        STA !status_bar+$27
        LDA #$24
        STA !status_bar+$2A
        
        RTL

; on overworld load, if just finished a run,
; display the time on the top left
display_fast_mode_finish_time:
        PHP
        LDA !total_frames
        BMI .nope ; no run
        LDA $0DD5
        BMI .nope ; run aborted
        
        REP #$30
        LDA.L $7F837B ; size
        TAX
        LDA #$E350
        STA.L $7F837D,X ; stripe
        INX #2
        LDA.W #$1500
        STA.L $7F837D,X ; stripe
        INX #2
        
        SEP #$20
        LDY #$0000
      - LDA !status_bar+$22,Y
        STA.L $7F837D,X ; stripe
        INX
        LDA #$3C
        STA.L $7F837D,X ; stripe
        INX
        INY
        CPY.W #$0B
        BNE -
        
        LDA #$FF
        STA !total_frames ; don't draw it again
        STA.L $7F837D,X ; stripe
        STA.L $7F837D+1,X ; stripe
        TXA
        STA.L $7F837B ; size
        
    .nope:
        PLP
        RTL