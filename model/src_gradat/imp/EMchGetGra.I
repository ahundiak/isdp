/* ###################   APOGEE COMPILED   ################## */
class implementation EMSchatch;

#include "EMS.h"
# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS error codes  */
# endif

# ifndef emserr_include
# include "emserr.h"        /* EMWRAPUP */
# endif

method EMgetGraphics(IGRlong *EMmsg; IGRchar *rlt_buffer;
                     IGRint rlt_buffer_size; struct IGResqbs **rlt;
                     IGRshort *mx_type; IGRmatrix mx; GRobjid surf_id;
                     struct IGRbsp_surface *in_surface, **out_surface)
{
  IGRlong   sts = OM_S_SUCCESS;
  void      EFget_xh_sf_geom();

  /*
   * Initialize
   */
  *EMmsg = EMS_S_Success;

  /*
   * Get my rule line table
   */
  sts = om$send(msg = message EMSgradata.EMgetRLT(EMmsg,
                rlt_buffer, rlt_buffer_size, rlt), targetid=my_id);
  if(! (1 & *EMmsg & sts)) goto wrapup;

  /*
   * Get the transformed surface
   */
  if(! *out_surface)
  {
    IGRint                  total_bytes;

    EMSbs_size(in_surface->u_order, in_surface->v_order,
               in_surface->u_num_poles, in_surface->v_num_poles,
               in_surface->rational, 0, (IGRlong *)NULL, total_bytes)

    *out_surface = (struct IGRbsp_surface *)om$malloc(size=total_bytes);
    if(!(*out_surface)) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }

    EMSbs_partition(in_surface->u_order, in_surface->v_order,
                    in_surface->u_num_poles, in_surface->v_num_poles,
                    in_surface->rational, 0, (IGRlong *) NULL,
                    *out_surface)
  }

  EFget_xh_sf_geom(EMmsg, me^^EMSchatch.angle, NULL, NULL, in_surface,
                   *out_surface);

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSchatch.EMgetGraphics")
  return(sts);
}

end implementation EMSchatch;
