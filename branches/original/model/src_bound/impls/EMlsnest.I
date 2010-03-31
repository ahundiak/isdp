/* ###################   APOGEE COMPILED   ################## */
/* 
Notes
	This method determines the nesting of a loop with respect to a 
   loopset.The loopset sends down the loop in question to all its children
   untill the innermost loop in which the loop is nested is found out.
	The nesting information is exchanged via the structure
   EMSnest_info. Upon input the structure should contain the id of the loop
   in question,its properties and its range box.Upon output the structure
   will contain the parent id(which can be a loop or a loopset) and its
   properties.The input fields will remain unchanged.

Assumption
	This method operates on a valid looptree in which there are no
   intersecting loops(the loops are completely inside or outside each other).
   Thus at any given level, a loop can be nested inside only one loop.
	The method does not make any assumptions about the loop types.The
   nesting is purely geometrical.

History
	SM	03/10/87	Creation date.
	SM	27-Nov-89	Removed trivial check for incoming natural
				loop to be nested under the loopset.
				If the loopset already has one natural loop, 
				the caller will know about the coincedence
				via EMS_I_Ambiguous, just like all other
				coincedent loops.
*/

class implementation EMSloopset;

#include "EMS.h"
#include "OMmacros.h"
#include "emsmacros.h"

from EMSloop import EMnesting;

method EMnesting(IGRlong *EMmsg;struct EMSnest_info *nesting;
		 struct EMSpartolbasis *partolbasis)
{

     IGRlong		sts;
     OM_S_CHANSELECT	to_loops;

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;

   to_loops.type = OM_e_addr;
   to_loops.u_sel.addr = &ME.EMSloopset->to_loops;


   nesting->parent = NULL_OBJID;

/* If the loop in question is open or natural or feature loop
   then it is my child.
*/
   if( (!(nesting->lp_props & EMLP_OPEN)) &&
       /*(!(nesting->lp_props & EMLP_NATURAL)) && */
       (!(nesting->lp_props & EMLP_NOAREA_NOHOLE)))
    {
/* send the message down to each loop untill OM_I_STOP_SENDING is returned
   by one of the 'branches'. */

      sts = om$send(msg = message EMSloop.EMnesting
				(EMmsg,nesting,partolbasis),
                          p_chanselect = &to_loops);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
    }

/* If the loop was not nested inside any other loop then it is my child.
*/
  if(IF_NULL_OBJID(nesting->parent))
   {
     nesting->parent = my_id;
     nesting->parent_props = ME.EMSloopset->ls_props;
   }
  
wrapup:
  if(sts == OM_I_STOP_SENDING) sts = OM_S_SUCCESS;

  EMWRAPUP(*EMmsg,sts,"In EMSloopset.EMnesting")
  return(sts);

}

end implementation EMSloopset;
