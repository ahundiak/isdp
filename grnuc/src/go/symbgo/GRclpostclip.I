/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRpost_clip_owner

Description
   This method is sent to an owner object after the clip operation is 
   performed.  This method allows the owner to update its geometry based
   upon its new components.  If the owner has no components it should
   delete itself.

Arguments
   *msg         IGRlong             completition code
   *mod_env     struct GRmd_env     The originial module environment.
   *target_env  struct GRmd_env     The target environment.
   *prism       IGRchar             The right prism to clip against.
   *inside_id   struct GRid         The object id of the inside owner.
   *outside_id  struct GRid         The object id of the outside owner.
   *overlap_id  struct GRid         The object id of the overlapping owner.
   *clip_flag   IGRlong             The flag describing the type of clip.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn    10/27/87    Creation date.
   scw          07/22/92    ansi conversion
\*/

class implementation GRclhdr;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "godef.h"
#include "grownerdef.h"
#include "grerr.h"
#include "gocmacros.h"
#include "grsymdef.h"
#include "vardef.h"

method GRpost_clip_owner (IGRlong *msg; struct GRmd_env *mod_env; 
                          struct GRmd_env *target_env; IGRchar *prism; 
                          struct GRid *inside_id; struct GRid *outside_id;
                          struct GRid *overlap_id; IGRlong *clip_flag)
{
IGRlong              om_msg;
IGRlong              temp;
IGRint               time_stamp;
IGRint               count;
IGRshort             four = 4;
IGRint               i;
IGRshort             matrix_type;
IGRboolean           world;
GRobjid              objid;
GRrange              range;
GRrange              go_range;
IGRmatrix            matrix;
OM_S_CHANSELECT      chansel;
struct IGRlbsys      lb;
struct GRpost_info   info;
struct GRvar_list    list[2];

   *msg = MSSUCC;

   /* 
    *  Get the number of components.
    */

   om_msg = om$send (
            msg = message GRowner.GRget_number_components(msg, &count),
            targetid = my_id);

   if (om_msg & *msg & 1)
   {
      if (!count)
      {
         /*
          *  Delete the owner if it does not have any children.
          */

         om_msg = om$send (
                  msg = message GRowner.GRdelete (msg, target_env),
                  targetid = my_id);
      }else
      {
         world = TRUE;
         chansel.type = OM_e_name;
         chansel.u_sel.name = "GRcmpowner.to_components";

         om_msg = om$send(msg = message GRvg.GRgetgeom (msg, 
                  &target_env->md_env.matrix_type, 
                  target_env->md_env.matrix, (IGRchar *)&lb),
                  targetid = my_id);

         /*
          *  Get the world to local matrix of the cell so that the 
          *  components will generate their range in the cell local
          *  coordiates. 
          */

         MAinvmx(msg, &four, lb.matrix, matrix);
         MAtypemx(msg, matrix, &matrix_type);

         om_msg = om$send(
                  msg = message GRvg.GRgetrang (msg, &matrix_type, matrix,
                  &world, range), 
                  p_chanselect = &chansel, to = 0, from = 0);

         for (i = 1; i < count; ++i)
         {
            /*
             *  Get the range of the object in the world coordinate system.
             */
         
            om_msg = om$send(
                     msg = message GRvg.GRgetrang (msg, &matrix_type,
                     matrix, &world, go_range),
                     p_chanselect = &chansel, to = i, from = i);

            GRaccumulate_range (msg, go_range, range);
         }

         if (om_msg & *msg & 1)
         {
            for (i = 0; i < 3; ++i)
            {
               lb.diag_pt1[i] = range[i];
               lb.diag_pt2[i] = range[i+3];
            }

            /*
             *  Post the definition of the cell.
             */

            info.construct_flag = FALSE;
            om_msg = om$send(msg = message GRvg.GRpostabsg(msg, target_env,
                     &info, (IGRchar *)&lb, &objid),
                     targetid = my_id);

            /*
             *  Reset the time stamp of the cell.
             */

            time_stamp = GRtime(0);
            list[0].var = GR_TIME_STAMP;
            list[0].var_ptr = (IGRchar *)&time_stamp;
            list[0].num_bytes = sizeof (IGRlong);
            list[0].bytes_returned = &temp;

            list[1].var = END_PARAM;
            list[1].var_ptr = NULL;
            list[1].num_bytes = NULL;
            list[1].bytes_returned = NULL;

            om_msg = om$send (msg = message GRsymbol.GRset_inq_symbol (msg,
                     1, list), targetid = my_id);
         }
      }
   }
   return (om_msg);
}
end implementation GRclhdr;
