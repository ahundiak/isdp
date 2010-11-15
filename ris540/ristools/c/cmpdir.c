/* Do not alter this line: $Revision: 1.2.29.1 $ */
/*
**	NAME:							cmpdir.c
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
#include <search.h>
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
#define MATCH			1
#define SKIP			2

#define	DIFF_VERSION	0
#define SAME_VERSION	1
#define UNKNOWN_VERSION	2

#define DIFF_FILE		0
#define SAME_FILE		1

#define DIR_1_ONLY					0
#define DIR_2_ONLY					1
#define DIFF_FILE_DIFF_VERSION		2
#define DIFF_FILE_SAME_VERSION		3
#define DIFF_FILE_UNKNOWN_VERSION	4
#define SAME_FILE_SAME_VERSION		5
#define SAME_FILE_UNKNOWN_VERSION	6
#define FILE_TYPE_COUNT				7

#define EXE	"cmpdir"

#define FILE_COUNT	768
#define FILE_SIZE	128

#define FILES_TO_CHECK_COUNT		2000
#define FILES_TO_CHECK_SIZE		80

#define MULTI_WILDCARD_CHAR		'*'
#define SINGLE_WILDCARD_CHAR	'?'

#if defined(unix)
#define PATH_CHAR '/'
#endif
#if defined(WIN32) || defined(DOS)
#define PATH_CHAR '\\'
#endif

#define MAX_SOURCE_LENGTH	1024

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
int			check_mode = 0;
char		files_to_check[FILES_TO_CHECK_COUNT][FILES_TO_CHECK_SIZE];
int			files_to_check_count = 0;

int			*files_countp;
char		(*filesp)[FILE_COUNT][FILE_SIZE];
int			top_dir_len;
char		*top_dir;

int			files_count[FILE_TYPE_COUNT];
char		files[FILE_TYPE_COUNT][FILE_COUNT][FILE_SIZE];

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

char *file_type_desc[FILE_TYPE_COUNT] =
{
	"Files in \"%s\" only",
	"Files in \"%s\" only",
	"Files that are different (with different versions)",
	"Files that are different (with identical versions)",
	"Files that are different (with unknown versions)",
	"Files that are indentical (with identical versions)",
	"Files that are indentical (with unknown versions)",
};

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

static char *substrcmp(
	char *s1,
	char *s2)
{
	int i;
	int l1;
	int l2;
	char *ptr;

	l1 = strlen(s1);
	l2 = strlen(s2);

	ptr = s1;
	for (i = 0; i <= l1 - l2; i++)
	{
		if (strncmp(ptr,s2,l2) == 0)
		{
			return ptr;
		}
		ptr++;
	}
	return 0;
}

/******************************************************************************/

static int compareFunction(
const void *s1,
const void *s2)
{
	return strcmp(s1,s2);
}

/******************************************************************************/

static int strcmp_wildcard(
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

static int read_files_to_check(
	char *filename)
{
	char buffer[80];
	char *ptr;
	FILE *fp;

	if (!filename)
	{
		return 0;
	}

	if ((fp = fopen(filename, "r")) == NULL)
	{
		fprintf(stderr, "%s: unable to open file \"%s\": %s\n",
			EXE, filename, strerror(errno));
		return 1;
	}

	while(fgets(buffer, FILES_TO_CHECK_SIZE, fp))
	{
		if (files_to_check_count == FILES_TO_CHECK_COUNT)
		{
			fprintf(stderr, "%s: The number of entries in \"%s\" is larger "
				"than FILES_TO_CHECK_COUNT:%d\n", EXE, filename,
				FILES_TO_CHECK_COUNT);
			fprintf(stderr, "%s: Change the number of entries or increase "
				"FILES_TO_CHECK_COUNT in \"%s\".\n", EXE, __FILE__);
			return 1;
		}
		if ((ptr = strchr(buffer, '\n')) == NULL)
		{
			fprintf(stderr, "%s: A entry in \"%s\" is larger than "
				"FILES_TO_CHECK_SIZE:%d\n", EXE, filename, FILES_TO_CHECK_SIZE);
			fprintf(stderr, "%s: Change the entry or increase "
				"FILES_TO_CHECK_SIZE in \"%s\".\n", EXE, __FILE__);
			return 1;
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
	return 0;
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
	char			*name;
	char			*path_ptr;
	char			*relative_path;
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
			EXE, dirname, strerror(errno));
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
		**		relative_path == common/COMgetdr.c
		**	
		*/
		relative_path = full_path;
		if (!strncmp(relative_path, top_dir, top_dir_len))
		{
			relative_path += top_dir_len + 1;
		}

		if (check_mode == SKIP)
		{
			if (check_files_to_check(relative_path))
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
				EXE, full_path, strerror(errno));
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
				if (!check_files_to_check(relative_path))
				{
					continue;
				}
			}

			if (*files_countp == FILE_COUNT)
			{
				fprintf(stderr, "%s: The number of files in \"%s\" is larger "
					"than FILE_COUNT:%d\n", EXE, top_dir, FILE_COUNT);
				fprintf(stderr, "%s: Increase FILE_COUNT in \"%s\".\n",
					EXE, __FILE__);
			}
			if ((int)strlen(relative_path) >= FILE_SIZE)
			{
				fprintf(stderr, "%s: \"%s\" is larger than FILE_SIZE:%d\n",
					EXE, relative_path, FILE_SIZE);
				fprintf(stderr, "%s: Increase FILE_SIZE in \"%s\".\n",
					EXE, __FILE__);
			}

			strcpy((*filesp)[(*files_countp)++], relative_path);
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

static int get_file_version(
	FILE *fp,
	char *version,
	int size)
{
	int		i;
	int		len;
	char	*ptr1;
	char	*ptr2;
	char	version_str[11] = { '$','R','e','v','i','s','i','o','n',':','\0'};
	char	buffer[1024];

	for (i = 0; i < 5 && fgets(buffer, 1024, fp) != NULL; i++)
	{
		if ((ptr1 = substrcmp(buffer, version_str)) != NULL)
		{
			ptr1 += 10;	
			while(*ptr1 && isspace(*ptr1)) ptr1++;
			if ((ptr2 = strchr(ptr1, '$')) != NULL)
			{
				*ptr2 = '\0';
				while(isspace(*(ptr2 - 1)))
				{
					ptr2--;
					*ptr2 = '\0';
				}

				if ((len = strlen(ptr1)) < size)
				{
					memcpy(version, ptr1, len + 1);
				}
				else
				{
					len = 0;
				}
				return len;
			}
		}
	}
	return 0;
}

/******************************************************************************/

extern int filecmp(
	char *filename1, 
	char *filename2)
{
	int return_sts = -1;
	int c1, c2;
	int file_sts;
	int version_sts;
	int v1_len, v2_len;
	char v1[16], v2[16];
	FILE *fp1, *fp2;

	if ((fp1 = fopen(filename1, "r")) == NULL)
	{
		fprintf(stderr, "%s: Unable to open \"%s\": %s", EXE, filename1,
			strerror(errno));
		return -1;
	}
	v1_len = get_file_version(fp1, v1, sizeof(v1));

	if ((fp2 = fopen(filename2, "r")) == NULL)
	{
		fprintf(stderr, "%s: Unable to open \"%s\": %s", EXE, filename2,
			strerror(errno));
		return -1;
	}
	v2_len = get_file_version(fp2, v2, sizeof(v2));

	/*
	**	Determine the version sts
	*/
	if (v1_len && v2_len)
	{
		if (strcmp(v1, v2))
		{
			version_sts = DIFF_VERSION;
		}
		else
		{
			version_sts = SAME_VERSION;
		}
	}
	else
	{
		version_sts = UNKNOWN_VERSION;
	}

	/*
	**	Determine the file status
	*/
	if (version_sts == DIFF_VERSION)
	{
		file_sts = DIFF_FILE;
	}
	else
	{
		rewind(fp1);
		rewind(fp2);

		while(1)
		{
			c1 = getc(fp1);
			c2 = getc(fp2);

			if (c1 == EOF && c2 == EOF)
			{
				file_sts = SAME_FILE;
				break;
			}

			if ((c1 != EOF && c2 == EOF) || (c1 == EOF && c2 != EOF))
			{
				file_sts = DIFF_FILE;
				break;
			}

			if (c1 != c2)
			{
				file_sts = DIFF_FILE;
				break;
			}
		}
	}
	fclose(fp1);
	fclose(fp2);

	/*
	**	Determine the return sts
	*/
	switch (version_sts)
	{
		case DIFF_VERSION:
			return_sts = DIFF_FILE_DIFF_VERSION;
			break;

		case SAME_VERSION:
			return_sts = (file_sts == SAME_FILE) ?
				SAME_FILE_SAME_VERSION : DIFF_FILE_SAME_VERSION;
			break;

		case UNKNOWN_VERSION:
			return_sts = (file_sts == SAME_FILE) ?
				SAME_FILE_UNKNOWN_VERSION : DIFF_FILE_UNKNOWN_VERSION;
			break;
	}
	return return_sts;
}

/******************************************************************************/

static void add_file(
	char *file,
	int type)
{
	if (file && type >= 0 && type < FILE_TYPE_COUNT)
	{
		strcpy(files[type][files_count[type]++], file);
	}
}

/******************************************************************************/

static void Usage(
	int help)
{
	int i;

	fprintf(stderr,
		"Usage: %s [-{s|m} filename] [-i] [-o filename] dir1 dir2\n", EXE);
	fprintf(stderr, "       %s -h\n");
	fprintf(stderr, "       %s -?\n");
	fprintf(stderr,
		"    -s filename: \"filename\" contains a list of files to skip.\n");
	fprintf(stderr,
		"    -m filename: \"filename\" contains a list of files to match.\n");
	fprintf(stderr,
		"    -i: also list files that are the identical.\n");
	fprintf(stderr,
		"    -o: output filename template.\n");
	fprintf(stderr,
		"    -h: show Help.\n");
	fprintf(stderr,
		"    -?: show Usage.\n");

	if (help)
	{
		fprintf(stderr, "\n");
		fprintf(stderr, "cmpdir will recursively compare dir1 and dir2 and report the following\n");
		fprintf(stderr, "information:\n");
		for (i = 0; i < FILE_TYPE_COUNT; i++)
		{
			fprintf(stderr, "\t");
			switch(i)
			{
				case DIR_1_ONLY:
					fprintf(stderr, file_type_desc[i], "dir1");
					break;

				case DIR_2_ONLY:
					fprintf(stderr, file_type_desc[i], "dir2");
					break;

				default:
					fprintf(stderr, file_type_desc[i]);
					break;
			}
			fprintf(stderr, "\n");
		}
		fprintf(stderr, "\n");

		fprintf(stderr, "The version is determined by the SPC Revision Macro which should be in embedded\n");
		fprintf(stderr, "in each file.\n");

		fprintf(stderr, "\n");

		fprintf(stderr, "The lists used for the -m and -s options can contain the wildcards '*' and '?'.\n");
		fprintf(stderr, "They have the same functionality as the ksh wildcards.\n");

		fprintf(stderr, "\n");

		fprintf(stderr, "If the -o option is used, the following suffixes will be appended to the output\n");
		fprintf(stderr, "filename template:\n");

		for (i = 0; i < FILE_TYPE_COUNT; i++)
		{
			fprintf(stderr, "\t.%d -- ", i);
			switch(i)
			{
				case DIR_1_ONLY:
					fprintf(stderr, file_type_desc[i], "dir1");
					break;

				case DIR_2_ONLY:
					fprintf(stderr, file_type_desc[i], "dir2");
					break;

				default:
					fprintf(stderr, file_type_desc[i]);
					break;
			}
			fprintf(stderr, "\n");
		}

	}

	exit(2);
}

/******************************************************************************/

extern int main(
int		argc,
char	*argv[])
{
	int		c, i;
	int		i1, i2;
	int		iflag = 0;
	int		file_type;
	int		files1_count = 0;
	int		files2_count = 0;
	char	dir1[256];
	char	dir2[256];
	char	files1[FILE_COUNT][FILE_SIZE];
	char	files2[FILE_COUNT][FILE_SIZE];
	char	*output = NULL;
	char	*files_to_check_filename = NULL;

	/*
	**	Process args
	*/
	while((c = getopt(argc, argv, "s:m:io:h?")) != -1)
	{
		switch(c)
		{
			case 's':
				if (files_to_check_filename) Usage(0);
				files_to_check_filename = optarg;
				check_mode = SKIP;
				break;

			case 'm':
				if (files_to_check_filename) Usage(0);
				files_to_check_filename = optarg;
				check_mode = MATCH;
				break;

			case 'i':
				if (iflag) Usage(0);
				iflag = 1;
				break;

			case 'o':
				if (output) Usage(0);
				output = optarg;
				break;

			case 'h':
				Usage(1);

			case '?':
			default:
				Usage(0);
		}
	}

	if (optind != argc - 2 )
	{
		Usage(0);
	}
	strcpy(dir1, argv[optind]);
	strcpy(dir2, argv[optind + 1]);

	/*
	**	Read files to skip
	*/
	if (files_to_check_filename)
	{
		if (read_files_to_check(files_to_check_filename))
		{
			return 2;
		}
	}

	/*
	**	Read files in first directory and sort them
	*/
	files_countp = &files1_count;
	filesp = &files1;
	top_dir = dir1;
	top_dir_len = strlen(top_dir);
	if (read_directory(top_dir))
	{
		return 2;
	}
    qsort((char *)files1,files1_count, FILE_SIZE, compareFunction);

	/*
	**	Read files in second directory and sort them
	*/
	files_countp = &files2_count;
	filesp = &files2;
	top_dir = dir2;
	top_dir_len = strlen(top_dir);
	if (read_directory(top_dir))
	{
		return 2;
	}
    qsort((char *)files2,files2_count, FILE_SIZE, compareFunction);

	/*
	**	Compare lists
	*/
	i1 = 0;
	i2 = 0;
	while(i1 < files1_count && i2 < files2_count)
	{
		if (strcmp(files1[i1],files2[i2]) < 0)
		{
			add_file(files1[i1], DIR_1_ONLY);
			i1++;
		}
		else if (strcmp(files1[i1],files2[i2]) > 0)
		{
			add_file(files2[i2], DIR_2_ONLY);
			i2++;
		}
		else
		{
			int sts;
			char path1[256];
			char path2[256];

			sprintf(path1, "%s%c%s", dir1, PATH_CHAR, files1[i1]);
			sprintf(path2, "%s%c%s", dir2, PATH_CHAR, files2[i2]);

			switch(sts = filecmp(path1, path2))
			{
				case -1: /* Error */
					return 2;

				case DIFF_FILE_DIFF_VERSION:
				case DIFF_FILE_SAME_VERSION:
				case SAME_FILE_SAME_VERSION:
				case DIFF_FILE_UNKNOWN_VERSION:
				case SAME_FILE_UNKNOWN_VERSION:
					add_file(files1[i1], sts);
					break;

				default:
					fprintf(stderr, "%s: Internal error: File:%s Line:%d\n", 
						EXE, __FILE__, __LINE__);
					return 2;
			}
			i1++;
			i2++;
		}
	}

	/* take care of any left over files */
	while(i1 < files1_count)
	{
		add_file(files1[i1], DIR_1_ONLY);
		i1++;
	}

	while(i2 < files2_count)
	{
		add_file(files2[i2], DIR_2_ONLY);
		i2++;
	}

	if (output)
	{
		FILE *fp;
		char path[256];

		for (file_type = 0; file_type < FILE_TYPE_COUNT; file_type++)
		{
			switch(file_type)
			{
				case SAME_FILE_SAME_VERSION:
				case SAME_FILE_UNKNOWN_VERSION:
					if (!iflag)
					{
						break;
					}

				default:
					sprintf(path, "%s.%d", output, file_type);
					if ((fp = fopen(path, "w")) != NULL)
					{
						for (i = 0; i < files_count[file_type]; i++)
						{
							fprintf(fp, "%s\n", files[file_type][i]);
						}
						fclose(fp);
					}
					break;
			}
		}
	}
	else
	{
		for (file_type = 0; file_type < FILE_TYPE_COUNT; file_type++)
		{
			switch(file_type)
			{
				case DIR_1_ONLY:
					printf("\n");
					printf(file_type_desc[file_type], dir1);
					printf(":\n");
					break;

				case DIR_2_ONLY:
					printf("\n");
					printf(file_type_desc[file_type], dir2);
					printf(":\n");
					break;

				case SAME_FILE_SAME_VERSION:
				case SAME_FILE_UNKNOWN_VERSION:
					if (!iflag)
					{
						break;
					}

				default:
					printf("\n");
					printf(file_type_desc[file_type]);
					printf(":\n");
					break;
			}

			switch(file_type)
			{
				case SAME_FILE_SAME_VERSION:
				case SAME_FILE_UNKNOWN_VERSION:
					if (!iflag)
					{
						break;
					}

				default:
					for (i = 0; i < files_count[file_type]; i++)
					{
						printf("\t\"%s\"\n", files[file_type][i]);
					}
					break;
			}
		}
	}

#if 0
	if (files1only_count || files2only_count || filesdiff_count) 
	{
		return 1;
	}
#endif

	return 0;
}

/******************************************************************************/
