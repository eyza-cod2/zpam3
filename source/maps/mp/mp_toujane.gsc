main()
{
	// Fix problem with plants - if bomb explodes, there is no tank explosion effect -> fixed
	// Find bombzones (2 bomzones, A and B)
	array = getentarray("bombzone", "targetname");
	bombzoneA = array[0];
	bombzoneB = array[1];

	ents = getentarray("script_brushmodel", "classname");
	smodels = getentarray("script_model", "classname");
	for(i = 0; i < smodels.size; i++)
		ents[ents.size] = smodels[i];

	// Find the correct entity - its enttity where targetname is empty (and needs to be filled with name, that needs to be saved into bombzone.target)
	for(i = 0; i < ents.size; i++)
	{
		if(isdefined(ents[i].script_exploder))
		{
			if (ents[i].model == "xmodel/fx" && !isDefined(ents[i].targetname))
			{
				if (ents[i].script_exploder == 3801)
				{
					ents[i].targetname = "pf3801_auto1";
					bombzoneA.target = "pf3801_auto1";
				}
				else if (ents[i].script_exploder == 3882)
				{
					ents[i].targetname = "pf3882_auto1";
					bombzoneB.target = "pf3882_auto1";
				}
			}
		}
	}


	// Fix texture bugs
	maps\mp\_bug_fix::toujane();

	maps\mp\mp_toujane_fx::main();
	maps\mp\_load::main();

	Ambient_Sound();

	game["allies"] = "british";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["british_soldiertype"] = "africa";
	game["german_soldiertype"] = "africa";

	setcvar("r_glowbloomintensity0",".25");
	setcvar("r_glowbloomintensity1",".25");
	setcvar("r_glowskybleedintensity0",".5");

	if(level.gametype == "hq")
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (285.332, 471.947, 12.1747));
		level.radio[0].angles = (0, 335.6, 0);

		level.radio[1] = spawn("script_model", (-7.80745, 1100.36, -11.0072));
		level.radio[1].angles = (355.751, 55.1337, -2.21861);

		level.radio[2] = spawn("script_model", (1282.54, 731.845, -1.99999));
		level.radio[2].angles = (0, 133.073, 0);

		level.radio[3] = spawn("script_model", (2206.32, 411.609, 54.6547));
		level.radio[3].angles = (2.21806, 151.797, -7.6227);

		level.radio[4] = spawn("script_model", (758.63, 1725.03, 148));
		level.radio[4].angles = (0, 354.855, 0);

		level.radio[5] = spawn("script_model", (1558.4, 1569.03, 96.0133));
		level.radio[5].angles = (0.629538, 196.751, -2.07329);

		level.radio[6] = spawn("script_model", (986.298, 3040.61, 58.7701));
		level.radio[6].angles = (0.640552, 196.255, -3.11342);

		level.radio[7] = spawn("script_model", (2295.88, 2483.53, 70.7077));
		level.radio[7].angles = (1.35945, 129.516, 1.18606);

		level.radio[8] = spawn("script_model", (2971.51, 1570.41, 45.4606));
		level.radio[8].angles = (0.282498, 74.994, -0.237561);

		level.radio[9] = spawn("script_model", (1758, 653.443, 176));
		level.radio[9].angles = (0, 39.351, 0);
	}

	if (!level.scr_remove_killtriggers)
	{
		level.killtriggers[0] = spawnstruct();
		level.killtriggers[0].origin = (2025, 1835, 316);
		level.killtriggers[0].radius = 277;
		level.killtriggers[0].height = 80;

		level.killtriggers[1] = spawnstruct();
		level.killtriggers[1].origin = (1968, 1572, 284);
		level.killtriggers[1].radius = 50;
		level.killtriggers[1].height = 30;

		level.killtriggers[2] = spawnstruct();
		level.killtriggers[2].origin = (2060, 1584, 284);
		level.killtriggers[2].radius = 50;
		level.killtriggers[2].height = 30;

		level.killtriggers[3] = spawnstruct();
		level.killtriggers[3].origin = (736, 1652, 232);
		level.killtriggers[3].radius = 110;
		level.killtriggers[3].height = 140;

		level.killtriggers[4] = spawnstruct();
		level.killtriggers[4].origin = (584, 944, 296);
		level.killtriggers[4].radius = 280;
		level.killtriggers[4].height = 140;

		level.killtriggers[5] = spawnstruct();
		level.killtriggers[5].origin = (1850, 2855, 298);
		level.killtriggers[5].radius = 12;
		level.killtriggers[5].height = 12;

		level.killtriggers[6] = spawnstruct();
		level.killtriggers[6].origin = (1616, 720, 256);
		level.killtriggers[6].radius = 12;
		level.killtriggers[6].height = 12;

		level.killtriggers[7] = spawnstruct();
		level.killtriggers[7].origin = (1320, 536, 302);
		level.killtriggers[7].radius = 12;
		level.killtriggers[7].height = 12;

		level.killtriggers[8] = spawnstruct();
		level.killtriggers[8].origin = (1932, 1054, 336);
		level.killtriggers[8].radius = 12;
		level.killtriggers[8].height = 12;

		if (level.gametype != "strat")
			thread maps\mp\_killtriggers::init();
	}
}

Ambient_Sound()
{
	if ( level.scr_allow_ambient_sounds )
		ambientPlay("ambient_africa");

	if ( level.scr_allow_ambient_fog )
		setExpFog(0.00015, 0.9, 0.95, 1, 0);

	//setcullfog(3000, 10000, 0.7, 0.85, 1.0, 50);
}
