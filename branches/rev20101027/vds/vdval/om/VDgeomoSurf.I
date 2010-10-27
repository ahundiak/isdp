/***************************************************************************
 * I/VDS
 *
 * File:        vdgeomo/VDgeomoSurf.I
 *
 * Description: OM Surface Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeomoSurf.I,v $
 *      Revision 1.1  2001/07/28 17:43:48  ahundiak
 *      ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/24/01  ah      Creation
 ***************************************************************************/

class implementation EMSsubbs;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"

#include "VDobj.h"
#include "VDchn.h"

VDASSERT_FFN("VDgeomoSurf.I");

/* -----------------------------------------------
 * Returns the geometry using the so called critical buffer
 * if available, Do NOT free this pointer and it's probably
 * best not keep it around for long
 */
void VDgeomoGetGeometry(TGRobj_env *objOE, IGRchar **geom)
{
  VDASSERT_FN("VDgeomoGetGeometry");
  IGRstat retFlag = 0;
  IGRstat msg,sts;
  IGRint  i;
  
  struct EMparms params;

  TGRbsp_surface *srf = NULL;
  
  // Arg check
  VDASSERTW(geom); *geom = NULL;
  VDASSERTW(objOE && objOE->obj_id.objid != NULL_OBJID);

  // Check the buffer
  GRabsg_test(&msg, 
	      &objOE->mod_env.md_env.matrix_type,
	      objOE->mod_env.md_env.matrix, 
	      &objOE->obj_id.osnum,
	      &objOE->obj_id.objid, 
	      geom);
  if (*geom) goto wrapup;
  
  // Generate it
  sts = om$send(mode = OM_e_wrt_object,
		msg  = message GRvg.GRgenabsg(&msg, 
					      &objOE->mod_env.md_env.matrix_type,
					      objOE->mod_env.md_env.matrix, 
					      geom),
		senderid = objOE->obj_id.objid,
		targetid = objOE->obj_id.objid,
		targetos = objOE->obj_id.osnum);
  if (!(sts & msg & 1)) *geom = NULL;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Gets the surface geometry and adds boundaries
 * copied out of the debug out code
 * Must free up the boundaries by calling
 * VDgeomoFreeSurfaceBoundaryGeometry 
 */
void VDgeomoGetSurfaceBoundaryGeometry(TGRobj_env *srfOE, TGRbsp_surface **srfp) 
{
  VDASSERT_FN("VDgeomoGetSurfaceBoundaryGeometry");
  IGRstat sts,msg;
  TGRbsp_surface *srf;
  IGRint m;
  
  // Arg check
  VDASSERTW(srfp); *srfp = NULL;
  VDASSERTW(srfOE && srfOE->obj_id.objid != NULL_OBJID);
  
  // Basic geometry
  VDgeomoGetGeometry(srfOE,(IGRchar**)srfp);
  if (*srfp == NULL) goto wrapup;
  srf = *srfp;
  
  // Boundaries
  sts = om$send(msg = message EMSsubbs.
		EMget_boundaries(&msg,
				 &srfOE->mod_env.md_env.matrix_type,
				 srfOE->mod_env.md_env.matrix,
				 &srf->on_off, 
				 &srf->num_boundaries,
				 &srf->bdrys),
		senderid = NULL_OBJID,
		targetid = srfOE->obj_id.objid,
		targetos = srfOE->obj_id.osnum);
#if 0
  printf("Number of boundaries %d for %d\n",
	 srf->num_boundaries,srfOE->obj_id.objid);
  for(m = 0; m < srf->num_boundaries; m++) {
    printf("Boundary %2d %3d\n",m,srf->bdrys[m].num_points);
  }
#endif
 wrapup:
  
  return;
}
#if 0
/* -----------------------------------------------
 * Gets the surface geometry and adds boundaries
 * copied out of the debug out code
 * Must free up the boundaries by calling
 * VDgeomoFreeSurfaceBoundaryGeometry 
 */
void VDgeomoGetSurfaceBoundaryGeometry(TGRobj_env *srfOE, TGRbsp_surface **srfp) 
{
  VDASSERT_FN("VDgeomoGetSurfaceBoundaryGeometry");
  IGRstat sts,msg;
  TGRbsp_surface *srf;

  TGRobj_env srfOEx;
  IGRint cnt;

  // Init
  srfOEx.obj_id.objid = NULL_OBJID;
  
  // Arg check
  VDASSERTW(srfp); *srfp = NULL;
  VDASSERTW(srfOE && srfOE->obj_id.objid != NULL_OBJID);
  
  // Xfer
  srfOEx = *srfOE;
  gr$get_module_env(buffer = &srfOEx.mod_env);
  
  /* ---------------------------------------------------
   * If the surface has an owner, make a copy
   * Otherwise, the loop stuff gets confused
   */
  vdchn$Get2(objOE = srfOE, chnIDx = VDCHN_IDX_TO_OWNERS, cnt = &cnt);

  if (cnt != 0) {
    sts = om$send(msg = message EMSsurface.
		  GRcopy(&msg,
			 &srfOE->mod_env,
			 &srfOEx.mod_env,
			 &srfOEx.obj_id.objid),
		  senderid = NULL_OBJID,
		  targetid = srfOE->obj_id.objid, 
		  targetos = srfOE->obj_id.osnum);
    if (!(sts & msg & 1)) {
      printf("Problem making copy of surface while getting geometry\n");
      goto wrapup;
    }
    VDASSERTW(srfOEx.obj_id.objid != NULL_OBJID);
  }

  /* ---------------------------------------------------
   * Add some boundaries
   */
  vdchn$Get2(objOE = &srfOEx, chnIDx = VDCHN_IDX_TO_LOOPSET, cnt = &cnt);
  if (traceFlag) printf("Number of loop_sets %d\n",cnt);

  if (cnt == 0) {
    if (traceFlag) printf("Made natural boundaries\n");
    sts = om$send(msg = message EMSsurface.
		  EMmk_nat_bdry(&msg, &srfOEx.mod_env.md_env, NULL ),
		  senderid = NULL_OBJID,
		  targetid = srfOEx.obj_id.objid,
		  targetos = srfOEx.obj_id.osnum);
    if (!(sts & msg & 1)) {
      printf("Problem creating natural boundaries while getting surface edges\n");
    }
  }

  
  // Basic geometry
  VDgeomoGetGeometry(&srfOEx,(IGRchar**)srfp);
  if (*srfp == NULL) goto wrapup;
  srf = *srfp;
  
  // Boundaries
  printf("Number of boundaries before %d\n",srf->num_boundaries);
    
  sts = om$send(msg = message EMSsubbs.
		EMget_boundaries(&msg,
				 &srfOEx.mod_env.md_env.matrix_type,
				 srfOEx.mod_env.md_env.matrix,
				 &srf->on_off, 
				 &srf->num_boundaries,
				 &srf->bdrys),
		senderid = NULL_OBJID,
		targetid = srfOEx.obj_id.objid,
		targetos = srfOEx.obj_id.osnum);

  printf("Number of boundaries after %d\n",srf->num_boundaries);
  
 wrapup:
  // Cleanup
  if ((srfOEx.obj_id.objid != NULL_OBJID) &&
      (srfOEx.obj_id.objid != srfOE->obj_id.objid)) {
    vdobj$Delete(objOE = &srfOEx);
  }
  
  return;
}
#endif

/* -----------------------------------------------
 * Frees the boundaries associated with the surface
 */
void VDgeomoFreeSurfaceBoundaryGeometry(TGRbsp_surface *srf)
{
  VDASSERT_FN("VDgeomoFreeSurfaceBoundaryGeometry");
  
  IGRint i;
  
  // Arg check
  VDASSERTW(srf);
  
  // Just to make sure have something
  if (srf->bdrys == NULL) goto wrapup;
  
  // Cycle through
  for(i = 0; i < srf->num_boundaries; i++) {
    free(srf->bdrys[i].points);
  }
  
  // Clean up
  free(srf->bdrys);
  srf->num_boundaries = 0;
  srf->bdrys = NULL;

 wrapup:
  return;
}

/* -----------------------------------------------
 * Wrappers for getting surface geometry
 */
void VDgeomoGetSurfaceGeometry(TGRobj_env *srfOE, TGRbsp_surface **srf) 
{
  VDgeomoGetGeometry(srfOE,(IGRchar**)srf);
}

/* -----------------------------------------------
 * Wrapper for getting curve
 */
void VDgeomoGetCurveGeometry(TGRobj_env *crvOE, TGRbsp_surface **crv) 
{
  VDgeomoGetGeometry(crvOE,(IGRchar**)crv);
}

/* -----------------------------------------------
 * Return a point and the normal at the point for the
 * surface object.
 * Copied from EFshow_normals1 mainly to help debugging
 */
IGRstat VDgeomoGetSurfaceNormal(TGRobj_env *srfOE, IGRpoint pt, IGRvector normal)
{
  VDASSERT_FN("VDgeomoGetSurfaceNormal");
  IGRstat retFlag = 0;
  IGRstat msg,sts;
  IGRint  i;
  
  struct EMparms params;

  TGRbsp_surface *srf = NULL; // Note: Don't free
  
  // Arg check
  VDASSERTW(normal);
  VDASSERTW(pt);
  VDASSERTW(srfOE && srfOE->obj_id.objid != NULL_OBJID);

  // Start by getting parameters of apoint
  sts = om$send(msg = message EMSsurface.
		EMget_point_on_surface(&msg, 
				       &srfOE->mod_env,0,1,NULL,&params),
		senderid = NULL_OBJID,
		targetid = srfOE->obj_id.objid,
		targetos = srfOE->obj_id.osnum);
  if (! (1 & msg & sts))
  {
    /*If any error continue ...*/
    params.u = .48;
    params.v = .48;   
    msg = EMS_S_Success;
    sts = OM_S_SUCCESS;
  }

  // Now get the surface
  VDgeomoGetSurfaceGeometry(srfOE,&srf);  
  if (srf == NULL) goto wrapup;

  // Pure majic
  EMavgsfnorm(&msg,srf,params.u,params.v,pt,normal);

  // Sometimes need to flip
  if (!srf->pos_orient) {
    for(i = 0; i < 3; i++) {
      normal[i] *= -1.0;
    }
  }
  
  
  // Done
  retFlag = 1;
  
 wrapup:

  return retFlag;
}

#if 0
IGRlong EFshow_normals1(msg, mdenv, active_display, display_mode,
                        ignore_pos_or, n_loc, objid, osnum)
IGRlong           *msg;
struct GRmd_env   *mdenv;
struct IGRdisplay *active_display;
enum GRdpmode     display_mode;
OMuword           ignore_pos_or;
IGRdouble         *n_loc;
GRobjid           objid;
OMuword           osnum;
{
  IGRboolean in_world_system = TRUE;
  IGRlong msg_loc, stat_OM;
  IGRdouble srfpt[3];
  IGRvector norm;
  GRrange range;
  struct IGRbsp_surface *srf;
  struct EMparms params;
  void EMavgsfnorm();
  extern IGRint IGEstop();


  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
 
  srf = NULL;

  /* Obtain a point in area on the surface.*/
  stat_OM = om$send(msg = message EMSsurface.EMget_point_on_surface(
                          &msg_loc, mdenv, 0, 1, NULL, &params),
                    senderid = NULL_OBJID,
                    targetid = objid,
                    targetos = osnum);
  if (! (1 & msg_loc & stat_OM))
  {
    /*If any error continue ...*/
    params.u = DRAW_U;
    params.v = DRAW_V;   
    msg_loc = EMS_S_Success;
    stat_OM = OM_S_SUCCESS;
  }

  if (n_loc)
  {
    n_loc[0] = params.u;
    n_loc[1] = params.v;
  }  

  /*
   * Obtain the surface's oriented average
   * unit normal.
   */
  
  if (! GRabsg_test(&msg_loc, &mdenv->md_env.matrix_type,
                    mdenv->md_env.matrix, &osnum, &objid, &srf))
  {
    msg_loc = MSFAIL;
    om$send(mode = OM_e_wrt_object,
            msg  = message GRvg.GRgenabsg(&msg_loc, &mdenv->md_env.matrix_type,
                   mdenv->md_env.matrix, (IGRchar **)&srf),
            senderid = objid,
            targetid = objid,
            targetos = osnum);
  }

  /******************************
  GRgetabsg (&msg_loc, &mdenv->md_env.matrix_type, mdenv->md_env.matrix,
   &srf, i);
  ******************************/
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  EMavgsfnorm (&msg_loc, srf, params.u, params.v, srfpt, norm);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
  if (msg_loc == EMS_I_NoSolution)
    {
    *msg = msg_loc;
    goto ret_end;
    }

  /*
   * Obtain the size of the normal to be drawn
   * as a defined fraction of the length of
   * the largest side of the range box. Phew!.
   */

  stat_OM = om$send(msg = message GRvg.GRgetrang (&msg_loc,
                         &mdenv->md_env.matrix_type, mdenv->md_env.matrix, 
                         &in_world_system, range),
                    senderid = NULL_OBJID,
                    targetid = objid,
                    targetos = osnum);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

  /*
   * Draw the vector
   */
   {
    extern void EFdraw_vector_on_screen();
    IGRboolean  reverse_vector=FALSE, toggle=FALSE;

    if (ignore_pos_or & 0x2)
    {
      toggle = TRUE;
      ignore_pos_or &= ~0x2;
    }

    if (!ignore_pos_or) reverse_vector = !srf->pos_orient;

    if (toggle) reverse_vector = !reverse_vector;

    EFdraw_vector_on_screen(
      objid,
      active_display,
      mdenv,
      display_mode,
      reverse_vector,
      srfpt,
      norm,
      range,
      msg);
     if (! (1 & *msg)) stat_OM = OM_E_ABORT;
   }

  if (IGEstop()) stat_OM = OM_I_STOP_SENDING;
  else if (*msg == EMS_I_Interrupt) stat_OM = OM_I_STOP_SENDING;
 
ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSsubbs.EFshow_normals1");
  return (stat_OM);
}
#endif

end implementation EMSsubbs;
