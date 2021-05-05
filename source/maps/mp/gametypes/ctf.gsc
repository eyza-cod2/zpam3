#include maps\mp\gametypes\global\_global;

main()
{
	InitCallbacks();

	setcvar("g_gametype", "sd");
	map(getCvar("mapname"));
}
