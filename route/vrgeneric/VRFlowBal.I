/* $Id: VRFlowBal.I,v 1.4 2002/04/10 19:41:02 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrgeneric / VRFlowBal.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRFlowBal.I,v $
 *	Revision 1.4  2002/04/10 19:41:02  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.3  2001/02/20 01:14:02  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 20:44:13  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/23  23:17:16  pinnacle
# Created: route/vrgeneric/VRFlowBal.I by lawaddel for Service Pack
#
# Revision 1.3  1999/05/05  13:04:22  pinnacle
# Replaced: vrgeneric/VRFlowBal.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1998/03/08  23:06:38  pinnacle
# Created: vrgeneric/VRFlowBal.I by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	3-98	KDD		creation 
 *
 *      05/04/99    Reddy       Doble value comparision corrected
 *      04/05/02    law         TR5649-standardize tolerance with VRGetTol
 *************************************************************************/
class implementation VRGeneric;

/*
#define vdsDEBUG	1
*/

#include <math.h>
#include "VDmem.h"
#include "VRMath.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "AS_status.h"
#include "vrdbgmacros.h"
#include "vdreporterr.h"
#include "VRcompdef.h"


/*------------------------------------------------------------------------------
* 1-98 KDD
*
* This method solves the ballance equation for the current component.
*
* propagates the updated flow values along the neighbours. 
* All neighbours need to be 2 cpt components to avoid infinite loops. 
*
* The default propagation formula is:
*	- the unique connect point gets its value updated. 
*	- there are 2 possible values. Flow going IN and flow going OUT. 
*	- Bidirectional flow is considered equal to 0, because otherwise there 
*	  could be no unique solution.
*-------------------------------------------------
*
* PARAMETERS
*
* O: IGRlong	*msg		- output status flag.
*
* I: IGRshort	CptNum		- incoming connect point (-1 if not needed).
*				  May be used to resolve propagation direction.
*
* I: IGRshort	*NoChangeList	- list of connect points not to change (if any).
*
* I: int	nNoChangeList	- number of points in NoChangeList
*
* I: int	MaxSize		- caller allocated size of PointToChange, 
*				  FlowRateToChange, FlowDirToChange arrays.
*
* O: IGRshort	*PointToChange	- list of points that need flow change.
*
* O: IGRdouble	*FlowRateToChange-  has the new flow rate at each changed point.
*
* O: IGRshort	*FlowDirToChange- has the new direction at each changed point
*
* O: int	*nPointToChange	- Number of points to change, i.e.
*				  size of arrays PointToChange, FlowRateToChange
*				  and FlowDirToChange.
*
* I: struct GRmd_env	*md_env	- matrix transformation info. 
*------------------------------------------
*
* NOTE: The caller MUST provide the memory needed (call twice if not sure). 
*	Except nPointToChange all other pointers may be null. 
*
------------------------------------------------------------------------------*/
method VRFlowBallance (      IGRlong   		*msg;
			     IGRshort		CptNum;
			     IGRshort		*NoChangeList;
			     int		nNoChangeList;
			     int		MaxSize;
			     IGRshort  		*PointToChange ;
                             IGRdouble 		*FlowRateToChange;
			     IGRshort           *FlowDirToChange;
                             int                *nPointToChange;
                             struct   GRmd_env  *md_env )
{
  int			i, j, NoChange_flag,
			status = OM_S_SUCCESS; 

  IGRshort		*FlowIn = NULL, 
			*FlowOut= NULL,
			PropPoint,
			FlowDir,
			nFlowIn, nFlowOut, nFlowBi;

  IGRdouble		*Flow = NULL,
			PropFlowRate,
			FlowRate,
			FlowRateIn,
			FlowRateOut,
			NoChangeFlowIn, NoChangeFlowOut;


SetProc (VRGeneric_VRFlowBallance); Begin

  *msg = MSSUCC;
  status = OM_S_SUCCESS;

  if ( !nPointToChange)  { *msg = status = 0; goto wrapup; }

  *nPointToChange = 0; 

  if ( !NoChangeList ) nNoChangeList = 0; 


/*------------------------------------------------------------------------------
#  KDD 2-98
*  Ballance flow in a 3+ connect point component.
*-----------------------------------------------------------------------------*/
  FlowIn   = _MALLOC( me->nNbCpts, IGRshort);
  FlowOut  = _MALLOC( me->nNbCpts, IGRshort);
  Flow     = _MALLOC( me->nNbCpts, IGRdouble);
 
  nFlowIn        = nFlowOut        = nFlowBi = 0;
  FlowRateIn     = FlowRateOut     = 0.0;
  NoChangeFlowIn = NoChangeFlowOut = 0.0;
 
/*----------------------
#1. Get the flow at each connect point.
*
* Check with VRGeneric.VRGetFlow to see that we get the flow relative to
* the connect point, so that FlowDir (+) means VR_FLOW_OUT, and
* FlowDir (-) means VR_FLOW_IN.
* 
* That is all corrections are connected with 0-th cpt to this branch.
----------------------*/
__DBGpr_int("target object      ", my_id);

  for ( i = 0; i < me->nNbCpts ; i++ ) {
      NoChange_flag = 0;

      status = om$send( msg      = message VRGeneric.VRGetFlow( msg,
                                      i, &FlowDir, &FlowRate, md_env),
                        targetid = my_id);
 
#ifdef vdsDEBUG
printf("\tConnect point =%d, flow direction = %d, flow rate = %f\n", 
			i, FlowDir, FlowRate); 
#endif

      Flow[ i ] = FlowRate;


      /* remove from the IN, OUT lists all non changable points */

      for ( j = 0; j < nNoChangeList; j++ ) {
	     if ( NoChangeList[ j ] == i )  { NoChange_flag = 1; break; }
      }

      if ( FlowDir == VR_FLOW_IN ) {
         FlowRateIn += FlowRate;

	 if ( NoChange_flag ) NoChangeFlowIn += FlowRate;
         else                 FlowIn  [ nFlowIn++  ] = i;

      }
      else if (FlowDir == VR_FLOW_OUT ) {
         FlowRateOut += FlowRate;

	 if ( NoChange_flag ) NoChangeFlowOut += FlowRate;
         else                 FlowOut [ nFlowOut++ ] = i;

      }
      else if (FlowDir == VR_FLOW_BIDIRECTION ) { nFlowBi++ ; }
  }


/*----------------------------
# Check.
*---------------------------*/
  if ( nFlowBi > 0 ) { 
        char    text[256];
 
        strcpy(text, "WARNING: Component %d. Bidirectional flow not included",
                     " in the flow ballance equation.", my_id );
 
        vd$report_error( mode = 1, error = text);
  }

#ifdef vdsDEBUG
printf("\tnFlowBi =%d, nFlowIn = %d, nFlowOut = %d\n", 
				nFlowBi, nFlowIn, nFlowOut); 
#endif

/*----------------------------
#2. Non unique propagation.
* Here is the place to implement your fancy formulae.
*---------------------------*/
  if (((nFlowIn != 1) && (nFlowOut != 1)) || (nFlowIn == 0) || (nFlowOut == 0)){
     if ( (CptNum < 0) || (CptNum > me->nNbCpts) ) {
	char 	text[256];

	sprintf(text, "Don't know how to propagate flow for component %d"
		     " prop point %d, flowIN = %d, flowOUT = %d",
		     my_id, CptNum, nFlowIn, nFlowOut);

	vd$report_error( mode = 1, error = text);

	*msg = status = 0; 
	goto wrapup;
     }

     /* Use CptNum as priority point to determine what to change IN or OUT*/

     for ( i = 0; i < nFlowIn; i++ ) { 
	 if ( FlowIn [ i ] == CptNum ) {

	    PropFlowRate = (FlowRateIn - NoChangeFlowOut) / nFlowOut; 

	    for ( j = 0 ; j < nFlowOut; j++ ) {

	       if ((Flow[ FlowOut [j] ] - PropFlowRate) < VRGetTol(VR_DEFAULT_TOL) ) continue; 
	       if ( *nPointToChange > MaxSize )          continue;

	       if (PointToChange) PointToChange [*nPointToChange] = FlowOut [j];

	       if (FlowRateToChange)
	               FlowRateToChange [ *nPointToChange ] = PropFlowRate ;

	       *nPointToChange += 1;
	    }
	    break;
	 }
     }
     if ( i == nFlowIn ) {
         for (i = 0; i < nFlowOut; i++) { 
	    if (FlowOut [ i ] != CptNum) continue;

            PropFlowRate = (FlowRateOut - NoChangeFlowIn) / nFlowIn;

            for ( j = 0 ; j < nFlowIn; j++ ) {

	       /*BILLA  Double value comparison problem */
               if (fabs(Flow[ FlowIn [j] ] - PropFlowRate) < VRGetTol(VR_DEFAULT_TOL) ) continue; 
	       if ( *nPointToChange > MaxSize )         continue;

               if (PointToChange) PointToChange [*nPointToChange] = FlowIn [j];

               if (FlowRateToChange) 
			FlowRateToChange [ *nPointToChange ] = PropFlowRate ;

               *nPointToChange += 1;
            }
	    break;
      }
     }
 
     goto wrapup;
  }
 
/*----------------------
# 2. Ballance the flow according to Jeff's main rule (propagate from a single
* direction).
*---------------------*/
  if ( (nFlowIn == 1) && (nFlowOut == 1) ) {

     if ( FlowIn [ 0 ] == CptNum ) {

	PropFlowRate = FlowRateIn - NoChangeFlowOut;
	PropPoint = FlowOut[ 0 ];
     }
     else if ( FlowOut [ 0] == CptNum ) {

        PropFlowRate = FlowRateOut - NoChangeFlowIn;
        PropPoint = FlowIn[ 0 ]; 
     }
     else {
        char    text[256];
 
        sprintf(text,"Don't know how to propagate flow (2) component %d",my_id);
        vd$report_error( mode = 1, error = text);

        *msg = status = 0;
        goto wrapup;
     }
  }
  else if ( nFlowIn == 1) {

     PropFlowRate = FlowRateOut - NoChangeFlowIn;
     PropPoint = FlowIn [ 0 ];
  }
  else if ( nFlowOut == 1 ) {

     PropFlowRate = FlowRateIn - NoChangeFlowOut;
     PropPoint = FlowOut[ 0 ];
  }
 
        /* Propagate flow rate from the unique connect point */
 
  /*BILLA  Double value comparison problem */
  if (fabs(Flow[ PropPoint ] - PropFlowRate) < VRGetTol(VR_DEFAULT_TOL) ) goto wrapup;

  if (PointToChange) PointToChange [*nPointToChange] = PropPoint;
 
  if (FlowRateToChange) FlowRateToChange[ *nPointToChange ] = PropFlowRate;
 
  *nPointToChange += 1;


wrapup:
 
  if ( Flow    ) _FREE(Flow  );
  if ( FlowIn  ) _FREE(FlowIn);
  if ( FlowOut ) _FREE(FlowOut);
 
#ifdef vdsDEBUG
if ( nPointToChange) {
__DBGpr_int("Number of points to change", *nPointToChange);
 if ( FlowRateToChange ) {
  for (i = 0; i < *nPointToChange; i++ ) { 
   printf("\tpoint %d, flow rate %f\n", i, FlowRateToChange[*nPointToChange]);
  } 
 }
}
#endif

End
  return (status);
}


end implementation VRGeneric;


