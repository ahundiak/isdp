#ifndef _EMDEFINES
#define _EMDEFINES	0

/************************************************************************/
/*									*/
/*	Miscellaneous Definitions					*/
/*									*/
/************************************************************************/

#ifndef	NULL
#define	NULL		0
#endif

#ifndef	TRUE
#define	TRUE		1
#define	FALSE		0
#endif

#ifndef	MAX
#define	MAX(a,b)	( ((a)>(b)) ? (a) : (b) )
#define	MIN(a,b)	( ((a)<(b)) ? (a) : (b) )
#endif

/* Pixel offsets which allow some space between displayed text and the 	*/
/* window border							*/
#define	XBORDER		5
#define	YBORDER		5


#endif
