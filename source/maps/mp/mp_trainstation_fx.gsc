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
	level._effect["thin_black_smoke_S"]				= loadfx ("fx/smoke/thin_black_smoke_S.efx");
	level._effect["thin_black_smoke_M"]				= loadfx ("fx/smoke/thin_black_smoke_M.efx");
	level._effect["thin_light_smoke_L"]				= loadfx ("fx/smoke/thin_light_smoke_L.efx");
	level._effect["thin_light_smoke_M"]				= loadfx ("fx/smoke/thin_light_smoke_M.efx");
	level._effect["battlefield_smokebank_S"]		= loadfx ("fx/smoke/battlefield_smokebank_S.efx");
	level._effect["tank_fire_turret"] 				= loadfx ("fx/fire/tank_fire_turret_small.efx");
	level._effect["tank_fire_turret_large"] 		= loadfx ("fx/fire/tank_fire_turret_large.efx");
	level._effect["tank_fire_engine"] 				= loadfx ("fx/fire/tank_fire_engine.efx");
	level._effect["building_fire_small"]			= loadfx ("fx/fire/building_fire_small.efx");


}

ambientFX()
{
	if (level.scr_allow_ambient_fire)
	{
		maps\mp\_fx::loopfx("thin_light_smoke_M", (3537,-3753,-4), 1, (3537,-3753,95));
		maps\mp\_fx::loopfx("thin_black_smoke_M", (6754,-2441,405), 0.8, (6754,-2441,505));
		maps\mp\_fx::loopfx("building_fire_small", (4294,-3288,169), 2, (4284,-3387,169));
		maps\mp\_fx::loopfx("thin_black_smoke_M", (4168,-3115,301), 0.8, (4168,-3115,401));
		maps\mp\_fx::loopfx("thin_black_smoke_M", (4168,-3115,301), 0.8, (4168,-3115,401));

		maps\mp\_fx::loopfx("thin_light_smoke_M", (4807,-3306,0), 1, (4807,-3306,99));
		maps\mp\_fx::loopfx("thin_light_smoke_M", (7495,-3321,-53), 1, (7495,-3321,46));
		maps\mp\_fx::loopfx("thin_light_smoke_M", (7662,-2473,-67), 1, (7662,-2473,32));
		maps\mp\_fx::loopfx("thin_light_smoke_M", (6849,-4013,6), 1, (6849,-4013,106));

		maps\mp\_fx::loopfx("thin_black_smoke_M", (6901,-3773,261), 0.8, (6901,-3773,361));
	//	maps\mp\_fx::loopfx("tank_fire_engine", (6356,-2068,47), 1, (6356,-2068,147));
		maps\mp\_fx::loopfx("tank_fire_turret", (6380,-4174,20), 2, (6380,-4174,120));
	//	maps\mp\_fx::loopfx("tank_fire_turret_large", (6456,-2043,63), 2, (6449,-2023,161));
		maps\mp\_fx::loopfx("tank_fire_engine", (4176,-3262,285), 1, (4176,-3262,385));
		maps\mp\_fx::loopfx("tank_fire_engine", (4194,-4207,62), 1, (4194,-4207,162));
		maps\mp\_fx::loopfx("tank_fire_engine", (4300,-4086,46), 1, (4300,-4086,146));

		maps\mp\_fx::loopfx("tank_fire_engine", (4234,-4131,94), 1, (4234,-4131,194));
		maps\mp\_fx::loopfx("tank_fire_engine", (7721,-4353,52), 1, (7721,-4353,152));
		maps\mp\_fx::loopfx("tank_fire_engine", (7703,-4164,52), 1, (7703,-4164,152));
	//	maps\mp\_fx::loopfx("tank_fire_engine", (6426,-2028,89), 1, (6426,-2028,189));
		maps\mp\_fx::loopfx("tank_fire_engine", (6666,-2413,456), 1, (6666,-2413,556));
		maps\mp\_fx::loopfx("tank_fire_engine", (6720,-2473,254), 1, (6720,-2473,354));
		maps\mp\_fx::loopfx("tank_fire_engine", (6919,-2542,259), 1, (6919,-2542,359));
		maps\mp\_fx::loopfx("tank_fire_engine", (6822,-2544,344), 1, (6822,-2544,444));

		maps\mp\_fx::loopfx("building_fire_small", (6678,-2444,277), 2, (6681,-2446,377));
		maps\mp\_fx::loopfx("building_fire_small", (7707,-4243,162), 2, (7710,-4245,262));

		//Sound FX
		maps\mp\_fx::soundfx("medfire", (6684,-2432,288));
	//	maps\mp\_fx::soundfx("medfire", (6466,-2049,67));
		maps\mp\_fx::soundfx("medfire", (4300,-3282,178));
		maps\mp\_fx::soundfx("medfire", (4221,-4133,54));
		maps\mp\_fx::soundfx("medfire", (6390,-4173,13));
		maps\mp\_fx::soundfx("medfire", (7741,-4229,94));
	}

	if (level.scr_allow_ambient_weather)
	{
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (7634,-4585,-67), 0.8, (7634,-4585,31));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (7735,-3622,-37), 0.8, (7735,-3622,61));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (7642,-1806,-23), 0.8, (7642,-1806,75));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (6777,-2895,-28), 0.8, (6777,-2895,70));

		maps\mp\_fx::loopfx("battlefield_smokebank_S", (5880,-1868,-34), 0.8, (5880,-1868,64));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (3909,-3186,-24), 0.8, (3909,-3186,74));

		maps\mp\_fx::loopfx("battlefield_smokebank_S", (4090,-4227,-38), 0.8, (4090,-4227,61));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (5938,-4938,-31), 0.8, (5938,-4938,67));
	}
}
