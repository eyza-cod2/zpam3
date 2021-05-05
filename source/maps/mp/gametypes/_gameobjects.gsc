#include maps\mp\gametypes\global\_global;

main(allowed)
{
	entitytypes = getentarray();
	for(i = 0; i < entitytypes.size; i++)
	{
		if(isdefined(entitytypes[i].script_gameobjectname))
		{
			dodelete = true;

			for(j = 0; j < allowed.size; j++)
			{
				if(entitytypes[i].script_gameobjectname == allowed[j])
				{
					dodelete = false;
					break;
				}
			}

			if(dodelete)
			{
				//println("DELETED: ", entitytypes[i].classname);
				entitytypes[i] delete();
			}
		}
	}
}
