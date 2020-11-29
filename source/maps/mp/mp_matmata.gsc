main()
{
	// Fix texture bugs
	maps\mp\_bug_fix::matmata();

	maps\mp\mp_matmata_fx::main();
	maps\mp\_load::main();

	Ambient_Sound();

	game["allies"] = "british";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["british_soldiertype"] = "africa";
	game["german_soldiertype"] = "africa";

	setcvar("r_glowbloomintensity0","1");
	setcvar("r_glowbloomintensity1","1");
	setcvar("r_glowskybleedintensity0",".25");

	if(level.gametype == "hq")
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (2925.68, 7300.22, 4.01708));
		level.radio[0].angles = (3.92908, 250.325, 0.746747);

		level.radio[1] = spawn("script_model", (3030.68, 6717.98, 34.6506));
		level.radio[1].angles = (359.304, 266.713, -0.301727);

		level.radio[2] = spawn("script_model", (2651.14, 5968.58, -5.09178));
		level.radio[2].angles = (358.755, 146.839, 2.65828);

		level.radio[3] = spawn("script_model", (4051.66, 7606.57, -17.0527));
		level.radio[3].angles = (359.953, 282.836, -0.484949);

		level.radio[4] = spawn("script_model", (3442.85, 6202.02, 10.0243));
		level.radio[4].angles = (358.274, 250.454, -1.30116);

		level.radio[5] = spawn("script_model", (3191.53, 5527.01, 11.5809));
		level.radio[5].angles = (0, 212.7, 0);

		level.radio[6] = spawn("script_model", (4096.23, 6718.92, 18.6298));
		level.radio[6].angles = (0.527973, 146.921, -0.707481);

		level.radio[7] = spawn("script_model", (3750.23, 4956.39, 36.9999));
		level.radio[7].angles = (0, 191.548, 0);

		level.radio[8] = spawn("script_model", (5180.04, 7180.11, -22.912));
		level.radio[8].angles = (351.027, 212.69, 0.065291);

		level.radio[9] = spawn("script_model", (4935.46, 5870.01, 10.3784));
		level.radio[9].angles = (355.367, 230.858, -2.7836);

		level.radio[10] = spawn("script_model", (4965.69, 6209.5, 130));
		level.radio[10].angles = (0, 24.4301, 0);

		level.radio[11] = spawn("script_model", (5513.3, 6096.1, -59.9275));
		level.radio[11].angles = (356.29, 135.912, 1.55805);
	}

	if (!level.scr_remove_killtriggers)
	{
		level.killtriggers[0] = spawnstruct();
		level.killtriggers[0].origin = (3856, 5632, 267);
		level.killtriggers[0].radius = 276;
		level.killtriggers[0].height = 200;

		level.killtriggers[1] = spawnstruct();
		level.killtriggers[1].origin = (4277, 5405, 160);
		level.killtriggers[1].radius = 12;
		level.killtriggers[1].height = 12;

		level.killtriggers[2] = spawnstruct();
		level.killtriggers[2].origin = (3578, 6055, 281);
		level.killtriggers[2].radius = 16;
		level.killtriggers[2].height = 12;

		level.killtriggers[3] = spawnstruct();
		level.killtriggers[3].origin = (3235, 6392, 147);
		level.killtriggers[3].radius = 12;
		level.killtriggers[3].height = 12;

		level.killtriggers[4] = spawnstruct();
		level.killtriggers[4].origin = (4379, 7373, 220);
		level.killtriggers[4].radius = 12;
		level.killtriggers[4].height = 12;

		level.killtriggers[5] = spawnstruct();
		level.killtriggers[5].origin = (5318, 6898, 147);
		level.killtriggers[5].radius = 12;
		level.killtriggers[5].height = 12;

		level.killtriggers[5] = spawnstruct();
		level.killtriggers[5].origin = (3816, 6320, 292);
		level.killtriggers[5].radius = 337;
		level.killtriggers[5].height = 140;

		if (level.gametype != "strat")
			thread maps\mp\_killtriggers::init();
	}

}

Ambient_Sound()
{
	if ( level.scr_allow_ambient_sounds )
		ambientPlay("ambient_africa");

	if ( level.scr_allow_ambient_fog )
		setExpFog(0.0002, 0.5, 0.5, 0.5, 0);
}
