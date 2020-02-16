ORG !_F+$178000

reset bytes

; this code is run on every single frame of execution
every_frame:
        PHP
        SEP #$20
;       JSR stack_overflow
        JSR update_dropped_frames
;       JSR check_kill
        
        LDA !in_overworld_menu
        BEQ +
        JSL update_background
      + PLP
        
        LDA $2137 ; latch h/v counter
        LDA $213D ; v counter
        STA !lagometer_line
        
        RTL
        
update_lagometer:
        LDA.L !status_lagometer
        BEQ +
        LDA $0100 ; game mode
        CMP #$14
        BNE +
        
        LDA #$04
        STA $0200 ; xpos
        LDA !lagometer_line
        STA $0201 ; ypos
        LDA #$3D
        STA $0202 ; tile
        LDA #$38
        STA $0203 ; prop
        STZ $0420 ; size
        
      + STZ $4300
        REP #$20
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

print "inserted ", bytes, "/32768 bytes into bank $17"