/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							arcswap.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/89
**	ABSTRACT:
** These routines are for architectures that have a different byte ordering
** than clipper. IBM/370, and SUN, and whatever else may be needed.
**		
**	
**	REVISION HISTORY:
**	modified April 1991 by John Gwyer - moved the swap byte routines from
**			 arcebcdc.c to here.
**
**
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <string.h>
#include "arch.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/
union short_1
{
	short s;
	struct
	{
		char b1;
		char b2;
	} byte;
};

union short_2
{
	short s;
	struct
	{
		char b2;
		char b1;
	} byte;
};

union int_1
{
	int i;
	struct
	{
		char b1;
		char b2;
		char b3;
		char b4;
	} byte;
};

union int_2
{
	int i;
	struct
	{
		char b4;
		char b3;
		char b2;
		char b1;
	} byte;
};

/*
**      FUNCTION PROTOTYPES
*/
#define arcswap_c
#include "arcswap.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void ARC_swap_bytes(
	char *ptr,
	int len)
{
	register	char  t;
	register	char *a;
	register	char *z;
	register	int   i;

	for ( a = ptr,
		  z = ptr + len - 1,
		  i = len / 2;

		  i > 0 ;

		  a++,
		  z--,
		  i--)
	{
		t  = *a;
		*a = *z;
		*z = t;
	}
}

/******************************************************************************/
extern void ARC_int_swap_bytes(
    arc_s *arc,       /* arc and len params not used in all the four fns below*/
	int *i,
    int len)
{
	union int_1 i1;
	union int_2 i2;

	len = len;	/* shut up the compiler */
	arc = arc;	/* shut up the compiler */

	i1.i = *i;
	i2.byte.b1 = i1.byte.b1;
	i2.byte.b2 = i1.byte.b2;
	i2.byte.b3 = i1.byte.b3;
	i2.byte.b4 = i1.byte.b4;
	*i = i2.i;
}

/******************************************************************************/

extern void ARC_double_swap_bytes(
    arc_s *arc,
	char *ptr,
    int len_dummy)
{
	char buf[sizeof(double)];
	int len;
	char *s1, *t1;

	len_dummy = len_dummy;	/* shut up the compiler */
	arc = arc;	/* shut up the compiler */

	for ( s1 = ptr,
		  t1 = &buf[sizeof(double)-1],
		  len = sizeof(double);

		  len > 0 ;

		  s1++,
		  t1--,
		  len--)
	{
		*t1 = *s1;
	}
	memcpy(ptr,buf,sizeof(double));
}

/******************************************************************************/

extern void ARC_float_swap_bytes(
    arc_s *arc,
	char *ptr,
    int len_dummy)
{
	char buf[sizeof(float)];
	int len;
	char *s1, *t1;

	len_dummy = len_dummy;	/* shut up the compiler */
	arc = arc;	/* shut up the compiler */

	for ( s1 = ptr,
		  t1 = &buf[sizeof(float)-1],
		  len = sizeof(float);

		  len > 0 ;

		  s1++,
		  t1--,
		  len--)
	{
		*t1 = *s1;
	}
	memcpy(ptr,buf,sizeof(float));
}

/******************************************************************************/

extern void ARC_short_swap_bytes(
    arc_s *arc,
	short *s,
    int len)
{
	union short_1 s1;
	union short_2 s2;

	
	arc = arc ; /* shut up the compiler */
	len = len ; /* shut up the compiler */

	s1.s = *s;
	s2.byte.b1 = s1.byte.b1;
	s2.byte.b2 = s1.byte.b2;
	*s = s2.s;
}

/******************************************************************************/
