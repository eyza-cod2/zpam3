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



updateDamageFeedback(enemy)
{
	self endon("disconnect");

	// Create variable to hold data about players hit in this frame
	if (!isDefined(self.hitPlayers))
		self.hitPlayers = [];

	// Enemy might be undefined when called programmatically
	if (isPlayer(enemy)) {
		enemy_num = enemy getEntityNumber();
		if (!isDefined(self.hitPlayers[enemy_num])) {
			self.hitPlayers[enemy_num] = []; // false = hit, true = kill
			self.hitPlayers[enemy_num]["kill"] = false; // false = hit, true = kill
			self.hitPlayers[enemy_num]["player"] = enemy; // false = hit, true = kill
		}
	}


	waittillframeend; // wait until player is killed

	if (isPlayer(enemy) && !isAlive(enemy)) {
		enemy_num = enemy getEntityNumber();
		self.hitPlayers[enemy_num]["kill"] = true; // set kill
	}

	// Make sure only one thread is running
	self notify("updateDamageFeedback");
	self endon("updateDamageFeedback");


	waittillframeend; // ensure this func runs only once per frame


	// Data processing
	numberOfHitPlayers = int(self.hitPlayers.size);
	containKill = !isPlayer(enemy); // false as default if enemy is defined, true if enemy is undefined (called programmatically)
	containTeamShot = false;
	containEnemyShot = false;
	allKilled = true;
	for (i = 0; i < 64; i++) {
		if (!isDefined(self.hitPlayers[i]))
			continue;
		// false = hit, true = kill
		if (self.hitPlayers[i]["kill"]) {
			containKill = true;
		} else {
			allKilled = false;
		}

		e = self.hitPlayers[i]["player"];
		if (isPlayer(e) && e.pers["team"] == self.pers["team"] && level.gametype != "dm")
			containTeamShot = true;
		else if (isPlayer(e) && e.pers["team"] != self.pers["team"] || level.gametype == "dm")
			containEnemyShot = true;
	}

	self.hitPlayers = undefined;



	if (level.scr_show_hitblip)
	{
		if(isPlayer(self))
		{
			// Play again if its kill, so hits and kills are more distinguishable
			for (i = 1; i <= numberOfHitPlayers; i++) {
				self playLocalSound("MP_hit_alert");
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

			if (numberOfHitPlayers >= 2 && !isDefined(self.hud_damagefeedback2)) {
				self.hud_damagefeedback2 = newClientHudElem2(self);
				self.hud_damagefeedback2.horzAlign = "center";
				self.hud_damagefeedback2.vertAlign = "middle";
				self.hud_damagefeedback2.x = -13;
				self.hud_damagefeedback2.y = -10;
				self.hud_damagefeedback2.alpha = 0;
				self.hud_damagefeedback2.archived = true;
				self.hud_damagefeedback2 setShader("damage_feedback", 26, 20);
			}

			// | Alpha 100%    | Alpha transitioning to 0 |
			// | Delay time    | Time                     |

			// Times for kill
			alpha = 1;
			time = 0.5;
			delay = 0.8;
			color = (1,1,1);
			width = 28;
			offset = -14;

			// Hit only
			if (!containKill)
			{
				alpha = 0.7;
				time = 1.2;
				delay = 0;
				width = 24;
				offset = -12;
				color = (1,1,0.85); // yellowish
			}

			// Team hit/kill
			if (containTeamShot && !containEnemyShot)
				color = (1,0.5,0.5);



			self.hud_damagefeedback.color = color;
			self.hud_damagefeedback fadeOverTime(0.00001);	// cancel fade time
			self.hud_damagefeedback scaleOverTime(0.00001, width, width);	// cancel scale time
			self.hud_damagefeedback moveOverTime(0.00001);	// cancel move time
			self.hud_damagefeedback.alpha = alpha;
			self.hud_damagefeedback.x = offset;
			self.hud_damagefeedback.y = offset;


			if (numberOfHitPlayers >= 2) {

				alpha2 = 1;
				color2 = (1, 1, 1);

				if (!allKilled) {
					color2 = (1,1,0.85); // yellowish
					alpha2 = 0.7;
				}
				// Team hit/kill
				if (containTeamShot)
					color2 = (1,0.5,0.5);

				self.hud_damagefeedback2.color = color2;
				self.hud_damagefeedback2 fadeOverTime(0.00001);	// cancel fade time
				self.hud_damagefeedback2.alpha = alpha2;
			} else if (isDefined(self.hud_damagefeedback2)) {
				self.hud_damagefeedback2.alpha = 0;
			}

			wait level.frame;

			self.hud_damagefeedback scaleOverTime(0.15, 24, 24);
			self.hud_damagefeedback moveOverTime(0.15);
			self.hud_damagefeedback.x = -12;
			self.hud_damagefeedback.y = -12;


			wait delay * level.fps_multiplier;

			self.hud_damagefeedback fadeOverTime(time);
			self.hud_damagefeedback.alpha = 0;

			if (numberOfHitPlayers >= 2) {
				self.hud_damagefeedback2 fadeOverTime(time);
				self.hud_damagefeedback2.alpha = 0;
			}
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
