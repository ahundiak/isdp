/* Do not alter this SPC information: $Revision: 1.2.45.1 $ */
/*
**  NAME:                           intsserr.c
**  AUTHORS:                        Prasad Challa
**  CREATION DATE:                  12/91
**  ABSTRACT:
**
**
**  REVISION HISTORY:
**
**	01/95:	Changed the argument for RISapp_initialize from RIS_DEFAULT_LANGUAGE
**			to getenv("RIS_LANGUAGE"). Paula Blohm
*/

/*
**  INCLUDES
*/
#include "intrface.h"

/*
**  DEFINES
*/

/*
**  VARIABLES
*/

/*
**  FUNCTIONS
*/


/*
**      FUNCTION PROTOTYPES
*/
#define intsserr_c
#include "appbufto.prt"
#include "appinit.prt"
#include "appsndrc.prt"
#include "apptobuf.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comsqlca.prt"
#include "interror.prt"
#include "intrap.prt"
#include "intsserr.prt"
#include "sys.prt"


/******************************************************************************/

extern void RISAPI RISXint_report_superschema_error(
	char	*ss_name)
{
	int	sts;
	int cnt;
	int more_to_follow;

	INT_DBG(("RISint_report_superschema_error(ss_name:<%s>)\n",
		STRING(ss_name)));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "REPORT SS ERROR\n");
		fprintf(RIS_RAP, "ss_name:0x%x\n", ss_name);
		if (ss_name)
		{
			fprintf(RIS_RAP, "*ss_name:%s\n", ss_name);
		}
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		SET_RISCA(sts);
		RISrap_return();
		RIS_RETURN();
	}

	if (RIS_client_died)
	{
		LONGJMP(RIS_E_CLIENT_DIED);
	}

	if (!RIS_mem)
	{
		RISapp_initialize(getenv("RIS_LANGUAGE"));
	}
	if (!RIS_net)
	{
        /*
        ** No need to start client; return RIS_SUCCESS
        */
        LONGJMP(RIS_SUCCESS);
	}

	RISapp_report_ss_error_to_buf(ss_name);
	RISapp_send_rec();
	more_to_follow =
		RISapp_buf_to_report_ss_error(&RISsuperschema_error.primary);
	if (RISsuperschema_error.primary.schrisca.sqlcode)
	{
		RISsuperschema_error.primary.schrisca.sqlerrm.sqlerrml = (short)
			RISXint_error_msg(RISsuperschema_error.primary.schrisca.sqlcode,
				RISsuperschema_error.primary.schrisca.sqlerrm.sqlerrmc,0);
	}
	else
	{
		RISsuperschema_error.primary.schrisca.sqlerrm.sqlerrml = 0;
	}

	cnt = 0;
	while(more_to_follow)
	{
		if (cnt >= 9)
		{
			INT_DBG(("RISreport_superschema_error: cnt >= 9\n"));
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
		RISapp_report_ss_error_to_buf(NULL);
		RISapp_send_rec();
		more_to_follow = RISapp_buf_to_report_ss_error(
			&RISsuperschema_error.secondary[cnt]);

		/*
		**	The schrisca.sqlstmt is the same for the primary & secondaries.
		**  RISsuperschema_error.secondary[cnt].schrisca.sqlstmt =
		**	  RISsuperschema_error.primary.schrisca.sqlstmt;
		**
		**	The above statement causes big time problems as primary could
		**  realloc for larger amount and therefore secondaries would be
		**  pointing to invalid memory.
		**  This was fixed in 4.0.14.8 but got lost in 4.3.4.2.
		**	Terry & Hitesh 10/28/93
		*/

		if (RISsuperschema_error.secondary[cnt].schrisca.sqlcode)
		{
			RISsuperschema_error.secondary[cnt].schrisca.sqlerrm.sqlerrml =
			(short)RISXint_error_msg(
				RISsuperschema_error.secondary[cnt].schrisca.sqlcode,
				RISsuperschema_error.secondary[cnt].schrisca.sqlerrm.sqlerrmc,
				0);
		}
		else
		{
			RISsuperschema_error.secondary[cnt].schrisca.sqlerrm.sqlerrml = 0;
		}
		cnt++;
	}
	for (; cnt < 9; cnt++)
	{
		RISsuperschema_error.secondary[cnt].schname[0] = '\0';
        RIScom_clear_sqlca(&(RISsuperschema_error.secondary[cnt].schrisca));
        RIScom_clear_sqlca(&(RISsuperschema_error.secondary[cnt].schdbca));
	}

	RESETJMP();

	INT_DBG(("RISint_report_superschema_error:return\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/
