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
   GSenv_compare 

Description
   This method compares the module environment and properties
   of a saveset.

   *msg          IGRlong            return code
   *mod_env      struct GRmd_env    module environment
   *env_properties IGRint           module properties.
   *sv_id        struct GRid        the save set id

Notes
   The env_properties may be NULL.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
\*/

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"

method GSenv_compare (IGRlong *msg; struct GRmd_env *mod_env;
                       IGRint *env_properties; struct GRid *sv_id)
{
IGRlong           om_msg;
unsigned int      count;
IGRint            i;
OM_S_CHANSELECT   chansel;

   *msg = MSFAIL;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgrset.to_sets";

   /*
    *  Get the channel count of the members channel.
    */

   om_msg = om$get_channel_count (object= me, p_chanselect = &chansel, 
            count = &count);

   for (i=0; (i < count) && (om_msg & 1); ++i)
   {
      /*
       *  Send the env compare message to each save set.
       */
      
      om_msg = om$send(
               msg = message GRgrset.GSenv_compare (msg, mod_env, 
               env_properties, sv_id), p_chanselect = &chansel,
               from = i, to = i);
    
      if (om_msg & *msg & 1)
      {
         return (om_msg);
      }
   }
   return (om_msg);
}

end implementation GRgrset;
