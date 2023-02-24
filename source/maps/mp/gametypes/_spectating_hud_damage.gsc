#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onPlayerDamaged", 	::onPlayerDamaged); // In readyup show damage info for regular players

	if(game["firstInit"])
	{
		precacheString2("STRING_AUTO_SPECTATOR_HIT_HP", 		&"&&1 hp");

		precacheString2("STRING_AUTO_SPECTATOR_HIT_HEAD", 		&"Head");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_NECK", 		&"Neck");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_BODY", 		&"Torso");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_BODY_UPPER", 	&"Torso-up");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_BODY_LOWER", 	&"Torso-low");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_SHOULDER", 		&"Shoulder");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_ARM", 		&"Arm");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_HAND", 		&"Hand");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_LEG", 		&"Leg");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_LEG_UPPEER", 	&"Leg-up");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_LEG_LOWER", 		&"Leg-low");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_FOOT", 		&"Foot");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_GRENADE", 		&"Grenade");

		precacheString2("STRING_AUTO_SPECTATOR_HIT_SHOTGUN_1p", 	&"1 pellet");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_SHOTGUN_2p", 	&"2 pellets");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_SHOTGUN_3p", 	&"3 pellets");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_SHOTGUN_4p", 	&"4 pellets");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_SHOTGUN_5p", 	&"5 pellets");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_SHOTGUN_6p", 	&"6 pellets");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_SHOTGUN_7p", 	&"7 pellets");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_SHOTGUN_8p", 	&"8 pellets");

		precacheString2("STRING_AUTO_SPECTATOR_HIT_INFO_SHOTGUN_1_KILL", 	&"Range 1   (1 pellet needed for kill");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_INFO_SHOTGUN_1_HIT", 	&"Range 1   (2 pellets needed for kill (body not visible)");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_INFO_SHOTGUN_2", 		&"Range 2   (2 pellets needed for kill");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_INFO_SHOTGUN_3", 		&"Range 3   (3 pellets needed for kill");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_INFO_SHOTGUN_4", 		&"Range 4   (linear damage)");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_INFO_TORSO_HITBOX_FIX", 	&"Torso hitbox fix applied");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_INFO_HAND_HITBOX_FIX", 	&"Hand hitbox fix applied");

		precacheShader("headicon_dead");
	}

	if (!level.spectatingSystem)
		return;

	addEventListener("onPlayerKilled", 	::onPlayerKilled);
}


/*
Called when player has taken damage.
self is the player that took damage.
*/
onPlayerDamaged(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	waittillframeend; // wait untill all hits are processed

	if (isDefined(eAttacker) && isPlayer(eAttacker) && self != eAttacker)
	{
		// Damage info can be showed in 2 modes:
		//   - in readyup for regular players
		//   - for auto-spectators - show info for spectated player
		if (level.in_readyup ||
			(level.spectatingSystem && !level.in_readyup && isDefined(level.autoSpectating_spectatedPlayer) && eAttacker == level.autoSpectating_spectatedPlayer))
		{
			self_num = self getEntityNumber();
			isShotgun = sWeapon == "shotgun_mp" && sMeansOfDeath == "MOD_PISTOL_BULLET";

			pellets = 0;
			if (isShotgun)
				pellets = eAttacker.hitData[self_num].id;

			adjustedBy = eAttacker.hitData[self_num].adjustedBy;

			// In readyup for regular players
			if (level.in_readyup)
			{
				// For shotgun show accumulated damage
				if (isShotgun) 	damage = eAttacker.hitData[self_num].damage_comulated;
				else		damage = eAttacker.hitData[self_num].damage;

				eAttacker thread showDamageInfoReadyup(damage, sHitLoc, sMeansOfDeath, pellets, adjustedBy);
			}
			else // For auto-spactators
			{
				damage = eAttacker.hitData[self_num].damage_comulated;

				// Show to all spectators
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					player = players[i];
					if (player.pers["team"] == "spectator" && player.pers["autoSpectating"] && !isDefined(player.killcam))
					{
						player thread showDamageInfo(damage, sHitLoc, sMeansOfDeath, pellets, adjustedBy);
					}
				}
			}
		}
	}

	if (!level.spectatingSystem)
		return;

	if (isDefined(level.autoSpectating_spectatedPlayer) && self == level.autoSpectating_spectatedPlayer && !level.in_readyup)
	{
		damage = iDamage;
		if (isDefined(eAttacker) && isPlayer(eAttacker))
		{
			self_num = self getEntityNumber();
			damage = eAttacker.hitData[self_num].damage_comulated;
		}

		// Show to all spectators
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player.pers["team"] == "spectator" && player.pers["autoSpectating"] && !isDefined(player.killcam))
			{
				player thread showTakenDamageInfo(damage, sHitLoc, sMeansOfDeath);
			}
		}
	}
}

/*
Called when player is killed
self is the player that was killed.
*/
onPlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	if (isDefined(eAttacker) && isPlayer(eAttacker) && self != eAttacker && isDefined(level.autoSpectating_spectatedPlayer) && eAttacker == level.autoSpectating_spectatedPlayer && !level.in_readyup)
	{
		// Show to all spectators
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player.pers["team"] == "spectator" && player.pers["autoSpectating"])
			{
				player thread showKillInfo();
			}
		}
	}
}

showDamageInfo(damage, sHitLoc, sMeansOfDeath, pellets, adjustedBy)
{
	hitLocTexts["head"] = 			game["STRING_AUTO_SPECTATOR_HIT_HEAD"];
	hitLocTexts["neck"] = 			game["STRING_AUTO_SPECTATOR_HIT_NECK"];
	hitLocTexts["torso_upper"] = 		game["STRING_AUTO_SPECTATOR_HIT_BODY"];
	hitLocTexts["torso_lower"] = 		game["STRING_AUTO_SPECTATOR_HIT_BODY"];
	hitLocTexts["left_arm_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_SHOULDER"];
	hitLocTexts["left_arm_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_ARM"];
	hitLocTexts["left_hand"] = 		game["STRING_AUTO_SPECTATOR_HIT_HAND"];
	hitLocTexts["right_arm_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_SHOULDER"];
	hitLocTexts["right_arm_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_ARM"];
	hitLocTexts["right_hand"] = 		game["STRING_AUTO_SPECTATOR_HIT_HAND"];
	hitLocTexts["left_leg_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG"];
	hitLocTexts["left_leg_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG"];
	hitLocTexts["right_leg_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG"];
	hitLocTexts["right_leg_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG"];
	hitLocTexts["left_foot"] = 		game["STRING_AUTO_SPECTATOR_HIT_FOOT"];
	hitLocTexts["right_foot"] = 		game["STRING_AUTO_SPECTATOR_HIT_FOOT"];


	self endon("disconnect");

	if (isDefined(self.killcam))
		return;

	self notify("autoSpectating_showDamageInfo_end");
	self endon("autoSpectating_showDamageInfo_end");

	if (!isDefined(self.hud_damageinfo))
	{
		self.hud_damageinfo = newClientHudElem2(self);
		self.hud_damageinfo.horzAlign = "center";
		self.hud_damageinfo.vertAlign = "middle";
		self.hud_damageinfo.alignX = "right";
		self.hud_damageinfo.label = game["STRING_AUTO_SPECTATOR_HIT_HP"];
		self.hud_damageinfo.x = -10;
		self.hud_damageinfo.fontscale = 1.1;
		self.hud_damageinfo.archived = false;
	}

	if (!isDefined(self.hud_damageinfo_loc))
	{
		self.hud_damageinfo_loc = newClientHudElem2(self);
		self.hud_damageinfo_loc.horzAlign = "center";
		self.hud_damageinfo_loc.vertAlign = "middle";
		self.hud_damageinfo_loc.alignX = "left";
		self.hud_damageinfo_loc.x = 2;
		self.hud_damageinfo_loc.fontscale = 1.1;
		self.hud_damageinfo_loc.archived = false;
	}

	if (damage > 100)
		damage = 100;

	self.hud_damageinfo setValue(damage);

	if (sMeansOfDeath == "MOD_GRENADE_SPLASH")
		self.hud_damageinfo_loc setText(game["STRING_AUTO_SPECTATOR_HIT_GRENADE"]);
	else if (pellets >= 1 && pellets <= 8) // shotgun
		self.hud_damageinfo_loc setText(game["STRING_AUTO_SPECTATOR_HIT_SHOTGUN_" + pellets + "p"]);
	else if (isDefined(hitLocTexts[sHitLoc]))
		self.hud_damageinfo_loc setText(hitLocTexts[sHitLoc]);

	r = 1;
	g = 1 - ((damage - 50) / 50); 	if (g < 0) g = 0; if (g > 1) g = 1;
	b = 1 - (damage / 50); 	if (b < 0) b = 0; if (b > 1) b = 1;

	// red to orange to yellow -> add green
	// yellow to white -> add blue

	self.hud_damageinfo.color = (r, g, b);
	self.hud_damageinfo_loc.color = (1, 1, 1);

	self.hud_damageinfo.y = 120;
	self.hud_damageinfo.alpha = 1;
	self.hud_damageinfo_loc.y = 120;
	self.hud_damageinfo_loc.alpha = 1;

	self.hud_damageinfo moveovertime(3);
	self.hud_damageinfo.y = 100;
	self.hud_damageinfo_loc moveovertime(3);
	self.hud_damageinfo_loc.y = 100;

	wait level.fps_multiplier * 1;

	self.hud_damageinfo FadeOverTime(2);
	self.hud_damageinfo.alpha = 0;
	self.hud_damageinfo_loc FadeOverTime(2);
	self.hud_damageinfo_loc.alpha = 0;

	wait level.fps_multiplier * 2;

	self.hud_damageinfo destroy2();
	self.hud_damageinfo_loc destroy2();
}



showDamageInfoReadyup(damage, sHitLoc, sMeansOfDeath, pellets, adjustedBy)
{
	hitLocTexts["head"] = 			game["STRING_AUTO_SPECTATOR_HIT_HEAD"];
	hitLocTexts["neck"] = 			game["STRING_AUTO_SPECTATOR_HIT_NECK"];
	hitLocTexts["torso_upper"] = 		game["STRING_AUTO_SPECTATOR_HIT_BODY_UPPER"];
	hitLocTexts["torso_lower"] = 		game["STRING_AUTO_SPECTATOR_HIT_BODY_LOWER"];
	hitLocTexts["left_arm_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_SHOULDER"];
	hitLocTexts["left_arm_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_ARM"];
	hitLocTexts["left_hand"] = 		game["STRING_AUTO_SPECTATOR_HIT_HAND"];
	hitLocTexts["right_arm_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_SHOULDER"];
	hitLocTexts["right_arm_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_ARM"];
	hitLocTexts["right_hand"] = 		game["STRING_AUTO_SPECTATOR_HIT_HAND"];
	hitLocTexts["left_leg_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG_UPPEER"];
	hitLocTexts["left_leg_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG_LOWER"];
	hitLocTexts["right_leg_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG_UPPEER"];
	hitLocTexts["right_leg_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG_LOWER"];
	hitLocTexts["left_foot"] = 		game["STRING_AUTO_SPECTATOR_HIT_FOOT"];
	hitLocTexts["right_foot"] = 		game["STRING_AUTO_SPECTATOR_HIT_FOOT"];

	adjuestedByTexts["consistent_shotgun_1_kill"] = 	game["STRING_AUTO_SPECTATOR_HIT_INFO_SHOTGUN_1_KILL"];
	adjuestedByTexts["consistent_shotgun_1_hit"] = 		game["STRING_AUTO_SPECTATOR_HIT_INFO_SHOTGUN_1_HIT"];
	adjuestedByTexts["consistent_shotgun_2"] = 		game["STRING_AUTO_SPECTATOR_HIT_INFO_SHOTGUN_2"];
	adjuestedByTexts["consistent_shotgun_3"] = 		game["STRING_AUTO_SPECTATOR_HIT_INFO_SHOTGUN_3"];
	adjuestedByTexts["consistent_shotgun_4"] = 		game["STRING_AUTO_SPECTATOR_HIT_INFO_SHOTGUN_4"];
	adjuestedByTexts["torso_hitbox_fix"] = 			game["STRING_AUTO_SPECTATOR_HIT_INFO_TORSO_HITBOX_FIX"];
	adjuestedByTexts["hand_hitbox_fix"] = 			game["STRING_AUTO_SPECTATOR_HIT_INFO_HAND_HITBOX_FIX"];


	self endon("disconnect");

	if (isDefined(self.killcam))
		return;

	self notify("autoSpectating_showDamageInfo_end");
	self endon("autoSpectating_showDamageInfo_end");

	if (!isDefined(self.hud_damageinfo))
	{
		self.hud_damageinfo = newClientHudElem2(self);
		self.hud_damageinfo.horzAlign = "center";
		self.hud_damageinfo.vertAlign = "middle";
		self.hud_damageinfo.alignX = "left";
		self.hud_damageinfo.label = game["STRING_AUTO_SPECTATOR_HIT_HP"];
		self.hud_damageinfo.x = -40;
		self.hud_damageinfo.fontscale = 1.1;
		self.hud_damageinfo.archived = false;
	}

	if (!isDefined(self.hud_damageinfo_loc))
	{
		self.hud_damageinfo_loc = newClientHudElem2(self);
		self.hud_damageinfo_loc.horzAlign = "center";
		self.hud_damageinfo_loc.vertAlign = "middle";
		self.hud_damageinfo_loc.alignX = "right";
		self.hud_damageinfo_loc.x = 40;
		self.hud_damageinfo_loc.fontscale = 1.1;
		self.hud_damageinfo_loc.archived = false;
	}

	if (!isDefined(self.hud_damageinfo_adjustedBy))
	{
		self.hud_damageinfo_adjustedBy = newClientHudElem2(self);
		self.hud_damageinfo_adjustedBy.horzAlign = "center";
		self.hud_damageinfo_adjustedBy.vertAlign = "middle";
		self.hud_damageinfo_adjustedBy.alignX = "center";
		self.hud_damageinfo_adjustedBy.x = 0;
		self.hud_damageinfo_adjustedBy.fontscale = 0.7;
		self.hud_damageinfo_adjustedBy.archived = false;
	}

	self.hud_damageinfo setValue(damage);

	if (sMeansOfDeath == "MOD_GRENADE_SPLASH")
		self.hud_damageinfo_loc setText(game["STRING_AUTO_SPECTATOR_HIT_GRENADE"]);
	else if (pellets >= 1 && pellets <= 8) // shotgun
		self.hud_damageinfo_loc setText(game["STRING_AUTO_SPECTATOR_HIT_SHOTGUN_" + pellets + "p"]);
	else if (isDefined(hitLocTexts[sHitLoc]))
		self.hud_damageinfo_loc setText(hitLocTexts[sHitLoc]);

	if (isDefined(adjuestedByTexts[adjustedBy]))
	{
		self.hud_damageinfo_adjustedBy setText(adjuestedByTexts[adjustedBy]);
		self.hud_damageinfo_adjustedBy.alpha = 1;
	}
	else
		self.hud_damageinfo_adjustedBy.alpha = 0;

	r = 1;
	g = 1 - ((damage - 50) / 50); 	if (g < 0) g = 0; if (g > 1) g = 1;
	b = 1 - (damage / 50); 		if (b < 0) b = 0; if (b > 1) b = 1;

	// red to orange to yellow -> add green
	// yellow to white -> add blue

	self.hud_damageinfo.color = (r, g, b);
	self.hud_damageinfo_loc.color = (1, 1, 1);
	self.hud_damageinfo_adjustedBy.color = (1, 1, 1);

	self.hud_damageinfo.y = 120;
	self.hud_damageinfo.alpha = 1;
	self.hud_damageinfo_loc.y = 120;
	self.hud_damageinfo_loc.alpha = 1;
	self.hud_damageinfo_adjustedBy.y = 110;
	//self.hud_damageinfo_adjustedBy.alpha = 1;

	wait level.fps_multiplier * 3;

	self.hud_damageinfo FadeOverTime(1);
	self.hud_damageinfo.alpha = 0;
	self.hud_damageinfo_loc FadeOverTime(1);
	self.hud_damageinfo_loc.alpha = 0;
	self.hud_damageinfo_adjustedBy FadeOverTime(1);
	self.hud_damageinfo_adjustedBy.alpha = 0;

	wait level.fps_multiplier * 1;

	self.hud_damageinfo destroy2();
	self.hud_damageinfo_loc destroy2();
	self.hud_damageinfo_adjustedBy destroy2();
}



showTakenDamageInfo(iDamage, sHitLoc, sMeansOfDeath)
{
	hitLocTexts["head"] = 			game["STRING_AUTO_SPECTATOR_HIT_HEAD"];
	hitLocTexts["neck"] = 			game["STRING_AUTO_SPECTATOR_HIT_NECK"];
	hitLocTexts["torso_upper"] = 		game["STRING_AUTO_SPECTATOR_HIT_BODY"];
	hitLocTexts["torso_lower"] = 		game["STRING_AUTO_SPECTATOR_HIT_BODY"];
	hitLocTexts["left_arm_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_SHOULDER"];
	hitLocTexts["left_arm_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_ARM"];
	hitLocTexts["left_hand"] = 		game["STRING_AUTO_SPECTATOR_HIT_HAND"];
	hitLocTexts["right_arm_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_SHOULDER"];
	hitLocTexts["right_arm_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_ARM"];
	hitLocTexts["right_hand"] = 		game["STRING_AUTO_SPECTATOR_HIT_HAND"];
	hitLocTexts["left_leg_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG"];
	hitLocTexts["left_leg_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG"];
	hitLocTexts["left_foot"] = 		game["STRING_AUTO_SPECTATOR_HIT_FOOT"];
	hitLocTexts["right_leg_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG"];
	hitLocTexts["right_leg_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG"];
	hitLocTexts["right_foot"] = 		game["STRING_AUTO_SPECTATOR_HIT_FOOT"];

	self endon("disconnect");

	if (isDefined(self.killcam))
		return;

	self notify("autoSpectating_showTakenDamageInfo_end");
	self endon("autoSpectating_showTakenDamageInfo_end");

	if (!isDefined(self.hud_takendamageinfo))
	{
		self.hud_takendamageinfo = newClientHudElem2(self);
		self.hud_takendamageinfo.horzAlign = "center";
		self.hud_takendamageinfo.vertAlign = "middle";
		self.hud_takendamageinfo.alignX = "right";
		self.hud_takendamageinfo.label = game["STRING_AUTO_SPECTATOR_HIT_HP"];
		self.hud_takendamageinfo.x = -10;
		self.hud_takendamageinfo.fontscale = 1.1;
		self.hud_takendamageinfo.archived = false;
	}

	if (!isDefined(self.hud_takendamageinfo_loc))
	{
		self.hud_takendamageinfo_loc = newClientHudElem2(self);
		self.hud_takendamageinfo_loc.horzAlign = "center";
		self.hud_takendamageinfo_loc.vertAlign = "middle";
		self.hud_takendamageinfo_loc.alignX = "left";
		self.hud_takendamageinfo_loc.x = 2;
		self.hud_takendamageinfo_loc.fontscale = 1.1;
		self.hud_takendamageinfo_loc.archived = false;
	}

	if (iDamage > 100)
		iDamage = 100;

	self.hud_takendamageinfo setValue(iDamage*-1);

	if (sMeansOfDeath == "MOD_GRENADE_SPLASH")
		self.hud_takendamageinfo_loc setText(game["STRING_AUTO_SPECTATOR_HIT_GRENADE"]);
	else if (isDefined(hitLocTexts[sHitLoc]))
		self.hud_takendamageinfo_loc setText(hitLocTexts[sHitLoc]);

	r = 1;
	g = 1 - ((iDamage - 50) / 50); 	if (g < 0) g = 0; if (g > 1) g = 1;
	b = 1 - (iDamage / 50); 	if (b < 0) b = 0; if (b > 1) b = 1;

	// red to orange to yellow -> add green
	// yellow to white -> add blue

	self.hud_takendamageinfo.color = (r, g, b);
	self.hud_takendamageinfo_loc.color = (1, 1, 1);

	self.hud_takendamageinfo.y = 120;
	self.hud_takendamageinfo.alpha = 1;
	self.hud_takendamageinfo_loc.y = 120;
	self.hud_takendamageinfo_loc.alpha = 1;

	self.hud_takendamageinfo moveovertime(3);
	self.hud_takendamageinfo.y = 140;
	self.hud_takendamageinfo_loc moveovertime(3);
	self.hud_takendamageinfo_loc.y = 140;

	wait level.fps_multiplier * 1;

	self.hud_takendamageinfo FadeOverTime(2);
	self.hud_takendamageinfo.alpha = 0;
	self.hud_takendamageinfo_loc FadeOverTime(2);
	self.hud_takendamageinfo_loc.alpha = 0;

	wait level.fps_multiplier * 2;

	self.hud_takendamageinfo destroy2();
	self.hud_takendamageinfo_loc destroy2();
}





showKillInfo()
{
	self endon("disconnect");

	if (isDefined(self.killcam))
		return;

	self notify("autoSpectating_showKillInfo_end");
	self endon("autoSpectating_showKillInfo_end");

	if (!isDefined(self.hud_damageinfo_kill))
	{
		self.hud_damageinfo_kill = newClientHudElem2(self);
		self.hud_damageinfo_kill.horzAlign = "center";
		self.hud_damageinfo_kill.vertAlign = "middle";
		self.hud_damageinfo_kill.x = -65;
		self.hud_damageinfo_kill.archived = false;
		self.hud_damageinfo_kill setShader("headicon_dead", 23, 23);
	}

	self.hud_damageinfo_kill.y = 120 - 2;
	self.hud_damageinfo_kill.alpha = 1;
	self.hud_damageinfo_kill moveovertime(3);
	self.hud_damageinfo_kill.y = 100 - 2;

	wait level.fps_multiplier * 1;

	self.hud_damageinfo_kill FadeOverTime(2);
	self.hud_damageinfo_kill.alpha = 0;

	wait level.fps_multiplier * 2;

	self.hud_damageinfo_kill destroy2();
}
