
class implementation EMinstance;

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "msdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include <alloca.h>
#include "assemconstr.h"
#include <values.h>

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMcheckbasis                                                      |
 |                                                                           |
 |  This method checks for the correct basis to position the part.           |
 |                                                                           |
 |  The constraints incident on the part are passed in as                    |
 |  arguments.                                                               |
 |                                                                           |
 |  Inputs:                                                                  |
 |                                                                           |
 |  IGRint num_inc 		                The # of incident constr     |
 |  struct GRid incident_constr[]		The incident constraints     |
 |                                                                           |
 |  Outputs:                                                                 |
 |                                                                           |
 |  IGRlong * msg                               Return code                  |
 |  unsigned int *pbasis_id                     The basis id                 |
 |                                                                           |
 +---------------------------------------------------------------------------*/

method EMcheckbasis( IGRlong *msg;
                     IGRint num_inc;
                     struct GRid incident_constr[];
                     unsigned int *pbasis_id)
{
  unsigned int constr_type;
  unsigned int incident_constype[MAX_INCIDENT_CONSTR];  
  IGRint counter;
  double rel_angle[MAX_INCIDENT_CONSTR];
  IGRlong status;
  struct GRid my_grid;

  *msg = EMS_S_Success;
  status = EMS_S_Success;
  
  for (counter = 0; counter < num_inc; counter++)
  {
    EMgetconstrtype (incident_constr[counter], &constr_type);
    incident_constype[counter] = constr_type;
    if ((constr_type == GROUND) && (num_inc > 1))
    {
      *pbasis_id = NULL_BASIS_ID;
      return(status);      
    }
  }
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  if (num_inc > 1)
  {
    status = EMgetrelang(my_grid, incident_constr[0], incident_constr[1], 
                         &rel_angle[0]); 
    EMerr_hndlr(!(1&status), status, EMS_E_Fail, ret_end);
    
    if (num_inc > 2)
    {
      status = EMgetrelang(my_grid, incident_constr[1], incident_constr[2], &rel_angle[1]); 
      EMerr_hndlr(!(1&status), status, EMS_E_Fail, ret_end);

      status = EMgetrelang(my_grid, incident_constr[2], incident_constr[0], &rel_angle[2]); 
      EMerr_hndlr(!(1&status), status, EMS_E_Fail, ret_end);
    }    
  }
  status = EMget_basis(num_inc, incident_constype, rel_angle, pbasis_id);
  EMerr_hndlr(!(1&status), status, EMS_E_Fail, ret_end);



ret_end:
  EMWRAPUP ( status, status, "In EMcheck_basis" );
  *msg = status;
  return(status);
  

}

end implementation EMinstance;

