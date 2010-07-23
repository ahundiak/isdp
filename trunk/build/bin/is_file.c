#include <stdio.h>
#include <stdlib.h>

#include <sys/param.h>
#define SEPARATOR_S	"/"
#define SEPARATOR_C	'/'

#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <limits.h>
#include "toolshash.h"
// #include "exsysdep.h"

static S_HASHTABLE	*FilTbl = 0;

int	is_file (f)
char	*f;
{
	S_HASHRECORD	*p_hrec = 0;
	int		found = 1;
	struct stat 	statbuff;

	if (!FilTbl)
		FilTbl = new_hash_table(511, 0, 0);

	if (!(p_hrec = hash_lookup(FilTbl, f)))
	{

		if (stat(f,&statbuff))
			found = 0;
		else
		{
			char	*name;

			if (NULL == (name = (char *)malloc(strlen(f)+1)))
			{
				fprintf(stderr, "is_file: unable to malloc for %s\n", f);
				exit(1);
			}
			strcpy(name, f);
			hash_add(FilTbl, name);
		}
	}

	return found;
}

char	*find_in_path(filename, path)
char	*filename;
char	*path;
{
	static char	namebuf[MAXPATHLEN];
	if (SEPARATOR_C != filename[0] && path)
	{
		char	*end_path = path + strlen(path);

		while (path < end_path)
		{
			char	*colon;

			if (colon = strchr(path, ':'))
				*colon = 0;

			strcpy(namebuf, path);
			strcat(namebuf, SEPARATOR_S);
			strcat(namebuf, filename);
			if (is_file(namebuf))
			{
				if (colon)
					*colon = ':';
				return &namebuf[0];
			}
			if (colon)
				*colon = ':';
			else
				break;

			path = ++colon; 
		}
		return 0;
	}
	if (is_file(filename))
		return filename;
	else
		return 0;
}
