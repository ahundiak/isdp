/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							arcfvxcx.c
**	AUTHORS:						David Michal
**	CREATION DATE:					10/88
**	ABSTRACT:
**	Conversion routine for vax ffloat to clipper float
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
#define arcfvxcx_c
#include "arcerrcd.prt"
#include "arcfvxcx.prt"
#include "sys.prt"

/******************************************************************************/

/*
** convert a vax ffloat to a clipper float
*/

extern void ARC_vax_to_clip_float(
	arc_s * arc,
	vax_ffloat * source,
    int len)
{
	clip_float dest;
	clip_float * final_dest;
	int round;
	int shift;

ARC_DBG(("\nARC_vax_to_clip_float arc_s = 0x%x source = %x\n",arc,source));

/* set up pointers */

	final_dest = source;

ARC_DBG(("sign = %x exp = %x high_frac = %x low_frac = %x\n",
 source->sign,source->exp,source->high_frac,source->low_frac));

/* zero */

	if (!source->sign && !source->exp)
	{

ARC_DBG(("zero\n"));

/*
** vax zero is equivalent to clipper zero
** set clipper to zero
*/


		dest.sign = 0;
		dest.exp = 0;
		dest.frac = 0;
	}

/* reserved */

	else if (source->sign && !source->exp)
	{

ARC_DBG(("reserved\n"));

/*
** a vax reserved operand fault
** return an error
*/
	/*	LONGJMP(ARC_NOT_A_NUMBER); */
		ARC_error(arc, ARC_NOT_A_NUMBER);
		return;
	}

/* normal numbers */

	else
	{

ARC_DBG(("normal\n"));

/* the sign remains the same */

		dest.sign = source->sign;

/*
** merge fraction
** clipper: 23 bit fraction vax: 7 and 16 bit fractions
*/

		dest.frac = source->high_frac ;
		dest.frac = dest.frac << 16 | source->low_frac;

/*
** adjust exponent
** clipper: excess 127 vax: excess 128
** clipper: implied 1 to left of decimal vax: implied 1 to right of decimal
** subtract 2 from the vax exponent to get the clipper exponent
** note: a vax exponent of 1 or 2 must be represented by a clipper
** denormalized number
*/

ARC_DBG(("exponent = %d\n",source->exp));

		if (source->exp > 2)
		{
			dest.exp = source->exp-2;
		}
		else
		{
			if (source->exp == 2)
			{
				shift = 1;
			}
			else
			{
				shift = 2;
			}

/* set exponent to 0 to indicate a denormalized number */

			dest.exp =  0;

/* shift the fraction right, insert the implied 1, and round */

			round = dest.frac & (0x1 << shift) - 1;
			dest.frac >>=  shift;
			dest.frac |= 0x400000 >> shift - 1;

ARC_DBG(("round = %d\n",round));

			if (round)
			{

				dest.frac++;

ARC_DBG(("frac = %x\n",dest.frac));

				if (!dest.frac)
				{

/* the rounded value is normal again so set the exponent equal to 1 */

					dest.exp = 1;
				}
			}
		}
	}

/* replace input float with output float */

	*final_dest = dest;

ARC_DBG(("sign = %x exp = %x frac = %x\n",
 final_dest->sign,final_dest->exp,final_dest->frac));

}

/******************************************************************************/

#endif
