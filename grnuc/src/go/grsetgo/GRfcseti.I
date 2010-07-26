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
   GSundo_save

Description
   This method is used to set up the global undo object so that the 
   next operation can be undone.  This method requires a function to
   be invoked to undo the operation, its arguments, and the size of
   its arguments.  The owner_id and owner_chansel are passed if the
   cloned version is to be connected to the owner and not to the global
   undo object.

   *msg           IGRlong           return code
   (*fun)()       IGRint            Address of the function to be 
                                    invoked when an operation is undone
   *args          IGRchar           The arguments to the undo function.
   *args_size     IGRint            The size of the undo arguments.
   *owner_id      struct GRid       Owner object id.
   owner_chansel  OM_p_CHANSELECT   The address of the owner channel.

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.

History
     Gray Winn    01/07/87    Creation date.
\*/

class implementation GRfcset;

#include "grimport.h"

method GSundo_save (IGRlong *msg; IGRint (*fun)();
                    IGRchar *args; IGRint *args_size;
                    struct GRid *owner_id; OM_p_CHANSELECT chansel)
{
   return(OM_S_SUCCESS);
}

end implementation GRfcset;
