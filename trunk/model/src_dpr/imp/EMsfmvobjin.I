class implementation EMSsfmove;

#include "EMS.h"
#include "EMSlmdef.h"
# include "msdef.h" /* MS message codes */
#include "msmacros.h"
#include "emsclasses.h"


method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 IGRchar myclassname[OM_K_MAXCLASS_LEN], myop[10];
 IGRlong sts = OM_S_SUCCESS;
 IGRint i, op;
 IGRboolean got_face = FALSE, got_edge = FALSE;


 *msg = EMS_S_Success;    

 for (i=0; i<ME.EMSsfmove->no_of_instructions; i++)
 {
   if (ME.EMSsfmove->exec_info[i].instruction.move_operation ==
       EMS_MOVE_LIN_FACE) got_face = TRUE;
   if (ME.EMSsfmove->exec_info[i].instruction.move_operation ==
       EMS_MOVE_LIN_EDGE) got_edge = TRUE;
 }   

 if (got_face) op = 2;
 else if (got_edge) op = 1;
 else op = 0;

 sts = om$get_classname(objid = my_id, classname = myclassname);
 if(!(1&sts)) goto ret_end;
 sprintf(myop, "%d", op);
 strcat(myclassname, myop);

 ex$message(msgname = myclassname, buff = info->type)


 ret_end:
  return(OM_S_SUCCESS);
}

end implementation EMSsfmove;
