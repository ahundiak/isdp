/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRset_inq_symbol

Description
   This method is used to inquire or set information pertaining to the
   symbol.

   *msg           IGRlong              return code 
   set_inq        IGRint               if 1 set the instance data
                                       if 0 inqure the instance data
   *var_list      struct GRvar_list    Varaible list

Notes
   The following items may be inquired.
      GR_SYMBOL_NAME
      GR_SYMBOL_DESC
      GR_TIME_STAMP

Return Values
   MSSUCC            -  if successful.
   MSFAIL            -  if failure.
   GR_E_INV_REQUEST  -  invalid request
   
\*/

class implementation GRsymbol;

#include "grimport.h"
#include "OMerrordef.h"
#include "godef.h"
#include "grsymdef.h"
#include "grerr.h"
#include "vardef.h"
#include "msdef.h"
#include "OMmacros.h"
#include "gocmacros.h"

method GRset_inq_symbol (IGRlong *msg; IGRint set_inq; 
                         struct GRvar_list *var_list)
{

IGRint   size;
IGRint   i;

   i = 0;
   *msg = MSSUCC;
   while (var_list[i].var != END_PARAM)
   {
      switch (var_list[i].var)
      {
         case GR_SYMBOL_NAME:
         {
            if (set_inq)
            {
               size = strlen(var_list[i].var_ptr);
               size++;  /* add one for NULL termination */
               om$vla_set_dimension(varray = me->symbol_name, size = size);
               strcpy (me->symbol_name, var_list[i].var_ptr);
            }else
            {
               size = om$dimension_of (varray = me->symbol_name);

               if (size)
               {
                  size = strlen(me->symbol_name);
                  size++;  /* add one for NULL termination */
                  if (size <= var_list[i].num_bytes)
                  {
                     strcpy (var_list[i].var_ptr, me->symbol_name);
                     *(var_list[i].bytes_returned) = size;
                  }else
                  {
                     strncpy (var_list[i].var_ptr, me->symbol_name, 
                              var_list[i].num_bytes);
                     *(var_list[i].bytes_returned) = var_list[i].num_bytes;
                  }
               }else
               {
                  var_list[i].var_ptr[0] = '\0';
                  *(var_list[i].bytes_returned) = 1;
               }
            }
         }
         break;

         case GR_SYMBOL_DESC:
         {
            if (set_inq)
            {
               size = strlen(var_list[i].var_ptr);
               size++;  /* add one for NULL termination */
               om$vla_set_dimension(varray = me->symbol_desc, size = size);
               strcpy (me->symbol_desc, var_list[i].var_ptr);
            }else
            {
               size = om$dimension_of (varray = me->symbol_name);

               if (size)
               {
                  size = strlen(me->symbol_desc);
                  size++;  /* add one for NULL termination */
                  if (size <= var_list[i].num_bytes)
                  {
                     strcpy (var_list[i].var_ptr, me->symbol_desc);
                     *(var_list[i].bytes_returned) = size;
                  }else
                  {
                     strncpy (var_list[i].var_ptr, me->symbol_desc, 
                              var_list[i].num_bytes);
                     *(var_list[i].bytes_returned) = var_list[i].num_bytes;
                  }
               }else
               {
                  var_list[i].var_ptr[0] = '\0';
                  *(var_list[i].bytes_returned) = 1;
               }
            }
         }
         break;

         case GR_TIME_STAMP:
         {
            if (set_inq)
            {
               me->time_stamp = *( (IGRlong *)var_list[i].var_ptr);
            }else
            {
               if (sizeof(IGRlong) <= var_list[i].num_bytes)
               {
                  *( (IGRlong *) var_list[i].var_ptr) = me->time_stamp;
                  *(var_list[i].bytes_returned) = sizeof(IGRlong);
               }else
               {
                  *msg = GR_E_INV_REQUEST;
                  *(var_list[i].bytes_returned) = 0;
               }
            }
         }
         break;

         default:
         {
            *msg = GR_E_INV_REQUEST;
         }
         break;
      }
      i++;
   }
   return(OM_S_SUCCESS);
}
end implementation GRsymbol;
