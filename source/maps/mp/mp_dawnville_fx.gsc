main()
{
	precacheFX();
	ambientFX();	
	level.scr_sound["flak88_explode"]	= "flak88_explode";
}

precacheFX()
{
	level._effect["flak_explosion"]		= loadfx("fx/explosions/flak88_explosion.efx");

	//ambient FX
	level._effect["thin_black_smoke_S"]				= loadfx ("fx/smoke/thin_black_smoke_S.efx");
	level._effect["thin_light_smoke_L"]				= loadfx ("fx/smoke/thin_light_smoke_L.efx");
	level._effect["thin_light_smoke_M"]				= loadfx ("fx/smoke/thin_light_smoke_M.efx");
	level._effect["battlefield_smokebank_S"]		= loadfx ("fx/smoke/battlefield_smokebank_S.efx");
	level._effect["tank_fire_turret"] 			= loadfx ("fx/fire/tank_fire_turret_small.efx");
	level._effect["tank_fire_engine"] 			= loadfx ("fx/fire/tank_fire_engine.efx");
	level._effect["building_fire_small"]		= loadfx ("fx/fire/building_fire_small.efx");


}

ambientFX()
{
	if (level.scr_allow_ambient_fire)
	{
		maps\mp\_fx::loopfx("thin_black_smoke_S", (-563,-17506,65), 0.6, (-563,-17506,164));
		maps\mp\_fx::loopfx("thin_black_smoke_S", (390,-17422,56), 0.6, (390,-17422,155));
		maps\mp\_fx::loopfx("thin_light_smoke_M", (-804,-16125,-74), 1, (-804,-16125,25));
		maps\mp\_fx::loopfx("thin_light_smoke_M", (-400,-15553,-62), 1, (-400,-15553,36));

		maps\mp\_fx::loopfx("tank_fire_turret", (655,-16348,37), 2, (655,-16348,136));
		maps\mp\_fx::loopfx("tank_fire_engine", (593,-16308,-2), 2, (601,-16209,14));
		maps\mp\_fx::loopfx("tank_fire_engine", (821,-17057,59), 2, (821,-17057,159));
		maps\mp\_fx::loopfx("tank_fire_engine", (724,-17202,53), 2, (724,-17202,153));
		maps\mp\_fx::loopfx("tank_fire_engine", (784,-17043,41), 2, (708,-16980,58));
		maps\mp\_fx::loopfx("tank_fire_engine", (732,-17091,45), 2, (657,-17028,62));

		//SoundFX
		maps\mp\_fx::soundfx("medfire", (785,-17095,82));
		maps\mp\_fx::soundfx("medfire", (658,-16335,17));
	}

	if (level.scr_allow_ambient_weather)
	{
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (620,-15642,1), 1, (620,-15642,101));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (2536,-15436,-84), 1, (2536,-15436,15));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (-302,-17245,32), 1, (-302,-17245,132));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (1048,-14864,-41), 1, (1048,-14864,58));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (-91,-14659,6), 1, (-91,-14659,105));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (626,-16903,56), 1, (626,-16903,156));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (-1014,-17478,37), 1, (-1014,-17478,137));
		maps\mp\_fx::loopfx("battlefield_smokebank_S", (-1819,-17836,-11), 1, (-1819,-17836,88));
	}
}
