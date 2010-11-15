/*
**	NAME:							intdebug.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					5/87
**	ABSTRACT:
**				set debug flags
**	
**	REVISION HISTORY:
**
*/
 
/*
**	INCLUDES
*/
#include "intrface.h"
#include "ris_inf.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define intdebug_c
#include "apptobuf.prt"
#include "appsndrc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "intdebug.prt"
#if defined(WIN32) || defined(DOS) || defined(sco) || defined(__hpux__)
#include "interror.prt" 
#endif
#include "intrap.prt"
#include "sys.prt"

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void process_debug(
	char	*s,
	char	output_flag)
{
	int		app_flag = 0;
	int		cli_flag = 0;
	int		srv_flag = 0;
	char	*sts;

	INT_DBG(("RISint_process_debug(s:<%s> output_flag:%d)\n", s, output_flag));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "DEBUG\n");
		fprintf(RIS_RAP, "s:0x%x\n", s);
		if (s)
		{
			fprintf(RIS_RAP, "*s:%s\n", s);
		}
		fprintf(RIS_RAP, "output_flag:%d\n", output_flag);
	RISrap_enter_END();

	sts = RIScom_debug_flags(s, &app_flag, &cli_flag, &srv_flag);

	if (RIS_mem && RIS_net && (cli_flag || srv_flag))
	{
		if (!SETJMP())
		{
			RISapp_debug_to_buf(srv_flag);
			RISapp_send_rec();
		}
		RESETJMP();
	}

	INT_DBG(("RISint_process_debug:complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/
/*** Melania M Stewart - Sept 1996 - TR#439602060 - Used for risrecrd when debug is
   On - enable the debug, but do not log on the RAP file ***/
static void process_debug_noRAP(
	char	*s,
	char	output_flag)
{
	int		app_flag = 0;
	int		cli_flag = 0;
	int		srv_flag = 0;
	char	*sts;

	INT_DBG(("RISint_process_debug_noRAP(s:<%s> output_flag:%d)\n", s, output_flag));

	RIS_ENTER();
/*************************************** Commented out ********************
	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "DEBUG\n");
		fprintf(RIS_RAP, "s:0x%x\n", s);
		if (s)
		{
			fprintf(RIS_RAP, "*s:%s\n", s);
		}
		fprintf(RIS_RAP, "output_flag:%d\n", output_flag);
	RISrap_enter_END();
********************************************************************************/
	sts = RIScom_debug_flags(s, &app_flag, &cli_flag, &srv_flag);

	if (RIS_mem && RIS_net && (cli_flag || srv_flag))
	{
		if (!SETJMP())
		{
			RISapp_debug_to_buf(srv_flag);
			RISapp_send_rec();
		}
		RESETJMP();
	}

	INT_DBG(("RISint_process_debug_noRAP:complete\n"));

	SET_RISCA(RIS_SUCCESS);
/**************************************** Commented out ****************************	
	RISrap_return();
************************************************************************************/	
	RIS_RETURN();
}

/******************************************************************************/

extern void RISAPI RISXint_process_debug(
	char *s)
{
	process_debug(s, 1);
}

/******************************************************************************/

extern void RISAPI RISXint_process_debug_noRAP(
	char *s)
{
	process_debug_noRAP(s, 1);
}

/******************************************************************************/

extern void RISAPI RISXint_process_debug_no_output(
	char *s)
{
	process_debug(s, 0);
}

/******************************************************************************/

extern void RISAPI RISXint_process_debug_no_output_noRAP(
	char *s)
{
	process_debug_noRAP(s, 0);
}

/******************************************************************************/

extern void RISAPI RISXint_get_debug_flags(
	char	*s)
{
	INT_DBG(("RISint_get_debug_flag(s:0x%x)\n", s));

	RIScom_get_debug_flags(s);

	SET_RISCA(RIS_SUCCESS);

	INT_DBG(("RISint_get_debug_flags:complete\n"));

	RIS_RETURN();
}

/******************************************************************************/
