main()
{
	precacheFX();
	ambientFX();
	level.scr_sound["flak88_explode"]			= "flak88_explode";
}

precacheFX()
{
	level._effect["flak_explosion"]				= loadfx("fx/explosions/flak88_explosion.efx");
	level._effect["dust_wind"]					= loadfx("fx/dust/dust_wind_brown.efx");
	level._effect["fogbank_small_duhoc"]		= loadfx ("fx/misc/fogbank_small_duhoc.efx");
	level._effect["smoke_plumeBG"]				= loadfx ("fx/smoke/smoke_plumeBG_toujane.efx");
}

ambientFX()
{
	if (level.scr_allow_ambient_fire)
	{
		maps\mp\_fx::loopfx("smoke_plumeBG", (8624,881,61), 1, (8624,881,71));
		maps\mp\_fx::loopfx("smoke_plumeBG", (-6206,8708,214), 1, (-6206,8708,224));
	//	maps\mp\_fx::loopfx("smoke_plumeBG", (-2234,-3032,12), 1, (-2234,-3032,22));
	}

	if (level.scr_allow_ambient_weather)
	{
		maps\mp\_fx::loopfx("dust_wind", (2027,692,21), 0.3, (2027,692,31));
		maps\mp\_fx::loopfx("dust_wind", (1365,3161,69), 0.3, (1365,3161,79));
		maps\mp\_fx::loopfx("dust_wind", (1856,2662,69), 0.3, (1856,2662,79));
		maps\mp\_fx::loopfx("dust_wind", (2250,2078,69), 0.3, (2250,2078,79));
		maps\mp\_fx::loopfx("dust_wind", (2519,1565,69), 0.3, (2519,1565,79));
		maps\mp\_fx::loopfx("dust_wind", (2434,890,69), 0.3, (2434,890,79));
		maps\mp\_fx::loopfx("dust_wind", (956,1213,-20), 0.3, (956,1213,-10));
		maps\mp\_fx::loopfx("dust_wind", (1480,587,-7), 0.3, (1480,587,2));
		maps\mp\_fx::loopfx("dust_wind", (988,520,-2), 0.3, (988,520,7));
		maps\mp\_fx::loopfx("dust_wind", (97,1566,23), 0.3, (97,1566,33));
		maps\mp\_fx::loopfx("dust_wind", (7,1042,23), 0.3, (7,1042,33));
		maps\mp\_fx::loopfx("dust_wind", (49,550,23), 0.3, (49,550,33));
		maps\mp\_fx::loopfx("dust_wind", (1548,1959,36), 0.3, (1548,1959,46));
		maps\mp\_fx::loopfx("dust_wind", (1763,1525,70), 0.3, (1763,1525,80));
		maps\mp\_fx::loopfx("dust_wind", (1304,1571,13), 0.3, (1304,1571,23));
		maps\mp\_fx::loopfx("dust_wind", (898,2122,35), 0.3, (898,2122,45));
		maps\mp\_fx::loopfx("dust_wind", (971,2615,67), 0.3, (971,2615,77));
	}
}
