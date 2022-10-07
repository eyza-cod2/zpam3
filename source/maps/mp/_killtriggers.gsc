init()
{
	if(isdefined(level.killtriggers))
	{
		for(i = 0; i < level.killtriggers.size; i++)
		{
			killtrigger = level.killtriggers[i];
			killtrigger.origin = (killtrigger.origin[0], killtrigger.origin[1], (killtrigger.origin[2] - 16));
		}

		playerradius = 16;

		for(;;)
		{
			players = getentarray("player", "classname");
			counter = 0;
			
			for(i = 0; i < players.size; i++)
			{
				player = players[i];
				
				if(isdefined(player) && isdefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
				{
					player checkKillTriggers();
					counter++;
					
					if(!(counter % 4))
					{
						wait .05;
						counter = 0;
					}
				}
			}
			
			wait .05;
		}
	}
}

checkKillTriggers()
{
	playerradius = 16;
	
	for(i = 0; i < level.killtriggers.size; i++)
	{
		killtrigger = level.killtriggers[i];
		diff = killtrigger.origin - self.origin;
	
		if((self.origin[2] >= killtrigger.origin[2]) && (self.origin[2] <= killtrigger.origin[2] + killtrigger.height))
		{
	        diff2 = (diff[0], diff[1], 0);
	
	        if(length(diff2) < killtrigger.radius + playerradius)
	        {
				self suicide();
				return;
	        }
		}
	}
}
