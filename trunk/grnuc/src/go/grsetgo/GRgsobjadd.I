/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*\
Name
   GSobject_add 

Description
   This method is used to add an object to an existing graphics set.

   *msg         IGRlong         return code
   *obj_id      struct GRid     The object id of the object to be
                                added to the save set.
   *path        GRmd_env        Structure containing the new module
                                environment.
   *env_properties IGRint       environment properties.
   *target_id    struct GRid     The object id of the owner.
   target_sel   OM_p_CHANSELECT The channel to connect the graphics set to.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
\*/

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"
#include "grgsmacros.h"

from GRsvset   import   GSsvinit;

method GSobject_add (IGRlong *msg; struct GRid *obj_id;
                     struct GRmd_env *path; IGRint *env_properties;
                     struct GRid *target_id; OM_p_CHANSELECT target_sel)
{
IGRlong           om_msg;
IGRlong           ret_msg;
OM_S_CHANSELECT   chansel;
struct GRid       gs_id;
struct GRid       sv_id;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgrset.to_sets";

   /*
    *  Is the object a graphics set?
    */

   om_msg = gr$gsis_graphics_set ( msg = &ret_msg,
            object_id = obj_id);

   if (om_msg & ret_msg & 1)
   {
      gs_id.objid = my_id;
      gs_id.osnum = OM_Gw_current_OS;
      om_msg = om$send (
               msg = message GRgrset.GSmerge (msg, &gs_id, target_id,
               &chansel, target_sel),
               targetid = obj_id->objid, targetos = obj_id->osnum);
   }else
   {
      /*
       *  Send a message to my self to find the given environment.
       */

      om_msg = om$send (
               msg = message GRgrset.GSenv_compare (&ret_msg,
               path, env_properties, &sv_id),
               targetid = my_id);
         
      if (om_msg & ret_msg & 1)
      {
         /*
          *  Add the object to the save set.
          */

         om_msg = om$send (
                  msg = message GRgrset.GSadd (msg, obj_id, NULL), 
                  targetid = sv_id.objid, targetos = sv_id.osnum);

         return (om_msg);
      }

      if (om_msg & 1)
      {
         /*
          *  Create a saveset and connect it to the graphics set.
          */
         
         sv_id.osnum = path->md_id.osnum;
         om_msg = gr$gsinit ( msg = &ret_msg, p_chanselect = &chansel,
                  p_objid = &sv_id.objid, osnum = path->md_id.osnum);
   
         if (om_msg & ret_msg & 1)
         {
            /*
             *  Init the saveset.
             */

            om_msg = om$send (
                     msg = message GRsvset.GSsvinit(&ret_msg,
                     path, env_properties, NULL),
                     targetid = sv_id.objid, 
                     targetos = sv_id.osnum);

            if (om_msg & ret_msg & 1)
            {
               /*
                *  Add the object the save set.
                */

               om_msg = om$send (
                        msg = message GRgrset.GSadd (&ret_msg, obj_id, 
                        NULL), targetid = sv_id.objid,
                        targetos = sv_id.osnum);

            }
         }
      }
   }      
   return ( om_msg );
}
end implementation GRgrset;
