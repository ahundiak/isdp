/******************ANSI COMPILED**********************/
class implementation EMSloop;

/*
DESCRIPTION

  This function checks to see
   1. If the incoming loop is the outtermost loop. i.e. it is
      connected to a loopset.
   2. Further, it checks to see if the loopset owning this loop has
      only loop

  If both these conditions are true then
      is_outter = TRUE.

HISTORY

 August, 1991  : AMD :  Creation
*/ 
 
#include  "emsdef.h"

extern GRclassid OPP_EMSloopset_class_id;

IGRlong EFcheck_loop_position( msg, loop_id, osnum, is_outter)
 
IGRlong *msg;
GRobjid loop_id;
OMuword osnum;
IGRboolean  *is_outter;
{

 IGRlong sts;
 OM_S_CHANSELECT  to_outter_object, chan_to_loops;
 OMuint count, loop_count;
 OM_S_OBJECT_LINKAGE outter_objlist;

 *msg = EMS_S_Success;
 sts  = OM_S_SUCCESS;

 *is_outter = FALSE;
 
  EMmake_chanselect( EMSloop_to_outter, &to_outter_object);
  EMmake_chanselect( EMSloopset_to_loops, &chan_to_loops);

  sts = om$get_channel_objects(
          osnum = osnum,
          objid = loop_id,
          p_chanselect = &to_outter_object,
          list = &outter_objlist,
          size = 1,
          count = &count);
  EMomerr_hndlr (sts, ret_end, "om$get_channel_objects");     

  if(count)
    {
      GRclassid      test_classid;
      
      sts = om$get_classid(objid = outter_objlist.S_objid,
			   osnum = osnum,
                           p_classid = &test_classid);
      EMomerr_hndlr (sts, ret_end, "om$get_classid");
 
      if(test_classid == OPP_EMSloopset_class_id)
        {
         sts = om$get_channel_count( 
		  objid = outter_objlist.S_objid,
                  osnum = osnum, 
                  p_chanselect = &chan_to_loops,
 		  count = &loop_count);
         EMomerr_hndlr (sts, ret_end, "om$get_channel_count");
 
         if (loop_count == 1) 
           *is_outter = TRUE;
         else
           *is_outter = FALSE;
        }
     }

ret_end:

  return(sts);

}

end implementation EMSloop;
