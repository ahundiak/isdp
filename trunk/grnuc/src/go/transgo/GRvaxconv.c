/*
Name
        GUvaxconv

Description
        This file contains functions for converting floating point
        numbers between VAX and Clipper formats.  These routines were
        "donated" by the InterPlot group.  There are GRNUC interfaces
        for each of the InterPlot functions.

History
        mrm     09/20/91    "borrowed" from InterPlot
*/
typedef double IGRdouble;
int GRFltVaxToFlt32(no_floats, vax_float, ieee_float)
int		no_floats;
unsigned long	vax_float[];
IGRdouble		*ieee_float;
{
    return(UTFltVaxToFlt32(no_floats, vax_float, ieee_float));
}

int GRFlt32ToFltVax(no_floats, ieee_float, vax_float)
int		no_floats;
IGRdouble		*ieee_float;
unsigned long	vax_float[];
{
    return(UTFlt32ToFltVax(no_floats, ieee_float, vax_float));
}

int GRFVaxTo32(no_floats, vax_float, ieee_float)
int		no_floats;
unsigned long	vax_float[];
float		*ieee_float;
{
    return(UTFVaxTo32(no_floats, vax_float, ieee_float));
}

int GRF32ToFVax(no_floats, ieee_float, vax_float)

int		no_floats;
float		*ieee_float;
unsigned long	vax_float[];
{
    return(UTF32ToFVax(no_floats, ieee_float, vax_float));
}

int flt32_to_fltvax(no_floats, ieee_float, vax_float)
int		no_floats;
IGRdouble		*ieee_float;
unsigned long	vax_float[];
{
    return(GRFlt32ToFltVax(no_floats, ieee_float, vax_float));
}

int fltvax_to_flt32(no_floats, vax_float, ieee_float)

int		no_floats;
unsigned long	vax_float[];
IGRdouble		*ieee_float;
{
   return(GRFltVaxToFlt32(no_floats, vax_float, ieee_float));
}

/*******************************************************************************

    FILE 

	UTFltCvt.c

    DESCRIPTION

	This file contains functions which convert floating point
	numbers between VAX and IEEE formats.
	
    FUNCTIONS

	UTAdjustDouble
	UTFltVaxToFlt32
	UTFlt32ToFltVax
	UTFVaxTo32
	UTF32ToFVax

    CHANGE HISTORY

        01/04/91 (dap)  Removed dependance on the local swpint macro and
                        used the swp_int macro from UTmacros instead.  This
                        was to fix an apparent bug in the Apogee compiler
                        which would allow the old macro to work.

	07/11/91 (mc)	Changed swp_int to UTSwpInt

	09/03/91 (RKS)	Corrected all references to the VAX/VMS Reference
			Manual.  Changed spacing in a few functions to
			make them adhere to coding standards.

*******************************************************************************/

/* GRNUC changes */

#ifdef ORIGINAL_FILE

#include        "exsysdep.h"
#include	"../hfiles/UTErrDef.h"
#include	"../hfiles/UTmacros.h"

#else

#define UTSuccess       1

#define UTSwpInt(i)     \
        {                                    \
            short t;                         \
            t = *((short *)i);               \
            *(short *)i = *(((short *) i) + 1);       \
            *(((short *) i) + 1) = t;        \
        }
#endif

/* end GRNUC changes */


/*******************************************************************************

    SYNOPSIS 

	double UTAdjustDouble(ieee_val)
	
	double	ieee_val;

    PARAMETERS
	
	NAME		ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
	----	    	--------------------------------------------------------
	ieee_val	(I)	The IEEE value to be checked, and possibly
				adjusted

    RETURN VALUE
	The adjusted value (see below) is returned.

    DESCRIPTION

	UTAdjustDouble checks an IEEE double value to see if it lies
	within the range of allowable VAX doubles.  If it does, it is
	returned unchanged.  Otherwise, it is adjusted to the nearest
	VAX boundary.

	The following diagram illustrates the floating point space.
	Values inside the "cross hatched" areas (including 0.0) are
	representable on the VAX.  Values in the blank areas are not.

	    ----+------------+-------+-------+------------+----
	        |XXXXXXXXXXXX|       X       |XXXXXXXXXXXX|
	    ----+------------+-------+-------+------------+----
                ^            ^       ^       ^            ^
                |            |       |       |            |
	    -1.70e+38   -0.29e-38   0.0   0.29e-38     1.70e38

	The range of IEEE values is larger, because IEEE exponents are
	11 bits, while VAX exponents are only 8 bits.

    CHANGE HISTORY

	12/11/91 (RKS)	Initial creation.

*******************************************************************************/


#define VAX_POSITIVE_MAX	 1.70e+38	/* MIN and MAX refer to	*/
#define VAX_POSITIVE_MIN	 0.29e-38	/* magnitudes, not	*/
#define VAX_NEGATIVE_MIN	-0.29e-38	/* numerical ordering	*/
#define VAX_NEGATIVE_MAX	-1.70e+38


double UTAdjustDouble(double ieee_val)

{
    double	adj_val;		/* value representable on VAX	*/


    if (ieee_val > VAX_POSITIVE_MAX)
    {
	/* The IEEE value is positive, and its magnitude is too great. */
	adj_val = VAX_POSITIVE_MAX;
    }
    else if (ieee_val < VAX_NEGATIVE_MAX)
    {
	/* The IEEE value is negative, and its magnitude is too great. */
	adj_val = VAX_NEGATIVE_MAX;
    }
    else if ((ieee_val > 0.0) && (ieee_val < VAX_POSITIVE_MIN))
    {
	/* The IEEE value is positive, and its magnitude is too small. */
	adj_val = VAX_POSITIVE_MIN;
    }
    else if ((ieee_val < 0.0) && (ieee_val > VAX_NEGATIVE_MIN))
    {
	/* The IEEE value is negative, and its magnitude is too small. */
	adj_val = VAX_NEGATIVE_MIN;
    }
    else
    {
	/* The IEEE value is inside the VAX range. */
	adj_val = ieee_val;
    }

    return(adj_val);
}


/*************************************************************************

    SYNOPSIS

	int UTFlt32ToFltVax(no_floats, ieee_float, vax_float)

	int		no_floats;
	double		*ieee_float;
	unsigned long	vax_float[];

    PARAMETERS
	
	NAME		ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
	----	    	--------------------------------------------------------

	no_floats	(I)	number of floats to be converted

	ieee_float	(I)	floats in IEEE format

	vax_float	(O)	floats in VAX format (stored as pairs of
				unsigned long integers)


    DESCRIPTION

	Convert the  32032 IEEE format to host VAX floating point numbers.
	A buffer of several floating point numbers can be converted at the
	same time.  The VAX floating point number is defined in two longwords.


                       31          15 14  7 6   0       
                        -------------------------       VAX/VMS Ref. Manual
                        |     f    |s|  e  |  f |       Vol. 8A
                        -------------------------       Pages A-8, A-9
                        |           f           |	D_floating
                        -------------------------
                       63                      32

		VAX Floating Point Format (64 bit double precision):
			s = sign bit 
			e = biased exponent (8 bits)   Bias = 128
			f = mantissa (55 bits)   0 <= f < 1   
			    implied high order bit (hidden bit)

			true exponent  E = e - Bias
			true mantissa  F = .1f
			
			X = (-1)**s * F * 2**E

		
		       31			  0
			---------------------------
			|             f           |
			---------------------------
			|s|    e    |	    f	  |
			---------------------------
		       63	    52		 32

		IEEE Floating Point Format  (64 bit double precision):
			s = sign bit
			e = biased exponent (11 bits)   Bias = 1023
			f = mantissa (52 bits)   1 <= f < 2
			    implied high order bit (hidden bit)

			true exponent  E = e - Bias
			true mantissa  F = 1.f

			X = (-1)**s * F * 2**E

	Remember to pre_allocate enough buffer space in vax_float
	to accommodate no_floats conversions.

    RETURN VALUE

	UTSuccess

    CHANGE HISTORY

	04/01/88 ( ? )	copied from VPLOT project

	04/01/88 (asb)	changed to conform to new coding standards	

        04/19/91 (mc )  Changed documentation to correct VAX floating point
                        datatype diagram

        04/29/91 (mc)   Added #ifdef sparc to convert from little Endian to
                        big endian.

	12/05/91 (RKS)	Rewrote function, cleaning it up and making it
			correctly process values that are outside the
			allowable ranges for VAX doubles.

*************************************************************************/

int UTFlt32ToFltVax(no_floats, ieee_float, vax_float)

int		no_floats;
IGRdouble		*ieee_float;
unsigned long	vax_float[];
{
#ifdef VAX
    int	bytes_to_move;

    /* Copy the input data to the output buffer. */
    bytes_to_move = no_floats * sizeof (double);
    UTMoveByte (&bytes_to_move, (char *) ieee_float, (char *) vax_float);
#else
    union
    {
	double		dbl_rep;
	unsigned long	long_rep[2];
    }			cur_dbl;	/* copy of the double being	*/
					/* converted			*/
    unsigned long	*vax_rep_ptr;	/* pointer to the space for the	*/
					/* converted double within the	*/
					/* return buffer		*/
    unsigned long	sign;		/* IEEE double's sign bit	*/
					/* (stored in the highest-order	*/
					/* bit)				*/
    unsigned long	mantissa[2];	/* IEEE double's mantissa	*/
    long		exponent;	/* IEEE double's exponent	*/
    unsigned long	temp;		/* used to swap longwords	*/
    int			i;		/* loop counter			*/


    for (i = 0; i < no_floats; i++)
    {
	/* Point to the storage for the next converted double. */
	vax_rep_ptr = &vax_float[i * (sizeof(double) / sizeof(unsigned long))];

	/* Copy the next double to be converted, making sure the IEEE	*/
	/* value lies within the range representable by a VAX double.	*/
	cur_dbl.dbl_rep = UTAdjustDouble(ieee_float[i]);

#ifdef BIG_ENDIAN
        /* Swap the longwords within the double so we can always get	*/
	/* sign bit and exponent from cur_dbl.long_rep[0].		*/
	temp = cur_dbl.long_rep[0];
	cur_dbl.long_rep[0] = cur_dbl.long_rep[1];
	cur_dbl.long_rep[1] = temp;
#endif

	/* Extract the components of the double. */
	sign = cur_dbl.long_rep[1] & 0x80000000L;
	exponent = (cur_dbl.long_rep[1] >> 20) & 0x7FFL;
	mantissa[0] = cur_dbl.long_rep[0];
	mantissa[1] = cur_dbl.long_rep[1] & 0x000FFFFFL;

	if (exponent == 0)
	{
	    /* The IEEE double is either a 0 or a denormalized number.	*/
	    /* Denormalized IEEE values are smaller than the smallest	*/
	    /* possible VAX double, so they are effectively 0s too.	*/
	    /* Format a VAX 0, which simply consists of 64 clear bits.	*/
	    vax_rep_ptr[0] = 0;
	    vax_rep_ptr[1] = 0;
	}
	else
	{
	    /* Store the VAX mantissa.  An IEEE mantissa is 52 bits,	*/
	    /* while a VAX mantissa is 55 bits, so left-shift the IEEE	*/
	    /* mantissa 3 bits.						*/
	    vax_rep_ptr[1] = (mantissa[1] << 3) | ((mantissa[0] >> 29) & 0x7L);
	    vax_rep_ptr[0] = mantissa[0] << 3;

	    /* Adjust the exponent.  IEEE exponents are "excess 1023,"	*/
	    /* so first subtract 1023 to get the true IEEE exponent.	*/
	    /* Then add 128 to obtain the VAX exponent, which must be 	*/
	    /* in "excess 128" format.  Finally, add 1 to compensate	*/
	    /* for differences in the IEEE and VAX hidden bits.  (On	*/
	    /* the VAX, the normalized number is of the form 0.1xxx	*/
	    /* [binary], so the high bit in the fraction is the hidden	*/
	    /* bit.  In IEEE, the normalized number is always of the	*/
	    /* form 1.xxx [binary], so the bit in the integer [to the	*/
	    /* left of the decimal point] is the hidden bit.)		*/
	    exponent = exponent - 1023 + 128 + 1;

	    /* Store the VAX exponent and sign bit. */
	    vax_rep_ptr[1] = vax_rep_ptr[1] | ((exponent & 0xFFL) << 23);
	    vax_rep_ptr[1] |= sign;

	    /* Swap the longwords within the double. */
	    temp = vax_rep_ptr[0];
	    vax_rep_ptr[0] = vax_rep_ptr[1];
	    vax_rep_ptr[1] = temp;

	    /* Swap the words within each longword of the VAX double. */
	    UTSwpInt(&vax_rep_ptr[0]);
	    UTSwpInt(&vax_rep_ptr[1]);

	    /* Byte-swap each longword if necessary (Big-Endian		*/
	    /* machines only).						*/
	    UTConvertLong(1, &vax_rep_ptr[0]);
	    UTConvertLong(1, &vax_rep_ptr[1]);
	}
    }

#endif
    return(UTSuccess);
}



/*******************************************************************************

    SYNOPSIS

	int UTFltVaxToFlt32(no_floats, vax_float, ieee_float)

	int		no_floats;
	unsigned long	vax_float[];
	double		*ieee_float;

    PARAMETERS
	
	NAME		ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
	----	    	--------------------------------------------------------

	no_floats	(I)	number of floats to convert

	vax_float	(I)	floats in vax format (stored as pairs of
				unsigned long integers)

	ieee_float	(O)	floats in ieee format

    DESCRIPTION

	This function converts the VAX/VMS floating point number format
	to the IEEE floating point number format.  A buffer of several 
	floating point numbers can be converted at the same time.  The
	VAX floating point number is defined in two longwords.


                       31          15 14  7 6   0       
                        -------------------------       VAX/VMS Ref. Manual
                        |     f    |s|  e  |  f |       Vol. 8A
                        -------------------------       Pages A-8, A-9
                        |           f           |	D_floating 
                        -------------------------
                       63                      32


		VAX Floating Point Format (64 bit double precision):
			s = sign bit 
			e = biased exponent (8 bits)   Bias = 128
			f = mantissa (55 bits)   0 <= f < 1   
			    implied high order bit (hidden bit)

			true exponent  E = e - Bias
			true mantissa  F = .1f
			
			X = (-1)**s * F * 2**E

		
		       31			  0
			---------------------------
			|             f           |
			---------------------------
			|s|    e    |	    f	  |
			---------------------------
		       63	    52		 32

		IEEE Floating Point Format  (64 bit double precision):
			s = sign bit
			e = biased exponent (11 bits)   Bias = 1023
			f = mantissa (52 bits)   1 <= f < 2
			    implied high order bit (hidden bit)

			true exponent  E = e - Bias
			true mantissa  F = 1.f

			X = (-1)**s * F * 2**E

	Remember to pre_allocate enough buffer space in ieee_float 
	to accommodate no_floats conversions.

    RETURN VALUE

	UTSuccess

    CHANGE HISTORY

	04/01/88 ( ? )	copied from AMmath.c in the ACTEM project

	04/01/88 (asb)	modified to conform to new coding standards

	04/19/88 (RKS)	Replaced the call to "move_byte" with a call to
			"UTMoveByte."

	09/04/90 (dap)	Changed 0x1 to 0x1l when forming the bit mask for
			the floating point sign.  Needed for Apogee.

        04/19/91 (mc )  Changed documentation to correct VAX floating point
                        datatype diagram

	04/29/91 (mc)   Added #ifdef sparc to convert from little Endian to
			big endian.

        06/18/91 (mc )  Changed function name from UTSwapLong to UTConvertLong

	09/03/91 (RKS)	Changed special-case check for 0.  The old check
			did not handle the case where the sign bit and
			exponent were 0 but the mantissa contained some
			non-zero bits.  I also restructured the code to
			remove unnecessary ifdefs and eliminate the need for
			the "zero" variable.

	12/05/91 (RKS)	Corrected bias definitions in above description.

*******************************************************************************/

int UTFltVaxToFlt32(no_floats, vax_float, ieee_float)

int		no_floats;
unsigned long	vax_float[];
IGRdouble		*ieee_float;
{
#ifdef VAX
    int	bytes_to_move;

    /* Copy the input data to the output buffer. */
    bytes_to_move = no_floats * sizeof (double);
    UTMoveByte (&bytes_to_move, (char *) vax_float, (char *) ieee_float);
#else
    union
    {
	double	*d;
	unsigned long	*l;
    } ptr;

    unsigned long	temp[2];	/* temporary ieee format storage */
    register long	sign;		/* sign bit */
    register long	e;		/* ieee exponent mask */
    int	i;


    for (i = 0; i < no_floats; i++)
    {
	temp[0] = vax_float[i*2];
	temp[1] = vax_float[1+(i*2)];

	/* Byte-swap each longword in the double if necessary. */
	UTConvertLong(1, &temp[0]);
	UTConvertLong(1, &temp[1]);

	/* Swap the words in each longword in the VAX-format number. */
	UTSwpInt(&temp[0]);
	UTSwpInt(&temp[1]);

	/* Get the sign bit and exponent. */
	sign = temp[0] & (((unsigned)0x1l) << 31);
	e = (temp[0] >> 23) & 0xff;
	   
	/* If the number is zero... */
	if ((sign == 0) && (e == 0))
	{
	    /* Set all 64 bits to 0. (Even though the number is 0, the	*/
	    /* mantissa may contain "1" bits that we want to clear.)	*/
	    temp[0] = 0;
	    temp[1] = 0;
	}
	else
	{
	    /* Get the low order 3 bits from the first longword; these	*/
	    /* bits will be transfered to the high order bits of the 	*/
	    /* second longword; this allows for the extended exponent 	*/
	    /* field in the ieee format and the mantissa being reduced 	*/
	    /* from 55 bits to  53 bits.				*/
	    temp[1] = (temp[1] >> 3) | ((temp[0] & 0x7) << 29);

	    /* Adjust the exponent field to 11 bits.  This bias is 	*/
	    /* being changed from 128 (VAX) to 1023 (IEEE).  In order 	*/
	    /* to compensate for the normalized mantissa, .1 for VAX 	*/
	    /* and 1. for IEEE, add 1 to the IEEE bias in the exponent.	*/
	    e = 1022 + (e - 128);

	    /* Add the new exponent along with the sign bit to the 	*/
	    /* first longword.						*/
	    temp[0] >>= 3;
	    temp[0] &= ~(0x7ff << 20);
	    temp[0] |= (e << 20);
	    temp[0] |= sign;
	}   

	/* Point to the memory allocated for the converted value. */
	ptr.d = (double *)(ieee_float + i);
	
	/* Store double according to Big Endian or Little Endian */
	/* architecture						 */
#ifdef BIG_ENDIAN
	*ptr.l++ = temp[0];
	*ptr.l = temp[1];
#else
	*ptr.l++ = temp[1];
	*ptr.l = temp[0];
#endif
    }
#endif
    return(UTSuccess);
}


/*******************************************************************************

    SYNOPSIS 
	int UTFVaxTo32(no_floats, vax_float, ieee_float)

	int		no_floats;
	unsigned long	vax_float[];
	float		*ieee_float;

    PARAMETERS
	
	NAME		ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
	----	    	--------------------------------------------------------

	no_floats	(I)	number of floats to convert
	
	vax_float	(I)	floats in VAX format (stored as unsigned
				long integers)

	ieee_float	(O)	floats in IEEE format

    DESCRIPTION

        This function converts the VAX/VMS floating point number format
        to the IEEE floating point number format.  A buffer of several
        floating point numbers can be converted at the same time.  The
        VAX floating point number is defined in two words.


                       31          15 14  7 6   0       
                        -------------------------       VAX/VMS Ref. Manual
                        |     f    |s|  e  |  f |       Vol. 8A
                        -------------------------       Pages A-8, A-9


                VAX Floating Point Format (32 bit precision):
                        s = sign bit
                        e = biased exponent (8 bits)   Bias = 128
                        f = mantissa (23 bits)   0 <= f < 1
                            implied high order bit (hidden bit)

                        true exponent  E = e - Bias
                        true mantissa  F = .1f

                        X = (-1)**s * F * 2**E


                        31 30     23 22           0
                        ---------------------------
                        |s|    e    |       f     |
                        ---------------------------


                IEEE Floating Point Format  (32 bit precision):
                        s = sign bit
                        e = biased exponent (8 bits)   Bias = 127
                        f = mantissa (23 bits)   1 <= f < 2
                            implied high order bit (hidden bit)

                        true exponent  E = e - Bias
                        true mantissa  F = 1.f

                        X = (-1)**s * F * 2**E

        Remember to pre_allocate enough buffer space in ieee_float
        to accommodate no_floats conversions.

    RETURN VALUE
	none

    CHANGE HISTORY

	07/05/88 (NPF)	Copied from float.c of IPLOT project.

        04/19/91 (mc )  Added description documentation

        04/29/91 (mc)   Added #ifdef sparc to convert from little Endian to
                        big endian.

        06/18/91 (mc )  Changed function name from UTSwapLong to UTConvertLong

	12/09/91 (mc)	Moved byte-swapping for Sparc to correct place.  We
			don't use this function currently.

	12/12/91 (RKS)	Corrected bias definitions and IEEE format in above
			description;  added argument description;  designated
			function as returning type "int."

*******************************************************************************/

int UTFVaxTo32(no_floats, vax_float, ieee_float)

int		no_floats;
unsigned long	vax_float[];
float		*ieee_float;
{
#ifdef VAX
    int	i;
    int	len;

    len = 4;
    for (i = 0; i < no_floats; i++)
    {
	UTMoveByte(&len, &vax_float[i], &ieee_float[i]);
    }
#else
    union
    {
	float		*f;
	unsigned long	*l;
    } ptr;

    unsigned long	sign;
    unsigned long	exp;
    unsigned long	frac;

    unsigned long 	temp;
    int			i;

    for (i = 0; i < no_floats; i++)
    {
	/* Store the a vax float into a temporary place. */
	temp = vax_float[i];

	/* Swap the long. */
	UTSwpInt(&temp);
	UTConvertLong(1, &temp);
	
	/* Separate the swapped long into the float components: sign,	*/
	/* exponent, and fraction.					*/
	sign= temp >> 31;
	exp = ((temp >> 23) & 0x00ff);

	/* If the exponent is different than zero the subtract 2.	*/
	if (exp != 0)
	{
	    exp -= 2;
	}
	frac = (temp) & 0x7fffff;

	/* Put all the float pieces back together again.		*/
	temp = (sign << 31) | (exp << 23) | frac;


	/* Store the ieee format float into ieee_float before processing*/ 
	/* the next float.						*/
	ptr.f = (ieee_float+i);
	*ptr.l = temp;
    }
#endif
    return(UTSuccess);
}


/*******************************************************************************

    SYNOPSIS 

	int UTF32ToFVax(no_floats, ieee_float, vax_float)

	int		no_floats;
	float		*ieee_float;
	unsigned long	vax_float[];

    PARAMETERS
	
	NAME		ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
	----	    	--------------------------------------------------------

	no_floats	(I)	number of floats to convert

	ieee_float[]	(I)	floats in IEEE format

	vax_float	(O)	floats in VAX format (stored as unsigned
				long integers)
	

    DESCRIPTION

        Convert the  32032 IEEE format to host VAX floating point numbers.
        A buffer of several floating point numbers can be converted at the
        same time.  The VAX floating point number is defined in two words.


                       31          15 14  7 6   0       
                        -------------------------       VAX/VMS Ref. Manual
                        |     f    |s|  e  |  f |       Vol. 8A
                        -------------------------       Pages A-8, A-9

                VAX Floating Point Format (32 bit precision):
                        s = sign bit
                        e = biased exponent (8 bits)   Bias = 128
                        f = mantissa (23 bits)   0 <= f < 1
                            implied high order bit (hidden bit)

                        true exponent  E = e - Bias
                        true mantissa  F = .1f

                        X = (-1)**s * F * 2**E


                        31 30     23 22           0
                        ---------------------------
                        |s|    e    |       f     |
                        ---------------------------

                IEEE Floating Point Format  (32 bit precision):
                        s = sign bit
                        e = biased exponent (8 bits)   Bias = 127
                        f = mantissa (23 bits)   1 <= f < 2
                            implied high order bit (hidden bit)

                        true exponent  E = e - Bias
                        true mantissa  F = 1.f

                        X = (-1)**s * F * 2**E

        Remember to pre_allocate enough buffer space in vax_float
        to accommodate no_floats conversions.

    RETURN VALUE

    CHANGE HISTORY

	07/05/88 (NPF)	Copied from float.c of IPLOT project.

        04/19/91 (mc )  Added description documentation

        04/29/91 (mc)   Added #ifdef sparc to convert from little Endian to
                        big endian.

        06/18/91 (mc )  Changed function name from UTSwapLong to UTConvertLong

	12/09/91 (mc)	Removed ifdef for SUNOS

	12/12/91 (RKS)	Corrected bias definitions and IEEE format in above
			description; added argument descriptions; designated
			function as returning type "int"; got rid of unecessary
			"ptr" union.

*******************************************************************************/

int UTF32ToFVax(no_floats, ieee_float, vax_float)

int		no_floats;
float		*ieee_float;
unsigned long	vax_float[];
{
#ifdef VAX
    int	i;
    int	len;

    len = 4;
    for (i = 0; i < no_floats; i++)
    {
	UTMoveByte(&len, &ieee_float[i], &vax_float[i]);
    }
#else
    unsigned long	sign;
    unsigned long	exp;
    unsigned long	frac;
    unsigned long 	temp;
    int			i;

    for (i = 0; i < no_floats; i++)
    {
	/* Copy the IEEE float to a temporary unsigned long integer. */
	memcpy((char *)&temp, (char *)&ieee_float[i], sizeof(float));

	/* Separate the float into its components: sign, exponent,	*/
	/* and fraction.						*/
	sign = temp >> 31;
	exp  = ((temp >> 23) & 0x00ff);

	/* If the exponent is not zero then add 2.			*/
	if (exp != 0)
	{
	    exp += 2;
	}
	frac = (temp) & 0x7fffff;

	/* Put the fraction back together.				*/
	temp = (sign << 31) | (exp << 23) | frac;

	/* Swap the long so that it is in vax format.			*/
	UTSwpInt(&temp);
	UTConvertLong(1, &temp);

	/* Store the long in the output array. */
	vax_float[i] = temp;
    }
#endif
    return(UTSuccess);
}
