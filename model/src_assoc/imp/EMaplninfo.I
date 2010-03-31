class implementation EMAplane;

#include "EMSasdef.h"
#include "OMmacros.h"
#include "emserr.h"
#include "REplane.h"

method EMget_info(IGRlong *EMmsg;
                   IGRushort options;
                   IGRuint *type;
                   IGRuint *info_size;
                   IGRchar **info)
{
 IGRint vla_size;
 struct EMSconverted_plane *ptr, *tmp;

 *EMmsg = EMS_S_Success;

 if(me->type != EMS_ASplane_converted_plane) 
  {
   om$send(mode = OM_e_wrt_message, msg = message EMSassoc.EMget_info
      (EMmsg, options, type, info_size, info), targetid = my_id);
   goto wrapup;
  }

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

   /* Set the original recompute pointer correctly.
   */
   ptr = (struct EMSconverted_plane *) *info;
   tmp = ptr;
   tmp++;
   ptr->orig_info = (IGRchar *) tmp;
 }

wrapup:
 return (OM_S_SUCCESS);
}

end implementation EMAplane;
