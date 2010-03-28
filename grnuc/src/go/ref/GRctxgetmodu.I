/* #######################    APOGEE COMPILED   ######################## */
/*     
Abstract: 	

	This method returns the environment information for objects
	in the reference file space represented by this context 
	object.

Arguments
     *msg	   IGRlong      O  completion code
     *env	struct GRmd_env	O  module environment structure
     					
Return Values
    - MSSUCC if successful 
    - MSFAIL if error
*/

class implementation GRcontext;

#include "grimport.h"
#include "refpriv.h"
#include "msdef.h"
#include "ex.h"
#include "exmacros.h"

method GRgetmodule_env(IGRlong *msg; struct GRmd_env *env)
{
    IGRlong	OMmsg,
		i;
    GRobjid     mod_id;
    
    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;
    mod_id = 0;

    env->md_id.osnum = me->osnum;
    env->md_env.matrix_type = me->mx_type;
    for (i=0; i<16; ++i)
    {
	env->md_env.matrix[i] = me->matrix[i];
    }

   /*
    Get_invisible_id_from_osnum(me->osnum,&mod_id)
   */
    ex$get_modid ( mod_osnum = me->osnum, mod_id = &mod_id );    

    env->md_id.objid = mod_id;
    return (OMmsg);

}
end implementation GRcontext;
