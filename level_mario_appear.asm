ORG $108000

; this code is run once on the frame that Mario appears (a frame after the mosaic effect finishes)
level_mario_appear:
		STZ !dropped_frames
		STZ !dropped_frames+1
		JSL upload_bowser_timer_graphics
		RTL