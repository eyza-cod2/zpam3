main()
{
	// Fix texture bugs
	maps\mp\_bug_fix::carentan();

	maps\mp\mp_carentan_fx::main();
	maps\mp\_load::main();

	Ambient_Sound();

	game["allies"] = "american";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["american_soldiertype"] = "normandy";
	game["german_soldiertype"] = "normandy";

	setCvar("r_glowbloomintensity0", ".25");
	setCvar("r_glowbloomintensity1", ".25");
	setcvar("r_glowskybleedintensity0",".3");

	if(level.gametype == "hq")
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (1314.6, 177, 4));
		level.radio[0].angles = (0, 270, 0);
		level.radio[1] = spawn("script_model", (1708.6, 2191.4, -22));
		level.radio[1].angles = (0, 233, 0);
		level.radio[2] = spawn("script_model", (836.2, 3585, 16));
		level.radio[2].angles = (0, 13.5, 0);
		level.radio[3] = spawn("script_model", (-831.6, 2098.8, 179.4));
		level.radio[3].angles = (0, 208, 0);
		level.radio[4] = spawn("script_model", (87.4083, 605.54, 0.375351));
		level.radio[4].angles = (0, 270, 0);
		level.radio[5] = spawn("script_model", (375.673, -951.321, 69.0145));
		level.radio[5].angles = (2.48971, 0.226723, 5.20487);
		level.radio[6] = spawn("script_model", (807.015, 600.315, 41.0145));
		level.radio[6].angles = (0, 80, 0);
		level.radio[7] = spawn("script_model", (478.177, 1983.88, -93.9855));
		level.radio[7].angles = (0, 136, 0);
	}

	if (!level.scr_remove_killtriggers)
	{
		level.killtriggers[0] = spawnstruct();
		level.killtriggers[0].origin = (976, 600, 316);
		level.killtriggers[0].radius = 375;
		level.killtriggers[0].height = 270;

		level.killtriggers[1] = spawnstruct();
		level.killtriggers[1].origin = (672, 368, 224);
		level.killtriggers[1].radius = 100;
		level.killtriggers[1].height = 92;

		level.killtriggers[2] = spawnstruct();
		level.killtriggers[2].origin = (928, 368, 224);
		level.killtriggers[2].radius = 100;
		level.killtriggers[2].height = 92;

		level.killtriggers[3] = spawnstruct();
		level.killtriggers[3].origin = (768, 1220, 310);
		level.killtriggers[3].radius = 255;
		level.killtriggers[3].height = 180;

		level.killtriggers[4] = spawnstruct();
		level.killtriggers[4].origin = (1180, 1524, 300);
		level.killtriggers[4].radius = 360;
		level.killtriggers[4].height = 220;

		level.killtriggers[5] = spawnstruct();
		level.killtriggers[5].origin = (354, 1918, 318);
		level.killtriggers[5].radius = 530;
		level.killtriggers[5].height = 330;

		level.killtriggers[6] = spawnstruct();
		level.killtriggers[6].origin = (168, 332, 152);
		level.killtriggers[6].radius = 68;
		level.killtriggers[6].height = 128;

		level.killtriggers[7] = spawnstruct();
		level.killtriggers[7].origin = (112, 604, 286);
		level.killtriggers[7].radius = 244;
		level.killtriggers[7].height = 210;

		level.killtriggers[8] = spawnstruct();
		level.killtriggers[8].origin = (1040, 3180, 294);
		level.killtriggers[8].radius = 425;
		level.killtriggers[8].height = 320;

		level.killtriggers[9] = spawnstruct();
		level.killtriggers[9].origin = (1328, 2432, 268);
		level.killtriggers[9].radius = 355;
		level.killtriggers[9].height = 320;

		level.killtriggers[10] = spawnstruct();
		level.killtriggers[10].origin = (-9, 187, 156);
		level.killtriggers[10].radius = 21;
		level.killtriggers[10].height = 12;

		level.killtriggers[11] = spawnstruct();
		level.killtriggers[11].origin = (956, 157, 156);
		level.killtriggers[11].radius = 21;
		level.killtriggers[11].height = 12;

		level.killtriggers[12] = spawnstruct();
		level.killtriggers[12].origin = (94, 1212, 150);
		level.killtriggers[12].radius = 21;
		level.killtriggers[12].height = 12;

		level.killtriggers[13] = spawnstruct();
		level.killtriggers[13].origin = (1218, 1764, 64);
		level.killtriggers[13].radius = 60;
		level.killtriggers[13].height = 12;

		level.killtriggers[14] = spawnstruct();
		level.killtriggers[14].origin = (1361, 1271, 64);
		level.killtriggers[14].radius = 41;
		level.killtriggers[14].height = 12;

		level.killtriggers[15] = spawnstruct();
		level.killtriggers[15].origin = (1820, 2050, 66);
		level.killtriggers[15].radius = 136;
		level.killtriggers[15].height = 12;

		level.killtriggers[16] = spawnstruct();
		level.killtriggers[16].origin = (-232, 2409, 76);
		level.killtriggers[16].radius = 46;
		level.killtriggers[16].height = 6;

		if (level.gametype != "strat")
			thread maps\mp\_killtriggers::init();
	}
}

Ambient_Sound()
{
	if ( level.scr_allow_ambient_sounds )
		ambientPlay("ambient_france");

	if ( level.scr_allow_ambient_fog )
		setExpFog(0.0001, 0.55, 0.6, 0.55, 0);
}
