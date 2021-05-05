// This is called in main function of gametype script
// Also called after map_restart (rounds, ...)
Init()
{
	if (game["firstInit"])
	{
		game["ruleCvars"] = [];
		game["cvars"] = [];
		game["cvarnames"] = [];
	}

	// Register importat cvars that needs to be loded first
	level.mapname = getCvar("mapname");
	level.gametype = getCvar("g_gametype");
	level.fs_game = getCvar("fs_game");
	level.dedicated = getCvarInt("dedicated");
	level.maxclients = getCvarInt("sv_maxclients");


	maps\mp\gametypes\global\_global::addEventListener("onStartGameType", ::onStartGameType);
}



// Called after the <gametype>.gsc::main() and <map>.gsc::main() scripts are called
// At this point game specific variables are defined (like game["allies"], game["axis"], game["american_soldiertype"], ...)
// Called again for every round in round-based gameplay
onStartGameType()
{
	// Monitor cvar changes
    	thread monitorCvarChanges();
}


// Registers cvar and monitor them.
// Value is not loaded into level. variable
registerCvar(cvar, type, defaultValue, minValue, maxValue)
{
	registerCvarEx("", cvar, type, defaultValue, minValue, maxValue);
}

// Register cvar into cvars array.
// minValue and maxValue may be undefined.
// type may be INT, FLOAT, BOOL or STRING
// If type is STRING, minValue means array of allowed strings.

// Meaning of first parameter:
// "" = empty - warning is showed if this cvar is changed and on map change this value is restored to default value defined by rules
// "C" = customizable cvars via option pam_mode_custom - When map change, value of this variable is not reseted to default value defined by rules
// "I" = important cvar - cvar value is not reset to default value and if is changed no warning message is showed in readyup
registerCvarEx(method, cvar, type, defaultValue, minValue, maxValue)
{
	cvar = toLower(cvar);

	//println("Registering cvar " + cvar);


	// Check if this cvar is registered for multiple times
	/#
	if (!isDefined(level.cvars_check))
		level.cvars_check = [];
	if (!isDefined(level.cvars_check[cvar]))
		level.cvars_check[cvar] = true;
	else
	{
		assertMsg("Multiple registration of cvar " + cvar + ".");
	}
	#/


	setValue = false;


	// If cvar is not defined yet, register
	if (!isDefined(game["cvars"][cvar]))
	{
		game["cvars"][cvar] = []; // create array
		game["cvarnames"][game["cvarnames"].size] = cvar;

		if (type == "BOOL")
		{
			minValue = 0;
			maxValue = 1;
		}

		// If this cvar is defined by rules, change default value
		if (isDefined(game["ruleCvars"]) && isDefined(game["ruleCvars"][cvar]))
		{
			defaultValue = game["ruleCvars"][cvar];
		}

		// Update cvar info array
		game["cvars"][cvar]["name"] = cvar;
		game["cvars"][cvar]["type"] = type;
		game["cvars"][cvar]["method"] = method; // R, I, "" (read-only, important, default)
		game["cvars"][cvar]["defaultValue"] = defaultValue;
		game["cvars"][cvar]["minValue"] = minValue;  // may be undefined
		game["cvars"][cvar]["maxValue"] = maxValue;  // may be undefined
		game["cvars"][cvar]["value"] = getValueByType(cvar, type, defaultValue);         // Get value from original function according to cvar type

		if (game["cvars"][cvar]["value"] != defaultValue)
			setValue = true;
	}
	else
   	{
		// If default value of rule cvars change (used for overtimes), set flag to set cvar to specified value
		if (isDefined(game["ruleCvars"]) && isDefined(game["ruleCvars"][cvar]))
		{
			if (game["ruleCvars"][cvar] != game["cvars"][cvar]["defaultValue"])
			{
				defaultValue = game["ruleCvars"][cvar];
				game["cvars"][cvar]["defaultValue"] = defaultValue;
				setValue = true;
			}
		}
	}



	// Set cvar to default value on registration or if default value changed
	// Ignore this for cvars pam_mode and pam_mode_custom
	if (setValue && isDefined(level.pam_mode) && isDefined(level.pam_mode_custom))
	{
		for(;;)
		{
			// Dont do this for public, since cvar values are defined in config file and we dont want to override them
			if (game["is_public_mode"])
				break;

			// If cvar is important, dont change value
			if (method == "I")
				break;

			// If custom rules are enabled and this cvar is marked as customizable, dont change
			if (level.pam_mode_custom && method == "C")
				break;

			// Change value
			setCvar(cvar, defaultValue);

			game["cvars"][cvar]["value"] = defaultValue;

			//println("Value of cvar " + cvar + " was set to " + defaultValue + " by rules");

			break;
		}
	}


	// Check if cvar value is in defined range and if cvar is defined - if not, set default value
	isOutsideLimit = limitCvar(game["cvars"][cvar], true); // true means that this is register time, no printing

	// if value was outside limit, limitCvar() set limited value - so update value also in array
	if (isOutsideLimit)
		game["cvars"][cvar]["value"] = getValueByType(cvar, type, defaultValue);

	// Nofity change to all subscribed events
	maps\mp\gametypes\global\events::notifyCvarChange(cvar, game["cvars"][cvar]["value"], true);
}



// Reset customisable cvars to value defined by rules
SetDefaultsForCustomisableCvars()
{
	for(i = 0; i < game["cvarnames"].size; i++)
	{
		cvar = game["cvars"][game["cvarnames"][i]]; // array

		if (cvar["method"] == "C")
		{
			setCvar(cvar["name"], cvar["defaultValue"]);
		}

	}
}


// Will set cvar value withou detecting that it was changed
changeCvarQuiet(cvarName, value)
{
	cvarName = toLower(cvarName);
	game["cvars"][cvarName]["value"] = value;
	setCvar(cvarName, value);
}

// Use to change cvar value and do not emmit onCvarChange
// If cvar is changed by user while in quiet mode, quiet mode is canceled
setCvarQuiet(cvarName, value)
{
	cvarName = toLower(cvarName);

	game["cvars"][cvarName]["inQuiet"] = true;
	game["cvars"][cvarName]["valueBeforeQuiet"] = game["cvars"][cvarName]["value"];
	game["cvars"][cvarName]["value"] = value;

	// Nofity change to all subscribed events
	maps\mp\gametypes\global\events::notifyCvarChange(cvarName, game["cvars"][cvarName]["value"], false);

	setCvar(cvarName, value);

	//println("Quiet mode for cvar " + cvarName + " was SET");
}

restoreCvarQuiet(cvarName)
{
	cvarName = toLower(cvarName);

	// Check if we are still in quiet mode - quiet may be canceled if cvar value is changed by user
	if (isDefined(game["cvars"][cvarName]["inQuiet"]))
	{
		game["cvars"][cvarName]["inQuiet"] = undefined;

		game["cvars"][cvarName]["value"] = game["cvars"][cvarName]["valueBeforeQuiet"];
		setCvar(cvarName, game["cvars"][cvarName]["value"]);

		game["cvars"][cvarName]["valueBeforeQuiet"] = undefined;

		// Nofity change to all subscribed events
		maps\mp\gametypes\global\events::notifyCvarChange(cvarName, game["cvars"][cvarName]["value"], false);

		//println("Quiet mode for cvar " + cvarName + " was canceled");
	}
}

cancelCvarQuiet(cvarName)
{
	cvarName = toLower(cvarName);

	game["cvars"][cvarName]["inQuiet"] = undefined;
	game["cvars"][cvarName]["valueBeforeQuiet"] = undefined;

	//println("Quiet mode for cvar " + cvarName + " was canceled");
}




// Return original cvar value accoring to cvar type (INT, BOOL, FLOAT, STRING)
getValueByType(name, type, defaultValue)
{
	// If cvar value is empty (and isnt string)
	if(type != "STRING" && getCvar(name) == "")
	{
		// This cvar is propably not defined, return default value
		return defaultValue;
	}

	if (type == "INT")		return getCvarInt(name);
	else if (type == "BOOL")	return getCvarInt(name);
	else if (type == "FLOAT")	return getCvarFloat(name);
	else if (type == "STRING")	return getCvar(name);
	else assertMsg("Cvar type " + type + " is unknown");
}


// Set cvar only if changed (this will avoid line writed to log)
setCvarIfChanged(cvar, value)
{
	// Convert value to string (to avoid wierd unmatching variable types errors)
	valueStr = value + "";

	// If value changed from last
	if (valueStr != getCvar(cvar))
	{
		setCvar(cvar, valueStr);
	}
}


setClientCvar2(cvar, value, aaa, bbb, ccc)
{
/*
	if (cvar == "cg_objectiveText")
      		println("### " + getTime() + " ### " + self.name + " ### " + cvar + " = " + "...localized string...");
        else
      		println("### " + getTime() + " ### " + self.name + " ### " + cvar + " = \"" + value + "\"");
*/
	/#
	/*
	self thread countCvarsInSingleFrame();


        if (!isDefined(self.pers["aaa"]))
        {
	      	self.pers["aaa"] = [];
	      	self.pers["sended_cvars"] = 0;
        }

        if (!isDefined(self.pers["aaa"][cvar]))
        {
	      	self.pers["aaa"][cvar] = 1;
	      	self.pers["sended_cvars"]++;

	      	//println("### new cvars:" + self.pers["sended_cvars"] + "  " + cvar);
        }
	*/
	#/

        self setClientCvar(cvar, value);
}

countCvarsInSingleFrame()
{
	self endon("disconnect");

	if (!isDefined(self.cvars2_count))
		self.cvars2_count = 0;
	else
		self.cvars2_count++;

	self notify("cvar2_count_end");
	self endon("cvar2_count_end");

	wait level.frame;

	if (self.cvars2_count > 20)
		println(self.name + ": sended cvars in frame " + gettime() + ": " + self.cvars2_count + " (defined cvars: "+self.pers["sended_cvars"]+")");

	self.cvars2_count = 0;
}

// This function will remember the last value sended to client, so if the same value is used, nothing will be send to client
setClientCvarIfChanged(cvar, value)
{
	if (!isDefined(value)) // just safety
	{
		value = "";
		/#
		assertmsg("setClientCvarIfChanged() setting undefined value for cvar " + cvar);
		#/
	}

	// Convert value to string (to avoid wierd unmatching variable types errors)
	valueStr = value + "";

	// Convert to lower to match same cvars
	cvar = toLower(cvar);

	// If value changed from last
	if (!isDefined(self.pers["cvar_" + cvar]) || valueStr != self.pers["cvar_" + cvar])
	{
		self setClientCvar2(cvar, valueStr);
	}

	self.pers["cvar_" + cvar] = valueStr;
}


//Checks if cvar is in min and max limit and return true if value is not valid
limitCvar(cvar, registerTime)
{
	// This guarantees that STRING type cvar is defined
	if (registerTime && getCvar(cvar["name"]) == "" && cvar["type"] == "STRING")
		setCvar(cvar["name"], cvar["defaultValue"]);

	// If cvar is empty set default value
	if(getCvar(cvar["name"]) == "" && cvar["type"] != "STRING")
	{
		setCvar(cvar["name"], cvar["defaultValue"]);
		if (!registerTime)
			iprintln("^3DVAR change detected: ^2" + cvar["name"] + " ^3 was not defined");
		return false;
	}
	else if (cvar["type"] == "INT" || cvar["type"] == "FLOAT" || cvar["type"] == "BOOL") // string does not have min - max value
	{
		value_now = getValueByType(cvar["name"], cvar["type"], cvar["defaultValue"]);

		// Bigger than max value
		if(isDefined(cvar["maxValue"]) && value_now > cvar["maxValue"])
		{
			if (value_now != cvar["value"])
				setCvar(cvar["name"], cvar["value"]); // set value before
			else
				setCvar(cvar["name"], cvar["maxValue"]); // value before is same as before (register time)

			if (!registerTime) {
				iprintln("^3DVAR change detected: ^2" + value_now + "^3 is not a valid value for dvar ^2" + cvar["name"]);
				iprintln("^3DVAR change detected: Domain is a value from ^2"+cvar["minValue"]+"^3 to ^2"+cvar["maxValue"]);
			} else {
				println("Cvar " + cvar["name"] + " has value '"+value_now+"' outside limit.");
				println("Domain is a value from ^2"+cvar["minValue"]+"^3 to ^2"+cvar["maxValue"]);
			}
			return true;

		// Lower then min value
		} else if(isDefined(cvar["minValue"]) && value_now < cvar["minValue"]) {
			if (value_now != cvar["value"])
				setCvar(cvar["name"], cvar["value"]); // set value before
			else
				setCvar(cvar["name"], cvar["minValue"]); // value before is same as before (register time)

			if (!registerTime) {
				iprintln("^3DVAR change detected: ^2" + value_now + "^3 is not a valid value for dvar ^2" + cvar["name"]);
				iprintln("^3DVAR change detected: Domain is a value from ^2"+cvar["minValue"]+"^3 to ^2"+cvar["maxValue"]);
			} else {
				println("Cvar " + cvar["name"] + " has value '"+value_now+"' outside limit.");
				println("Domain is a value from ^2"+cvar["minValue"]+"^3 to ^2"+cvar["maxValue"]);
			}
			return true;
		}
	}
	else if (cvar["type"] == "STRING" && isDefined(cvar["minValue"]) && !isString(cvar["minValue"]) && cvar["minValue"].size != 0) // cvar["minValue"] is array of alloved strings
	{
		value_now = getValueByType(cvar["name"], cvar["type"], cvar["defaultValue"]);

		allowedStrings = cvar["minValue"];
		isValid = false;
		for (i=0; i < allowedStrings.size ; i++ )
		{
			if (value_now == allowedStrings[i])
			{
				isValid = true;
				break;
			}
		}

		if (!isValid)
		{
			stringToPrint = "";
			for (i=0; i < allowedStrings.size; i++)
			{
				if (i != 0)
				stringToPrint += ", ";
				stringToPrint += allowedStrings[i];
			}

			// Print not valid warning
			if (!registerTime)
			{
				iprintln("^3DVAR change detected: ^2" + value_now + "^3 is not a valid value for dvar ^2" + cvar["name"]);
				iprintln("^3Following values are valid:");
				iprintln("^3" + stringToPrint);
			} else {
				println("Cvar " + cvar["name"] + " has invalid value '"+value_now+"'. Valid values: " + stringToPrint + ". Using " + cvar["defaultValue"] + ".");
			}

			// Check also is value before is valid
			for (i=0; i < allowedStrings.size ; i++ )
			{
				if (cvar["value"] == allowedStrings[i])
				{
					isValid = true;
					break;
				}
			}

			if (!isValid)
	                    setCvar(cvar["name"], cvar["defaultValue"]); // set default value
	                else
	                    setCvar(cvar["name"], cvar["value"]); // set value before

			return true;
		}
	}

	return false;
}


monitorCvarChanges()
{
	wait level.fps_multiplier * 0.31337;

	for (;;)
	{
		j = 0;
		for(i = 0; i < game["cvarnames"].size; i++)
		{
			cvar = game["cvars"][game["cvarnames"][i]]; // array

			value_last = cvar["value"];
			value_now = getValueByType(cvar["name"], cvar["type"], cvar["defaultValue"]);

			// Value changed
			if (value_last != value_now)
			{
				// Check if new value is in cvar limit, if is outside limit - restore value before
				isOutsideLimit = limitCvar(cvar, false);

				// Update only if value vas changed to correct value
				if (!isOutsideLimit)
				{
					// Dont print cvar changed if it is in quiet mode (changed by script - exmp: g_speed in stratime,...)
					if (!isDefined(cvar["inQuiet"]))
						iprintln("^3Server cvar ^2" + cvar["name"] + "^3 changed from ^2" + cvar["value"] + "^3 to ^2" + value_now);

					// Update value in global struct definition
					game["cvars"][game["cvarnames"][i]]["value"] = value_now;

					// Nofity change to all subscribed events
					maps\mp\gametypes\global\events::notifyCvarChange(cvar["name"], value_now, false);
				}
			}

			// Split checking into multiple frames to avoid overhead
			j++;
			if (j > 8)
			{
				wait level.frame;
				j = 0;
			}

		}
	}
}

isCvarChangedFromRuleValue(cvarName)
{
	cvarName = toLower(cvarName);

	cvar = game["cvars"][cvarName]; // array

	// If cvar changed + isnt in quiet mode
	if (cvar["value"] != cvar["defaultValue"] && !isDefined(cvar["inQuiet"]))
		return true;
	return false;
}

getChangedCvarsString()
{
	arr = [];

	for(i = 0; i < game["cvarnames"].size; i++)
	{
		cvar = game["cvars"][game["cvarnames"][i]]; // array

		// Dont show warning for important cvar
		if (cvar["method"] == "I")
			continue;

		// If cvar changed + isnt in quiet mode
		if (cvar["value"] != cvar["defaultValue"] && !isDefined(cvar["inQuiet"]))
		{
			arr[arr.size] = cvar["name"];
		}
	}
	return arr;
}

// Used in readyup to check if some cvar is changed from original rules values
cvarsChangedFromRulesValues()
{
	someCvarChanged = false;

	for(i = 0; i < game["cvarnames"].size; i++)
	{
		cvar = game["cvars"][game["cvarnames"][i]]; // array

		// Dont show warning for important cvar
		if (cvar["method"] == "I")
			continue;

		// If cvar changed + isnt in quiet mode
		if (cvar["value"] != cvar["defaultValue"] && !isDefined(cvar["inQuiet"]))
		{
			/#
			//println("Not equal to rules: " + cvar["name"] + ", value="+cvar["value"] +", defValue="+ cvar["defaultValue"]);
			#/

			someCvarChanged = true;
			break;
		}
	}
	return someCvarChanged;
}
