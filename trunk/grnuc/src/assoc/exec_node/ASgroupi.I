class implementation ASgroup;

#include "ASmacroi.h"
#include <limits.h>
#include "macro.h"
#include "grownerdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exdef.h"
#include "exmacros.h"

#define path_MAX_CHAR 160

method GRget_locate_properties(IGRlong *msg; IGRint *properties )
{
 *msg = MSSUCC;
 return (om$send (mode = OM_e_wrt_message,
                  msg = message GRowner.GRget_locate_properties(msg,
                        properties),
         targetid = my_id));

}

method ACreturn_foot( IGRlong *msg; char *foot_name; 
		struct GRid *foot_GRid; IGRshort *mat_type;IGRdouble *matrix )
{
 int index;
 long status;
 char *strchr();
 char 		*chpos, chtemp[path_MAX_CHAR];
 
 *msg = 0;
 foot_GRid->objid = NULL_OBJID;

 if(foot_name[0] == '.' || foot_name[0] == '\0')
   index = 0;

 else if(foot_name[0] == '$')
   sscanf(foot_name+1,"%d",&index);

 else return OM_S_SUCCESS;


 /*"index %d\n",index */
 status = om$get_objid_at_index( objid      = my_id,
                                  p_chanselect  = &AS_to_comp,
                                  index         = index,
                                  objidaddr     = &(foot_GRid->objid),
                                  osnumaddr     = &(foot_GRid->osnum) );
 as$status(  );
 if(!(status&1)) return OM_S_SUCCESS;

 if(chpos=strchr(foot_name,':')) 
 {
    strcpy(chtemp,chpos+1);  
    *chpos = '\0';

    status = om$send(msg =  message ASnode.ACreturn_foot
					(msg,chtemp,foot_GRid,mat_type,matrix),
        	    targetid = foot_GRid->objid ,targetos = foot_GRid->osnum);
    if(!(status&1)) *msg = 0;
    as$status(action = RET_STATUS );
 }

 *msg = 1;
 if(mat_type) *mat_type = MAIDMX;
 if(matrix) MAidmx(&status,matrix);

 return OM_S_SUCCESS;
}


method GRcopy( IGRlong *msg; struct GRmd_env *obj_dsenv;
     	       struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
 IGRint status;

 status = om$send( msg = message ASnode.GRcopy
					(msg,obj_dsenv,new_dsenv,newobjid),
                    mode = OM_e_wrt_parent,
                    targetid = my_id);
 as$status();

 return status;
}

end implementation ASgroup;
