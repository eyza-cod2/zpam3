main()
{
	precacheFX();
	ambientFX();

	level.scr_sound["flak88_explode"]			= "flak88_explode";
}

precacheFX()
{
	level._effect["flak_explosion"]				= loadfx("fx/explosions/flak88_explosion.efx");

	//ambient FX
	level._effect["thin_black_smoke_S"]				= loadfx ("fx/smoke/thin_black_smoke_S.efx");
	level._effect["thin_black_smoke_M"]				= loadfx ("fx/smoke/thin_black_smoke_M.efx");
	level._effect["thin_light_smoke_M"]				= loadfx ("fx/smoke/thin_light_smoke_M.efx");
	level._effect["battlefield_smokebank_S"]		= loadfx ("fx/smoke/battlefield_smokebank_S.efx");
	level._effect["tank_fire_turret"] 				= loadfx ("fx/fire/tank_fire_turret_small.efx");
	level._effect["tank_fire_engine"] 				= loadfx ("fx/fire/tank_fire_engine.efx");
	level._effect["tank_fire_turret_large"] 		= loadfx ("fx/fire/tank_fire_turret_large.efx");


}

ambientFX()
{
	if (level.scr_allow_ambient_fire)
	{
		maps\mp\_fx::loopfx("tank_fire_turret_large", (4986,5787,78), 1, (4986,5787,178));
		maps\mp\_fx::loopfx("tank_fire_engine", (4067,5872,65), 1, (4067,5872,165));
		maps\mp\_fx::loopfx("tank_fire_engine", (5069,5867,89), 1, (5069,5867,189));
		maps\mp\_fx::loopfx("tank_fire_engine", (5088,5775,73), 1, (5088,5775,173));
		maps\mp\_fx::loopfx("tank_fire_engine", (3994,5742,64), 1, (3994,5742,164));
		maps\mp\_fx::loopfx("tank_fire_engine", (3081,5782,29), 1, (3081,5782,129));
		maps\mp\_fx::loopfx("tank_fire_engine", (3119,5806,33), 1, (3119,5806,133));
		maps\mp\_fx::loopfx("tank_fire_engine", (3330,3364,53), 1, (3330,3364,153));
		maps\mp\_fx::loopfx("tank_fire_engine", (3345,3426,111), 1, (3345,3426,211));
		maps\mp\_fx::loopfx("tank_fire_engine", (3451,3421,67), 1, (3451,3421,167));
		maps\mp\_fx::loopfx("tank_fire_engine", (5326,3366,59), 1, (5326,3366,159));
		maps\mp\_fx::loopfx("tank_fire_engine", (5414,3288,48), 1, (5414,3288,148));
		maps\mp\_fx::loopfx("tank_fire_engine", (5871,3428,25), 1, (5871,3428,125));
		maps\mp\_fx::loopfx("tank_fire_engine", (6682,3989,37), 1, (6682,3989,137));
		maps\mp\_fx::loopfx("tank_fire_engine", (5241,3229,58), 1, (5241,3229,158));
		maps\mp\_fx::loopfx("tank_fire_engine", (5293,4482,39), 1, (5293,4482,139));
		maps\mp\_fx::loopfx("tank_fire_engine", (5836,3398,4), 1, (5836,3398,104));
		maps\mp\_fx::loopfx("tank_fire_engine", (6124,4708,51), 1, (6124,4708,151));
		maps\mp\_fx::loopfx("tank_fire_engine", (6110,4671,19), 1, (6110,4671,119));
		maps\mp\_fx::loopfx("tank_fire_engine", (6038,4826,2), 1, (5951,4827,50));
		maps\mp\_fx::loopfx("tank_fire_engine", (6132,4681,19), 1, (6132,4681,119));
		maps\mp\_fx::loopfx("tank_fire_turret_large", (4096,5772,76), 1, (4096,5772,176));
		maps\mp\_fx::loopfx("tank_fire_turret_large", (3327,3435,84), 1, (3327,3435,184));
		maps\mp\_fx::loopfx("tank_fire_turret_large", (6561,4004,41), 1, (6569,4023,139));
		maps\mp\_fx::loopfx("tank_fire_turret", (5093,4164,51), 1, (5092,4167,151));

		//House Fires
		maps\mp\_fx::loopfx("thin_black_smoke_M", (5546,4722,315), 1, (5546,4722,414));
		maps\mp\_fx::loopfx("thin_black_smoke_M", (7782,7712,228), 1, (7782,7712,327));
		maps\mp\_fx::loopfx("thin_black_smoke_M", (3809,4984,412), 1, (3809,4984,511));

		// Smoldering Vehicles
		maps\mp\_fx::loopfx("thin_black_smoke_S", (3099,5756,49), 0.6, (3099,5756,149));
		maps\mp\_fx::loopfx("thin_black_smoke_S", (5785,6221,11), 0.6, (5785,6221,111));
		maps\mp\_fx::loopfx("thin_black_smoke_S", (5900,3412,20), 0.6, (5900,3412,120));

		//Sound FX
		maps\mp\_fx::soundfx("medfire", (3345,3349,117));
		maps\mp\_fx::soundfx("smallfire", (3316,5767,64));
		maps\mp\_fx::soundfx("medfire", (4082,5757,126));
		maps\mp\_fx::soundfx("medfire", (5011,5791,127));
		maps\mp\_fx::soundfx("smallfire", (6122,4709,71));
		maps\mp\_fx::soundfx("medfire", (6593,3995,47));
		maps\mp\_fx::soundfx("medfire", (5299,3293,61));
		maps\mp\_fx::soundfx("smallfire", (5300,4477,64));

		//burning car
		maps\mp\_fx::soundfx("medfire", (5088,4163,48));
	}

	if (level.scr_allow_ambient_weather)
	{
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (4240,5284,37), 1, (4240,5284,137));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (4758,4628,9), 1, (4758,4628,109));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (6173,5346,16), 1, (6173,5346,116));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (6983,5362,11), 1, (6983,5362,111));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (6021,4506,-21), 1, (6021,4506,78));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (5329,3309,25), 1, (5329,3309,125));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (4250,3261,-10), 1, (4250,3261,89));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (3297,3336,9), 1, (3297,3336,109));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (3182,4365,-3), 1, (3182,4365,96));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (3190,5324,-31), 1, (3190,5324,68));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (5697,6475,-45), 1, (5697,6475,53));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (4792,5770,24), 1, (4792,5770,123));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (6591,6710,-66), 1, (6591,6710,33));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (6701,6071,-34), 1, (6701,6071,64));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (5280,5039,-13), 1, (5280,5039,86));
	}
}
