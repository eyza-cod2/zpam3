#include maps\mp\gametypes\global\_global;

/*
Via script we are able to detect if some player starts using a MG.
To detect if player drop the MG, we will use that player position accesed via player.origin is beeing overwriten when player is using MG
Even if we link player to specific tag, the position is overwrited.
So when player start using MG, we lock player position exacly behind MG. Since position is overwrited by the game, player moves normally while using MG..
When player drops MG, he will be moved to locked position (because of link)
If players position equals the locked position, it means player drops the MG and we can unlink him.
Via this player always spawn behind the MG when he drop it
*/

init()
{
	addEventListener("onConnected",     ::onConnected);
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("scr_mg_peek_fix", "BOOL", 0);

	if (level.scr_mg_peek_fix)
	{
		wait level.frame;	// wait a frame - MGs can be removed by other scripts
		start();
	}
}

onConnected()
{
	self.usingMG = false;
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_mg_peek_fix":
			level.scr_mg_peek_fix = value;
			if (!isRegisterTime)
			{
				if (level.scr_mg_peek_fix) // changed to 1
				{
					start();
				}
				else
				{
					level notify("kill_mg_fix");
				}
			}
			return true;
	}
	return false;
}


start()
{
	handleTurretEntity("misc_turret");
	handleTurretEntity("misc_mg42");
}


handleTurretEntity(name)
{
	entities = getentarray(name, "classname");
        for(i = 0; i < entities.size; i++)
        {
            entities[i] thread waitTrigger();
        }
}


waitTrigger()
{
	level endon("kill_mg_fix");

	for(;;)
	{
		self waittill("trigger", player);

		// Player must be defined!
		if (!isDefined(player))
		    continue;

		player thread handleDrop(self);
	}
}

handleDrop(turret)
{
	self endon("disconnect");

	self.usingMG = true;
	//iprintln("Player "+self.name+ " is using MG");

	wait level.frame;

	// Compute position of player behid the MG
	forward = AnglesToForward( turret.angles ); // 1.0 scale
	dist = -30; // how far behind MG should player spawn
	pos = turret.origin + (forward[0] * dist, forward[1] * dist, forward[2] * dist); // new pos

	trace = bulletTrace(pos, (pos + (0, 0, -40)), false, undefined);
	if(trace["fraction"] < 1)
	{
		pos = trace["position"];
	}
	else
	{
		pos = pos + (0, 0, -24); // new pos
	}

	while (true)
	{
	        self setOrigin(pos);

	        wait level.frame;

		// Next frame the position of player is overwrited when using MG
		// Via that we can detect if player is still using the MG - by checking distance between position

		dist = distance(self.origin, pos);

	        if (dist < 2)
	          break;
	}

	//iprintln("Player "+self.name+ " dropped MG");

	self.usingMG = false;
}
