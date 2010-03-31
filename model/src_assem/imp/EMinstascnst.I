/*
   This method returns the constraints incident on 
   the given part.
*/

class implementation EMinstance;

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "assemconstr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include <alloca.h>
#include "nddef.h"

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method : EMget_incident_constr                                            |
 |                                                                           |
 | This message returns the incident constraints on this part instance.      |
 |                                                                           |
 | Output:  IGRlong     * msg       Return code, MSSUC or MSFAIL for now.    |
 |          IGRint *pnum_incident_constr  Number of incident constraints.    |
 |          struct GRid incident_constr[] The incident constraints.          |
 |                                                                           |
 +---------------------------------------------------------------------------*/

extern GRclassid OPP_EMconstr_class_id;

method EMget_incident_constr (IGRlong *msg; 
                               IGRint *pnum_incident_constr;
                               struct GRid incident_constr[])
{
  IGRlong stat_OM;
  int num_constr, constr_counter;
  struct GRid *constr_list;
  GRclassid classid = 0;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *pnum_incident_constr = 0;

  stat_OM = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
	            NULL,0,&constr_list,0,OM_K_MAXINT,&num_constr),
		   targetid = my_id);
  EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, wrap_up);		   
    
  for (constr_counter = 0; constr_counter < num_constr; constr_counter++)
  {
    om$get_classid (objid = constr_list[constr_counter].objid, 
    osnum = constr_list[constr_counter].osnum, p_classid = &classid);

    if (om$is_ancestry_valid (subclassid = classid,
       superclassid = OPP_EMconstr_class_id) == OM_S_SUCCESS)
    {
      incident_constr[*pnum_incident_constr].objid = 
                                             constr_list[constr_counter].objid;
      incident_constr[*pnum_incident_constr].osnum = 
                                             constr_list[constr_counter].osnum;    
      ++(*pnum_incident_constr);
    }
  }
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

wrap_up:
  EMWRAPUP (*msg, stat_OM, "EMonstraint.EMget_incident_constr");
  return (stat_OM);

}

end implementation EMinstance;
