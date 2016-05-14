;========================
; SMW Practice Cart
; Version 2.0.0
; Created by Dotsarecool
;========================

ORG $00FFC0
		db "SMW PRACTICE CART    "

; include everything because I want to be organized this time

incsrc "overworld_menu.asm"     ; $180000 - $198000
incsrc "nmi.asm"                ; $168000
incsrc "hijacks.asm"            ; internal
incsrc "relocations.asm"        ; internal
incsrc "statusbar.asm"          ; internal
incsrc "level_mario_appear.asm" ; $108000
incsrc "overworld_tick.asm"     ; $148000
incsrc "level_tick.asm"         ; $158000
incsrc "every_frame.asm"        ; $178000
incsrc "prepare_file.asm"       ; internal
incsrc "hex_edits.asm"          ; internal
incsrc "level_load.asm"         ; $128000
incsrc "l_r_reset.asm"          ; $1A8000
incsrc "level_finish.asm"       ; $138000
incsrc "overworld_load.asm"     ; $118000