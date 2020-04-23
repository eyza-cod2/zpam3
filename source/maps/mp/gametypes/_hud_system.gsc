#include maps\mp\gametypes\_callbacksetup;
// CoD2 has can show up only 31 hud elements at once
// It means when we add 32. hud elemtent (global, client, timer, shader,..) - element is not visible (is saved, but not showed)
// Added checking system if we have free slots for hud, if not, print warning

// COD2 functions that can be called on hudElement variable:
/*
destroy()
moveovertime(time)
scaleovertime(time, new_with, new_height)
fadeovertime(time)
setwaypoint ??
setvalue(int)
setclockup
setclock(time_in_seconds, total_clock_time_in_seconds, shadername[, width, height])
settenthstimerup
settenthstimer
settimerup
settimer
setshader
setgametypestring
setmapnamestring
setplayernamestring
settext
*/

init()
{
    level.HUDElements = 0;

	addEventListener("onConnected",     ::onConnected);
}

onConnected()
{
	self.HUDElements = 0;
}



// (int, int, float, (float, float, float), [left center right], [top middle bottom], [subleft left center right fullscreen noscale alignto640 center_safearea], [subtop top middle bottom fullscreen noscale alignto480 center_safearea])
addHUD(x, y, fontSize, color, alignX, alignY, horzAlign, vertAlign)
{
    if (!isDefined(alignX))
        alignX = "left"; // left center right
    if (!isDefined(alignY))
        alignY = "top"; // top middle bottom
    if (!isDefined(horzAlign))
        horzAlign = "subleft"; // subleft left center right fullscreen noscale alignto640 center_safearea
    if (!isDefined(vertAlign))
        vertAlign = "subtop"; // subtop top middle bottom fullscreen noscale alignto480 center_safearea

    hud = newHudElem();
    hud.x = x;
    hud.y = y;
    hud.horzAlign = horzAlign;
    hud.vertAlign = vertAlign;
    hud.alignX = alignX;
    hud.alignY = alignY;
    if (isDefined(fontSize)) hud.fontScale = fontSize;
    if (isDefined(color)) hud.color = color;
    //hud.font = "default"; // default bigfixed smallfixed
    //hud.foreground = false;
    //hud.sort = 0;
    //hud.label = ""; // add string before
    //hud.archived = true; // if is false, hud-elemtn is not visible for spectating-player

    level.HUDElements++;

    return hud;
}

addHUDClient(player, x, y, fontSize, color, alignX, alignY, horzAlign, vertAlign)
{
    if (!isDefined(alignX))
        alignX = "left"; // left center right
    if (!isDefined(alignY))
        alignY = "top"; // top middle bottom
    if (!isDefined(horzAlign))
        horzAlign = "subleft"; // subleft left center right fullscreen noscale alignto640 center_safearea
    if (!isDefined(vertAlign))
        vertAlign = "subtop"; // subtop top middle bottom fullscreen noscale alignto480 center_safearea

    hud = newClientHudElem(player);
    hud.client = player;
    hud.x = x;
    hud.y = y;
    hud.horzAlign = horzAlign;
    hud.vertAlign = vertAlign;
    hud.alignX = alignX;
    hud.alignY = alignY;
    if (isDefined(fontSize)) hud.fontScale = fontSize;
    if (isDefined(color)) hud.color = color;

    player.HUDElements++;

	/#
	if (player.HUDElements + level.HUDElements > 31)
	{
		assertMsg("^1Maximum showable hud elements exceeded! " + (player.HUDElements + level.HUDElements) + " " + player.name);
	}
	#/

    return hud;
}

removeHUD()
{
    if (isDefined(self.client))
        self.client.HUDElements--;
    else
        level.HUDElements--;

    self destroy();
}

removeHUDSmooth(time)
{
    if (time > 0) self FadeOverTime(time);
    self.alpha = 0;

    wait level.fps_multiplier * time;

    if (self.alpha)
		self removeHUD();
}

showHUDSmooth(time, from, to)
{
    if (!isDefined(from))
        from = 0;
    if (!isDefined(to))
        to = 1;

    // If hud is already showed
    if (self.alpha == to)
        return;

    self.alpha = from;
    if (time > 0) self FadeOverTime(time);
    self.alpha = to;
}

hideHUDSmooth(time, from, to)
{
    if (!isDefined(from))
        from = 1;
    if (!isDefined(to))
        to = 0;

    // If hud is already hided
    if (self.alpha == to)
        return;

    self.alpha = from;
    if (time > 0) self FadeOverTime(time);
    self.alpha = to;
}
