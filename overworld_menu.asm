; this code is run once on overworld menu load
; GAME MODE #$1D
ORG $188000
overworld_menu_load:
		PHP
		PHB
		PHK
		PLB
		
		LDA #$09 ; special world theme
		STA $1DFB ; apu i/o
		
		LDA $1F28 ; yellow switch
		STA !status_yellow
		LDA $1F27 ; green switch
		STA !status_green
		LDA $1F2A ; red switch
		STA !status_red
		LDA $1F29 ; blue switch
		STA !status_blue
		
		LDA $0DBA ; ow yoshi color
		LSR A
		BEQ .skip_dec
		DEC A
	.skip_dec:
		STA !status_yoshi
		
		LDA $19 ; powerup
		STA !status_powerup
		LDA $0DC2 ; itembox
		STA !status_itembox
		STZ !status_erase
		STZ !status_enemy
		STZ !status_exit
		STZ !erase_records_flag
		
		LDA #$80
		STA $2100 ; force blank
		STZ $4200 ; nmi disable
		
		JSR upload_overworld_menu_graphics
		
		REP #$10
		LDA #$33
		STA $2108 ; bg2 base address & size
		STZ $210B ; bg12 name base address
		LDA #$06
		STA $212C ; through main
		LDX #$0000
		STX $1E ; layer 2 x position
		LDX #$0004
		STX $20 ; layer 2 y position
		LDX #$A445
		STX $0701 ; back area color
		SEP #$10
		
		LDX #!number_of_options-1
	.loop_item:
		JSL draw_menu_selection
		DEX
		BPL .loop_item
		
		JSL $0084C8
		
		LDX #$07
	.loop_graphics_files:
		STZ $0101,X
		DEX
		BPL .loop_graphics_files
		
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
		LDX #$0000
		STX $2116 ; vram address
		LDA #$19 ; #bank of menu_layer2_tiles
		LDX #menu_layer2_tiles
		LDY #$4000
		JSL load_vram
		
		LDX #$3000
		STX $2116 ; vram address
		LDA #$19 ; #bank of menu_layer2_tilemap
		LDX #menu_layer2_tilemap
		LDY #$0800
		JSL load_vram
		
		LDX #$5000
		STX $2116 ; vram address
		LDA #$19 ; #bank of menu_layer3_tilemap
		LDX #menu_layer3_tilemap
		LDY #$0800
		JSL load_vram
		
		LDA #$00
		STA $2121 ; cgram address
		LDA #$19 ; #bank of menu_palette
		LDX #menu_palette
		LDY #$0100
		JSL load_cgram
		
		PLP
		RTS

; draw one of the menu options to the screen, where X = menu index
draw_menu_selection:
		PHX
		PHP
		PHB
		PHK
		PLB
		
		LDA option_x_position,X
		STA $00
		LDA option_y_position,X
		STA $01
		
		LDA #$00
		CPX !current_selection
		BNE .not_selected
		LDA option_arrow_type,X
	.not_selected:
		TAY
		LDA arrow_tiles,Y
		STA $02
		
		REP #$30
		LDA !status_table,X
		AND #$00FF
		STA $0E
		TXA
		ASL A
		TAX
		LDA $0E
		CLC
		ADC option_index,X
		STA $03
		
		LDA $7F837B
		TAX
		SEP #$20
		
		LDA $01
		LSR #3
		ORA #$30
		STA $7F837D+00,X
		LDA $01
		INC A
		LSR #3
		ORA #$30
		STA $7F837D+12,X
		LDA $01
		ASL #5
		ORA $00
		STA $7F837D+01,X
		LDA $01
		INC A
		ASL #5
		ORA $00
		STA $7F837D+13,X
		LDA #$00
		STA $7F837D+02,X
		STA $7F837D+14,X
		LDA #$07
		STA $7F837D+03,X
		STA $7F837D+15,X
		LDA $02
		STA $7F837D+04,X
		STA $7F837D+16,X
		STA $7F837D+10,X
		STA $7F837D+22,X
		LDA #$50
		STA $7F837D+05,X
		LDA #$D0
		STA $7F837D+17,X
		LDA #$10
		STA $7F837D+11,X
		LDA #$90
		STA $7F837D+23,X
		LDA #$FF
		STA $7F837D+24,X
		
		REP #$20
		LDA $03
		ASL #3
		TAY
		LDA menu_option_tiles,Y
		STA $7F837D+06,X
		LDA menu_option_tiles+2,Y
		STA $7F837D+08,X
		LDA menu_option_tiles+4,Y
		STA $7F837D+18,X
		LDA menu_option_tiles+6,Y
		STA $7F837D+20,X
		
		TXA
		CLC
		ADC #$0018
		STA $7F837B
		
		PLB
		PLP
		PLX
		RTL

option_arrow_type:
		db $01,$01,$01,$01,$01,$01,$01,$01,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02
option_x_position:
		db $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
option_y_position:
		db $02,$04,$06,$08,$0A,$0E,$10,$12,$16,$02,$06,$08,$0A,$0C,$0E,$10,$12,$14,$18
option_index:
		dw $0000,$0002,$0004,$0006
		dw $0008,      $000A,$010A
		dw $020A,      $030A
		dw $030B,      $0315,$0318
		dw $031A,$031C,$031E,$0320
		dw $0322,$0324,      $032B
arrow_tiles:
		db $70,$4A,$4B
menu_option_tiles:
		incbin "bin/menu_option_tiles.bin"

ORG $198000

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

; this code is run on every frame during the overworld menu game mode (after fade in completes)
; GAME MODE #$1F
overworld_menu:
		PHP
		PHB
		PHK
		PLB
		SEP #$30
		INC $14
		
		LDA !current_selection
		STA $00
		
		LDA !erase_records_flag
		BEQ .test_up
		LDA $0DA2 ; byetudlr
		AND #%00100000
		BEQ .test_up
		JSR delete_data
		JMP .finish_no_sound
		
	.test_up:
		LDA $0DA6 ; byetudlr frame
		AND #%00001000
		BEQ .test_down
		LDA !current_selection
		DEC A
		CMP #$FF
		BNE .no_up_wrap
		LDA #!number_of_options-1
	.no_up_wrap:
		STA !current_selection
		JMP .finish_sound
		
	.test_down:
		LDA $0DA6 ; byetudlr frame
		AND #%00000100
		BEQ .test_left
		LDA !current_selection
		INC A
		CMP #!number_of_options
		BNE .no_down_wrap
		AND #$00
	.no_down_wrap:
		STA !current_selection
		JMP .finish_sound
		
	.test_left:
		LDA $0DA6 ; byetudlr frame
		AND #%00000010
		BNE .go_left
		LDA $0DA4 ; axlr----
		AND #%00100000
		BEQ .test_right
	.go_left:
		LDX !current_selection
		DEC !status_table,X
		LDA #$00
		JSR check_bounds
		JMP .finish_sound
		
	.test_right:
		LDA $0DA6 ; byetudlr frame
		AND #%00000001
		BNE .go_right
		LDA $0DA4 ; axlr----
		AND #%00010000
		BEQ .test_selection
	.go_right:
		LDX !current_selection
		INC !status_table,X
		LDA #$01
		JSR check_bounds
		JMP .finish_sound
		
	.test_selection:
		LDA $0DA2 ; byetudlr
		ORA $0DA4 ; axlr----
		AND #%10000000
		BEQ .test_start
		LDA !current_selection
		ASL A
		TAX
		JMP (.selection_table,X)
		
	.selection_table:
		dw .select_yellow
		dw .select_green
		dw .select_red
		dw .select_blue
		dw .select_special
		dw .select_powerup
		dw .select_itembox
		dw .select_yoshi
		dw .select_enemy
		dw .select_records
		dw .select_slots
		dw .select_fractions
		dw .select_pause
		dw .select_timedeath
		dw .select_music
		dw .select_drop
		dw .select_states
		dw .select_dynmeter
		dw .select_save
		
	.select_yoshi:
		LDA #$1F ; yoshi sound
		STA $1DFC ; apu i/o
	.select_yellow:
	.select_green:
	.select_red:
	.select_blue:
	.select_special:
	.select_powerup:
	.select_itembox:
	.select_slots:
	.select_fractions:
	.select_pause:
	.select_timedeath:
	.select_music:
	.select_drop:
	.select_dynmeter:
	.select_states:
		JMP .finish_no_sound
	.select_records:
		LDA #$24 ; "press select to confirm"
		STA $12 ; stripe image loader
		LDA !status_erase
		INC A
		STA !erase_records_flag
		LDA #$0B ; itembox sound
		STA $1DFC ; apu i/o
		JMP .finish_no_sound
	.select_enemy:
		LDA #$01 ; coin sound
		STA $1DFC ; apu i/o
		JSR reset_enemy_states
		JMP .finish_no_sound
	.select_save:
		LDA #$29 ; ding sound
		STA $1DFC ; apu i/o
		JMP .save_and_quit
	.select_cancel:
		LDA #$2A ; buzz sound
		STA $1DFC ; apu i/o
		JMP .quit
	
	.test_start:
		LDA $0DA6 ; byetudlr frame
		AND #%00010000
		BEQ .finish_no_sound
		JMP .select_save
		
	.save_and_quit:
		LDA !status_yellow
		STA $1F28 ; yellow switch
		LDA !status_green
		STA $1F27 ; green switch
		LDA !status_red
		STA $1F2A ; red switch
		LDA !status_blue
		STA $1F29 ; blue switch
		LDA !status_yoshi
		BEQ .no_yoshi_inc
		INC A
	.no_yoshi_inc:
		ASL A
		STA $13C7 ; yoshi color
		LDA #$01
		STA $0DC1 ; persistant yoshi
		LDA !status_powerup
		STA $19 ; powerup
		LDA !status_itembox
		STA $0DC2 ; itembox
	.quit:
		LDA #$0B
		STA $0100 ; game mode
		BRA .finish_no_sound
	
	.finish_sound:
		LDA #$06 ; fireball sound
		STA $1DFC ; apu i/o
		LDX $00
		JSL draw_menu_selection
		LDX !current_selection
		JSL draw_menu_selection
		
	.finish_no_sound:
		PLB
		PLP
		RTL

; check the bounds on the menu options, and fix them if they are out of bounds
; X = option index
check_bounds:
		PHP
		PHY
		LDY !status_table,X
		REP #$10
		PHY
		PHA
		LDA $0DA2 ; byetudlr
		ORA $0DA4 ; axlr----
		AND #%01000000
		BEQ .not_extended
		LDA minimum_selection_extended,X
		BRA .merge
	.not_extended:
		LDA minimum_selection_normal,X
	.merge:
		REP #$20
		AND #$00FF
		CMP $02,S
		SEP #$30
		BPL .out
		PLY
		BNE .increasing
		STA !status_table,X
		BRA .done
	.increasing:
		STZ !status_table,X
		BRA .done
	.out:
		PLY
	.done:
		PLY
		PLY
		PLY
		PLP
		RTS

; the number of options to allow when holding x or y
minimum_selection_extended:
		db $01,$01,$01,$01,$01,$FF,$FF,$FF,$00,$09,$02,$01,$01,$01,$01,$01,$01,$06,$00

; the number of options to allow when not holding x or y
minimum_selection_normal:
		db $01,$01,$01,$01,$01,$03,$04,$04,$00,$09,$02,$01,$01,$01,$01,$01,$01,$06,$00
		
; reset persistant enemy states
; right now this only includes boo cloud and boo ring angles
reset_enemy_states:
		PHP
		REP #$30
		PHX
		STZ $0FAE
		STZ $0FB0 ; boo ring angles
		
		LDX #$004E
	.loop_boo_cloud:
		STZ $1E52,X ; cluster sprite table
		STZ $190A,X ; cluster sprite table
		DEX
		DEX
		BPL .loop_boo_cloud
		
		PLX
		PLP
		RTS

; clear all the times saved in memory
; this is also run the first time you start up the game
delete_all_data:
		PHP
		REP #$30
		
		LDA #$FFFF
		LDX #$0FDE
	.loop:
		STA $700020,X
		DEX
		DEX
		BPL .loop
		
		PLP
		RTL

; clear all records from one level
; A = translevel to delete
delete_translevel_data:
		PHP
		CMP #$00 ; level 00 contains file info, so never delete it
		BEQ .done
		
		LDX #$07
	.loop:
		JSL delete_one_record
		DEX
		BPL .loop
		
	.done:		
		PLP
		RTL

; clear a record where A = translevel & X = 00000xkk, x = normal/secret, kk = kind
; restores A & X
delete_one_record:
		PHP
		PHA
		
		REP #$20
		AND #$00FF
		ASL A
		ASL A
		ASL A
		ASL A
		ASL A
		STA $00
		SEP #$20
		TXA
		ASL A
		ASL A
		TSB $00
		LDA #$70
		STA $02
		
		LDA #$FF
		LDY #$03
	.loop:
		STA [$00],Y
		DEY
		BPL .loop
		
		PLA
		PLP
		RTL
		
; function that runs if select is pressed after choosing delete data
delete_data:
		LDA #$18 ; thunder
		STA $1DFC ; apu i/o
		LDA #$27 ; "the data has been erased"
		STA $12 ; stripe image loader
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
		DEC A
		DEC A
		DEC A
		TAX
		LDA !potential_translevel
		JSL delete_one_record
		JMP .done
		
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
    db $50,$54,$00,$13
    db $19,$38,$1B,$38
    db $0E,$38,$1C,$38
    db $1C,$38,$FC,$38
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
	
    db $50,$74,$00,$13
    db $1C,$38,$0E,$38
    db $15,$38,$0E,$38
    db $0C,$38,$1D,$38
    db $FC,$38,$FC,$38
    db $FC,$38,$FC,$38
	
    db $50,$94,$00,$13
    db $1D,$38,$18,$38
    db $FC,$38,$0C,$38
    db $18,$38,$17,$38
    db $0F,$38,$12,$38
    db $1B,$38,$16,$38
	db $FF
stripe_deleted:
    db $50,$54,$00,$13
    db $1D,$38,$11,$38
    db $0E,$38,$FC,$38
    db $0D,$38,$0A,$38
    db $1D,$38,$0A,$38
    db $FC,$38,$FC,$38
	
    db $50,$74,$00,$13
    db $11,$38,$0A,$38
    db $1C,$38,$FC,$38
    db $0B,$38,$0E,$38
    db $0E,$38,$17,$38
    db $FC,$38,$FC,$38
	
    db $50,$94,$00,$13
    db $0D,$38,$0E,$38
    db $15,$38,$0E,$38
    db $1D,$38,$0E,$38
    db $0D,$38,$FC,$38
    db $FC,$38,$FC,$38
	db $FF