#include maps\mp\gametypes\global\_global;

Init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvarEx("C", "scr_prone_peek_fix", "BOOL", 0);				// level.scr_prone_peek_fix

	addEventListener("onConnected",     ::onConnected);
	addEventListener("onDisconnect",     ::onDisconnect);
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_prone_peek_fix":
			level.scr_prone_peek_fix = value;
			if (!isRegisterTime)
			{
				if (level.scr_prone_peek_fix) // changed to 1
				{
						players = getentarray("player", "classname");
						for(i = 0; i < players.size; i++)
						{
								player = players[i];
								player onConnected();
						}
				}
			}
			return true;
	}
	return false;
}

onConnected()
{
	if (!level.scr_prone_peek_fix)
		return;

	self thread pronePeekFix();
}

onDisconnect()
{
	if (isDefined(self.pronePeekTag))
		self.pronePeekTag delete();
}

// Is also called on every player if cvar is changed in middle of game
pronePeekFix()
{
	self endon("disconnect");

	wait level.frame;

	// Spawn help tag that will be used to disable moving and proning
	self.pronePeekTag = spawn("script_model", (999999, 999999, 999999));

	// Debug position of collision

	zoomLast = 0;
	inProne = false;
	framesInProne = 0;
	linked = false;
	time_in_crouch = 0;
	time_in_prone = 0;

	for (;;)
	{
		// Update every frame
		wait level.frame;

		// If player is not alive, or model is not set, or player is planting, wait more
		while (!isAlive(self) || !isDefined(self.pers["savedmodel"]) || (level.gametype == "sd" && self.bombinteraction))
			wait level.fps_multiplier * 1;

		// If prone peek fix was disabled via cvar
		if (!level.scr_prone_peek_fix)
		{
			self.pronePeekTag delete();
			self.pronePeekTag = undefined;
			return;
		}

		// Count stance height (length between plyer origin and head)
		head = self.headTag getOrigin();
		origin = self getOrigin();
		stanceHeight = distance((0, 0, head[2]), (0, 0, origin[2]));
		zoom = self playerAds();
		zoomDirection = (zoom - zoomLast); // >1 = zooming | 0=no change | <1 unzooming
		zoomLast = zoom;
		/*
		Prone = 	~8 center 	| ~3 down 	| ~10 up
		Crouch = 	~36 center 	| ~26 down 	| ~32 up 	| 43 moving forward
		Stand = 	~58 center 	| ~52 down 	| ~51 up 	| 53 moving
		*/

		// If we are proning
		if (!inProne && stanceHeight < 20)
		{
				time_in_prone += level.frame;

				// If we are in prone for some time (to avoid state when head is in weird position - for example climbing)
				if (time_in_prone > 0.3)
						inProne = true;
		}


		// We was in prone position and now we stand up to crouch
		if (inProne && stanceHeight >= 20)
		{
				inProne = false;


				wallInProne = false;
				wallInCrouch = false;

				eye = self.origin + (0, 0, 10);
				angles = self getPlayerAngles();
				angles = (0, angles[1], angles[2]); // looking in middle
				forward = anglestoforward(angles);
				forwardTrace = Bullettrace(eye, eye + (forward[0]*100000, forward[1]*100000, forward[2]*100000),true,self);
				if(forwardTrace["fraction"] < 1)
				{
					distance = distance(self.origin, forwardTrace["position"]);
					if (distance < 300)
						wallInProne = true;

					if (level.debug_pronepeek)
					{
						if (!isDefined(self.pronepeek_waypoint1))
							self.pronepeek_waypoint1 = newClientHudElem2(self);
						self.pronepeek_waypoint1.x = forwardTrace["position"][0];
						self.pronepeek_waypoint1.y = forwardTrace["position"][1];
						self.pronepeek_waypoint1.z = forwardTrace["position"][2];
						self.pronepeek_waypoint1 setShader("objpoint_default", 2, 2);
						self.pronepeek_waypoint1 setwaypoint(true);
					}
				}

				if (wallInProne)
				{
					eye = self.origin + (0, 0, 40);
					forwardTrace = Bullettrace(eye, eye + (forward[0]*100000, forward[1]*100000, forward[2]*100000),true,self);
					if(forwardTrace["fraction"] < 1)
					{
						distance = distance(self.origin, forwardTrace["position"]);
						if (distance < 300)
							wallInCrouch = true;

						if (level.debug_pronepeek)
						{
							if (!isDefined(self.pronepeek_waypoint2))
								self.pronepeek_waypoint2 = newClientHudElem2(self);
							self.pronepeek_waypoint2.x = forwardTrace["position"][0];
							self.pronepeek_waypoint2.y = forwardTrace["position"][1];
							self.pronepeek_waypoint2.z = forwardTrace["position"][2];
							self.pronepeek_waypoint2 setShader("objpoint_default", 2, 2);
							self.pronepeek_waypoint2 setwaypoint(true);
						}
					}
				}

				isClipableWall = (wallInProne && !wallInCrouch) && (zoomDirection > 0 || zoom >= 0.5);

				//self iprintln(wallInProne+" "+wallInCrouch+" "+isClipableWall);


				if (isClipableWall) {
					if (level.debug_pronepeek) self iprintln("Prone-peek: ^5Looking to clip-able wall");
				} else {
					if (level.debug_pronepeek) self iprintln("Prone-peek: ^6NOT Looking to clip-able wall");
				}


				if (isClipableWall)
				{
					// Link player to actual position (then player is linked, proning is not allowed - we temporally disable proning again by this)
					linked = true;
					self linkto(self.pronePeekTag);

					if (level.debug_pronepeek) self iprintln("^1Preventing prone peek");

					// Reset timer
					time_in_crouch = 0;
				}
		}

		if (linked)
		{
			// Unlink if time expired, player is standing or player is proning again or is not zoomed
			if (time_in_crouch > 0.4 || stanceHeight >= 45 || stanceHeight < 20 || (zoom < 0.4 && zoomDirection < 0))
			{
				// Unlink
				linked = false;
				self unlink();
				//self iprintln("Unlink");
			}
			else
			{	// Wait enouht time before allowing prone again
				time_in_crouch += level.frame;
			}
		}



	}
}
