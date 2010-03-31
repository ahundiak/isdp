class implementation EMSplane;

#include "emsimpdef.h"
#include "EMSprop.h"
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "emsmapdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSfrtdef.h"
#include "EMSdpr.h"


IGRlong EMget_planar_geometry( IGRlong *msg,
                               IGRint num_surfs,
                               GRobjid *surfs,
                               GRobjid new_surf,
                               struct GRvg_construct construct_list)

{
 IGRlong                           sts;
 IGRint                            i, j; 
 OM_S_CHANSELECT                   to_loopset, to_common_edge;
                                   
 struct IGRbsp_surface             *surface=NULL, plane;
 GRrange                           myrange, plane_range;
 IGRboolean                        world_range = TRUE, inrange;
 IGRdouble                         plane_u_knots[4], plane_v_knots[4],
                                   scale_factor, chtol;
 struct IGRplane                   locplane;
 IGRvector                         locplnormal;
 IGRpoint                          *rngpt = NULL, *plpts = NULL,
                                   plane_poles[4], locplpt;
 IGRint                            num_plpts, num_surf_pt, num_rng_pt;
 BSrc                              rc;
 struct GRmd_env                   *md_env=NULL;
 IGRlong                           surf_size;

 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 num_plpts = 0;
 num_rng_pt = 0;
 md_env = construct_list.env_info;

 EMmake_chanselect ( EMSedge_to_common_edge, &to_common_edge );
 EMmake_chanselect ( EMSsubbs_to_loopset, &to_loopset);

 BSEXTRACTPAR(&rc, BSTOLCHRDHT, chtol);

 /* Get the range of all surfaces */

 rngpt = (IGRpoint *) om$malloc (size = (2 * num_surfs)
                                 * sizeof (IGRpoint));

 for (i=0; i<num_surfs; i++)
 {
  sts = om$send ( msg = message GRvg.GRgetrang ( msg, 
                  &md_env->md_env.matrix_type, md_env->md_env.matrix,
                  &world_range, myrange),
           senderid = NULL_OBJID,
           targetid = surfs[i]);
  EMomerr_hndlr (sts, ret_end, ""); 
  for (j=0; j<3; j++)
  {
   rngpt[num_rng_pt][j] = myrange[j];
   rngpt[num_rng_pt + 1][j] = myrange[3 + j];
  }

  num_rng_pt += 2;
 
  num_surf_pt = 0;

  sts = om$send ( msg = message GRvg.GRgetsize ( msg,
                  &md_env->md_env.matrix_type, md_env->md_env.matrix,
                  &surf_size),
           senderid = NULL_OBJID,
           targetid = surfs[i]);
  EMomerr_hndlr (sts, ret_end, "GRvg.GRgetsize"); 

  surface = (struct IGRbsp_surface *) alloca(surf_size);

  sts = om$send ( msg = message EMSsubbs.GRgetgeom( msg,
                  &md_env->md_env.matrix_type,
                  md_env->md_env.matrix, (IGRchar *) surface),
          senderid = NULL_OBJID,
          targetid = surfs[i]);
  EMomerr_hndlr (sts, ret_end, "EMSsubbs.GRgetgeom"); 

  num_surf_pt = surface->u_num_poles * surface->v_num_poles;
/* fix for abr & abw */
  if(!num_plpts)
  {
    plpts = (IGRpoint *) om$malloc (size = (num_surf_pt)
             * sizeof (IGRpoint));
    EMerr_hndlr (! plpts , *msg, EMS_E_NoDynamicMemory, ret_end );
  }
  else
  {
    plpts = (IGRpoint *) om$realloc (ptr = (IGRchar *)plpts, size = 
            (num_plpts + num_surf_pt) * sizeof (IGRpoint));
   EMerr_hndlr (! plpts , *msg, EMS_E_NoDynamicMemory, ret_end );
  }
     
  if (surface->rational && surface->weights)
  {
   (void) BSunwght_p ( &rc, surface->poles, surface->weights, 
                       &num_surf_pt, plpts[num_plpts]);
  }
  else OM_BLOCK_MOVE ( surface->poles, &plpts[num_plpts],
                       num_surf_pt * sizeof(IGRpoint));
  
  num_plpts += num_surf_pt;
  
 }

 /* Get the range encompassing all surfaces */

 BSbx2 (msg, &num_rng_pt, rngpt, NULL, &plane_range[0], 
        &plane_range[3]);

 /* Construct a plane having this range */

 plane.poles = (IGRdouble *) plane_poles;
 plane.u_knots = (IGRdouble *) plane_u_knots;
 plane.v_knots = (IGRdouble *) plane_v_knots;
 plane.weights = NULL;

 scale_factor = 1.1;

 locplane.point = locplpt;
 locplane.normal = locplnormal;
 
 sts = MAdetplane ( msg, plpts, &num_plpts, &chtol, &locplane );
 EMomerr_hndlr (sts, ret_end, "MAdetplane"); 

 BSplptnorrg ( &plane_range[0], &plane_range[3], locplane.point,
               locplane.normal, scale_factor, &inrange, &plane, 
               &rc );

 sts = EMorient_plane ( msg, surface->poles, &plane, NULL );
 EMomerr_hndlr (sts, ret_end, "EMorient_plane"); 

 construct_list.geometry = (IGRchar *) &plane;
 
  sts = om$send ( mode = OM_e_wrt_object,
                  msg = message GRgraphics.GRconstruct
                  ( &construct_list),
           senderid = NULL_OBJID,
           targetid = new_surf);
  EMomerr_hndlr (sts, ret_end, "GRgraphics.GRconstruct");


 ret_end:


 return(sts);

}

end implementation EMSplane;
