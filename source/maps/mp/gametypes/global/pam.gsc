#include maps\mp\gametypes\global\_global;



init()
{
	// At the start of the server reset cvar pam_mode_custom to make sure default values are used for first time
    if (getTime() == 0)
	{
		setCvar("pam_mode_custom", "0");

		level thread switchMapToFixVersion();
	}

	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvarEx("I", "pam_mode", "STRING", "comp", maps\mp\gametypes\global\rules::IsValidPAMMode);
	registerCvarEx("I", "pam_mode_custom", "BOOL", false);


	if(game["firstInit"])
	{
		// PAM installed wrong
		precacheString2("STRING_NOT_INSTALLED_CORRECTLY_1", &"Error: zPAM is not installed correctly.");

		// Errors
		precacheString2("STRING_PAM_DONT_STEAL", &"This version of pam is only for testing! Dont steal!");
		precacheString2("STRING_PAM_FS_GAME", &"Cvar /fs_game is not empty!)");
		precacheString2("STRING_PAM_MUST_EXISTS_UNDER_MAIN", &"Iwd file ^9zpam402.iwd^7 must be installed in ^9main^7 folder."); // ZPAM_RENAME
		precacheString2("STRING_PAM_GETTING_IWD_FILES_ERROR", &"Error while getting loaded iwd files. Make sure iwd files does not contains spaces.");
		precacheString2("STRING_PAM_MAPS_MISSING", &"Iwd file ^9zpam_maps_v6.iwd^7 does not exists in ^9main^7 folder"); // ZPAM_RENAME
		precacheString2("STRING_PAM_MAPS_LOAD_ERROR", &"Error while checking if fixed maps exists. Map printed above was not found on server.");
		precacheString2("STRING_PAM_WWW_DOWNLOADING", &"WWW downloading must be enabled. Set ^9sv_wwwDownload^7 and ^9sv_wwwBaseURL");
		precacheString2("STRING_PAM_BLACKLIST", &"Old zPAM or maps detected in ^9main^7 folder. Delete iwd file you see printed above.");
		precacheString2("STRING_PAM_IWD_CUSTOM", &"Rename iwd file ^9zzz_zpam_custom.iwd^7 to something unique (e.g. ^9zzz_zpam_custom_fpschallange_v1.iwd^7)."); // ZPAM_RENAME
		precacheString2("STRING_PAM_COD2X_BLACKLIST", &"Old CoD2x version detected. Please update CoD2x version.");


		// Help url
		precacheString2("STRING_GITHUB_URL", &"https://github.com/eyza-cod2/zpam3");
		precacheString2("STRING_GITHUB_URL_HELP", &"Please visit ^9https://github.com/eyza-cod2/zpam3 ^7for install instructions.");
	}


	level.pam_folder = "main/zpam402"; // ZPAM_RENAME
	level.pam_map_iwd = "zpam_maps_v6";

	level.pam_mode_change = false;

	level.pam_installation_error = false;


	addEventListener("onStartGameType", ::onStartGameType);
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "pam_mode":
			if (isRegisterTime)
			{
				// Load pam mode cvars imidietly
				level.pam_mode = value;
				// Determine if public mode is set
				game["is_public_mode"] = level.pam_mode == "pub"; // Is public
			}
			else
				thread ChangeTo(value);
		return true;

		case "pam_mode_custom":
			level.pam_mode_custom = value;
			if (!isRegisterTime && value == false) // changed to 0
			{
				maps\mp\gametypes\global\cvar_system::SetDefaults();
			}
			//iprintln("pam_mode_custom changed to " + value);
		return true;

	}
	return false;
}


// Called after the <gametype>.gsc::main() and <map>.gsc::main() scripts are called
// At this point game specific variables are defined (like game["allies"], game["axis"], game["american_soldiertype"], ...)
// Called again for every round in round-based gameplay
onStartGameType()
{
	level thread CheckInstallation();
}


switchMapToFixVersion()
{
	waittillframeend;

	// Wait untill sv_cheats is set
	wait level.fps_multiplier * 0.2;

	// Dont switch the map if devmap were used
	if (getcvarint("sv_cheats") == 1)
		return;

	// Change map to FIX version if the server is run for first time
	map = "";
	if      (level.mapname == "mp_toujane") map = "mp_toujane_fix";
	else if (level.mapname == "mp_burgundy") map = "mp_burgundy_fix";
	else if (level.mapname == "mp_dawnville") map = "mp_dawnville_fix";
	else if (level.mapname == "mp_matmata") map = "mp_matmata_fix";
	else if (level.mapname == "mp_carentan") map = "mp_carentan_fix";
	else if (level.mapname == "mp_trainstation") map = "mp_trainstation_fix";
	if (map != "")
		map(map, false);
}


CheckInstallation()
{
	// If we are in listening mode, dont show installating error
	//if (level.dedicated == 0)
	//	return;

	// Wait untill sv_referencedIwds is set
	// Dont know why, but sv_referencedIwds cvars is defined after 4 frames
	wait level.fps_multiplier * 0.3; // just to be sure - on some servers cvars are set twice with different value every time

	sv_referencedIwds = getCvar("sv_referencedIwds");
	sv_referencedIwdNames = getCvar("sv_referencedIwdNames");
	sv_iwdNames = getCvar("sv_iwdNames");
	sv_iwds = getCvar("sv_iwds");

	// Referenced contains only loaded iwds, but full path!
	//"sv_referencedIwds" is: "-340018619 473749641 181429573 780394069 1101180720 1046874969 1053665859 -1652414412 " default: ""
	//"sv_referencedIwdNames" is: "main/zpam320_alpha main/iw_15 main/iw_13 main/iw_08 main/iw_07 main/iw_06 main/iw_04" default: ""

	// This contains all available iwd names
	//"sv_iwdNames" is: "zpam320_alpha mp_burgundy_fix iw_15 iw_14 iw_13 iw_12 iw_11 iw_10 iw_09 iw_08 iw_07 iw_06 iw_05 iw_04 iw_03 iw_02 iw_01 iw_00" default: ""
	//"sv_iwds" is: "530543226 960396763 181429573 -1449716526 780394069 -1333623355 -1980843666 1334775335 -621896007 1101180720 1046874969 1053665859 1842349204 -1652414412 1659111092 -1085686032 -2025394354 178615151 " default: ""


	// eyza safe
	/*if (getCvar("eyza") != "1337") // ZPAM_RENAME
	{
		setError(game["STRING_PAM_DONT_STEAL"]);
		return;
	}*/

	// If fs_mode is set
	if (tolower(level.fs_game) != "")
	{
		level thread printTextInLoop("Cvar /fs_game = '" + level.fs_game + "'. It needs to be empty", "Make sure IWD files are installed in main folder, not in mod folder.");

		setError(game["STRING_PAM_FS_GAME"]);
		return;
	}

	// Convert iwd names to array
	fullNumbersArray = splitString(sv_referencedIwds, " ");
	fullNameArray = splitString(sv_referencedIwdNames, " ");



	// Number of items is not same - may be due to spaces in iwd names!
	if (fullNumbersArray.size != fullNameArray.size)
	{
		level thread printTextInLoop("Diagnostics info: referencedIwds", sv_referencedIwdNames, sv_referencedIwdNames, fullNumbersArray.size + "!=" + fullNameArray.size);

		setError(game["STRING_PAM_GETTING_IWD_FILES_ERROR"]);
		return;
	}
/*
	/#
	println("Loaded iwds:");
	for (i = 0; i < fullNameArray.size; i++)
	{
		println(i + ": " + fullNameArray[i] + " " + fullNumbersArray[i]);
	}
	#/
*/
	// Convert iwd names to array
	numbersArray = splitString(sv_iwds, " ");
	nameArray = splitString(sv_iwdNames, " ");

	// Number of items is not same - may be due to spaces in iwd names!
	if (numbersArray.size != nameArray.size)
	{
		level thread printTextInLoop("Diagnostics info: iwds", sv_iwds, sv_iwdNames, numbersArray.size + "!=" + nameArray.size);

		setError(game["STRING_PAM_GETTING_IWD_FILES_ERROR"]);
		return;
	}
/*
	/#
	println("Available iwds:");
	for (i = 0; i < nameArray.size; i++)
	{
		println(i + ": " + nameArray[i] + " " + numbersArray[i]);
	}
	#/
*/

	if (!arrayContains(fullNameArray, level.pam_folder))
	{
		level thread printTextInLoop("Diagnostics info: sv_referencedIwdNames does not contain " + level.pam_folder);

		setError(game["STRING_PAM_MUST_EXISTS_UNDER_MAIN"]);
		return;
	}

	isLatestPatchOrCoD2x = getCvar("shortversion") == "1.3" || getCvarInt("g_cod2x") > 0;

	if (isLatestPatchOrCoD2x && (getCvarInt("sv_wwwDownload") == 0 || getCvar("sv_wwwBaseURL") == ""))
	{
		setError(game["STRING_PAM_WWW_DOWNLOADING"]);
		return;
	}

	if (isLatestPatchOrCoD2x && !arrayContains(nameArray, level.pam_map_iwd))
	{
		setError(game["STRING_PAM_MAPS_MISSING"]);
		return;
	}

	if (isLatestPatchOrCoD2x)
	{
		maps = [];

		maps[maps.size] = "mp_toujane_fix";
		maps[maps.size] = "mp_burgundy_fix";
		maps[maps.size] = "mp_dawnville_fix";
		maps[maps.size] = "mp_matmata_fix";
		maps[maps.size] = "mp_carentan_fix";
		maps[maps.size] = "mp_chelm_fix";
		maps[maps.size] = "mp_breakout_tls";
		maps[maps.size] = "mp_dawnville_sun";
		maps[maps.size] = "mp_leningrad_tls";
		maps[maps.size] = "mp_vallente_fix";
		maps[maps.size] = "mp_trainstation_fix";
		maps[maps.size] = "mp_carentan_bal";
		maps[maps.size] = "mp_railyard_mjr";
		maps[maps.size] = "mp_leningrad_mjr";
		maps[maps.size] = "wawa_3daim";


		for(i = 0; i < maps.size; i++)
		{
			if (!MapExists(maps[i]))
			{
				setError(game["STRING_PAM_MAPS_LOAD_ERROR"]);

				level thread printTextInLoop(maps[i]);

				return;
			}
		}
	}

	// Zpam custom iwd file
	if (arrayContains(nameArray, "zzz_zpam_custom"))
	{
		setError(game["STRING_PAM_IWD_CUSTOM"]);

		return;
	}

	blackList = [];
	blackList[blackList.size] = "zPAM207";
	blackList[blackList.size] = "zpam300_beta_2016_2_2";
	blackList[blackList.size] = "zpam300_beta";
	blackList[blackList.size] = "zpam300";
	blackList[blackList.size] = "zpam301";
	blackList[blackList.size] = "zpam301_beta";
	blackList[blackList.size] = "zpam301_server";
	blackList[blackList.size] = "zpam310_beta";
	blackList[blackList.size] = "zpam310_beta2";
	blackList[blackList.size] = "zpam310_beta3";
	blackList[blackList.size] = "zpam310_beta4";
	blackList[blackList.size] = "zpam310_beta5";
	blackList[blackList.size] = "zpam310_beta6";
	blackList[blackList.size] = "zpam320_test";
	blackList[blackList.size] = "zpam320";
	blackList[blackList.size] = "zpam321";
	blackList[blackList.size] = "mp_toujane_fix_v1";
	blackList[blackList.size] = "zpam322";
	blackList[blackList.size] = "mp_toujane_fix_v2";
	blackList[blackList.size] = "mp_burgundy_fix_v1";
	blackList[blackList.size] = "zpam330";
	blackList[blackList.size] = "zpam_maps_v1";
	blackList[blackList.size] = "zpam331";
	blackList[blackList.size] = "zpam332";
	blackList[blackList.size] = "zpam333_lan";
	blackList[blackList.size] = "zpam333";
	blackList[blackList.size] = "zpam333_test1";
	blackList[blackList.size] = "zpam333_test2";
	blackList[blackList.size] = "zpam_maps_v2";
	blackList[blackList.size] = "zpam_maps_v3";
	blackList[blackList.size] = "zpam_maps_v4_beta1";
	blackList[blackList.size] = "zpam_maps_v4_beta2";
	blackList[blackList.size] = "zpam334_test1";
	blackList[blackList.size] = "zpam334_test2";
	blackList[blackList.size] = "zpam334_beta1";
	blackList[blackList.size] = "zpam334_beta2";
	blackList[blackList.size] = "zpam_maps_v4";
	blackList[blackList.size] = "zpam334";
	blackList[blackList.size] = "zpam_maps_v5";
	blackList[blackList.size] = "zpam335";
	blackList[blackList.size] = "zpam335_test1";
	blackList[blackList.size] = "zpam335_test2";
	blackList[blackList.size] = "zpam336";
	blackList[blackList.size] = "zpam400_test1";
	blackList[blackList.size] = "zpam400_test2";
	blackList[blackList.size] = "zpam400_test3";
	blackList[blackList.size] = "zpam400_test4";
	blackList[blackList.size] = "zpam400_test5";
	blackList[blackList.size] = "zpam400_test6";
	blackList[blackList.size] = "zpam401";

	blackList[blackList.size] = "mp_chelm_fix";
	blackList[blackList.size] = "mp_breakout_tls";
	blackList[blackList.size] = "wawa_3daim_tdm";
	blackList[blackList.size] = "wawa_3daim";
	blackList[blackList.size] = "wawa_3dAim_tdm";
	blackList[blackList.size] = "wawa_3dAim";
	blackList[blackList.size] = "e_vallente";
	blackList[blackList.size] = "mp_vallente";
	blackList[blackList.size] = "mp_railyard_mjr_test1";
	blackList[blackList.size] = "mp_railyard_mjr_test2";
	blackList[blackList.size] = "mp_leningrad_mjr_test1";
	blackList[blackList.size] = "mp_leningrad_mjr_test2";

	// ZPAM_RENAME - add old pam

	for(i = 0; i < blackList.size; i++)
	{
		if (arrayContains(nameArray, blackList[i]))
		{
			file = "main/" + blackList[i] + ".iwd";

			setError(game["STRING_PAM_BLACKLIST"], file);

			level thread printTextInLoop(file);

			return;
		}
	}



	cod2x_blacklist = [];
	cod2x_blacklist[cod2x_blacklist.size] = "1.4.5.1-test.1";
	cod2x_blacklist[cod2x_blacklist.size] = "1.4.5.1-test.2";
	cod2x_blacklist[cod2x_blacklist.size] = "1.4.5.1-test.3";
	cod2x_blacklist[cod2x_blacklist.size] = "1.4.5.1-test.4";
	cod2x_blacklist[cod2x_blacklist.size] = "1.4.5.1-test.5";
	cod2x_blacklist[cod2x_blacklist.size] = "1.4.5.1-test.6";
	cod2x_blacklist[cod2x_blacklist.size] = "1.4.5.1-test.7";
	cod2x_blacklist[cod2x_blacklist.size] = "1.4.5.1-test.8";
	cod2x_blacklist[cod2x_blacklist.size] = "1.4.5.1-test.9";
	cod2x_blacklist[cod2x_blacklist.size] = "1.4.5.1-test.10";
	cod2x_blacklist[cod2x_blacklist.size] = "1.4.5.1-test.11";
	cod2x_blacklist[cod2x_blacklist.size] = "1.4.5.1-test.12";
	cod2x_blacklist[cod2x_blacklist.size] = "1.4.5.1-test.13";

	// ZPAM_RENAME - add incompatible versions

	for(i = 0; i < cod2x_blacklist.size; i++)
	{
		if (tolower(getCvar("shortversion")) == cod2x_blacklist[i])
		{
			setError(game["STRING_PAM_COD2X_BLACKLIST"], cod2x_blacklist[i]);

			level thread printTextInLoop(cod2x_blacklist[i]);

			return;
		}
	}
}


printTextInLoop(line1, line2, line3, line4)
{
	for(;;)
	{
		iprintlnbold(" ");

		if (!isDefined(line4)) 	iprintlnbold(" ");
		if (!isDefined(line3)) 	iprintlnbold(" ");
		if (!isDefined(line2)) 	iprintlnbold(" ");
		if (!isDefined(line1)) 	iprintlnbold(" ");

		if (isDefined(line1)) 	iprintlnbold(line1);
		if (isDefined(line2)) 	iprintlnbold(line2);
		if (isDefined(line3)) 	iprintlnbold(line3);
		if (isDefined(line4)) 	iprintlnbold(line4);

		wait level.fps_multiplier * 5;
	}
}


arrayContains(array, content)
{
	for (i = 0; i < array.size; i++)
	{
		//println("comparing -" + array[i] + "- with -" + content + "-");
		if (tolower(array[i]) == tolower(content))
			return true;
	}
	return false;
}



ChangeTo(mode)
{
	if (!maps\mp\gametypes\_matchinfo::canMapBeChanged())
		return;
			
	// Will disable all comming map-restrat (so pam_mode can be changed correctly)
	level.pam_mode_change = true;

	iprintlnbold("^3zPAM mode changing to ^2" + mode);
	iprintlnbold("^3Please wait...");

	wait level.fps_multiplier * 3;

	// Reset custom cvars
	setCvar("pam_mode_custom", 0);

	map_restart(false); // fast_restart
}




setError(error, console_error)
{
	level.pam_installation_error = true;

	// Is printed only for developer...
	println("^1------------ zPAM Errors -----------");
	println(game["STRING_NOT_INSTALLED_CORRECTLY_1"]);
	println(error);
	if (isDefined(console_error)) {
		println(console_error);
	}
	println("^1------------------------------------");


	bg = newHudElem2();
	bg.horzAlign = "fullscreen";
	bg.vertAlign = "fullscreen";
	bg.alignx = "left";
	bg.aligny = "top";
	bg.alpha = 1;
	bg.sort = -3;
	bg.foreground = true;
	bg setShader("black", 640, 480);

	text1 = newHudElem2();
	text1.alignx = "center";
	text1.aligny = "top";
	text1.x = 320;
	text1.y = 200;
	text1.fontscale = 1.7;
	text1.alpha = 1;
	text1.sort = -2;
	text1.foreground = true;
	text1.color = (1, .5, .5);
	text1 SetText(game["STRING_NOT_INSTALLED_CORRECTLY_1"]);

	text2 = newHudElem2();
	text2.alignx = "center";
	text2.aligny = "top";
	text2.x = 320;
	text2.y = 225;
	text2.fontscale = 1.2;
	text2.alpha = 1;
	text2.sort = -1;
	text2.foreground = true;
	text2.color = (1, .5, .5);
	text2 SetText(error);

	text3 = newHudElem2();
	text3.alignx = "center";
	text3.aligny = "top";
	text3.x = 320;
	text3.y = 295;
	text3.fontscale = 0.8;
	text3.alpha = 1;
	text3.sort = -1;
	text3.foreground = true;
	text3.color = (1, .5, .5);
	text3 SetText(game["STRING_GITHUB_URL_HELP"]);
}
