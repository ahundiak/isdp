/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							ARCclp370fl.c
**	AUTHORS:						Dan Karier
**	CREATION DATE:					7/89
**	ABSTRACT:
**		
**	Conversion routine for clipper float to IBM 370 (4381,VM) float
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

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define ARCclp370fl_c
#include "ARCclp370fl_.h"
#include "COMfunc_.h"


/******************************************************************************/

/*
** convert a clipper float to a 370-architecture float
*/

extern void ARC_clip_to_370_float(
	arc_s * arc,
	clip_float * source)
{
	ibm370_float dest;
	ibm370_float * final_dest;
	int shift;
	int exp;
	unsigned frac;
	int round;
    int len; /* dummy parameter to swap_bytes function */

ARC_DBG(("\nARC_clip_to_370_float arc = 0x%x source = %x\n",arc,source));
ARC_DBG(("source: sign <%c>, exp = %d (%08x), frac %d (%08x)\n",
source->sign ? '-' : '+', source->exp, source->exp, source->frac,source->frac));

/* set up pointers */

	final_dest = (ibm370_float *)source;

	ARC_DBG(("sign = %x exp = %x frac = %x\n",
		source->sign,source->exp,source->frac));

/* normal numbers */

	if (source->exp && source->exp < 255)
	{

	ARC_DBG(("normal\n"));

		/* the sign remains the same */

		dest.sign = source->sign;

/*
** adjust exponent and mantissa
** clipper: excess 127 
**     370: excess 64
** clipper: implied 1 to left of decimal 
**     370: nothing implied 
**
**     370 float works with hex representation;
**		e.g.:
**			float value 1234.5678
**			reduced to hex: ABC.DEF
**			normalized:  (.)ABCDEF with exponent 3 
**
**			The IBM exponent is in terms of hex digits, not bits.
**			In converting from clipper, we have to adjust to
**			get a true exponent that is evenly divisible by 4.
**			I.e., if the clipper exponent is 6, we need to
**			rotate the mantissa a couple of bits for an
**			exponent of 8, which is then stored as 2 (8/4).
*/

		/*
		** Pick up the clipper mantissa and make the implicit 1 explicit;
		*/

		frac = source->frac | 0x00800000; 

		exp =  source->exp - 127;	/* true clipper exponent */

		exp = exp+1; 				/* add 1 for the explicit bit we added */

		/*
		** The exponent at this point is directly equivalent to
		** the number of bits to shift the radix point.
		** We need an exponent that is divisible by 4.
		** For every one we add to the exponent, we need to shift
		** the mantissa right.  We can lose precision here.
		*/
		
		/*
		** If we lose precision, check for rounding.
		** Note that we have to round ONLY if we have shifted
		** one or more bits, so when we add 1 for rounding we
		** do not have to worry about overflowing and getting
		** a mantissa of zero.
		*/

		if (exp % 4)
		{
			shift = 4-(exp % 4);
			exp += shift;
			round = (frac & (0x1 << (shift-1)));
			frac = frac >> shift;
			if (round)
				frac += 1;
		}

		/*
		** Now reduce the exponent from a bit-shift value to a
		** 4-bit shift value, and add on 64 for excess 64.
		*/

		dest.exp = (exp/4)+64;

		dest.frac = frac;
	}

/* denornamlized numbers */	

	else if (!source->exp && source->frac)
	{
ARC_DBG(("denormal\n"));

		/* the sign remains the same */

		dest.sign = source->sign;

		/* 
		** frac does not have an implicit bit; 
		** take the value as is, shift left 1 to make for 24 bit value
		*/

		frac = source->frac << 1;

		/* 
		** Our clipper exponent is -126; we need to arrange to get this
		** to a 4-divisible value without losing too much.
		** Worst case clipper fraction is 0x400001 (10000000000000000000001).
		** Even though we have 24 bits to play with, we are going to lose
		** by shifting to make the exponent divisible by 4.
		** We could automatically shift right, but if the fraction is
		** 0x000001, we completely lose a value we could store.
		** We can not shift left and lose the high bits.  So . . .
		**
		** First test to see if we can shift left.  If so, do it that way.
		** If not, we shift right and lose precision.
		*/

		/* 
		** most significant bits 0, ok to shift left.  
		*/

		if (!(frac & 0xc00000))	
		{
			frac = frac << 2;
			exp = -128;
		}
		else
		{
			round =
			round = frac & 0x2;
			frac = frac >> 2;
			if (round) 
				frac += 1;
			exp = -124;
		}

		/*
		** In the event the high 4 bits (or more) are 0, we can left shift
		** the bits
		*/

		while (!(frac & 0xF00000))
		{
			frac = frac << 4;
			exp -= 4;
		}

		dest.exp = (exp/4) + 64;
		dest.frac = frac;
	}

/* zero */

	else if (!source->exp && !source->frac)
	{

ARC_DBG(("zero\n"));

/* 
** ibm representation of zero is all zero 
*/

		dest.sign = 0;
		dest.exp = 0;
		dest.frac = 0;
	}

/* infinity */

	else if (source->exp == 255 && !source->frac)
	{

ARC_DBG(("infinity\n"));

/*
** clipper has infinity representation.  ibm does not.
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
** clipper has NaN representations. ibm does not.
** return an error
*/

	/*	LONGJMP(ARC_NOT_A_NUMBER);  */
		ARC_error(arc, ARC_NOT_A_NUMBER);
		return;
	}

/* swap the byte ordering */

	ARC_float_swap_bytes(arc,(char *)&dest,len);

/* replace input float with output float */

	*final_dest = dest;

ARC_DBG(("result: sign <%c>, exp = %d (%08x), frac %d (%08x)\n",dest.sign ? '-' : '+', dest.exp, dest.exp, dest.frac,dest.frac));

}

/******************************************************************************/

