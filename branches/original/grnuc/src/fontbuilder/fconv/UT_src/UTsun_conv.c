/*----------------------------------------------------------------------*/
/* Xconv routines -  convert the data to Little/Big to Big/Little 	*/
/*		     Endian format.					*/ 
/*----------------------------------------------------------------------*/

/*
$Log: UTsun_conv.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:41  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:55  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:55  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:52:03  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:30:22  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  20:42:25  tim
 * COMMENT : added Log variable
 *
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

Xconv_double(d)
  double *d;
{
  union	{
	char c[8];
	double d;
	} x, y;	
	
  x.d = *d;

  y.c[0] = x.c[7];
  y.c[1] = x.c[6];
  y.c[2] = x.c[5];
  y.c[3] = x.c[4];
  y.c[4] = x.c[3];
  y.c[5] = x.c[2];
  y.c[6] = x.c[1];
  y.c[7] = x.c[0];

  *d = y.d;
}
