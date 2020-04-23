main()
{
	precacheFX();
	ambientFX();
	level.scr_sound["flak88_explode"]	= "flak88_explode";
}

precacheFX()
{
	level._effect["flak_explosion"]		= loadfx("fx/explosions/flak88_explosion.efx");
	level._effect["dust_wind"]			= loadfx ("fx/dust/dust_wind_brown_thick.efx");

}

ambientFX()
{
	if (level.scr_allow_ambient_weather)
	{
		//original dust fx DO NOT DELETE
		maps\mp\_fx::loopfx("dust_wind", (2693,5237,-7), 3, (2693,5237,2));
		maps\mp\_fx::loopfx("dust_wind", (2758,6086,-7), 3, (2758,6086,2));
		maps\mp\_fx::loopfx("dust_wind", (3225,5742,-7), 3, (3225,5742,2));
		maps\mp\_fx::loopfx("dust_wind", (3007,7063,11), 3, (3007,7063,21));
		maps\mp\_fx::loopfx("dust_wind", (3700,8032,33), 3, (3700,8032,43));
		maps\mp\_fx::loopfx("dust_wind", (4310,7680,33), 3, (4310,7680,43));
		maps\mp\_fx::loopfx("dust_wind", (4318,6863,9), 3, (4318,6863,19));
		maps\mp\_fx::loopfx("dust_wind", (4323,6232,9), 3, (4323,6232,19));
		maps\mp\_fx::loopfx("dust_wind", (5695,7583,9), 3, (5695,7583,19));
		maps\mp\_fx::loopfx("dust_wind", (5485,6965,9), 3, (5485,6965,19));
		maps\mp\_fx::loopfx("dust_wind", (5387,6282,-54), 3, (5387,6282,-44));
		maps\mp\_fx::loopfx("dust_wind", (4888,5676,9), 3, (4888,5676,19));
		maps\mp\_fx::loopfx("dust_wind", (4878,5168,15), 3, (4878,5168,25));
		maps\mp\_fx::loopfx("dust_wind", (4875,4523,15), 3, (4875,4523,25));
		maps\mp\_fx::loopfx("dust_wind", (6537,6190,-17), 3, (6537,6190,-7));
	}
}
