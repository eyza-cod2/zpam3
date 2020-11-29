#include maps\mp\gametypes\_callbacksetup;

init()
{
  addEventListener("onConnected",         ::onConnected);
  addEventListener("onMenuResponse",  ::onMenuResponse);
}

onConnected()
{
  self endon("disconnect");

  if (!isDefined(self.pers["quicksettings_saved"]))
    self.pers["quicksettings_saved"] = false;

  wait level.fps_multiplier * 1;

  if (!self.pers["quicksettings_saved"])
    self updateClientSettings(); // write defaults
}

/*
Called when command scriptmenuresponse is executed on client side
self is player that called scriptmenuresponse
Return true to indicate that menu response was handled in this function
*/
onMenuResponse(menu, response)
{
	if (menu == game["menu_quicksettings"])
	{
    self parseString(response);
		return true;
	}
}

parseString(string)
{
  // set server16 "openscriptmenu quicksettings autorecording_0|matchinfo_0|teamscore_0|"

  // Settings are formated in format "<item>_<value>|<item2>_<value2>|..."

  if (string.size == 0)
  {
    self updateClientSettings(); // write defaults
    return;
  }

  lastItemPos = 0;
  for (i = 0; i <= string.size; i++)
  {
    if (i == string.size)
      char = "|"; // used for last item
    else
      char = string[i];

    if (char == "|")
    {
      item = ToLower(getsubstr(string, lastItemPos, i)); //<item>_<value>

      if (item == "autorecording")          self maps\mp\gametypes\_record::toggle();
      else if (item == "autorecording_0")   self maps\mp\gametypes\_record::disable();
      else if (item == "autorecording_1")   self maps\mp\gametypes\_record::enable();

      else if (item == "matchinfo")         self maps\mp\gametypes\_matchinfo::ingame_toggle();
      else if (item == "matchinfo_0")       self maps\mp\gametypes\_matchinfo::ingame_disable();
      else if (item == "matchinfo_1")       self maps\mp\gametypes\_matchinfo::ingame_enable();

      lastItemPos = i + 1;
    }
  }

  self updateClientSettings();
}

updateClientSettings()
{
  string = "openscriptmenu quicksettings ";
  delimiter = "|";

  recording = self maps\mp\gametypes\_record::isEnabled();
  matchinfo = self maps\mp\gametypes\_matchinfo::ingame_isEnabled();

  string = string + "autorecording_" + recording;
  string = string + delimiter;
  string = string + "matchinfo_" + matchinfo;

  self setClientCvar("server16", string);

  // Cvars for switching text in quick menu
  self setClientCvar("ui_quicksettings_autorecording", recording);
  self setClientCvar("ui_quicksettings_matchinfo", matchinfo);

  self.pers["quicksettings_saved"] = true;
}
