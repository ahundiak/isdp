/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMS.h"
#include "EMSlm.h"
#include "emsmacros.h"

from EMSedge import EMendpts;

method EMfix_end_point (IGRlong             *EMmsg;
                        GRobjid             loop_id)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure

Assumption

Bugs

History
	
	  gupta 	04/16/88:	design date

Algorithm
     
*/

{
 IGRlong		  stat_OM, msg;
 IGRint		   	  i, j;
 IGRdouble        end_pts[4];
 OM_S_CHANSELECT  to_edges;

 /*--------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
 if (! (1 & stat_OM)) goto wrapup;

 for (i=0; i<ME.EMSsfround->no_of_boundaries; i++)
  {
   if (ME.EMSsfround->round_exec_info[i].bnd_info.loop_id == loop_id)
    {
     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                             &end_pts[0], &end_pts[2],
                             NULL,NULL,NULL),
                       senderid = loop_id,
                       p_chanselect = &to_edges);
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

     for (j=0; j<4; j++)
      ME.EMSsfround->round_exec_info[i].bnd_info.end_pts[j] = end_pts[j];
    }
  }

 wrapup:
  EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMfix_end_point");
  return (stat_OM);
}
end implementation EMSsfround; 
