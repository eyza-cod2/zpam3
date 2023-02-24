#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onConnected",         ::onConnected);
}

onConnected()
{
	if (!isDefined(self.pers["language_orig"]))
		self.pers["language_orig"] = -1;
	if (!isDefined(self.pers["language_setting"]))
		self.pers["language_setting"] = -1;
	// English by default
	if (!isDefined(self.pers["language"]))
		self.pers["language"] = 0;
}

/*
	// Localization
	execOnDvarStringValue ui_language 0 "openscriptmenu -1 key_0"; // English
	execOnDvarStringValue ui_language 1 "openscriptmenu -1 key_1"; // French
	execOnDvarStringValue ui_language 2 "openscriptmenu -1 key_2"; // German
	execOnDvarStringValue ui_language 6 "openscriptmenu -1 key_6"; // Russian
	execOnDvarStringValue ui_language 7 "openscriptmenu -1 key_7"; // Polish
	execOnDvarStringValue ui_language 14 "openscriptmenu -1 key_14"; // Czech
	execOnDvarStringValue ui_language 15 "openscriptmenu -1 key_15"; // Czech
*/

// Called from OnConnect menu - value of original loc_language cvar
// If known languages are not recognized, -1 is as default
saveOriginalLanguage(lang)
{
	if (lang == "0")		self.pers["language_orig"] = 0;
	else if (lang == "1")		self.pers["language_orig"] = 1;
	else if (lang == "2")		self.pers["language_orig"] = 2;
	else if (lang == "6")		self.pers["language_orig"] = 6;
	else if (lang == "7")		self.pers["language_orig"] = 7;
	else if (lang == "14")		self.pers["language_orig"] = 14;
	else if (lang == "15")		self.pers["language_orig"] = 15;
	else				self.pers["language_orig"] = -1;

	// Parse language
	self iprintln("Original language: " + self.pers["language_orig"]);
}

// Called from quick settings menu
toggle()
{
	if (self.pers["language_setting"] == -1)	select(0);
	else if (self.pers["language_setting"] == 0)	select(1);
	else if (self.pers["language_setting"] == 1)	select(2);
	else if (self.pers["language_setting"] == 2)	select(6);
	else if (self.pers["language_setting"] == 6)	select(7);
	else if (self.pers["language_setting"] == 7)	select(14);
	else if (self.pers["language_setting"] == 14)	select(15);
	else if (self.pers["language_setting"] == 15)	select(-1);
	else						select(-1);
}

// Called from quick settings menu when saved players settings are loaded
select(lang)
{
	// If language is "Automatic", use original language from game
	if (lang == -1)
		lang = self.pers["language_orig"];

	// If original language is unknown, use English
	if (lang == -1)
		lang = 0;

	self.pers["language_setting"] = lang;
	self.pers["language"] = lang;

	self iprintln("Language switched to " + lang);
}

// Called from quick settings menu when current settings is saved
getValue()
{
	return self.pers["language_setting"];
}
