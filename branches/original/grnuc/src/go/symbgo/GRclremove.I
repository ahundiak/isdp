/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRremove_components

Description
   This method is used to remove a list of elements from an owner.

   *msg           IGRlong              completion code 
   *mod_env       struct GRmd_env      The current module environment
   *num_objects   IGRint               The number of objects
   *objects[]     struct GRobj_env     The list of elements to be removed.

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.

History
   Gray Winn    04/20/88    Creation date.
   scw          07/22/92    ansi conversion
\*/

class implementation GRclhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "gocmacros.h"

extern IGRboolean  MAinvmx();
extern IGRboolean  MAtypemx();

method GRremove_components (IGRlong *msg; struct GRmd_env *mod_env;
                            IGRint *num_objects;
                            struct GRobj_env objects[])
{
IGRlong              om_msg;
IGRint               i;
IGRshort             four = 4;
OMuint               count;
IGRshort             matrix_type;
IGRboolean           world;
GRobjid              objid;
GRrange              range;
GRrange              go_range;
IGRmatrix            matrix;
struct GRid          my_GRid;
struct IGRlbsys      lbs;
struct GRpost_info   info;
OM_S_CHANSELECT      chansel;

   *msg = MSSUCC;
   world = TRUE;
   my_GRid.objid = my_id;
   my_GRid.osnum = OM_Gw_current_OS;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *  Get the geometry of the cell.
    */

   om_msg = om$send(
            msg = message GRvg.GRgetgeom (msg, 
                          &mod_env->md_env.matrix_type, mod_env->md_env.matrix, 
                          (IGRchar *)&lbs),
            targetid = my_id);

   /*
    *  Get the world to local matrix of the cell so that the components
    *  will generate their range in the cell local coordiates.
    */

   MAinvmx(msg, &four, lbs.matrix, matrix);
   MAtypemx(msg, matrix, &matrix_type);

   for (i = 0; i < 3; ++i)
   {
      range[i] = 0.0;
      range[i+3] = 0.0;
   }

   /*
    *  Remove the objects from the owner.
    */

   for (i = 0; i < *num_objects; ++i)
   {
      om_msg = om$send (
               msg = message GRconnector.GRdisconn (msg, &my_GRid),
               targetid = objects[i].obj_id.objid,
               targetos = objects[i].obj_id.osnum);
   }

   /*
    *  Get the number of objects left on the cell.
    */

   om_msg = om$get_channel_count(osnum = OM_Gw_current_OS,
            objid = my_id, p_chanselect = &chansel, count = &count);

   if (count)
   {
      /*
       *  Accumulate the range of the cell components in the local 
       *  coordinate system.
       */

      for (i = 0; i < count; ++i)
      {
         
         om_msg = om$send(
                  msg = message GRvg.GRgetrang (msg, &matrix_type, matrix, 
                  &world, go_range),
                  targetos = objects[i].obj_id.osnum,
                  targetid = objects[i].obj_id.objid);

         if (om_msg & *msg & 1)
         {
            GRaccumulate_range (msg, go_range, range);
         }
      }

      for (i = 0; i < 3; ++i)
      {
         lbs.diag_pt1[i] = range[i];
         lbs.diag_pt2[i] = range[i+3];
      }

      /*
       *  Post the new definition of the cell.
       */

      info.construct_flag = FALSE;
      om_msg = om$send(
               msg = message GRvg.GRpostabsg(msg, mod_env, &info, 
                                             (IGRchar *)&lbs, &objid),
               targetid = my_id);
   }else
   {
      /*
       *  If all my elements were removed then delete myself.
       */

      om_msg = om$send (
               msg = message GRowner.GRdelete_owner (msg, mod_env),
               targetid = my_id);
   }

   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_CHANNEL_USED);
   return (om_msg);
}
end implementation GRclhdr;
