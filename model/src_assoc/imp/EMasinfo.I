/* ###################   APOGEE COMPILED   ################## */
class implementation EMSassoc;

#include "EMSasdef.h"
#include "OMmacros.h"
#include "emserr.h"

method EMget_info(IGRlong *EMmsg;
                   IGRushort options;
                   IGRuint *type;
                   IGRuint *info_size;
                   IGRchar **info)
/* ************************************************************************

Description
 This message gets the size of the recomputation information 
If (*info) is NULL then memory is allocated inside this method and if the
same is not NULL then it is assumed that the buffer is of an appropriate
size. If (**info) is NULL then only info_size is returned.

Notes
 Upon exit the completion code will be one of the following:

EMS_S_Success : If all goes well.
EMS_E_DynamicMemoryAllocated: If there was an error in allocating memory.
EMS_E_Fail : If there is failure

History
    mrm     4/01/91     Change "vla_size - 1" to "vla_size" in the
                        OM_BLOCK_MOVE to return all the data (type is
                        no longer stored in the vla).
    DLB     3/25/91     Fixed a stupid bug introduced in the last fix.
    DLB     3/18/91     If vla_size == 0 then return info_size = 0 not -1.

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

method EMput_info (IGRlong *EMmsg; 
                   IGRushort options;
                   IGRuint type;
                   IGRuint size;
                   IGRchar *info)

/* *******************************************************************
Description
 This message stores the recomputation information into the vla
 defined at this class. 

Arguments
 Input
  options : Currently can be set to NULL.
  info_size : Size of the recomputation information.
  info : Pointer to the recomputation information which needs to be
         moved into the instance info.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well
 EMS_E_Fail:    If things dont go well
  ******************************************************************* */
{
 IGRlong status;
 IGRuint future_size,
                 current_size;
 IGRuchar char_type;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 me->type = type;

 current_size = OM_DIMENSION_OF(me->info);

 future_size = size;

 if (future_size != current_size)
   OM_SET_DIMENSION(me^^EMSassoc.info, future_size);

 if (info)
  OM_BLOCK_MOVE(info, &me^^EMSassoc.info[0], size);

wrapup:
 return (status);
}
end implementation EMSassoc;
