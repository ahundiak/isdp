/*----
%HD%
 
     MODULE NAME POevPoleLen
 
     Abstract:
        This function evaluates the length between each poles.
-----
%SC%

POevPoleLen( cv, totalLenWanted, startIndex, numPoles, poleLen, totalLen, rc )

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *cv       IGRbsp_curve     curve

	totalLenWanted IGRboolean  TRUE if we want to evaluated the
				   total length between all poles 
				   ELSE we evaluate the distance 
				   between each two poles and store
				   the result in poleLen.

	startIndex IGRint	   from which poles we start to 
				   evaluate the distance.

	numPoles   IGRint	   number of poles

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

	*poleLen   IGRdouble	 this array contains the single    
				 between each poles
	
	*totalLen  IGRdouble	 totalLen evaluated if 
			         totalLenWanted is set to TRUE

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
        
        JLL    : Creation date.
      
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
#include "msdef.h"
#include "bserr.h"
#include "bstypes.h"


POevPoleLen (

struct	IGRbsp_curve	*cv,		/*I the curve on which we insert knots*/

	IGRboolean	totalLenWanted, /*I TRUE if we want to evaluated the
					    total length between all poles 
					    ELSE we evaluate the distance 
					    between each two poles and store
					    the result in poleLen	      */

	IGRint		startIndex,	/*I from which poles we start to 
					    evaluate the distance	      */

	IGRint		numPoles,	/*I number of poles 		      */

	IGRdouble	*poleLen,       /*O this array contains the single    
					    between each poles		      */

	IGRdouble	*totalLen,	/*O totalLen evaluated if 
					    totalLenWanted is set to TRUE     */

	IGRlong		*rc )
{

IGRint			i, iend, istart, iD3;
IGRdouble		Pt1[3], Pt2[3];

extern	IGRdouble	BSdistptpt();


	if(cv->rational){
		

		istart = 3 * startIndex;

		for(i=0;i<3;i++)
		Pt1[i] = cv->poles[istart+i] / cv->weights[startIndex];
		
		istart = istart + 3;
		iend = 3 * ( startIndex + numPoles ) ;

		for(i=istart;i<iend;i+=3){

			iD3 = i / 3;
			Pt2[0] = cv->poles[i]   / cv->weights[iD3];
			Pt2[1] = cv->poles[i+1] / cv->weights[iD3];
			Pt2[2] = cv->poles[i+2] / cv->weights[iD3];
		
			poleLen[iD3-1] = BSdistptpt(rc,Pt1,Pt2); 

			Pt1[0] = Pt2[0];
			Pt1[1] = Pt2[1];
			Pt1[2] = Pt2[2];

		}
	}
	else{

		istart = 3 * startIndex;
		iend = 3 * ( startIndex + numPoles - 1 ) ;

		for(i=istart;i<iend;i+=3)
		poleLen[i/3] = 	BSdistptpt(rc,&cv->poles[i],&cv->poles[i+3]); 
	}

	if( totalLenWanted == TRUE ){

		*totalLen = 0.0;
		iend = cv->num_poles - 1;
		for(i=0;i<iend;i++) *totalLen = *totalLen + poleLen[i];

	}


	#ifdef DEBUG
	for(i=0;i<iend;i++) printf("polLen[%d] = %f\n",i,poleLen[i]);
	#endif

	*rc = BSSUCC;
	return;
}
