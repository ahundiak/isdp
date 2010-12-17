/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							ARC370clpfl.c
**	AUTHORS:						Dan Karier
**	CREATION DATE:					7/89
**	ABSTRACT:
**	Conversion routine for ibm float to clipper float
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include  <stdio.h>
#include "arch.h"
#include "ARCerrcode_.h"
#include "sys_.h"
#include "ARCswap_.h"
#include "RIScommon.h"



/*
**	DEFINES
*/
#ifdef TEST
# define ARC_ERR(err) {printf("	*** ERR %d ***\n", err); return;}
# define ARC_DBG(x)  /* printf x  */
#endif


/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define ARC370clpfl_c
#include "ARC370clpfl_.h"
#include "COMfunc_.h"

/******************************************************************************/

/*
** convert an ibm float to a clipper float
*/

extern void ARC_370_to_clip_float(
	arc_s * arc,
	ibm370_float * source)
{
	clip_float dest;
	clip_float * final_dest;
	int exp;
	unsigned frac;
	int shift;
	int round;
    int len; /* dummy parameter to ARC_float_swap_bytes function */

ARC_DBG(("\nARC_370_to_clip_float arc = 0x%x source = %x\n",arc,source));

/* swap the byte ordering */

	ARC_float_swap_bytes(arc,(char *)source,len);

ARC_DBG(("\nARC_370_to_clip_float source = %x\n",source));

/* set up pointers */

	final_dest = (clip_float *)source;

ARC_DBG(("sign = %x exp = %x frac = %x \n",
 source->sign,source->exp,source->frac));

/* zero */

	if (!source->exp && !source->frac)
	{

ARC_DBG(("zero\n"));

/*
** ibm zero is equivalent to clipper zero
** set clipper to zero
*/


		dest.sign = 0;
		dest.exp = 0;
		dest.frac = 0;
	}

/* numbers so small they must be represented in clipper denormal form */

	else if (    source->exp <= 32 )
	{
		/* too small? give up */

		if (source->exp < 27)
		{
		/*	LONGJMP(ARC_UNDERFLOW); */
			ARC_error(arc, ARC_UNDERFLOW);
			return;
		}

		dest.sign = source->sign;
		dest.exp = 0;

		/*
		** Clipper denormal form has an assumed exponent of -126,
		** 23 bit mantissa without an implicit 1.
		** IBM has 24 bits.  We may lose 1 or more.
		*/

		exp = (source->exp - 64) * 4;
		frac = source->frac;

		shift = -126 - exp;		/* exp always divis. by 4 so shift never 0 */

		/*
		** We are going from 24 to 23 bits, so add 1 to the shift
		*/

		++shift;

		round = frac & (0x1 << (shift-1));

		frac = frac >> shift;
		if (round)
			++frac;
		
		dest.frac = frac;

	}

/* normal numbers */

	else
	{

		ARC_DBG(("normal\n"));

		/* the sign remains the same */

		dest.sign = source->sign;

		/*
		** Convert the ibm exponent to a true exponent.
		*/

		exp = (source->exp - 64) * 4;

		/*
		** We are going from a non-normalized 24-bit fraction
		** to a normalized 23-bit fraction with an implicit 1.
		** So, shift left until we have a non-zero high bit.
		*/

		frac = source->frac;
		while (!(frac & 0x800000))
		{
			frac = frac << 1;
			--exp;
		}

		/*
		** and make the high bit implicit; adjust the exponent 
		*/

		dest.frac = frac & 0x7FFFFF;
		--exp;

		/* bias the true exponent to get a clipper exponent */

		exp += 127;
		dest.exp = exp;

		/* if too large, return an error */

		if (exp > 254)
		{
		/*	LONGJMP(ARC_OVERFLOW); */
			ARC_error(arc, ARC_OVERFLOW);
			return;
		}

	}

/* replace input float with output float */

	*final_dest = dest;

ARC_DBG(("sign = %x exp = %x frac = %x\n",
 final_dest->sign,final_dest->exp,final_dest->frac));

}

/******************************************************************************/
