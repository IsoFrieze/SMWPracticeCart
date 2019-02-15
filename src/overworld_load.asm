ORG !_F+$118000

reset bytes

; this code is run once on overworld load
overworld_load:
        LDA !spliced_run
        BNE .done_saving
        LDA !save_timer_address+2
        BMI .done_saving ; bank >= 80 -> no record
        LDA !record_used_orb
        BEQ +
        
        ; if you used an orb to complete the level, you must let the parade play out for it to count
        LDA $0DD5 ; level exit type
        CMP #$80 ; type = death or start/select
        BEQ .done_saving
        
        ; failsafe: if level was beaten in under 1 second, just discard the time, it was probably a glitch
      + LDA !level_timer_minutes
        ORA !level_timer_seconds
        BEQ .done_saving
    
        LDA !record_used_powerup
        BNE +
        JSR attempt_timer_save
      + LDA !save_timer_address
        CLC
        ADC #$04
        STA !save_timer_address
        
        LDA !record_used_cape
        BNE +
        JSR attempt_timer_save
      + LDA !save_timer_address
        CLC
        ADC #$04
        STA !save_timer_address
        
        JSR attempt_timer_save
        LDA !save_timer_address
        CLC
        ADC #$04
        STA !save_timer_address
        
        LDA !record_lunar_dragon
        BEQ .done_saving
        JSR attempt_timer_save
        
    .done_saving:
        LDA #$FF
        STA !save_timer_address+2
        STZ !l_r_function
        STZ.W !slowdown_speed
        STZ !in_overworld_menu
        JSL !_F+$04DAAD ; layer 2 tilemap upload routine
        JSR setup_shadow
        JSL update_meterset_pointer
        
        LDA !in_record_mode
        ORA !in_playback_mode
        BEQ +
        LDA #$00
        STA.L !save_state_exists
        
      + LDA !in_record_mode
        BEQ +
        JSR save_movie_details
        STZ !in_record_mode
        
      + LDA !in_playback_mode
        BEQ .no_playback
        STZ !in_playback_mode
        
        ; restore settings
        LDX #$1F
      - LDA.L !backup_status_table,X
        STA.L !status_table,X
        DEX
        BPL -
        JSL restore_basic_settings
        
    .no_playback:
        STZ !ow_display_times
        LDA #$00
        STA.L !spliced_run
        STZ !start_midway
        JSR identify_movies
        
        RTL

; this code is run once on overworld load, but after everything else has loaded already
late_overworld_load:
        PHP
        SEP #$20
        REP #$10
        
        LDA #$80
        STA $2115 ; vram increment
        LDX #$4490
        STX $2116 ; vram address
        PHK
        PLA ; #bank of overworld_layer_3_tiles
        LDX #overworld_layer_3_tiles
        LDY #$0030
        JSL load_vram
        
        LDX #$46A0
        STX $2116 ; vram address
        PHK
        PLA ; #bank of overworld_layer_3_tiles
        LDX #overworld_layer_3_tiles+$30
        LDY #$0030
        JSL load_vram
        
        LDX #$4200
        STX $2116 ; vram address
        PHK
        PLA ; #bank of overworld_layer_3_tiles
        LDX #overworld_layer_3_tiles+$60
        LDY #$0050
        JSL load_vram
        
        LDX #$4D30
        STX $2116 ; vram address
        PHK
        PLA ; #bank of overworld_layer_3_tiles
        LDX #overworld_layer_3_tiles+$B0
        LDY #$0040
        JSL load_vram
        
        LDX #$4668
        STX $2116 ; vram address
        PHK
        PLA ; #bank of overworld_layer_3_tiles
        LDX #overworld_layer_3_tiles+$F0
        LDY #$0060
        JSL load_vram
        
        LDX #$46B8
        STX $2116 ; vram address
        PHK
        PLA ; #bank of overworld_layer_3_tiles
        LDX #overworld_layer_3_tiles+$150
        LDY #$0020
        JSL load_vram
        
        LDX #$4130
        STX $2116 ; vram address
        PHK
        PLA ; #bank of overworld_layer_3_tiles
        LDX #overworld_layer_3_tiles+$160
        LDY #$0010
        JSL load_vram
        
        LDX #$4B70
        STX $2116 ; vram address
        PHK
        PLA ; #bank of overworld_layer_3_tiles
        LDX #overworld_layer_3_tiles+$170
        LDY #$0070
        JSL load_vram
        
        LDX #$6BD0
        STX $2116 ; vram address
        PHK
        PLA ; #bank of overworld_object_tiles
        LDX #overworld_object_tiles
        LDY #$0060
        JSL load_vram
        
        PLP
        RTL

overworld_layer_3_tiles:
        incbin "bin/overworld_layer3_tiles.bin"
overworld_object_tiles:
        incbin "bin/overworld_object_tiles.bin"
        
; compare the timer stored at !save_timer_address against the current time, and save it if it is faster
attempt_timer_save:
        LDA !save_timer_address
        STA $00
        LDA !save_timer_address+1
        STA $01
        LDA !save_timer_address+2
        STA $02
        
        LDY #$03
        LDA [$00],Y
        AND #$20
        CMP !record_used_orb
        BEQ +
        CMP #$00
        BEQ .done
        BRA .new_record
        
      + LDY #$00
      - CPY #$03
        BEQ .done
        LDA [$00],Y
        CMP #$FF
        BEQ .new_record
        CMP !level_timer_minutes,Y
        BEQ +
        BMI .done
        BPL .new_record
      + INY
        BRA -
        
    .new_record:
        LDY #$00
      - CPY #$03
        BEQ +
        LDA !level_timer_minutes,Y
        STA [$00],Y
        INY
        BRA -
    
      + LDA $1F28 ; yellow switch blocks
        ASL A
        ORA $1F27 ; green switch blocks
        ASL A
        ORA $1F2A ; red switch blocks
        ASL A
        ORA $1F29 ; blue switch blocks
        STA $04
        CLC
        LDA.L !status_special
        ROR A
        ROR A
        TSB $04
        LDA !record_used_yoshi
        TSB $04
        LDA !record_used_orb
        TSB $04
        
        LDA $04
        STA [$00],Y
        
    .done:
        RTS

; this will run when exiting the title screen
prepare_file:
        JSR set_overworld_position
        JSL restore_basic_settings
        JSR check_for_rtc
        RTL

; initialize mario on the overworld
set_overworld_position:
        LDA !save_data_exists
        CMP #$BD
        BEQ +
        JSL delete_all_data
        JSR set_defaults
        BRA .reset
        
      + LDA.L !save_overworld_submap
        CMP #$07
        BCS .reset
        STA $1F11
        LDA.L !save_overworld_x
        STA $1F17
        LDA.L !save_overworld_x+1
        CMP #$02
        BCS .reset
        STA $1F18
        LDA.L !save_overworld_y
        STA $1F19
        LDA.L !save_overworld_y+1
        CMP #$02
        BCS .reset
        STA $1F1A
        LDA.L !save_overworld_animation
        STA $1F13
        JSL update_ow_position_pointers
        BRA +
        
    .reset:
        JSL set_position_to_yoshis_house
      + RTS

; set default settings for all the overworld menu options
set_defaults:
        PHP
        LDA #$00
        STA.L !status_yellow
        STA.L !status_green
        STA.L !status_red
        STA.L !status_blue
        STA.L !status_special
        STA.L !status_powerup
        STA.L !status_itembox
        STA.L !status_yoshi
        STA.L !status_enemy
        STA.L !status_erase
        STA.L !status_slots
        STA.L !status_controller
        STA.L !status_pause
        STA.L !status_timedeath
        STA.L !status_music
        STA.L !status_drop
        STA.L !status_statedelay
        STA.L !status_dynmeter
        STA.L !status_slowdown
        STA.L !status_layout
        STA.L !status_lrreset
        STA.L !status_moviesave
        STA.L !status_movieload
        STA.L !status_region
        LDA #$01
        STA.L !status_scorelag
        STA.L !status_states
        LDA #$17
        STA.L !status_playername
        LDA #$0A
        STA.L !status_playername+1
        LDA #$16
        STA.L !status_playername+2
        LDA #$0E
        STA.L !status_playername+3
        
        REP #$30
        LDX #$011E
      - LDA.L meterset_default,X
        STA.L !statusbar_meters,X
        DEX #2
        BPL -
        
        PLP
        RTS

; set marios position on the overworld to yoshi's house
set_position_to_yoshis_house:
        LDA #$BD
        STA.L !save_data_exists
        LDA #$01
        STA.L !save_overworld_submap
        STA $1F11
        LDA #$68
        STA.L !save_overworld_x
        STA $1F17
        LDA #$00
        STA.L !save_overworld_x+1
        STA $1F18
        LDA #$78
        STA.L !save_overworld_y
        STA $1F19
        LDA #$00
        STA.L !save_overworld_y+1
        STA $1F1A
        LDA #$02
        STA.L !save_overworld_animation
        STA $1F13
        JSL update_ow_position_pointers
        RTL

; update the pointers to overworld poitions
update_ow_position_pointers:
        REP #$20
        LDX #$06
      - LDA $1F17,X
        LSR #4
        STA $1F1F,X
        DEX #2
        BPL -
        SEP #$20
        RTL

; check if realtime clock is available on this system
check_for_rtc:
        ; clock takes ~8 reads to activate
        ; we'll give it twice as long to respond
        LDX #$10
        
      - LDA.L $802800 ; clock dummy read
        AND #$0F
        CMP #$0F
        BEQ .yes
        DEX
        BPL -
        
        LDA #$00
        BRA +
        
    .yes:
        LDA #$BD
      + STA.L !clock_available
        RTS

; save movie length and checksum
save_movie_details:
        REP #$30
        LDA !movie_location
        TAX
        LDA !movie_location+$44,X
        AND #$0008
        BEQ +
        INX
      + INX #2
        TXA
        STA !movie_location+$05
        SEP #$20
        
        DEX
        LDA #$00
      - CLC
        ADC !movie_location+$43,X
        DEX
        BPL -
        STA !movie_location+$0C
        
        LDA #$BD
        STA !movie_location+$0D
        
        SEP #$10
        RTS

; check for saved movies, if so get their translevels
identify_movies:
        PHP
        PHB
        PHK
        PLB
        
        LDX #$02
     -- TXA
        STA $00
        ASL A
        CLC
        ADC $00
        TAY
        LDA movie_pointers,Y
        STA $00
        LDA movie_pointers+1,Y
        STA $01
        LDA movie_pointers+2,Y
        STA $02
        
        LDY #$0A
        LDA [$00],Y
        CMP #$BD
        BNE .no_movie_here
        
        REP #$30
        LDY #$0002
        LDA [$00],Y
        CLC
        ADC #$003F
        TAY
        SEP #$20
        LDA #$00
      - CLC
        ADC [$00],Y
        DEY
        CPY #$0040
        BCS -
        SEP #$10    
        LDY #$09
        CMP [$00],Y
        BEQ .save_level
    
    .no_movie_here:
        STZ !level_movie_slots,X
        BRA +
    .save_level:
        LDY #$01
        LDA [$00],Y
        STA !level_movie_slots,X
      + DEX
        BPL --
        
        PLB
        PLP
        RTS

movie_pointers:
        dl $707000,$707800,#!movie_location+3

; this sets up some hdma so we can correct the shadow palette
setup_shadow:
        PHP
        SEP #$20
        REP #$10
        
        LDA #$03
        STA $4360
        LDA #$21
        STA $4361
        LDX #shadow_palette_hdma
        STX $4362
        PHK
        PLA
        STA $4364
        
        PLP
        RTS

shadow_palette_hdma:
        db $01
        dw $0D0D,$573B
        db $01
        dw $0E0E,$551E
        db $28
        dw $0F0F,$0000
        db $01
        dw $0D0D,$3E75
        db $01
        dw $0E0E,$3212
        db $01
        dw $0F0F,$25AF
        db $00

print "inserted ", bytes, "/32768 bytes into bank $11"