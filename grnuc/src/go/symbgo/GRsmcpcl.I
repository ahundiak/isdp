/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRcp_symbol_to_cell

Description
   This method is used to convert a symbol to a cell.

   *msg         IGRlong             completition code
   *mod_env     struct GRmd_env     The originial module environment.
   *target_env  struct GRmd_env     The target environment.
   *cell_id     struct GRid         The new cell id.

Algorithm
   Convert a symbol to a cell.
   1)  Get symbol information
        a)  geometry
        b)  display attr.
   2)  Construct a cell header object.
   3)  Initiliaze the cell header object.
   4)  Copy symbol definition to active module space.

Return Values
   MSSUCC  -- successful completion
   MSFAIL --  if failure

HISTORY
   HGW     02/16/87 : Creation
   HGW     11/06/87 : Changes for version 1.1
   WBC     03/04/92 : Clearing the GR_RIGID_RELATIONSHIP bit of the created
                      cell since it is not connected to the symbol's owners.
   SCW     07/23/92 : Ansi conversion
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "grerr.h"
#include "gocmacros.h"
#include "vardef.h"
#include "growner.h"
#include "grsymdef.h"
#include "grsym.h"


from GRsmdfhdr    import   GRcp_sd_to_ams;
from GRsymbol     import   GRset_inq_symbol;

method GRcp_symbol_to_cell (IGRlong *msg; struct GRmd_env *mod_env;
                            struct GRmd_env *target_env;
                            struct GRid *cell_id)
{
IGRlong                    om_msg;
IGRlong                    ret_msg;
IGRlong                    temp;
IGRint                     dis_attr;   /* Display attributes of symbol */
OM_S_CHANSELECT            components_chansel;
struct GRsymbology         symb;       /* symbology of symbol reference */
struct GRvg_construct      const_list; /* Construct list for sm const   */
struct IGRlbsys            *absgptr;   /* symbol geometry               */
struct IGRlbsys            cell;       /* cell geometry                 */
struct GRvar_list          list[4];
struct GRcell_class_attr   class_attr;   
struct IGRaltdisplay       display_attr;
struct GRmd_env            new_target_env;

   *msg = MSSUCC;

   new_target_env.md_id = target_env->md_id;
   MAidmx (&ret_msg, new_target_env.md_env.matrix);
   new_target_env.md_env.matrix_type = MAIDMX;

   components_chansel.type = OM_e_name;
   components_chansel.u_sel.name = "GRcmpowner.to_components";
   const_list.properties = me->properties & (~GR_RIGID_RELATIONSHIP);
   const_list.newflag = FALSE;
   const_list.display = NULL;
   const_list.level = NULL;
   const_list.class_attr = (IGRchar *)&class_attr;
   const_list.name = NULL;
   const_list.msg = &ret_msg;
   const_list.geometry = (IGRchar *)&cell;
   const_list.env_info = &new_target_env;

   GRgetabsg(msg, &mod_env->md_env.matrix_type, mod_env->md_env.matrix, 
             (IGRchar **)&absgptr,i);

   cell = *absgptr;

   if (*msg & 1)
   {
      /*
       *  Get the symbology of the symbol.
       */

      om_msg = om$send(
               msg = message GRvg.GRgetsymb(&ret_msg, &symb),
               targetid = my_id);

      if (om_msg & ret_msg & 1)
      {
         if (ret_msg == GR_I_NODISATTR)
         {
            dis_attr = FALSE;
         }else
         {
            dis_attr = TRUE;
            if (me->owner_properties & GR_SYM_COLOR)
            {
               display_attr.color = &symb.display_attr.color;
            }else
            {
               display_attr.color = NULL;
            }

            if (me->owner_properties & GR_SYM_WEIGHT)
            {
               display_attr.weight = &symb.display_attr.weight;
            }else
            {
               display_attr.weight = NULL;
            }
   
            if (me->owner_properties & GR_SYM_STYLE)
            {
               display_attr.style = &symb.display_attr.style;
            }else
            {
               display_attr.style = NULL;
            }
         }

         class_attr.properties = NULL;

         list[0].var = GR_SYMBOL_NAME;
         list[0].var_ptr = class_attr.name_symbol;
         list[0].num_bytes = MAX_SYMBOL_DEF_NAME;
         list[0].bytes_returned = &temp;

         list[1].var = GR_SYMBOL_DESC;
         list[1].var_ptr = class_attr.desc_symbol;
         list[1].num_bytes = MAX_SYMBOL_DEF_DESC;
         list[1].bytes_returned = &temp;

         list[2].var = GR_TIME_STAMP;
         list[2].var_ptr = (IGRchar *)&class_attr.time_stamp;
         list[2].num_bytes = sizeof (IGRlong);
         list[2].bytes_returned = &temp;

         list[3].var = END_PARAM;
         list[3].var_ptr = NULL;
         list[3].num_bytes = NULL;
         list[3].bytes_returned = NULL;

         om_msg = om$send (
                  msg = message GRsymbol.GRset_inq_symbol (&ret_msg, 0, 
                  list), p_chanselect = &components_chansel);

         /*
          *  Construct the cell.
          *
          *  NOTE: THAT THE CLASSNAME IS HARD CODED. KLUDGE
          */

         cell_id->osnum = target_env->md_id.osnum;
         om_msg = om$construct(classname = "GRclhdr",
                  osnum = target_env->md_id.osnum,
                  p_objid = &cell_id->objid);

         if (om_msg & 1)
         {
            /*
             *  Send a message to the cell header to initilaze itself.
             */

            om_msg = om$send(
                     msg = message GRgraphics.GRconstruct (&const_list),
                     targetid = cell_id->objid,
                     targetos = cell_id->osnum);

            if (om_msg & 1)
            {
               /*
                *  Copy the symbol definition from the local
                *  cell library to the active module space. The 
                *  objects should be transformed by the placement
                *  matrix.  The objects will be added to the 
                *  appropiate index objects.
                */

               om_msg = om$send(
                        msg = message GRsmdfhdr.GRcp_sd_to_ams (msg,
                        cell.matrix, (dis_attr)? &display_attr : NULL,
                        cell_id, mod_env, target_env),
                        p_chanselect = &components_chansel);
            }
         }
      }
   }
   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_GEOM_MODIFIED);
   return (om_msg);
}
end implementation GRsmhdr;
