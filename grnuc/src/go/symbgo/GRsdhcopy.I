/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRcopy

Description
   This method is responsible for coping the symbol definition to the 
   specified space.

   *msg         IGRlong          Completion code
   *mod_env     struct GRmd_env  Module environment structure 
   *target_env  struct GRmd_env  The target environment structure 
   *newobjid    GRobjid          Objid of the transformed object

Algorighm
   This method is responsible for coping the symbol definition to
   the specified space.  This method is called each time a symbol
   reference header receives the copy message.  This method will 
   return the object that the symbol reference header connects to.

   There are three cases in which different approaches will need to 
   be taken.

   o  if (Current module environement = target environement)
      {
         The symbol definition is already in this space therefore
         there is no need to copy to this space.

         The sdh will return its id.
      }

   o  if (target environement allows only one copy of symbol definition)
      {
         if ( symbol definition is located in target environement )
         {
            if (time stamp of located symbol defition == my time stamp)
            {
               Return the id of located symbol definition.
            }else
            {
               Return error symbol definition not unique.
            }
         }else
         {
            make a copy of the symbol definition to the target env.
            Return the id of the copied symbol definition.
         }
      }

   o  if (target environement allows multiple copies of a symbol 
          definition)
      {
         if ( symbol definition(s) located in target environement )
         {
            for each located symbol definition
            {
               if (time stamp of located symbol definition == 
                   my time stamp)
               {
                  Return the id of located symbol definition.
               }
            }
         }

         make a copy of the symbol definition to the target env.
         Return the id of the copied symbol definition.
      }

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
   HGW      06/23/86 : Design Date
   HGW      06/23/86 : Creation Date
   HGW      08/14/86 : Changed terminology
   HGW      08/14/86 : Convert to 4.0
   HGW      11/02/87 : Convert to version 1.1
   SCW      07/22/92 : Ansi conversion
\*/

class implementation GRsmdfhdr;

#include "grimport.h"
#include "msdef.h"
#include "grerr.h"
#include "grsymdef.h"
#include "OMindex.h"
#include "OMerrordef.h"
#include "grsymmacros.h"
#include "vardef.h"

method GRcopy ( IGRlong *msg; struct GRmd_env *mod_env;
                struct GRmd_env *target_env; GRobjid *ret_objid )
{
IGRlong           om_msg;
IGRlong           ret_msg;
IGRlong           located_time_stamp;
IGRint            symbol_lib_type;
IGRint            buffer_size;
IGRint            i;
IGRint            malloc_flag;
IGRlong            temp;
IGRchar           *buffer;
GRspacenum        located_OS;
GRobjid           *obj_array;
struct GRmd_env   local_target_env;
struct GRvar_list list[2];
OM_S_OBJARRAY     located_symbol_def;

   *msg = MSSUCC;
   malloc_flag = FALSE;
   buffer = NULL;
   local_target_env.md_id = target_env->md_id;
   local_target_env.md_env.matrix_type = MAIDMX;
   MAidmx(&ret_msg, local_target_env.md_env.matrix);

   /********************* CASE 1 *********************/   
   /*
    *  Compare the module enviroment.  Only the osnum is 
    *  important.  Because there is only one module object 
    *  per object space.  The martrix is not needed since 
    *  the symbol definition is defined in the symbol coordinate 
    *  system not in the world coordinate system.
    */

   if (mod_env->md_id.osnum == target_env->md_id.osnum)
   {
      /*
       *  The symbol definition was already in the target space.
       *  Therefore, return the id of this symbol definition.
       */

      *ret_objid = my_id;
      return (OM_S_SUCCESS);
   }

   /*
    *  Inquire the type of symbol library from the target module:
    *  0) Allows multiple occurances of a symbol.
    *  1) Allows only one occurance of the symbol.
    */

   om_msg = gr$symget_sl_type (msg = &ret_msg, 
            sl_osnum = &target_env->md_id.osnum, 
            type = &symbol_lib_type);

   if (! (om_msg & ret_msg & 1))
   {
      *msg = MSFAIL;
      om_msg = OM_E_ABORT;
      goto FINISH;
   }

   /************************* Case two *************************/
   /*************** SINGLE OCCURANCE SYMBOL LIBRARY **************/
   if (symbol_lib_type)
   {
      /*
       *  Search the symbol library of the target space for another symbol
       *  definition with the same name.
       */

      located_symbol_def.size = sizeof (OM_S_OBJARRAY);
      located_symbol_def.tree_type = KEY_STRING;

      om_msg = gr$symsd_locate ( msg = &ret_msg, num_OS = 1,
               p_OS = &target_env->md_id.osnum, 
               sd_name = me->symbol_name, 
               p_OBJARRAY = &located_symbol_def, 
               p_loc_OS = &located_OS);

      if (! (om_msg & 1))
      {
         goto FINISH;
      }else if (!located_symbol_def.count)
      {
         /*
          *  Symbol definition not found so place a copy of this 
          *  symbol definition into the object space.
          */

         om_msg = om$send(mode = OM_e_wrt_message,
                  msg = message GRowner.GRcopy (&ret_msg, mod_env, 
                  &local_target_env, ret_objid ),
                  targetid = my_id);
      
         if (! (om_msg & ret_msg & 1))
         {
            *msg = MSFAIL;
            goto FINISH;
         }

         /*
          *  The symbol was copied into the target space.  The
          *  symbol has a unique name is that space. 
          */

          return (OM_S_SUCCESS);
      }else
      {
         /*
          *  A symbol was located then compare the time stamp on 
          *  the located sdh to this sdh.
          */

         list[0].var = GR_TIME_STAMP;
         list[0].var_ptr = (IGRchar *)&located_time_stamp,
         list[0].num_bytes = sizeof (IGRlong);
         list[0].bytes_returned = &temp;

         list[1].var = END_PARAM;
         list[1].var_ptr = NULL;
         list[1].num_bytes = NULL;
         list[1].bytes_returned = NULL;

         om_msg = om$send (
                  msg = message GRsymbol.GRset_inq_symbol (&ret_msg, 
                  NULL, list),
                  targetid = located_symbol_def.array[0],
                  targetos = located_OS);

         if (! (om_msg & ret_msg & 1))
         {
            *msg = MSFAIL;
            goto FINISH;
         }

         if (me->time_stamp == located_time_stamp )
         {
            /*
             *  The symbols have the same name and were created
             *  at the same time.  It is assumed they are
             *  the same symbol.  
             */

            *ret_objid = located_symbol_def.array[0];
            return (OM_S_SUCCESS);
         }else
         {
            /*
             *  The located symbol definition is different from this 
             *  symbol definition.  The space only allows one symbol
             *  definition with that name to exist, therefore an 
             *  error has occurred.
             */

            *msg = GR_E_SDNOTUNIQUE;
            return (OM_E_ABORT);
         }
      }  
   }  /* End of case 2  */
   /*************************** Case 3 *********************************/
   /****************** MULTIPLE OCCURANCE SYMBOL LIBRARY ***************/
   else
   {
      /*
       *  Search the symbol library of the target space for all symbol
       *  definitions with the same name as this symbol definition.
       */

      buffer_size = (sizeof(OM_S_OBJID) * MAX_SYMBOL_DEF_INIT) + 
                     sizeof(OM_S_OBJARRAY);

      if (!(buffer = om$malloc (size = buffer_size)))
      {
         om_msg = OM_E_ABORT;
         *msg = MSFAIL;
         goto FINISH;
      }
      malloc_flag = TRUE;
  
      ((OM_S_OBJARRAY *)buffer)->size = buffer_size;
      ((OM_S_OBJARRAY *)buffer)->tree_type = KEY_STRING;

      om_msg = gr$symsd_locate ( msg = &ret_msg, num_OS = 1,
               p_OS = &target_env->md_id.osnum, 
               sd_name = me->symbol_name, 
               p_OBJARRAY = buffer, p_loc_OS = &located_OS);
         
      if (! (om_msg & 1))
      {
         goto FINISH;
      }else if (ret_msg == GR_I_EXCEDBUF)
      {
         /*  
          *  The buffer was not big enough reallocate a bigger
          *  buffer.
          */

         buffer_size = (sizeof(OM_S_OBJID) * ((((OM_S_OBJARRAY *)
                       buffer)->count) - 1)) + sizeof(OM_S_OBJARRAY);

         om$dealloc (ptr = buffer);
         malloc_flag = FALSE;  
         if (!(buffer = om$malloc (size = buffer_size)))
         {
            om_msg = OM_E_ABORT;
            *msg = MSFAIL;
            goto FINISH;
         }
         
         malloc_flag = TRUE;

         ((OM_S_OBJARRAY *)buffer)->size = buffer_size;
         ((OM_S_OBJARRAY *)buffer)->tree_type = KEY_STRING;

         om_msg = gr$symsd_locate ( msg = &ret_msg, num_OS = 1,
                  p_OS = &target_env->md_id.osnum, 
                  sd_name = me->symbol_name, 
                  p_OBJARRAY = buffer, p_loc_OS = &located_OS);
         
         if (! (om_msg & 1))
         {
            goto FINISH;
         }
      }
       
      if ( ! (((OM_S_OBJARRAY *)buffer)->count))
      {
         /*
          *  Symbol definition not found so place a copy of this 
          *  symbol definition into the object space.
          */

         om_msg = om$send(mode = OM_e_wrt_message,
                  msg = message GRowner.GRcopy ( &ret_msg, mod_env,
                  &local_target_env, ret_objid ),
                  targetid = my_id);
      
         if (! (om_msg & ret_msg & 1))
         {
            *msg = MSFAIL;
            goto FINISH;
         }

         /*
          *  The symbol was copied into the target space. The
          *  symbol has a unique name is that space. 
          */
      
         om$dealloc (ptr = buffer);
         return (OM_S_SUCCESS);
      }else
      {
         /*
          *  Symbol definitions within the object space were located.
          *  Since this space allows for multiple symbol definitions 
          *  check if any of the symbol definitions are the same as 
          *  this symbol definition;
          */
         
         obj_array = &(((OM_S_OBJARRAY *)buffer)->array[0]);

         for (i=0; i < ((OM_S_OBJARRAY *)buffer)->count; ++i)
         {
            list[0].var = GR_TIME_STAMP;
            list[0].var_ptr = (IGRchar *)&located_time_stamp,
            list[0].num_bytes = sizeof (IGRlong);
            list[0].bytes_returned = &temp;

            list[1].var = END_PARAM;
            list[1].var_ptr = NULL;
            list[1].num_bytes = NULL;
            list[1].bytes_returned = NULL;

            om_msg = om$send (
                     msg = message GRsymbol.GRset_inq_symbol (&ret_msg, 
                     NULL, list),
                     targetid = obj_array[i], targetos = located_OS);

            if (! (om_msg & ret_msg & 1))
            {
               *msg = MSFAIL;
               goto FINISH;
            }

            if (me->time_stamp == located_time_stamp )
            {
               /*
                *  The symbols have the same name and were created
                *  at the same time.  It is assumed they are
                *  the same symbol.
                */

               om$dealloc (ptr = buffer);
               *ret_objid = obj_array[i];
               return (OM_S_SUCCESS);
            }
         }  /* End of for loop   */

         /*
          *  The located symbol definitions were different from 
          *  this symbol symbol definition.  The space allows multiple
          *  symbols with the same name to exist, therefore copy
          *  this symbol into the target space.
          */

         om_msg = om$send(mode = OM_e_wrt_message,
                  msg = message GRowner.GRcopy ( &ret_msg, mod_env,
                  &local_target_env, ret_objid ),
                  targetid = my_id);
      
         if (! (om_msg & ret_msg & 1))
         {
            *msg = MSFAIL;
            goto FINISH;
         }

         om$dealloc (ptr = buffer);
         return (OM_S_SUCCESS);
      }
   }  /* End of case 3 */

FINISH:
   if (malloc_flag)
   {
      om$dealloc (ptr = buffer);
   }
   return (om_msg);
}

end implementation GRsmdfhdr;
