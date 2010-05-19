/*----
%HD%
 
     MODULE NAME POfndMaxDist
 
     Abstract:
        This function finds the index of the Greville parameter which
	is at the largest square distance.
-----
%SC%

	POfndMaxDist( greAbs, numGreAbs, indexMax, rc )

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *greAbs	   struct cvGrePa   array of structure that contains
			            all the Greville abscissia and
			            we will find which point is at
				    the farest distance		  
 
	numGreAbs  IGRint 	    number Greville dist to check

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

	*indexMax  IGRint	index of the largest distance

        *rc        BSrc         completion code message
                                 - always BSSUCC
  
-----
%MD%

     MODULES INVOKED: none
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 8 of March 1993 Creation date.
      
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
#include "vdloft.h"

POfndMaxDist( greAbs, numGreAbs, indexMax, rc )

struct  cvGrePa		*greAbs;	/*I array of structure that contains
					    all the Greville abscissia and
					    we will find which point is at
					    the farest distance		    */

	IGRint		numGreAbs;	/*I number Greville dist to check   */
	IGRint		*indexMax;      /*O index of the largest distance   */
	BSrc		*rc;		/*O fulltime BSSUCC 		    */
{

IGRint		i;
IGRdouble	distSol;


 distSol = -1.0;

 for(i=0;i<numGreAbs;i++){

	if( greAbs[i].dist > distSol ){
		distSol = greAbs[i].dist;
		*indexMax = i;
	}		
 }

 #ifdef DEBUG
	printf("indexMax = %d, greAbs.pa =%f, greAbs.dist = %f\n",
	        (*indexMax),greAbs[(*indexMax)].pa, greAbs[(*indexMax)].dist);
 #endif

 

 *rc = BSSUCC;
 return;

}
