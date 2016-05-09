!real_frames = $FD
!previous_sixty_hz = $FE
!counter_sixty_hz = $FF

ORG $178000
every_frame:
		PHP
		LDA !counter_sixty_hz
		SEC
		SBC !previous_sixty_hz
		STA !real_frames
		LDA !counter_sixty_hz
		STA !previous_sixty_hz
		PLP
		RTL