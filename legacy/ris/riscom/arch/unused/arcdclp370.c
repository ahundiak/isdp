/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							ARCclp370db.c
**	AUTHORS:						Dan Karier
**	CREATION DATE:					7/89
**	ABSTRACT:
**	Conversion routine for clipper double to ibm370 double
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

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define ARCclp370db_c
#include "ARCclp370db_.h"
#include "COMfunc_.h"

/******************************************************************************/

/*
** convert a clipper double to a 370 double
*/

extern void ARC_clip_to_370_double(
	arc_s * arc,
	clip_double * source)
{
	ibm370_double dest;
	ibm370_double * final_dest;
	int shift_bits;
	int shift_exp;
	int shift_count;
	unsigned temp_lowf, temp_highf;
	int exp;
    int len; /* dummy parameter to ARC_float_swap_bytes function */

ARC_DBG(("\nARC_clip_to_ibm370_double arc = 0x%x source = %x\n",arc,source));

/* set up pointers */

	final_dest = (ibm370_double *)source;

ARC_DBG(("source sign = %x exp = %x high_frac = %x low_frac = %x\n",
 source->sign,source->exp,source->high_frac,source->low_frac));

/* normal numbers */

	if (source->exp && source->exp < 2047)
	{

ARC_DBG(("normal\n"));

/* the sign remains the same */

		dest.sign = source->sign;

/*
** adjust exponent and mantissa
** clipper: excess 1023
**     370: excess 64
** clipper: implied 1 to left of decimal
**     370: nothing implied
**
**     370 float works with hex representation;
**      e.g.:
**          float value 1234.5678
**          reduced to hex: ABC.DEF
**          normalized:  (.)ABCDEF with exponent 3
**
**          The IBM exponent is in terms of hex digits, not bits.
**          In converting from clipper, we have to adjust to
**          get a true exponent that is evenly divisible by 4.
**          I.e., if the clipper exponent is 6, we need to
**          rotate the mantissa a couple of bits for an
**          exponent of 8, which is then stored as 2 (8/4).
**
**  370 double is truly double precision.  The exponent range is the
**  same as for a float, they just go from 3 bytes to 7 bytes for
**  the mantissa.  Since their exponent is stored in just 7 bits,
**  even when multiplied by 4 its range comes nowhere near that
**  of the clipper.  There is the potential of a lot of overflow/underflow
**  here.
*/


ARC_DBG(("exponent = %d\n",source->exp));

		exp = source->exp - 1023;

		++exp;	/* for the implicit 1 in the clipper representation */

			/*
			** Make the exponent divisible by 4 --
			** remember how many bits we will have to do to shift it up
			** to a number divisible by 4.
			*/
		
		shift_bits = (4-(exp % 4));	 /* gives 1,2,3, or 4; no need to shift 4 */

		if (shift_bits == 4)
			shift_bits = 0;

		if (shift_bits)
		{
			exp += shift_bits;
		}
	
		/*
		**	Map the exponent to an ibm exponent.  Check for overflow
		**  and underflow.
		*/

		exp = exp/4;

		/*
		**  ibm has 7-bit exponent, max value 127.  They use excess 64,
		**  so we are looking at 63 (*4) as the highest true exponent
		**  they can have.
		*/

		if ((exp) > 63)  			
		{
		/*	LONGJMP(ARC_OVERFLOW); */
			ARC_error(arc, ARC_OVERFLOW);
			return;
		}

		/*
		**  The smallest true exponent they can have is -64 (*4), but
		**  beyond that we can right-shift the bits up to 52 bits
		**  (13 hex digits).  That will cause us to lose precision,
		**  but we will still have a value.
		*/

		if ((exp) < (-64-13))
		{
		/*	LONGJMP(ARC_UNDERFLOW); */
			ARC_error(arc, ARC_UNDERFLOW);
			return;
		}

		/*
		**  If we do have to shift the bits in order to get an exponent,
		**  note how many times.
		*/

		shift_exp = 0;

		if (exp < -64)
		{
			shift_exp = -64 - exp;
			exp = -64;
		}

		/* bias exponent */

		exp += 64;
		dest.exp = exp;

		/*
		** Now get the fraction correct, complete with shifting
		** clipper: 20 and 32 bit fractions
		** ibm: 24 and 32 bit fractions
		*/

		/*
		** total number of bits to shift right, due to the original
		** shift to get the exponent divisible by 4, and possibly
		** another shift to increase the exponent value to within
		** the legal range.
		*/

		shift_count = shift_bits + (4 * shift_exp);

		/*
		** ibm has a 24-bit high fraction, clipper has 20 with an
		** implied 1.  So, add on the 1, shift left 3 more bits,
		** and add the 3 upper bits of the low fraction.
		*/

		temp_highf = ((source->high_frac | 0x100000) << 3) | 
						 ((source->low_frac & 0xE0000000) >> 29);

		temp_lowf = (source->low_frac << 3) >> shift_count;

		/*
		** Now we need to shift the high and low fractions, with
		** the extra bits of the high fraction spilling into the
		** low fraction.  We have 24 bits in the high fraction;
		** we may be shifting more than that.  We may be shifting
		** more than 32; if so, we lose the low fraction entirely.
		*/

		if (shift_count >= 32)
		{
			dest.low_frac = temp_highf >> (shift_count - 32);
		}
		else
		{
			dest.low_frac = temp_lowf | (temp_highf << (32 - shift_count));
		}
		
		dest.high_frac = temp_highf >> shift_count;
	}

/* denornamlized numbers */

	else if (!source->exp && (source->high_frac || source->low_frac))
	{

	ARC_DBG(("denormal\n"));

	/* all denormalized doubles on clipper are too small for the ibm */

		/*	LONGJMP(ARC_UNDERFLOW); */
			ARC_error(arc, ARC_UNDERFLOW);
			return;
	}

/* zero */

	else if (!source->exp && !(source->high_frac || source->low_frac))
	{

	ARC_DBG(("zero\n"));

		/* 
		** clipper and ibm representations of zero are the same 
		** except clipper allows negative zero
		*/

		dest.sign = 0;
		dest.exp = 0;
		dest.low_frac = 0;
		dest.high_frac = 0;
	}

/* infinity */

	else if (source->exp == 2048 && !(source->high_frac || source->low_frac))
	{

ARC_DBG(("infinity\n"));

		/*
		** clipper has infinity representation 
		** ibm does not
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

ARC_DBG((
 "doubl sign = %x exp = %x high_frac = %x low_frac = %x\n",
 dest.sign,dest.exp,dest.high_frac,dest.low_frac));

/* swap the byte ordering */

	ARC_double_swap_bytes(arc,(char *)&dest,len);

/* replace input double with output double */

    *final_dest = dest;

ARC_DBG((
 "ibmdouble sign = %x exp = %x high_frac = %x low_frac = %x\n",
 final_dest->sign,final_dest->exp,final_dest->high_frac,
 final_dest->low_frac));

}

/******************************************************************************/

