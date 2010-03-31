/* ###################   APOGEE COMPILED   ################## */

class implementation EMSsolid;

#include "EMS.h"
#include "EMSopt.h"
#include "EMSbnd.h"
#include "EMSbnddef.h"
#include "EMSerrordef.h"

from EMSboundary import EMcount_edges;
from EMSsubbs import EMpassloop;

method EMcount_vertices (IGRlong *EMmsg;
                         IGRint *no_of_vertices)

/* **********************************************************

Description
             This method counts the number of vertices belonging
             to the solid.

             Input
               
             Output
              EMmsg   - completion code
              no_of_vertices : number of vertices

Notes
             Upon exit the completion code will be one of the following:
              EMS_S_Success : if successful
              EMS_E_Fail    : if there is failure

Assumptions
             This method assumes that the solid is a primitive solid
             
             
Algorithm
             1. Get the loopsets belonging to myself.
             2. Get the number of nondegenerate edges.
             3. Apply the Eulers formula to determine the
                number of vertices.

History
             PP  : 06/09/87          Changes to accomadate the new class
                                     structure and data structure.
                                     Deadline kludge
             PP  : 02/15/87          Design date

*************************************************************** */


{
 IGRshort               i;          /* index for the for loop */

 IGRint                 edge_count; /* number of nondegenerate edges */
 IGRint                 no_of_edges;
 OMuint                 surf_count;

 IGRlong                msg_loc;
 IGRlong                status;     /* OM completion code */

 OM_S_CHANSELECT        to_components;

 


/* *******************

   Initialisation

   ******************* */

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 
 no_of_edges = 0;
 edge_count = 0;
 surf_count = 0;

 status = EMmake_chanselect (GRcmpowner_to_components, &to_components);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);


 status = om$get_channel_count (object = me,
                                p_chanselect = &to_components,
                                count = &surf_count);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 for (i=0 ; i < surf_count ; i++)
 {
   edge_count = 0;

   status = om$send (msg = message EMSsubbs.EMpassloop (&msg_loc, message
                           EMSboundary.EMcount_edges (EMmsg, 
                           EMS_OPT_NONDEG, &edge_count)),
                     p_chanselect = &to_components,
                     from = i,
                     to = i);
   EMerr_hndlr (!(1&status&msg_loc&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   no_of_edges += edge_count;
 }


 *no_of_vertices = 2 - surf_count + (no_of_edges / 2);

wrapup:

 EMWRAPUP (*EMmsg, status , "In EMSsolid: EMcount_vertices error");
 return (status);

}

end implementation EMSsolid;

