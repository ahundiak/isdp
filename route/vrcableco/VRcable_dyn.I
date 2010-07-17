/* $Id: VRcable_dyn.I,v 1.1.1.1 2001/01/04 21:12:41 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcableco / VRcable_dyn.I 
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcable_dyn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/01/16  20:32:30  pinnacle
# Replaced: vrcableco/VRcable_dyn.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	04/23/91	AdZ	created
 *	01/15/96	tlb	Add protoype file
 *				Change VRCableDyn, struct VRcable to static
 *	01/16/96	tlb	Change VRCbDynamics to ANSI style declaration
 *
 *************************************************************************/

class implementation Root;

/* 
 * include files
 */
#include "math.h"

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrdef.h"

#include "vrcablec_pto.h"
#include "vrtools_pto.h"

#include "msdef.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "AS_status.h"

#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "bsdistptpt.h"
#include "bslenvec.h"
#include "bspt_on_lne.h"
#include "bscrossp.h"
#include "bsmkvec.h"
#include "bsroto.h"

#define	AS_DEBUG	1
/*
 * extrernal macro calls
 */

static struct	VRcable{
	GRobjid			ObjId;
	IGRdouble		*start_pnt;
	IGRdouble		*end_pnt;
	IGRdouble		*start_vec;
	IGRboolean		Dynamic_Point;
	IGRdouble		*Z_Window;
	
	struct VRcable_data	*Cable_Data;
	IGRdouble		*Pnts;
	IGRint			num_pnts;
	struct	DPele_header	*header_line;
};


/* ---------------------------------------------------------------------- */
/* VRCableDyn 								- */
/* ---------------------------------------------------------------------- */

static
IGRint VRCableDyn( VRinfo, point, matrix, objects, num_objects,
		   buffers, num_buffers, dummy_in1, dummy_in2, 
		   dummy_in3, dummy_out1, dummy_out2, dummy_out3 )

struct 		VRcable		*VRinfo;
struct 		EX_button      	*point;
IGRdouble                   	*matrix;
struct 		GRid           	**objects;
IGRint                     	*num_objects;
struct 		DPele_header  	**buffers;
IGRint                       	*num_buffers;
IGRchar                      	*dummy_in1;
IGRchar                      	*dummy_in2;
IGRchar                      	*dummy_in3;
IGRchar                      	**dummy_out1;
IGRchar                      	**dummy_out2;
IGRchar                      	**dummy_out3;
/*.VRCableDyn*/
{
IGRint		i, cond;    
IGRdouble	u_val, cur_pt[6];
IGRint		status;
IGRlong		retmsg;
BSrc		rc;
IGRboolean	online, VRVerifyBendRad();

	/*" point(x,y,z) %f %f %f\n", point->x, point->y, point->z */

	if( VRinfo->Dynamic_Point )
	{
	  /* | find the X-vector point */

	  for(i=0;i<3;i++) VRinfo->Z_Window[i] = matrix[8+i];

	  status = VRCbGetProjectPnt(	VRinfo->start_pnt, 
					VRinfo->start_vec,
					&point->x,
					&matrix[8],
					cur_pt );
	  if( ! status ){
	    /* | function VRCbGetProjectPnt failed */
	    return FALSE;
	  }


	  /* In case the end point is defined, the next point is	*/
	  /*    projected on the rway element. The rway element is 	*/
	  /*    limited between the start_pnt an end_pnt		*/
	  /* else find the projection point on the x-axis of connection	*/
	  /*    point.							*/

	  if( VRinfo->end_pnt != NULL ){

	    BSpt_on_lne( &rc, VRinfo->start_pnt, VRinfo->end_pnt,
			 cur_pt, &u_val, &online );
	    if( rc != BSSUCC ){
	      /*| error in BSpt_on_line */
	    }
	    else{

	      /*| test if on line */
	      if( online == FALSE ){
		/*| find the external values */
		if( BSdistptpt( &rc, VRinfo->start_pnt, cur_pt ) <
		    BSdistptpt( &rc, VRinfo->end_pnt,   cur_pt ) ){
		  /*| cur_pt equal to start_pnt */
		  for(i=0;i<3;i++) cur_pt[i] = VRinfo->start_pnt[i];
		}
		else{
		  /*| cur_pt equal to end_pnt */
		  for(i=0;i<3;i++) cur_pt[i] = VRinfo->end_pnt[i];
	    	}
	      } /* if online */
	    } /* if rc != BSSUCC */
	  } /* end_pnt != NULL */
	}
	else{
	  /* | next point */
	  cur_pt[0] = point->x;
	  cur_pt[1] = point->y;
	  cur_pt[2] = point->z;
	}

	cond = VRinfo->num_pnts * 3;
	/*" cond : %d \n", cond */

	/* Add bruno 08/05/92 */
	if ( !VRVerifyBendRad ( &retmsg, VRinfo->num_pnts, VRinfo->Pnts, cur_pt,
				VRinfo->Cable_Data->BendRadius) ) return FALSE;

	for(i=0; i<cond; i++ ){
    	  VRinfo->header_line->geometry.polyline->points[i] = VRinfo->Pnts[i];
	  /*" pts[%d]:%f\n", i,VRinfo->header_line->geometry.polyline->points[i] */
	}
	for(i=0; i<3; i++ ){
	  VRinfo->header_line->geometry.polyline->points[i+cond] = cur_pt[i];
	  /*" ps[%d]:%f\n",i+cond,VRinfo->header_line->geometry.polyline->points[i+cond] */
	}

	/*" num_pts : %d\n", VRinfo->header_line->geometry.polyline->num_points */

	*buffers     = VRinfo->header_line;
	*num_buffers = 1;


return TRUE;

}

/* ---------------------------------------------------------------------- */
/* VRCbDynamics		 						- */
/* ---------------------------------------------------------------------- */

IGRint VRCbDynamics( 	struct VRcable_data	*CabData,
			IGRdouble		*Pnts,
			IGRint			Num_Pnts,
			struct	IGRdisplay	*Display,
			IGRdouble		*Z_Window,
			GRobjid			Obj_Id,
			IGRboolean		Dynamic_Type,
			IGRdouble		*St_Pnt,
			IGRdouble		*St_Vec,
			IGRdouble		*End_Pnt)
{
struct	IGRpolyline	polyline;
struct 	DPele_header	element;     
struct 	VRcable		VRinfo;       

	polyline.num_points = Num_Pnts + 1;
	polyline.points     = Pnts;

	/*" poly num_pnts : %d \n", polyline.num_points */

	dp$build_dis_buffer(	buffer      = &element,
		  		type        = IGRPY,
		  		display_att = Display,
		  		geometry    = &polyline );

	VRinfo.header_line	= &element;
	VRinfo.Pnts		= Pnts;
	VRinfo.num_pnts		= Num_Pnts;
	VRinfo.ObjId		= Obj_Id;
	VRinfo.Dynamic_Point	= Dynamic_Type;
	VRinfo.Z_Window		= Z_Window;
	VRinfo.start_pnt	= St_Pnt;
	VRinfo.end_pnt		= End_Pnt;
	VRinfo.start_vec	= St_Vec;
	VRinfo.Cable_Data	= CabData;

	dp$dynamics(	dyn_fun     = VRCableDyn,
		   	information = &VRinfo );

return OM_S_SUCCESS;

} /* end function VRCbDynamics */

/*-----------------------------------------------------------------
/*	VRVerifyBendRad 
/*
/*	Abstract : 
/*
/*	This function verifies that the triangle defined by the 3
/*	vertices ( segments' length and angle ) matches the
/* 	specified bend radius.
/*-----------------------------------------------------------------
*/
IGRboolean	VRVerifyBendRad ( msg, NbAdjPts, dAdjPts, dModPt, dBendRadius)

IGRlong		*msg;		/* O  : Completion message returns 0 if
					everthing went allright, error message key
					if returned status = FALSE , warning
					message key if returned status = TRUE ) */
IGRint		NbAdjPts;	/* I  : Number of adjacent points */
IGRdouble	dAdjPts[]; 	/* I  : Array of adjacent points */
IGRdouble	dModPt[]; 	/* I/O: Modified point */
IGRdouble	dBendRadius; 	/* I  : bend radius value */
{

	IGRdouble	atan(),tan(), fabs();
	IGRdouble	dAngle, dDeltaAng, dDeltaLen;
	IGRdouble	dSeg1[3], dSeg1Len, dSeg2[3], dSeg2Len;
	BSrc		rc;

	*msg = 0;

	/*"nb adj points = %d\n", NbAdjPts */

/* EXIT : nothing to verify */
	if (NbAdjPts<2) return TRUE;

	/* -- Compute current and previous segment -- */

	BSmkvec (&rc, dSeg1, &dAdjPts[NbAdjPts*3-3], &dAdjPts[NbAdjPts*3-6]);
	BSmkvec (&rc, dSeg2, &dAdjPts[NbAdjPts*3-3], dModPt);

	/* -- Compute length of previous segment -- */

	dSeg1Len = BSlenvec(&rc,dSeg1);
	dSeg2Len = BSlenvec(&rc,dSeg2);

	/* -- If there is a segment prior to seg1 => there is already a bend -- */
	/* -- overlapping it => compute free length left -- */
	if (NbAdjPts>2)
	{
		/* length of segment 1 is minored by another bend */
		IGRdouble dSeg0[3];
		BSmkvec (&rc, dSeg0, &dAdjPts[NbAdjPts*3-9], &dAdjPts[NbAdjPts*3-6]);
		dSeg1Len -= dBendRadius/tan( VRcompute_angle(dSeg0,dSeg1, NULL) /2.0);
	}

/* EXIT : ERROR :  Segment 1 or 2 too short */
	if ( dSeg1Len < BSVALLENVEC ) { *msg = 1; return FALSE;}
	if ( dSeg2Len < BSVALLENVEC ) { *msg = 2; return FALSE;}

	/* -- Compute angle between the segments -- */


	dAngle = VRcompute_angle ( dSeg1, dSeg2, (IGRdouble *)NULL );

		/* -------------------------- */
		/* -- 	Verify constraints -- */
		/* -------------------------- */

	/* -- Cons1: verify that 2*atan(BendRad/Seg1) <= angle -- */

	/*    compute delta between minimum angle and present angle */
	dDeltaAng = 2.0*(atan(dBendRadius/dSeg1Len)) - dAngle;

	if ( dDeltaAng >= 0.0 )
	{
		IGRdouble	dNormal[3];
		IGRboolean	bBool=TRUE;

		/* compute normal */

		BScrossp ( &rc , dSeg1, dSeg2, dNormal );
		dNormal[0] += dAdjPts[NbAdjPts*3-3];
		dNormal[1] += dAdjPts[NbAdjPts*3-2];
		dNormal[2] += dAdjPts[NbAdjPts*3-1];

		/*"Rotating point of %f rad\n", dDeltaAng */
		/* Force angle to be the minimum acceptable + tolerance (1 degre) */
		dDeltaAng += 0.01;
		BSroto ( &rc,&dAdjPts[NbAdjPts*3-3],dNormal,&bBool,&dDeltaAng,dModPt,dModPt );

		/* Update angle and Seg2 */
		dAngle += dDeltaAng;
		BSmkvec (&rc, dSeg2, &dAdjPts[NbAdjPts*3-3], dModPt);

	}

	/* -- Cons2: verify that Seg2  >= BendRad/ tg( angle/2) -- */
	/*    compute delta between minimum angle and present angle */
	dDeltaLen = dBendRadius/tan(dAngle/2.0) - dSeg2Len;


	if ( dDeltaLen > 0.0 )
	{
		/* Force length to be the minimum acceptable */
		/*" Extending Segment of %f inches \n" */
		*msg = 3;
		dModPt[0] += dSeg2[0]* dDeltaLen/dSeg2Len;
		dModPt[1] += dSeg2[1]* dDeltaLen/dSeg2Len;
		dModPt[2] += dSeg2[2]* dDeltaLen/dSeg2Len;
	}

	return TRUE;


}/* end VRVerifyBendRad */


end implementation Root;
