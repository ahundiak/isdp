/*
NAME:
    EFget_dimensioning_information

ABSTRACT:
    This function determines and returns information needed for dimensioning
    of 'thinwall'solids/'offset' surfaces. This function determines the
    surface, and the 'u,v' point on the surface for each of the specific
    thickness values/offset distances. It determines the common thickness/
    offset dimensioning surface also. 

ARGUMENTS:

RETURN VALUES:

DESCRIPTION:

NOTES:

KEYWORDS:

HISTORY:
   Sudhakar : 26May'93  : Creation. Used in 'Pl. Of. Su command object'
                          (file : src_testco/imp/ECcsoffseti.I) and the
                          'Make Thinwall' command object.
   Sudha    :  07/02/93 : Modified for BSprototypes ansification
   Sudhakar : 24Sep'93  : Modified to return the dimensioning info in terms
                          of surfaces and 'u,v' points on the surfaces.
                          Deleted two arguments and added one. Changed the
                          name of the function from 
                          'EMget_edges_near_locpts_and_views' to read
                          'EFget_dimensioning_information'.
   Sudhakar : 23Nov'93  : Provided fix for TR# 119312355.
   Sudhakar : 12Jan'94  : Fix for TR# 119415326.
*/
    
class implementation ECcsoffset;

#include "EMS.h"
#include <stdio.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "gocmacros.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "bserr.h"
#include "bsconic.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "emsmapdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emserr.h"
#include "emsbool.h"
#include "bsmdistptsf.h"

struct dimension_info 
{
  GRobjid    surf;
  IGRpoint   uv_point;
  OMuword    view_index;
};
  

from EMSloopset import EMpt_location, EMget_edges;
from EMSsubbs   import EMpartolbasis;
from GRvg       import GRgetsize, GRgetgeom;
from EMSboundary import EMget_objid;
from EMSedge     import EMgetsurface_info;
from EMSsubbs    import EMputLsIfNotThere;

IGRlong EFget_dimensioning_information(msg, modenv,
                  common_surf, common_surf_pt,
                  num_spec_tks, 
                  num_sfs_per_tk,
                  spec_surf_ids, locpt, num_opensfs, opensfs,
                  dimension_info)
IGRlong *msg;
struct GRmd_env *modenv;
struct GRid  common_surf;
IGRpoint common_surf_pt;
IGRint                  num_spec_tks;
IGRint                  *num_sfs_per_tk;
GRobjid                 *spec_surf_ids;
IGRpoint                *locpt;
IGRint                  num_opensfs;
GRobjid                 *opensfs;
struct dimension_info   *dimension_info;
{

 IGRint ii, num_sfs;
 IGRlong  sts;
 GRspacenum   thisos;
 GRobjid      current_sf, *common_surfaces = NULL;
 IGRpoint     current_pt;
 IGRboolean   found = FALSE, is_member=FALSE;
 IGRint       sf_ind, list_size;
 struct GRid  sf_grid;
 IGRpoint     uv_pt;

 IGRlong EFget_surfaces_across_common_edges();
 IGRlong EFget_uv_pt_on_sf();
 IGRboolean EFis_member();


 sts     = OM_S_SUCCESS;
 *msg  = EMS_S_Success;

 
 /* 
    For each of the special thicknesses, find the first surface associated
     with that thickness and the 'u,v' point on the surface which was used
     to identify the surface. Fill in the information into the output
     'dimensioning_info' structure.
       
    For the common surface
      Check if it is a member of any of the 'special thickness surfaces'
       or 'open surfaces'.
      If member
              Find the nearest neighbouring surface which is not a member
              of the above two lists and call it the common surface.

      Project the u,v point on the original surface onto the 
      new surface and store the new u,v point.

      Repeat the steps described above for special thickness surfaces for
      this common surface.
  */

  thisos  = common_surf.osnum; 
  num_sfs = 0; 
  if(num_spec_tks)
  {
    for(ii=0; ii<num_spec_tks; ii++)
    {
      current_sf = spec_surf_ids[num_sfs];
      OM_BLOCK_MOVE (locpt[ii], current_pt, sizeof (IGRpoint));

      sf_grid.objid = current_sf;
      sf_grid.osnum = thisos;

     /* Convert the 'xyz' locate point to 'u,v' of the surface */
      sts = EFget_uv_pt_on_sf(msg, modenv, sf_grid, current_pt, uv_pt);
      EMerr_hndlr(!(sts&1), *msg, sts, ret_end);

     /* Fill in the 'output' structure. */
      dimension_info[ii + 1].surf = current_sf;
      OM_BLOCK_MOVE(uv_pt, dimension_info[ii + 1].uv_point, sizeof(IGRpoint)); 
      dimension_info[ii + 1].view_index = 1;
      
  /* Find the best view index. - TBD */

  /* Increment the index */
      num_sfs += num_sfs_per_tk[ii];

    } /* end of for(ii......) loop */

  } /* end of if(num_spec_tks).. */

 /* Check whether 'common_surf' is member of any of the lists */

  /* allocate memory for surface list */
  common_surfaces = (GRobjid *) om$malloc (size = sizeof(GRobjid));
  EMerr_hndlr(!common_surfaces,*msg,EMS_E_NoDynamicMemory,ret_end);

  common_surfaces[0] = common_surf.objid;
  found = FALSE;
  sf_ind = 0;
  list_size = 1;

  while (!found)
  {
    current_sf = common_surfaces[sf_ind];
    is_member = FALSE;
    is_member |= EFis_member(current_sf, num_opensfs, opensfs);
    is_member |= EFis_member(current_sf,
                                 num_sfs, spec_surf_ids);
    if(is_member)
    {
      if(sf_ind >= list_size-1)
      {
        sts = EFget_surfaces_across_common_edges(msg, thisos, 
                                           current_sf,
                                           &list_size,
                                           &common_surfaces);
        EMerr_hndlr(!(sts&1), *msg, sts, ret_end);
      }
      sf_ind++;
    }
    else
    {
      found = TRUE;
    }
  }

  /* Find edge and 'view' for the 'current_sf'. */

    OM_BLOCK_MOVE (common_surf_pt, current_pt, sizeof (IGRpoint));

    sf_grid.objid = current_sf;
    sf_grid.osnum = thisos;

   /* Convert the 'xyz' locate point to 'u,v' of the surface */
    sts = EFget_uv_pt_on_sf(msg, modenv, sf_grid, current_pt, uv_pt);
    EMerr_hndlr(!(sts&1), *msg, sts, ret_end);

   /* Fill in the 'output' structure. */
    dimension_info[0].surf = current_sf;
    OM_BLOCK_MOVE(uv_pt, dimension_info[0].uv_point, sizeof(IGRpoint)); 
    dimension_info[0].view_index = 1;

  /* Find the best view index  for common_thickness_dimension_surface */

 ret_end:

   if(common_surfaces) om$dealloc(ptr = common_surfaces);

   return(sts);

}

 /**********************************************************/
 IGRlong EFget_uv_pt_on_sf(msg, modenv, sf_grid, current_pt, uv_pt)
 IGRlong  *msg;
 struct GRmd_env  *modenv;
 struct GRid      sf_grid;
 IGRpoint         current_pt;
 IGRpoint         uv_pt;

{

 IGRlong  msg_loc, sts;
 struct EMSpartolbasis   sfpartol;
 OM_S_CHANSELECT         sf_ls_chan;
 IGRdouble               u,v, min_dist /*, dist_from_edge */;
 IGRdouble               proj_locpt[3];
 IGRboolean              in_world=TRUE, ls_created = FALSE;
 struct IGRbsp_surface   *sf_geom=NULL;
 IGRlong                 sf_size=0;
 GRobjid                 current_sf;
 GRspacenum              thisos;

 sts     = OM_S_SUCCESS;
 *msg  = EMS_S_Success;

 sts = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
 EMerr_hndlr (!(1&sts),*msg,EMS_E_OMerror, ret_end);

 current_sf = sf_grid.objid;
 thisos     = sf_grid.osnum;
 
 min_dist         = MAXDOUBLE;

  /* Make sure the surface has a 'loopset' before proceeding. */
    sts = om$send (msg = message EMSsubbs.EMputLsIfNotThere(&msg_loc,
                          &(modenv->md_env), NULL, NULL, 0, &ls_created),
                   targetid = current_sf,
                   targetos = thisos,
                   senderid = NULL_OBJID);
    EMerr_hndlr(!(msg_loc&sts&1), *msg, EMS_E_LoopsetError, ret_end);
#ifdef DEBUG
 if(ls_created)
   printf("Loopset created for surface id = %d\n", current_sf);
#endif

  /* get the parametric tolerance on this surface */

    sts = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                                       &(modenv->md_env.matrix_type),
                                        modenv->md_env.matrix,
                                       &in_world, FALSE, &(sfpartol.tol)),
                   targetid = current_sf,
                   targetos = thisos,
                   senderid = NULL_OBJID);
    EMerr_hndlr(!(msg_loc&sts&1), *msg, msg_loc, ret_end);
    sfpartol.is_valid = TRUE;

  /* get size of surface geometry */
     sts = om$send(msg = message GRvg.GRgetsize(
                &msg_loc,
                &(modenv->md_env.matrix_type),
                modenv->md_env.matrix,
                &sf_size),
               senderid = NULL_OBJID,
               targetid = current_sf,
               targetos = thisos);
     EMerr_hndlr(!(1&sts&msg_loc),*msg,msg_loc,ret_end);

  /* allocate memory for surface geometry */
    sf_geom = (struct IGRbsp_surface *) om$malloc (size = sf_size);
    EMerr_hndlr(!sf_geom,*msg,EMS_E_NoDynamicMemory,ret_end);

  /* Get the surface geometry.*/
    sts = om$send(msg = message GRvg.GRgetgeom(
                &msg_loc,
                &(modenv->md_env.matrix_type),
                modenv->md_env.matrix,
                (IGRchar *) sf_geom),
               senderid = NULL_OBJID,
               targetid = current_sf,
               targetos = thisos);
    EMerr_hndlr(!(msg_loc&sts&1), *msg, msg_loc, ret_end);


  /* project pt. onto surface just to make sure it lies on surface*/
    sts = BSmdistptsf( (BSrc *)&msg_loc, sf_geom, current_pt, &u,&v,
                       proj_locpt, &min_dist);
    EMerr_hndlr (!(sts&1) || BSERROR(msg_loc), *msg, EMS_E_BSerror, ret_end);

  /* Return the UV point */
    uv_pt[0] = u;
    uv_pt[1] = v;

ret_end:

  if(sf_geom) om$dealloc(ptr = sf_geom);
  return(sts);
}
/*****************************************************************/
  IGRboolean EFis_member(this_sf, num_sfs, sf_id_list)
  GRobjid  this_sf;
  IGRint   num_sfs;
  GRobjid  *sf_id_list;
{
 
 IGRint ii;
 IGRboolean is_member = FALSE;

 if(num_sfs)
 {
   for(ii=0; ii<num_sfs; ii++)
         if(this_sf == sf_id_list[ii])
            is_member = TRUE;
 }

 return(is_member);
}
/*****************************************************************/
 IGRlong EFget_surfaces_across_common_edges(msg, thisos,
                                         current_sf,
                                         num_sfs,
                                         common_surfaces)
 IGRlong *msg;
 GRspacenum   thisos;
 GRobjid current_sf;
 IGRint  *num_sfs;
 GRobjid **common_surfaces; 
{
 IGRlong msg_loc, sts;
 IGRint buff_size, num_edges, kk; 
 struct GRid  *edges=NULL, comm_surf, comm_ed;
 GRobjid  *input_sf_list = NULL, *unique_sf_list = NULL;
 GRobjid  current_edge, common_edge;
 IGRint  input_num, unique_sf_count;
 OMuint  count;
 OM_S_CHANSELECT         sf_ls_chan, chan_to_cm_ed;

 /* STEPS:
 
    1. Get all the edges of the 'current_sf' which have a common-edge
       connection.
    2. Get the corresponding list of common surfaces.
    3. Append the list of surfaces to the list passed in ('common_surfaces')
       after weeding out those which are already present.
  */ 

 sts     = OM_S_SUCCESS;
 *msg  = EMS_S_Success;

 sts = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
 EMerr_hndlr (!(1&sts),*msg,EMS_E_OMerror, ret_end);
 sts = EMmake_chanselect (EMSedge_to_common_edge, &chan_to_cm_ed);
 EMerr_hndlr (!(1&sts),*msg,EMS_E_OMerror, ret_end);


 input_sf_list = *common_surfaces;
 input_num     = *num_sfs;

 /* Get all the edges in the loopset */
 buff_size = num_edges = 0;
 edges = NULL;
 sts = om$send(msg = message EMSloopset.EMget_edges(&msg_loc, 1,
                       EMS_OPT_STITCHED_ALL, &edges, &buff_size, &num_edges),
                       senderid = current_sf,
                       targetos = thisos,
                       p_chanselect = &sf_ls_chan); 
 EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_LoopsetError,
                       ret_end);

 unique_sf_list = (GRobjid *) om$malloc (
                           size = num_edges * sizeof(GRobjid));
 EMerr_hndlr(!(unique_sf_list),*msg, EMS_E_DynamicMemoryAllocated, ret_end);
 
 unique_sf_count = 0;
 for(kk=0; kk<num_edges; kk++)
 {
   current_edge = edges[kk].objid;
   common_edge = NULL_OBJID;
   /* Get the common edge and common-edge-surface if it exists */
   count = 0;
   sts = om$get_channel_count(objid = current_edge,
                              osnum = edges[kk].osnum,
                        p_chanselect = &chan_to_cm_ed, 
                               count = &count);
   EMerr_hndlr (!(1&sts), *msg, EMS_E_OMerror, ret_end);
   if(count) /* common edge exists */
   {
     comm_ed.osnum = edges[kk].osnum;
     sts = om$send(msg = message EMSboundary.EMget_objid(&msg_loc,
                                                       &comm_ed.objid),
                   senderid = current_edge,
                   targetos = edges[kk].osnum,
                   p_chanselect = &chan_to_cm_ed);
     EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_EdgeError,
                             ret_end);
     comm_surf.osnum = edges[kk].osnum;

     sts = om$send(msg = message EMSedge.EMgetsurface_info(&msg_loc,
                                                     &comm_surf.objid, NULL),
                   senderid = NULL_OBJID,
                   targetid = comm_ed.objid,
                   targetos = comm_ed.osnum);
     EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_EdgeError,
                             ret_end);
   }
   else
   {
#ifdef DEBUG
     printf("*** Common-edge & Surface not existing ***\n");
#endif
     sts = OM_E_ABORT;
     goto ret_end;
   }

   if(!EFis_member(comm_surf.objid, input_num, input_sf_list))
   {
     unique_sf_list[unique_sf_count] = comm_surf.objid;
     unique_sf_count++;
   }
 }

 if(unique_sf_count > 0)
 {
    input_sf_list = (GRobjid *) om$realloc (ptr = (char *)input_sf_list,
                      size = (input_num + unique_sf_count) * sizeof(GRobjid));
    EMerr_hndlr(!(input_sf_list),*msg, EMS_E_DynamicMemoryAllocated, ret_end);

    for(kk=0; kk<unique_sf_count; kk++)
    {
     input_sf_list[input_num + kk] = unique_sf_list[kk];
    }
 }

 *num_sfs = input_num + unique_sf_count;
 *common_surfaces = input_sf_list;

ret_end:
 
 if(edges) om$dealloc(ptr=edges);
 if(unique_sf_list) om$dealloc(ptr = unique_sf_list);

 return(sts);
}

end implementation ECcsoffset;
