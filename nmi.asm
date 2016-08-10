ORG $168000

; this code is run on every NMI; therefore, it is guaranteed to run 60 times per second, even if the game is lagging
nmi_expand:
		INC !counter_sixty_hz
		
		LDA $0100
		CMP #$13 ; level fade in
		BNE .done
		JSL load_slots_graphics
		
	.done:
		RTL