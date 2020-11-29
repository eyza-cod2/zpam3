#include maps\mp\gametypes\_callbacksetup;

init()
{
	if (game["is_public_mode"])
		return;
	if (level.gametype != "sd")
		return;
	if (level.in_readyup)
		return;

	level.autoSpectating_forceTime = 0;

	addEventListener("onConnected",  ::onConnected);
	addEventListener("onSpawnedSpectator",  ::onSpawnedSpectator);
}

onConnected()
{
	if (!isDefined(self.pers["autoSpectating"]))
		self.pers["autoSpectating"] = false;
	if (!isDefined(self.pers["autoSpectatingID"]))
		self.pers["autoSpectatingID"] = -1;
	self.autoSpectating_timer = 0;

	self thread watchAction();
}

onSpawnedSpectator()
{
	if (self.pers["team"] == "spectator")
	{
		thread spectator_mode();

		thread autoSpectator();
	}
}

spectator_mode()
{
	self endon("disconnect");

	wait level.fps_multiplier * .5;

	// DEFINING ARRAY FOR AXIS
	self.health_background_axis = [];
	self.healthbar_axis = [];
	self.playername_axis = [];

	// DEFINING ARRAY FOR ALLIES
	self.health_background_allies = [];
	self.healthbar_allies = [];
	self.playername_allies = [];

	// MAKING AXIS BOXES
	for(i = 0; i < 5; i++)
	{
		y_pos = 120 + (30 * i);
		self making_AXIS_boxes(i, y_pos);
	}

	// MAKING ALLIES BOXES
	for(i = 0; i < 5; i++)
	{
		y_pos = 120 + (30 * i);
		self making_ALLIES_boxes(i, y_pos);
	}

	self filling_boxes();
}

making_AXIS_boxes(i, y)
{
	self endon("disconnect");

	self.healthbar_axis[i] = newClientHudElem(self);
	self.healthbar_axis[i].x = 4;
	self.healthbar_axis[i].y = y + 1;
	self.healthbar_axis[i].horzAlign = "left";
	self.healthbar_axis[i].vertAlign = "top";
	self.healthbar_axis[i].color = (0, 0, .7);
	self.healthbar_axis[i].alpha = 0;
	self.healthbar_axis[i].sort = 1;
	self.healthbar_axis[i].filled = false;
	self.healthbar_axis[i].archived = false;

	self.playername_axis[i] = newClientHudElem(self);
	self.playername_axis[i].x = 8;
	self.playername_axis[i].y = y + 3.5;
	self.playername_axis[i].horzalign = "left";
	self.playername_axis[i].vertalign = "top";
	self.playername_axis[i].sort = 2;
	self.playername_axis[i].fontScale = 1;
	self.playername_axis[i].color = (.8, 1, 1);
	self.playername_axis[i].archived = false;

	self.healthbar_axis[i] setShader(game["health_bar"], 128, 18);
}

making_ALLIES_boxes(i, y)
{
	self endon("disconnect");

	self.healthbar_allies[i] = newClientHudElem(self);
	self.healthbar_allies[i].x = -4;
	self.healthbar_allies[i].y = y + 1;
	self.healthbar_allies[i].horzAlign = "right";
	self.healthbar_allies[i].vertAlign = "top";
	self.healthbar_allies[i].color = (1, 0, 0);
	self.healthbar_allies[i].alignX = "right";
	self.healthbar_allies[i].alpha = 0;
	self.healthbar_allies[i].sort = 1;
	self.healthbar_allies[i].filled = false;
	self.healthbar_allies[i].archived = false;

	self.playername_allies[i] = newClientHudElem(self);
	self.playername_allies[i].x = -8;
	self.playername_allies[i].y = y + 3.5;
	self.playername_allies[i].horzalign = "right";
	self.playername_allies[i].vertalign = "top";
	self.playername_allies[i].alignX = "right";
	self.playername_allies[i].sort = 2;
	self.playername_allies[i].fontScale = 1;
	self.playername_allies[i].color = (.8, 1, 1);
	self.playername_allies[i].archived = false;

	//bar = Int(self.health * 1.28);

	self.healthbar_allies[i] setShader(game["health_bar"], 128, 18);
}

filling_boxes()
{
	self endon("disconnect");

	for(;;)
	{
		if (self.pers["team"] == "spectator")
		{
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				player = players[i];

				if (player.pers["team"] == "allies")
				{
					for(j = 0; j < 5; j++)
					{
						if(self.healthbar_allies[j].filled == false)
						{
							self.playername_allies[j] setplayernamestring(player);
							self.healthbar_allies[j].filled = true;

							health2 = player.health;

							if(isDefined(self.healthbar_allies[j]))
							{
								if (health2 <= 0)
								{
									self.healthbar_allies[j].alpha = 0;
									self.playername_allies[j].alpha = 0.5;
								}
								else
								{
									bar = Int(health2 * 1.28);

									self.healthbar_allies[j].alpha = 1;
									self.healthbar_allies[j] setShader(game["health_bar"], bar, 18);
									self.playername_allies[j].alpha = 1;
								}
							}
							break;
						}

					}
				}
				else if (player.pers["team"] == "axis")
				{
					for(j = 0; j < 5; j++)
					{
						if(self.healthbar_axis[j].filled == false)
						{
							self.playername_axis[j] setplayernamestring(player);
							self.healthbar_axis[j].filled = true;

							health2 = player.health;

							if(isDefined(self.healthbar_axis[j]))
							{
								if (health2 <= 0)
								{
									self.healthbar_axis[j].alpha = 0;
									self.playername_axis[j].alpha = 0.5;
								}
								else
								{
									bar = Int(health2 * 1.28);

									self.healthbar_axis[j].alpha = 1;
									self.healthbar_axis[j] setShader(game["health_bar"], bar, 18);
									self.playername_axis[j].alpha = 1;
								}
							}
							break;
						}
					}
				}
			}
			self unfill_boxes();
			wait level.fps_multiplier * 0.1;
		}
		else
		{
			for(c = 0; c < 5; c++)
			{
				if(isdefined(self.playername_allies[c]))
					self.playername_allies[c] destroy();
				if(isdefined(self.healthbar_allies[c]))
					self.healthbar_allies[c] destroy();
				if(isdefined(self.playername_axis[c]))
					self.playername_axis[c] destroy();
				if(isdefined(self.healthbar_axis[c]))
					self.healthbar_axis[c] destroy();
			}
			return;
		}
	}
}

unfill_boxes()
{
	self endon("disconnect");

	for(r = 0; r < 5; r++)
	{
		if(self.healthbar_allies[r].filled == false)
		{
			self.playername_allies[r] settext(game["empty"]);
			self.healthbar_allies[r] setShader(game["health_bar"], 128, 18);
			self.healthbar_allies[r].alpha = 0;
			self.playername_allies[r].alpha = 1;
		}

		if(self.healthbar_axis[r].filled == false)
		{
			self.playername_axis[r] settext(game["empty"]);
			self.healthbar_axis[r] setShader(game["health_bar"], 128, 18);
			self.healthbar_axis[r].alpha = 0;
			self.playername_axis[r].alpha = 1;
		}
	}

	for(r = 0; r < 5; r++)
	{
		self.healthbar_allies[r].filled = false;
		self.healthbar_axis[r].filled = false;
	}
}





autoSpectator()
{
	self endon("disconnect");

	if(!isdefined(self.autoSpectatingText))
	{
		self.autoSpectatingText = newClientHudElem(self);
		self.autoSpectatingText.horzAlign = "right";
		self.autoSpectatingText.vertAlign = "bottom";
		self.autoSpectatingText.alignX = "right";
		self.autoSpectatingText.alignY = "bottom";
		self.autoSpectatingText.x = -5;
		self.autoSpectatingText.y = -1;
		self.autoSpectatingText.archived = false;
		self.autoSpectatingText.font = "default";
		self.autoSpectatingText.fontscale = 0.75;
	}
	if(self.pers["autoSpectating"])
	{
		self.autoSpectatingText setText(game["STRING_AUTO_SPECT_ENABLED"]);

		// Follow previously active player
		if (self.pers["autoSpectatingID"] > -1)
			self.spectatorclient = self.pers["autoSpectatingID"];
	}
	else
		self.autoSpectatingText setText(game["STRING_AUTO_SPECT_DISABLED"]);

	for(;;)
	{
		// End this thread if player join team
		if (self.pers["team"] != "spectator")
		{
			self.autoSpectatingText destroy();
			self.autoSpectatingText = undefined;
			self.pers["autoSpectating"] = false;
			break;
		}

		if(self usebuttonpressed())
		{
			if(self.pers["autoSpectating"] == false)
			{
				self iprintlnbold(game["STRING_AUTO_SPECT_IS_ENABLED"]);
				self.autoSpectatingText setText(game["STRING_AUTO_SPECT_ENABLED"]);
				self.pers["autoSpectating"] = true;

				// Follow previously active player
				if (self.pers["autoSpectatingID"] > -1)
					self.spectatorclient = self.pers["autoSpectatingID"];
			}
			else
			{
				self iprintlnbold(game["STRING_AUTO_SPECT_IS_DISABLED"]);
				self.autoSpectatingText setText(game["STRING_AUTO_SPECT_DISABLED"]);
				self.pers["autoSpectating"] = false;

				self.spectatorclient = -1;
				self.pers["autoSpectatingID"] = -1;
			}

			// Wait untill key is released
			while(self usebuttonpressed())
			{
				wait level.fps_multiplier * 0.2;
			}
		}

		wait level.frame;
	}
}

// If player is firing, spectators are forced to follow this player
watchAction()
{
	self endon("disconnect");

	for(;;)
	{
		wait level.frame;

		if (isAlive(self) && self attackbuttonpressed())
		{
			if(gettime() - level.autoSpectating_forceTime > 5000)
			{
				// Set all spectators to follow this player
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					player = players[i];
					if (player.pers["team"] == "spectator" && player.pers["autoSpectating"])
					{
						player.spectatorclient = self getEntityNumber();

						level.autoSpectating_forceTime = gettime();
					}
					player.pers["autoSpectatingID"] = self getEntityNumber();
				}

				// Follow this player for atleast 5 sec
				wait level.fps_multiplier * 5;
			}
		}
	}
}
