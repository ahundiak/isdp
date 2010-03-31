class implementation ECfedge;

/*

History
	09/30/92	JSY	Creation.

*/

#include <stdio.h>
#include <math.h>
#include "OMlimits.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "gocmacros.h"
#include "dp.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "bs.h"
#include "bsparameters.h"
#include "alloca.h"
#include "comndef.h"
#include "EMS.h"
#include "ems_m_inc.h"
#include "EC_P.h"
#include "EC_I.h"
#include "EMSdpb.h"
#include "ECmsg.h"

/* display flag used when locating surface */
#define SURF_LC_DISFLAG ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | \
                        ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT | \
                        LC_ERASE_LOC_ELEMENT

/* state number definition */
#define LOCATE_SURF 2

extern OMuword OPP_EMSsurface_class_id;
from EMScompsurf import EMget_free_edge;

method execute(IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRlong loc_mask, acc_mask, event_mask;
  struct GRlc_locate loc_attr;
  OMuword eclassid, rclassid;
  OM_S_CLASSLIST sf_elig, sf_rtree;
  struct GRevent acc_event;
  IGRboolean loop = TRUE;
  OMuword sf_classid;
  IGRlong sts, msg;

  UI_message("Free Edge List");

  /* initialize masks */
  loc_mask = GRm_DATA | GRm_BACK_UP | GRm_RESTART;
  acc_mask = GRm_DATA | GRm_RESTART;
  event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_RESTART;

  /* initialize locate attrbutes */
  loc_attr.properties = COPY_LC_PROPS;
  loc_attr.owner_action = LC_NON_GEOM_MOD;

  /* initialize locate eligible surface classes */
  rclassid = eclassid = OPP_EMSsurface_class_id;
  sf_rtree.w_count = sf_elig.w_count = 1;
  sf_rtree.w_flags = sf_elig.w_flags = OM_CLST_subclass;
  sf_rtree.p_classes = &rclassid;
  sf_elig.p_classes = &eclassid;

  /* enter infinite loop */
  do
  {
    switch (ME.super_cmd->state)
    {
    case 0:
      ME.super_cmd->state = LOCATE_SURF;
      break;

    case LOCATE_SURF:
      {
	/* locate the surface */
	sts = lc$locate(rc = &msg,
			event1 = &me->locev,
			event2 = &acc_event,
			mask1 = loc_mask,
			mask2 = acc_mask,
			response = response,
			response_data = response_data,
			display_flag = SURF_LC_DISFLAG,
			locate_key = EMS_P_00031,
			acc_key = EMS_P_00038,
			relocate_key = EMS_P_00011,
			attributes = &loc_attr,
			stack = &me->locate_stack,
			rtree_classes = &sf_rtree,
			eligible_classes = &sf_elig);

	/* verify the correctness of input */
	if (!(1 & msg))
	{
	  if (me->locev.response == EX_BACK_UP)
	  {
	    UI_status("Ignoring BACK_UP or MOVEON");
	    ME.super_cmd->state = LOCATE_SURF;
	  }
	  else
	    return OM_S_SUCCESS;
	}
	else
	{
	  /* save the located surface */
	  me->elem = acc_event.located_object[0];

	  gr$display_object(object_id = &me->elem.located_obj,
			    mode = GRhe);

	  /* test for composite surface */
	  om$get_classid(osnum = me->elem.located_obj.osnum,
			 objid = me->elem.located_obj.objid,
			 p_classid = &sf_classid);
	  if (om$is_ancestry_valid(subclassid = sf_classid,
				   superclassname = "EMScompsurf") == OM_S_SUCCESS)
	  {
	    if (om$is_ancestry_valid(subclassid = sf_classid,
				     superclassname = "EMSsolid") == OM_S_SUCCESS)
	      UI_status("surface of a solid");
	    else
	    {
	      sts = om$send(msg = message EMScompsurf.EMget_free_edge(&msg,
								      &me->elem),
			    targetid = me->elem.located_obj.objid,
			    targetos = me->elem.located_obj.osnum);
	    }
	  }
	  else
	  {
	    UI_status("non-composite surface");
	  }
	}
	break;
      }
    }
  } while ( loop );

  return OM_S_SUCCESS;
}

end implementation ECfedge;
