#include maps\mp\gametypes\global\_global;

/*
AFK kick for CoD2x match.

Enabled only if match data contains key "afkTimeout" with number of seconds (for example 60).
If the key is missing or is 0, feature is disabled.
Works in SD and DM.

Player in team (allies / axis) who is alive and does not move, does not turn the view and does not press
attack / use / melee for afkTimeout seconds of live time is kicked from the server.
The reason is shown to the player 3 seconds before the kick and passed to kick() - newer CoD2x shows it
in the disconnect dialog and does not ban the player. Older CoD2x ignores the reason and bans the player
for sv_kickBanTime seconds (0 in all competitive rulesets).
Only live time is counted (same as leaver detection):
 - SD: from the end of strat time to the end of the round
 - DM: from the end of strat time to the end of the map
Ready-ups, timeouts, strat time, time between rounds, pistol bash rounds and time when player is dead or spectating are not counted,
but they do not reset the inactive time either, so AFK player is kicked even if he dies in every round.
Player is warned 30, 20 and 10 seconds before the kick, moving cancels the kick until the player is kicked.

Spinning the view to avoid the kick (+left / +right bind, weight on the mouse, macro) is not counted as activity:
when player does not move and does not press any button, a turn of the view in the same direction and at nearly
the same speed as in the previous second, without moving the view up / down, is ignored.

AFK kick is not reported in match data - kicked player is not connected anymore,
so if he does not come back, leaver detection counts his time as usual.
*/
init()
{
	if (level.gametype != "sd" && level.gametype != "dm")
		return;

	addEventListener("onConnected", ::onConnected);
}


onConnected()
{
	self endon("disconnect");

	// Inactive time in ms, kept in pers to survive round restarts
	if (!isDefined(self.pers["afk_time"]))
		self.pers["afk_time"] = 0;

	// Turn of the view in last counted second, kept in pers to detect spinning right after round restart
	if (!isDefined(self.pers["afk_yawDelta"]))
		self.pers["afk_yawDelta"] = 0;

	// Offset thread from other threads, wait for matchinfo to prepare map
	wait level.frame * 10;

	if (!matchIsActivated())
		return;

	timeout = getTimeout();
	if (timeout <= 0)
		return;

	kickDelay = 3; // seconds between showing kick reason and kick

	lastOrigin = self.origin;
	lastAngles = self getPlayerAngles();
	lastTime = getTime();
	lastWarning = 0;
	wasCounted = false;

	for (;;)
	{
		wait level.fps_multiplier * 1;

		now = getTime();
		elapsed = now - lastTime;
		lastTime = now;

		// Match was canceled / finished
		if (!matchIsActivated())
			return;

		origin = self.origin;
		angles = self getPlayerAngles();
		moved = distanceSquared(origin, lastOrigin) > 1;
		buttons = self attackButtonPressed() || self useButtonPressed() || self meleeButtonPressed();
		pitchDelta = angleDelta(angles[0], lastAngles[0]);
		yawDelta = angleDelta(angles[1], lastAngles[1]);
		viewChanged = pitchDelta != 0 || yawDelta != 0;
		spinning = !moved && !buttons && isSpinning(pitchDelta, yawDelta, self.pers["afk_yawDelta"]);
		active = moved || buttons || (viewChanged && !spinning);
		lastOrigin = origin;
		lastAngles = angles;

		// Not counted, but inactive time is kept (paused)
		if (!self isCounted())
		{
			lastWarning = 0;
			wasCounted = false;
			continue;
		}

		// First counted check after a pause (respawn in DM, end of strat time) - position and angles
		// may be changed by spawn, so only take new baseline (already done above)
		if (!wasCounted)
		{
			wasCounted = true;
			continue;
		}

		// Turn speed is saved only in counted time, so spinning is detected also right after respawn / round restart
		self.pers["afk_yawDelta"] = yawDelta;

		if (active)
		{
			if (lastWarning != 0)
				self iprintlnbold("^2AFK kick canceled");
			self.pers["afk_time"] = 0;
			lastWarning = 0;
			continue;
		}

		self.pers["afk_time"] += elapsed;

		remaining = timeout - int(self.pers["afk_time"] / 1000);

		if (remaining <= -kickDelay)
		{
			self kickAfk(timeout);
			return;
		}

		// Kick message cannot be customized in older CoD2x, so show reason before kick
		if (remaining <= 0)
		{
			if (lastWarning != -1)
			{
				lastWarning = -1;
				self iprintlnbold("^1You are being kicked for being AFK");
			}
		}

		// Warn 30, 20 and 10 seconds before kick
		else if (remaining <= 30)
		{
			warning = int((remaining + 9) / 10) * 10; // 30, 20, 10
			if (warning != lastWarning)
			{
				lastWarning = warning;
				self iprintlnbold("^1You are AFK!^7 Move or you will be kicked in " + remaining + " seconds");
			}
		}
	}
}


kickAfk(timeout)
{
	uuid = self matchPlayerGetData("uuid");

	iprintln(self.name + "^7 was kicked: ^1AFK for " + timeout + " seconds");
	logprint("AFK: " + uuid + " (" + self.name + ") was kicked after " + timeout + " seconds of inactivity\n");

	self.pers["afk_time"] = 0;

	// Reason is shown in disconnect dialog and to all players as "<name> <reason>" (CoD2x with kick reason support - callofduty2x/CoD2x#45, older versions ignore it)
	kick(self getEntityNumber(), "^1was kicked for being AFK^7 (no activity for " + timeout + " seconds)");
}


// Player in team, alive, in live time
isCounted()
{
	if (isDefined(self.pers["isBot"]) && self.pers["isBot"])
		return false;

	if (!isDefined(self.pers["team"]) || (self.pers["team"] != "allies" && self.pers["team"] != "axis"))
		return false;

	if (self.sessionstate != "playing")
		return false;

	return maps\mp\gametypes\_matchinfo_leaver::isLiveTime();
}


// View is turned in the same direction at nearly the same speed as in previous second, without moving it up / down
// (+left / +right bind, weight on the mouse, macro). Real player holding an angle makes small corrections in both directions.
isSpinning(pitchDelta, yawDelta, lastYawDelta)
{
	if (yawDelta == 0 || lastYawDelta == 0)
		return false;

	// Different direction
	if ((yawDelta > 0) != (lastYawDelta > 0))
		return false;

	// View moved up / down
	if (absValue(pitchDelta) > 0.5)
		return false;

	// Speed changed by more than 25% (+1 degree tolerance for slow turning)
	return absValue(yawDelta - lastYawDelta) <= absValue(lastYawDelta) * 0.25 + 1;
}


// Difference of two angles in range -180 .. 180
angleDelta(angle, lastAngle)
{
	delta = angle - lastAngle;
	while (delta > 180)
		delta -= 360;
	while (delta < -180)
		delta += 360;
	return delta;
}


absValue(num)
{
	if (num < 0)
		return num * -1;
	return num;
}


getTimeout()
{
	timeout = matchGetData("afkTimeout");
	if (!isDigitalNumber(timeout))
		return 0;
	return int(timeout);
}

