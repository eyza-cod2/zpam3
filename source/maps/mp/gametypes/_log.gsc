#include maps\mp\gametypes\global\_global;

/*
Server log (games_mp.log) used by stats applications - format is documented in README.md (Server log for stats applications)
Rules to keep existing log parsers working:
 - never change or remove existing lines or fields
 - new fields can be added only at the end of lines with fixed number of fields
 - new data are logged via new line types
 - increase level.log_version when the format is extended

Log functions are called directly from gametype (not via level notify), because notify is lost if it is called again in the same frame
*/

init()
{
	level.log_version = 2;

	addEventListener("onConnected",     ::onConnected);
	addEventListener("onDisconnect",    ::onDisconnect);
	addEventListener("onJoinedTeam",    ::onJoinedTeam);

	if (game["firstInit"])
		level thread logInfo();
}

logInfo()
{
	waittillframeend; // wait until gametype variables are set

	pam_version = getsubstr(level.pam_folder, 5, level.pam_folder.size); // "main/zpam412" -> "zpam412"

	logPrint("LogInfo;" + level.log_version + ";" + pam_version + ";" + level.gametype + ";" + level.mapname + ";" + level.pam_mode + ";" +
		getMatchId() + ";" + getTime() + "\n");
}


// Players

onConnected()
{
	self logConnection("Connected");
}

onDisconnect()
{
	self logConnection("Disconnected");
}

logConnection(lineType)
{
	logPrint(lineType + ";" + self getGuid() + ";" + self getEntityNumber() + ";" + self.name + ";" + getPlayerIds(self) + ";" + getTime() + "\n");
}

onJoinedTeam(teamName)
{
	logPrint("Team;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.name + ";" + teamName + ";" +
		getPlayerIds(self) + ";" + getTime() + "\n");
}


// Round flow

logReadyUpOver()
{
	logPrint("ReadyupDone;\n");
}

// Called when new round is started (after map_restart, before strat time) - round number is already set
logRoundStartInfo()
{
	half = 1;
	if (game["is_halftime"])
		half = 2;

	logPrint("RoundStartInfo;" + game["round"] + ";" + half + ";" + game["overtime_active"] + ";" +
		game["attackers"] + ";" + game["defenders"] + ";" +
		getTeamScore("allies") + ";" + getTeamScore("axis") + ";" + getMatchTeamNames() + ";" + getTime() + "\n");
}

// Called when round goes live (strat time is over) - list of players in teams with their weapons
logRoundLive()
{
	level.log_roundLiveTime = getTime();

	logPrint("RoundLive;" + game["round"] + ";" + int(level.roundlength * 60) + ";" + getTime() + "\n");

	players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		player = players[i];
		if (player.pers["team"] != "allies" && player.pers["team"] != "axis")
			continue;

		alive = 0;
		primary = "";
		secondary = "";
		if (player.sessionstate == "playing")
		{
			alive = 1;
			primary = player getWeaponSlotWeapon("primary");
			secondary = player getWeaponSlotWeapon("primaryb");
		}

		logPrint("RoundPlayer;" + game["round"] + ";" +
			player getGuid() + ";" + player getEntityNumber() + ";" + player.name + ";" + player.pers["team"] + ";" +
			getPlayerIds(player) + ";" + alive + ";" + primary + ";" + secondary + "\n");
	}
}

// Called before finishPlayerDamage to know how much health was really removed
saveHealthBeforeDamage(eAttacker)
{
	self saveHealth();

	// Attacker may be damaged instead of self if scr_friendlyfire is "reflected" or "shared"
	if (isDefined(eAttacker) && isPlayer(eAttacker) && eAttacker != self)
		eAttacker saveHealth();
}

saveHealth()
{
	self.log_healthBefore = self.health;
	self.log_healthBeforeTime = getTime();
}

// Health removed from the player by the hit in this frame (0 if there was no hit, like suicide via team change)
getRealDamage(player, healthAfter)
{
	if (!isDefined(player.log_healthBeforeTime) || player.log_healthBeforeTime != getTime() || player.log_healthBefore < healthAfter)
		return 0;
	return player.log_healthBefore - healthAfter;
}

logDamage(player, eAttacker, sWeapon, iDamage, sMeansOfDeath, sHitLoc, isFriendlyFire)
{
	realDamage = getRealDamage(player, player.health);

	// This means that scr_friendlyfire is "reflected" or "shared" - it means attacker get hitted instead of self
	if (isFriendlyFire)
	{
		if (realDamage == 0 && isDefined(eAttacker) && isPlayer(eAttacker))
			realDamage = getRealDamage(eAttacker, eAttacker.health);

		eAttacker = player;
	}

	logHit("Damage", player, eAttacker, sWeapon, iDamage, sMeansOfDeath, sHitLoc, realDamage);
}

logKill(player, attacker, sWeapon, iDamage, sMeansOfDeath, sHitLoc)
{
	logHit("Kill", player, attacker, sWeapon, iDamage, sMeansOfDeath, sHitLoc, getRealDamage(player, 0));
}

logHit(lineType, player, attacker, sWeapon, iDamage, sMeansOfDeath, sHitLoc, realDamage)
{
	attack_num = -1;
	attack_guid = "";
	attack_name = "";
	attack_team = "world";

	if (isPlayer(attacker))
	{
		attack_num = attacker getEntityNumber();
		attack_guid = attacker getGuid();
		attack_name = attacker.name;
		attack_team = attacker.pers["team"];
	}

	logPrint(lineType + ";" + player getGuid() + ";" + player getEntityNumber() + ";" + player.name + ";" + player.pers["team"] + ";" +
		attack_guid + ";" + attack_num + ";" + attack_name + ";" + attack_team + ";" +
		sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + ";" +
		realDamage + ";" + getPlayerIds(player) + ";" + getPlayerIds(attacker) + ";" + getDistance(player, attacker) + ";" + getTime() + "\n");
}

logBomb(player, action, site)
{
	logPrint("Bomb;" + player getGuid() + ";" + player getEntityNumber() + ";" + player.pers["team"] + ";" + player.name + ";" + action + ";" +
		getPlayerIds(player) + ";" + site + ";" + game["round"] + ";" + getTime() + "\n");
}

logBombExploded(planter, site)
{
	guid = "";
	num = -1;
	team = "";
	name = "";

	if (isDefined(planter) && isPlayer(planter))
	{
		guid = planter getGuid();
		num = planter getEntityNumber();
		team = planter.pers["team"];
		name = planter.name;
	}

	logPrint("BombExploded;" + guid + ";" + num + ";" + team + ";" + name + ";" +
		getPlayerIds(planter) + ";" + site + ";" + game["round"] + ";" + getTime() + "\n");
}

// Must be called as thread (waits to the end of the frame)
logRoundEnd(roundwinner, reason)
{
	if (!isDefined(reason))
		reason = "";

	waittillframeend; // wait to complete kill log

	logPrint("RoundEnd;\n");

	roundlooser = "axis";
	if (roundwinner == "axis")
		roundlooser = "allies";

	winners = "";
	losers = "";

	players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		lpGuid = players[i] getGuid();
		if (isDefined(players[i].pers["team"]) && players[i].pers["team"] == roundwinner)
			winners = winners + ";" + lpGuid + ";" + players[i].name;
		else if (isDefined(players[i].pers["team"]) && players[i].pers["team"] == roundlooser)
			losers = losers + ";" + lpGuid + ";" + players[i].name;
	}
	logPrint("Winners;" + roundwinner + winners + "\n");
	logPrint("Losers;" + roundlooser + losers + "\n");

	logPrint("Score;allies;" + getTeamScore("allies") + ";axis;" + getTeamScore("axis") + "\n");

	duration = -1;
	if (isDefined(level.log_roundLiveTime))
		duration = getTime() - level.log_roundLiveTime;

	logPrint("RoundResult;" + game["round"] + ";" + roundwinner + ";" + reason + ";" +
		getTeamScore("allies") + ";" + getTeamScore("axis") + ";" + duration + ";" + getTime() + "\n");
}


/*
Overall stats of the map, printed at the end of the map right before MatchEnd line
  StatsStart;...
  StatsHeader;<column names>
  PlayerStats;<values in the same order as StatsHeader>     (one line per player)
  StatsEnd;<number of PlayerStats lines>
*/
logMapStats()
{
	maps\mp\gametypes\_player_stat::saveIdentityOfConnectedPlayers();

	roundsPlayed = 0;
	if (isDefined(game["roundsplayed"]))
		roundsPlayed = game["roundsplayed"];

	logPrint("StatsStart;" + level.log_version + ";" + level.gametype + ";" + level.mapname + ";" +
		getTeamScore("allies") + ";" + getTeamScore("axis") + ";" +
		getMatchTeamNames() + ";" + roundsPlayed + ";" + getMatchId() + ";" + getTime() + "\n");

	keys = getStatKeys();

	line = "StatsHeader";
	for (c = 0; c < keys.size; c++)
		line += ";" + getStatColumnName(keys[c]);
	logPrint(line + "\n");

	count = 0;
	for (i = 0; i < game["playerstats"].size; i++)
	{
		data = game["playerstats"][i];
		if (data["deleted"])
			continue;

		line = "PlayerStats";
		for (c = 0; c < keys.size; c++)
		{
			value = 0; // clutch columns of bigger situations are created on demand
			if (isDefined(data[keys[c]]))
				value = data[keys[c]];

			line += ";" + value;
		}
		logPrint(line + "\n");
		count++;
	}

	logPrint("StatsEnd;" + count + "\n");
}

// Keys of game["playerstats"] printed as columns of PlayerStats line
getStatKeys()
{
	keys = strTok("name;team;isConnected;guid;uuid;hwid;score;kills;deaths;assists;damage;damage_dealt;headshots;grenades;plants;defuses;" +
		"entry_kills;entry_deaths;trade_kills;traded_deaths;aces", ";");

	for (c = 2; c <= 5; c++)
		keys[keys.size] = "multi_kills_" + c;

	classes = level.stat_weapon_classes;
	for (c = 0; c < classes.size; c++)
		keys[keys.size] = "kills_" + classes[c];

	clutchMax = getClutchMax();
	for (c = 1; c <= clutchMax; c++)
	{
		keys[keys.size] = "clutches_won_1v" + c;
		keys[keys.size] = "clutches_attempts_1v" + c;
	}

	return keys;
}

// Clutch columns - 1v1 - 1v5 by default, bigger situations are created on demand
getClutchMax()
{
	clutchMax = 5;
	for (i = 0; i < game["playerstats"].size; i++)
	{
		data = game["playerstats"][i];
		if (data["deleted"])
			continue;

		if (data["clutches_max"] > clutchMax)
			clutchMax = data["clutches_max"];
	}

	return clutchMax;
}

// Name of column in log, if it differs from the key in game["playerstats"]
getStatColumnName(key)
{
	if (key == "isConnected")
		return "connected";
	if (key == "damage")
		return "hits";
	return key;
}

logServerRestart()
{
	logPrint("ServerRestart;EmptyServer\n");
}


// Helpers

// Match UUID of player from CoD2x match system, empty if match is not activated or player is not logged in
getPlayerUuid(player)
{
	if (!isDefined(player) || !isPlayer(player) || !matchIsActivated())
		return "";
	return player matchPlayerGetData("uuid");
}

// Hardware id of player from CoD2x (empty if not known, for example bots)
getPlayerHwid(player)
{
	if (!isDefined(player) || !isPlayer(player))
		return "";
	return player getHWID();
}

// "uuid;hwid" fields of the player
getPlayerIds(player)
{
	return getPlayerUuid(player) + ";" + getPlayerHwid(player);
}

getMatchId()
{
	if (!matchIsActivated())
		return "";
	return matchGetData("match_id");
}

// "allies_team_name;axis_team_name" fields
getMatchTeamNames()
{
	allies = maps\mp\gametypes\_matchinfo::getMatchTeamName("allies");
	axis = maps\mp\gametypes\_matchinfo::getMatchTeamName("axis");

	return removeSeparator(allies) + ";" + removeSeparator(axis);
}

// Team names come from cvars / match system and may contain ";", which would shift the following fields
removeSeparator(text)
{
	parts = strTok(text, ";");
	result = "";
	for (i = 0; i < parts.size; i++)
	{
		if (i > 0)
			result += " ";
		result += parts[i];
	}
	return result;
}

getDistance(player, attacker)
{
	if (!isDefined(attacker) || !isPlayer(attacker) || attacker == player)
		return -1;
	return int(distance(player.origin, attacker.origin));
}
