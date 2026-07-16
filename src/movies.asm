!movie_list_none = $0000

ORG !_F+$1B8000

reset bytes

translevel_movie_ptrs_head:
		dw !movie_list_none, movie_list_VS2, movie_list_VS3, movie_list_TSA
		dw movie_list_DGH, movie_list_DP3, movie_list_DP4, movie_list_C2
		dw movie_list_GSP, movie_list_DP2, movie_list_DS1, movie_list_VF
		dw movie_list_BB1, movie_list_BB2, movie_list_C4, movie_list_CBA
		dw movie_list_CM, movie_list_SL, !movie_list_none, movie_list_DSH
		dw movie_list_YSP, movie_list_DP1, !movie_list_none, !movie_list_none
		dw movie_list_SGS, !movie_list_none, movie_list_C6, movie_list_CF
		dw movie_list_CI5, movie_list_CI4, !movie_list_none, movie_list_FF
		dw movie_list_C5, movie_list_CGH, movie_list_CI1, movie_list_CI3
		dw movie_list_CI2, movie_list_C1, movie_list_YI4, movie_list_YI3
		dw movie_list_YH, movie_list_YI1, movie_list_YI2, movie_list_VGH
		dw !movie_list_none, movie_list_VS1, movie_list_VD3, movie_list_DS2
		dw !movie_list_none, movie_list_FD, movie_list_BD, movie_list_VoB4
		dw movie_list_C7, movie_list_VoBF, !movie_list_none, movie_list_VoB3
		dw movie_list_VoBGH, movie_list_VoB2, movie_list_VoB1, movie_list_CS
		dw movie_list_VD2, movie_list_VD4, movie_list_VD1, movie_list_RSP
		dw movie_list_C3, movie_list_FGH, movie_list_FoI1, movie_list_FoI4
		dw movie_list_FoI2, movie_list_BSP, movie_list_FSA, movie_list_FoI3
		dw !movie_list_none, movie_list_SP8, movie_list_SP7, movie_list_SP6
		dw movie_list_SP5, !movie_list_none, movie_list_SP1, movie_list_SP2
		dw movie_list_SP3, movie_list_SP4, !movie_list_none, !movie_list_none
		dw movie_list_SW2, !movie_list_none, movie_list_SW3, !movie_list_none
		dw movie_list_SW1, movie_list_SW4, movie_list_SW5, !movie_list_none
		dw !movie_list_none

translevel_movie_ptrs_count:
		db 0, 2, 2, 2
		db 2, 2, 2, 2
		db 2, 2, 2, 2
		db 2, 2, 2, 2
		db 2, 2, 0, 2
		db 2, 2, 0, 0
		db 2, 0, 2, 2
		db 2, 2, 0, 2
		db 2, 2, 2, 2
		db 2, 2, 2, 2
		db 2, 2, 2, 2
		db 0, 2, 2, 2
		db 0, 2, 2, 2
		db 2, 2, 0, 2
		db 2, 2, 2, 2
		db 2, 2, 2, 2
		db 2, 2, 2, 2
		db 2, 2, 2, 2
		db 0, 2, 2, 2
		db 2, 0, 2, 2
		db 2, 2, 0, 0
		db 2, 0, 2, 0
		db 2, 2, 2, 0
		db 0
        
movie_list_YH:
        dl movie_YH_A, movie_YH_B
movie_list_YI1:
        dl movie_YI1_A, movie_YI1_B
movie_list_YI2:
        dl movie_YI2_A, movie_YI2_B
movie_list_YI3:
        dl movie_YI3_A, movie_YI3_B
movie_list_YI4:
        dl movie_YI4_A, movie_YI4_B
movie_list_YSP:
        dl movie_YSP_A, movie_YSP_B
movie_list_C1:
        dl movie_C1_A, movie_C1_B
movie_list_DP1:
        dl movie_DP1_A, movie_DP1_B
movie_list_DP2:
        dl movie_DP2_A, movie_DP2_B
movie_list_DP3:
        dl movie_DP3_A, movie_DP3_B
movie_list_DP4:
        dl movie_DP4_A, movie_DP4_B
movie_list_DS1:
        dl movie_DS1_A, movie_DS1_B
movie_list_DS2:
        dl movie_DS2_A, movie_DS2_B
movie_list_DGH:
        dl movie_DGH_A, movie_DGH_B
movie_list_DSH:
        dl movie_DSH_A, movie_DSH_B
movie_list_GSP:
        dl movie_GSP_A, movie_GSP_B
movie_list_TSA:
        dl movie_TSA_A, movie_TSA_B
movie_list_C2:
        dl movie_C2_A, movie_C2_B
movie_list_VD1:
        dl movie_VD1_A, movie_VD1_B
movie_list_VD2:
        dl movie_VD2_A, movie_VD2_B
movie_list_VD3:
        dl movie_VD3_A, movie_VD3_B
movie_list_VD4:
        dl movie_VD4_A, movie_VD4_B
movie_list_VS1:
        dl movie_VS1_A, movie_VS1_B
movie_list_VS2:
        dl movie_VS2_A, movie_VS2_B
movie_list_VS3:
        dl movie_VS3_A, movie_VS3_B
movie_list_VGH:
        dl movie_VGH_A, movie_VGH_B
movie_list_RSP:
        dl movie_RSP_A, movie_RSP_B
movie_list_VF:
        dl movie_VF_A, movie_VF_B
movie_list_C3:
        dl movie_C3_A, movie_C3_B
movie_list_BB1:
        dl movie_BB1_A, movie_BB1_B
movie_list_BB2:
        dl movie_BB2_A, movie_BB2_B
movie_list_CBA:
        dl movie_CBA_A, movie_CBA_B
movie_list_CM:
        dl movie_CM_A, movie_CM_B
movie_list_SL:
        dl movie_SL_A, movie_SL_B
movie_list_C4:
        dl movie_C4_A, movie_C4_B
movie_list_FoI1:
        dl movie_FoI1_A, movie_FoI1_B
movie_list_FoI2:
        dl movie_FoI2_A, movie_FoI2_B
movie_list_FoI3:
        dl movie_FoI3_A, movie_FoI3_B
movie_list_FoI4:
        dl movie_FoI4_A, movie_FoI4_B
movie_list_FSA:
        dl movie_FSA_A, movie_FSA_B
movie_list_FGH:
        dl movie_FGH_A, movie_FGH_B
movie_list_BSP:
        dl movie_BSP_A, movie_BSP_B
movie_list_FF:
        dl movie_FF_A, movie_FF_B
movie_list_C5:
        dl movie_C5_A, movie_C5_B
movie_list_CI1:
        dl movie_CI1_A, movie_CI1_B
movie_list_CI2:
        dl movie_CI2_A, movie_CI2_B
movie_list_CI3:
        dl movie_CI3_A, movie_CI3_B
movie_list_CI4:
        dl movie_CI4_A, movie_CI4_B
movie_list_CI5:
        dl movie_CI5_A, movie_CI5_B
movie_list_CS:
        dl movie_CS_A, movie_CS_B
movie_list_CGH:
        dl movie_CGH_A, movie_CGH_B
movie_list_CF:
        dl movie_CF_A, movie_CF_B
movie_list_C6:
        dl movie_C6_A, movie_C6_B
movie_list_SGS:
        dl movie_SGS_A, movie_SGS_B
movie_list_VoB1:
        dl movie_VoB1_A, movie_VoB1_B
movie_list_VoB2:
        dl movie_VoB2_A, movie_VoB2_B
movie_list_VoB3:
        dl movie_VoB3_A, movie_VoB3_B
movie_list_VoB4:
        dl movie_VoB4_A, movie_VoB4_B
movie_list_VoBGH:
        dl movie_VoBGH_A, movie_VoBGH_B
movie_list_VoBF:
        dl movie_VoBF_A, movie_VoBF_B
movie_list_C7:
        dl movie_C7_A, movie_C7_B
movie_list_FD:
        dl movie_FD_A, movie_FD_B
movie_list_BD:
        dl movie_BD_A, movie_BD_B
movie_list_SW1:
        dl movie_SW1_A, movie_SW1_B
movie_list_SW2:
        dl movie_SW2_A, movie_SW2_B
movie_list_SW3:
        dl movie_SW3_A, movie_SW3_B
movie_list_SW4:
        dl movie_SW4_A, movie_SW4_B
movie_list_SW5:
        dl movie_SW5_A, movie_SW5_B
movie_list_SP1:
        dl movie_SP1_A, movie_SP1_B
movie_list_SP2:
        dl movie_SP2_A, movie_SP2_B
movie_list_SP3:
        dl movie_SP3_A, movie_SP3_B
movie_list_SP4:
        dl movie_SP4_A, movie_SP4_B
movie_list_SP5:
        dl movie_SP5_A, movie_SP5_B
movie_list_SP6:
        dl movie_SP6_A, movie_SP6_B
movie_list_SP7:
        dl movie_SP7_A, movie_SP7_B
movie_list_SP8:
        dl movie_SP8_A, movie_SP8_B

movie_YH_A:
        db "YH MESSAGE BOX MEME "
		incbin "bin/movies/yh_messagebox.smwmovie"
movie_YH_B:
        db "YH EXTRA EXIT ORB   "
		incbin "bin/movies/yh_orb.smwmovie"
movie_YI1_A:
        db "YI1 COLLECT ORB     "
		incbin "bin/movies/yi1_orb.smwmovie"
movie_YI1_B:
        db "YI1 WITH CAPE       "
		incbin "bin/movies/yi1_cape.smwmovie"
movie_YI2_A:
        db "YI2 SMALL MARIO     "
		incbin "bin/movies/yi2_small.smwmovie"
movie_YI2_B:
        db "YI2 GET CLOUD       "
		incbin "bin/movies/yi2_cloud.smwmovie"
movie_YI3_A:
        db "YI3 SMALL MARIO     "
		incbin "bin/movies/yi3_small.smwmovie"
movie_YI3_B:
        db "YI3 POWERUP INC     "
		incbin "bin/movies/yi3_pi.smwmovie"
movie_YI4_A:
        db "YI4 SHELLJUMP       "
		incbin "bin/movies/yi4_shelljump.smwmovie"
movie_YI4_B:
        db "YI4 WITH YOSHI      "
		incbin "bin/movies/yi4_yoshi.smwmovie"
movie_YSP_A:
        db "YSP PIPE FLY        "
		incbin "bin/movies/ysp_pipefly.smwmovie"
movie_YSP_B:
        db "YSP SMALL MARIO     "
		incbin "bin/movies/ysp_small.smwmovie"
movie_C1_A:
        db "C1 GET FIRE         "
		incbin "bin/movies/c1_fire.smwmovie"
movie_C1_B:
        db "C1 SMALL MARIO      "
		incbin "bin/movies/c1_small.smwmovie"

movie_DP1_A:
        db "DP1 NO CAPE SECRET  "
		incbin "bin/movies/dp1_nocape.smwmovie"
movie_DP1_B:
        db "DP1 SMALL SECRET    "
		incbin "bin/movies/dp1_small.smwmovie"
movie_DP2_A:
        db "DP2 CAPE SECRET     "
		incbin "bin/movies/dp2_secret.smwmovie"
movie_DP2_B:
        db "DP2 SMALL NORMAL    "
		incbin "bin/movies/dp2_small.smwmovie"
movie_DP3_A:
        db "DP3 FIRE MARIO      "
		incbin "bin/movies/dp3_fire.smwmovie"
movie_DP3_B:
        db "DP3 SMALL MARIO     "
		incbin "bin/movies/dp3_small.smwmovie"
movie_DP4_A:
        db "DP4 FIRE MARIO      "
		incbin "bin/movies/dp4_fire.smwmovie"
movie_DP4_B:
        db "DP4 SMALL MARIO     "
		incbin "bin/movies/dp4_small.smwmovie"
movie_DS1_A:
        db "DS1 CAPE SECRET     "
		incbin "bin/movies/ds1_cape.smwmovie"
movie_DS1_B:
        db "DS1 SMALL NORMAL    "
		incbin "bin/movies/ds1_small.smwmovie"
movie_DS2_A:
        db "DS2 CAPE MARIO      "
		incbin "bin/movies/ds2_cape.smwmovie"
movie_DS2_B:
        db "DS2 SMALL MARIO     "
		incbin "bin/movies/ds2_small.smwmovie"
movie_DGH_A:
        db "DGH SMALL NORMAL    "
		incbin "bin/movies/dgh_small.smwmovie"
movie_DGH_B:
        db "DGH CAPE SECRET     "
		incbin "bin/movies/dgh_secret.smwmovie"
movie_DSH_A:
        db "DSH CAPE SECRET     "
		incbin "bin/movies/dsh_cape.smwmovie"
movie_DSH_B:
        db "DSH SMALL NORMAL    "
		incbin "bin/movies/dsh_small.smwmovie"
movie_GSP_A:
        db "GSP PIPE FLY        "
		incbin "bin/movies/gsp_pipefly.smwmovie"
movie_GSP_B:
        db "GSP SMALL MARIO     "
		incbin "bin/movies/gsp_small.smwmovie"
movie_TSA_A:
        db "TSA COLLECT ORB     "
		incbin "bin/movies/tsa_orb.smwmovie"
movie_TSA_B:
        db "TSA MARIO DIES      "
		incbin "bin/movies/tsa_death.smwmovie"
movie_C2_A:
        db "C2 CAPE MARIO       "
		incbin "bin/movies/c2_cape.smwmovie"
movie_C2_B:
        db "C2 FIRE MARIO       "
		incbin "bin/movies/c2_nocape.smwmovie"

movie_VD1_A:
        db "VD1 CAPE WINGS      "
		incbin "bin/movies/vd1_cape.smwmovie"
movie_VD1_B:
        db "VD1 CAPELESS WINGS  "
		incbin "bin/movies/vd1_nocape.smwmovie"
movie_VD2_A:
        db "VD2 CAPE NORMAL     "
		incbin "bin/movies/vd2_cape.smwmovie"
movie_VD2_B:
        db "VD2 YOSHI CLIP      "
		incbin "bin/movies/vd2_clip.smwmovie"
movie_VD3_A:
        db "VD3 CAPE RAFT SKIP  "
		incbin "bin/movies/vd3_cape.smwmovie"
movie_VD3_B:
        db "VD3 NO CAPE         "
		incbin "bin/movies/vd3_nocape.smwmovie"
movie_VD4_A:
        db "VD4 CAPE MARIO      "
		incbin "bin/movies/vd4_cape.smwmovie"
movie_VD4_B:
        db "VD4 SMALL MARIO     "
		incbin "bin/movies/vd4_small.smwmovie"
movie_VS1_A:
        db "VS1 CAPE NORMAL     "
		incbin "bin/movies/vs1_cape.smwmovie"
movie_VS1_B:
        db "VS1 CAPELESS NORMAL "
		incbin "bin/movies/vs1_nocape.smwmovie"
movie_VS2_A:
        db "VS2 FIRE MARIO      "
		incbin "bin/movies/vs2_nocape.smwmovie"
movie_VS2_B:
        db "VS2 GRAB EXTRA FIRE "
		incbin "bin/movies/vs2_fire.smwmovie"
movie_VS3_A:
        db "VS3 FIRE MARIO      "
		incbin "bin/movies/vs3_nocape.smwmovie"
movie_VS3_B:
        db "VS3 DRAGON COINS    "
		incbin "bin/movies/vs3_ld.smwmovie"
movie_VGH_A:
        db "VGH CAPE MARIO      "
		incbin "bin/movies/vgh_cape.smwmovie"
movie_VGH_B:
        db "VGH SMALL MARIO     "
		incbin "bin/movies/vgh_small.smwmovie"
movie_RSP_A:
        db "RSP CAPE PIPE FLY   "
		incbin "bin/movies/rsp_pipefly.smwmovie"
movie_RSP_B:
        db "RSP SMALL MARIO     "
		incbin "bin/movies/rsp_small.smwmovie"
movie_VF_A:
        db "VF CAPE MARIO       "
		incbin "bin/movies/vf_cape.smwmovie"
movie_VF_B:
        db "VF SMALL MARIO      "
		incbin "bin/movies/vf_small.smwmovie"
movie_C3_A:
        db "C3 CAPE MARIO       "
		incbin "bin/movies/c3_cape.smwmovie"
movie_C3_B:
        db "C3 FIRE MARIO       "
		incbin "bin/movies/c3_nocape.smwmovie"

movie_BB1_A:
        db "BB1 CAPE MARIO      "
		incbin "bin/movies/bb1_cape.smwmovie"
movie_BB1_B:
        db "BB1 FIRE MARIO      "
		incbin "bin/movies/bb1_nocape.smwmovie"
movie_BB2_A:
        db "BB2 FIRE MARIO      "
		incbin "bin/movies/bb2_nocape.smwmovie"
movie_BB2_B:
        db "BB2 SMALL MARIO     "
		incbin "bin/movies/bb2_small.smwmovie"
movie_CBA_A:
        db "CBA CAPE MARIO      "
		incbin "bin/movies/cba_cape.smwmovie"
movie_CBA_B:
        db "CBA FIRE MARIO      "
		incbin "bin/movies/cba_nocape.smwmovie"
movie_CM_A:
        db "CM CAPE MARIO       "
		incbin "bin/movies/cm_cape.smwmovie"
movie_CM_B:
        db "CM BOSS KILL        "
		incbin "bin/movies/cm_cmbk.smwmovie"
movie_SL_A:
        db "SL CAPE MARIO       "
		incbin "bin/movies/sl_cape.smwmovie"
movie_SL_B:
        db "SL DRAGON COINS     "
		incbin "bin/movies/sl_ld.smwmovie"
movie_C4_A:
        db "C4 CAPE MARIO       "
		incbin "bin/movies/c4_cape.smwmovie"
movie_C4_B:
        db "C4 FIRE MARIO       "
		incbin "bin/movies/c4_nocape.smwmovie"

print "inserted ", bytes, "/32768 bytes into bank $1B"

ORG !_F+$1C8000

reset bytes

movie_FoI1_A:
        db "FOI1 CAPE WINGS     "
		incbin "bin/movies/foi1_wings.smwmovie"
movie_FoI1_B:
        db "FOI1 FIRE NORMAL    "
		incbin "bin/movies/foi1_nocape.smwmovie"
movie_FoI2_A:
        db "FOI2 YOSHI CLIP     "
		incbin "bin/movies/foi2_clip.smwmovie"
movie_FoI2_B:
        db "FOI2 SMALL MARIO    "
		incbin "bin/movies/foi2_small.smwmovie"
movie_FoI3_A:
        db "FOI3 FIRE MARIO     "
		incbin "bin/movies/foi3_nocape.smwmovie"
movie_FoI3_B:
        db "FOI3 DRAGON COINS   "
		incbin "bin/movies/foi3_ld.smwmovie"
movie_FoI4_A:
        db "FOI4 CAPE SECRET    "
		incbin "bin/movies/foi4_cape.smwmovie"
movie_FoI4_B:
        db "FOI4 COLLECT FIRE   "
		incbin "bin/movies/foi4_firegrab.smwmovie"
movie_FSA_A:
        db "FSA CAPE MARIO      "
		incbin "bin/movies/fsa_cape.smwmovie"
movie_FSA_B:
        db "FSA SMALL MARIO     "
		incbin "bin/movies/fsa_small.smwmovie"
movie_FGH_A:
        db "FGH CAPE NORMAL     "
		incbin "bin/movies/fgh_cape.smwmovie"
movie_FGH_B:
        db "FGH CORNER CLIP     "
		incbin "bin/movies/fgh_clip.smwmovie"
movie_BSP_A:
        db "BSP CAPE PIPE FLY   "
		incbin "bin/movies/bsp_pipefly.smwmovie"
movie_BSP_B:
        db "BSP SMALL MARIO     "
		incbin "bin/movies/bsp_small.smwmovie"
movie_FF_A:
        db "FF CAPE MARIO       "
		incbin "bin/movies/ff_cape.smwmovie"
movie_FF_B:
        db "FF FIRE MARIO       "
		incbin "bin/movies/ff_nocape.smwmovie"
movie_C5_A:
        db "C5 CAPE MARIO       "
		incbin "bin/movies/c5_cape.smwmovie"
movie_C5_B:
        db "C5 FIRE MARIO       "
		incbin "bin/movies/c5_nocape.smwmovie"

movie_CI1_A:
        db "CI1 CAPE MARIO      "
		incbin "bin/movies/ci1_cape.smwmovie"
movie_CI1_B:
        db "CI1 FIRE MARIO      "
		incbin "bin/movies/ci1_nocape.smwmovie"
movie_CI2_A:
        db "CI2 CAPE NORMAL     "
		incbin "bin/movies/ci2_normal.smwmovie"
movie_CI2_B:
        db "CI2 CAPE SECRET     "
		incbin "bin/movies/ci2_secret.smwmovie"
movie_CI3_A:
        db "CI3 FIRE NORMAL     "
		incbin "bin/movies/ci3_nocape.smwmovie"
movie_CI3_B:
        db "CI3 SMALL SECRET    "
		incbin "bin/movies/ci3_small.smwmovie"
movie_CI4_A:
        db "CI4 CAPE MARIO      "
		incbin "bin/movies/ci4_cape.smwmovie"
movie_CI4_B:
        db "CI4 CAPELESS MARIO  "
		incbin "bin/movies/ci4_nocape.smwmovie"
movie_CI5_A:
        db "CI5 CAPE MARIO      "
		incbin "bin/movies/ci5_cape.smwmovie"
movie_CI5_B:
        db "CI5 CAPELESS MARIO  "
		incbin "bin/movies/ci5_nocape.smwmovie"
movie_CS_A:
        db "CS CAPE MARIO       "
		incbin "bin/movies/cs_cape.smwmovie"
movie_CS_B:
        db "CS SMALL MARIO      "
		incbin "bin/movies/cs_nocape.smwmovie"
movie_CGH_A:
        db "CGH CAPE MARIO      "
		incbin "bin/movies/cgh_cape.smwmovie"
movie_CGH_B:
        db "CGH FIRE MARIO      "
		incbin "bin/movies/cgh_nocape.smwmovie"
movie_CF_A:
        db "CF CAPE MARIO       "
		incbin "bin/movies/cf_cape.smwmovie"
movie_CF_B:
        db "CF SMALL MARIO      "
		incbin "bin/movies/cf_nocape.smwmovie"
movie_C6_A:
        db "C6 CAPE MARIO       "
		incbin "bin/movies/c6_cape.smwmovie"
movie_C6_B:
        db "C6 SMALL MARIO      "
		incbin "bin/movies/c6_nocape.smwmovie"

movie_SGS_A:
        db "SGS CAPE MARIO      "
		incbin "bin/movies/sgs_cape.smwmovie"
movie_SGS_B:
        db "SGS SMALL MARIO     "
		incbin "bin/movies/sgs_nocape.smwmovie"
movie_VoB1_A:
        db "VOB1 CAPE MARIO     "
		incbin "bin/movies/vob1_cape.smwmovie"
movie_VoB1_B:
        db "VOB1 SMALL MARIO    "
		incbin "bin/movies/vob1_nocape.smwmovie"
movie_VoB2_A:
        db "VOB2 CAPE WINGS     "
		incbin "bin/movies/vob2_wings.smwmovie"
movie_VoB2_B:
        db "VOB2 SANDBAR CLIP   "
		incbin "bin/movies/vob2_clip.smwmovie"
movie_VoB3_A:
        db "VOB3 CAPE MARIO     "
		incbin "bin/movies/vob3_cape.smwmovie"
movie_VoB3_B:
        db "VOB3 FIRE MARIO     "
		incbin "bin/movies/vob3_nocape.smwmovie"
movie_VoB4_A:
        db "VOB4 CAPE MARIO     "
		incbin "bin/movies/vob4_cape.smwmovie"
movie_VoB4_B:
        db "VOB4 FIRE MARIO     "
		incbin "bin/movies/vob4_nocape.smwmovie"
movie_VoBGH_A:
        db "VOBGH CAPE SECRET   "
		incbin "bin/movies/vobgh_cape.smwmovie"
movie_VoBGH_B:
        db "VOBGH NO CAPE SECRET"
		incbin "bin/movies/vobgh_nocape.smwmovie"
movie_VoBF_A:
        db "VOBF CAPE MARIO     "
		incbin "bin/movies/vobf_cape.smwmovie"
movie_VoBF_B:
        db "VOBF SMALL MARIO    "
		incbin "bin/movies/vobf_nocape.smwmovie"
movie_C7_A:
        db "C7 CAPE MARIO       "
		incbin "bin/movies/c7_cape.smwmovie"
movie_C7_B:
        db "C7 SMALL MARIO      "
		incbin "bin/movies/c7_small.smwmovie"
movie_FD_A:
        db "FD CLOUD BOWSER     "
		incbin "bin/movies/fd_cloud.smwmovie"
movie_FD_B:
        db "FD CAPE MARIO       "
		incbin "bin/movies/fd_cape.smwmovie"
movie_BD_A:
        db "BD CAPE KILL        "
		incbin "bin/movies/bd_cape.smwmovie"
movie_BD_B:
        db "BD SMALL MARIO      "
		incbin "bin/movies/bd_small.smwmovie"

movie_SW1_A:
        db "SW1 CAPE NORMAL     "
		incbin "bin/movies/sw1_normal.smwmovie"
movie_SW1_B:
        db "SW1 CAPE SECRET     "
		incbin "bin/movies/sw1_secret.smwmovie"
movie_SW2_A:
        db "SW2 CAPE NORMAL     "
		incbin "bin/movies/sw2_normal.smwmovie"
movie_SW2_B:
        db "SW2 CAPE SECRET     "
		incbin "bin/movies/sw2_secret.smwmovie"
movie_SW3_A:
        db "SW3 CAPE SECRET     "
		incbin "bin/movies/sw3_cape.smwmovie"
movie_SW3_B:
        db "SW3 FIRE SECRET     "
		incbin "bin/movies/sw3_nocape.smwmovie"
movie_SW4_A:
        db "SW4 FIRE SECRET     "
		incbin "bin/movies/sw4_nocape.smwmovie"
movie_SW4_B:
        db "SW4 SMALL SECRET    "
		incbin "bin/movies/sw4_small.smwmovie"
movie_SW5_A:
        db "SW5 CAPE SECRET     "
		incbin "bin/movies/sw5_yyc.smwmovie"
movie_SW5_B:
        db "SW5 SMALL SECRET    "
		incbin "bin/movies/sw5_small.smwmovie"

movie_SP1_A:
        db "GNARLY CAPE WINGS   "
		incbin "bin/movies/sp1_wings.smwmovie"
movie_SP1_B:
        db "GNARLY CAPE MARIO   "
		incbin "bin/movies/sp1_nowings.smwmovie"
movie_SP2_A:
        db "TUBULAR CAPE WINGS  "
		incbin "bin/movies/sp2_wings.smwmovie"
movie_SP2_B:
        db "TUBULAR CAPE MARIO  "
		incbin "bin/movies/sp2_cape.smwmovie"
movie_SP3_A:
        db "WAY COOL CAPE MARIO "
		incbin "bin/movies/sp3_cape.smwmovie"
movie_SP3_B:
        db "WAY COOL NO CAPE    "
		incbin "bin/movies/sp3_nocape.smwmovie"
movie_SP4_A:
        db "AWESOME GET FLOWER  "
		incbin "bin/movies/sp4_flower.smwmovie"
movie_SP4_B:
        db "AWESOME SMALL MARIO "
		incbin "bin/movies/sp4_small.smwmovie"
movie_SP5_A:
        db "GROOVY CAPE MARIO   "
		incbin "bin/movies/sp5_cape.smwmovie"
movie_SP5_B:
        db "GROOVY BOSS KILL    "
		incbin "bin/movies/sp5_gbk.smwmovie"
movie_SP6_A:
        db "MONDO CAPE MARIO    "
		incbin "bin/movies/sp6_cape.smwmovie"
movie_SP6_B:
        db "MONDO FIRE MARIO    "
		incbin "bin/movies/sp6_nocape.smwmovie"
movie_SP7_A:
        db "OUTRAGEOUS CAPE     "
		incbin "bin/movies/sp7_nocape.smwmovie"
movie_SP7_B:
        db "OUTRAGEOUS KEEP YOSH"
		incbin "bin/movies/sp7_keepyoshi.smwmovie"
movie_SP8_A:
        db "FUNKY SMALL MARIO   "
		incbin "bin/movies/sp8_small.smwmovie"
movie_SP8_B:
        db "FUNKY SECRET EXIT   "
		incbin "bin/movies/sp8_secret.smwmovie"
		
print "inserted ", bytes, "/32768 bytes into bank $1C"
