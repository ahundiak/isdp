/* #######################    APOGEE COMPILED   ######################## */

/*\
Name
   GRlslmgr_fun

Description
   This function calls the appropriate method on the symbol manager.

   *msg     IGRlong    Completion code.
   type     IGRint     The function to be performed.
   *arg1    IGRchar    Arguments to be passed.
   *arg2    IGRchar    Arguments to be passed.
   *arg3    IGRchar    Arguments to be passed.
   *arg4    IGRchar    Arguments to be passed.

History
   Gray Winn         Creation Date
   scw    07/22/92   ansi conversion
\*/

class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "grsymdef.h"
#include "grsymmacros.h"
#include "exmacros.h"

from GRlslmgr     import   GRget_active_symbol, GRget_asl_env,
                           GRput_active_symbol, GRput_asl,
                           GRget_sl_env_from_OS, GRget_sl_OS_array,
                           GRsave_asl, GRget_sl_type, 
                           GRget_asl_info;

IGRint GRlslmgr_fun (msg, type, arg1, arg2, arg3, arg4)
IGRlong     *msg;
IGRint      type;
IGRchar     *arg1;
IGRchar     *arg2;
IGRchar     *arg3;
IGRchar     *arg4;
{
IGRlong        om_msg;
GRobjid        global_mgr;
GRspacenum     mod_osnum;
GRobjid        mod_id;
OM_p_MESSAGE   pass_msg;

   *msg = MSSUCC;
   pass_msg = NULL;

   om_msg = ex$get_cur_mod( id = &mod_id, osnum = &mod_osnum);
   om_msg = ex$get_super (mod_id = mod_id, mod_osnum = mod_osnum,
            super_name = GR_SYM_LIB_MGR, create = TRUE, 
            super_class = "GRlslmgr", super_id = &global_mgr);

   if (om_msg & 1)
   {
      switch (type)
      {
         case  GRGET_ACTIVE_SYMBOL:
         {
            pass_msg = message GRlslmgr.GRget_active_symbol (msg, 
                       (struct GRactive_symbol_def *)arg1,
                       (IGRint) arg2);
         }
         break;

         case  GRGET_ASL_ENV:
         {
            pass_msg = message GRlslmgr.GRget_asl_env (msg, 
                       (struct GRmd_env *)arg1);
         }
         break;

         case GRGET_SL_TYPE:
         {
            pass_msg = message GRlslmgr.GRget_sl_type (msg, 
                       (GRspacenum *) arg1,
                       (IGRint *)     arg2);
         }
         break;

         case GRPUT_ACTIVE_SYMBOL:
         {
            pass_msg = message GRlslmgr.GRput_active_symbol (msg, 
                       (IGRchar *)arg1, 
                       (struct GRid *)arg2,
                       (struct GRmd_env *)arg3,
                       (IGRint) arg4);
         }
         break;
      
         case GRPUT_ASL:
         {
            pass_msg = message GRlslmgr.GRput_asl (msg, 
                       (struct GRsymbol_lib_file *)arg1);
         }
         break;

         case GRGET_SL_ENV_FROM_OS:
         {
            pass_msg = message GRlslmgr.GRget_sl_env_from_OS (msg,
                       (GRspacenum *)arg1, 
                       (struct GRmd_env *)arg2);
         }
         break;

         case GRGET_SL_OS_ARRAY:
         {
            pass_msg = message GRlslmgr.GRget_sl_OS_array (msg, 
                       (GRspacenum *)arg1,
                       (IGRint *)arg2);
         }
         break;

         case GRSAVE_ASL:
         {
            pass_msg = message GRlslmgr.GRsave_asl (msg );
         }
         break;

         case GRGET_ASL_INFO:
         {
            pass_msg = message GRlslmgr.GRget_asl_info (msg,
                       (struct GRsymbol_lib_file *)arg1);
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
