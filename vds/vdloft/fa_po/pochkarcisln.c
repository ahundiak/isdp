/*----
%HD%
 
     MODULE NAME POchkArcIsLn 
 
     Abstract:
        This function checks if an arc can be replace by a line.


-----
%SC%

IGRlong     POchkArcIsLn( arcStr, p1,  p2, cv, tol, dmax,  rc )

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	*arcStr	   struct geomStruct the arc definition;

        *p1  	   IGRdouble         start point of the arc

	*p2	   IGRdouble	     end point of the arc

	*cv	   struct IGRbsp_curve the original curve that is partially
					approximated by the arc;

	tol	   IGRdouble	     the chord height

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	
	*dmax	   IGRdouble	     deviation

        *rc        BSrc              completion code message
                                 	- BSSUCC 
					- BSFAIL if wrong type

  
-----
%MD%

     MODULES INVOKED: sqrt(), fabs()
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 9 March 1994.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#include <stdio.h>
#include "v_.h"
#include "msdef.h"
#include "bserr.h"
#include "bsvalues.h"
#include "bsvalues_sn.h"
#include "vdloft.h"


IGRlong	POchkArcIsLn (

struct geomStruct	*arcStr,        /*IO the arc stored in geomStr */

IGRdouble		*p1,		/*I the arc start point */

IGRdouble		*p2,		/*I the arc end point */

struct	IGRbsp_curve	*cv,		/*I the original curve that is
				            partially approximated by the
					    arc */

IGRdouble		tol,		/*I real tolerance */

IGRdouble		*dmax,		/*O deviation */

IGRlong			*rc )		/*O BSSUCC 2, 3 */


{

#define EPSILON 1.0E-12

	IGRint 		i;
	IGRdouble	u;
	IGRdouble	dist;
	IGRdouble	midPt[3];
	IGRdouble	eccou;
	IGRdouble	base[3];
	BSrc		irc;

extern  IGRdouble	fabs();
extern  IGRdouble	sqrt();
extern  void		BSmdstptcv();


	if( arcStr->type != geomArc ){
		*rc = 2;
		goto wrapup;
	}

	if( arcStr->uGeom.Arc.sweep_angle > M_PI ){ 
		*rc = 3;
		goto wrapup;
	}

	dist = 0.0;
	for(i=0;i<3;i++){
		midPt[i] = 0.5 * p1[i] + 0.5 * p2[i];
	   	u = midPt[i] - arcStr->uGeom.Arc.origin[i];
		dist += u * u;
	}
	
	dist = sqrt(dist);
	*dmax = fabs( (arcStr->uGeom.Arc.prim_axis - dist ) );
	if( (*dmax) < tol ){

		if( cv ){
			BSmdstptcv( cv, midPt, &u, base, &eccou, &irc );
        		if( ( eccou - tol )  > EPSILON ){
	  			*rc = 4;
	  			goto wrapup;
			}
		}

		*dmax = eccou;
		arcStr->type = geomLine;

		for(i=0;i<3;i++){
			arcStr->uGeom.Line[i]   = p1[i];
			arcStr->uGeom.Line[i+3] = p2[i];
		}

		*rc = BSSUCC;
		return( BSSUCC );
	}
 
wrapup:

	return( BSFAIL );  
}

