ORG $1A8000

; this code is run when the player presses L + R in a level to reset the current room
activate_room_reset:
		; if we are in first room of level, just level reset
		LDA $141A ; sublevel count
		AND #$7F
		BNE .room_reset
		JSL activate_level_reset
		RTL
		
	.room_reset:
		LDA #$01
		STA !l_r_function
		
		LDA !recent_screen_exit
		LDY !recent_secondary_flag
		JSL set_global_exit
		JSR trigger_screen_exit
		
		RTL

; this code is run when the player presses L + R + A + B in a level to reset the entire level
activate_level_reset:
		LDA #$02
		STA !l_r_function
		
		JSR get_level_low_byte
		LDY #$00
		JSL set_global_exit
		JSR trigger_screen_exit
		
		RTL

; this code is run when the player presses L + R + X + Y in a level to advance to the next room
activate_room_advance:
		LDA #$03
		STA !l_r_function
		
		; X = level bank
		LDX #$00
		LDA $13BF ; translevel number
		CMP #$25
		BCC .low_level_bank
		INX
	.low_level_bank:
		
		LDA $141A ; sublevel count
		AND #$7F
		BNE .load_from_backup
		
		; we just entered the level, so backup may not be available
		; we know we entered via screen exit, not from secondary exit
		JSR get_level_low_byte
		LDY #$00
		BRA .merge
	.load_from_backup:
		; we are in some sublevel, so backup is available
		LDA !recent_screen_exit
		LDY !recent_secondary_flag
	
	.merge:
		JSR get_next_sensible_exit
		JSL set_global_exit
		JSR trigger_screen_exit
		
		RTL

; set the screen exit for all screens to be set to the exit number in A
; Y = 1 iff this exit is a secondary exit
set_global_exit:
		LDX #$20
	.loop_exits:
		DEX
		STA $19B8,X ; exit table
		BNE .loop_exits
		STY $1B93 ; secondary exit flag
		RTL

; get the low byte of the level number, not the translevel number
get_level_low_byte:
		LDA $13BF ; translevel number
		CMP #$25
		BCC .done
		SEC
		SBC #$24
	.done:
		RTS

; actually trigger the screen exit
trigger_screen_exit:
		LDA #$05
		STA $71 ; player animation trigger
		STZ $88
		STZ $89 ; pipe timers
		
		LDA #$20 ; bow sound
		STA $1DF9 ; apu i/o
		RTS

; given the current sub/level, return a sub/level that 'advances' one room forward
; given A = level number low byte, X = level number high byte, Y = secondary exit flag
; return A = level number low byte / secondary exit number, Y = secondary exit flag
get_next_sensible_exit:
		PHP
		PHB
		PHK
		PLB
		CPX #$00
		BEQ .low_bank
		TAX
		CPY #$00
		BEQ .high_level_number
		LDA room_advance_table+$000,X
		LDY room_advance_table+$100,X
		BRA .done
	.high_level_number:
		LDA room_advance_table+$200,X
		LDY room_advance_table+$300,X
		BRA .done
		
	.low_bank:
		TAX
		CPY #$00
		BEQ .low_level_number
		LDA room_advance_table+$400,X
		LDY room_advance_table+$500,X
		BRA .done
	.low_level_number:
		LDA room_advance_table+$600,X
		LDY room_advance_table+$700,X
		
	.done:
		PLB
		PLP
		RTS
		
room_advance_table:
		; =======================================
		; This bin file contains 8 tables that hold screen exit data to be used
		; by the advance room function. Each table is 0x100 bytes long.
		; Table 1: exit number to take if last exit was a secondary exit, bank 1
		; Table 2: secondary exit flag for above table number
		; Table 3: exit number to take if last exit was a level exit, bank 1
		; Table 4: secondary exit flag for above table number
		; Table 5: exit number to take if last exit was a secondary exit, bank 0
		; Table 6: secondary exit flag for above table number
		; Table 7: exit number to take if last exit was a level exit, bank 0
		; Table 8: secondary exit flag for above table number
		incbin "bin/room_advance_table.bin"
		; =======================================
		
; this code is run when the player presses R + select to make a save state
activate_save_state:
		PHP
		LDA.L !disallow_save_states
		BEQ .save_allowed
		RTL
	.save_allowed:
		LDA #$0E ; swim sound
		STA $1DF9 ; apu i/o
		
		LDA #$80
		STA $2100 ; force blank
		STZ $4200 ; nmi disable
		
		REP #$10
		
		; save wram $0000-$1FFF to $701000-$702FFF
		LDX #$1FFF
	.loop_mirror:
		LDA $7E0000,X
		STA $701000,X
		DEX
		BPL .loop_mirror
		
		; save wram $C680-$C6DF to $703000-$70305F
		LDX #$005F
	.loop_boss:
		LDA $7EC680,X
		STA $703000,X
		DEX
		BPL .loop_boss
		
		; save wram $7F9A7B-$7F9C7A to $703060-$70325F
		LDX #$01FF
	.loop_wiggler:
		LDA $7F9A7B,X
		STA $703060,X
		DEX
		BPL .loop_wiggler
		
		; save wram $C800-$FFFF to $703260-$706A5F
		LDX #$37FF
	.loop_tilemap_low:
		LDA $7EC800,X
		STA $703260,X
		DEX
		BPL .loop_tilemap_low
		
		; save wram $7FC800-$7FFFFF to $710000-$7137FF
		LDX #$37FF
	.loop_tilemap_high:
		LDA $7FC800,X
		STA $710000,X
		DEX
		BPL .loop_tilemap_high
		
		; save cgram w$00-w$FF to $713800-$713AFF
		LDX #$0000
		STX $2121 ; cgram address
		LDX #$3800
		STX $4302 ; dma0 destination address
		LDA #$71
		STA $4304 ; dma0 destination bank
		LDX #$0200
		STX $4305 ; dma0 length
		LDA #$80 ; 1-byte
		STA $4300 ; dma0 parameters
		LDA #$3B ; $213B cgram data read
		STA $4301 ; dma0 source
		LDA #$01 ; channel 0
		STA $420B ; dma enable
		
		; save vram w$0000-w$3FFF to $720000-$727FFF
		LDA #$80
		STA $2115 ; vram increment
		LDX #$0000
		STX $2116 ; vram address
		LDX $2139 ; vram data read (dummy read)
		LDX #$0000
		STX $4302 ; dma0 destination address
		LDA #$72
		STA $4304 ; dma0 destination bank
		LDX #$8000
		STX $4305 ; dma0 length
		LDA #$81 ; 2-byte, low-high
		STA $4300 ; dma0 parameters
		LDA #$39 ; $2139 vram data read
		STA $4301 ; dma0 source
		LDA #$01 ; channel 0
		STA $420B ; dma enable
		
		; save vram w$4000-w$7FFF to $730000-$737FFF
		LDA #$80
		STA $2115 ; vram increment
		LDX #$4000
		STX $2116 ; vram address
		LDX $2139 ; vram data read (dummy read)
		LDX #$0000
		STX $4302 ; dma0 destination address
		LDA #$73
		STA $4304 ; dma0 destination bank
		LDX #$8000
		STX $4305 ; dma0 length
		LDA #$81 ; 2-byte, low-high
		STA $4300 ; dma0 parameters
		LDA #$39 ; $2139 vram data read
		STA $4301 ; dma0 source
		LDA #$01 ; channel 0
		STA $420B ; dma enable
		
		LDA #$81
		STA $4200 ; nmi enable
		LDA #$0F
		STA $2100 ; exit force blank
		
		LDA #$01
		STA.L !spliced_run
		LDA #$BD
		STA.L !save_state_exists
		PLP
		RTL

; this code is run when the player presses L + select to load a save state
activate_load_state:
		PHP
		LDA.L !disallow_save_states
		BEQ .save_allowed
		RTL
	.save_allowed:
		LDA #$80
		STA $2100 ; force blank
		STZ $4200 ; nmi disable
		
		REP #$10
		
		; load $701000-$702FFF to wram $0000-$1FFF
		LDX #$1FFF
	.loop_mirror:
		LDA $701000,X
		STA $7E0000,X
		DEX
		BPL .loop_mirror
		
		; load $703000-$70305F to wram $C680-$C6DF
		LDX #$005F
	.loop_boss:
		LDA $703000,X
		STA $7EC680,X
		DEX
		BPL .loop_boss
		
		; load $703060-$70325F to wram $7F9A7B-$7F9C7A
		LDX #$01FF
	.loop_wiggler:
		LDA $703060,X
		STA $7F9A7B,X
		DEX
		BPL .loop_wiggler
		
		; load $703260-$706A5F to save wram $C800-$FFFF
		LDX #$37FF
	.loop_tilemap_low:
		LDA $703260,X
		STA $7EC800,X
		DEX
		BPL .loop_tilemap_low
		
		; load $710000-$7137FF to wram $7FC800-$7FFFFF
		LDX #$37FF
	.loop_tilemap_high:
		LDA $710000,X
		STA $7FC800,X
		DEX
		BPL .loop_tilemap_high
		
		; load $713800-$713AFF to cgram w$00-w$FF
		LDX #$0000
		STX $2121 ; cgram address
		LDX #$3800
		STX $4302 ; dma0 destination address
		LDA #$71
		STA $4304 ; dma0 destination bank
		LDX #$0200
		STX $4305 ; dma0 length
		STZ $4300 ; dma0 parameters
		LDA #$22 ; $2122 cgram data write
		STA $4301 ; dma0 source
		LDA #$01 ; channel 0
		STA $420B ; dma enable
		
		; load $720000-$727FFF to vram w$0000-w$3FFF
		LDA #$80
		STA $2115 ; vram increment
		LDX #$0000
		STX $2116 ; vram address
		LDX #$0000
		STX $4302 ; dma0 destination address
		LDA #$72
		STA $4304 ; dma0 destination bank
		LDX #$8000
		STX $4305 ; dma0 length
		LDA #$01 ; 2-byte, low-high
		STA $4300 ; dma0 parameters
		LDA #$18 ; $2118 vram data write
		STA $4301 ; dma0 source
		LDA #$01 ; channel 0
		STA $420B ; dma enable
		
		; load $730000-$737FFF to vram w$4000-w$7FFF
		LDA #$80
		STA $2115 ; vram increment
		LDX #$4000
		STX $2116 ; vram address
		LDX #$0000
		STX $4302 ; dma0 destination address
		LDA #$73
		STA $4304 ; dma0 destination bank
		LDX #$8000
		STX $4305 ; dma0 length
		LDA #$01 ; 2-byte, low-high
		STA $4300 ; dma0 parameters
		LDA #$18 ; $2118 vram data write
		STA $4301 ; dma0 source
		LDA #$01 ; channel 0
		STA $420B ; dma enable
		
		LDA #$81
		STA $4200 ; nmi enable
		LDA #$0F
		STA $2100 ; exit force blank
		PLP
		RTL