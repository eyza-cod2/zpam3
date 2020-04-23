#include maps\mp\gametypes\_callbacksetup;

init()
{
    addEventListener("onConnected",         ::onConnected);
	addEventListener("onSpawnedPlayer",     ::onSpawnedPlayer);

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

    // Set some cheat-cvars to value that increase details, realistic and better quality
    self thread betterGraphics();

    self thread Force();
}

betterGraphics()
{
    self endon("disconnect");

    // Wait untill sv_cheats is properly set (if this is called right after map is changed via devmap, sv_cheats is set after 0.05)
    wait level.fps_multiplier * 0.1;

	/*
	!!!!!!!!!!!!!!!!!!!!!!!
	This below was canceled because of significant FPS drops in some areas of map
	!!!!!!!!!!!!!!!!!!!!!!!
	*/

	// More details for far distance
	// Set it only if we are not in devmap!
	// (there is a bug when r_forceLod is changed in devmap and map is restarted.. - all xmodels are not visible.. why??)
    if (getCvarInt("sv_cheats") == 1 || level.gametype == "strat") {
		// Low detail
		//self setClientCvar("r_lodBias", "0"); //  cvar is cheat protected, so it has to be handled in pb ranges
	    //self setClientCvar("r_forceLod", "none");
	} else {
		// High detail
	    //self setClientCvar("r_lodBias", "-500"); //  cvar is cheat protected, so it has to be handled in pb ranges
	    //self setClientCvar("r_forceLod", "high");
	}

    // More realistic bullet-trace light
    self setClientCvar("cg_tracerChance", "1");
    self setClientCvar("cg_tracerWidth", "1");
    self setClientCvar("cg_tracerLength", "1000");
    self setClientCvar("cg_tracerSpeed", "20000");

    // Show icons in scipe while zoomed
    self setClientCvar("cg_hudDamageIconInScope", "1");
    self setClientCvar("cg_hudGrenadeIconInScope", "1");
}

onSpawnedPlayer()
{
    self notify("stop_enforcement"); // stop thread before running next one
	self thread Start_Enforcer();
}


Start_Enforcer()
{
	self endon("disconnect");
	self endon("killed_player");
    self endon("joined_spectators");
	self endon("stop_enforcement");

	//wait level.fps_multiplier * 3; // Wait a while after they spawned to help minimize the number of commands being flooded into the client

	while (1)
	{
		wait level.fps_multiplier * 3;
		self thread Force();
	}
}

Force()
{
    self endon("disconnect");

    //self iprintln("^5ENFORCE");

    if (level.scr_force_client_best_connection)
    {
        self setClientCvar("rate", 25000);
		wait level.fps_multiplier * 0.1;

        self setClientCvar("cl_maxpackets", 100);
        wait level.fps_multiplier * 0.1;

		self setClientCvar("cl_packetdup", 1);	// this will increase length of packets
		wait level.fps_multiplier * 0.1;

        self setClientCvar("snaps", 30);	// this may corespond to sv_fps
        wait level.fps_multiplier * 0.1;
    }

	if (level.scr_force_client_exploits)
	{
        self setClientCvar("sc_enable", 0); // disable shadows in dx9
		wait level.fps_multiplier * 0.1;

        self setClientCvar("fx_sort", 1); // for better smoke rendering
        wait level.fps_multiplier * 0.1;

        self setClientCvar("mss_Q3fs", 1); // 0 will disable background music - ???
        wait level.fps_multiplier * 0.1;
	}
}

setForcedCvarsByPB()
{
    self endon("disconnect");

    wait level.fps_multiplier * 3;

    self setClientCvar("cg_errordecay", "100");
    self setClientCvar("cg_hintFadeTime", "100");

    self setClientCvar("cg_hudCompassMaxRange", "1500");
    self setClientCvar("cg_hudCompassMinRadius", "0");
    self setClientCvar("cg_hudCompassMinRange", "0");
    self setClientCvar("cg_hudCompassSpringyPointers", "0");

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
    self setClientCvar("cl_packetdup", "1");
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

    self setClientCvar("snaps", "30");


    self.pers["pbForcedCvarsLoaded"] = true;

}
