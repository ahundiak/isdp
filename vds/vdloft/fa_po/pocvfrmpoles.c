/*----
%HD%
 
     MODULE NAME POcvFrmPoles 
 
     Abstract:
        This function build a curve from a existing one.
	if it's possible  cvsol->order = cv->order
	else cvsol->order = cvsol->num_poles

-----
%SC%

     POcvFrmPoles( cv, parType, fromPole, toPole, cvsol, rc )

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *cv  	   IGRbsp_curve      the original curve 

	parType	   IGRshort	     0 uniform.
				     1 arc length

	IGRint	   fromPole          index of the first pole to copy

	IGRint	   toPole	     index of the last pole to copy.

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	
	*cvsol	   IGRbsp_curve	     the curve solution 

        *rc        BSrc              completion code message
                                 	- BSSUCC or BSFAIL

  
-----
%MD%

     MODULES INVOKED:
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 29 novembre 1993.
      
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


POcvFrmPoles (

struct	IGRbsp_curve	*cv,		/*I the original curve  */

IGRshort		parType,	/*I parametrisation type 
						0 = uniform.
				     		1 = arc length  */

IGRint	   		fromPole,       /*I index of the first pole to copy */

IGRint	   		toPole,         /*I index of the last pole to copy. */

	
struct	IGRbsp_curve	*cvsol,	   	/*O curve solution, malloc done by
					    the caller */

BSrc			*rc )		/*O BSSUCC or BSFAIL		     */


{

extern	IGRchar		*memcpy();
extern  IGRboolean	BSchrdlkts();
extern  IGRdouble	BSdistptpts();

IGRint		numPols;
IGRdouble	u;
IGRint		i, numkts;


 /*--- check if we have something to copy ---*/

 numPols = toPole - fromPole + 1;

/* if( numPols <= 0 ) goto wrapup;*/

 if( numPols < 2 ) goto wrapup;

 /*--- copy the poles ---*/

 memcpy((IGRchar *)cvsol->poles,(IGRchar *)&cv->poles[3*fromPole],
	(IGRint) ( 3 * numPols * sizeof(IGRdouble) )  );

 /*--- set the cvsol->structure ---*/

/*
 if( numPols < 4 ) cvsol->order = numPols;
 else		   cvsol->order = 4;
*/

 if( numPols < cv->order ) cvsol->order = numPols;
 else			   cvsol->order = cv->order;

 cvsol->num_poles      = numPols;
 cvsol->periodic       = FALSE;
 cvsol->non_uniform    = (parType == 0) ? FALSE : TRUE;
 cvsol->rational       = FALSE;
 cvsol->weights        = NULL;
 cvsol->bdrys          = NULL;
 cvsol->num_boundaries = 0;
 cvsol->planar         = TRUE;
 cvsol->num_knots      = cvsol->num_poles + cvsol->order;

 /*--- evaluate the knot vector ---*/

 if( parType == 0 ){

	numkts = cvsol->num_poles - cvsol->order;
	u = numkts + 1;
	if( numkts > 0 ) 
	for(i=0;i<numkts;i++) cvsol->knots[cvsol->order+i]=(IGRdouble)(i+1)/u;
	for(i=0;i<cvsol->order;i++){
		cvsol->knots[i]         = 0.0;
		cvsol->knots[numPols+i] = 1.0;
	}  
 }
 else     BSchrdlkts( rc, &cvsol->num_poles, cvsol->poles, 
                      &cvsol->order, &cvsol->periodic, cvsol->knots );

 u = BSdistptpts( rc, cvsol->poles, &cvsol->poles[(cvsol->num_poles-1)*3] );
 if( u < 1.0E-12 ) cvsol->phy_closed = TRUE;
  else             cvsol->phy_closed = FALSE;

 *rc = BSSUCC;
 return;


wrapup:
 *rc = BSFAIL;
 return; 

}
