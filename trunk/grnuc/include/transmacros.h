#ifndef transmacros_include

#define transmacros_include

/*
 *  Include file for macros needed during
 *  translation of IGDS elements to their
 *  IGE object equivalents and vice versa.
 */


/*
 *  Following is a list of include file dependencies
 *
 *  	igrtypedef.h
 *      igr.h
 *  
 */

#include "exsysdep.h"

#define GUswapint(s,d)          \
    {                           \
        IGRshort t, *p1, *p2;   \
        p1 = (IGRshort *)s;     \
        p2 = p1 + 1;            \
        t = *p1;                \
        *p1 = *p2;              \
        *p2 = t;                \
        *d = *s;                \
    }

/*
#define GUswapint(s,d)				\
	{					\
	    IGRshort t;				\
	    t = *((IGRshort *)s); 		\
	    *((IGRshort *)s) = *(((IGRshort *) s) + 1); 	\
	    *(((IGRshort *) s) + 1) = t;	\
	    *d = *s;				\
	}
*/

#define GUswapint_by_char(s)			\
	{					\
	    IGRchar t1, t2;			\
   	    t1 = *s;		 		\
	    t2 = *(s+1);			\
	    *s = *(s + 2);		 	\
	    *(s+1) = *(s+3);			\
	    *(s+2) = t1;			\
	    *(s+3) = t2;			\
	}
	
#define GUswaprange_igdsige(s,d)			\
	{						\
	    IGRshort t;					\
	    t = (*((IGRshort *)s)) ^ 0x8000;   		\
	    *(IGRshort *)s = *(((IGRshort *) s) + 1); 	        \
	    *(((IGRshort *) s) + 1) = t;		\
	    *d = *s;					\
	}

#ifdef BIG_ENDIAN 
#define GUswaprange_igeigds(s,d)  \
   {                           \
        IGRshort t, *p1, *p2;   \
        p1 = (IGRshort *)s;     \
        p2 = p1 + 1;            \
        t = *p2;                \
        *p2 = *p1 ^ 0x8000;     \
        *p1 = t;                \
        *d = *s;                \
    }
#else
#define GUswaprange_igeigds(s,d)  \
    {                           \
        IGRshort t, *p1, *p2;   \
        p1 = (IGRshort *)s;     \
        p2 = p1 + 1;            \
        t = *p1;                \
        *p1 = *p2 ^ 0x8000;     \
        *p2 = t;                \
        *d = *s;                \
    }
#endif

/*
#define GUswaprange_igeigds(s,d)			\
	{						\
	    IGRshort t;					\
	    t = (*((IGRshort *)s));      		\
	    *(IGRshort *)s = (*(((IGRshort *) s) + 1)) ^ 0x8000;    \
	    *(((IGRshort *) s) + 1) = t;		\
	    *d = *s;					\
	}
*/	

/*
 * GUarray_max finds the maximum value in the array passed in.
 * a - pointer to array, this value is modified.
 * m - pointer to maximum value, must point to same type as array.
 * n - number of values in array.
 */

#define GUarray_max(a,m,n)					\
	{							\
		IGRlong i__xx;					\
		*m = *a;				\
		for ( i__xx = 0 ; i__xx < n ; i__xx++, a++ )	\
			if ( *a > *m ) *m = *a;			\
	}

#define GUaccumulate_range(range1,range2)			\
	{							\
	    if ( range1[0] < range2[0] )			\
		range2[0] = range1[0];				\
	    if ( range1[1] < range2[1] )			\
		range2[1] = range1[1];				\
	    if ( range1[2] < range2[2] )			\
		range2[2] = range1[2];				\
	    if ( range1[3] > range2[3] )			\
		range2[3] = range1[3];				\
	    if ( range1[4] > range2[4] )			\
		range2[4] = range1[4];				\
	    if ( range1[5] > range2[5] )			\
		range2[5] = range1[5];				\
	}

#define GUnint(val)   ((val >= 0.0 ) ? ((IGRlong) ((val) + 0.5))   \
				     : ((IGRlong) ((val) - 0.5)));

#define GUbit_set(addr,bit_no)					\
		  *(((IGRchar *) (addr))+((bit_no)/8))		\
	      |=  (1 << ((bit_no)%8));

#define GUbcweight(msg,curve)					\
	TRUE;							\
	*(msg) = MSSUCC;					\
	if ((curve)->rational)					\
	{							\
	    IGRlong	ind;					\
	    for (ind = 0; ind < (curve)->num_poles; ind++) 	\
	    {							\
		(curve)->poles[3*ind] 	*= (curve)->weights[ind];\
		(curve)->poles[3*ind+1] *= (curve)->weights[ind];\
		(curve)->poles[3*ind+2] *= (curve)->weights[ind];\
	    }							\
	}

#define GUbcunweight(msg,curve)					\
	TRUE;						        \
	*(msg) = MSSUCC;					\
	if ((curve)->rational)					\
	{							\
	    IGRlong ind;					\
	    for ( ind = 0; ind < (curve)->num_poles; ind++ )	\
	    {							\
	 	(curve)->poles[3*ind]   /= (curve)->weights[ind];\
		(curve)->poles[3*ind+1] /= (curve)->weights[ind];\
		(curve)->poles[3*ind+2] /= (curve)->weights[ind];\
	    }							\
	}
	
#endif
