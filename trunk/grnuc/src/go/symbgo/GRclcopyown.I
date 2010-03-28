/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRcopy_owner

Description
   This method is responsible for coping the symbol definition 
   header to the specified space.  This method will add the sdh 
   to the symbol index object.

   *msg           IGRlong              return code 
   *mod_env       struct GRmd_env      The module environment
   *target_env    struct GRmd_env      The target environment
   *owner_id      GRobjid              The new owner

Return Value
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn 07/18/88      Coding Date
\*/

class implementation GRclhdr;

#include "grimport.h"
#include "msdef.h"
#include "grownerdef.h"
#include "gocmacros.h"

extern   IGRboolean     MAinvmx();   
extern   IGRboolean     MAmulmx();
extern   IGRboolean     MAtypemx();
extern   IGRboolean     MAidmx();

method GRcopy_owner (IGRlong *msg; struct GRmd_env *mod_env;
                     struct GRmd_env *target_env; GRobjid *owner_id)
{
IGRlong              om_msg;
IGRlong              ret_msg;
IGRint               i;
IGRint               cont;
IGRint               cleanup;
IGRshort             mxsize = 4; 
IGRshort             mx_type;     
IGRmatrix            tmatrix;
IGRmatrix            invmx;
struct GRmd_env      temp_env;
OM_S_CHANSELECT      chansel;

   *msg = MSSUCC;
   cleanup = FALSE;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *  Invoke the owner GRcopy_owner message.
    */

   om_msg = om$send (mode = OM_e_wrt_message,
            msg = message GRowner.GRcopy_owner (&ret_msg, mod_env, 
            target_env, owner_id),
            targetid = my_id);

   if (om_msg & ret_msg & 1)
   {
      cleanup = TRUE;

      if ((mod_env->md_env.matrix_type != MAIDMX) ||
          (target_env->md_env.matrix_type != MAIDMX))
      {
         if (target_env->md_env.matrix_type != MAIDMX)
         {                        
            if (MAinvmx(&ret_msg, &mxsize, target_env->md_env.matrix,
                        invmx))
            {
               MAmulmx(&ret_msg, &mxsize, &mxsize, &mxsize, invmx,
                  mod_env->md_env.matrix, tmatrix);
               MAtypemx(&ret_msg, tmatrix, &mx_type);
            }else
            {
               om_msg = OM_E_ABORT;
            }
         }else
         {
            mx_type = mod_env->md_env.matrix_type;
            for (i=0; i < 16; ++i)
            {
               tmatrix[i] = mod_env->md_env.matrix[i];
            }
         }
      
         if (om_msg & 1)
         {
            temp_env.md_env.matrix_type = MAIDMX;
            MAidmx(&ret_msg, temp_env.md_env.matrix);
            temp_env.md_id = target_env->md_id;
        
            om_msg = om$send(
                     msg = message GRowner.GRxform_owner(&ret_msg,
                     &temp_env, &mx_type, tmatrix, owner_id, &cont),
                     targetid = *owner_id,
                     targetos = target_env->md_id.osnum);
         }
      }
   }

   if (!( om_msg & ret_msg & 1))
   {
      *msg = MSFAIL;
      if (cleanup)
      {
         om_msg = om$send(
                  msg = message GRgraphics.GRdelete (&ret_msg, target_env),
                  senderid = my_id, targetid = *owner_id,
                  targetos = target_env->md_id.osnum);
      }
   }
   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_COPIED);
   return (om_msg);
}
end implementation GRclhdr;
