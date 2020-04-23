#include maps\mp\_utility;

/*
	****************************************************************************************************************
	OneShotfx: Fires an effect once.
	maps\_fx::OneShotfx( effectname, (x y z), predelay);

	Example:
	maps\_fx::OneShotfx(level.medFire,		// Medium fire effect
					(-701, -18361, 148),	// Origin
					5);						// Wait 5 seconds before doing effect
	****************************************************************************************************************


	****************************************************************************************************************
	Loopfx: Loops an effect with a waittime.
	maps\_fx::loopfx( effectname, (x y z), delay_between_shots);

	Example:
	maps\_fx::loopfx(level.medFire,			// Medium fire effect
					(-701, -18361, 148),	// Origin
					0.3);					// Wait 0.3 seconds between shots
	****************************************************************************************************************


	****************************************************************************************************************
	GunFireLoopfx: Simulates bursts of fire.
	maps\_fx::gunfireloopfx(fxId, fxPos, shotsMin, shotsMax, shotdelayMin, shotdelayMax, betweenSetsMin, betweenSetsMax)

	Example:
	maps\_fx::gunfireloopfx (level.medFire,			// Medium fire effect
							(-701, -18361, 148),	// Origin
							10, 15,					// 10 to 15 shots
							0.1, 0.3,				// 0.1 to 0.3 seconds between shots
							2.5, 9);				// 2.5 to 9 seconds between sets of shots.
	****************************************************************************************************************

	****************************************************************************************************************
	GrenadeExplosionfx: Creates a grenade explosion with view jitter.
	maps\_fx::GrenadeExplosionfx((x y z));

	Example:
	maps\_fx::GrenadeExplosionfx( (-701, -18361, 148) ); // origin
	****************************************************************************************************************
*/

/*
{
"origin" "-451 -14930 26"
"targetname" "auto1166"
"classname" "script_origin"
}
*/

print_org (fxcommand, fxId, fxPos, waittime)
{
	if (getcvar("debug") == "1")
	{
		println ("{");
		println ("\"origin\" \"" + fxPos[0] + " " + fxPos[1] + " " + fxPos[2] + "\"");
		println ("\"classname\" \"script_model\"");
		println ("\"model\" \"xmodel/fx\"");
		println ("\"script_fxcommand\" \"" + fxcommand + "\"");
		println ("\"script_fxid\" \"" + fxId + "\"");
		println ("\"script_delay\" \"" + waittime + "\"");
		println ("}");
	}
}

OneShotfx(fxId, fxPos, waittime, fxPos2)
{
	level thread print_org ("OneShotfx", fxId, fxPos, waittime);
    level thread OneShotfxthread (fxId, fxPos, waittime, fxPos2);
}

OneShotfxthread ( fxId, fxPos, waittime, fxPos2 )
{
	wait level.frame; // waitframe

    wait level.fps_multiplier * waittime;
    if (isdefined (fxPos2))
		fxPos2 = vectornormalize (fxPos2 - fxPos);

	if (isdefined (fxPos2))
		playfx ( level._effect[fxId], fxPos, fxPos2 );
	else
		playfx ( level._effect[fxId], fxPos);
}

exploderfx(num, fxId, fxPos, waittime, fxPos2, fireFx, fireFxDelay, fireFxSound, fxSound, fxQuake, fxDamage, soundalias)
{
	fx = spawn("script_origin", (0,0,0));
	//println ("total ", getentarray ("script_origin","classname").size);
	fx.origin = fxPos;
	fx.angles = vectortoangles(fxPos2 - fxPos);
//	fx.targetname = "exploder";
	fx.script_exploder = num;
	fx.script_fxid = fxId;
	fx.script_delay = waittime;

	fx.script_firefx = fireFx;
	fx.script_firedelay = fireFxDelay;
	fx.script_firefxsound = fireFxSound;

	fx.script_sound = fxSound;
	fx.script_earthquake = fxQuake;
	fx.script_damage = fxDamage;
	fx.script_soundalias = soundalias;

	forward = anglestoforward(fx.angles);
	forward = vectorScale(forward, 150);
	fx.targetPos = fxPos + forward;

	if (!isdefined(level._script_exploders))
		level._script_exploders = [];
	level._script_exploders[level._script_exploders.size] = fx;

	maps\mp\_createfx::createfx_showOrigin(fxid, fxPos, waittime, fxpos2, "exploderfx", fx);
}

loopfx(fxId, fxPos, waittime, fxPos2, fxStart, fxStop, timeout)
{
	//level thread print_org ("loopfx", fxId, fxPos, waittime);
    level thread loopfxthread (fxId, fxPos, waittime, fxPos2, fxStart, fxStop, timeout);
}

/*
loopfxRotate(fxId, fxPos, waittime, angle, fxStart, fxStop, timeout)
{
	level thread print_org ("loopfx", fxId, fxPos, waittime);
    level thread loopfxthread (fxId, fxPos, waittime, fxPos2, fxStart, fxStop, timeout);
}
*/

loopfxthread ( fxId, fxPos, waittime, fxPos2, fxStart, fxStop, timeout )
{
	ent = undefined;

	ent = spawnstruct();
	ent.id = fxId;
	ent.org = fxPos;
	ent.delay = waittime;
	ent.org2 = fxPos2;


	wait level.frame; // waitframe
//	println ( "fx testing running Id: ", fxId );
    if ((isdefined (level.scr_sound)) && (isdefined (level.scr_sound[fxId])))
	   loopSound(level.scr_sound[fxId], fxPos);


	dist = 0;

	if (isdefined (fxStart))
		level waittill ("start fx" + fxStart);

	while (1)
	{
		if (isdefined (ent.org2))
		{
			fxAngle = vectorNormalize (ent.org2 - ent.org);
			looper = playLoopedFx( level._effect[fxId], ent.delay, ent.org, dist, fxAngle );
		}
		else
			looper = playLoopedFx( level._effect[fxId], ent.delay, ent.org, dist );

		if (isdefined (timeout))
			looper thread loopfxStop(timeout);

		if (isdefined (fxStop))
			level waittill ("stop fx" + fxStop);
		else
			return;

		if (isdefined (looper))
			looper delete();

		if (isdefined (fxStart))
			level waittill ("start fx" + fxStart);
		else
			return;
	}
}

loopfxStop (timeout)
{
	self endon("death");
	wait(level.fps_multiplier * timeout);
	self delete();
}

loopSound(sound, Pos, waittime)
{
//	level thread print_org ("loopSound", sound, Pos, waittime);
	level thread loopSoundthread (sound, Pos, waittime);
}

loopSoundthread ( sound, pos, waittime )
{
	org = spawn ("script_origin", (pos));

	org.origin = pos;
//	println ("hello1 ", org.origin, sound);
	org playLoopSound ( sound );
}

gunfireloopfx(fxId, fxPos, shotsMin, shotsMax, shotdelayMin, shotdelayMax, betweenSetsMin, betweenSetsMax)
{
    thread gunfireloopfxthread (fxId, fxPos, shotsMin, shotsMax, shotdelayMin, shotdelayMax, betweenSetsMin, betweenSetsMax);
}

gunfireloopfxthread (fxId, fxPos, shotsMin, shotsMax, shotdelayMin, shotdelayMax, betweenSetsMin, betweenSetsMax)
{
	level endon ("stop all gunfireloopfx");
	wait level.fps_multiplier * .05; // waitframe

	if (betweenSetsMax < betweenSetsMin)
	{
		temp = betweenSetsMax;
		betweenSetsMax = betweenSetsMin;
		betweenSetsMin = temp;
	}

	betweenSetsBase = betweenSetsMin;
	betweenSetsRange = betweenSetsMax - betweenSetsMin;

	if (shotdelayMax < shotdelayMin)
	{
		temp = shotdelayMax;
		shotdelayMax = shotdelayMin;
		shotdelayMin = temp;
	}

	shotdelayBase = shotdelayMin;
	shotdelayRange = shotdelayMax - shotdelayMin;

	if (shotsMax < shotsMin)
	{
		temp = shotsMax;
		shotsMax = shotsMin;
		shotsMin = temp;
	}

	shotsBase = shotsMin;
	shotsRange = shotsMax - shotsMin;

    for (;;)
    {
		shotnum = shotsBase + randomint (shotsRange);
		for (i=0;i<shotnum;i++)
		{
			playfx ( level._effect[fxId], fxPos );

			wait level.fps_multiplier * (shotdelayBase + randomfloat (shotdelayRange));
		}
        wait level.fps_multiplier * (betweenSetsBase + randomfloat(betweenSetsRange));
    }
}

gunfireloopfxVec(fxId, fxPos, fxPos2, shotsMin, shotsMax, shotdelayMin, shotdelayMax, betweenSetsMin, betweenSetsMax)
{
    thread gunfireloopfxVecthread (fxId, fxPos, fxPos2, shotsMin, shotsMax, shotdelayMin, shotdelayMax, betweenSetsMin, betweenSetsMax);
}

gunfireloopfxVecthread (fxId, fxPos, fxPos2, shotsMin, shotsMax, shotdelayMin, shotdelayMax, betweenSetsMin, betweenSetsMax)
{
	level endon ("stop all gunfireloopfx");
	wait level.fps_multiplier * .05; // waitframe

	if (betweenSetsMax < betweenSetsMin)
	{
		temp = betweenSetsMax;
		betweenSetsMax = betweenSetsMin;
		betweenSetsMin = temp;
	}

	betweenSetsBase = betweenSetsMin;
	betweenSetsRange = betweenSetsMax - betweenSetsMin;

	if (shotdelayMax < shotdelayMin)
	{
		temp = shotdelayMax;
		shotdelayMax = shotdelayMin;
		shotdelayMin = temp;
	}

	shotdelayBase = shotdelayMin;
	shotdelayRange = shotdelayMax - shotdelayMin;

	if (shotsMax < shotsMin)
	{
		temp = shotsMax;
		shotsMax = shotsMin;
		shotsMin = temp;
	}

	shotsBase = shotsMin;
	shotsRange = shotsMax - shotsMin;

	fxPos2 = vectornormalize (fxPos2 - fxPos);

	for (;;)
	{
		shotnum = shotsBase + randomint (shotsRange);
		for (i=0;i<shotnum;i++)
		{
			playfx ( level._effect[fxId], fxPos, fxPos2);
			wait level.fps_multiplier * (shotdelayBase + randomfloat (shotdelayRange));
		}
		wait level.fps_multiplier * (shotdelayBase + randomfloat (shotdelayRange));
		wait level.fps_multiplier * (betweenSetsBase + randomfloat(betweenSetsRange));
	}
}

GrenadeExplosionfx(pos)
{
	playfx (level._effect["mechanical explosion"], pos);
	earthquake(0.15, 0.5, pos, 250);
}

soundfx(fxId, fxPos)
{
	org = spawn ("script_origin",(0,0,0));
	org.origin = fxPos;
	org playloopsound (fxId);


	ent = level thread maps\mp\_createfx::createfx_showOrigin ( fxId, fxPos, undefined, undefined, "soundfx" );
	ent.delay = 0;
	ent endon ("effect deleted");
	ent.soundfx = org;

}
