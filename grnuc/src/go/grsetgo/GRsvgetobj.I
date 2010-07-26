/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSget_object 

Description
   This method will return the object and module environment for the
   objects between from_obj and to_obj.

   *msg          IGRlong              return code
   array[]       struct GRobj_env     An array of GRid's and module
                                      environments.
   array_size    IGRint               Size of array in bytes.
   *count        IGRint               The number of objects returned.
   from_obj      IGRint               The base index
   to_obj        IGRint               The high index

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "grgs.h"

method GSget_object (IGRlong *msg; struct GRobj_env array[];
                    IGRint  array_size; IGRint *count; IGRint from_obj; 
                    IGRint to_obj)
{
IGRlong           om_msg;
IGRint            i, j;
unsigned int      count1;
OM_S_CHANSELECT   chansel;
IGRint            buffer_size;
IGRchar           *buffer;
IGRint            current_array_size;

   *msg = MSSUCC;
   buffer = (IGRchar *)NULL;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";
   current_array_size = array_size;

   /*
    *  Get the channel count of the number of graphics objects.
    */

   om_msg = om$get_channel_count (object= me, p_chanselect = &chansel, 
            count = &count1);
   count1--;

   /* 
    *  Validation 
    */

   if ( (from_obj > count1) || (from_obj < 0) ||
        (to_obj < 0) || (!array_size) )
   {
      *count = 0;
      *msg = MSFAIL;
      return (OM_S_SUCCESS);
   }

   if (to_obj >= count1)
   {
      to_obj = count1;
   }

   buffer_size = sizeof(OM_S_OBJECT_LINKAGE) * (count1 + 1);
   if (buffer = om$malloc (size = buffer_size) )
   {
      om_msg = om$get_channel_objects (osnum = OM_Gw_current_OS,
               objid = my_id, p_chanselect = &chansel, 
               list = (OM_S_OBJECT_LINKAGE *) buffer, 
               size = buffer_size, count = &count1);

      current_array_size -= sizeof(struct GRobj_env);
      for (i = from_obj, j = 0; (i <= to_obj) && 
          (current_array_size >= 0); ++i, ++j)
      {
        array[j].obj_id.objid = ((OM_S_OBJECT_LINKAGE *)buffer)[i].S_objid;
        array[j].obj_id.osnum = ((OM_S_OBJECT_LINKAGE *)buffer)[i].osnum;
        array[j].mod_env = me->path;
        current_array_size -= sizeof(struct GRobj_env);
        (*count)++;
      }
   }
   if (buffer) om$dealloc (ptr = buffer);
   return (OM_S_SUCCESS);
}
end implementation GRsvset;
