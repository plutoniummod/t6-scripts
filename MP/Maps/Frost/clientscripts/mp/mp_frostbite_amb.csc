// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "frostbite_outdoor", 1 );
    setambientroomreverb( "frostbite_outdoor", "frostbite_outdoor", 1, 1 );
    setambientroomcontext( "frostbite_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "frostbite_coffee" );
    setambientroomtone( "frostbite_coffee", "amb_interior_2d", 0.55, 1 );
    setambientroomreverb( "frostbite_coffee", "frostbite_smallroom", 1, 1 );
    setambientroomcontext( "frostbite_coffee", "ringoff_plr", "indoor" );
    declareambientroom( "frostbite_stairs" );
    setambientroomreverb( "frostbite_stairs", "frostbite_hallroom", 1, 1 );
    setambientroomcontext( "frostbite_stairs", "ringoff_plr", "outdoor" );
    declareambientroom( "frostbite_bridge_overhang" );
    setambientroomreverb( "frostbite_bridge_overhang", "frostbite_partialroom", 1, 1 );
    setambientroomcontext( "frostbite_bridge_overhang", "ringoff_plr", "outdoor" );
    declareambientroom( "frostbite_small_house" );
    setambientroomtone( "frostbite_small_house", "amb_interior_2d", 0.55, 1 );
    setambientroomreverb( "frostbite_small_house", "frostbite_smallroom", 1, 1 );
    setambientroomcontext( "frostbite_small_house", "ringoff_plr", "indoor" );
    declareambientroom( "frostbite_wood_house" );
    setambientroomtone( "frostbite_wood_house", "amb_interior_2d", 0.55, 1 );
    setambientroomreverb( "frostbite_wood_house", "frostbite_smallroom", 1, 1 );
    setambientroomcontext( "frostbite_wood_house", "ringoff_plr", "indoor" );
    declareambientroom( "frostbite_watch_house" );
    setambientroomtone( "frostbite_watch_house", "amb_interior_2d", 0.55, 1 );
    setambientroomreverb( "frostbite_watch_house", "frostbite_smallroom", 1, 1 );
    setambientroomcontext( "frostbite_watch_house", "ringoff_plr", "indoor" );
    declareambientroom( "frostbite_tunnel" );
    setambientroomreverb( "frostbite_tunnel", "frostbite_stoneroom", 1, 1 );
    setambientroomcontext( "frostbite_tunnel", "ringoff_plr", "indoor" );
    declareambientroom( "frostbite_bar_sml" );
    setambientroomtone( "frostbite_bar_sml", "amb_interior_2d", 0.55, 1 );
    setambientroomreverb( "frostbite_bar_sml", "frostbite_smallroom", 1, 1 );
    setambientroomcontext( "frostbite_bar_sml", "ringoff_plr", "indoor" );
    declareambientroom( "frostbite_bar_med" );
    setambientroomtone( "frostbite_bar_med", "amb_interior_2d", 0.55, 1 );
    setambientroomreverb( "frostbite_bar_med", "frostbite_mediumroom", 1, 1 );
    setambientroomcontext( "frostbite_bar_med", "ringoff_plr", "indoor" );
    declareambientroom( "frostbite_candy_med" );
    setambientroomtone( "frostbite_candy_med", "amb_interior_2d", 0.55, 1 );
    setambientroomreverb( "frostbite_candy_med", "frostbite_mediumroom", 1, 1 );
    setambientroomcontext( "frostbite_candy_med", "ringoff_plr", "indoor" );
    declareambientroom( "frostbite_candy_sml" );
    setambientroomtone( "frostbite_candy_sml", "amb_interior_2d", 0.55, 1 );
    setambientroomreverb( "frostbite_candy_sml", "frostbite_smallroom", 1, 1 );
    setambientroomcontext( "frostbite_candy_sml", "ringoff_plr", "indoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
}

snd_start_autofx_audio()
{
    snd_play_auto_fx( "fx_mp_frostbite_lamp_post", "amb_street_lights", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_downhill_gust_window", "amb_snow_wind_lp", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_frostbite_snow_flurries", "amb_snow_wind_lp", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_frostbite_circle_light_glare", "amb_inside_lights_sml", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_frostbite_circle_light_glare_flr", "amb_inside_lights_sml", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_frostbite_lamp_int", "amb_bar_light", 0, 0, 0, 0 );
}

snd_play_loopers()
{
    playloopat( "amb_tree_wind", ( 753, 1335, 331 ) );
    playloopat( "amb_sewer_drain", ( 1468, 905, -4 ) );
    playloopat( "amb_sewer_drain", ( -1543, -150, 62 ) );
    playloopat( "amb_tree_wind", ( 753, 1335, 331 ) );
    playloopat( "amb_tree_wind", ( 574, 1693, 299 ) );
    playloopat( "amb_tree_wind", ( 1611, 1278, 471 ) );
    playloopat( "amb_tree_wind", ( 2400, 929, 488 ) );
    playloopat( "amb_tree_wind", ( 1725, 605, 483 ) );
    playloopat( "amb_tree_wind", ( 1820, -391, 434 ) );
    playloopat( "amb_tree_wind", ( 2776, -283, 375 ) );
    playloopat( "amb_tree_wind", ( 910, 78, 417 ) );
    playloopat( "amb_tree_wind", ( 1523, 49, 227 ) );
    playloopat( "amb_tree_wind", ( -1708, -291, 337 ) );
    playloopat( "amb_tree_wind", ( -1165, -538, 328 ) );
    playloopat( "amb_tree_wind", ( -1498, -1451, 245 ) );
    playloopat( "amb_tree_wind", ( -1197, -1469, 225 ) );
    playloopat( "amb_tree_wind", ( -150, -1456, 268 ) );
    playloopat( "amb_tree_wind", ( 142, -1457, 234 ) );
    playloopat( "amb_tree_wind", ( 1578, -948, 321 ) );
    playloopat( "amb_tree_wind", ( 2216, -789, 435 ) );
    playloopat( "amb_tree_wind", ( -1701, 679, 315 ) );
    playloopat( "amb_wind_mill", ( -809, 1429, 562 ) );
    playloopat( "amb_fridge_hum", ( 2158, -264, 82 ) );
    playloopat( "amb_neon_sign", ( -1031, -1044, 122 ) );
    playloopat( "amb_neon_sign", ( -2185, -132, 198 ) );
    playloopat( "amb_neon_sign", ( -1898, 210, 199 ) );
    playloopat( "amb_neon_sign", ( -949, 521, 180 ) );
    playloopat( "amb_neon_sign", ( -635, 320, 182 ) );
    playloopat( "amb_neon_sign", ( 620, 412, 208 ) );
    playloopat( "amb_neon_sign", ( -461, -1016, 176 ) );
    playloopat( "amb_neon_sign", ( -444, -524, 208 ) );
    playloopat( "amb_clock_tick", ( 1085, 705, 175 ) );
    playloopat( "amb_clock_tick", ( 2158, -253, 139 ) );
    playloopat( "amb_clock_tick", ( -2370, 147, 176 ) );
    playloopat( "amb_clock_tick", ( -401, -206, 172 ) );
    playloopat( "amb_clock_tick", ( 581, 146, 172 ) );
    playloopat( "amb_curtain_flap", ( 1026, 538, 154 ) );
    playloopat( "amb_curtain_flap", ( 2084, 49, 89 ) );
    playloopat( "amb_curtain_flap", ( 1996, -350, 130 ) );
    playloopat( "amb_curtain_flap", ( 473, 783, 132 ) );
    playloopat( "amb_curtain_flap", ( 501, 991, 133 ) );
    playloopat( "amb_fireplace", ( 466, 668, 95 ) );
    playloopat( "amb_outside_heater", ( -146, 855, 20 ) );
    playloopat( "amb_house_radiator_hum", ( 585, 534, 82 ) );
    playloopat( "amb_house_radiator_hum", ( 1027, 534, 78 ) );
    playloopat( "amb_house_radiator_hum", ( 2185, -432, 51 ) );
    playloopat( "amb_house_radiator_hum", ( 349, 257, 100 ) );
    playloopat( "amb_house_radiator_hum", ( -171, -342, 99 ) );
    playloopat( "amb_house_radiator_hum", ( 433, 502, 95 ) );
    playloopat( "amb_house_radiator_hum", ( 2365, -7, 50 ) );
    playloopat( "amb_dryer", ( 1104, 674, 86 ) );
    playloopat( "amb_dryer", ( 1104, 636, 86 ) );
    playloopat( "amb_flag_flap", ( -1274, 378, 199 ) );
    playloopat( "amb_flag_flap", ( -1035, 382, 197 ) );
    playloopat( "amb_flag_flap", ( -1179, 692, 210 ) );
    playloopat( "amb_flag_flap", ( -1178, 815, 207 ) );
    playloopat( "amb_flag_flap", ( -1178, 937, 207 ) );
    playloopat( "amb_flag_flap", ( -242, 1054, 177 ) );
    playloopat( "amb_flag_flap", ( -376, 1056, 174 ) );
}
