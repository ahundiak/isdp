
class implementation EMconstr;

/*

Name
  EMcnstrover.I

Description
  This file has the override of methods for the Assembly 
  Constraint Class.

Notes
 09/09/93 : Kapil Singh (KS): created
 */


#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMindex.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "igrdef.h"
#include "madef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "emsdef.h"
#include "emserr.h"
#include "AS_status.h"
#include "nddef.h"
#include "expression.h"
#include "expmacros.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"

#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

method NDcompute_node ( IGRlong *rc; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env)
{
    *rc = ND_COMP_SUCC;
    return( OM_S_SUCCESS );
}

method NDgive_structure (IGRlong *msg; struct ret_struct *str;
                         struct GRmd_env *md_env )
{
    str->type = other_generic ;
    *msg = MSSUCC;

    return (OM_S_SUCCESS);
}

method ASreturn_go ( struct GRid * go; short *mat_type; double *matrix )
{
long            msg;
struct GRmd_env mod_env;
int             sizbuf, nret;

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

method NDdisplay ( int dp_type; enum GRdpmode dpmode; struct GRmd_env *env )
{
    return OM_S_SUCCESS;
}

method NDmove_to_root (IGRlong *msg; struct GRid *src_grid;
			  struct GRmd_env *md_env )
{
struct GRid mygrid;
int    om_msg;

    /*
     * Delete the constraint itself.
     */
    mygrid.objid = my_id;
    mygrid.osnum = OM_Gw_current_OS;
    
    om_msg = asm$rem_constraint( msg = msg,
                        constraint_id = &mygrid );

    return OM_S_SUCCESS;
}

end implementation EMconstr;
