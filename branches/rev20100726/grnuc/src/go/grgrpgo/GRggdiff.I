/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRdifference

Description
   Finds the difference between two graphic groups and puts the results
   into a third graphic group (result_gg_id = my_gg_id difference gg_id).
   
Arguments
   *msg           IGRlong           return code
   *gg_id         struct GRid       graphic group
   *result_gg_id  struct GRid       result graphic group

Notes
   If the third graphic group object id is the same as one of the graphic
   group object ids that the operation is being performed upon, the 
   contents of that group are replaced with the results from the operation.

Return Values
   MSSUCC  if successful
   MSFAIL  if failure

History
   Gray Winn      Creation Date :   09/30/88
\*/   

class implementation GRgrgrp;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"

method GRdifference (IGRlong *msg; struct GRid *gg_id; 
                     struct GRid *result_gg_id)
{
IGRlong           om_msg;
IGRint            i,j;
IGRint            add;
OMuint            count1;
OMuint            count2;
IGRint            channel_type;
IGRint            connection_type;
IGRint            operand1_flag;
IGRint            operand2_flag;
GRobjid           operand1;
GRobjid           operand2;
IGRchar           *buffer1;
IGRchar           *buffer2;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;
   buffer1 = NULL;
   buffer2 = NULL;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *  Ensure that all three graphic groups are within the same
    *  object space.
    */

   if ((OM_Gw_current_OS == gg_id->osnum) && 
       (OM_Gw_current_OS == result_gg_id->osnum))
   {
      om_msg = om$send (msg = message GRowner.GRget_channel_type (msg,
               &channel_type, &connection_type), 
               targetid = result_gg_id->objid);

      /*
       *  Check to see if either of the operand graphic group is
       *  the same as the result graphics group.
       */

      operand1 = my_id;
      operand2 = gg_id->objid;
      if (result_gg_id->objid == my_id)
      {
         operand1_flag = TRUE;
         operand2_flag = FALSE;
      }else if (result_gg_id->objid == gg_id->objid)
      {
         operand1_flag = FALSE;
         operand2_flag = TRUE;
      }else
      {
         operand1_flag = FALSE;
         operand2_flag = FALSE;
      }            
      
      om_msg = om$get_channel_count (objid = operand1,
               p_chanselect = &chansel, count = &count1);

      if (om_msg & 1)
      {
         if (buffer1 = om$malloc (size = sizeof(OM_S_OBJECT_LINKAGE) 
                       * count1))
         {
            om_msg = om$get_channel_objects (objid = operand1, 
                     p_chanselect = &chansel, list = (OM_S_OBJECT_LINKAGE *)buffer1, 
                        size = count1, count = &count1);
         }
      }

      if (om_msg & 1)
      {
         om_msg = om$get_channel_count (objid = operand2,
                  p_chanselect = &chansel, count = &count2);
   
         if (om_msg & 1)
         {
            if (buffer2 = om$malloc (size = sizeof(OM_S_OBJECT_LINKAGE) 
                          * count2))
            {
               om_msg = om$get_channel_objects (objid = operand2, 
                        p_chanselect = &chansel, list = (OM_S_OBJECT_LINKAGE *)buffer2, 
                        size = count2, count = &count2);
            }
         }
      }

      if ((om_msg & 1) && ((operand1_flag) || (operand2_flag)))
      {
         om_msg = om$send (msg = message Root.wild_disconnect (chansel),
                  targetid = result_gg_id->objid);
      }
      
      if (om_msg & 1)
      {
         for (i=0; i < count1; ++i)
         {
            for (j=0, add = TRUE; ((add) && (j < count2)); ++j)
            {
               if ( ((OM_S_OBJECT_LINKAGE *)buffer1)[i].S_objid == 
                    ((OM_S_OBJECT_LINKAGE *)buffer2)[j].S_objid)
               {
                  add = FALSE;
               }
            }

            if (add)
            {
               /*
                *  Connect the component to the result graphic group.
                */

               om_msg = GRconnect_object (msg, 
                        ((OM_S_OBJECT_LINKAGE *)buffer1)[i].osnum,
                        ((OM_S_OBJECT_LINKAGE *)buffer1)[i].S_objid,
                        result_gg_id, channel_type, connection_type,
                        OM_K_MAXINT, OM_K_MAXINT);
            }
         }
      }
   }else
   {
      *msg = MSFAIL;
   }

   if (buffer1) om$dealloc (ptr = buffer1);
   if (buffer2) om$dealloc (ptr = buffer2);
   return (om_msg);
}
end implementation GRgrgrp;
