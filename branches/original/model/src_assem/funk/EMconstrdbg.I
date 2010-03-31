
/*
   This function prints information about the constraints
   on the part.
*/

class implementation EMinstance;

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "assemconstr.h"
#include <alloca.h>

from EMconstr import EMgetpart;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | ‚Function: EMconstrdbg                                                    |
 |                                                                           |
 | This function prints the basis of the part and the constraints            |
 | incident of the part.                                                     |
 |                                                                           |
 | Input :  struct GRid part_grid         Part grid
 |                                        under consideration.               |
 | Output:  IGRlong     * msg       Return code, MSSUC or MSFAIL for now.    |
 |                                                                           |
 +---------------------------------------------------------------------------*/

int EMconstrdbg (msg, part_grid)
IGRlong *msg;
struct GRid part_grid;
{

  IGRint num_inc;
  struct GRid incident_constr[MAX_INCIDENT_CONSTR];	/* The incident constraints */
  IGRlong stat_OM, msg_loc;
  unsigned int basis_id, constype, constr_counter;
  char constr_name[64];
  struct GRid curr_constr, from_part;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;


  stat_OM = om$send (msg = message EMinstance.EMgivebasis(&msg_loc, &basis_id), 
                       senderid = NULL_OBJID,
                       targetid = part_grid.objid,
                       targetos = part_grid.osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, wrap_up);
  
  EMprintbasis(basis_id);
            
  stat_OM = om$send (msg = message EMinstance.EMget_incident_constr 
            (&msg_loc, &num_inc, incident_constr), 
                       senderid = NULL_OBJID,
                       targetid = part_grid.objid,
                       targetos = part_grid.osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, wrap_up);

  for (constr_counter = 0; constr_counter < num_inc; constr_counter++)
  {
    curr_constr = incident_constr[constr_counter];
     
    stat_OM = EMgetconstrtype (curr_constr, &constype);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, wrap_up);
        
    switch (constype)
    {
      case MATE:
  	strcpy(constr_name, "MATE");
         break;
      case ALIGN:
          strcpy(constr_name, "ALIGN");
          break;
      case GROUND:
          strcpy(constr_name, "GROUND");
          break;
      default:
          strcpy(constr_name, "UNKNOWN");
          break;
    }

    stat_OM = om$send (msg = message EMconstr.EMgetpart (&msg_loc, FALSE,&from_part),
                 senderid = NULL_OBJID,
                 targetid = curr_constr.objid,
                 targetos = curr_constr.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, wrap_up);
      
  }

  
wrap_up:
  EMWRAPUP (*msg, stat_OM, "EMconstrdbg");
  return (stat_OM);
}

end implementation EMinstance;

