main()
{
	precacheFX();
	ambientFX();
	level.scr_sound["flak88_explode"]	= "flak88_explode";
}

precacheFX()
{
	level._effect["flak_explosion"]			= loadfx("fx/explosions/flak88_explosion.efx");
	level._effect["snow_light"]				= loadfx ("fx/misc/snow_light_mp_downtown.efx");
	level._effect["snow_wind_cityhall"]		= loadfx ("fx/misc/snow_wind_cityhall.efx");
}


ambientFX()
{
	if (level.scr_allow_ambient_weather)
	{
		//world snow
		maps\mp\_fx::loopfx("snow_light", (1635,-1393,375), 0.8, (1635,-1393,475));

		//ground effects
		maps\mp\_fx::loopfx("snow_wind_cityhall", (414,-2231,32), 0.5, (414,-2231,132));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (1711,-2363,129), 0.5, (1711,-2363,229));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (3635,-1707,143), 0.5, (3635,-1707,243));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (2866,1016,13), 0.5, (2866,1016,113));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (2931,-271,9), 0.5, (2931,-271,109));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (354,124,61), 0.5, (354,124,161));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (482,-1161,3), 0.5, (482,-1161,103));
	}
}
