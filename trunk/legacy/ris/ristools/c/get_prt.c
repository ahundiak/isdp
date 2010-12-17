/* Do not alter this line: $Revision: 1.3.29.1 $ */
/*
**	NAME:							get_prt.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					4/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#if defined (WIN32) || defined(DOS)
#include <io.h>
#include <stdlib.h>
#endif
#if defined(sco)
#include <prototypes.h>
#endif

/*
**	DEFINES
*/

#ifdef DEBUG_ON
# define DEBUG(x)  printf x 
#else
# define DEBUG(x)
#endif

#if defined(unix)
#define OPEN_TO_READ_MODE	"r"
#define OPEN_TO_WRITE_MODE	"w"
#endif
#if defined(WIN32) || defined(DOS)
#define OPEN_TO_READ_MODE	"rt"
#define OPEN_TO_WRITE_MODE	"w"
#endif

#define MAX_SOURCE_LENGTH	1024
#define MAX_LINE_SIZE		2048
#define MAX_PROTOTYPE_LINES	1000

#define NO_FUNCTION		0
#define STATIC_FUNCTION	1
#define EXTERN_FUNCTION	2

#define END_OF_BUFFER	0
#define IF				1
#define ELIF			2
#define ELSE			3
#define ENDIF			4
#define CODE			5

#define DELIMITERS		" \n"

#define	SKIP_WHITE_SPACE(ptr)	while(*(ptr) && isspace(*(ptr))) { (ptr)++; }

#define INCREMENT_LINE() \
if (++line >= MAX_PROTOTYPE_LINES) \
{ \
	fprintf(stderr, \
		"%s: file:<%s> line:%d MAX_PROTOTYPE_LINES exceeded\n", \
		exe, src_path, src_line); \
	exit(1); \
}

/*
**	TYPES
*/
typedef struct header_s
{
	char *code;
	struct header_s *next;
} header_s;

/*
**	FUNCTION PROTOTYPES
*/
extern char *getenv();

/*
**	VARIABLES
*/
int			line;
char		buffer[MAX_PROTOTYPE_LINES][MAX_SOURCE_LENGTH];
char		output_path[256];
static char	*exe = "get_prt";

/*
**	FUNCTIONS
*/

/******************************************************************************/

static int diff(
	char *filename1,
	char *filename2)
{
	int c1, c2;
	FILE *fp1, *fp2;

	if ((fp1 = fopen(filename1, OPEN_TO_READ_MODE)) == NULL)
	{
		return 1;
	}

	if ((fp2 = fopen(filename2, OPEN_TO_READ_MODE)) == NULL)
	{
		fclose(fp1);
		return 1;
	}

	do
	{
		c1 = getc(fp1);
		c2 = getc(fp2);

		if (c1 != c2)
		{
			fclose(fp1);
			fclose(fp2);
			return 1;
		}

	} while(c1 != EOF);

	fclose(fp1);
	fclose(fp2);
	return 0;
}

/******************************************************************************/

static int need_to_update(
	char *source_file,
	char *object_file)
{
	struct stat source_buf;
	struct stat object_buf;

	if (stat(source_file, &source_buf))
		return 1;

	if (stat(object_file, &object_buf))
		return 1;

	if (source_buf.st_mtime > object_buf.st_mtime)
		return 1;

	return 0;
}

/******************************************************************************/

int get_line(
	char **pp)
{
	char	*ptr;
	int		save_line;

	/*
	**	This functions removes any preprocessor directives that don't deal
	**	with prototypes.
	*/
	if (buffer[line][0] == -1)
	{
		*pp	= NULL;
		return END_OF_BUFFER;
	}

	if (buffer[line][0] != '#')
	{
		*pp = buffer[line++];
		return CODE;
	}

	ptr = &(buffer[line][1]);
	SKIP_WHITE_SPACE(ptr);

	if (!strncmp(ptr, "ifdef", 5) ||
		!strncmp(ptr, "ifndef", 6) ||
		!strncmp(ptr, "if", 2))
	{
		save_line = line;
		line++;
		if (get_line(pp) == ENDIF)
		{
			return(get_line(pp));
		}
		else
		{
			line = save_line;
			*pp = buffer[line++];
			return IF;
		}
	}
	else if (!strncmp(ptr, "elif", 4))
	{
		save_line = line;
		line++;
		if (get_line(pp) == ENDIF)
		{
			return(ENDIF);
		}
		else
		{
			line = save_line;
			*pp = buffer[line++];
			return ELIF;
		}
	}
	else if (!strncmp(ptr, "else", 4))
	{
		save_line = line;
		line++;
		if (get_line(pp) == ENDIF)
		{
			return(ENDIF);
		}
		else
		{
			line = save_line;
			*pp = buffer[line++];
			return ELSE;
		}
	}
	else if (!strncmp(ptr, "endif", 5))
	{
			*pp = buffer[line++];
			return ENDIF;
	}
	else
	{
		*pp = buffer[line++];
		return CODE;
	}
}

/******************************************************************************/

static void get_prt(
	char *path)
{
	int i;
	int len;
	int function;
	int src_line;
	int prt_include;
	char s[MAX_SOURCE_LENGTH];
	char *ptr;
	char src_path[256];
	char new_path[256];
	char cur_path[256];
	char obj_path[256];
	char filename[15];
	char define[15];
	char *objdir;
	char *dbdir;
	FILE *in;
	FILE *out;

#if defined(DOS)
	/*
	**	Nmake under DOS expands wildcards (i.e, *.c ), but if no file exists
	**	which match the wildcard string, the wildcard string itself is passed
	**	in.  So the wildcard strings represent no files.
	*/
	if (!strcmp(path, "*.c") || !strcmp(path, "*.rc"))
	{
		return;
	}
#endif

	line = 0;
	src_line = 0;
	for (i = 0; i < MAX_PROTOTYPE_LINES; i++)
	{
		buffer[i][0] = '\0';
	}

	if ((objdir = getenv("OBJDIR")) == NULL)
		objdir = "objdir";

	if (((dbdir = getenv("DB_DIR")) != NULL) && (!*dbdir))
		dbdir = NULL;

	for (ptr = path; *ptr; ptr++)
	{
		if (isupper(*ptr))
		{
			*ptr = _tolower(*ptr);
		}
	}

	strcpy(src_path, path);
#if defined(unix)
	if ((ptr = strrchr(path, '/')))
	{
		*ptr++ = 0;
		strcpy(filename, ptr);
		sprintf(cur_path, "%s/prt/",
			output_path[0] ? output_path : path);

		sprintf(new_path, "%s/prt/", 
			output_path[0] ? output_path : path);

		sprintf(obj_path, "%s/%s%s/", path, dbdir ? dbdir : "", objdir);
	}
	else
	{
		strcpy(filename, path);
		sprintf(obj_path, "%s%s/", dbdir ? dbdir : "", objdir);

		sprintf(cur_path, 
			output_path[0] ? output_path : "prt/",
			output_path[0] ? "/prt/" : "");

		sprintf(new_path, "%s%s",
			output_path[0] ? output_path : "prt/",
			output_path[0] ? "/prt/" : "");
	}
#endif
#if defined(WIN32) || defined(DOS)
	if ((ptr = strrchr(path, '\\')) != NULL)
	{
		*ptr++ = 0;
		strcpy(filename, ptr);
		sprintf(cur_path, "%s\\prt\\",
			output_path[0] ? output_path : path);

		sprintf(new_path, "%s\\prt\\", 
			output_path[0] ? output_path : path);

		sprintf(obj_path, "%s\\%s%s\\", path, dbdir ? dbdir : "", objdir);
	}
	else
	{
		strcpy(filename, path);
		sprintf(obj_path, "%s%s\\", dbdir ? dbdir : "", objdir);

		sprintf(cur_path, 
			output_path[0] ? output_path : "prt\\",
			output_path[0] ? "\\prt\\" : "");

		sprintf(new_path, "%s%s",
			output_path[0] ? output_path : "prt\\",
			output_path[0] ? "\\prt\\" : "");
	}
#endif


	for (i = 0; i < 15; i++)
	{
		if (filename[i] == '.')
			define[i] = '_';
		else
			define[i] = filename[i];
	}

	if ((ptr = strrchr(filename, '.')) != NULL)
	{
	   if (! strcmp(ptr, ".pnc"))
	   {
	     return;
	   }
		*ptr = 0;
	}
	strcat(cur_path, filename);
	strcat(cur_path, ".prt"); 

	strcat(new_path, filename);
	strcat(new_path, ".N");

	strcat(obj_path, filename);
#if defined(unix)
	strcat(obj_path, ".o");
#endif
#if defined(WIN32) || defined(DOS)
	strcat(obj_path, ".obj");
#endif

	strcat(filename, ".prt");

	DEBUG(("%s: Checking \"%s\".\n", exe, src_path));

#if defined(unix)
	if (access(cur_path, 00) == 0 && !need_to_update(src_path, obj_path))
#endif
#if defined(WIN32) || defined(DOS)
	if (_access(cur_path, 00) == 0 && !need_to_update(src_path, obj_path))
#endif
	{
		return;
	}

	DEBUG(("%s: Reading \"%s\".\n", exe, src_path)); 
	DEBUG(("\t%s   ->   prt/%s\n", src_path, filename)); 

	/*
	**	open input file
	*/
	if ((in = fopen(src_path, OPEN_TO_READ_MODE)) == NULL)
	{
		fprintf(stderr, "%s: Unable to open filename \"%s\".\n", exe, src_path);
		perror(exe);
		return;
	}
	
	sprintf(buffer[line], "/*\n");
	INCREMENT_LINE();
	sprintf(buffer[line], "**\t%s\n", filename);
	INCREMENT_LINE();
	sprintf(buffer[line], "*/\n\n");
	INCREMENT_LINE();

	function = NO_FUNCTION;
	prt_include = 0;
	while(fgets(s, MAX_SOURCE_LENGTH, in))
	{
		src_line++;
		if (strchr(s, '\n') == NULL)
		{
			fprintf(stderr,
				"%s: file:<%s> line:%d MAX_SOURCE_LENGTH exceeded\n", exe,
				src_path, src_line);
			exit(1);
		}

		/*
		**	Check for get_prt directives
		*/
		if (prt_include)
		{
			/*
			**	Check for STOP_PRT_INCLUDE
			*/
			if (!strncmp(s, "/*STOP_PRT_INCLUDE*/", 20))
			{
				prt_include = 0;
				continue;
			}
			sprintf(buffer[line], "%s", s);
			INCREMENT_LINE();
			continue;
		}
		else
		{
			if (!strncmp(s, "/*START_PRT_INCLUDE*/", 21))
			{
				prt_include = 1;
				continue;
			}
		}

		/*
		**	Check for preprocessor directives
		*/
		if (s[0] == '#')
		{
			ptr = s + 1;
			SKIP_WHITE_SPACE(ptr);
			if (!strncmp(ptr, "ifdef", 5) ||
				!strncmp(ptr, "ifndef", 6) ||
				!strncmp(ptr, "if", 2) ||
				!strncmp(ptr, "elif", 4) ||
				!strncmp(ptr, "else", 4) ||
				!strncmp(ptr, "endif", 5))
			{
				sprintf(buffer[line], "%s", s);
				INCREMENT_LINE();
			}
			continue;
		}

		/*
		**	remove trailing white space
		*/
		len = strlen(s);
		while(len > 0 && isspace(s[len-1]))
			len--;
		s[len] = '\0';


		if (function == NO_FUNCTION)
		{
			if (!strncmp(s, "static", 6) &&
				(s[len - 1] == '(' || s[len - 1] == ')'))
			{
				function = STATIC_FUNCTION;
				sprintf(buffer[line], "#ifdef %s\n", define);
				INCREMENT_LINE();
			}
			if (!strncmp(s, "extern", 6) &&
				(s[len - 1] == '(' || s[len - 1] == ')'))
			{
				function = EXTERN_FUNCTION;
			}
		}

		if (function)
		{
			if (s[0] == '{')
			{
				/*
				**	End of header
				*/

				/*
				** Notes -- 
				**  This will print out everything between the ")" and "{" ;
				**  in the case     extern func(decl) -- comments -- { 
				**  we will get all the comments;
				**  We can live with that, but there must be a newline
				**  before the ; so that we do not end up with something 
				**  bizarre:
				**
				**    extern func (
				**      char * arg)
				**    #ifdef junk
				**    #endif 
				**    {
				**
				**  This example would give 
				**
				**    extern func (
				**      char * arg)
				**    #ifdef junk
				**    #endif;
				**
				**	and the semicolon gets lost by the C preprocessor.
				*/

				sprintf(buffer[line], ";\n");
				INCREMENT_LINE();

				if (function == STATIC_FUNCTION)
				{
					sprintf(buffer[line], "#endif /* %s */\n", define);
					INCREMENT_LINE();
				}

				function = NO_FUNCTION;
			}
			else
			{
				/*
				**	Add code to buffer
				*/ 
				sprintf(buffer[line], "%s\n", s);
				INCREMENT_LINE();
			}
		}
	}
	fclose(in);
	buffer[line][0] = -1;

	/*
	**	open output file
	*/
	if ((out = fopen(new_path, OPEN_TO_WRITE_MODE)) == NULL)
	{
		fprintf(stderr, "%s: Unable to open file \"%s\".\n", exe, new_path);
		perror(exe);
		return;
	}

	line = 0;
	while(get_line(&ptr) != END_OF_BUFFER)
	{
		fputs(ptr, out);
	}

	fclose(out);

	DEBUG(("get_prt(): cur_path=<%s> new_path=<%s>\n", cur_path, new_path));

	if (diff(cur_path, new_path))
	{
#if defined(unix)
		printf("\t%s   ->   prt/%s\n", src_path, filename);
#endif
#if defined(WIN32) || defined(DOS)
		printf("\t%s   -to-   prt\\%s\n", src_path, filename);
#endif
		/*
		** remove the cur_path file (if exists) otherwise rename won't
		** be done.
		*/
		remove(cur_path);
		rename(new_path, cur_path);
	}
	else
	{
		DEBUG(("get_prt(): new_path=<%s>\n", new_path));
		remove(new_path);
	}
}

/******************************************************************************/

	/*
	** 	-o output_path 			
	**
	**    get_prt -o /usr/tmp  /x/y/junk1.c  -> /usr/tmp/prt/junk1.prt
	*/

static void handle_options( 
	int *counter, 
	int argc, 
	char *argv[])
{
	int i;
	FILE *in;
	char line[MAX_LINE_SIZE];
	char *filename;
	
	for (i = 1; i < argc; ++i)
	{
		if (argv[i][0] == '@')
		{
			if ((in = fopen(&argv[i][1],OPEN_TO_READ_MODE)) == NULL)
			{
				fprintf(stderr, "%s: file:<%s> not found.\n", exe, argv[i]);
				exit(1);
			}
			while(fgets(line, MAX_LINE_SIZE, in))
			{
				if ((filename = strtok(line, DELIMITERS)) != NULL)
				{
					do
					{
						get_prt(filename);
					} while ((filename = strtok(NULL, DELIMITERS)) != NULL);
				}
			}
			++i;
			break;
		}
		else if (argv[i][0] == '-')
		{
			switch (argv[i][1])
			{
				case 'o' :	
					++i;
					if ((int)strlen(argv[i]) > 255)
						strncpy(output_path,argv[i],255);
					else
						strcpy(output_path,argv[i]);
				break;
			}	
		}
		else
		{
			break;
		}
	}
	*counter = i;		/* what to adjust argc by */
}

/******************************************************************************/

main(argc, argv)
int argc;
char *argv[];
{
	int i;
	int j = 0;

	handle_options(&j,argc,argv);

	for (i = j; i< argc; i++)
	{
		DEBUG(("get_prt: argv[%d]=<%s>\n", i,argv[i]));
		get_prt(argv[i]);
	}

	return 0;
}

/******************************************************************************/
