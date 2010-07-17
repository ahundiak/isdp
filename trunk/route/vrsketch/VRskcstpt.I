/* $Id: VRskcstpt.I,v 1.4 2002/04/10 20:33:30 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrsketch / VRskcstpt.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRskcstpt.I,v $
 *	Revision 1.4  2002/04/10 20:33:30  louis
 *	tr5649-standardize tolerance
 *	
 *	Revision 1.3  2001/02/20 01:17:22  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 19:54:25  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/24  01:08:46  pinnacle
# Created: route/vrsketch/VRskcstpt.I by lawaddel for Service Pack
#
# Revision 1.2  1999/05/04  13:50:14  pinnacle
# Replaced: vrsketch/VRskcstpt.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/07/31  15:22:58  pinnacle
# Replaced: vrsketch/VRskcstpt.I for:  by onayragu for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.5  1997/06/27  14:07:56  pinnacle
# Replaced: vrsketch/VRskcstpt.I for:  by apazhani for route
#
# Revision 1.4  1997/05/29  07:52:48  pinnacle
# Replaced: vrsketch/VRskcstpt.I for:  by apazhani for route
#
# Revision 1.3  1997/03/26  14:38:00  pinnacle
# Replaced: vrsketch/VRskcstpt.I for:  by hverstee for route
#
# Revision 1.2  1997/03/24  10:15:44  pinnacle
# Replaced: vrsketch/VRskcstpt.I for:  by ashankar for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/04/02  22:15:06  pinnacle
# Replaced: vrsketch/VRskcstpt.I for:  by hverstee for route240
#
# Revision 1.3  1996/02/12  12:51:44  pinnacle
# Replaced: vrsketch/VRskcstpt.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/19  15:10:22  pinnacle
# Replaced: vrsketch/VRskcstpt.I for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *
 *      05/04/99    Reddy       Double value comparision corrected
 *      04/08/02    law         TR5649-standardize tolerance with VRGetTol
 *************************************************************************/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 sketch state language file.

 CHANGE HISTORY:  momo 13-11-1989 : Design date
                 Alwin May-30-1997  Made some checks, to prevent the crash
                                    When using "dl" function while specifying 
                                    next point - for TR179700865
                  Alwin Jun-27-1997  Maintain Skewed Problem, provided
                                     3 segments solutions. CR179601979

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

class implementation VRsketch;

#include <stdio.h>
#include <math.h>

#include "dpdef.h"
#include "dpmacros.h"
#include "igrdef.h"
#include "igr.h"
#include "madef.h"
#include "nddef.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "AS_status.h"
#include "vrtools_pto.h"
#include "VRMath.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsnorvec.h"
#include "ma2lnise.h"
#include "maptlndis.h"
#include "bsint2lns.h"
#include "bsxlnpl.h"
#include "vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define AS_DEBUG	 	1
#define VR_RETURN		-1
#define VR_CONNECTABLE		-6
#define NO_MORE_SOLUTIONS      101 // added by alwin - for TR179700865

from	GRcoords	import	GRcvt_to_lcl_coords;
from	VRCnrlSeg	import	VRget_terminators;
from	VRGeneric	import	VRGetSupports,
				VRGetMatrix,
				VRGetSysType,
				VRGetCptGeom,
				VRGetIndex;
from	VRNozzle	import	VRGetRefId;

extern	GRclassid 	OPP_VRGeneric_class_id;

static	IGRshort	which_plane;       
static  IGRshort       	dimension;     
static  IGRshort       	TmpDimension;
static  IGRshort       	current_solution;     
static  IGRshort       	nb_sol;
static  IGRdouble	cst_pts[15];
static  IGRdouble       dIntSecPoint[3];

%safe
static  IGRboolean      bMaintainSkew=FALSE;
%endsafe

IGRlong VRis_an_extend( extend, prev_pt, first_pt, next_pt )

IGRlong	  	*extend;
IGRdouble 	*prev_pt;
IGRdouble 	*first_pt;
IGRdouble 	*next_pt;

/*.VRis_an_extend */
{
  BSrc		bsretcode;
  IGRdouble 	prev_direct[3]; /* previous direction vector                 */
  IGRdouble 	next_direct[3]; /* next direction vector                     */

  /* calculate normal previous direction vector */
  BSmkvec( &bsretcode, prev_direct, prev_pt, first_pt );

  BSnorvec( &bsretcode, prev_direct );
  /*"prev_dir = %f %f %f\n",prev_direct[0],prev_direct[1],prev_direct[2] */

  /* calculate normal next direction vector */
  BSmkvec( &bsretcode, next_direct, first_pt, next_pt );

  BSnorvec( &bsretcode, next_direct );
  /*"next_dir = %f %f %f\n",next_direct[0],next_direct[1],next_direct[2] */

  *extend = 0; /* init value */

  /* calculate the dot product between next and previous directions */

  if( 1 - fabs( BSdotp(&bsretcode,prev_direct,next_direct)) < VRGetTol(VR_DOTPROD_TOL) )
	*extend = IS_AN_EXTEND;

  /*"extend = %d\n", *extend */

  return OM_S_SUCCESS;
}

/*****************************************************************************
/* System called this method when the user locates a component to connect to
/* or gives a tentative point.
/**/

method VRskgetnxtpt( IGRlong *sts )
{
  IGRlong	ret_msg;
  IGRint	status;
  GRclassid	obj_class;

  *sts = MSSUCC;

  /* get located element class */
  status = om$get_classid( osnum     = me->event1.located_object[0].located_obj.osnum,
                           objid     = me->event1.located_object[0].located_obj.objid,
                           p_classid = &obj_class );

  if( om$is_ancestry_valid
      ( subclassid   = obj_class,
        superclassid = OPP_VRGeneric_class_id ) == OM_S_SUCCESS )
  {
    /* if it is a I/ROUTE component we update SecondLocatedElemId instance data */
    me->SecondLocatedElemId    = me->event1.located_object[0].located_obj;
    me->SecondLocatedElemMdEnv = me->event1.located_object[0].module_info;
  }

  /* update the next_pt instance data */
  me->next_pt[0] = me->event1.event.button.x;
  me->next_pt[1] = me->event1.event.button.y;
  me->next_pt[2] = me->event1.event.button.z;
  /*"next pt %f %f %f\n", me->next_pt[0], me->next_pt[1], me->next_pt[2] */

  /* get valid solution in me->cst_pts buffer */
  status = om$send( msg      = message VRsketch.VRskget_valid_sol( &ret_msg ),
                    targetid = my_id );
  as$status( action = RET_STATUS );

  if( ret_msg == VR_RETURN )  { *sts = MSSUCC; return OM_S_SUCCESS;  }
  else if( ret_msg != MSSUCC )
       { 
    	 ex$message( field   = ERROR_FIELD, in_buff = "No valid solution !" );
         *sts = MSFAIL;
         return OM_S_SUCCESS;
       }

  /* set display attributes buffer */ 
  me->cst_buffer.dis_att     = &me->cst_display;
  me->way_cst_buffer.dis_att = &me->way_cst_display;

  /* display the first solution */
  status = om$send( msg      = message VRsketch.VRskfstchoice( &ret_msg ),
                    targetid = my_id );
  as$status( action = RET_STATUS );
  as$status( sts = ret_msg, action = RET_STATUS );

  return( OM_S_SUCCESS );

}


/******************************************************************************
/* This methos is called to get all valid solution
/**/

method VRskget_valid_sol( IGRlong *sts )
{
  IGRint	i,j,k, StopLoop;     /* loop index                       	        */
  IGRint	status;		     /* return code                      	        */
  IGRint	action;		     /* action needed to call is_next_pt_valid function */
  IGRint	IsValidPoint;	     /* returned by is_next_pt_valid function           */
  IGRdouble	lcl_first_pt[3];
  IGRdouble	lcl_next_pt[3];

  SetProc( VRsketch_VRskget_valid_sol ); Begin
  *sts = MSSUCC;

  /* get first and next point in the active cs */
  VRskgetpt_in_active_cs( me->first_pt, lcl_first_pt, &me->ModuleInfo);
  VRskgetpt_in_active_cs( me->next_pt, lcl_next_pt, &me->ModuleInfo );

  me->cst_poly.num_points = 2;

  which_plane   = 0;

  /* get the construct way dimension : 1, 2 or 3 */
  if( fabs( lcl_first_pt[0] - lcl_next_pt[0] ) < VRGetTol(VR_DIST_TOL) && 
      fabs( lcl_first_pt[1] - lcl_next_pt[1] ) < VRGetTol(VR_DIST_TOL) &&
      fabs( lcl_first_pt[2] - lcl_next_pt[2] ) < VRGetTol(VR_DIST_TOL)     )
  {
    /* from and end points are coincident */
    if( me->SecondLocatedElemId.objid != NULL_OBJID  ) 
    {
      /* connect with zero distance two networks */
      dimension = 1;
    }
    else
    {
      ex$message( field   = ERROR_FIELD, 
                  in_buff = "Not able to create zero lenght segment !" );
      *sts = MSFAIL;
      End
      return OM_S_SUCCESS;
    }
  }
  else 
  if( 
      ( !me->orthogonal_sketch )
      ||
      (
        fabs( lcl_first_pt[0] - lcl_next_pt[0] ) < VRGetTol(VR_DIST_TOL) && 
        fabs( lcl_first_pt[1] - lcl_next_pt[1] ) < VRGetTol(VR_DIST_TOL)    
      ) 
      ||
      (
        fabs( lcl_first_pt[0] - lcl_next_pt[0] ) < VRGetTol(VR_DIST_TOL) && 
        fabs( lcl_first_pt[2] - lcl_next_pt[2] ) < VRGetTol(VR_DIST_TOL) 
      )
      ||
      ( fabs( lcl_first_pt[1] - lcl_next_pt[1] ) < VRGetTol(VR_DIST_TOL) && 
        fabs( lcl_first_pt[2] - lcl_next_pt[2] ) < VRGetTol(VR_DIST_TOL)   
      )
    )
  {
    /* from and end points are joigned maximum by one segment */
    dimension     = 1;
  }
  else if( fabs( lcl_first_pt[0] - lcl_next_pt[0] ) < VRGetTol(VR_DIST_TOL) )
  {
    /* from and end points are joigned maximum by two segments */
    dimension      = 2;
    which_plane    = 1;  /* YZ */ 
  }
  else if( fabs( lcl_first_pt[1] - lcl_next_pt[1] ) < VRGetTol(VR_DIST_TOL) )
  {
    /* from and end points are joigned maximum by two segments */
    dimension      = 2;
    which_plane    = 2;  /* XZ */ 
  }
  else if( fabs( lcl_first_pt[2] - lcl_next_pt[2] ) < VRGetTol(VR_DIST_TOL) )
  {
    /* from and end points are joigned maximum by two segments */
    dimension     = 2;
    which_plane   = 3;  /* XY */ 
  }
  else
  {
    /* from and end points are joigned maximum by three segments */
    dimension  = 3;
  }

  /* nb_sol is dimension plus the direct solution when from and end points
  /* are in an orthiginal plane
  /**/

  switch( dimension )
  {
	case 1: nb_sol = dimension;
		break;
	case 2: nb_sol = dimension+1;
		break;
	case 3: nb_sol = dimension+2;
		break;
	default:
          End
          return OM_E_ABORT;
  }

  /*"nb_sol = %d\n", nb_sol */

  /*BILLA  Double value comparison problem */
  if( me->AngleFlag && ( fabs(me->Angle) < VRGetTol(VR_ANGULAR_TOL) ) && me->SecondLocatedElemId.objid != NULL_OBJID )
  {
	IGRdouble t1[3], t2[3], tmp_pts[6], tol;
	IGRlong retcode;
        IGRint   nb_of_supports;
	IGRshort cmp_systype;
	struct MAline	line1, line2;
	struct GRid	PrevSegId;
	BSrc	bsretcode;

	line1.point1 = me->prev_pt;
	line1.point2 = me->first_pt;

        status = om$send( msg = message VRGeneric.VRGetSupports(
				&retcode, 1, &PrevSegId, &nb_of_supports ),
		targetid = me->SecondLocatedElemId.objid,
		targetos = me->SecondLocatedElemId.osnum );
	as$status();
       
        status = om$send( msg      = message VRGeneric.VRGetSysType( &retcode, &cmp_systype ),
                      targetid = me->SecondLocatedElemId.objid,
                      targetos = me->SecondLocatedElemId.osnum );
    	as$status( action = RET_STATUS );

	if( cmp_systype == VR_DANGLING )
	{
            status = om$send( msg      = message VRCnrlSeg.VRget_terminators (
				&retcode, NULL, &me->SecondLocatedElemMdEnv,
				 tmp_pts, NULL ),
		targetid = PrevSegId.objid,
		targetos = PrevSegId.osnum );
	    as$status();

	    line2.point1 = &tmp_pts[0];
	    line2.point2 = &tmp_pts[3];

	    tol = 0.001;
            MA2lnisect( &retcode, &line1, &line2, &tol, cst_pts, t1, t2 );

	    if( ( fabs(cst_pts[0] - me->next_pt[0]) < VRGetTol(VR_DIST_TOL) ) &&
		( fabs(cst_pts[1] - me->next_pt[1]) < VRGetTol(VR_DIST_TOL) ) &&
		( fabs(cst_pts[2] - me->next_pt[2]) < VRGetTol(VR_DIST_TOL) ))
	    {
                 /* In this case the Continued Skewed line, meets the dangle
                    itself */
                 //           O --> Dangle2
                 /*          /
                            /
                           /
                    line1 / is extended and fortunately it meets the dangle2
                         O --> Dangle1
                 */

		cst_pts[0] = me->next_pt[0];
		cst_pts[1] = me->next_pt[1];
		cst_pts[2] = me->next_pt[2];
		dimension = 1;
		nb_sol = 1;
	    }
	    else if ( retcode != MSSUCC )
	    {
 // added by Alwin
                 IGRdouble dIntersectPt[3], Normal[3];
                 IGRmatrix matrix;
                 IGRvector vector, NormalVec;
                 struct GRid WindowId;

                 bMaintainSkew = TRUE;

                 /* This window depends upon the view in which the user locates
                    the Second Object. In case if the user accepts in Top view
                    then this holds the Top window Id(107,2) */

                 WindowId.objid = me->event1.event.button.objid;
                 WindowId.osnum = me->event1.event.button.osnum;

                 /* All we need to get is the "Local to World Rotation Matrix"
                    Implementation of this is available in
                    "$GRNUC/src/go/supfungo/GRprismhelp.C" file. */

                 status = GRbuild_prism_helper( &retcode, &WindowId, NULL, NULL,
                          NULL, NULL, NULL, matrix, NULL, NULL );

                 /* From this Matrix obtained we obtain the Normal to the View
                    i.e. the view in which the user locates the object. With the
                    help of which we are going to find out the intersection pt*/

                 Normal[0] = matrix[8];
                 Normal[1] = matrix[9];
                 Normal[2] = matrix[10];

                 // This function produces the  vector from point1 to point2
                 BSmkvec( &bsretcode, vector, line2.point1, line2.point2 );

                 BSnorvec( &bsretcode, vector );

                 BScrossp(&bsretcode, vector, Normal, &NormalVec);

                 // This BS function gets the intersection point between a
                 // plane and a line
                 BSxlnpl( &bsretcode, NormalVec, me->next_pt,
                          line1.point1, line1.point2, dIntersectPt );

                 if( bsretcode == BSSUCC )
                 {
                   me->cst_pts[0] = me->first_pt[0];
                   me->cst_pts[1] = me->first_pt[1];
                   me->cst_pts[2] = me->first_pt[2];

                   me->cst_pts[3] = dIntersectPt[0];
                   me->cst_pts[4] = dIntersectPt[1];
                   me->cst_pts[5] = dIntersectPt[2];

                   dIntSecPoint[0] = dIntersectPt[0];
                   dIntSecPoint[1] = dIntersectPt[1];
                   dIntSecPoint[2] = dIntersectPt[2];

                   dimension = 3;
                   nb_sol = 3;

                   VRskgetpt_in_active_cs( dIntersectPt, lcl_first_pt,
                                             &me->ModuleInfo);
                   VRskgetpt_in_active_cs( me->next_pt, lcl_next_pt,
                                             &me->ModuleInfo );

                   if( fabs( lcl_first_pt[0] - lcl_next_pt[0] ) <
                                                      VRGetTol(VR_DIST_TOL) )
                   {    /* from and end points are joigned maximum by two segments */
                        which_plane    = 1;  /* YZ */
                   }
                   else if( fabs( lcl_first_pt[1] - lcl_next_pt[1] ) <
                                                      VRGetTol(VR_DIST_TOL) )
                   {
                      //from and end points are joined maximum by two segments
 
                       which_plane    = 2;  /* XZ */
                   }
                   else if( fabs( lcl_first_pt[2] - lcl_next_pt[2] ) <
                                                      VRGetTol(VR_DIST_TOL) )
                   {
                       //from and end points are joigned maximum by two segments
                       which_plane   = 3;  /* XY */
                   }

                   if( which_plane == 0 )
                   {
                       IGRint    i, nConstant=100;
                       IGRdouble X[3], Y[3], Z[3], distance=0.0;
                       IGRdouble Point1[3], Point2[3], Point3[3], Point4[3];
                       IGRvector dFirstVector, dSecondVector;
                       //IGRpoint  dPoints[2];
                       IGRdouble dPoints[6];
                       struct IGRline line0, line1;
                       struct IGRline *Line[2];

                       /* Trying to find out the remaining points of the
                          Sketch way. This is done by first finding out the
                          two vector which will be nothing but the direction
                          in which the second segment is going to run. From that
                          vectors we make two infinite lines. Intersection
                          points will give result in the other points 2 & 3
                  Intersection Pt(4)<------- o me->next_pt
                               ^             |
                               |             |
                               |             |
                               |             V
                  dIntersectPt o----------> Pt(4), Intersection Point

                       ***************/

                       for( i=0; i<3; i++ )
                       {
                          X[i] = 0.0;
                          Y[i] = 0.0;
                          Z[i] = 0.0;
                       }

                       X[0]=Y[1]=Z[2] = 1;

                       // Check for perpendicularity
                       if( BSdotp(&bsretcode, NormalVec, X) == 0 )
                       {
                           dFirstVector[0] = X[0];
                           dFirstVector[1] = X[1];
                           dFirstVector[2] = X[2];
                       }

                       if( BSdotp(&bsretcode, NormalVec, Y) == 0)
                       {
                           dFirstVector[0] = Y[0];
                           dFirstVector[1] = Y[1];
                           dFirstVector[2] = Y[2];
                       }

                       if( BSdotp(&bsretcode, NormalVec, Z) == 0 )
                       {
                           dFirstVector[0] = Z[0];
                           dFirstVector[1] = Z[1];
                           dFirstVector[2] = Z[2];
                       }

                       BScrossp(&bsretcode, dFirstVector, NormalVec, &dSecondVector);
                       line0.point1 = Point1;
                       line0.point2 = Point2;

                       line1.point1 = Point3;
                       line1.point2 = Point4;

                       for( i=0; i<3; i++ )
                       {
                         line0.point1[i] = dIntersectPt[i];
                         line0.point2[i] = dIntersectPt[i] + nConstant * dFirstVector[i];
                         line1.point1[i] = me->next_pt[i];
                         line1.point2[i] = me->next_pt[i] + nConstant * dSecondVector[i];
                       }

                       //Finds the intersection between two infinte lines
                       Line[0] = &line0;
                       Line[1] = &line1;

                       BSint2lns( Line, (IGRpoint *) dPoints, &distance, &bsretcode );

                       if ( bsretcode == BSSUCC )
                       {
                          cst_pts[0] = dPoints[0];
                          cst_pts[1] = dPoints[1];
                          cst_pts[2] = dPoints[2];

                      //For providing the skewed solution for the Second Network
                      //Find the intersection of the above line  with the
                      // extended line of the second network
 
                          Line[0] = &line0;
                          Line[1] = &line2;
                          BSint2lns( Line, (IGRpoint *) dPoints, &distance, &bsretcode );
                          if( bsretcode == BSSUCC )
                          {
                             cst_pts[6] = dPoints[0];
                             cst_pts[7] = dPoints[1];
                             cst_pts[8] = dPoints[2];
                          }
                          else {
                             Line[0] = &line1;
                             Line[1] = &line2;
 
                             BSint2lns( Line, (IGRpoint *) dPoints, &distance, &bsretcode );
                             if( bsretcode == BSSUCC )
                             {
                                cst_pts[6] = dPoints[0];
                                cst_pts[7] = dPoints[1];
                                cst_pts[8] = dPoints[2];
                             }
                          }
                       }

                       // Get the other diagonal point of the Rectangle
                       for( i=0; i<3; i++ )
                       {
                         line0.point1[i] = dIntersectPt[i];
                         line0.point2[i] = dIntersectPt[i] + nConstant * dSecondVector[i];
                         line1.point1[i] = me->next_pt[i];
                         line1.point2[i] = me->next_pt[i] + nConstant * dFirstVector[i];
                       }

                       Line[0] = &line0;
                       Line[1] = &line1;

                       BSint2lns( Line, (IGRpoint *) dPoints, &distance, &bsretcode );

                       if ( bsretcode == BSSUCC )
                       {
                          cst_pts[3] = dPoints[0];
                          cst_pts[4] = dPoints[1];
                          cst_pts[5] = dPoints[2];
                       }

                       cst_pts[9]  = me->next_pt[0];
                       cst_pts[10] = me->next_pt[1];
                       cst_pts[11] = me->next_pt[2];
                     }
                     else {
                        status = VRskget_all_sol( nb_sol, which_plane, cst_pts,
                               lcl_first_pt, me->next_pt, lcl_next_pt );
                        as$status( action = RET_STATUS );
                     }

                     /*************
                     for(i=0; i<12; i++ )
                       printf("\n cst_pts[%d] = %g \n", i, cst_pts[i] );

                     printf("\n CHECK THESE VALUES \n" );
                     *************/
                 }
                 else {
                       cst_pts[0] = me->next_pt[0];
                       cst_pts[1] = me->next_pt[1];
                       cst_pts[2] = me->next_pt[2];
                       dimension = 1;
                       nb_sol = 1;
                 }
	    }
	    else
	    {
                 /* It intersects the line somewhere outside the line */
               // So, it is connected by two segments

                 //    ------O-----------(line)
                 //   / \ this is the intersection point of these two lines
                 //  /
                 // O  \ this segment is extended skewed segment joins the othe

		cst_pts[3] = me->next_pt[0];
		cst_pts[4] = me->next_pt[1];
		cst_pts[5] = me->next_pt[2];
		dimension = 2;
	        nb_sol = 1;
	    }
	}
	else if ( cmp_systype == VR_PIPE )
	{
		IGRdouble dist;

		status = om$send( msg      = message VRGeneric.VRGetCptGeom
			( &retcode, 0, &tmp_pts[0], NULL, NULL, &me->SecondLocatedElemMdEnv ),
			targetid = me->SecondLocatedElemId.objid,
			targetos = me->SecondLocatedElemId.osnum );
		as$status();

		status = om$send( msg      = message VRGeneric.VRGetCptGeom
			( &retcode, 1, &tmp_pts[3], NULL, NULL, &me->SecondLocatedElemMdEnv ),
			targetid = me->SecondLocatedElemId.objid,
			targetos = me->SecondLocatedElemId.osnum );
		as$status();

	        line2.point1 = &tmp_pts[0];
	        line2.point2 = &tmp_pts[3];

	        tol = 0.001;
                MA2lnisect( &retcode, &line1, &line2, &tol, cst_pts, t1, t2 );

		MAptlndis( &retcode, cst_pts, &line2, &dist );

		if( fabs(dist) <= VRGetTol(VR_DIST_TOL) )
		{
		    me->next_pt[0] = cst_pts[0];
		    me->next_pt[1] = cst_pts[1];
		    me->next_pt[2] = cst_pts[2];
		    dimension = 1;
		}
		else
		{
		    cst_pts[0] = me->next_pt[0];
		    cst_pts[1] = me->next_pt[1];
		    cst_pts[2] = me->next_pt[2];
		    dimension = 1;
		}

	}
	else if ( cmp_systype == 0 )
	{
		IGRdouble CptCoord[3], CptAxis[3];

		status = om$send( msg      = message VRGeneric.VRGetCptGeom
			( &retcode, me->SecondCptNum, CptCoord, CptAxis, NULL,
					 &me->SecondLocatedElemMdEnv ),
			targetid = me->SecondLocatedElemId.objid,
			targetos = me->SecondLocatedElemId.osnum );
		as$status();

		CptAxis[0] = CptAxis[0] + CptCoord[0];
		CptAxis[1] = CptAxis[1] + CptCoord[1];
		CptAxis[2] = CptAxis[2] + CptCoord[2];

	        line2.point1 = CptCoord;
	        line2.point2 = CptAxis;

	        tol = 0.001;
                MA2lnisect( &retcode, &line1, &line2, &tol, cst_pts, t1, t2 );

	        if( ( fabs(cst_pts[0] - CptCoord[0]) < VRGetTol(VR_DIST_TOL)) &&
		    ( fabs(cst_pts[1] - CptCoord[1]) < VRGetTol(VR_DIST_TOL)) &&
		    ( fabs(cst_pts[2] - CptCoord[2]) < VRGetTol(VR_DIST_TOL))	)
	        {
		    cst_pts[0] = CptCoord[0];
		    cst_pts[1] = CptCoord[1];
		    cst_pts[2] = CptCoord[2];
		    dimension = 1;
	        }
	        else if ( retcode != MSSUCC )
	        {
		    cst_pts[0] = CptCoord[0];
		    cst_pts[1] = CptCoord[1];
		    cst_pts[2] = CptCoord[2];
		    dimension = 1;
	        }
	        else
	        {
		    cst_pts[3] = CptCoord[0];
		    cst_pts[4] = CptCoord[1];
		    cst_pts[5] = CptCoord[2];
		    dimension = 2;
	         }
		 me->next_pt[0] = CptCoord[0];
		 me->next_pt[1] = CptCoord[1];
		 me->next_pt[2] = CptCoord[2];
	         nb_sol = 1;
	}
	else
	{
		cst_pts[0] = me->next_pt[0];
		cst_pts[1] = me->next_pt[1];
		cst_pts[2] = me->next_pt[2];
		dimension = 1;
	}
  }

  TmpDimension = dimension;

  /* get all the solution points in cst_pts */
  
  if( !( me->AngleFlag && fabs(me->Angle) < VRGetTol(VR_ANGULAR_TOL) ) )
  {
       status = VRskget_all_sol( nb_sol, which_plane, cst_pts, 
                              lcl_first_pt, me->next_pt, lcl_next_pt );
       as$status( action = RET_STATUS );
  }

  /* select available solutions from first point ==> update needed variables
  /* to call VRis_next_pt_valid
  /**/

  if( me->FirstType == IS_PIPE ) action = 0;
  else				 action = 1;
  for( i=0, j=0, StopLoop=nb_sol; i<StopLoop; i++ )
  {      
    status = VRis_next_pt_valid
             ( action, &IsValidPoint, me->prev_pt, me->first_pt, &cst_pts[3*i],
	       me->NbOfImpDirection, me->ImpDirForDyn );

    if( status & IS_A_VALID_POINT & IsValidPoint )
    { 
      for( k=0; k<3; k++,j++ ) cst_pts[j] = cst_pts[3*i+k];
    }
    else nb_sol--;
  }

  if( ( me->SecondLocatedElemId.objid != NULL_OBJID ) && ( dimension != 1 ) )
  {
	struct GRid PrevSegId;
	IGRlong retcode;
        IGRint   nb_of_supports;
	IGRshort index, cmp_systype;
	IGRdouble tmp_pts[6], *prev_pt, *first_pt;
      
        status = om$send( msg = message VRGeneric.VRGetSupports(
				&retcode, 1, &PrevSegId, &nb_of_supports ),
		targetid = me->SecondLocatedElemId.objid,
		targetos = me->SecondLocatedElemId.osnum );
	as$status();
       
        status = om$send( msg      = message VRGeneric.VRGetSysType( &retcode, &cmp_systype ),
                      targetid = me->SecondLocatedElemId.objid,
                      targetos = me->SecondLocatedElemId.osnum );
    	as$status( action = RET_STATUS );

	if( cmp_systype == VR_DANGLING )
	{
            status = om$send( msg      = message VRCnrlSeg.VRget_terminators (
				&retcode, NULL, &me->SecondLocatedElemMdEnv,
				 tmp_pts, NULL ),
		targetid = PrevSegId.objid,
		targetos = PrevSegId.osnum );
	    as$status();

            status = om$send( msg      = message VRGeneric.VRGetIndex (
				&retcode, &PrevSegId, &index ),
		targetid = me->SecondLocatedElemId.objid,
		targetos = me->SecondLocatedElemId.osnum );
	    as$status();

	    if( ! index )
	    {
		prev_pt = &tmp_pts[3];
		first_pt = &tmp_pts[0];
	    }
	    else
	    {
		prev_pt = &tmp_pts[0];
		first_pt = &tmp_pts[3];
	    }

            for( i=0, j=0, StopLoop=nb_sol; i<StopLoop; i++ )
            {      
               status = VRis_next_pt_valid
                    ( action, &IsValidPoint, prev_pt, first_pt, &cst_pts[3*i],
	              me->NbOfImpDirection, me->ImpDirForDyn );

               if( status & IS_A_VALID_POINT & IsValidPoint )
               { 
                 for( k=0; k<3; k++,j++ ) cst_pts[j] = cst_pts[3*i+k];
               }
               else nb_sol--;
             }
	}

  }

  /*"nb_sol = %d\n", nb_sol */

  if( ! nb_sol ) *sts = MSFAIL; /* return if no valid solution */

  else if( ( dimension == 1 && me->SecondLocatedElemId.objid != NULL_OBJID  ) ||
			nb_sol == 1 )
  {
    status = om$send
             ( msg      = message VRsketch.VRskend_valid_sol( sts ),
               targetid = my_id
             );
    as$status( action = RET_STATUS );
  }

  End
  return OM_S_SUCCESS;

}


/******************************************************************************
/*
/*  			   VRskend_valid_sol method
/*
/* This method shakes for valid solution to connect to end component.
/*
/**/

method VRskend_valid_sol( IGRlong *sts )
{
  IGRint	i;		     /* loop index                       */
  IGRint	action, IsValidPoint;/* needed to call is_next_pt_valid  */
  IGRint 	nb_of_parents;       /* used by get_objects message      */
  IGRshort 	dangling_type;       /* dangling type                    */
  IGRshort	cmp_systype;         /* component system type            */
  IGRshort	dang_index;          /* dangling index                   */
  IGRint	status;		     /* return code                      */
  IGRlong	msg;		     /* return code                      */
  IGRvector	ImpDirForConnection; /* imposed connection direction     */
  IGRdouble	cmp_pt[6];           /* connection points coordinates    */
  IGRmatrix 	ref_matrix;
  struct	GRid	dang_seg_id; /* dangling parent's segment's GRid */

  SetProc( VRsketch_VRskend_valid_sol ); Begin
  *sts = MSSUCC;

  /* the user want to connect to component ==> get its type to upgrade needed
  /* information
  /**/
  if( me->IS_CONNECTABLE ) cmp_systype = VR_CONNECTABLE;
  else if( me->SecondLocatedElemId.objid != NULL_OBJID )
  {
    /* Checking SecondLocatedElemId for NULL_OBJID; prevents the errors
       which scroll when you use "dl"function for specifying the Next Point.
       Because in this case there is no Second Object Involved init.
       --Alwin, for TR179700865 */

    /* get located component type : Dangling, Nozzle,.... */
    status = om$send( msg      = message VRGeneric.VRGetSysType( &msg, &cmp_systype ),
                      targetid = me->SecondLocatedElemId.objid,
                      targetos = me->SecondLocatedElemId.osnum );
    as$status( action = RET_STATUS );
    as$status( sts = msg, action = RET_STATUS );
  }
  else if( me->SecondLocatedElemId.objid == NULL_OBJID )
  {
     /* force the state to be N_C -Alwin for TR179700865*/
     *sts = MSSUCC;
     End
     return OM_S_SUCCESS;
  }

  switch( cmp_systype )
  {
    case VR_NOZZLE :

      /*| located object is a NOZZLE */

      /* get its matrix to get imposed direction for dynamics */
      /* data == - X vector because we are going to connect to the nozzle
      /**/
      status = om$send( msg      = message VRGeneric.VRGetMatrix
                                           ( &msg, 0, NULL, ref_matrix,
                                             &me->SecondLocatedElemMdEnv ),
                        targetid = me->SecondLocatedElemId.objid,
                        targetos = me->SecondLocatedElemId.osnum );
      as$status( action = RET_STATUS );
      as$status( sts = msg, action = RET_STATUS );

      ImpDirForConnection[0] = -ref_matrix[0];
      ImpDirForConnection[1] = -ref_matrix[4];
      ImpDirForConnection[2] = -ref_matrix[8];
      /*"imp_dir = %f %f %f\n",ImpDirForConnection[0],ImpDirForConnection[1],ImpDirForConnection[2] */

      /* call VRis_next_pt_valid to see if the solution is valid */
      action = 1;
      status = VRis_next_pt_valid( action, &IsValidPoint, me->prev_pt, me->first_pt, me->next_pt,
				   1, ImpDirForConnection );

      if( status & IS_A_VALID_POINT & IsValidPoint ) me->SecondType = IS_NOZZLE;
      else
      {
         /* Not a valid solution */
         *sts = MSFAIL;
         End
         return OM_S_SUCCESS;
      }
    
      break;

    case VR_CONC_COMP:
    case VR_CONNECTABLE:

      /*| located object is a Conc Comp or connectable */
      status = VRGetCompInfo
               ( me->Product, &me->SecondLocatedElemId, 
		 (cmp_systype==VR_CONC_COMP) ? IS_CONC_COMP : IS_COMP_TO_CONNECT, me->next_pt,
                 &me->SecondLocatedElemMdEnv, &me->SecondCptNum, NULL, ImpDirForConnection,
                 NULL, NULL, NULL );
      as$status( action = RET_STATUS );

      /* we connect the network to constrain component ==> imposed direction is * by -1 */

      if( cmp_systype != VR_CONNECTABLE )
      {
      	ImpDirForConnection[0] *= -1;
      	ImpDirForConnection[1] *= -1;
      	ImpDirForConnection[2] *= -1;
      	/*"imp_dir = %f %f %f\n",ImpDirForConnection[0],ImpDirForConnection[1],ImpDirForConnection[2] */

      	action = 1;
        status = VRis_next_pt_valid( action, &IsValidPoint, me->prev_pt, 
			me->first_pt, me->next_pt, 1, ImpDirForConnection );
      }
      else
      {
      	action = 1;
        status = VRis_next_pt_valid
             ( action, &IsValidPoint, me->prev_pt, me->first_pt, me->next_pt,
	       me->NbOfImpDirection, me->ImpDirForDyn );
      }

      if( status & IS_A_VALID_POINT & IsValidPoint )
      {
        if( cmp_systype == VR_CONC_COMP ) me->SecondType = IS_CONC_COMP;
        else                              me->SecondType = IS_COMP_TO_CONNECT;
      }
      else { *sts = MSFAIL;
             End
             return OM_S_SUCCESS; }
      break;

    case VR_DANGLING :
      /*| the located object is a DANGLING */

      /* we need to know if the connection is valid ==> get the dangling support's id */
      status = om$send(msg      = message VRGeneric.VRGetSupports
                                  ( &msg, 1, &dang_seg_id, &nb_of_parents ),
                       targetid = me->SecondLocatedElemId.objid,
                       targetos = me->SecondLocatedElemId.osnum );
      as$status( action = RET_STATUS );
      /*"dang_seg_id = %d %d\n",dang_seg_id.objid,dang_seg_id.osnum */
   
      /* get end point of dangling support */
      status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                                   (&msg,NULL,&me->SecondLocatedElemMdEnv,cmp_pt,NULL),
                        targetid = dang_seg_id.objid,
                        targetos = dang_seg_id.osnum);
      as$status( action = RET_STATUS );
      as$status( sts = msg, action = RET_STATUS );
      /*"connect_pt1 = %f %f %f\n", cmp_pt[0], cmp_pt[1], cmp_pt[2] */
      /*"connect_pt2 = %f %f %f\n", cmp_pt[3], cmp_pt[4], cmp_pt[5] */

      /* get dangling index on the support */
      status = om$send( msg      = message VRGeneric.VRGetIndex
                                  ( &msg, &dang_seg_id, &dang_index ),
                        targetid = me->SecondLocatedElemId.objid,
                        targetos = me->SecondLocatedElemId.osnum);
      as$status( action = RET_STATUS );
      as$status( sts = msg, action = RET_STATUS );

      /* to call VRSkIsDanglingConnectionValid we need the dangling type : start
      /* or end component
      /**/
      dangling_type = END_OF_SEG;
      if( dang_index == 0 ) dangling_type = BEGIN_OF_SEG;

      if( VRSkIsDanglingConnectionValid
          ( dangling_type, &cmp_pt[0], &cmp_pt[3], me->first_pt, me->next_pt )
        ) me->SecondType = IS_DANGLING;
      else { *sts = MSFAIL;
             End
             return OM_S_SUCCESS; }
      break;

    case VR_PIPE :
      /*| the located object is a pipe */

      if( VRSkIsPipeConnectionValid
          ( me->Product, &me->SecondLocatedElemId, me->first_pt, me->next_pt,
            &me->SecondLocatedElemMdEnv ) )
	me->SecondType = IS_PIPE;
      else
      {
        if( me->prev_seg_id.objid != NULL_OBJID )
        {
          /* the last connection is not valid, but we connect the previous
          /* segment to the located pipe
          /**/
          dimension      = 1;
          me->SecondType = IS_PIPE;
          for(i=0; i<3; i++) me->next_pt[i] = me->first_pt[i];
          status =
	  om$send( msg      = message VRsketch.VRskcstsol( sts ),
                            targetid = my_id );
          as$status( action = RET_STATUS );
          *sts = VR_RETURN; /* to stop construct point mecanisme */
        }
        else { *sts = MSFAIL;
               End
               return OM_S_SUCCESS; }
      }

      break;

    case VR_ELBOW :
      {
        IGRdouble elbow_direct1[3], elbow_direct2[3];

        /*| Second Located boject is an elbow */

        /* get elbow topology to see if connection is valid */
        status = VRSkGetElbowTopo
                 ( &me->SecondLocatedElemId, elbow_direct1, elbow_direct2, NULL,
                   &me->SecondLocatedElemMdEnv );
        as$status( action = RET_STATUS );

        status = VRSkIsConElbowValid
                 ( (int *)&msg, me->first_pt, me->next_pt, elbow_direct1, elbow_direct2 );

        if( status & IS_A_VALID_POINT & msg ) me->SecondType = IS_ELBOW;
        else { *sts = MSFAIL;
               End
               return OM_S_SUCCESS; }
      }
  
      break;

    default : *sts = MSFAIL;
              End
              return OM_S_SUCCESS;
  }
  End
  return( OM_S_SUCCESS );
}


/******************************************************************************
/* System calls this method to display the first solution
/**/

method VRskfstchoice( IGRlong *sts )
{
  IGRint	status;		   
  IGRlong	msg;		   

  SetProc( VRsketch_VRskfstchoice ); Begin
  *sts = MSSUCC;

  /* display first segment for the first solution */

  if( !bMaintainSkew )
  {
     me->cst_pts[0] = me->first_pt[0];
     me->cst_pts[1] = me->first_pt[1];
     me->cst_pts[2] = me->first_pt[2];
     me->cst_pts[3] = cst_pts[0];
     me->cst_pts[4] = cst_pts[1];
     me->cst_pts[5] = cst_pts[2];
  }

  dp$display ( 	msg 	= sts,
		osnum 	= me->ModuleInfo.md_id.osnum,
		mode	= GRhd,
		num_elem = 1,
		buffer	= &me->cst_buffer );

  /* if dimension not equal to 1 ==> display the end of the way */
  if( dimension != 1 )
  {
        TmpDimension = dimension;
 
        if( bMaintainSkew )
        {
            IGRint i;
 
            if( dimension == 3 )
            {
              me->cst_pts[6]  = cst_pts[0];
              me->cst_pts[7]  = cst_pts[1];
              me->cst_pts[8]  = cst_pts[2];
 
              me->cst_pts[9]  = me->next_pt[0];
              me->cst_pts[10] = me->next_pt[1];
              me->cst_pts[11] = me->next_pt[2];
 
              me->way_cst_poly.num_points   = 3;
 
              for( i=0; i<9; i++ )
              {
                me->way_cst_pts[i] = me->cst_pts[3+i];
              }
            }
            else {
                me->cst_pts[0] = dIntSecPoint[0];
                me->cst_pts[1] = dIntSecPoint[1];
                me->cst_pts[2] = dIntSecPoint[2];
 
                for( i=0; i<3;  i++ )
                  me->cst_pts[3+i] = cst_pts[3*(current_solution-1) + i];
 
                me->cst_pts[6] = me->next_pt[0];
                me->cst_pts[7] = me->next_pt[1];
                me->cst_pts[8] = me->next_pt[2];
 
                for(i=0; i<6; i++ )
                   me->way_cst_pts[i] = me->cst_pts[3+i];
            }
 
            dp$erase_hilite ( msg   = &msg, osnum = me->ModuleEnv.md_id.osnum);
 
            dp$display (  msg      = sts,
                          osnum    = me->ModuleInfo.md_id.osnum,
                          mode     = GRhd,
                          num_elem = 1,
                          buffer   = &me->cst_buffer );
 
            dp$display (       msg      = sts,
                               osnum    = me->ModuleInfo.md_id.osnum,
                               mode     = GRhd,
                               num_elem = 1,
                               buffer   = &me->way_cst_buffer );
        }
        else {
 
          status =
          om$send( msg      = message VRsketch.VRskdisp_all_way( &msg ),
                  targetid = my_id );
          as$status( action = RET_STATUS );
 
        }
  }
  else if( bMaintainSkew )
  {
 
    bMaintainSkew = FALSE;
    me->cst_pts[0] = me->first_pt[0];
    me->cst_pts[1] = me->first_pt[1];
    me->cst_pts[2] = me->first_pt[2];
 
    me->cst_pts[3] = me->next_pt[0];
    me->cst_pts[4] = me->next_pt[1];
    me->cst_pts[5] = me->next_pt[2];
 
    dp$erase_hilite ( msg   = &msg, osnum = me->ModuleEnv.md_id.osnum);
 
    dp$display (        msg     = sts,
                      osnum         = me->ModuleInfo.md_id.osnum,
                          mode  = GRhd,
                          num_elem = 1,
                          buffer        = &me->cst_buffer );
 
    me->way_cst_pts[0] = me->next_pt[0];
    me->way_cst_pts[1] = me->next_pt[1];
    me->way_cst_pts[2] = me->next_pt[2];
 
    dp$display (       msg      = sts,
                               osnum    = me->ModuleInfo.md_id.osnum,
                               mode     = GRhd,
                               num_elem = 1,
                               buffer   = &me->way_cst_buffer );

  }

  current_solution = 1;

  /* print status information */
  VRskprint_segments_lengh( me->cst_pts, me->way_cst_pts, dimension ); 

  End
  return(OM_S_SUCCESS);
}

/*****************************************************************************
/* System calls this method to display the next solution
/**/

method VRsknextchoice( IGRlong *sts )
{
  IGRint	i;
  BSrc		bsretcode;
  IGRint	status;		     
  IGRlong	msg;		     
  IGRdouble 	TmpVect[3];


  SetProc( VRsketch_VRsknextchoice ); Begin
  *sts = MSSUCC;

  /* undisplay previous solution ==> principal segment and secondary segments */

  dp$erase_hilite ( msg   = &msg, osnum = me->ModuleEnv.md_id.osnum);

  if( nb_sol == 1 )
  {
    *sts = NO_MORE_SOLUTIONS;
    End
    return OM_S_SUCCESS;
  }

  /*"current solution = %d\n", current_solution */
  /*"dimension        = %d\n", dimension        */
  /*"nb_sol           = %d\n", nb_sol           */

  /* update buffer */
  if( ++current_solution > nb_sol ) 
  {
     /* This loop gets executed when all the solutions are displayed and
        user didn't select them; he wants to quit the loop of options which
        the system offers him. 
     */
     
        current_solution = 1;
  }
    
  if( bMaintainSkew )
  {
 
     if( dimension == 3 )
     {
        for( i=0; i<3; i++ )
           me->cst_pts[6+i] = cst_pts[3*(current_solution-1) + i ];
 
        me->cst_pts[9]  = me->next_pt[0];
        me->cst_pts[10] = me->next_pt[1];
        me->cst_pts[11] = me->next_pt[2];
 
        me->way_cst_poly.num_points   = 3;
 
        for( i=0; i<9; i++ )
        {
          me->way_cst_pts[i] = me->cst_pts[3+i];
        }
 
     }
     else if( dimension == 2 )
     {
        me->cst_pts[0] = dIntSecPoint[0];
        me->cst_pts[1] = dIntSecPoint[1];
        me->cst_pts[2] = dIntSecPoint[2];
 
        for( i=0; i<3; i++ )
           me->cst_pts[3+i] = cst_pts[3*(current_solution-1) + i ];
 
        me->cst_pts[6] = me->next_pt[0];
        me->cst_pts[7] = me->next_pt[1];
        me->cst_pts[8] = me->next_pt[2];
 
        for( i=0; i<6; i++ )
           me->way_cst_pts[i] = me->cst_pts[3+i];
 
     }
     else if( dimension == 1 )
     {
        me->cst_pts[0] = me->first_pt[0];
        me->cst_pts[1] = me->first_pt[1];
        me->cst_pts[2] = me->first_pt[2];
 
        me->cst_pts[3] = me->next_pt[0];
        me->cst_pts[4] = me->next_pt[1];
        me->cst_pts[5] = me->next_pt[2];
 
        me->way_cst_pts[0] = me->next_pt[0];
        me->way_cst_pts[1] = me->next_pt[1];
        me->way_cst_pts[2] = me->next_pt[2];
 
     }
  }
  else {
     me->cst_pts[0] = me->first_pt[0];
     me->cst_pts[1] = me->first_pt[1];
     me->cst_pts[2] = me->first_pt[2];
 
     for( i=0; i<3; i++ )
        me->cst_pts[i+3] = cst_pts[3 * (current_solution-1) + i];
  }
 
  /* Unhilite the old solution */
  dp$erase_hilite ( msg   = sts, osnum = me->ModuleEnv.md_id.osnum);
 
  /* display new solution */
  dp$display (       msg        = sts,
                     osnum      = me->ModuleInfo.md_id.osnum,
                     mode       = GRhd,
                     num_elem   = 1,
                     buffer     = &me->cst_buffer );
 
  if ( bMaintainSkew ) {
 
 
    dp$display (       msg      = sts,
                       osnum    = me->ModuleInfo.md_id.osnum,
                       mode     = GRhd,
                       num_elem = 1,
                       buffer   = &me->way_cst_buffer );
 
  /* print status information */
  VRskprint_segments_lengh( me->cst_pts, me->way_cst_pts, dimension );
 
  if( dimension == 1 ) bMaintainSkew = FALSE;
 
  End
  return OM_S_SUCCESS;
 
  }

  /*"cst_pt = %f %f %f\n", me->cst_pts[3], me->cst_pts[4], cst_pts[5] */
  /*"nxt_pt = %f %f %f\n", me->next_pt[0], me->next_pt[1], me->next_pt[2] */

  /* see if connect with zero distance ==>
  /* calculate the Tmpvector ( current next point, real next point )
  /* if TmpVector length is less than BSBASISVAl that's mean we would like
  /* to connect two network with zero distance
  /**/

  BSmkvec( &bsretcode, TmpVect, &me->cst_pts[3], me->next_pt );
  if( BSlenvec( &bsretcode, TmpVect ) < VRGetTol(VR_LENGTH_TOL) ) TmpDimension = 1;
  else TmpDimension = dimension;

  /*"TmpDimension = %d\n", TmpDimension */

  if( TmpDimension != 1 )
  {
    /* not zero distance connect */
    status = om$send( msg      = message VRsketch.VRskdisp_all_way( &msg ),
                      targetid = my_id );
    as$status( action = RET_STATUS );
  }

  /* print status information */
  VRskprint_segments_lengh( me->cst_pts, me->way_cst_pts, TmpDimension ); 

  End
  return(OM_S_SUCCESS);

}

/******************************************************************************
/* This method display the way between first proposed segment and end point
/* with different symbology
/**/

method VRskdisp_all_way( IGRlong *sts )
{
  IGRshort		way_which_plane;       
  IGRshort      	way_dimension;     
  IGRdouble 		lcl_first_pt[3]; /* cvt first_pt to local ref.       */
  IGRdouble 		lcl_next_pt[3];  /* cvt next_pt  to local ref.       */

  SetProc( VRsketch_VRskdisp_all_way ); Begin
  *sts = MSSUCC;
    
  /* get first and next point in the active cs */
  VRskgetpt_in_active_cs( &me->cst_pts[3], lcl_first_pt, &me->ModuleInfo);
  VRskgetpt_in_active_cs( me->next_pt, lcl_next_pt, &me->ModuleInfo );
  /*"next_pt = %f %f %f\n", me->next_pt[0], me->next_pt[1], me->next_pt[2] */

  way_which_plane   = 0;

  /* calculate the way dimension */
  if( 
      (
        fabs( lcl_first_pt[0] - lcl_next_pt[0] ) < VRGetTol(VR_DIST_TOL) && 
        fabs( lcl_first_pt[1] - lcl_next_pt[1] ) < VRGetTol(VR_DIST_TOL)    
      ) 
      ||
      (
        fabs( lcl_first_pt[0] - lcl_next_pt[0] ) < VRGetTol(VR_DIST_TOL) && 
        fabs( lcl_first_pt[2] - lcl_next_pt[2] ) < VRGetTol(VR_DIST_TOL) 
      )
      ||
      ( fabs( lcl_first_pt[1] - lcl_next_pt[1] ) < VRGetTol(VR_DIST_TOL) && 
        fabs( lcl_first_pt[2] - lcl_next_pt[2] ) < VRGetTol(VR_DIST_TOL)   
      )
    )
  {
    /*| linear way */
    way_dimension = 1;
    me->way_cst_poly.num_points   = 2;
  }
  else if( fabs( lcl_first_pt[0] - lcl_next_pt[0] ) < VRGetTol(VR_DIST_TOL) )
  {
    /*| planar way */
    way_dimension      = 2;
    way_which_plane    = 1;  /* YZ */ 
    me->way_cst_poly.num_points   = 3;
  }
  else if( fabs( lcl_first_pt[1] - lcl_next_pt[1] ) < VRGetTol(VR_DIST_TOL) )
  {
    /*| planar way */
    way_dimension      = 2;
    way_which_plane    = 2;  /* XZ */ 
    me->way_cst_poly.num_points   = 3;
  }
  else if( fabs( lcl_first_pt[2] - lcl_next_pt[2] ) < VRGetTol(VR_DIST_TOL) )
  {
    /*| planar way */
    way_dimension     = 2;
    way_which_plane   = 3;  /* XY */ 
    me->way_cst_poly.num_points   = 3;
  }
  else  {
    End
    return(OM_E_ABORT);  }

  /* call VRskget_way function */
  VRskget_way( way_dimension, way_which_plane, me->way_cst_pts, &me->cst_pts[3], 
               lcl_first_pt, me->next_pt, lcl_next_pt );

  /* display the end of the way */

  dp$display ( 	msg 	= sts,
		osnum 	= me->ModuleInfo.md_id.osnum,
		mode	= GRhd,
		num_elem = 1,
		buffer	= &me->way_cst_buffer );

  End
  return(OM_S_SUCCESS);
}


/*****************************************************************************
/**/

method VRskcstsol( IGRlong *sts )
{
  IGRint 			i;	   /* loop index                      */
  IGRshort			save_first_state;
                                           /* to store the first_pt state     */
  IGRshort			save_next_state;
                                           /* to store the next_pt state      */
  IGRlong			msg;       /* return code used to know if     */
                                           /* next point is valid and to      */
                                           /* detect an extend                */
  IGRint 			status;    /* return code                     */
  IGRdouble			tmp_pt[3]; /* temporary point                 */
  IGRboolean                    bIsSkew=FALSE;


  SetProc( VRsketch_VRskcstsol ); Begin
  *sts       = MSSUCC;

  /* undisplay the solution */

  dp$erase_hilite ( msg   = &msg, osnum = me->ModuleEnv.md_id.osnum);

  if( TmpDimension != dimension && me->SecondLocatedElemId.objid != NULL_OBJID )
  {
    /* connect to pipe with the last proposed segment is on the pipe */
    status = om$send( msg      = message VRsketch.VRskend_valid_sol( &msg ),
                      targetid = my_id);
    as$status( action = RET_STATUS );

    if( bMaintainSkew && dimension == 1 ) bMaintainSkew = FALSE;

    if( msg == MSFAIL )
    {
      ex$message( field   = ERROR_FIELD, in_buff = "No valid solution !" );
      End
      return OM_W_ABORT;
    }
  }

  if( dimension == 1 || TmpDimension != dimension )
  {

    /*| only one segment to connect networks ==> call VRskcstpt method */

    msg=FALSE;
    status = VRis_an_extend( &msg, me->prev_pt, me->first_pt, me->next_pt );
    as$status( action = RET_STATUS );

    if( msg == IS_AN_EXTEND ) me->extend = TRUE;
    else                      me->extend = FALSE;

   status = om$send( msg      = message VRsketch.VRskcstpt( &msg ),
                      targetid = my_id);
    as$status( action = RET_STATUS );
    as$status( sts = msg, action = RET_STATUS );

    /* force the state to restart */
    me->my_ret = 20; /* FORCE STOP YOU IDIOT, 
                        DEFINED SOMEWHERE ELSE AND TESTED AS 20
                        a sterling example of good coding......... */

    /*     (old comment)
                        any thing different then 10 and 100 */
    if( bMaintainSkew && dimension == 1 ) bMaintainSkew = FALSE;
  }
  else
  {
    /* many segments to connect network ==> call VRskcrseg method */
    me->my_ret = 10; /* there are ohter steps */

    /* update needed information to call VRskcrseg method */
    for( i=0; i<3; i++ )
    {
      tmp_pt[i] = me->next_pt[i];
      me->next_pt[i] = me->cst_pts[3+i];
    }

    msg=FALSE;
    status = VRis_an_extend( &msg, me->prev_pt, me->first_pt, me->next_pt );
    as$status( action = RET_STATUS );

    if( msg == IS_AN_EXTEND ) me->extend = TRUE;
    else                      me->extend = FALSE;

    /* we calling create segment method without fitting to fitting */
    save_first_state  = me->first_pt_free;
    save_next_state   = me->next_pt_free;
    me->first_pt_free = FALSE;
    me->next_pt_free  = FALSE;

    status = om$send( msg      = message VRsketch.VRskcrseg( sts ),
                      targetid = my_id );
    as$status( action = RET_STATUS );

    if( bMaintainSkew )
    {
        bIsSkew = TRUE;
        --dimension;
    }

    /* restore first point and next point state */
    me->first_pt_free = save_first_state;
    me->next_pt_free  = save_next_state;

    /* update next_pt for the next solution */
    me->next_pt[0] = tmp_pt[0];
    me->next_pt[1] = tmp_pt[1];
    me->next_pt[2] = tmp_pt[2];

    /*| call VRskget_valid_sol method to continu */
    if( !bIsSkew )
    {
      status = om$send( msg      = message VRsketch.VRskget_valid_sol( &msg ),
                      targetid = my_id);
      as$status( action = RET_STATUS );

      if( msg != MSSUCC )
      {
        /*| force the state to be N_P */
        me->my_ret = 20; /* any thing different then 10 */
        End
        return( OM_S_SUCCESS );
      }
    }

    /* display first solution of the new way */
    status = om$send( msg      = message VRsketch.VRskfstchoice( &msg ),
                      targetid = my_id);
    as$status( action = RET_STATUS );
    as$status( sts = msg, action = RET_STATUS );
  }

  End
  return OM_S_SUCCESS;

}  


/*****************************************************************************
/* This method calls VRskconnect method to connect to networks.
/**/

method VRskcstpt( IGRlong *sts )
{
  IGRlong			msg;       /* return code used to know if     */
                                           /* next point is valid and to      */
                                           /* detect an extend                */
  IGRint 			status;    /* return code                     */

  SetProc( VRsketch_VRskcstpt ); Begin
  *sts       = MSSUCC;

  /* undisplay the solution */

  dp$erase_hilite ( msg   = &msg, osnum = me->ModuleEnv.md_id.osnum);

  if( me->SecondLocatedElemId.objid != NULL_OBJID )
  {
    /* restart sketch command */
    _put_response(resp = EX_RJT_MOVEON);

    status = om$send( msg      = message VRsketch.VRskconnect( &msg ),
                      targetid = my_id );

    if( ! ( status & 1 & msg ) && me->FirstType == FREE_SPACE ) me->PlaceDangling = TRUE;
    else                         			        me->PlaceDangling = FALSE;
  }
  else
  {
  	/* construct point mecanism was activated because user given a tentative
  	/* data point so we call VRskcrseg to place the last segment
  	/**/
  	status = om$send( msg      = message VRsketch.VRskcrseg( &msg ),
                    	  targetid = my_id );
  	as$status( action = RET_STATUS );
  }

quit:
  End
  return(OM_S_SUCCESS);

}  

end implementation VRsketch;
