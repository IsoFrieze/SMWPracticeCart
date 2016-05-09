!real_frames = $FD
!previous_sixty_hz = $FE
!counter_sixty_hz = $FF

ORG $168000
vblank_expand:
		INC !counter_sixty_hz
		RTL