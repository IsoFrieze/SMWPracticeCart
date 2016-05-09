;========================
; SMW Practice Cart
; Version 2.0.0
; Created by Dotsarecool
;========================

ORG $00FFC0
		db "SMW PRACTICE CART    "

; include everything because I want to be organized this time
incsrc "hijacks.asm"
incsrc "relocations.asm"
incsrc "statusbar.asm"
incsrc "level_mario_appear.asm"
incsrc "overworld_load.asm"
incsrc "level_load.asm"
incsrc "level_finish.asm"
incsrc "overworld_tick.asm"
incsrc "level_tick.asm"
incsrc "vblank.asm"
incsrc "every_frame.asm"
incsrc "prepare_file.asm"
incsrc "overworld_menu.asm"
		