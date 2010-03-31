/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

#include "EMS.h"
# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS error codes  */
# endif

# ifndef emserr_include
# include "emserr.h"        /* EMWRAPUP         */
# endif

method EMgetGraphics(IGRlong *EMmsg; IGRchar *rlt_buffer;
                     IGRint rlt_buffer_size; struct IGResqbs **rlt;
                     IGRshort *mx_type; IGRmatrix mx; GRobjid surf_id;
                     struct IGRbsp_surface *in_surface, **out_surface)
{
  IGRlong   sts = OM_S_SUCCESS;

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
   * Return the input geometry
   */
  *out_surface = in_surface;

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSgradata.EMgetGraphics")
  return(sts);
}

end implementation EMSgradata;
