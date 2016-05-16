!dropped_frames    = $FB ; 2 bytes, 16-bit value
!real_frames       = $FD
!previous_sixty_hz = $FE
!counter_sixty_hz  = $FF

ORG $168000

; this code is run on every NMI; therefore, it is guaranteed to run 60 times per second, even if the game is lagging
nmi_expand:
		INC !counter_sixty_hz
		LDA $0100 ; game mode
		CMP #$1F ; overworld menu
		BNE .test_level_fade
		
		LDX !current_selection
		JSL draw_menu_selection
		PHX
		DEX
		CPX #$FF
		BNE .no_left_wrap
		LDX #!number_of_options-1
	.no_left_wrap:
		JSL draw_menu_selection
		PLX
		INX
		CPX #!number_of_options
		BNE .no_right_wrap
		LDX #$00
	.no_right_wrap:
		JSL draw_menu_selection
		BRA .done
		
	.test_level_fade:
		CMP #$13 ; level fade in
		BNE .done
		JSL load_slots_graphics
		
	.done:
		RTL