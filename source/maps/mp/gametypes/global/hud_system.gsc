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

		fov = camera_player_real maps\mp\gametypes\global\player::getFOV();

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

	right = anglestoright(camera_angles);
	up = anglestoup(camera_angles);
	forward = anglestoforward(camera_angles);

	relativePos = vectornormalize(position - camera_origin);

        forwardDot = VectorDot(relativePos, forward);
        rightDot = VectorDot(relativePos, right);
        upDot = VectorDot(relativePos, up);

	// Avoid devision by 0
	if (forwardDot == 0) forwardDot = 0.001;

	// Calculate screen position
        x = (width / 2) * (1 + (rightDot / tan(fov_x/2) / forwardDot));
        y = (height / 2) * (1 - (upDot / tan(fov_y/2) / forwardDot));

	// Point is behind camera, move it offscreen
	if (forwardDot <= 0)
	{
		if (x < width / 2)	x = width * 2;
		else 			x = width * -1;
	}

	ret[0] = x;
	ret[1] = y;
	return ret;
}


WorldToScreen2(camera_origin, camera_angles, position, fov_scale)
{
	width = 640;
	height = 480;
	fov_x = 80 * fov_scale;
	fov_y = 63 * fov_scale;	// 63 - i dont know how its computed

	right = anglestoright(camera_angles);
	up = anglestoup(camera_angles);
	forward = anglestoforward(camera_angles);

	relativePos = position - camera_origin;
	relativePosNorm = vectornormalize(relativePos);

        forwardDot = VectorDot(relativePos, forward);
        rightDot = VectorDot(relativePos, right);
        upDot = VectorDot(relativePos, up);
/*
        // make sure it is in front of us
        if (forwardDot < 0.1)
	{
		ret[0] = -1000;
	        ret[1] = -1000;
		return ret;
	}
*/
    // Check if the point is behind the camera
    if (forwardDot <= 0) {

        farPoint = vectoradd(camera_origin, vectorscale(forward, 1000));

        relativePosNorm = vectornormalize(farPoint - camera_origin);

        forwardDot = VectorDot(forward, relativePosNorm);
        rightDot = VectorDot(right, relativePosNorm);
        upDot = VectorDot(up, relativePosNorm);
    }

	// Calculate screen position
        x = (width * 0.5) * (1 - (rightDot / tan(fov_x/2) / forwardDot));
        y = (height * 0.5) * (1 - (upDot / tan(fov_y/2) / forwardDot));

	x = width - x; // flip x

	// check if target point is outside viewable screen area
	if (x < 0.0 || x > 640.0 || y < 0.0 || y > 480.0)
	{
		    halfFOVH = fov_x / 2;
		    halfFOVV = fov_y / 2;
		    tanHalfFOVH = tan(halfFOVH);
		    tanHalfFOVV = tan(halfFOVV);
		    aspectRatio = width / height;

	        // Compute the edge of the screen that is closest to the 3D point
	        edgePoint = position;
	        edgeDist = distance(position, camera_origin);
	        edgeX = width / 2 + (rightDot / tanHalfFOVH) * height / aspectRatio / 2;
	        edgeY = height / 2 - (upDot / tanHalfFOVV) * height / 2;

	        // Check the left edge
	        leftX = 0;
	        leftY = height / 2 - (upDot / tanHalfFOVV) * height / 2;
	        leftPoint = vectoradd(camera_origin, vectorscale(forward, (leftX - width / 2) / (rightDot / tanHalfFOVH)));
	        leftDist = distance(leftPoint, position);
	        if (leftDist < edgeDist) {
	            edgePoint = leftPoint;
	            edgeDist = leftDist;
	            edgeX = leftX;
	            edgeY = leftY;
	        }

	        // Check the right edge
	        rightX = width;
	        rightY = height / 2 - (upDot / tanHalfFOVV) * height / 2;
	        rightPoint = vectoradd(camera_origin, vectorscale(forward, (rightX - width / 2) / (rightDot / tanHalfFOVH)));
		rightDist = distance(rightPoint, position);
		if (rightDist < edgeDist) {
			edgePoint = rightPoint;
			edgeDist = rightDist;
			edgeX = rightX;
			edgeY = rightY;
		}

		// Check the top edge
		topX = width / 2 + (rightDot / tanHalfFOVH) * height / aspectRatio / 2;
		topY = 0;
		topPoint = vectoradd(camera_origin, vectorscale(up, (topY - height / 2) / (upDot / tanHalfFOVV)));
		topDist = distance(topPoint, position);
		if (topDist < edgeDist) {
			edgePoint = topPoint;
			edgeDist = topDist;
			edgeX = topX;
			edgeY = topY;
		}

		// Check the bottom edge
		bottomX = width / 2 + (rightDot / tanHalfFOVH) * height / aspectRatio / 2;
		bottomY = height;
		bottomPoint = vectoradd(camera_origin, vectorscale(up, (bottomY - height / 2) / (upDot / tanHalfFOVV)));
		bottomDist = distance(bottomPoint, position);
		if (bottomDist < edgeDist) {
			edgePoint = bottomPoint;
			edgeDist = bottomDist;
			edgeX = bottomX;
			edgeY = bottomY;
		}


		// Compute the screen coordinates of the edge point
		edgeScreenX = edgeX;
		edgeScreenY = edgeY;
		if (edgeX < 0) {
			edgeScreenY = height / 2 - (upDot / tanHalfFOVV) * edgeX / (rightDot / tanHalfFOVH) / aspectRatio;
			edgeScreenX = 0;
		} else if (edgeX > width) {
			edgeScreenY = height / 2 + (upDot / tanHalfFOVV) * (edgeX - width) / (rightDot / tanHalfFOVH) / aspectRatio;
			edgeScreenX = width;
		}
		if (edgeY < 0) {
			edgeScreenX = width / 2 + (rightDot / tanHalfFOVH) * edgeY / (upDot / tanHalfFOVV);
			edgeScreenY = 0;
		} else if (edgeY > height) {
			edgeScreenX = width / 2 + (rightDot / tanHalfFOVH) * (edgeY - height) / (upDot / tanHalfFOVV);
			edgeScreenY = height;
		}

			ret[0] = edgeScreenX;
			ret[1] = edgeScreenY;
			return ret;
	}
/*
   // Check if the waypoint is outside the screen bounds
    if (x < 0) {
        x = 0;
    } else if (x > 640) {
        x = 640;
    }

    if (y < 0) {
        y = 0;
    } else if (y > 480) {
        y = 480;
    }
*/

	//aspectRatio = width / height;
/*
    // Check if the waypoint is outside the screen bounds and adjust it if necessary
    if (x < 0) {
        newX = 0;
        newZ = (newX - width / 2) * aspectRatio / height * tan(fov_x/2);
        newPoint = vectoradd(camera_origin, vectorscale(forward, newZ / forwardDot));
	return WorldToScreen(camera_origin, camera_angles, newPoint, fov_scale);
    } else if (x > width) {
        newX = width;
        newZ = (newX - width / 2) * aspectRatio / height * tan(fov_x/2);
        newPoint = vectoradd(camera_origin, vectorscale(forward, newZ / forwardDot));
        return WorldToScreen(camera_origin, camera_angles, newPoint, fov_scale);
    }

   if (y < 0) {
        newY = 0;
        newZ = -1 * (newY - height / 2) * tan(fov_y/2);
        newPoint = vectoradd(camera_origin, vectorscale(forward, newZ / forwardDot));
        return WorldToScreen(camera_origin, camera_angles, newPoint, fov_scale);
    } else if (y > height) {
        newY = height;
        newZ = -1 * (newY - height / 2) * tan(fov_y/2);
        newPoint = vectoradd(camera_origin, vectorscale(forward, newZ / forwardDot));
        return WorldToScreen(camera_origin, camera_angles, newPoint, fov_scale);
}*/


	ret[0] = x;
	ret[1] = y;
	return ret;
}

vectoradd(v1, v2)
{
	return v1 + v2;
}


vectorscale(v1, multiplier)
{
	return (v1[0] * multiplier, v1[1] * multiplier, v1[2] * multiplier);
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
