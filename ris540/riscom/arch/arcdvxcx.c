/* Do not alter this SPC information: $Revision: 1.2.52.1 $ */
/*
**	NAME:							arcdvxcx.c
**	AUTHORS:						David Michal
**	CREATION DATE:					10/88
**	ABSTRACT:
**		
**	Conversion routine for vax dfloat to clipper double
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#ifdef vms

#include  <stdio.h>
#include "arch.h"
#include "risstjmp.h"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/
extern double MTH$CVT_D_G();

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define arcdvxcx_c
#include "arcdvxcx.prt"
#include "arcerrcd.prt"
#include "arcexcpt.prt"
#include "comjmp.prt"
#include "sys.prt"



/******************************************************************************/

/*
** convert a vax dfloat to a clipper double
*/

extern void ARC_vax_to_clip_double(
	arc_s * arc,
	vax_dfloat * orig_source,
    int len)
{
	vax_gfloat * source;
	clip_double dest;
	clip_double * final_dest;
	int round;
	int shift;
	unsigned temp;
	double * gfloat_val;
	unsigned underflow_detection;
/*
	static void catch_underflow();
	static void ignore_underflow();
*/

	struct swapper { unsigned x1 : 32;
                     unsigned x2 : 32;
					} swapper;

ARC_DBG(("\nARC_vax_to_clip_double arc = 0x%x orig_source = %x\n",
 arc,orig_source));

/* set up pointers */

	source = orig_source;
	final_dest = orig_source;
	gfloat_val = source;

ARC_DBG((
 "dfloat sign = %x exp = %x high_frac = %x med_frac = %x low_frac = %x\n",
 orig_source->sign,orig_source->exp,orig_source->high_frac,
 orig_source->med_frac,orig_source->low_frac));

/* replace input dfloat with a gfloat */

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

	*gfloat_val = MTH$CVT_D_G(orig_source);

	RESETJMP();
	ignore_underflow();

ARC_DBG((
 "gfloat sign = %x exp = %x high_frac = %x med_frac = %x low_frac = %x\n",
 source->sign,source->exp,source->high_frac,source->med_frac,source->low_frac));

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
		dest.low_frac = 0;
		dest.high_frac = 0;
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
** clipper: 20 and 32 bit fractions vax: 4, 16, and 32 bit fractions
*/

		dest.high_frac = source->high_frac ;
		dest.high_frac = dest.high_frac << 16 | source->med_frac;
		dest.low_frac = source->low_frac;

/*
** adjust exponent
** clipper: excess 1023 vax: excess 1024
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

			round = dest.low_frac & (0x1 << shift) - 1;
			temp = (dest.high_frac & 0x3);
			dest.high_frac >>=  shift;
			dest.low_frac = dest.low_frac >> shift | temp << 32 - shift;
			dest.high_frac |= 0x80000 >> shift - 1;

ARC_DBG(("round = %d\n",round));

			if (round)
			{

				dest.low_frac++;

ARC_DBG(("low_frac = %x\n",dest.low_frac));

				if (!dest.low_frac)
				{

/* propagate the 1 to the high fraction */

					dest.high_frac++;

ARC_DBG(("high_frac = %x\n",dest.high_frac));

					if (!dest.high_frac)
					{
/* the rounded value is normal again so set the exponent equal to 1 */

						dest.exp = 1;
					}
				}
			}
		}
	}

/* we need to swap the shorts of the completed low fraction */

    swapper.x1 = (unsigned) dest.low_frac;
    swapper.x2 = 0;
	swapper.x2 = ((unsigned) (swapper.x1 <<16))|((unsigned)(swapper.x1 >> 16));
	dest.low_frac = (unsigned) swapper.x2;

/* replace input float with output float */

	*final_dest = dest;

ARC_DBG(("sign = %x exp = %x high_frac = %x low_frac = %x\n",
 final_dest->sign,final_dest->exp,final_dest->high_frac,final_dest->low_frac));

}

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
/******************************************************************************/

#endif
