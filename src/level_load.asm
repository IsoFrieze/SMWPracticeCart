ORG !_F+$128000

reset bytes

; this code is run once on level load (during the black screen)
level_load:
        PHP
        PHB
        PHK
        PLB
        SEP #$20
        
        JSR check_lagless
        JSR check_pal
        JSR check_midway_entrance
        
        LDA !l_r_function
        BEQ +
        
        DEC A
        ASL A
        TAX
        JSR (l_r_functions,X)
        BRA .merge
        
      + JSR save_room_properties
    
        LDA $141A ; sublevel count
        BNE .merge
        JSR save_level_properties
        
    .merge:
        LDA $148F ; held item flag
        DEC A
        STA !held_item_slot
        STZ !freeze_timer_flag
        JSL reset_igt_frames
        LDA #$FF
        STA !save_timer_address+2
        
        PLB
        PLP
        
        RTL
        
l_r_functions:
        dw setup_room_reset
        dw setup_level_reset
        dw setup_room_advance
        
; if lag is disabled, disable saving a time
check_lagless:
        LDA.L !status_scorelag
        BNE +
        LDA #$01
        STA.L !spliced_run
    +   RTS
        
; if current version is pal, disable saving a time
check_pal:
        LDA.L !status_region
        CMP #$02
        BCC +
        LDA #$01
        STA.L !spliced_run
    +   RTS

; check if we should advance to the midway entrance of the level
check_midway_entrance:
        LDA.L !status_lrreset
        BNE .done
        LDA !l_r_function
        CMP #$02
        BEQ +
        LDA $141A
        AND #$7F
        BNE .done
      + LDA !util_axlr_hold
        AND #%00110000
        CMP #%00110000
        BNE .done
        
        LDA #$01
        STA !start_midway
        
    .done:
        RTS

; prepare the level load if we just did a room reset
setup_room_reset:
        LDA #$01
        STA.L !spliced_run
        
        LDA !restore_room_powerup
        STA $19 ; powerup
        LDA !restore_room_itembox
        STA $0DC2 ; item box
        LDA !restore_room_yoshi
        STA $13C7 ; yoshi color
        STA $0DBA ; ow yoshi color
        STA $0DC1 ; persistent yoshi
        LDA !restore_room_coins
        STA $0DBF ; coins
        LDA !restore_room_takeoff
        STA $149F ; takeoff
        LDA !restore_room_dragoncoins
        STA $1420 ; dragon coins
        LDA !restore_room_igt
        STA $0F31
        LDA !restore_room_igt+1
        STA $0F32
        LDA !restore_room_igt+2
        STA $0F33 ; in game timer
        LDA !restore_level_timer_minutes
        STA !level_timer_minutes
        LDA !restore_level_timer_seconds
        STA !level_timer_seconds
        LDA !restore_level_timer_frames
        STA !level_timer_frames
        DEC $141A ; sublevel count
        LDA !restore_room_xpos
        STA $D1 ; mario x position low byte
        LDA !restore_room_xpos+1
        STA $D2 ; mario x position high byte
        LDA !restore_room_tide
        STA $1B9D ; layer 3 tide timer
        LDA !restore_room_rng_index
        STA !rng_index
        LDA !restore_room_rng_index+1
        STA !rng_index+1
        LDA !restore_room_rng_index+2
        STA !rng_index+2
        
        LDX #$03
      - LDA !restore_room_boo_ring,X
        STA $0FAE,X ; boo ring angles
        LDA !restore_room_rng,X
        STA $148B,X ; rng
        DEX
        BPL -
        
        LDA !restore_room_item
        BEQ +
        STA $9E ; sprite 0 id
        LDA #$0B ; carried
        STA $14C8 ; sprite 0 status
        
      + JSR restore_common_aspects
        RTS

; prepare the level load if we just did a level reset
setup_level_reset:
        LDA #$00
        STA.L !spliced_run
        
        LDA !restore_level_powerup
        STA $19 ; powerup
        LDA !restore_level_itembox
        STA $0DC2 ; item box
        LDA !restore_level_yoshi
        STA $13C7 ; yoshi color
        STA $0DBA ; ow yoshi color
        STA $0DC1 ; persistent yoshi
        STZ $0DBF ; coins
        STZ $149F ; takeoff
        LDA !restore_level_igt
        STA $0F31
        STZ $0F32
        STZ $0F33 ; in game timer
        STZ $1B95 ; yoshi heaven flag
        STZ $1420 ; dragon coins
        STZ $2A ; mode 7 center
        STZ $13CE ; midway flag
        STZ !level_timer_minutes
        STZ !level_timer_seconds
        STZ !level_timer_frames
        STZ !record_used_powerup
        STZ !record_used_cape
        STZ !record_used_yoshi
        STZ !record_used_orb
        STZ !record_lunar_dragon
        LDA !restore_level_xpos
        STA $D1 ; mario x position low byte
        LDA !restore_level_xpos+1
        STA $D2 ; mario x position high byte
        STZ $1B9D ; layer 3 tide timer
        STZ !rng_index
        STZ !rng_index+1
        STZ !rng_index+2
        
        ; set msb so it's not 00, which is a special case for entering the level
        ; we'll turn this byte into fnnnnnnn, f = 0 if just entered level, n = sublevel count
        LDA #$80 
        STA $141A ; sublevel count
        
        LDX #$03
      - LDA !restore_level_boo_ring,X
        STA $0FAE,X ; boo ring angles
        STZ $148B,X ; rng
        DEX
        BPL -
        
        JSR restore_common_aspects
        
        LDA $13BF ; translevel
        LDX #$05
      - CMP water_entrance_levels,X
        BEQ +
        DEX
        BPL -
        BRA .done
      + STZ $9D ; sprite lock
        
    .done:
        RTS

; translevels that start with an underwater pipe entrance
; and coincidentally start with sprite lock OFF for some reason
water_entrance_levels:
        db $0A,$0B,$11,$18,$44,$54

; prepare the level load if we just did a room advance
setup_room_advance:
        LDA #$01
        STA.L !spliced_run
        
        LDA !restore_room_xpos
        PHA
        LDA !restore_room_xpos+1
        PHA
        
        ; bad form but this bug sucks and I'm done dealing with it
        ; hey, this is assembly. if it works, it's good Kappa b
        JSR save_room_properties_but_not_xpos
        JSR restore_common_aspects
        
        PLA
        STA $D2
        PLA
        STA $D1
                
        RTS

; restore things that are common to both room and level resets
restore_common_aspects:
        STZ $14A3 ; punch yoshi timer
        STZ $36
        STZ $37 ; mode 7 angle
        STZ $14AF ; on/off switch
        STZ $1432 ; coin snake
        STZ $1B9F ; reznor floor
        STZ $14B1
        STZ $14B5
        STZ $14B6 ; bowser timers
        LDA $0D9B ; boss flag
        STZ $1434 ; keyhole timer
        STZ $1493 ; end level timer
        CMP #$C1
        BNE +
        LDA #$02
        STA $1884 ; bowser HP
      + STZ $1496
        STZ $1497 ; mario animation timers
        STZ $1B9A ; scrolling background
        STZ !room_timer_minutes
        STZ !room_timer_seconds
        STZ !room_timer_frames
        STZ !pause_timer_minutes
        STZ !pause_timer_seconds
        STZ !pause_timer_frames
        
        LDX #$03
      - STZ $1A,X ; layer 1 x/y positions
        STZ $1E,X ; layer 2 x/y positions
        STZ $26,X ; layer 2 - layer 1 x/y positions
        DEX
        BPL -
        
        REP #$10
        LDX #$017F
      - STZ $19F8,X ; item memory
        DEX
        BPL -
        SEP #$10
        RTS
        
; save everything after entering a new room
save_room_properties:
        LDA $D1 ; mario x position low byte
        STA !restore_room_xpos
        LDA $D2 ; mario x position high byte
        STA !restore_room_xpos+1
    .but_not_xpos:
        LDA $19 ; powerup
        STA !restore_room_powerup
        LDA $0DC2 ; item box
        STA !restore_room_itembox
        LDA $187A ; riding yoshi flag
        BNE +
        STZ !restore_room_yoshi
        BRA ++
      + LDA $13C7 ; yoshi color
        STA !restore_room_yoshi
     ++ LDA $149F ; takeoff
        STA !restore_room_takeoff
        LDA $0DBF ; coins
        STA !restore_room_coins
        LDA $1420 ; dragon coins
        STA !restore_room_dragoncoins
        LDA $1B9D ; layer 3 tide timer
        STA !restore_room_tide
        
        LDX #$0B
      - LDA $14C8,X ; sprite status
        CMP #$0B ; carried
        BEQ ++
        DEX
        BPL -
        STZ !restore_room_item
        BRA +
     ++ LDA $9E,X ; sprite id
        STA !restore_room_item

      + LDX #$03
      - LDA $0FAE,X ; boo ring angle
        STA !restore_room_boo_ring,X
        LDA $148B,X ; rng
        STA !restore_room_rng,X
        DEX
        BPL -
        
        LDX #$02
      - LDA $0F31,X ; timer
        STA !restore_room_igt,X
        DEX
        BPL -
        
        LDA !rng_index
        STA !restore_room_rng_index
        LDA !rng_index+1
        STA !restore_room_rng_index+1
        LDA !rng_index+2
        STA !restore_room_rng_index+2
        LDA !level_timer_minutes
        STA !restore_level_timer_minutes
        LDA !level_timer_seconds
        STA !restore_level_timer_seconds
        LDA !level_timer_frames
        STA !restore_level_timer_frames
        STZ !room_timer_minutes
        STZ !room_timer_seconds
        STZ !room_timer_frames
        STZ !pause_timer_minutes
        STZ !pause_timer_seconds
        STZ !pause_timer_frames
        
        RTS
        
; add the frame count stored in A to the timer
add_many_to_timer:
        CLC
        ADC !level_timer_frames
    .check_frames:
        CMP #$3C
        BCS .carry_frame
        STA !level_timer_frames
        LDA !level_timer_seconds
        BRA .check_seconds
    .carry_frame:
        SEC
        SBC #$3C
        INC !level_timer_seconds
        BRA .check_frames
    .check_seconds:
        CMP #$3C
        BCS .carry_seconds
        STA !level_timer_seconds
        LDA !level_timer_minutes
        BRA .check_minutes
    .carry_seconds:
        SEC
        SBC #$3C
        INC !level_timer_minutes
        BRA .check_seconds
    .check_minutes:
        CMP #$0A
        BCS .timer_overflow
        STA !level_timer_minutes
        RTL
    .timer_overflow:
        LDA #$09
        STA !level_timer_minutes
        LDA #$3B
        STA !level_timer_seconds
        STA !level_timer_frames
        RTL
        
; save everything after entering a new level
save_level_properties:
        LDA $19 ; powerup
        STA !restore_level_powerup
        LDA $0DC2 ; item box
        STA !restore_level_itembox
        LDA $187A ; riding yoshi flag
        BNE +
        STZ !restore_level_yoshi
        BRA ++
      + LDA $13C7 ; yoshi color
        STA !restore_level_yoshi
     ++ LDA $D1 ; mario x position low byte
        STA !restore_level_xpos
        LDA $D2 ; mario x position high byte
        STA !restore_level_xpos+1
        LDA $1B9D ; layer 3 tide timer
        STA !restore_room_tide
        
        LDX #$03
      - LDA $0FAE,X ; boo ring angle
        STA !restore_level_boo_ring,X
        DEX
        BPL -
        
        STZ $0DBF ; coins
        STZ !level_timer_minutes
        STZ !level_timer_seconds
        STZ !level_timer_frames
        STZ !pause_timer_minutes
        STZ !pause_timer_seconds
        STZ !pause_timer_frames
        STZ !record_used_powerup
        STZ !record_used_cape
        STZ !record_used_yoshi
        STZ !record_used_orb
        STZ !record_lunar_dragon
        STZ !level_finished
        
        RTS

; copy screen exit to backup registers
; this isn't done in the above code because $17BB is only available during the load routine
level_load_exit_table:
        CPX #$20
        BCC +
        LDX #$00
      + LDA $1B93
        STA !recent_secondary_flag
        LDA $19B8,X ; exit table
        STA $17BB ; exit backup
        STA !recent_screen_exit
        RTL

; save starting time to backup register
; this isn't done in the above code because X is only the level index during the load routine
; also check for lemmy's castle region difference
level_load_timer:
        LDA.L !status_region
        BNE +
        LDA $13BF ; translevel
        CMP #$40 ; lemmy's castle
        BNE +
        LDA #$03
        BRA ++
      + LDA $0584D7,X ; timer table
     ++ STA !restore_level_igt
        RTL

; load $01 - $03 with source of music bank
; X = music bank 0-2
set_music_bank:
        PHB
        PHK
        PLB
        
        LDA.L !status_music
        BEQ +
        LDA muted_music_location
        STA $00
        LDA muted_music_location+1
        STA $01
        LDA muted_music_location+2
        STA $02
        BRA .done
    
      + STX $00
        TXA
        ASL A
        CLC
        ADC $00
        TAX
        LDA music_bank_locations,X
        STA $00
        LDA music_bank_locations+1,X
        STA $01
        LDA music_bank_locations+2,X
        STA $02
        
    .done
        PLB
        RTL

music_bank_locations:
        dl $0E98B1,$0EAED6,$03E400
muted_music_location:
        dl muted_music_bank
muted_music_bank:
        incbin "bin/music_empty_bank.bin"

; upload the graphics for the sprite slots and dynmeter, if they are enabled
load_slots_graphics:
        PHP
        REP #$10
        SEP #$20
        LDA.L !status_slots
        BNE +
        LDA.L !status_dynmeter
        BEQ .done
        
      + LDY #$0080
        LDA #$80
        STA $2115 ; vram increment
        PHK
        PLA
        
        LDX #$6440
        STX $2116 ; vram address
        LDX #sprite_slots_graphics
        JSL load_vram
        
        LDX #$6540
        STX $2116 ; vram address
        LDX #sprite_slots_graphics+$80
        JSL load_vram
        
        LDX #$6680
        STX $2116 ; vram address
        LDX #sprite_slots_graphics+$100
        JSL load_vram
        
        LDX #$6780
        STX $2116 ; vram address
        LDX #sprite_slots_graphics+$180
        JSL load_vram
        
    .done:
        PLP
        RTL

; upload the tiles used for the timer during the bowser fight
upload_bowser_timer_graphics:
        PHP
        SEP #$20
        REP #$10
        
        LDA $0D9B ; boss flag
        CMP #$C1
        BNE .done
        
        LDA #$80
        STA $2100 ; force blank
        STZ $4200 ; nmi disable
        
        LDA #$80
        STA $2115 ; vram properties
        PHK
        PLA
        LDY #$0140
        LDX #$6A80
        STX $2116 ; vram address
        LDX #sprite_slots_graphics
        JSL load_vram
        
        LDY #$00C0
        LDX #$6B80
        STX $2116 ; vram address
        LDX #sprite_slots_graphics+$140
        JSL load_vram
        
        LDY #$0080
        LDX #$6980
        STX $2116 ; vram address
        LDX #sprite_slots_graphics+$200
        JSL load_vram
        
        LDA #$81
        STA $4200 ; nmi enable
        LDA #$0F
        STA $2100 ; exit force blank
        
    .done:
        PLP
        RTL
        
sprite_slots_graphics:
        incbin "bin/sprite_slots_graphics.bin"

; fix the graphics upload routine for reznor, iggy, & larry
; this really should have been done already, they were just lucky that
; the last thing they uploaded ended at $7FFF :p
fix_iggy_larry_graphics:
        STZ $2116
        STZ $2117 ; vram address write
        LDY #$0000
        LDX #$03FF
        RTL

; at the very start of level loading, latch the apu timer so we can figure out the load time
latch_apu:
        PHP
        REP #$20
      - LDA $2140
        BEQ -
        STA !apu_timer_latch
        PLP
        RTL

; complete the level load by updating the timer with the calculated load time
do_final_loading:
        LDA $141A ; sublevel count
        BEQ .final_level_reset
        LDA !l_r_function
        ASL A
        TAX
        JMP (.final_l_r_functions,X)
        
    .final_l_r_functions:
        dw .final_normal_advance
        dw .final_room_reset
        dw .final_level_reset
        dw .final_room_advance
        dw .final_level_reset
        
    .final_normal_advance:
    .final_room_advance:
        JSL calculate_load_time
    .final_room_reset:
        LDA !apu_timer_difference
        JSL add_many_to_timer
    .final_level_reset:
        
        STZ !l_r_function
        RTL

; at the very end of level loading, latch the apu timer and calculate the load time
calculate_load_time:
        REP #$20
      - LDA $2140
        BEQ -
        SEC
        SBC !apu_timer_latch ; divide difference by 0x1C0
        STA $4204 ; dividend
        LDX #$07
        STX $4206 ; divisor
        NOP #10
        LDA $4214 ; quotient
        LSR #6
        CLC
        ADC #$001F ; add #$1F to account for the fade in time
        LDX $2A ; mode 7 center
        BNE +
        CLC
        ADC #$001F ; add #$1F to account for the fade out time
      + SEP #$20
        STA !apu_timer_difference
        RTL

; initialize status bar properties
init_statusbar_properties:
        PHP
        PHB
        SEP #$30
        
        LDX #$A0
        LDA #$38
      - STA $0904,X
        DEX
        BNE -
        
        LDA #$7E
        STA $02
        LDA #$09
        STA $01
        
        LDY #$5F
        
      - LDA [!statusbar_layout_ptr],Y
        DEY #3
        CLC
        ADC #$05 ; 7E0905 - temporary mirror for statusbar properties (shared with fade palette)
        STA $00
        
        LDA [!statusbar_layout_ptr],Y
        CMP #$14
        BCS +
        ASL A
        TAX
        INY
        JSR (.meter,X)
        DEY
      + DEY
        BPL -
        
        PHK
        PLB
        
        LDA $0100
        CMP #$1D ; load overworld menu
        BCS +
        LDA #$00
        STA $2116
        LDA #$50
        STA $2117
        BRA .merge
      + LDA #$A0
        STA $2116
        LDA #$53
        STA $2117
        
    .merge:
        LDX #$00
      - LDA #$00
        STA $4310
        LDA #$19
        STA $4311
        LDA #$7E
        STA $4314
        LDA #$20
        STA $4315
        LDA #$00
        STA $4316
        
        LDA #$80
        STA $2115
        LDA .tiles_low,X
        STA $4312
        LDA .tiles_high,X
        STA $4313
        LDA #$02
        STA $420B
        INX
        CPX #$05
        BNE -
        
        PLB
        PLP
        RTL
        
    .tiles_high:
        db $09,$09,$09,$09,$09
    .tiles_low:
        db $05,$25,$45,$65,$85
    
    .meter:
        dw .nothing
        dw .item_box
        dw .mario_speed
        dw .mario_takeoff
        dw .mario_pmeter
        dw .yoshi_subpixel
        dw .held_subpixel
        dw .lag_frames
        dw .timer_level
        dw .timer_room
        dw .timer_stopwatch
        dw .coin_count
        dw .in_game_time
        dw .slowdown
        dw .input_display
        dw .name
        dw .movie_recording
        dw .memory_7e
        dw .memory_7f
        dw .rng
        
    .mario_speed:
        LDA #$2C
        JMP .store_2
        
    .memory_7e:
    .mario_takeoff:
        LDA #$38
        JMP .store_2
        
    .yoshi_subpixel:
        LDA #$28
        JMP .store_2
        
    .mario_pmeter:
    .memory_7f:
    .held_subpixel:
        LDA #$3C
        JMP .store_2
        
    .lag_frames:
        LDA #$2C
        JMP .store_5
        
    .timer_level:
        LDA [!statusbar_layout_ptr],Y
        CMP #$02
        PHP
        LDA #$3C
        PLP
        BEQ .store_6
        JMP .store_8
        
    .timer_room:
        LDA [!statusbar_layout_ptr],Y
        CMP #$02
        PHP
        LDA #$38
        PLP
        BEQ .store_5
        JMP .store_7
        
    .timer_stopwatch:
        LDA [!statusbar_layout_ptr],Y
        CMP #$02
        PHP
        LDA #$28
        PLP
        BEQ .store_5
        JMP .store_7
        
    .coin_count:
        LDA #$3C
        STA [$00]
        INC $00
        LDA [!statusbar_layout_ptr],Y
        PHP
        LDA #$38
        PLP
        BEQ .store_2
        JMP .store_1
        
    .in_game_time:
        LDA #$3C
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        LDA [!statusbar_layout_ptr],Y
        CMP #$01
        PHP
        LDA #$38
        PLP
        BEQ .store_2
        BCS .store_1
        RTS
    
    .slowdown:
        LDA #$2C
        JMP .store_1
        
    .name:
        PHB
        PHK
        PLB
        LDA !in_playback_mode
        BEQ +
        PLB
        LDA #$2C
        JMP .store_4
      + PLB
        LDA [!statusbar_layout_ptr],Y
        TAX
        LDA.L name_colors,X
        JMP .store_4
    
    .rng:
        LDA [!statusbar_layout_ptr],Y
        PHP
        LDA #$38
        PLP
        BEQ .store_5
        JMP .store_4
        
    .store_8:
        STA [$00]
        INC $00
    .store_7:
        STA [$00]
        INC $00
    .store_6:
        STA [$00]
        INC $00
    .store_5:
        STA [$00]
        INC $00
    .store_4:
        STA [$00]
        INC $00
    .store_3:
        STA [$00]
        INC $00
    .store_2:
        STA [$00]
        INC $00
    .store_1:
        STA [$00]
        RTS
        
    .movie_recording:
        LDA [!statusbar_layout_ptr],Y
        BEQ +
        LDA #$2C
        JMP .store_4
      + LDA #$28
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        LDA #$68
        STA [$00]
        RTS
    
    .input_display:
        LDA [!statusbar_layout_ptr],Y
        ASL A
        TAX
        JMP (.input_properties,X)
        
    .input_properties:
        dw .wide
        dw .compact_horiz
        dw .compact_horiz
        dw .compact_vert
        dw .compact_vert
        
    .wide:
        LDA #$28
        INC $00
        STA [$00]
        INC $00
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        INC $00
        STA [$00]
        LDA $00
        CLC
        ADC #$1A
        STA $00
        LDA #$28
        STA [$00]
        INC $00
        INC $00
        STA [$00]
        INC $00
        INC $00
        INC $00
        STA [$00]
        INC $00
        INC $00
        STA [$00]
        LDA $00
        CLC
        ADC #$1A
        STA $00
        LDA #$28
        STA [$00]
        INC $00
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        INC $00
        STA [$00]
        RTS
        
    .compact_horiz:
        LDA #$28
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        LDA $00
        CLC
        ADC #$1B
        STA $00
        LDA #$28
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        RTS
        
    .compact_vert:
        LDA #$28
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        LDA $00
        CLC
        ADC #$1E
        STA $00
        LDA #$28
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        LDA $00
        CLC
        ADC #$1E
        STA $00
        LDA #$28
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        LDA $00
        CLC
        ADC #$1E
        STA $00
        LDA #$28
        STA [$00]
        INC $00
        STA [$00]
        INC $00
        STA [$00]
        RTS
    
    .item_box:        
        LDA #$38
        STA $0905+$2E
        STA $0905+$2F
        STA $0905+$30
        STA $0905+$4E
        STA $0905+$6E
        LDA #$78
        STA $0905+$31
        STA $0905+$51
        STA $0905+$71
        LDA #$B8
        STA $0905+$8E
        STA $0905+$8F
        STA $0905+$90
        LDA #$F8
        STA $0905+$91
        
    .nothing:
        RTS

name_colors:
        db $28,$38,$3C
        
title_screen_load:
        PHB
        PHK
        PLB
        
        JSR titlescreen_total_time_count
        LDA #$03
        STA $12
        JSL !_F+$0084C8
        JSR draw_title_screen_extras
        
        PLB
        RTL

titlescreen_total_time_count:
        PHP        
        REP #$30
        
        STZ $00
        LDY #$02B8
      - LDA intended_exit_type_indicies,Y
        ASL #2
        TAX
        SEP #$20
        LDA $700000,X
        BMI +
        LDA $700001,X
        BMI +
        LDA $700002,X
        BMI +
        LDA $700003,X
        AND #%00100000
        BNE +
        REP #$20
        INC $00
      + DEY #2
        REP #$20
        BPL -
        
        LDA $00
        STA !exit_type_count
        CMP #$015D
        BEQ +
        JMP .done
        
        ; calculate frames 12563651
      + STZ $00
        LDY #$02B8
      - LDA intended_exit_type_indicies,Y
        ASL #2
        TAX
        LDA $700002,X
        AND #$00FF
        CLC
        ADC $00
        STA $00
        DEY #2
        BPL -
        
        LDA $00
        STA $4204 ; div C
        LDA #$003C
        STA $4206 ; div B
        NOP #10
        LDA $4216 ; div remainder
        AND #$00FF
        STA !total_frames
        LDA $4214 ; div result
        AND #$00FF
        
        ; calculate seconds
        STA $00
        LDY #$02B8
      - LDA intended_exit_type_indicies,Y
        ASL #2
        TAX
        LDA $700001,X
        AND #$00FF
        CLC
        ADC $00
        STA $00
        DEY #2
        BPL -
        
        LDA $00
        STA $4204 ; div C
        LDA #$003C
        STA $4206 ; div B
        NOP #10
        LDA $4216 ; div remainder
        AND #$00FF
        STA !total_seconds
        LDA $4214 ; div result
        AND #$00FF
        
        ; calculate minutes & hours
        STA $00
        LDY #$02B8
      - LDA intended_exit_type_indicies,Y
        ASL #2
        TAX
        LDA $700000,X
        AND #$00FF
        CLC
        ADC $00
        STA $00
        DEY #2
        BPL -
        
        LDA $00
        STA $4204 ; div C
        LDA #$003C
        STA $4206 ; div B
        NOP #10
        LDA $4216 ; div remainder
        AND #$00FF
        STA !total_minutes
        LDA $4214 ; div result
        AND #$00FF
        STA !total_hours
        
    .done:
        PLP
        RTS

intended_exit_type_indicies:
        dw $0008,$0009,$000A,$000B,$0010,$0011,$0012,$0013
        dw $0022,$0024,$0025,$0026,$0028,$0029,$002A,$002B
        dw $0030,$0031,$0032,$0033,$0038,$0039,$003A,$0040
        dw $0041,$0042,$0048,$0049,$004A,$004B,$004C,$004D
        dw $004E,$0050,$0051,$0052,$0053,$0054,$0055,$0056
        dw $0057,$0058,$0059,$005A,$0060,$0061,$0062,$0063
        dw $0068,$0069,$006A,$006B,$0070,$0071,$0072,$0078
        dw $0079,$007A,$007B,$007D,$007E,$007F,$0080,$0081
        dw $0082,$0083,$0088,$0089,$008A,$008B,$0098,$0099
        dw $009A,$009C,$009D,$009E,$00A0,$00A1,$00A2,$00A8
        dw $00A9,$00AA,$00AB,$00AC,$00AD,$00AE,$00AF,$00C0
        dw $00C1,$00C2,$00C3,$00D0,$00D1,$00D2,$00D8,$00D9
        dw $00DA,$00E0,$00E1,$00E2,$00E3,$00E8,$00E9,$00EA
        dw $00EB,$00F8,$00F9,$00FA,$0100,$0101,$0102,$0103
        dw $0108,$0109,$010A,$0110,$0111,$0112,$0113,$0118
        dw $0119,$011A,$011B,$011C,$011D,$011E,$011F,$0120
        dw $0121,$0122,$0123,$0124,$0125,$0126,$0128,$0129
        dw $012A,$0130,$0131,$0132,$0133,$0138,$0139,$013A
        dw $013B,$0148,$0149,$014A,$014B,$0150,$0151,$0152
        dw $0153,$0158,$0159,$015A,$015B,$0168,$0169,$016A
        dw $016B,$016C,$016D,$016E,$016F,$0170,$0171,$0172
        dw $0173,$0178,$0179,$017A,$017B,$0188,$0189,$018A
        dw $0190,$0191,$0192,$0198,$0199,$019A,$019D,$019E
        dw $01A0,$01A1,$01A2,$01A3,$01A8,$01A9,$01AA,$01B8
        dw $01B9,$01BA,$01BB,$01C0,$01C1,$01C2,$01C3,$01C4
        dw $01C5,$01C6,$01C7,$01C8,$01C9,$01CA,$01CB,$01CC
        dw $01CD,$01CE,$01D0,$01D1,$01D2,$01D3,$01D8,$01D9
        dw $01DA,$01E0,$01E1,$01E2,$01E3,$01E4,$01E5,$01E6
        dw $01E7,$01E8,$01E9,$01EA,$01EB,$01F0,$01F1,$01F2
        dw $01F3,$01F4,$01F5,$01F6,$01F7,$01F8,$01F9,$01FA
        dw $0200,$0201,$0202,$0208,$0209,$020A,$020B,$020C
        dw $020D,$020E,$0210,$0211,$0212,$0214,$0215,$0216
        dw $0218,$0219,$021A,$021B,$021C,$021D,$021E,$021F
        dw $0220,$0221,$0222,$0223,$0224,$0225,$0226,$0227
        dw $0228,$0229,$022A,$0230,$0231,$0232,$0233,$0238
        dw $0239,$023A,$023B,$023C,$023D,$023E,$023F,$0248
        dw $0249,$024A,$024B,$0250,$0251,$0252,$0253,$0258
        dw $0259,$025A,$025B,$0260,$0261,$0262,$0263,$0270
        dw $0271,$0272,$0273,$0278,$0279,$027A,$027B,$0280
        dw $0281,$0282,$0283,$0288,$0289,$028A,$028B,$02A0
        dw $02A1,$02A2,$02A4,$02A5,$02A6,$02B0,$02B1,$02B2
        dw $02B4,$02B5,$02B6,$02C1,$02C2,$02C3,$02C5,$02C6
        dw $02C7,$02C8,$02C9,$02CA,$02CC,$02CD,$02CE,$02D0
        dw $02D1,$02D2,$02D4,$02D5,$02D6
        
; draw "Practice Cart", "Dotsarecool", version, & exit type count + total time
draw_title_screen_extras:
        PHP
        REP #$30
        
        ; static things
        LDA.L $7F837B
        TAX
        LDY #$0000
      - LDA stripe_practicecart,Y
        STA.L $7F837D,X
        INX #2
        INY #2
        CMP #$FFFF
        BNE -
        
        DEX #2
        
        ; exit type count
        LDY #$0000
        LDA !exit_type_count
      - CMP #$000A
        BCC +
        SEC
        SBC #$000A
        INY
        BRA -
        
      + ORA #$2800
        STA.L $7F837D+8,X
        TYA
        LDY #$0000
      - CMP #$000A
        BCC +
        SEC
        SBC #$000A
        INY
        BRA -
       
      + ORA #$2800
        STA.L $7F837D+6,X
        TYA
        AND #$00FF
        ORA #$2800
        STA.L $7F837D+4,X
        
        LDA #$2C52
        STA.L $7F837D,X
        LDA #$0500
        STA.L $7F837D+2,X
        LDA #$FFFF
        STA.L $7F837D+10,X
        
        TXA
        CLC
        ADC #$000A
        STA.L $7F837B
        TAX
        
        LDA !exit_type_count
        CMP #$015D
        BEQ +
        JMP .done
        
        ; if all exit times are filled out, display total time too
      + LDA #$4B52
        STA.L $7F837D+0,X
        LDA #$1500
        STA.L $7F837D+2,X
        LDA #$3C00
        STA.L $7F837D+4,X
        STA.L $7F837D+6,X
        STA.L $7F837D+10,X
        STA.L $7F837D+12,X
        STA.L $7F837D+16,X
        STA.L $7F837D+18,X
        STA.L $7F837D+22,X
        STA.L $7F837D+24,X
        LDA #$3C85
        STA.L $7F837D+8,X
        STA.L $7F837D+14,X
        LDA #$3C86
        STA.L $7F837D+20,X
        LDA #$FFFF
        STA.L $7F837D+26,X
        SEP #$20
        
        LDA !total_hours
        PHX
        SEP #$10
        JSL !_F+$00974C ; hex2dec
        TXY
        REP #$10
        PLX
        STA.L $7F837D+6,X
        TYA
        STA.L $7F837D+4,X
        
        LDA !total_minutes
        PHX
        SEP #$10
        JSL !_F+$00974C ; hex2dec
        TXY
        REP #$10
        PLX
        STA.L $7F837D+12,X
        TYA
        STA.L $7F837D+10,X
        
        LDA !total_seconds
        PHX
        SEP #$10
        JSL !_F+$00974C ; hex2dec
        TXY
        REP #$10
        PLX
        STA.L $7F837D+18,X
        TYA
        STA.L $7F837D+16,X
        
        LDA !total_frames
        PHX
        SEP #$10
        JSL !_F+$00974C ; hex2dec
        TXY
        REP #$10
        PLX
        STA.L $7F837D+24,X
        TYA
        STA.L $7F837D+22,X
        
        REP #$20
        TXA
        CLC
        ADC #$001A
        STA.L $7F837B
        
    .done:
        PLP
        RTS

stripe_practicecart:
        db $51,$EA,$00,$19,$19,$38,$1B,$38
        db $0A,$38,$0C,$38,$1D,$38,$12,$38
        db $0C,$38,$0E,$38,$FC,$38,$0C,$38
        db $0A,$38,$1B,$38,$1D,$38
stripe_dotsarecool:
        db $53,$07,$00,$25,$FC,$28,$FC,$28
        db $FC,$28,$FC,$28,$FC,$28,$12,$28
        db $1C,$28,$18,$28,$0F,$28,$1B,$28
        db $12,$28,$0E,$28,$23,$28,$0E,$28
        db $FC,$28,$FC,$28,$FC,$28,$FC,$28
        db $FC,$28
stripe_version:
        db $53,$38,$00,$0B,$1F,$3C,!version_a,$3C
        db $24,$3C,!version_b,$3C,$24,$3C,!version_c,$3C
stripe_exittypecount:
        db $52,$30,$00,$09,$78,$28,$FC,$28
        db $03,$28,$04,$28,$09,$28
        db $FF,$FF

ORG !_F+$12F000

j_levels:
        incbin "bin/j_levels.bin"
j_level_layer1_ptrs:
        incbin "bin/j_level_layer1_ptrs.bin"

print "inserted ", bytes, "/32768 bytes into bank $12"