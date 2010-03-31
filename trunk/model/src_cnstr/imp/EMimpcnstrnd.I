/* ###################   APOGEE COMPILED   ################## */
class implementation EMSimpcnstr;

#include "nddef.h"
#include "ndmacros.h"
#include "godef.h"
#include "parametric.h"


method NDgive_structure (IGRlong *msg; struct ret_struct *str;
                         struct GRmd_env *md_env )
{
 str->type = other_generic ;
 *msg = MSSUCC;
 return (OM_S_SUCCESS);
}

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

end implementation EMSimpcnstr;

