/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: dim.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:07:47  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.3  1997/02/20  12:21:42  askomand
# COMMENT : Fix for locate of elements for detailing, annotaster environment.
#
# Revision 330.2  1996/12/31  07:24:27  skathiri
# COMMENT : Changes for RFA+Assembly
#
# Revision 330.1  1996/07/15  09:32:09  skathiri
# COMMENT : Changes for RFA
#
# Revision 330.0  1996/01/11  21:21:46  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:51:16  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.2  1994/08/10  21:52:32  grnuc40
# COMMENT : Upgrade due to Intel Solaris port
#
# Revision 240.1  1993/03/01  19:38:51  mikel
# COMMENT : remove ms.h or change it to msmacros.h
#
# Revision 240.0  1992/12/06  23:43:16  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.1  1992/09/09  14:15:16  scott
# COMMENT : ANSI/SGI fixes
#
Revision 201.10  1992/08/07  15:41:00  grnuc20
COMMENT : ANSI C conversion fixes

Revision 201.9  1992/07/23  19:53:58  doree
COMMENT : message subsystem compliance

Revision 201.8  1992/07/20  12:04:30  gvk
COMMENT : Added LC_HANDLES bit for locating constraints.

Revision 201.7  1992/07/19  16:13:19  poo
COMMENT : Inital Checkin of Jogged Dimension fuctionality.

*/

class implementation COdim;

#define AS_DEBUG 1
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "maidmx.h"
#include "madef.h"

%safe
#include "math.h"
%endsafe

from IGEgragad import DPinrot;
from GRgraphics import GRlnproject;

method init(int type; char *string_ptr)
{
	IGRint status;
        IGRint DMlocate_dynamics();
    IGRboolean aflag;
    IGRlong msg;

	status =
	om$send(msg = message super_cmd.init(type, string_ptr),
		targetid = my_id,
		mode = OM_e_wrt_message);
	dm$status(action = RET_STATUS);


    aflag = pwIsActivationOn();
    if (aflag)
    {
      int sts;
      sts = pwGetActiveModuleEnv(&me->md_env);
      MAidmx(&msg, me->md_env.md_env.matrix);
      me->md_env.md_env.matrix_type = MAIDMX;
    }
    else
    {
	status =
	DMget_module_info(&me->md_env);
	dm$status(action = RET_STATUS);
    }

	me->dyn_env = me->md_env;
	me->dyn_env.md_id.objid = NULL_OBJID;

	me->attr.properties =   LC_LC_ONLY | LC_DP_ONLY | LC_RW;
	me->attr.owner_action = LC_READ  | LC_NO_REF_HEADER |
				LC_REF_OBJECTS | LC_HANDLES;

	me->act_parms.cmd.objid = my_id;
	me->act_parms.cmd.osnum = OM_Gw_current_OS;
	me->act_parms.stack.num_entries = 0;

	me->lc_dyn.GRlc_dyn = DMlocate_dynamics;
	me->lc_dyn.add_info = (IGRchar *)&me->act_parms.cmd;

	me->mask1 =
	me->mask2 = GRm_DATA | GRm_RESET | GRm_BACK_UP;
	me->display_flag = ELEM_HILIGHT | ALL_WINDOWS |
			   NO_PROJ_ACCEPT_POINT | DO_NOT_RELOCATE
			   | LC_INPUT_LOC_POINT;

	ASsuper_construct();

	return(OM_S_SUCCESS);
}

method wakeup(int pos)
{
	struct GRid super_grid;

	ex$message(msgnumb = me->msgnumb);
	dm$get_cur_super(p_grid = &super_grid);
	return( OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
	IGRint msg;

	ex$message(msgnumb = GR_P_Clear);
	ex$message(msgnumb = GRC_M_Clear);

	dp$erase_hilite(msg = &msg);

	return(OM_S_SUCCESS);
}

method locate_parent(
	IGRint *response;
	IGRchar *response_data;
	struct GRevent *loc_event;
	IGRboolean putque_acc;
	IGRint locate_key;
	IGRint acc_key;
	IGRint relocate_key)
{
	IGRint status, rc;
	IGRint byte = sizeof(struct GRevent);

	ex$message(msgnumb = locate_key, buff = me->locate_prompt);
	ex$message(msgnumb = acc_key,    buff = me->acc_prompt);
	ex$message(msgnumb = relocate_key,  buff = me->relocate_prompt);

	status =
	DMlocate(
		&me->locate_rc,
		&me->event1,
		&me->event2,
		me->mask1,
		me->mask2,
		me->display_flag,
		response,
		response_data,
		me->locate_prompt,
		me->acc_prompt,
		me->relocate_prompt,
		&me->attr,
		&me->act_parms,
		&me->lc_dyn);
	dm$status(action = RET_STATUS);


	if (me->event1.response == DATA)
	{
		switch (me->event1.subtype)
		{
			case GRst_REGULAR:
			case GRst_TANGENT_FROM:
			case GRst_TANGENT_TO:
			case GRst_CENTER:
			case GRst_INTER:
			case GRst_KEYPOINT:
			case GRst_MIDPOINT:
			case GRst_ENDPOINT:
			case GRst_LOCATE:
			case GRst_ASSOC_KEYPOINT:
			break;

			default:
			ex$message(msgnumb = DM_E_EvtNotSup);
			me->locate_rc = LC_NO_OBJ_LOCATED;
		}
	}

	if (me->locate_rc == LC_OBJ_LOCATED)
	{
		*loc_event = me->event1;

		/*"me->event1.subtype=%d\n", me->event1.subtype*/

		if (putque_acc && me->event1.response == DATA
		&&  me->event1.subtype == GRst_REGULAR)
		{
			/*|Put accept point on queue*/

			status =
			ex$putque(
				msg = (IGRlong *) &rc,
				response = &me->event2.response,
				byte = (IGRlong *) &byte,
				buffer = (IGRchar *) &me->event2.event);
			dm$status(action = RET_STATUS);
		}
		else if (me->event1.subtype != GRst_REGULAR)
		{
			struct GRlc_info *lc_info;

			/* - If a composite curve was located
			     it must be replaced by the proper
			     leaf-id - */

			if (me->event1.subtype != GRst_LOCATE)
			{
				status = DMupdate_event(&me->event1);
				dm$status(action = RET_STATUS);
			}

			lc_info = me->event1.located_object;
			me->locate_rc = LC_RELOCATE;

			status =
			om$send(msg = message COdim.LC_selection(&rc, lc_info),
				targetid = my_id);
			dm$status(action = RET_VALUE, value = OM_S_SUCCESS);
			if (!rc) return(OM_S_SUCCESS);

			status =
			om$send(msg = message COdim.LC_preproc(&rc, lc_info),
				targetid = my_id);
			dm$status(action = RET_VALUE, value = OM_S_SUCCESS);

			status =
			om$send(msg = message COdim.LC_postproc(),
				targetid = my_id);
			dm$status(action = RET_VALUE, value = OM_S_SUCCESS);

                        me->locate_rc = LC_OBJ_LOCATED;
		}
	}

	return(OM_S_SUCCESS);
}

method load_obj_info(
	struct GRevent *loc_event;
	struct DMobj_info *obj_info)
{
	IGRint status, rc;
	struct GRlc_info *lc_info;
	struct GRmd_env *lc_env;
	IGRmatrix matrix;
	struct IGRline view_line;
	IGRpoint norpt, dummy_pt;
	IGRdouble dummy_par;

	lc_info = &loc_event->located_object[0];
	lc_env  = &lc_info->module_info;
	obj_info->grid = lc_info->located_obj;

	status =
	om$send(msg = message IGEgragad.DPinrot((IGRlong *) &rc, matrix),
		targetid = loc_event->event.button.objid,
		targetos = loc_event->event.button.osnum);
	dm$status(action = RET_STATUS);

	view_line.point1 = &loc_event->event.button.x;
	view_line.point2 = norpt;
	norpt[0] = view_line.point1[0] + matrix[8];
	norpt[1] = view_line.point1[1] + matrix[9];
	norpt[2] = view_line.point1[2] + matrix[10];

	status =
	om$send(msg = message GRgraphics.GRlnproject(
					(IGRlong *) &rc,
					&lc_env->md_env.matrix_type,
					lc_env->md_env.matrix,
					&view_line,
					dummy_pt,
					obj_info->lnproj,
					&dummy_par,
					&obj_info->par),
		targetid = obj_info->grid.objid,
		targetos = obj_info->grid.osnum);
	dm$status(action = RET_STATUS);


	status =
	GRfindcontext(
		&rc,
		&lc_info->module_info.md_env.matrix_type,
		lc_info->module_info.md_env.matrix,
		&obj_info->grid.osnum,
		&obj_info->context);
	if (status != OM_S_SUCCESS || rc != MSSUCC)
	{
		/*"GRfindcontext status = %d, rc = %d\n", status, rc*/
		obj_info->context.objid = NULL_OBJID;
	}
	/*^
		print_grid("loc_grid", &obj_info->grid);
		print_point("lc_proj_pnt", lc_info->proj_pnt);
		printf("lc_u_par=%lf\n", lc_info->geom_parms.u);
		print_point("proj_pnt", obj_info->lnproj);
		printf("u_par=%lf\n", obj_info->par.u);
		printf("context=%d,%d\n", obj_info->context.objid,
					  obj_info->context.osnum);
	*/

	return(OM_S_SUCCESS);
}

method getevent(
	IGRint msgkey;
	IGRint *response;
	IGRchar *response_data;
	struct GRevent *event)
{
	IGRint status, rc;
	IGRint nbytes = sizeof(struct GRevent);

	status =
	co$getevent(
		msg = &rc,
		event_mask = me->mask1,
		msgnum = msgkey,
		mode = EX_LINE_MODE,
		nbytes = &nbytes,
		response = response,
		response_data = response_data,
		event = event);
	dm$status(action = RET_STATUS);

	if (rc != MSSUCC)
	{
		/*| co$getevent filter fails */
		return(OM_E_ABORT);
	}

	/*^
		printf("response = %d\n", *response);
		printf("event->response = %d\n", event->response);
	*/

	return(OM_S_SUCCESS);
}

method create_form(
	int form_label;
	char *form_name;
	Form *form)
{
	int status;
        int DMnotify_form();

	/*"form_label=%d, form_name=%s\n", form_label, form_name*/

	status =
	FIf_new(form_label, form_name, DMnotify_form, form);
	if (status != FI_SUCCESS)
	{
		/*|create_form: FIf_new failed*/
		return(OM_E_ABORT);
	}

	status =
	FIf_set_cmd_oid_os(*form, my_id, OM_Gw_current_OS);
	if (status != FI_SUCCESS)
	{
		/*|create_form: FIf_set_cmd_oid_os failed*/
		return(OM_E_ABORT);
	}

	return(OM_S_SUCCESS);
}

end implementation COdim;

