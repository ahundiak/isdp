/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

#include "EMS.h"
# include "msdef.h" /* MS message codes */
#include "msmacros.h"
#include "emsclasses.h"

/*
Uses class name and appends operation type to it. Uses the resulting string
as the message name to search the message file.
*/
method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 IGRchar myclassname[OM_K_MAXCLASS_LEN], myop[10];
 IGRlong sts = OM_S_SUCCESS;

 *msg = MSSUCC;

 sts = om$get_classname(objid = my_id, classname = myclassname);
 if(!(1&sts)) goto ret_end;
 sprintf(myop, "%d", me->operation_type);
 strcat(myclassname, myop);

 ex$message(msgname = myclassname, buff = info->type)

ret_end:
 return(sts);
}

end implementation EMSlift;
