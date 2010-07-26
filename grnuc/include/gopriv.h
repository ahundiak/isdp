/*
 * Private Include file for Graphics Objects 
 */

#ifndef gopriv_include

#define gopriv_include


/*  This routine does a check to determine if 2 ranges are equal
 *
 *  GRrange    r1		- first range
 *  GRrange    r2		- second range
 *  IGRboolean equal		- flag to indicate if ranges are 
 *				   equal
 *
 */

#define GRrange_check(r1,r2,equal,i)		\
        equal = 1;				\
        for (i = 0; i < 6 && equal; ++i)	\
  	{					\
	    if (r1[i] != r2[i])			\
	    {					\
		equal = 0;			\
	    }					\
        }				

#endif
