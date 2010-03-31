class implementation EMconstr;

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include <alloca.h>
#include "nddef.h"

extern GRclassid OPP_EMinstance_class_id; 

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMgetpart                                                      |
 |                                                                           |      
 | This message gets one of the part grids to which the constraint is        |
 | attached. If "is_incident" is TRUE, ==> the part on which the constraint  |
 | is incident is to be returned.                                            |
 |                                                                           |
 | Input:   IGRboolean is_incident  if TRUE return part on which the         |
 |                                  constraint is incident                   |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |          struct GRid *ppart_grid the part attached to the constraint.     |
 |                                                                           |
 +---------------------------------------------------------------------------*/

method EMgetpart (
long                *msg;        /* The return message   OUT */
IGRboolean   is_incident; 	 /* The direction of constr IN */
struct GRid  *ppart_grid)        /* GRid of attached part  OUT */

{
  IGRlong stat_OM;
  int  num_part;
  struct GRid *part_list;
  GRclassid classid = 0;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (is_incident)
  {
    stat_OM = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN|ND_IN_BUF,
  	            NULL,0,&part_list,0,OM_K_MAXINT,&num_part),
  		   targetid = my_id);
    EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, wrap_up);
    if (num_part == 1)
      *ppart_grid = part_list[0];
    else
      EMerr_hndlr (TRUE, *msg, EMS_F_InvalidArg, wrap_up);
  }
  else
  {
    stat_OM = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
  	            NULL,0,&part_list,0,OM_K_MAXINT,&num_part),
  		   targetid = my_id);
    EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, wrap_up);
    if (num_part == 2)
    {
      om$get_classid (objid = part_list[0].objid, 
      osnum = part_list[0].osnum, p_classid = &classid);
  
      if (om$is_ancestry_valid (subclassid = classid,
         superclassid = OPP_EMinstance_class_id) == OM_S_SUCCESS)
        *ppart_grid = part_list[0];        
      else
      {
        om$get_classid (objid = part_list[1].objid, 
        osnum = part_list[1].osnum, p_classid = &classid);
    
        if (om$is_ancestry_valid (subclassid = classid,
           superclassid = OPP_EMinstance_class_id) == OM_S_SUCCESS)
          *ppart_grid = part_list[1];
        else        
          EMerr_hndlr (TRUE, *msg, EMS_F_InvalidArg, wrap_up);          
      }
    }
    else if(num_part == 0)
       ppart_grid->objid = NULL_OBJID;
  }

wrap_up:
  EMWRAPUP (*msg, stat_OM, "EMonstraint.EMgetpart");
  return (stat_OM);

}

end implementation EMconstr;
