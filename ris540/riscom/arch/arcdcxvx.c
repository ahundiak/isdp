/* Do not alter this SPC information: $Revision: 1.2.52.1 $ */
/*
**	NAME:							arcdcxvx.c
**	AUTHORS:						David Michal
**	CREATION DATE:					10/88
**	ABSTRACT:
**	Conversion routine for clipper double to vax dfloat
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#ifdef vms

#include <signal.h>
#include <stdio.h>
#include "arch.h"
#include "risstjmp.h"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/
extern double MTH$CVT_G_D();

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define arcdcxvx_c
#include "arcdcxvx.prt"
#include "arcerrcd.prt"
#include "arcexcpt.prt"
#include "comjmp.prt"
#include "sys.prt"



/******************************************************************************/

/*
** convert a clipper double to a vax dfloat
*/

extern void ARC_clip_to_vax_double(
	arc_s * arc,
	clip_double * source,
    int len)
{
	vax_gfloat dest;
	vax_dfloat * final_dest;
	int shift = 0;
	double * dfloat_val;

	struct swapper { unsigned x1 : 32;
                     unsigned x2 : 32;
					} swapper;

ARC_DBG(("\nARC_clip_to_vax_double arc = 0x%x source = %x\n",arc,source));

/* set up pointers */

	final_dest = source;
	dfloat_val = final_dest;

ARC_DBG(("sign = %x exp = %x high_frac = %x low_frac = %x\n",
 source->sign,source->exp,source->high_frac,source->low_frac));

/* normal clipper numbers */

	if (source->exp && source->exp < 2047)
	{

ARC_DBG(("normal\n"));

/* the sign remains the same */

		dest.sign = source->sign;

/*
** adjust exponent
** clipper: execess 1023 vax: excess 1024
** clipper: implied 1 to left of decimal vax: implied 1 to right of decimal
** add two to the clipper exponent to get the vax exponent
** note: a clipper exponent of 2046 or 2047 has no vax equivalent
*/

ARC_DBG(("exponent = %d\n",source->exp));

/*
** Date 3/29/93, bug fix for TRs 249301365,249301367, exponent limit is 
** changed to 2046 from 2047. -goverdhan
*/
		if (source->exp < 2046)
		{
			dest.exp = source->exp+2;
		}
		else
		{
		/*	LONGJMP(ARC_OVERFLOW); */
			ARC_error(arc, ARC_OVERFLOW);
			return;
		}

/*
** split fraction
** clipper: 20 and 32 bit fractions vax: 4, 16, and 32 bit fractions
*/

		dest.high_frac = source->high_frac >> 16;
		dest.med_frac = source->high_frac;
		dest.low_frac = source->low_frac;
	}

/* denornamlized numbers */

	else if (!source->exp && (source->high_frac || source->low_frac))
	{

ARC_DBG(("denormal\n"));

/* most denormalized numbers on clipper are too small for the vax */

ARC_DBG(("high_frac = %x\n",source->high_frac));

/* these denormalized numbers can be represented on the vax */

		if (source->high_frac & 0xc0000)
		{

/* the sign remains the same */

			dest.sign = source->sign;

/* set exponent */

			if (source->high_frac & 0x80000)
			{
				shift = 1;
				dest.exp = 2;
			}
			else
			{
				shift = 2;
				dest.exp = 1;
			}

/* split the fraction shifted by 1 or 2 for the implict 1 on the vax */

			dest.high_frac = source->high_frac >> 16 - shift;
			dest.med_frac = source->high_frac << shift | 
			 source->low_frac >> 32 - shift;
			dest.low_frac = source->low_frac << shift;
		}
		else
		{

/* these can not  so return an error */

		/*	LONGJMP(ARC_UNDERFLOW); */
			ARC_error(arc, ARC_UNDERFLOW);
			return;
		}
	}

/* zero */

	else if (!source->exp && !(source->high_frac || source->low_frac))
	{

ARC_DBG(("zero\n"));

/* 
** clipper and vax representations of zero are the same except clipper allows
** negative zero
** set vax to positive zero
*/

		dest.sign = 0;
		dest.exp = 0;
		dest.low_frac = 0;
		dest.med_frac = 0;
		dest.high_frac = 0;
	}

/* infinity */

	else if (source->exp == 2048 && !(source->high_frac || source->low_frac))
	{

ARC_DBG(("infinity\n"));

/*
** clipper has infinity representation vax does not
** return an error
*/

	/*	LONGJMP(ARC_OVERFLOW); */
		ARC_error(arc, ARC_OVERFLOW);
		return;
	}

/* NaNs */

	else
	{

ARC_DBG(("NaN\n"));

/*
** clipper has NaN representations vax does not
** return an error
*/

	/*	LONGJMP(ARC_NOT_A_NUMBER); */
		ARC_error(arc, ARC_NOT_A_NUMBER);
		return;
	}

/* we need to swap the shorts of the completed low fraction */

    swapper.x1 = (unsigned) dest.low_frac;
    swapper.x2 = 0;
	swapper.x2 = ((unsigned) (swapper.x1 <<16))|((unsigned)(swapper.x1 >> 16));
	dest.low_frac = (unsigned) swapper.x2;



ARC_DBG((
 "gfloat sign = %x exp = %x high_frac = %x med_frac = %x low_frac = %x\n",
 dest.sign,dest.exp,dest.high_frac,dest.med_frac,dest.low_frac));

/* replace input float with output float converted to a dfloat */

	if (SETJMP())
	{
			/*
			** The error handler "ARC_handle_except" will longjump to here;
			** after that we just return because the error has been set.
			*/
		RESETJMP();
		ignore_underflow();
		return;
	}

	catch_underflow();
	ARC_save_arc(arc);
	VAXC$ESTABLISH(ARC_handle_except);

	*dfloat_val = MTH$CVT_G_D(&dest);

	RESETJMP();
	ignore_underflow();

ARC_DBG((
 "dfloat sign = %x exp = %x high_frac = %x med_frac = %x low_frac = %x\n",
 final_dest->sign,final_dest->exp,final_dest->high_frac,final_dest->med_frac,
 final_dest->low_frac));

}

/******************************************************************************/
static void catch_underflow(
	)
{
	unsigned underflow_detection = 1;
	LIB$FLT_UNDER(&underflow_detection);
}

static void ignore_underflow(
	)
{
	unsigned underflow_detection = 0;
	LIB$FLT_UNDER(&underflow_detection);
}
#endif
