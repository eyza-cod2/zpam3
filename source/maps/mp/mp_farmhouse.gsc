main()
{
	maps\mp\mp_farmhouse_fx::main();
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
		level.radio[0] = spawn("script_model", (-3513.59, -1361.81, -35.665));
		level.radio[0].angles = (359.639, 269.643, 0.227865);

		level.radio[1] = spawn("script_model", (-2374.96, -649.441, 27.609));
		level.radio[1].angles = (359.101, 187.63, 1.78765);

		level.radio[2] = spawn("script_model", (-2557.94, 501.352, 2.32927));
		level.radio[2].angles = (359.996, 225.988, -6.0574);

		level.radio[3] = spawn("script_model", (-1231.45, -2028.35, 49.0045));
		level.radio[3].angles = (0.191027, 215.78, 1.61672);

		level.radio[4] = spawn("script_model", (-27.3077, -1447.69, 40.9167));
		level.radio[4].angles = (2.692, 359.988, 0.19894);

		level.radio[5] = spawn("script_model", (284.767, -147.686, 68));
		level.radio[5].angles = (0, 0, 0);

		level.radio[6] = spawn("script_model", (841.004, 13.4426, 181.043));
		level.radio[6].angles = (4.21794, 231.32, 2.38887);

		level.radio[7] = spawn("script_model", (-323.344, 1183.38, 103.457));
		level.radio[7].angles = (1.56637, 300.056, 2.24019);

		level.radio[8] = spawn("script_model", (1231.23, -199.082, 211.32));
		level.radio[8].angles = (0.169897, 294.644, 0.388363);

		level.radio[9] = spawn("script_model", (-2792.75, 1316.81, -15));
		level.radio[9].angles = (0, 135.929, 0);

		level.radio[10] = spawn("script_model", (-2907.03, -866.834, 27));
		level.radio[10].angles = (0, 11.929, 0);

		level.radio[11] = spawn("script_model", (-1125.98, -425.723, -57.8988));
		level.radio[11].angles = (0.789996, 292.829, 1.08254);

		level.radio[12] = spawn("script_model", (-538.039, -82.2693, 56.7781));
		level.radio[12].angles = (1.50739, 310.182, -1.78412);
	}

	if (!level.scr_remove_killtriggers)
	{
		level.killtriggers[0] = spawnstruct();
		level.killtriggers[0].origin = (-2808, 1308, 241);
		level.killtriggers[0].radius = 280;
		level.killtriggers[0].height = 200;

		level.killtriggers[1] = spawnstruct();
		level.killtriggers[1].origin = (-544, 232, 180);
		level.killtriggers[1].radius = 121;
		level.killtriggers[1].height = 138;

		level.killtriggers[2] = spawnstruct();
		level.killtriggers[2].origin = (-460, 416, 208);
		level.killtriggers[2].radius = 161;
		level.killtriggers[2].height = 110;

		level.killtriggers[3] = spawnstruct();
		level.killtriggers[3].origin = (-708, 368, 208);
		level.killtriggers[3].radius = 161;
		level.killtriggers[3].height = 30;

		level.killtriggers[4] = spawnstruct();
		level.killtriggers[4].origin = (-568, -144, 168);
		level.killtriggers[4].radius = 64;
		level.killtriggers[4].height = 30;

		level.killtriggers[5] = spawnstruct();
		level.killtriggers[5].origin = (-536, -536, 203);
		level.killtriggers[5].radius = 243;
		level.killtriggers[5].height = 120;

		level.killtriggers[6] = spawnstruct();
		level.killtriggers[6].origin = (-478, -308, 164);
		level.killtriggers[6].radius = 93;
		level.killtriggers[6].height = 40;

		level.killtriggers[7] = spawnstruct();
		level.killtriggers[7].origin = (-642, -336, 164);
		level.killtriggers[7].radius = 93;
		level.killtriggers[7].height = 40;

		level.killtriggers[8] = spawnstruct();
		level.killtriggers[8].origin = (12, -598, 252);
		level.killtriggers[8].radius = 12;
		level.killtriggers[8].height = 12;

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
