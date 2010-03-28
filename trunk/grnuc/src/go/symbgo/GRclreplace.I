/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRreplace

Description
   This method will replace an owner and its components with a new 
   definition of that owner and its components.

   *msg           IGRlong              completion code 
   *mod_env       struct GRmd_env      The module environment
   *lib_env       struct GRmd_env      The library environment
   *def_id        struct GRid          The definition id
   *new_id        struct GRid          The new id

Return Values
   MSSUCC  if successful
   MSFAIL  if failure

History
   Gray Winn   04/03/88    creation date
   scw         07/22/92    ansi conversion
\*/

class implementation GRclhdr;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "grsymdef.h"
#include "vardef.h"

from GRsmdfhdr    import GRcp_sd_to_ams;

method GRreplace (IGRlong *msg; struct GRmd_env *mod_env;
                  struct GRmd_env *lib_env; struct GRid *def_id;
                  struct GRid *new_id)
{
IGRlong              om_msg;
OMuint               count;
IGRint               i;
IGRlong               size;
IGRlong               temp;
IGRboolean           world;
IGRlong              time_stamp;
IGRchar              name[MAX_SYMBOL_DEF_NAME];
IGRchar              desc[MAX_SYMBOL_DEF_DESC];
GRrange              range;
OM_S_CHANSELECT      chansel;
struct GRmd_env      local_mod_env;
struct IGRlbsys      lb;
struct GRpost_info   info;
struct GRvar_list    list[4];

   *msg = MSSUCC;
   world = FALSE;
   new_id->osnum = OM_Gw_current_OS;
   new_id->objid = my_id;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   om_msg = om$send (
            msg = message GRvg.GRgetgeom (msg, 
            &mod_env->md_env.matrix_type, mod_env->md_env.matrix,
            (IGRchar *)&lb), targetid = my_id);

   om_msg = om$send (msg = message GRowner.GRget_context(msg, mod_env,
            &local_mod_env), targetid = my_id);

   /* 
    *  Get the number of objects on my channel.
    */

   om_msg = om$get_channel_count(object = me, p_chanselect = &chansel, 
            count = &count);

   for (i = count - 1; i >= 0; i--)
   {
      /*
       *  Delete all the components.
       */

      om_msg = om$send(
               msg = message GRgraphics.GRdelete (msg, &local_mod_env),
               p_chanselect = &chansel, from = i, to = i);
   }

   /*
    *  Copy new components from sdh to cell.
    */

   om_msg = om$send(
            msg = message GRsmdfhdr.GRcp_sd_to_ams (msg, lb.matrix,
            NULL, new_id, lib_env, mod_env),
            targetid = def_id->objid,
            targetos = def_id->osnum);

   /*
    *  Get the extents of the sdh.
    */

   om_msg = om$send (
            msg = message GRgraphics.GRgetrang (msg, NULL, NULL, &world,
            range), 
            targetos = def_id->osnum,
            targetid = def_id->objid);

   for (i=0; i < 3; ++i)
   {
      lb.diag_pt1[i] = range[i];
      lb.diag_pt2[i] = range[i+3];
   }

   /*
    *  Post the definition of the cell.
    */

   info.construct_flag = FALSE;
   om_msg = om$send(
            msg = message GRvg.GRpostabsg(msg, mod_env, &info, (IGRchar *)&lb,
            &new_id->objid),
            targetid = my_id);

   /*
    *  Get the name, desc and time stamp from the sdh.
    */

   list[0].var = GR_SYMBOL_NAME;
   list[0].var_ptr = name;
   list[0].num_bytes = MAX_SYMBOL_DEF_NAME;
   list[0].bytes_returned = &temp;


   list[1].var = GR_SYMBOL_DESC;
   list[1].var_ptr = desc;
   list[1].num_bytes = MAX_SYMBOL_DEF_DESC;
   list[1].bytes_returned = &temp;

   list[2].var = GR_TIME_STAMP;
   list[2].var_ptr = (IGRchar *)&time_stamp;
   list[2].num_bytes = sizeof (IGRlong);
   list[2].bytes_returned = &temp;

   list[3].var = END_PARAM;
   list[3].var_ptr = NULL;
   list[3].num_bytes = NULL;
   list[3].bytes_returned = NULL;

   om_msg = om$send (
            msg = message GRsymbol.GRset_inq_symbol (msg, 0, list),
            targetid = def_id->objid,
            targetos = def_id->osnum);

   /*
    *  Post the name, desc and time stamp to the cell.
    */

   size = strlen(name);
   size++;  /* add one for NULL termination */
   list[0].var = GR_SYMBOL_NAME;
   list[0].var_ptr = name;
   list[0].num_bytes = size;
   list[0].bytes_returned = &temp;

   size = strlen(desc);
   size++;  /* add one for NULL termination */
   list[1].var = GR_SYMBOL_DESC;
   list[1].var_ptr = desc;
   list[1].num_bytes = size;
   list[1].bytes_returned = &temp;

   list[2].var = GR_TIME_STAMP;
   list[2].var_ptr = (IGRchar *)&time_stamp;
   list[2].num_bytes = sizeof (IGRlong);
   list[2].bytes_returned = &temp;

   list[3].var = END_PARAM;
   list[3].var_ptr = NULL;
   list[3].num_bytes = NULL;
   list[3].bytes_returned = NULL;

   om_msg = om$send (
            msg = message GRsymbol.GRset_inq_symbol (msg, 1, list),
            targetid = my_id);

   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_GEOM_MODIFIED);
   return (om_msg);
}
end implementation GRclhdr;
