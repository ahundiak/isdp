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
   GSto_cpx 

Description
   This method will connect the graphics objects to_cpx channel to
   the members channel.

   *msg          IGRlong              return code

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    12/02/86    Creation date.
\*/

class implementation GRfcset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"

method GSto_cpx (IGRlong *msg)
{
IGRlong           om_msg;
OM_S_CHANSELECT   overlap_sel;

   *msg = MSSUCC;
   overlap_sel.type = OM_e_name;
   overlap_sel.u_sel.name = "GRfcset.clip_overlap";

   /*
    *  Send to parents method.
    */

   om_msg = om$send (mode = OM_e_wrt_message,
            msg = message GRgrset.GSto_cpx (msg),
            targetid = my_id);

   if (me->properties & GRIS_POST_PROCESSING)
   {
      om_msg = om$send (
               msg = message GRgrset.GSto_cpx (msg),
               p_chanselect = &overlap_sel);
   }

   return(om_msg);
}
end implementation GRfcset;
