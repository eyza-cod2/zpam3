main()
{
	//maps\pam\pam_setup::main();

	maps\mp\mp_downtown_fx::main();
	maps\mp\_load::main();

	Ambient_Sound();

	if(level.scr_replace_russian)
	{
		game["allies"] = "british";
		game["axis"] = "german";
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		game["british_soldiertype"] = "normandy";
		game["german_soldiertype"] = "winterlight";
	}
	else
	{
		game["allies"] = "russian";
		game["axis"] = "german";
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		game["russian_soldiertype"] = "padded";
		game["german_soldiertype"] = "winterlight";
	}

	setcvar("r_glowbloomintensity0","1");
	setcvar("r_glowbloomintensity1","1");
	setcvar("r_glowskybleedintensity0",".5");

	if((level.gametype == "hq"))
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (1471.18, -3017.88, 55.4537));
		level.radio[0].angles = (0, 245.3, 0);

		level.radio[1] = spawn("script_model", (1781.3, 440.9, 262));
		level.radio[1].angles = (0, 180, 0);

		level.radio[2] = spawn("script_model", (1791.4, -857.5, 54.1));
		level.radio[2].angles = (0, 180, -7.6);

		level.radio[3] = spawn("script_model", (3350.3, -512.4, 10.5));
		level.radio[3].angles = (352.8, 149.3, 4.2);

		level.radio[4] = spawn("script_model", (436.3, -375.1, 26.4));
		level.radio[4].angles = (356.8, 207.5, -0.3);

		level.radio[5] = spawn("script_model", (3116.11, -1763.43, 22.7667));
		level.radio[5].angles = (0, 206, 0);

		level.radio[6] = spawn("script_model", (601.505, -1756.95, 24.4676));
		level.radio[6].angles = (1.23737, 226.765, 0.316602);

		level.radio[7] = spawn("script_model", (3175.32, 599.681, -8.8989));
		level.radio[7].angles = (359.44, 136.782, -0.550982);

		level.radio[8] = spawn("script_model", (1420.13, -2144.28, 286));
		level.radio[8].angles = (0, 188.2, 0);

		level.radio[9] = spawn("script_model", (1387.16, 766.204, 82));
		level.radio[9].angles = (0, 180, 0);

		level.radio[10] = spawn("script_model", (2187.53, 1081.38, 82));
		level.radio[10].angles = (0, 163.4, 0);
	}

	if (!level.scr_remove_killtriggers)
	{
		level.killtriggers[0] = spawnstruct();
		level.killtriggers[0].origin = (1540, 33, 172);
		level.killtriggers[0].radius = 17;
		level.killtriggers[0].height = 6;

		level.killtriggers[1] = spawnstruct();
		level.killtriggers[1].origin = (1878, 60, 176);
		level.killtriggers[1].radius = 17;
		level.killtriggers[1].height = 4;

		if (level.gametype != "strat")
			thread maps\mp\_killtriggers::init();
	}
}

Ambient_Sound()
{
	if ( level.scr_allow_ambient_sounds )
		ambientPlay("ambient_russia");

	if ( level.scr_allow_ambient_fog )
		setExpFog(0.00028, .58, .57, .57, 0);
}
