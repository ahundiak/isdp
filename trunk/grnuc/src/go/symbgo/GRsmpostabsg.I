/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRpostabsg

Description
   This method posts the geometry into the instance data for the 3-D 
   floating point symbol header.

   *msg         IGRlong             completion message 
   *mod_env     struct GRmd_env     data set environment
   *post_info   struct GRpost_info  post information
   *absptr      IGRchar             pointer to abstract geometry
   *newobjid    GRobjid             object id of any new object


Return Values
   MSSUCC    - if successful
   MSFAIL    - if failure

History
   DEM  07/03/86 : Design date and Creation date.
   HGW  08/07/86 : Changed terminolgy.
   HGW  11/06/87 : Changes for version 1.1
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "OMerrordef.h"
#include "grerr.h"
#include "gocmacros.h"

from GRmodule import GRmdaddwrng;

method GRpostabsg(IGRlong *msg; struct GRmd_env *mod_env;
                  struct GRpost_info *post_info; IGRchar *absptr;
                  GRobjid *newobjid)
{
IGRlong          om_msg;         /* return om_msg for method */
IGRint           i;              /* index counter            */
GRrange          range;          /* range of sym ref object  */
GRrange          old_range;      /* old range of sym ref     */
struct IGRlbsys  lbs;            /* storage for local lbsys  */

   *msg = MSSUCC;
   *newobjid = my_id;

   om_msg = GR3dlbvipost (msg, mod_env, 
            (me->properties & GRIS_VIEW_INDEP) ? 1 : 0, 
            absptr, &lbs, range);

   if (om_msg & *msg & 1)
   {
      /*
       *  If the object is not being constructed, update the 
       *  range in the object and in the R-tree
       */

      if (!post_info->construct_flag)
      {
         /*
          *  Get the old range of the symbol.  This range does not have
          *  to be exact, it can be just an intersection of the old range.
          */
    
         old_range[0] = me->origin[0];
         old_range[1] = me->origin[1];
         old_range[2] = me->origin[2];
         old_range[3] = me->origin[0];
         old_range[4] = me->origin[1];
         old_range[5] = me->origin[2];

         if (!GRupdaterng(msg, mod_env, post_info, &my_id, 
                          &me->properties, old_range, range))
         {
            *msg = MSFAIL;
            om_msg = OM_E_ABORT;
         }
      }else
      {
         if (! ((mod_env->md_id.objid == NULL_OBJID) ||
                (me->properties & GRNOT_IN_RTREE)))
         {
            om_msg = om$send(
                     msg = message GRmodule.GRmdaddwrng(msg, range, 
                     &my_id),
                     targetid = mod_env->md_id.objid,
                     targetos = mod_env->md_id.osnum);
         }
      }

      if (om_msg & *msg & 1)
      {
         /*
          * update object
          */

         for (i = 0; i < 3; ++i)
         {
            me->matrix[i]   = lbs.matrix[i];
            me->matrix[i+3] = lbs.matrix[i+4];
            me->matrix[i+6] = lbs.matrix[i+8];
            me->origin[i]   = lbs.matrix[4*i+3];
         }
      }
   }
   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_GEOM_POSTED);
   return(om_msg);
}
end implementation GRsmhdr;
