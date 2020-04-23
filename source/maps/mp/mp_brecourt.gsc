main()
{
	maps\mp\mp_brecourt_fx::main();
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
	setcvar("r_glowskybleedintensity0",".25");

	if(level.gametype == "hq")
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (-2924.2, 1286.5, 25.6));
		level.radio[0].angles = (0, 315, 0);
		level.radio[1] = spawn("script_model", (2155.4, 675.6, -26.3));
		level.radio[1].angles = (0, 30, 0);
		level.radio[2] = spawn("script_model", (882.8, -243.1, 11));
		level.radio[2].angles = (0, 105, 0);
		level.radio[3] = spawn("script_model", (-1137.5, -2552.5, -15.9));
		level.radio[3].angles = (0, 151, 0);
		level.radio[4] = spawn("script_model", (1921.4, -2695, 35.7));
		level.radio[4].angles = (0, 108, 0);
		level.radio[5] = spawn("script_model", (1115.6, -1119.3, -3.2));
		level.radio[5].angles = (0, 1.5, 0);
		level.radio[6] = spawn("script_model", (2982.2, -828.7, -16.2));
		level.radio[6].angles = (0, 62, 0);
		level.radio[7] = spawn("script_model", (-1136.8, -740.3, 47.8));
		level.radio[7].angles = (0, 305, 0);
	}

	if (!level.scr_remove_killtriggers)
	{
		level.killtriggers[0] = spawnstruct();
		level.killtriggers[0].origin = (-3086, 884, 168);
		level.killtriggers[0].radius = 8;
		level.killtriggers[0].height = 12;

		level.killtriggers[1] = spawnstruct();
		level.killtriggers[1].origin = (-1736, -1688, 184);
		level.killtriggers[1].radius = 20;
		level.killtriggers[1].height = 12;

		level.killtriggers[2] = spawnstruct();
		level.killtriggers[2].origin = (-1062, -1284, 180);
		level.killtriggers[2].radius = 20;
		level.killtriggers[2].height = 12;

		level.killtriggers[3] = spawnstruct();
		level.killtriggers[3].origin = (1220, -2930, 148);
		level.killtriggers[3].radius = 27;
		level.killtriggers[3].height = 12;

		if (level.gametype != "strat")
			thread maps\mp\_killtriggers::init();
	}
}

Ambient_Sound()
{
	if ( level.scr_allow_ambient_sounds )
		ambientPlay("ambient_france");

	if ( level.scr_allow_ambient_fog )
		setExpFog(0.0001, 0.30, 0.31, 0.34, 0);
}
