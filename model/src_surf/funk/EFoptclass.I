class implementation Root;

from GRgraphics import GRconstruct;
from EMSsurface import EMmk_nat_bdry;
from GRvg import GRchgprops;

%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"
#include "EMSmsgdef.h"            /* EMS_I_NotFound */
#include "EC_M.h"            /* Command strings */
#include "EC_P.h"      /* Prompt strings */
#include "EC_I.h"      /* Informational strings */
#include "EC_F.h"      /* Fatal strings */
#include "FI.h"
#include "emsdef.h"
#include "emserr.h"
#include "REsfsolid.h"
#include "emsmass.h"
#include "bsgeom_cvsf.h"
#include "EMSsfparms.h"
#include "bsconic.h"
#include "bssrmktsncg.h"
#include "bssftgeomsf.h"
#include "bssf_rev.h"
#include "bssf_copy.h"
#include "bsmergsfnna.h"
#include "bsfreesf.h"
#include "bsarclnpars.h"
#include "bsallocsf.h"
#include "godef.h"

/*

Name
  EFspecial_case_from_geom

Abstract
  This function will create an optimized surface object from input
  geometry. That is, it will create a cylinder, torus, plane or whatever
  if the geometry passed in is suitable.
Synopsis

Description
  OUT:IGRlong *EMmsg: status message.
  IN:struct IGRbsp_surface *geometry: the geometry of the surface to construct. 
  IN:struct GRvg_construct *construct_list: construction list.
  OUT:GRobjid *res_surf_objid: object id of the newly created object.
  
Return Value
  EMS_E_Fail
  EMS_S_Success

Notes

Index

Keywords

History
  01/14/94 : Carlos M. Diaz : created

 */
IGRlong EFspecial_case_from_geom (IGRlong *EMmsg, 
	struct IGRbsp_surface *geometry, 
	struct GRvg_construct *construct_list,
	GRobjid *res_surf_objid)

{
  IGRlong status, msg_loc;
  GRobjid part_surf_objid;
  struct IGRbsp_surface *p_polished_surface;
  IGRboolean stsfree;
  struct         BSgeom_bsp_surf merged_sf_struct;
  void           getsfclassid();
  OMuword        sf_classid = 0;
  IGRint         num_uknots = 0;
  IGRint         num_vknots = 0;
  IGRdouble      *uknots = NULL;
  IGRdouble      *vknots = NULL;
  BSrc		 rc;

  /*
          * reparameterize the knots, the math that removes excess knots
          * requires this be done.
          */
  BSarclnpars( &rc, 2, geometry);
  if (rc != BSSUCC) {
    *EMmsg = MSFAIL; 
    goto wrapup;  
  }

  BSallocsf(
      geometry->u_order,
      geometry->v_order,
      geometry->u_num_poles,
      geometry->v_num_poles,
      geometry->rational,
      0,                            /* No boundaries */
  &p_polished_surface,
      &rc);
  if (rc != BSSUCC) {
    *EMmsg = MANOMEMORY;
    goto wrapup;  
  }
  /*
     * BStst_plan
     */
  {
    IGRvector plane_vector;
    IGRint num_poles;

    num_poles = ((geometry->u_num_poles)
        *
        (geometry->v_num_poles));
    BStst_plan (num_poles,
        geometry->poles,
        geometry->weights,
        &geometry->planar,
        plane_vector,
        &rc);
  }
  /*
          * remove any excess knots without changing the shape of the surface
          */
  uknots = (IGRdouble *) alloca(geometry->
      u_num_poles * sizeof(IGRdouble));
  vknots = (IGRdouble *) alloca(geometry->
      v_num_poles * sizeof(IGRdouble));
  BSsrmktsncg(geometry,
      FALSE,0.0,FALSE,
      p_polished_surface,              
      &num_uknots,
      &num_vknots,
      uknots,
      vknots,
      &rc);
  if (rc != BSSUCC) {
    *EMmsg = MSFAIL;
    goto wrapup;  
  }

  merged_sf_struct.bspsf = p_polished_surface;
  merged_sf_struct.type = NULL;
  merged_sf_struct.sfgen_cv = NULL;
  BSsftgeomsf(&merged_sf_struct,
      TRUE,
      100,
      &rc);

  if(rc != BSSUCC) {
    *EMmsg = MSFAIL; 
    goto wrapup;  
  }
  getsfclassid( merged_sf_struct.type,
      &sf_classid);
#ifdef DEBUG
  printf ("Type of surface is: %d\n",merged_sf_struct.type);
  printf ("Classid for that type is %d\n",sf_classid);
#endif
  status = om$construct ( classid =  sf_classid, 
      osnum   =  OM_Gw_current_OS, 
      p_objid = &part_surf_objid,
      neighbor = OM_GS_NULL_NEIGHBOR);
  if (!(1&status)) goto wrapup;
  /*
     * Fill the instance data
     */
  construct_list->geometry = (IGRchar *) p_polished_surface;
  construct_list->newflag = FALSE; /* (actually means true) */

  status = om$send(mode = OM_e_wrt_object,
      msg = message GRgraphics.GRconstruct(
      construct_list),
      senderid = NULL_OBJID,
      targetos = OM_Gw_current_OS,
      targetid = part_surf_objid);
  construct_list->geometry = NULL;
  if (!(1 & status)) goto wrapup;

  /* set planarity so that convert_into_plane will work */
  if (p_polished_surface->planar) {
    IGRshort props = GRIS_PLANAR;
    IGRshort action = 1;
    status = om$send( msg = message GRgraphics.GRchgprops(
        &msg_loc,
        &action,
        &props),
        senderid = NULL_OBJID,
        targetos = OM_Gw_current_OS,
        targetid = part_surf_objid);
    if (!(1 & status & msg_loc)) goto wrapup;
  }

  *res_surf_objid = part_surf_objid;

#ifdef DEBUG
  printf ("Constructed surface %d\n", *res_surf_objid);
#endif    

/*
 fix for FMR
  stsfree = BSfreesf (&rc,geometry);
  geometry = NULL;
*/

  stsfree = BSfreesf (&rc,p_polished_surface);
  p_polished_surface = NULL;

  status = om$send ( msg = message EMSsurface.EMmk_nat_bdry
      ( &msg_loc, 
      &construct_list->env_info->md_env,
      NULL),
      senderid = NULL,
      targetid = part_surf_objid);
  if (!(1&status)) EFprintcode(0,status);
  EMerr_hndlr (!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  status = EMconvert_into_plane(&msg_loc, NULL, NULL, NULL, NULL, NULL, NULL,
      NULL, construct_list->env_info, part_surf_objid, OM_Gw_current_OS);
  if (!(1&status)) EFprintcode(0,status);
  EMerr_hndlr (!(1&status&msg_loc), *EMmsg, EMS_E_OMerror, wrapup);

wrapup:
  if (!(1&status&msg_loc))
    return EMS_E_Fail;
  else 
    return EMS_S_Success;
}

end implementation Root;
