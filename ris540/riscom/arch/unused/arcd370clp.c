/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							ARC370clpdb.c
**	AUTHORS:						Dan Karier
**	CREATION DATE:					7/89
**	ABSTRACT:
**		
**	Conversion routine for ibm double to clipper double
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include  <stdio.h>
#include "arch.h"
#include "sys_.h"
#include "RIScommon.h"
#include "ARCswap_.h"


/*
**	DEFINES
*/
#ifdef TEST
# define ARC_ERR(err) {printf("  *** ERR %d ***\n", err); return;}
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
#define ARC370clpdb_c
#include "ARC370clpdb_.h"
#include "COMfunc_.h"



/******************************************************************************/

/*
** convert an ibm double to a clipper double
*/

extern void ARC_370_to_clip_double(
	arc_s * arc,
	ibm370_double * source)
{
	clip_double dest;
	clip_double * final_dest;
	int exp;
	unsigned highf, lowf;
	int round;
	int shift;
	int shiftblock;
	int i;
    int len; /* dummy parameter to double_swap function */

ARC_DBG(("\nARC_370_to_clip_double arc = 0x%x source = %x\n",arc,source));

/* swap the byte ordering */

	ARC_double_swap_bytes(arc,(char *)source,len);

ARC_DBG(("\nARC_370_to_clip_double source = %x\n",source));

/* set up pointers */

	final_dest = (clip_double *)source;

	ARC_DBG(("sign = %x exp = %x high_frac = %x low_frac = %x\n",
	 source->sign,source->exp,source->high_frac,source->low_frac));

/* zero */

	if (!source->sign && !source->exp)
	{

ARC_DBG(("zero\n"));

/*
** ibm zero is equivalent to clipper zero
** set clipper to zero
*/


		dest.sign = 0;
		dest.exp = 0;
		dest.high_frac = 0;
		dest.low_frac = 0;
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
		** We are going from a non-normalized 56-bit fraction (24 Hi,32 Lo)
		** to a normalized 52-bit fraction (20 Hi, 32 Lo) with an implicit 1.
		** So, shift left until we have a non-zero high bit.
		*/

		highf = source->high_frac;
		lowf  = source->low_frac;
		shift = 0;

		shiftblock = 24;
		if (!highf)
		{
			highf = (lowf & 0xFFFFFF00)>>8;
			lowf  = lowf << 24;
			shift += 24;
		}
		if (!highf)
		{
			highf = (lowf & 0xFF000000)>>8;
			lowf  = 0;
			shift += 24;
			shiftblock = 8;
		}
		for (i=0; ((!(highf & 0x800000)) && (i < shiftblock)); ++i)
		{
			highf = highf << 1;
			++shift;
		}

		exp -= shift;
		shift = i;

		/*
		** get rid of the implicit 1;  we have to adjust the exponent too
		** shift left 1 to stay at 24 bits.
		*/
		
		--exp;
		highf = (highf & 0x7fffff) << 1;
		++shift;
		
		/*
		** We are going from 24 to 20 bits in the high fraction.
		** We might have to shift the low fraction left and spill
		** bits into the high fraction, or we might have to
		** shift the low fraction right, spill bits into the
		** low fraction, and worry about rounding.
		** It all depends on whether we have shifted the high fraction
		** left more or less than the 4 bits we shift right to get
		** down to 20.
		*/

		if (shift == 4)
		{
			/*
			** No shifting of the low fraction; we have shifted the
			** high fraction 4 bits left, so just shift it back.
			*/

			highf = highf >> 4;
		}
		else if (shift > 4)
		{
			/*
			** low fraction needs to move left and spill into the 
			** high fraction
			*/

			shift -= 4;
			highf = (highf >> 4) | (lowf >> (32 - shift));
			lowf  = lowf << shift;
		}
		else
		{
			/*
			** low fraction moves right; bits spill into low fraction;
			** round if necessary
			*/

			shift = 4 - shift;	/* now rightshift */
			round = lowf | (0x1<<(shift-1));
			lowf = (lowf >> shift) | (highf << 28);
			highf = highf >> 4;
			if (round)
			{
				++lowf;
				if (!lowf)
				{
					++highf;
					if (!highf)
						++exp;
				}
			}
		}

		dest.exp = exp + 1023;
		dest.high_frac = highf;
		dest.low_frac  = lowf;

	}

/* replace input double with output double */

	*final_dest = dest;

ARC_DBG(("sign = %x exp = %x high frac = %x low frac = %x\n",
 final_dest->sign,final_dest->exp,final_dest->high_frac,final_dest->low_frac));
ARC_DBG((" Result: %lf\n",  * (double *)final_dest));
}

/******************************************************************************/

