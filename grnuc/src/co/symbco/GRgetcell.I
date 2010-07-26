/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRget_cell

Description
   This function will find the cell(s) with the given name and form a
   graphics set which contains these cells.

   *msg              IGRlong              Return code
   osnum             GRspacenum           command's osnum
   objid             GRobjid              command's objid
   *mod_env          struct GRmd_env      module environment
   name[]            IGRchar              name of cell
   *gs_id            struct GRid          graphics set id
   p_chanselect      OM_p_CHANSELECT      command's channel

Notes
   The name argument may be NULL if it is NULL all cells will be found.
   The gs_id may be NULL.
   The p_chanselect may be NULL.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn   03/31/88    Creation Date
   SCW         07/08/92    ANSI conversion 
\*/

class implementation Root;

#include "coimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "exdef.h"
#include "ex.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "dp.h"
#include "dpdef.h"
#include "lcdef.h"
#include "lc.h"
#include "OMindex.h"
#include "OMminimum.h"
#include "dpstruct.h"
#include "grsymdef.h"
#include "vardef.h"
#include "grgsmacros.h"
#include "OMerrordef.h"

from  GRsymbol    import   GRset_inq_symbol;
from  GRgrset     import   GSstart_transition, GSend_transition;

struct temp
{  
   IGRint               num_objids;
   struct GRid          gs_id;
   struct GRid          sv_id;
   OM_p_BTREE_CONTENTS  sd_objids;
};

IGRint GRget_cell (msg, osnum, objid, mod_env, name, gs_id, p_chanselect)
IGRlong              *msg;
GRspacenum           osnum;
GRobjid              objid;
struct GRmd_env      *mod_env;
IGRchar              name[];
struct GRid          *gs_id;
OM_p_CHANSELECT      p_chanselect;
{
OM_S_BTREE_CONTENTS     sd_objid;

   if (name)
   {
      sd_objid.objid = NULL_OBJID;
      strcpy (sd_objid.name.key_name, name);
      return (GRget_all_cells (msg, osnum, objid, mod_env, 1, &sd_objid, 
              gs_id, p_chanselect));
   }else
   {
      return (GRget_all_cells (msg, osnum, objid, mod_env, 0, NULL,
              gs_id, p_chanselect));
   }   
}

/*\
Name
   GRget_all_cells

Description
   This function will find all cells that match a given list of
   cells and then form a graphics set which contains these cells.

   *msg              IGRlong              Return code
   osnum             GRspacenum           command's osnum
   objid             GRobjid              command's objid
   num_objids        IGRint               the number of comparison cells
   sd_objids         OM_S_BTREE_CONTENTS  cells to compare against
   *mod_env          struct GRmd_env      module environment
   *gs_id            struct GRid          graphics set id
   p_chanselect      OM_p_CHANSELECT      command's channel

Notes
   The name argument may be NULL if it is NULL all cells will be found.
   The gs_id may be NULL.
   The p_chanselect may be NULL.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn   03/31/88             Creation Date
\*/

extern IGRint   GRgs_locate_action();
IGRint GRget_all_cells (msg, osnum, objid, mod_env, num_objids, sd_objids,
                        gs_id, p_chanselect)
IGRlong              *msg;
GRspacenum           osnum;
GRobjid              objid;
struct GRmd_env      *mod_env;
IGRint               num_objids;
OM_S_BTREE_CONTENTS  sd_objids[];
struct GRid          *gs_id;
OM_p_CHANSELECT      p_chanselect;
{
IGRlong              om_msg;
IGRlong              ret_msg;
IGRint               properties;
struct GRlc_locate   attributes;
struct GRlc_classes  classinfo;
GRclassid            GRclhdr_classid;
OM_S_CLASSLIST       locate_eligible;
struct EX_button     button;
struct temp          args;
struct GRid          args1[2];
struct GRid          sv_id;
struct GRid          temp_id;
IGRint		     GRcell_action_handler();

   /*
    *  Create a graphics set.
    */

   temp_id.osnum = mod_env->md_id.osnum;
   om_msg = gr$gsinit (msg = &ret_msg, flag = 2, p_objid = &temp_id.objid,
            senderos = osnum, senderid = objid, 
            osnum = mod_env->md_id.osnum,
            p_chanselect = p_chanselect);

   if (gs_id) *gs_id = temp_id;

   /*
    *  Start a transition for the graphics set. 
    */
   
   properties = 0;
   om_msg = om$send (
            msg = message GRgrset.GSstart_transition 
            (&ret_msg, mod_env, &properties, NULL, &sv_id),
            senderid = objid,
            targetid = temp_id.objid,
            targetos = temp_id.osnum);

   /*
    *  Build the attributes structure.
    */

   strcpy (attributes.classes,"GRgraphics");
   attributes.owner_action =  LC_FLEX_COMP;
   attributes.properties = LC_LC_ONLY |
                           LC_RW |
                           LC_DP_ONLY |
                           IGN_MOD_BIT |
                           IGN_PLANAR_BIT;

   /*
    *  Build class list.
    */

   om_msg = om$get_classid (classname = "GRclhdr",
            p_classid = &GRclhdr_classid);
   locate_eligible.w_count = 1;
   locate_eligible.w_flags = OM_CLST_subclass;
   locate_eligible.p_classes = &GRclhdr_classid;
   classinfo.rtree_classes = NULL;
   classinfo.eligible_classes = &locate_eligible;

   button.objid = NULL_OBJID;
   button.osnum = mod_env->md_id.osnum;

   if (sd_objids)
   {
      /*
       *  Query all objects looking for cells with the given name.
       */

      args.num_objids = num_objids;
      args.gs_id = temp_id;
      args.sv_id = sv_id;
      args.sd_objids = sd_objids;
      om_msg = GRgsquery_all(msg, mod_env, &attributes, &classinfo, NULL,
            &button, GRcell_action_handler, &args);
   }else
   {
      /*
       *  Query all objects looking for cells.
       */

      args1[0] = temp_id;
      args1[1] = sv_id;
      om_msg = GRgsquery_all(msg, mod_env, &attributes, &classinfo, NULL,
            &button, GRgs_locate_action, args1);
   }

   /*
    *  Send the GSend_transition message.
    */
      
   om_msg = om$send (msg = message GRgrset.GSend_transition (msg, NULL),
            senderid = objid,
            targetid = temp_id.objid,
            targetos = temp_id.osnum);
   return (1);
}


#argsused
IGRint GRcell_action_handler (action_args, new_entry, locate_args, action)
struct temp             *action_args;
struct GRlc_info        *new_entry;
IGRchar                 *locate_args;
enum GRlocate_action    *action;
{
IGRlong              om_msg;
IGRlong              ret_msg;
IGRint               i;
IGRlong              temp;
IGRchar              name[MAX_SYMBOL_DEF_NAME];
struct GRvar_list    list[2];

   if ((*action == add_all) ||
       (*action == add_inside) ||
       (*action == add_outside) ||
       (*action == add_overlap))
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
               msg = message GRsymbol.GRset_inq_symbol (&ret_msg, 0, list),
               senderid = NULL_OBJID,
               targetid = new_entry->located_obj.objid,
               targetos = new_entry->located_obj.osnum);
   
      for (i = 0; i < action_args->num_objids; ++i)
      {  
         if (!strcmp (name, action_args->sd_objids[i].name.key_name))
         {
            return(GRgsaction (new_entry, action, &action_args->gs_id, 
                   &action_args->sv_id, NULL, TRUE));
         }
      }
   }else
   {
      return(GRgsaction (new_entry, action, &action_args->gs_id, 
              &action_args->sv_id, NULL, TRUE));
   }
   return(OM_S_SUCCESS);
}
end implementation Root;
