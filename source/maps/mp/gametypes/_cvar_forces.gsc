#include maps\mp\gametypes\global\_global;

init()
{
    addEventListener("onConnected",         ::onConnected);

    setCvar("rate", "25000");
    setCvar("sv_maxRate", "25000");
    setCvar("sv_pure", "1");
}

onConnected()
{
    if (!isDefined(self.pers["pbForcedCvarsLoaded"]))
        self.pers["pbForcedCvarsLoaded"] = false;

    // Set cvars that are forced by PunkBuster do correct value to prevent PUNKBUSTER WARNINGS
    if (!self.pers["pbForcedCvarsLoaded"])
        self thread setForcedCvarsByPB();

    // Set some cvars to value that increase competitive quality
    self thread competitiveQuality();
}


competitiveQuality()
{
	self endon("disconnect");

	// Wait till player join team to save sent cvars to client
	while (!isDefined(self.pers["firstTeamSelected"]))
		wait level.frame;

	wait level.fps_multiplier * 0.1;

	// Wait more if player joined spectator (usefull especially for streamers - lot of cvars is beeing sent)
	if (self.sessionstate == "spectator")
		wait level.fps_multiplier * 8;

	// More realistic bullet-trace light
	self setClientCvar2("cg_tracerChance", "1");
	self setClientCvar2("cg_tracerWidth", "1");
	self setClientCvar2("cg_tracerLength", "1000");
	self setClientCvar2("cg_tracerSpeed", "20000");

	// Show icons in scipe while zoomed
	self setClientCvar2("cg_hudDamageIconInScope", "1");
	self setClientCvar2("cg_hudGrenadeIconInScope", "1");

	// disable sun
	self setClientCvar2("r_drawSun", 0);
}


setForcedCvarsByPB()
{
	self endon("disconnect");

	// Wait till player join team to save sent cvars to client
	while (!isDefined(self.pers["firstTeamSelected"]))
		wait level.frame;

	wait level.fps_multiplier * 0.2;

	// Wait more if player joined spectator (usefull especially for streamers - lot of cvars is beeing sent)
	if (self.sessionstate == "spectator")
		wait level.fps_multiplier * 8;

	self setClientCvar2("snaps", 30);
	self setClientCvar2("sc_enable", "0");
	self setClientCvar2("fx_sort", "1");
	self setClientCvar2("rate", "25000");
	self setClientCvar2("cl_maxpackets", "100");

	wait level.fps_multiplier * 0.2;

	self setClientCvar2("cg_viewsize", "100");
	self setClientCvar2("cl_avidemo", "0");
	self setClientCvar2("cl_forceavidemo", "0");
	self setClientCvar2("cl_freelook", "1");
	self setClientCvar2("cl_pitchspeed", "140");
	self setClientCvar2("cl_yawspeed", "140");

	wait level.fps_multiplier * 0.2;

	self setClientCvar2("fixedtime", "0");
	self setClientCvar2("friction", "5.5");
	self setClientCvar2("mss_q3fs", "1");
	self setClientCvar2("cg_errordecay", "100");
	self setClientCvar2("cg_hintFadeTime", "100");

	wait level.fps_multiplier * 0.2;

	self setClientCvar2("cg_hudCompassMaxRange", "1500");
	self setClientCvar2("cg_hudCompassMinRadius", "0");
	self setClientCvar2("cg_hudCompassMinRange", "0");
	self setClientCvar2("cg_hudCompassSpringyPointers", "0");
	self setClientCvar2("cg_hudCompassSoundPingFadeTime", "2");

	wait level.fps_multiplier * 0.2;

	self setClientCvar2("cg_hudDamageIconHeight", "64");
	self setClientCvar2("cg_hudDamageIconOffset", "128");
	self setClientCvar2("cg_hudDamageIconTime", "2000");
	self setClientCvar2("cg_hudDamageIconWidth", "128");

	wait level.fps_multiplier * 0.2;

	self setClientCvar2("cg_hudGrenadeIconHeight", "25");
	self setClientCvar2("cg_hudGrenadeIconOffset", "50");
	self setClientCvar2("cg_hudGrenadeIconWidth", "25");
	self setClientCvar2("cg_hudGrenadePointerHeight", "12");

	wait level.fps_multiplier * 0.2;

	self setClientCvar2("cg_hudGrenadePointerPivot", "12 27");
	self setClientCvar2("cg_hudGrenadePointerWidth", "25");
	self setClientCvar2("cg_hudObjectiveMaxRange", "2048");
	self setClientCvar2("cg_hudObjectiveMinAlpha", "1");
	self setClientCvar2("cg_hudObjectiveMinHeight", "-70");

	self.pers["pbForcedCvarsLoaded"] = true;

}
