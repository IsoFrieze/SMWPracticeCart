ORG !_F+$178000

; this code is run on every single frame of execution
every_frame:
        PHP
        SEP #$20
        JSR stack_overflow
        JSR update_dropped_frames
        JSR check_kill
        
        LDA !in_overworld_menu
        BEQ +
        JSL update_background
      + PLP
        RTL
        
; get the number of frames dropped this execution frame, and update the total
update_dropped_frames:
        LDA !counter_sixty_hz
        SEC
        SBC !previous_sixty_hz
        STA !real_frames
        DEC A
        REP #$20
        AND #$00FF
        CLC
        ADC !dropped_frames
        STA !dropped_frames
        SEP #$20
        LDA !counter_sixty_hz
        STA !previous_sixty_hz
        RTS

; check if stack overflowed as a failsafe
stack_overflow:
        PHP
        REP #$10
        TSX
        CPX #$0110
        BCS +
        BRK #$BD
      + PLP
        RTS

; press ABXYLR + up to force a bsod
check_kill:
        LDA !util_byetudlr_hold
        CMP #%11001000
        BNE +
        LDA !util_axlr_hold
        CMP #%11110000
        BNE +
        BRK #$C8
      + RTS
