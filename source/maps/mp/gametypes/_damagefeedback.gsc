#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("scr_show_hitblip", "BOOL", 1);

	if(game["firstInit"])
	{
		precacheShader("damage_feedback");
		precacheRumble("damage_heavy");

		precacheString2("STRING_ASSIST", &"assist");
	}
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_show_hitblip": 	level.scr_show_hitblip = value; return true;
	}
	return false;
}

updateDamageFeedback(enemy, count)
{
	self endon("disconnect");

	// Make sure only one thread is running
	self notify("updateDamageFeedback");
	self endon("updateDamageFeedback");

	waittillframeend; // wait intill player is killed

	if (level.scr_show_hitblip)
	{
		if(isPlayer(self))
		{
			// Play hit sound
			for (i = 1; i <= count; i++)
			{
				self playlocalsound("MP_hit_alert");
			}


			if (!isDefined(self.hud_damagefeedback))
			{
				self.hud_damagefeedback = newClientHudElem2(self);
				self.hud_damagefeedback.horzAlign = "center";
				self.hud_damagefeedback.vertAlign = "middle";
				self.hud_damagefeedback.x = -12;
				self.hud_damagefeedback.y = -12;
				self.hud_damagefeedback.alpha = 0;
				self.hud_damagefeedback.archived = true;
				self.hud_damagefeedback setShader("damage_feedback", 24, 24);
			}

			alpha = 1;
			time = 1.2;
			delay = 0.25;
			color = (1,1,1);
			if (isPlayer(enemy) && level.gametype == "sd" /*&& !level.in_readyup*/)
			{
				if (enemy.pers["team"] == self.pers["team"])
					color = (1,0.5,0.5);
				else if (isAlive(enemy))
				{
					// Hit only
					alpha = 0.75;
					time = 1;
					delay = 0;
				}
			}

			//iprintln("playing feedback, alpha: " + alpha);


			self.hud_damagefeedback.color = color;

			self.hud_damagefeedback fadeOverTime(0.00001);	// cancel fade time


			self.hud_damagefeedback.alpha = alpha;



			wait delay * level.fps_multiplier;

			self.hud_damagefeedback fadeOverTime(time);
			self.hud_damagefeedback.alpha = 0;




		}
	}
}

updateAssistsFeedback()
{
	if (level.scr_show_hitblip)
	{
		if(isPlayer(self))
		{
			if (!isDefined(self.hud_assistfeedback))
			{
				self.hud_assistfeedback = newClientHudElem2(self);
				self.hud_assistfeedback.horzAlign = "center";
				self.hud_assistfeedback.vertAlign = "middle";
				self.hud_assistfeedback.x = 0;
				self.hud_assistfeedback.y = 20;
				self.hud_assistfeedback.alpha = 0;
				self.hud_assistfeedback.archived = true;
				self.hud_assistfeedback.color = (1,1,1);
				self.hud_assistfeedback.fontSize = 1.1;
				self.hud_assistfeedback setText(game["STRING_ASSIST"]);
			}

			self.hud_assistfeedback.alpha = 1;
			self.hud_assistfeedback fadeOverTime(1.3);
			self.hud_assistfeedback.alpha = 0;
		}
	}
}
