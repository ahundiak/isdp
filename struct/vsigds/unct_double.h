/*----------------------------------------------------------------------*/
/* Xconv routines -  convert the data to Little/Big to Big/Little       */
/*                   Endian format.                                     */
/*----------------------------------------------------------------------*/

/*
$Log: unct_double.h,v $
Revision 1.1.1.1  2001/01/04 21:10:41  cvs
Initial import to CVS

 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.1  1997/05/08  14:03:58  pinnacle
 * Struct 250
 *
 * Revision 320.0  1994/12/12  17:59:38  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:53:52  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:31:52  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  19:17:29  tim
 * COMMENT : added Log variable
 *
 * 7/23/96 slj		Commented out unconvert_double as it need to
 *			be linked in from libmcsl.a
 * 07/26/96 slj		Removed comments around unconvert_double until I
 * 			can locate all the appropriate libraries.
 * 09/24/96 slj 	Replaced unconvert_double with reversed engineered
 *			version. Removed libmcsl.a from list of libraries
*/

Xconv_short(s)
  short *s;
{
  union	{
	char c[2];
	short s;
	} x, y;	
	
  x.s = *s;

  y.c[0] = x.c[1]; 
  y.c[1] = x.c[0]; 

  *s = y.s;
}

Xconv_int(i)
  int *i; 
{
  union	{
	char c[4];
	int  i;
	} x, y;	
	
  x.i = *i;

  y.c[0] = x.c[3];
  y.c[1] = x.c[2];
  y.c[2] = x.c[1];
  y.c[3] = x.c[0];

  *i = y.i;
}

/* actual conversion function */
static void flt32_to_fltvax (
        int             no_floats,
        double          *ieee_float,
        unsigned long   vax_float[])
{
  unsigned      short   *vax_ptr;
  unsigned      short   *ieee_ptr;
  unsigned      long    *lvax_ptr;
  unsigned      long    *lieee_ptr;
  unsigned      long    expon;
  unsigned      long    sign;
  unsigned      long    msg;

  int                   i;


  for (i= 0; i<no_floats; i++)
   {
        vax_ptr = (unsigned short *) &vax_float[i*2];
        lvax_ptr = (unsigned long *) vax_ptr;
        ieee_ptr = (unsigned short *) ieee_float++;
        lieee_ptr = (unsigned long *) ieee_ptr;

        /* check for 0 */
#ifdef BIG_ENDIAN
        lvax_ptr[0] = lieee_ptr[1];
        lvax_ptr[1] = lieee_ptr[0];
#endif
        if ((*lieee_ptr == 0) && (*(lieee_ptr+1) == 0)) {
          *lvax_ptr++ = 0;
          *lvax_ptr = 0; }
        else {
#ifndef BIG_ENDIAN
          /* copy to vax number */
          lvax_ptr[0] = lieee_ptr[0];
          lvax_ptr[1] = lieee_ptr[1];
#endif
          /* adjust exponent, ieee - 1023 + 128 -1 = VAX */
#ifndef BIG_ENDIAN
          expon = ((vax_ptr[3] >> 4) & 0x7ff) - 894;
#else
          expon = ((vax_ptr[2] >> 4) & 0x7ff) - 894;
#endif
          /* save the sign */
          sign = lvax_ptr[1] & 0x80000000;

          /* we need to shift the entire f field left 3 bits. */
          msg = (lvax_ptr[0] & 0xe0000000) >> 29;
          lvax_ptr[0] <<=3;

          lvax_ptr[1] = (((lvax_ptr[1] << 3)|msg)&0x007fffff)|(expon<<23)|sign;

          /* swap to vax word order (use sign as temp) */
          sign = vax_ptr[0];
          vax_ptr[0] = vax_ptr[3];
          vax_ptr[3] = (unsigned short) sign;

          sign = vax_ptr[1];
          vax_ptr[1] = vax_ptr[2];
          vax_ptr[2] = (unsigned short) sign;
        }
    }
}


/* Convert IEEE doubles to VAX D-float */
void    unconvert_double(double *dbl)
{
  union {
        unsigned short  s[4];
        unsigned long   l[2];
        double          d;
        } du;

  flt32_to_fltvax(1, dbl, (unsigned long *) &du);

 *dbl = du.d;

  return;
}
