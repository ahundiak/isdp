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
   GSdelete

Description
   This method is used to delete all the members of the graphics set.

   *msg         IGRlong        return code 

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
     Sudha	  03/10/95    Fix for TR# 119420485. get the channel count
			      before sending a GSdelete on the channel.
\*/

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"

method GSdelete (IGRlong *msg )
{
IGRlong           om_msg;
OMuint		  count;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgrset.to_sets";

 om_msg = om$get_channel_count (object= me, 
			        p_chanselect = &chansel,
               	    	        count = &count);

 if ( count )
 {
   /*
    *  Send the GSdelete message to members.
    */

   om_msg = om$send(
            msg = message GRgrset.GSdelete (msg), 
            senderid = my_id, p_chanselect = &chansel);

   if (om_msg & *msg & 1)
   {
      /*
       *  Send the GSdissolve message to my_self.
       */
      
      om_msg = om$send(
               msg = message GRgrset.GSdissolve (msg), 
               targetid = my_id);
   }
 }
   return ( om_msg );
}
end implementation GRgrset;
