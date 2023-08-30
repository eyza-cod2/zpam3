#include maps\mp\gametypes\global\_global;

init()
{
	// Precache
	if (game["firstInit"])
	{
		precacheString2("STRING_FORCEDOWNLOAD_ERROR_1", &"You must download zPAM mod to play on this server.");
		precacheString2("STRING_FORCEDOWNLOAD_ERROR_2", &"Downloading was enabled (/cl_allowDownload 1).");
		precacheString2("STRING_FORCEDOWNLOAD_ERROR_3", &"Please reconnect to the server.");

		precacheStatusIcon("icon_mod");
	}

	setCvar("sv_allowDownload", "1");
	setCvar("sv_wwwDlDisconnected", "0"); // disconnect player while downloading?

	addEventListener("onConnected",     ::onConnected);
}

onConnected()
{
	// Define variables
	if (!isDefined(self.pers["modDownloaded"]))
	{
		self.pers["modDownloaded"] = false;
		self.pers["downloadDisableResponse"] = false;
	}

	if (self.pers["isBot"])
		self.pers["modDownloaded"] = true;

	// Ignore if pam is not installed correctly
	if (level.pam_installation_error)
		return;

	if (!self.pers["modDownloaded"] && game["state"] != "intermission")
	{
		// Show error message even if we dont know yet if mod is downloaded
		// Message is not visible if menu is open and is removed when response comes
		self showErrorMessage();
	}
}

// Called from _menus::OnConnected() when we are waiting for response
checkDownload()
{
	self endon("disconnect");

	// After a few second of not getting response from client disable all
	wait level.fps_multiplier * 3;

	// Ignore if pam is not installed correctly
	if (level.pam_installation_error || game["state"] == "intermission")
		return;

	if (!self.pers["modDownloaded"])
	{
		self.pers["downloadDisableResponse"] = true;

		self closeMenu();
		self closeInGameMenu();
		self setClientCvar2("g_scriptMainMenu", "");

		spawnModNotDownloaded();
	}
}

spawnModNotDownloaded()
{
  	self endon("disconnect");

	self setClientCvar2("cl_allowdownload", "1"); // enable downloading on client side (just for sure)
	self setClientCvar2("cl_wwwdownload", "1");

	[[level.spawnSpectator]]((999999, 999999, -999999), (90, 0, 0));

	wait level.frame; // wait to correctly replace statusicon (is set in readyup)

	// Special icon for player with not downloaded mod
	self.statusicon = "icon_mod";
}

modIsDownloaded()
{
	self.pers["modDownloaded"] = true;

	removeErrorMessage();
}


waitingForResponse()
{
	return !self.pers["modDownloaded"] && !self.pers["downloadDisableResponse"];
}

modIsNotDownloadedForSure()
{
	return !self.pers["modDownloaded"] && self.pers["downloadDisableResponse"];
}


showErrorMessage()
{
	// Background
	self.forcedownload = addHUDClient(self, 0, 0, undefined, (1,1,1), "left", "top", "fullscreen", "fullscreen");
	self.forcedownload.sort = 1000;
	self.forcedownload.foreground = true;
	self.forcedownload.archived = false;
	self.forcedownload setShader("black", 640, 480);

	self.forcedownloadm1 = addHUDClient(self, 0, 150, 1.8, (1, .86, .4), "center", "top", "center");
	self.forcedownloadm1.sort = 1001;
	self.forcedownloadm1.foreground = true;
	self.forcedownloadm1.archived = false;
	self.forcedownloadm1 SetText(game["STRING_FORCEDOWNLOAD_ERROR_1"]);

	self.forcedownloadm2 = addHUDClient(self, 0, 174, 1.4, (1, .86, .4), "center", "top", "center");
	self.forcedownloadm2.sort = 1002;
	self.forcedownloadm2.foreground = true;
	self.forcedownloadm2.archived = false;
	self.forcedownloadm2 SetText(game["STRING_FORCEDOWNLOAD_ERROR_2"]);

	self.forcedownloadm3 = addHUDClient(self, 0, 210, 1.6, (1, .86, .4), "center", "top", "center");
	self.forcedownloadm3.sort = 1003;
	self.forcedownloadm3.foreground = true;
	self.forcedownloadm3.archived = false;
	self.forcedownloadm3 SetText(game["STRING_FORCEDOWNLOAD_ERROR_3"]);
}

removeErrorMessage()
{
	if (isdefined(self.forcedownload))
		self.forcedownload destroy2();
	if (isdefined(self.forcedownloadm1))
		self.forcedownloadm1 destroy2();
	if (isdefined(self.forcedownloadm2))
		self.forcedownloadm2 destroy2();
	if (isdefined(self.forcedownloadm3))
		self.forcedownloadm3 destroy2();
}
