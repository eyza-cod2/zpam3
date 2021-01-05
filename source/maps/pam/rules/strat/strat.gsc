Rules()
{
    // Match Style
	setcvar("scr_strat_timelimit", 0);
	setcvar("scr_strat_half_round", 0);
	setcvar("scr_strat_half_score", 0);
	setcvar("scr_strat_end_round", 0);
	setcvar("scr_strat_end_score", 0);

	// Are there OT Rules?
	setcvar("scr_overtime", 0);

	// Automaticly enable / disable deadchat
	setcvar("scr_auto_deadchat", 1);

	// Readyup
	setcvar("scr_readyup", 0); // Enable readyup [0, 1] 0 = disbled  1 = enabled

	// Time-out
	setcvar("scr_timeouts", 0);	// Total timeous for one team

	// Hud Options
	setcvar("scr_show_players_left", 0);
	//setcvar("scr_show_death_icons", 0);
	setcvar("scr_show_objective_icons", 0);
	setcvar("scr_show_hitblip", 1);

	setcvar("scr_show_scoreboard", 0); //The stock one up in the upper left corner...
	setcvar("scr_show_scoreboard_limit", 0);


	// Health Regen & Delay
	setcvar("scr_allow_health_regen", 1); // 0= no regen, 1 is stock, and there are other options too
	setcvar("scr_regen_delay", 5000); //Time before regen starts





	// Nade Spawn Counts
	setcvar("scr_boltaction_nades", 99);
	setcvar("scr_semiautomatic_nades", 99);
	setcvar("scr_smg_nades", 99);
	setcvar("scr_sniper_nades", 99);
	setcvar("scr_mg_nades", 99);
	setcvar("scr_shotgun_nades", 99);

	// Smoke Spawn Counts
	setcvar("scr_boltaction_smokes", 99);
	setcvar("scr_semiautomatic_smokes", 99);
	setcvar("scr_smg_smokes", 99);
	setcvar("scr_sniper_smokes", 99);
	setcvar("scr_mg_smokes", 99);
	setcvar("scr_shotgun_smokes", 99);

	// Allow Weapon Drops
	setcvar("scr_allow_grenade_drop", 0);
	setcvar("scr_sniper_allow_drop", 0);
	setcvar("scr_shotgun_allow_drop", 0);

	// Secondary Weapon Drop
	setcvar("scr_allow_secondary_drop", 1);

	// Weapon Limits by class per team
	setcvar("scr_boltaction_limit", 99);
	setcvar("scr_sniper_limit", 99);
	setcvar("scr_semiautomatic_limit", 99);
	setcvar("scr_smg_limit", 99);
	setcvar("scr_mg_limit", 99);
	setcvar("scr_shotgun_limit", 99);

	// Allow/Disallow Weapons
	setcvar("scr_allow_greasegun", 1);
	setcvar("scr_allow_m1carbine", 1);
	setcvar("scr_allow_m1garand", 1);
	setcvar("scr_allow_springfield", 1);
	setcvar("scr_allow_thompson", 1);
	setcvar("scr_allow_bar", 1);
	setcvar("scr_allow_sten", 1);
	setcvar("scr_allow_enfield", 1);
	setcvar("scr_allow_enfieldsniper", 1);
	setcvar("scr_allow_bren", 1);
	setcvar("scr_allow_pps42", 1);
	setcvar("scr_allow_nagant", 1);
	setcvar("scr_allow_svt40", 1);
	setcvar("scr_allow_nagantsniper", 1);
	setcvar("scr_allow_ppsh", 1);
	setcvar("scr_allow_mp40", 1);
	setcvar("scr_allow_kar98k", 1);
	setcvar("scr_allow_g43", 1);
	setcvar("scr_allow_kar98ksniper", 1);
	setcvar("scr_allow_mp44", 1);
	setcvar("scr_allow_shotgun", 1);
	//setcvar("scr_allow_fraggrenades", 1);
	setcvar("scr_allow_smokegrenades", 1);
	setcvar("scr_allow_pistols", 1);
	setcvar("scr_allow_turrets", 1);



	// Single Shot Kills
	setcvar("scr_no_oneshot_pistol_kills", 0);
	setcvar("scr_no_oneshot_ppsh_kills", 0);

	// PPSH Balance - Limits range of PPSH to same as Tommy
	setcvar("scr_balance_ppsh_distance", 0);

	//ShellShock
	setcvar("scr_allow_shellshock", 0);


	// DVAR Enforcer
	setcvar("scr_force_client_best_connection", 1);
	setcvar("scr_force_client_exploits", 1);


	// Ambients
	setcvar("scr_allow_ambient_fog", 0);
	setcvar("scr_allow_ambient_sounds", 0);
	setcvar("scr_allow_ambient_fire", 0);
	setcvar("scr_allow_ambient_weather", 0);

	// Kill Triggers
	setcvar("scr_remove_killtriggers", 1);

	// Shared gametype script cvars
	setcvar("scr_friendlyfire", 1);
	setcvar("scr_drawfriend", 1);
	setcvar("scr_teambalance", 0);
	setcvar("scr_killcam", 0);
	setcvar("scr_spectatefree", 1);
	setcvar("scr_spectateenemy", 1);
	setcvar("scr_replace_russian", 1);
	setcvar("scr_recording", 0); 						// Starts automatically recording when match starts
	setcvar("scr_shotgun_rebalance", 1);				// Enable shotgun rebalance to fix long shot kills and short range hits
	setcvar("scr_diagonal_fix", 0); 					// Enable diagonal bug fix (disables leaning for players when strafing)
	setcvar("scr_prone_peak_fix", 0);					// Prevent players from doing fast peaks from prone (time, after player can prone again will be increased)
	setcvar("scr_fast_reload_fix", 1);				// Prevent players from shoting faster via double-scroll bug
	setcvar("scr_bash", 0);															// Bash mode can be called via menu in readyup

	// Not Likely to Change
	setcvar("g_allowVote", 0); // level.allowvote
	setcvar("g_antilag", 0); // Turn on antilag checks for weapon hits
	setcvar("g_maxDroppedWeapons", 32); // Maximum number of dropped weapons
	setcvar("sv_fps", 30);
	setcvar("sv_maxRate", 25000);
	setcvar("sv_timeout", 60);		// time after 999 player is kicked
    setCvar("sv_cheats", "0");


	// Blackout
	setcvar("scr_blackout", 0); // If match is in progress, show map background all over the screen and disable sounds for connected player

	// DO NOT MODIFY BELOW THIS LINE!
	game["leagueLogo"] = "";
	game["leagueString"] = &"Strategy Planning Mode";
	game["is_public_mode"] = false;
}
