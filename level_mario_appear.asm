ORG $108000

; this code is run once on the frame that Mario appears (a frame after the mosaic effect finishes)
level_mario_appear:
		JSL upload_bowser_timer_graphics
		RTL