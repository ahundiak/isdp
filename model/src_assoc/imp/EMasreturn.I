/* ###################   APOGEE COMPILED   ################## */
class implementation EMSassoc;

#include "EMS.h"
#include "parametric.h"
#include "exmacros.h" /* For ex$get_modid */
#include "nddef.h" /* For ND_DROP_MAX */
#include "emserr.h"
#include "EMSerrordef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h" /* For gr$get_module_env */
#include "OMmacros.h"
#include "EMSkey.h"

method ASreturn_go ( struct GRid * go;
                     IGRshort    * mat_type;
                     IGRdouble   * matrix )
{
    IGRlong         msg;
    struct GRmd_env mod_env;
    IGRint          sizbuf, nret;

    go->objid = my_id;
    go->osnum = OM_Gw_current_OS;


    if (matrix && mat_type)
    {
      sizbuf = sizeof(struct GRmd_env);

      gr$get_module_env ( msg = &msg,
                            sizbuf = &sizbuf,
                            buffer = &mod_env,
                            nret = &nret );

      *mat_type = mod_env.md_env.matrix_type;    

      memcpy (matrix, mod_env.md_env.matrix, sizeof(IGRmatrix));
    }

    return OM_S_SUCCESS;
}

method ACbecome_macro(IGRlong *msg; 
                      IGRint position;
		      struct GRmd_env *md_env)

/* ***************************************************************************
Description 
 This object returns the type of macros that can be constructed with this
 object. At this time it is only valid for drop macro placement and hence
 will return a completion code of ND_DROP_MAC.
*************************************************************************** */
{
 *msg = ND_DROP_MAC | ND_CONS_MAC;
 return (OM_S_SUCCESS);
}

method NDcopy_graph(IGRlong *EMmsg;IGRint cp_type;
  		    struct GRmd_env *fr_env,*to_env;
		    struct NDcp_list *list;
                    int list_count;
		    int position)
{
 IGRlong msg_loc;
 OM_S_CHANSELECT children;

 *EMmsg = MSSUCC;

 EMmake_chanselect (NDchildren_children, &children);

 om$send (msg = message EMSpointerA.EMstore_key_from_id(&msg_loc,
                          EMS_OPT_STORE_ID, NULL),
                    p_chanselect = &children);

 return (om$send (msg = message EMSassoc.NDcopy_graph(EMmsg, cp_type, fr_env,
                        to_env, list, list_count, position),
                  mode = OM_e_wrt_parent,
                  targetid = my_id));
}
end implementation EMSassoc;


