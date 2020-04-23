main()
{
	maps\mp\mp_rhine_fx::main();
	maps\mp\_load::main();

 	Ambient_Sound();

	game["allies"] = "american";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["american_soldiertype"] = "normandy";
	game["german_soldiertype"] = "normandy";

	setCvar("r_glowbloomintensity0", ".25");
	setCvar("r_glowbloomintensity1", ".25");
	setcvar("r_glowskybleedintensity0",".3");

	if(level.gametype == "hq")
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (3050, 15816, 400));
		level.radio[0].angles = (0, 270, 0);

		level.radio[1] = spawn("script_model", (4573, 15698.6, 363.984));
		level.radio[1].angles = (355.898, 97.3474, -4.13478);

		level.radio[2] = spawn("script_model", (4472, 17144, 506.143));
		level.radio[2].angles = (354.045, 89.9709, -1.28846);

		level.radio[3] = spawn("script_model", (5329, 16100, 494.945));
		level.radio[3].angles = (349.815, 355.492, 24.0316);

		level.radio[4] = spawn("script_model", (5887.67, 15554, 408.859));
		level.radio[4].angles = (0.784237, 354.371, 1.5749);

		level.radio[5] = spawn("script_model", (7342, 15548, 442.041));
		level.radio[5].angles = (4.60768, 174.308, -0.943653);

		level.radio[6] = spawn("script_model", (6473.24, 14479.8, 423.517));
		level.radio[6].angles = (358.085, 17.8576, 9.8757);

		level.radio[7] = spawn("script_model", (5804, 15101, 434));
		level.radio[7].angles = (0, 107.858, 0);

		level.radio[8] = spawn("script_model", (3415, 14729, 377.487));
		level.radio[8].angles = (16.3467, 268.252, -6.18853);


	}


}

Ambient_Sound()
{
	if ( level.scr_allow_ambient_sounds )
		ambientPlay("ambient_france");

	if ( level.scr_allow_ambient_fog )
		setExpFog(0.0001, 0.55, 0.6, 0.55, 0);
}
