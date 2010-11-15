/* Do not alter this SPC information: $Revision: 1.6.3.1 $ */
/*
**	NAME:							clumain.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risutl.h"
#include "risver.h"
#include "risstjmp.h"
#include "utl_inf.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define clumain_c
#include "clumain.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "sys.prt"
#include "net_sys.prt"
#include "ucoerrbx.prt"
#include "ucoumsg.prt"

/*
**	VARIABLES
*/
char *sys1 = "`ipcs | awk 'BEGIN{print \"ipcrm\"} /^m.*0x524953/{print \"-m\", $2} /^s.*0x524953/{print \"-s\", $2}'` 2>/dev/null";

/* INFORMIX */
char *sys2 = 
"`ps -e | awk 'BEGIN { print \"kill -9\"} /risinf/ { print $1 }'` 2>/dev/null";

/* ORACLE */
char *sys3 = 
"`ps -e | awk 'BEGIN { print \"kill -9\"} /risora/ { print $1 }'` 2>/dev/null";

/* INGRES */
char *sys4 = 
"`ps -e | awk 'BEGIN { print \"kill -9\"} /rising/ { print $1 }'` 2>/dev/null";

/* DB2 */
char *sys5 = 
"`ps -e | awk 'BEGIN { print \"kill -9\"} /risdb2/ { print $1 }'` 2>/dev/null";

/* SYBASE */
char *sys6 = 
"`ps -e | awk 'BEGIN { print \"kill -9\"} /rissyb/ { print $1 }'` 2>/dev/null";

/* AS400 */
char *sys7 = 
"`ps -e | awk 'BEGIN { print \"kill -9\"} /risos4/ { print $1 }'` 2>/dev/null";

/* RIS CLIENT */
char *sys8 = 
"`ps -e | awk 'BEGIN { print \"kill -9\"} /riscli/ { print $1 }'` 2>/dev/null";

#define DBASE_ENTRIES 8
#define MEM_LEN  ((lic_users * 36) + 2)                                   
#define BADADDR (char *)(-1)

static void clear_license()
{
#if defined(unix)

/*    Database order is INFORMIX SYBASE ORACLE INGRES DB2 RDB OS400 MSSQL*/

char  semamemory[DBASE_ENTRIES][60]={"ipcrm -S 7679311 -M 8375352 2> /dev/null",
                                     "ipcrm -S 7679312 -M 8375353 2> /dev/null",
                                     "ipcrm -S 7679313 -M 8375354 2> /dev/null",
                                     "ipcrm -S 7679314 -M 8375355 2> /dev/null",
                                     "ipcrm -S 7679315 -M 8375356 2> /dev/null",
                                     "ipcrm -S 7679316 -M 8375357 2> /dev/null",
                                     "ipcrm -S 7679317 -M 8375358 2> /dev/null",
                                     "ipcrm -S 7679318 -M 8375359 2> /dev/null"};
int i;

      for (i = 0; i < DBASE_ENTRIES ; i++)
       {
          system(semamemory[i]);

       }
#endif   /* Hardware support list */

}

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int main(
	int argc,
	char *argv[])
{

	if (argc == 2)
	{
		if (strcmp(argv[1],"-V")==0)
		{
			DoVersion();
			return(0);
		}
		if (strcmp(argv[1],"-?")==0)
		{
			DoUsage();
			return(0);
		}

		DoUsage();
		return(1);
	}
	else if (argc > 2)
	{
		DoUsage();
		return(1);
	}

	/*
	**	free shared memory and semaphores and kill client and server processes
	*/
	system(sys1);
	system(sys2);
	system(sys3);
	system(sys4);
	system(sys5);
	system(sys6);
	system(sys7);
	system(sys8);

        clear_license();

	return 0;
}

/******************************************************************************/

static int init_ums()
{
	int status;

	status = SETJMP();
	if (status)
	{
		RESETJMP();

		RISuco_file_error_box(stdout, RISUTL_I_CLNUP_ERROR,0,status,NULL,0,1);
		PRINTF(CHECK_UNINIT_MSG(RISUTL_I_CLNUP_COULD_NOT_INIT,
			"RIS Clean Up Utility could not initialize... Bye\n"));
 		return 1;
	}

	RISuco_initialize_ums(INIT_UTL_UMS_FILE);

	RESETJMP();
	return 0;
}

/******************************************************************************/

static void DoVersion()
{
	if (init_ums()) return;

	/*PRINTF(MSG(RISUTL_I_COPYRIGHT));*/
	/* 1996.03.12:Alan Barksdale:TR439600483 */
	PRINTF(MSG(RISUTL_I_BEGIN_COPYRIGHT));
	PRINTF(" ");
	PRINTF(COPYRIGHTYEAR);
	PRINTF(", ");
	PRINTF(MSG(RISUTL_I_END_COPYRIGHT));
	PRINTF(MSG(RISUTL_I_CLNUP_UTILITY), RIS_version);
}

/******************************************************************************/

static void DoUsage()
{
	if (init_ums()) return;

	PRINTF(MSG(RISUTL_I_CLNUP_USAGE_1));
	PRINTF(MSG(RISUTL_I_CLNUP_USAGE_2));
	PRINTF(MSG(RISUTL_I_CLNUP_USAGE_3));
	PRINTF(MSG(RISUTL_I_CLNUP_USAGE_4));
	PRINTF(MSG(RISUTL_I_CLNUP_USAGE_5));
}

/******************************************************************************/
