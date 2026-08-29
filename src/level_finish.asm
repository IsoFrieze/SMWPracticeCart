ORG !_F+$138000

reset bytes

; this code is run once on the frame that the level is completed
; X = 1 if the secret exit was activated, 0 otherwise
level_finish:
        PHP
        STX !most_recent_exit
        LDA #$01
        STA !freeze_timer_flag
        STA !level_finished
        JSL set_time_save_address
        JSL add_additional_finish_time
        JSL display_meters_wrapper
        
        LDA !fast_mode_start_play
        BEQ +
        
        JSL accumulate_fastmode_time
        JSL display_fastmode_run_time
        LDA #$0B ; End level quicker in fast mode
        STA $0100
           
      + PLP
        RTL
; test if level completed this frame
; X = 0 for normal exit, 1 for secret exit
; return 1 in A for finished, 0 for not finished
test_last_frame:
        LDA !level_finished
        BNE .exit
        LDX $141C ; secret flag
        LDA $9E ; sprite id
        CMP #$C5
        BNE +
        LDX #$01
      + LDA $1493 ; end level timer
        BNE .trigger
        LDA $190D ; bowser dead
        BNE .trigger
        LDX #$01
        LDA $1434 ; keyhole timer
        BNE .trigger
        LDA $1B95 ; wings flag
        BEQ .exit
        LDA $0DD5 ; exit level flag
        CMP #$01
        BNE .exit
        LDX #$00
        BRA .trigger
    .exit:
        LDA #$00
        RTL
        
    .trigger:
        JSL level_finish
        LDA #$01
        RTL

; set the appropriate pointer corresponding to this level and exit
; X = 1 if the secret exit was activated, 0 otherwise
set_time_save_address:
        LDA $1B95 ; wings flag
        BEQ .check_splice
        LDA $0DD5 ; level complete flag
        CMP #$01
        BEQ .continue
        BRA .not_complete
    .check_splice:
        LDA.L !spliced_run
        BEQ .continue
    .not_complete:
        LDA #$FF
        STA !save_timer_address+2
        BRA .done
    .continue:
        LDA #$70
        STA !save_timer_address+2
        REP #$20
        STZ !save_timer_address
        LDA $13BF ; translevel
        AND #$007F
        ASL #5
        TSB !save_timer_address ; apply level number
        SEP #$20
        TXA
        ASL #4
        TSB !save_timer_address ; apply exit
    .done:
        RTL

; add time to the timer to make up for end level fanfares.
; this is because some versions of completing the level are faster even though they take longer rta.
add_additional_finish_time:
        LDA $190D
        BNE .end_bowser
        LDA $1423
        BNE .end_switch
        LDA $1434
        BNE .end_key
        LDA $1B95
        BNE .end_wings
        LDA $13C6
        BNE .end_boss
        LDA $1925
        TAX
        LDA.L vertical_level_modes,X
        BNE .end_orb_tape_vert
        BRA .end_orb_tape_horiz
        
    .end_wings:
        LDA #$1F
        JSL add_many_to_timer
        BRA .done
    .end_key:
        LDA #$95
        JSL add_many_to_timer
        BRA .done
    .end_switch:
    .end_boss:
        LDA #$C0
        JSL add_many_to_timer
        LDA #$C0
        JSL add_many_to_timer
        LDA #$C0
        JSL add_many_to_timer
        LDA #$79
        JSL add_many_to_timer
        BRA .done
    .end_orb_tape_horiz:
        LDA #$C0
        JSL add_many_to_timer
        LDA #$C0
        JSL add_many_to_timer
        LDA #$C0
        JSL add_many_to_timer
        LDA #$14
        JSL add_many_to_timer
        BRA .done
    .end_orb_tape_vert:
        LDA #$C0
        JSL add_many_to_timer
        LDA #$C0
        JSL add_many_to_timer
        LDA #$9A
        JSL add_many_to_timer
        BRA .done
    .end_bowser:
    .done:
        RTL

; add time to the timer to make up for death and start/select
; used for fast mode runs when you fail a level as penalty
add_additional_exit_time:
        LDA $0DD5
        CMP #$81
        BEQ .start_select
        CMP #$82
        BEQ .death
        RTL
        
    .start_select:
        LDA #$1F
        JSL add_many_to_timer
        BRA .done
        
    .death:
        LDA #$C0
        JSL add_many_to_timer
        LDA #$19
        JSL add_many_to_timer
        
    .done:
        RTL
        
vertical_level_modes:
        db $00,$00,$00,$01,$01,$00,$00,$01
        db $01,$00,$01,$00,$00,$01,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$00

print "inserted ", bytes, "/32768 bytes into bank $13"