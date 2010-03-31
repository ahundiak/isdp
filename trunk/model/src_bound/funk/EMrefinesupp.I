/* ###################   APOGEE COMPILED   ################## */
/* 
Notes
Following are special purpose functions written for refinement of the trim
points in the intersection data.

History
	SM	10-April-88	Creation.
        RV      07-Sep-88	Added matrix-type and matrix to
				EMsm_insert_point_in_edge.
	SM	10-Jan-89	Project the uv point onto the bs/natural
				edge in EMsm_insert_point function. Reason
				for this is explained in the change
				history in EMedrefine.I bearing the same
				date.
	SM	28-Feb-89	Added functions EMrecord_pointers(), 
				EMset_connection() and EMbreak_connection().
				These are called from the functions
				EMsfint_exact() and EMfix_sfint_uvtrace()
				and deal with fwd/bwd pointers in EMSintobj
				structure.
	SM	01-Nov-89	Do not set uv connection properties in
				EMset_connection() if one or both intobjs
				are marked as 'noconnectuv'. 
	SM	19-Aug-92       Do not set the fwd/bwd pointer (and also any
	                        connectivity property) in EMset_connection
	                        if either intobjs is marked 'noconnectuv'
	                        at that end. Presence of the fwd/bwd pointer
	                        in such cases, has a different meaning for
	                        trace than when the pointer is NULL.
            	                This action to be taken regardless of whether
                                the connectivity is being established in
                                uv or xyz space if 'fwd/bwd noconnectuv' is
                                set because the fwd/bwd pointers are shared
                                for uv and/or xyz connectivity.

                                In keeping with the same reasoning, do not
                                set the fwd/bwd pointers to NULL in the
                                function 'EMbreak_connection' if the
                                corresponding noconnectuv property is set.
*/
class implementation EMSedge;

#define DEBUG	0

#if DEBUG
#include <stdio.h>
#endif
#include "emsdef.h"
#include "OMmacros.h"
#include "EMSfrtdef.h"	/* EMS_O_RETRIM */


from GRvg import GRgetsize, GRgetgeom;
from EMSsubbs import EMpartolbasis;
from EMSloop import EMget_props;
from EMSgradata import EMreset;
from EMSloopset import EMlsparttrim;
from EMSloop import EMsetrange;

IGRint EMsm_get_surface_tolerance(EMmsg, surf_data, loc_surf_data, 
				      tol, loc_tol, env, edgeid, srfid)
 IGRlong 		*EMmsg;
 struct EMSdataselect	*surf_data, *loc_surf_data;
 struct EMSpartolbasis	*tol, *loc_tol;
 struct GRmdenv_info	*env;
 GRobjid		edgeid;
 struct GRid		*srfid;
{
  IGRlong		sts;
  IGRboolean		world;

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if(surf_data) *loc_surf_data = *surf_data;
  else
   {
    loc_surf_data->datatype = EMSdata_null;
    loc_surf_data->data.object = (struct GRid *) srfid;
   }

  if(tol && loc_tol) *loc_tol = *tol;
  else if(loc_tol)
   {
    loc_tol->is_valid = FALSE;
    loc_tol->in_world = TRUE;
    loc_tol->mattyp = &env->matrix_type;
    loc_tol->mat = env->matrix;
   }
  if(loc_tol && surf_data && (surf_data->datatype == EMSdata_object) &&
     (!loc_tol->is_valid))
   {
    srfid = surf_data->data.object;
#if DEBUG
    fprintf(stderr, "REFINE:Getting tol for surf %d\n", srfid->objid);
#endif
    sts = om$send(msg = message EMSsubbs.EMpartolbasis
			(EMmsg, loc_tol->mattyp, loc_tol->mat, &world, 
			 TRUE, &loc_tol->tol), 
		senderid = NULL_OBJID, targetid = srfid->objid, 
		targetos = srfid->osnum);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
    loc_tol->is_valid = TRUE;
   }

  if(!surf_data || (loc_tol ? !loc_tol->is_valid : NULL))
   {
#if DEBUG
    if(loc_tol && !loc_tol->is_valid)
     fprintf(stderr, "REFINE:Getting tol for surf of edge %d\n", edgeid);
#endif
    if(!surf_data) srfid->objid = NULL_OBJID;
    sts = om$send(msg = message EMSboundary.EMgetsurface_info
			(EMmsg, surf_data ? NULL : &srfid->objid, 
			 loc_tol ? (loc_tol->is_valid ? NULL : loc_tol)
			: NULL), 
			senderid = NULL_OBJID, 
			targetid = edgeid);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
    if(!surf_data)
     {
      if(IF_NULL_OBJID(srfid->objid)) *EMmsg = EMS_E_NoSolution;
      else loc_surf_data->datatype = EMSdata_object;
     }
   }

wrapup:
 return(sts);
}



IGRint	EMsm_get_surface_geom(EMmsg, surf_data, env, surf_geom)
  IGRlong 		*EMmsg;
  struct EMSdataselect 	*surf_data;
  struct GRmdenv_info	*env;
  struct IGRbsp_surface **surf_geom;
{
  IGRlong	sts;
  struct GRid	surf_GRid;
  IGRlong	num_bytes;
  
  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  *surf_geom = NULL;

  EMerr_hndlr(!surf_data, *EMmsg, EMS_E_InvalidArg, wrapup);
  if(surf_data->datatype == EMSdata_surface)
   {
#if DEBUG 
    fprintf(stderr, "REFINE:Using supplied Surf Geom\n");
#endif
    *surf_geom = (struct IGRbsp_surface *) surf_data->data.surface;
   }
  else if(surf_data->datatype == EMSdata_object)
   {
    surf_GRid = *surf_data->data.object;
#if DEBUG
    fprintf(stderr, "REFINE:Getting Geom for surf %d\n", surf_GRid.objid);
#endif
    sts = om$send(msg = message GRvg.GRgetsize(
                  EMmsg, &env->matrix_type, env->matrix, &num_bytes),
                  senderid = NULL_OBJID,
                  targetid = surf_GRid.objid, targetos = surf_GRid.osnum);
    EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_Fail,wrapup);
    *surf_geom = (struct IGRbsp_surface *) malloc(num_bytes);
    EMerr_hndlr(!surf_geom,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);

    /* Get the surface geometry.
    */
    sts = om$send(msg = message GRvg.GRgetgeom(
                  EMmsg, &env->matrix_type, env->matrix, (IGRchar *)*surf_geom),
                  senderid = NULL_OBJID, 
                  targetid = surf_GRid.objid, targetos = surf_GRid.osnum);
    if (!(1 & sts)) goto wrapup;
   }
  else
   *EMmsg = EMS_E_InvalidArg;

wrapup:
 if(!(1&*EMmsg&sts))
  {
   if(*surf_geom) free(*surf_geom);
   *surf_geom = NULL;
  }
 return(sts);
}



EMsm_reset_gradata(EMmsg, edgeid, to_outter, to_helper, hole)
IGRlong	*EMmsg;
GRobjid edgeid;
OM_S_CHANSELECT *to_outter, *to_helper;
IGRboolean *hole;
{
 IGRlong	sts, rc;
 GRobjid	loopid;
 IGRushort lp_props = NULL, reset_option = EMS_O_RETRIM;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 if(hole) *hole = FALSE;

 loopid = NULL_OBJID;
 sts = EMsend_loops(&rc, message EMSboundary.EMget_objid
		(EMmsg, &loopid), edgeid, 0, MAXINT, EMLP_ACTIVE, NULL, NULL);
 if(!IF_NULL_OBJID(loopid))
  {
   sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &lp_props), 
				senderid = NULL_OBJID, targetid = loopid);
   if( !(lp_props & EMLP_PLOOP))
    {
     if(hole) *hole = TRUE;
     sts = om$send(msg = message EMSboundary.EMget_objid
	(EMmsg, &loopid), p_chanselect = to_outter, senderid = loopid);
    }
   sts = om$send(msg = message EMSgradata.EMreset(EMmsg, reset_option), 
			senderid = loopid, p_chanselect = to_helper);
  }

 sts = EMsend_loops(&rc, message EMSloop.EMsetrange(EMmsg), 
			edgeid, 0, MAXINT, NULL, NULL, NULL);
 
return(sts);
}




IGRint EMsm_validate_three_points(EMmsg, points, edgeid, tol, isvalid)
IGRlong	*EMmsg;
IGRdouble *points;
GRobjid edgeid;
struct EMSpartolbasis *tol;
IGRboolean *isvalid;
{
 IGRlong 		sts;
 struct IGRpolyline 	poly;
 GRobjid 		srfid = NULL_OBJID;
 OM_S_CHANSELECT 	to_loopset;
 struct EMSdataselect	uvdata;
 IGRint			num_bdrys = 0;
 IGRushort	trim_options = NULL;
 struct EMSpypoint	*pypoint;
 IGRdouble		from_par, to_par;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 *isvalid = FALSE;
 pypoint = NULL;

 poly.num_points = 3;
 poly.points = points;

 sts = om$send(msg = message EMSboundary.EMgetsurface_info
			(EMmsg, &srfid, NULL), 
		targetid = edgeid, senderid = NULL_OBJID);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
 EMerr_hndlr(IF_NULL_OBJID(srfid), *EMmsg, EMS_E_EdgeError, wrapup);

 sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
 uvdata.datatype = EMSdata_poly2d;
 uvdata.data.poly = &poly;

 sts = om$send(msg = message EMSloopset.EMlsparttrim
	  (EMmsg, &uvdata, tol, trim_options, &num_bdrys, &pypoint, NULL), 
		senderid = srfid, p_chanselect = &to_loopset);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

 if(!num_bdrys) *isvalid = TRUE;
 else
  {
   from_par = pypoint->span_inx + pypoint->param;
   to_par = pypoint->next->span_inx + pypoint->next->param;
   if( (num_bdrys == 1) && (from_par == 0.0) && (to_par == 2.0))
   *isvalid = TRUE;
   else *isvalid = FALSE;
  }

#if DEBUG
  if(!(*isvalid))
   {
    struct EMSdataselect junk_uvdata;

    fprintf(stderr, "INVALID: Cannot refine edge %d\n", edgeid);
    junk_uvdata = uvdata;
   }
#endif

wrapup:
if(pypoint) EMpypoint_free(pypoint, NULL);

EMWRAPUP(*EMmsg, sts, "In EMsm_validate_three_points");
return(sts);
}


extern OMuword OPP_EMSlinedge_class_id;

#include "bserr.h"
#include "bsparameters.h"
#include "emssfint.h"
#include "emssfintdef.h"
#include "emsmacros.h"
#include "emsinterdef.h"

IGRint EMsm_insert_point_in_edge(EMmsg, edpar, partol, edgeid, uv, edge_hole, 
				 refined, mattyp, mat, surf_data)
IGRlong			*EMmsg;
struct EMSsfintedpar	*edpar;
struct EMSpartolbasis	*partol;
GRobjid			edgeid;
IGRdouble		*uv;
IGRboolean		*edge_hole, *refined;
IGRshort		*mattyp;
IGRmatrix		mat;
struct EMSdataselect	*surf_data;
{
 IGRlong		sts, rc;
 IGRushort 	        junkprops;
 IGRdouble 		junk[4], points[3][2];
 struct IGRpolyline 	junk_poly, ins_poly;
 GRobjid 		junkid;
 IGRboolean 		reverse, isvalid = FALSE, check_constraints = TRUE, 
			exact_edge = FALSE;
 OMuword		junk_classid;
 IGRdouble		lentol;
 OM_S_CHANSELECT	to_outter, to_helper;
 IGRint			before_ptinx, uv_size;
 struct EMSproj_info	proj_info;
 
 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 if(refined) *refined = FALSE;
 uv_size = 2 * sizeof(IGRdouble);

 sts = EFextract_par(BSTOLLENVEC, partol->tol, &lentol, &rc);
 junk_poly.num_points = 0;
 junk_poly.points = junk;
 sts = om$send(msg = message EMSedge.EMget_bottom_edge(EMmsg, &junkid), 
				targetid = edgeid, senderid = edgeid);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

 /* If the bottom edge is a natural edge or a BS edge then
       it is already exact and hence does not need any refinement.
 */
 sts = om$get_classid(objid = junkid, p_classid = &junk_classid);
 EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);
   
 if (junk_classid != OPP_EMSlinedge_class_id || 
          om$is_ancestry_valid (subclassid = junk_classid,
           superclassid = OPP_EMSlinedge_class_id) != OM_S_SUCCESS)
   exact_edge = TRUE;

 /* If the information about where to insert the point is not supplied then
    generate it by projecting the point onto the edge. The fact that such
    info is not supplied is indicated by the fact that edgeid in edpar
    is NULL_OBJID. This is probably because this intersection was dangling
    and hence the information was not generated during trimming.

    For natural/bs edge -

    The uv point obtained may have moved away from the edge.
    Project it onto the edge to make sure it lies on the edge. This
    will ensure the movement of the refined point to always be along
    the bs/natural edge and never away from it. This problem does not
    arise for a linear edge because the linear edge itself is
    modified to contain the refined point.
 */
 if(IF_NULL_OBJID(edpar->edgeid) || exact_edge)
  {
   sts = om$send(msg = message EMSedge.EMptproject(EMmsg, uv, 1, &proj_info, 
				NULL, partol), senderid = edgeid, 
				targetid = edgeid);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_I_NoSolution, wrapup);
   OM_BLOCK_MOVE(&proj_info.param, &edpar->edgepar, 
					sizeof(struct EMSedgebound));
   if(proj_info.location != EMScvint_unknown)
	edpar->intloc = proj_info.location;
   edpar->edgeid = edgeid;
   OM_BLOCK_MOVE(uv, edpar->point, uv_size);
  }

 if(exact_edge) {sts = OM_S_SUCCESS; *EMmsg = EMS_I_InvalidArg; goto wrapup;}

 sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &junkprops), 
				targetid = junkid, senderid = junkid);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_I_NoSolution, wrapup);

 /* If we have an iso edge on our hands then see if the uv point really
    needs to go in.
 */
 if(junkprops & EMED_ISO)
  {
   sts = om$send(msg = message EMSedge.EMptproject(EMmsg, uv, 1, &proj_info, 
				NULL, partol), senderid = junkid, 
				targetid = junkid);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_I_NoSolution, wrapup);
   if(proj_info.dist < lentol)
    {*EMmsg = EMS_I_Degenerate; goto wrapup;}
  }

 reverse = junkprops & EMED_REVERSED ? TRUE : FALSE;
 sts = om$send(msg = message EMSedge.EMgetpygeom
		(EMmsg, edpar->edgepar.span_inx, 1, reverse, NULL, &junk_poly,
                 NULL, NULL),
			targetid = junkid, senderid = junkid);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_I_NoSolution, wrapup);

 if( (EM2ddistptpt(uv, junk) > lentol) &&
     (EM2ddistptpt(uv, &junk[2]) > lentol))
  {
   before_ptinx = edpar->edgepar.span_inx + 1;
   ins_poly.num_points = 1;
   ins_poly.points = uv;
   OM_BLOCK_MOVE(junk, points[0], uv_size);
   OM_BLOCK_MOVE(uv, points[1], uv_size);
   OM_BLOCK_MOVE(&junk[2], points[2], uv_size);
   sts = EMsm_validate_three_points(EMmsg, (IGRdouble *)points, edgeid, partol, &isvalid);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
   if(isvalid)
    {
     sts = om$send(msg = message EMSedge.EMputpygeom(EMmsg, before_ptinx, 
			reverse, &ins_poly, check_constraints, partol, NULL,
			surf_data, mattyp, mat), 
			targetid = junkid, senderid = junkid);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
     if(*EMmsg == EMS_I_InvalidArg) goto wrapup;
	
     if(refined) *refined = TRUE;
     sts = EMmake_chanselect (EMSloop_to_outter, &to_outter);
     sts = EMmake_chanselect (EMSrequester_to_helpers, &to_helper);
     sts = EMsm_reset_gradata(EMmsg, edgeid, &to_outter, &to_helper, 
				edge_hole);
    }
   else *EMmsg = EMS_I_InvalidArg;

  }
 else *EMmsg = EMS_I_Degenerate;

wrapup:

return(sts);
}



IGRboolean EMrecord_pointers(EMmsg, begin1, begin2, intobj1, intobj2)
IGRlong			*EMmsg;
IGRboolean		begin1, begin2;
struct EMSintobj	*intobj1, *intobj2;
{
 struct EMSintobj	*junk1 = NULL, *junk2 = NULL;
 IGRboolean		ok = FALSE, begin1_other = FALSE, 
			begin2_other = FALSE, dummy = FALSE;
 IGRushort 	flag1 = NULL, flag2 = NULL;
 extern IGRboolean	EMset_connection();
 extern void		EMbreak_connection();

 ok = EMset_connection(EMmsg, begin1, begin2, intobj1, intobj2, FALSE);
 if(!ok)
  {
   EMbreak_connection(intobj1);
   EMbreak_connection(intobj2);
  }
 else if( (junk1 = intobj1->other_intobj_node) &&
       (junk2 = intobj2->other_intobj_node))
  {
   flag1 = intobj1->reversed ? 0x1 : 0x0;
   flag2 = junk1->reversed ? 0x1 : 0x0;
   begin1_other = flag1 ^ flag2 ? !begin1 : begin1;
   flag1 = begin1_other ? 0x1 : 0x0;
   dummy = flag1 ^ flag2 ? TRUE : FALSE;
   flag1 = intobj2->reversed ? 0x1 : 0x0;
   flag2 = junk2->reversed ? 0x1 : 0x0;
   begin2_other = flag1 ^ flag2 ? !begin2 : begin2;
   ok = EMset_connection(EMmsg, begin1_other, begin2_other, junk1, junk2, 
			 FALSE);
   if(!ok)
    {
     EMbreak_connection(intobj1);
     EMbreak_connection(intobj2);
     EMbreak_connection(junk1);
     EMbreak_connection(junk2);
    }
  }

if(ok) return(TRUE);
else return(FALSE);
}



#include "emsmacros.h"

IGRboolean EMset_connection(EMmsg, begin1, begin2, intobj1, intobj2, uv)
IGRlong			*EMmsg;
IGRboolean		begin1, begin2;
struct EMSintobj	*intobj1, *intobj2;
IGRboolean		uv;
{
 struct EMSintobj	*junk1, *junk2;
 IGRboolean		ignore_uv = FALSE;

 ignore_uv = (begin1 ? intobj1->props & EMSintobj_bwd_noconnectuv :
		       intobj1->props & EMSintobj_fwd_noconnectuv) ||
             (begin2 ? intobj2->props & EMSintobj_bwd_noconnectuv :
		       intobj2->props & EMSintobj_fwd_noconnectuv);

 if(ignore_uv) return(TRUE);

 if(begin1) junk1 = intobj1->bwd; 
 else junk1 = intobj1->fwd; 

 if(begin2) junk2 = intobj2->bwd; 
 else junk2 = intobj2->fwd; 
	

 /* If either of the ends are already connected to some other intobj, it
    signals an orientation error (resulting possibly out of incorrect trace
    linkages).
 */
 if( (junk1 && (junk1 != intobj2)) || (junk2 && (junk2 != intobj1)))
  {*EMmsg = EMS_E_IntersectOrient; return(FALSE);} 

 if(begin1)
  {
   intobj1->bwd = (struct EMSintobj *) intobj2;
   if(uv) intobj1->props |= EMSintobj_bwd_connectuv;
  }
 else 
  {
   intobj1->fwd = (struct EMSintobj *) intobj2;
   if(uv) intobj1->props |= EMSintobj_fwd_connectuv;
  }

 if(begin2)
  {
   intobj2->bwd = (struct EMSintobj *) intobj1;
   if(uv) intobj2->props |= EMSintobj_bwd_connectuv;
  }
 else
  {
   intobj2->fwd = (struct EMSintobj *) intobj1;
   if(uv) intobj2->props |= EMSintobj_fwd_connectuv;
  }

 if( (intobj1->fwd == intobj2) && (intobj1->bwd == intobj2) &&
     ((intobj2->fwd != intobj1) || (intobj2->bwd != intobj1)))
  {*EMmsg = EMS_E_IntersectOrient; return(FALSE);} 

 if( (intobj2->fwd == intobj1) && (intobj2->bwd == intobj1) &&
     ((intobj1->fwd != intobj2) || (intobj1->bwd != intobj2)))
  {*EMmsg = EMS_E_IntersectOrient; return(FALSE);} 
	
return(TRUE);
}






void EMbreak_connection(intobj1)
struct EMSintobj	*intobj1;
{
 struct EMSintobj	*intobj2 = NULL;

 /* The fwd/bwd_connectuv and fwd/bwd_noconnectuv properties will never be
    set simultaneously.
    While breaking a connection, do not change the fwd/bwd pointer if the
    corresponding noconnectuv property is set. This is because if such
    noconnectuv property is set the fwd/bwd pointers were set external to
    refinement.
  */
 intobj2 = intobj1->bwd;
 if(intobj2)
  {
    intobj1->props &= ~EMSintobj_bwd_connectuv;
    if(!(intobj1->props & EMSintobj_bwd_noconnectuv))
     intobj1->bwd = NULL;
    if(intobj2->fwd == intobj1)
     {
      intobj2->props &= ~EMSintobj_fwd_connectuv;
      if(!(intobj2->props & EMSintobj_fwd_noconnectuv))
       intobj2->fwd = NULL;
     }
    if(intobj2->bwd == intobj1)
     {
      intobj2->props &= ~EMSintobj_bwd_connectuv;
      if(!(intobj2->props & EMSintobj_bwd_noconnectuv))
       intobj2->bwd = NULL;
     }
  }

 intobj2 = intobj1->fwd;
 if(intobj2)
  {
    intobj1->props &= ~EMSintobj_fwd_connectuv;
    if(!(intobj1->props & EMSintobj_fwd_noconnectuv))
     intobj1->fwd = NULL;

     if(intobj2->fwd == intobj1)
     {
      intobj2->props &= ~EMSintobj_fwd_connectuv;
      if(!(intobj2->props & EMSintobj_fwd_noconnectuv))
       intobj2->fwd = NULL;
     }
    if(intobj2->bwd == intobj1)
     {
      intobj2->props &= ~EMSintobj_bwd_connectuv;
      if(!(intobj2->props & EMSintobj_bwd_noconnectuv))
       intobj2->bwd = NULL;
     }
  }

}


end implementation EMSedge;
