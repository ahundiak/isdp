/*----
%HD%
 
     MODULE NAME POcvevGreAbs 
 
     Abstract:
        This function evaluates the Greville abscissia of a set of
	parameters. the caller must malloc the receiving array to
	the number of poles.

-----
%SC%

     POcvevGreAbs( sourceCv, tempCv, distEvalWanted, greIndex, numGreAbs, 
	           greAbs, rc )

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *sourceCv  IGRbsp_curve      the original curve to minimise
				     the greville computation

	*tempCv    IGRbsp_curve      the Greville distance is evaluated
				     between the poles of this curve
				     and their image evaluated with
			             the sourceCv to winn time

	distEvalWanted IGRboolean    flag to tell if you want to
				     evaluate Greville parameter and
				     the square distance to

	greIndex   IGRint            the index from which you start
				     to evaluate the Greville parameters 

	numGreAbs  IGRint	     the number of Greville pa and or
				     distance you want to evaluate 


-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	
	*greAbs	  struct cvGrePa     the array containing the Greville
				     parameter and the square distance
				     between the pole and his image
			             on the curve 

	
        *rc        BSrc              completion code message
                                 	- BSSUCC or BSFAIL

  
-----
%MD%

     MODULES INVOKED: none
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 8 mars 1993.
      
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
#include "vdloft.h"

/*
# ifndef DEBUG
# define DEBUG 0
# endif
*/

POcvevGreAbs (

struct	IGRbsp_curve	*sourceCv,	/*I the original curve to minimise
					    the greville computation */

struct	IGRbsp_curve	*tempCv,	/*I the Greville distance is evaluated
					    between the poles of this curve
				            and their image evaluated with
					    the sourceCv to winn time        */

IGRboolean		distEvalWanted, /*I flag to tell if you want to
					    evaluate Greville parameter and
					    the square distance to           */

IGRint			greIndex,       /*I the index from which you start
					    to evaluate the Greville 
					    parameters */

IGRint			numGreAbs,	/*I the number of Greville pa and or
					    distance you want to evaluate    */

struct  cvGrePa		*greAbs,	/*O the array containing the Greville
					    parameter and the square distance
					    between the pole and his image
					    on the curve                     */

BSrc			*rc )		/*O BSSUCC or BSFAIL		     */


{

IGRint		deg, i, endGreAbs, j, jstart, jend, iM3;
IGRdouble	pt[3], pol[3];


 extern		IGRdouble	BSdistptpts();
 extern		void		BScveval();
	

 deg = sourceCv->order - 1;

 if( sourceCv->num_knots < deg ) goto wrapup;

 endGreAbs = greIndex + numGreAbs;


 if( distEvalWanted == TRUE ){

	/*c we want to evaluate the square distance between poles and 
	    Greville points */ 

	if( sourceCv->rational ){

		for(i=greIndex;i<endGreAbs;i++){

			greAbs[i].pa = 0.0;
			jstart = i + 1;
			jend = jstart + deg;
		
			for(j=jstart;j<jend;j++) 
			greAbs[i].pa += tempCv->knots[j];

			greAbs[i].pa = greAbs[i].pa / (IGRdouble) deg;
			BScveval( sourceCv, greAbs[i].pa, 0, pt, rc );

			iM3 = 3 * i;
			pol[0] = tempCv->poles[iM3]   / tempCv->weights[i];
			pol[1] = tempCv->poles[iM3+1] / tempCv->weights[i];
			pol[2] = tempCv->poles[iM3+2] / tempCv->weights[i];

			greAbs[i].dist = BSdistptpts(rc,pol,pt);

		}
	}
	else{
		for(i=greIndex;i<endGreAbs;i++){

			greAbs[i].pa = 0.0;
			jstart = i + 1;
			jend = jstart + deg;
		
			for(j=jstart;j<jend;j++) 
			greAbs[i].pa += tempCv->knots[j];

			greAbs[i].pa = greAbs[i].pa / (IGRdouble) deg;
			BScveval( sourceCv, greAbs[i].pa, 0, pt, rc );
			greAbs[i].dist = BSdistptpts(rc,&tempCv->poles[3*i],pt);
		}
	}
 }
 else{
	/*c we do not want to evaluate the distance */

	for(i=greIndex;i<endGreAbs;i++){

		greAbs[i].pa = 0.0;
		jstart = i + 1;
		jend = jstart + deg;
		
		for(j=jstart;j<jend;j++) 
		greAbs[i].pa += tempCv->knots[j];

		greAbs[i].pa = greAbs[i].pa / (IGRdouble) deg;
	}
 }


 #ifdef DEBUG
	for(i=greIndex;i<numGreAbs;i++)
	printf("greAbs[%d] = %f, %f\n",i,greAbs[i].pa,greAbs[i].dist);
 #endif


 *rc = BSSUCC;
 return;


wrapup:
 	*rc = BSFAIL;
	return;

}
