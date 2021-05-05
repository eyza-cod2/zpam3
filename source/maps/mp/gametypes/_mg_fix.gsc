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
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvarEx("C", "scr_mg_peek_fix", "BOOL", 0);

	if (level.scr_mg_peek_fix)
		start();
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

	//iprintln("Player "+self.name+ " is using MG");

	wait level.frame;

	tempTag = spawn("script_model", (999999, 999999, 999999));

	// Compute position of player behid the MG
	forward = AnglesToForward( turret.angles ); // 1.0 scale
	dist = -30; // how far behind MG should player spawn
	pos = turret.origin + (forward[0] * dist, forward[1] * dist, -24); // new pos


	while (isDefined(self))
	{
	        self setOrigin(pos);
	        self linkto(tempTag);

	        wait level.frame;
	        waittillframeend;

		// Even we linked player to tag, next frame the position of player is overwrited when using MG
		// Via that we can detect if player is still using the MG - by checking distance between position

		dist = distance(self.origin, pos);

		self unlink();

	        if (dist < 2)
	          break;
	}

	tempTag delete();

	//iprintln("Player "+self.name+ " dropped MG");
}
