/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRcopy

Description
   This method will copy the symbol. 

   *msg         IGRlong          Completion code
   *mod_env     struct GRmd_env  Module environment structure 
   *target_env  struct GRmd_env  The target environment structure 
   *newobjid    GRobjid          Objid of the transformed object

Notes
   This method must be overriden by the symbol because the abstract
   geometry of the symbol is dependent upon the symbol definition.

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
   Gray Winn 09/08/87    Coding Date
   mrm       04/02/90    fixed
   scw       07/23/93    ansi conversion
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "grownerdef.h"
#include "gocmacros.h"

#define  OWNER                 1
#define  OWNER_PLUS_ONE        2

from GRmodule import GRmdaddwrng;

extern IGRboolean MAinvmx();   
extern IGRboolean MAmulmx();
extern IGRboolean MAtypemx();
extern IGRboolean MAidmx();

method GRcopy( IGRlong *msg; struct GRmd_env *mod_env;
               struct GRmd_env *target_env; GRobjid *new_objid)
{
IGRlong              om_msg;
IGRlong              ret_msg;
IGRint               i;
IGRint               cleanup;
IGRint               channel_type;
IGRint               connection_type;
IGRshort             mxsize = 4; 
IGRshort             mx_type;     
IGRboolean           world;
GRobjid              go_objid;
GRrange              range;
IGRmatrix            tmatrix;
IGRmatrix            invmx;
struct GRid          owner_id;
struct GRmd_env      temp_env;
OM_S_CHANSELECT      chansel;

   *msg = MSSUCC;
   cleanup = 0;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *  Make a copy of the owner.
    */

   owner_id.osnum = target_env->md_id.osnum;
   om_msg = om$send (
            msg = message GRowner.GRcopy_owner (&ret_msg, mod_env, 
            target_env, &owner_id.objid),
            targetid = my_id);

   if (om_msg & ret_msg & 1)
   {
      cleanup = OWNER;

      if (target_env->md_id.objid != NULL_OBJID)
      {         
         world = FALSE;
         om_msg = om$send(
                  msg = message GRgraphics.GRgetrang (&ret_msg,
                  NULL, NULL, &world, range),
                  targetid = my_id);

         if (om_msg & ret_msg & 1)
         {
            om_msg = om$send(
                     msg = message GRmodule.GRmdaddwrng (&ret_msg,
                     range, &owner_id.objid),
                     targetid = target_env->md_id.objid,
                     targetos = target_env->md_id.osnum);
         }
      }

      if (om_msg & ret_msg & 1)
      {
         /*
          *  Get the type of connection (i.e. Rigid or Flexible )
          */

         om_msg = om$send (
                  msg = message GRowner.GRget_channel_type (&ret_msg,
                  &channel_type, &connection_type),
                  targetid = my_id);

         if (om_msg & ret_msg & 1)
         {
            temp_env.md_env.matrix_type = MAIDMX;
            MAidmx(&ret_msg, temp_env.md_env.matrix);
            temp_env.md_id = mod_env->md_id;

            om_msg = om$send(
                     msg = message GRgraphics.GRcopy (&ret_msg, 
                     &temp_env, target_env, &go_objid),
                     p_chanselect = &chansel);

            if (om_msg & ret_msg & 1)
            {
               cleanup = OWNER_PLUS_ONE;

               /*
                *  Connect the copy of the component to the new owner.
                */

               om_msg = GRconnect_object (&ret_msg,
                        target_env->md_id.osnum, go_objid, &owner_id,
                        channel_type, connection_type, OM_K_MAXINT,
                        OM_K_MAXINT);

               if (om_msg & ret_msg & 1)
               {
                  cleanup = OWNER;
               }
            }
         }

         if (om_msg & ret_msg & 1)
         {
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
                  temp_env.md_id = target_env->md_id;
        
                  om_msg = om$send(
                           msg = message GRgraphics.GRxform(&ret_msg, 
                           &temp_env, &mx_type, tmatrix, &owner_id.objid),
                           targetid = owner_id.objid,
                           targetos = target_env->md_id.osnum);
               }
            }
         }
      }
   }

   if (!( om_msg & ret_msg & 1))
   {
      *msg = MSFAIL;
      if (cleanup)
      {
         /*
          *  Delete the owner and all components.
          */

         om_msg = om$send(mode = OM_e_wrt_object,
                  msg = message GRgraphics.GRdelete (&ret_msg, target_env),
                  senderid = my_id, 
                  targetid = owner_id.objid,
                  targetos = owner_id.osnum);
         
         if (cleanup == OWNER_PLUS_ONE)
         {

            om_msg = om$send(
                     msg = message GRgraphics.GRdelete (&ret_msg, 
                     target_env),
                     targetid = go_objid, 
                     targetos = target_env->md_id.osnum);
         }
      }
   }

   *new_objid = owner_id.objid;
   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_COPIED);
   return (om_msg);
}
end implementation GRsmhdr;
