#include maps\mp\gametypes\global\_global;

/*
Map may contain targets that players can use to practise their aim
Names of entities:
	Targets (array of targets):
	- "trainer_target" - image of target
	- "trainer_trigger" - trigger_damage

	Activators (2 per map - for allies and axis):
	- "trainer_ground" - image of target activator
	- "trainer_ground_trigger" - trigger_damage
*/

Init()
{
	addEventListener("onConnected",     ::onConnected);
        addEventListener("onDisconnect",    ::onDisconnect);
	addEventListener("onSpawned",    ::onSpawned);

	level.aimTargets = [];

	// Load targets and activators
	targets = 		getentarray("trainer_target", "targetname");
	targets_damage = 	getentarray("trainer_trigger", "targetname");
	activators = 		getent("trainer_activator", "targetname");
	activators_damage = 	getentarray("trainer_activator_damage", "targetname");
	activators_hint = 	getentarray("trainer_activator_hint", "targetname");
/*
	println("## trainer_target = " + targets.size);
	println("## trainer_trigger = " + targets_damage.size);
	println("## trainer_activator = " + isDefined(activators));
	println("## trainer_activator_damage = " + activators_damage.size);
	println("## trainer_activator_hint = " + activators_hint.size);
*/
	if (targets.size == 0 || !isDefined(activators))
		return;
	if (targets.size != targets_damage.size)
		return;


	// Not allowed -> delete
	if (!level.in_readyup)
	{
		for (i = 0; i < targets.size; i++)
		{
			targets[i] delete();
			targets_damage[i] delete();
		}
		for (i = 0; i < activators.size; i++)
		{
			activators_damage[i] delete();
			activators_hint[i] delete();
		}
		activators delete();
		return;
	}



	level._effect["aimTargetExplosion"] = loadfx("fx/impacts/large_metalhit.efx");



	for (i = 0; i < targets.size; i++)
	{
		targets_damage[i] enablelinkto();
		targets_damage[i] linkTo(targets[i]);
		targets_damage[i].parent = targets[i];

		targets[i] notsolid();
		targets[i].trigger_damage = targets_damage[i];
		targets[i].origin_original = targets[i].origin;
		//targets[i].trigger_damage thread debugDamage("["+i+"]");
		//targets[i] thread maps\mp\gametypes\global\developer::showWaypoint();
	}


	for (i = 0; i < activators_damage.size; i++)
	{
		//activators[i] notsolid();
		activators_damage[i] thread handleActivation();
	}


	level.aimTargets = targets;

	println("## level.aimTargets = " + level.aimTargets.size); // TODO
}

onConnected()
{
	self.aimTrainerMode = 0;
	self.aimTrainer_outOfAmmo = false;
	self.aimTrainer_startAngles = (0, 0, 0);
}


onDisconnect()
{
	self turnOff();
}

onSpawned()
{
	self turnOff();
}



reserveTargetBy(player)
{
	for (i = 0; i < level.aimTargets.size; i++)
	{
		target = level.aimTargets[i];

		if (!isDefined(target.reservedBy))
		{
			target.reservedBy = player;

			//player iprintln("reserving index " + i);

			return target;
		}
	}
	return undefined;
}

releaseTarget()
{
	target = self;

	target hide();
	target.reservedBy = undefined;
	target.origin = target.origin_original;

	target notify("aim_trainer_target_released");
}

rotateTowards(player)
{
	target = self;

	target endon("aim_trainer_target_released");

	for (;;)
	{
		if (!isDefined(target) || !isDefined(player))
			return;

		angles = vectortoangles(player.origin - target.origin);

		target.angles = (0, angles[1] + 180, 0);

		wait level.frame;
		waittillframeend;
	}
}



debugDamage(name)
{
	for(;;)
	{
		self waittill("damage", dmg, player);

		iprintln("Damage " + dmg + " to " + name + " by " + player.name);
	}
}

handleDamageForPlayer(player)
{
	target = self;

	target endon("aim_trainer_target_released");

	for(;;)
	{
		target.trigger_damage waittill("damage", dmg, attacker);

		// Ignore damages for other players
		if (attacker != player)
			continue;

		player thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback(undefined, 1);

		player thread generateMeNewTargetPosition("kill");
	}
}

handleActivation()
{
	activator_damage = self;

	for(;;)
	{
		activator_damage waittill("damage", dmg, player);

		player thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback(undefined, 1);

		//player toggle();

		player iprintlnbold("Aim trainer");
		player iprintlnbold("Hold ^3[{+melee_breath}] ^7to enable / switch modes.");
		player iprintlnbold("Double press ^3[{+melee_breath}] ^7to disable.");
		player iprintlnbold(" ");
		player iprintlnbold(" ");
	}
}


setKillTimeout(seconds, player)
{
	target = self;

	target endon("aim_trainer_target_released");
	target notify("aim_trainer_kill_timeout");
	target endon("aim_trainer_kill_timeout");

	wait level.fps_multiplier * seconds;

	player iprintln("^1Time to kill elapsed!");

	player thread generateMeNewTargetPosition("missed");
}





getTargetPos(randomize)
{
	eye = self maps\mp\gametypes\global\player::getEyeOrigin();
	angles = self getPlayerAngles();
	fov = self getFOV() / 80;



	// Make sure the target is always visible on screen
	angles_new = angles;
	if (randomize)
	{
		angleDiff = angles[1] - self.aimTrainer_startAngles[1];
		if (angleDiff > 180)		angleDiff -= 360;
		else if (angleDiff < -180)	angleDiff += 360;

		// Player is not looking to startAngles direction, save new
		if (angleDiff < -45 || angleDiff > 45)
			self.aimTrainer_startAngles = angles;

		// left +, right -, max 40
		left_right = randomint(40) - 20; // -20 <-> 19
		left_right *= fov;
		left_right += self.aimTrainer_startAngles[1];

		// up -, down +
		up_down = randomint(14) - 8; // -8 <-> 5
		up_down *= fov;

		// In center put target always above weapon target
		if (up_down > angles[0] && self playerAds() > 0 && !maps\mp\gametypes\_weapons::isSniper(self getcurrentweapon()))
		{
			left_right_diff = (angles[1] - left_right);
			if (left_right_diff > -10 && left_right_diff <= 0)
			{
				left_right += 10;
				//iprintln("adjusted target more to the left");

			}
			else if (left_right_diff < 10 && left_right_diff > 0)
			{
				left_right -= 10;
				//iprintln("adjusted target more to the right");
			}
		}


		angles_new = (up_down, left_right, 0);
	}

	distance = 200 + (800 - (800 * fov));

	forward = anglesToForward(angles_new);
	forwardMultiplier = distance;

	forwardOrigin = eye + (forward[0] * forwardMultiplier, forward[1] * forwardMultiplier, forward[2] * forwardMultiplier);


	forwardTrace = Bullettrace(eye, forwardOrigin, false, self); // BulletTrace( <start>, <end>, <hit characters>, <ignore entity> )
	forwardTracedOrigin = forwardTrace["position"];


	vector = (forwardTracedOrigin - eye);

	vectorNorm = VectorNormalize(vector);
	vectorLen = length(vector);

	multiplier = vectorLen * 0.8;

	newPos = eye + (vectorNorm[0] * multiplier, vectorNorm[1] * multiplier, vectorNorm[2] * multiplier);

	return newPos;
}

moving(speed)
{
	target = self;

	target endon("aim_trainer_target_released");
	target endon("aim_trainer_target_updated");

	// Wait till properly rotated and spawned
	waittillframeend;

	// Generate moving direction
	right = anglesToRight(target.angles);
	distance = 100; // to both sides

	origin_original = target.origin;
	origin_right = target.origin + (right[0] * distance, right[1] * distance, right[2] * distance);
	origin_left = target.origin + (right[0] * distance * -1, right[1] * distance * -1, right[2] * distance * -1);

	rightTrace = Bullettrace(origin_original, origin_right, false, target); // BulletTrace( <start>, <end>, <hit characters>, <ignore entity> )
	leftTrace = Bullettrace(origin_original, origin_left, false, target); // BulletTrace( <start>, <end>, <hit characters>, <ignore entity> )

	new_distance_right = distance(origin_original, rightTrace["position"]) * 0.8;
	new_distance_left = distance(origin_original, leftTrace["position"]) * 0.8;

	origin[0] = origin_original + (right[0] * new_distance_right, right[1] * new_distance_right, right[2] * new_distance_right);
	origin[1] = origin_original + (right[0] * new_distance_left * -1, right[1] * new_distance_left * -1, right[2] * new_distance_left * -1);

	total_distance = distance(origin[0], origin[1]);

	speed = speed * (total_distance / (distance*2));
	time[0] = speed * (new_distance_right / (distance*2));
	time[1] = speed * (new_distance_left / (distance*2));






	index_1 = 0;
	index_2 = 1;
	rand = randomint(2); // 0 - 1
	if (rand)
	{
		index_1 = 1;
		index_2 = 0;
	}

/*
	if (!isDefined(target.waypoint1))
	{
		target.waypoint1 = spawnstruct();
		target.waypoint1.origin = origin[index_1];
		target.waypoint1 thread maps\mp\gametypes\global\developer::showWaypoint(undefined, 1);
	}
	if (!isDefined(target.waypoint2))
	{
		target.waypoint2 = spawnstruct();
		target.waypoint2.origin = origin[index_2];
		target.waypoint2 thread maps\mp\gametypes\global\developer::showWaypoint(undefined, 1);
	}
	target.waypoint1.origin = origin[index_1];
	target.waypoint2.origin = origin[index_2];
*/
/*
	iprintln("speed: ("+speed+")");
	iprintln("right: ("+time[0]+")");
	iprintln("left: ("+time[1]+")");
*/
	firstMove = true;
	for(;;)
	{
		accel = 0.1;
		time1 = speed;
		time2 = speed;
		accel1 = time1*accel;
		if (firstMove)
		{
			time1 = time[index_1]; // first move is faster with no accell
			accel1 = 0;
			firstMove = false;
		}

		target moveto(origin[index_1], time1, accel1, time1*accel); // moveto( <point>, <time>, <acceleration time>, <deceleration time> )

		target waittill("movedone");

		target moveto(origin[index_2], time2, time2*accel, time2*accel); // moveto( <point>, <time>, <acceleration time>, <deceleration time> )

		target waittill("movedone");
	}
}






toggle()
{
	if (level.aimTargets.size == 0)
	{
		self iprintln("^1This map does not support aim trainer targets!");
		return;
	}


	wasDisabled = self.aimTrainerMode == 0;

	for (i = 0; i < 2; i++)
		self iprintlnbold(" ");

	if (self.aimTrainerMode == 0)
	{
		self.aimTrainerMode = 1;

		self thread player_loop();

		// No avaible targets
		if (self.aimTrainerMode == 0)
			return;

		self iprintln("Aim Trainer ^2Enabled");
		self iprintlnbold("Aim Trainer ^2Enabled");
	}


	if (wasDisabled || self.aimTrainerMode == 4)
	{
		self.aimTrainerMode = 1;
		self iprintlnbold("Mode 1: Static targets");
	}
	else if (self.aimTrainerMode == 1)
	{
		self.aimTrainerMode = 2;
		self iprintlnbold("Mode 2: Moving targets");
	}
	else if (self.aimTrainerMode == 2)
	{
		self.aimTrainerMode = 3;
		self iprintlnbold("Mode 3: Moving targets fast");
	}
	else if (self.aimTrainerMode == 3)
	{
		self.aimTrainerMode = 4;
		self iprintlnbold("Mode 4: Reaction time");
	}

	self thread generateMeNewTargetPosition("mode");

	for (i = 0; i < 2; i++)
		self iprintlnbold(" ");
}

turnOff()
{
	if (isDefined(self.aimTrainerMode) && self.aimTrainerMode)
	{
		self notify("aim_trainer_turnedOff");

		self.aimTarget1 releaseTarget();

		self iprintln("Aim Trainer ^1Disabled");
		self iprintlnbold("Aim Trainer ^1Disabled");

		self.aimTrainerMode = 0;
	}
}


player_loop()
{
	self endon("disconnect");
	self endon("aim_trainer_turnedOff");

	self.aimTarget1 = reserveTargetBy(self);

	// No avaible targets
	if (!isDefined(self.aimTarget1))
	{
		self iprintln("^1No avaible targets!");
		self iprintlnbold("^1No avaible targets!");
		self.aimTrainerMode = 0;
		return;
	}

	self.aimTarget1.generateTime = undefined;
	self.aimTarget1.kills = 0;

	self.aimTarget1 thread rotateTowards(self);
	self.aimTarget1 thread handleDamageForPlayer(self);
	//self.aimTarget1 thread maps\mp\gametypes\global\developer::showWaypoint(self, 4);
	//self.aimTarget1.trigger_damage thread maps\mp\gametypes\global\developer::showWaypoint(self, 3);


	self.aimTrainer_outOfAmmo = false;
	self.aimTrainer_startAngles = self.angles;
	last_current = "none";
	last_ammo = 0;
	last_kills = 0;
	last_mode = self.aimTrainerMode;
	while(1)
	{
		wait level.frame;

		if (!isAlive(self))
		{
			self.aimTrainer_outOfAmmo = false;
			continue;
		}

		weapon1 = self getweaponslotweapon("primary");
		weapon2 = self getweaponslotweapon("primaryb");

		weapon1_clipAmmo = self getweaponslotclipammo("primary");
		weapon2_clipAmmo = self getweaponslotclipammo("primaryb");

		current = self getcurrentweapon();

		// For example player is on ladder
		if(current == "none")
			continue;

		current_ammo = -1;
		if(current == weapon1) current_ammo = weapon1_clipAmmo;
		if(current == weapon2) current_ammo = weapon2_clipAmmo;

		//self iprintln("ammo: " + current_ammo);

		// Out of ammo, wait for reloading
		if(current_ammo == 0)
		{
			//self iprintln("out of ammo");
			self.aimTrainer_outOfAmmo = true;
		}

		// Ammo restored
		if (self.aimTrainer_outOfAmmo && current_ammo > 0)
		{
			wait level.fps_multiplier * 1.5;

			self.aimTrainer_outOfAmmo = false;

			self.aimTrainer_startAngles = self.angles;

			//self iprintln("ammo restored");
		}

		// Weapon reloaded, give max ammo to slot
		if (last_current == current && current_ammo > last_ammo && last_ammo >= 0)
		{
			self giveMaxAmmo(current);

			self.aimTrainer_startAngles = self.angles;
		}

		if (last_current == current && current_ammo < last_ammo && current_ammo >= 0)
		{
			//self iprintln("fired");

			// This bullet was not into target
			if (self.aimTarget1.kills == last_kills && self.aimTrainerMode == last_mode)
			{
				//self iprintln("missed shot");

				self thread generateMeNewTargetPosition("missed");
			}


		}

		last_current = current;
		last_ammo = current_ammo;
		last_kills = self.aimTarget1.kills;
		last_mode = self.aimTrainerMode;
	}
}

generateMeNewTargetPosition(reason)
{
	self endon("disconnect");
	self endon("aim_trainer_turnedOff");

	if (!isDefined(self.aimTarget1))
		return;

	// Lock thread
	self.aimTarget1 notify("aim_trainer_target_updated");
	self.aimTarget1 endon("aim_trainer_target_updated");

	// Mode
	weapons["m1carbine_mp"] = 		2;
	weapons["m1garand_mp"] = 		2;
	weapons["thompson_mp"] = 		2;
	weapons["bar_mp"] = 			2;
	weapons["springfield_mp"] = 		  1;
	weapons["greasegun_mp"] = 		2;
	weapons["shotgun_mp"] = 		  1;
	weapons["enfield_mp"] = 		  1;
	weapons["sten_mp"] = 			2;
	weapons["bren_mp"] = 			2;
	weapons["enfield_scope_mp"] = 		  1;
	weapons["mosin_nagant_mp"] = 		  1;
	weapons["SVT40_mp"] = 			2;
	weapons["PPS42_mp"] = 			2;
	weapons["ppsh_mp"] = 			2;
	weapons["mosin_nagant_sniper_mp"] = 	  1;
	weapons["kar98k_mp"] = 			  1;
	weapons["g43_mp"] = 			2;
	weapons["mp40_mp"] = 			2;
	weapons["mp44_mp"] = 			2;
	weapons["kar98k_sniper_mp"] = 		  1;
	weapons["colt_mp"] = 			2;
	weapons["luger_mp"] = 			2;
	weapons["tt30_mp"] = 			2;
	weapons["webley_mp"] = 			2;
	weapons["mg_mp"] = 			2;

	// "", "missed", "kill"
	if (!isDefined(reason))
		reason = "";

	playSpawnSound = false;


	// Mode changed or initialized
	if (reason == "mode")
	{
		self.aimTarget1 hide();
		self.aimTarget1.origin = (-99999, -99999, -99999);

		wait level.fps_multiplier * 1.5;

		self.aimTrainer_startAngles = self.angles;

		playSpawnSound = true;
	}

	if (reason == "missed")
	{
		self.aimTarget1 hide();
		self.aimTarget1.origin = (-99999, -99999, -99999);

		// Mode 4: Reaction time"
		if (self.aimTrainerMode == 4)
		{
			self iprintlnbold("^1Too soon!");
		}

		wait level.fps_multiplier * 0.1;

		self playlocalsound("aim_trainer_missed_shot");

		wait level.fps_multiplier * 0.9;

		self.aimTrainer_startAngles = self.angles;

		playSpawnSound = true;
	}

	if (reason == "kill")
	{
		react_time = -1;
		if (isDefined(self.aimTarget1.generateTime))
		{
			react_time = (gettime() - self.aimTarget1.generateTime);
			// Because it will be always increment of sv_fps and the ping, add some number to make it dynamic
			react_time += randomint(level.sv_fps);
			// Remove 30 ms ping
			if (react_time > 50) react_time -= 30;

			// Mode 4: Reaction time"
			if (self.aimTrainerMode == 4)
			{
				self iprintlnbold("Reaction time: " + react_time + "ms");
			}


			if (react_time > 5000)
				self.aimTrainer_startAngles = self.angles;

		}

		playfx(level._effect["aimTargetExplosion"], self.aimTarget1.origin);
		self playlocalsound("aim_trainer_hit");

		self.aimTarget1 hide();
		self.aimTarget1.origin = (-99999, -99999, -99999);
		self.aimTarget1.kills++;
	}

	wait level.frame;

	while(self.aimTrainer_outOfAmmo)
	{
		wait level.frame;
		playSpawnSound = true;
	}


	weapon = self getcurrentweapon(); // can be none
	if (self.usingMG)
		weapon = "mg_mp";

	mode = 1;
	if (isDefined(weapons[weapon]))
		mode = weapons[weapon];

	// Single shot
	if (mode == 1)
	{
		wait level.fps_multiplier * 2;

		playSpawnSound = true;
	}

	// Automatic
	if (mode == 2)
	{

	}

	//self iprintln("self.aimTrainerMode: " + self.aimTrainerMode);

	if (self.aimTrainerMode == 1)
	{
		// Mode 1: Static targets
		self.aimTarget1.origin = self getTargetPos(true);
	}
	else if (self.aimTrainerMode == 2)
	{
		// Mode 2: Moving targets
		self.aimTarget1.origin = self getTargetPos(true);
		self.aimTarget1 thread moving(5);
	}
	else if (self.aimTrainerMode == 3)
	{
		// Mode 3: Moving targets fast
		self.aimTarget1.origin = self getTargetPos(true);
		self.aimTarget1 thread moving(2.5);
	}
	else if (self.aimTrainerMode == 4)
	{
		// Mode 4: Reaction time"
		wait level.fps_multiplier * 1;
		wait level.fps_multiplier * (randomint(30) / 10);  // 0.0 - 2.9
		self.aimTarget1.origin = self getTargetPos(false);
		playSpawnSound = true;
	}

	//self.aimTarget1.trigger_damage unlink();
	self.aimTarget1.trigger_damage.origin = self.aimTarget1.origin;
	//self.aimTarget1.trigger_damage linkto(self.aimTarget1);

	self.aimTarget1 show();
	//self.aimTarget1 thread setKillTimeout(5, self);
	self.aimTarget1.generateTime = gettime();

	if (playSpawnSound)
		self playlocalsound("aim_trainer_spawn");
}
