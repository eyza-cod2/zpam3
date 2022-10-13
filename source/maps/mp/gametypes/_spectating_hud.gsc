#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onConnected",  ::onConnected);

	if (!level.spectatingSystem)
		return;

	if(game["firstInit"])
	{
		precacheString2("STRING_AUTO_SPECTATOR_KEY", &"Press ^3[{+melee_breath}]^7 to disable auto-spectator\nHold ^3[{+attack}]^7 to enable auto-spectator\nPress ^3[{+activate}]^7 to play killcam\nHold ^3[{+activate}]^7 to toggle player names");

		precacheString2("STRING_AUTO_SPECTATOR_HIT_HEAD", 		&"Head");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_NECK", 		&"Neck");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_BODY_UPPER", 	&"Body");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_BODY_LOWE", 		&"Body");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_SHOULDER", 		&"Shoulder");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_ARM", 		&"Arm");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_HAND", 		&"Hand");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_LEG_UPPEER", 	&"Leg");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_LEG_LOWER", 		&"Leg");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_FOOT", 		&"Foot");
		precacheString2("STRING_AUTO_SPECTATOR_HIT_GRENADE", 		&"Grenade");

		precacheShader("headicon_dead");
	}

	addEventListener("onSpawnedSpectator",  ::onSpawnedSpectator);
	addEventListener("onPlayerDamaged", 	::onPlayerDamaged);
	addEventListener("onPlayerKilled", 	::onPlayerKilled);
}

onConnected()
{
	self endon("disconnect");

	// Hide all HUD from previous map
	if (!level.spectatingSystem || level.in_readyup || self.pers["team"] != "spectator")
	{
		wait level.frame; // for optimalization - send in different frame
		HUD_hideUI();
	}
}

onSpawnedSpectator()
{
	if (self.pers["team"] == "spectator" && !level.in_readyup)
	{
		// Create and update boxes with players name
		self thread filling_boxes();
	}
}


/*
Called when player has taken damage.
self is the player that took damage.
*/
onPlayerDamaged(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	if (isDefined(eAttacker) && isPlayer(eAttacker) && self != eAttacker && isDefined(level.autoSpectating_spectatedPlayer) && eAttacker == level.autoSpectating_spectatedPlayer && !level.in_readyup)
	{
		// Count total damage
		id = self getEntityNumber();
		if (!isDefined(eAttacker.autoSpectating_hits))
			eAttacker.autoSpectating_hits = [];
		if (!isDefined(eAttacker.autoSpectating_hits[id]))
			eAttacker.autoSpectating_hits[id] = 0;
		eAttacker.autoSpectating_hits[id] += iDamage;
		self thread resetDamage(eAttacker, id);

		// Show to all spectators
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player.pers["team"] == "spectator" && player.pers["autoSpectating"])
			{
				player thread showDamageInfo(eAttacker.autoSpectating_hits[id], sHitLoc, sMeansOfDeath);
			}
		}
	}


	if (isDefined(level.autoSpectating_spectatedPlayer) && self == level.autoSpectating_spectatedPlayer && !level.in_readyup)
	{
		// Show to all spectators
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player.pers["team"] == "spectator" && player.pers["autoSpectating"])
			{
				player thread showTakenDamageInfo((self.maxhealth - self.health) + iDamage, sHitLoc, sMeansOfDeath);
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




resetDamage(eAttacker, id)
{
	//self endon("disconnect");
	eAttacker endon("disconnect");

	self notify("autoSpectating_resetDamage_end");
	self endon("autoSpectating_resetDamage_end");

	wait level.fps_multiplier * 5;

	eAttacker.autoSpectating_hits[id] = undefined;
}


showDamageInfo(iDamage, sHitLoc, sMeansOfDeath)
{
	hitLocTexts["head"] = 			game["STRING_AUTO_SPECTATOR_HIT_HEAD"];
	hitLocTexts["neck"] = 			game["STRING_AUTO_SPECTATOR_HIT_NECK"];
	hitLocTexts["torso_upper"] = 		game["STRING_AUTO_SPECTATOR_HIT_BODY_UPPER"];
	hitLocTexts["torso_lower"] = 		game["STRING_AUTO_SPECTATOR_HIT_BODY_LOWE"];
	hitLocTexts["left_arm_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_SHOULDER"];
	hitLocTexts["left_arm_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_ARM"];
	hitLocTexts["left_hand"] = 		game["STRING_AUTO_SPECTATOR_HIT_HAND"];
	hitLocTexts["right_arm_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_SHOULDER"];
	hitLocTexts["right_arm_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_ARM"];
	hitLocTexts["right_hand"] = 		game["STRING_AUTO_SPECTATOR_HIT_HAND"];
	hitLocTexts["left_leg_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG_UPPEER"];
	hitLocTexts["left_leg_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG_LOWER"];
	hitLocTexts["left_foot"] = 		game["STRING_AUTO_SPECTATOR_HIT_FOOT"];
	hitLocTexts["right_leg_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG_UPPEER"];
	hitLocTexts["right_leg_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG_LOWER"];
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
		self.hud_damageinfo.x = 50;
		self.hud_damageinfo.fontscale = 1.2;
		self.hud_damageinfo.archived = false;
	}

	if (!isDefined(self.hud_damageinfo_loc))
	{
		self.hud_damageinfo_loc = newClientHudElem2(self);
		self.hud_damageinfo_loc.horzAlign = "center";
		self.hud_damageinfo_loc.vertAlign = "middle";
		self.hud_damageinfo_loc.x = 80;
		self.hud_damageinfo_loc.fontscale = 1.1;
		self.hud_damageinfo_loc.archived = false;
	}

	if (iDamage > 100)
		iDamage = 100;

	self.hud_damageinfo setValue(iDamage);

	if (sMeansOfDeath == "MOD_GRENADE_SPLASH")
		self.hud_damageinfo_loc setText(game["STRING_AUTO_SPECTATOR_HIT_GRENADE"]);
	else if (isDefined(hitLocTexts[sHitLoc]))
		self.hud_damageinfo_loc setText(hitLocTexts[sHitLoc]);

	r = 1;
	g = 1 - ((iDamage - 50) / 50); 	if (g < 0) g = 0; if (g > 1) g = 1;
	b = 1 - (iDamage / 50); 	if (b < 0) b = 0; if (b > 1) b = 1;

	// red to orange to yellow -> add green
	// yellow to white -> add blue

	self.hud_damageinfo.color = (r, g, b);
	self.hud_damageinfo_loc.color = (1, 1, 1);

	self.hud_damageinfo.y = 0;
	self.hud_damageinfo.alpha = 1;
	self.hud_damageinfo_loc.y = 0;
	self.hud_damageinfo_loc.alpha = 1;

	self.hud_damageinfo moveovertime(2);
	self.hud_damageinfo.y = -50;
	self.hud_damageinfo_loc moveovertime(2);
	self.hud_damageinfo_loc.y = -50;

	wait level.fps_multiplier * 1;

	self.hud_damageinfo FadeOverTime(1);
	self.hud_damageinfo.alpha = 0;
	self.hud_damageinfo_loc FadeOverTime(1);
	self.hud_damageinfo_loc.alpha = 0;

	wait level.fps_multiplier * 2;

	self.hud_damageinfo destroy2();
	self.hud_damageinfo_loc destroy2();
}



showTakenDamageInfo(iDamage, sHitLoc, sMeansOfDeath)
{
	hitLocTexts["head"] = 			game["STRING_AUTO_SPECTATOR_HIT_HEAD"];
	hitLocTexts["neck"] = 			game["STRING_AUTO_SPECTATOR_HIT_NECK"];
	hitLocTexts["torso_upper"] = 		game["STRING_AUTO_SPECTATOR_HIT_BODY_UPPER"];
	hitLocTexts["torso_lower"] = 		game["STRING_AUTO_SPECTATOR_HIT_BODY_LOWE"];
	hitLocTexts["left_arm_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_SHOULDER"];
	hitLocTexts["left_arm_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_ARM"];
	hitLocTexts["left_hand"] = 		game["STRING_AUTO_SPECTATOR_HIT_HAND"];
	hitLocTexts["right_arm_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_SHOULDER"];
	hitLocTexts["right_arm_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_ARM"];
	hitLocTexts["right_hand"] = 		game["STRING_AUTO_SPECTATOR_HIT_HAND"];
	hitLocTexts["left_leg_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG_UPPEER"];
	hitLocTexts["left_leg_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG_LOWER"];
	hitLocTexts["left_foot"] = 		game["STRING_AUTO_SPECTATOR_HIT_FOOT"];
	hitLocTexts["right_leg_upper"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG_UPPEER"];
	hitLocTexts["right_leg_lower"] = 	game["STRING_AUTO_SPECTATOR_HIT_LEG_LOWER"];
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
		self.hud_takendamageinfo.x = -20;
		self.hud_takendamageinfo.fontscale = 1.2;
		self.hud_takendamageinfo.archived = false;
	}

	if (!isDefined(self.hud_takendamageinfo_loc))
	{
		self.hud_takendamageinfo_loc = newClientHudElem2(self);
		self.hud_takendamageinfo_loc.horzAlign = "center";
		self.hud_takendamageinfo_loc.vertAlign = "middle";
		self.hud_takendamageinfo_loc.x = 10;
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

	self.hud_takendamageinfo.y = 80;
	self.hud_takendamageinfo.alpha = 1;
	self.hud_takendamageinfo_loc.y = 80;
	self.hud_takendamageinfo_loc.alpha = 1;

	self.hud_takendamageinfo moveovertime(2);
	self.hud_takendamageinfo.y = 120;
	self.hud_takendamageinfo_loc moveovertime(2);
	self.hud_takendamageinfo_loc.y = 120;

	wait level.fps_multiplier * 1;

	self.hud_takendamageinfo FadeOverTime(1);
	self.hud_takendamageinfo.alpha = 0;
	self.hud_takendamageinfo_loc FadeOverTime(1);
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
		self.hud_damageinfo_kill.x = 30;
		self.hud_damageinfo_kill.archived = false;
		self.hud_damageinfo_kill setShader("headicon_dead", 23, 23);
	}

	self.hud_damageinfo_kill.y = 0;
	self.hud_damageinfo_kill.alpha = 1;
	self.hud_damageinfo_kill moveovertime(2);
	self.hud_damageinfo_kill.y = -50;

	wait level.fps_multiplier * 1;

	self.hud_damageinfo_kill FadeOverTime(1);
	self.hud_damageinfo_kill.alpha = 0;

	wait level.fps_multiplier * 2;

	self.hud_damageinfo_kill destroy2();
}







keys_show()
{
	if(!isdefined(self.autoSpectatingKeyInfoBG))
	{
		self.autoSpectatingKeyInfoBG = newClientHudElem2(self);
		self.autoSpectatingKeyInfoBG.archived = false;
		self.autoSpectatingKeyInfoBG.x = -170;
		self.autoSpectatingKeyInfoBG.y = 55;
		self.autoSpectatingKeyInfoBG.horzAlign = "right";
		self.autoSpectatingKeyInfoBG.vertAlign = "top";
		self.autoSpectatingKeyInfoBG.alpha = 0.8;
		self.autoSpectatingKeyInfoBG.sort = -1;
		self.autoSpectatingKeyInfoBG setShader("black", 160, 42);
	}
	if(!isdefined(self.autoSpectatingKeyInfo))
	{
		self.autoSpectatingKeyInfo = addHUDClient(self, -164, 60, 0.7, (1,1,1), "left", "top", "right", "top");
		self.autoSpectatingKeyInfo.archived = false;
		self.autoSpectatingKeyInfo setText(game["STRING_AUTO_SPECTATOR_KEY"]);
	}
}

keys_hide()
{
	self endon("disconnect");

	time = 0.3;

	if(isDefined(self.autoSpectatingKeyInfoBG))
	{
		self.autoSpectatingKeyInfoBG fadeOverTime(time);
		self.autoSpectatingKeyInfoBG.alpha = 0;
	}
	if(isDefined(self.autoSpectatingKeyInfo))
	{
		self.autoSpectatingKeyInfo fadeOverTime(time);
		self.autoSpectatingKeyInfo.alpha = 0;
	}

	wait level.fps_multiplier * time;

	if(isdefined(self.autoSpectatingKeyInfoBG))
	{
		self.autoSpectatingKeyInfoBG destroy2();
		self.autoSpectatingKeyInfoBG = undefined;
	}
	if(isdefined(self.autoSpectatingKeyInfo))
	{
		self.autoSpectatingKeyInfo destroy2();
		self.autoSpectatingKeyInfo = undefined;
	}
}
















HUD_hideUI()
{

	setClientCvarIfChanged("ui_spectatingsystem_team1_sideColor", 	"");
	setClientCvarIfChanged("ui_spectatingsystem_team1_name", 	"");
	setClientCvarIfChanged("ui_spectatingsystem_team1_scoreProgress", "");

	setClientCvarIfChanged("ui_spectatingsystem_team2_sideColor", 	"");
	setClientCvarIfChanged("ui_spectatingsystem_team2_name", 	"");
	setClientCvarIfChanged("ui_spectatingsystem_team2_scoreProgress", "");

	setClientCvarIfChanged("ui_spectatingsystem_playerProgress", "");

	for (i = 0; i < 5; i++)
	{
		setClientCvarIfChanged("ui_spectatingsystem_team1_player"+i+"_health", "");
		setClientCvarIfChanged("ui_spectatingsystem_team1_player"+i+"_text", "");
		setClientCvarIfChanged("ui_spectatingsystem_team2_player"+i+"_health", "");
		setClientCvarIfChanged("ui_spectatingsystem_team2_player"+i+"_text", "");
	}

}


filling_boxes()
{
	self endon("disconnect");

	wait level.frame;

	teamLeft = "allies";
	teamRight = "axis";

	// If match info is enabled, ensure teams are in correct sides
	if (game["scr_matchinfo"] == 1 || game["scr_matchinfo"] == 2)
	{
		if (game["match_team1_side"] == "axis")
		{
			teamLeft = "axis";
			teamRight = "allies";
		}
	}


	for(;;)
	{
		wait level.fps_multiplier * 0.1;

		if (self.pers["team"] == "spectator")
		{
			// Hide for a while
			if (isDefined(self.killcam) || level.in_readyup) // readyup in case timeout is called
			{
				HUD_hideUI();
				continue;
			}


			scoreProgress = "";
			if (isDefined(game["allies_score_history"]) && isDefined(game["axis_score_history"]) && game["allies_score_history"] != "" && game["axis_score_history"] != "")
			{
				scoreProgress = "Team 1: ";
				if (teamLeft == "axis") scoreProgress += game["axis_score_history"];
				else scoreProgress += game["allies_score_history"];
			}
			setClientCvarIfChanged("ui_spectatingsystem_team1_scoreProgress", scoreProgress);

			scoreProgress = "";
			if (isDefined(game["allies_score_history"]) && isDefined(game["axis_score_history"]) && game["allies_score_history"] != "" && game["axis_score_history"] != "")
			{
				scoreProgress = "Team 2: ";
				if (teamRight == "axis") scoreProgress += game["axis_score_history"];
				else scoreProgress += game["allies_score_history"];
			}

			setClientCvarIfChanged("ui_spectatingsystem_team2_scoreProgress", scoreProgress);




			playerProgress = "";
			if (level.gametype == "sd" && isDefined(level.player_alive_history) && level.player_alive_history != "")
				playerProgress = "Players:" + level.player_alive_history;

			setClientCvarIfChanged("ui_spectatingsystem_playerProgress", playerProgress);





			playersLeft = getPlayersSortedByScore(teamLeft);
			playersRight = getPlayersSortedByScore(teamRight);

			// Fill bars
			for(r = 0; r < 5; r++)
			{
				if (r < playersLeft.size)
					self fill_box(r, "left", teamLeft, playersLeft[r]);
				else
					self unfill_box(r, "left");

				if (r < playersRight.size)
					self fill_box(r, "right", teamRight, playersRight[r]);
				else
					self unfill_box(r, "right");
			}

		}
		else
		{
			// Player left spectators
			// Hide hud elements
			HUD_hideUI();
			return;
		}
	}
}

getPlayersSortedByScore(teamname)
{
	playersFiltered = [];
	index = 0;
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if (!isDefined(teamname) || player.pers["team"] == teamname)
		{
			playersFiltered[index] = player;
			index++;
		}
	}

	sorted = sort(playersFiltered);

	// Sort and return
	return sorted;
}

sort(players)
{
	// Sort score from highest to Vlowest
	for(j = 1; j < players.size; j++)
	{
		for (
			jj = j;
			jj >= 1 && (
				(players[jj-1].score < players[jj].score) ||
				(players[jj-1].score == players[jj].score && players[jj-1].deaths > players[jj].deaths)
			);
			jj--)
		{
			temp = players[jj];
			players[jj] = players[jj-1];
			players[jj-1] = temp;
		}
	}
	return players;
}



fill_box(index, barSide, teamname, player)
{
	teamNum = "1";
	if (barSide == "right")
		teamNum = "2";

	value = "";
	// Because health is showed via menu elements, the health bar is splited only into a few sizes
	// So according to helth we select most corresponding size
	if (player.health <= 0)
		value =  "0";

	else if (player.health < 20)
		value =  "10";

	else if (player.health < 70)
		value =  "50";

	else if (player.health < 99)
		value =  "80";

	else
		value =  "100";


	if (player.health > 0)
	{
	      	if (teamname == "allies")
		{
			if(game["allies"] == "american")
				value = value + "_green";
			else if(game["allies"] == "british")
				value = value + "_blue";
			else if(game["allies"] == "russian")
				value = value + "_red";
		}
		else
			value = value + "_gray";
	}


	if (self.pers["autoSpectating"] && isDefined(level.autoSpectating_spectatedPlayer) && player == level.autoSpectating_spectatedPlayer)
	{
		value = value + "_"; // underscore means this player is followed and rectangle next player box is showed
	}

	setClientCvarIfChanged("ui_spectatingsystem_team"+teamNum+"_player"+index+"_health", value);



	teamNum = "1";
	if (barSide == "right")
		teamNum = "2";
	setClientCvarIfChanged("ui_spectatingsystem_team"+teamNum+"_player"+index+"_text", player.score + " / " + player.deaths + "    " + player.name);
}


unfill_box(index, barSide)
{
	teamNum = "1";
	if (barSide == "right")
		teamNum = "2";

	// Text does not need to be updated, because is hided automatically if healht is empty
	//setClientCvarIfChanged("ui_spectatingsystem_team"+teamNum+"_player"+index+"_text", "");

	setClientCvarIfChanged("ui_spectatingsystem_team"+teamNum+"_player"+index+"_health", "");
}
