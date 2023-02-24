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
/*
Makes HUD element to follow head of player in 3D world
HUD element needs to be aligned with "subleft" and "subtop" to fit between different resolutions and FOVs
Example:
    self.spec_waypoint[index] = addHUDClient(self, 0, 0, 1.2, (1,1,1), "center", "middle", "subleft", "subtop");
    self.spec_waypoint[index] SetPlayerNameString(player);
    self.spec_waypoint[index].offset = (0, 0, 10);
    self.spec_waypoint[index] thread SetPlayerWaypoint(self, player);

If its a shader, these variables needs to be set
    self.spec_waypoint[index] = addHUDClient(self, 0, 0, 1.2, (1,1,1), "center", "middle", "subleft", "subtop");
    self.spec_waypoint[index].shader = "shader_name";
    self.spec_waypoint[index].w = 24;
    self.spec_waypoint[index].h = 24;
    self.spec_waypoint[index].scale = 1;
    self.spec_waypoint[index].offset = (0, 0, 10);
    self.spec_waypoint[index] thread SetPlayerWaypoint(self, player);
*/
SetPlayerWaypoint(camera_player, waypoint_player)
{
	// Make sure only 1 thread is running on this HUD element
	self notify("SetPlayerWaypoint");
	self endon("SetPlayerWaypoint");

	last_x = undefined;
	last_y = undefined;

	waypoint_origin = undefined;

	for(;;)
	{
		wait level.frame;

		if (!isDefined(self) || !isDefined(camera_player) || !isDefined(waypoint_player))
			break;

		camera_player_real = camera_player;

		// If this player is following other player (auto-spectator), choose that player
		if (camera_player.spectatorclient != -1)
		{
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				if (players[i] getEntityNumber() == camera_player.spectatorclient)
				{
					camera_player_real = players[i];
					break;
				}
			}
		}

		fov = 80;
		if (isAlive(camera_player_real))
		{
			weapon_fov["m1carbine_mp"] = 55;
			weapon_fov["m1garand_mp"] = 50;
			weapon_fov["thompson_mp"] = 65;
			weapon_fov["bar_mp"] = 50;
			weapon_fov["springfield_mp"] = 15;
			weapon_fov["greasegun_mp"] = 65;
			weapon_fov["shotgun_mp"] = 65;
			weapon_fov["enfield_mp"] = 50;
			weapon_fov["sten_mp"] = 65;
			weapon_fov["bren_mp"] = 50;
			weapon_fov["enfield_scope_mp"] = 15;
			weapon_fov["mosin_nagant_mp"] = 50;
			weapon_fov["SVT40_mp"] = 50;
			weapon_fov["PPS42_mp"] = 65;
			weapon_fov["ppsh_mp"] = 65;
			weapon_fov["mosin_nagant_sniper_mp"] = 15;
			weapon_fov["kar98k_mp"] = 50;
			weapon_fov["g43_mp"] = 50;
			weapon_fov["mp40_mp"] = 65;
			weapon_fov["mp44_mp"] = 50;
			weapon_fov["kar98k_sniper_mp"] = 15;
			weapon_fov["colt_mp"] = 80;
			weapon_fov["luger_mp"] = 80;
			weapon_fov["tt30_mp"] = 80;
			weapon_fov["webley_mp"] = 80;
			weapon_fov["mg_mp"] = 60;

			current = camera_player_real getcurrentweapon(); // can be none
			zoom = camera_player_real playerAds();	// 1 = zoom | 0 = no zoom

			if (camera_player_real.usingMG)
			{
				current = "mg_mp";
				zoom = 1;
			}

			if (zoom < 0.5)
				zoom = 0;
			else
				zoom = (zoom*2)-1;

			if (isDefined(weapon_fov[current]))
				fov = 80 - (80 - weapon_fov[current]) * zoom;
		}

		waypoint_origin = waypoint_player.origin + self.offset;
		if (isDefined(self.tag) && self.tag == "head")
			waypoint_origin = waypoint_player.headTag.origin + self.offset;

		point = WorldToScreen(camera_player_real maps\mp\gametypes\global\player::getEyeOrigin(), camera_player_real getplayerangles(), waypoint_origin, fov/80);

		self.x = point[0];
		self.y = point[1];
		/*
		if (isDefined(last_x) && isDefined(last_y))
		{
			self.x = (last_x + point[0]) / 2;
			self.y = (last_y + point[1]) / 2;
		}
		last_x = point[0];
		last_y = point[1];
		*/
		// Shader set
		if (isDefined(self.shader) && self.shader != "")
		{
			dist = distance(waypoint_origin, camera_player_real.origin);
			if (dist <= 0) dist = 10;
			const = 1 / (dist * fov/80);
			w = self.w * self.scale * const;
			h = self.h * self.scale * const;

			// Scale up if shader is in corners
			const = 1 + (distance((self.x, self.y - h / 2, 0), (320, 240, 0)) / 640);	// Distance of text from center - text is in 640x480 rectangle aligned left top
			w = w * const;
			h = h * const;

			// Limits of the game
			if (w > 1023) w = 1023;
			if (h > 1023) h = 1023;

			self setShader(self.shader, int(w), int(h));
		}
	}
}

abs (num)
{
	if (num < 0)
		num *= -1;
	return num;
}

WorldToScreen(camera_origin, camera_angles, position, fov_scale)
{
	width = 640;
	height = 480;
	fov_x = 80 * fov_scale;
	fov_y = 63 * fov_scale;	// 63 - i dont know how its computed

	left = anglestoright(camera_angles);
	up = anglestoup(camera_angles);
	forward = anglestoforward(camera_angles);

	Position = position - camera_origin;
        Transform[0] = VectorDot(Position, left);
        Transform[1] = VectorDot(Position, up);
        Transform[2] = VectorDot(Position, forward);

        // make sure it is in front of us
        if (Transform[2] < 0.1)
	{
		ret[0] = -1000;
	        ret[1] = -1000;
		return ret;
	}

        ret[0] = (width * 0.5) * (1 - (Transform[0] / tan(fov_x/2) / Transform[2]));
        ret[1] = (height * 0.5) * (1 - (Transform[1] / tan(fov_y/2) / Transform[2]));

	ret[0] = width - ret[0]; // flip x

	//iprintln(ret[0] + " " + ret[1]);

	return ret;
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
