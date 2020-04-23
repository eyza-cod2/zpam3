main()
{
	maps\mp\mp_decoy_fx::main();
	maps\mp\_load::main();

	Ambient_Sound();

	game["allies"] = "british";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["british_soldiertype"] = "africa";
	game["german_soldiertype"] = "africa";

	setcvar("r_glowbloomintensity0","0");
	setcvar("r_glowbloomintensity1","0");
	setcvar("r_glowskybleedintensity0","0");

	if((level.gametype == "hq"))
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (9402, -13535, -500));
		level.radio[0].angles = (358, 60, 2.22);

		level.radio[1] = spawn("script_model", (8563, -14178, -693));
		level.radio[1].angles = (356, 60, 6.86);

		level.radio[2] = spawn("script_model", (7780, -13970, -536));
		level.radio[2].angles = (0, 300, 0);

		level.radio[3] = spawn("script_model", (7618, -12650, -497));
		level.radio[3].angles = (0, 15, 0);

		level.radio[4] = spawn("script_model", (6377, -13422, -493));
		level.radio[4].angles = (357, 269.6, 0);

		level.radio[5] = spawn("script_model", (7363.66, -13329.8, -577.496));
		level.radio[5].angles = (1.68365, 205.676, -3.8154);


	}

}

Ambient_Sound()
{
	if ( level.scr_allow_ambient_sounds )
		ambientPlay("ambient_africa");
}
