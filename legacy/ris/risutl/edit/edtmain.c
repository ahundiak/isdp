/* Do not alter this SPC information: $Revision: 1.2.9.1 $ */
/*
**	NAME:							edtmain.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					3/88
**	ABSTRACT:
**	
**	REVISION HISTORY:
**      Modified to support double-byte char format for Hangul.
**                                -- Hitesh R. Patel (10/19/92)
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "risutl.h"
#include "ucommon.h"
#include "edit.h"

/*
**	DEFINES
*/
#define BUFFER_SIZE				10000
#define SKIP_WHITE_SPACE(ptr)	{while(*ptr && RIScom_isspace(*ptr)) ptr++;}

#define EDITOR					"editor"
#define EDITOR_LEN				(sizeof(EDITOR)-1)

#define DEBUG					"debug"
#define DEBUG_LEN				(sizeof(DEBUG)-1)
 

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define edtmain_c
#include "comdebug.prt"
#include "edtmain.prt"
#include "edtgets.prt"
#include "edtgtcmd.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
debug_info_s debug_info[] =
{
	{	"edt",	3,	&RISedt_debug	}
};
int debug_count	= sizeof(debug_info)/sizeof(debug_info_s);

int NET_debug = 0;
int ARC_debug = 0;

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int main(
	int		argc,
	char	*argv[])
{
	int		cnt;
	char	*ptr;
	char	buf[BUFFER_SIZE];
	char	editor[8] = "vi";

	RISuco_initialize_debug(debug_info, debug_count);

    if (argc > 1)
    {
        for (cnt = 1; cnt < argc; cnt++)
        {
            if (strcmp(argv[cnt],"-e") == 0)
            {
                strcpy(editor,"emacs");
            }
			else
			{
				printf("Usage: %s [-e]\n");
			}
        }
    }

	printf("\nRIS Interactive Utility\n");

	if (EDT_init(editor))
	{
		printf("\nRIS Initialization Failed\n");
		exit(1);
	}

	printf("\nRIS Initialized Successfully... \n");


	for(;;)
	{
		printf("\n");
		EDT_getcmd(buf, BUFFER_SIZE, 0);
		printf("\nline --> <%s>\n",buf);

		if (*buf == 'q') 
		{
			break;
		}

		if (!strncmp(buf, EDITOR,  EDITOR_LEN))
		{
			ptr = buf + EDITOR_LEN;
			SKIP_WHITE_SPACE(ptr);

			if (!strcmp(ptr, "vi") || !strcmp(ptr, "emacs"))
			{
				EDT_set_edit_style(ptr);
				printf("\neditor set to \"%s\"\n", ptr);
			}
		}

		if (!strncmp(buf, DEBUG,  DEBUG_LEN))
		{
			ptr = buf + DEBUG_LEN;
			SKIP_WHITE_SPACE(ptr);

			if (!strcmp(ptr, "off") || !strcmp(ptr, "OFF"))
			{
				RISedt_debug = 0;
			}
			else if (!strcmp(ptr, "on") || !strcmp(ptr, "ON"))
			{
				RISedt_debug = 1;
			}
			printf("\nEDT_DBG is %s\n", RISedt_debug ? "ON" : "OFF");
		}
	}

	EDT_terminate();

	return 0;
}

/******************************************************************************/

extern void RISint_process_debug_no_output(
	char *s)
{
	int		app_flag = 0;
	int		cli_flag = 0;
	int		srv_flag = 0;
	char	*sts;

	sts = RIScom_debug_flags(s, &app_flag, &cli_flag, &srv_flag);
}

/******************************************************************************/
