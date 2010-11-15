/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							arcfc.c
**	AUTHORS:						Dan Karier
**	CREATION DATE:					04/93
**	ABSTRACT:
**	Routine to check that a clipper float is a valid number.
**	
**	This is based on the clipper/vax conversion routines; I simply took
**	the conversion routine, cut out the code that does anything, and
**	was left with the tests for valid numbers vs. NaN.
**	
**	This was written for the hydra (Intel/SCO unix).  The oracle code 
**  to convert floating point from chip representation to oracle internal
**	numeric results in a SIGFPE if it encounters a NaN, so we have to
**	verify that all input floating point values are valid.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/

#include  <stdio.h>
#include "arch.h"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define arcfc_c
#include "arcfc.prt"
#include "arcerrcd.prt"

/******************************************************************************/

/*
** convert a clipper float to a vax ffloat
*/

extern void ARC_clip_validate_float(
	arc_s * arc,
	clip_float * source
    )
{
ARC_DBG(("\nARC_clip_validate_float source = %g\n",*(clip_float *)source));

	if (
		(source->exp && source->exp < 255) ||
		(!source->exp && source->frac)     ||
		(!source->exp && !source->frac)    ||
		(source->exp == 255 && !source->frac)
	   )
	{
		/* valid number */
	}
	else
	{

		ARC_DBG(("ARC_clip_validate_float: NaN\n"));
		ARC_error(arc, ARC_NOT_A_NUMBER);
		if ((int)(arc->error_handler))
		{
			(*arc->error_handler)(arc);
			/* return(arc->error_code);	NOT NEEDED */
		}
		else
		{
			return;
		}
	}

}

/******************************************************************************/

