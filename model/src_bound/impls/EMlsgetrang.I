/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"

from EMSloop import EMgetrange;

method EMgetrange (
	IGRlong			*EMmsg;
	IGRdouble		*range)

/*
 This method calculates the range of a loopset.

History	   RC	05/01/87	Creation Date
*/

{
  IGRlong		OM_stat,
			mthd_stat;

  IGRint		i;
  OMuint 		num_lps;

  IGRdouble		lp_range[4];

  OM_S_CHANSELECT	ls_lp_chan;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  range[0] = MAXFLOAT;
  range[1] = MAXFLOAT;
  range[2] = MINFLOAT;
  range[3] = MINFLOAT;

  ls_lp_chan.type = OM_e_addr;
  ls_lp_chan.u_sel.addr = &ME.EMSloopset->to_loops;

  OM_stat = om$get_channel_count ( object = me,
				p_chanselect = &ls_lp_chan,
				count = &num_lps);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  for ( i = 0; i < num_lps; i++)
  {
	OM_stat = om$send (msg = message EMSloop.EMgetrange (
					&mthd_stat,
					lp_range),
				p_chanselect = &ls_lp_chan,
				from = i,
				to = i);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

	if (lp_range[0] < range[0]) range[0] = lp_range[0];
	if (lp_range[1] < range[1]) range[1] = lp_range[1];
	if (lp_range[2] > range[2]) range[2] = lp_range[2];
	if (lp_range[3] > range[3]) range[3] = lp_range[3];

  }

wrapup:

 EMWRAPUP (*EMmsg, OM_stat, "In EMSloopset.EMgetrange");

 return (OM_stat);

}

end implementation EMSloopset;

