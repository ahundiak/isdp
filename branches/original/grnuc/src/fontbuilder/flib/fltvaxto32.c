/*\


	NAME
	fltvax_to_flt32 - convert the VAX/VMS floating point number format
			 to the IEEE floating point number format

	SYNOPSIS
	fltvax_to_flt32(no_floats,vax_float,ieee_float)
	int	no_floats;
	unsigned long	vax_float[];
	double	*ieee_float;

	DESCRIPTION
	Convert the host VAX floating point numbers to 32032 IEEE flormat.
	A buffer of several floating point numbers
	can be converted at the same time.  The VAX floating point number
	is defined in two longwords.

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
	flt32_to_fltvax


\*/

#define swp_int(long_addr) \
	{ \
	union { \
	      long l; \
	      struct { \
		     short s0; \
		     short s1; \
	      }s; \
	}tmp1, tmp2; \
	tmp1.l = *(long *)long_addr; \
	tmp2.s.s0 = tmp1.s.s1; \
	tmp2.s.s1 = tmp1.s.s0; \
	*(long *)long_addr = tmp2.l; \
	}

convert_double(no_floats,vax_float,ieee_float)
int	no_floats;
unsigned long	vax_float[];
double	*ieee_float;

{
union
{
	double	*d;
	unsigned long	*l;
	unsigned short	*s;
} ptr;

unsigned long	temp[2];		/* temporary ieee format storage */
register long	sign;			/* sign bit */
register long	e;			/* ieee exponent mask */
	 char	zero;			/* is it zero */

	 int	i;

	for (i=0; i<no_floats; i++)
	{
	   temp[0]=vax_float[i*2];
	   temp[1]=vax_float[1+(i*2)];

/*   Swap the words in the VAX floating point number   */

	   swp_int(&temp[0]);		/* swap first longword */
	   
	   swp_int(&temp[1]);		/* swap second longword */


	   if ((temp[0] == 0) && (temp[1] == 0))
	      zero = 1;
	   else
	      zero = 0;

/*   get the sign bit   */

	   if (zero == 0)
	   {
	      sign = temp[0] & (0x1 << 31);
	   
/*   Get the low order 3 bits from the first longword; these bits will
 *   be transfered to the high order bits of the second longword; this
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

/*   Add the new exponent along with the sign bit to the first longword   */
	   
	      temp[0] >>= 3;
	      temp[0] &= ~(0x7ff << 20);
	      temp[0] |= (e << 20);
	      temp[0] |= sign;
	   }   
/*   Cast the two longword integers representing the ieee format into
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
