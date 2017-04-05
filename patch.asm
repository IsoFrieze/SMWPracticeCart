;========================
; SMW Practice Cart
; Version 2.5.0
; Created by Dotsarecool
;========================

; internal rom name
ORG $00FFC0
		db "SMW PRACTICE CART    "

; nintendo presents sound
ORG $0093C1
		db $0B

; include everything because I want to be organized this time

incsrc "src/defines.asm"            ; internal
incsrc "src/hijacks.asm"            ; internal
incsrc "src/hex_edits.asm"          ; internal
incsrc "src/relocations.asm"        ; internal
incsrc "src/statusbar.asm"          ; internal
incsrc "src/level_mario_appear.asm" ; $108000
incsrc "src/overworld_load.asm"     ; $118000
incsrc "src/level_load.asm"         ; $128000
incsrc "src/level_finish.asm"       ; $138000
incsrc "src/overworld_tick.asm"     ; $148000
incsrc "src/level_tick.asm"         ; $158000
incsrc "src/nmi.asm"                ; $168000
incsrc "src/every_frame.asm"        ; $178000
incsrc "src/overworld_menu.asm"     ; $180000 - $198000
incsrc "src/l_r_reset.asm"          ; $1A8000
; make sure the ROM is expanded to the full 1MBit
ORG $1FFFFF
		db $EA