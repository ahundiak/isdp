/* Do not alter this SPC information: $Revision: 1.5.3.1 $ */
/*
**	NAME:							utlinit.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					5/87
**	ABSTRACT:
**		Initialization for the interactive utility.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "rismem.h"
#include "util.h"
#include "risver.h"

/*
**	DEFINES
*/
#define DEFAULT_EDIT_STYLE	"vi"

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define utlinit_c
#include "utlinit.prt"
#include "sys.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "edtgets.prt"
#include "ris.prt"
#include "utlerror.prt"
#include "utlintrp.prt"
#if defined(WIN32) || defined(DOS)
# include "ucogtopt.prt"
#endif

/*
**	VARIABLES
*/
extern int optind;
extern char *optarg;


/*
**	FUNCTIONS
*/

/******************************************************************************/

static void USAGE()
{
	printf(MSG(RISUTL_I_RIS_USAGE_1));
	printf(MSG(RISUTL_I_RIS_USAGE_2));
	printf(MSG(RISUTL_I_RIS_USAGE_3));
	printf(MSG(RISUTL_I_RIS_USAGE_4));
	printf(MSG(RISUTL_I_RIS_USAGE_5));
	printf(MSG(RISUTL_I_RIS_USAGE_6));
}

/******************************************************************************/

extern void RISutl_init(
	int		argc,
	char	*argv[])
{
	int		c, i;
	char	*s;
	char	*edit_style = DEFAULT_EDIT_STYLE;

	UTL_DBG(("RISutl_init()\n"));

	/*
	**	Initialize interrupt handler
	*/
	RISutl_init_interrupt();

	/*
	**	Process args
	*/
	while((c = getopt(argc, argv, "et?V")) != -1)
	{
		switch (c)
		{
			case 'e':	
				edit_style = "emacs";
				break;

			case 't':
				RISutl_testbed_output = 1;
				break;

			case 'V':
				/*printf(MSG(RISUTL_I_COPYRIGHT));*/
				/* 1996.03.12:Alan Barksdale:TR439600483 */
				printf(MSG(RISUTL_I_BEGIN_COPYRIGHT));
				printf(" ");
				printf(COPYRIGHTYEAR);
				printf(", ");
				printf(MSG(RISUTL_I_END_COPYRIGHT));
				printf(MSG(RISUTL_I_REL_INT_SYS), RIS_version);
				exit(1);

			case '?':
			default:
				USAGE();
				exit(1);
		}
	}
	if (optind < argc)
	{
		USAGE();
		exit(1);
	}

	EDT_init(edit_style);

	RISutl_file_tos =
		(struct RISutl_file_stack*)malloc(sizeof(struct RISutl_file_stack));
	RISutl_file_tos->file = stdin;
	RISutl_file_tos->next = 0;

	/*
	**	Initialize RIS
	*/
	RISinitialize(getenv("RIS_LANGUAGE"));
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	/*
	**	Fill ris_parameters
	*/
	RISget_parameters(&RISutl_parameters);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	/*
	** Dynamic allocate memory for RISutl_stmts
	*/
	RISutl_stmts = (ris_utl_stmt *)calloc(RISutl_parameters.max_user_stmts,
		sizeof(ris_utl_stmt));
	if (RISutl_stmts == NULL)
	{
		LONGJMP(RISUTL_E_MALLOC);
	}

	for (i = 0; i < RISutl_parameters.max_user_stmts; i++)
	{
		RISutl_stmts[i].stmt_id = -1;
	}

	/*
	**	Check for $LINES
	*/
	if ((s = getenv("LINES")) != NULL)
	{
		int lines;

		if ((lines = atoi(s)) > 0)
		{
			RISutl_rows = lines;
		}
	}

	/*
	**	Check for $COLUMNS
	*/
	if ((s = getenv("COLUMNS")) != NULL)
	{
		int columns;

		if ((columns = atoi(s)) > 0)
		{
			RISutl_columns = columns;
		}
	}

	UTL_DBG(("RISutl_init:returning\n"));
}

/******************************************************************************/


