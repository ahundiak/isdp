/*----
%HD%
 
     MODULE NAME POchkCirArc 
 
     Abstract:
        This function checks if a set of points belong to an arc or circle.


-----
%SC%

     POchkCirArc( pts, weights, numPts,  relTol, arcStr, isArc,  rc )

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *pts  	   IGRdouble         array of points 

	*weights   IGRdouble	     array of weights if rationaltol2 

	numPts	   IGRint	     number of points

	relTol	   IGRdouble	     the relative error to concider that points
				     belong to a circle.

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	
	*arcStr   struct IGRarc	     circle or arc solution.
				     NULL if not a circle or arc

	*isArc	  IGRshort	     to tell if circle or arc

        *rc       IGRlong              completion code message
                                 	- BSSUCC or BSFAIL

  
-----
%MD%

     MODULES INVOKED: BSdistptpt(), BScrossp(), BSxln(), fabs()
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 22 February 1994.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#include <stdio.h>
#include "v_.h"
#include "madef.h"
#include "ma.h"
#include "msdef.h"
#include "igr.h"
#include "igrdef.h"
#include "bserr.h"
#include "bsvalues.h"


POchkCirArc (

IGRdouble		*pts,		/*I array of points */

IGRdouble		*weights,	/*I array of weights if rational,
					    else should be set to NULL */

IGRint			numPts,		/*I number of points */

IGRdouble		relTol,		/*I real tolerance */

struct	IGRarc		*arcStr,	/*O circle or arc solution.
				     	    NULL if not a circle or arc */

IGRshort		*isArc,         /*O isArc = TRUE if arc, else circle */

IGRlong			*rc )		/*O BSSUCC or BSFAIL		     */


{


	IGRint 		i;
	IGRint		j;
        IGRint		numRealPts;
	IGRint		index1;
	IGRint		index2;
	IGRdouble	closureDist;
	IGRdouble	curRad;
	IGRdouble	averageRad;
struct	IGRbsp_curve	bspArc;
	IGRdouble	bstab[72];



extern	IGRdouble	BSdistptpt();
extern	IGRdouble	BSdistptpts();
extern  IGRdouble	fabs();
extern  IGRboolean	BSarc3pts();
extern  IGRboolean	MAbctoar();
extern	IGRboolean	BScirc3pts();


 /*
  * check if numPts >= 4
  */


#ifdef DEBUG
  printf("--------------------\n");
#endif

  if( numPts < 4 ){
	#ifdef DEBUG
	printf("ERROR in POchkCirArc\n");
	printf("numPts must be >= 4\n");
	#endif
	goto wrapupend;
  }


 /*
  *   unweights the points if rational
  */

  if( weights ){
	numRealPts = 3 * numPts;
	for(i=0;i<numRealPts;i+=3){
		j = i / 3;
		pts[i]   /= weights[j];
		pts[i+1] /= weights[j];
		pts[i+2] /= weights[j];
	}
  }
 


 /*
  *	set bsArc
  */

   bspArc.poles   = &bstab[0];
   bspArc.knots   = &bstab[27];
   bspArc.weights = &bspArc.knots[12];



 /*
  *   test if the curve is closed or not
  */

  closureDist = BSdistptpts( rc, pts, &(pts[3*(numPts-1)]));

  if( closureDist > 1.0E-6 ) {

       /*	
	*  the curve is not closed, then we:
	*    - just set index that will let us to evaluate mediatrices
	*/
	
	index1 = 3 * ( numPts / (IGRint)2 );
	index2 = 3 * ( numPts - 1 );

	BSarc3pts( rc, pts, &(pts[index1]), &(pts[index2]), &bspArc );
	if( *rc != BSSUCC ) goto wrapup;

	MAbctoar( rc, &bspArc, arcStr);
	numRealPts = 3 * ( numPts - 1 );
	
	*isArc = TRUE;

  }
  else{

	/*
	*   the curve is closed, then we:
	*     - set flag to closed
	*     - set index for mediatrices evaluation
	*/
     
	index1 = 3 * (numPts / (IGRint)3 );
	index2 = 3 * (numPts - 1) - index1;

	BScirc3pts( rc, pts, &(pts[index1]), &(pts[index2]), &bspArc );
	if( *rc != BSSUCC ) goto wrapup;

	MAbctoar( rc, &bspArc, arcStr);

	numRealPts = 3 * numPts;

	*isArc      = FALSE;

  }


 averageRad = arcStr->prim_axis;
 
 for(i=3;i<numRealPts;i+=3 ){
 	curRad = BSdistptpt( rc, &(arcStr->origin[0]), &(pts[i]) );
	curRad = fabs( (curRad-averageRad) );
	if( curRad > relTol ) goto wrapup;
 }


 /*
  *
  *  unweight the pts back if necessary
  *
  */

 if( weights ){
	numRealPts = 3 * numPts;
	for(i=0;i<numRealPts;i+=3){
		j = i / 3;
		pts[i]   *= weights[j];
		pts[i+1] *= weights[j];
		pts[i+2] *= weights[j];
	}
 }

 *rc = BSSUCC;
 return;



wrapup:

  	if( weights ){
		numRealPts = 3 * numPts;
		for(i=0;i<numRealPts;i+=3){
			j = i / 3;
			pts[i]   *= weights[j];
			pts[i+1] *= weights[j];
			pts[i+2] *= weights[j];
		}
  	}

wrapupend:

	*rc = BSFAIL;
	return;  
}

