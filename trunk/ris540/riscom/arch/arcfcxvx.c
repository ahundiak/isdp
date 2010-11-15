/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							arcfcxvx.c
**	AUTHORS:						David Michal
**	CREATION DATE:					10/88
**	ABSTRACT:
**	Conversion routine for clipper float to vax ffloat
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#ifdef vms

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
#define arcfcxvx_c
#include "arcerrcd.prt"
#include "arcfcxvx.prt"
#include "sys.prt"

/******************************************************************************/

/*
** convert a clipper float to a vax ffloat
*/

extern void ARC_clip_to_vax_float(
	arc_s * arc,
	clip_float * source,
    int len)
{
	vax_ffloat dest;
	vax_ffloat * final_dest;
	int shift;

ARC_DBG(("\nARC_clip_to_vax_float arc = 0x%x source = %x\n",arc,source));

/* set up pointers */

	final_dest = source;

ARC_DBG(("sign = %x exp = %x frac = %x\n",
 source->sign,source->exp,source->frac));

/* normal numbers */

	if (source->exp && source->exp < 255)
	{

ARC_DBG(("normal\n"));

/* the sign remains the same */

		dest.sign = source->sign;

/*
** adjust exponent
** clipper: execess 127 vax: excess 128
** clipper: implied 1 to left of decimal vax: implied 1 to right of decimal
** add two to the clipper exponent to get the vax exponent
** note: a clipper exponent of 254 has no vax equivalent
*/

ARC_DBG(("exponent = %d\n",source->exp));

		if (source->exp < 254)
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
** clipper: 23 bit fraction vax: 7 and 16 bit fractions
*/

		dest.high_frac = source->frac >> 16;
		dest.low_frac = source->frac;
	}

/* denornamlized numbers */

	else if (!source->exp && source->frac)
	{

ARC_DBG(("denormal\n"));

/* most denormalized numbers on clipper are too small for the vax */

ARC_DBG(("frac = %x\n",source->frac));

/* these denormalized numbers can be represented on the vax */

		if (source->frac & 0x600000)
		{

/* the sign remains the same */

			dest.sign = source->sign;

/* set exponent */

			if (source->frac & 0x400000)
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

			dest.high_frac = source->frac >> 16 - shift;
			dest.low_frac = source->frac << shift;
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

	else if (!source->exp && !source->frac)
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
		dest.high_frac = 0;
	}

/* infinity */

	else if (source->exp == 255 && !source->frac)
	{

ARC_DBG(("infinity\n"));

/*
** clipper has infinity representation vax does not
** return an error
*/

	/*	LONGJMP(ARC_OVERFLOW);  */
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

/* replace input float with output float */

	*final_dest = dest;

ARC_DBG(("sign = %x exp = %x high_frac = %x low_frac = %x\n",
 final_dest->sign,final_dest->exp,final_dest->high_frac,final_dest->low_frac));

}

/******************************************************************************/

#endif
