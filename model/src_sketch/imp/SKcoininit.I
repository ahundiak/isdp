class implementation SKcoincident;

#include <math.h>
#include "OMmacros.h"
#include "SKdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSopt.h"

extern OMuword OPP_SKhorizvert_class_id;

method SKinit (IGRlong *msg; IGRushort options;
               struct GRmd_env *md_env;
               IGRint num_pts; GRobjid *pt_ids;
               IGRushort cnstr_props;
               GRobjid *geom_handle;
               IGRchar *moreinfo)
{
 IGRlong  OM_stat;
 IGRint   i;
 GRobjid  cnstr_ids[2];

 /* ************************************************************** */

 *msg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 /*
  * Coincident constraint between 2 points is established by imposing,
  *  o A horizontal constraint between the points.
  *  o A vertical constraint between the points.
  */

 for (i = 0; i < 2; i++)
  {
   OM_stat = om$construct (classid = OPP_SKhorizvert_class_id,
                         p_objid = &cnstr_ids[i]);
   EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

   OM_stat = om$send (msg = message SKconstraint.SKinit (msg,
                       ((options | SK_OPT_NO_MGR_CONNECT) & 
                                  ~SK_OPT_CREATE_GEOMETRY),
                       md_env,
                       2, pt_ids, i == 0 ? SK_HORIZONTAL : NULL,
                       NULL, NULL),
                       targetid = cnstr_ids[i]);
   EMerr_hndlr (!(1&OM_stat&*msg), *msg, EMS_E_Fail, wrapup);

   OM_stat = om$send (msg = message SKinterface.SKconnect_to_member
              (msg, NULL, cnstr_ids[i], MAXINT, MAXINT),
              targetid = my_id);
   EMerr_hndlr (EMSerror (OM_stat & *msg), *msg, EMS_E_OMerror, wrapup);
  } /* for (i = 0; i < 2; i++) */

  /*
   * Having constructed the member constraints, this interface constraint is
   * then initialized using the default method.
   */

  OM_stat = om$send (mode = OM_e_wrt_parent,
             msg = message SKinterface.SKinit (msg,
             (options & ~SK_OPT_NO_MGR_CONNECT) | SK_OPT_NO_CONNECT_PTS,
             md_env, 2, pt_ids, cnstr_props, geom_handle, moreinfo),
             targetid = my_id);
  EMerr_hndlr (EMSerror (OM_stat & *msg), *msg, EMS_E_OMerror, wrapup);

wrapup:
 EMWRAPUP (*msg, OM_stat, "SKcoincident.SKinit");
 return(OM_stat);
} 

end implementation SKcoincident;
