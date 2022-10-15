; empty/unreachable bytes overwritten:
; $00A249 - 16 / 18 bytes
; $00F9F5 - 35 / 36 bytes
; $00C578 - 10 / 13 bytes
; $00CC86 - 53 / 53 bytes
; $009510 - 22 / 25 bytes
; $00D27C -  8 / 11 bytes
; $00CDD0 - 12 / 12 bytes
; $00FC23 - 17 / 80 bytes
; $01C062 - 17 / 19 bytes
; $01CD1E - 11 / 12 bytes
; $04FFB1 -  4 / 79 bytes
; $05DC46 - 

; run on nmi
ORG !_F+$0081AA
        JSR nmi_hijack
        NOP #2
        
ORG !_F+$009510
nmi_hijack:
        JSL nmi_expand
        RTS
every_frame_hijack:
        JSR $9322
        JSL every_frame
        RTS
temp_fade_hijack:
        JSL temp_fade_tick
        RTS
m7_boss_hijack:
        JSR $995B
        RTL

; run on every frame
ORG !_F+$008072
        JSR every_frame_hijack

; run on overworld load
ORG !_F+$00A087
        JSR overworld_load_hijack
ORG !_F+$00A192
        JSR overworld_late_load_hijack
    
ORG !_F+$00A249
overworld_load_hijack:
        JSR $937D
        JSL overworld_load
        RTS
        
; run every frame on overworld
ORG !_F+$00A1C3
        JSL overworld_tick
        
; run every frame in level
ORG !_F+$00A1DA
        JSR level_hijack
        
ORG !_F+$00F9F5
level_hijack:
        JSL level_tick
        LDA !level_loaded
        BEQ +
        STZ !level_loaded
        JSL level_mario_appear
      + JSL test_last_frame
        LDA $1426
        RTS
level_load_hijack:
        JSL level_load
        STZ $4200
        INC !level_loaded
        RTS
; run on loading graphics from save state
ORG !_F+$00CDD0
upload_3bpp_to_vram:
        JSR $AA6F
        RTL
update_layer3_tilemap:
        JSR $A01F
        RTL
gfx27_hijack:
        JSR $AB42
        RTL

; run on nintendo presents
ORG !_F+$0093C5
        JSL nintendo_presents
        NOP

; run on temporary fade game modes
ORG !_F+$009F37
        JSR temp_fade_hijack

; run on level load in between game modes
ORG !_F+$0096D5
        JSR level_load_hijack

; run when setting layer 3 y position
ORG !_F+$0082AA
        NOP #2
        JSL layer_3_y

; run when setting layer 3 priority
ORG !_F+$0081D5
        NOP
        JSL layer_3_priority

; don't draw sprite BG when sprite slots enabled
ORG !_F+$0282FA
        JSL boss_sprite_background

; run before dmaing to oam
ORG !_F+$008449
        JSL update_lagometer
        NOP
        
; test if level completed this frame
; X = 0 for normal exit, 1 for secret exit
; return 1 in A for finished, 0 for not finished
ORG !_F+$00CC68
        JMP $CCBB
test_last_frame:
        LDA !level_finished
        BNE .exit
        LDX $141C ; secret flag
        LDA $9E ; sprite id
        CMP #$C5
        BNE +
        LDX #$01
      + LDA $1493 ; end level timer
        BNE .trigger
        LDA $190D ; bowser dead
        BNE .trigger
        LDX #$01
        LDA $1434 ; keyhole timer
        BNE .trigger
        LDA $1B95 ; wings flag
        BEQ .exit
        LDA $0DD5 ; exit level flag
        CMP #$01
        BNE .exit
        LDX #$00
        BRA .trigger
    .exit:
        LDA #$00
        RTL
        
    .trigger:
        JSL level_finish
        LDA #$01
        RTL
       
; hijack drawing titlescreen
ORG !_F+$009A97
        JSL title_screen_load

; hijack temp fade exit level
ORG !_F+$00933F
        dw tmp_fade_begin_hijack
        
; hijack for overworld menu game modes
ORG !_F+$009363
        dw overworld_menu_load_gm
ORG !_F+$009367
        dw overworld_menu_gm
        
; game modes for overworld menu
ORG !_F+$00C578
overworld_menu_load_gm:
        JSL overworld_menu_load
        RTS
overworld_menu_gm:
        JSL overworld_menu
        RTS

; prepare sram for new file
; set all levels as beaten and enable all directions on all overworld tiles
ORG !_F+$009F0E
        JSL prepare_file
        LDA #$8F
        LDX #$5F
      - STA $1EA2,X
        DEX
        BPL -
        RTS

; run during level load, like while $17BB is available
ORG !_F+$05D7BD
        JSL level_load_exit_table
        NOP #2

; run during level load, like while X = level index into timer table
ORG !_F+$058583
        JSL level_load_timer

; run after collecting an orb, like while X = its slot number
ORG !_F+$018778
        JSL collect_orb
        NOP

; orb initialization will set flag in $1525 misc. table
ORG !_F+$018211
        dw init_orb
ORG !_F+$01C062
init_orb:
        LDA $14E0,X ; x position high byte + extra bits
        AND #%00001100
        STA $1528,X ; misc. table
        LDA $14E0,X ; x position high byte + extra bits
        AND #%00000001
        STA $14E0,X ; x position high byte
        RTS

; revamp how dropping an item from the item box works
ORG !_F+$00C56C
item_box:
        JSL drop_item_box
        CMP #$00
        BNE $1B ; BNE $C58F
        JMP $C585
        
; revamp how pausing works
ORG !_F+$00A21B
        JSL test_pause
ORG !_F+$00A22C
        JSL pause_timer
        NOP
        
; run subroutine on 99 and 0 seconds left
ORG !_F+$008E4C
        JSL hurry_up
        JSL out_of_time
        JMP $8E69

; load proper number of igt frames depending on region
ORG !_F+$008D8A
        JSL reset_igt_frames
        NOP
ORG !_F+$008E2D
        JSL reset_igt_frames
        NOP

; disable score sprites if sprite slot numbers are enabled
ORG !_F+$02AEA5
score_sprites:
        JSL check_score_sprites
        BEQ +
        RTS
      + NOP #5
        
; draw dynmeter & replay star
ORG !_F+$01809E
        JSL display_dynmeter
        NOP #2

; draw bounce sprites
ORG !_F+$029040
        JSR bounce_hijack
ORG !_F+$02B628
bounce_hijack:
        JSR $904D
        JSL display_bounce_slot
        RTS

; draw sprite slots
ORG !_F+$0180AF
        JSR sprite_hijack
ORG !_F+$01CD1E
sprite_hijack:
        JSR $8127
        JSL display_slot
        RTS

; upload graphics after load state
ORG !_F+$00D27C
upload_all_graphics:
        PHB
        PHK
        PLB
        JSR $A9DA
        PLB
        RTL

; prevent entering level on first 2 frames of overworld
ORG !_F+$04919F
        JSL test_main_enter_level

; faster overworld movement
ORG !_F+$048244
        JSL iterate_overworld_movement
        JMP $8261

; stripe images for overworld menu record delete
ORG !_F+$0084F4
        dl stripe_confirm
        dl stripe_deleted

; fix reznor/iggy/larry graphics upload
ORG !_F+$00AB4A
        JSL fix_iggy_larry_graphics
        NOP #2

; allow both controllers 1 and 2 to control mario at any time
ORG !_F+$008650
        JSL controller_update
        RTS

; run at the very start of the game, to make sure the option save data is not corrupt
ORG !_F+$00940F
        JSR check_option_bounds_hijack

; run at the very start of level load
ORG !_F+$00968E
        JSR begin_loading_level
        
; run at the very end of level load
ORG !_F+$0093F4
        JSR conclude_loading_level

; COP & BRK vectors
ORG !_F+$00FFE4
        dw #break_wrapper,#break_wrapper

; clear the controller registers so we can tsb them
ORG !_F+$00FC23
empty_controller_regs:
        JSL play_input
        STZ $15
        STZ $16
        STZ $17
        STZ $18
        RTL
begin_loading_level:
        JSL latch_apu
        JSR $85FA
        RTS
conclude_loading_level:
        LDA $0100
        CMP #$12
        BEQ +
        CMP #$13
        BNE ++
      + JSL do_final_loading
     ++ INC $0100
        RTS
break_wrapper:
        JSL break
        BCS +
        LDA.L !save_state_exists
        BEQ .forever
        JSL activate_load_state
      + RTI
    .forever:
        BRA .forever
; tick the timer and co. for one frame after exiting the level with wings
; this is because the game exits out of this state abruptly
tmp_fade_begin_hijack:
        JSL test_last_frame
        BEQ +
        JSL level_tick
      + JMP $9F6F
; run on overworld load, after everything else has loaded already
overworld_late_load_hijack:
        JSL late_overworld_load
        JMP $93F4
check_option_bounds_hijack:
        JSL failsafe_check_option_bounds
        DEC $1DF5
        RTS

; 'fix' PI with this convoluted hijack
ORG !_F+$01F203
        JSL fix_powerup_incrementation
        NOP #2
        
; 'fix' item swap
ORG !_F+$01C550
        JSL fix_item_swap_bug

; on goal tape trigger
ORG !_F+$00FA89
        JSL goal_tape_trigger
        NOP #2

;;;;;;;;;;;;; REGION DIFFERENCES ;;;;;;;;;;;;;

; ldadDolphin
ORG !_F+$07F7C1
        JSL load_tweaker_1686

; level layer 1 load
ORG !_F+$05D8C2
        JSL load_level_layer1_ptr
        JMP $D8D1

; level sprite load
ORG !_F+$05D8EB
        JSL load_level_sprite_ptr
        JMP $D8F9
        
; load different title screen controller input depending on region
; return differently depending on carry flag
ORG !_F+$009C6F
        JSL title_screen_input
        BCC +
        RTS
      + JMP $9C9C

; play running out sfx for pswitch, coin snake, star
ORG !_F+$00C54F
        JSL check_pswitch_runout
        NOP #2
ORG !_F+$00E2E3
        JSL check_star_runout
        
; physics regarding grabbing yoshi wings
ORG !_F+$00C80F
        JSL grab_yoshi_wings_phsyics
        NOP
        
; physics regarding mario holding out arms
ORG !_F+$00D014
        JSL mario_holding_out_arms
        NOP #2
        
; physics regarding mario's running animation
ORG !_F+$00CFFB
        JSL get_animation_frame
ORG !_F+$00CEF8
        JSL get_animation_frame
        
; physics regarding wall triangle
ORG !_F+$00EAEE
        JSL calc_wall_triangle_y
        NOP #3
ORG !_F+$00F037
        JSL calc_wall_triangle_x
        NOP #3
ORG !_F+$00F015
        JSL wall_triangle_in_block
        NOP #4

; physics
ORG !_F+$00D6F4
        JSL physics_hijack_1
        NOP #8
ORG !_F+$00D742
        JSL physics_hijack_2
        BCS phy_hijack_a
        BRA phy_hijack_b
ORG !_F+$00D772
        JSL physics_hijack_3
        BCS phy_hijack_b
        BRA phy_hijack_c
    ORG !_F+$00D76B
        phy_hijack_a:
    ORG !_F+$00D7A0
        phy_hijack_b:
    ORG !_F+$00D7A2
        phy_hijack_c:
ORG !_F+$00D66A
        JSL physics_hijack_4
        NOP
ORG !_F+$00D71C
        JSL physics_hijack_5
        NOP #5
ORG !_F+$00D811
        JMP physics_hijack_6_pre
ORG !_F+$00963D
        RTS
physics_hijack_6_pre:
        JML physics_hijack_6b
ORG !_F+$00D87E
        JSL physics_hijack_6
        NOP #2
ORG !_F+$00D96A
        JSL physics_hijack_7
        RTS
ORG !_F+$00DC4F
        JSL physics_hijack_8
        RTS
ORG !_F+$00EF1F
        JSL physics_hijack_9
        NOP #5
        
; physics regarding kicked and spat shells
ORG !_F+$01A090
        JSL set_shell_speed_lda
        NOP
ORG !_F+$01A0A0
        JSL set_shell_speed_adc
        NOP #2
ORG !_F+$01AAAC
        JSL set_shell_speed_lda
        NOP

; count rng index
ORG !_F+$01ACFC
        JSL count_rng_index

; roulette item speed
ORG !_F+$01C31C
        JSL set_roulette_speed
        NOP #7

; brown swinging platforms
ORG !_F+$01CA79
        JSL pal_brown_swinging_platform
        JMP $CA9B
        
; big castle crusher
ORG !_F+$02D429
        JSL pal_castle_crusher_1
        NOP
ORG !_F+$02D44A
        JSL pal_castle_crusher_2
ORG !_F+$02D458
        JSL pal_castle_crusher_3
        JMP $D465
ORG !_F+$02D489
        JSL pal_castle_crusher_4
ORG !_F+$02D496
        JSL pal_castle_crusher_5
        NOP
        
; shaking dorito spike
ORG !_F+$03925C
        JSL pal_shaking_dorito
        NOP
        
; bowser
ORG !_F+$009A37
        JSL pal_boss_1
        BNE pal_boss_a
    ORG !_F+$009A4D
            pal_boss_a:
ORG !_F+$00994F
        JSL pal_boss_2
ORG !_F+$03A450
        JSL pal_bowser_1
ORG !_F+$03A47C
        JSL pal_bowser_2
        NOP
ORG !_F+$03AB79
        JSL pal_bowser_3
ORG !_F+$03ABB4
        JSL pal_bowser_4
        NOP
ORG !_F+$03ABE0
        JSL pal_bowser_4
        NOP
ORG !_F+$03ABEB
        JSL pal_bowser_5
        BCC pal_bowser_b
        BNE pal_bowser_a
    ORG !_F+$03ABF8
            pal_bowser_a:
    ORG !_F+$03AC02
            pal_bowser_b:
ORG !_F+$03B193
        JSL pal_bowser_6
        BCC pal_bowser_c
        NOP #2
    ORG !_F+$03B1C5
            pal_bowser_c:
ORG !_F+$03B4BF
        JSL pal_bowser_7
        NOP
ORG !_F+$03B503
        JSL pal_bowser_8
ORG !_F+$03B53D
        JSL pal_bowser_8
        
; layer 2 scrolling
ORG !_F+$05C871
        JSL pal_l2_1
ORG !_F+$05C9B1
        JSL pal_l2_2
        NOP #2
ORG !_F+$05BF42
        JSL pal_l2_3
ORG !_F+$05C5ED
        JSL pal_l2_4