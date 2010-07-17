/* $Id: VRCorrCommon.C,v 1.1.1.1 2001/01/04 21:12:48 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcorrection / VRCorrGlob.I
 *
 * Description:	Functions to Store/Set/Get global Parameters of
 *		VRCorrection objects. Could be called from PPL commands. 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCorrCommon.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:48  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.2  1997/06/24  22:37:02  pinnacle
 * Replaced: vrcorrection/VRCorrCommon.C for:  by kddinov for route
 *
 * Revision 1.1  1997/02/24  00:11:48  pinnacle
 * Created: vrcorrection/VRCorrCommon.C by kddinov for route
 *
 *
 * History:
 *	Feb/03/97	kdd	VRCorrection_VRFlArSc
 *				VRCorrection_VRFlArSym
 *
 *************************************************************************/
#include <stdlib.h>
#include "VRcompdef.h"

extern     char    toupper( char);

/*
#define vdsDEBUG 1
#define vdserrDEBUG 1
*/

/******************************************************************************
*
*  This function stores/sets/gets the 3D flow arrow scale vector 
*	for all objects of class VRCorrection.
*
*-------------------------------------------------------------------------------
*  PARAMETERS 
*
*  setflag	= 1 set the scale array. 3 different X, Y & Z scales.
*		 -1 set the scale array. Single scale factor for all axis.
*		  0 get the scale array
*
*  XYZscale	= 3D scale array
*
*-------------------------------------------------------------------------------
*  ALGORITHM:
*  All negative or zero values are filtered out, and old values remain. 
*  For XYZscale={2.0, 0.0, 3.0}, scaling is: X = 2, Y unchanged, Z = 3
*
*-------------------------------------------------------------------------------
*  RETURN STATUS
*	1 = OK
*	0 = Unknown setflag.
*
*-------------------------------------------------------------------------------
*  Sample call:
*
*  	int           rc,setflag;
*  	double        XYZscale[3];
*
*  	rc = VRCorrection_VRFlArSc ( setflag, XYZscale);
*-------------------------------------------------------------------------------
*
*  HISTORY
*  Feb 97	kdd	creation 
*
*******************************************************************************/
int VRCorrection_VRFlArSc( int		setflag,
			   double	*XYZscale)
{
static	double		VRArrowScale[3]={1.0, 1.0, 1.0};
  	int		status= 1;

  switch ( setflag ) {

  case -1:					/* Set uniform scale */
  	if ( *XYZscale <= 0.0 ) { break; }

        VRArrowScale[0] = *XYZscale;
        VRArrowScale[1] = *XYZscale;
        VRArrowScale[2] = *XYZscale;
        break;

  case 1:					/* Set non uniform scale */
	if (XYZscale[0] > 0.0) VRArrowScale[0] = XYZscale[0];
	if (XYZscale[1] > 0.0) VRArrowScale[1] = XYZscale[1];
	if (XYZscale[2] > 0.0) VRArrowScale[2] = XYZscale[2];
        break;

  case 0:					/* Get scale */	
	XYZscale[0] = VRArrowScale[0];
	XYZscale[1] = VRArrowScale[1];
	XYZscale[2] = VRArrowScale[2];
	break;

  default: 
	status = 0;
	goto wrapup;
  }

wrapup:

return (status) ;
}


/******************************************************************************
*  This function stores/sets/gets the Flow Arrow Symbol for VRUpdateFlowArrow
*
* 	This function is needed in vrflowco/VRflowdir.sl to determine the 
*	next symbol. The direction will be inherited from the current symbol. 
*-------------------------------------------------------------------------------
*  PARAMETERS
*
*  setflag      = 1 set current Flow Arrow Symbol
*                 0 get current Flow Arrow Symbol
*                 2 set Update flag
*                -2 get Update flag
*
*  code         = Flow Arrow Symbol code 
*		  single arrow (VR_FLOW_IN or VR_FLOW_OUT)
*		  double arrow (VR_FLOW_BIDIRECTION)
*-------------------------------------------------------------------------------
*  RETURN STATUS
*       1 = OK
*       0 = Unknown code .
*******************************************************************************/
int VRCorrection_VRFlArSym( int  setflag,
                            int	 *code)
{
static	int 	flow_symbol={0};
static  int	UpdateFlag={0}; 

	int	status = 1;

   switch ( setflag) { 

   case 1:
	flow_symbol = *code;
	break;

   case 0:
	*code = flow_symbol;
	break;

   case 2:
	UpdateFlag = *code;
	break;

   case -2:
	*code = UpdateFlag;
	break;

   default:
	status = 0; 
	goto wrapup; 
   }

wrapup:

return (status);
}

