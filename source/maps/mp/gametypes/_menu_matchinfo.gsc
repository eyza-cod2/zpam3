#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onConnected",     ::onConnected);

}

onConnected()
{
	self endon("disconnect");

	if (!isDefined(self.pers["menu_matchinfo_keepRefreshing"]))
		self.pers["menu_matchinfo_keepRefreshing"] = 0;

	// This will make sure menu is still responsible even if map is restarted (next round)
	if (self.pers["menu_matchinfo_keepRefreshing"] > 0)
		self thread refreshMenu();
}



// Called when menu is opened
// Keep refreshing untill we know player closed the menu
refreshMenu() {
	self endon("disconnect");

	// Make sure onlny 1 thread is running
	self notify("menu_matchinfo_refreshMenu");
	self endon("menu_matchinfo_refreshMenu");

	wait level.frame; // wait till level variables are defined

	self.pers["menu_matchinfo_keepRefreshing"] = 1;

	repeats = 0;

	while(true) {

		// Stop when
		// - player is moving (so menu is closed)
		// - player left clicked
		if (self.pers["menu_matchinfo_keepRefreshing"] == 0 || (self.pers["menu_matchinfo_keepRefreshing"] == 1 && (self.isMoving || self attackbuttonpressed())))
		{
			if (repeats > 3) {
				// Stop refreshing
				self.pers["menu_matchinfo_keepRefreshing"] = 0;

				// Hide
				self setClientCvarIfChanged("ui_matchinfo_description", "Loading...");
				self setClientCvarIfChanged("ui_matchinfo_players_names", "");
				self setClientCvarIfChanged("ui_matchinfo_players_nicknames", "");
				self setClientCvarIfChanged("ui_matchinfo_players_side", "");
				self setClientCvarIfChanged("ui_matchinfo_players_status", "");
				
				//self iprintln("^1CANCEL ^7updating menu match info " + self.pers["menu_matchinfo_keepRefreshing"] + " " + self.isMoving + " " + self attackbuttonpressed());

				return;
			}
			repeats++;
		} else {
			repeats = 0;
		}

		players_names = "";
		players_nicknames = "";
		players_side = "";
		players_status = "";

		if (!matchIsActivated()) {
			players_names = "Match is not activated";
		} else {
			players_names = level.match_players_names;
			players_nicknames = level.match_players_nicknames;
			players_side = level.match_players_side;
			players_status = level.match_players_status;
		}

		self setClientCvarIfChanged("ui_matchinfo_description", 		level.match_description);
		self setClientCvarIfChanged("ui_matchinfo_players_names", 		players_names);
		self setClientCvarIfChanged("ui_matchinfo_players_nicknames", 	players_nicknames);
		self setClientCvarIfChanged("ui_matchinfo_players_side", 		players_side);
		self setClientCvarIfChanged("ui_matchinfo_players_status", 		players_status);




		wait level.fps_multiplier * 1;
	}
}

