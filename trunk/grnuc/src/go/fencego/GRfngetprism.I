/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRget_prism

Description
   This method returns a prism which represents the fence object.

Arguments
   *msg           IGRlong          o   completion code
   *mod_env       struct GRmd_env  i   The module environment. 
   formatted      IGRint           i   Flag signifing if prism is formated.
                                          if 0 - prism is unformated buffer
                                          if 1 - prism is formated
   *prism         IGRchar          i/o Pointer to the prism
   *window_id     struct GRid      o   object id of the window.

Notes
   The prism or the window_id may be NULL.

Algorithm
   The fence object is a user defined element which represents a 
   volume in a specific window.  This volume is defined at the time
   the input tool is invoked by projection of the fence object onto
   the window surface, and the depth  of the window defines the depth
   for the volume.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn    10/05/86    Creation date.
   Gray Winn    10/07/88    Updated for message interception
   msm          07/09/92    ANSI-C conversion.
   mrm          10/30/92    Fixed pointer arithmetic problem caused by 
                            typecast introduced during the ANSI conversion.
                            This was causing rt_prism->polygon.points to point
                            to far below the rest of the prism structure.
\*/

class implementation GRgsmgr;

#include "grimport.h"
#include "gocmacros.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grgsdef.h"

from GRvg   import   GRgenabsg;

method GRget_prism (IGRlong *msg; struct GRmd_env *mod_env; 
                    IGRint formatted; IGRchar *prism;
                    struct GRid *window_id)
{
IGRlong              om_msg;
unsigned int         count;
IGRint               prism_type;
IGRchar              *total_so_far;
OM_S_CHANSELECT      window_chansel;   
OM_S_CHANSELECT      chansel;
OM_S_OBJECT_LINKAGE  list;
struct IGRbsp_curve  *absgptr;
struct IGRrt_prism   *rt_prism;
struct IGRcv_prism   *cv_prism;
struct GRid          temp_id;

   *msg = MSSUCC;
   window_chansel.type = OM_e_addr;
   window_chansel.u_sel.addr = &me->gra_gad;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   om_msg = om$send(msg  = message GRvg.GRgenabsg (msg, 
            &mod_env->md_env.matrix_type, mod_env->md_env.matrix, 
            (IGRchar **)&absgptr), p_chanselect = &chansel);
        
   /*
    *  Get the objid of the window.
    */ 

   om_msg = om$get_channel_objects ( objid = my_id, 
            p_chanselect = &window_chansel, list = &list,
            size = 1, count = &count);

   temp_id.objid = list.S_objid;
   temp_id.osnum = list.osnum;

   if (om_msg & 1)
   {
      if (prism)
      {
         if (!formatted)
         {
            /*
             *  Format the prism.
             */

            prism_type = ((absgptr->order == 2) && (!absgptr->rational)) ? 
                         GR_RIGHT_PRISM : GR_CURVE_PRISM;
   
            if (prism_type == GR_RIGHT_PRISM)
            {
               rt_prism = (struct IGRrt_prism *)prism;
               rt_prism->polygon.points = 
                   (IGRdouble *)(prism + sizeof(struct IGRrt_prism));
            }
            else
            {
               cv_prism = (struct IGRcv_prism *)prism;
               total_so_far = prism + sizeof (struct IGRcv_prism);

               cv_prism->curve.poles = (IGRdouble *)total_so_far;
               total_so_far += sizeof (IGRdouble) * 3 * absgptr->num_poles;

               if (absgptr->rational)
               {
                  cv_prism->curve.weights = (IGRdouble *)total_so_far;
                  total_so_far += sizeof (IGRdouble) * absgptr->num_poles;
               }

               if (absgptr->num_knots)
               {
                  cv_prism->curve.knots = (IGRdouble *)total_so_far;
                  total_so_far += sizeof (IGRdouble) * absgptr->num_knots;
               }

               if (absgptr->num_boundaries)
               {         
                  cv_prism->curve.bdrys = (IGRdouble *)total_so_far;
               }
            }
         }

         /*
          *  Call a function that will build the prism.
          */

         om_msg = GRbuild_prism_in_wnd (msg, &temp_id, absgptr, prism);
      }

      if (window_id)
      {
         *window_id = temp_id;
      }
   }
   return(OM_S_SUCCESS);
}
end implementation GRgsmgr;
