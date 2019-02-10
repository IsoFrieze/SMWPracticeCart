ORG !_F+$108000

reset bytes

; this code is run once on the frame that Mario appears (a frame after the mosaic effect finishes)
level_mario_appear:
        JSL upload_bowser_timer_graphics
        JSR playback_buffered_inputs
        JSR try_midway_advance
        RTL

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