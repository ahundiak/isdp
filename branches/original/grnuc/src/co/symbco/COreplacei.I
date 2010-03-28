class implementation COreplace;



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


method get_asl_env ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

   *sts = MSSUCC;
   gr$symget_asl_env (msg = sts, asl_env = &me->asl_env);
quit:
  return OM_S_SUCCESS;
}

method get_all_sd_in_asl ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method get_all_sd_in_lsl ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method get_all_cells_in_module ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

   *sts = MSSUCC;
   me->cmpflag = TRUE;

   /*
    *  Get all the cells within the active module environemnt
    *  that match one of the names of the cells within the library.
    */
         
   status = GRget_all_cells (sts, OM_Gw_current_OS, my_id, 
            &me->ModuleInfo, me->asl_count, me->asl_objids, NULL,
            &me->located_chansel);
quit:
  return OM_S_SUCCESS;
}

method locate_sd_in_asl_by_name ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method locate_sd_in_lsl_by_name ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method locate_cells_by_name ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

   *sts = MSSUCC;
   me->cmpflag = FALSE;

   /*
    *  Get all the cells within the active module environemnt
    *  that match one of the names of the cells within the library.
    */
         
   status = GRget_cell (sts, OM_Gw_current_OS, my_id, &me->ModuleInfo, 
            me->event1.event.keyin, NULL, &me->located_chansel);
quit:
  return OM_S_SUCCESS;
}

method erase_sd ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method highlight_sd ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method draw_sd ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method erase_objects ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

   status = gr$gsdisplay ( msg = sts, dpmode = GRbe,
            display_id = &me->ModuleInfo.md_id,
            p_chanselect = &me->located_chansel);
quit:
  return OM_S_SUCCESS;
}

method draw_objects ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

   status = gr$gsdisplay ( msg = sts, dpmode = GRbd,
            display_id = &me->ModuleInfo.md_id,
            p_chanselect = &me->located_chansel);
quit:
  return OM_S_SUCCESS;
}

method erase_highlight ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

   dp$erase_hilite (msg = sts, objid = me->ModuleInfo.md_id.objid,
      osnum = me->ModuleInfo.md_id.osnum);
quit:
  return OM_S_SUCCESS;
}

method empty_channel ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

   status = gr$gsempty ( msg = sts, p_chanselect = &me->located_chansel);
quit:
  return OM_S_SUCCESS;
}

method get_cell_names ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method replace_sd ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method replace_cells ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method parse_y_or_n ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method increment_inuse ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

   me->lsl_count --;
   if (me->lsl_count)
   {
      me->lsl_sd_inuse[me->lsl_count - 1] = TRUE;
   }else
   {
      *sts = MSFAIL;
   }
quit:
  return OM_S_SUCCESS;
}

method replace_prompt ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method put_event_on_queue ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

IGRint   response;
IGRlong  size;
            
   response = me->event1.response;
   size  = sizeof(struct GRevent) - (sizeof(IGRlong) * 2);
   status = ex$putque ( msg = sts, response = &response,
            byte = &size, buffer = (IGRchar *)&me->event1.event);

quit:
  return OM_S_SUCCESS;
}

method delete_symbol_definition ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

   status = om$send (msg = message GRgraphics.GRdelete(sts, &me->asl_env),
            targetid = me->asl_objids[0].objid,
            targetos = me->asl_env.md_id.osnum);

   if (!(status & 1))
   {
      *sts = MSFAIL;
   }
quit:
  return OM_S_SUCCESS;
}

method delete_status ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

   *sts = MSSUCC;
   ex$message (msgnumb = GR_I_CelDel, type = "%s", var = `me->cell_name`);
quit:
  return OM_S_SUCCESS;
}

method delete_prompt ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

   ex$message(msgnumb=GR_P_DelCelYN, type="%s", var=`me->cell_name`,
      buff = me->prompt);
quit:
  return OM_S_SUCCESS;
}

method save_asl ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

   *sts = MSSUCC;
   gr$symsave_asl (msg = sts);
quit:
  return OM_S_SUCCESS;
}

method clear_symbol_symbology_properties ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

IGRshort   properties;

   *sts = MSSUCC;
   properties = GR_SYM_DISPLAY_ATTR;
   status = gr$gspass ( msg = sts,
            pass_msg = message GRowner.GRchg_owner_properties (sts, 0, 
            &properties),
            p_chanselect = &me->located_chansel);
quit:
  return OM_S_SUCCESS;
}

end implementation COreplace;
