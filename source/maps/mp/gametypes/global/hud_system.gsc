/*
	CoD2
	- can show only 30 archived huds and 30 not archived huds at once
	- archived:
	 	- means that hud elements are stored in memory to use them for killcam.
		- Also if client hud is archived, that value is showed for spectating player
		- when player is in spectator and have own archived huds, these huds are not visible when spectating player
	- When more than 30 hud element is added, hud is saved but not visible
	 	- so to always display a hud, it needs to be registered first
	- in this file I added counter witch count number of used hud elements
		- if count is exceeded, warning is showed
		- it will only works if we will use only these functions to create hud

	COD2 functions that can be called on hudElement variable:
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

	Hud parameters:
		hud.x = x;
	        hud.y = y;
	        hud.horzAlign = horzAlign;	subleft left center right fullscreen noscale alignto640 center_safearea
	        hud.vertAlign = vertAlign;	subtop top middle bottom fullscreen noscale alignto480 center_safearea
	        hud.alignX = alignX;		left center right
	        hud.alignY = alignY;		top middle bottom
	        hud.fontScale = fontSize;	1.0
	        hud.color = color;		(0, 0, 0)
		hud.alpha = 1;
		hud.archived = true;		will be visible in killcam + for spectating
		hud.sort = 1;			order
		hud.foreground = true;		visible if menu is opened?
		hud.label = ""			add string before?
		hud.font = "default"; 		default bigfixed smallfixed
	By eyza
*/

Init()
{
	/#
	level.HUDElementsArchived = 0;
	level.HUDElementsNonArchived = 0;

	maps\mp\gametypes\global\_global::addEventListener("onConnected",     ::onConnected);
	#/
}

onConnected()
{
	/#
	self.HUDElementsArchived = 0;
	self.HUDElementsNonArchived = 0;
	#/
}


// Use these functions for creating HUD elements!
newHudElem2()
{
	hud = newHudElem();

	// Count usage of HUD elements in debug mode
        /#
        hud thread watchArchived();
        #/

	return hud;
}

// Use these functions for creating HUD elements!
newClientHudElem2(player)
{
	hud = newClientHudElem(player);
        hud.client = player;

	// Count usage of HUD elements in debug mode
        /#
        hud thread watchArchivedClient(player);
        #/

	return hud;
}

// Use this function to remove HUD element!
destroy2()
{
	/#
	if (isDefined(self.client))
	{
		if (self.archived)
			self.client.HUDElementsArchived--;
		else
			self.client.HUDElementsNonArchived--;
	}
	else
	{
		if (self.archived)
			level.HUDElementsArchived--;
		else
			level.HUDElementsNonArchived--;
	}
	#/

	self destroy();
}



// Shorthand for creating HUD elemets
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

    hud = newHudElem2();
    hud.x = x;
    hud.y = y;
    hud.horzAlign = horzAlign;
    hud.vertAlign = vertAlign;
    hud.alignX = alignX;
    hud.alignY = alignY;
    if (isDefined(fontSize)) hud.fontScale = fontSize;
    if (isDefined(color)) hud.color = color;

    return hud;
}

// Shorthand for creating HUD elemets
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

    hud = newClientHudElem2(player);
    hud.x = x;
    hud.y = y;
    hud.horzAlign = horzAlign;
    hud.vertAlign = vertAlign;
    hud.alignX = alignX;
    hud.alignY = alignY;
    if (isDefined(fontSize)) hud.fontScale = fontSize;
    if (isDefined(color)) hud.color = color;

    return hud;
}

watchArchived()
{
	waittillframeend; // wait untill .archoved attribute is set

	if (self.archived)
		level.HUDElementsArchived++;
	else
		level.HUDElementsNonArchived++;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		players[i] checkCount();
	}
}

watchArchivedClient(player)
{
	waittillframeend;

	// stalo se to pri multi plantovani
	if (isDefined(self.archived))	// if display is deleted imiditly after creating, archived is not defined
	{
		if (self.archived) // wait untill .archoved attribute is set
			player.HUDElementsArchived++;
		else
			player.HUDElementsNonArchived++;
	}


	player checkCount();
}

getArchivedCount()
{
	return level.HUDElementsArchived + self.HUDElementsArchived;
}

getNonArchivedCount()
{
	return level.HUDElementsNonArchived + self.HUDElementsNonArchived;
}

checkCount()
{
	archived = getArchivedCount();
	nonArchived = getNonArchivedCount();

	if (archived > 30)
		println("Archived HUD elements exceeded 30! Archived: " + archived);

	if (nonArchived > 30)
		println("Non-archived HUD elements exceeded 30! Non-Archived: " + nonArchived);

	//iprintln("Archived: " + archived);
	//iprintln("Non-Archived: " + nonArchived);
}



removeHUD()
{
    	self destroy2();
}


removeHUDSmooth(time)
{
    if (time > 0) self FadeOverTime(time);
    self.alpha = 0;

    wait level.fps_multiplier * time;

    if (isDefined(self) && isDefined(self.alpha))
	self removeHUD();
}

showHUDSmooth(time, from, to)
{
    if (!isDefined(from))
        from = 0;
    if (!isDefined(to))
        to = 1;

    // If hud is already showed
    //if (self.alpha == to)
 	//return;

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
    //if (self.alpha == to)
        //return;

    self.alpha = from;
    if (time > 0) self FadeOverTime(time);
    self.alpha = to;
}
