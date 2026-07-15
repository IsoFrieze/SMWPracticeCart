ORG !_F+$108000

reset bytes

; this code is run once on the frame that Mario appears (a frame after the mosaic effect finishes)
level_mario_appear:
        LDA $0D9B ; boss flag
        CMP #$C1 ; bowser fight
        BNE +

        LDA #$01
        STA $11 ; IRQType
        LDA #$09
        STA $3E ; MainBGMode
        LDA #$54
        STA $2107 ; HW_BG1SC
        LDA #$59
        STA $2108 ; HW_BG2SC
        LDA #$48
        STA $2112 ; HW_BG3VOFS
        LDA #$03
        STA $2112 ; HW_BG3VOFS
        LDA #$B7
        STA $4209 ; HW_VTIME
        STZ $420A ; HW_VTIME+1
        STZ !bowser_layer1_y_pos
        STZ !bowser_layer1_y_pos+1
        
        JSR setup_bowser_phase
        JSL upload_bowser_graphics
      + JSR playback_buffered_inputs
        JSR try_midway_advance
        RTL
        
; if required, set up the appropriate bowser fight phase
; also place a stunned mechakoopa in the middle of the screen
setup_bowser_phase:
        ; this is #1 if advancing from start to phase 2,
        ; #8 if advancing from phase 2 to 3, and #9 if
        ; 'advancing' from phase 3 (don't advance)
        LDA !bowser_phase_tracker
        BNE +
        RTS
        
      + TAX
        LDA.L bowser_advancing_phases,X
        STA $14B4 ; bowser phase
        LDA #$03
        STA $1525 ; bowser routine
        STZ $14B0 ; bowser timer
        LDA #$0E
        STA $1579 ; bowser animation
        
        LDA #$A2 ; mechakoopa
        STA $9E ; sprite number,0
        LDA #$09
        STA $14C8 ; sprite status
        LDA #$FF
        STA $1540 ; stun timer
        STA $C2 ; frame timer
        STZ $AA ; y speed
        STZ $B6 ; x speed
        STZ $14E0 ; high x pos
        STZ $14D4 ; high y pos
        LDA #$78
        STA $E4 ; low x pos
        LDA #$B0
        STA $D8 ; low y pos
        LDA #$10
        STA $1656 ; tweaker a
        LDA #$3B
        STA $1662 ; tweaker b
        LDA #$BB
        STA $166E ; tweaker c
        LDA #$19
        STA $167A ; tweaker d
        LDA #$01
        STA $1686 ; tweaker e
        
        RTS
        
bowser_advancing_phases:
        db $00,$07,$00,$00,$00,$00,$00,$08,$08,$08

; when entering a mode 7 boss area, retrigger button presses
playback_buffered_inputs:
        LDA $2A ; mode 7 center
        BEQ +
        LDA !in_playback_mode
        BEQ +
        STZ !util_byetudlr_hold
        STZ !util_byetudlr_hold+1
        STZ !util_axlr_hold
        STZ !util_axlr_hold+1
      + RTS

; if we did buffer a reset, activate it here
try_midway_advance:
        LDA !start_midway
        BEQ +
        JSL activate_midway_entrance
      + RTS

print "inserted ", bytes, "/32768 bytes into bank $10"