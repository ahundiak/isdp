/*
   This method returns the reversible constraints 
   incident on the given part.
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
extern int Is_0_level;
/*---------------------------------------------------------------------------+
 |                                                                           |
 | ‚Method: EMget_reversible_constr                                          |
 |                                                                           |
 | This message returns the reversible constraints on this part instance.    |
 | The reversible constraints are wrt a particular candidate constraint.     |
 |                                                                           |
 | Input :  struct GRid candidate_constr  Candidate constraint under         |
 |                                        under consideration.               |
 | Output:  IGRlong     * msg       Return code, MSSUC or MSFAIL for now.    |
 |          IGRint *pnum_reversible_constr  Number of incident constraints.  |
 |          struct GRid reversible_constr[] The reversible constraints.      |
 |                                                                           |
 +---------------------------------------------------------------------------*/

method EMget_reversible_constr (IGRlong *msg;
                                struct GRid candidate_constr;
                                IGRint *pnum_reversible_constr;
                                struct GRid reversible_constr[])
{
  IGRint num_inc, constr_counter, counter;	
  struct GRid incident_constr[MAX_INCIDENT_CONSTR];	/* The incident constraints */
  struct GRid possible_basis[MAX_INCIDENT_CONSTR]; 
  struct GRid possible_constr;
  IGRlong stat_OM, msg_loc;
  unsigned int basis_id;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (msg = message EMinstance.EMget_incident_constr 
            (&msg_loc, &num_inc, incident_constr), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, wrap_up);

  *pnum_reversible_constr = 0;
  
  if (!Is_0_level)
  {
    incident_constr[num_inc] = candidate_constr;

    stat_OM = om$send (msg = message EMinstance.EMcheckbasis
        (&msg_loc, num_inc + 1, incident_constr, &basis_id), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, wrap_up);
  } 
  else
  {

    stat_OM = om$send (msg = message EMinstance.EMcheckbasis
        (&msg_loc, num_inc, incident_constr, &basis_id), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, wrap_up);
  } 

  if (basis_id == NULL_BASIS_ID)
  {
    if (!Is_0_level)
    {
      for (constr_counter = 0; constr_counter < num_inc; constr_counter++)
      {

        possible_constr =  incident_constr[constr_counter];        
        incident_constr[constr_counter] = candidate_constr;
        
    
        stat_OM = om$send (msg = message EMinstance.EMcheckbasis
            (&msg_loc, num_inc, incident_constr, &basis_id), targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, wrap_up);

        if (basis_id != NULL_BASIS_ID)      
        {
          reversible_constr[*pnum_reversible_constr] = possible_constr;
          ++(*pnum_reversible_constr);
        }
        incident_constr[constr_counter] = possible_constr;
      }
      if ((*pnum_reversible_constr) == 0) 
         (*pnum_reversible_constr) = -1;
         
    }
    else
    {
      for (constr_counter = 0; constr_counter < num_inc; constr_counter++)
      {
        possible_basis[constr_counter] = incident_constr[constr_counter];
        if ((candidate_constr.objid ==  incident_constr[constr_counter].objid) &&
            (candidate_constr.osnum ==  incident_constr[constr_counter].osnum))
          continue;
  
        possible_constr =  incident_constr[constr_counter];
                
        for (counter = constr_counter; counter < (num_inc - 1); counter++)
        {
          possible_basis[counter] =  incident_constr[counter + 1]; 
        }
    
        stat_OM = om$send (msg = message EMinstance.EMcheckbasis
            (&msg_loc, num_inc - 1, possible_basis, &basis_id), targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, wrap_up);

        if (basis_id != NULL_BASIS_ID)      
        {
          reversible_constr[*pnum_reversible_constr] = possible_constr;
          ++(*pnum_reversible_constr);
        }
        possible_basis[constr_counter] = possible_constr;
      }
    }

    if ((*pnum_reversible_constr) == 0) 
       (*pnum_reversible_constr) = -1;
  
  }
  
wrap_up:
  EMWRAPUP (*msg, stat_OM, "EMinstance.EMget_reversible_constr");
  return (stat_OM);

}

end implementation EMinstance;
