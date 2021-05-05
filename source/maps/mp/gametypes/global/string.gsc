// String starts with substring
startsWith(string, substring)
{
	for (i = 0; i < string.size && i < substring.size; i++)
	{
		if (string[i] != substring[i])
		{
			return false;
		}
	}
	return true;
}

// If string contain just numbers, return true
// If string starts with dash and number, like -1337, true is returned
isDigitalNumber(string)
{
	for (i = 0; i < string.size; i++)
	{
		char = string[i];
		charNext = "";
		if ((i+1) < string.size)
			char = string[i+1];

		if (isDigit(char)  ||  (i == 0 && char == "-" && isDigit(charNext)))
			continue;

		return false;
	}

	return true;
}

isDigit(char)
{
	if (char == "0" ||
	    char == "1" ||
	    char == "2" ||
	    char == "3" ||
	    char == "4" ||
	    char == "5" ||
	    char == "6" ||
	    char == "7" ||
	    char == "8" ||
	    char == "9")
	{
		return true;
	}
	return false;
}

// Return array with separated items
splitString(string, delimiter)
{
	array = [];
	buffer = "";
	for (i = 0; i <= string.size; i++)
	{
		char = delimiter;
		if (i < string.size)
			char = string[i];

		if (char == delimiter)
		{
			if (buffer != "")
			{
				array[array.size] = buffer;
				buffer = "";
			}
		}
		else
			buffer += char;
	}
	return array;
}

// Remove ^1 colors from string
// may be like: "ahoj^1kokos^^33pica^^^777neco__^nic^^kokos"
// clean:      	"ahojkokospica^7neco__^nic^^kokos"
removeColorsFromString(string)
{
	clean = "";

	ignoreNumber = 0;
	for (j = 0; j < string.size; j++)
	{
	    char = string[j];

	    if (ignoreNumber > 0 && (char == "0" || char == "1" || char == "2" || char == "3" || char == "4" || char == "5" || char == "6" || char == "7" || char == "8" || char == "9"))
	    {
		ignoreNumber--;

	    } else if (char == "^" && ignoreNumber < 2)
	    {
		ignoreNumber++;
	    }
	    else
	    {
		clean += char;
	    }
	}

	return clean;
}

// Prints second in format 00:00:00 (hours are printed only if > 0)
formatTime(timeSec)
{
	timeSec = int(timeSec); // to avoid unmatching types 'float' and 'int'
	str = "";
	min = int(timeSec / 60);
	hour = int(min / 60);
	sec = timeSec % 60;
	if (hour > 0)
	{
		if (hour < 10) hour = "0" + hour;
		min = min % 60;
		str += hour + ":";
	}
	if (min < 10) min = "0" + min;
	if (sec < 10) sec = "0" + sec;

	str += min + ":";
	str += sec;

	return str;
}
