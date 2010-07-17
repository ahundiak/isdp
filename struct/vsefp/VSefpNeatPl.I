/* $Id $ */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:      vsefp/VSefpNeatPl.I  
 *
 * Description: Function to get the "neat" contour of a plate.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      07/17/00        Rama Rao        File Creation
 *      10/16/00        ah              Added env to VDdrawCurve
 *      08/01/01        Jayadev         Fix for TR#MP5443 
 *      11/14/01        Jayadev         Fix for etl#10958, 10920, 10885
 *                                      Drawing extraction failures 
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "EMSmsgdef.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "VDobj.h"
#include "VDefp.h"
#include "VDgeom.h"
#include "vs.h"
#include "vsplatedef.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"

#define	vdsDEBUG	1
#define vdserrDEBUG	1

extern GRclassid	OPP_VSsubPlate_class_id, OPP_VSbooPlate_class_id,
			OPP_VSimbPlate_class_id, OPP_VSholPlate_class_id;

from	VSfeature	import	VSgetResultType, VSgetOperationHistory;

IGRlong		VSgetNeatPlEdges(  IGRlong		   *msg,
				   struct GRobj_env	   *inp_pl,
				   struct GRvg_construct   *cst,
				   IGRboolean		   neat_edge,
				   IGRint		   *edge_count,
				   struct GRid		   **edge_list,
				   struct GRid		   *comp_crv	)
{
IGRlong			sts;
IGRint			i, loc_edge_count=0;
unsigned long   	type;
IGRdouble		tol;
VSopHistory     	*history=NULL, *h ;
struct GRid 		res_id, *loc_edge_list=NULL;
struct GRobj_env	par_plate, srfOE;
struct IGRbsp_curve     *edgeGeom[VDEFP_NEAT_EDGES_MAX];

   SetProc( VSgetNeatPlEdges );	Begin

   sts = *msg = MSSUCC;

   if( edge_count ) *edge_count = 0 ;
   if( edge_list  ) *edge_list  = NULL;

   for( i=0; i<VDEFP_NEAT_EDGES_MAX; ++i )  edgeGeom[i] = NULL;

   __DBGpr_obj("Input Plate ", inp_pl->obj_id );

   gr$get_module_env( buffer = cst->env_info );

   if( neat_edge == FALSE ||
       vd_$is_ancestry_valid(  	object  = &inp_pl->obj_id,
				classid = OPP_VSsubPlate_class_id ) )	
   {
      __DBGpr_com( "Input plate is Sub-Plate" );
      par_plate = *inp_pl;
   }
   else
   {
      sts = _VD_SEND_OBJN( inp_pl->obj_id, VSfeature.VSgetResultType(
						msg, &type ) );
      __CheckRC( sts, *msg, "Getting plate type", wrapup ) ;

      if( ( type & VS_m_BOO_PLATE ) || ( type & VS_m_IMB_PLATE ) )
      {
         sts = _VD_SEND_OBJN( inp_pl->obj_id, VSfeature.VSgetOperationHistory(
				msg, &inp_pl->mod_env, &history ) );
         __CheckRC( sts, *msg, "Getting Operation History", wrapup ) ;

	 for( h = history ; h ; h = h->next )
	 {
	    res_id.objid = h->resultId;
	    res_id.osnum = h->resultOs;

	    __DBGpr_obj("Parent ", res_id );

	    if( vd_$is_ancestry_valid( object  = &res_id,
			classid  = OPP_VSbooPlate_class_id ) ||
	        vd_$is_ancestry_valid( object  = &res_id,
			classid  = OPP_VSimbPlate_class_id ) ||
		vd_$is_ancestry_valid( object  = &res_id,
			classid  = OPP_VSholPlate_class_id ) )  continue;

	    par_plate._objid  = h->resultId;
	    par_plate._osnum  = h->resultOs;
	    par_plate.mod_env = h->resultEnv; 
	 }
      }
   }
   __DBGpr_obj("Immediate Non-Hole Plate ", par_plate.obj_id );

   vdobj$GetFoot( objOE    = &par_plate, 
                  footName = VS_K_plBotSfPath,
		  footOE   = &srfOE );
   if (srfOE.obj_id.objid == NULL_OBJID) goto wrapup;
   srfOE.mod_env = inp_pl->mod_env;

   vdgeom$GetTolerance(cht = &tol);

   /*
    * Using the new BSpmath neat plate routine for TR#MP5443
    * Replaced VDefpGetSurfaceEdgeBsps() with the one seen here
    */
   sts = VDefpGetSurfaceEdgeBspsBS( &srfOE, VDEFP_NEAT_EDGES_MAX, tol,
				  &loc_edge_count, edgeGeom );
   //__CheckRC( sts, 1, "VDefpGetSurfaceEdgeBsps", wrapup );
   /*
    * Call Art's VDefpGetSurfaceEdgeBsps() routine in the event
    * of the BSroutine failure; This is more tolerant to little
    * notches in the surface geometry
    */
   if(!(sts&1))
   {
    __DBGpr_com("FAILED : VDefpGetSurfaceEdgeBspsBS ");

    for( i=0; i<loc_edge_count; ++i )   _FREE( edgeGeom[i] );
    loc_edge_count = 0;

    __DBGpr_com("TRYING : VDefpGetSurfaceEdgeBsps ");

     sts = VDefpGetSurfaceEdgeBsps(&srfOE, VDEFP_NEAT_EDGES_MAX, tol,
                                   &loc_edge_count, edgeGeom );
     __CheckRC( sts, 1, "VDefpGetSurfaceEdgeBsps", wrapup );
   }

   
   if( !( loc_edge_list = _MALLOC( loc_edge_count,  struct GRid ) ) )
        vd_$mem_fail();

   /* --------------------------------------------
    * 16 Oct 2000 - Added loc_env, 
    * note that loc_env may not be correct if this ever gets called
    * from a nested marco or in a reference file recompute
    */
   for( i=0; i<loc_edge_count; ++i ) 
	VDdrawCurve( edgeGeom[i], cst->env_info, &loc_edge_list[i] );
   __DBGpr_objlist("Neat Edges ", loc_edge_count, loc_edge_list );

   if( edge_count ) *edge_count = loc_edge_count ;
   if( edge_list  ) 
   {
	if( !( *edge_list = _MALLOC( loc_edge_count,  struct GRid ) ) )
	   vd_$mem_fail();

	for( i=0; i<loc_edge_count; ++i )
	  (*edge_list)[i] = loc_edge_list[i] ;
   }
   else if( comp_crv )
   {
	__DBGpr_com("Creating Composite Curve" );
        sts = vs$makeCompCurve2( msg    = msg,
                                cst     = cst,
                                cvList  = loc_edge_list,
                                cvCount = loc_edge_count,
                                cvEnv   = cst->env_info,
                                compEnv = cst->env_info,
                                compCv  = comp_crv ) ;
	__CheckRC( sts, *msg, "vs$makeCompCurve", wrapup ) ;
	__DBGpr_obj("Output Composite Curve", *comp_crv ) ;
   }

wrapup:
   if( !edge_list && !comp_crv )
   {
     for( i=0; i<loc_edge_count; ++i )
	VSbulkDeleteByGRids( cst->env_info, loc_edge_count, loc_edge_list );
   }

   _FREE( loc_edge_list );
   for( i=0; i<loc_edge_count; ++i )   _FREE( edgeGeom[i] );
   if( history ) VSfreeOpHistory( history ) ;
   End
   return sts;
}

end implementation VDSroot;
