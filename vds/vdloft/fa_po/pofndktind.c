/*----
%HD%
 
     MODULE NAME POfndKtInd
 
     Abstract:
        This function finds the dot product of two vectors
-----
%SC%

     POfndKtInd( order, kts, t , greIndex, ktsIndex, rc )
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        order      IGRint        order of the curve
        *kts       IGRdouble	 knots vector on which we will perform the
				 search
	t	   IGRdouble	 paramater to check
	greIndex   IGRint	 index defining where we start the search.

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	*ktsIndex  IGRint	index solution with t <= kts[i] 

        *rc        BSrc         BSSUCC or BSKNTI
  
-----
%MD%

     MODULES INVOKED: none
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 8 March 1993 Creation date.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#include "v_.h"
#include "madef.h"
#include "ma.h"
#include "bserr.h"
#include "bstypes.h"

POfndKtInd( order, kts, t , greIndex, ktsIndex, rc )

IGRint		order;		/*I order of the curve			      */

IGRdouble	*kts;		/*I knots vector on which we will perform the
				    search				      */
IGRdouble	t;		/*I paramater to check			      */
IGRint		greIndex;	/*I index defining where we start the search  */
IGRint		*ktsIndex;	/*O index solution with t <= kts[i]           */
BSrc		*rc;		/*O BSSUCC or BSKNTI			      */


{


IGRint	i, start, end;

 	*rc = BSKNTI;

	*ktsIndex = -1;
	start = greIndex + 2;
	end = start + order - 2;


	for( i=start;i<=end;i++ ){
		if( t <= kts[i] ){
			*ktsIndex = i;
			*rc = BSSUCC;
			break;
		}
	}

	#ifdef DEBUG
	printf("ktsIndex = %d\n",*ktsIndex);
	#endif

	return;
}
