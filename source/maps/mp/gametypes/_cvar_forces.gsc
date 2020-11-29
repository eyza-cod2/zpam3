#include maps\mp\gametypes\_callbacksetup;

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

    wait level.fps_multiplier * (randomIntRange(10, 30) / 10); // wait 1-3 sec (to avoid sendind commands to all players at once)

    // More realistic bullet-trace light
    self setClientCvar("cg_tracerChance", "1");
    self setClientCvar("cg_tracerWidth", "1");
    self setClientCvar("cg_tracerLength", "1000");
    self setClientCvar("cg_tracerSpeed", "20000");

    wait level.fps_multiplier * 0.1;

    // Show icons in scipe while zoomed
    self setClientCvar("cg_hudDamageIconInScope", "1");
    self setClientCvar("cg_hudGrenadeIconInScope", "1");

    // disable sun
    self setClientCvar("r_drawSun", 0);
}


setForcedCvarsByPB()
{
    self endon("disconnect");

    wait level.fps_multiplier * (randomIntRange(10, 30) / 10); // wait 1-3 sec (to avoid sendind commands to all players at once)

    self setClientCvar("cg_errordecay", "100");
    self setClientCvar("cg_hintFadeTime", "100");

    self setClientCvar("cg_hudCompassMaxRange", "1500");
    self setClientCvar("cg_hudCompassMinRadius", "0");
    self setClientCvar("cg_hudCompassMinRange", "0");
    self setClientCvar("cg_hudCompassSpringyPointers", "0");
    self setClientCvar("cg_hudCompassSoundPingFadeTime", "2");


	wait level.frame;

    self setClientCvar("cg_hudDamageIconHeight", "64");
    self setClientCvar("cg_hudDamageIconOffset", "128");
    self setClientCvar("cg_hudDamageIconTime", "2000");
    self setClientCvar("cg_hudDamageIconWidth", "128");

    wait level.frame;

    self setClientCvar("cg_hudGrenadeIconHeight", "25");
    self setClientCvar("cg_hudGrenadeIconOffset", "50");
    self setClientCvar("cg_hudGrenadeIconWidth", "25");
    self setClientCvar("cg_hudGrenadePointerHeight", "12");
	wait level.frame;
    self setClientCvar("cg_hudGrenadePointerPivot", "12 27");
    self setClientCvar("cg_hudGrenadePointerWidth", "25");

    self setClientCvar("cg_hudObjectiveMaxRange", "2048");
    self setClientCvar("cg_hudObjectiveMinAlpha", "1");
    self setClientCvar("cg_hudObjectiveMinHeight", "-70");

    wait level.frame;

    self setClientCvar("cg_viewsize", "100");
    self setClientCvar("cl_avidemo", "0");
    self setClientCvar("cl_forceavidemo", "0");
    self setClientCvar("cl_freelook", "1");
	wait level.frame;
    self setClientCvar("cl_maxpackets", "100");
    //self setClientCvar("cl_packetdup", "3");
    self setClientCvar("cl_pitchspeed", "140");
    self setClientCvar("cl_yawspeed", "140");



    wait level.frame;

    self setClientCvar("fixedtime", "0");
    self setClientCvar("friction", "5.5");
    self setClientCvar("fx_sort", "1");
    self setClientCvar("mss_q3fs", "1");

	wait level.frame;

    self setClientCvar("rate", "25000");
    self setClientCvar("sc_enable", "0");
    self setClientCvar("snaps", 30);


    self.pers["pbForcedCvarsLoaded"] = true;

}
