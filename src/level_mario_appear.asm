ORG $108000

; this code is run once on the frame that Mario appears (a frame after the mosaic effect finishes)
level_mario_appear:
		JSL upload_bowser_timer_graphics
		JSR playback_buffered_inputs
		JSR try_midway_advance
		RTL

; when entering a mode 7 boss area, retrigger button presses
playback_buffered_inputs:
		LDA $2A ; mode 7 center
		BEQ .done
		LDA !in_playback_mode
		BEQ .done
		STZ $0DA2
		STZ $0DA3
		STZ $0DA4
		STZ $0DA5
	.done:
		RTS

; if we did buffer a reset, activate it here
try_midway_advance:
		LDA !start_midway
		BEQ .done
		JSL activate_midway_entrance
		
	.done:
		RTS