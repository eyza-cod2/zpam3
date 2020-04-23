main()
{
	maps\mp\mp_leningrad_fx::main();
	maps\mp\_load::main();

	Ambient_Sound();

	if(level.scr_replace_russian)
	{
		game["allies"] = "british";
		game["axis"] = "german";
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		game["british_soldiertype"] = "normandy";
		game["german_soldiertype"] = "winterdark";
	}
	else
	{
		game["allies"] = "russian";
		game["axis"] = "german";
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		game["russian_soldiertype"] = "padded";
		game["german_soldiertype"] = "winterdark";
	}

	setcvar("r_glowbloomintensity0","1");
	setcvar("r_glowbloomintensity1","1");
	setcvar("r_glowskybleedintensity0",".5");

	if((level.gametype == "hq"))
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (482.259, 1086.52, 8));
		level.radio[0].angles = (0, 157.687, 0);

		level.radio[1] = spawn("script_model", (-215.47, 1021.66, -56));
		level.radio[1].angles = (0, 19.587, 0);

		level.radio[2] = spawn("script_model", (-1012.53, 852.77, 16.329));
		level.radio[2].angles = (358.036, 233.487, -5.43541);

		level.radio[3] = spawn("script_model", (676.957, 135.464, 60));
		level.radio[3].angles = (0, 75, 0);

		level.radio[4] = spawn("script_model", (-984.004, 112.323, 93));
		level.radio[4].angles = (0, 233.3, 0);

		level.radio[5] = spawn("script_model", (577.105, -505.297, 8.72071));
		level.radio[5].angles = (359.008, 73.0989, -0.690039);

		level.radio[6] = spawn("script_model", (-283.817, -681.342, 80));
		level.radio[6].angles = (0, 317.899, 0);

		level.radio[7] = spawn("script_model", (-1096, -1021, 55));
		level.radio[7].angles = (0, 356.5, 0);

		level.radio[8] = spawn("script_model", (-212.005, 82.1896, 58.0002));
		level.radio[8].angles = (6.86437, 89.8501, 0.930204);
	}

	if (!level.scr_remove_killtriggers)
	{
		level.killtriggers[0] = spawnstruct();
		level.killtriggers[0].origin = (330, 1098, 288);
		level.killtriggers[0].radius = 72;
		level.killtriggers[0].height = 12;

		level.killtriggers[1] = spawnstruct();
		level.killtriggers[1].origin = (630, 1096, 288);
		level.killtriggers[1].radius = 72;
		level.killtriggers[1].height = 12;

		level.killtriggers[2] = spawnstruct();
		level.killtriggers[2].origin = (-928, -640, 264);
		level.killtriggers[2].radius = 136;
		level.killtriggers[2].height = 160;

		level.killtriggers[3] = spawnstruct();
		level.killtriggers[3].origin = (-1200, -1024, 264);
		level.killtriggers[3].radius = 465;
		level.killtriggers[3].height = 160;

		level.killtriggers[4] = spawnstruct();
		level.killtriggers[4].origin = (-160, -736, 352);
		level.killtriggers[4].radius = 360;
		level.killtriggers[4].height = 170;

		level.killtriggers[5] = spawnstruct();
		level.killtriggers[5].origin = (990, 894, 224);
		level.killtriggers[5].radius = 40;
		level.killtriggers[5].height = 80;

		if (level.gametype != "strat")
			thread maps\mp\_killtriggers::init();
	}

}

Ambient_Sound()
{
	if ( level.scr_allow_ambient_sounds )
		ambientPlay("ambient_russia");

	if ( level.scr_allow_ambient_fog )
		setExpFog(0.00045, .58, .57, .57, 0);
}
