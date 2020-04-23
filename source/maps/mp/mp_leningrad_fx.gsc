main()
{
	precacheFX();
	ambientFX();
	level.scr_sound["flak88_explode"]	= "flak88_explode";
}

precacheFX()
{
	level._effect["flak_explosion"]				= loadfx("fx/explosions/flak88_explosion.efx");
	level._effect["building_fire_large"]		= loadfx ("fx/fire/building_fire_large.efx");
	level._effect["building_fire_small"]		= loadfx ("fx/fire/building_fire_small.efx");
	level._effect["thin_black_smoke_M"]			= loadfx ("fx/smoke/thin_black_smoke_M.efx");
	level._effect["snow_light"]					= loadfx ("fx/misc/snow_light_mp_downtown.efx");
	level._effect["snow_wind_cityhall"]			= loadfx ("fx/misc/snow_wind_cityhall.efx");
}


ambientFX()
{
	if (level.scr_allow_ambient_fire)
	{
		//Ambient fx
		maps\mp\_fx::loopfx("building_fire_large", (-2236,1405,362), 1, (-2137,1396,369));
		maps\mp\_fx::loopfx("thin_black_smoke_M", (1444,-893,517), 2, (1444,-893,532));
		maps\mp\_fx::loopfx("thin_black_smoke_M", (1680,1468,484), 1, (1680,1468,498));
		maps\mp\_fx::loopfx("building_fire_large", (-1355,-1509,599), 2, (-1355,-1509,610));
		maps\mp\_fx::loopfx("building_fire_large", (1371,-738,506), 2, (1371,-738,517));
		maps\mp\_fx::loopfx("thin_black_smoke_M", (-2211,1574,540), 2, (-2211,1574,550));
		maps\mp\_fx::loopfx("thin_black_smoke_M", (-1599,1828,585), 1, (-1599,1828,595));
		maps\mp\_fx::loopfx("thin_black_smoke_M", (-630,-958,71), 2, (-657,-955,168));

		//Sound FX
		maps\mp\_fx::soundfx("bigfire", (1384,-746,-575));
		maps\mp\_fx::soundfx("bigfire", (-1352,-1494,656));
		maps\mp\_fx::soundfx("bigfire", (-2236,1405,362));
	}

	if (level.scr_allow_ambient_weather)
	{
		//world snow
		maps\mp\_fx::loopfx("snow_light", (-75,-208,232), 0.6, (-75,-208,332));
	}
}
