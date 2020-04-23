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
	level._effect["fogbank_small_duhoc"]		= loadfx ("fx/misc/fogbank_small_duhoc.efx");
	level._effect["thin_light_smoke_M"]			= loadfx ("fx/smoke/thin_light_smoke_M.efx");
	level._effect["battlefield_smokebank_S"]		= loadfx ("fx/smoke/battlefield_smokebank_S.efx");

}

ambientFX()
{
	if (level.scr_allow_ambient_fire)
	{
		maps\mp\_fx::loopfx("thin_light_smoke_M", (854,264,142), 1, (854,264,242));
		maps\mp\_fx::loopfx("thin_light_smoke_M", (196,-1383,47), 1, (196,-1383,147));
		maps\mp\_fx::loopfx("thin_light_smoke_M", (-237,-1389,158), 1, (-237,-1389,258));
		maps\mp\_fx::loopfx("thin_light_smoke_M", (-317,4,56), 1, (-317,4,156));
		maps\mp\_fx::loopfx("thin_light_smoke_M", (144,698,78), 1, (144,698,178));
		maps\mp\_fx::loopfx("thin_light_smoke_M", (-2282,1110,-30), 1, (-2282,1110,69));
	}

	if (level.scr_allow_ambient_weather)
	{
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (-257,1154,91), 1, (-257,1154,191));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (-3502,-1477,-68), 1, (-3502,-1477,31));

		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-2218,-614,-56), 2, (-2218,-614,43));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-3140,386,-76), 2, (-3140,386,23));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-2220,1820,-38), 2, (-2220,1820,61));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-848,-2588,-38), 2, (-848,-2588,61));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-863,-1618,-38), 2, (-863,-1618,61));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-998,-894,-38), 2, (-998,-894,61));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-1157,-148,-38), 2, (-1157,-148,61));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-1134,508,-38), 2, (-1134,508,61));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-998,1051,-38), 2, (-998,1051,61));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-1722,1775,-38), 2, (-1722,1775,61));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-2178,-1683,-52), 2, (-2178,-1683,47));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-3492,-425,-69), 2, (-3492,-425,30));
	}
}
