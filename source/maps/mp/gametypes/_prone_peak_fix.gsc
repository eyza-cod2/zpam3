#include maps\mp\gametypes\_callbacksetup;

Init()
{
	addEventListener("onConnected",     ::onConnected);
	addEventListener("onDisconnect",     ::onDisconnect);
}

onConnected()
{
	if (!level.scr_prone_peak_fix)
		return;

	self thread pronePeakFix();
}

onDisconnect()
{
	if (isDefined(self.pronePeakTag))
		self.pronePeakTag delete();
}

// Called if cvar scr_prone_peak_fix changes
cvarChanged()
{
		if (level.scr_prone_peak_fix) // changed to 1
		{
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
						player = players[i];
						player onConnected();
				}
		}
}

// Is also called on every player if cvar is changed in middle of game
pronePeakFix()
{
	self endon("disconnect");

	wait level.frame;

	// Spawn collision cylinder, that will block player from proning
	self.pronePeakTag = spawn("script_model", (999999, 999999, 999999));

	// Debug position of collision

	zoomLast = 0;
	inProne = false;
	linked = false;
	time_in_crouch = 0;
	time_in_prone = 0;
	ignoreMovingTimer = 0;

	for (;;)
	{
		// Update every frame
		wait level.frame;

		// If player is not alive, or model is not set, or player is planting, wait more
		while (!isAlive(self) || !isDefined(self.pers["savedmodel"]) || (level.gametype == "sd" && self.bombinteraction))
			wait level.fps_multiplier * 1;

		// To attach tag to head correctly, player's model must be set
		if (!isDefined(self.tag_head))
		{
			// Attach tag to head to get head position (used to determine player stance)
			self.tag_head = spawn("script_origin",(0,0,0));
			wait level.frame;
			self.tag_head linkto (self, "J_Head",(0,0,0),(0,0,0));
			//self.tag_head thread maps\mp\gametypes\__developer::showWaypoint();
		}


		// If prone peak fix was disabled via cvar
		if (!level.scr_prone_peak_fix)
		{
			self.tag_head delete();
			self.pronePeakTag delete();

			self.tag_head = undefined;
			self.pronePeakTag = undefined;
			return;
		}

		// Count stance height (length between plyer origin and head)
		head = self.tag_head getOrigin();
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

		// Decrease timer
		if (ignoreMovingTimer > 0)
			ignoreMovingTimer -= level.frame;


		// We was in prone position and now we stand up to crouch
		if (inProne && stanceHeight >= 20)
		{
				inProne = false;

				// Do only if player is zooming
				if (zoomDirection > 0 || zoom >= 1.0)
				{
					// Ignore moving only once in shot periot of time
					// for once you can do prone peak with moving, but second time it will be prevenented (until 5 sec delay expire)
					ignoreMoving = ignoreMovingTimer > 0;
					ignoreMovingTimer = 5.0;
					notMoving = self.movingDifference < 0.1; // 3=forward in prone 12=crouch

					if (notMoving || ignoreMoving)
					{
						// Link player to actual position (then player is linked, proning is not allowed - we temporally disable proning again by this)
						linked = true;
						self linkto(self.pronePeakTag);

						//if (issubstr(self.name, "eyza"))
							self iprintln("^1Preventing prone peak");

						// Reset timer
						time_in_crouch = 0;
					}
					else
					{
						//if (issubstr(self.name, "eyza"))
							self iprintln("^3Next prone peak will be prevented!");
					}
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
