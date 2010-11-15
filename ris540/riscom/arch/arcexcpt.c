/* Do not alter this SPC information: $Revision: 1.2.52.1 $ */
/*
**	NAME:							arcexcpt.c
**	AUTHORS:						David Michal
**	CREATION DATE:					10/88
**	ABSTRACT:
**		
**	Routine for handling floating point exceptions on the VAX.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#ifdef vms

#include <lib$routines.h>
#include "arch.h"
#include "risstjmp.h"

/*
**	DEFINES
*/
#define MTH$_FLOOVEMAT 0x1682c4
#define MTH$_FLOUNDMAT 0x1682cc


/*
**	VARIABLES
*/

static arc_s * current_arc;

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/

	/*
	** sys.prt must come before comjmp.prt in order to pick up the
	** include <setjmp.h> in sys.prt, otherwise we use jmp_buf before
	** it is known.  VAX
	*/
#define arcexcpt_c
#include "sys.prt"
#include "arcexcpt.prt"
#include "comjmp.prt"
#include "arcerrcd.prt"

/******************************************************************************/

	/*
	** The problem is that our error handling in ARC* expects
	** an arc_s pointer as an argument, but the signal handler
	** does not get one.  This routine can be called before establishing
	** a signal handler in order to have the correct arc_s.
	*/

extern void ARC_save_arc(
	arc_s * arc)
{
	current_arc = arc;
}

/******************************************************************************/

extern unsigned int ARC_handle_except(
	int * sigarr,
	int * mecharr)
{
	int except;

ARC_DBG(("\nARC_handle_except sigarr = 0x%x mecharr = 0x%x\n",sigarr,mecharr));

	except = LIB$MATCH_COND(&sigarr[1],&MTH$_FLOOVEMAT,&MTH$_FLOUNDMAT);
	switch(except)
	{
		case 1:

ARC_DBG(("overflow detected\n"));

			ARC_error(current_arc,ARC_OVERFLOW);
		break;
		case 2:

ARC_DBG(("underflow detected\n"));

			ARC_error(current_arc,ARC_UNDERFLOW);
		break;
		default:

/* Date 3/29/93, -goverdhan */

ARC_DBG(("other exception <%d> detected\n",except));
ARC_DBG(("exception is neither underflow or overflow, but we jump back\n"));
ARC_DBG(("with overflow error\n"));
			ARC_error(current_arc,ARC_OVERFLOW);

		break;
	}

	LONGJMP(1);	/* nonzero number is required but meaningless */
}

/******************************************************************************/

#endif
