/*
	This file is included in every .gsc script
	Functions defined here are accesible in every file without need to provide a path to this script
*/

/*************************************************************************************************************
* Init functions
**************************************************************************************************************/

InitSystems()
{
	return maps\mp\gametypes\global\_init::InitSystems();
}
InitModules()
{
	return maps\mp\gametypes\global\_init::InitModules();
}
AbortLevel()
{
	return maps\mp\gametypes\_callbacksetup::AbortLevel();
}



/*************************************************************************************************************
* Event system
**************************************************************************************************************/
addEventListener(eventName, funcPointer)
{
	return maps\mp\gametypes\global\events::addListener(eventName, funcPointer);
}



/*************************************************************************************************************
* Precache
**************************************************************************************************************/
precacheString2(gameName, string)
{
	return maps\mp\gametypes\global\precache::precacheString2(gameName, string);
}



/*************************************************************************************************************
* Player
**************************************************************************************************************/
GetEntityByClientId(id)
{
	return maps\mp\gametypes\global\player::GetEntityByClientId(id);
}
isPlayerLookingAt(entity)
{
	return maps\mp\gametypes\global\player::isPlayerLookingAt(entity);
}
isPlayerInSight(player)
{
	return maps\mp\gametypes\global\player::isPlayerInSight(player);
}
isEntityInSight(entity)
{
	return maps\mp\gametypes\global\player::isEntityInSight(entity);
}
getLookingAtPosition()
{
	return maps\mp\gametypes\global\player::getLookingAtPosition();
}
getFOV()
{
	return maps\mp\gametypes\global\player::getFOV();
}

/*************************************************************************************************************
* Cvar system
**************************************************************************************************************/
registerCvar(cvar, type, defaultValue, minValue, maxValue)
{
	return maps\mp\gametypes\global\cvar_system::registerCvar(cvar, type, defaultValue, minValue, maxValue);
}
registerCvarEx(method, cvar, type, defaultValue, minValue, maxValue)
{
	return maps\mp\gametypes\global\cvar_system::registerCvarEx(method, cvar, type, defaultValue, minValue, maxValue);
}
setCvarIfChanged(cvar, value)
{
	return maps\mp\gametypes\global\cvar_system::setCvarIfChanged(cvar, value);
}
setClientCvarIfChanged(cvar, value)
{
	return maps\mp\gametypes\global\cvar_system::setClientCvarIfChanged(cvar, value);
}
changeCvarQuiet(cvarName, value)
{
	return maps\mp\gametypes\global\cvar_system::changeCvarQuiet(cvarName, value);
}
setClientCvar2(cvar, value, aaa, bbb, ccc)
{
	return maps\mp\gametypes\global\cvar_system::setClientCvar2(cvar, value, aaa, bbb, ccc);
}



/*************************************************************************************************************
* Rules
**************************************************************************************************************/
PAMModeContains(string)
{
	return maps\mp\gametypes\global\rules::PAMModeContains(string);
}
ruleCvarDefault(array, cvarName, value)
{
	return maps\mp\gametypes\global\rules::ruleCvarDefault(array, cvarName, value);
}

/*************************************************************************************************************
* HUD system
**************************************************************************************************************/
newHudElem2()
{
	return maps\mp\gametypes\global\hud_system::newHudElem2();
}
newClientHudElem2(player)
{
	return maps\mp\gametypes\global\hud_system::newClientHudElem2(player);
}
destroy2()
{
	return maps\mp\gametypes\global\hud_system::destroy2();
}
addHUD(x, y, fontSize, color, alignX, alignY, horzAlign, vertAlign)
{
	return maps\mp\gametypes\global\hud_system::addHUD(x, y, fontSize, color, alignX, alignY, horzAlign, vertAlign);
}
addHUDClient(player, x, y, fontSize, color, alignX, alignY, horzAlign, vertAlign)
{
	return maps\mp\gametypes\global\hud_system::addHUDClient(player, x, y, fontSize, color, alignX, alignY, horzAlign, vertAlign);
}
removeHUD()
{
	return maps\mp\gametypes\global\hud_system::removeHUD();
}
removeHUDSmooth(time)
{
	return maps\mp\gametypes\global\hud_system::removeHUDSmooth(time);
}
showHUDSmooth(time, from, to)
{
	return maps\mp\gametypes\global\hud_system::showHUDSmooth(time, from, to);
}
hideHUDSmooth(time, from, to)
{
	return maps\mp\gametypes\global\hud_system::hideHUDSmooth(time, from, to);
}
SetPlayerWaypoint(camera_player, waypoint_player)
{
	return maps\mp\gametypes\global\hud_system::SetPlayerWaypoint(camera_player, waypoint_player);
}


/*************************************************************************************************************
* String
**************************************************************************************************************/
startsWith(string, substring)
{
	return maps\mp\gametypes\global\string::startsWith(string, substring);
}
contains(string, substring)
{
	return maps\mp\gametypes\global\string::contains(string, substring);
}
isDigitalNumber(string)
{
	return maps\mp\gametypes\global\string::isDigitalNumber(string);
}
isDigit(char)
{
	return maps\mp\gametypes\global\string::isDigit(char);
}
splitString(string, delimiter)
{
	return maps\mp\gametypes\global\string::splitString(string, delimiter);
}
removeColorsFromString(string)
{
	return maps\mp\gametypes\global\string::removeColorsFromString(string);
}
formatTime(timeSec, separator)
{
	return maps\mp\gametypes\global\string::formatTime(timeSec, separator);
}
plural_s(num, text)
{
	return maps\mp\gametypes\global\string::plural_s(num, text);
}
format_fractional(num, fixedPositions, precision)
{
	return maps\mp\gametypes\global\string::format_fractional(num, fixedPositions, precision);
}
