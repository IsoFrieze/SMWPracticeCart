;========================
; SMW Practice Cart
; Version 3.-.7
; Created by Dotsarecool
;========================

; set to $000000 to compile for SlowROM
; set to $800000 to compile for FastROM
; must patch to a FastROM version of SMW
!_F = $800000

cleartable

; internal rom name
ORG !_F+$00FFC0
        db "SMW PRACTICE CART    "

; ROM speed and memory map mode
if !_F = $800000
ORG !_F+$00FFD5
        db #$30
endif

; give the cartridge more ROM
ORG !_F+$00FFD7
        db $0A

; give the cartridge more SRAM
ORG !_F+$00FFD8
        db $05

; nintendo presents sound
ORG !_F+$0093C1
        db $15

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
incsrc "src/overworld_menu.asm"     ; $188000 - $198000
incsrc "src/l_r_reset.asm"          ; $1A8000
incsrc "src/movies.asm"             ; $1B8000 - $1C8000

; incbin "bin/spc_engine.bin"       ; $1F8000 (see relocations.asm)

; make sure the ROM is expanded to the full 1MBit
ORG !_F+$1FFFFF
        db $EA