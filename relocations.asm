; 1FE2 cape interaction table
!new_cape_interaction = $0F5E

ORG $00FCC2
	STA !new_cape_interaction,X
ORG $01810E
	LDA !new_cape_interaction,X
ORG $018113
	DEC !new_cape_interaction,X
ORG $0191FB
	ORA !new_cape_interaction,X
ORG $0195D8
	STA !new_cape_interaction,X
ORG $0199CF
	STA !new_cape_interaction,X
ORG $01D2CA
	LDA !new_cape_interaction,X
ORG $01D2D1
	STA !new_cape_interaction,X
ORG $01EDA0
	STA !new_cape_interaction,X
ORG $0293C9
	ORA !new_cape_interaction,X
ORG $02A9D4
	STA !new_cape_interaction,X
ORG $02C4F3
	LDA !new_cape_interaction,X
ORG $02C4FF
	STA !new_cape_interaction,X
ORG $02DDC1
	STA !new_cape_interaction,X
ORG $02DEBC
	LDA !new_cape_interaction,X
ORG $039569
	LDA !new_cape_interaction,X
ORG $0395C3
	STA !new_cape_interaction,X
ORG $039688
	LDA !new_cape_interaction,X
ORG $07F74B
	STZ !new_cape_interaction,X
	
; clear unused table
ORG $07F782
	NOP #3
	
; clear moons, dragon coins, 1ups tables
ORG $00F2B8
	NOP #6
ORG $00F322
	NOP #6
ORG $00F351
	NOP #6
ORG $0DA59C
	LDA #$00
	NOP
ORG $0DA5A7
	LDA #$00
	NOP
ORG $0DB2D7
	LDA #$00
	NOP

; clear save file buffer table
ORG $009BC9
	RTL
ORG $009D18
	NOP #3
ORG $00A19A
	NOP #6
ORG $01E765
	NOP #3
ORG $049046
	NOP #3