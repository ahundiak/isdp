/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRrename_sd

Description
   This method will rename a symbol definition header.

   *msg           IGRlong         return code 
   *new_name      IGRchar         The new name for the sdh.
   *new_desc      IGRchar         The new desc for the sdh.

Notes
   If the new_name argument is supplied it replaces the current
   name.  If the new_desc argument is supplied it replaces the
   current descripition.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   HGW  10/22/86 : Design date
   HGW  11/03/87 : Changed for version 1.1
\*/

class implementation GRsmdfhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grsymmacros.h"
#include "OMmacros.h"
#include "grsymdef.h"
#include "vardef.h"

method GRrename_sd(IGRlong *msg; IGRchar *new_name; IGRchar *new_desc)
{
IGRlong              om_msg;  
IGRlong              size;
IGRlong               temp;
IGRchar              name[MAX_SYMBOL_DEF_NAME];
struct GRvar_list    list[2];

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;

   if (new_name)
   {
      list[0].var = GR_SYMBOL_NAME;
      list[0].var_ptr = name;
      list[0].num_bytes = MAX_SYMBOL_DEF_NAME;
      list[0].bytes_returned = &temp;

      list[1].var = END_PARAM;
      list[1].var_ptr = NULL;
      list[1].num_bytes = NULL;
      list[1].bytes_returned = NULL;

      om_msg = om$send (
               msg = message GRsymbol.GRset_inq_symbol (msg, 0, list),
               targetid = my_id);

      if (om_msg & *msg & 1)
      {
         /*
          *  Remove the current name form the btree.
          */

         om_msg = gr$symsd_remove ( msg = msg, sd_name = name,
                  sd_objid = my_id);

         if (om_msg & *msg & 1)
         {
            size = strlen(new_name);
            size++;  /* Add one for the NULL terminator */
            list[0].var = GR_SYMBOL_NAME;
            list[0].var_ptr = new_name;
            list[0].num_bytes = size;
            list[0].bytes_returned = &temp;

            list[1].var = END_PARAM;
            list[1].var_ptr = NULL;
            list[1].num_bytes = NULL;
            list[1].bytes_returned = NULL;

            om_msg = om$send (
                     msg = message GRsymbol.GRset_inq_symbol (msg, 1, 
                     list), targetid = my_id);

            if (om_msg & *msg & 1)
            {
               /*
                *  Add the new name to the btree.
                */
               om_msg = gr$symsd_add ( msg = msg, sd_name = new_name,
                        sd_objid = my_id);   
            }
         }
      }
   }

   if (new_desc && (om_msg & *msg & 1))
   {
      size = strlen(new_desc);
      size++;  /* Add one for the NULL terminator */
      list[0].var = GR_SYMBOL_DESC;
      list[0].var_ptr = new_desc;
      list[0].num_bytes = size;
      list[0].bytes_returned = &temp;

      list[1].var = END_PARAM;
      list[1].var_ptr = NULL;
      list[1].num_bytes = NULL;
      list[1].bytes_returned = NULL;

      om_msg = om$send (
               msg = message GRsymbol.GRset_inq_symbol (msg, 1, list),
               targetid = my_id);
   }

   if (!(om_msg & *msg & 1))
   {
      *msg = MSFAIL;
   }else
   {
      *msg = MSSUCC;
   }
   return (om_msg);
}
end implementation GRsmdfhdr;
