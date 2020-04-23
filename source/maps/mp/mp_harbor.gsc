main()
{
	// Fix texture bugs
	maps\mp\_bug_fix::harbor();

	maps\mp\mp_harbor_fx::main();
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
		level.radio[0] = spawn("script_model", (-6960.68, -7405.43, -3.61082));
		level.radio[0].angles = (4.40472, 76.0809, -0.520537);

		level.radio[1] = spawn("script_model", (-8388.52, -7920.24, 9.02138));
		level.radio[1].angles = (0, 330, 0);

		level.radio[2] = spawn("script_model", (-9787.16, -8687.53, 8.00002));
		level.radio[2].angles = (0, 345.2, 0);

		level.radio[3] = spawn("script_model", (-11576.8, -7591.59, 15.243));
		level.radio[3].angles = (358.462, 30.004, -0.146589);

		level.radio[4] = spawn("script_model", (-9204.64, -6806.99, 0.224747));
		level.radio[4].angles = (1.75818, 15.035, 0.94779);

		level.radio[5] = spawn("script_model", (-8521.13, -8747.75, 0));
		level.radio[5].angles = (0, 345.035, 0);

	}
}

Ambient_Sound()
{
	if ( level.scr_allow_ambient_sounds )
		ambientPlay("ambient_russia");

	if ( level.scr_allow_ambient_fog )
		setExpFog(0.00028, .58, .57, .57, 0);
}
