/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This is the overridden implementation for the method declared at
  EMSedge. The method acts as a pass on like all other methods for
  EMSpartedge, sending down the proper boundary.
	If a NULL pointer is passed for the EMSpartedinfo, this object sends
  down its structure. Otherwise it simply passes on the structure it 
  received from the sender.

Assumption
	Every EMSpartedge object has a 'to_edge' connection. Going down
  this channel, one will ultimately hit the full edge where the action is.

History
        PP    12/02/87   Made changes for edge type
	SM    02/26/87   Creation date
*/

class implementation EMSpartedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emsmacros.h"

method EMextractyourself(IGRlong *EMmsg;
			 struct EMSsfintedpar *my_bdrys,*ele_bdrys;
			 IGRint num_bdrys;GRobjid **output_obj;
			 struct EMSsfintedpar ***out_bdrys,***against_bdrys;
			 IGRboolean output_pairs;
			 IGRushort options;struct EMSpartedinfo *part;
			 struct EMSpartolbasis *partolbasis)
{

	IGRlong			sts;
	OM_S_CHANSELECT		to_edge;

	*EMmsg=EMS_S_Success;
	sts = OM_S_SUCCESS;

/* If a NULL pointer was passed for bnd, it means I have to send down to my
   geometry. If the pointer is non NULL then it means that somebody up
   there is trying hard to reach its geometry and I need to help by acting
   as a passon.
*/
	sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edge);
	if(!(1&sts)) goto wrapup;
	
	if(part)
	sts = om$send(msg=message EMSedge.EMextractyourself
			(EMmsg, my_bdrys, ele_bdrys, num_bdrys, output_obj,
			 out_bdrys, against_bdrys, output_pairs, options,
			 part, partolbasis),
			p_chanselect = &to_edge);
	else
	 {
	   struct EMSpartedinfo my_info;
           EMput_partinfo (my_info);
 	   sts = om$send(msg=message EMSedge.EMextractyourself
			(EMmsg, my_bdrys, ele_bdrys, num_bdrys, output_obj,
			 out_bdrys, against_bdrys, output_pairs, options, 
			 &my_info, partolbasis),
			p_chanselect = &to_edge);
	 }
wrapup:
	EMWRAPUP(*EMmsg,sts,"In EMSpartedge.EMextractyourself")
	return(sts);
}

end implementation EMSpartedge;
