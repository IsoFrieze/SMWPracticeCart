; empty/unreachable bytes overwritten:
; $00A249 - 16 / 18 bytes
; $00F9F5 - 35 / 36 bytes
; $00C578 - 10 / 13 bytes
; $00CC86 - 53 / 53 bytes
; $009510 - 18 / 25 bytes
; $00D27C -  8 / 11 bytes
; $01C062 - 17 / 19 bytes
; $01CD1E - 11 / 12 bytes
; $04FFB1 -  4 / 79 bytes

!level_loaded           = $13C8
!level_finished         = $1DEF

; run on nmi
ORG $0081AA
		JSR nmi_hijack
		NOP #2
		
ORG $009510
nmi_hijack:
		LDA #$80
		STA $2100
		JSL nmi_expand ; nmi.asm
		RTS
every_frame_hijack:
		JSR $9322
		JSL every_frame ; every_frame.asm
		RTS

; run on every frame
ORG $008072
		JSR every_frame_hijack

; run on overworld load
ORG $00A087
		JSR overworld_load_hijack
	
ORG $00A249
overworld_load_hijack:
		JSL overworld_load ; overworld_load.asm
		JSR $937D
		RTS
overworld_hijack:
		JSL overworld_tick ; overworld_tick.asm
		JSR $9A74
		RTS
		
; run every frame on overworld
ORG $00A1BE
		JSR overworld_hijack
		
; run every frame in level
ORG $00A1DA
		JSR level_hijack
		
ORG $00F9F5
level_hijack:
		JSL level_tick ; level_tick.asm
		LDA !level_loaded
		BEQ .already_loaded
		STZ !level_loaded
		JSL level_mario_appear ; level_mario_appear.asm
	.already_loaded:
		JSL test_last_frame
		LDA $1426
		RTS
level_load_hijack:
		JSL level_load ; level_load.asm
		STZ $4200 ; *
		INC !level_loaded
		RTS
		
; * This will prevent NMI during level loading.
; Eventually I will re-enable it so that we can count frames during room transitions.
		
; run on level load before fade in
ORG $0096D5
		JSR level_load_hijack
		
; test if level completed this frame
; X = 0 for normal exit, 1 for secret exit
ORG $00CC86
test_last_frame:
		LDA !level_finished
		BNE .exit
		LDX $141C
		LDA $9E
		CMP #$C5
		BNE .not_big_boo
		LDX #$01
	.not_big_boo:
		LDA $1493
		BNE .trigger
		LDA $190D
		BNE .trigger
		LDX #$01
		LDA $1434
		BNE .trigger
		LDA $1B95
		BEQ .exit
		LDA $0DD5
		BEQ .exit
		LDX #$00
		BRA .trigger
	.exit:
		RTL
		
	.trigger:
		JSL level_finish ; level_finish.asm
		RTL
		
; hijack for overworld menu game modes
ORG $009363
		dw overworld_menu_load_gm
ORG $009367
		dw overworld_menu_gm
		
; game modes for overworld menu
ORG $00C578
overworld_menu_load_gm:
		JSL overworld_menu_load ; overworld_menu.asm
		RTS
overworld_menu_gm:
		JSL overworld_menu ; overworld_menu.asm
		RTS

; run during level load, like while $17BB is available
ORG $05D7BD
		JSL level_load_exit_table
		NOP #2

; run during level load, like while X = level index into timer table
ORG $058583
		JSL level_load_timer

; run after collecting an orb, like while X = its slot number
ORG $018778
		JSL collect_orb
		NOP

; orb initialization will set flag in $1525 misc. table
ORG $018211
		dw init_orb
ORG $01C062
init_orb:
		LDA $14E0,X ; x position high byte + extra bits
		AND #%00001100
		STA $1528,X ; misc. table
		LDA $14E0,X ; x position high byte + extra bits
		AND #%00000001
		STA $14E0,X ; x position high byte
		RTS

; revamp how dropping an item from the item box works
ORG $00C56C
item_box:
		JSL drop_item_box
		CMP #$00
		db $D0,$1B ; BNE $C58F
		JMP $C585
		
; revamp how pausing works
ORG $00A22C
		JSL pause_timer
		NOP
		
; run subroutine on 0 seconds left
ORG $008E60
		JSL out_of_time
		NOP #5

; disable score sprites if sprite slot numbers are enabled
ORG $02AEA5
score_sprites:
		JSL check_score_sprites
		BEQ .not_disabled
		RTS
	.not_disabled:
		NOP #5

; draw sprite slots
ORG $0180AF
		JSR $CD1E
ORG $01CD1E
		JSR $8127
		JSL display_slot
		RTS

; upload graphics after load state
ORG $00D27C
upload_all_graphics:
		PHB
		PHK
		PLB
		JSR $A9DA
		PLB
		RTL

; faster overworld movement
ORG $048244
		JSL iterate_overworld_movement
		JMP $8261

; stripe images for overworld menu record delete
ORG $0084F4
		dl stripe_confirm
		dl stripe_deleted