main()
{
	thread maps\mp\_minefields::minefields();
	thread maps\mp\_shutter::main();

	// create light effect for lanterns
	lanterns = getentarray("lantern_glowFX_origin","targetname");
	for( i = 0 ; i < lanterns.size ; i++ )
		lanterns[i] thread lanterns();


	// Hide exploder models.
	ents = getentarray("script_brushmodel", "classname");
	smodels = getentarray("script_model", "classname");
	for(i = 0; i < smodels.size; i++)
		ents[ents.size] = smodels[i];

	for(i = 0; i < ents.size; i++)
	{
		if(isdefined(ents[i].script_exploder))
		{
			if((ents[i].model == "xmodel/fx") && ((!isdefined(ents[i].targetname)) || (ents[i].targetname != "exploderchunk")))
				ents[i] hide();
			else if((isdefined(ents[i].targetname)) && (ents[i].targetname == "exploder"))
			{
				ents[i] hide();
				ents[i] notsolid();
			}
			else if((isdefined(ents[i].targetname)) && (ents[i].targetname == "exploderchunk"))
			{
				ents[i] hide();
				ents[i] notsolid();
			}
		}
	}

	ents = undefined;


	// Do various things on triggers
	for(p = 0; p < 5; p++)
	{
		switch (p)
		{
			case 0:
				triggertype = "trigger_multiple";
				break;

			case 1:
				triggertype = "trigger_once";
				break;

			case 2:
				triggertype = "trigger_use";
				break;

			case 3:
				triggertype = "trigger_radius";
				break;

			default:
				assert(p == 4);
				triggertype = "trigger_damage";
				break;
		}

		triggers = getentarray(triggertype, "classname");
		for(i = 0; i < triggers.size; i++)
		{
			if(isdefined(triggers[i].script_exploder))
				level thread exploder(triggers[i]);
		}
	}

	level._script_exploders = [];

	potentialExploders = getentarray("script_brushmodel", "classname");
	for(i = 0; i < potentialExploders.size; i++)
	{
		if(isdefined(potentialExploders[i].script_exploder))
			level._script_exploders[level._script_exploders.size] = potentialExploders[i];
	}

	potentialExploders = getentarray("script_model", "classname");
	for(i = 0; i < potentialExploders.size; i++)
	{
		if(isdefined(potentialExploders[i].script_exploder))
			level._script_exploders[level._script_exploders.size] = potentialExploders[i];
	}
}

exploder(trigger)
{
	level endon("killexplodertriggers"+trigger.script_exploder);
	trigger waittill("trigger");
//	println("TRIGGERED");
	exploder(trigger.script_exploder);
	level notify ("killexplodertriggers"+trigger.script_exploder);
}

lanterns()
{
	if (!isdefined(level._effect["lantern_light"]))
		level._effect["lantern_light"]	= loadfx("fx/props/glow_latern.efx");
	maps\mp\_fx::loopfx("lantern_light", self.origin, 0.3, self.origin + (0,0,1));
}
