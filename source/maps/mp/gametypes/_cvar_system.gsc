#include maps\mp\gametypes\_callbacksetup;

// Add cvar that is already defined via game engine (like sv_fps, g_speed, ...)
// Cvars are monitored - so add only cvars which affects gameplay
addServerCvar(cvar, type, defaultValue, minValue, maxValue)
{
    addCvar("S", cvar, type, defaultValue, minValue, maxValue);
}

// Add new cvar that is used in script (like scr_killcam, scr_sd_rounds, ...)
// Cvars are monitored - so if cvar changed value onCvarChange is called
addScriptCvar(cvar, type, defaultValue, minValue, maxValue)
{
    addCvar("", cvar, type, defaultValue, minValue, maxValue);
}

// Add cvar that is important in this script system (value must be loaded into level. variable imiedetly)
// Cvar is checked if is in limit and onCvarChange is called
addImportantCvar(method, cvar, type, defaultValue, minValue, maxValue)
{
    addCvar(method, cvar, type, defaultValue, minValue, maxValue);

    // Load actual value to array
	game["cvars"][cvar]["value"] = getValueByType(cvar, type, defaultValue);         // Get value from original function according to cvar type

    // Set default, min and max value and return status
    isOutsideLimit = limitCvar(game["cvars"][cvar]);

    // if value was outside limit, limitCvar() set limited value - so update value also in array
    if (isOutsideLimit) {
        game["cvars"][cvar]["value"] = getValueByType(cvar, type, defaultValue);
    }

    // Update level. variable
	maps\mp\gametypes\_cvars::onCvarChange(cvar, game["cvars"][cvar]["value"], true); // true means that this is register time

}


// Register cvar into cvars array.
// minValue and maxValue may be undefined.
// type may be INT, FLOAT, BOOL or STRING
// If type is STRING, minValue means array of allowed strings.
addCvar(method, cvar, type, defaultValue, minValue, maxValue)
{
	if (isDefined(game["cvars"][cvar]))
		assertMsg("Cvar " + game["cvars"][cvar]["name"] + " already defined");

	if (type == "BOOL")
	{
		minValue = 0;
		maxValue = 1;
	}

    // Cvar info array
	cvarArray = []; // create array
	cvarArray["name"] = cvar;
	cvarArray["type"] = type;
    cvarArray["method"] = method; // S, R, "" (server, read-only, default)
	cvarArray["defaultValue"] = defaultValue;
	cvarArray["minValue"] = minValue;  // may be undefined
	cvarArray["maxValue"] = maxValue;  // may be undefined

    // Register cvar to global array
	game["cvarnames"][game["cvarnames"].size] = cvar;
	game["cvars"][cvar] = cvarArray;
}

// Use to change cvar value and do not emmit onCvarChange
// If cvar is changed by user while in quiet mode, quiet mode is canceled
setCvarQuiet(cvarName, value)
{
    // Make sure we are not in checking thread
    if (isDefined(level.in_checkingCvarChanges))
        assertMsg("InCheckingChanges");

    game["cvars"][cvarName]["inQuiet"] = true;
    game["cvars"][cvarName]["valueBeforeQuiet"] = game["cvars"][cvarName]["value"];
    game["cvars"][cvarName]["value"] = value;

    setCvar(cvarName, value);
}

restoreCvarQuiet(cvarName)
{
    // Make sure we are not in checking thread
	/#
    while (isDefined(level.in_checkingCvarChanges))
    {
        assertMsg("InCheckingChanges");
    }
	#/

    // Check if we are still in quiet mode - quiet may be canceled if cvar value is changed by user
    if (isDefined(game["cvars"][cvarName]["inQuiet"]))
    {
        game["cvars"][cvarName]["inQuiet"] = undefined;

        game["cvars"][cvarName]["value"] = game["cvars"][cvarName]["valueBeforeQuiet"];
        setCvar(cvarName, game["cvars"][cvarName]["value"]);

        game["cvars"][cvarName]["valueBeforeQuiet"] = undefined;
    }
}

cancelCvarQuiet(cvarName)
{
    game["cvars"][cvarName]["inQuiet"] = undefined;
    game["cvars"][cvarName]["valueBeforeQuiet"] = undefined;
}


resetServerCvars()
{
    for(i = 0; i < game["cvarnames"].size; i++)
	{
		cvar_name = game["cvarnames"][i];
		cvar = game["cvars"][cvar_name]; // array

		if (cvar["method"] == "S") // server cvar
            setCvar(cvar["name"], cvar["defaultValue"]);
	}
}

resetScriptCvars()
{
    for(i = 0; i < game["cvarnames"].size; i++)
	{
		cvar_name = game["cvarnames"][i];
		cvar = game["cvars"][cvar_name]; // array

		if (cvar["method"] == "") // script (default) cvar
            setCvar(cvar["name"], cvar["defaultValue"]);

        // "I" means cvar is important cvar - value was already loaded
        else if (cvar["method"] == "I")
            game["cvars"][cvar_name]["method"] = "";
	}
}

// Call this function after pam_mode rules file is loaded
saveRuleValues()
{
	for(i = 0; i < game["cvarnames"].size; i++)
	{
		cvar_name = game["cvarnames"][i];
		cvar = game["cvars"][cvar_name]; // array

		value_now = getValueByType(cvar["name"], cvar["type"], cvar["defaultValue"]);

		game["cvars"][cvar_name]["ruleValue"] = value_now;
	}
}

// Cvars has to be loaded after every call of start_gametype (round restart...)
loadCvars()
{
	for(i = 0; i < game["cvarnames"].size; i++)
	{
		cvar_name = game["cvarnames"][i];
		cvar = game["cvars"][cvar_name]; // array

        game["cvars"][cvar_name]["value"] = getValueByType(cvar["name"], cvar["type"], cvar["defaultValue"]);         // Get value from original function according to cvar type

        //println("Cvar: " + cvar_name + " = " + game["cvars"][cvar_name]["value"]);

        // Set default, min and max value and return status
        isOutsideLimit = limitCvar(game["cvars"][cvar_name]);

        if (isOutsideLimit) { // if value was outside limit, limitCvar() set limited value - so update value also in array
            game["cvars"][cvar_name]["value"] = getValueByType(cvar["name"], cvar["type"], cvar["defaultValue"]);
        }

		maps\mp\gametypes\_cvars::onCvarChange(cvar_name, game["cvars"][cvar_name]["value"], true); // load values into level. variables
	}
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

	if (type == "INT")			return getCvarInt(name);
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


// This function will remember the last value sended to client, so if the same value is used, nothing will be send to client
setClientCvarIfChanged(cvar, value)
{
	if (!isDefined(value)) // just safety
		value = "";

	// Convert value to string (to avoid wierd unmatching variable types errors)
	valueStr = value + "";

	// If value changed from last
	if (!isDefined(self.pers["cvar_" + cvar]) || valueStr != self.pers["cvar_" + cvar])
	{
		self setClientCvar(cvar, valueStr);
	}

	self.pers["cvar_" + cvar] = valueStr;
}


//Checks if cvar is in min and max limit and return true if value is not valid
limitCvar(cvar)
{
    print = true;

    // This guarantees that STRING type cvar is defied
    if (getCvar(cvar["name"]) == "" && cvar["type"] == "STRING")
        setCvar(cvar["name"], cvar["defaultValue"]);

	// Set default value
	if(getCvar(cvar["name"]) == "" && cvar["type"] != "STRING")
	{
		setCvar(cvar["name"], cvar["defaultValue"]);
		if (print) {
			//iprintln("^3DVAR change detected: ^2" + cvar["name"] + " ^3 was not defined");
		}
        return false;
	}
	else if (cvar["type"] == "INT" || cvar["type"] == "FLOAT" || cvar["type"] == "BOOL") // string does not have min - max value
	{
		value_now = getValueByType(cvar["name"], cvar["type"], cvar["defaultValue"]);

		// Set max value
		if(isDefined(cvar["maxValue"]) && value_now > cvar["maxValue"]) {
            if (value_now != cvar["value"])
                setCvar(cvar["name"], cvar["value"]); // set value before
            else
                setCvar(cvar["name"], cvar["maxValue"]); // value before is same as before (register time)

            if (print) {
				iprintln("^3DVAR change detected: ^2" + value_now + "^3 is not a valid value for dvar ^2" + cvar["name"]);
				iprintln("^3DVAR change detected: Domain is a value from ^2"+cvar["minValue"]+"^3 to ^2"+cvar["maxValue"]);
			}
            return true;

		// Set min value
		} else if(isDefined(cvar["minValue"]) && value_now < cvar["minValue"]) {
            if (value_now != cvar["value"])
                setCvar(cvar["name"], cvar["value"]); // set value before
            else
                setCvar(cvar["name"], cvar["minValue"]); // value before is same as before (register time)

			if (print) {
				iprintln("^3DVAR change detected: ^2" + value_now + "^3 is not a valid value for dvar ^2" + cvar["name"]);
				iprintln("^3DVAR change detected: Domain is a value from ^2"+cvar["minValue"]+"^3 to ^2"+cvar["maxValue"]);
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

        if (!isValid && print) {
            iprintln("^3DVAR change detected: ^2" + value_now + "^3 is not a valid value for dvar ^2" + cvar["name"]);
            iprintln("^3Following values are valid:");
            stringToPrint = "^3";
            for (i=0; i < allowedStrings.size; i++)
        	{
                if (i != 0)
                    stringToPrint += ", ";
        		stringToPrint += allowedStrings[i];
        	}
            iprintln(stringToPrint);
        }

        if (!isValid)
        {
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

// Called in start_gametype
monitorCvarChanges()
{
	for (;;)
	{
        // Used in setCvarQuiet() to make sure script is not checking cvar changes
        level.in_checkingCvarChanges = undefined;

		wait level.fps_multiplier * 1;

        level.in_checkingCvarChanges = true;

		for(i = 0; i < game["cvarnames"].size; i++)
		{
			cvar = game["cvars"][game["cvarnames"][i]]; // array

			value_last = cvar["value"];
			value_now = getValueByType(cvar["name"], cvar["type"], cvar["defaultValue"]);

			// Value changed
			if (value_last != value_now)
			{
                // Dont print cvar changed if it is in quiet mode (changed by script - exmp: g_speed in stratime,...)
                if (isDefined(cvar["inQuiet"]))
                    cancelCvarQuiet(cvar["name"]);

				// Check if new value is in cvar limit, if is outside limit - restore value before
                isOutsideLimit = limitCvar(cvar);

                // Update only if value vas changed to correct value
                if (!isOutsideLimit)
                {
    				iprintln("^3Server cvar ^2" + cvar["name"] + "^3 changed from ^2" + cvar["value"] + "^3 to ^2" + value_now);

    				// Update script variable assigned to this cvar
    				maps\mp\gametypes\_cvars::onCvarChange(cvar["name"], value_now, false);

    				// Update value in global struct definition
    				game["cvars"][game["cvarnames"][i]]["value"] = value_now;
                }
			}
		}
	}
}

// Used in readyup to check if some cvar is changed from original rules values
cvarsChangedFromRulesValues()
{
    someCvarChanged = false;

	for(i = 0; i < game["cvarnames"].size; i++)
	{
		cvar = game["cvars"][game["cvarnames"][i]]; // array

        // If cvar changed + isnt in quiet mode + is server or script type
		if (cvar["value"] != cvar["ruleValue"] && !isDefined(cvar["inQuiet"]) && (cvar["method"] == "S" || cvar["method"] == ""))
		{
            someCvarChanged = true;
            break;
        }
	}
    return someCvarChanged;
}
