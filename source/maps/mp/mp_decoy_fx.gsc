main()
{
	precacheFX();
	ambientFX();
	level.scr_sound["flak88_explode"]	= "flak88_explode";
}

precacheFX()
{
	level._effect["flak_explosion"]				= loadfx("fx/explosions/flak88_explosion.efx");
	level._effect["dust_wind_night"] 			= loadfx ("fx/dust/dust_wind_night.efx");
	level._effect["tank_fire_turret"] 			= loadfx ("fx/fire/tank_fire_turret_small.efx");
	level._effect["tank_fire_engine"] 			= loadfx ("fx/fire/tank_fire_engine.efx");


}

ambientFX()
{
	if (level.scr_allow_ambient_fire)
	{
		maps\mp\_fx::loopfx("tank_fire_turret", (6278,-12882,-426), 1, (6278,-12882,-326));
		maps\mp\_fx::loopfx("tank_fire_engine", (6307,-12952,-463), 1, (6403,-12979,-474));
		maps\mp\_fx::loopfx("tank_fire_engine", (6217,-12988,-440), 1, (6217,-12988,-340));
		maps\mp\_fx::loopfx("tank_fire_engine", (8223,-13346,-470), 1, (8313,-13306,-452));
		maps\mp\_fx::loopfx("tank_fire_engine", (8198,-13409,-398), 1, (8288,-13369,-381));
		maps\mp\_fx::loopfx("tank_fire_engine", (8214,-13503,-434), 1, (8214,-13503,-334));
		maps\mp\_fx::loopfx("tank_fire_engine", (7875,-12708,-442), 1, (7875,-12708,-342));
		maps\mp\_fx::loopfx("tank_fire_engine", (7837,-12562,-442), 1, (7837,-12562,-342));
		maps\mp\_fx::loopfx("tank_fire_engine", (7917,-12603,-460), 1, (8009,-12564,-453));
		maps\mp\_fx::loopfx("tank_fire_turret", (8193,-13408,-422), 1, (8197,-13406,-323));
		maps\mp\_fx::loopfx("tank_fire_turret", (7860,-12626,-423), 1, (7864,-12624,-324));

		//Sound FX
		maps\mp\_fx::soundfx("medfire", (6271,-12902,-435));
		maps\mp\_fx::soundfx("medfire", (7852,-12631,-438));
		maps\mp\_fx::soundfx("medfire", (8197,-13405,-438));
	}

	if (level.scr_allow_ambient_weather)
	{
		// Original Dust FX DO NOT DELETE
		maps\mp\_fx::loopfx("dust_wind_night", (8823,-12338,-441), .6, (8823,-12338,-341));
		maps\mp\_fx::loopfx("dust_wind_night", (6469,-12810,-496), .6, (6469,-12810,-396));
		maps\mp\_fx::loopfx("dust_wind_night", (7128,-13570,-489), .6, (7128,-13570,-389));
		maps\mp\_fx::loopfx("dust_wind_night", (7008,-12849,-496), .6, (7008,-12849,-396));
		maps\mp\_fx::loopfx("dust_wind_night", (7228,-12212,-450), .6, (7228,-12212,-350));
		maps\mp\_fx::loopfx("dust_wind_night", (7645,-12160,-396), .6, (7645,-12160,-296));
		maps\mp\_fx::loopfx("dust_wind_night", (8566,-12053,-513), .6, (8566,-12053,-413));
		maps\mp\_fx::loopfx("dust_wind_night", (8469,-11695,-480), .6, (8469,-11695,-380));
		maps\mp\_fx::loopfx("dust_wind_night", (8015,-11958,-474), .6, (8015,-11958,-374));
		maps\mp\_fx::loopfx("dust_wind_night", (7642,-12674,-496), .6, (7642,-12674,-396));
		maps\mp\_fx::loopfx("dust_wind_night", (6701,-13118,-496), .6, (6701,-13118,-396));
		maps\mp\_fx::loopfx("dust_wind_night", (7493,-13248,-480), .6, (7493,-13248,-380));
		maps\mp\_fx::loopfx("dust_wind_night", (8316,-12883,-493), .6, (8316,-12883,-393));
		maps\mp\_fx::loopfx("dust_wind_night", (8528,-14377,-702), .6, (8528,-14377,-602));
		maps\mp\_fx::loopfx("dust_wind_night", (9220,-13096,-508), .6, (9220,-13096,-408));
		maps\mp\_fx::loopfx("dust_wind_night", (8674,-13699,-599), .6, (8674,-13699,-499));
		maps\mp\_fx::loopfx("dust_wind_night", (8723,-13259,-492), .6, (8723,-13259,-392));
		maps\mp\_fx::loopfx("dust_wind_night", (9863,-13181,-499), .6, (9863,-13181,-400));
		maps\mp\_fx::loopfx("dust_wind_night", (9590,-13828,-499), .6, (9590,-13828,-399));
		maps\mp\_fx::loopfx("dust_wind_night", (9263,-14137,-579), .6, (9263,-14137,-479));
		maps\mp\_fx::loopfx("dust_wind_night", (9528,-12412,-520), .6, (9528,-12412,-420));
		maps\mp\_fx::loopfx("dust_wind_night", (7244,-14192,-453), .6, (7244,-14192,-353));
		maps\mp\_fx::loopfx("dust_wind_night", (5963,-13410,-520), .6, (5963,-13410,-420));
		maps\mp\_fx::loopfx("dust_wind_night", (6185,-14084,-341), .6, (6185,-14084,-241));
	}
}
