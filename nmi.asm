!dropped_frames    = $FB ; 2 bytes, 16-bit value
!real_frames       = $FD
!previous_sixty_hz = $FE
!counter_sixty_hz  = $FF

ORG $168000

; this code is run on every NMI; therefore, it is guaranteed to run 60 times per second, even if the game is lagging
nmi_expand:
		INC !counter_sixty_hz
		RTL