/* ###################   APOGEE COMPILED   ################## */
class implementation AScompcurve;

#define AS_DEBUG
#include "asbox.h"
#include "AS_status.h"


from  ACpretend   import ACrebind;

method GRdrop(IGRlong *msg; struct GRmd_env *md_env)
{
 int status;
 struct GRid my_grid;
 
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;
 status = om$send(msg = message ACpretend.ACrebind( (int *)msg,&my_grid),
           p_chanselect = &ND_children);
 as$status();

 status = om$send(msg = message GRcompcurve.GRdrop(msg,md_env),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 as$status();

 return status;

}

end implementation AScompcurve;
