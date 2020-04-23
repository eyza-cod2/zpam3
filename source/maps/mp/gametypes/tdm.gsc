#include maps\mp\gametypes\_callbacksetup;

main()
{
	InitCallbacks();

	setcvar("g_gametype", "sd");
	map(getCvar("mapname"));
}
