/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlmain.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					3/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**		Feb 6,1990 - modified to be placed in the shared library. It will now
**		be called by main() in ris/main/client_main.c
**		RISutl_main will also be the only function in the branch
**		table that is not in the "interface" directory.
**
*/
 
/*
**	DEFINES
*/

#define UTL_REPORT_WARNING() \
if (RISutl_warnings[0] == 'W') \
{\
 int i;\
 RISuco_file_warning_box(stdout, RISutl_warnings, 1);\
 for (i=0;i<8;i++) RISutl_warnings[i]='\0';\
}

#define UTL_REPORT_ERROR(status) \
if (status == RISUTL_E_RIS_ERROR)\
{\
 if (RISutl_ris_error[0])\
 {\
  RISutl_output_ris_error(RISutl_ris_error);\
  RISutl_clear_ris_error();\
 }\
 if (RISutl_ss_error.primary.schname[0])\
 {\
  RISutl_output_ss_error(&RISutl_ss_error);\
  RISutl_clear_ss_error();\
 }\
}\
else\
{\
 RISuco_file_error_box(stdout,RISUTL_I_RISUTL_ERROR,0,status,RISutl_line,0,1);\
}

/*
**	INCLUDES
*/
#include "util.h"

/*
**	FUNCTION PROTOTYPES
*/
#define utlmain_c
#include "comjmp.prt"
#include "utlcmd.prt"
#include "utlinit.prt"
#include "utlmain.prt"
#include "utlread.prt"
#include "utlerror.prt"
#include "utloutpt.prt"
#include "ucoerrbx.prt"
#include "ucodebug.prt"
#include "ucoumsg.prt"
#include "ris.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int main(
	int argc,
	char *argv[])
{
	int		one = 1; /* shut up compiler */
	int		status;

	if (RISload_dll()) return(1);

	status = SETJMP();
	if (status)
	{
		RESETJMP();

		UTL_REPORT_ERROR(status);
		printf(CHECK_UNINIT_MSG(RISUTL_I_COULD_NOT_INIT,
			"RIS Interactive Utility could not initialize... Bye\n"));
 		exit(1);
	}

	RISuco_initialize_debug(RISutl_debug_info, RISutl_debug_count);
	RISuco_initialize_ums(
		INIT_UTL_UMS_FILE|INIT_RIS_UMS_FILE|INIT_NET_UMS_FILE);

	RISutl_init(argc, argv);

	RESETJMP();

	status = SETJMP();

	while(one)
	{
		if (status)
		{
			if (RISutl_file_tos->next && !RISutl_ignore_errors_flag)
			{
				RISutl_stop_read(STOP_READ_ERROR);
			}

			UTL_REPORT_WARNING();
			UTL_REPORT_ERROR(status);

			status = 0;
		}

		printf("\n");
		RISutl_command();
	}

	return 0;
}

/******************************************************************************/
