main()
{
	precacheFX();
	ambientFX();
	level.scr_sound["flak88_explode"]	= "flak88_explode";
}

precacheFX()
{
	level._effect["flak_explosion"]		= loadfx("fx/explosions/flak88_explosion.efx");

	//ambient FX
	level._effect["fogbank_small_duhoc"]			= loadfx ("fx/misc/fogbank_small_duhoc.efx");
	level._effect["thin_light_smoke_L"]				= loadfx ("fx/smoke/thin_light_smoke_L.efx");
	level._effect["insects_carcass_flies"]			= loadfx ("fx/misc/insects_carcass_flies.efx");

}

ambientFX()
{
	if (level.scr_allow_ambient_weather)
	{
		maps\mp\_fx::loopfx("thin_light_smoke_L", (1817,-1474,-10), 1, (1817,-1474,89));
		maps\mp\_fx::loopfx("thin_light_smoke_L", (2365,-1832,-14), 1, (2365,-1832,85));
		maps\mp\_fx::loopfx("thin_light_smoke_L", (2860,-2869,-22), 1, (2860,-2869,77));
		maps\mp\_fx::loopfx("thin_light_smoke_L", (315,-2372,10), 1, (315,-2372,110));
		maps\mp\_fx::loopfx("thin_light_smoke_L", (-2150,-1766,-15), 1, (-2150,-1766,84));

		maps\mp\_fx::loopfx("fogbank_small_duhoc", (3350,-1762,-49), 2, (3350,-1762,49));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (3650,-188,-135), 2, (3650,-188,-36));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (3520,712,-138), 2, (3520,712,-39));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (3803,-903,-74), 2, (3803,-903,24));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (2578,436,-126), 2, (2578,436,-27));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (1567,833,-126), 2, (1567,833,-27));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (1409,1651,-114), 2, (1409,1651,-15));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (2686,1385,-168), 2, (2686,1385,-69));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (476,1542,-121), 2, (476,1542,-22));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-622,1872,-104), 2, (-622,1872,-5));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-68,1007,-126), 2, (-68,1007,-27));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-1169,588,-77), 2, (-1169,588,21));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-1658,1516,-37), 2, (-1658,1516,61));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-1949,570,-89), 2, (-1949,570,9));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-2855,1406,23), 2, (-2855,1406,122));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-2265,-706,-25), 2, (-2265,-706,73));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-1569,-1941,-35), 2, (-1569,-1941,63));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-301,-1613,-23), 2, (-301,-1613,75));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-56,-3279,6), 2, (-56,-3279,105));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-1327,-732,-7), 2, (-1327,-732,91));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (215,-811,-7), 2, (215,-811,91));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (1793,-861,-7), 2, (1793,-861,91));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (2892,-1010,-7), 2, (2892,-1010,91));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (803,-1855,-49), 2, (803,-1855,49));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (1765,-2999,8), 2, (1765,-2999,107));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (1197,-2393,5), 2, (1197,-2393,104));
	}

	//Flies
	maps\mp\_fx::loopfx("insects_carcass_flies", (2401,-2720,61), 0.3, (2401,-2720,71));
	maps\mp\_fx::loopfx("insects_carcass_flies", (1364,-2416,61), 0.3, (1364,-2416,71));
	maps\mp\_fx::loopfx("insects_carcass_flies", (1644,-3275,61), 0.3, (1644,-3275,71));
	maps\mp\_fx::loopfx("insects_carcass_flies", (-19,-3188,61), 0.3, (-19,-3188,71));
}
