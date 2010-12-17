/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							arcdc.c
**	AUTHORS:						Dan Karier
**	CREATION DATE:					4/93
**	ABSTRACT:
**	Routine to check that a clipper double is a valid number.
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

#include <stdio.h>
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
#define arcdc_c
#include "arcdc.prt"
#include "arcerrcd.prt"



/******************************************************************************/

extern void ARC_clip_validate_double(
	arc_s * arc,
	clip_double * source
	)
{

	ARC_DBG(("\nARC_clip_validate_double,  source = %lg\n",*(double *)source));


	if	(
		(source->exp && source->exp < 2047) ||
		(!source->exp && (source->high_frac || source->low_frac)) ||
		(!source->exp && !(source->high_frac || source->low_frac)) ||
		(source->exp == 2047 && !(source->high_frac || source->low_frac)) 
		)
		{
			/* valid double */
		}
	else
	{
		ARC_DBG(("ARC_clip_validate_double: NaN\n"));
		ARC_error(arc, ARC_NOT_A_NUMBER);
		if ((int)(arc->error_handler))
		{
			(*arc->error_handler)(arc);
			/* return(arc->error_code); NOT NEEDED */
		}
		else
		{
			return;
		}
	}
}

/******************************************************************************/
