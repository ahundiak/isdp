/* Do not alter this PINNACLE information: $Revision: 1.2.28.1 $ */
/*
**	NAME:							comjmp.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					2/89
**	ABSTRACT:
**	
**	REVISION HISTORY:
**          Changed the call from strrchr to RIScom_strrchr to handle multibyte
**          characters. Paula 10/17/94
*/
 
/*
**	INCLUDES
*/
#include "risdebug.h"
#include "risstjmp.h"
#include "rispath.h"
#include "commacro.h"
/*START_PRT_INCLUDE*/
#include <setjmp.h>
/*STOP_PRT_INCLUDE*/


/*
**	DEFINES
*/
#define JMPS 10

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define comjmp_c
#include "comjmp.prt"
#include "comdebug.prt"
#include "comuni.prt"
#include "sys.prt"


/*
**	VARIABLES
*/
static  struct
{
	jmp_buf	jmp;
	char	*file;
	int		line;
} RIS_jmp[JMPS];

/*
**	FUNCTIONS
*/

/******************************************************************************/

static char *get_filename(
	char *path)
{
	char *ptr;
	char *return_sts;

	if (path)
	{
		if ((ptr = RIScom_strrchr(path, PATH_CHAR)) != NULL)
		{
			return_sts = ptr + 1;
		}
		else
		{
			return_sts = path;
		}
	}
	else
	{
		return_sts = "";
	}

	return return_sts;
}

/******************************************************************************/

extern void RIScom_longjmp(
	int		st,
	char	*file,
	int		line)
{
	if (RIS_cnt < 0)
	{
		JMP_DBG(("FATAL LONGJMP ERROR: no environment\n"));
		_exit(st);
	}

	JMP_DBG(("LONGJMP st:0x%x FROM %s, %d TO %s, %d\n",
		st, get_filename(file), line, get_filename(RIS_jmp[RIS_cnt].file),
		RIS_jmp[RIS_cnt].line));

	longjmp(RIS_jmp[RIS_cnt].jmp, st);
}

/******************************************************************************/

extern void RIScom_resetjmp(
	char	*file,
	int		line)
{
	JMP_DBG(("RESETJMP from %s, %d\n", get_filename(file),line));

	if (RIS_cnt < 0)
	{
		JMP_DBG(("FATAL ERROR: RIS_cnt < 0 in resetjmp\n"));
		_exit(-1);
	}

	--RIS_cnt;
}

/******************************************************************************/

extern jmp_buf *RIScom_setjmp(
	char	*file,
	int		line)
{
	jmp_buf *ptr;

	JMP_DBG(("SETJMP in %s, %d\n", get_filename(file), line));

	if (RIS_cnt >= (JMPS-1))
	{
		JMP_DBG(("FATAL ERROR: RIS_cnt >= (JMPS-1) in setjmp\n"));
		_exit(-1);
	}

	++RIS_cnt;

	RIS_jmp[RIS_cnt].file = file;
	RIS_jmp[RIS_cnt].line = line;
	ptr = &RIS_jmp[RIS_cnt].jmp;
	return(ptr);
}

/******************************************************************************/
