/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "EMSerrordef.h"
#include "EMSdef.h"
#include "emsmacros.h"
#include "OMstackalloc.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bstypes.h"
#include "bsparameters.h"

method EMis_parm_valid  (
        IGRlong    *EMmsg;                 /* completion code */
        IGRshort   position;
        IGRint     num_parm;
        IGRdouble  *parms;
        IGRint     *num_valid_parms;
        IGRdouble  **valid_parms)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure
                - EMS_E_EdgeError error in edge method
Assumption

Bugs

History
	
	  gupta 	05/05/87:	design date

          Sudha         06/04/93        modified to include BSprototype header files

Algorithm
    
      Given a stack of parameters, find the one's which fall in the 
      range of my(edge) end point parameters, and store them in
      valid_parms.

*/

{
  IGRlong                         stat_OM, msg;
  IGRint                          i;
  IGRdouble                       begin_pt[2], end_pt[2],
                                  par1, par2;
  IGRdouble                       knot_tol;
/* ------------------------------------------------------------- */

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *num_valid_parms = 0;
  *valid_parms = NULL;

  *valid_parms = (IGRdouble *) OM_stack_alloc (
                        num_parm * sizeof(IGRdouble));

  (void)BSEXTRACTPAR(&msg, BSTOLKNOT, knot_tol);

  EMerr_hndlr(BSERROR(msg), *EMmsg, EMS_E_Fail, wrapup);

  /* get my end points */

  stat_OM = om$send(msg=message EMSedge.EMendpts(
                        &msg, begin_pt, end_pt, NULL,NULL,NULL),
                    targetid = my_id);
  EMomerr_hndlr(stat_OM, wrapup, "EMedvld_prm.EMendpts");
  EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

  switch (position)
   {
    case 0:
           par1 = begin_pt[1];
           par2 = end_pt[1];
           break;

    case 1:
           par1 = begin_pt[0];
           par2 = end_pt[0];
           break;

    case 2:
           par1 = end_pt[1];
           par2 = begin_pt[1];
           break;

    case 3:
           par1 = end_pt[0];
           par2 = begin_pt[0];
           break;
   }  /* end switch */

/* keep the parameters within range of my end parameters */

  for (i=0; i<num_parm; i++)
   {
    if ((parms[i] >= par1+knot_tol) && (parms[i] <= par2-knot_tol))
     {
      (*valid_parms)[(*num_valid_parms)] = parms[i];
      (*num_valid_parms)++;
     }
   }

wrapup:

  return(stat_OM);
}
end implementation EMSedge;
