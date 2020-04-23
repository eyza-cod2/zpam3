main()
{
	precacheFX();
	ambientFX();
	level.scr_sound["flak88_explode"]			= "flak88_explode";
}

precacheFX()
{
	level._effect["flak_explosion"]				= loadfx("fx/explosions/flak88_explosion.efx");
	level._effect["dust_wind"]					= loadfx("fx/dust/dust_wind_eldaba.efx");
	level._effect["fogbank_small_duhoc"]		= loadfx ("fx/misc/fogbank_small_duhoc.efx");
	level._effect["thin_black_smoke_M"]			= loadfx ("fx/smoke/thin_black_smoke_M.efx");

}

ambientFX()
{
	if (level.scr_allow_ambient_fire)
		maps\mp\_fx::loopfx("thin_black_smoke_M", (266,620,280), 1, (266,620,379));

	if (level.scr_allow_ambient_weather)
	{
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (1568,2712,-47), 2, (1568,2712,52));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-1102,1725,-27), 2, (-1102,1725,72));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (567,3433,-52), 2, (567,3433,47));

		//original dust fx DO NOT DELETE
		maps\mp\_fx::loopfx("dust_wind", (-240,1574,-23), 1, (-240,1574,76));
		maps\mp\_fx::loopfx("dust_wind", (-240,1110,-23), 1, (-240,1110,76));
		maps\mp\_fx::loopfx("dust_wind", (473,966,-2), 1, (473,966,97));
		maps\mp\_fx::loopfx("dust_wind", (1546,2003,-42), 1, (1546,2003,57));
		maps\mp\_fx::loopfx("dust_wind", (1511,1078,-39), 1, (1511,1078,60));
		maps\mp\_fx::loopfx("dust_wind", (1398,349,-16), 1, (1398,349,83));
		maps\mp\_fx::loopfx("dust_wind", (935,2569,-49), 1, (935,2569,50));
		maps\mp\_fx::loopfx("dust_wind", (-228,2353,-15), 1, (-228,2353,84));
		maps\mp\_fx::loopfx("dust_wind", (470,238,2), 1, (470,238,101));
		maps\mp\_fx::loopfx("dust_wind", (362,-202,46), 1, (362,-202,145));
		maps\mp\_fx::loopfx("dust_wind", (372,-673,46), 1, (372,-673,145));
		maps\mp\_fx::loopfx("dust_wind", (-242,485,-8), 1, (-242,485,90));
	}
}
