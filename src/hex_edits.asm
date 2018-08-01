; point game mode 8 to start game
; this will skip all file and player menuing
ORG !_F+$009339
		dw $9E10
		
; disable routine that gets the number of exits and shows it on the screen
ORG !_F+$009CB8
		NOP #3
		
; disable disabling sprite layer on title screen
ORG !_F+$009CA5
		NOP #3
		
; disable no-yoshi intros
ORG !_F+$05DA19
		JMP $DAD7
ORG !_F+$05D9DE
		NOP #3

; don't go to bonus game
ORG !_F+$008F67
		NOP #3

; reload music on death
ORG !_F+$00F610
		db $00
		
; disable losing lives
ORG !_F+$00D0D8
		NOP #3

; disable midway points
ORG !_F+$00CA2C
		db $00
ORG !_F+$048F35
		JMP $8F56

; disable yoshi message
ORG !_F+$01EC36
		db $80
		
; increase size of status bar
ORG !_F+$008293
		db #$26
ORG !_F+$00835D
		db #$26

; disable score and bonus star counters at the level end
ORG !_F+$05CC10
		dw $CFE9
ORG !_F+$05CC42
		db $FF
ORG !_F+$05CC94
		dw $002C
ORG !_F+$05CCC8
		JMP $CD26

; don't remember 1ups, moons, or dragon coins
ORG !_F+$00F2BB
		NOP #3
ORG !_F+$00F325
		NOP #3
ORG !_F+$00F354
		NOP #3
ORG !_F+$0DA5A7
		LDA #$00
		NOP
ORG !_F+$0DA59C
		LDA #$00
		NOP
ORG !_F+$0DB2D7
		LDA #$00
		NOP
		
; overworld shadow HDMA during transitions
ORG !_F+$04DB97
		LDA #$C0

; remove ! block party
ORG !_F+$04F294
		db $00

; activate ! blocks every time
ORG !_F+$00EEB1
		NOP #2
ORG !_F+$0DEC9A
		NOP #2

; make switch palace message go away fast
ORG !_F+$00C963
		db $08

; disable overworld panning
ORG !_F+$048380
		db $00

; remove save prompts & castle crushes
ORG !_F+$04E5B6
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
ORG !_F+$04903F
		db $80

; remove castle cutscenes
ORG !_F+$00C9A7
		db $00,$00,$00,$00,$00,$00,$00,$00

; remove switch palace crushes
ORG !_F+$00C9A7
		db $00,$00,$00,$00,$00

; move level names down one tile
ORG !_F+$049D22
		dw $AB50

; remove lives counter on overworld
ORG !_F+$05DBC9
		dw $885A

; faster star road warp
ORG !_F+$049E5E
		db $01
ORG !_F+$049E69
		LDA #$FF
		STA $1DF7
		NOP #10

; create gold palette for overworld
ORG !_F+$00B5EC
		dw $7393,$573B,$03FF,$0000
		dw $7393,$3E75,$3212,$25AF
		dw $7393,$573B,$7FFF,$0000
		dw $7393,$573B,$47F1,$0000
		
; remove intro sequence
ORG !_F+$009CB1
		db $00
		
; mario is not always small when you start the game
ORG !_F+$009E2F
		NOP #11
ORG !_F+$009E3F
		NOP #12

; allow pausing during level end & death
ORG !_F+$00A224
		NOP #2
ORG !_F+$00A22A
		NOP #2

; press b on yoshi's house to warp to special world
ORG !_F+$049134
		AND #%10000000
		db $F0
ORG !_F+$0484D1
		dw $0B18
ORG !_F+$048507
		dw $0118

; set extra bit on ghost ship orb so we can differentiate it from orb from item box
ORG !_F+$07DD07
		db $67

; title screen "practice cart"
ORG !_F+$05B6D3
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
ORG !_F+$028D42
		db $66,$66,$64,$64,$64

; prevent credits
ORG !_F+$03AC12
		dw $1493
ORG !_F+$00CA24
		db $0B

; disable chocolate island 2 weirdness
ORG !_F+$05DAE5
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
ORG !_F+$05E228 ; Layer 1
		dl $06EAB0 ; parakoopa room
		dl $06E9FB ; rex room
		dl $06EBBE ; keyhole room
		dl $06EB72 ; rhino room
		dl $06EC7E ; rex goal room
ORG !_F+$05E828 ; Layer 2
		dl $FFDF59,$FFDF59,$FFDF59,$FFDF59,$FFDF59
ORG !_F+$05ED70 ; Sprites
		dw $D825 ; parakoopa room
		dw $D7EA ; rex room
		dw $D888 ; keyhole room
		dw $D86E ; rhino room
		dw $D8A1 ; rex goal room
ORG !_F+$05F2B8 ; level entrance
		db $10,$10,$10,$10,$10
		
; midway secondary entrances
; destination level number
ORG !_F+$05F800
		db $00,$01,$02,$03,$F9,$05,$06,$E7,$C9,$E9,$C2,$E0,$0C,$0D,$DB,$0F
		db $10,$11,$00,$ED,$CA,$15,$00,$00,$F7,$00,$1A,$1B,$1C,$1D,$00,$1F
		db $20,$21,$22,$23,$24
ORG !_F+$05F900
		db $00,$01,$02,$03,$04,$05,$06,$07,$00,$09,$0A,$0B,$00,$D0,$0E,$0F
		db $10,$11,$00,$13,$DB,$15,$16,$17,$18,$19,$1A,$D8,$1C,$1D,$1E,$1F
		db $20,$D7,$22,$23,$00,$25,$26,$27,$28,$00,$2A,$2B,$2C,$2D,$00,$00
		db $30,$00,$32,$00,$34,$35,$36,$00,$00
; bgfgyyyy
ORG !_F+$05FA00
		db $00,$AB,$A9,$AB,$AB,$AB,$AB,$CD,$AB,$AA,$AD,$A9,$A9,$AB,$AC,$AB
		db $AB,$A8,$00,$AB,$AB,$AB,$00,$00,$C1,$00,$AB,$AB,$A7,$04,$00,$AB
		db $A8,$AB,$AB,$AB,$AB
ORG !_F+$05FB00
		db $00,$AB,$A9,$AB,$AB,$AB,$AB,$AB,$00,$8A,$A8,$AB,$00,$AA,$AB,$A8
		db $AB,$A8,$00,$AB,$AB,$AB,$AB,$A7,$02,$A7,$A7,$AB,$A7,$AB,$AC,$AB
		db $02,$AB,$56,$AC,$00,$AB,$AC,$A8,$AB,$00,$CC,$AE,$AB,$A9,$00,$00
		db $A8,$00,$AB,$00,$80,$AA,$AB,$00,$00
; xxxsssss
ORG !_F+$05FC00
		db $00,$09,$08,$20,$00,$2A,$0A,$07,$00,$00,$04,$24,$00,$09,$24,$09
		db $09,$06,$00,$64,$00,$09,$00,$00,$00,$00,$0B,$08,$0B,$A6,$00,$25
		db $06,$0A,$09,$09,$23
ORG !_F+$05FD00
		db $00,$07,$24,$09,$20,$09,$09,$08,$00,$22,$0F,$09,$00,$00,$06,$09
		db $27,$00,$00,$08,$63,$07,$09,$07,$2A,$09,$0F,$00,$29,$07,$09,$09
		db $06,$00,$00,$09,$00,$0D,$09,$08,$09,$00,$80,$22,$09,$29,$00,$00
		db $04,$00,$01,$00,$65,$09,$69,$00,$00
; s---haaa
ORG !_F+$05FE00
		db $00,$00,$00,$00,$00,$00,$00,$00,$02,$03,$03,$07,$00,$00,$00,$00
		db $00,$07,$00,$00,$02,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00
ORG !_F+$05FF00
		db $00,$08,$08,$08,$08,$08,$08,$08,$00,$08,$08,$8D,$00,$08,$08,$08
		db $08,$08,$00,$08,$08,$08,$08,$08,$08,$08,$08,$0A,$08,$08,$08,$08
		db $0F,$0A,$08,$08,$00,$08,$08,$08,$08,$00,$08,$08,$08,$8D,$00,$00
		db $0F,$00,$08,$00,$08,$08,$08,$00,$00

; give the cartridge more SRAM
ORG !_F+$00FFD8
		db $05