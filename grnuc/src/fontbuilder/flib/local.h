/*
 *  local.h  -  definitions for logical C
 */

/*
$Log: local.h,v $
Revision 1.1.1.1  2001/12/17 22:39:13  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:16:22  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:39  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:33  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:53:36  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:31:39  root
 * COMMENT : Corresponds to Rel201.3 in 2.0.1 RCS
 *
 * Revision 201.3  1992/07/13  19:17:22  tim
 * COMMENT : added Log variable
 *
*/

#ifndef DEF_LOCAL
#define DEF_LOCAL

/*
	Define some new data types to make things more convient
 */


#define bits		unsigned short
#define bool		int
#define tbool		tiny
#define tiny		char
#define utiny		unsigned tiny
#define uchar		unsigned char

#define	longword	long
#define	word		short
#ifndef byte
#define byte		char/*microcsl.h has typedef unsigned char byte */
#endif
/*#define EOF -1        Eof is already defined in /usr/include/stdio.h */
#define BUFLEN 1024
#define BLOCK 255
#define BUF_512 512
#define BUF_1024 1024
#define BUF_2048 2048
#define BUF_4096 4096
#define OUTLEN 4096
#define NRLEN (21)
#define FHLEN 103
#define EOS		NUL
#define FOREVER		for(;;)
#define NO		(0)
#define NUL		'\0'
#ifndef TRUE
#define TRUE 		1
#endif
#ifndef FALSE
#define FALSE		0
#endif
#define YES		(1)

#define _and_		&&
#define _or_		||
#define _not_		!

#define AND(x,y)	((x) & (y))
#define NOT(x)		(~(x))
#define OR(x,y)		((x) | (y))
#define XOR(x,y)	((x) ^ (y))

#define ABS(x)		(((x) < 0) ? -(x) : (x))
#define MAX(x,y)	(((x) < (y)) ? (y) : (x))
#define MIN(x,y)	(((x) < (y)) ? (x) : (y))

#define SUCCESS		0
#define FAILURE		1
#define ISFALSE(x)	(x==0)
#define ISTRUE(x)	(x==1)
#define ISSUCCESS(x)	(x==0)
#define STSSEV(x)	((x) & STS_M_SEVERITY)
#define ISFAIL(x)	(!ISSUCCESS(x))
#define ISINFO(x)	(STSSEV(x)==STS_K_INFO)
#define ISWARNING(x)	(STSSEV(x)==STS_K_WARNING)
#define ISERROR(x)	(STSSEV(x)==STS_K_ERROR)
#define ISFATAL(x)	(STSSEV(x)==STS_K_SEVERE)


#endif
