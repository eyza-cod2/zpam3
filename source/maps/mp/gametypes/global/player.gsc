// Called on player connected, but before all events are called
// Defined new properties here
BeforeOnConnected()
{
	self thread IsMoving();

	self thread AddTags();
}

// Called when player disconnect, after all disconnect evets were called
AfterOnDisconnect()
{
	self thread DeleteTags();
}



// Is also called on every player if cvar is changed in middle of game
IsMoving()
{
	self endon("disconnect");

	self.isMoving = false;
	self.movingDifference = 0;

	origin = self getOrigin();
	origin_old = origin;

	for (;;)
	{
		wait level.fps_multiplier * .1;

		origin = self getOrigin();

		self.movingDifference = distance(origin, origin_old);
		if (self.movingDifference > 5.0)
		{/*
		  if (!self.isMoving)
			self iprintln("Moving");*/
		  self.isMoving = true;
		}
		else
		{/*
		  if (self.isMoving)
			self iprintln("^1Stopped");*/
		  self.isMoving = false;
		}

		origin_old = origin;
	}
}





AddTags()
{
	self endon("disconnect");

	// Spawn help tag that will be linked to head
	self.headTag = spawn("script_origin",(0,0,0));
	//self.headTag thread maps\mp\gametypes\global\developer::showWaypoint();

	wait level.frame;

	for (;;)
	{
		// If player is not alive, or model is not set, wait
		while (!isAlive(self) || !isDefined(self.pers["savedmodel"]))
			wait level.frame;
		wait level.frame;

		// Link tag to head
		/#
		println(self.name + " " + self.model); // crash on xmodel/playerbody_german_africa01 | xmodel/playerbody_american_normandy09
		#/
		self.headTag unlink();
		self.headTag linkto (self, "J_Head",(0,0,0),(0,0,0));

		// ^ Crash error:  failed to link entity since parent model 'xmodel/playerbody_american_normandy09' is invalid

		// Wait untill is alive
		while (isAlive(self))
			wait level.fps_multiplier * 1;
	}
}

DeleteTags()
{
	if (isDefined(self.headTag))
		self.headTag delete();
}








getEyeOrigin()
{
	origin = self getOrigin();
	head = self.headTag getOrigin();
	angles = self getPlayerAngles();

	// Vector of head
	diff = head - origin;

	// Rotate vector back to angle 0
	angle = -1 * angles[1];
	x = diff[0] * cos(angle) - diff[1] * sin(angle);
	y = diff[1] * cos(angle) + diff[0] * sin(angle);
	//iprintln(x + ", " + y);

	// Distance between head and origin
	stanceHeight = distance((0, 0, head[2]), (0, 0, origin[2]));

	// Determine stance position and lean left / right
	/*
	Prone = 	~8 center 	| ~3 down 	| ~10 up
	Crouch = 	~36 center 	| ~26 down 	| ~32 up 	| 43 moving forward
	Stand = 	~58 center 	| ~52 down 	| ~51 up 	| 53 moving
	*/
	lean = 0;

	// Prone
	if (stanceHeight < 20)
	{
		offset = 11;

		/*
		Prone 			= (1, 3)		| +x
		Prone lean left 	= (0.7, 10.5)		|
		Prone lean right	= (0, -3)	+y______|
		*/
		if (y > 7)
			lean = -1; // lean left
		else if (y < 0)
			lean = 1; // lean right
	}
	// Crouch
	else if (stanceHeight < 45)
	{
		offset = 40;

		/*
		Crouch 			= (0, -4.5)		| +x
		Crouch lean left 	= (0, 14)		|
		Crouch lean right	= (-5, -14)	+y______|
		*/
		if (y > 10)
			lean = -1; // lean left
		else if (y < -10)
			lean = 1; // lean right
	}
	// Stand
	else
	{
		offset = 60;

		/*
		Stand 			= (-5, 0)		| +x
		Stand lean left 	= (-5, 14.5)		|
		Stand lean right	= (-5, -12)	+y______|
		*/
		if (y > 10)
			lean = -1; // lean left
		else if (y < -8)
			lean = 1; // lean right
	}

	//iprintln("stance: " + offset + " | lean: " + lean);


	eye = origin + (0, 0, offset);

	// Add offset if we are lean left / right
	if (lean != 0)
	{
		aright = anglestoright(angles);
		eye = eye + (14 * aright[0] * lean, 14 * aright[1] * lean, -3);
	}

	return eye;
}



isPlayerLookingAt(entity)
{
	eye = self getEyeOrigin();
	angles = self getPlayerAngles();
	forward = anglestoforward(angles);
	forwardTrace = Bullettrace(eye, eye + (forward[0]*100000, forward[1]*100000, forward[2]*100000),true,self);

	if (isDefined(forwardTrace["entity"]) && forwardTrace["entity"] == entity)
	{
		return true;
	}

	return false;
}

getLookingAtPosition()
{
	eye = self getEyeOrigin();
	angles = self getPlayerAngles();
	forward = anglestoforward(angles);
	forwardTrace = Bullettrace(eye, eye + (forward[0]*100000, forward[1]*100000, forward[2]*100000),true,self);

	if(forwardTrace["fraction"] < 1)
	{
		return forwardTrace["position"];
	}
	return undefined;
}


GetEntityByClientId(id)
{
	if (id == -1)
		return;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		playerId = player getEntityNumber();

		if (playerId == id)
			return player;
	}
	return undefined;
}
