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
   GSupdate_path

Description
   This method will update the save sets' path (module environment
   information.

   *msg         IGRlong           return code 
   *path        struct GRmd_env   new module environment

Return Values
   MSSUCC  -- successful completion

History
     WBC    04/11/89    Creation date.
\*/

class implementation GRfcset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"

method GSupdate_path (IGRlong *msg; struct GRmd_env *path)
{

IGRlong           om_msg;
OM_S_CHANSELECT   to_sets_chansel;
OM_S_CHANSELECT   overlap_chansel;

   *msg = MSSUCC;
   to_sets_chansel.type = OM_e_name;
   to_sets_chansel.u_sel.name = "GRgrset.to_sets";
   overlap_chansel.type = OM_e_name;
   overlap_chansel.u_sel.name = "GRfcset.clip_overlap";

   om_msg = om$send (msg = message GRgrset.GSupdate_path (msg,path),
                     p_chanselect = &to_sets_chansel);

   om_msg = om$send (msg = message GRgrset.GSupdate_path (msg,path),
                     p_chanselect = &overlap_chansel);

   return (om_msg);
}
end implementation GRfcset;
