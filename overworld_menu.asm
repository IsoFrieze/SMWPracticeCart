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
!status_music        = $0F05
!status_enemy        = $0F06
!status_cancel       = $0F07
!status_save         = $0F08
; $0F09 - $0F18 reserved for future expansion


; this code is run once on overworld menu load
ORG $188000
overworld_menu_load:
		RTL

; this code is run on every frame during the overworld menu game mode (after fade in completes)
ORG $198000
overworld_menu:
		RTL