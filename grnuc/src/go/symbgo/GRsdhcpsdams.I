/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRcp_sd_to_ams

Description
   This method will copy a symbol definition to the specified 
   active module space.  This method will add the components to 
   the index objects for that space.

   *msg           IGRlong              return code 
   place_matrix   IGRmatrix            matrix defining transformation
   *display_attr  struct IGRaltdisplay (Optional) display attributes 
   *target_id     struct GRid          (Optional) owner for components.
   *lsl_env       struct GRmd_env      Object's present environment
   *ams_env       struct GRmd_env      Object's target environment

Algorithm
   This method will copy the components of the symbol definition to
   the specified space, transform them to the world  coordinate 
   system.  The sd components will be added to the neccessary 
   index objects and connected to the target object.
  
   For each symbol component
   {
     -  Copy the object to the specified space and transform it to 
        the world coordinate system.

     -  Change symbolobgy 

     -  connect to the target
   }

Notes
   If the target id is NULL then the objects will not be connected.
   If the symbology is NULL then the objects will not be changed.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   HGW      06/23/86 : Design Date and Creation Date
   HGW      08/14/86 : Changed terminology
   HGW      11/02/87 : Changes for version 1.1
   SCW      07/22/92 : Ansi conversion
\*/

class implementation GRsmdfhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grsymdef.h"
#include "grownerdef.h"

extern IGRboolean MAinvmx();
extern IGRboolean MAmulmx();
extern IGRboolean MAtypemx();

method GRcp_sd_to_ams (IGRlong *msg; IGRmatrix place_matrix; 
                       struct IGRaltdisplay  *display_attr;
                       struct GRid *target_id; 
                       struct GRmd_env *lsl_env;
                       struct GRmd_env *ams_env )
{
IGRlong           om_msg;
IGRlong           ret_msg;
IGRint            i;
OMuint            count=0;
IGRint            conn_type;
IGRint            type;   
OM_S_CHANSELECT   chansel;
struct GRid       go_id;
struct GRmd_env   tams_env;

   *msg = MSSUCC;
   ret_msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";
   
   /*
    *  Combine the transformation to the world coordinate system and 
    *  the placement transformation.
    */

   tams_env = *lsl_env;
   for (i=0; i<16; ++i)
   {
       tams_env.md_env.matrix[i]=place_matrix[i];
   }
   MAtypemx(msg,place_matrix,&tams_env.md_env.matrix_type);
   
   /*
    *  Get the number of components owned by the sdh
    */

   om_msg = om$get_channel_count(object = me, p_chanselect = &chansel,
            count = &count);

   if (om_msg & 1)
   {
      /* 
       *  If target id is NULL then we do not need the channel number
       *  of the target object.
       */

      if (target_id != NULL)
      {
         /*
          *  Get the channel number for the target object
          */

         om_msg = om$send(
                  msg = message GRowner.GRget_channel_type (&ret_msg,
                  &type, &conn_type),
                  targetid = target_id->objid,
                  targetos = target_id->osnum);
      }

      
      if (om_msg & ret_msg & 1)
      {
         /*
          *  Loop for each component
          */

         for (i=0; ((i < count) && (om_msg & ret_msg & 1)); ++i)
         {
            /*  
             *  Copy the object to the specified space.
             *
             *  GRcopy transforms the object by the inverse of the 
             *  original matrix times the new matrix.  Therefore the
             *  object is in world coordinates.
             */

            go_id.osnum = ams_env->md_id.osnum;
            om_msg = om$send(
                     msg = message GRgraphics.GRcopy (&ret_msg, &tams_env,
                     ams_env, &go_id.objid),
                     p_chanselect = &chansel, from = i, to = i);

            if (om_msg & ret_msg & 1)
            {
               /*
                *  If target objid is NULL then do not connect
                */

               if (target_id)
               {
                  /*
                   *  Connect to the target object.
                   */

                  om_msg = GRconnect_object (&ret_msg, go_id.osnum,
                           go_id.objid, target_id, type, conn_type,
                           OM_K_MAXINT, OM_K_MAXINT);
               }

               if (om_msg & ret_msg & 1)
               {
                  if (display_attr != NULL)
                  {
                     /*
                      *  If display_attr is NULL then do not change
                      *  in object.
                      */

                     if (display_attr->color)
                     {
                        om_msg = om$send(
                                 msg = message GRvg.GRchgcolor (&ret_msg,
                                 0,
                                 display_attr->color),
                                 targetid = go_id.objid,
                                 targetos = go_id.osnum);
                     }

                     if (display_attr->weight)
                     {
                        om_msg = om$send(
                                 msg = message GRvg.GRchgweight (&ret_msg,
                                 display_attr->weight),
                                 targetid = go_id.objid,
                                 targetos = go_id.osnum);
                     }

                     if (display_attr->style)
                     {
                        om_msg = om$send(
                                 msg = message GRvg.GRchgstyle (&ret_msg,
                                 display_attr->style),
                                 targetid = go_id.objid,
                                 targetos = go_id.osnum);
                     }
                  }
               }
            }
         }
      }
   }

   if (!(om_msg & ret_msg & 1))
   {
      *msg = MSFAIL;
   }
   return ( om_msg );
}
end implementation GRsmdfhdr;
