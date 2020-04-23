main()
{
	// Fix texture bugs
 	maps\mp\_bug_fix::dawnville();

	maps\mp\mp_dawnville_fx::main();
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
		level.radio[0] = spawn("script_model", (-782.993, -17459, 32));
		level.radio[0].angles = (0, 0, 0);

		level.radio[1] = spawn("script_model", (-480.421, -15988.5, -14.7338));
		level.radio[1].angles = (358.443, 129.085, -3.34077);

		level.radio[2] = spawn("script_model", (130.131, -16987.2, 40));
		level.radio[2].angles = (0, 321.085, 0);

		level.radio[3] = spawn("script_model", (199.834, -15920, 27));
		level.radio[3].angles = (0, 149.451, 0);

		level.radio[4] = spawn("script_model", (626.478, -16290.2, -14.5538));
		level.radio[4].angles = (4.04017, 352.386, -1.11768);

		level.radio[5] = spawn("script_model", (1596.11, -16373.1, 10.3558));
		level.radio[5].angles = (13.3743, 149.451, -9.99528);

		level.radio[6] = spawn("script_model", (759.444, -15016.7, -68.307));
		level.radio[6].angles = (355.201, 149.059, 4.67512);

		level.radio[7] = spawn("script_model", (1109.1, -15503.7, -2.99999));
		level.radio[7].angles = (0, 108.459, 0);

		level.radio[8] = spawn("script_model", (2430.82, -15839.3, -64));
		level.radio[8].angles = (0, 149.059, 0);

		level.radio[9] = spawn("script_model", (915.985, -17651.6, 103));
		level.radio[9].angles = (0, 151.785, 0);

		level.radio[10] = spawn("script_model", (-87.6296, -17982.9, 197));
		level.radio[10].angles = (0, 155.4, 0);

		level.radio[11] = spawn("script_model", (-243.158, -14714, -8.23551));
		level.radio[11].angles = (352.187, 108.612, -1.12543);
	}

	if (!level.scr_remove_killtriggers)
	{
		level.killtriggers[0] = spawnstruct();
		level.killtriggers[0].origin = (-1340, -16068, 24);
		level.killtriggers[0].radius = 64;
		level.killtriggers[0].height = 80;

		level.killtriggers[1] = spawnstruct();
		level.killtriggers[1].origin = (-44, -15292, 168);
		level.killtriggers[1].radius = 192;
		level.killtriggers[1].height = 80;

		level.killtriggers[2] = spawnstruct();
		level.killtriggers[2].origin = (-1340, -16212, 24);
		level.killtriggers[2].radius = 64;
		level.killtriggers[2].height = 80;

		level.killtriggers[3] = spawnstruct();
		level.killtriggers[3].origin = (-528, -16488, 92);
		level.killtriggers[3].radius = 12;
		level.killtriggers[3].height = 12;

		level.killtriggers[4] = spawnstruct();
		level.killtriggers[4].origin = (1024, -16416, 244);
		level.killtriggers[4].radius = 260;
		level.killtriggers[4].height = 120;

		level.killtriggers[5] = spawnstruct();
		level.killtriggers[5].origin = (196, -15596, 243);
		level.killtriggers[5].radius = 280;
		level.killtriggers[5].height = 180;

		level.killtriggers[6] = spawnstruct();
		level.killtriggers[6].origin = (192, -16100, 227);
		level.killtriggers[6].radius = 280;
		level.killtriggers[6].height = 180;

		level.killtriggers[7] = spawnstruct();
		level.killtriggers[7].origin = (220, -16992, 250);
		level.killtriggers[7].radius = 165;
		level.killtriggers[7].height = 100;

		level.killtriggers[8] = spawnstruct();
		level.killtriggers[8].origin = (148, -16672, 250);
		level.killtriggers[8].radius = 210;
		level.killtriggers[8].height = 170;

		level.killtriggers[9] = spawnstruct();
		level.killtriggers[9].origin = (1024, -14720, 120);
		level.killtriggers[9].radius = 192;
		level.killtriggers[9].height = 80;
	}

	if (level.gametype != "strat")
		thread maps\mp\_killtriggers::init();
}

Ambient_Sound()
{
	if ( level.scr_allow_ambient_sounds )
		ambientPlay("ambient_france");

	if ( level.scr_allow_ambient_fog )
		setExpFog(0.00025, 0.32, 0.36, 0.40, 0);
}
