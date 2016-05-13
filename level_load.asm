ORG $128000

; this code is run once on level load (during the black screen)
level_load:
		PHP
		PHB
		PHK
		PLB
		SEP #$20
		
		LDA !l_r_function
		BEQ .just_entered_level
		
	.just_entered_level:
		LDA #$FF
		STA !held_item_slot
		STZ !dropped_frames
		STZ !dropped_frames+1
		STZ !l_r_function
		
		PLB
		PLP
		RTL