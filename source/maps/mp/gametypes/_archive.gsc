#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onCvarChanged",    	 	::onCvarChanged);

	registerCvar("g_antilag", "BOOL", 1); 				// Turn on antilag checks for weapon hits

	update();

}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "g_antilag":
		{
			level.antilag = value;
			if (!isRegisterTime)
				update();
			return true;
		}
	}
	return false;
}

// This function decides if game archive should be enabled or not
// If is enabled, all game state is saved in game for history
// Used especially for killcam to play history of players
// Is in separate file because of use also in spectating system
// This function is called from multiple places
update()
{
	if(level.scr_killcam ||
		level.antilag ||
		level.autoSpectating_do)
		setarchive(true);
	else
		setarchive(false);
}
