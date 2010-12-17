/* Do not alter this line: $Revision: 1.2.29.1 $ */
/*
**	NAME:							getfiles.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include <ctype.h>

#if defined(unix)
#include <dirent.h>
#endif

#if defined(WIN32)
#include <windows.h>
#endif
#if defined(DOS)
#include <stdlib.h>
#include <sys/utime.h>
#include <dos.h>
#endif
#if defined(sco)
#include <prototypes.h>
#include <utime.h>
#endif

/*
**	DEFINES
*/
#define OLD_TIME 496299600

#define FILES_TO_CHECK_COUNT		100
#define FILES_TO_CHECK_SIZE		80

#define MULTI_WILDCARD_CHAR		'*'
#define SINGLE_WILDCARD_CHAR	'?'

#define MATCH	1
#define SKIP	2

#if defined(unix)
#define PATH_CHAR '/'
#endif
#if defined(WIN32) || defined(DOS)
#define PATH_CHAR '\\'
#endif

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
extern char *ctime();
extern char	*getenv();
extern char	*strchr();
#if defined(WIN32) || defined(DOS)
extern int _stat();
extern int _utime();
#endif
extern void exit();

/*
**	VARIABLES
*/
char		*exe;
char		files_to_check[FILES_TO_CHECK_COUNT][FILES_TO_CHECK_SIZE];
char		top_dir[256];
int			top_dir_len;
int			files_to_check_count = 0;
int			check_mode = 0;
int			relativeflag = 0;
time_t		oldtime = 0;
time_t		newtime = 0;
time_t		exacttime = 0;
int			touchflag = 0;

#if defined(unix)
extern int	errno;
extern char *optarg;
extern int 	optind;
extern int 	opterr;
#endif

#if defined(WIN32) || defined(DOS)
char *optarg = 0;
int  optind = 1;
int  opterr = 0;
#endif

/*
**	FUNCTIONS
*/

/******************************************************************************/

#if defined(WIN32) || defined(DOS)

extern int getopt(
	int argc,
	char **argv,
	char *optstring)
{
	char *ptrstr = 0;


	optarg = 0;

	if (optind < argc)
	{
		if( *argv[optind] == '-' )
		{
			ptrstr = strchr(optstring, *(argv[optind]+1));
			if( ptrstr )
			{
				if( *(ptrstr+1) == ':' )
				{
					if( *(argv[optind]+2) )
					{ 
						optarg = argv[optind]+2;
					}
					else
					{
						optind++; /* Next */
						if( *argv[optind] == '-' )
						{
							if( opterr )
							{
								fprintf(stderr,"%s: option requires an argument -- %c\n",
									argv[0], *ptrstr);
							}
							return('?');
						}
						else
						{
							optarg = argv[optind];
						}
					}
				}
				optind++; /* Next */
				return(*ptrstr);
			}
			else
			{
				if( opterr )
				{
					fprintf(stderr,"%s: illegal option -- %c\n",
							argv[0], *(argv[optind]+1));
				}
				optind++; /* Next */
				return('?');
			}
		}
		else
		{
			/*
			**	First nonoption argument
			*/
			return(-1);
		}
	}
	return(-1);
}

#endif

/******************************************************************************/

int strcmp_wildcard(
	char *s1,	/* string with possible wild card */
	char *s2)	/* string to compare against */
{
	if (*s1 == MULTI_WILDCARD_CHAR)
	{
		while(*s1 == MULTI_WILDCARD_CHAR)
			s1++;

		while(*s2)
		{
			if(strcmp_wildcard(s1, s2) == 0)
				return 0;
			s2++;
		}

		if (*s1 == 0 && *s2 == 0)
			return 0;
	}
	else if (*s1 == SINGLE_WILDCARD_CHAR)
	{
		if (*s2)
			return strcmp_wildcard(s1+1, s2+1);
		else
			return 1;
	}
	else
	{
		if (*s1 == *s2)
		{
			if (*s1 == 0) /* which implies s2 == 0 */
			{
				return 0;
			}
			return strcmp_wildcard(s1+1, s2+1);
		}
		else
		{
			return 1;
		}
	}
	return 1;
}

/******************************************************************************/

static void read_files_to_check(
	char *filename)
{
	char buffer[80];
	char *ptr;
	FILE *fp;

	if (!filename)
	{
		return;
	}

	if ((fp = fopen(filename, "r")) == NULL)
	{
		fprintf(stderr, "%s: unable to open file \"%s\": %s\n",
			exe, filename, strerror(errno));
		exit(1);
	}

	while(fgets(buffer, FILES_TO_CHECK_SIZE, fp))
	{
		if (files_to_check_count == FILES_TO_CHECK_COUNT)
		{
			fprintf(stderr, "%s: The number of entries in \"%s\" is larger "
				"than FILES_TO_CHECK_COUNT:%d\n", exe, filename,
				FILES_TO_CHECK_SIZE);
			fprintf(stderr, "%s: Change the number of entries or increase "
				"FILES_TO_CHECK_COUNT in \"%s\".\n", exe, __FILE__);
			exit(1);
		}
		if ((ptr = strchr(buffer, '\n')) == NULL)
		{
			fprintf(stderr, "%s: A entry in \"%s\" is larger than "
				"FILES_TO_CHECK_SIZE:%d\n", exe, filename, FILES_TO_CHECK_SIZE);
			fprintf(stderr, "%s: Change the entry or increase "
				"FILES_TO_CHECK_SIZE in \"%s\".\n", exe, __FILE__);
			exit(1);
		}
		*ptr = '\0';

#if defined(WIN32) || defined(DOS)
		for (ptr = buffer; *ptr; ptr++)
		{
			if (*ptr == '/')
			{
				*ptr = '\\';
			}
		}
#endif

		strcpy(files_to_check[files_to_check_count++], buffer);
	}

	fclose(fp);
}

/******************************************************************************/

static int check_files_to_check(
	char *filename)
{
	int i;

	for (i = 0; i < files_to_check_count; i++)
	{
		if (!strcmp_wildcard(files_to_check[i],filename))
		{
			return 1;
		}
	}

	return 0;
}

/******************************************************************************/

static int read_directory(
	char *dirname)
{
	char			*ptr;
	char			*path_ptr;
	char			*path;
	char			*name;
	char			full_path[256];
#if defined(unix)
	struct stat		statbuf;
	struct dirent	*d;
	DIR				*dp;
#endif
#if defined(WIN32)
	char			searchString[256];
	struct _stat	statbuf;
	WIN32_FIND_DATA d;
	HANDLE			hSearch;
#endif
#if defined(DOS)
	char			searchString[256];
	struct _stat	statbuf;
	struct find_t	d;
#endif

	for(path_ptr = full_path, ptr = dirname ;*ptr; ptr++, path_ptr++)
	{
		*path_ptr = *ptr;
	}
	*path_ptr++ = PATH_CHAR;
	*path_ptr = '\0';

#if defined(WIN32)
	sprintf(searchString, "%s\\*", dirname);
#endif
#if defined(DOS)
	sprintf(searchString, "%s\\*.*", dirname);
#endif


#if defined(unix)
	if ((dp = opendir(dirname)) == NULL)
#endif	
#if defined(WIN32)
	if ((hSearch = FindFirstFile(searchString, &d)) == INVALID_HANDLE_VALUE)
#endif	
#if defined(DOS)
	if (_dos_findfirst(searchString, _A_NORMAL|_A_SUBDIR, &d))
#endif
	{
		fprintf(stderr, "%s: unable to open \"%s\": %s\n",
			exe, dirname, strerror(errno));
		return 1;
	}

#if defined(unix)
	while((d = readdir(dp)) != NULL)
#endif
#if defined(WIN32) || defined(DOS)
	do
#endif
	{
#if defined(unix)
		name = d->d_name;
#endif
#if defined(WIN32)
		name = d.cFileName;
#endif
#if defined(DOS)
		name = d.name;
#endif
		if (name[0] == '.' &&
			(name[1] == '\0') ||
			(name[1] == '.' && name[2] == '\0'))
		{
			continue;
		}

#if defined(WIN32) || defined(DOS)
		for (ptr = name; *ptr; ptr++)
		{
			if (isupper(*ptr))
			{
				*ptr = _tolower(*ptr);
			}
		}
#endif

		/*
		**	Append the filename to then full path;
		*/
		strcpy(path_ptr, name);

		/*
		**	Setup the path relative to the top dir.
		**	for example:
		**	if
		**		top_dir == /usr/4.2.2/riscom
		**		full_path == /usr/4.2.2/riscom/common/COMgetdr.c
		**	then
		**		path == common/COMgetdr.c
		**	
		*/
		path = full_path;
		if (relativeflag)
		{
			if (!strncmp(path, top_dir, top_dir_len))
			{
				path += top_dir_len + 1;
			}
		}

		if (check_mode == SKIP)
		{
			if (check_files_to_check(path))
			{
				continue;
			}
		}


#if defined(unix)
		if (stat(full_path, &statbuf) == -1)
#endif
#if defined(WIN32) || defined(DOS)
		if (_stat(full_path, &statbuf) == -1)
#endif
		{
			fprintf(stderr, "%s: stat failed for \"%s\": %s\n",
				exe, full_path, strerror(errno));
			return 1;
		}
		if (statbuf.st_mode & S_IFDIR)
		{
			/*
			**	It's a directory
			*/
			if (read_directory(full_path))
			{
				return 1;
			}
		}
		else
		{
			/*
			**	It's a file
			*/
			if (check_mode == MATCH)
			{
				if (!check_files_to_check(path))
				{
					continue;
				}
			}

			if (exacttime || oldtime || newtime)
			{
				/*
				**	It's a file; A conditional flag is set;
				*/
				if (exacttime && statbuf.st_mtime == exacttime)
				{
					if (touchflag)
					{
#if defined(unix)
						if (utime(full_path, 0) == -1)
#endif
#if defined(WIN32) || defined(DOS)
						if (_utime(full_path, 0) == -1)
#endif
						{
							fprintf(stderr, "%s: utime failed for \"%s\": %s\n",
								exe, full_path, strerror(errno));
							return 1;
						}
					}
					puts(path);
					continue;
				}
				if (oldtime || newtime)
				{
					if (oldtime && statbuf.st_mtime >= oldtime)
					{
						continue;
					}
		
					if (newtime && statbuf.st_mtime <= newtime)
					{
						continue;
					}

					puts(path);
				}
			}
			else
			{
				puts(path);
			}
		}
	}
#if defined(WIN32)
	while(FindNextFile(hSearch, &d));
#endif
#if defined(DOS)
	while(_dos_findnext(&d) == 0);
#endif

#if defined(unix)
	closedir(dp);
#endif
#if defined(WIN32)
	FindClose(hSearch);
#endif
	return 0;
}

/******************************************************************************/

extern void Usage()
{
	char	*date;
	time_t	clock = OLD_TIME;

	date = ctime(&clock);
	*strchr(date, '\n') = '\0';

	fprintf(stderr,
		"Usage: %s [-{s|m} filename] [-n filename] [-o filename] [-e[t]] [-r] [directory...]\n", exe);
	fprintf(stderr,
		"    -s filename: \"filename\" contains a list of files to skip.\n");
	fprintf(stderr,
		"    -m filename: \"filename\" contains a list of files to match.\n");
	fprintf(stderr,
		"    -n filename: list files newer than \"filename\".\n");
	fprintf(stderr,
		"    -o filename: list files older than \"filename\".\n");
	fprintf(stderr,
		"    -e: list files dated \"%s\".\n", date);
	fprintf(stderr,
		"    -t: touch files dated \"%s\". Valid only with -e\n", date);
	fprintf(stderr,
		"    -r: display files relative to \"directory\".\n");
	exit(1);
}

/******************************************************************************/

extern int main(
int		argc,
char	*argv[])
{
	int			c;
	char		*older_filename = NULL;
	char		*newer_filename = NULL;
	char		*files_to_check_filename = NULL;
#if defined(unix)
	struct stat	statbuf;
#endif
#if defined(WIN32) || defined(DOS)
	struct _stat	statbuf;
#endif

	exe = argv[0];

	while((c = getopt(argc, argv, "s:m:o:n:etr")) != -1)
	{
		switch(c)
		{
			case 's':
				if (files_to_check_filename) Usage();
				files_to_check_filename = optarg;
				check_mode = SKIP;
				break;

			case 'm':
				if (files_to_check_filename) Usage();
				files_to_check_filename = optarg;
				check_mode = MATCH;
				break;

			case 'o':
				if (older_filename) Usage();
				older_filename = optarg;
				break;

			case 'n':
				if (newer_filename) Usage();
				newer_filename = optarg;
				break;

			case 'e':
				if (exacttime) Usage();
				exacttime = OLD_TIME;
				break;

			case 't':
				if (touchflag) Usage();
				touchflag = 1;
				break;

			case 'r':
				if (relativeflag) Usage();
				relativeflag = 1;
				break;

			default:
				Usage();
		}
	}

	if (touchflag && !exacttime)
	{
		Usage();
	}

	if (files_to_check_filename)
	{
		read_files_to_check(files_to_check_filename);
	}

	if (older_filename)
	{
#if defined(unix)
		if (stat(older_filename, &statbuf) == -1)
#endif
#if defined(WIN32) || defined(DOS)
		if (_stat(older_filename, &statbuf) == -1)
#endif
		{
			fprintf(stderr, "%s: stat failed for \"%s\": %s\n",
				exe, older_filename, strerror(errno));
			return 1;
		}
		oldtime = statbuf.st_mtime;
	}

	if (newer_filename)
	{
#if defined(unix)
		if (stat(newer_filename, &statbuf) == -1)
#endif
#if defined(WIN32) || defined(DOS)
		if (_stat(newer_filename, &statbuf) == -1)
#endif
		{
			fprintf(stderr, "%s: stat failed for \"%s\": %s\n",
				exe, newer_filename, strerror(errno));
			return 1;
		}
		newtime = statbuf.st_mtime;
	}

	if (optind < argc)
	{
		for (; optind < argc; optind++)
		{
			strcpy(top_dir, argv[optind]);
			top_dir_len = strlen(top_dir);
			read_directory(top_dir);
		}
	}
	else
	{
		relativeflag = 1;
		strcpy(top_dir, ".");
		top_dir_len = strlen(top_dir);
		read_directory(top_dir);
	}

	return 0;
}

/******************************************************************************/
