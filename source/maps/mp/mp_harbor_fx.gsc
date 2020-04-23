main()
{
	precacheFX();
	ambientFX();
	level.scr_sound["flak88_explode"]	= "flak88_explode";
}

precacheFX()
{
	level._effect["flak_explosion"]				= loadfx ("fx/explosions/flak88_explosion.efx");
	level._effect["snow_light"]					= loadfx ("fx/misc/snow_light_mp_downtown.efx");
	level._effect["thin_black_smoke_S"]			= loadfx ("fx/smoke/thin_black_smoke_S.efx");
	level._effect["thin_black_smoke_M"]			= loadfx ("fx/smoke/thin_black_smoke_M.efx");
	level._effect["snow_wind_cityhall"]			= loadfx ("fx/misc/snow_wind_cityhall.efx");
	level._effect["fogbank_small_duhoc"]		= loadfx ("fx/misc/fogbank_small_duhoc.efx");
	level._effect["tank_fire_engine"] 			= loadfx ("fx/fire/tank_fire_engine.efx");
}


ambientFX()
{
	if (level.scr_allow_ambient_weather)
	{
		//Snow
		maps\mp\_fx::loopfx("snow_light", (-11246,-7164,450), 0.6, (-11246,-7164,530));
		maps\mp\_fx::loopfx("snow_light", (-7352,-7369,450), 0.6, (-7352,-7369,530));

		//Wind FX
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-8014,-8515,34), 1, (-8014,-8515,134));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-6776,-8657,18), 1, (-6776,-8657,118));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-6693,-7364,18), 1, (-6693,-7364,118));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-7493,-7016,2), 1, (-7493,-7016,102));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-7977,-7641,18), 1, (-7977,-7641,118));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-8727,-8311,126), 1, (-8727,-8311,226));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-8793,-7809,14), 1, (-8793,-7809,114));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-8814,-7145,30), 1, (-8814,-7145,130));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-9406,-6648,30), 1, (-9406,-6648,130));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-9267,-8359,30), 1, (-9267,-8359,130));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-10115,-7554,14), 1, (-10115,-7554,114));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-10234,-8122,14), 1, (-10234,-8122,114));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-9201,-6121,15), 1, (-9201,-6121,115));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-6245,-7070,19), 1, (-6245,-7070,119));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-6765,-7786,33), 1, (-6765,-7786,133));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-7582,-8902,7), 1, (-7582,-8902,107));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-9590,-7220,81), 1, (-9590,-7220,181));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-11626,-7573,14), 1, (-11626,-7573,114));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-11634,-8236,15), 1, (-11634,-8236,115));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-10975,-7170,18), 1, (-10975,-7170,118));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-10684,-7173,78), 1, (-10684,-7173,178));
		maps\mp\_fx::loopfx("snow_wind_cityhall", (-9264,-8633,174), 1, (-9264,-8633,274));

		//interrior fog
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-8449,-8819,-33), 2, (-8449,-8819,66));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-9791,-8669,8), 2, (-9791,-8669,108));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-9804,-8321,8), 2, (-9804,-8321,108));
		maps\mp\_fx::loopfx("fogbank_small_duhoc", (-8399,-7360,28), 2, (-8399,-7360,128));
	}

	if (level.scr_allow_ambient_fire)
	{
		maps\mp\_fx::loopfx("thin_black_smoke_S", (-6653,-7064,-30), 1, (-6653,-7064,70));
		maps\mp\_fx::loopfx("thin_black_smoke_M", (-4790,-6309,1544), 1, (-4818,-6309,1640));
		maps\mp\_fx::loopfx("thin_black_smoke_M", (-4999,-6863,1544), 1, (-4999,-6863,1644));
		maps\mp\_fx::loopfx("thin_black_smoke_M", (-6198,-10181,1544), 1, (-6198,-10181,1644));
		maps\mp\_fx::loopfx("thin_black_smoke_M", (-11848,-10941,1858), 1, (-11848,-10941,1958));
		maps\mp\_fx::loopfx("thin_black_smoke_S", (-12047,-10712,1125), 1, (-12147,-10712,1126));
		maps\mp\_fx::loopfx("thin_black_smoke_M", (-9325,-9553,828), 1, (-9325,-9553,928));

		//barrel fire
		maps\mp\_fx::loopfx("tank_fire_engine", (-8687,-7065,64), 1, (-8687,-7065,164));
		maps\mp\_fx::loopfx("tank_fire_engine", (-8642,-8987,43), 1, (-8642,-8987,143));

		//firesounds
		maps\mp\_fx::soundfx("medfire", (-8681,-7063,66));
		maps\mp\_fx::soundfx("medfire", (-8642,-8987,43));
	}
}
