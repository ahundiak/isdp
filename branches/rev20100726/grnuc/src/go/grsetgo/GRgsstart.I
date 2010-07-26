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
   GSstart_transition 

Description
   This method is used to define the start of a different environment.

   *msg            IGRlong         return code
   *path           GRmd_env        Structure containing the new module
                                   environment.
   *env_properties IGRint          Properties of the environment.
   *cur_sv_id      GRid            The object id of the previous saveset.
   *new_sv_id      GRid            The object id of the saveset initilazed.

Notes
   For this method cur_sv_id is not used.

Algorithm
   This method constructs a saveset with the new environment and 
   properties.  

Return Values
   MSSUCC  -- successful completion

History
     Gray Winn    11/02/86    Creation date.
\*/

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "grgsmacros.h"

method GSstart_transition (IGRlong *msg; struct GRmd_env *path;
                           IGRint *env_properties; struct GRid *cur_sv_id;
                           struct GRid *new_sv_id)
{
IGRlong           om_msg;
IGRlong           ret_msg;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgrset.to_sets";
   
   if (!(me->properties & GRIS_CURRENT))
   {
      me->current_sv.objid = NULL_OBJID;
   }

   /*
    *  Create a saveset and connect it to the graphics set.
    */

   new_sv_id->osnum = path->md_id.osnum;
   om_msg = gr$gsinit ( msg = &ret_msg, p_chanselect = &chansel,
            p_objid = &new_sv_id->objid, osnum = path->md_id.osnum);

   if (om_msg & ret_msg & 1)
   {
      /*
       *  Init the saveset with the start transition message.
       */

      om_msg = om$send (
               msg = message GRgrset.GSstart_transition(&ret_msg,
               path, env_properties, &me->current_sv, NULL),
               targetid = new_sv_id->objid, targetos = new_sv_id->osnum);

      if (om_msg & ret_msg & 1)
      {
         /*
          *  Set the current bit.
          */

         me->properties |= GRIS_CURRENT;
         me->current_sv = *new_sv_id;
      }
   }      
   return ( om_msg );
}
end implementation GRgrset;
