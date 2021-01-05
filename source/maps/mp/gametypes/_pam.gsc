init()
{
	level.pam_folder = "mods/zpam310_beta6";

	level.pam_mode_change = false;

	if (!isInstalledCorrectly())
	{
		// Is printed only for developer...
		println("^1------------ zPAM Errors -----------");
	    println(game["STRING_NOT_INSTALLED_CORRECTLY_1"]);
	    println(game["STRING_NOT_INSTALLED_CORRECTLY_2"]);
		println(level.fs_game + " != " + level.pam_folder);
	    println("^1------------------------------------");

		// Show error to all
		level showError();
	}
}

isInstalledCorrectly()
{
	// If we are in listening mode, dont show bad installating error
	if (getCvar("dedicated") == "0")
		return true;

	// TODO - eyza 1337 safe
	//if (getCvar("eyza") != "1337")
	//	return false;

	return tolower(level.fs_game) == tolower(level.pam_folder);
}

showError()
{
	bg = NewHudElem();
	bg.horzAlign = "fullscreen";
	bg.vertAlign = "fullscreen";
	bg.alignx = "left";
	bg.aligny = "top";
	bg.alpha = 1;
	bg.sort = -3;
	bg.foreground = true;
	bg setShader("black", 640, 480);

	text1 = NewHudElem();
	text1.alignx = "center";
	text1.aligny = "top";
	text1.x = 320;
	text1.y = 180;
	text1.fontscale = 1.9;
	text1.alpha = 1;
	text1.sort = -2;
	text1.foreground = true;
	text1.color = (1, .5, .5);
	text1 SetText(game["STRING_NOT_INSTALLED_CORRECTLY_1"]);

	text2 = NewHudElem();
	text2.alignx = "center";
	text2.aligny = "top";
	text2.x = 320;
	text2.y = 205;
	text2.fontscale = 1.4;
	text2.alpha = 1;
	text2.sort = -1;
	text2.foreground = true;
	text2.color = (1, .5, .5);
	text2 SetText(game["STRING_NOT_INSTALLED_CORRECTLY_2"]);

	text3 = NewHudElem();
	text3.alignx = "center";
	text3.aligny = "top";
	text3.x = 320;
	text3.y = 235;
	text3.fontscale = 1.2;
	text3.alpha = 1;
	text3.sort = -1;
	text3.foreground = true;
	text3.color = (1, .5, .5);
	text3 SetText(game["STRING_GITHUB_URL_HELP"]);
}

ChangeTo(mode)
{
	// Will disable all comming map-restrat (so pam_mode can be changed correctly)
	level.pam_mode_change = true;

	iprintlnbold("^3zPAM mode changing to ^2" + mode);
	iprintlnbold("^3Please wait...");

	wait level.fps_multiplier * 3;

	map_restart(false); // fast_restart
}
