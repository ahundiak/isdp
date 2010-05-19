#include <stdlib.h>
#include <string.h>

char	*envtok(char *envName, char *separator)
{
 	char	*envValue = 0;

	if (envName)
	{
		/*
		*	This is an initial invocation of the routine.  We
		*	need to lookup the env variable.  Subsequent calls
		*	will have a NULL name.
		*/
 
		envValue = getenv(envName);
	}
/*Fix for crash, when the variable is not set in the environment - KK */	
	if (envValue)
    	    return strtok(envValue, separator);
    	else
    	    return NULL;
}

struct dir
{
	char		*path;
	struct dir	*next;
};

static struct dir	*addToDirList(char *path, struct dir *list)
{
	if (!list)
	{
		if (list = malloc(sizeof(*list)))
		{
			list->path = _strdup(path);
			list->next = NULL;
		}
	}
	else
	{
		/*  Find list end. */
		struct dir	*last = 0;

		for (last = list; last->next; )
			last = last->next;

		/*  Add new entry. */
		if (last->next = malloc(sizeof(*list)))
		{
			last->next->path = _strdup(path);
			last->next->next = NULL;
		}
	}
	return list;
}

char	*getNextEnvIncludeDir(void)
{
	static struct dir	*list = NULL;
	static struct dir	*next = NULL;
	char			*path = NULL;
	
	if (!list)
	{
		/*
		*	Read include environment variable and build
		*	a list of all the include paths.
		*/

		char	*dir = 0;
		
		if (dir = envtok("Include", ";"))
			while (dir)
			{
				/*
				*	Check for empty dir name (multiple
				*	semicolons in the path).
				*/
				
				while (dir && !strlen(dir))
					dir = envtok(0, ";");

				if (dir)
				{
					if (!(list = addToDirList(dir, list)))
						return NULL;
					dir = envtok(0, ";");
				}
			}

		/*
		*	The dir list may be empty.
		*/
		
		path = list ? list->path : NULL;
		next = list ? list->next : NULL;
	}
	else
	{
		if (!next)
		{
			path = NULL;
			next = list;
		}
		else
		{
			path = next->path;
			next = next->next;
		}
	}
	
	return path;
}
		
