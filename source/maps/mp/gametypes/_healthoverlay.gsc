#include maps\mp\gametypes\_callbacksetup;

init()
{
	if(!level.scr_allow_health_regen)
		return;


	precacheShader("overlay_low_health");

	addEventListener("onSpawnedPlayer",     ::onSpawnedPlayer);
    addEventListener("onPlayerKilled",   			::onPlayerKilled);
	addEventListener("onJoinedAlliesAxis",  ::onJoinedAlliesAxis);
    addEventListener("onJoinedSpectator",   ::onJoinedSpectator);
}

onSpawnedPlayer()
{
	self thread playerHealthRegen();
}

onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	self notify("end_healthregen");
}
onJoinedAlliesAxis()
{
	self notify("end_healthregen");
}
onJoinedSpectator()
{
	self notify("end_healthregen");
}



playerHealthRegen()
{
	self endon("disconnect");
	self endon("end_healthregen");

	healthOverlayCutoff = 0.45;

	maxhealth = self.health;
	oldhealth = maxhealth;
	player = self;

	regenRate = 0.1; // 0.017;
	veryHurt = false;

	if (level.scr_allow_regen_sounds)
		thread playerBreathingSound(maxhealth * .45);

	lastSoundTime_Recover = 0;
	hurtTime = 0;
	newHealth = 0;


    lastTime = 0;

	for (;;)
	{
		wait level.frame;
		if (player.health == maxhealth)
		{
			veryHurt = false;
			continue;
		}

		// End thread if player is dead
		if (player.health <= 0)
			return;


		if (player.health < oldhealth)
			hurtTime = gettime();


		wasVeryHurt = veryHurt;
		ratio = player.health / maxHealth;
		if (ratio <= healthOverlayCutoff)
			veryHurt = true;


		if (player.health >= oldhealth)
		{
			if (gettime() - hurttime < level.scr_regen_delay)
				continue;

			if (gettime() - lastSoundTime_Recover > level.scr_regen_delay)
			{
				if (veryHurt)
				{
					lastSoundTime_Recover = gettime();
					if (level.scr_allow_regen_sounds)
						self playLocalSound("breathing_better");
				}
			}

			if (veryHurt)
			{
				newHealth = ratio;
				lastTime = hurtTime;

				if (gettime() > lastTime + 3000)
				{
					newHealth += regenRate;
				}
			}
			else
			{
				newHealth = ratio;
				lastTime = hurtTime;

				if (gettime() > lastTime + 3000)
				{
					newHealth = 1;
				}

			}

			if (newHealth > 1.0)
				newHealth = 1.0;

			if (newHealth <= 0)
			{
				// Player is dead
				player.health = 0;
				return;
			}

			player setnormalhealth (newHealth);

			oldhealth = player.health;
			continue;
		}

		oldhealth = player.health;

		hurtTime = gettime();
	}
}

playerBreathingSound(healthcap)
{
	self endon("disconnect");
	self endon("end_healthregen");

	wait level.fps_multiplier * 2;
	player = self;
	for (;;)
	{
		wait level.fps_multiplier * 0.2;
		if (player.health <= 0)
			return;

		// Player still has a lot of health so no breathing sound
		if (player.health >= healthcap)
			continue;

		player playLocalSound("breathing_hurt");
		wait level.fps_multiplier * .784;
		wait level.fps_multiplier * (0.1 + randomfloat (0.8));
	}
}
