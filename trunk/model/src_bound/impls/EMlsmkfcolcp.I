/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include <stdio.h>
#include "emserr.h"
#include "emsmacros.h"

from EMSloop import EMmkface_collapse_copy;

method EMmkface_collapse_copy (
	IGRlong				*EMmsg;
	struct	EMSpartolbasis  	*partolbasis;
	GRobjid				*new_lps_added;
	IGRint				*num_lps_added;
	GRobjid				**lps_removed;
	IGRint				*num_lps_removed;
	IGRint				*lps_rm_array_size;
  	struct EMSmkf_edcon_info 	**ed_con_info;
  	IGRint				*num_edcon_entries;
  	IGRint				*edcon_array_size)
/*
 Notes
	This method is currently used by MAKE FACE
	operation. It is not clear if this functionality
	can be used any where else.

	In case of a make face operation, the boundaries 
	are moved from the original surface to the newly
	made face. Since a boundary can not share two
	(u,v) spaces, it is needed to copy the boundary
	if necessary and then collapse it.

	This is just a passon method.

History	  
            RC 	05/10/87   Creation Date


*/


{   
   IGRlong		OM_stat, 
			mthd_stat;

   OM_S_CHANSELECT	ls_lp_chan;

   OM_stat = OM_S_SUCCESS;
   *EMmsg  = EMS_S_Success;

   ls_lp_chan.type = OM_e_addr;
   ls_lp_chan.u_sel.addr = &ME.EMSloopset->to_loops;
 
   *num_lps_removed = 0;
   *lps_rm_array_size = 0;
   *num_edcon_entries = 0;
   *edcon_array_size = 0;

   OM_stat = om$send (msg = message EMSloop. EMmkface_collapse_copy(
					&mthd_stat,
				  	 partolbasis,
					 new_lps_added,
					 num_lps_added,
					 lps_removed,
					 num_lps_removed,
					 lps_rm_array_size,
 					 ed_con_info,
					 num_edcon_entries,
  					 edcon_array_size),
		      p_chanselect = &ls_lp_chan);
   EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);

wrapup:
   EMWRAPUP (*EMmsg,OM_stat, "In EMSloopset.EMmkface_collapse_copy");

   return (OM_stat);
}
	
end implementation EMSloopset;
