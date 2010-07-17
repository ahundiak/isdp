/* $Id: VLmrkAConFi.I,v 1.8 2002/02/26 23:24:55 ylong Exp $  */
/*************************************************************************
 * I/LOFT
 *
 * File:        src/mrkLine/VLmrkAConFi.I
 *
 * Description: Implementation of object defining the mark of a Struct
 *		stiffener or plate on a plate. The result is usually a
 *		curve defining the side of the marking object which touches
 *		the corresponding plate along with an offset (malconta) which
 *		indicates the width of the marking object.  The main curve
 *		may be trimmed across boundaries and the offset is usually a
 *		short curve of a 100 units, a third of the way along the
 *		length of the marking object.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLmrkAConFi.I,v $
 *      Revision 1.8  2002/02/26 23:24:55  ylong
 *      marking line losing feet for plate stiffener
 *
 *      Revision 1.7  2001/12/03 22:49:44  ramarao
 *      changes for CR#MP 5085 and tabs in emacs
 *
 *      Revision 1.6  2001/10/21 17:33:29  ramarao
 *      Implemented CR# 5085.
 *
 *      Revision 1.5  2001/03/05 17:20:24  ramarao
 *      Modified the feet order in case of Manual Marking.
 *
 *      Revision 1.4  2001/02/20 01:04:54  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.3  2001/01/31 15:45:28  jayadev
 *      changes for TR4572
 *
 *      Revision 1.2  2001/01/16 20:56:18  ramarao
 *      *** empty log message ***
 *
 # Revision 1.13  2000/11/17  19:22:54  pinnacle
 # Replaced: loft/src/mrkLine/VLmrkAConFi.I for:  by jpulapar for Service Pack
 #
 # Revision 1.12  2000/11/16  19:43:10  pinnacle
 # Replaced: loft/src/mrkLine/VLmrkAConFi.I for:  by jpulapar for Service Pack
 #
 # Revision 1.11  2000/10/16  17:29:38  pinnacle
 # ah
 #
 # Revision 1.10  2000/09/28  21:47:00  pinnacle
 # Replaced: loft/src/mrkLine/VLmrkAConFi.I for:  by jpulapar for Service Pack
 #
 # Revision 1.9  2000/09/28  18:05:20  pinnacle
 # Replaced: loft/src/mrkLine/VLmrkAConFi.I for:  by jpulapar for Service Pack
 #
 # Revision 1.8  2000/08/02  15:34:46  pinnacle
 # Replaced: loft/src/mrkLine/VLmrkAConFi.I for:  by rchennup for Service Pack
 #
 # Revision 1.7  2000/07/08  16:51:28  pinnacle
 # Replaced: loft/src/mrkLine/VLmrkAConFi.I for:  by rchennup for Service Pack
 #
 # Revision 1.6  2000/07/02  16:16:30  pinnacle
 # Replaced: loft/src/mrkLine/VLmrkAConFi.I for:  by rchennup for Service Pack
 #
 # Revision 1.5  2000/06/03  21:58:38  pinnacle
 # Replaced: loft/src/mrkLine/VLmrkAConFi.I for:  by rchennup for Service Pack
 #
 # Revision 1.4  2000/04/30  14:06:08  pinnacle
 # Replaced: loft/src/mrkLine/VLmrkAConFi.I for:  by rchennup for Service Pack
 #
 # Revision 1.2  2000/04/25  22:49:20  pinnacle
 # Replaced: loft/src/mrkLine/VLmrkAConFi.I for:  by rchennup for Service Pack
 #
 # Revision 1.1  2000/04/21  21:41:08  pinnacle
 # Created: loft/src/mrkLine/VLmrkAConFi.I by rchennup for Service Pack
 #
 # Revision 1.10  2000/03/31  19:46:24  pinnacle
 # Replaced VLmrkAConFi.I by jpulapar
 #
 # Revision 1.9  2000/03/16  16:51:18  pinnacle
 # Replaced: src/mrkLine/VLmrkAConFi.I for:  by impd252 for loft
 #
 # Revision 1.8  2000/03/10  22:53:48  pinnacle
 # Replaced VLmrkAConFi.I by jpulapar
 #
 # Revision 1.7  2000/03/06  20:27:18  pinnacle
 # Replaced VLmrkAConFi.I for TR179901047 by jpulapar
 #
 # Revision 1.6  2000/02/17  20:44:34  pinnacle
 # Changed the extension value from 100.0 to 1.0
 #
 # Revision 1.5  1999/12/30  12:42:34  pinnacle
 # Replaced VLmrkAConFi.I for TR179900910 by jpulapar for loft
 #
 # Revision 1.4  1999/06/08  15:59:46  pinnacle
 # ah
 #
 # Revision 1.3  1999/06/02  13:53:40  pinnacle
 # tr179900638
 #
 # Revision 1.2  1999/04/09  21:36:50  pinnacle
 # Rama Rao SP08
 #
 # Revision 1.1  1998/04/30  10:32:50  pinnacle
 # LOFT 2.5.1
 #
 # Revision 1.5  1998/03/10  08:33:10  pinnacle
 # Replaced: src/mrkLine/VLmrkAConFi.I for:  by rchennup for loft
 #
 # Revision 1.4  1998/02/17  15:43:00  pinnacle
 # Replaced: src/mrkLine/VLmrkAConFi.I for:  by rchennup for loft
 #
 # Revision 1.3  1998/01/28  15:20:26  pinnacle
 # Replaced: src/mrkLine/VLmrkAConFi.I for:  by rchennup for loft
 #
 # Revision 1.2  1998/01/02  06:37:40  pinnacle
 # Replaced: src/mrkLine/VLmrkAConFi.I for:  by rchennup for loft
 #
 *
 * History:
 * MM/DD/YY  AUTHOR   DESCRIPTION
 * 01/02/98  Rama Rao Header Creation and Fix for TR#179702403
 * 04/09/99  ah       Rama Rao SP08 Fixes
 * 06/02/99  ah       TR179900638 Add Side attributes to foot
 * 06/08/99  ah       Adjusted marking line tolerance from 5.0 to .01
 * 09/04/99  Jayadev  changes made for TR179900777
 * 10/12/99  Jayadev  changes made for TR179900904
 * 10/20/99  Jayadev  changes made for TR179900910
 * 02/17/00  RR	      Changed the extension value from 100.0 to 1.0 
 *                    for get_extsurf_geom() function.
 * 03/06/00  Jayadev  changes made for TR179901047
 * 03/31/00  Jayadev  changes made for TR179901294
 * 04/21/00  Jayadev  VLClosestEdgeToSrf modified - the closest edge will be
 *                    projected on to the plate surface from now on
 * 04/26/00  Jayadev  IntTwoSrf trimoption set to TRUE and some memory freeup
 * 04/30/00  Jayadev  Extension of stiff surfaces changed from 1.0 to multiple
 *		      of plate thickness - TR179901476
 * 07/02/00  Jayadev  Avoid collar plates from marking (as stiffeners)
 * 08/02/00  Jayadev  delete unwanted graphics; these additional feet are 
 *		      messing up the SPADES translation
 * 09/28/00  Jayadev  TR179902044
 * 11/16/00  Jayadev  TR# MP3378 FullLine should be copy of main mark
 * 11/17/00  Jayadev  Plates marking given perpendicular marker - TR179902114 
 * 11/30/01  Jayadev  Dummy point for marking being placed at the origin; 
 *                    Place it at the mid_point of fullLine - CR#MP 5085 ; 
 *                    Entire Code reorganized cleanly and tabbed in emacs 
 *************************************************************************/

class implementation VLmrkLine;

#include <stdio.h>
#include "vlprototype.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "bserr.h"
#include "msdef.h"
#include "madef.h"
#include "ma.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "exmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "growner.h"
#include "EMSopt.h"
#include "EMSwrmacros.h"
#include "VDgeom.h"
#include "v_geommacros.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDsa.h"
#include "vsbmaxisdef.h"
#include "vsglobalmsg.h"
#include "vsattr.h"
#include "vsplate.h"
#include "vsplatedef.h"
#include "vsoptdef.h"
#include "vsstfnrdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsbeam.h"
#include "VDtypedef.h"
#include "VDefp.h"
/********************************** DEBUG flags	***********************
				    
#ifndef MARKERDEBUG
#define MARKERDEBUG	1 
#define vsDEBUG		1
#define vserrDEBUG	1
#endif
				    
******************************** end DEBUG flags	***********************/

#include "vldbgmacros.h"
#include "vldbgmacros.h"
#include "vlmark.h"
#include "bsmdarrptsf.h"
#include "bsdistptpt.h"
#include "bscveval.h"

#ifndef M_PI
#define M_PI    3.14159265358979323846
#endif

#define EPS 1e-5
#define MALCONTA 8

extern   IGRint   VLGetWebProj();
extern   IGRint   VLgetPlateSide();
extern	 double	  fabs() ;
extern 	 ASmake_source_from_env( 
                                struct GRid *,
				struct GRmd_env *,
				struct GRid *,
				int	
                               );

extern   GRdisplay_object(),
         VLseekFields ( struct ACrg_coll*, int, char* );

from	ACrg_collect	import	AClist_attribute,
                                ACmod_list_attribute,
                                ACadd_list_attribute;

from	EMSboundary	import	EMget_edges ;
from	EMSedge 	import	EMgetstrkpy ,
                                EMget_bcxyz_geom ;

from	GRbcsubbc	import	EMdirect_fit_curve ;
from    VSfeature       import  VSforwardToSource ;
from    VSstfBeam       import  VSgetPlateSide;
from    EMSsubbs        import  EMproject_curve_along_surface_normals;
from    expression      import  NDgive_value;

extern	GRclassid	OPP_EMSgenbs_class_id ,
                        OPP_GRbcsubbc_class_id ,
                        OPP_VSplate_class_id ,
                        OPP_VSfeature_class_id ,
                        OPP_VSimgFeature_class_id,
                        OPP_VSbeam_class_id ,
                        OPP_ACpretend_class_id ,
                        OPP_EMSplane_class_id ;

static struct GRobj_env surfOE;
/*
 * ----------------------------------------------------------------------------
 * Function to find if a surface has an edge of which at least a part of it
 * lies on another (base) surface, if this is the case return the part of
 * edge lying on the base surface and TRUE, otherwise no linestring + FALSE
 * + NULL_OBJID 
 * ----------------------------------------------------------------------------
 */

#if 0
IGRboolean  VLClosestEdgeToSrf (
				IGRlong			* IMsg ,	    // I/O status code
				IGRdouble		  Tol ,		    //Tolerance for edge
				struct GRobj_env	* TanSurfPtr ,	    //I:Surf with edge
				struct IGRbsp_surface	* BaseSrfGeomPtr ,  //I:srf to check 
				struct GRvg_construct	* VgCnst,	    //I:constrn list
				struct GRid		* EdgeCurve 	    //O:curve of edge
				)
  
  
  
{
  
  struct GRid	*	Edges	= NULL ;	    // list of tan srf edges
  GRobjid	*	LoopIds = NULL ;	    // loopset of edges
  OM_S_OBJECT_LINKAGE	LoopSetLink ;		    // loopset link of edges
  IGRuint		NumLoopSets = 0;
  IGRint		NumLoopIds  = 0 ,	    // ints for managing
                        TreeDepth   = OM_K_MAXINT , // various arrays of
                        NumEdges    = 0 ,	    // pts and loops etc
                        ArraySize   = 0 ,
                        * NumXYZPts = NULL ,
                        xx	    = 0 ,
                        sts	    = OM_E_INVARG ,
                        EdgeNum	;
  
  IGRlong	        Option	    = EMS_OPT_NON_DEG_SEAM_XYZCLSD ;
  IGRushort	        Options	    = 0 ;
  IGRdouble **          XYZPts	    = NULL ,
                        **Dists	    = NULL ,
                        PreviousDist;		// check for coincident pts
  
  // NOT USED IGRpoint  **   SurfPts	    = NULL ;
  
  IGRboolean	        AllOnSurf   = FALSE ,
                        BoolRC	    = FALSE ;
  
  BSrc		        bsrc	    = BSFAIL ;
  
  int              CurrEdgePtCheck  = 0 , 	// check edge with most pts
                   LargestNumPts    = 0 , 	// num pts of edge within Tol
                   ClosestEdge	    = 0 ;	// index of edge closest to surf
  
  struct EMSpartolbasis	ParTolBasis ;
  
  struct IGRbsp_curve	EdgeCurveGeom ;		// this is a struct NOT ptr !
  int                   is_planar   = TRUE; 

  SetProc( VLClosestEdgeToSrf )	;	Begin
					  
  EdgeCurveGeom.poles = EdgeCurveGeom.weights = EdgeCurveGeom.knots = NULL ;
  
  if (	! IMsg		||
	! TanSurfPtr	||
	!BaseSrfGeomPtr ||
	! EdgeCurve )		goto wrapup ;
  /* 
   * The algo for finding the closest edge to the surface doesnot work for 
   * some of the surfaces of curved plates - under such a case wrapup here and 
   * extend the stiff surface to intersect 
   */
  // check if the surface being marked is planar - TR179900910
  if(surfOE.obj_id.objid != NULL_OBJID)
  {
    is_planar = vs$is_surface_planar( msg = IMsg,
				      surfId  = &surfOE.obj_id,
				      surfEnv = &surfOE.mod_env ) ;
    __CheckRC( 1, *IMsg, "vs$is_surface_planar", wrapup ) ;
    if(!is_planar) goto wrapup;
    
  }
  EdgeCurve->objid =  NULL_OBJID ;		//always assume fail 
  
  sts = VLGetSurfLoops( &(TanSurfPtr->obj_id) ,
			&LoopSetLink ,
			&NumLoopSets ,
			&LoopIds ,
			&NumLoopIds ) ;
  CheckRC( sts, 1  ) ;
  
  __DBGpr_int( "num loops", NumLoopIds ) ;
  
  if(NumLoopSets == 0 || NumLoopIds == 0) goto wrapup; // for TR179900904
  
  sts  = om$send ( msg = message EMSboundary.EMget_edges( 
                                             IMsg,
                                             TreeDepth,
                                             Option,
                                             &Edges,
                                             &ArraySize,
                                             &NumEdges ),
		   senderid = NULL_OBJID,
		   targetid = LoopIds[0],
		   targetos = TanSurfPtr->_osnum ) ;
  
  __CheckRC( sts, *IMsg, "EMSboundary.EMget_edges", wrapup );
  __DBGpr_int( "after get edges",NumEdges );
  
  if( !NumEdges )  goto wrapup;
  
  XYZPts	= _MALLOC( NumEdges , IGRdouble* ) ;
  NumXYZPts	= _MALLOC( NumEdges , IGRint ) ;
  Dists  	= _MALLOC( NumEdges , IGRdouble* ) ;
  //	SurfPts	= _MALLOC( NumEdges , IGRpoint* ) ; NOT USED 
  
  ParTolBasis.is_valid = ParTolBasis.in_world = FALSE ;
  ParTolBasis.mattyp   = NULL ;
  ParTolBasis.mat      = NULL ;
  
  // go thru edges find num pts closest to base surf
  
  for ( EdgeNum = 0 ; EdgeNum < NumEdges ; ++EdgeNum ) {
    
    sts  = om$send ( msg = message EMSedge.EMgetstrkpy( 
                                           IMsg,
					   &(TanSurfPtr->_matrix_type) ,
					   (TanSurfPtr->_matrix) ,
					   NULL ,  // no surf geom
					   &ParTolBasis ,  
					   Options ,
					   &(NumXYZPts[EdgeNum])  ,
					   NULL ,		//no uv pts 
					   &(XYZPts[EdgeNum]),
					   NULL 		//no uv pts 
					  ),
		     senderid = NULL_OBJID,
		     targetid = Edges[EdgeNum].objid ,
		     targetos = Edges[EdgeNum].osnum ) ;
    
    __CheckRC( sts, *IMsg, "EMSedge.EMgetstrkpy", wrapup );
    __DBGpr_int( "after get stroke pts", NumXYZPts[EdgeNum] );
    
    //	NOT USED SurfPts[EdgeNum] = _MALLOC( NumXYZPts[EdgeNum] , IGRpoint ) ;
    
    Dists  [EdgeNum] = _MALLOC( NumXYZPts[EdgeNum] , IGRdouble ) ;
    
    BSmdarrptsf( NumXYZPts[EdgeNum] ,
		 (IGRpoint*)XYZPts[EdgeNum] ,
		 BaseSrfGeomPtr ,// Surf,
		 Tol ,		 // tol,	Fixed ie NOT base tol 
		 FALSE ,	 // ret_uvs, 	NO UV pts
		 FALSE ,	 // ret_pts,	NO pts on surface
		 TRUE ,	         // ret_dist,
		 FALSE ,         // ret_all_on_surf,
		 NULL ,	         // uvs,
		 NULL ,	         // SurfPts[EdgeNum],	//sf_pts, NOT USED 
		 Dists[EdgeNum] ,//dists,
		 &AllOnSurf ,	 //all_on_surf,
		 &bsrc ) ;
    __CheckBSRC( bsrc, "BSmdarrptsf", wrapup );
    __DBGpr_int( "all edge pts on surf", AllOnSurf ) ;
    
    // note the pts within Tol of base surface
    
    //NOT USED	   	__DBGpr_vec( "1st srf point", ((SurfPts[EdgeNum])[xx]));
    
    //	  PreviousDist = 0.0 ;
    for ( xx=0, CurrEdgePtCheck=0 ; 
	  xx<NumXYZPts[EdgeNum]	  ;
	  PreviousDist = Dists[EdgeNum][xx], ++xx ) 				
    {
      
      __DBGpr_dbl( "dist", Dists[EdgeNum][xx] ) ;
      
      // dist less than Tol and not same as previous
      
      if ( Dists[EdgeNum][xx] < Tol  ) {
	if ( xx ) {
	  if ( BSdistptpt( &bsrc, ((IGRpoint*)XYZPts[EdgeNum])[xx] ,
			   ((IGRpoint*)XYZPts[EdgeNum])[xx-1] ) > 0.1 )
	    ++CurrEdgePtCheck ;
	}
	else				    	    ++CurrEdgePtCheck ;
      }
      
    }     // for pts on edge 
    
    // find edge with most points within Tol of surface
    
    if ( CurrEdgePtCheck > LargestNumPts ) {
      LargestNumPts = CurrEdgePtCheck ;
      ClosestEdge   = EdgeNum ;
    }
    __DBGpr_int( "ClosestEdge", ClosestEdge ) ;
    __DBGpr_int( "number of pts of this edge on surf", LargestNumPts ) ;
    
  }	// for All Edges
  
  if ( LargestNumPts > 1 ) {	// if some points were within Tol
    
    sts  = om$send ( msg = message EMSedge.EMget_bcxyz_geom (
                                           IMsg,
					   &(VgCnst->env_info->md_env) ,
					   &(TanSurfPtr->obj_id) , 
					   NULL,
					   0,
					   OM_K_MAXINT,
					   FALSE,
					   NULL,
					   &EdgeCurveGeom ),
		     senderid = NULL_OBJID,
		     targetid = Edges[ClosestEdge].objid,
		     targetos = Edges[ClosestEdge].osnum  );
    
    __CheckRC( sts, *IMsg , "EMSedge.EMget_bcxyz_geom", wrapup );
    __DBGpr_int( "edge curve order", EdgeCurveGeom.order ) ;
    
    EdgeCurve->osnum =  VgCnst->env_info->md_id.osnum;
    VgCnst->geometry = (char*)&EdgeCurveGeom ;
    
    // got the extend geom, build the curve
    sts = om$construct(     classid = OPP_GRbcsubbc_class_id ,
			    osnum   = EdgeCurve->osnum	,
			    p_objid = &(EdgeCurve->objid) ,
			    );
    __DBGpr_int( "edge curve order", EdgeCurveGeom. order ) ;
    
    if ( EdgeCurveGeom. order >2 ) {
      
      sts = om$send( msg  =	message GRgraphics.GRconstruct( VgCnst ),
		     senderid = NULL_OBJID,
		     targetid = EdgeCurve->objid,
		     targetos = EdgeCurve->osnum  );
      VgCnst->geometry = NULL ;
      __CheckRC( sts, *(VgCnst->msg) , "construct&place edge curv", wrapup );
      
    }
    else {		// linestring, should be a rare occurrence!!
      
      IGRboolean Periodic  = FALSE ;		//don't force it to be periodic
      IGRlong	 Order ;
      IGRvector  *StartTan = NULL ,		//for now, don't give tangents
	         *EndTan   = NULL ;
      
      /*      
       * commented for TR179901047 - retain linestring with order 2
       * set desired curve order as function of num poles
       * if ( EdgeCurveGeom. order < 3 && EdgeCurveGeom. num_poles > 3 ) 
       *                                               Order	= 4 ;
       *      else if ( EdgeCurveGeom. num_poles > 2 ) Order	= 3 ;
       *      else				       Order	= 2 ;
       */
      Order = 2; //TR179901047
      VgCnst->geometry = NULL ;
      sts = om$send( msg  = message GRbcsubbc.EMdirect_fit_curve ( 
                                              Order ,
					      Periodic ,
					      EdgeCurveGeom. num_poles ,
					      (IGRpoint*)EdgeCurveGeom. poles ,
					      NULL ,
					      StartTan ,
					      EndTan ,
					      VgCnst  ),
		     senderid = NULL_OBJID,
		     targetid = EdgeCurve->objid,
		     targetos = EdgeCurve->osnum  );
      
      VgCnst->geometry = NULL ;
      __CheckRC( sts, *(VgCnst->msg) , "construct&place edge curv", wrapup );
      
    }	// else if edge order 2 (linestring)
    
    __DBGpr_obj( "edge curve", *EdgeCurve );
    BoolRC	=	TRUE ; // found and placed an edge curve
    
  }     // if more than one point on surface 
  
  else	BoolRC = FALSE ;
  
  
 wrapup:  // BE careful,the combination of ptrs in this function is subtle
 
  if ( XYZPts ) {
    for ( EdgeNum = 0 ; EdgeNum < NumEdges ; ++EdgeNum ) {
      if ( XYZPts[EdgeNum] ){ om$dealloc( ptr = XYZPts[EdgeNum] );
      XYZPts[EdgeNum] = NULL ; }
    }
  }
  
  if ( Dists ) {
    for ( EdgeNum = 0 ; EdgeNum < NumEdges ; ++EdgeNum )
      _FREE( Dists[EdgeNum] ) ; 
  }
  // _FREE( SurfPts[EdgeNum] ) ;   pts on base srf not used 
  
  if ( LoopIds ) { om$dealloc( ptr = LoopIds ) ;  LoopIds = NULL ; }
  if ( Edges )   { om$dealloc( ptr = Edges ) ;    Edges   = NULL ; }
  
  _FREE( NumXYZPts ) ; _FREE( XYZPts ) ; _FREE( Dists ) ;
  
  _FREE( EdgeCurveGeom.poles ) ;
  _FREE( EdgeCurveGeom.weights );
  _FREE( EdgeCurveGeom.knots  ) ;
  
  End
    return BoolRC ;		// this is a boolean function
  
}	// end VLClosestEdge to surf
#endif

IGRint  VLClosestEdgeToSrf (
			    IGRlong		  *IMsg ,	    // I/O status code
			    IGRdouble		  Tol ,		    //Tolerance for edge
			    struct GRobj_env	  *TanSurfPtr ,	    //I:Surf with edge
			    struct IGRbsp_surface *BaseSrfGeomPtr , //I:srf to check 
			    struct GRvg_construct *VgCnst,	    //I:constrn list
			    struct GRid		  *EdgeCurve 	    //O:curve of edge
			    )
{
  IGRint                 retFlag = FALSE,mcount = 0;
  IGRlong                sts;
  struct IGRbsp_curve    *edgeCurves[VDEFP_NEAT_EDGES_MAX];
  BSrc			 rc = BSFAIL ;
  int                    i,is_planar = TRUE; 
  IGRdouble              par = 0.0,min_dist = 0.0;
  int                    numEdges	=0 , 	// num of edges marking the surf
                         LargestNumPts	=0 , 	// num pts of edge within Tol
                         ClosestEdge	=0 ;	// index of edge closest to surf
  
  IGRint                 *min_dist_count = NULL;
  IGRint                 num = 0,numInters = 0;
  IGRdouble              *part =NULL;
  IGRdouble              *paruv =NULL;
  IGRpoint               *cpt =NULL,*sfpt =NULL;
  OM_S_OBJID             *inters = NULL;
  struct GRobj_env       edgeOE;
  struct GRid            edgeID,*deleteList;
  
  
  SetProc( VLClosestEdgeToSrf )	;	
  
  // arg check
  if (	! IMsg		||
	! TanSurfPtr	||
	!BaseSrfGeomPtr ||
	! EdgeCurve )		goto wrapup ;
  
  //init
  edgeID.objid = NULL_OBJID;
  edgeOE.obj_id.objid = NULL_OBJID;
  /* 
   * The algo for finding the closest edge to the surface doesnot work for 
   * some of the surfaces of curved plates - under such a case wrapup here and 
   * extend the stiff surface to intersect 
   */
  /*
   * check if the surface being marked is planar - TR179900910
   */
  if(surfOE.obj_id.objid != NULL_OBJID)
  {
    is_planar = vs$is_surface_planar( msg = IMsg,
				      surfId  = &surfOE.obj_id,
				      surfEnv = &surfOE.mod_env ) ;
    __CheckRC( 1, *IMsg, "vs$is_surface_planar", wrapup ) ;
    if(!is_planar) goto wrapup;
  }
  EdgeCurve->objid =  NULL_OBJID ;		//always assume fail
  ex$get_modid(   mod_osnum = TanSurfPtr->obj_id.osnum ,
		  mod_id  = &(TanSurfPtr->_md_id) ) ;
  TanSurfPtr->mod_env.md_id.osnum = TanSurfPtr->obj_id.osnum; 
  
  // Get the bsps for the surface edges
  sts =  VDefpGetSurfaceEdgeBsps(TanSurfPtr,VDEFP_NEAT_EDGES_MAX,Tol,&numEdges,edgeCurves);
  if((!(sts&1))||(numEdges == 0)) goto wrapup;

  __DBGpr_int("No. of edges for surface : ",numEdges);
  
  min_dist_count = _MALLOC(numEdges,IGRint);
  for(i=0;i<numEdges;i++) min_dist_count[i] = 0;
  // Get the closest edge to the plate surface
  for(i=0;i<numEdges;i++)
  {
    BSmdistcvsf(edgeCurves[i],BaseSrfGeomPtr,&num,&part,&paruv,&cpt,&sfpt,&min_dist,&rc);
    if ( BSSUCC != rc ) goto wrapup;
    if(min_dist>Tol) continue;
    for(par = 0.0;par<=1.0; par=par+0.1)
    {
      IGRdouble u, v  ;
      IGRdouble base[3],dist1= 0.0;
      IGRint    num_pars = 1;
      IGRdouble point[3];

      // get the point on the curve at par
      BScvarrev0(&rc,edgeCurves[i],&par,num_pars,point); 
      if ( BSSUCC != rc ) goto wrapup;
      // find the min_dist of the point from the plate surface
      BSmdistptsf(&rc, BaseSrfGeomPtr,point, &u,&v,base,&dist1);
      if ( BSSUCC != rc ) goto wrapup;
      if(dist1<Tol) min_dist_count[i]=min_dist_count[i]+1; 
    }  
  }
  num = 2;
#ifdef DEBUG
  for(i=0;i<numEdges;i++) printf("\n min_dist_count[%d] = %d \n",i,min_dist_count[i]);
#endif
  for(i=0;i<numEdges;i++)
  {
    if(min_dist_count[i] > num)
    {
      num = min_dist_count[i];
      ClosestEdge = i;
    }
  }
  if(num == 2) goto wrapup; // not enough close points
  
  /*
   *  TR179901294 - stiffener surface having multiple close edges to the plate
   *  being marked. Returning only one edge will not help. Extend the stif surf
   */
  for(i=0;i<numEdges;i++)
  {
    if(min_dist_count[i] > 2) mcount++;
    if(mcount>1) goto wrapup; // too many close edges
  } 
  { // if some points were within Tol
    /* 16 Oct 2000 Added env to VDdrawCurve */
    VDdrawCurve(edgeCurves[ClosestEdge],VgCnst->env_info,&edgeID);
    if(edgeID.objid == NULL_OBJID) goto wrapup;

    VDahGetObjectEnv(&edgeID,&edgeOE);
    if(edgeOE.obj_id.objid == NULL_OBJID) goto wrapup;
    
    _FREE(edgeCurves[ClosestEdge]);
    edgeCurves[ClosestEdge] = NULL;
    
    sts = VLproject_curve(&surfOE,&edgeOE,VgCnst,&numInters,&inters);
    if(!(sts&1)) goto wrapup;
    if(numInters == 0) goto wrapup;

    deleteList = _MALLOC(numInters,struct GRid);
    for(i=0;i<numInters;i++)
    {
      deleteList[i].objid = inters[i];
      deleteList[i].osnum = VgCnst->env_info->md_id.osnum;
    } 
    edgeOE.obj_id.objid = inters[0];
    edgeOE.obj_id.osnum = VgCnst->env_info->md_id.osnum;
    
    vdgeom$Get2(objOE = &edgeOE, crv = &edgeCurves[ClosestEdge]);
    if (edgeCurves[ClosestEdge] == NULL) goto wrapup;
    
    EdgeCurve->osnum =  VgCnst->env_info->md_id.osnum;
    VgCnst->geometry = (char*)edgeCurves[ClosestEdge];
    
    // got the geom, build the curve
    sts = om$construct(     classid = OPP_GRbcsubbc_class_id ,
			    osnum   = EdgeCurve->osnum	,
			    p_objid = &(EdgeCurve->objid) ,
		      );
    
    sts = om$send( msg      =	message GRgraphics.GRconstruct( VgCnst ),
		                senderid = NULL_OBJID,
		                targetid = EdgeCurve->objid,
		                targetos = EdgeCurve->osnum  );
    VgCnst->geometry = NULL ;
    __CheckRC( sts, *(VgCnst->msg) , "construct&place edge curv", wrapup );
    
  } // if more than one point on surface 
  
  // Done
  retFlag = TRUE;
 wrapup:
  for(i=0;i<numEdges;i++)
    if(edgeCurves[i] != NULL) _FREE(edgeCurves[i]);
  if(numInters > 0)
    vs$bulk_delete( count   = numInters,
                    grids   = deleteList,
                    theEnv  = &edgeOE.mod_env) ;
  vs$bulk_delete( count   = 1,
		  grids   = &edgeID,
		  theEnv  = &edgeOE.mod_env) ;
  _FREE(inters); inters = NULL;
  _FREE(deleteList); deleteList = NULL;
  _FREE(part); _FREE(paruv);
  _FREE(cpt); _FREE(sfpt);
  _FREE(min_dist_count);   
  return retFlag ;
  
} // end VLClosestEdge to surf

/*
 *  This function checks plate side on which the mark lies for manual marking
 */
IGRint VLmanualCheckPlSide(
                           struct GRobj_env *curveObj, //IN
			   struct GRobj_env *plateObj, //IN
			   GRobjid           myID,     //IN
			   int              *TypeSide  //OUT
			   )
{
  IGRint                retFlag = 0,sts = OM_E_INVARG;
  IGRdouble             tol = 0.1,dist_base = 100.0 ;
  IGRlong               msg;
  struct IGRbsp_curve   *curveBsp = NULL;
  struct IGRbsp_surface *baseSrfGeom = NULL,*offSrfGeom = NULL;
  struct GRid           colID,markID;
  struct GRobj_env      baseOE,offsetOE;
  struct ACrg_coll      lstAtts[2];
  int                   numAtt;
  IGRdouble             *part =NULL, *paruv = NULL;
  IGRdouble             dist_offset = 100.0; 
  IGRpoint              *cpt =NULL, *sfpt =NULL;
  BSrc 		        rc;
  
  colID.objid           = NULL_OBJID;
  baseOE.obj_id.objid   = NULL_OBJID;
  offsetOE.obj_id.objid = NULL_OBJID;
  
  markID.objid = myID;
  markID.osnum = OM_Gw_current_OS;
  
  // Get the collector info
  vdchn$Get2(objID  = &markID,
             chnIDx = VDCHN_IDX_PARENT,
             nth    = 0,
             outID  = &colID );
  if(colID.objid == NULL_OBJID) goto wrapup;
  
  numAtt = 0;
  sts = om$send(msg = message
		ACrg_collect.AClist_attribute(&msg,
					      1,
					      lstAtts,
					      &numAtt),
		senderid = NULL_OBJID,
		targetid = colID.objid,
		targetos = colID.osnum);
  
  if (numAtt != 2) goto wrapup;
  if(!(sts&msg&1)) goto wrapup;
  // Get the mark geometry 
  
  vdgeom$Get2(objOE = curveObj, crv = &curveBsp);
  if (curveBsp == NULL) goto wrapup;
  
  // get the plate surfaces and their geometry
  
  vdobj$GetFoot(objOE = plateObj, footName = VS_K_plBotSfPath, footOE = &baseOE);
  if (baseOE.obj_id.objid == NULL_OBJID) goto wrapup;

  vdobj$GetFoot(objOE = plateObj, footName = VS_K_plTopSfPath, footOE = &offsetOE);
  if (offsetOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  vdgeom$Get2(objOE = &baseOE, srf = &baseSrfGeom);
  if (baseSrfGeom == NULL) goto wrapup;

  vdgeom$Get2(objOE = &offsetOE, srf = &offSrfGeom);
  if (offSrfGeom == NULL) goto wrapup;
  
  //check the closest plate surface to the marking
  BSmdistcvsf(curveBsp,baseSrfGeom,&numAtt,&part,&paruv,&cpt,&sfpt,&dist_base,&rc);
  if(BSSUCC != rc ) goto wrapup;

  BSmdistcvsf(curveBsp,offSrfGeom,&numAtt,&part,&paruv,&cpt,&sfpt,&dist_offset,&rc);
  if(BSSUCC != rc ) goto wrapup;
  
  __DBGpr_dbl("DistBase : ",dist_base);
  __DBGpr_dbl("DistOffset : ",dist_offset);
  
  if((dist_base>tol) && (dist_offset>tol)) goto wrapup;

  if(((dist_base<tol) && (*TypeSide == 0)) || 
     ((dist_offset<tol) && (*TypeSide == 1)))
  {
    retFlag = 1; // attribute information proper
    goto wrapup;
  }
  
  // modify the parent attribute information for the marking line
  // Flip side
  if (lstAtts[0].desc.value.att_exp < .5) lstAtts[0].desc.value.att_exp = 1.0;
  else                                    lstAtts[0].desc.value.att_exp = 0.0;
  
  if(*TypeSide==0) *TypeSide = 1;
  else             *TypeSide = 0; 
  // Update
  sts = om$send(msg = message
		ACrg_collect.ACmod_list_attribute(&msg,
						  1,
						  lstAtts),
		senderid = NULL_OBJID,
		targetid = colID.objid,
		targetos = colID.osnum);
  if(!(sts&msg&1)) goto wrapup;
  //Done
  retFlag = 1;
 wrapup:
  __DBGpr_int("retFlag of VLmanualCheckPlSide : %d ",retFlag);
  _FREE(curveBsp); curveBsp = NULL;
  _FREE(baseSrfGeom); baseSrfGeom = NULL;
  _FREE(offSrfGeom);  offSrfGeom = NULL;
  _FREE(part); part = NULL;
  _FREE(paruv); paruv = NULL;
  _FREE(cpt);   cpt = NULL;
  _FREE(sfpt);  sfpt= NULL;
  
  return retFlag;
}
/*
 * ===========================================================================
 * Actual method used by associative system to build and display results
 * of this object.
 * ===========================================================================
 */
method ACconstruct_feet (               
                         IGRlong         *ret;
                         IGRint          cn_type;
                         IGRint          count;
			 struct GRid     list[];
			 struct GRmd_env *md_env;
                         IGRint          *fcount;
			 struct GRid     *feet_list 
                        )
  
{
  
  OMuword		PlateObjClass,		// plate+located obj classid
                        StiffObjClass; 		// stiffener+   obj classid
  
  IGRlong		msg	=	MSFAIL,	// return code in method
                        SideMsg = 	MSFAIL;	// temporary rc for forward
  
  IGRpoint		PtOnSurf  ; 		//pt on sf closest to midpt
  
  IGRint		sts	=   OM_E_INVARG,// return code	for message
                        stat	=   OM_E_INVARG,// return code	for message
                        NumInter = 0,		// number of inters curves
                        NumMarks  = 1,		// number of mark curves
                        num_att,ret_type = FALSE;// number attribs in rg
  
  int			i, TypeSide,		// Which side of plate
                        IntsTypeSide,		// Which side of stiff/plate
                        posn,kk;		// position in collection
  
  struct GRid 		boiteObj,		// context for rg_colln obj
                        Marks[VLMrkNumFeet],	// marks + Offset  
                        MainIso,		// the full iso curve
                        Offset ;		// the full offset curve
  
  struct GRobj_env	stiffObj,		// context for stiffner obj
                        plateObj,		// context for the plate obj
                        curveObj[VLMrkMaxNumTemplates],
                        PlateSideObj,		// the surf of plate obj
                        StiffSideObj,		// the surf of stiff obj
                        StiffSideExtObj[2],	// the extend surfs of stiff obj
                        IsoObj ,		// first iso curve of stf beam
                        OffseSideObj;		//the surf of stiff offset obj
  
  //struct ACrg_coll	list_att[ VLMrkMinAtt]; // input from rg collection
  struct ACrg_coll	list_att[4]; // Output all 4 attributes
  
  struct GRvg_construct	vg_cnst;         	// construction list
  
  struct GRid		Curves[2];
  
  struct GRlc_info      lcStiff,		//stiffener surface to intersect
                        lcPlate ;		//plate surface to intersect
  
  IGRboolean		TrimReq	   = TRUE,	// Are the curves trimmed
                        StiffIsPlate = FALSE;	// stiff to plate line
  
  
  struct IGRbsp_surface	* PlateSrfGeom	= NULL, // plate surf's geometry
                        * StiffSideExtGeom[2] ; //ext geom of stiff plates sides
  
  IGRvector	        OffsetDir ;		// dirn from main to offset crv
  
  BSrc			bsrc	= BSFAIL;	// BS's return code
  
  unsigned short      	PropMask = 0 ;		// which properties to set for
  //the virtual line
  IGRshort		action  = 0 ;		// what to do to the properties
  IGRboolean            markFlag = FALSE, parseFlag = FALSE, pr_error=FALSE;       
  IGRboolean            OffsetDirFlag = FALSE;       
  IGRlong 		sts1;
  IGRchar               debugfile[50],plateName[50];
  IGRchar               platePcmk[100], beamPcmk[100];
  IGRlong               isConsumed;
  IGRdouble             extValue = 1.0, point[3];
  VSpartAttr            PltAttr ;
  VSplateAttr           PltInfo ;
  struct IGRbsp_curve   *full_curve = NULL;
  struct GRid           myGRid; 

  SetProc ( MrkCnstFeet ); 
  
  if ( !ret || !md_env || !list || !fcount || !feet_list ) {
    __DBGpr_int( " Problem with arguments ret ", ret );
    __DBGpr_int( " Problem with arguments md_env ", md_env );
    __DBGpr_int( " Problem with arguments list ", list );
    __DBGpr_int( " Problem with arguments fcount ", fcount );
    __DBGpr_int( " Problem with arguments feet_list ", feet_list );
    goto wrapup;
  }
  myGRid.objid               =  my_id;
  myGRid.osnum               =  OM_Gw_current_OS;

  surfOE.obj_id.objid        =  NULL_OBJID; //TR179900910
  *ret			     =	MSFAIL;
  PlateSideObj.mod_env	     =	*md_env;
  StiffSideObj.mod_env	     =	*md_env;
  OffseSideObj.mod_env	     =	*md_env;
  *fcount		     =	2;
  lcStiff.located_obj.objid  =	NULL_OBJID;
  Offset.objid		     =	NULL_OBJID ;
  MainIso.objid		     =	NULL_OBJID ;
  StiffSideExtGeom[0]        =  NULL;
  StiffSideExtGeom[1]        =  NULL ;
  StiffSideExtObj [0]._objid =  NULL_OBJID ;
  StiffSideExtObj [1]._objid =  NULL_OBJID ;
  
  feet_list[VLFulLinIndex].objid =	NULL_OBJID; // should be a curve
  feet_list[VLMrkParIndex].objid =	NULL_OBJID; //should be an ACrg_coll
    
  for ( posn=0 ; posn<  VLMrkNumFeet ; ++ posn ) {
    Marks[posn].objid = NULL_OBJID;
    Marks[posn].osnum =  md_env->md_id.osnum;
  }
  
  VLinitCnst( &vg_cnst );
  
  boiteObj              = list[0];      // box of parameters
  plateObj.obj_id       = list[1];      // the plate to be marked
  stiffObj.obj_id       = list[2];      // object defining the mark:
  // normally a stiffener, but sometimes
  // a beam
  
  __DBGpr_obj( "Mark got ACrg_collect object id ",  boiteObj );
  
  __DBGpr_int("Input Count for ACconstruct_feet ", count );
  
  //c  get objects class, if pretend find underlying object
  
  sts = VLGetObjAndClass(	&msg,
				&plateObj ,
				md_env ,
				&PlateObjClass ) ;
  __CheckRC( sts, msg, "Get obj and class", wrapup ) ;
  __DBGpr_obj( "Mark got plate object id ",  plateObj.obj_id );
    
  // should have the plate to be marked, by now in plateObj
  // same methodology for the stiffening object
  
  sts = VLGetObjAndClass(	&msg,
				&stiffObj ,
				md_env ,
				&StiffObjClass ) ;
  __CheckRC( sts, msg, "Get stiff obj and class", wrapup ) ;
  __DBGpr_obj( "Mark got stiff object id ",  stiffObj.obj_id );
  
  // avoid collar plates from marking
  plateName[0] = 0;
  sts = VLGetShortName(	&stiffObj ,
			md_env ,
			plateName);
  CheckRC( sts, 1 );
  
  sts = om$send(  msg     = message NDmacro.ACtest_consumed( &isConsumed),
		  senderid = NULL_OBJID,
		  targetid = stiffObj.obj_id.objid,
		  targetos = stiffObj.obj_id.osnum );
  
  __CheckRC( sts, 1, "NDmacro.ACtest_consumed", wrapup ) ;

  /************ This has been commented for TR4572 **************
  if( om$is_ancestry_valid( superclassid = OPP_VSplate_class_id,
			    subclassid   = StiffObjClass ) == OM_S_SUCCESS )
  {
    IGRchar           footName[DI_PATH_MAX];
    struct GRid       par_surf;
    
    if(!(isConsumed & 1)&&(plateName[0] == 'c')&&(plateName[1] == 'o')) 
    {
      // this is a collar source plate - donot generate marking line
      sts = OM_W_ABORT;
      goto wrapup;
    }             
    vdobj$GetParent(  objID    = &stiffObj.obj_id,
		      idx        = 0,
		      parentID   = &par_surf );
    if( ( VSgetOperName( &par_surf, "~~post_placement",
			 footName) &1 ) )  
    { 
      sts = OM_W_ABORT; goto wrapup; 
    }
  }
  ************ This has been commented for TR4572 **************/
  
  sts = om$send(msg = message ACrg_collect.AClist_attribute( 
                                           &msg,
					   VLMrkMinAtt,
					   list_att,
					   &num_att ),
		targetid = list[ VLMrkCollIndex].objid,
		targetos = list[ VLMrkCollIndex].osnum);
  
  __CheckRC( sts, msg, "Mark: ACrg_collect.AClist_attribute", wrapup ) ;
  __DBGpr_int( "ACrg_collect gave attributes",  num_att );
  if ( num_att <  VLMrkMinAtt ) goto wrapup;
  
  // find which side is the mark and which is the offset
  
  if ( (posn = VLseekFields( list_att, num_att,  VLTypeSide) ) != -1 ) 
    TypeSide = list_att[TypeSideIndex].desc.value.att_exp;
  else {  __DBGpr_str( "Couldn't find attribute ",  VLTypeSide); goto wrapup;}
  
  if ( (posn = VLseekFields( list_att, num_att,  VLIntsTypeSide) ) != -1 ) 
    IntsTypeSide = list_att[TypeIntsSideIndex].desc.value.att_exp;
  else {__DBGpr_str( "Couldn't find attribute ",  VLIntsTypeSide); goto wrapup;}
  
  __DBGpr_obj( "Mark got plate object id ",  plateObj.obj_id );
  if( count > 3 )
  {
    __DBGpr_objlist("Curve Template", count-3, &list[3] );
    for( i=3; i<count; ++i )
    {
      sts = om$send(msg = message NDmacro.ACreturn_foot(
				    &msg, "", &curveObj[i-3].obj_id,
				    &curveObj[i-3]._matrix_type,
				    curveObj[i-3]._matrix           ),
		    targetid = list[i].objid,
		    targetos = list[i].osnum  );
      __CheckRC( sts, msg, "NDmacro.ACreturn_foot", wrapup );
      __DBGpr_obj( " Original Curve in model ", curveObj[i-3].obj_id );
      curveObj[i-3]._md_os = curveObj[i-3]._osnum;
      ex$get_modid(   mod_osnum = curveObj[i-3]._md_os,
		      mod_id    = &curveObj[i-3]._md_id ) ;
    }
    
    sts = vs$grCopy(	msg     = &msg,
			frEnv   = &curveObj[0].mod_env,
                        frObj   = &curveObj[0]._grid,
                        toEnv   = md_env,
                        toObj   = &feet_list[VLFulLinIndex] ) ;
    __CheckRC( sts, msg, "vs$grCopy", wrapup );
    ret_type = VLmanualCheckPlSide(&curveObj[0],&plateObj,my_id,&TypeSide);
    
    if(!(ret_type&1)){
      printf("\n failed compute plateSide for manual mark on plate[%d,%d] \n",
                 plateObj.obj_id.objid,plateObj.obj_id.osnum);
    }
    
    PropMask = GRIS_DISPLAYABLE | GRIS_LOCATABLE    ;
    action   = 0 ;  // unset the properties
    sts = gr$put_properties( object_id = &feet_list[VLFulLinIndex] ,
			     action    = action ,
			     properties_mask = PropMask ) ;
    
    for( i=0; i<count-4; ++i )
    {
      __DBGpr_obj("Copying the curve to foot", curveObj[i]._grid );
      sts = vs$grCopy(msg     = &msg,
		      frEnv   = &curveObj[i+1].mod_env,
		      frObj   = &curveObj[i+1]._grid,
		      toEnv   = md_env,
		      toObj   = &feet_list[(*fcount)] ) ;
      __CheckRC( sts, msg, "vs$grCopy", wrapup );
      (*fcount)++;
    }
    
    sts = vs$grCopy( msg     = &msg,
		     frEnv   = &curveObj[0].mod_env,
		     frObj   = &curveObj[0]._grid,
		     toEnv   = md_env,
		     toObj   = &feet_list[(*fcount)] ) ;
    __CheckRC( sts, msg, "vs$grCopy", wrapup );
    (*fcount)++;
    goto get_attr;
  }
  
  if( om$is_ancestry_valid( superclassid  = OPP_VSbeam_class_id,
			    subclassid = StiffObjClass ) == OM_S_SUCCESS ){
    
    int StiffSide	= VS_K_stOnBotOfPlate ;	// side of plate beam is really
    
    /********************* Code addition for TR179900777 begins *******************/
    {
      long            status1;
      GRspacenum      cur_osnum;
      OM_S_OBJID      cur_objid;
      IGRchar         file_name[DI_PATH_MAX],
	              exp_name[DI_PATH_MAX],
	              cur_dir[DI_PATH_MAX];
      struct GRid     exp_obj;
      
      ex$get_cur_mod( id = &cur_objid, osnum = &cur_osnum );
      
      VDSget_filename(file_name);
      di$pwd(dirname = cur_dir);
      
      strcat( file_name, ":IGENOD" );
      sprintf(exp_name, "%s:MarkingOption", file_name );
      
      di$cd(dirname = file_name);
      status1 = di$translate(  objname = exp_name,
			       osnum   = cur_osnum,
			       p_objid = &exp_obj.objid);
      if( status1 == DIR_S_SUCCESS)
      {
	IGRdouble mrk_opt;
	sts = om$send ( msg = message expression.NDgive_value (&mrk_opt),
			targetid = exp_obj.objid,
			targetos = cur_osnum );
	if( mrk_opt == 1.0 ) markFlag = TRUE; 
      }
      di$cd(dirname = cur_dir);
    }
    /********************* Code addition for TR179900777 ends *********************/
    
    // check the flag here for marking with left web of the stiffener 
    
    if(!markFlag) goto default_implementation; // for TR179900777
    
    // get isomeric curves of stiffener used to mark the plate
    sts = VLGetBeamIsos(	&stiffObj ,
				md_env ,
				&vg_cnst ,
				IntsTypeSide ,
				Marks  ,       // list of isos
				&NumMarks      // num of isos
				) ;
    __CheckRC( sts, 1, "VLGetBeamIsos", wrapup ) ;
    
    __DBGpr_objlist( "after get isos marks list", 5, Marks ) ;
    __DBGpr_int( "Got this many isos", NumMarks ) ;
    
    Offset = Marks[NumMarks-1] ;    
    MainIso= Marks[0] ;    	// need to delete at the end
    
    /*
     * this is a workaround because in certain cases the stiffener
     * is unable (doesn't want) to say which side of the plate it is
     * i.e., reply to the message VSgetPlateSide
     */
    
    IsoObj.obj_id = Marks[0] ;
    IsoObj.mod_env= *md_env ;
    
    default_implementation :   // for TR179900777
      sts = om$send( msg = message VSstfBeam.VSgetPlateSide( 	&SideMsg,
								&StiffSide ),
		     targetid = stiffObj.obj_id.objid,
		     targetos = stiffObj.obj_id.osnum );
    if( !(sts&SideMsg&1) && !markFlag)             // for TR179900777
    {
      StiffSide = VLgetPlateSide(&stiffObj,&plateObj.obj_id);
    }
    if( !(sts&SideMsg&1) && markFlag )// for TR179900777  
    {	
	sts = VLCheckSide(	&SideMsg, 	// return code
				&plateObj, 	// the plate to check
				&IsoObj ,	// curve to check proximity
				&StiffSide,	//the side on which it's
				PtOnSurf ) ; 	//pt on sf closest to midpt
    }
    CheckRC( sts, SideMsg ) ;
    
    /********************* Code addition for TR179900777 begins *******************/
    if(markFlag == FALSE)
    {
      IGRboolean ret= FALSE;
      ret = VLGetWebProj(&stiffObj,&plateObj,md_env,&vg_cnst,StiffSide,Marks,&NumMarks);
      if(!ret) goto wrapup;
      Offset = Marks[NumMarks-1] ;    
      MainIso= Marks[0] ;      // need to delete at the end
    }
    /********************* Code addition for TR179900777 ends *********************/
    // if stiffener on different side, change side to its
    if ( StiffSide != TypeSide ) {
      
      __DBGpr_int( "TypeSide is diff to actual side,change frm", TypeSide);
      
      // change gobal
      TypeSide = StiffSide ;
      
      // change value in collection
      list_att[TypeSideIndex].desc.value.att_exp	= StiffSide ;
      
      sts = om$send(msg = message ACrg_collect.ACmod_list_attribute( 
                                               &msg,
					       (IGRint) 1,
					       &list_att[TypeSideIndex] ),
		    senderid = NULL_OBJID,
		    targetid = list[ VLMrkCollIndex].objid ,
		    targetos = list[ VLMrkCollIndex].osnum);
      
      __CheckRC( sts, msg, "Mark: ACrg_col.ACmod_list_attrib", wrapup );
      
    }  // if stiffener is not on the side the mark is supposed to appear
    
  }    // end if stiffener
  // have the plate object, now get the side where the stiff is
  
  if( om$is_ancestry_valid( superclassid   = OPP_VSplate_class_id,
			    subclassid	   = PlateObjClass ) == OM_S_SUCCESS ){
    char * sidename;
    // Get side of plate.
    
    if( TypeSide == VS_K_baOnTopOfPlate ) 
      sidename        = VS_K_plTopSfPath ;
    else
      sidename        = VS_K_plBotSfPath ;
    
    __DBGpr_str( "Plate Type of side wanted", sidename ) ;
    
    sts = om$send( msg = message NDmacro.ACreturn_foot(
					 &msg,
					 sidename,
					 &PlateSideObj.obj_id,
					 &PlateSideObj._matrix_type,
					 PlateSideObj._matrix ),
		   senderid = NULL_OBJID,
		   targetid = plateObj._objid,
		   targetos = plateObj._osnum ) ;
    
    __CheckRC( sts, msg, "Mark: Plate NDmacro.ACreturn_foot", wrapup ) ;
    __DBGpr_obj( "Mark: got plateSide object id ",  PlateSideObj.obj_id );
    
    PlateSideObj._md_os = PlateSideObj.obj_id.osnum ;
    
    ex$get_modid(	mod_osnum = PlateSideObj.obj_id.osnum ,
			mod_id	= &(PlateSideObj._md_id) ) ;
    
    
    if ( !PlateSrfGeom ) 
    {
      surfOE.obj_id  = PlateSideObj.obj_id;
      surfOE.mod_env  = PlateSideObj.mod_env;
      vs$get_geometry( msg    = &msg,
		       grobjId = &PlateSideObj.obj_id,
		       grobjEnv= &PlateSideObj.mod_env,
		       geometry= &PlateSrfGeom );
      
      __CheckRC( 1, msg, "get geom on located surface", wrapup);
#ifdef DEBUG
      strcpy(debugfile,"plate_surface.txt");
      sts1 = VDdumpSurface(NULL,PlateSrfGeom,debugfile);
#endif
    }
  }  // end if plate 
  
  else { __DBGpr_com( "2nd obj not a plate !!!"); sts=OM_E_ABORT; goto wrapup; }
  
  if( om$is_ancestry_valid( superclassid  = OPP_VSplate_class_id,
			    subclassid    = StiffObjClass ) == OM_S_SUCCESS )
  {
    
    char        * SideNames[2];		   // side of plate to use
    int		ii              = 0 ,
                NumOffsetCurves = 0 ;
    struct GRobj_env 
                * StiffSidePtr  = NULL ;   // ditto
    long	lsts            = MSFAIL ; // status return for VSforward
    
    
    StiffIsPlate = TRUE ;  // stiff is a plate, non?
    
    // Get side of intersecting plate.
  parse0:
    if( IntsTypeSide == VS_K_baOnTopOfPlate ) {
      SideNames[0]        = VS_K_plTopSfPath ;
      SideNames[1]        = VS_K_plBotSfPath ;
    }
    else {
      SideNames[0]        = VS_K_plBotSfPath ;
      SideNames[1]        = VS_K_plTopSfPath ;
    }
    
    StiffSidePtr	=	&StiffSideObj ;
    if(parseFlag) goto parse1;
    // should have the stiffener by now in stiffObj,
    //	so require geom of the plate to mark
    
    for ( ii=0 ; ii<2 ; ++ii ) {   // for mark then offset side of plate
      
      __DBGpr_str( "Stiff getting side ", SideNames[ii] ) ;
      parse1 :
	if(parseFlag) ii = 0;
      sts = om$send( msg = message VSfeature.VSforwardToSource 
                                   ( 
                                       &lsts ,
				       OM_e_wrt_object ,
				       message NDmacro.ACreturn_foot
                                                     (
						       &msg,
						       SideNames[ii],
						       &(StiffSidePtr->obj_id),
						       &(StiffSidePtr->_matrix_type),
						       StiffSidePtr->_matrix 
                                                     ) 
				    ), 
		     senderid = NULL_OBJID,
		     targetid = stiffObj._objid,
		     targetos = stiffObj._osnum ) ;
      
      __CheckRC( lsts, 1, "Mark: forward to source of plate", wrapup ) ;
      __CheckRC( sts, msg, "Mark: surface of 2nd plate ", wrapup ) ;
      
      StiffSidePtr->mod_env = stiffObj.mod_env;
      if(parseFlag) goto parse2;

      // find an edge on the base plate
      if (  VLClosestEdgeToSrf (	&msg ,
					0.01  ,
					StiffSidePtr ,
					PlateSrfGeom ,
					&vg_cnst ,
					(ii) ? &Offset : &MainIso ) ) {
	__DBGpr_obj( "MainIso", MainIso ) ;
	__DBGpr_obj( "Offset Iso", Offset ) ;
      }
      else {  // no edge on base plate, so intersect the surfs
	
	__DBGpr_com( "no Edge  close to surface" ) ;
	// this is a VDS fn to extend the surf by a given factor
	// to try to avoid problems of tanjency
      parse2:
	{
	  // get the plate thickness - TR179901476
	  PltAttr.Iwant    = VS_m_Thickness;
	  PltAttr.specific = (void *) &PltInfo ;
	  sts1 = om$send(  msg    = message GRvg.GRgetattr( &msg,
							    (char *) &PltAttr),
			   senderid = NULL_OBJID,
			   targetid = plateObj.obj_id.objid,
			   targetos = plateObj.obj_id.osnum );
	  if(!(sts1&msg&1))
	  {
	    printf("\n failed to get the thickness for plate[%d,%d] \n",plateObj.obj_id.objid,plateObj.obj_id.osnum);
	    //continue the process with an extension value of 1.0
	    //goto wrapup;
	  }
	  else extValue = 3*(PltInfo.thickness);	
	}
	sts = get_extsurf_geom( 
	                       &(StiffSidePtr->obj_id),
			       &(StiffSidePtr->mod_env),
			       extValue,
			       &(StiffSideExtGeom[ii]) );
	__CheckRC( sts, 1, "get ext geom of plate side", wrapup);
#ifdef DEBUG
	if(ii==0) strcpy(debugfile,"stiff_base.txt");
	if(ii==1) strcpy(debugfile,"stiff_offset.txt");
	sts1 = VDdumpSurface(NULL,StiffSideExtGeom[ii],debugfile);
#endif
	StiffIsPlate = TRUE ;		// stiff is a plate, non?
	
	vg_cnst. geometry  = (char *)StiffSideExtGeom[ii] ;// offset
	*(vg_cnst. msg)	   = OM_S_SUCCESS ;
	
	StiffSideExtObj[ii]._objid = NULL_OBJID;
	StiffSideExtObj[ii]._osnum = md_env->md_id.osnum;
	
	// got the extend geom, build the srf
	sts = om$construct(     classid = OPP_EMSgenbs_class_id ,
				osnum   = StiffSideExtObj[ii]._osnum ,
				p_objid = &(StiffSideExtObj[ii]._objid) ,
				
				msg  = message GRgraphics.GRconstruct( &vg_cnst ),
				);
	
	__CheckRC( sts, *(vg_cnst.msg),"construct&place extsurf", wrapup );
	__DBGpr_obj( "Mrk: extended side surf", StiffSideExtObj[ii].obj_id);
	
	vg_cnst. geometry       =       NULL;
	if(parseFlag) goto parse3;
      }	// if edges are not on base plate 
      
    }	// for each side of stiffening plate
    
    // no offset object means no edge on the base plate so intersect
    
    if ( Offset.objid == NULL_OBJID ) {
      // intersect offset side of stiffening plate with base plate
      // in order to get a basis for the offset marker
      
      lcPlate .located_obj	= 	PlateSideObj.obj_id ;
      lcPlate .module_info	= 	PlateSideObj.mod_env ;
      lcStiff.located_obj	= 	StiffSideExtObj[1].obj_id ;
      lcStiff.module_info	= 	*md_env;
      lcStiff.module_info._MD_OS	=	StiffSideExtObj[1].obj_id.osnum ;
      
      ex$get_modid(	mod_osnum = StiffSideExtObj[1].obj_id.osnum ,
 			mod_id	= &lcStiff.module_info._MD_ID ) ;
      
      //TrimReq = FALSE ;
      
      // VDS fn to intersect two surfaces (elements)
      sts = IntTwoSrf(	TrimReq ,
			FALSE ,
			&lcPlate ,
			&lcStiff ,
			&vg_cnst ,
			&NumOffsetCurves ,
			Marks ,
			&msg ) ;
      
      __CheckRC( sts, msg, "VLIntTwoSrfs", wrapup ) ;
      __DBGpr_int( "intersect stiff ext offset gives #curves", NumOffsetCurves );
      
      Offset = Marks[0] ;		// just use 1st crv as offset marker
      // delete the rest
      
      for ( ii=1; ii<NumOffsetCurves ; ++ii ){
	
	if (   Marks[ii].objid != NULL_OBJID ) {
	  __DBGpr_obj( "deleting offset", Marks[ii] ) ;
	  stat= om$send(msg  = message GRgraphics.GRdelete( &msg,
							    md_env ),
			targetid =   Marks[ii].objid,
			targetos =   Marks[ii].osnum  );
	  CheckRC( stat, msg );
	  Marks[ii].objid = NULL_OBJID ;
	}
      }
    } // if no offset found
    
    if ( MainIso.objid == NULL_OBJID ) 
    {
      //extened side will be used for intersection
    parse3:
      if(StiffSideExtObj[0]._objid != NULL_OBJID)
      {
	StiffSideObj = StiffSideExtObj[0] ;
      }
      else goto wrapup;	
      
    } // if no edge found
    else {
      struct GRid	Curves[2];
      
      Curves[0] = MainIso ;    // main
      Curves[1] = Offset  ;    // offset 
      
      // build a skinning surface along the iso curves of 
      // srf of the beam closest to the plate
      
      sts = VLCreateFlatSkin( &msg ,
			      Curves ,
			      md_env ,
			      &vg_cnst ,
			      OffsetDir ,
			      &(StiffSideObj.obj_id) ) ;
      
      __CheckRC( sts, msg, "VLCreateFlatSkin", wrapup ) ;
      __DBGpr_obj( "plate:plate skin", StiffSideObj.obj_id ) ;
      __DBGpr_vec( "OffsetDir", OffsetDir) ;
      
      OffsetDirFlag = TRUE; 
    }  // else offset edge on surface found, build skin for intersection
    
  }   // if stiffener is a plate
  else if (!StiffIsPlate) {
    struct GRid	Curves[2];
    {
      long             nb_res = 0;
      struct GRlc_info curv_info,surf_info;
      OM_S_OBJID       *obj_id = NULL;
      
      curv_info.located_obj = Marks[0];
      curv_info.module_info = *md_env;
      
      surf_info.located_obj = PlateSideObj.obj_id;
      surf_info.module_info = PlateSideObj.mod_env;
      
      sts = om$send(msg=message
		    EMSsubbs.EMproject_curve_along_surface_normals(
			     &curv_info,
			     &surf_info,
			     &vg_cnst,
			     FALSE,
			     TRUE,
			     &nb_res,
			     &obj_id,
			     &msg),
                    senderid = NULL_OBJID,
                    targetid = surf_info.located_obj.objid,
                    targetos = surf_info.located_obj.osnum);
      __CheckRC( sts, msg, "EMproject_curve_along_surface_normals", wrapup );
      
      if( !nb_res ) 
      {
	sts = OM_E_ABORT; 
	goto wrapup;
      }
      NumMarks = (IGRint) nb_res;
      
      for( i=0; i<NumMarks; ++i )
	Marks[i].objid = obj_id[i];
      
      _FREE( obj_id );
      
      Curves[0] = MainIso ;  // main
      Curves[1] = Offset  ;  // offset 
      
      sts = VLCreateFlatSkin( &msg ,
			      Curves ,
			      md_env ,
			      &vg_cnst ,
			      OffsetDir ,
			      NULL		);
      __CheckRC( sts, msg, "VLCreateFlatSkin", wrapup ) ;
      __DBGpr_vec( "OffsetDir", OffsetDir) ;
      
      goto place_line;
    }
    
    Curves[0] = Marks[0] ;		// main
    Curves[1] = Marks[NumMarks-1] ;	// offset 
    
    // build a skinning surface along the iso curves of 
    // srf of the beam closest to the plate
    sts = VLCreateFlatSkin( &msg ,
			    Curves ,
			    md_env ,
			    &vg_cnst ,
			    OffsetDir ,
			    &(StiffSideObj.obj_id) ) ;
    
    __CheckRC( sts, msg, "VLCreateFlatSkin", wrapup ) ;
    __DBGpr_vec( "OffsetDir", OffsetDir) ;
  } //if stiffener is beam
  else 
  { 
    __DBGpr_com( "Stiffener Not a plate" ); 
  }
  
  lcPlate .located_obj	        =  PlateSideObj.obj_id ;
  lcPlate .module_info	        =  PlateSideObj.mod_env ;
  lcStiff.located_obj	        =  StiffSideObj.obj_id ;
  lcStiff.module_info	        =  *md_env;
  lcStiff.module_info._MD_OS	=  StiffSideObj.obj_id.osnum ;
  
  ex$get_modid(	mod_osnum = StiffSideObj.obj_id.osnum ,
		mod_id	  = &lcStiff.module_info._MD_ID ) ;
  
  // VDS fn to intersect two surfaces (elements)
  sts = IntTwoSrf(	TrimReq ,
			FALSE ,
			&lcPlate ,
			&lcStiff ,
			&vg_cnst ,
			&NumMarks ,
			Marks ,
			&msg ) ;
  if( !(sts&msg&1) )
  {
    sts = IntTwoSrf( TrimReq ,
		     FALSE ,
		     &lcStiff ,
		     &lcPlate ,
		     &vg_cnst ,
		     &NumMarks ,
		     Marks ,
		     &msg ) ;
    // __CheckRC( sts, msg, "VLIntTwoSrf", wrapup ) ;
    // Modification for TR179900910 begin
    if((!(sts&msg&1)) && (!parseFlag))
    {
      parseFlag = TRUE;
      // delete the already created flatskin surface
      if(lcStiff.located_obj .objid != NULL_OBJID)
      {
	stat = om$send(msg  = message GRgraphics.GRdelete( &msg, md_env ),
		       targetid =   lcStiff.located_obj .objid,
		       targetos =   lcStiff.located_obj .osnum);
	CheckRC( stat, msg );
      }
      goto parse0;
    }
    else if(!(sts&msg&1)) goto wrapup;
    // Modification for TR179900910 end
  }
  // unwanted graphics messing up with SPADES - begin
  for ( kk=1; kk<NumMarks ; ++kk ){
    
    if (   Marks[kk].objid != NULL_OBJID ) {
      __DBGpr_obj( "deleting offset", Marks[kk] ) ;
      stat= om$send(msg  = message GRgraphics.GRdelete( &msg,
							md_env ),
		    targetid =   Marks[kk].objid,
		    targetos =   Marks[kk].osnum  );
      CheckRC( stat, msg );
      Marks[kk].objid = NULL_OBJID ;
    }
  }
  NumMarks = 1;
  // unwanted graphics messing up with SPADES - end
  
  __DBGpr_int( "num int curves", NumMarks ) ;
  
 place_line:
  // need a copy of main mark for gen lines
  if(StiffIsPlate && !OffsetDirFlag){
    struct GRid       Curves[2],tempID;
    
    Curves[0] = Marks[0] ;  // main
    Curves[1] = Offset  ;   // offset
    
    // build a skinning surface along the iso curves of
    // srf of the beam closest to the plate
    // this is done for the offsetdir if it is not available  
    
    sts = VLCreateFlatSkin( &msg ,
			    Curves ,
			    md_env ,
			    &vg_cnst ,
			    OffsetDir ,
			    &tempID) ;
    
    __CheckRC( sts, msg, "VLCreateFlatSkin", wrapup ) ;
    __DBGpr_obj( "plate:plate skin", StiffSideObj.obj_id ) ;
    __DBGpr_vec( "OffsetDir", OffsetDir) ;
    // delete the flat skin surface
    vs$bulk_delete( count   = 1,
		    grids   = &tempID,
		    theEnv  = md_env) ;
  } 
  // Place dummy point at mid_point of fullLine - CR#MP 5085

  point[0] = point[1] = point[2] = 0.0 ;
  sts = vs$grCopy(	msg     = &msg,
			frEnv   = md_env,
                        frObj   = &Marks[0],
                        toEnv   = md_env,
                        toObj   = &feet_list[VLFulLinIndex] ) ;
  __CheckRC( sts, msg, "vs$grCopy", wrapup );
  /*
   * Get the geometry data for the curve
   */
  sts = vd_$get_geometry ( msg      =  &msg,
                           grobjId  = &feet_list[VLFulLinIndex],
                           grobjEnv = md_env,
                           geometry = &full_curve );
  if(!(sts&msg&1) || (full_curve == NULL))
  {
    __DBGpr_obj(" FAILED to get geometry of FullLine for ", myGRid);
    __DBGpr_com(" Dummy points will be placed at [0,0,0] if any ");
  }
  else
  {
    BScveval(full_curve,0.5,0,(IGRpoint *)point,&msg);
  }  
  __DBGpr_vec("mid_point of FullLine ", point);
  /*
   *
   * TR# MP3378 FullLine should be copy of main mark
     sts = VLPlaceFullLine (
                            &vg_cnst ,
                            NumMarks ,
                            Marks ,
                            &(feet_list[VLFulLinIndex] ) 
                           );
     CheckRC( sts, 1 ) ;
   *
   */ 
  PropMask = GRIS_DISPLAYABLE | GRIS_LOCATABLE    ;
  action   = 0 ;  // unset the properties
  sts = gr$put_properties( object_id = &feet_list[VLFulLinIndex] ,
			   action    = action ,
			   properties_mask = PropMask ) ;
  CheckRC( sts, 1 ) ;
  
  __DBGpr_int( "num marks", NumMarks );
  __DBGpr_obj( "offset in", Offset   );
  
  __DBGpr_objlist( "before Find sub feet list", 5, feet_list ) ;
  // find subcurve offset
  
  feet_list[*fcount].objid = NULL_OBJID ;
  
  // given a curve on/near to the srf, produce a sub curve
  // of at least 50 units
  
  sts = VLFindSubCurveByCurve(	
                              Marks ,
                              &Offset ,
                              md_env,
			      &vg_cnst ,
			      &feet_list[*fcount] 
			      );
  __CheckRC( 1, sts, "VLFindSubCurveByCurve", wrapup ) ;
  if ( feet_list[*fcount].objid != NULL_OBJID ) 
  {
    ++ (*fcount ) ;
    __DBGpr_int( "before perp num feet", *fcount );
    
    //if ( !StiffIsPlate ) - commented for TR179902114 
    {
      // place the stiffener type marker ie |-
      // as opposed to plate-plate which doesn't have one
      
      __DBGpr_objlist( "before mid feet list", 5, feet_list ) ;
      __DBGpr_vec( "OffsetDir", OffsetDir) ;
      feet_list[*fcount].objid = NULL_OBJID ;
      
      sts = VLLineAtMidByVec(   &msg ,
				&feet_list[(*fcount)-1] ,
				OffsetDir ,
				&vg_cnst ,
				&feet_list[(*fcount)] );
      CheckRC( sts , msg ) ;
      
      if ( feet_list[*fcount].objid != NULL_OBJID ) ++ (*fcount ) ;
    }
  }   // if we have the offset subcurve
  
  __DBGpr_int( "num feet", *fcount );
  __DBGpr_objlist( "before marks feet list", 5, feet_list ) ;
  
  if ( NumMarks ) 
  {  // make sure all marks are in the feet_list
    int MarkNum = 0 ;
    for ( NumInter=*fcount,MarkNum=0; MarkNum<NumMarks; ++NumInter,
	    ++MarkNum   ){
      feet_list[NumInter] = Marks[MarkNum] ;
      Marks[MarkNum].objid= NULL_OBJID ;     //don't delete
    }
    *fcount += NumMarks  ;
  }
  __DBGpr_int( "num feet", *fcount );
  
#ifdef vsDEBUG
  for ( NumInter=2; NumInter<*fcount; ++NumInter ) {
    __DBGpr_obj( "foot", feet_list[NumInter] );
    
    sts = gr$display_object(	object_id = &feet_list[NumInter],
				md_env	  = md_env		,
				mode	  = GRbd )		;
    __CheckRC( sts, 1, "Mark: display result", wrapup ) ;
  }
#endif

  // get the names of the marking elements
 get_attr:
  list_att[0].desc.value.att_txt[0] = 0;
  sts = VLGetShortName(	&stiffObj ,
			md_env ,
			list_att[0].desc.value.att_txt );
  CheckRC( sts, 1 );
  
  __DBGpr_str( "stiff name ", list_att[0].desc.value.att_txt ) ;
  
  list_att[1].desc.value.att_txt[0] = 0;
  sts = VLGetShortName(	&plateObj ,
			md_env ,
			list_att[1].desc.value.att_txt );
  CheckRC( sts, 1 );
  
  __DBGpr_str( "plate name ", list_att[1].desc.value.att_txt ) ;
  
  
  feet_list[ VLMrkParIndex].osnum  = feet_list[ VLFulLinIndex].osnum ;
  
  // for genLine compatibility
  strcpy( list_att[0].name,  "dataName" );
  strcpy( list_att[1].name,  "plate name" );
  list_att[0].desc.type = list_att[1].desc.type = AC_ATTRIB_TEXT;
  
  // TR179900638 Add 2 more
  strcpy(list_att[2].name,VLTypeSide);
  strcpy(list_att[3].name,VLIntsTypeSide);
  
  list_att[2].desc.value.att_exp = (IGRdouble) TypeSide;
  list_att[3].desc.value.att_exp = (IGRdouble) IntsTypeSide;
  
  list_att[2].desc.type = AC_ATTRIB_DOUBLE;
  list_att[3].desc.type = AC_ATTRIB_DOUBLE;
  
  sts = om$construct(classid    = OPP_ACrg_collect_class_id,
		     osnum      = feet_list[ VLMrkParIndex].osnum,
		     p_objid    = &feet_list[ VLMrkParIndex].objid ,
		     
		     msg = message ACrg_collect.ACadd_list_attribute
		     (&msg, 4 , list_att ) );
  CheckRC( sts, msg ) ;

  __DBGpr_obj( "placed colln ", feet_list[VLMrkParIndex] ) ;
  
  if ( feet_list[ VLMrkParIndex].objid == NULL_OBJID ) --(*fcount) ;
  
  sts = *ret = OM_S_SUCCESS;
  
  __DBGpr_objlist( "before wrapup feet list", 5, feet_list ) ;

  /**********  WRAPUP HERE  **************/
 wrapup:				
  
  _FREE(full_curve);
  
  // make sure no construction objects left lying around
#ifndef vsDEBUG		
  // these objects left when in struct debug
  if (   lcStiff.located_obj.objid != NULL_OBJID ) { 
    __DBGpr_obj( "wrapup: located_obj",lcStiff.located_obj );
    __DBGpr_obj( "wrapup: StiffSideObj.obj_id",StiffSideObj.obj_id);
    stat = om$send(msg  = message GRgraphics.GRdelete( &msg, md_env ),
		   targetid =   lcStiff.located_obj.objid,
		   targetos =   lcStiff.located_obj.osnum  );
    CheckRC( stat, msg );
  }
  for (posn= 0;posn< 2; ++posn) {
    if (   StiffSideExtObj[posn]._objid != NULL_OBJID ) {
      __DBGpr_obj( "deleting", StiffSideExtObj[posn].obj_id );
      stat= om$send(msg  = message GRgraphics.GRdelete( &msg,
							md_env ),
		    targetid =   StiffSideExtObj[posn]._objid,
		    targetos =   StiffSideExtObj[posn]._osnum  );
      CheckRC( stat, msg );
    }
  }
  
#endif
  
  if (   Offset .objid != NULL_OBJID ) { 
    __DBGpr_obj( "wrapup: del offset",Offset  );
    stat = om$send(msg  = message GRgraphics.GRdelete( &msg, md_env ),
		   targetid =   Offset .objid,
		   targetos =   Offset .osnum  );
    CheckRC( stat, msg );
  }
  if (  MainIso .objid != NULL_OBJID ) { 
    __DBGpr_obj( "wrapup: del MainIso",Offset  );
    stat = om$send(msg  = message GRgraphics.GRdelete( &msg, md_env ),
		   targetid =   MainIso.objid,
		   targetos =   MainIso.osnum  );
    CheckRC( stat, msg );
  }
  
  for ( NumInter = 1; NumInter < NumMarks ; ++NumInter ) {
    
    if (   Marks[NumInter].objid != NULL_OBJID ) {
      __DBGpr_obj( "deleting", Marks[NumInter] ) ;
      stat= om$send(msg  = message GRgraphics.GRdelete( &msg,
							md_env ),
		    targetid =   Marks[NumInter].objid,
		    targetos =   Marks[NumInter].osnum  );
      CheckRC( stat, msg );
    }
  }
  
  _FREE( PlateSrfGeom );
  
  _FREESF( &bsrc, StiffSideExtGeom[0] ) ;
  _FREESF( &bsrc, StiffSideExtGeom[1] ) ;

  vdsa$GetStruct( objOE   = &plateObj,
                  name    = "SA_AST:StagingTree:0:pcmk",
                  txt     = platePcmk );
  if( !strlen( platePcmk ) )
    sts = VLGetShortName( &plateObj, md_env, platePcmk );
  
  vdsa$GetStruct( objOE   = &stiffObj,
                  name    = "SA_AST:StagingTree:0:pcmk",
                  txt     = beamPcmk );
  if( !strlen( beamPcmk ) )
    sts = VLGetShortName( &stiffObj, md_env, beamPcmk );
  
  if( !vs$is_ancestry_valid( object  = &feet_list[2],
                             classid = OPP_GRcurve_class_id ) )
  {
    if( pr_error == FALSE )
    {
      printf("Failed to construct for marking line between <%s> and <%s>\n",
	     platePcmk, beamPcmk );
      pr_error = TRUE;
    }
    VLplPt( &msg, point, &feet_list[2], md_env );
  }
  
  if( !vs$is_ancestry_valid( object  = &feet_list[3],
                             classid = OPP_GRcurve_class_id ) )
  {
    if( pr_error == FALSE )
    {
      printf("Failed to construct for marking line between <%s> and <%s>\n",
	     platePcmk, beamPcmk );
      pr_error = TRUE;
    }
    VLplPt( &msg, point, &feet_list[3], md_env );
  }
  
  if( !vs$is_ancestry_valid( object  = &feet_list[4],
	       classid = OPP_GRcurve_class_id ) )
  {
    if( pr_error == FALSE )
    {
	printf("Failed to construct for marking line between <%s> and <%s>\n",
	       platePcmk, beamPcmk );
	pr_error = TRUE;
    }
    VLplPt( &msg, point, &feet_list[4], md_env );
  }
  
  End
    
    if ( sts == MSFAIL )	sts = OM_W_ABORT ;	//this means more to OM
  
  return sts;
  
}  // end ACconstruct_feet

end implementation VLmrkLine  ;
