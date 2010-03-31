/* ###################   APOGEE COMPILED   ################## */
class implementation GRcompcurve;

#include "EMScc.h"
#include "OMminimum.h"
#include "msdef.h"
#include "grerr.h"    /* GR_E_INV_REQUEST */
#include "godef.h"
#include "gr.h"
#include "grgsdef.h"   /* GO_ ..... */
#include "ma.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bserr.h"

#define INSIDE    1
#define OVERLAP   2

method GRstretch(IGRlong *msg; struct GRmd_env *md_env;
	IGRshort *type_prism; IGRchar *prism;
	IGRmatrix xform_matrix; GRobjid *objid)

/*
Abstract:
    This method does a stretch fence contents operation on a composite
    curve.  The object is assumed to be either overlapping or inside the
    prism.

Arguments
    GRstretch(msg, md_env, type_prism, prism, xform_matrix, objid)

    IGRlong    *msg               return code
    struct GRmd_env *md_env       environment information
    IGRshort        *type_prism	  type of prism
                                     GRCURVE_PRISM
                                     GRRIGHT_PRISM
                                     (defined in godef.h)
    IGRchar         *prism        prism
    IGRmatrix       xform_matrix  transformation matrix
    GRobjid         *objid        object id after transformation

Return Values
    MSSUCC - successful completion
    MSFAIL - failure of routine

History
    dhm    09/30/88    creation date.
    dhm    01/26/89    changed to only send the GRstretch message to the
                       components inside or overlapping the fence.

*/

{
  IGRlong     msg_loc, status, prism_rel, relation;
  IGRint      i;
  IGRchar     errmsg[EMMAXERRMSG_LEN];
  IGRuint   count;
  OM_S_CHANSELECT   to_comps;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg,"GRcompcurve.GRstretch\n");

  /*
   * Initialize the channel selector
   */

  status = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Get the number of components.
   */

  status = om$get_channel_count(object = me,
                                p_chanselect = &to_comps,
                                count = &count);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Get the relationship of each component to the prism.
   * If it is inside or overlapping the prism (fence), then
   * send the GRstretch message to that component.  dhm  1/26/89.
   */

  prism_rel = GO_INSIDE | GO_OVERLAP;

  for (i = 0; i < count; i++)
  {
    status = om$send(msg = message GRowner.GRprismrel(&msg_loc,
                           &md_env->md_env.matrix_type,
                           md_env->md_env.matrix, &prism_rel, type_prism,
                           prism, &relation),
                     senderid = my_id,
                     p_chanselect = &to_comps,
                     from = i, to = i);
    if (msg_loc == GR_E_INV_REQUEST)   status = OM_S_SUCCESS;
    EMomerr_hndlr(status, ret_end, errmsg);

    if ( (relation == INSIDE) || (relation == OVERLAP) )
    {
      status = om$send(msg = OPPmargs,
                       senderid = my_id,
                       p_chanselect = &to_comps,
                       from = i, to = i);
      EMomerr_hndlr(status, ret_end, errmsg);
    }

  }  /* end for loop */


  ret_end:
    return(status);
}

end implementation GRcompcurve;
