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


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_feature                                                    |
 |                                                                           |
 | This message gets one of the features on which the constraint applies.    |
 | If "is_incident" is TRUE, ==> the feature on which the constraint         |
 | is incident is to be returned.                                            |
 |                                                                           |
 | Input:   IGRboolean is_incident  if TRUE return feature on which the      |
 |                                  constraint is incident                   |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |          struct GRid *pfeature_grid the feature id.                       |
 |                                                                           |
 +---------------------------------------------------------------------------*/

method EMget_feature (IGRlong *msg; IGRboolean is_incident; 
                       struct GRid *pfeature_grid)

{
  FEATURE_ID feature;
  IGRlong stat_OM;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  if (is_incident)
     feature = me->feature_two;
  else
     feature = me->feature_one;

  stat_OM = om$os_internal_name_to_number(osname = feature.osname,
                                          p_osnum = &(pfeature_grid->osnum));
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$tag_to_objid(osnum = pfeature_grid->osnum,
                            tag = feature.tag,
                            p_objid = &(pfeature_grid->objid));
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
     
ret_end:
  EMWRAPUP (*msg, stat_OM, "In EMconstr:EMget_feature error");
  return (stat_OM);
}

end implementation EMconstr;
