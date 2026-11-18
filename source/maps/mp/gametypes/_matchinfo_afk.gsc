#include maps\mp\gametypes\global\_global;

/*
AFK kick for CoD2x match.

Enabled only if match data contains key "afkTimeout" with number of seconds (for example 60).
If the key is missing or is 0, feature is disabled.
Works in SD and DM.

Player in team (allies / axis) who is alive and does not move from the position he spawned at
for afkTimeout seconds of live time is kicked from the server.
Only horizontal position is compared with a tolerance of level.afk_moveTolerance units, so falling onto the ground
after spawn or jumping in place is not a move.
Turning the view and pressing buttons is not activity - only moving from the spawn position is. So a player who holds
an angle or camps anywhere else is never kicked, and spinning the view / macros do not avoid the kick.
The reason is shown to the player 3 seconds before the kick and passed to kick() - newer CoD2x shows it
in the disconnect dialog and does not ban the player. Older CoD2x ignores the reason and bans the player
for sv_kickBanTime seconds (0 in all competitive rulesets).
Only live time is counted (same as leaver detection):
 - SD: from the end of strat time to the end of the round
 - DM: from the end of strat time to the end of the map
Ready-ups, timeouts, strat time, time between rounds, pistol bash rounds and time when player is dead or spectating are not counted,
but they do not reset the AFK time either, so AFK player is kicked even if he dies at his spawn position in every round.
Moving from the spawn position resets the AFK time. It starts counting again only after the next spawn.
Warning is shown above the crosshair, where iprintlnbold messages are:
a countdown every second in last 15 seconds before the kick. Moving from the spawn position cancels the kick until the player is kicked.

AFK kick is not reported in match data - kicked player is not connected anymore,
so if he does not come back, leaver detection counts his time as usual.
*/
init()
{
	if (level.gametype != "sd" && level.gametype != "dm")
		return;

	if (game["firstInit"])
	{
		precacheString2("STRING_AFK_WARNING", &"You are AFK! Move or you will be kicked in");
		precacheString2("STRING_AFK_KICKING", &"You are being kicked for being AFK");
	}

	// Horizontal distance from the spawn position that counts as a move
	level.afk_moveTolerance = 5;

	addEventListener("onConnected", ::onConnected);
	addEventListener("onSpawnedPlayer", ::onSpawnedPlayer);
}


onSpawnedPlayer()
{
	self.afk_spawnOrigin = self.origin;
	self.afk_leftSpawn = false;
}


onConnected()
{
	self endon("disconnect");

	// AFK time in ms, kept in pers to survive round restarts
	if (!isDefined(self.pers["afk_time"]))
		self.pers["afk_time"] = 0;

	// Offset thread from other threads, wait for matchinfo to prepare map
	wait level.frame * 10;

	if (!matchIsActivated())
		return;

	timeout = getTimeout();
	if (timeout <= 0)
		return;

	kickDelay = 3; // seconds between showing kick reason and kick
	toleranceSquared = level.afk_moveTolerance * level.afk_moveTolerance;

	lastTime = getTime();

	for (;;)
	{
		wait level.fps_multiplier * 1;

		now = getTime();
		elapsed = now - lastTime;
		lastTime = now;

		// Match was canceled / finished
		if (!matchIsActivated())
			return;

		// Not counted, but AFK time is kept (paused)
		if (!self isCounted())
		{
			self HUD_Destroy();
			continue;
		}

		// Already moved from spawn position in this life - not AFK until next spawn
		if (self.afk_leftSpawn)
			continue;

		// Moved from spawn position (horizontally)
		dx = self.origin[0] - self.afk_spawnOrigin[0];
		dy = self.origin[1] - self.afk_spawnOrigin[1];
		if (dx * dx + dy * dy > toleranceSquared)
		{
			self HUD_Destroy();
			self.afk_leftSpawn = true;
			self.pers["afk_time"] = 0;
			continue;
		}

		self.pers["afk_time"] += elapsed;

		remaining = timeout - int(self.pers["afk_time"] / 1000);

		if (remaining + kickDelay <= 0) // unary minus on variable is not supported
		{
			self kickAfk(timeout);
			return;
		}

		// Kick message cannot be customized in older CoD2x, so show reason before kick
		if (remaining <= 0)
			self HUD_Kicking();

		// Countdown every second in last 15 seconds before kick
		else if (remaining <= 15)
			self HUD_Warning(remaining);
	}
}


// Text above the crosshair, where iprintlnbold messages are (HUD element, so the countdown does not stack up lines like iprintlnbold)
HUD_Create()
{
	if (isDefined(self.afk_hud))
		return;

	self.afk_hud = addHUDClient(self, 0, 120, 1.4, (1, 0.2, 0.2), "center", "top", "center", "top");
	self.afk_hud.font = "default";
	self.afk_hud.archived = false;

	self.afk_hud_value = addHUDClient(self, 0, 140, 1.4, (1, 0.2, 0.2), "center", "top", "center", "top");
	self.afk_hud_value.font = "default";
	self.afk_hud_value.archived = false;
}

HUD_Warning(remaining)
{
	self HUD_Create();
	self.afk_hud setText(game["STRING_AFK_WARNING"]);
	self.afk_hud_value.alpha = 1;
	self.afk_hud_value setValue(remaining);
}

HUD_Kicking()
{
	self HUD_Create();
	self.afk_hud setText(game["STRING_AFK_KICKING"]);
	self.afk_hud_value.alpha = 0;
}

HUD_Destroy()
{
	if (isDefined(self.afk_hud))
		self.afk_hud destroy2();
	if (isDefined(self.afk_hud_value))
		self.afk_hud_value destroy2();
	self.afk_hud = undefined;
	self.afk_hud_value = undefined;
}


kickAfk(timeout)
{
	uuid = self matchPlayerGetData("uuid");

	iprintln(self.name + "^7 was kicked: ^1AFK for " + timeout + " seconds");
	logprint("AFK: " + uuid + " (" + self.name + ") was kicked after " + timeout + " seconds at spawn position\n");

	self.pers["afk_time"] = 0;

	// Reason is shown in disconnect dialog and to all players as "<name> <reason>" (CoD2x with kick reason support - callofduty2x/CoD2x#45, older versions ignore it)
	kick(self getEntityNumber(), "^1was kicked for being AFK^7 (did not move from spawn for " + timeout + " seconds)");
}


// Player in team, alive, spawned, in live time
isCounted()
{
	if (isDefined(self.pers["isBot"]) && self.pers["isBot"])
		return false;

	if (!isDefined(self.pers["team"]) || (self.pers["team"] != "allies" && self.pers["team"] != "axis"))
		return false;

	if (self.sessionstate != "playing")
		return false;

	if (!isDefined(self.afk_spawnOrigin))
		return false;

	return maps\mp\gametypes\_matchinfo_leaver::isLiveTime();
}


getTimeout()
{
	timeout = matchGetData("afkTimeout");
	if (!isDigitalNumber(timeout))
		return 0;
	return int(timeout);
}
