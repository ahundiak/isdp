/* #######################    APOGEE COMPILED   ######################## */

/*\
Name
   GRgsmgr_fun

Description
   This routine serves as the router for the user interface macros.
   This routine is used instead of sending directly to the objects 
   since one must import the messages that are sent. 

   *msg     IGRlong    Completion code.
   type     IGRint     The function to be performed.
   *arg1    IGRchar    Arguments to be passed.
   *arg2    IGRchar    Arguments to be passed.
   *arg3    IGRchar    Arguments to be passed.
   *arg4    IGRchar    Arguments to be passed.
   *arg5    IGRchar    Arguments to be passed.
   *arg6    IGRchar    Arguments to be passed.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray  Winn  11/01/86    Creation Date
   msm         07/09/92    ANSI-C conversion.
\*/

class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "grgsmacros.h"
#include "exmacros.h"

from GRgsmgr      import   GRput_fence, 
                           GRget_fence, 
                           GRput_select_set,
                           GRget_select_set, 
                           GRput_locate_criteria,
                           GRget_locate_criteria, 
                           GRget_number_rtree_classes,
                           GRget_number_eligible_classes;

IGRint GRgsmgr_fun(msg, type, arg1, arg2, arg3, arg4, arg5, arg6)
IGRlong     *msg;
IGRint      type;
IGRchar     *arg1;
IGRchar     *arg2;
IGRchar     *arg3;
IGRchar     *arg4;
IGRchar     *arg5;
IGRchar     *arg6;
{
IGRlong        om_msg;
GRobjid        mod_id;
GRobjid        global_mgr;
GRspacenum     mod_osnum;
OM_p_MESSAGE   pass_msg;

   *msg = MSSUCC;
   pass_msg = NULL;

   om_msg = ex$get_cur_mod( id = &mod_id, osnum = &mod_osnum);
   om_msg = ex$get_super (mod_id = mod_id, mod_osnum = mod_osnum,
            super_name = GR_GSMGR, create = TRUE, super_class = "GRgsmgr",
            super_id = &global_mgr);

   if (om_msg & 1)
   {
      switch (type)
      {
         case  GSGET_FENCE:
         {
            pass_msg = message GRgsmgr.GRget_fence (msg, 
                       (struct GRid *)arg1);
         }
         break;

         case  GSPUT_FENCE:
         {
            pass_msg = message GRgsmgr.GRput_fence(msg,
                       (struct GRmd_env *)arg1,
                       (struct GRid *)arg2,
                       (struct GRid *)arg3);
         }
         break;

         case  GSGET_SELECT_SET:
         {
            pass_msg = message GRgsmgr.GRget_select_set (msg, 
                       (struct GRid *)arg1);
         }
         break;

         case  GSPUT_SELECT_SET:
         {
            pass_msg = message GRgsmgr.GRput_select_set(msg,
                       (struct GRmd_env *)arg1,
                       (struct GRid *)arg2);
         }
         break;

         case  GSPUT_CRITERIA:
         {
            pass_msg = message GRgsmgr.GRput_locate_criteria(msg,
                       (struct GRmd_env *)arg1,
                       (struct GRlc_locate *)arg2,
                       (OM_S_CLASSLIST *)arg3,
                       (OM_S_CLASSLIST *)arg4,
                       (IGRint *)arg5);
         }
         break;

         case  GSGET_CRITERIA:
         {
            pass_msg = message GRgsmgr.GRget_locate_criteria(msg,
                       (IGRint *)arg1,
                       (struct GRmd_env *)arg2,
                       (struct GRlc_locate *)arg3,
                       (OM_S_CLASSLIST *)arg4,
                       (OM_S_CLASSLIST *)arg5,
                       (IGRint *)arg6);
         }
         break;

         case  GSGET_NUM_RTREE:
         {
            pass_msg = message GRgsmgr.GRget_number_rtree_classes(msg,
                       (IGRint *)arg1);
         }
         break;

         case  GSGET_NUM_ELIGIBLE:
         {
            pass_msg = message GRgsmgr.GRget_number_eligible_classes(msg,
                       (IGRint *)arg1);
         }
         break;
      }

      om_msg = om$send(mode = OM_e_wrt_object,
               msg = pass_msg, senderid = NULL_OBJID,
               targetid = global_mgr, targetos = mod_osnum);
   }
   return (om_msg);
}
end implementation Root;
