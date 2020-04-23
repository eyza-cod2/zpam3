main()
{
	maps\mp\mp_breakout_fx::main();
	maps\mp\_load::main();

	Ambient_Sound();

	game["allies"] = "british";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["british_soldiertype"] = "normandy";
	game["german_soldiertype"] = "normandy";

	setcvar("r_glowbloomintensity0",".25");
	setcvar("r_glowbloomintensity1",".25");
	setcvar("r_glowskybleedintensity0",".3");

	if((level.gametype == "hq"))
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (6940, 4475, 16));
		level.radio[0].angles = (1.51392, 106.39, -4.1593);

		level.radio[1] = spawn("script_model", (6521, 5098, -31));
		level.radio[1].angles = (4.08207, 0.456171, 6.38183);

		level.radio[2] = spawn("script_model", (6081, 6350, -10));
		level.radio[2].angles = (1.27831, 109.043, 7.58356);

		level.radio[3] = spawn("script_model", (5995, 5199, -4));
		level.radio[3].angles = (3.03321, 185.043, 7.23174);

		level.radio[4] = spawn("script_model", (5743, 4759, 40));
		level.radio[4].angles = (0, 5.043, 0);

		level.radio[5] = spawn("script_model", (5638, 4325, -2));
		level.radio[5].angles = (357.526, 275.319, 3.96995);

		level.radio[6] = spawn("script_model", (4916, 4163, 2));
		level.radio[6].angles = (0.669369, 256.05, 2.69276);

		level.radio[7] = spawn("script_model", (4975, 4815, 27));
		level.radio[7].angles = (0.46843, 275.043, 1.88415);

		level.radio[8] = spawn("script_model", (4371, 4228, 14));
		level.radio[8].angles = (2.80349, 288.983, 1.82355);

		level.radio[9] = spawn("script_model", (3838, 3652, 48));
		level.radio[9].angles = (0, 58.358, 0);

		level.radio[10] = spawn("script_model", (3851, 4758, 77));
		level.radio[10].angles = (356.541, 275.483, -4.95457);

		level.radio[11] = spawn("script_model", (4555, 5239, 12));
		level.radio[11].angles = (352.833, 185.058, 1.6828);

		level.radio[12] = spawn("script_model", (4941, 5965, 45));
		level.radio[12].angles = (356.64, 196.34, -12.3407);

		level.radio[13] = spawn("script_model", (3503, 5375, 69));
		level.radio[13].angles = (0.526773, 109.004, 3.96236);
	}

	if (!level.scr_remove_killtriggers)
	{
		level.killtriggers[0] = spawnstruct();
		level.killtriggers[0].origin = (5628, 4852, 312);
		level.killtriggers[0].radius = 300;
		level.killtriggers[0].height = 300;

		level.killtriggers[1] = spawnstruct();
		level.killtriggers[1].origin = (3840, 3776, 344);
		level.killtriggers[1].radius = 310;
		level.killtriggers[1].height = 320;

		level.killtriggers[2] = spawnstruct();
		level.killtriggers[2].origin = (3752, 5064, 344);
		level.killtriggers[2].radius = 270;
		level.killtriggers[2].height = 240;

		level.killtriggers[3] = spawnstruct();
		level.killtriggers[3].origin = (4070, 4132, 244);
		level.killtriggers[3].radius = 12;
		level.killtriggers[3].height = 12;

		level.killtriggers[4] = spawnstruct();
		level.killtriggers[4].origin = (4996, 5796, 392);
		level.killtriggers[4].radius = 150;
		level.killtriggers[4].height = 100;

		level.killtriggers[5] = spawnstruct();
		level.killtriggers[5].origin = (4692, 5212, 248);
		level.killtriggers[5].radius = 110;
		level.killtriggers[5].height = 150;

		level.killtriggers[6] = spawnstruct();
		level.killtriggers[6].origin = (5656, 5672, 180);
		level.killtriggers[6].radius = 210;
		level.killtriggers[6].height = 180;

		level.killtriggers[7] = spawnstruct();
		level.killtriggers[7].origin = (5884, 5444, 180);
		level.killtriggers[7].radius = 210;
		level.killtriggers[7].height = 180;

		level.killtriggers[8] = spawnstruct();
		level.killtriggers[8].origin = (5456, 3928, 270);
		level.killtriggers[8].radius = 280;
		level.killtriggers[8].height = 200;

		if (level.gametype != "strat")
			thread maps\mp\_killtriggers::init();
	}

}

Ambient_Sound()
{
	if ( level.scr_allow_ambient_sounds )
		ambientPlay("ambient_france");

	if ( level.scr_allow_ambient_fog )
		setExpFog(0.00015, 0.15, 0.14, 0.13, 0);

}
