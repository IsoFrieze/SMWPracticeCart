!invalidate_record = $0F19

ORG $1A8000

; this code is run when the player presses L + R in a level to reset the current room
activate_room_reset:
		LDA #$01
		STA !invalidate_record
		RTL

; this code is run when the player presses L + R + A + B in a level to reset the entire level
activate_level_reset:
		STZ !invalidate_record
		RTL

; this code is run when the player presses L + R + X + Y in a level to advance to the next room
activate_room_advance:
		LDA #$01
		STA !invalidate_record
		RTL