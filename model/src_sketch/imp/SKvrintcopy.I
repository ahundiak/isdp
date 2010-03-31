class implementation SKvariable;

#include "EMS.h"
#include <stdio.h>
#include "ma.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "gocmacros.h"
#include "EMcp.h"

method SKintcopy(
	IGRlong 	*EMmsg; 	
        IGRushort options;
	struct GRmd_env *obj_mdenv;
	struct GRmd_env *new_mdenv;
	GRobjid 	*newobjid;
	struct EMcp_info *copy_info)

		
{
   IGRboolean            var_copy_exists;
   IGRlong               OM_stat;
   IGRlong   mthd_stat;
   void                  EMcpsearch ();

   /* ****************************************************************** */

   *EMmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;

   /*
    * find out if I have been already copied or not.
    * If so, return my counter part's objid and I am all done
    */
	
   EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 0, 
               &var_copy_exists);
   EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

   if (var_copy_exists) goto wrapup;


   OM_stat = om$construct_and_copy(object = me, 
	      osnum = new_mdenv->md_id.osnum, p_objid = newobjid);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_Fail, wrapup);

   /*
    * put my_id and my counter part's id in the copy_info
    */

   EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 3, 
               &var_copy_exists);
		    	 
   EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

wrapup:
     EMWRAPUP (*EMmsg, OM_stat, "SKvariable.EMintcopy");
     return(OM_stat);
}
end implementation SKvariable;
