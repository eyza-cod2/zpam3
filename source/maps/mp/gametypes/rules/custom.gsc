#include maps\mp\gametypes\global\_global;

Load()
{
	game["ruleCvars"] = GetCvars(game["ruleCvars"]);

}

GetCvars(arr)
{
	// This function is intended to be replaced via custom iwd file
	customArray = maps\mp\gametypes\_custom_rules::LoadCvars();

	for (i = 0; i < customArray.size; i++) {
		if (customArray[i].warning == false) {
			arr = ruleCvarDefault(arr, customArray[i].cvar, customArray[i].value);
		}
	}

	if (game["firstInit"])
		level thread SetCvarsWithWarning(customArray);

	return arr;
}

SetCvarsWithWarning(customArray)
{
	// Wait till default rule cvar values are saved
	waittillframeend;

	for (i = 0; i < customArray.size; i++) {
		if (customArray[i].warning) {
			setCvar(customArray[i].cvar, customArray[i].value);
		}
	}
}

// This function is called from external file
AddCustomCvar(customArray, cvar, value, warning) {
	if (!isDefined(customArray))
		customArray = [];
	i = customArray.size;
	customArray[i] = spawnstruct();
	customArray[i].cvar = cvar;
	customArray[i].value = value;
	customArray[i].warning = warning;
	return customArray;
}


