; this code is run once on overworld menu load
; GAME MODE #$1D
ORG !_F+$188000

reset bytes

overworld_menu_load:
        PHP
        PHB
        PHK
        PLB
        
        STZ !fast_mode_current_level
        STZ !menu_tile_upload_bytes
        STZ !menu_tile_upload_bytes+1
        
        LDA #$09 ; special world theme
        STA $1DFB ; apu i/o
        STZ $0D9F ; hdmaen
        
        LDA $1F28 ; yellow switch
        BEQ +
        LDA #$01
      + STA.L !status_yellow
        LDA $1F27 ; green switch
        BEQ +
        LDA #$01
      + STA.L !status_green
        LDA $1F2A ; red switch
        BEQ +
        LDA #$01
      + STA.L !status_red
        LDA $1F29 ; blue switch
        BEQ +
        LDA #$01
      + STA.L !status_blue
        
        JSL load_yoshi_color
        
        LDA $19 ; powerup
        STA.L !status_powerup
        LDA $0DC2 ; itembox
        STA.L !status_itembox
        LDA #$00
        STA.L !status_erase
        STA.L !status_enemy
        STA.L !erase_records_flag
        STA.L !status_moviesave
        STA.L !status_movieload
        
        STZ !text_timer
        
        LDA #$80
        STA $2100 ; force blank
        STZ $4200 ; nmi disable
        STZ $420C ; hdmaen
        
        JSR upload_overworld_menu_graphics
        
        REP #$10
        LDA #$20
        STA $40 ; cgadsub mirror
        LDA #$20
        STA $2107 ; bg1 base address & size
        LDA #$33
        STA $2108 ; bg2 base address & size
        STZ $210B ; bg12 name base address
        LDA #$16
        STA $212C ; through main
        LDA #$01
        STA $212D ; through sub
        LDX #$0000
        STX $1E ; layer 2 x position
        STX $22 ; layer 3 x position
        LDX #$0000
        STX $20 ; layer 2 y position
        LDX #$0020
        STX $24 ; layer 3 y position
        STZ $2121 ; cgram address
        LDA $13
        AND #$EF
        STA $2122
        LDA $14
        AND #$3D
        STA $2122 ; cgram data
        SEP #$10
        
        LDX #!number_of_options_pg1-1
      - JSL draw_menu_selection
        DEX
        BPL -
        
        JSL draw_meter_names
        
        JSL !_F+$0084C8
        JSL $7F8000
        
        LDX #$07
      - STZ $0101,X
        DEX
        BPL -
        
        REP #$30
        LDA #$FF00
        LDX #$01BE
      - STA $04A0,X
        DEX
        DEX
        BPL -
        SEP #$30
        
        LDA #$01
        STA !in_overworld_menu
        
        LDA #$53
        STA $2109 ; BG3SC
        LDA #$01
        STA $2105 ; mode
        
        LDA #$81
        STA $4200 ; nmi enable
        STZ $2100 ; exit force blank
        INC $0100
        
        PLB
        PLP
        RTL

; upload all necessary graphics and tilemaps to vram
upload_overworld_menu_graphics:
        PHP
        REP #$10
        SEP #$20
        
        LDA #$80
        STA $2115 ; vram increment
        
        LDX #$2000
        STX $2116 ; vram address
        LDA.B #bank(menu_layer1_tilemap)
        LDX #menu_layer1_tilemap
        LDY #$0800
        JSL load_vram
        
        LDX #$0000
        STX $2116 ; vram address
        LDA.B #bank(menu_layer2_tiles)
        LDX #menu_layer2_tiles
        LDY #$4000
        JSL load_vram
        
        LDX #$3000
        STX $2116 ; vram address
        LDA.B #bank(menu_layer2_tilemap)
        LDX #menu_layer2_tilemap
        LDY #$0800
        JSL load_vram
        
        LDX #$3400
        STX $2116 ; vram address
        LDA.B #bank(menu_layer2_tilemap)
        LDX #menu_layer2_tilemap
        LDY #$0800
        JSL load_vram
        
        LDX #$3800
        STX $2116 ; vram address
        LDA.B #bank(menu_layer2_tilemap)
        LDX #menu_layer2_tilemap
        LDY #$0800
        JSL load_vram
        
        LDX #$3C00
        STX $2116 ; vram address
        LDA.B #bank(menu_layer2_tilemap)
        LDX #menu_layer2_tilemap
        LDY #$0800
        JSL load_vram
        
        LDX #$6000
        STX $2116 ; vram address
        LDA.B #bank(menu_object_tiles)
        LDX #menu_object_tiles
        LDY #$1000
        JSL load_vram
        
        LDA #$00
        STA $2121 ; cgram address
        LDA.B #bank(menu_palette)
        LDX #menu_palette
        LDY #$0100
        JSL load_cgram
        
        LDA #$80
        STA $2121 ; cgram address
        LDA.B #bank(menu_palette)
        LDX #menu_palette
        LDY #$0100
        JSL load_cgram
        
        LDX #$5000
        STX $2116 ; vram address
        LDA.B #bank(menu_layer3_tilemap)
        LDX #menu_layer3_tilemap
        LDY #$0800
        JSL load_vram
        
        LDX #$5800
        STX $2116 ; vram address
        LDA.B #bank(menu_layer3_tilemap)
        LDX #menu_layer3_tilemap
        LDY #$0800
        JSL load_vram
        
        LDX #$4800
        STX $2116 ; vram address
        LDA.B #bank(menu_layer3_tiles)
        LDX #menu_layer3_tiles
        LDY #$1000
        JSL load_vram
        
        PLP
        RTS

; draw one of the menu options to the screen, where X = menu index
draw_menu_selection:
        PHX
        PHP
        PHB
        PHK
        PLB

        REP #$20

        LDA option_x_position,X
        AND #$00FF
        BIT #$0020
        BEQ +
        EOR #$0420 ; on the second page
      + STA $00
        LDA option_y_position,X
        AND #$00FF
        BIT #$0020
        BEQ +
        EOR #$0060 ; on the second page (so technically 3rd page)
      + ASL #5
        ADC $00
        ADC #$3000
        REP #$30
        LDY !menu_tile_upload_bytes
        STA !menu_tile_upload_location,Y
        CLC
        INC A
        STA !menu_tile_upload_location+4,y
        CLC
        ADC #$001F
        STA !menu_tile_upload_location+8,y
        INC A
        STA !menu_tile_upload_location+12,y

        LDA.L !status_table,X
        AND #$00FF
        STA $0E
        TXA
        ASL A
        TAX
        LDA $0E
        CLC
        ADC option_index,X
        ASL #3
        TAX

        LDA menu_option_tiles,X
        STA !menu_tile_upload_location+2,y
        LDA menu_option_tiles+2,X
        STA !menu_tile_upload_location+6,y
        LDA menu_option_tiles+4,X
        STA !menu_tile_upload_location+10,y
        LDA menu_option_tiles+6,X
        STA !menu_tile_upload_location+14,y

        TYA
        ADC #$0010
        STA !menu_tile_upload_bytes

        PLB
        PLP
        PLX
        RTL


option_x_position:
        db $06,$06,$06,$06,$06,$09,$09,$09,$09,$18,$0C,$15,$12,$12,$15,$0C
        db $0F,$0F,$0C,$0F,$18,$0F,$12,$15,$12,$15,$0E,$10,$12,$14,$0C,$18
        db $26,$26,$26,$26,$26,$29,$29,$29,$2C,$2C,$2C,$29,$2C,$23,$23,$23
option_y_position:
        db $03,$06,$09,$0C,$0F,$06,$09,$0C,$03,$0F,$09,$06,$0C,$09,$09,$0F
        db $06,$09,$06,$0C,$03,$0F,$06,$0C,$0F,$0F,$02,$02,$02,$02,$0C,$0C
        db $03,$06,$09,$0C,$0F,$06,$09,$0C,$06,$09,$0C,$03,$03,$03,$06,$0F
option_width:
        db $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
        db $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$08,$08,$08,$08,$10,$10
        db $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
option_height:
        db $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
        db $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
        db $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
option_type:
        db $01,$01,$01,$01,$01,$01,$01,$01,$02,$03,$01,$01,$01,$01,$01,$01
        db $01,$01,$01,$01,$03,$01,$01,$01,$03,$03,$01,$01,$01,$01,$01,$01
        db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$03
option_index:
        dw $0001,$0003,$0005,$0007,$0009,$000B,$010B,$020B
        dw $030B,$030C,$0319,$031E,$0321,$0323,$0325,$0327
        dw $0329,$032C,$0337,$033F,$0341,$0347,$0349,$03AE
        dw $03B0,$03B2,$03BA,$03BA,$03BA,$03BA,$03B6,$03E3
        dw $0001,$0003,$0005,$0007,$0009,$000B,$010B,$020B
        dw $000B,$010B,$020B,$03EC,$03E8,$03F1,$03F4,$03F7
menu_option_tiles:
        incbin "bin/menu_option_tiles.bin"
menu_object_tiles:
        incbin "bin/menu_object_tiles.bin"
menu_layer3_tiles:
        incbin "bin/menu_layer3_tiles.bin"
        
; See level_mario_appear.asm for option_text

print "inserted ", bytes, "/32768 bytes into bank $18"

ORG !_F+$198000

reset bytes

; the layer 1 tilemap for the overworld menu
menu_layer1_tilemap:
        incbin "bin/menu_layer1_tilemap.bin"

; the overworld menu graphics
menu_layer2_tiles:
        incbin "bin/menu_layer2_tiles.bin"

; the layer 2 tilemap for the overworld menu
menu_layer2_tilemap:
        incbin "bin/menu_layer2_tilemap.bin"

; the layer 3 tilemap for the overworld menu
menu_layer3_tilemap:
        incbin "bin/menu_layer3_tilemap.bin"

; the palette for the overworld menu
menu_palette:
        incbin "bin/menu_palette.bin"

; which selection to go to when a direction is pressed
selection_press_up:
        db $04,$00,$01,$02,$03,$08,$05,$06,$07,$1F,$12,$1D,$0D,$16,$0B,$1E
        db $1B,$10,$1A,$11,$09,$13,$1C,$0E,$0C,$17,$0F,$15,$18,$19,$0A,$14
        db $24,$20,$21,$22,$23,$2B,$25,$26,$2C,$28,$29,$27,$2A,$2F,$2D,$2E
selection_press_down:
        db $01,$02,$03,$04,$00,$06,$07,$08,$05,$14,$1E,$0E,$18,$0C,$17,$1A
        db $11,$13,$0A,$15,$1F,$1B,$0D,$19,$1C,$1D,$12,$10,$16,$0B,$0F,$09
        db $21,$22,$23,$24,$20,$26,$27,$2B,$29,$2A,$2C,$25,$28,$2E,$2F,$2D
selection_press_left:
        db $14,$0B,$0E,$1F,$09,$01,$02,$03,$00,$19,$06,$16,$13,$11,$0D,$04
        db $12,$0A,$05,$1E,$1D,$0F,$10,$0C,$15,$18,$08,$1A,$1B,$1C,$07,$17
        db $2D,$2E,$29,$2A,$2F,$21,$22,$23,$25,$26,$27,$20,$2B,$2C,$28,$24
selection_press_right:
        db $08,$05,$06,$07,$0F,$12,$0A,$1E,$1A,$04,$11,$01,$17,$0E,$02,$15
        db $16,$0D,$10,$0C,$00,$18,$0B,$1F,$19,$09,$1B,$1C,$1D,$14,$13,$03
        db $2B,$25,$26,$27,$2F,$28,$29,$2A,$2E,$22,$23,$2C,$2D,$20,$21,$24

; the number of options to allow when holding x or y
minimum_selection_extended:
        db $01,$01,$01,$01,$01,$FF,$FF,$FF,$00,$0C,$04,$02,$01,$01,$01,$01
        db $02,$0A,$07,$01,$05,$01,$64,$01,$01,$03,$28,$28,$28,$28,$03,$04
        db $01,$01,$01,$01,$01,$07,$FF,$07,$07,$FF,$07,$01,$03,$02,$02,$01

; the number of options to allow when not holding x or y
minimum_selection_normal:
        db $01,$01,$01,$01,$01,$03,$04,$04,$00,$0C,$04,$02,$01,$01,$01,$01
        db $02,$0A,$07,$01,$05,$01,$37,$01,$01,$03,$28,$28,$28,$28,$03,$03
        db $01,$01,$01,$01,$01,$03,$04,$04,$03,$04,$04,$01,$01,$02,$02,$01

; this code is run on every frame during the overworld menu game mode (after fade in completes)
; GAME MODE #$1F
overworld_menu:
        PHP
        PHB
        PHK
        PLB
        SEP #$30
        INC $14
        JSL $7F8000
        
        JSL scroll_screens
        PHP
        LDA !overworld_menu_mode
        PLP
        BMI +
        STA !menu_screen_moved
      + ASL A
        TAX
        JSR (overworld_menu_submodes,X)
    
        PLB
        PLP
        RTL

overworld_menu_submodes:
        dw option_selection_mode
        dw meter_editor_mode
        dw FastMode_editor_mode

; move the screen if not in the right spot
scroll_screens:
        PHP
        REP #$20
        LDY #$00
        LDX !overworld_menu_mode

        CPX #$00
        BNE .check_mode_1
        
        ; main menu @ ($00,$00)
        LDA $20 ; bg1 y
        BEQ +
        LDA $20
        SEC
        SBC #$0004
        STA $20
        INY
      + LDA $22 ; bg3 x
        BEQ +
        SEC
        SBC #$0008
        STA $22
        INY
      + LDA $24 ; bg3 y
        CMP #$0020
        BEQ +
        SEC
        SBC #$0004
        STA $24
        INY
      + LDA $1E ; bg1 x
        BEQ +
        SEC
        SBC #$0008
        STA $1E
        INY
      + BRA .done_scrolling
        
    .check_mode_1:
        CPX #$01
        BNE .check_mode_2
        
        ; status bar editor @ ($00,$A4)
        LDA $20 ; bg1 y
        CMP #$00A4
        BCS +
        ADC #$0004
        STA $20
        INY
      + LDA $22 ; bg3 x
        BEQ +
        SEC
        SBC #$0008
        STA $22
        INY
      + LDA $24 ; bg3 y
        CMP #$00C4
        BCS +
        ADC #$0004
        STA $24
        INY
      + LDA $1E ; bg1 x
        BEQ +
        SEC
        SBC #$0008
        STA $1E
        INY
      + BRA .done_scrolling

    .check_mode_2:
        CPX #$02
        BNE .done_scrolling
        
        ; route editor @ ($100,$00)
        LDA $20 ; bg1 y
        BEQ +
        SEC
        SBC #$0004
        STA $20
        INY
      + LDA $22 ; bg3 x
        CMP #$0100
        BEQ +
        CLC
        ADC #$0008
        STA $22
        INY
      + LDA $24 ; bg3 y
        CMP #$0020
        BEQ +
        SEC
        SBC #$0004
        STA $24
        INY
      + LDA $1E ; bg1 x
        CMP #$0100
        BEQ +
        CLC
        ADC #$0008
        STA $1E
        INY
        
    .done_scrolling:
      + PLP
        DEY
        TYA
        EOR #$FF
        STA !menu_screen_moved
        RTL
        
unpack_FastMode_level_settings:
        JSL retrieve_current_level
        BNE +
        
        ; empty route
        LDA #$00
        STA !status_fast_mode_timer
        STA !status_fast_mode_heads_up
        STA !status_fast_mode_start_item
        STA !status_fast_mode_end_item
        STA !status_fast_mode_start_powerup
        STA !status_fast_mode_end_powerup
        STA !status_fast_mode_start_yoshi
        STA !status_fast_mode_end_yoshi
        STA !status_fast_mode_red
        STA !status_fast_mode_blue
        STA !status_fast_mode_yellow
        STA !status_fast_mode_green
        STA !status_fast_mode_special
        STA !status_fast_mode_midway
        STA !status_fast_mode_exit_type
        BRA .done
        
;      + LDA !fast_mode_save_current_header+1
;        CMP #$01 ; version
;        BEQ +
        
      + LDA !fast_mode_save_current_header+2
        STA !status_fast_mode_timer
        
        LDA !fast_mode_save_current_header+3
        STA !status_fast_mode_heads_up

        LDA !fast_mode_save_current_level+1
        STA !status_fast_mode_start_item

        LDA !fast_mode_save_current_level+2
        STA !status_fast_mode_end_item

        LDA !fast_mode_save_current_level+3
        STA !status_fast_mode_start_powerup

        LDA !fast_mode_save_current_level+4
        STA !status_fast_mode_end_powerup

        LDA !fast_mode_save_current_level+5
        STA !status_fast_mode_start_yoshi

        LDA !fast_mode_save_current_level+6
        STA !status_fast_mode_end_yoshi

        LDA !fast_mode_save_current_level+7
        STA !status_fast_mode_red

        LDA !fast_mode_save_current_level+8
        STA !status_fast_mode_blue

        LDA !fast_mode_save_current_level+9
        STA !status_fast_mode_yellow

        LDA !fast_mode_save_current_level+10
        STA !status_fast_mode_green

        LDA !fast_mode_save_current_level+11
        STA !status_fast_mode_special

        LDA !fast_mode_save_current_level+12
        STA !status_fast_mode_midway

        LDA !fast_mode_save_current_level+13
        STA !status_fast_mode_exit_type
        
        ;; TODO special case for required flags

    .done:
        RTS
        
pack_FastMode_level_settings:
        JSL retrieve_current_header
        
        LDA #$01 ; version of route data
        STA !fast_mode_save_current_header+1
        
        LDA !status_fast_mode_timer
        STA !fast_mode_save_current_header+2
        
        LDA !status_fast_mode_heads_up
        STA !fast_mode_save_current_header+3

        LDA !status_fast_mode_start_item
        STA !fast_mode_save_current_level+1

        LDA !status_fast_mode_end_item
        STA !fast_mode_save_current_level+2

        LDA !status_fast_mode_start_powerup
        STA !fast_mode_save_current_level+3

        LDA !status_fast_mode_end_powerup
        STA !fast_mode_save_current_level+4

        LDA !status_fast_mode_start_yoshi
        STA !fast_mode_save_current_level+5

        LDA !status_fast_mode_end_yoshi
        STA !fast_mode_save_current_level+6

        LDA !status_fast_mode_red
        STA !fast_mode_save_current_level+7

        LDA !status_fast_mode_blue
        STA !fast_mode_save_current_level+8

        LDA !status_fast_mode_yellow
        STA !fast_mode_save_current_level+9

        LDA !status_fast_mode_green
        STA !fast_mode_save_current_level+10

        LDA !status_fast_mode_special
        STA !fast_mode_save_current_level+11

        LDA !status_fast_mode_midway
        STA !fast_mode_save_current_level+12

        LDA !status_fast_mode_exit_type
        STA !fast_mode_save_current_level+13
        
        ;; TODO special case for required flags

        JSL store_current_level
        RTS

RedrawPg2:
        LDX #!number_of_options_pg1                         ; \
      - JSL draw_menu_selection                             ; | Draw all page 2 options
        INX                                                 ; |
        CPX #!number_of_options_pg1+!number_of_options_pg2  ; |
        BNE -                                               ; /
        RTS

FastMode_editor_mode:
        JSL retrieve_current_level
        JSR unpack_FastMode_level_settings

        LDA !util_byetudlr_frame                            ; \
        AND #$10                                            ; |
        BEQ +                                               ; |
                                                            ; |
        LDA #$00                                            ; |
        STA !overworld_menu_mode                            ; |
        STA !util_byetudlr_frame                            ; | Return to main menu on START
        STZ !text_timer                                     ; |
        LDA #$1F                                            ; |
        STA !current_selection                              ; |
        LDA #$0B ; on/off sound
        STA $1DF9 ; apu i/o
        JMP .done                                           ; /

      + LDA !util_byetudlr_hold                             ; \
        AND #$40                                            ; |
        BEQ .no_y                                           ; |
                                                            ; |
        LDA !util_byetudlr_frame                            ; | 
        BIT #$04                                            ; | if Y+Down, increment level counter
        BEQ .check_ydown                                    ; | 
        
        JSR pack_FastMode_level_settings                    ; | Pack away old values before increment
        INC !fast_mode_current_level                        ; |
        LDA !fast_mode_save_current_header+0
        DEC A
        CMP !fast_mode_current_level
        BCS +
        LDA #00
        STA !fast_mode_current_level
      + STZ !util_byetudlr_frame                            ; |
        STZ !text_timer                                     ; |
        LDA #$06 ; fireball sound
        STA $1DFC ; apu i/o
        JSR unpack_FastMode_level_settings                  ; | unpack new values after increment
        JSR RedrawPg2
        JSL draw_route_level_list
        BRA .no_y

    .check_ydown:
        LDA !util_byetudlr_frame                            ; |
        BIT #$08                                            ; | if Y+Up, decrement level counter
        BEQ .no_y                                           ; |
        JSR pack_FastMode_level_settings                    ; |
        DEC !fast_mode_current_level                        ; |
        BPL +
        LDA !fast_mode_save_current_header+0
        DEC A
        STA !fast_mode_current_level
      + STZ !util_byetudlr_frame                            ; |
        STZ !text_timer                                     ; |
        LDA #$06 ; fireball sound
        STA $1DFC ; apu i/o
        JSR unpack_FastMode_level_settings                  ; |
        JSR RedrawPg2                                       ; /
        JSL draw_route_level_list
        
    .no_y:
        JSR option_selection_mode
    .done
        JSR pack_FastMode_level_settings
        RTS
        
; run the default part of the menu
option_selection_mode:
        LDA !current_selection
        STA $0B
        
        INC !fast_scroll_timer
        LDA !util_axlr_hold
        AND #%00110000
        BNE +
        STZ !fast_scroll_timer
      + LDA !fast_scroll_timer
        CMP #!fast_scroll_delay
        BCC .test_select
        LDA #!fast_scroll_delay
        STA !fast_scroll_timer
        
    .test_select:
        LDA !erase_records_flag
        BEQ .test_start
        LDA !util_byetudlr_hold
        AND #%00100000
        BEQ .test_start
        JSR delete_data
        JMP .finish_no_change
    
    .test_start:
        LDA !util_byetudlr_frame
        AND #%00010000
        BEQ .test_dup
        LDA #$29 ; ding sound
        STA $1DFC ; apu i/o
        JMP .quit
        
    .test_dup:
        LDA !util_byetudlr_frame
        AND #%00001000
        BEQ .test_ddown
        LDA !current_selection
        TAX
        LDA selection_press_up,X
        STA !current_selection
        JMP .finish_sound
        
    .test_ddown:
        LDA !util_byetudlr_frame
        AND #%00000100
        BEQ .test_dleft
        LDA !current_selection
        TAX
        LDA selection_press_down,X
        STA !current_selection
        JMP .finish_sound
        
    .test_dleft:
        LDA !util_byetudlr_frame
        AND #%00000010
        BEQ .test_dright
        LDA !current_selection
        TAX
        LDA selection_press_left,X
        STA !current_selection
        JMP .finish_sound
        
    .test_dright:
        LDA !util_byetudlr_frame
        AND #%00000001
        BEQ .test_left
        LDA !current_selection
        TAX
        LDA selection_press_right,X
        STA !current_selection
        JMP .finish_sound
        
    .test_left:
        LDA !util_axlr_frame
        AND #%00100000
        BNE .go_left
        LDA !util_axlr_hold
        AND #%00100000
        BEQ .test_right
        LDA !fast_scroll_timer
        CMP #!fast_scroll_delay
        BNE .test_right
    .go_left:
        LDX !current_selection
        LDA.L !status_table,X
        DEC A
        STA.L !status_table,X
        LDA #$00
        JSR check_bounds
        JSR check_pal_switch
        BCS +
        JMP .finish_sound
      + JMP .finish_no_sound 
        
    .test_right:
        LDA !util_axlr_frame
        AND #%00010000
        BNE .go_right
        LDA !util_axlr_hold
        AND #%00010000
        BEQ .test_selection
        LDA !fast_scroll_timer
        CMP #!fast_scroll_delay
        BNE .test_selection
    .go_right:
        LDX !current_selection
        LDA.L !status_table,X
        INC A
        STA.L !status_table,X
        LDA #$01
        JSR check_bounds
        JSR check_pal_switch
        BCS +
        JMP .finish_sound
      + JMP .finish_no_sound 
        
    .test_selection:
        LDA !util_axlr_frame
        ORA !util_byetudlr_frame
        AND #%10000000
        BNE .make_selection
        JMP .finish_no_change
    .make_selection:
        LDA !current_selection
        ASL A
        TAX
        LDA .selection_table,X
        BNE +
        JMP .finish_no_change
      + JMP (.selection_table,X)
        
	.selection_table:
		dw 0                               ;00
		dw 0                               ;01
		dw 0                               ;02
		dw 0                               ;03
		dw 0                               ;04
		dw 0                               ;05
		dw 0                               ;06
		dw .select_yoshi                   ;07
		dw .select_enemy                   ;08
		dw .select_records                 ;09
		dw 0                               ;0A
		dw 0                               ;0B
		dw 0                               ;0C
		dw 0                               ;0D
		dw 0                               ;0E
		dw 0                               ;0F
		dw 0                               ;10
		dw 0                               ;11
		dw 0                               ;12
		dw 0                               ;13
		dw .select_meters                  ;14
		dw 0                               ;15
		dw 0                               ;16
		dw 0                               ;17
		dw .select_moviesave               ;18
		dw .select_movieload               ;19
		dw 0                               ;1A
		dw 0                               ;1B
		dw 0                               ;1C
		dw 0                               ;1D
		dw 0                               ;1E
		dw .select_fast_mode_save          ;1F
		dw .propogate_forward              ;20
		dw .propogate_forward              ;21
		dw .propogate_forward              ;22
		dw .propogate_forward              ;23
		dw .propogate_forward              ;24
		dw .propogate_forward              ;25
		dw .propogate_forward              ;26
		dw .propogate_forward              ;27
		dw .propogate_forward              ;28
		dw .propogate_forward              ;29
		dw .propogate_forward              ;2A
		dw .propogate_forward              ;2B
		dw .propogate_forward              ;2C
		dw 0                               ;2D
		dw 0                               ;2E
		dw .select_fast_mode_delete_save   ;2F


    .propogate_forward:
        LDA !util_byetudlr_hold
        AND !util_axlr_hold
        AND #$80
        BEQ +
        JSR FastMode_propogate_forward
        LDA #$01 ; coin sound
        STA $1DFC ; apu i/o
      + JMP .finish_no_change
      
    .select_fast_mode_save:
        LDA !status_fast_mode
        BNE +
        LDA #$2A ; wrong sound
        STA $1DFC ; apu i/o
        JMP .finish_no_change
      + LDA #$02
        STA !overworld_menu_mode
        LDA #$20
        STA !current_selection
        STZ !text_timer
        STZ !fast_mode_current_level
        JSL draw_route_level_list
        JSR unpack_FastMode_level_settings
        JSR RedrawPg2
        LDA #$0B ; on/off sound
        STA $1DF9 ; apu i/o
        JMP .finish_no_change
        
    .select_fast_mode_delete_save:
        LDA !status_fast_mode_delete
        BNE ++
        LDA !fast_mode_save_current_header
        BNE +
        JMP .finish_error_sound
      + JSL route_remove_level
        JMP .finish_no_change
     ++ LDA !fast_mode_save_current_header
        BEQ +
        JSL route_duplicate_level
        JMP .finish_no_change
      + JSL route_add_new_level
        JMP .finish_no_change
        
    .select_meters:
        LDA.L !status_layout
        CMP #$03
        BCS +
        JMP .finish_error_sound
      + LDA #$0B ; on/off sound
        STA $1DF9 ; apu i/o
        JSL update_meterset_pointer
        JSL draw_meter_names
        JSR draw_edited_status_bar
        LDA #$01
        STA !overworld_menu_mode
        STZ !text_timer
        JMP .no_update_text
        
    .select_yoshi:
        LDA #$1F ; yoshi sound
        STA $1DFC ; apu i/o
        JMP .finish_no_change
        
    .select_records:
        LDA #$24 ; "press select to confirm"
        STA $12 ; stripe image loader
        LDA.L !status_erase
        INC A
        STA !erase_records_flag
        LDA #$0B ; itembox sound
        STA $1DFC ; apu i/o
        LDA #$80 ; fade out music
        STA $1DFB ; apu i/o
        JMP .finish_no_change
        
    .select_enemy:
        LDA #$01 ; coin sound
        STA $1DFC ; apu i/o
        JSR reset_enemy_states
        JMP .finish_no_change
        
    .select_moviesave:
        JSR export_movie_to_sram
        JMP .finish_no_change
        
    .select_movieload:
        JSR load_movie
        JMP .finish_no_change    


    .quit:
        LDA #$0B
        STA $0100 ; game mode
        
        JSL restore_basic_settings
        BRA .finish_no_change
        
    .finish_error_sound:
        LDA #$2A ; wrong sound
        STA $1DFC ; apu i/o
        BRA .finish_no_sound
    
    .finish_sound:
        LDA #$06 ; fireball sound
        STA $1DFC ; apu i/o
    .finish_no_sound:
        LDX !current_selection
        JSL draw_menu_selection
        JSL draw_option_value
        
    .finish_no_change:
        JSL draw_option_cursor
        JSL draw_option_text
        
        LDA !text_timer
        CMP #$31
        BCS .no_inc_text
        INC A
        STA !text_timer
    .no_inc_text:
        LDX !current_selection
        CPX $0B
        BEQ .no_update_text
        STZ !text_timer
    .no_update_text:
        RTS

; remove the current level from the route
; shouldn't happen if route is empty
route_remove_level: ; use mvn, (Y) <- (X), C = len-1
        PHP
        LDA #$06 ; gulp sound
        STA $1DF9 ; apu i/o
        
        LDA.L !status_fast_mode
        DEC A
        REP #$30
        AND #$00FF
        ASL #2
        TAX
        LDA.L FastMode_header_locations,X
        STA $00
        LDA.L FastMode_header_locations+1,X
        STA $01
        LDA [$00]
        DEC A
        STA [$00] ; shorten route by one
        STA $03
        LDA.L FastMode_save_locations,X
        STA $00
        LDA.L FastMode_save_locations+1,X
        STA $01
        LDA !fast_mode_current_level
        AND #$00FF
        STA $05
        ASL #2
        CLC
        ADC $05
        ASL A ; x10
        CLC
        ADC $00
        TAY
        CLC
        ADC #$000A ; level entry length
        TAX
        LDA $03
        AND #$00FF
        SEC
        SBC !fast_mode_current_level
        STA $05
        ASL #2
        CLC
        ADC $05
        ASL A ; x10
        PHB
        MVN $70,$70
        PLB
        
        SEP #$30
        LDA $03
        CMP !fast_mode_current_level
        BNE +
        DEC !fast_mode_current_level
      + JSL draw_route_level_list
        JSR unpack_FastMode_level_settings
        JSR RedrawPg2
        PLP
        RTL

; add a fresh new level to a route that was previously empty
route_add_new_level:
        LDA #$2A ; yi2
        STA !potential_translevel
        LDX #$00
        JSL FastMode_add_level
        JSL draw_route_level_list
        JSR unpack_FastMode_level_settings
        JSR RedrawPg2
        RTL

; duplicate the current level in the route
route_duplicate_level: ; use mvp
        PHP
        
        LDA.L !status_fast_mode
        DEC A
        REP #$30
        AND #$00FF
        ASL #2
        TAX
        LDA.L FastMode_header_locations,X
        STA $00
        LDA.L FastMode_header_locations+1,X
        STA $01
        LDA [$00]
        AND #$00FF
        CMP.W #!fast_mode_max_route_length ; full
        BCC +
        SEP #$20
        LDA #$2A ; wrong sound
        STA $1DFC ; apu i/o
        PLP
        RTL
        
      + STA $03
        INC A
        STA [$00] ; lengthen route by one
        LDA.L FastMode_save_locations,X
        STA $00
        LDA.L FastMode_save_locations+1,X
        STA $01
        LDA $03
        AND #$00FF
        STA $05
        ASL #2
        CLC
        ADC $05
        ASL A ; x10
        DEC A
        CLC
        ADC $00
        TAX
        CLC
        ADC #$000A ; level entry length
        TAY
        LDA $03
        AND #$00FF
        SEC
        SBC !fast_mode_current_level
        STA $05
        ASL #2
        CLC
        ADC $05
        ASL A ; x10
        DEC A
        PHB
        MVP $70,$70
        PLB
        
        SEP #$30
        JSL draw_route_level_list
        JSR unpack_FastMode_level_settings
        JSR RedrawPg2     

        LDA #$02 ; bop sound
        STA $1DF9 ; apu i/o
        
        PLP
        RTL

; take the selection option and apply it to all later levels in the route
FastMode_propogate_forward:
        LDA !current_selection
        TAX
        LDA selection_to_uncompressed_table-$20,X
        TAX
        STA $04
        LDA !fast_mode_current_level
        STA $05
        LDA !fast_mode_save_current_level,X
        STA $06

        LDY !fast_mode_save_current_header+0

      - INC !fast_mode_current_level
        JSL retrieve_current_level
        BEQ .done

        LDA $04
        TAX
        LDA $06
        STA !fast_mode_save_current_level,X
        JSL store_current_level
        BRA -

    .done:
        LDA $05
        STA !fast_mode_current_level
        JSL retrieve_current_level

        ;; TODO special case for required flags
        RTS

; mapping of overworld menu options to indices into route level data
selection_to_uncompressed_table:
    db $09,$0A,$07,$08,$0B,$03,$01,$05,$04,$02,$06,$0C,$10
        
; copy currently loaded movie to sram
export_movie_to_sram:
        PHP
        REP #$30
        LDA #$7070
        STA $02
        LDA #$7000
        STA $00
        LDA.L !status_moviesave
        AND #$00FF
        XBA
        ASL #3
        TAY
        LDX #$0000
        
      - LDA.L !movie_location+3,X
        STA [$00],Y
        INY #2
        INX #2
        CPX #$0800
        BNE -
        
        SEP #$20
        LDA #$01 ; coin sound
        STA $1DFC ; apu i/o
        
        PLP
        RTS
        
; copy a movie from sram or rom to ram
load_movie:
        PHP
        PHB
        PHK
        PLB
        LDA.L !status_movieload
        CMP #$02
        BCS .getptr
        STA $00
        ASL A
        CLC
        ADC $00
        TAX
        LDA sram_movie_locations,X
        STA $00
        LDA sram_movie_locations+1,X
        STA $01
        LDA sram_movie_locations+2,X
        STA $02
        BRA .copy
    .getptr:
        LDA !potential_translevel
        TAX
        LDA.L translevel_movie_ptrs_count,X
        BEQ .error
        LDA.B #translevel_movie_ptrs_head>>16
        STA $02
        TXA
        ASL A
        TAX
        LDA.L translevel_movie_ptrs_head,X
        STA $00
        LDA.L translevel_movie_ptrs_head+1,X
        STA $01
        LDA.L !status_movieload
        DEC #2
        STA $03
        ASL A
        CLC
        ADC $03
        TAY
        REP #$20
        LDA [$00],Y
        PHA
        INY
        LDA [$00],Y
        STA $01
        PLA
        CLC
        ADC #$0014 ; skip the movie name
        STA $00
        
    .copy:
        REP #$30
        LDY #$0000
        LDX #$0000
      - LDA [$00],Y
        STA.L !movie_location+3,X
        INY #2
        INX #2
        CPX #$0800
        BNE -
        
        SEP #$20
        LDA #$01 ; coin sound
        STA $1DFC ; apu i/o    
        BRA .exit
    .error:
        LDA #$2A ; wrong sound
        STA $1DFC ; apu i/o    
    .exit:
        PLB
        PLP
        RTS
        
sram_movie_locations:
        dl $707000, $707800

        
; restore gameplay settings
restore_basic_settings:
        LDA.L !status_yellow
        STA $1F28 ; yellow switch
        LDA.L !status_green
        STA $1F27 ; green switch
        LDA.L !status_red
        STA $1F2A ; red switch
        LDA.L !status_blue
        STA $1F29 ; blue switch
        JSL save_yoshi_color
        LDA #$01
        STA $0DC1 ; persistant yoshi
        LDA.L !status_powerup
        STA $19 ; powerup
        STA $0DB8 ; ow powerup
        LDA.L !status_itembox
        STA $0DC2 ; itembox
        STA $0DBC ; ow itembox
        RTL
        
; draw the flashing cursor to the screen:
draw_option_cursor:
        PHP
        PHB
        PHK
        PLB
        
        STZ $0A
        LDA !current_selection
        TAX
        LDA option_width,X
        STA $00
        LDA option_height,X
        STA $01
        LDA option_type,X
        STA $03
        LDA option_y_position,X
        REP #$20
        AND #$00FF
        ASL #3
        SEC
        SBC #$0009

        SEC
        SBC $20
        BPL +
        CMP #$FFE8
        BCC .done
      + SEP #$20
        TAY
        LDA option_x_position,X
        REP #$20
        AND #$00FF
        ASL #3
        SEC
        SBC #$0008
        
        SEC
        SBC $1E
        BPL +
        CMP #$FFE8
        BCC .done
      + SEP #$20
        TAX
        
        LDA !util_axlr_hold
        ORA !util_byetudlr_hold
        AND #%01000000
        BEQ +
        LDA #$01
        BRA ++
      + LDA #$00
     ++ STA $04
        
        REP #$10
        LDA !fast_scroll_timer
        CMP #!fast_scroll_delay
        BEQ +
        LDA #$00
        BRA ++
      + LDA #$01
     ++ STA $02
        
        SEP #$10
        JSR draw_generic_cursor
        
    .done:
        SEP #$20
        PLB
        PLP
        RTL
        
; load yoshi color from yoshi space to simple space
load_yoshi_color:
        LDA $0DBA ; ow yoshi color
        CMP #$0B
        BCS +
        TAX
        LDA.L yoshi_color_mapping_input,X
      + STA.L !status_yoshi
        RTL
        
; save yoshi color from simple space to yoshi space
save_yoshi_color:
        LDA.L !status_yoshi
        CMP #$0B
        BCS +
        TAX
        LDA.L yoshi_color_mapping_output,X
      + STA $0DBA ; ow yoshi color
        STA $13C7 ; level yoshi color
        RTL
        
yoshi_color_mapping_input:
        db $00,$05,$06,$07,$01,$08,$02,$09,$03,$0A,$04
yoshi_color_mapping_output:
        db $00,$04,$06,$08,$0A,$01,$02,$03,$05,$07,$09

; update the background offset and colorg
update_background:
        SEP #$20
        DEC $1A ; layer 1 x position
        LDA $13 ; frame counter
        AND #$01
        BEQ +
        DEC $1C ; layer 1 y position
      + RTL
      
; check if ntsc/pal switched
; A = 0/1 for L/R, X = option index
; set carry to denote to not play fireball sfx
check_pal_switch:
        LDX !current_selection
        CPX #$1E
        BNE +
        ASL #2
        ORA.L !status_region
        TAX
        LDA.L pal_switch_sfx,X
        BEQ +
        STA $1DFC ; apu i/o 3
        SEC
        RTS
        
      + CLC
        RTS
      
pal_switch_sfx:
        db $00,$4C,$00,$4D,$4C,$00,$4D,$00

; check the bounds on the menu options, and fix them if they are out of bounds
; X = option index, A = direction
check_bounds:
        PHP
        PHA
        PHY
        PHA
        LDA.L !status_table,X
        TAY
        PLA
        REP #$10
        PHY
        PHA
        LDA !util_byetudlr_hold
        ORA !util_axlr_hold
        AND #%01000000
        BEQ +
        LDA minimum_selection_extended,X
        BRA ++
      + LDA minimum_selection_normal,X
      
     ++ CPX #$0019 ; load movie, length depends on level
        BNE +
        LDA #$00
        XBA
        LDA !potential_translevel
        TAX
        LDA.L translevel_movie_ptrs_count,X
        INC A
        LDX #$0019
        
      + REP #$20
        AND #$00FF
        CMP $02,S
        SEP #$30
        BPL .out
        PLY
        BNE +
        STA.L !status_table,X
        BRA .done
      + LDA #$00
        STA.L !status_table,X
        BRA .done
    .out:
        PLY
    .done:
        PLY
        PLY
        PLY
        PLA
        PLP
        RTS
        
; reset persistant enemy states
; right now this only includes boo cloud and boo ring angles
reset_enemy_states:
        PHP
        REP #$30
        PHX
        STZ $0FAE
        STZ $0FB0 ; boo ring angles
        
        LDX #$004E
      - STZ $1E52,X ; cluster sprite table
        STZ $190A,X ; cluster sprite table
        DEX
        DEX
        BPL -
        
        PLX
        PLP
        RTS

; clear all the times saved in memory
; this is also run the first time you start up the game
delete_all_data:
        PHP
        PHB
        PHK
        PLB
        REP #$30
        
        LDA #$FFFF
        LDX #$0FDE
      - STA $700020,X
        CPX #$0320
        BNE +
        TXA
        SEC
        SBC #$0020
        TAX
        LDA #$FFFF
      + DEX
        DEX
        BPL -

        LDA #$0000
        STA !restore_status_from_backup
        SEP #$30
        JSL reset_header
        PLB
        PLP
        RTL

; when the layout is changed, update the pointer to the data
update_meterset_pointer:
        PHP
        REP #$30
        LDA.L !status_layout
        AND #$00FF
        ASL #2
        TAX
        LDA.L metersets+1,X
        STA !statusbar_layout_ptr+1
        LDA.L metersets,X
        STA !statusbar_layout_ptr
        PLP
        RTL
        
; delete one custom status bar (A = which custom slot)
delete_custom_statusbar:
        PHP
        REP #$30
        AND #$00FF
        ASL #5
        STA $00
        ASL A
        CLC
        ADC $00
        TAX
        LDY #$005E
        
      - LDA.L meterset_default,X
        STA.L !statusbar_meters,X
        INX #2
        DEY #2
        BPL -
        
        PLP
        RTL
        

; the default sets of statusbar meters
metersets:
        dd meterset_default
        dd meterset_lagcalibrated
        dd meterset_empty
        dd !statusbar_meters
        dd !statusbar_meters+$60
        dd !statusbar_meters+$C0
        dd meterset_vanilla
meterset_default:
        db $01,$00,$00,$21,$02,$00,$00,$21,$03,$00,$00,$41,$04,$00,$00,$61
        db $05,$00,$00,$24,$06,$00,$00,$44,$08,$00,$00,$26,$09,$00,$00,$47
        db $0A,$00,$00,$67,$07,$00,$00,$89,$0B,$00,$00,$32,$11,$8D,$14,$52
        db $11,$8E,$14,$54,$0C,$01,$00,$72,$0D,$00,$00,$36,$0E,$00,$00,$37
        db $0F,$04,$00,$81,$10,$00,$00,$98,$00,$00,$00,$00,$00,$00,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
meterset_lagcalibrated:
        db $01,$00,$00,$21,$02,$00,$00,$41,$04,$00,$00,$43,$01,$00,$00,$24
        db $08,$00,$00,$46,$09,$00,$00,$67,$07,$00,$00,$72,$0C,$01,$00,$52
        db $0E,$02,$00,$59,$0F,$04,$00,$61,$00,$00,$00,$98,$00,$00,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
meterset_empty:
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
meterset_vanilla:
        db $01,$00,$00,$24,$15,$00,$00,$42,$0B,$00,$00,$5B,$0C,$00,$00,$73
        db $14,$00,$00,$77,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; clear all records from one level
; A = translevel to delete
delete_translevel_data:
        PHP
        CMP #$00 ; level 00 contains file info, so never delete it
        BEQ +
        CMP #$19 ; level 19 contains options, so never delete it
        BEQ +
        
        LDX #$07
      - JSL delete_one_record
        DEX
        BPL -
         
      + PLP
        RTL

; clear a record where A = translevel & X = 00000xkk, x = normal/secret, kk = kind
; restores A & X
delete_one_record:
        PHP
        PHA
        
        REP #$20
        AND #$00FF
        ASL #5
        STA $00
        SEP #$20
        TXA
        ASL #2
        TSB $00
        LDA #$70
        STA $02
        
        LDA #$FF
        LDY #$03
      - STA [$00],Y
        DEY
        BPL -
        
        PLA
        PLP
        RTL
        
; function that runs if select is pressed after choosing delete data
delete_data:
        LDA #$18 ; thunder
        STA $1DFC ; apu i/o
        LDA #$27 ; "the data has been erased"
        STA $12 ; stripe image loader
        LDA #$09 ; replay music
        STA $1DFB ; apu i/o
        LDA !erase_records_flag
        DEC A
        ASL A
        TAX
        JMP (.delete_table,X)
    
    .delete_table:
        dw .delete_all
        dw .delete_level
        dw .delete_normal_low
        dw .delete_normal_nocape
        dw .delete_normal_cape
        dw .delete_normal_lunardragon
        dw .delete_secret_low
        dw .delete_secret_nocape
        dw .delete_secret_cape
        dw .delete_secret_lunardragon
        dw .delete_statusbar_1
        dw .delete_statusbar_2
        dw .delete_statusbar_3
        
    .delete_all:
        JSL delete_all_data
        JMP .done
    .delete_level:
        LDA !potential_translevel
        JSL delete_translevel_data
        JMP .done
    .delete_normal_low:
    .delete_normal_nocape:
    .delete_normal_cape:
    .delete_normal_lunardragon:
    .delete_secret_low:
    .delete_secret_nocape:
    .delete_secret_cape:
    .delete_secret_lunardragon:
        LDA !erase_records_flag
        DEC #3
        TAX
        LDA !potential_translevel
        JSL delete_one_record
        JMP .done
    .delete_statusbar_1:
    .delete_statusbar_2:
    .delete_statusbar_3:
        LDA !erase_records_flag
        SEC
        SBC #$0B
        JSL delete_custom_statusbar
        
    .done:
        STZ !erase_records_flag
        RTS

; A|X = address of data, Y = number of bytes
; requires 8-bit accumulator, 16-bit index
load_vram:
        PHP
        PHA
        
        STX $4302 ; dma0 source address
        STA $4304 ; dma0 source bank
        STY $4305 ; dma0 length
        
        LDA #$01 ; 2-byte, low-high
        STA $4300 ; dma0 parameters
        LDA #$18 ; $2118, vram data
        STA $4301 ; dma0 destination
        LDA #$01 ; channel 0
        STA $420B ; dma enable
        
        PLA
        PLP
        RTL

; A|X = address of data, Y = number of bytes
; requires 8-bit accumulator, 16-bit index
load_cgram:
        PHP
        PHA
        
        STX $4302 ; dma0 source address
        STA $4304 ; dma0 source bank
        STY $4305 ; dma0 length
        
        LDA #$00 ; 1-byte
        STA $4300 ; dma0 parameters
        LDA #$22 ; $2122, cgram data
        STA $4301 ; dma0 destination
        LDA #$01 ; channel 0
        STA $420B ; dma enable
        
        PLA
        PLP
        RTL

; stripe images for text when deleting data
stripe_confirm:
        db $53,$02,$00,$31
        db $19,$2C
        db $1B,$2C,$0E,$2C
        db $1C,$2C,$1C,$2C
        db $FC,$2C,$1C,$2C
        db $0E,$2C,$15,$2C
        db $0E,$2C,$0C,$2C
        db $1D,$2C,$FC,$2C
        db $1D,$2C,$18,$2C
        db $FC,$2C,$0C,$2C
        db $18,$2C,$17,$2C
        db $0F,$2C,$12,$2C
        db $1B,$2C,$16,$2C
        db $FC,$2C,$FC,$2C
        db $FF
stripe_deleted:
        db $53,$02,$00,$31
        db $1D,$2C,$11,$2C
        db $0E,$2C,$FC,$2C
        db $0D,$2C,$0A,$2C
        db $1D,$2C,$0A,$2C
        db $FC,$2C
        db $11,$2C,$0A,$2C
        db $1C,$2C,$FC,$2C
        db $0B,$2C,$0E,$2C
        db $0E,$2C,$17,$2C
        db $FC,$2C,$0D,$2C
        db $0E,$2C,$15,$2C
        db $0E,$2C,$1D,$2C
        db $0E,$2C,$0D,$2C
        db $FF

; draw option title and description
; $04|$05 contains background offset
draw_option_text:
        PHP
        STZ $04
        STZ $05
        LDA !overworld_menu_mode
        CMP #$02
        BNE +
        LDA #$04
        STA $05 ; route editor is on second page
        
      + LDA !text_timer
        AND #$07
        BEQ +
        BRL .done
        
      + LDA !text_timer
        BNE +
        BRL .draw_title_and_clear
        
      + SEP #$30
        LDA !current_selection
        REP #$30
        AND #$00FF
        ASL #6
        STA $00
        ASL A
        CLC
        ADC $00
        CLC
        ADC #option_description
        STA $00
        LDA !text_timer
        AND #$00FF
        SEC
        SBC #$0008
        ASL #2
        CLC
        ADC $00
        STA $00
        LDA.W #bank(option_description) ; bank of text
        STA $02
        LDA !text_timer
        AND #$00FF
        SEC
        SBC #$0008
        ASL #2
        CLC
        ADC #$5320 ; position of description
        CLC
        ADC $04
        XBA
        TAY
        LDX #$0020
        LDA #$3838
        JSL draw_text_string
        BRL .done
        
    .draw_title_and_clear:
        REP #$30
        LDA !current_selection
        AND #$00FF
        ASL #5
        CLC
        ADC #option_title
        STA $00
        LDA.W #bank(option_title) ; bank of text
        STA $02
        LDA #$52C0 ; position of option name
        CLC
        ADC $04
        XBA
        TAY
        LDX #$0020
        LDA #$3434
        JSL draw_text_string
        
        JSL draw_option_value
        
        LDA.L $7F837B
        TAX
        LDA #$5320 ; position of description
        CLC
        ADC $04
        XBA
        STA.L $7F837D,X
        LDA #$BF41
        STA.L $7F837F,X
        LDA #$38FC
        STA.L $7F8381,X
        LDA #$FFFF
        STA.L $7F8383,X
        TXA
        CLC
        ADC #$0006
        STA.L $7F837B    
    .done:
        PLP
        RTL
        
; $04|$05 contains background offset
draw_option_value:
        PHP
        REP #$30
        LDA #option_empty
        STA $00
        LDA.W #bank(option_empty) ; bank of text
        STA $02
        LDA !current_selection
        AND #$00FF
        ASL A
        TAX
        LDA option_value_lists,X
        BEQ .exit_default
        BMI .continue
        
    .yoshi_powerup_hybrid:
        ORA #$8000
        PHA ; special case for yoshi color/powerup which is a hybrid
        LDA !current_selection
        AND #$00FF
        TAX
        LDA.L !status_table,X
        AND #$00FF
        CMP #$0005
        PLA
        BCS .exit_default
        STA $00
        BRA .finish
        
    .continue:
        STA $00
        TXA
        LSR A
        TAX
    .finish:
        LDA.L !status_table,X
        AND #$00FF
        ASL #5
        ADC $00
        STA $00
    .exit_default:
        LDX #$0020
        LDA #$52E0 ; position of option selection
        CLC
        ADC $04
        XBA
        TAY
    .exit:
        LDA #$3030
        JSL draw_text_string
        
        SEP #$30
        LDA !current_selection
        CMP #$19
        BNE +
        LDA !status_movieload
        CMP #$02
        BCC +
        BRA ++
      + PLP
        RTL
        
        ; draw movie name for load movie option
     ++ LDA !potential_translevel
        ASL A
        TAX
        LDA.L translevel_movie_ptrs_head,X
        STA $00
        LDA.L translevel_movie_ptrs_head+1,X
        STA $01
        LDA #translevel_movie_ptrs_head>>16
        STA $02
        
        LDA.L !status_movieload
        DEC #2
        STA $03
        ASL A
        CLC
        ADC $03
        TAY
        LDA [$00],Y
        PHA
        INY
        LDA [$00],Y
        PHA
        INY
        LDA [$00],Y
        STA $02
        PLA
        STA $01
        PLA
        STA $00
      
        REP #$30
        LDA #$52EB ; position of movie name
        CLC
        ADC $04
        XBA
        TAY
        LDX #$0014
        LDA #$3030
        JSL draw_text_string
        
        PLP
        RTL

; draw a text string
; where $00|01|02 holds the pointer to the string
; and A holds the property byte for the text
; X (16-bit) holds the length of the string
; and Y (16-bit) holds the 16-bit header for the stripe image
draw_text_string:
        PHA
        STX $0C
        LDA.L $7F837B
        TAX
        TYA
        STA.L $7F837D,X
        LDA $0C
        PHA
        AND #$3FFF
        STA $0C
        PLA
        ASL A
        DEC A
        XBA
        STA.L $7F837F,X
        LDY #$0000
        SEP #$20
        
      - LDA [$00],Y
        STA.L $7F8381,X
        INX
        PLA
        PHA
        STA.L $7F8381,X
        INX
        INY
        CPY $0C
        BNE -
        
        REP #$20
        LDA.L $7F837B
        CLC
        ADC $0C
        CLC
        ADC $0C
        CLC
        ADC #$0004
        STA.L $7F837B
        TAX
        LDA #$FFFF
        STA.L $7F837D,X
        PLA
        RTL

; draw a single tile
; and A holds the property and tile
; X (16-bit) holds the vram address
draw_single_tile:
        STA $0C
        PHX
        LDA.L $7F837B
        TAX
        PLA
        STA.L $7F837D,X
        LDA #$0100
        STA.L $7F837F,X
        LDA $0C
        STA.L $7F8381,X
        LDA #$FFFF
        STA.L $7F8383,X
        TXA
        CLC
        ADC #$0006
        STA.L $7F837B
        RTL

; draw a cursor
; where X = x pos, Y = y pos, $00 = width, $01 = height, $02 = squeezed, $03 = cursor type, $04 = change color, $0A = pointer to OAM
draw_generic_cursor:
        LDA !menu_screen_moved
        BMI +
        CMP !overworld_menu_mode
        BEQ ++
      + RTS

     ++ PHX
        PHY
        
        LDA $02
        BEQ +
        LDA #$00
        BRA .merge_squeeze
      + LDA $13 ; frame counter
        AND #$10
        BEQ +
        LDA #$02
        BRA .merge_squeeze
      + LDA #$01
    .merge_squeeze:
        STA $0F
        LDA #$02
        STA $07
        
        TXA
        SEC
        SBC $0F
        STA $0E
        TYA
        SEC
        SBC $0F
        TAY
        LDA !util_axlr_hold
        AND #%00100000
        BEQ +
        LDA #$3C
        BRA .merge_tl_color
      + LDA $04
        BEQ +
        LDA #$3A
        BRA .merge_tl_color
      + LDA #$36
    .merge_tl_color:
        STA $05
        LDA #$00
        CLC
        ADC $0A
        STA $06
        LDA $03
        AND #$01
        TAX
        LDA cursor_tiles,X
        LDX $0E
        JSR draw_cursor_bit
        
        PLY
        PLX
        PHX
        PHY
        TXA
        CLC
        ADC $0F
        CLC
        ADC $00
        STA $0E
        TYA
        SEC
        SBC $0F
        TAY
        LDA !util_axlr_hold
        AND #%00010000
        BEQ +
        LDA #$3C
        BRA .merge_tr_color
      + LDA $04
        BEQ +
        LDA #$3A
        BRA .merge_tr_color
      + LDA #$36
    .merge_tr_color:
        ORA #$40
        STA $05
        LDA #$04
        CLC
        ADC $0A
        STA $06
        LDA $03
        AND #$01
        TAX
        LDA cursor_tiles,X
        LDX $0E
        JSR draw_cursor_bit
        
        PLY
        PLX
        PHX
        PHY
        TXA
        SEC
        SBC $0F
        STA $0E
        TYA
        CLC
        ADC $0F
        CLC
        ADC $01
        TAY
        LDA $04
        BEQ +
        LDA #$3A
        BRA .merge_bl_color
      + LDA #$36
    .merge_bl_color:
        ORA #$80
        STA $05
        LDA #$08
        CLC
        ADC $0A
        STA $06
        LDA cursor_tiles
        LDX $0E
        JSR draw_cursor_bit
        
        PLY
        PLX
        PHX
        PHY
        TXA
        CLC
        ADC $0F
        CLC
        ADC $00
        STA $0E
        TYA
        CLC
        ADC $0F
        CLC
        ADC $01
        TAY
        LDA $04
        BEQ +
        LDA #$3A
        BRA .merge_br_color
      + LDA #$36
    .merge_br_color:
        ORA #$C0
        STA $05
        LDA #$0C
        CLC
        ADC $0A
        STA $06
        LDA $03
        AND #$02
        TAX
        LDA cursor_tiles,X
        LDX $0E
        JSR draw_cursor_bit
        
        PLY
        PLX
        LDA $0A
        LSR #4
        TAY
        LDA #$AA
        CPX #$F8
        BCC +
        ORA #$11
      + CPX #$08
        BCS +
        ORA #$11
      + STA $0400,Y
        
        RTS

cursor_tiles:
        db $06,$08,$0A

; draw 1/4 of a cursor
; where x = x pos, Y = y pos, A = tile byte, $05 = property byte, $06 = pointer to oam
; if carry is clear, set high x position bit
draw_cursor_bit:
        PHY
        LDY #$02
        STA ($06),Y
        PLA
        DEY
        STA ($06),Y
        DEY
        TXA
        STA ($06),Y
        LDY #$03
        LDA $05
        STA ($06),Y
        RTS        
        
; draw the list of levels in the current fast mode route
; list maxes at 12 long
; uses $00-$08
draw_route_level_list:
        PHP
        SEP #$30
        LDA !status_fast_mode
        BNE +
        BRL .exit
        
      + DEC A
        ASL #2
        TAX
        LDA.L FastMode_header_locations,X
        STA $00
        LDA.L FastMode_header_locations+1,X
        STA $01
        LDA.L FastMode_header_locations+2,X
        STA $02
        LDA [$00] ; number of levels
        STA $03 ; number of levels in route
        BNE .not_empty
        
        LDA.B #level_names
        STA $00
        LDA.B #level_names>>8
        STA $01
        LDA.B #bank(level_names)
        STA $02
        REP #$30
        LDA #$28FC ; blank tile
        LDX #$F554 ; address
        JSL draw_single_tile
        LDA #$28FC ; blank tile
        LDX #$9556 ; address
        JSL draw_single_tile
        LDX #$0010
        LDA #$5511 ; address
        STA $04
        XBA
        TAY
        LDA #$2D2D
        JSL draw_text_string
        
        LDA.W #level_names_empty
        STA $00
      - LDA $04
        CLC
        ADC #$0020
        CMP #$5511+($20*12)
        BEQ +
        STA $04
        XBA
        TAY
        LDX #$0010
        LDA #$2D2D
        JSL draw_text_string
        BRA -
        
      + LDX #$400C ; hack for vertical string
        LDY #$1055
        LDA #$2929
        JSL draw_text_string
        BRL .exit
        
    .not_empty:
        PHX
        
        LDA !fast_mode_current_level
        PHA
      - CMP #12
        BCC +
        SEC
        SBC #12
        BRA -
        
      + STA $08
        PLA
        SEC
        SBC $08
        
        STA $08
        CMP #$01
        REP #$30
        LDA #$28FC ; blank tile
        BCC + ; if more levels exit, draw arrow
        LDA #$2841 ; arrow tile
      + LDX #$F554 ; address
        JSL draw_single_tile
        
        LDA.W #level_names_empty
        STA $00
        LDA.W #level_names_empty>>8
        STA $01
        LDX #$400C ; hack for vertical string
        LDY #$1055
        LDA #$2929
        JSL draw_text_string
        
        SEP #$30
        PLX
        STZ $07 ; number of levels to show
        LDA.L FastMode_save_locations,X
        STA $04
        LDA.L FastMode_save_locations+1,X
        STA $05
        LDA.L FastMode_save_locations+2,X
        STA $06
        
      - LDA $07
        CMP #12 ; max levels to show
        BNE .not_finished
        LDA $08
        CMP $03
        REP #$30
        LDA #$28FC ; blank tile
        BCS + ; if more levels exit, draw arrow
        LDA #$2842 ; arrow tile
      + LDX #$9556 ; address
        JSL draw_single_tile
        BRL .exit
        
    .not_finished:
        LDA $08
        CMP $03
        BCC .level
        REP #$30
        LDA.W #level_names_empty
        STA $00
        JMP .merge
        
    .level:
        REP #$30
        AND #$00FF
        STA $09
        ASL #2
        CLC
        ADC $09
        ASL A ; x10
        TAY
        LDA [$04],Y
        AND #$00FF
        ASL #4
        CLC
        ADC.W #level_names
        STA $00
    .merge:
        LDX.W #10
        LDA $08
        EOR !fast_mode_current_level
        AND #$00FF
        BEQ .highlight_me
        INY #8
        LDA [$04],Y
        AND #$00F0
        BEQ .normal_exit
        LDA #$3D3D
        BRA +
    .normal_exit:
        LDA #$2D2D
        BRA +
    .highlight_me:
        PHX
        LDA $07
        AND #$00FF
        ASL #5
        CLC
        ADC #$5510 ; address
        XBA
        TAX
        LDA #$2C40 ; arrow tile
        JSL draw_single_tile
        PLX
        LDA #$2929
        
      + PHA
        LDA $07
        AND #$00FF
        ASL #5
        CLC
        ADC #$5511
        XBA
        TAY
        PLA
        JSL draw_text_string
        SEP #$30
        INC $07
        INC $08
        BRL -
        
        
    .exit:
        PLP
        RTL

; check the saved options, and if any are out of bounds, set them to zero as a failsafe
failsafe_check_option_bounds:
        PHP
        PHB
        PHK
        PLB
        SEP #$30
        
        LDX #!number_of_options
      - LDA.L !status_table,X
        DEC A
        CMP minimum_selection_extended,X
        BCC +
        LDA #$00
        STA.L !status_table,X
        
      + DEX
        BPL -
        
        PLB
        PLP
        RTL
        
; run the meter editor section of the menu
meter_editor_mode: ; w$5460
        LDA !current_meter_selection
        STA $0B
        
        LDA !util_byetudlr_frame
        AND #%00010000
        BEQ +
        LDA #$0B ; on/off sound
        STA $1DF9 ; apu i/o
        STZ !overworld_menu_mode
        STZ !text_timer
        RTS
        
      + INC !fast_scroll_timer
        LDA !util_axlr_hold
        AND #%00110000
        BNE .fast_scroll
        STZ !fast_scroll_timer
    .fast_scroll:
        LDA !fast_scroll_timer
        CMP #!fast_scroll_delay
        BCC .check_left
        LDA #!fast_scroll_delay
        STA !fast_scroll_timer
        
    .check_left:
        LDA !util_axlr_frame
        AND #%00100000
        BNE .go_left
        LDA !util_axlr_hold
        AND #%00100000
        BEQ .check_right
        LDA !fast_scroll_timer
        CMP #!fast_scroll_delay
        BNE .check_right
    .go_left:
        LDA !util_byetudlr_hold
        ORA !util_axlr_hold
        AND #%01000000
        BEQ .left_no_hold
        LDA !current_meter_selection
        ASL #2
        TAY
        LDA [!statusbar_layout_ptr],Y
        CMP #$11 ; memory viewer $7E
        BEQ +
        CMP #$12 ; memory viewer $7F
        BEQ +
      - INY
        LDA [!statusbar_layout_ptr],Y
        DEC A
        STA [!statusbar_layout_ptr],Y
        JSR check_meter_valid
        JMP .done_update_sub
      + LDA !util_byetudlr_hold
        AND #%01000000
        BEQ -
        INY 
        BRA -
    .left_no_hold:
        LDA !current_meter_selection
        ASL #2
        TAY
        LDA [!statusbar_layout_ptr],Y
        DEC A
        BPL +
        LDA #$14 ; number of meters
      + STA [!statusbar_layout_ptr],Y
        LDA #$00
        INY
        STA [!statusbar_layout_ptr],Y
        INY
        STA [!statusbar_layout_ptr],Y
        JSR check_meter_valid
        JMP .done_update_text
        
    .check_right:
        LDA !util_axlr_frame
        AND #%00010000
        BNE .go_right
        LDA !util_axlr_hold
        AND #%00010000
        BEQ .check_side
        LDA !fast_scroll_timer
        CMP #!fast_scroll_delay
        BNE .check_side
    .go_right:
        LDA !util_byetudlr_hold
        ORA !util_axlr_hold
        AND #%01000000
        BEQ .right_no_hold
        LDA !current_meter_selection
        ASL #2
        TAY
        LDA [!statusbar_layout_ptr],Y
        CMP #$11 ; memory viewer $7E
        BEQ +
        CMP #$12 ; memory viewer $7F
        BEQ +
      - INY
        LDA [!statusbar_layout_ptr],Y
        INC A
        STA [!statusbar_layout_ptr],Y
        JSR check_meter_valid
        JMP .done_update_sub
      + LDA !util_byetudlr_hold
        AND #%01000000
        BEQ -
        INY
        BRA -
    .right_no_hold:
        LDA !current_meter_selection
        ASL #2
        TAY
        LDA [!statusbar_layout_ptr],Y
        INC A
        CMP #$15 ; number of meters + 1
        BNE +
        LDA #$00
      + STA [!statusbar_layout_ptr],Y
        LDA #$00
        INY
        STA [!statusbar_layout_ptr],Y
        INY
        STA [!statusbar_layout_ptr],Y
        JSR check_meter_valid
        JMP .done_update_text
        
    .check_side:
        LDA !util_byetudlr_frame
        AND #%00000011
        BEQ .check_dup
        LDA !util_byetudlr_hold
        ORA !util_axlr_hold
        AND #%01000000
        BEQ .side_no_hold
        LDA !util_byetudlr_frame
        AND #%00000001
        ASL A
        DEC A
        STA $01
        LDA !current_meter_selection
        ASL #2
        ORA #$03
        TAY
        LDA [!statusbar_layout_ptr],Y
        AND #$E0
        STA $00
        LDA [!statusbar_layout_ptr],Y
        AND #$1F
        CLC
        ADC $01
        BMI +
        CMP #$20
        BEQ +
        ORA $00
        STA [!statusbar_layout_ptr],Y
        JSR check_meter_valid
      + JMP .done_update_meter
    .side_no_hold:
        LDA !current_meter_selection
        CLC
        ADC #$0C
        CMP #$18
        BCC +
        SEC
        SBC #$18
      + STA !current_meter_selection
        JMP .done_sound
      
    .check_dup:
        LDA !util_byetudlr_frame
        AND #%00001000
        BEQ .check_ddown
        LDA !util_byetudlr_hold
        ORA !util_axlr_hold
        AND #%01000000
        BEQ .dup_no_hold
        LDA !current_meter_selection
        ASL #2
        ORA #$03
        TAY
        LDA [!statusbar_layout_ptr],Y
        AND #$1F
        STA $00
        LDA [!statusbar_layout_ptr],Y
        AND #$E0
        BEQ +
        SEC
        SBC #$20
        ORA $00
        STA [!statusbar_layout_ptr],Y
        JSR check_meter_valid
      + JMP .done_update_meter
    .dup_no_hold:
        LDA !current_meter_selection
        DEC A
        BPL +
        LDA #$17
      + STA !current_meter_selection
        JMP .done_sound
      
    .check_ddown:
        LDA !util_byetudlr_frame
        AND #%00000100
        BEQ .check_press
        LDA !util_byetudlr_hold
        ORA !util_axlr_hold
        AND #%01000000
        BEQ .ddown_no_hold
        LDA !current_meter_selection
        ASL #2
        ORA #$03
        TAY
        LDA [!statusbar_layout_ptr],Y
        AND #$1F
        STA $00
        LDA [!statusbar_layout_ptr],Y
        AND #$E0
        CLC
        ADC #$20
        CMP #$A0
        BEQ +
        ORA $00
        STA [!statusbar_layout_ptr],Y
        JSR check_meter_valid
      + JMP .done_update_meter
    .ddown_no_hold:
        LDA !current_meter_selection
        INC A
        CMP #$18
        BCC +
        LDA #$00
      + STA !current_meter_selection
        JMP .done_sound
        
    .check_press:
        JMP .done_no_sound
    
    .done_update_text:
        STZ !text_timer
        BRA .done_update_meter
    .done_update_sub:
        REP #$30
        JSL draw_meter_text_draw_subtype_text
        SEP #$30
    .done_update_meter:
        LDA.b #bank(meter_names)
        STA $02
        LDA !current_meter_selection
        ASL #2
        TAY
        LDA [!statusbar_layout_ptr],Y
        REP #$30
        AND #$00FF
        ASL #4
        CLC
        ADC #meter_names
        STA $00
        LDA !current_meter_selection
        AND #$00FF
        TAX
        ASL #5
        CLC
        ADC #$58E2
        CPX #$000C
        BCC +
        SEC
        SBC #$0171
      + XBA
        TAY
        LDX #$000E
        LDA #$3838
        JSL draw_text_string
        SEP #$30
        JSL default_status_bar
        JSL display_meters_wrapper
        JSR draw_edited_status_bar
    .done_sound:
        LDA #$06 ; fireball sound
        STA $1DFC ; apu i/o
    .done_no_sound:
        JSL draw_meter_cursors
        JSL draw_meter_text        
        LDA !text_timer
        CMP #$27
        BCS +
        INC A
        STA !text_timer
      + LDX !current_meter_selection
        CPX $0B
        BEQ +
        STZ !text_timer
    
      + RTS
      
; make sure meter position and subtype are valid
; Y = meter index * 4 somewhere
check_meter_valid:
        TYA
        AND #$FC
        TAY
        LDA [!statusbar_layout_ptr],Y
        CMP #$11
        BEQ .check_pos2
        CMP #$12
        BEQ .check_pos2
        TAX
        LDA meter_subtype_counts,X
        STA $00
        INY
        LDA [!statusbar_layout_ptr],Y
        CMP #$FF
        BNE +
        LDA $00
        DEC A
        STA [!statusbar_layout_ptr],Y
        BRA .check_pos
      + CMP $00
        BCC .check_pos
        LDA #$00
        STA [!statusbar_layout_ptr],Y
        
    .check_pos:
        DEY
    .check_pos2:
        LDA [!statusbar_layout_ptr],Y
        ASL #3
        CMP #$88 ; memory viewer $7E
        BEQ +
        CMP #$90 ; memory viewer $7F
        BEQ +
        INY
        ORA [!statusbar_layout_ptr],Y
        DEY
      + TAX
        LDA meter_widths,X
        STA $00
        LDA meter_heights,X
        STA $01
        
    .check_xpos:
        INY #3
        LDA [!statusbar_layout_ptr],Y
        AND #$1F
        CLC
        ADC $00
        DEC A
        CMP #$20
        BCC .check_ypos
        LDA #$20
        SEC
        SBC $00
        STA $00
        LDA [!statusbar_layout_ptr],Y
        AND #$E0
        ORA $00
        STA [!statusbar_layout_ptr],Y
        
    .check_ypos:
        LDA [!statusbar_layout_ptr],Y
        AND #$E0
        LSR #5
        CLC
        ADC $01
        DEC A
        CMP #$05
        BCC .done
        LDA #$05
        SEC
        SBC $01
        ASL #5
        STA $01
        LDA [!statusbar_layout_ptr],Y
        AND #$1F
        ORA $01
        STA [!statusbar_layout_ptr],Y
        
    .done:
        RTS

; draw the two cursors for the meter editor
draw_meter_cursors:
        LDA #$70
        STA $00
        LDA #$08
        STA $01
        STZ $02
        LDA !fast_scroll_timer
        CMP #!fast_scroll_delay
        BNE +
        INC $02
      + LDA #$01
        STA $03
        STZ $04
        STZ $0A
        LDA !current_meter_selection
        CMP #$0C
        BCC +
        SEC
        SBC #$0C
      + ASL #3
        CLC
        REP #$20
        AND #$00FF
        ADC #$012F
        SEC
        SBC $24
        CMP #$00E0
        SEP #$20
        BCS .draw_status_cursor
        TAY
        LDA !current_meter_selection
        CMP #$0C
        BCC +
        LDA #$80
        BRA ++
      + LDA #$08
     ++ TAX
        JSR draw_generic_cursor
        
    .draw_status_cursor:
        LDA !current_meter_selection
        ASL #2
        TAY
        LDA [!statusbar_layout_ptr],Y
        BNE +
        JMP .done
        
      + ASL #3
        CMP #$88 ; $7E memory viewer
        BEQ +
        CMP #$90 ; $7F memory viewer
        BEQ +
        INY
        ORA [!statusbar_layout_ptr],Y
        DEY
      + TAX
        LDA meter_widths,X
        ASL #3
        STA $00
        LDA meter_heights,X
        ASL #3
        STA $01
        
        STZ $02
        STZ $03
        STZ $04
        LDA !util_axlr_hold
        ORA !util_byetudlr_hold
        AND #%01000000
        BEQ +
        INC $04
      + LDA #$10
        STA $0A
        LDA [!statusbar_layout_ptr],Y
        CMP #$01 ; item box
        BEQ +
        CMP #$15 ; vanilla hud
        BNE +++
        LDA #$10
        BRA ++
      + LDA #$08
        BRA ++
    +++ INY #3
        LDA [!statusbar_layout_ptr],Y
        DEY #3
        AND #$E0
        LSR #2
     ++ CLC
        REP #$20
        AND #$00FF
        ADC #$00FF
        SEC
        SBC $24
        CMP #$00E0
        SEP #$20
        BCS .done
        PHA
        LDA [!statusbar_layout_ptr],Y
        CMP #$01 ; item box
        BEQ +
        CMP #$15 ; vanilla hud
        BNE +++
        LDA #$08
        BRA ++
      + LDA #$68
        BRA ++
    +++ INY #3
        LDA [!statusbar_layout_ptr],Y
        AND #$1F
        DEC A
        ASL #3
     ++ TAX
        PLY
        JSR draw_generic_cursor
        
    .done:
        RTL

meter_subtype_counts:
        db $01,$01,$01,$01,$02,$03,$03,$01,$03,$03,$03,$02,$03,$01,$05,$05,$02,$FF,$FF,$03,$01,$01
meter_widths:
        db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $04,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $02,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $02,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $02,$02,$FF,$FF,$FF,$FF,$FF,$FF
        db $02,$02,$02,$FF,$FF,$FF,$FF,$FF
        db $02,$02,$02,$FF,$FF,$FF,$FF,$FF
        db $05,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $08,$08,$06,$FF,$FF,$FF,$FF,$FF
        db $07,$07,$05,$FF,$FF,$FF,$FF,$FF
        db $07,$07,$05,$FF,$FF,$FF,$FF,$FF
        db $03,$02,$FF,$FF,$FF,$FF,$FF,$FF
        db $03,$05,$04,$FF,$FF,$FF,$FF,$FF
        db $01,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $08,$06,$06,$03,$03,$FF,$FF,$FF
        db $04,$04,$04,$04,$04,$FF,$FF,$FF
        db $07,$04,$FF,$FF,$FF,$FF,$FF,$FF
        db $02,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $02,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $05,$04,$04,$FF,$FF,$FF,$FF,$FF
        db $07,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $1C,$FF,$FF,$FF,$FF,$FF,$FF,$FF
meter_heights:
        db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $04,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $01,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $01,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $01,$01,$FF,$FF,$FF,$FF,$FF,$FF
        db $01,$01,$01,$FF,$FF,$FF,$FF,$FF
        db $01,$01,$01,$FF,$FF,$FF,$FF,$FF
        db $01,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $01,$01,$01,$FF,$FF,$FF,$FF,$FF
        db $01,$01,$01,$FF,$FF,$FF,$FF,$FF
        db $01,$01,$01,$FF,$FF,$FF,$FF,$FF
        db $01,$01,$FF,$FF,$FF,$FF,$FF,$FF
        db $01,$01,$01,$FF,$FF,$FF,$FF,$FF
        db $01,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $03,$02,$02,$04,$04,$FF,$FF,$FF
        db $01,$01,$01,$01,$01,$FF,$FF,$FF
        db $01,$01,$FF,$FF,$FF,$FF,$FF,$FF
        db $01,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $01,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $01,$01,$01,$FF,$FF,$FF,$FF,$FF
        db $01,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        db $02,$FF,$FF,$FF,$FF,$FF,$FF,$FF

draw_meter_names:
        PHP
        LDA.b #bank(meter_names) ; bank of text
        STA $02
        REP #$30
        
        LDX #$0017
      - TXA
        ASL #5
        CLC
        ADC #$58E2
        CPX #$000C
        BCC +
        SEC
        SBC #$0171
      + XBA
        PHA
        LDA #meter_names
        STA $00
        TXA
        ASL #2
        TAY
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        ASL #4
        CLC
        ADC $00
        STA $00
        PLY
        PHX
        LDX #$000E
        LDA #$3838
        JSL draw_text_string
        PLX
        DEX
        BPL -
        
        PLP
        RTL
      
; draw meter description
draw_meter_text: 
        LDA !text_timer
        AND #$07
        BEQ +
        BRL .done
        
      + LDA !text_timer
        BNE +
        BRL .draw_title_and_clear
      + REP #$30
        LDA !current_meter_selection
        AND #$00FF
        ASL #2
        TAY
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        ASL #7
        CLC
        ADC #meter_description
        STA $00
        LDA !text_timer
        AND #$00FF
        SEC
        SBC #$0008
        ASL #2
        CLC
        ADC $00
        STA $00
        LDA.W #bank(meter_description) ; bank of text
        STA $02
        LDA !text_timer
        AND #$00FF
        SEC
        SBC #$0008
        ASL #2
        CLC
        ADC #$5380
        XBA
        TAY
        LDX #$0020
        LDA #$3838
        JSL draw_text_string
        BRL .done
    .draw_title_and_clear:
        REP #$30
        
        LDA.L $7F837B
        TAX
        LDA #$E052
        STA.L $7F837D,X
        LDA #$3F42
        STA.L $7F837F,X
        LDA #$38FC
        STA.L $7F8381,X
        LDA #$FFFF
        STA.L $7F8383,X
        TXA
        CLC
        ADC #$0006
        STA.L $7F837B  
        
        LDA !current_meter_selection
        AND #$00FF
        ASL #2
        TAY
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        ASL #4
        CLC
        ADC #meter_names
        STA $00
        LDA.W #bank(meter_names) ; bank of text
        STA $02
        LDY #$4553
        LDX #$000E
        LDA #$3434
        JSL draw_text_string  
        
    .draw_subtype_text:
        LDA !current_meter_selection
        AND #$00FF
        ASL #2
        TAY
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        CMP #$0011 ; $7E memory viewer
        BEQ .break
        CMP #$0012 ; $7F memory viewer
        BEQ .break
        ASL A
        TAX
        LDA.L meter_types,X
        STA $00
        INY
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        ASL #4
        CLC
        ADC $00
        STA $00
        LDA.W #bank(meter_types) ; bank of text
        STA $02
        LDY #$5453
        LDX #$000A
        LDA #$3434
        JSL draw_text_string
        JMP .done
    .break:
        AND #$0002
        LSR A
        ORA #$070E
        XBA
        STA $00B6
        INY
        LDA [!statusbar_layout_ptr],Y
        PHA
        XBA
        LSR #4
        AND #$000F
        STA $00B6+2
        PLA
        PHA
        XBA
        AND #$000F
        STA $00B6+3
        PLA
        PHA
        LSR #4
        AND #$000F
        STA $00B6+4
        PLA
        AND #$000F
        STA $00B6+5
        LDA #$00B6
        STA $00
        LDA #$7E7E ; bank of $7E00B6
        STA $02
        LDY #$5853
        LDX #$0006
        LDA #$3434
        JSL draw_text_string
        
    .done:
        SEP #$30
        RTL
        
; draw the status bar, but put it in the RAM buffer for speed
draw_edited_status_bar:
        PHP
        REP #$30
        LDA.L $7F837B
        TAX
        CLC
        ADC #$0144
        STA.L $7F837B
        
        LDA #$2058 ; w$5820
        STA.L $7F837D,X
        LDA #$3F01 ; $0140 bytes
        STA.L $7F837F,X
        LDA #$FFFF
        STA.L $7F84C1,X
        TXA
        CLC
        ADC #$8381
        STA $03
        
        TXA
        CLC
        ADC #$013E
        TAX
        LDA #$38FC
        LDY #$013E
      - STA.L $7F8381,X
        DEX #2
        DEY #2
        BPL -
        
        SEP #$20
        LDA #$7F
        STA $02
        
        LDY #$005C
        
        REP #$20
      - LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        BEQ +
        CMP #$0016
        BCS +
        INY #3
        LDA [!statusbar_layout_ptr],Y
        DEY #3
        AND #$00FF
        ASL A
        CLC
        ADC $03
        STA $00
        
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        ASL A
        TAX
        PHY
        LDY #$0000
        JSR (.meter,X)
        PLY
      + DEY #4
        BPL -
        
        PLP
    .nothing:
        RTS
    
    .meter:
        dw .nothing
        dw .edited_item_box
        dw .edited_mario_speed
        dw .edited_mario_takeoff
        dw .edited_mario_pmeter
        dw .edited_yoshi_subpixel
        dw .edited_held_subpixel
        dw .edited_lag_frames
        dw .edited_timer_level
        dw .edited_timer_room
        dw .edited_timer_stopwatch
        dw .edited_coin_count
        dw .edited_in_game_time
        dw .edited_slowdown
        dw .edited_input_display
        dw .edited_name
        dw .edited_movie_recording
        dw .edited_memory_7e
        dw .edited_memory_7f
        dw .edited_rng
        dw .edited_score
        dw .edited_vanilla_hud
        
    .edited_item_box:
        LDA $03
        CLC
        ADC #$005C
        STA $00
        LDA #$383A
        STA [$00],Y
        INY #2
        LDA #$383B
        STA [$00],Y
        INY #2
        STA [$00],Y
        INY #2
        LDA #$783A
        STA [$00],Y
        TYA
        CLC
        ADC #$003A
        TAY
        LDA #$384A
        STA [$00],Y
        INY #6
        LDA #$784A
        STA [$00],Y
        TYA
        CLC
        ADC #$003A
        TAY
        LDA #$384A
        STA [$00],Y
        INY #6
        LDA #$784A
        STA [$00],Y
        TYA
        CLC
        ADC #$003A
        TAY
        LDA #$B83A
        STA [$00],Y
        INY #2
        LDA #$B83B
        STA [$00],Y
        INY #2
        STA [$00],Y
        INY #2
        LDA #$F83A
        STA [$00],Y
        RTS
        
    .edited_mario_speed:
        LDA #$2884
        STA [$00],Y
        INY #2
        LDA #$2888
        STA [$00],Y
        RTS
        
    .edited_mario_takeoff:
        LDA #$3800
        STA [$00],Y
        INY #2
        LDA #$3802
        STA [$00],Y
        RTS
        
    .edited_mario_pmeter:
        PHY
        LDA $05,S
        TAY
        INY
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        PLY
        ASL A
        TAX
        JMP (.pmeter_type,X)
    .pmeter_type:
        dw .pmeter_type_Px
        dw .pmeter_type_xx
    .pmeter_type_Px:
        LDA #$3C19
        STA [$00],Y
        INY #2
        LDA #$3C07
        STA [$00],Y
        RTS
    .pmeter_type_xx:
        LDA #$3C07
        STA [$00],Y
        INY #2
        LDA #$3C00
        STA [$00],Y
        RTS
        
    .edited_yoshi_subpixel:
        PHY
        LDA $05,S
        TAY
        INY
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        PLY
        ASL A
        TAX
        JMP (.yoshi_subpixel_type,X)
    .yoshi_subpixel_type:
        dw .yoshi_subpixel_type_XY
        dw .yoshi_subpixel_type_Xx
        dw .yoshi_subpixel_type_Yy
    .yoshi_subpixel_type_XY:
        LDA #$280F
        STA [$00],Y
        INY #2
        LDA #$2808
        STA [$00],Y
        RTS
    .yoshi_subpixel_type_Xx:
        LDA #$280F
        STA [$00],Y
        INY #2
        LDA #$2800
        STA [$00],Y
        RTS
    .yoshi_subpixel_type_Yy:
        LDA #$2808
        STA [$00],Y
        INY #2
        LDA #$2800
        STA [$00],Y
        RTS
        
    .edited_held_subpixel:
        PHY
        LDA $05,S
        TAY
        INY
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        PLY
        ASL A
        TAX
        JMP (.held_subpixel_type,X)
    .held_subpixel_type:
        dw .held_subpixel_type_XY
        dw .held_subpixel_type_Xx
        dw .held_subpixel_type_Yy
    .held_subpixel_type_XY:
        LDA #$3883
        STA [$00],Y
        INY #2
        LDA #$3885
        STA [$00],Y
        RTS
    .held_subpixel_type_Xx:
        LDA #$3883
        STA [$00],Y
        INY #2
        LDA #$3880
        STA [$00],Y
        RTS
    .held_subpixel_type_Yy:
        LDA #$3885
        STA [$00],Y
        INY #2
        LDA #$3880
        STA [$00],Y
        RTS
        
    .edited_lag_frames:
        LDA #$2881
        STA [$00],Y
        INY #2
        LDA #$288E
        STA [$00],Y
        INY #2
        LDA #$2887
        STA [$00],Y
        INY #2
        LDA #$288F
        STA [$00],Y
        INY #2
        LDA #$28AF
        STA [$00],Y
        RTS
        
    .edited_timer_level:
        LDA #$3C76
        STA [$00],Y
        INY #2
        LDA #$3C00
        STA $05
        JMP .edited_timer_general
        
    .edited_timer_room:
        LDA #$3800
        STA $05
        JMP .edited_timer_general
        
    .edited_timer_stopwatch:
        LDA #$2800
        STA $05
        JMP .edited_timer_general
        
    .edited_timer_general:
        PHY
        LDA $05,S
        TAY
        INY
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        PLY
        ASL A
        TAX
        JMP (.timer_type,X)
    .timer_type:
        dw .timer_type_sec_decimal
        dw .timer_type_sec_frame
        dw .timer_type_framecount
    .timer_type_sec_decimal:
        LDA #$0001
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$0029
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$0002
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$0003
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$0024
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$0006
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$0009
        ORA $05
        STA [$00],Y
        RTS
    .timer_type_sec_frame:
        LDA #$0001
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$0029
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$0002
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$0003
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$002A
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$0004
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$0001
        ORA $05
        STA [$00],Y
        RTS
    .timer_type_framecount:
        LDA #$0001
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$0003
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$0009
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$000D
        ORA $05
        STA [$00],Y
        INY #2
        LDA #$002F
        ORA $05
        STA [$00],Y
        RTS

    .edited_coin_count:
        LDA #$3C2E
        STA [$00],Y
        INY #2
        PHY
        LDA $05,S
        TAY
        INY
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        PLY
        ASL A
        TAX
        JMP (.coin_types,X)
    .coin_types:
        dw .coin_types_normal
        dw .coin_types_dragon
    .coin_types_normal:
        LDA #$3804
        STA [$00],Y
        INY #2
        LDA #$3802
        STA [$00],Y
        RTS
    .coin_types_dragon:
        LDA #$3803
        STA [$00],Y
        RTS
        
    .edited_in_game_time:
        LDA #$3C03
        STA [$00],Y
        INY #2
        LDA #$3C00
        STA [$00],Y
        INY #2
        STA [$00],Y
        INY #2
        PHY
        LDA $05,S
        TAY
        INY
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        PLY
        ASL A
        TAX
        JMP (.igt_types,X)
    .igt_types:
        dw .igt_types_nothing
        dw .igt_types_decimal
        dw .igt_types_symbolic
    .igt_types_nothing:
        RTS
    .igt_types_decimal:
        LDA #$3802
        STA [$00],Y
        INY #2
        LDA #$3802
        STA [$00],Y
        RTS
    .igt_types_symbolic:
        LDA #$3877
        STA [$00],Y
        RTS
        
    .edited_slowdown:
        LDA #$2882
        STA [$00],Y
        RTS
        
    .edited_input_display:
        PHY
        LDA $05,S
        TAY
        INY
        LDA [!statusbar_layout_ptr],Y
        PLY
        AND #$00FF
        STA $05
        ASL A
        CLC
        ADC $05
        ASL #2
        CLC
        ADC.L #layout_locations
        STA $05
        LDA #$9595 ; bank of layout_locations
        STA $07
        PHB
        PHK
        PLB
        JSR .input_display_type
        PLB
        RTS
    .input_display_type:
        LDX #$000C
    .edited_input_button:
        DEX
        BMI .edited_input_exit
        LDA $00
        PHA
        TXY
        LDA [$05],Y
        AND #$00FF
        ASL A
        CLC
        ADC $00
        STA $00
        LDA.L layout_tiles,X
        AND #$00FF
        ORA #$2800
        STA [$00]
        PLA
        STA $00
        INY #2
        BRA .edited_input_button
    .edited_input_exit:
        RTS
        
    .edited_name:
        PHY
        LDA $05,S
        TAY
        INY
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        STA $07 ; color option, for alt-set check
        PLY
        TAX
        LDA.L name_colors,X
        AND #$00FF
        XBA
        STA $05
        LDA $07
        CMP #$0003
        BCS .alt_set
        LDA.L !status_playername
        AND #$00FF
        ORA $05
        STA [$00],Y
        INY #2
        LDA.L !status_playername+1
        AND #$00FF
        ORA $05
        STA [$00],Y
        INY #2
        LDA.L !status_playername+2
        AND #$00FF
        ORA $05
        STA [$00],Y
        INY #2
        LDA.L !status_playername+3
        AND #$00FF
        ORA $05
        STA [$00],Y
        RTS
    .alt_set:
        LDA.L !status_playername
        AND #$00FF
        ORA #$0080 ; alt character set
        ORA $05
        STA [$00],Y
        INY #2
        LDA.L !status_playername+1
        AND #$00FF
        ORA #$0080 ; alt character set
        ORA $05
        STA [$00],Y
        INY #2
        LDA.L !status_playername+2
        AND #$00FF
        ORA #$0080 ; alt character set
        ORA $05
        STA [$00],Y
        INY #2
        LDA.L !status_playername+3
        AND #$00FF
        ORA #$0080 ; alt character set
        ORA $05
        STA [$00],Y
        RTS

    .edited_movie_recording:
        PHY
        LDA $05,S
        TAY
        INY
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        PLY
        ASL A
        TAX
        JMP (.recording_types,X)
    .recording_types:
        dw .recording_types_bar
        dw .recording_types_hex
    .recording_types_bar:
        LDA #$28D0
        STA [$00],Y
        INY #2
        LDA #$28D1
        STA [$00],Y
        INY #2
        STA [$00],Y
        INY #2
        LDA #$28CF
        STA [$00],Y
        INY #2
        STA [$00],Y
        INY #2
        STA [$00],Y
        INY #2
        LDA #$48CE
        STA [$00],Y
        RTS
    .recording_types_hex:
        LDA #$2885
        STA [$00],Y
        INY #2
        LDA #$288E
        STA [$00],Y
        INY #2
        LDA #$2883
        STA [$00],Y
        INY #2
        LDA #$28AF
        STA [$00],Y
        RTS

    .edited_memory_7e:
        LDA #$3807
        STA [$00],Y
        INY #2
        LDA #$380E
        STA [$00],Y
        RTS
        
    .edited_memory_7f:
        LDA #$3C07
        STA [$00],Y
        INY #2
        LDA #$3C0F
        STA [$00],Y
        RTS
        
    .edited_rng:
        PHY
        LDA $05,S
        TAY
        INY
        LDA [!statusbar_layout_ptr],Y
        AND #$00FF
        PLY
        ASL A
        TAX
        JMP (.rng_types,X)
    .rng_types:
        dw .rng_types_index
        dw .rng_types_value
        dw .rng_types_seed
    .rng_types_index:
        LDA #$3801
        STA [$00],Y
        INY #2
        LDA #$3802
        STA [$00],Y
        INY #2
        LDA #$3803
        STA [$00],Y
        INY #2
        LDA #$3804
        STA [$00],Y
        INY #2
        LDA #$3805
        STA [$00],Y
        RTS
    .rng_types_value:
    .rng_types_seed:
        LDA #$3800
        STA [$00],Y
        INY #2
        STA [$00],Y
        INY #2
        STA [$00],Y
        INY #2
        STA [$00],Y
        RTS

    .edited_score:
        LDA #$3801
        STA [$00],Y
        INY #2
        LDA #$3802
        STA [$00],Y
        INY #2
        LDA #$3803
        STA [$00],Y
        INY #2
        LDA #$3804
        STA [$00],Y
        INY #2
        LDA #$3805
        STA [$00],Y
        INY #2
        LDA #$3806
        STA [$00],Y
        INY #2
        LDA #$3800
        STA [$00],Y
        RTS

    .edited_vanilla_hud:
        LDA $03
        CLC
        ADC #$0084
        STA $00
        LDA #$2830
        STA [$00],Y
        INY #2
        LDA #$2831
        STA [$00],Y
        INY #2
        LDA #$2832
        STA [$00],Y
        INY #2
        LDA #$2833
        STA [$00],Y
        INY #2
        LDA #$2834
        STA [$00],Y
        TYA
        CLC
        ADC #$000E
        TAY
        LDA #$38B7
        STA [$00],Y
        TYA
        CLC
        ADC #$000C
        TAY
        LDA #$3C3D
        STA [$00],Y
        INY #2
        LDA #$3C3E
        STA [$00],Y
        INY #2
        LDA #$3C3F
        STA [$00],Y
        INY #8
        LDA #$3C2E
        STA [$00],Y
        INY #2
        LDA #$38DC
        STA [$00],Y
        INY #2
        LDA #$38FC
        STA [$00],Y
        TYA
        CLC
        ADC #$0010
        TAY
        LDA #$38DC
        STA [$00],Y
        INY #4
        LDA #$3805
        STA [$00],Y
        INY #8
        LDA #$2864
        STA [$00],Y
        INY #2
        LDA #$38DC
        STA [$00],Y
        INY #6
        LDA #$38C3
        STA [$00],Y
        RTS

print "inserted ", bytes, "/32768 bytes into bank $19"