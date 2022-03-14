ORG !_F+$1A8000

reset bytes

; this code is run when the player presses L + R in a level to reset the current room
activate_room_reset:
        ; if we are in first room of level, just level reset
        LDA $141A ; sublevel count
        AND #$7F
        BNE +
        
        JSL activate_level_reset
        RTL
        
      + LDA #$01
        STA !l_r_function
        
        LDA !recent_screen_exit
        LDY !recent_secondary_flag
        JSL set_global_exit
        JSR trigger_screen_exit
        
        LDA !restore_room_yoshi
        BEQ +
        INC $187A ; on yoshi flag
        
      + LDA.L !status_states
        CMP #$02
        BNE +
        
;        JSR shuffle_rng_and_framerule ; not sure if this should be here??
        
      + LDA #$20 ; bow sound
        STA $1DF9 ; apu i/o
        
        RTL
        
; this code is run when the player buffers L + R upon level load or reset
activate_midway_entrance:
        LDA #$03
        STA !l_r_function
        STZ !start_midway
        INC $13CE ; midway flag
        
        JSR get_level_low_byte ; use secondary exit that is equal to level number
        LDY #$01
        JSL set_global_exit
        JSR trigger_screen_exit
        
        LDA #$05 ; midway sound
        STA $1DF9 ; apu i/o
        
        RTL

; this code is run when the player presses L + R + A + B in a level to reset the entire level
activate_level_reset:
        LDA #$02
        STA !l_r_function
        
        JSR get_level_low_byte
        LDY #$00
        JSL set_global_exit
        JSR trigger_screen_exit
        
        LDA.L !status_states
        CMP #$02
        BNE +
        
;        JSR shuffle_rng_and_framerule ; not sure if this should be here??
        
      + LDA #$20 ; bow sound
        STA $1DF9 ; apu i/o
        
        RTL
        
; copy timer from apu and put it in the rng value and effective frame counter to shuffle them
shuffle_rng_and_framerule:
        PHP
        REP #$20
        
      - LDA $2140 ; get apu timer and put it in room frame and rng
        BEQ -
        
        STA $148B ; rng calc
        SEP #$20
        STA $14 ; effective frame
        PLP
        RTS

; this code is run when the player presses L + R + X + Y in a level to advance to the next room
activate_room_advance:
        PHP
        LDA #$03
        STA !l_r_function
        
        ; X = level bank
        LDX #$00
        LDA $13BF ; translevel number
        CMP #$25
        BCC +
        INX
      + LDA $141A ; sublevel count
        AND #$7F
        BNE +
        
        ; we just entered the level, so backup may not be available
        ; we know we entered via screen exit, not from secondary exit
        JSR get_level_low_byte
        LDY #$00
        BRA .merge
        
        ; we are in some sublevel, so backup is available
      + LDA !recent_screen_exit
        LDY !recent_secondary_flag
    
    .merge:
        JSR get_next_sensible_exit
        PHX
        JSL set_global_exit
        JSR trigger_screen_exit
        
        LDA #$09 ; cape sound
        STA $1DF9 ; apu i/o
        
        PLA
        REP #$20
        AND #$00FF
        ASL #5
        STA !restore_room_xpos
        
        PLP
        RTL

; set the screen exit for all screens to be set to the exit number in A
; Y = 1 iff this exit is a secondary exit
set_global_exit:
        LDX #$20
      - DEX
        STA $19B8,X ; exit table
        BNE -
        STY $1B93 ; secondary exit flag
        RTL

; get the low byte of the level number, not the translevel number
get_level_low_byte:
        LDA $13BF ; translevel number
        CMP #$25
        BCC +
        SEC
        SBC #$24
      + RTS

; actually trigger the screen exit
trigger_screen_exit:
        LDA #$05
        STA $71 ; player animation trigger
        STZ $88
        STZ $89 ; pipe timers
        RTS

; given the current sub/level, return a sub/level that 'advances' one room forward
; given A = level number low byte, X = level number high byte, Y = secondary exit flag
; return A = level number low byte / secondary exit number, Y = secondary exit flag, X = mario x position
get_next_sensible_exit:
        PHP
        PHB
        PHK
        PLB
        CPX #$00
        BEQ .low_bank
        TAX
        CPY #$00
        BEQ +
        LDA room_advance_table+$000,X
        LDY room_advance_table+$200,X
        PHY
        LDY room_advance_table+$100,X
        PLX
        BRA .done
        
      + LDA room_advance_table+$300,X
        LDY room_advance_table+$500,X
        PHY
        LDY room_advance_table+$400,X
        PLX
        BRA .done
        
    .low_bank:
        TAX
        CPY #$00
        BEQ +
        LDA room_advance_table+$600,X
        LDY room_advance_table+$800,X
        PHY
        LDY room_advance_table+$700,X
        PLX
        BRA .done
        
      + LDA room_advance_table+$900,X
        LDY room_advance_table+$B00,X
        PHY
        LDY room_advance_table+$A00,X
        PLX
        
    .done:
        PLB
        PLP
        RTS
        
room_advance_table:
        ; =======================================
        ; This bin file contains 12 tables that hold screen exit data to be used
        ; by the advance room function. Each table is 0x100 bytes long.
        ; Table 01: exit number to take if last exit was a secondary exit, bank 1
        ; Table 02: secondary exit flag for above table number
        ; Table 03: player x position data for above table (sssssxxx, s = screen, x = x pos / 2)
        ; Table 04: exit number to take if last exit was a level exit, bank 1
        ; Table 05: secondary exit flag for above table number
        ; Table 06: player x position data for above table (sssssxxx, s = screen, x = x pos / 2)
        ; Table 07: exit number to take if last exit was a secondary exit, bank 0
        ; Table 08: secondary exit flag for above table number
        ; Table 09: player x position data for above table (sssssxxx, s = screen, x = x pos / 2)
        ; Table 10: exit number to take if last exit was a level exit, bank 0
        ; Table 11: secondary exit flag for above table number
        ; Table 12: player x position data for above table (sssssxxx, s = screen, x = x pos / 2)
        incbin "bin/room_advance_table.bin"
        ; =======================================
        
; this code is run when the player presses R + select to make a save state
activate_save_state:
        LDA #$0E ; swim sound
        STA $1DF9 ; apu i/o
        STZ $4200 ; nmi disable
        
      - LDA $4212
        BPL -
        
        LDA #$80
        STA $2100 ; force blank
        
        LDA !in_record_mode
        BEQ +
        LDA #$01
        STA !movie_location+$0E
        
      + JSR go_save_state
        LDA !level_timer_minutes
        ORA !level_timer_seconds
        ORA !level_timer_frames
        STA.L !spliced_run
        LDA #$BD
        STA.L !save_state_exists
        
      - LDA $4212
        BPL -
        
        LDA $4210 ; clear nmi flag
        
        LDA #$81
        STA $4200 ; nmi enable
        LDA #$0F
        STA $2100 ; exit force blank
        
        RTL

go_save_state:
        PHP
        REP #$10
        
        ; save wram $0000-$1FFF to wram $705000-$706FFF
        ; mirrored wram
        LDX #$1FFF
      - LDA $7E0000,X
        STA $705000,X
        DEX
        BPL -
        
        ; save wram $C680-$C6DF to $704CE0-$704D3F
        ; mode 7 boss tilemap
        LDX #$005F
      - LDA $7EC680,X
        STA $704CE0,X
        DEX
        BPL -
        
        ; save wram $7F9A7B-$7F9C7A to $704AE0-$704CDF
        ; wiggler segments
        LDX #$01FF
      - LDA $7F9A7B,X
        STA $704AE0,X
        DEX
        BPL -
        
;        ; save wram $B900-$C0FF to $704C40-$70543F
;        ; background tilemap
;        LDX #$07FF
;      - LDA $7EB900,X
;        STA $704C40,X
;        DEX
;        BPL -
        
        ; save wram $C800-$FFFF to $700BA0-$70439F
        ; level tilemap low byte
        LDX #$37FF
      - LDA $7EC800,X
        STA $700BA0,X
        DEX
        BPL -
        
        ; save wram $7FC800-$7FFFFF to $7043A0-$704A9F
        ; level tilemap high bit
        ; since only bit 0 is used for this data, crunch it into a 1:8 ratio
        ; unrolled inner loop is used for the speed increase
        PHB
        LDA #$70
        PHA
        PLB
        
        LDX #$37F8
        LDY #$06FF
      - LDA $7FC800,X
        STA $00
        LDA $7FC801,X
        STA $01
        LDA $7FC802,X
        STA $02
        LDA $7FC803,X
        STA $03
        LDA $7FC804,X
        STA $04
        LDA $7FC805,X
        STA $05
        LDA $7FC806,X
        STA $06
        LDA $7FC807,X
        STA $07
        LDA #$00
        LSR $00
        ROL A
        LSR $01
        ROL A
        LSR $02
        ROL A
        LSR $03
        ROL A
        LSR $04
        ROL A
        LSR $05
        ROL A
        LSR $06
        ROL A
        LSR $07
        ROL A
        STA $43A0,Y ; $7043A0,Y
        DEX #8
        DEY
        BPL -
        
        ; do these separately because they actually use the upper 7 bits
        ; mode 7 level tilemaps
        LDX #$001F
      - LDA $7FC8B0,X
        STA $704AA0,X
        DEX
        BPL -
        
        LDX #$001F
      - LDA $7FCA60,X
        STA $704AC0,X
        DEX
        BPL -
        
        PLB
        
        ; save the stack pointer to $704D48 - $704D49
        REP #$30
        TSX
        TXA
        STA $704D48
        
        ; save the currently used music to $704D4A
        SEP #$20
        LDA $2142
        STA $704D4A
        
        PLP
        RTS

; this code is run when the player presses L + select to load a save state
activate_load_state:
        STZ $4200 ; nmi disable
      - LDA $4212 ; wait until vblank
        BPL -
        
        LDA #$80
        STA $2100 ; force blank
        
        STZ $420C ; disable all HDMA to fix S-CPU ver. 1 bug
        
        JSR go_load_state
    .done:
        JSR restore_hardware_regs
        
        JSR restore_all_graphics
        JSR restore_all_tilemaps
        JSR restore_all_palettes
        
        LDA !level_timer_minutes
        ORA !level_timer_seconds
        ORA !level_timer_frames
        STA !spliced_run
        
        LDA !status_dynmeter
        ORA !status_slots
        BEQ +
        JSL load_slots_graphics
        
      + LDA.L !status_states
        CMP #$02
        BNE +
        
        JSR shuffle_rng_and_framerule
       
      + 
      - LDX $2137
        LDA $213D
        LDX $213D
        CMP #$30 ; wait until line 48 (past IRQ)
        BNE -
        
        LDA $4210 ; clear nmi flag
        
        LDA #$81
        STA $4200 ; nmi enable

        LDA.L !status_statedelay
        INC A
        ASL #3
        TAX
        LDA #$80
      - DEX
        BEQ +
        WAI ; wait for NMI
        STA $2100
        WAI ; wait for IRQ
        STA $2100
        INC !previous_sixty_hz ; waiting here shouldn't count as lag
        BRA -
    
        STZ $2100
    
      + RTL
        
go_load_state:
        PHP        
        REP #$10
        
        ; load wram $705000-$706FFF to wram $0000-$1FFF
        ; mirror wram
        ; copy old graphics files into state
        LDX #$0007
      - LDA $7E0101,X
        STA $704D40,X
        DEX
        BPL -
        
        LDX #$1FFF
      - LDA $705000,X
        STA $7E0000,X
        DEX
        BPL -
        
        ; load $704CE0-$704D3F to wram $C680-$C6DF
        ; mode 7 boss tilemap
        LDX #$005F
      - LDA $704CE0,X
        STA $7EC680,X
        DEX
        BPL -
        
        ; load $704AE0-$704BDF to wram $7F9A7B-$7F9C7A
        ; wiggler segments
        LDX #$01FF
      - LDA $704AE0,X
        STA $7F9A7B,X
        DEX
        BPL -
        
;        ; load $704C40-$70543F to wram $B900-$C0FF
;        ; background tilemap
;        LDX #$07FF
;      - LDA $704C40,X
;        STA $7EB900,X
;        DEX
;        BPL -
        
        ; load $700BA0-$70439F to wram $C800-$FFFF
        LDX #$37FF
      - LDA $700BA0,X
        STA $7EC800,X
        DEX
        BPL -
        
        ; load $7043A0-$704A9F to wram $7FC800-$7FFFFF
        ; since only bit 0 is used for this data, expand it into a 8:1 ratio
        ; unrolled inner loop is used for the speed increase
        LDX #$0007
      - STZ $00,X
        DEX
        BPL -
        
        PHB
        LDA #$70
        PHA
        PLB
        
        LDX #$37F8
        LDY #$06FF
      - LDA $43A0,Y ; $7043A0,Y
        LSR $07
        ROR A
        ROL $07
        LSR $06
        ROR A
        ROL $06
        LSR $05
        ROR A
        ROL $05
        LSR $04
        ROR A
        ROL $04
        LSR $03
        ROR A
        ROL $03
        LSR $02
        ROR A
        ROL $02
        LSR $01
        ROR A
        ROL $01
        LSR $00
        ROR A
        ROL $00
        LDA $00
        STA $7FC800,X
        LDA $01
        STA $7FC801,X
        LDA $02
        STA $7FC802,X
        LDA $03
        STA $7FC803,X
        LDA $04
        STA $7FC804,X
        LDA $05
        STA $7FC805,X
        LDA $06
        STA $7FC806,X
        LDA $07
        STA $7FC807,X
        DEX #8
        DEY
        BPL -
        
        ; do these separately because they actually use the upper 7 bits
        LDX #$001F
      - LDA $704AA0,X
        STA $7FC8B0,X
        DEX
        BPL -
        
        LDX #$001F
      - LDA $704AC0,X
        STA $7FCA60,X
        DEX
        BPL -
        
        PLB
        
        ; load the stack pointer from $704D48 - $704D49
        REP #$30
        LDA $704D48
        TAX
        TXS
        
        ; load the currently used music from $704D4A
        SEP #$20
        LDA $704D4A
        CMP $2142
        BEQ +
        STA $2142
      + REP #$20
        
        ; since we restored the stack, we need to update the return
        ; address of this routine to what we want it to be. otherwise,
        ; it would return to the save state routine.
        LDX #activate_load_state_done-1
        TXA
        STA $02,S
        
        PLP
        RTS

; since we can't restore the hardware registers directly (they are non-readable),
; we have to use smw's hardware register mirrors to restore the actual registers.
; we do this manually because smw only restores mirrors to registers at certain
; points in the game, we want to do this immediately after a load state.
restore_hardware_regs:
        LDA $0DB0 ; mosaic mirror
        ORA #$03
        STA $2106 ; mosaic
        
        LDA $0D9D ; tm mirror
        STA $212C ; tm
        STA $212E ; tmw
        LDA $0D9E ; ts mirror
        STA $212D ; ts
        STA $212F ; tsw
        
        LDA #$23 ; sometimes #$59 ($008416)
        STA $2107 ; gb1sc
        LDA #$33
        STA $2108 ; gb2sc
        LDA #$53
        STA $2109 ; gb3sc
        LDA #$00 ; sometimes #$07 ($008416)
        STA $210B ; bg12nba
        LDA #$04
        STA $210C ; bg34nba
        RTS
        
vram_locations:
        dw $7800,$7000,$6800,$6000
        dw $1800,$1000,$0800,$0000

; restore all graphics files from $0101-$0108
restore_all_graphics:
        PHP
        PHB
        PHK
        PLB
        REP #$10
        SEP #$20
        LDX #$0007
        
      - PHX
        TXA
        XBA
        LDA #$00
        XBA
        ASL A
        TAX
        LDY vram_locations,X
        PLX
        PHX
        CPX #$0006
        BCS ++
        LDA $704D40,X
        CMP $0101,X
        BEQ +
     ++ LDA $0101,X
        LDX #$1000
        JSL load_a_graphics
        
      + PLX
        DEX
        BPL -    
        PLB
        
        JSL load_slots_graphics
        
        PLP
        RTS

; thank you Kaizoman for the help for the following routines!
decompress_it:
        PHX
        PHY
        PHP
        CMP #$7F
        BCS +
        TAX
        SEP #$30
        LDA $00B992,X
        STA $8A
        LDA $00B9C4,X
        STA $8B
        LDA $00B9F6,X
        STA $8C
        
        PHK
        PER $0005
        PHB
        PHY
        JML $00BA47
     
      + PLP
        PLY
        PLX
        RTL

load_a_graphics:
        PHP
        PHA
        LDA #$7E
        STA $02
        REP #$20
        LDA #$AD00
        STA $00
        SEP #$20
        PLA
        PHA
        JSL decompress_it ; decompress to $7EAD00
        STY $2116
        SEP #$30
        LDA #$80
        STA $2115 ; vram increment
        PLA
        
        JSL upload_3bpp_to_vram

        PLP
        RTL
        
load_gfx27:
        PHP
        SEP #$30
        LDA #$80
        STA $2115
        JSL gfx27_hijack
        PLP
        RTS

; rebuild the background from level setting to wram
build_background:
        PHP
        
        LDA $1925 ; level mode
        BEQ .has_bg
        CMP #$1E
        BEQ .has_bg
        CMP #$0F
        BEQ .no_bg
        CMP #$09
        BCC .no_bg
        CMP #$12
        BCS .no_bg
        BRA .has_bg
        
    .no_bg:
        JMP .done
    
    .has_bg:        
        REP #$10
        LDX $68
        STX $00
        LDA #$8C
        STA $02
        
        LDA #$25
        XBA
        LDY #$0000
        CPX #$E8FE
        BCC +
        INY
      + LDX #$00FF
        TYA
      - STA $7EBD00,X
        STA $7EBE00,X
        STA $7EBF00,X
        STA $7EC000,X
        XBA
        STA $7EB900,X
        STA $7EBA00,X
        STA $7EBB00,X
        STA $7EBC00,X
        XBA
        DEX
        BPL -
        
        REP #$20
        LDX #$0000 ; x = ptr into wram table
        
    .loop:
        LDA [$00]
        CMP #$FFFF
        BEQ .upload
        XBA
        CMP #$0000
        BMI .rle
        XBA
        AND #$007F
        TAY
        INC $00
        SEP #$20
      - LDA [$00]
        INC $00
        BNE +
        INC $01
      + STA $7EB900,X
        INX
        DEY
        BPL -
        REP #$20
        BRA .loop
    .rle:
        XBA
        AND #$007F
        TAY
        INC $00
        SEP #$20
        LDA [$00]
      - STA $7EB900,X
        INX
        DEY
        BPL -
        REP #$20
        INC $00
        BRA .loop
        
    .upload:
        LDA #$7E7E
        STA $0C
        STA $0E
        LDA #$B900
        STA $0A
        LDA #$BD00
        STA $0D
        LDA #$9100
        STA $00
        LDA #$8D8D
        STA $02
        STZ $03
        LDA #$0030
        STA $08
        
    .strip:
        LDY $03
        LDA [$0A],Y
        STA $05
        LDA [$0D],Y
        STA $06
        LDA $05
        ASL #3
        TAY
        LDA $03
        LSR #2
        AND #$FFFC
        TAX
        LDA [$00],Y
        STA $1CE8,X
        INY #2
        LDA [$00],Y
        STA $1CEA,X
        INY #2
        LDA [$00],Y
        STA $1D68,X
        INY #2
        LDA [$00],Y
        STA $1D6A,X
        LDA $03
        CLC
        ADC #$0010
        STA $03
        CMP #$01B0
        BCC .strip
        
        LDA $08
        STA $1CE6
        SEP #$30
        JSL $8088F3 ; dma
        REP #$30
        LDA $08
        XBA
        CLC
        ADC #$0002
        XBA
        STA $08
        
        LDA $03
        AND #$000F
        INC A
        STA $03
        CMP #$0010
        BNE .strip
        LDA #$0034
        STA $08
        LDA $0D
        CLC
        ADC #$01B0
        STA $0D
        LDA $0A
        CLC
        ADC #$01B0
        STA $0A
        CMP #$BAB0
        BEQ .strip
        
    .done:
        PLP
        RTL

; restore all tilemaps from respective data
restore_all_tilemaps:
        PHP
        PHB
        LDA #$80
        PHA
        PLB
        JSL !_F+$05809E ; layer 1 & 2
        JSL build_background
        PLB
        
        REP #$10

        ; clear layer 3 tilemap
        LDA #$FC
        STA $0F
        STZ $2115 ; vram increment
        LDX #$50A0
        STX $2116 ; vram address
        LDX #$000F
        STX $4302 ; dma0 destination address
        LDA #$7E
        STA $4304 ; dma0 destination bank
        LDX #$1EC0
        STX $4305 ; dma0 length
        LDX #$1809 ; $2118 vram data write
        STX $4300 ; dma0 parameters, source
        LDA #$01 ; channel 0
        STA $420B ; dma enable
        
        SEP #$30
        LDA $1931
        ASL A
        CLC
        ADC $1931
        STA $00
        JSL update_layer3_tilemap
        
        ; mode 7 stuff
        LDA $1925 ; level mode
        CMP #$0B
        BNE +
        JMP .iggylarry
      + CMP #$09
        BNE +
        JMP .mortonludwigroyreznor
      + CMP #$10
        BNE +
        JMP .bowser
      + JMP .no_mode7
        
    .iggylarry: ; m7 graphics
        STZ $2115
        STZ $2116
        STZ $2117
        REP #$10
        LDX #$4000
        LDA #$FF
      - STA $2118
        DEX
        BNE -
        SEP #$10
        
        JSL !_F+$03D958 ; tilemap
        JSR load_gfx27
        JMP .no_mode7
        
    .mortonludwigroyreznor:
        STZ $2115
        STZ $2116
        STZ $2117
        REP #$10
        LDX #$4000
        LDA #$FF
      - STA $2118
        DEX
        BNE -
        SEP #$10
        
        LDX #$07
        LDA $A5 ; sprite slot 7
        CMP #$A9 ; reznor
        BEQ +
        LDX #$09
      + JSL !_F+$03DD7D
        
        JSL m7_boss_hijack ; prepare ceiling, bridge, lava
        LDA #$18
        STA.L $7F837B
        LDA #$03
        STA.L $7F837C
        LDA #$5A
        STA.L $7F837D
        
        LDA $13FC ; current boss
        CMP #$02
        BEQ .ludwig
        CMP #$04
        BEQ .reznor
        JMP .finish_thisboss
        
    .ludwig:
        LDA #$40
        STA.L $7F8486
        STA.L $7F8612
        JMP .finish_thisboss
    
    .reznor:
        JSR load_gfx27
        
        LDA #$5F
        STA.L $7F8485
        STA.L $7F8611
        LDA #$C0
        STA.L $7F8486
        STA.L $7F8612
        
        LDY $1B9F ; number of broken bridge segments
      - BEQ .finish_thisboss
      
        ; delete bridge
        TYA
        CLC
        ADC #$0B
        REP #$30
        AND #$00FF
        PHA
        CMP #$0010
        BCC +
        CLC
        ADC #$01B0
      + TAX
        SEP #$20
        LDA #$00
        STA.L $7FC8B0,X ; collision
        REP #$20
        PLA
        ASL #2
        CMP #$0040
        BCC +
        CLC
        ADC #$014C
      + TAX
        LDA #$38FC
        STA.L $7F8381,X ; graphics
        STA.L $7F8383,X
        STA.L $7F83C1,X
        STA.L $7F83C3,X
        SEP #$30
        STY $00
        LDA #$0C
        SEC
        SBC $00
        TAX
        LDA #$00
        STA.L $7FC8B0,X ; collision
        TXA
        ASL #2
        TAX
        LDA #$FC
        STA.L $7F8381,X ; graphics
        STA.L $7F8383,X
        STA.L $7F83C1,X
        STA.L $7F83C3,X
        DEY
        BRA -
        
    .finish_thisboss:
        JSL !_F+$0084C8
        JMP .no_mode7
    
    .bowser:
        STZ $2115
        STZ $2116
        STZ $2117
        REP #$10
        LDX #$4000
        LDA #$FF
      - STA $2118
        DEX
        BNE -
        SEP #$10
        
        LDX #$09
        JSL !_F+$03DD7D
        JSL upload_bowser_timer_graphics
        JMP .no_mode7
        
    .no_mode7:
        
        PLP
        RTS

; restore all palettes from respective data
restore_all_palettes:
        PHP
        REP #$10
        SEP #$20

        LDA #$00
        STA $2121 ; cgram address
        LDX #$0703
        STX $4302 ; dma0 destination address
        LDA #$7E
        STA $4304 ; dma0 destination bank
        LDX #$0200
        STX $4305 ; dma0 length
        STZ $4300 ; dma0 parameters
        LDA #$22 ; $2122 cgram data write
        STA $4301 ; dma0 source
        LDA #$01 ; channel 0
        STA $420B ; dma enable
        
        PLP
        RTS

print "inserted ", bytes, "/32768 bytes into bank $1A"