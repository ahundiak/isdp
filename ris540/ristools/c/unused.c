/* Do not alter this line: $Revision: 1.2.29.1 $ */
/*
**	NAME:							unused.c
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
#include <stdarg.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <ftw.h>
#include <dirent.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>
#if defined(sco)
#include <prototypes.h>
#endif


/*
**	DEFINES
*/
#define UNUSED_DIR		"unused"

#define MAX_GOOD_FILES	200
#define MAX_ALL_FILES	100
#define MAX_M_FILES		100

#define ARCHIVE			1
#define CC				2
#define CCFILTER		3
#define COPT			4
#define DEPLIB			5
#define DOPT			6
#define END_RULES		7
#define END_SPECIAL		8
#define EXEC			9
#define INCLUDE			10
#define LIB				11
#define LINKLIB			12
#define OMCPP			13
#define OPP				14
#define OPPFLAGS		15
#define POST_SPECIAL	16
#define RULES			17
#define SOURCE			18
#define SPEC			19
#define SPECIAL			20
#define SRC				21
#define SUFFIXES		22
#define TARGET			23


/*
**	TYPES
*/
typedef struct keyword_s
{
	char	*name;
	int		value;
} keyword_s;

/*
**	FUNCTION PROTOTYPES
*/

/*
**	VARIABLES
*/
char		*exe;
int			database_mode = 0;
int			all_count = 0;
int			good_count = 0;
int			m_file_count = 0;
char		all[MAX_ALL_FILES][15];
char		good[MAX_GOOD_FILES][15];
char		m_file[MAX_M_FILES][80];

keyword_s	keyword[] = 
{
	{ "ARCHIVE",		ARCHIVE },
	{ "CC",				CC },
	{ "CCFILTER",		CCFILTER },
	{ "COPT",			COPT },
	{ "DEPLIB",			DEPLIB },
	{ "DOPT",			DOPT },
	{ "END_RULES",		END_RULES },
	{ "END_SPECIAL",	END_SPECIAL },
	{ "END_SPECIAL",	END_SPECIAL },
	{ "EXEC",			EXEC },
	{ "INCLUDE",		INCLUDE },
	{ "LIB",			LIB },
	{ "LINKLIB",		LINKLIB },
	{ "OMCPP",			OMCPP },
	{ "OPP",			OPP },
	{ "OPPFLAGS",		OPPFLAGS },
	{ "POST_SPECIAL",	POST_SPECIAL },
	{ "RULES",			RULES },
	{ "SOURCE",			SOURCE },
	{ "SPEC",			SPEC },
	{ "SPECIAL",		SPECIAL },
	{ "SRC",			SRC },
	{ "SUFFIXES",		SUFFIXES },
	{ "TARGET",			TARGET },
};
int keyword_count = sizeof(keyword)/sizeof(struct keyword_s);

extern int errno;
extern char *sys_errlist[];


/*
**	FUNCTIONS
*/

/******************************************************************************/

static int get_next_line(
	char	*buffer,
	int		size,
	FILE	*fp)
{
	char *sts;

	sts = fgets(buffer, size, fp);

	if (buffer[0] == '#')
	{
		return get_next_line(buffer, size, fp);
	}

	return sts ? 1 : 0;
}

/******************************************************************************/

static int get_keyword(
	char *buffer)
{
	int i;
	char *p;

	for (p = buffer; *p && isspace(*p); p++);

	for (i = 0; i < keyword_count; i++)
	{
		if (!strncmp(p, keyword[i].name, strlen(keyword[i].name)))
		{
			return (keyword[i].value);
		}
	}

	return 0;
}

/******************************************************************************/

static int add_good_file(
char *filename)
{
	int i;

	for (i = 0; i < good_count; i++)
	{
		if (!strcmp(good[i], filename))
		{
			return 0;
		}
	}

	if (good_count == MAX_GOOD_FILES)
	{
		fprintf(stderr, "%s: MAX_GOOD_FILES(%d) needs to be increased\n",
			exe, MAX_GOOD_FILES);		
		return 1;
	}

	strcpy(good[good_count], filename);
	good_count++;

	return 0;
}

/******************************************************************************/

static int read_m_file(
	char	*m_file)
{
	int		len;
	char	*e;
	char	*p;
	char	buffer[256];
	FILE	*fp;

	if ((fp = fopen(m_file, "r")) == NULL)
	{
		fprintf(stderr, "%s: Unable to open \"%s\": %s\n", exe, m_file,
			sys_errlist[errno]);
		return 1;
	}

	while(get_next_line(buffer, 256, fp))
	{
		if (get_keyword(buffer) == SOURCE)
		{
			break;
		}
	}

	while(get_next_line(buffer, 256, fp))
	{
		if (get_keyword(buffer))
		{
			break;
		}

		for (p = buffer; *p && isspace(*p); p++);
		if (!*p)
		{
			continue;
		}

		for (e = p; *e && !isspace(*e); e++);
		*e = 0;

		if (add_good_file(p))
		{
			return 1;
		}

		if (database_mode)
		{
			if ((len = strlen(p)) > 2)
			{
				if (p[len - 2] == '.' && p[len - 1] == 'c')
				{
					p[len - 1] = 'h';
					if (add_good_file(p))
					{
						return 1;
					}
				}
			}
		}
	}

	if (add_good_file(m_file))
	{
		return 1;
	}

	fclose(fp);

	return 0;
}

/******************************************************************************/

static int fn(
#if defined(__Sol2__) || defined(Soli) || defined(__hpux__)
	const char		*s,
	const struct stat	*p,
	int			i)
#else
	char		*s,
	struct stat	*p,
	int			i)
#endif
{
	int len;
#if defined(__Sol2__) || defined(Soli) || defined(__hpux__)
	const char *name;
#else
	char *name;
#endif

	p = p;	/* shut up compilier */
	i = i;	/* shut up compilier */
	len = strlen(s);
	if (len > 2)
	{
		if (s[len - 2] == '.' && s[len - 1] == 'm')
		{
			if (m_file_count == MAX_M_FILES)
			{
				fprintf(stderr, "%s: MAX_M_FILES(%d) needs to be increased\n",
					exe, MAX_M_FILES);		
				return 1;
			}

			if (s[0] == '.' && s[1] == '/')
			{
				name = s+2;
			}
			else
			{
				name = s;
			}
			strcpy(m_file[m_file_count], name);
			m_file_count++;
		}
	}

    return 0;
}

/******************************************************************************/

static int get_m_files()
{
    if (ftw(".", fn, 3) == -1)
	{
		fprintf(stderr, "%s: ftw failed: %s\n", exe, sys_errlist[errno]);
		return -1;
	}
	return 0;
}

/******************************************************************************/

static int get_good_files()
{
	int i;

	for (i = 0; i < m_file_count; i++)
	{
		if (read_m_file(m_file[i]))
		{
			return 1;
		}
	}

	return 0;
}

/******************************************************************************/

static int get_all_files()
{
	struct stat		statbuf;
	struct dirent	*d;
	DIR				*dp;

	/*
	**	Get a list of all files.
	*/
	if ((dp = opendir(".")) == NULL)
	{
		fprintf(stderr, "%s: unable to open \".\": %s\n",
			exe, sys_errlist[errno]);
		return 1;
	}

	while((d = readdir(dp)) != NULL)
	{
		if (stat(d->d_name, &statbuf) == -1)
		{
			fprintf(stderr, "%s: stat failed for \"%s\": %s\n",
				exe, d->d_name, sys_errlist[errno]);
			return 1;
		}

		if (!(statbuf.st_mode & S_IFDIR))
		{
			if (all_count == MAX_ALL_FILES)
			{
				fprintf(stderr, "%s: MAX_ALL_FILES(%d) needs to be increased\n",
					exe, MAX_ALL_FILES);		
				return 1;
			}
			strcpy(all[all_count], d->d_name);
			all_count++;
		}
	}

	closedir(dp);
	return 0;
}

/******************************************************************************/

static int move_unused_file(
	char *filename)
{
	char cmd[80];

	/*
	**	First create the unused directory
	*/
	if (mkdir(UNUSED_DIR, 0777) == -1)
	{
		if (errno != EEXIST)
		{
			fprintf(stderr, "%s: unable to create directory \"%s\": %s\n",
				exe, UNUSED_DIR, sys_errlist[errno]);
			return -1;
		}
	}
	else
	{
		printf("Made directory \"%s\"\n", UNUSED_DIR);
	}

	sprintf(cmd, "mv %s %s", filename, UNUSED_DIR);
	if (system(cmd) < 0)
	{
		fprintf(stderr, "%s: unable to move \"%s\" to \"%s\": %s\n",
			exe, filename, UNUSED_DIR, sys_errlist[errno]);
		return -1;
	}

	printf("Moved \"%s\" to \"%s\"\n", filename, UNUSED_DIR);
	return 0;
}

/******************************************************************************/

extern int main(
int		argc,
char	*argv[])
{
	int		i,j;

	exe = argv[0];

	for (i = 1; i < argc; i++)
	{
		if (i == 1 && !strcmp(argv[i], "-d"))
		{
			database_mode = 1;
		}
		else
		{
			if ((int)strlen(argv[i]) > 14)
			{
				fprintf(stderr, "%s: Invalid arg \"%s\"\n", exe, argv[i]);
				return 1;
			}
			strcpy(good[good_count], argv[i]);
			good_count++;
		}
	}

	if (get_m_files())
	{
		return 1;
	}
	if (m_file_count == 0)
	{
		fprintf(stderr, "%s: no .m files found\n", exe);
		return 1;
	}
#ifdef DEBUG
	printf("\n.m files\n");
	for (i = 0; i< m_file_count; i++)
	{
		printf("m_file[%d]:<%s>\n", i, m_file[i]);
	}
#endif

	if (get_good_files())
	{
		return 1;
	}
#ifdef DEBUG
	printf("\nGood files\n");
	for (i = 0; i< good_count; i++)
	{
		printf("good[%d]:<%s>\n", i, good[i]);
	}
#endif

	if (get_all_files())
	{
		return 1;
	}
#ifdef DEBUG
	printf("\nAll files\n");
	for (i = 0; i< all_count; i++)
	{
		printf("all[%d]:<%s>\n", i, all[i]);
	}
#endif

	for (i = 0; i< all_count; i++)
	{
		for (j = 0; j < good_count; j++)
		{
			if (!strcmp(all[i], good[j]))
			{
				break;
			}
		}
		if (j == good_count)
		{
			if (move_unused_file(all[i]))
			{
				return 1;
			}
		}
	}
	return 0;
}

/******************************************************************************/
