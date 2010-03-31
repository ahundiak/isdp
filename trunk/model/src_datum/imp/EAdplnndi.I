class implementation EMSdimdtm;

#include "EMS.h"
#include "parametric.h"
#include "exmacros.h" /* For ex$get_modid */
#include "nddef.h" /* For ND_DROP_MAX */
#include "emserr.h"
#include "EMSerrordef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h" /* For gr$get_module_env */
#include "OMmacros.h"

method NDupdate(int *msg, cn_type, count;
		   struct GRid *parents;
		   int * parent_state;
		   struct GRid *context,*new_objid;
		   struct GRmd_env *md_env)
{
 *msg = ND_COMP_SUCC;
 new_objid->objid = my_id;
 new_objid->osnum = OM_Gw_current_OS;
 return (OM_S_SUCCESS);
}

method NDgive_structure (IGRlong *msg; struct ret_struct *str;
                            struct GRmd_env *md_env )
{
 *msg = MSSUCC;
 str->type = other_generic;
 return (OM_S_SUCCESS);
}

method NDdisplay(IGRint dp_type;enum GRdpmode pen;struct GRmd_env *env)
{
 return (OM_S_SUCCESS);
}

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
end implementation EMSdimdtm;

