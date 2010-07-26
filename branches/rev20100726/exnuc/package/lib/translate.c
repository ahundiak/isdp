/*
**	translate.c
**	6/26/91
**	Richard Eade
*/

#include <stdio.h>
#include <string.h>
#include "translate.h"

int	translate_build(name, p_rt, p_dp, p_owner, p_group)
/*
**	Converts a build name into the build info:
**		is it runtime or DP ?
**		the owner for files in this build (argument for chown(1))
**		the group for files in this build (argument for chgrp(1))
*/
char	*name;
int	*p_rt;
int	*p_dp;
char	**p_owner;
char	**p_group;
{
	int	i = 0;

	for (i = 0; Build[i].name; ++i)
		if (!strcmp(name, Build[i].name))
		{
			if (p_rt)
				*p_rt = Build[i].rt;
			if (p_dp)
				*p_dp = Build[i].dp;
			if (p_owner)
				*p_owner = Build[i].owner;
			if (p_group)
				*p_group = Build[i].group;

			return 1;
		}

	return 0;
}


int	translate_cpio(name, p_dir)
/*
**	Converts a cpio name into a base directory name.
*/
char	*name;
char	**p_dir;
{
	int	i = 0;

	for (i = 0; Cpio[i].name; ++i)
		if (!strcmp(name, Cpio[i].name))
		{
			if (p_dir)
			{
				if ('$' == Cpio[i].dir[0])
				{
					if (!(*p_dir = (char *)getenv(&Cpio[i].dir[1])))
					{
						fprintf(stderr, "translate_cpio: %s: unable to get env variable value\n", Cpio[i].dir);
						exit(1);
					}
				}
				else
					*p_dir = Cpio[i].dir;
			}

			return 1;
		}

	return 0;
}

int	is_in_build(char *buildName, char *buildString)
/*
*	Scans a string of build names looking for a particular name.
*	The build string is a list of comma separated names.
*/
{
	int	found = 0;
	char	*nextName = 0;

	while (buildString)
	{
		char	*comma = 0;

		if (comma = strchr(buildString, ','))
		{
			nextName = comma + 1;
			*comma = 0;
		}
		else
			nextName = 0;
		
		if (!strcmp(buildName, buildString))
		{
			if (comma)
				*comma = ',';
			found = 1;
			nextName = 0;
		}
		buildString = nextName;
	}

	return found;
}
