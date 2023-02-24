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
	self.isWaling = false;
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
			self iprintln("^1Stopped moving");*/
		  self.isMoving = false;
		}


		if (self.movingDifference > 10.0)
		{/*
		  if (!self.isWaling)
			self iprintln("Walking");*/
		  self.isWaling = true;
		}
		else
		{/*
		  if (self.isWaling)
			self iprintln("^1Stopped walking");*/
		  self.isWaling = false;
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
	self.pelvisTag = spawn("script_origin",(0,0,0));
	//self.pelvisTag thread maps\mp\gametypes\global\developer::showWaypoint();

	dead = true;
	for (;;)
	{
		wait level.frame;

		// If player is not alive, or model is not set, wait
		if (self.sessionstate != "playing" || !isDefined(self.pers["savedmodel"]))
		{
			dead = true;
			continue;
		}

		// We can call linkto() after 1 frame or it will cause runtime error "failed to link entity since parent model 'xmodel/playerbody_german_africa01' is invalid"
		if (dead)
		{
			dead = false;
			continue;
		}

		// Link tags
		self.headTag unlink();
		self.headTag linkto (self, "J_Head",(0,0,0),(0,0,0));

		self.pelvisTag unlink();
		self.pelvisTag linkto (self, "pelvis",(0,0,0),(0,0,0));
	}
}

DeleteTags()
{
	if (isDefined(self.headTag))
		self.headTag delete();
	if (isDefined(self.pelvisTag))
		self.pelvisTag delete();
}








getEyeOrigin()
{
	origin = self getOrigin();

	if (self.sessionteam == "spectator")
	{
		return origin + (0, 0, 8);
	}

	angles = self getPlayerAngles();
	head = self.headTag getOrigin();

	// Vector of head
	diff = head - origin;

	// Rotate vector back to angle 0
	angle = -1 * angles[1];
	x = diff[0] * cos(angle) - diff[1] * sin(angle);
	y = diff[1] * cos(angle) + diff[0] * sin(angle);
	//iprintln(x + ", " + y);

	lean = 0;
	stance = self getStance();

	// Prone
	if (stance == "prone")
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
	else if (stance == "crouch")
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


getStance()
{
	origin = self getOrigin();
	head = self.headTag getOrigin();

	// Distance between head and origin
	stanceHeight = distance((0, 0, head[2]), (0, 0, origin[2]));

	// Determine stance position and lean left / right
	/*
	Prone = 	~8 center 	| ~3 down 	| ~10 up
	Crouch = 	~36 center 	| ~26 down 	| ~32 up 	| 43 moving forward
	Stand = 	~58 center 	| ~52 down 	| ~51 up 	| 53 moving
	*/

	// Prone
	if (stanceHeight < 20)
		return "prone";
	// Crouch
	else if (stanceHeight < 45)
		return "crouch";
	// Stand
	else
		return "stand";
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


/*
self is player as 1st point of view
player is player that is checked if is visible in self's point of view
*/
isPlayerInSight(player)
{
	eye = self getEyeOrigin();

	trace = Bullettrace(eye, player.headTag getOrigin(), true, self);
	headVisible = isDefined(trace["entity"]) && trace["entity"] == player;
	if (headVisible)
		return true;

	trace = Bullettrace(eye, player.pelvisTag getOrigin(), true, self);
	pelvisVisible = isDefined(trace["entity"]) && trace["entity"] == player;
	if (pelvisVisible)
		return true;

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
	if (id <= -1)
		return undefined;

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



/*
Error produced when invalid name of tag is used via function link():

Models:
0: 'playerbody_british_africa03'
79: 'head_british_macgregor'
107: 'helmet_british_afrca'

Bones:
Bone 0: 'tag_origin'
Bone 1: 'j_mainroot'
Bone 2: 'pelvis'
Bone 3: 'j_hip_le'
Bone 4: 'j_hip_ri'
Bone 5: 'torso_stabilizer'
Bone 6: 'j_spine1'
Bone 7: 'back_low'
Bone 8: 'j_back_equip_le'
Bone 9: 'j_back_equip_ri'
Bone 10: 'j_hiptwist_le'
Bone 11: 'j_hiptwist_ri'
Bone 12: 'j_knee_le'
Bone 13: 'j_knee_ri'
Bone 14: 'j_leftspade'
Bone 15: 'j_shorts_le'
Bone 16: 'j_shorts_lift_le'
Bone 17: 'j_shorts_lift_ri'
Bone 18: 'j_shorts_ri'
Bone 19: 'j_spade'
Bone 20: 'j_spine2'
Bone 21: 'back_mid'
Bone 22: 'j_ankle_le'
Bone 23: 'j_ankle_ri'
Bone 24: 'j_spine3'
Bone 25: 'back_up'
Bone 26: 'j_ball_le'
Bone 27: 'j_ball_ri'
Bone 28: 'j_spine4'
Bone 29: 'j_clavicle_le'
Bone 30: 'j_clavicle_ri'
Bone 31: 'j_neck'
Bone 32: 'neck'
Bone 33: 'j_head'
Bone 34: 'head'
Bone 35: 'j_shoulder_le'
Bone 36: 'j_shoulder_ri'
Bone 37: 'j_elbow_bulge_le'
Bone 38: 'j_elbow_bulge_ri'
Bone 39: 'j_elbow_le'
Bone 40: 'j_elbow_ri'
Bone 41: 'j_shouldertwist_le'
Bone 42: 'j_shouldertwist_ri'
Bone 43: 'j_wrist_le'
Bone 44: 'j_wrist_ri'
Bone 45: 'j_wristtwist_le'
Bone 46: 'j_wristtwist_ri'
Bone 47: 'j_index_le_1'
Bone 48: 'j_index_ri_1'
Bone 49: 'j_mid_le_1'
Bone 50: 'j_mid_ri_1'
Bone 51: 'j_pinky_le_1'
Bone 52: 'j_pinky_ri_1'
Bone 53: 'j_ring_le_1'
Bone 54: 'j_ring_ri_1'
Bone 55: 'j_thumb_le_1'
Bone 56: 'j_thumb_ri_1'
Bone 57: 'tag_weapon_left'
Bone 58: 'tag_weapon_right'
Bone 59: 'j_index_le_2'
Bone 60: 'j_index_ri_2'
Bone 61: 'j_mid_le_2'
Bone 62: 'j_mid_ri_2'
Bone 63: 'j_pinky_le_2'
Bone 64: 'j_pinky_ri_2'
Bone 65: 'j_ring_le_2'
Bone 66: 'j_ring_ri_2'
Bone 67: 'j_thumb_le_2'
Bone 68: 'j_thumb_ri_2'
Bone 69: 'j_index_le_3'
Bone 70: 'j_index_ri_3'
Bone 71: 'j_mid_le_3'
Bone 72: 'j_mid_ri_3'
Bone 73: 'j_pinky_le_3'
Bone 74: 'j_pinky_ri_3'
Bone 75: 'j_ring_le_3'
Bone 76: 'j_ring_ri_3'
Bone 77: 'j_thumb_le_3'
Bone 78: 'j_thumb_ri_3'
Bone 79: 'j_spine2'
Bone 80: 'j_spine3'
Bone 81: 'j_spine4'
Bone 82: 'j_neck'
Bone 83: 'j_head'
Bone 84: 'j_brow_le'
Bone 85: 'j_brow_ri'
Bone 86: 'j_cheek_le'
Bone 87: 'j_cheek_ri'
Bone 88: 'j_eye_lid_bot_le'
Bone 89: 'j_eye_lid_bot_ri'
Bone 90: 'j_eye_lid_top_le'
Bone 91: 'j_eye_lid_top_ri'
Bone 92: 'j_eyeball_le'
Bone 93: 'j_eyeball_ri'
Bone 94: 'j_head_end'
Bone 95: 'j_jaw'
Bone 96: 'j_levator_le'
Bone 97: 'j_levator_ri'
Bone 98: 'j_lip_top_le'
Bone 99: 'j_lip_top_ri'
Bone 100: 'j_mouth_le'
Bone 101: 'j_mouth_ri'
Bone 102: 'tag_eye'
Bone 103: 'j_chin_skinroll'
Bone 104: 'j_helmet'
Bone 105: 'j_lip_bot_le'
Bone 106: 'j_lip_bot_ri'
Bone 107: 'j_helmet'

Part duplicates:
79 ('j_spine2') -> 20 ('j_spine2')
80 ('j_spine3') -> 24 ('j_spine3')
81 ('j_spine4') -> 28 ('j_spine4')
82 ('j_neck') -> 31 ('j_neck')
83 ('j_head') -> 33 ('j_head')
107 ('j_helmet') -> 104 ('j_helmet')
*/
