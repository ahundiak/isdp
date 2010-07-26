/*****************************************************************************/
/*                                                                           */
/*				Intergraph  1985                             */
/*                                                                           */
/*	INTERGRAPH Corporation assumes  NO responsibility for the use        */
/*	or reliability of software altered by the user.                      */
/*                                                                           */
/*	The information in this document is subject to change without        */
/*	notice  and  should  not  be  construed  as  a  commitment by        */
/*	INTERGRAPH corporation.                                              */
/*                                                                           */
/*                                                                           */
/*****************************************************************************/

/*
$Log: UTvax_conv.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:42  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:56  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:56  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:51:53  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:30:14  root
 * COMMENT : Corresponds to Rel201.3 in 2.0.1 RCS
 *
 * Revision 201.3  1992/07/13  20:42:21  tim
 * COMMENT : added Log variable
 *
*/

#include <stdio.h>

/*


	NAME
	UTflt32_to_fltvax - convert the IEEE floating point number format
			 to the VAX/VMS floating point number format

	SYNOPSIS
*/
	UTflt32_to_fltvax(no_floats,ieee_float,vax_float)
	int	no_floats;
	double	*ieee_float;
	unsigned int 	vax_float[];

/*
	DESCRIPTION
	Convert the  32032 IEEE format to host VAX floating point numbers.
	A buffer of several floating point numbers
	can be converted at the same time.  The VAX floating point number
	is defined in two integers.

		       31               9 8     0
			-------------------------
			|     f        |s|   e  |
			-------------------------
			|           f           |
			-------------------------
		       63		       32

		VAX Floating Point Format (64 bit double precision):
			s = sign bit 
			e = biased exponent (8 bits)   Bias = 2**(e-1)
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
			e = biased exponent (11 bits)   Bias = 2**(e-1) - 1
			f = mantissa (52 bits)   1 <= f < 2
			    implied high order bit (hidden bit)

			true exponent  E = e - Bias
			true mantissa  F = 1.f

			X = (-1)**s * F * 2**E

	GLOBAL DATA BEING CHANGED

	RETURN VALUE

	NOTES
	Remember to pre_allocate enough buffer space in vax_float
	to accommodate no_floats conversions.

	SEE ALSO
	UTfltvax_to_flt32


*/

{
	unsigned	short	*vax_ptr;
	unsigned	short	*ieee_ptr;
	unsigned	int 	*lvax_ptr;
	unsigned	int 	*lieee_ptr;
	unsigned	int 	expon;
	unsigned	int 	sign;
	unsigned	int 	msb;

	int	i;

	for (i=0; i<no_floats; i++)
	{
	    vax_ptr = (unsigned short *) &vax_float[i*2];
	    lvax_ptr = (unsigned int  *) vax_ptr;
	    ieee_ptr = (unsigned short *) ieee_float++;
	    lieee_ptr = (unsigned int  *) ieee_ptr;

	    /* check for zero  */
	    if (*lieee_ptr==0 && *(lieee_ptr+1)==0)
	    {
		*lvax_ptr++ = 0;
		*lvax_ptr   = 0;
	    }
	    else
	    {
		/* copy to vax number */
		lvax_ptr[0] = lieee_ptr[0];
		lvax_ptr[1] = lieee_ptr[1];

		/* adjust exponent (ieee -1023 +128 -1 = VAX)  */
		expon = ((vax_ptr[3] >> 4) & 0x7ff) - 894;

		/* save sign */
		sign = lvax_ptr[1] & 0x80000000;

		/* we need to shift the entire f field left 3 bits. */
		/* we shift integers, saving 3 msbs before shift */
		msb = (lvax_ptr[0] & 0xe0000000) >> 29;
		lvax_ptr[0] <<= 3;

		lvax_ptr[1] = (((lvax_ptr[1] << 3) | msb) & 0x007fffff)
		    | (expon << 23) | sign;

		/* swap to vax word order  (use sign as a temp) */
		sign = vax_ptr[0];
		vax_ptr[0] = vax_ptr[3];
		vax_ptr[3] = sign;

		sign = vax_ptr[1];
		vax_ptr[1] = vax_ptr[2];
		vax_ptr[2] = sign;
	    }
	}
}




/*


	NAME
	UTfltvax_to_flt32 - convert the VAX/VMS floating point number format
			 to the IEEE floating point number format

	SYNOPSIS
	UTfltvax_to_flt32(no_floats,vax_float,ieee_float)
	int	no_floats;
	unsigned int 	vax_float[];
	double	*ieee_float;

	DESCRIPTION
	Convert the host VAX floating point numbers to 32032 IEEE flormat.
	A buffer of several floating point numbers
	can be converted at the same time.  The VAX floating point number
	is defined in two integers.

		       31               9 8     0
			-------------------------
			|     f        |s|   e  |
			-------------------------
			|           f           |
			-------------------------
		       63		       32

		VAX Floating Point Format (64 bit double precision):
			s = sign bit 
			e = biased exponent (8 bits)   Bias = 2**(e-1)
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
			e = biased exponent (11 bits)   Bias = 2**(e-1) - 1
			f = mantissa (52 bits)   1 <= f < 2
			    implied high order bit (hidden bit)

			true exponent  E = e - Bias
			true mantissa  F = 1.f

			X = (-1)**s * F * 2**E

	GLOBAL DATA BEING CHANGED

	RETURN VALUE

	NOTES
	Remember to pre_allocate enough buffer space in ieee_float 
	to accommodate no_floats conversions.

	SEE ALSO
	UTflt32_to_fltvax


*/
UTfltvax_to_flt32(no_floats,vax_float,ieee_float)
int	no_floats;
unsigned int 	vax_float[];
double	*ieee_float;

{
union
{
	double	*d;
	unsigned int 	*l;
	unsigned short	*s;
} ptr;

unsigned int	temp[2];		/* temporary ieee format storage */
register int 	sign;			/* sign bit */
register int 	e;			/* ieee exponent mask */
	 char	zero;			/* is it zero */

	 int	i;

	for (i=0; i<no_floats; i++)
	{
	   temp[0]=vax_float[i*2];
	   temp[1]=vax_float[1+(i*2)];

/*   Swap the words in the VAX floating point number   */

	   UTconv_int(&temp[0]);		/* swap first integer */
	   
	   UTconv_int(&temp[1]);		/* swap second integer */


	   if ((temp[0] == 0) && (temp[1] == 0))
	      zero = 1;
	   else
	      zero = 0;

/*   get the sign bit   */

	   if (zero == 0)
	   {
	      sign = temp[0] & (0x1 << 31);
	   
/*   Get the low order 3 bits from the first integer; these bits will
 *   be transfered to the high order bits of the second integer; this
 *   allows for the extended exponent field in the ieee format and the
 *   mantissa being reduced from 55 bits to 53 bits.
 */

	      temp[1] = (temp[1] >> 3) | ((temp[0] & 0x7) << 29);

/*   Adjust the exponent field to 11 bits.  This bias is being changed from
 *   128 (VAX) to 1023 (IEEE).  In order to compensate for the normalized
 *   mantissa, .1 for VAX and 1. for IEEE, add 1 to the IEEE bias in the
 *   exponent.
 */

	      e = (temp[0] >> 23) & 0xff;
	      e = 1022 + (e - 128);

/*   Add the new exponent along with the sign bit to the first integer   */
	   
	      temp[0] >>= 3;
	      temp[0] &= ~(0x7ff << 20);
	      temp[0] |= (e << 20);
	      temp[0] |= sign;
	   }   
/*   Cast the two integer integers representing the ieee format into
 *   a double type variable.
 */

 	      if (zero == 1)
	      {
		 temp[0] = 0;
		 temp[1] = 0;
	      }

 	      ptr.d = (ieee_float+i);
	      *ptr.l++ = temp[1];
	      *ptr.l = temp[0];
	}
}




UTconv_int( temp )		/* swap integer */

 	unsigned int *temp;

{

	unsigned short *s_ptr1, *s_ptr2;
        unsigned short  temp2;
                 int   *i_val;

   s_ptr1 = s_ptr2 = (unsigned short *)temp;
   s_ptr2++;

   temp2    = *s_ptr1;
   *s_ptr1  = *s_ptr2;
   *s_ptr2  = temp2;
   i_val    = (int *)s_ptr1;
   return( (*i_val) );

}
