minefields()
{
	minefields = getentarray("minefield", "targetname");
	if (minefields.size > 0)
	{
		level._effect["mine_explosion"] = loadfx ("fx/explosions/grenadeExp_dirt.efx");
	}

	for(i = 0; i < minefields.size; i++)
	{
		minefields[i] thread minefield_think();
	}
}

minefield_think()
{
	while (1)
	{
		self waittill ("trigger",other);

		if ( isDefined(level.in_readyup) && level.in_readyup )
			continue;

		if(isPlayer(other))
			other thread minefield_kill(self);
	}
}

minefield_kill(trigger)
{
	if(isDefined(self.minefield))
		return;

	if (!isDefined(level.fps_multiplier))
		level.fps_multiplier = 1;

	self.minefield = true;
	self playsound ("minefield_click");

	wait(level.fps_multiplier * .5);
	wait(level.fps_multiplier * randomFloat(.5));

	if(isdefined(self) && self istouching(trigger))
	{
		origin = self getorigin();
		range = 300;
		maxdamage = 2000;
		mindamage = 50;

		self playsound("explo_mine");
		playfx(level._effect["mine_explosion"], origin);
		radiusDamage(origin, range, maxdamage, mindamage);
	}

	self.minefield = undefined;
}
