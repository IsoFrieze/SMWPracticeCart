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
		
controller_update:
		LDA !in_playback_mode
		BNE .skip
		
		LDA.W $4218
		AND.B #$F0 
		STA.W $0DA4
		TAY        
		EOR.W $0DAC
		AND.W $0DA4
		STA.W $0DA8
		STY.W $0DAC
		LDA.W $4219
		STA.W $0DA2
		TAY        
		EOR.W $0DAA
		AND.W $0DA2
		STA.W $0DA6
		STY.W $0DAA
		LDA.W $421A
		AND.B #$F0 
		STA.W $0DA5
		TAY        
		EOR.W $0DAD
		AND.W $0DA5
		STA.W $0DA9
		STY.W $0DAD
		LDA.W $421B
		STA.W $0DA3
		TAY        
		EOR.W $0DAB
		AND.W $0DA3
		STA.W $0DA7
		STY.W $0DAB
	.skip:
		
		JSL empty_controller_regs
		LDX #$01
	.loop:
		LDA $0DA4,X
		AND #$C0
		ORA $0DA2,X
		TSB $15
		LDA $0DA4,X
		TSB $17
		LDA $0DA8,X
		AND #$40
		ORA $0DA6,X
		TSB $16
		LDA $0DA8,X
		TSB $18
		DEX
		BPL .loop
		RTL