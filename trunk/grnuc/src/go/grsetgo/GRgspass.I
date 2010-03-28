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
   GSpass 

Description
   This method is used for the graphic sets to pass a mesage on to
   all graphics objects that it owns.

   *msg           IGRlong              return code 
   pass_msg       OM_p_MESSAGE         Message to be passed
   *path          struct GRmd_env      Pointer to the data within the 
                                       message which contains the module 
                                       environment.

Notes
   The path argument may be NULL which means the message does not
   need the module environment.

Return Values
   MSSUCC   -  if successful.

History
     Gray Winn    11/02/86    Creation date.
\*/

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"

method GSpass ( IGRlong         *msg;
                OM_p_MESSAGE    pass_msg;
                struct GRmd_env *path)
{
IGRlong   om_msg;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgrset.to_sets";

   /*
    *  Pass the pass message to all members.
    */

   om_msg = om$send (mode = OM_e_wrt_object, 
            msg = message GRgrset.GSpass (msg, pass_msg, path), 
            senderid = my_id, p_chanselect = &chansel);

   return ( om_msg );
}
end implementation GRgrset;
