/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMS.h"
#include "EMSbnddef.h"
#include "emsmacros.h"
#include "OMmacros.h"

method EMloopset_add (IGRlong             *EMmsg;
                      struct EMboundary_info bnd_info;
                      GRobjid             loopset_id)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure

Assumption

Bugs

History
	
	  gupta 	10/09/87:	design date

Algorithm
     
*/

{
 IGRlong		  stat_OM;
 IGRint		   	  i, index,
                  ls_count,
                  dimension,
                  bndry_no;
 IGRboolean       is_in_list;

 /*--------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;
 is_in_list = FALSE;

 ls_count = OM_DIMENSION_OF(ME.EMSdpr->ids);

 if (ls_count)
  {
   for (i=0; i<ls_count; i++)  
    {
     if (IF_EQ_OBJID(ME.EMSdpr->ids[i], loopset_id))
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
     OM_SET_DIMENSION(ME.EMSdpr->ids,ls_count + 1);
     ME.EMSdpr->ids[ls_count] = loopset_id;
     index = ls_count;
    }
  }
 else
  {
    OM_SET_DIMENSION(ME.EMSdpr->ids, 1);
    ME.EMSdpr->ids[ls_count] = loopset_id;
    index = ls_count;
    ME.EMSsfround->no_of_boundaries = 0;
  }

dimension = OM_DIMENSION_OF(ME.EMSsfround->round_exec_info);

bndry_no = ME.EMSsfround->no_of_boundaries;

if (bndry_no == dimension)
 {
  stat_OM = OM_SET_DIMENSION(ME.EMSsfround->round_exec_info,bndry_no + 5);
 }

 ++ ME.EMSsfround->no_of_boundaries;

 ME.EMSsfround->round_exec_info[bndry_no].index = index;
 ME.EMSsfround->round_exec_info[bndry_no].bnd_info = bnd_info;

 wrapup:

  return (stat_OM);
}
end implementation EMSsfround; 
