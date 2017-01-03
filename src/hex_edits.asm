; point game mode 8 to start game
; this will skip all file and player menuing
ORG $009339
		dw $9E10
		
; disable routine that gets the number of exits and shows it on the screen
ORG $009CB8
		NOP #3
		
; disable disabling sprite layer on title screen
ORG $009CA5
		NOP #3
		
; disable no-yoshi intros
ORG $05DA19
		JMP $DAD7

; don't go to bonus game
ORG $008F67
		NOP #3

; reload music on death
ORG $00F610
		db $00
		
; disable losing lives
ORG $00D0D8
		NOP #3

; disable midway points
ORG $00CA2C
		db $00

; disable yoshi message
ORG $01EC36
		db $80

; don't remember 1ups, moons, or dragon coins
ORG $00F2BB
		NOP #3
ORG $00F325
		NOP #3
ORG $00F354
		NOP #3
ORG $0DA5A7
		LDA #$00
		NOP
ORG $0DA59C
		LDA #$00
		NOP
ORG $0DB2D7
		LDA #$00
		NOP

; activate ! blocks every time
ORG $00EEB1
		NOP #2
ORG $0DEC9A
		NOP #2

; make switch palace message go away fast
ORG $00C963
		db $08

; disable overworld panning
ORG $048380
		db $00

; remove save prompts & castle crushes
ORG $04E5B6
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
ORG $04903F
		db $80

; remove castle cutscenes
ORG $00C9A7
		db $00,$00,$00,$00,$00,$00,$00,$00

; remove switch palace crushes
ORG $00C9A7
		db $00,$00,$00,$00,$00

; move level names down one tile
ORG $049D22
		dw $AB50

; remove lives counter on overworld
ORG $05DBC9
		dw $885A

; faster star road warp
ORG $049E5E
		db $01
ORG $049E69
		LDA #$FF
		STA $1DF7
		NOP #10

; create gold palette for overworld
ORG $00B5EC
		dw $7393,$573B,$03FF,$0000
		dw $7393,$573B,$551E,$0000
		dw $7393,$573B,$7FFF,$0000
		dw $7393,$573B,$47F1,$0000
		
; remove intro sequence
ORG $009CB1
		db $00
		
; mario is not always small when you start the game
ORG $009E2F
		NOP #11
ORG $009E3F
		NOP #12

; allow pausing during level end & death
ORG $00A224
		NOP #2
ORG $00A22A
		NOP #2

; press b on yoshi's house to warp to special world
ORG $049134
		AND #%10000000
		db $F0
ORG $0484D1
		dw $0B18
ORG $048507
		dw $0118

; set extra bit on ghost ship orb so we can differentiate it from orb from item box
ORG $07DD07
		db $67

; title screen "practice cart"
ORG $05B6D3
		db $52,$2A,$00,$19,$19,$38,$1B,$38
		db $0A,$38,$0C,$38,$1D,$38,$12,$38
		db $0C,$38,$0E,$38,$FC,$38,$0C,$38
		db $0A,$38,$1B,$38,$1D,$38
		db $53,$0B,$00,$15,$0D,$28,$18,$28
		db $1D,$28,$1C,$28,$0A,$28,$1B,$28
		db $0E,$28,$0C,$28,$18,$28,$18,$28
		db $15,$28
		db $53,$38,$00,$0B,$1F,$3C,!version_a,$3C
		db $24,$3C,!version_b,$3C,$24,$3C,!version_c,$3C
		db $FF

; modify water splash to not conflict with slot numbers
ORG $028D42
		db $66,$66,$64,$64,$64

; prevent credits
ORG $03AC12
		db $93,$14

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

; give the cartridge more SRAM
ORG $00FFD8
		db $07
;		db $05 ; some platforms will treat $07 as $05 here