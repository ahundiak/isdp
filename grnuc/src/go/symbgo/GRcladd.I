/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRadd_components

Description
   This method is used to add a list of elements to an owner.

   *msg           IGRlong              completion code 
   *mod_env       struct GRmd_env      The current module environment
   *num_objects   IGRint               The number of objects
   objects[]      struct GRobj_env     The list of elements to be added.
   own_index[]    IGRint               An array of indexes for the owner's
                                       channel when connecting.
   go_index[]     IGRint               An array of indexes for the graphics
                                       object's channel when connecting. 

Notes
   The own_index and go_index arrays may be NULL.  If either is NULL
   then OM_K_MAXINT will be used.

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.

History
   Gray Winn    01/14/88    Creation date.
   SCW          07/22/92    Ansi conversion
\*/

class implementation GRclhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "gocmacros.h"

extern IGRboolean  MAinvmx();
extern IGRboolean  MAtypemx();

method GRadd_components (IGRlong *msg; struct GRmd_env *mod_env;
                         IGRint *num_objects; struct GRobj_env objects[];
                         IGRint own_index[]; IGRint go_index[])
{
IGRlong              om_msg;
IGRint               i;
IGRshort             four = 4;
IGRint               local_go_index;
IGRint               local_own_index;
IGRint               channel_type;
IGRint               connection_type;
IGRshort             matrix_type;
IGRboolean           world;
GRobjid              objid;
GRrange              range;
GRrange              go_range;
IGRmatrix            matrix;
struct GRid          my_GRid;
struct IGRlbsys      lbs;
struct GRpost_info   info;

   *msg = MSSUCC;
   world = TRUE;
   my_GRid.objid = my_id;
   my_GRid.osnum = OM_Gw_current_OS;

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

   /*
    *  Get the type of channel.
    */

   om_msg = om$send (
            msg = message GRowner.GRget_channel_type (msg,
            &channel_type, &connection_type), targetid = my_id);

   for (i = 0; i < 3; ++i)
   {
      range[i] = lbs.diag_pt1[i];
      range[i+3] = lbs.diag_pt2[i];
   }

   for (i = 0; i < *num_objects; ++i)
   {
      /*
       *  This method only adds objects which are within the
       *  same object space as the current module environment.
       */

      if ( (objects[i].mod_env.md_id.osnum == mod_env->md_id.osnum) &&
           (objects[i].mod_env.md_id.objid == mod_env->md_id.objid))
      {
         /*
          *  Get the range of the object in the local coordinate system.
          */
         
         om_msg = om$send(
                  msg = message GRvg.GRgetrang (msg, &matrix_type, matrix, 
                  &world, go_range),
                  targetos = objects[i].obj_id.osnum,
                  targetid = objects[i].obj_id.objid);

         if (om_msg & *msg & 1)
         {
            GRaccumulate_range (msg, go_range, range);

            if (own_index)
            {
               local_own_index = own_index[i];
            }else
            {
               local_own_index = OM_K_MAXINT;
            }

            if (go_index)
            {
               local_go_index = go_index[i];
            }else
            {
               local_go_index = OM_K_MAXINT;
            }

            /*
             *  Add the object to the owner.
             */

            om_msg = GRconnect_object (msg, objects[i].obj_id.osnum,
                     objects[i].obj_id.objid, &my_GRid, channel_type,
                     connection_type, local_own_index, local_go_index);
         }
      }
   }

   for (i = 0; i < 3; ++i)
   {
      lbs.diag_pt1[i] = range[i];
      lbs.diag_pt2[i] = range[i+3];
   }

   /*
    *  Post the definition of the cell.
    */

   info.construct_flag = FALSE;
   om_msg = om$send(
            msg = message GRvg.GRpostabsg(msg, mod_env, &info, (IGRchar *)&lbs,
            &objid),
            targetid = my_id);

   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_CHANNEL_USED);
   return (om_msg);
}
end implementation GRclhdr;
