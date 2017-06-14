!movie_none = $0000

ORG $1B8000

reset bytes

translevel_movie_ptr_A:
		dw !movie_none, movie_VS2_A, movie_VS3_A, movie_TSA_A
		dw movie_DGH_A, movie_DP3_A, movie_DP4_A, movie_C2_A
		dw movie_GSP_A, movie_DP2_A, movie_DS1_A, movie_VF_A
		dw movie_BB1_A, movie_BB2_A, movie_C4_A, movie_CBA_A
		dw movie_CM_A, movie_SL_A, !movie_none, movie_DSH_A
		dw movie_YSP_A, movie_DP1_A, !movie_none, !movie_none
		dw movie_SGS_A, !movie_none, movie_C6_A, movie_CF_A
		dw movie_CI5_A, movie_CI4_A, !movie_none, movie_FF_A
		dw movie_C5_A, movie_CGH_A, movie_CI1_A, movie_CI3_A
		dw movie_CI2_A, movie_C1_A, movie_YI4_A, movie_YI3_A
		dw movie_YH_A, movie_YI1_A, movie_YI2_A, movie_VGH_A
		dw !movie_none, movie_VS1_A, movie_VD3_A, movie_DS2_A
		dw !movie_none, movie_FD_A, movie_BD_A, movie_VoB4_A
		dw movie_C7_A, movie_VoBF_A, !movie_none, movie_VoB3_A
		dw movie_VoBGH_A, movie_VoB2_A, movie_VoB1_A, movie_CS_A
		dw movie_VD2_A, movie_VD4_A, movie_VD1_A, movie_RSP_A
		dw movie_C3_A, movie_FGH_A, movie_FoI1_A, movie_FoI4_A
		dw movie_FoI2_A, movie_BSP_A, movie_FSA_A, movie_FoI3_A
		dw !movie_none, movie_SP8_A, movie_SP7_A, movie_SP6_A
		dw movie_SP5_A, !movie_none, movie_SP1_A, movie_SP2_A
		dw movie_SP3_A, movie_SP4_A, !movie_none, !movie_none
		dw movie_SW2_A, !movie_none, movie_SW3_A, !movie_none
		dw movie_SW1_A, movie_SW4_A, movie_SW5_A, !movie_none
		dw !movie_none

movie_YH_A:
		incbin "bin/movies/_______.smwmovie"
movie_YI1_A:
		incbin "bin/movies/yi1_orb.smwmovie"
movie_YI2_A:
		incbin "bin/movies/_______.smwmovie"
movie_YI3_A:
		incbin "bin/movies/yi3_small.smwmovie"
movie_YI4_A:
		incbin "bin/movies/yi4_shelljump.smwmovie"
movie_YSP_A:
		incbin "bin/movies/ysp_pipefly.smwmovie"
movie_C1_A:
		incbin "bin/movies/c1_fire.smwmovie"

movie_DP1_A:
		incbin "bin/movies/dp1_nocape.smwmovie"
movie_DP2_A:
		incbin "bin/movies/dp2_secret.smwmovie"
movie_DP3_A:
		incbin "bin/movies/dp3_fire.smwmovie"
movie_DP4_A:
		incbin "bin/movies/dp4_fire.smwmovie"
movie_DS1_A:
		incbin "bin/movies/ds1_cape.smwmovie"
movie_DS2_A:
		incbin "bin/movies/ds2_cape.smwmovie"
movie_DGH_A:
		incbin "bin/movies/dgh_small.smwmovie"
movie_DSH_A:
		incbin "bin/movies/dsh_cape.smwmovie"
movie_GSP_A:
		incbin "bin/movies/gsp_pipefly.smwmovie"
movie_TSA_A:
		incbin "bin/movies/tsa_death.smwmovie"
movie_C2_A:
		incbin "bin/movies/c2_cape.smwmovie"

movie_VD1_A:
		incbin "bin/movies/vd1_cape.smwmovie"
movie_VD2_A:
		incbin "bin/movies/vd2_cape.smwmovie"
movie_VD3_A:
		incbin "bin/movies/vd3_cape.smwmovie"
movie_VD4_A:
		incbin "bin/movies/vd4_cape.smwmovie"
movie_VS1_A:
		incbin "bin/movies/vs1_cape.smwmovie"
movie_VS2_A:
		incbin "bin/movies/vs2_nocape.smwmovie"
movie_VS3_A:
		incbin "bin/movies/_______.smwmovie"
movie_VGH_A:
		incbin "bin/movies/vgh_cape.smwmovie"
movie_RSP_A:
		incbin "bin/movies/rsp_pipefly.smwmovie"
movie_VF_A:
		incbin "bin/movies/vf_cape.smwmovie"
movie_C3_A:
		incbin "bin/movies/c3_cape.smwmovie"

movie_BB1_A:
		incbin "bin/movies/_______.smwmovie"
movie_BB2_A:
		incbin "bin/movies/_______.smwmovie"
movie_CBA_A:
		incbin "bin/movies/cba_cape.smwmovie"
movie_CM_A:
		incbin "bin/movies/cm_cmbk.smwmovie"
movie_SL_A:
		incbin "bin/movies/sl_cape.smwmovie"
movie_C4_A:
		incbin "bin/movies/c4_cape.smwmovie"

movie_FoI1_A:
		incbin "bin/movies/foi1_wings.smwmovie"
movie_FoI2_A:
		incbin "bin/movies/foi2_clip.smwmovie"
movie_FoI3_A:
		incbin "bin/movies/foi3_nocape.smwmovie"
movie_FoI4_A:
		incbin "bin/movies/foi4_cape.smwmovie"
movie_FSA_A:
		incbin "bin/movies/fsa_cape.smwmovie"
movie_FGH_A:
		incbin "bin/movies/fgh_cape.smwmovie"
movie_BSP_A:
		incbin "bin/movies/bsp_pipefly.smwmovie"
movie_FF_A:
		incbin "bin/movies/ff_cape.smwmovie"
movie_C5_A:
		incbin "bin/movies/c5_cape.smwmovie"

movie_CI1_A:
		incbin "bin/movies/ci1_cape.smwmovie"
movie_CI2_A:
		incbin "bin/movies/ci2_normal.smwmovie"
movie_CI3_A:
		incbin "bin/movies/ci3_nocape.smwmovie"
movie_CI4_A:
		incbin "bin/movies/ci4_cape.smwmovie"
movie_CI5_A:
		incbin "bin/movies/ci5_cape.smwmovie"
movie_CS_A:
		incbin "bin/movies/cs_cape.smwmovie"
movie_CGH_A:
		incbin "bin/movies/cgh_cape.smwmovie"
movie_CF_A:
		incbin "bin/movies/cf_cape.smwmovie"
movie_C6_A:
		incbin "bin/movies/c6_cape.smwmovie"

movie_SGS_A:
		incbin "bin/movies/sgs_cape.smwmovie"
movie_VoB1_A:
		incbin "bin/movies/vob1_cape.smwmovie"
movie_VoB2_A:
		incbin "bin/movies/vob2_wings.smwmovie"
movie_VoB3_A:
		incbin "bin/movies/vob3_cape.smwmovie"
movie_VoB4_A:
		incbin "bin/movies/vob4_cape.smwmovie"
movie_VoBGH_A:
		incbin "bin/movies/vobgh_cape.smwmovie"
movie_VoBF_A:
		incbin "bin/movies/vobf_cape.smwmovie"
movie_C7_A:
		incbin "bin/movies/c7_cape.smwmovie"
movie_FD_A:
		incbin "bin/movies/_______.smwmovie"
movie_BD_A:
		incbin "bin/movies/bd_cape.smwmovie"

movie_SW1_A:
		incbin "bin/movies/sw1_normal.smwmovie"
movie_SW2_A:
		incbin "bin/movies/sw2_normal.smwmovie"
movie_SW3_A:
		incbin "bin/movies/sw3_cape.smwmovie"
movie_SW4_A:
		incbin "bin/movies/sw4_nocape.smwmovie"
movie_SW5_A:
		incbin "bin/movies/sw5_yyc.smwmovie"

movie_SP1_A:
		incbin "bin/movies/sp1_wings.smwmovie"
movie_SP2_A:
		incbin "bin/movies/sp2_wings.smwmovie"
movie_SP3_A:
		incbin "bin/movies/_______.smwmovie"
movie_SP4_A:
		incbin "bin/movies/_______.smwmovie"
movie_SP5_A:
		incbin "bin/movies/sp5_gbk.smwmovie"
movie_SP6_A:
		incbin "bin/movies/sp6_cape.smwmovie"
movie_SP7_A:
		incbin "bin/movies/sp7_nocape.smwmovie"
movie_SP8_A:
		incbin "bin/movies/_______.smwmovie"

print "inserted ", bytes, "/32768 bytes into bank $1B"

ORG $1C8000

reset bytes
		
translevel_movie_ptr_B:
		dw !movie_none, movie_VS2_B, movie_VS3_B, movie_TSA_B
		dw movie_DGH_B, movie_DP3_B, movie_DP4_B, movie_C2_B
		dw movie_GSP_B, movie_DP2_B, movie_DS1_B, movie_VF_B
		dw movie_BB1_B, movie_BB2_B, movie_C4_B, movie_CBA_B
		dw movie_CM_B, movie_SL_B, !movie_none, movie_DSH_B
		dw movie_YSP_B, movie_DP1_B, !movie_none, !movie_none
		dw movie_SGS_B, !movie_none, movie_C6_B, movie_CF_B
		dw movie_CI5_B, movie_CI4_B, !movie_none, movie_FF_B
		dw movie_C5_B, movie_CGH_B, movie_CI1_B, movie_CI3_B
		dw movie_CI2_B, movie_C1_B, movie_YI4_B, movie_YI3_B
		dw movie_YH_B, movie_YI1_B, movie_YI2_B, movie_VGH_B
		dw !movie_none, movie_VS1_B, movie_VD3_B, movie_DS2_B
		dw !movie_none, movie_FD_B, movie_BD_B, movie_VoB4_B
		dw movie_C7_B, movie_VoBF_B, !movie_none, movie_VoB3_B
		dw movie_VoBGH_B, movie_VoB2_B, movie_VoB1_B, movie_CS_B
		dw movie_VD2_B, movie_VD4_B, movie_VD1_B, movie_RSP_B
		dw movie_C3_B, movie_FGH_B, movie_FoI1_B, movie_FoI4_B
		dw movie_FoI2_B, movie_BSP_B, movie_FSA_B, movie_FoI3_B
		dw !movie_none, movie_SP8_B, movie_SP7_B, movie_SP6_B
		dw movie_SP5_B, !movie_none, movie_SP1_B, movie_SP2_B
		dw movie_SP3_B, movie_SP4_B, !movie_none, !movie_none
		dw movie_SW2_B, !movie_none, movie_SW3_B, !movie_none
		dw movie_SW1_B, movie_SW4_B, movie_SW5_B, !movie_none
		dw !movie_none


movie_YH_B:
		incbin "bin/movies/_______.smwmovie"
movie_YI1_B:
		incbin "bin/movies/yi1_cape.smwmovie"
movie_YI2_B:
		incbin "bin/movies/yi2_cloud.smwmovie"
movie_YI3_B:
		incbin "bin/movies/yi3_pi.smwmovie"
movie_YI4_B:
		incbin "bin/movies/_______.smwmovie"
movie_YSP_B:
		incbin "bin/movies/_______.smwmovie"
movie_C1_B:
		incbin "bin/movies/c1_small.smwmovie"

movie_DP1_B:
		incbin "bin/movies/dp1_small.smwmovie"
movie_DP2_B:
		incbin "bin/movies/_______.smwmovie"
movie_DP3_B:
		incbin "bin/movies/dp3_small.smwmovie"
movie_DP4_B:
		incbin "bin/movies/dp4_small.smwmovie"
movie_DS1_B:
		incbin "bin/movies/_______.smwmovie"
movie_DS2_B:
		incbin "bin/movies/ds2_small.smwmovie"
movie_DGH_B:
		incbin "bin/movies/dgh_secret.smwmovie"
movie_DSH_B:
		incbin "bin/movies/dsh_small.smwmovie"
movie_GSP_B:
		incbin "bin/movies/_______.smwmovie"
movie_TSA_B:
		incbin "bin/movies/_______.smwmovie"
movie_C2_B:
		incbin "bin/movies/_______.smwmovie"

movie_VD1_B:
		incbin "bin/movies/vd1_nocape.smwmovie"
movie_VD2_B:
		incbin "bin/movies/vd2_clip.smwmovie"
movie_VD3_B:
		incbin "bin/movies/vd3_nocape.smwmovie"
movie_VD4_B:
		incbin "bin/movies/vd4_small.smwmovie"
movie_VS1_B:
		incbin "bin/movies/_______.smwmovie"
movie_VS2_B:
		incbin "bin/movies/_______.smwmovie"
movie_VS3_B:
		incbin "bin/movies/_______.smwmovie"
movie_VGH_B:
		incbin "bin/movies/vgh_small.smwmovie"
movie_RSP_B:
		incbin "bin/movies/_______.smwmovie"
movie_VF_B:
		incbin "bin/movies/_______.smwmovie"
movie_C3_B:
		incbin "bin/movies/c3_nocape.smwmovie"

movie_BB1_B:
		incbin "bin/movies/bb1_nocape.smwmovie"
movie_BB2_B:
		incbin "bin/movies/_______.smwmovie"
movie_CBA_B:
		incbin "bin/movies/cba_nocape.smwmovie"
movie_CM_B:
		incbin "bin/movies/cm_cape.smwmovie"
movie_SL_B:
		incbin "bin/movies/_______.smwmovie"
movie_C4_B:
		incbin "bin/movies/c4_nocape.smwmovie"

movie_FoI1_B:
		incbin "bin/movies/foi1_nocape.smwmovie"
movie_FoI2_B:
		incbin "bin/movies/_______.smwmovie"
movie_FoI3_B:
		incbin "bin/movies/_______.smwmovie"
movie_FoI4_B:
		incbin "bin/movies/foi4_firegrab.smwmovie"
movie_FSA_B:
		incbin "bin/movies/_______.smwmovie"
movie_FGH_B:
		incbin "bin/movies/fgh_clip.smwmovie"
movie_BSP_B:
		incbin "bin/movies/_______.smwmovie"
movie_FF_B:
		incbin "bin/movies/_______.smwmovie"
movie_C5_B:
		incbin "bin/movies/c5_nocape.smwmovie"

movie_CI1_B:
		incbin "bin/movies/ci1_nocape.smwmovie"
movie_CI2_B:
		incbin "bin/movies/ci2_secret.smwmovie"
movie_CI3_B:
		incbin "bin/movies/_______.smwmovie"
movie_CI4_B:
		incbin "bin/movies/ci4_nocape.smwmovie"
movie_CI5_B:
		incbin "bin/movies/ci5_nocape.smwmovie"
movie_CS_B:
		incbin "bin/movies/cs_nocape.smwmovie"
movie_CGH_B:
		incbin "bin/movies/cgh_nocape.smwmovie"
movie_CF_B:
		incbin "bin/movies/cf_nocape.smwmovie"
movie_C6_B:
		incbin "bin/movies/_______.smwmovie"

movie_SGS_B:
		incbin "bin/movies/sgs_nocape.smwmovie"
movie_VoB1_B:
		incbin "bin/movies/vob1_nocape.smwmovie"
movie_VoB2_B:
		incbin "bin/movies/vob2_clip.smwmovie"
movie_VoB3_B:
		incbin "bin/movies/vob3_nocape.smwmovie"
movie_VoB4_B:
		incbin "bin/movies/vob4_nocape.smwmovie"
movie_VoBGH_B:
		incbin "bin/movies/vobgh_nocape.smwmovie"
movie_VoBF_B:
		incbin "bin/movies/vobf_nocape.smwmovie"
movie_C7_B:
		incbin "bin/movies/_______.smwmovie"
movie_FD_B:
		incbin "bin/movies/fd_cape.smwmovie"
movie_BD_B:
		incbin "bin/movies/_______.smwmovie"

movie_SW1_B:
		incbin "bin/movies/sw1_secret.smwmovie"
movie_SW2_B:
		incbin "bin/movies/_______.smwmovie"
movie_SW3_B:
		incbin "bin/movies/_______.smwmovie"
movie_SW4_B:
		incbin "bin/movies/_______.smwmovie"
movie_SW5_B:
		incbin "bin/movies/_______.smwmovie"

movie_SP1_B:
		incbin "bin/movies/sp1_nowings.smwmovie"
movie_SP2_B:
		incbin "bin/movies/sp2_cape.smwmovie"
movie_SP3_B:
		incbin "bin/movies/sp3_nocape.smwmovie"
movie_SP4_B:
		incbin "bin/movies/_______.smwmovie"
movie_SP5_B:
		incbin "bin/movies/sp5_cape.smwmovie"
movie_SP6_B:
		incbin "bin/movies/sp6_nocape.smwmovie"
movie_SP7_B:
		incbin "bin/movies/sp7_keepyoshi.smwmovie"
movie_SP8_B:
		incbin "bin/movies/sp8_small.smwmovie"
		
print "inserted ", bytes, "/32768 bytes into bank $1C"