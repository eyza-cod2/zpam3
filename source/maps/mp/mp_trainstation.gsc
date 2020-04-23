main()
{
	maps\mp\mp_trainstation_fx::main();
	maps\mp\_load::main();

	Ambient_Sound();

	game["allies"] = "american";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["american_soldiertype"] = "normandy";
	game["german_soldiertype"] = "normandy";

	setcvar("r_glowbloomintensity0","1");
	setcvar("r_glowbloomintensity1","1");
	setcvar("r_glowskybleedintensity0",".5");

	if(level.gametype == "hq")
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (7680.83, -3602.28, 18));
		level.radio[0].angles = (0, 297.2, 0);

		level.radio[1] = spawn("script_model", (6954, -3052, -5));
		level.radio[1].angles = (0.000130414, 314.6, 1.64352);

		level.radio[2] = spawn("script_model", (6883, -2418, 23));
		level.radio[2].angles = (0, 348.4, 0);

		level.radio[3] = spawn("script_model", (5689, -2117, 30));
		level.radio[3].angles = (0, 227, 0);

		level.radio[4] = spawn("script_model", (6688.13, -4136.62, -32));
		level.radio[4].angles = (- 0, 109.379, 0);

		level.radio[5] = spawn("script_model", (5598, -4975, -8));
		level.radio[5].angles = (0, 350.4, 0);

		level.radio[6] = spawn("script_model", (5289, -3530, 40));
		level.radio[6].angles = (0, 223.8, 0);

		level.radio[7] = spawn("script_model", (4415, -3532, -32));
		level.radio[7].angles = (0, 316.6, 0);

		level.radio[8] = spawn("script_model", (5769.37, -3350.22, 25));
		level.radio[8].angles = (0, 197.179, 0);

		level.radio[9] = spawn("script_model", (3787.95, -4388.3, 0.598343));
		level.radio[9].angles = (357.615, 359.479, 0.843511);
	}

	if (!level.scr_remove_killtriggers)
	{
		level.killtriggers[0] = spawnstruct();
		level.killtriggers[0].origin = (4320, -4553, 130);
		level.killtriggers[0].radius = 40;
		level.killtriggers[0].height = 12;

		level.killtriggers[1] = spawnstruct();
		level.killtriggers[1].origin = (3940, -4565, 122);
		level.killtriggers[1].radius = 21;
		level.killtriggers[1].height = 12;

		level.killtriggers[2] = spawnstruct();
		level.killtriggers[2].origin = (3776, -4164, 136);
		level.killtriggers[2].radius = 21;
		level.killtriggers[2].height = 12;

		level.killtriggers[3] = spawnstruct();
		level.killtriggers[3].origin = (4092, -4038, 130);
		level.killtriggers[3].radius = 21;
		level.killtriggers[3].height = 12;

		level.killtriggers[4] = spawnstruct();
		level.killtriggers[4].origin = (6820, -3458, 144);
		level.killtriggers[4].radius = 21;
		level.killtriggers[4].height = 12;

		level.killtriggers[5] = spawnstruct();
		level.killtriggers[5].origin = (7224, -3390, 114);
		level.killtriggers[5].radius = 18;
		level.killtriggers[5].height = 12;

		level.killtriggers[6] = spawnstruct();
		level.killtriggers[6].origin = (7034, -2824, 114);
		level.killtriggers[6].radius = 18;
		level.killtriggers[6].height = 12;

		level.killtriggers[7] = spawnstruct();
		level.killtriggers[7].origin = (6441, -2980, 198);
		level.killtriggers[7].radius = 25;
		level.killtriggers[7].height = 12;

		level.killtriggers[8] = spawnstruct();
		level.killtriggers[8].origin = (6366, -2241, 114);
		level.killtriggers[8].radius = 18;
		level.killtriggers[8].height = 12;

		level.killtriggers[9] = spawnstruct();
		level.killtriggers[9].origin = (5037, -1955, 112);
		level.killtriggers[9].radius = 18;
		level.killtriggers[9].height = 12;

		level.killtriggers[10] = spawnstruct();
		level.killtriggers[10].origin = (6581, -2826, 104);
		level.killtriggers[10].radius = 16;
		level.killtriggers[10].height = 12;

		level.killtriggers[11] = spawnstruct();
		level.killtriggers[11].origin = (6690, -4634, 200);
		level.killtriggers[11].radius = 128;
		level.killtriggers[11].height = 128;

		level.killtriggers[12] = spawnstruct();
		level.killtriggers[12].origin = (7656, -1628, 106);
		level.killtriggers[12].radius = 24;
		level.killtriggers[12].height = 12;

		if (level.gametype != "strat")
			thread maps\mp\_killtriggers::init();
	}
}

Ambient_Sound()
{
	if ( level.scr_allow_ambient_sounds )
		ambientPlay("ambient_france");

	if ( level.scr_allow_ambient_fog )
		setExpFog(0.000125, 0.7, 0.85, 1.0, 0);
}
