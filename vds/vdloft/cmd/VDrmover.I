/* $Id: VDrmover.I,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $ */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdloft/cmd/VDRepSrfCmd.sl
 *
 * Description:    Contains a set of functions to remove overlaps and
 *                 coincident poles.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrmover.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/01/29  20:12:00  pinnacle
# TR_179702387: converted file from Loft to VDS
#
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *  11/01/94  jll     Creation
 *  01/23/98  ejm     TR:179702387, converted file from Loft to VDS
 ***************************************************************************/

class implementation Root;

/*
# ifndef DEBUG
# define DEBUG 1
# endif
*/


#include <stdio.h>
/*
#include "vlprototype.h"
*/

#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "gr.h"

#include "bs.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "bserr.h"
#include "growner.h"
#include "igr.h"


#include "igrdp.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dp.h"
#include "maerr.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "EMSssprops.h"
#include "EMSdpb.h"
#include "EMSopt.h"
#include "grmacros.h"
#include "dpezmac.h"
#include "griodef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "nddef.h"
#include "asmacros.h"
#include "parametric.h"
#include "vsdbgmacros.h"


  


extern	IGRdouble	BSdotp();
extern	IGRdouble	BSlenvec();
extern  IGRboolean	BSnorvec();
extern  IGRdouble	sqrt();
extern	IGRdouble	fabs();
extern  char		*malloc();
extern  IGRboolean 	BSfindmkts();
extern  IGRdouble	BSdistptpts();
extern			BSmkvec();
extern IGRboolean       BSxtractpar();
extern IGRboolean	BSunwght_p();
extern IGRboolean	BSwght_p();

/*==========================================================================*/

void VDSmvTwoPolesOnCv( crv, begPol, endPol, firstPolInd, polTol, msg )

/*h this function moves two coincident poles. The caller should notice that
    if the curve is rational this function is expecting that the poles have been
    already unweighted.
*/

struct	IGRbsp_curve	*crv;		/*IO the input curve with the modifyed
				             after execution 		      */
IGRint			begPol;		/*I  the first pole evaluated with
					     a knot multiplicity equal to
					     order - 1                        */
IGRint			endPol;		/*I  the last pole evaluated with
					     a knot multiplicity equal to
					     order - 1                        */
IGRint			firstPolInd;    /*I  index of the first pole to 
					     modify			      */
IGRdouble		polTol;		/*I  the displacement length          */
IGRlong			*msg;		/*O  MSSUCC or MSFAIL	              */

{
 


 IGRint		i;
 IGRdouble	u1[3],u2[3], d1, d2;
 


 if( firstPolInd ==  begPol ){

	__DBGpr_com("mul=2 begPol\n");

	d1 = 0.0;
 
  	for(i=0;i<3;i++){
	   u1[i] = crv->poles[firstPolInd+6+i] - crv->poles[firstPolInd+i];
	   d1 = d1 + u1[i] * u1[i]; 
	}

	d1 = polTol / (sqrt(d1));

	for(i=0;i<3;i++)
	crv->poles[firstPolInd+3+i] = crv->poles[firstPolInd+i] + d1 * u1[i];
	
 }
 else if ( firstPolInd ==  (endPol-3) ){
	__DBGpr_com("mul=2 endPol\n");

	d1 = 0.0;
 
  	for(i=0;i<3;i++){
	   u1[i] = crv->poles[firstPolInd-3+i] - crv->poles[firstPolInd+3+i];
	   d1 = d1 + u1[i] * u1[i]; 
	}

	d1 = polTol / (sqrt(d1));

	for(i=0;i<3;i++)
	 crv->poles[firstPolInd+i] = crv->poles[firstPolInd+i+3] + d1 * u1[i];

 }
 else{
	__DBGpr_com("mul=2 midle\n");

	d1 = 0.0;
	d2 = 0.0;
 
  	for(i=0;i<3;i++){
	   u1[i] = crv->poles[firstPolInd-3+i] - crv->poles[firstPolInd+i];
	   d1 = d1 + u1[i] * u1[i]; 
	   u2[i] = crv->poles[firstPolInd+6+i] - crv->poles[firstPolInd+i];
	   d2 = d2 + u2[i] * u2[i]; 
	}

	d1 = polTol / (sqrt(d1));
	d2 = polTol / (sqrt(d2));

	for(i=0;i<3;i++){
	  crv->poles[firstPolInd+3+i] = crv->poles[firstPolInd+i] + d2 * u2[i];
	  crv->poles[firstPolInd+i]   = crv->poles[firstPolInd+i] + d1 * u1[i];
	}

 }

 *msg = MSSUCC;
 return;

}

/*===========================================================================*/

void VDSmvThreePolesOnCv( crv, begPol, endPol, firstPolInd, polTol, msg )

/*h this function moves three coincident poles. The caller should notice that
    if the curve is rational this function is expecting that the poles have been
    already unweighted.
*/

struct	IGRbsp_curve	*crv;		/*IO the input curve with the modifyed
				             after execution 		      */
IGRint			begPol;		/*I  the first pole evaluated with
					     a knot multiplicity equal to
					     order - 1                        */
IGRint			endPol;		/*I  the last pole evaluated with
					     a knot multiplicity equal to
					     order - 1                        */
IGRint			firstPolInd;  /*I  index of the first pole to 
					     modify			      */
IGRdouble		polTol;		/*I  the displacement length          */
IGRlong			*msg;		/*O  MSSUCC or MSFAIL	              */

{
 

 IGRint		i;
 IGRdouble	u1[3],u2[3], d1, d2;
 


 if( firstPolInd ==  begPol ){

	__DBGpr_com(" mul=3 begPol\n");
	d1 = 0.0;
 
  	for(i=0;i<3;i++){
	   u1[i] = crv->poles[firstPolInd+9+i] - crv->poles[firstPolInd+i];
	   d1 += u1[i] * u1[i]; 
	}

	d1 = polTol / (sqrt(d1));

	for(i=0;i<3;i++){
	  crv->poles[firstPolInd+3+i] = crv->poles[firstPolInd+i] + d1 * u1[i];
	  crv->poles[firstPolInd+6+i] = crv->poles[firstPolInd+3+i] + 
				        d1 * u1[i];
	}
 }
 else if ( firstPolInd ==  (endPol-6) ){
	__DBGpr_com("mul=3 endPol\n");

	d1 = 0.0;
 
  	for(i=0;i<3;i++){
	   u1[i] = crv->poles[firstPolInd-3+i] - crv->poles[firstPolInd+6+i];
	   d1 += u1[i] * u1[i]; 
	}

	d1 = polTol / (sqrt(d1));

	for(i=0;i<3;i++){
	  crv->poles[firstPolInd+3+i] = crv->poles[firstPolInd+i+6] + d1*u1[i];
	  crv->poles[firstPolInd+i] = crv->poles[firstPolInd+i+3] + d1*u1[i];
	}

 }
 else{

	__DBGpr_com("mul=3 midle\n");
	d1 = 0.0;
	d2 = 0.0;
 
  	for(i=0;i<3;i++){
	   u1[i] = crv->poles[firstPolInd-3+i] - crv->poles[firstPolInd+3+i];
	   d1 += u1[i] * u1[i]; 
	   u2[i] = crv->poles[firstPolInd+9+i] - crv->poles[firstPolInd+3+i];
	   d2 += u2[i] * u2[i]; 
	}

	d1 = polTol / (sqrt(d1));
	d2 = polTol / (sqrt(d2));

	for(i=0;i<3;i++){
	  crv->poles[firstPolInd+i]   = crv->poles[firstPolInd+3+i] + d1*u1[i];
	  crv->poles[firstPolInd+6+i] = crv->poles[firstPolInd+3+i] + d2*u2[i];
	}

 }

 *msg = MSSUCC;
 return;

}
/*===========================================================================*/

void VDSmvFourPolesOnCv( crv, begPol, endPol, firstPolInd, polTol, msg )

/*h this function moves four coincident poles. The caller should notice that
    if the curve is rational this function is expecting that the poles have been
    already unweighted.
*/

struct	IGRbsp_curve	*crv;		/*IO the input curve with the modifyed
				             after execution 		      */
IGRint			begPol;		/*I  the first pole evaluated with
					     a knot multiplicity equal to
					     order - 1                        */
IGRint			endPol;		/*I  the last pole evaluated with
					     a knot multiplicity equal to
					     order - 1                        */
IGRint			firstPolInd;    /*I  index of the first pole to 
					     modify			      */
IGRdouble		polTol;		/*I  the displacement length          */
IGRlong			*msg;		/*O  MSSUCC or MSFAIL	              */

{
 

 IGRint		i;
 IGRdouble	u1[3],u2[3], d1, d2;
 


 if( firstPolInd ==  begPol ){

	__DBGpr_com(" mul=4 begPol\n");
	d1 = 0.0;
 
  	for(i=0;i<3;i++){
	   u1[i] = crv->poles[firstPolInd+12+i] - crv->poles[firstPolInd+i];
	   d1 += u1[i] * u1[i]; 
	}

	d1 = polTol / (sqrt(d1));

	for(i=0;i<3;i++){
	  crv->poles[firstPolInd+3+i] = crv->poles[firstPolInd+i] + d1*u1[i];
	  crv->poles[firstPolInd+6+i] = crv->poles[firstPolInd+3+i] + d1*u1[i];
	  crv->poles[firstPolInd+9+i] = crv->poles[firstPolInd+6+i] + d1*u1[i];
	}
 }
 else if ( firstPolInd ==  (endPol-9) ){
	__DBGpr_com("mul=4 endPol\n");

	d1 = 0.0;
 
  	for(i=0;i<3;i++){
	   u1[i] = crv->poles[firstPolInd-3+i] - crv->poles[firstPolInd+6+i];
	   d1 += u1[i] * u1[i]; 
	}

	d1 = polTol / (sqrt(d1));

	for(i=0;i<3;i++){
	  crv->poles[firstPolInd+6+i] = crv->poles[firstPolInd+i+9] + d1*u1[i];
	  crv->poles[firstPolInd+3+i] = crv->poles[firstPolInd+i+6] + d1*u1[i];
	  crv->poles[firstPolInd+i] = crv->poles[firstPolInd+i+3] + d1*u1[i];
	}

 }
 else{

	__DBGpr_com("mul=4 midle\n");
	d1 = 0.0;
	d2 = 0.0;
 
  	for(i=0;i<3;i++){
	   u1[i] = crv->poles[firstPolInd-3+i] - crv->poles[firstPolInd+3+i];
	   d1 += u1[i] * u1[i]; 
	   u2[i] = crv->poles[firstPolInd+12+i] - crv->poles[firstPolInd+3+i];
	   d2 += u2[i] * u2[i]; 
	}

	d1 = polTol / (sqrt(d1));
	d2 = polTol / (sqrt(d2));

	for(i=0;i<3;i++){
	  crv->poles[firstPolInd+3+i] = crv->poles[firstPolInd+i] + d1*u1[i];
	  crv->poles[firstPolInd+i]   = crv->poles[firstPolInd+3+i] + d1*u1[i];
	  crv->poles[firstPolInd+6+i] = crv->poles[firstPolInd+6+i] + d2*u2[i];
	  crv->poles[firstPolInd+9+i] = crv->poles[firstPolInd+6+i] + d2*u2[i];
	}

 }

 *msg = MSSUCC;
 return;

}

/*===========================================================================*/

void VDSmvPolesOnCv( crv, begPol, endPol, firstPolInd, numCoincident, 
		    polTol, msg )

/*h this function is a driver to three functions. The caller should notice that
    if the curve is rational this function is expecting that the poles have been
    already unweighted. */

struct	IGRbsp_curve	*crv;
IGRint			begPol;
IGRint			endPol;
IGRint			firstPolInd;
IGRint			numCoincident;
IGRdouble		polTol;
IGRlong			*msg;

{

 switch( numCoincident ){ 

 case 2:
	VDSmvTwoPolesOnCv( crv, begPol, endPol, firstPolInd, polTol, msg );
	break;

 case 3:
	VDSmvThreePolesOnCv( crv, begPol, endPol, firstPolInd, polTol, msg );
	break;

 case 4:
	VDSmvFourPolesOnCv( crv, begPol, endPol, firstPolInd, polTol, msg );
	break;
	
 default: goto wrapup;

 }

 return;

wrapup:
	*msg = MSFAIL;
	return;
}

/*===========================================================================*/

void VDSmvCoincidentPolesOnCv( crv, knotTol, polTol, curveIsModifyed, msg )

/* this function find all the poles that are coincident with in polTol.
   The caller should notice that if the curve is rational 
   this function is expecting that the poles have been already unweighted. */

struct	IGRbsp_curve	*crv;
IGRdouble		knotTol;
IGRdouble		polTol;
IGRboolean		*curveIsModifyed;
IGRlong			*msg;

{




IGRint		deg;
IGRint		i, j, k, begPol, max, j1, j2;
IGRdouble	d, d1;
IGRint		numCoincident;
IGRint		numMkts;

IGRdouble	*pars;
IGRint   	*poleIndex;
IGRlong		rcLoc;
IGRdouble	polTol2;



	polTol2          = polTol * polTol;
  	pars             = NULL;
	poleIndex        = NULL;
	deg              = crv->order - 1;
	max              = crv->num_knots - crv->order-1;
	*curveIsModifyed = FALSE;
	*msg             = MSFAIL;


/*
 * 	evaluate the number of knots with multiplicity order -1  
 */


	pars = (IGRdouble *) 
	om$malloc( size = crv->num_knots * sizeof(IGRdouble) );
	if( pars == NULL ){
    		printf("Error in VDSmvCoincidentPolesOnCv \n");
    		printf("Not enought memory for pars \n");
    		goto wrapup;
	}

	poleIndex = (IGRint *) 
	om$malloc( size = crv->num_knots * sizeof(IGRint) );
	if( poleIndex == NULL ){
    		printf("Error in VDSmvCoincidentPolesOnCv \n");
    		printf("Not enought memory for index\n");
    		goto wrapup;
	}

	poleIndex[0] = 0;   
	numMkts = 0;


	BSfindmkts( &rcLoc, &(crv->order), &(crv->num_poles), &(crv->knots[0]),
            	    &knotTol, &numMkts, pars, poleIndex );
	if( rcLoc != BSSUCC ){
    		printf("Error in VDSmvCoincidentPolesOnCv \n");
		printf(" BSfindmkts Failed in \n" );
		goto wrapup;
	}

	__DBGpr_int("exit BSfindmkts numMkts ",numMkts);

	pars[numMkts] = 1.0;
	poleIndex[numMkts] = crv->num_knots - crv->order;
	numMkts = numMkts+1;
	i = 0;

	/*
         * Loop between each poles with knots of multiplicity = order -1.
	 * Find the coincident poles with their multiplicity and move them .
	 */


	for(k=0;k<numMkts;k++){

   	    __DBGpr_int("k",k );
   	    __DBGpr_dbl("poleIndex[k]",poleIndex[k]);

   	    begPol = i;
  	    max = 3 * ( poleIndex[k]-1 );
      
  	    while(i<max)
	    {

  		d = BSdistptpts( msg, &(crv->poles[i]),&(crv->poles[i+3]) );

		__DBGpr_int("i ",i);
		__DBGpr_dbl("d ", d);

  		if( d > polTol2 ) i = i + 3;
  		else
		{
		    	j1 = i + 6;
			j2 = i + 12;
			numCoincident = 2;
			for( j=j1; k<j2;j+=3 ){
		     		d1 = BSdistptpts( msg, &(crv->poles[i]),
						  &(crv->poles[j]) );
				__DBGpr_dbl("d1 ",d1);
		
		     		if( d1 > polTol2 ) break;
		     		else numCoincident = numCoincident + 1;
	        	}

			VDSmvPolesOnCv( crv, begPol, max, i, 
				       numCoincident, polTol, msg );

			__DBGpr_int("i coinc",i);
			__DBGpr_dbl("numCoincident ",numCoincident);
				

			*curveIsModifyed = TRUE;
			i += 3 * numCoincident;
        	}

            }

   	    i = max;

	}

	*msg = MSSUCC;

wrapup:
        if( pars  != NULL ) { om$dealloc( ptr = pars); pars = NULL; }
	if( poleIndex != NULL ) { om$dealloc( ptr = poleIndex);
				  poleIndex = NULL; }
	return;

}


/*==========================================================================*/

void VDSremoveOverlaps( crv, firstPoleInd, numPolesToModify, poleIndexToModify, 
		       msg )

/*h this function remove overlap. The caller should notice that
    if the curve is rational this function expected that the poles have been
    already unweighted. */

struct	IGRbsp_curve	*crv;
IGRint			firstPoleInd;
IGRint			numPolesToModify;
IGRint			*poleIndexToModify;
IGRlong			*msg;

{

IGRint 		i, j, ind, ind1;


  __DBGpr_com("enter VDSremoveOverlaps\n");

  if( crv->order > 4 ) goto wrapup;



  if( crv->order == 3 ){
	ind = 3 * firstPoleInd;
	for(i=0;i<3;i++)
	crv->poles[ind+3+i] = (crv->poles[ind+i] + crv->poles[ind+i+6]) * 0.5;  
  }
  else{
	ind = 3 * firstPoleInd;

	for(j=0;j<numPolesToModify;j=j+1){

	   if( poleIndexToModify[j] == 3 ){
		ind1 = ind + 3;
		for(i=0;i<3;i++) crv->poles[ind1+i] = crv->poles[ind+i];
	   }
	   else if( poleIndexToModify[j] == 6 ){
		for(i=0;i<3;i++) crv->poles[ind+6+i] = crv->poles[ind+3+i];
           }
	   else{
		for(i=0;i<3;i++) crv->poles[ind+6+i] = crv->poles[ind+9+i];
	   }

	}

  }



*msg = MSSUCC;
return;

wrapup:
	
	*msg = MSFAIL;
	return;

}

/*============================================================================*/
IGRboolean VDSfindOverlapsOnSpan( poles, deg, tol, numPolesToModify, 
				 polesIndexToModify, msg)

/*h this function check if order poles overlap. The caller should notice that
    if the curve is rational this function expected that the poles have been
    already unweighted. */



IGRdouble	*poles;			/*I the array of poles to test    */
IGRshort	deg;			/*I the number of poles to test   */
IGRdouble	tol;			/*I tolerance 			  */
IGRint		*numPolesToModify;	/*O num of poles to modify        */
IGRint		*polesIndexToModify;	/*O index of the poles to modify 
					    if no poles to modify
					    poleIndexTomodify = -1;       */
IGRlong		*msg;			/*O return code MSSUCC or MSFAIL  */

{





IGRint		i, iM3;
IGRdouble	vec[3], v1[3];



	*numPolesToModify = 0;

	BSmkvec( msg, vec, poles, &(poles[3*deg]) );

	iM3 = 3 * deg;

	for(i=0;i<iM3;i+=3){

		BSmkvec( msg, v1, &(poles[i]), &(poles[i+3]) );
		if( BSdotp(msg,v1,v1) > tol ){
			if( BSdotp(msg,v1,vec) < tol ){
				polesIndexToModify[*numPolesToModify] = i+3;
				*numPolesToModify = *numPolesToModify + 1;

			}
		}
	}

	*msg = MSSUCC;

	if( (*numPolesToModify) > 0 ) return(TRUE);
	else			      return(FALSE);

}

/*===========================================================================*/
void VDSfindOverlapsOnCv( crv, modifNeeded, zeroTol, chtTol, 
			  curveHasOverlaps, msg )

struct	IGRbsp_curve	*crv;		   /*I curve to be analysed	     */
IGRboolean		modifNeeded;	   /*I modifNeeded==TRUE,then we will
					       modify the original curve to
					       remove the overlaps           */ 
IGRdouble		zeroTol;	   /*I zero tolerance                */
IGRdouble		chtTol;		   /*I chord height tolerance        */
IGRboolean		*curveHasOverlaps; /*O flag to tell the curve has or
					       not overlaps		     */
IGRlong			*msg;		   /*O return code msg = BSSUCC, or
					       BSFAIL			     */

{

  
IGRint		deg;
IGRint		i, max;
IGRint		poleIndexTomodify[15];
IGRint		numPolesToModify;
IGRboolean	tmpHasOverlaps, curveIsModifyed;



extern IGRboolean	VDSfindOverlapsOnSpan();
extern void		VDSremoveOverlaps();
extern void		VDSmvCoincidentPolesOnCv();




 deg = crv->order - 1;
 max = crv->num_knots - crv->order;
 *curveHasOverlaps = FALSE;


 for(i=deg;i<max;i++){
	
  	if( fabs( (crv->knots[i+1] - crv->knots[i]) ) > zeroTol ){

		tmpHasOverlaps = VDSfindOverlapsOnSpan(
			&(crv->poles[3*(i-deg)]), deg, zeroTol,
			&numPolesToModify, poleIndexTomodify, msg );

		if( *msg == MSFAIL ) goto wrapup;
		if( tmpHasOverlaps == TRUE ){
			__DBGpr_int("i-deg ",(i-deg));
			__DBGpr_int("numPolesToModify ", numPolesToModify);
			*curveHasOverlaps = tmpHasOverlaps;

			if( modifNeeded == TRUE ){

		   	VDSremoveOverlaps( crv, (i-deg), numPolesToModify,
				     	  poleIndexTomodify, msg );
			}
			else break;

		}
	}
 }

 VDSmvCoincidentPolesOnCv( crv, zeroTol, chtTol, &curveIsModifyed, msg );
 if( curveIsModifyed == TRUE ) *curveHasOverlaps = TRUE;


return;

wrapup:
	*msg = MSFAIL;
	return;

}

/*============================================================================*/

void VDScleanupCv( crv, modifNeeded, curveHasOverlaps, msg )


struct	IGRbsp_curve	*crv;		   /*I curve to be analysed	     */
IGRboolean		modifNeeded;	   /*I modifNeeded==TRUE,then we will
					       modify the original curve to
					       remove the overlaps           */ 
IGRboolean		*curveHasOverlaps; /*O flag to tell the curve has or
					       not overlaps		     */
IGRlong			*msg;		   /*O return code msg = MSSUCC, or
					       MSFAIL			     */

{

extern void		VDSfindOverlapsOnCv();


IGRboolean 	status;
IGRdouble	zeroTol, chtTol;
IGRlong		locRc;


  	if( crv->order > 4 ) goto wrapup;

 	status = BSxtractpar(msg,BSTOLCLOSETOZERO, &zeroTol );
 	if( !status )  goto wrapup;

 	status = BSxtractpar(msg,BSTOLCHRDHT, &chtTol );
 	if( !status )  goto wrapup;

	if( crv->rational ){
		BSunwght_p( &locRc, crv->poles, crv->weights, 
			   (IGRint)&crv->num_poles, crv->poles );
		VDSfindOverlapsOnCv( crv, modifNeeded, zeroTol, chtTol,
				    curveHasOverlaps, msg );
		BSwght_p( &locRc, crv->poles, crv->weights, 
			 (IGRint)&crv->num_poles, crv->poles );
		if( !(*msg&1) ) goto wrapup;
	}
	else {
		VDSfindOverlapsOnCv( crv, modifNeeded, zeroTol, chtTol,
				    curveHasOverlaps, msg );
		if( !(*msg&1) ) goto wrapup;
	}

	*msg = MSSUCC;
	return;

wrapup:
	*msg = MSFAIL;
	return;
}


end implementation Root;
