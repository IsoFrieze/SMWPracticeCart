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

; allow pausing during level end
ORG $00A224
		NOP #2

; press x or y on yoshi's house to warp to special world
ORG $049134
		AND #%01000000
		db $F0
ORG $0484D1
		dw $0B18
ORG $048507
		dw $0118

; set extra bit on ghost ship orb so we can differentiate it from orb from item box
ORG $07DD07
		db $67

; modify water splash to not conflict with slot numbers
ORG $028D42
		db $66,$66,$64,$64,$64

; disable chocolate island 2 weirdness
ORG $05DAE5
		db $00

; chocolate island 2 sublevels
; main level = 024 (original)
; coins:
;    00-08: 0B8 (NEW)
;    09-20: 0B9 (NEW)
;    21+  : 0CF (original)
; time:
;    250+   : 0BA (NEW)
;    235-249: 0BB (NEW)
;    000-234: 0CE (original)
; dragon coins:
;    0-4: 0BC (NEW)
;    5  : 0CD (original)
ORG $05E228 ; Layer 1
		dl $06EAB0 ; parakoopa room
		dl $06E9FB ; rex room
		dl $06EBBE ; keyhole room
		dl $06EB72 ; rhino room
		dl $06EC7E ; rex goal room
ORG $05E828 ; Layer 2
		dl $FFDF59,$FFDF59,$FFDF59,$FFDF59,$FFDF59
ORG $05ED70 ; Sprites
		dw $D825 ; parakoopa room
		dw $D7EA ; rex room
		dw $D888 ; keyhole room
		dw $D86E ; rhino room
		dw $D8A1 ; rex goal room
ORG $05F2B8 ; level entrance
		db $10,$10,$10,$10,$10