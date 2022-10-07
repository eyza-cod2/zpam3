#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onCvarChanged",    	 	::onCvarChanged);

	registerCvar("scr_killcam", "BOOL", 1);

	if(game["firstInit"])
	{
		precacheString(&"MP_KILLCAM");
		precacheString(&"PLATFORM_PRESS_TO_SKIP");
		precacheString(&"PLATFORM_PRESS_TO_RESPAWN");
	}
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_killcam":
		{
			level.scr_killcam = value;
			if (!isRegisterTime)
				maps\mp\gametypes\_archive::update();
			return true;
		}
	}
	return false;
}

killcam(attackerNum, pastTime, length, offsetTime, respawn, isReplay)
{
	self endon("spawned");

	if (!isDefined(isReplay))
		isReplay = false;

	if(attackerNum < 0)
		return;

	self.killcam = true;

	spectatorclient = self.spectatorclient;

	if (!isReplay)
		self.sessionstate = "spectator";
	self.spectatorclient = attackerNum;
	self.archivetime = pastTime;
	self.psoffsettime = offsetTime;

	// Allow spectating all in killcam
	self.skip_setspectatepermissions = true;	// ignore spectate permissions
	self allowSpectateTeam("allies", true);
	self allowSpectateTeam("axis", true);
	self allowSpectateTeam("freelook", true);
	self allowSpectateTeam("none", true);


	// wait till the next server frame to allow code a chance to update archivetime if it needs trimming
	wait level.frame;

	cutedTime = pastTime - self.archivetime;
	//self iprintln(cutedTime);


	if(cutedTime >= length)
	{
		if (!isReplay)
		{
			self.sessionstate = "dead";
			self.spectatorclient = -1;
		}
		self.archivetime = 0;
		self.psoffsettime = 0;

		self.killcam = false;

		return;
	}


	if(!isdefined(self.kc_topbar))
	{
		self.kc_topbar = newClientHudElem2(self);
		self.kc_topbar.archived = false;
		self.kc_topbar.x = 0;
		self.kc_topbar.y = 0;
		self.kc_topbar.horzAlign = "fullscreen";
		self.kc_topbar.vertAlign = "fullscreen";
		self.kc_topbar.alpha = 0.5;
		self.kc_topbar.sort = 99;
		self.kc_topbar setShader("black", 640, 100);
	}

	if(!isdefined(self.kc_bottombar))
	{
		self.kc_bottombar = newClientHudElem2(self);
		self.kc_bottombar.archived = false;
		self.kc_bottombar.x = 0;
		self.kc_bottombar.y = 380;
		self.kc_bottombar.horzAlign = "fullscreen";
		self.kc_bottombar.vertAlign = "fullscreen";
		self.kc_bottombar.alpha = 0.5;
		self.kc_bottombar.sort = 99;
		self.kc_bottombar setShader("black", 640, 100);
	}

	if(!isdefined(self.kc_title))
	{
		self.kc_title = newClientHudElem2(self);
		self.kc_title.archived = false;
		self.kc_title.x = 0;
		self.kc_title.y = 40;
		self.kc_title.alignX = "center";
		self.kc_title.alignY = "middle";
		self.kc_title.horzAlign = "center_safearea";
		self.kc_title.vertAlign = "top";
		self.kc_title.sort = 999; // force to draw after the bars
		self.kc_title.fontScale = 2.5;

		if (isReplay)
		{
			self.kc_title.y = 62;
		}
		self.kc_title setText(&"MP_KILLCAM");
	}

	if (isReplay)
	{
		if(!isdefined(self.kc_playername))
		{
			player = GetEntityByClientId(attackerNum);
			if (isDefined(player))
			{
				self.kc_playername = newClientHudElem2(self);
				self.kc_playername.archived = false;
				self.kc_playername.x = 0;
				self.kc_playername.y = 85;
				self.kc_playername.alignX = "center";
				self.kc_playername.alignY = "middle";
				self.kc_playername.horzAlign = "center_safearea";
				self.kc_playername.vertAlign = "top";
				self.kc_playername.fontScale = 1.5;
				self.kc_playername.sort = 999; // force to draw after the bars
				self.kc_playername setplayernamestring(player);
			}
		}
	}



	if(!isdefined(self.kc_skiptext))
	{
		self.kc_skiptext = newClientHudElem2(self);
		self.kc_skiptext.archived = false;
		self.kc_skiptext.x = 0;
		self.kc_skiptext.y = 85;
		self.kc_skiptext.alignX = "center";
		self.kc_skiptext.alignY = "middle";
		self.kc_skiptext.horzAlign = "center_safearea";
		self.kc_skiptext.vertAlign = "top";
		self.kc_skiptext.sort = 999; // force to draw after the bars
		self.kc_skiptext.font = "default";
		self.kc_skiptext.fontscale = 1.5;

		if (isReplay)
		{
			self.kc_skiptext.vertAlign = "bottom";
			self.kc_skiptext.y = -70;
		}
	}


	if(isdefined(respawn) && !isReplay)
		self.kc_skiptext setText(&"PLATFORM_PRESS_TO_RESPAWN");
	else
		self.kc_skiptext setText(&"PLATFORM_PRESS_TO_SKIP");


	if(!isdefined(self.kc_timer))
	{
		self.kc_timer = newClientHudElem2(self);
		self.kc_timer.archived = false;
		self.kc_timer.x = 0;
		self.kc_timer.y = -50;
		self.kc_timer.alignX = "center";
		self.kc_timer.alignY = "middle";
		self.kc_timer.horzAlign = "center_safearea";
		self.kc_timer.vertAlign = "bottom";
		self.kc_timer.fontScale = 3;
		self.kc_timer.sort = 999;
	}

	self.kc_timer setTenthsTimer(length - cutedTime);

	self thread spawnedKillcamCleanup();
	self thread waitSkipKillcamButton();

	self thread waitKillcamTime();
	self thread waitTime(length);

	self waittill("end_killcam");

	self removeKillcamElements();

	if (isReplay)
	{
		if (self.spectatorclient == attackerNum)
			self.spectatorclient = spectatorclient;
	}
	else
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
	}
	self.archivetime = 0;
	self.psoffsettime = 0;

	self.killcam = undefined;

	self.skip_setspectatepermissions = false;
	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}

waitTime(time)
{
	self endon("disconnect");
	self endon("end_killcam");

	wait level.fps_multiplier * time;
	self notify("end_killcam");
}

waitKillcamTime()
{
	self endon("disconnect");
	self endon("end_killcam");

	wait level.fps_multiplier * (self.archivetime - level.frame);
	self notify("end_killcam");
}

waitSkipKillcamButton()
{
	self endon("disconnect");
	self endon("end_killcam");

	while(self useButtonPressed())
		wait level.frame;

	while(!(self useButtonPressed()))
		wait level.frame;

	self notify("end_killcam");
}

removeKillcamElements()
{
	if(isDefined(self.kc_topbar))
		self.kc_topbar destroy2();
	if(isDefined(self.kc_bottombar))
		self.kc_bottombar destroy2();
	if(isDefined(self.kc_title))
		self.kc_title destroy2();
	if(isDefined(self.kc_skiptext))
		self.kc_skiptext destroy2();
	if(isDefined(self.kc_timer))
		self.kc_timer destroy2();
	if(isDefined(self.kc_playername))
		self.kc_playername destroy2();
}

spawnedKillcamCleanup()
{
	self endon("disconnect");
	self endon("end_killcam");

	self waittill("spawned");
	self removeKillcamElements();
}
