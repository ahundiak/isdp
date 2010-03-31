/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmove;

#include "EMS.h"
#include "EMSbnddef.h"
#include "emsmacros.h"
#include "OMmacros.h"

method EMloop_add (IGRlong *EMmsg;
                   struct EMinstruction_table_info info;
                   GRobjid loop_id)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure

Assumption

Bugs

History
	
	  gupta 	05/04/87:	design date
                10/19/87:   major modification for new system
Algorithm
     
      Check to see, if the incoming loop_id is in the vla for ids[] in
      EMSdpr. If it is not then put it in the vla. Finally store the
      execute instruction info at the proper index and also reset the
      vla if neccessary.
*/

{
 IGRlong		  stat_OM, msg;
 IGRint		   	  i, index;
 IGRint 		  loop_count,
                  dimension,
                  inst_no;
 IGRboolean       is_in_list;

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;
 is_in_list = FALSE;

 loop_count = OM_DIMENSION_OF(ME.EMSdpr->ids);

 if (loop_count)
  {
   for (i=0; i<loop_count; i++)
    {
     if (IF_EQ_OBJID(ME.EMSdpr->ids[i], loop_id))
      {
       is_in_list = TRUE;
       break;
      }
    }
   
   if (is_in_list)
    {
     index = i;
    }
   else
    {
     stat_OM = OM_SET_DIMENSION(ME.EMSdpr->ids, loop_count+1);
     ME.EMSdpr->ids[loop_count] = loop_id;
     index = loop_count;
    }
  }
 else
  {
   stat_OM = OM_SET_DIMENSION(ME.EMSdpr->ids, 1);
   ME.EMSdpr->ids[loop_count] = loop_id;
   index = loop_count;
   ME.EMSsfmove->no_of_instructions = 0;
  } 
     
dimension = OM_DIMENSION_OF(ME.EMSsfmove->exec_info);

inst_no = ME.EMSsfmove->no_of_instructions;

if (inst_no == dimension)
 {
  stat_OM = OM_SET_DIMENSION(ME.EMSsfmove->exec_info,inst_no + 5);
 }

 ++ ME.EMSsfmove->no_of_instructions;

 ME.EMSsfmove->exec_info[inst_no].index = index;
 ME.EMSsfmove->exec_info[inst_no].instruction = info;

 wrapup:

  return (stat_OM);
}

end implementation EMSsfmove; 

                
