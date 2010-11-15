/* Do not alter this SPC information: $Revision: 1.3.22.1 $ */
/*
**	NAME:							m.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

#define GLOBAL_DEFINE
 
/*
**	INCLUDES
*/
#if defined(unix)
#include <signal.h>
#endif
#include "mm.h"

/*
**	DEFINES
*/
#define MAX_SOURCE	50

/*
**	TYPES
*/
typedef struct source_data_s
{
	int		type;
	char	name[PATH_MAX];
	char	obj[PATH_MAX];
}source_data_s;

/*
**	FUNCTION PROTOTYPES
*/
#define mm_c
#include "define.prt"
#include "mm.prt"
#include "output.prt"
#include "path.prt"
#include "read.prt"
#include "readm.prt"
#include "special.prt"
#include "sys.prt"
#if defined(WIN32) || defined(DOS) || defined(WIN32S)
#include "getopt.prt"
#endif

/*
**	VARIABLES
*/
int				c_count = 0;
int				rc_count = 0;
int				unk_count = 0;
int				source_count = 0;
#if defined(__hpux__)
static source_data_s    source[MAX_SOURCE];
#else
source_data_s	source[MAX_SOURCE];
#endif
extern char *optarg;
extern int optind;

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern void control_c(
	int sig)
{
	sig = sig;
	fprintf(stderr, "\n\n%s: User interrupt\n\n", exe);
	EXIT(1);
}

/******************************************************************************/

extern void add_source(
	int		type,
	char	*name,
	char	*obj)
{
	DBG(("add_source(name:<%s> obj:<%s>)\n", name, obj));

	if (source_count == MAX_SOURCE)
	{
		fprintf(stderr, "%s: increase MAX_SOURCE(%d) in \"%s\".\n",
			exe, MAX_SOURCE, __FILE__);
		EXIT(1);
	}

	source[source_count].type = type;
	strcpy(source[source_count].name, name);
	strcpy(source[source_count].obj, obj);

	switch(type)
	{
		case C_TYPE:
			c_count++;
			break;

		case RC_TYPE:
			rc_count++;
			break;

		case UNK_TYPE:
		default:
			unk_count++;
			break;
	}
	source_count++;

	DBG(("add_source returning\n"));
}

/******************************************************************************/

static void write_objects()
{
	int i;

	if (c_count)
	{
		output("\nC_OBJECTS=");
		for (i = 0; i < source_count; i++)
		{
			if (source[i].type == C_TYPE)
			{
				output("\\\n\t%s", source[i].obj);
			}
		}
		output("\n");
	}

	if (rc_count)
	{
		output("\nRC_OBJECTS=");
		for (i = 0; i < source_count; i++)
		{
			if (source[i].type == RC_TYPE)
			{
				output("\\\n\t%s", source[i].obj);
			}
		}
		output("\n");
	}

	if (unk_count)
	{
		output("\nUNK_OBJECTS=");
		for (i = 0; i < source_count; i++)
		{
			if (source[i].type == UNK_TYPE)
			{
				output("\\\n\t%s", source[i].obj);
			}
		}
		output("\n");
	}

	output("\nOBJECTS=");
	if (c_count) output("\\\n\t$(C_OBJECTS)");
	if (rc_count) output("\\\n\t$(RC_OBJECTS)");
	if (unk_count) output("\\\n\t$(UNK_OBJECTS)");
	output("\n");
}

/******************************************************************************/

static void Usage()
{
	fprintf(stderr, "Usage: %s [-w] [-o output] [-D define]... filename\n",exe);
	EXIT(1);
}

/******************************************************************************/

extern void main(
	int		argc,
	char	*argv[])
{
	int	c;
	int i;
	int oflag = 0;

#if defined(unix)
	sigset(SIGINT, control_c);
#endif

	add_define("MM");

#if defined(unix)
	add_define("unix");
#endif
#if defined(vms)
	add_define("vms");
#endif
#if defined(WIN32) && !defined(WIN32S)
	add_define("WIN32");
#endif
#if defined(WIN32S)
	add_define("WIN32S");
#endif
#if defined(DOS)
	add_define("DOS");
#endif
#if defined(__clipper__)
	add_define("__clipper__");
#endif
#if defined(sun)
	add_define("sun");
#endif
#if defined(sco)
	add_define("sco");
#endif
#if defined(__Sol2__)
	add_define("__Sol2__");
#endif
#if defined(Soli)
	add_define("Soli");
#endif
#if defined(__hpux__)
	add_define("__hpux__");
#endif

	while((c = getopt(argc, argv, "D:o:w")) != -1)
	{
		switch(c)
		{
			case 'D':
				add_define(optarg);	
				break;

			case 'o':
				if (oflag)
				{
					Usage();
				}
				oflag = 1;
				open_output_file(optarg);
				break;

			case 'w':
				warnings = 1;
				break;

			default:
				Usage();
		}
	}
	
	if (optind != argc - 1)
	{
		Usage();
	}

	read_m_file(argv[optind]);
	
	output("SRC=%s\n", src);

	write_I_path();

	write_objects();

	write_pre_special();

	output("\nobjects: $(OBJECTS)\n");
	if (c_count) output("\nc_objects: $(C_OBJECTS)\n");
	if (rc_count) output("\nrc_objects: $(RC_OBJECTS)\n");
	if (unk_count) output("\nunk_objects: $(RC_OBJECTS)\n");

	for (i = 0; i < source_count; i++)
	{
		read_dependencies(source[i].name, source[i].obj);
	}

	write_post_special();

	EXIT(error_count);
}

/******************************************************************************/
