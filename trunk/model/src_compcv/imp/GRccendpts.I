class implementation GRcompcurve;

#include "EMScc.h"
#include "msdef.h"

#include "igrdef.h"
#include "emserr.h"

method GRendpts(IGRlong *msg;
		IGRshort *mat_type;
		IGRmatrix matrix;
		IGRpoint startpt;
		IGRpoint endpt)

/*
Abstract
	This method return the end points of a composite curve

Return values for error code
	MSSUCC	if successful
	MSFAIL	otherwise

History
	gk	11/18/86	creation date
	rlw	05/08/87	changed channel name
    DLB 10/28/87    modified channel for version 1.1.0
*/

{
  IGRuint		numb_components;
  IGRpoint 		point;
  IGRlong  		msg_loc, status=OM_S_SUCCESS;
  OM_S_CHANSELECT	chan_def;


  *msg = MSSUCC;

  chan_def.type = OM_e_addr;
  chan_def.u_sel.addr = &ME.GRcmpowner->to_components;


/* The first component */

  status = om$send(msg = message GRcurve.GRendpts
			(&msg_loc, mat_type, matrix, startpt, point),
                   p_chanselect = &chan_def,
                   from = 0,
                   to = 0);
  EMomerr_hndlr(status, wrapup, "GRccendpts1");
  EMerr_hndlr(EMis_error(msg_loc), *msg, msg_loc, wrapup);

/* The last component */
/* How many components do I have so far? */

  status = om$get_channel_count(p_chanselect = &chan_def,
			        objid = my_id,
				count = &numb_components);
  EMomerr_hndlr(status, wrapup, "GRcompcurve: GRccchgprops, count");

  numb_components -= 1;
  status = om$send(msg = message GRcurve.GRendpts
			(&msg_loc, mat_type, matrix, point, endpt),
                   p_chanselect = &chan_def,
                   from = numb_components,
                   to = numb_components);
  EMomerr_hndlr(status, wrapup, "GRccendpts2");
  EMerr_hndlr(EMis_error(msg_loc), *msg, msg_loc, wrapup);

wrapup:
  return(status);

}

end implementation GRcompcurve;
