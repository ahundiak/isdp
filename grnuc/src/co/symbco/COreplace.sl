/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
   This is the command class for the commands which are used to replace
   cell and symbols.

   This class has transactions files for the following commands:
      REPLACE SINGLE OCCURENCE OF SYMBOL OR CELL
      REPLACE ALL OCCURENCES OF A SYBMOL
      REPLACE ALL OCCURENCES OF A CELL
      REPLACE ALL OCCURENCES OF ALL SYMBOLS
      REPLACE ALL OCCURENCES OF ALL CELLS

Notes
   Each action within this file uses local instance data to store
   or retrieve information.  This is not a good programming practice.
   A better approach is to allow for the local instance data to be 
   passed into the action.  Thus, when COB allows for data to passed
   into an action these methods will be converted to take any local 
   instance data that is used or modified as arguments.
   
History
   Gray Winn    04/06/88   Creation date.
   SCW          07/08/92   ANSI conversion
\*/

class           COreplace
super_class     CEO_GSLOCATE
start_state     terminate
product_name    "$PLATFORM"

specification


#include "msdef.h"
#include "igrmacros.h"
#include "grdpbmacros.h"
#include "grerr.h"
#include "codef.h"
#include "OMindex.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "lcdef.h"
#include "lc.h"
#include "grgsdef.h"
#include "growner.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "var.h"
#include "grsymdef.h"

instance
{
   IGRint                        asl_count;
   IGRint                        lsl_count;
   IGRint                        cell_count;
   IGRint                        cmpflag;
   IGRchar                       cell_name[MAX_SYMBOL_DEF_NAME];
   struct GRmd_env               asl_env;
   variable OM_S_BTREE_CONTENTS  asl_objids[];
   variable OM_S_BTREE_CONTENTS  lsl_objids[];
   variable IGRchar              lsl_sd_inuse[];
   variable struct GRobj_env     cell_objids[];
   variable IGRchar              char_array[];
}

implementation

#include "coimport.h"
#include "grmessage.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "grsymmacros.h"
#include "grsymdef.h"
#include "OMmacros.h"
#include "vardef.h"
#include "grerr.h"

from GRsmdfhdr    import   GRdisplay_all_instances;
from GRowner      import   GRreplace, GRchg_owner_properties;
from GRsymbol     import   GRset_inq_symbol;
from GRgraphics   import   GRdelete;

/*\
Description
   This action will get the active cell library

Notes
   This action sets up the following local instance data:
      -  me->asl_env
\*/
action get_asl_env( IGRlong *sts )
{
   *sts = MSSUCC;
   gr$symget_asl_env (msg = sts, asl_env = &me->asl_env);
}

/*\
Description
   This action will get all symbol definitions within the active cell 
   library.

Notes
   This action is dependent upon the following instance data:
      -  me->asl_env

   This action sets up the following local instance data:
      -  me->asl_count
      -  me->asl_objids
      -  me->cmpflag
\*/
action get_all_sd_in_asl( IGRlong *sts )
{
   /*
    *  Search the symbol library for all symbol definitions.
    */

   me->cmpflag = TRUE;
   me->asl_count = 100;
   om$vla_set_dimension(varray = me->asl_objids, size = me->asl_count);
   status = GRbtreelocate_all (sts, me->asl_env.md_id.osnum,
            GR_SD_BTREE_NAME, me->asl_objids, 0, 100, &me->asl_count);
         
   if (*sts == GR_I_EXCEDBUF)
   {
      /*  
       *  The buffer was not big enough allocate a bigger buffer.
       */

      om$vla_set_dimension(varray = me->asl_objids, size = me->asl_count);
      status = GRbtreelocate_all (sts, me->asl_env.md_id.osnum,
               GR_SD_BTREE_NAME, me->asl_objids, 0, me->asl_count, 
               &me->asl_count);
   }
}

/*\
Description
   This action will get all symbol definitions within the local symbol
   library.

Notes
   This action is dependent upon the following instance data:
      -  me->asl_objids
      -  me->asl_count

   This action sets up the following local instance data:
      -  me->lsl_count
      -  me->lsl_objids
      -  me->lsl_sd_inuse
      -  me->cmpflag
\*/
action get_all_sd_in_lsl( IGRlong *sts )
{
IGRint      i,j;

   /*
    *  Search the local symbol library for all symbol definitions.
    */

   me->cmpflag = TRUE;
   me->lsl_count = 100;
   om$vla_set_dimension(varray = me->lsl_objids, size = me->lsl_count);
   status = GRbtreelocate_all (sts, me->ModuleInfo.md_id.osnum,
            GR_SD_BTREE_NAME, me->lsl_objids, 0, 100, &me->lsl_count);
         
   if (*sts == GR_I_EXCEDBUF)
   {
      /*  
       *  The buffer was not big enough allocate a bigger buffer.
       */

      om$vla_set_dimension(varray = me->lsl_objids, size = me->lsl_count);
      status = GRbtreelocate_all (sts, me->ModuleInfo.md_id.osnum,
               GR_SD_BTREE_NAME, me->lsl_objids, 0, me->lsl_count, 
               &me->lsl_count);
   }

   om$vla_set_dimension(varray = me->lsl_sd_inuse, size = me->lsl_count);

   for (i=0; i < me->lsl_count; ++i)
   {
      me->lsl_sd_inuse[i] = FALSE;
   }

   for (i=0; i < me->asl_count; ++i)
   {
      for (j=0; j < me->lsl_count; ++j)
      {  
         if (!strcmp (me->asl_objids[i].name.key_name,
                      me->lsl_objids[j].name.key_name))
         {
            me->lsl_sd_inuse[j] = TRUE;
         }
      }
   }
}

/*\
Description
   This action will get all cells in the current module environment.

Notes
   This action is dependent upon the following instance data:
      -  me->asl_objids
      -  me->asl_count

   This action sets up the following local instance data:
      -  me->cell_count
      -  me->cmpflag
\*/
action get_all_cells_in_module( IGRlong *sts )
{
   *sts = MSSUCC;
   me->cmpflag = TRUE;

   /*
    *  Get all the cells within the active module environemnt
    *  that match one of the names of the cells within the library.
    */
         
   status = GRget_all_cells (sts, OM_Gw_current_OS, my_id, 
            &me->ModuleInfo, me->asl_count, me->asl_objids, NULL,
            &me->located_chansel);
}

/*\
Description
   This action will get a symbol definition from the active symbol
   library.

Notes
   This action sets up the following local instance data:
      -  me->asl_env
      -  me->asl_objids
      -  me->asl_count
      -  me->cmpflag
\*/
action locate_sd_in_asl_by_name( IGRlong *sts )
{
struct GRid temp_id;

   me->cmpflag = FALSE;
   strcpy (me->cell_name, me->event1.event.keyin);
   status = gr$symsd_locate_in_asl (msg = sts, 
            sd_name = me->event1.event.keyin, sl_env = &me->asl_env,
            sd_id = &temp_id);

   if (status & *sts & 1)
   {
      me->asl_count = 1;
      om$vla_set_dimension(varray = me->asl_objids, size = me->asl_count);
      me->asl_objids[0].objid = temp_id.objid;
   }else
   {
      *sts = MSFAIL;
   }
}


/*\
Description
   This action will get a symbol definition from the local cell
   library.

Notes
   This action sets up the following local instance data:
      -  me->lsl_objids
      -  me->lsl_count
      -  me->cmpflag
\*/
action locate_sd_in_lsl_by_name( IGRlong *sts )
{
IGRint         i;
IGRint         array_size;
GRspacenum     located_OS;
OM_S_OBJARRAY  *objarray;

   me->cmpflag = FALSE;
   array_size = (sizeof(OM_S_OBJID) * MAX_SYMBOL_DEF_INIT) + 
                sizeof(OM_S_OBJARRAY);
   om$vla_set_dimension(varray = me->char_array, size = array_size);
   objarray = (OM_S_OBJARRAY *)me->char_array;
   objarray->size = array_size;
   objarray->tree_type = KEY_STRING;

   status = gr$symsd_locate (msg = sts, num_OS = 1,
            p_OS = &me->ModuleInfo.md_id.osnum,
            sd_name = me->event1.event.keyin,
            p_OBJARRAY = objarray, p_loc_OS = &located_OS);
         
   if ( (!(status & *sts & 1)) || (!objarray->count) )
   {
      *sts = MSFAIL;
   }else if (*sts == GR_I_EXCEDBUF)
   {
      /*  
       *  The buffer was not big enough reallocate bigger buffer.
       */

      array_size = sizeof(OM_S_OBJID) * (objarray->count - 1) +
                   sizeof(OM_S_OBJARRAY);
      om$vla_set_dimension(varray = me->char_array, size = array_size);
      objarray = (OM_S_OBJARRAY *)me->char_array;
      objarray->size = array_size;
      objarray->tree_type = KEY_STRING;

      status = gr$symsd_locate (msg = sts, num_OS = 1,
               p_OS = &me->ModuleInfo.md_id.osnum,
               sd_name = me->event1.event.keyin,
               p_OBJARRAY = objarray, p_loc_OS = &located_OS);
                              
      if (!(status & *sts & 1))
      {
         *sts = MSFAIL;
      }
   }

   if (*sts & 1)
   {
      me->lsl_count = objarray->count;
      om$vla_set_dimension(varray = me->lsl_objids, size = me->lsl_count);
      om$vla_set_dimension(varray = me->lsl_sd_inuse, 
                           size = me->lsl_count);

      for (i=0; i < me->lsl_count; ++i)
      {
         /*
          *  Set the inuse bit to FALSE for each symbol definition
          *  in the local cell library.
          */

         me->lsl_sd_inuse[i] = FALSE;
         me->lsl_objids[i].objid = objarray->array[i];
      }

      /*
       *  Set the inuse bit on for the last symbol definition.
       *  This will allow one symbol definition to be replaced at
       *  a time.
       */

      me->lsl_sd_inuse[me->lsl_count - 1] = TRUE;
   }
}

/*\
Description
   This action will locate all cells in the current module environment
   with a given name.

Notes
   This action sets up the following local instance data:
      -  me->cmpflag
\*/
action locate_cells_by_name( IGRlong *sts )
{
   *sts = MSSUCC;
   me->cmpflag = FALSE;

   /*
    *  Get all the cells within the active module environemnt
    *  that match one of the names of the cells within the library.
    */
         
   status = GRget_cell (sts, OM_Gw_current_OS, my_id, &me->ModuleInfo, 
            me->event1.event.keyin, NULL, &me->located_chansel);
}

/*\
Description
   This action will erase all symbols that are associated with the
   given set of symbol definitions.

Notes
   This action is dependent upon the following instance data:
      -  me->lsl_objids
      -  me->lsl_count
      -  me->lsl_sd_inuse
\*/
action erase_sd( IGRlong *sts )
{
long           msg;
IGRint         i;
enum GRdpmode  dpmode;

   dpmode = GRbe;
   for (i=0; i < me->lsl_count; ++i)
   {
      if (me->lsl_sd_inuse[i])
      {
         status = om$send(
                  msg = message GRsmdfhdr.GRdisplay_all_instances (&msg,
                  &me->ModuleInfo.md_env.matrix_type,
                  me->ModuleInfo.md_env.matrix, &dpmode, 
                  &me->ModuleInfo.md_id),
                  targetid = me->lsl_objids[i].objid,
                  targetos = me->ModuleInfo.md_id.osnum);
      }
   }
}

/*\
Description
   This action will highlight all symbols that are associated with the
   given set of symbol definitions.

Notes
   This action is dependent upon the following instance data:
      -  me->lsl_objids
      -  me->lsl_count
      -  me->lsl_sd_inuse
\*/
action highlight_sd( IGRlong *sts )
{
long           msg;
IGRint         i;
enum GRdpmode  dpmode;

   dpmode = GRhd;
   for (i=0; i < me->lsl_count; ++i)
   {
      if (me->lsl_sd_inuse[i])
      {
         status = om$send(
                  msg = message GRsmdfhdr.GRdisplay_all_instances (&msg,
                  &me->ModuleInfo.md_env.matrix_type,
                  me->ModuleInfo.md_env.matrix, &dpmode, 
                  &me->ModuleInfo.md_id),
                  targetid = me->lsl_objids[i].objid,
                  targetos = me->ModuleInfo.md_id.osnum);
      }
   }
}

/*\
Description
   This action will display all symbols that are associated with the
   given set of symbol definitions.

Notes
   This action is dependent upon the following instance data:
      -  me->lsl_objids
      -  me->lsl_count
      -  me->lsl_sd_inuse
\*/
action draw_sd( IGRlong *sts )
{
long           msg;
IGRint         i;
enum GRdpmode  dpmode;

   dpmode = GRbd;
   for (i=0; i < me->lsl_count; ++i)
   {
      if (me->lsl_sd_inuse[i])
      {
         status = om$send(
                  msg = message GRsmdfhdr.GRdisplay_all_instances (&msg,
                  &me->ModuleInfo.md_env.matrix_type,
                  me->ModuleInfo.md_env.matrix, &dpmode, 
                  &me->ModuleInfo.md_id),
                  targetid = me->lsl_objids[i].objid,
                  targetos = me->ModuleInfo.md_id.osnum);
      }
   }
}

/*\
Description
   This action will erase all objects on the graphic set channel
\*/
action erase_objects( IGRlong *sts )
{
   status = gr$gsdisplay ( msg = sts, dpmode = GRbe,
            display_id = &me->ModuleInfo.md_id,
            p_chanselect = &me->located_chansel);
}

/*\
Description
   This action will display all objects on the graphic set channel
\*/
action draw_objects( IGRlong *sts )
{
   status = gr$gsdisplay ( msg = sts, dpmode = GRbd,
            display_id = &me->ModuleInfo.md_id,
            p_chanselect = &me->located_chansel);
}


/*\
Description
   This action will erase the highlight plane.
\*/
action erase_highlight( IGRlong *sts )
{
   dp$erase_hilite (msg = sts, objid = me->ModuleInfo.md_id.objid,
      osnum = me->ModuleInfo.md_id.osnum);
}

/*\
Description
   This action will empty all objects from the graphic set channel.
\*/
action empty_channel( IGRlong *sts )
{
   status = gr$gsempty ( msg = sts, p_chanselect = &me->located_chansel);
}

/*\
Description
   This action will get all the cells on the graphics set channel
   and their names.

Notes
   This action is dependent upon the following instance data:
      -  me->cmpflag

   This action defines the following instance data:
      -  me->cell_count
      -  me->cell_objids
      -  me->char_array

\*/
action get_cell_names( IGRlong *sts )
{
long                 msg;
IGRint               i;
IGRlong              temp;
struct GRvar_list    list[2];

   /*
    *  Did we find any cells?
    */

   status = gr$gsinqcount ( msg = sts, count = &me->cell_count,
            p_chanselect = &me->located_chansel);

   if (!me->cell_count)
   {
      *sts = MSFAIL;
   }else
   {
      om$vla_set_dimension(varray = me->cell_objids, 
                           size = me->cell_count);

      status = gr$gsget_objects ( msg = sts, array = me->cell_objids,
               size = sizeof (struct GRobj_env) * me->cell_count,
               count = &me->cell_count, 
               p_chanselect = &me->located_chansel);

      if (me->cmpflag)
      {   
         /*
          *  The names of the cells with the active module environment.
          */

         om$vla_set_dimension(varray = me->char_array, 
                              size = me->cell_count * MAX_SYMBOL_DEF_NAME);

         list[0].var = GR_SYMBOL_NAME;
         list[0].num_bytes = MAX_SYMBOL_DEF_NAME;
         list[0].bytes_returned = &temp;

         list[1].var = END_PARAM;
         list[1].var_ptr = NULL;
         list[1].num_bytes = NULL;
         list[1].bytes_returned = NULL;
   
         for (i=0; i < me->cell_count; ++i)
         {
            list[0].var_ptr = &me->char_array[i * MAX_SYMBOL_DEF_NAME];
            status = om$send (
                     msg = message GRsymbol.GRset_inq_symbol(&msg, 0, list),
                     targetos = me->cell_objids[i].obj_id.osnum,
                     targetid = me->cell_objids[i].obj_id.objid);
         }
      }
   }
}

/*\
Description
   This action will replace the symbol definitions in the local cell
   library with its counter part in the active cell library.

Notes
   This action is dependent upon the following instance data:
      -  me->asl_env
      -  me->asl_count
      -  me->asl_objids
      -  me->lsl_count
      -  me->lsl_objids
      -  me->lsl_sd_inuse
      -  me->cmpflag
\*/
action replace_sd( IGRlong *sts )
{
long           msg;
IGRint         i,j;
struct GRid    sdh_id;
struct GRid    new_id;

   for (i=0; i < me->asl_count; ++i)
   {
      for (j=0; j < me->lsl_count; ++j)
      {
         if (me->lsl_sd_inuse[j])
         {
            if ( (!me->cmpflag) ||
                 (!strcmp (me->asl_objids[i].name.key_name,
                           me->lsl_objids[j].name.key_name)))
            {
               /*
                *  Replace the symbol definition
                */

               sdh_id.osnum = me->asl_env.md_id.osnum;
               sdh_id.objid = me->asl_objids[i].objid;
               status = om$send (
                        msg = message GRowner.GRreplace (&msg,
                        &me->ModuleInfo, &me->asl_env, &sdh_id, &new_id),
                        targetid = me->lsl_objids[j].objid,
                        targetos = me->ModuleInfo.md_id.osnum);

               me->lsl_objids[j].objid = new_id.objid;   
            }
         }
      }
   }
}

/*\
Description
   This action will replace the cells in the active module environemnt
   with its counter part in the active cell library.

Notes
   This action is dependent upon the following instance data:
      -  me->asl_env
      -  me->asl_count
      -  me->asl_objids
      -  me->cell_count
      -  me->cell_objids
      -  me->cmpflag
\*/
action replace_cells( IGRlong *sts )
{
long        msg;
IGRint      i,j;
struct GRid sdh_id;
struct GRid temp_id;

   for (i=0; i < me->asl_count; ++i)
   {
      for (j=0; j < me->cell_count; ++j)
      {
         if ( (!me->cmpflag) || 
              (!strcmp (me->asl_objids[i].name.key_name,
                        &me->char_array[j * MAX_SYMBOL_DEF_NAME])))
         {
            /*
             *  Replace the cell definition
             */
   
            sdh_id.osnum = me->asl_env.md_id.osnum;
            sdh_id.objid = me->asl_objids[i].objid;
            status = om$send (
                     msg = message GRowner.GRreplace (&msg,
                     &me->cell_objids[j].mod_env, &me->asl_env, &sdh_id,
                     &temp_id),
                     targetid = me->cell_objids[j].obj_id.objid,
                     targetos = me->cell_objids[j].obj_id.osnum);
         }
      }
   }
}

/*\
Description
   This action will parse a string for yes or no.
\*/
action parse_y_or_n( IGRlong *sts )
{
IGRint   flag;

   GRparseyn (sts, me->event1.event.keyin, &flag);

   if (*sts & 1)
   {
      if (flag)
      {
         *sts = MSSUCC;
      }else
      {
         *sts = MSFAIL;  
      }
   }else
   {
      *sts = GR_E_INV_REQUEST;
   }   
}

/*\
Description
   This action will set the inuse bit for one of the symbol definitions
   in the local symbol library.

Notes
   This action modifies the following instance data:
      -  me->lsl_count
      -  me->lsl_sd_inuse
\*/
action increment_inuse( IGRlong *sts )
{
   me->lsl_count --;
   if (me->lsl_count)
   {
      me->lsl_sd_inuse[me->lsl_count - 1] = TRUE;
   }else
   {
      *sts = MSFAIL;
   }
}

/*\
Description
   This action will generate the prompt for a symbol definition.

Notes
   This action modifies the following instance data:
      -  me->lsl_count
      -  me->lsl_sd_inuse
      -  me->lsl_objids
\*/
action replace_prompt( IGRlong *sts )
{
long              msg;
IGRint            i;
time_t            time_stamp;
IGRlong           temp;
IGRchar           ascii_time_stamp[27];
struct GRvar_list list[2];

   for (i=0; i < me->lsl_count; ++i)
   {
      if (me->lsl_sd_inuse[i])
      {
         /*
          *  Get the time stamp
          */

         list[0].var = GR_TIME_STAMP;
         list[0].var_ptr = (IGRchar *)&time_stamp;
         list[0].num_bytes = sizeof (IGRlong);
         list[0].bytes_returned = &temp;

         list[1].var = END_PARAM;
         list[1].var_ptr = NULL;
         list[1].num_bytes = NULL;
         list[1].bytes_returned = NULL;

         status = om$send(msg = message GRsymbol.GRset_inq_symbol (&msg, 0, 
                  list),
                  targetid = me->lsl_objids[i].objid,
                  targetos = me->ModuleInfo.md_id.osnum);

         /*
          *  Convert the time stamp to an ascii string.
          */

         GRcvt_time_to_ascii (sts, &time_stamp, ascii_time_stamp);

         /*
          *  Prompt the user to insure that he wants to replace
          *  this version of the symbol definition.
          */

         ex$message(msgnumb=GR_I_One, type="%s", var=`ascii_time_stamp`);
         break;
      }
   }
}

/*\
Description
   This action will put the last event onto the software queue.
\*/
action put_event_on_queue( IGRlong *sts )
{
IGRint   response;
IGRlong  size;
            
   response = me->event1.response;
   size  = sizeof(struct GRevent) - (sizeof(IGRlong) * 2);
   status = ex$putque ( msg = sts, response = &response,
            byte = &size, buffer = (IGRchar *)&me->event1.event);

}

/*\
Description
   This action deletes a symbol definition
\*/
action delete_symbol_definition( IGRlong *sts )
{
   status = om$send (msg = message GRgraphics.GRdelete(sts, &me->asl_env),
            targetid = me->asl_objids[0].objid,
            targetos = me->asl_env.md_id.osnum);

   if (!(status & 1))
   {
      *sts = MSFAIL;
   }
}

/*\
Description
   This action display the status of the deleted symbol definiton.
\*/
action delete_status( IGRlong *sts )
{
   *sts = MSSUCC;
   ex$message (msgnumb = GR_I_CelDel, type = "%s", var = `me->cell_name`);
}

/*\
Description
   This action will generate the prompt for a symbol definition delete.
\*/
action delete_prompt( IGRlong *sts )
{
   ex$message(msgnumb=GR_P_DelCelYN, type="%s", var=`me->cell_name`,
      buff = me->prompt);
}

/*\
Description
   This action saves the active cell library.
\*/
action save_asl( IGRlong *sts )
{
   *sts = MSSUCC;
   gr$symsave_asl (msg = sts);
}

action clear_symbol_symbology_properties( IGRlong *sts )
{
IGRshort   properties;

   *sts = MSSUCC;
   properties = GR_SYM_DISPLAY_ATTR;
   status = gr$gspass ( msg = sts,
            pass_msg = message GRowner.GRchg_owner_properties (sts, 0, 
            &properties),
            p_chanselect = &me->located_chansel);
}
