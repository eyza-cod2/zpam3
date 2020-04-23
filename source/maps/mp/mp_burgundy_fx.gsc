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
	level._effect["tank_fire_turret"] 			= loadfx ("fx/fire/tank_fire_turret_large.efx");
	level._effect["tank_fire_engine"] 			= loadfx ("fx/fire/tank_fire_engine.efx");

}

ambientFX()
{
	if (level.scr_allow_ambient_fire)
	{
		maps\mp\_fx::loopfx("tank_fire_turret", (207,306,83), 1, (207,306,93));
		maps\mp\_fx::loopfx("tank_fire_engine", (217,324,114), 1, (217,324,124));
		maps\mp\_fx::loopfx("tank_fire_engine", (139,361,82), 1, (139,361,92));
		maps\mp\_fx::loopfx("tank_fire_engine", (289,278,70), 1, (289,278,80));
		maps\mp\_fx::loopfx("tank_fire_engine", (244,394,54), 1, (244,394,64));

		//Sound FX
		maps\mp\_fx::soundfx("medfire", (201,312,100));
	}

	if (level.scr_allow_ambient_weather)
	{
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (235,1406,10), 2, (235,1406,20));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (31,877,0), 2, (31,877,10));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (1674,2014,-39), 2, (1674,2014,-29));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (1571,359,4), 2, (1571,359,14));

		// dust
		maps\mp\_fx::loopfx("dust_wind", (769,-189,40), 1, (769,-189,50));
		maps\mp\_fx::loopfx("dust_wind", (941,351,40), 1, (941,351,50));
		maps\mp\_fx::loopfx("dust_wind", (286,-26,8), 1, (286,-26,18));
		maps\mp\_fx::loopfx("dust_wind", (-1154,1517,19), 1, (-1154,1517,29));
		maps\mp\_fx::loopfx("dust_wind", (-1060,797,19), 1, (-1060,797,29));
		maps\mp\_fx::loopfx("dust_wind", (-1071,2040,19), 1, (-1071,2040,29));
		maps\mp\_fx::loopfx("dust_wind", (-402,2658,4), 1, (-402,2658,14));
		maps\mp\_fx::loopfx("dust_wind", (725,3334,16), 1, (725,3334,26));
		maps\mp\_fx::loopfx("dust_wind", (803,2819,16), 1, (803,2819,26));
		maps\mp\_fx::loopfx("dust_wind", (667,2331,16), 1, (667,2331,26));
		maps\mp\_fx::loopfx("dust_wind", (646,1728,16), 1, (646,1728,26));
		maps\mp\_fx::loopfx("dust_wind", (777,1292,16), 1, (777,1292,26));
		maps\mp\_fx::loopfx("dust_wind", (605,752,16), 1, (605,752,26));
		maps\mp\_fx::loopfx("dust_wind", (1520,1368,14), 1, (1520,1368,24));
	}
}
