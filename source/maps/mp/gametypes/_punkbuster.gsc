init()
{
	// Ignore pb check if pam is not installed correctly
	if (!maps\mp\gametypes\_pam::isInstalledCorrectly())
		return;

    if (!isDefined(game["pbsv_not_loaded"]))
        game["pbsv_not_loaded"] = false;
    if (!isDefined(game["pbsv_loaded"]))
        game["pbsv_loaded"] = false;


    // At the start of the server reset cvar pam_pbsv_loaded = 0 to make sure it cannot be changed from outside
    if (getTime() == 0)
        setCvar("pam_pbsv_loaded", "0");

    if (getCvar("pam_pbsv_not_loaded") != "" && getCvarInt("pam_pbsv_not_loaded") == 1)
    {
        game["pbsv_loaded"] = false;
        game["pbsv_not_loaded"] = true;

        setCvar("pam_pbsv_loaded", "0");

        printError();
		showError();

        return;
    }


    if (getCvar("pam_pbsv_loaded") != "" && getCvarInt("pam_pbsv_loaded") == 1)
        game["pbsv_loaded"] = true;

    if (getCvarInt("sv_punkbuster") == 0 || game["pbsv_loaded"])
        return;

    level.pbAliveSeed = randomintrange(999, 999999);// Returns a random integer r, where min <= r < max

    setCvar("pam_pbsv_load", "set pam_pbsv_alive " + level.pbAliveSeed);


    thread checkAlive();
}


checkAlive()
{
    wait level.fps_multiplier * 10;


    // Check cvars that can be se
    if ((getCvar("pam_pbsv_loaded") != "" && getCvarInt("pam_pbsv_loaded") == 1) ||
        getCvarInt("pam_pbsv_alive") != level.pbAliveSeed)
    {
        game["pbsv_not_loaded"] = true;

        printError();
		showError();

        setCvar("pam_pbsv_loaded", "0");
        setCvar("pam_pbsv_not_loaded", "1");
    }
    else
    {
        game["pbsv_loaded"] = true;

        setCvar("pam_pbsv_loaded", "1");
    }
}


printError()
{
	// Is printed only for developer...
    println("^1------------ zPAM Errors -----------");
    println(game["STRING_NOT_INSTALLED_CORRECTLY_1"]);
    println(game["STRING_PBSV_NOT_LOADED_ERROR_2"]);
    println("^1------------------------------------");
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
	text2 SetText(game["STRING_PBSV_NOT_LOADED_ERROR_1"]);

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
