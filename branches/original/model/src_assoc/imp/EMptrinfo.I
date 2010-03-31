/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpointer;

#include "EMSasdef.h"
#include "OMmacros.h"
#include "emserr.h"

method EMget_pointer_info(IGRlong *EMmsg;
                          IGRushort options;
                          IGRuint *type;
                          IGRuint *info_size;
                          IGRchar **info)
/* ************************************************************************

Description
 This message gets the size of the pointer information 
If (*info) is NULL then memory is allocated inside this method and if the
same is not NULL then it is assumed that the buffer is of an appropriate
size. If (**info) is NULL then only info_size is returned.

Notes
 Upon exit the completion code will be one of the following:

EMS_S_Success : If all goes well.
EMS_E_DynamicMemoryAllocated: If there was an error in allocating memory.
EMS_E_Fail : If there is failure

History
    PP      06/11/91    Creation
************************************************************************** */
{
 IGRint vla_size;

 *EMmsg = EMS_S_Success;
 
 vla_size = OM_DIMENSION_OF(me->info);
 if (type) *type = me->type;
 if (vla_size)
 {
   if (info_size) *info_size = vla_size;
 }
 else
 {
   if (info_size) *info_size = 0;
   if (info) *info = NULL;
 }

 if (info && vla_size)
 {
   if (!*info)
   {
    *info = (IGRchar *) om$malloc (size = vla_size);
    EMerr_hndlr(!(*info), *EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
   }

   OM_BLOCK_MOVE(&me->info[0], *info, vla_size);
 }

wrapup:
 return (OM_S_SUCCESS);
}

method EMput_pointer_info (IGRlong *EMmsg; 
                           IGRushort options;
                           IGRuint type;
                           IGRuint size;
                           IGRchar *info)

/* *******************************************************************
Description
 This message stores the pointer information into the vla
 defined at this class. 

Arguments
 Input
  options : Currently can be set to NULL.
  info_size : Size of the pointer information.
  info : Pointer information which needs to be
         moved into the instance info.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well
 EMS_E_Fail:    If things dont go well

History
    PP      06/11/91    Creation
  ******************************************************************* */
{
 IGRlong status;
 IGRuint future_size,
                 current_size;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 me->type = type;

 current_size = OM_DIMENSION_OF(me->info);

 future_size = size;

 if (future_size != current_size)
   OM_SET_DIMENSION(me->info, future_size);

 if (info)
  OM_BLOCK_MOVE(info, &me->info[0], size);

 return (status);
}


method debug()
{
 struct GRid junk, crt;
 IGRshort mxtyp;
 IGRmatrix mx;
 OM_S_CHANSELECT father;

 om$make_chanselect(channame = "NDfather.father",
                             p_chanselect = &father);
 fprintf(stderr, "EMSpointer object %d\n", my_id);
 fprintf(stderr, "  Type = %d\n", me->type);
 junk.objid = NULL_OBJID;
 crt.objid = NULL_OBJID;

 om$send (msg = message NDnode.ASreturn_go(&crt, &mxtyp, mx), 
          p_chanselect = &father, from = 0, to = 0);

 om$send(msg = message NDnode.ASreturn_go(&junk, &mxtyp, mx), targetid=my_id);

 fprintf(stderr, "  Father = %d\n", crt.objid);
 fprintf(stderr, "  Pointing to = %d\n", junk.objid);

 return(OM_S_SUCCESS);
}

end implementation EMSpointer;
