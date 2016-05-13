; disable no-yoshi intros
ORG $05DA19
    JMP $DAD7
	
; disable tempo hike at 99 seconds
ORG $008E59
	db $80
	
; disable death at 0 seconds
; TODO make this an option
ORG $008E69
	db $80

; don't go to bonus game
ORG $008F67
    NOP #3

; reload music on death
ORG $00F610
	db $00

; disable midway points
ORG $00CA2C
    db $00

; activate ! blocks every time
ORG $00EEB1
    NOP #2
ORG $0DEC9A
    NOP #2

; disable overworld panning
ORG $048380
    db $00

; remove save prompt
ORG $04E5E6
    db $00,$00,$00,$00,$00,$00,$00,$00
	
; remove intro sequence
ORG $009CB1
	db $00