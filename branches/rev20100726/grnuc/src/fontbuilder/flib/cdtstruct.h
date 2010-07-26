/*
$Log: cdtstruct.h,v $
Revision 1.1.1.1  2001/12/17 22:39:13  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:16:07  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:23  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:19  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:52:59  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:31:08  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  19:17:00  tim
 * COMMENT : added Log variable
 *
*/

typedef struct  {
	        byte    abc_wid;	/* abc width for cell */
		byte	a_wid;			/* a width */
		byte	c_wid;			/* c width */
		byte    asc;			/* ascender */
		byte    desc;			/* descender */
		byte	just;			/* justification for symbol fonts */
		} byt_dim;

typedef struct {
		unsigned short    abc_wid;
		short	 a_wid;
		short	 c_wid;
		short	 asc;
		short	 desc;
		short	 just;
		} word_dim;

typedef struct   {
		   unsigned long    abc_wid;
		   long	   a_wid;
		   long	   c_wid;
		   long	   asc;
		   long	   desc;
		   long	   just;
		   } lgword_dim;	

