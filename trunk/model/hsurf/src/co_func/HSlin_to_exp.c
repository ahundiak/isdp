/* 

$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $

    HSlin_to_exp:  given a percentage (an integer value in the range
       [0..100]), this function returns an exponent (an integer value in
       the range [1..128]).
 
    HSexp_to_lin:  given an exponent (an integer value in the range
       [1..128]), this function returns a percentage (an integer value in
       the range [0..100]).
 
*/

#include <stdio.h>
#include <math.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

#include "HSpr_co_func.h"

  static unsigned char table[51] = {
      1,   1,   1,   1,   1,   2,   2,   2,   2,   2,  /* 0% - 18% */
      3,   3,   3,   4,   4,   4,   5,   5,   6,   6,  /* 20% - 38% */
      7,   8,   8,   9,  10,  11,  12,  14,  15,  17,  /* 40% - 58% */
     18,  20,  22,  25,  27,  30,  33,  36,  40,  44,  /* 60% - 78% */
     49,  53,  59,  65,  71,  79,  87,  96, 105, 116,  /* 80% - 98% */
    128};                                              /* 100% */

/*--------HSlin_to_exp-----------------------------------------------------*/

/* Given a percentage (an integer value in the range [0..100]), this       */
/*   function returns an exponent (an integer value in the range           */
/*   [1..128]).  The array "table" is used to accomplish this feat.  It is */
/*   organized as follows:                                                 */
/*     table[n] contains the exponent that corresponds to (2*n)%.          */
/*   For example,                                                          */
/*     table[0] contains the exponent that corresponds to 0%.              */ 
/*     table[1] contains the exponent that corresponds to 2%.              */
/*     table[2] contains the exponent that corresponds to 4%.              */
/*       ...                                                               */
/*     table[50] contains the exponent that corresponds to 100%.           */
/*   Linear interpolation is done between adjacent table entries to derive */
/*   the odd percentages.                                                  */

#if defined(__STDC__) || defined(__cplusplus)
	int HSlin_to_exp( int percentage )
#else
	int HSlin_to_exp (percentage)
	int percentage;  /* "linear" percentage, an integer value in [0..100] */
#endif

{
  int n, value;

  n = percentage/2;

  if ( (n * 2) < percentage )
     value = table[n] + (percentage - n*2)/2.0 * (table[n+1] - table[n]) + 0.5;
  else
     value = table[n];

  return (value);

}    /* HSlin_to_exp */


/*--------HSexp_to_lin------------------------------------------------------*/

/* Given an exponent (an integer value in the range [1..128]), this        */
/*   function returns a percentage (an integer value in the range          */
/*   [0..100]).  The array "table" is used to accomplish this feat.  It is */
/*   organized as described above.  "table" is searched until the exponent */
/*   in question is <= an entry in the array; then linear interpolation is */
/*   done to find a corresponding "linear" percentage value.               */

#if defined(__STDC__) || defined(__cplusplus)
	int HSexp_to_lin( int exponent )
#else
	int HSexp_to_lin (exponent)
	int exponent;  /* exponent, an integer value in [1..128] */
#endif

{
  int i=0, min, max, value;
	
  while (i <= 51) 
  {
     if ( exponent <= table[i] )
     {
        if ( exponent == table[i] )
    	{
      	   min = i; max = i;
	   while (exponent == table[i])
	   {
	      max = i;
	      i++;
	   }

           return( min + max );
	}

        if ( exponent < table[i] )
    	{
           value = (i-1 + (exponent-table[i-1])/((table[i]-table[i-1])*1.0))* 2;
	   return( value );
	}

     }

     i++;
  }
  return(0);
}    /* HSexp_to_lin */


