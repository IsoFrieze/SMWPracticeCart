!status_table        = $0EF9 ; $20 bytes
!status_yellow       = $0EF9
!status_green        = $0EFA
!status_red          = $0EFB
!status_blue         = $0EFC
!status_special      = $0EFD
!status_yoshi        = $0EFE
!status_powerup      = $0EFF
!status_itembox      = $0F00
!status_erase        = $0F01
!status_drop         = $0F02
!status_fractions    = $0F03
!status_slots        = $0F04
!status_pause        = $0F05
!status_timedeath    = $0F06
!status_music        = $0F07
!status_enemy        = $0F08
!status_exit         = $0F09
; $0F0A - $0F18 reserved for future expansion


; this code is run once on overworld menu load
ORG $188000
overworld_menu_load:
		RTL

; this code is run on every frame during the overworld menu game mode (after fade in completes)
ORG $198000
overworld_menu:
		RTL

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