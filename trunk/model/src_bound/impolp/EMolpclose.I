/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	EMSopenloop does not use any of the pieces of the exisiting loopset
to close itself off. It is closed by itself. This method therefore just
initializes the loop and inserts it into the input loopset.

History
	SM	01-Mar-89	Creation.
*/
class implementation EMSopenloop;

#include "EMS.h"

#include "emsdef.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsgeteddef.h"
#include "emslpinitdef.h"

from EMSloopset import EMnesting,EMtreemod;

method EMcloseyourself( IGRlong *EMmsg;
			GRobjid *loopset;IGRboolean *closed;
			struct EMSpartolbasis *partolbasis)
{
   IGRlong              sts;

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;

   *closed = TRUE;
   ME.EMSloop->lp_props &= ~EMLP_OPEN;
   sts = om$send(msg=message EMSopenloop.EMolpinit
		(EMmsg, ME.EMSloop->lp_props, partolbasis, FALSE), 
		targetid = my_id);
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

/* If the caller has specified a loopset, then put myself into its looptree
*/
   if(loopset)
    {
      struct EMSnest_info	nesting;

      nesting.loopid = my_id;
      nesting.lp_props = ME.EMSloop->lp_props;
      nesting.parent = NULL_OBJID;
      nesting.parent_props = NULL;
      OM_BLOCK_MOVE(ME.EMSloop->range, nesting.range, 4 * sizeof(IGRdouble));

      sts = om$send(msg=message EMSloopset.EMnesting
				(EMmsg,&nesting,partolbasis),
			targetid = *loopset);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
      if(IF_EQ_OBJID(*loopset,nesting.parent))
       {
	sts = om$send(msg=message EMSloopset.EMtreemod
			(EMmsg,&nesting,ADD_CHILD,partolbasis),
			targetid = nesting.parent);
	EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
       }
      else
       {
	sts = om$send(msg=message EMSloop.EMtreemod
			(EMmsg,&nesting,ADD_CHILD,partolbasis),
			targetid = nesting.parent);
	EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
       }

     } /* If loopset */

wrapup:
   EMWRAPUP(*EMmsg,sts,"EMSopenloop.EMcloseyourself")
   return(sts);
}

end implementation EMSopenloop;
