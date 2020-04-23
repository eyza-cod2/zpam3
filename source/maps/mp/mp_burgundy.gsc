main()
{
	// Fix texture bugs
	maps\mp\_bug_fix::burgundy();

	maps\mp\mp_burgundy_fx::main();
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

	if((level.gametype == "hq"))
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (768.8, 58.1, 83.1));
		level.radio[0].angles = (0, 295, 0);

		level.radio[1] = spawn("script_model", (428.8, 994.9, 0.1));
		level.radio[1].angles = (0, 70, 0);

		level.radio[2] = spawn("script_model", (1978.9, 2085.63, 0.864801));
		level.radio[2].angles = (0.851713, 120.007, 0.491852);

		level.radio[3] = spawn("script_model", (1030.3, 442.3, 151.9));
		level.radio[3].angles = (0, 13, 0);

		level.radio[4] = spawn("script_model", (226.6, 2515.6, 56));
		level.radio[4].angles = (0, 126, 0);

		level.radio[5] = spawn("script_model", (-415.364, 2474.61, -1.73221));
		level.radio[5].angles = (355.978, 180, -1.30946);
	}

	if (!level.scr_remove_killtriggers)
	{
		level.killtriggers[0] = spawnstruct();
		level.killtriggers[0].origin = (96, 2296, 168);
		level.killtriggers[0].radius = 165;
		level.killtriggers[0].height = 170;

		level.killtriggers[1] = spawnstruct();
		level.killtriggers[1].origin = (88, 2696, 200);
		level.killtriggers[1].radius = 165;
		level.killtriggers[1].height = 140;

		level.killtriggers[2] = spawnstruct();
		level.killtriggers[2].origin = (552, 2686, 200);
		level.killtriggers[2].radius = 150;
		level.killtriggers[2].height = 140;

		level.killtriggers[3] = spawnstruct();
		level.killtriggers[3].origin = (1144, 2000, 125);
		level.killtriggers[3].radius = 165;
		level.killtriggers[3].height = 230;

		level.killtriggers[4] = spawnstruct();
		level.killtriggers[4].origin = (1144, 1328, 147);
		level.killtriggers[4].radius = 205;
		level.killtriggers[4].height = 200;

		level.killtriggers[5] = spawnstruct();
		level.killtriggers[5].origin = (1444, 1948, 108);
		level.killtriggers[5].radius = 27;
		level.killtriggers[5].height = 12;

		level.killtriggers[6] = spawnstruct();
		level.killtriggers[6].origin = (144, 734, 130);
		level.killtriggers[6].radius = 35;
		level.killtriggers[6].height = 12;

		level.killtriggers[7] = spawnstruct();
		level.killtriggers[7].origin = (452, 981, 132);
		level.killtriggers[7].radius = 16;
		level.killtriggers[7].height = 12;
	}

	if (level.gametype != "strat")
		thread maps\mp\_killtriggers::init();
}

Ambient_Sound()
{
	if ( level.scr_allow_ambient_sounds )
		ambientPlay("ambient_france");

	if ( level.scr_allow_ambient_fog )
		setExpFog(0.00015, 0.7, 0.85, 1.0, 0);
}
