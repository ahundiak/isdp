class implementation COchgter;

#define AS_DEBUG 1

#include "dpstruct.h"
#include "dimformdef.h"
#include "dimform.h"
#include "form_env.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "DMmessages.h"

from DMroot import set_dim_state, return_go_index;

method init(int type; char *string_ptr)
{
	IGRint status;
	IGRchar *opt_name;
	struct DMenv_param par_env;

	status =
	om$send(msg = message COdim.init(type, string_ptr),
		targetid = my_id,
		mode = OM_e_wrt_message);
	dm$status(action = RET_STATUS);

	status =
	dm$get_dim_param(type = DM_ENV_PARAM, p_data = (char*) &par_env);
	dm$status(action = RET_STATUS);

	me->msgnumb = DMC_M_RpTr;
	me->dim_grid.objid = NULL_OBJID;
	me->state = STATE_CT_LOC_TERM;
	me->form_is_displayed = FALSE;
	me->ter_type = par_env.ter_type;

	opt_name = (char *)DMget_option(
				FORM_DIMTERM,
				SUB_FORM_LABEL,
				me->ter_type);
	strcpy(me->ter_name, opt_name);

	status =
	om$send(msg = message COdim.create_form(0, "DMSubTerm", &me->form),
		targetid = my_id);
	dm$status(action = RET_STATUS);

        ex$message(msgnumb = DM_I_StatFormAvForOpt);

	return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
	IGRint status;

	while (TRUE)
	{
		switch (me->state)
		{
		
			/*********************/
			case STATE_CT_LOC_TERM:
			/*********************/

                        ex$message(msgnumb = DM_I_ActiveTermType,
                                   type = "%s",
                                   var = `me->ter_name`);

			status =
			om$send(msg = message COdim.locate_parent(
							response,
							response_data,
							&me->dim_event,
							FALSE,
							DM_P_LocTer,
							DM_P_Ac,
							DM_E_Obnofo),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->locate_rc == LC_OBJ_LOCATED)
				me->state = STATE_CT_CHG_TERM;
			break;

			/*********************/
			case STATE_CT_CHG_TERM:
			/*********************/

			status =
			om$send(msg = message COchgter.change_terminator(),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			me->state = STATE_CT_LOC_TERM;
			break;

			/******/
			default:
			/******/

			printf("COchgter: Unknown state %d\n", me->state);
			*response = TERMINATE;
			return(OM_S_SUCCESS);
		}

		switch (*response)
		{
			case DATA:
			case RESET:
			case D_RESET:
			case MOVE_ON:
			break;

			case STATUS_DISP:

			status =
			om$send(msg = message COchgter.display_form(),
				targetid = my_id);
			dm$status(action = RET_STATUS);
			break;

			default:
			return(OM_S_SUCCESS);
		}
	}
}

method LC_preproc(IGRint *msg; struct GRlc_info *lc_info)
{
	me->event1.located_object[0] = *lc_info;
	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method LC_postproc()
{
	return(OM_S_SUCCESS);
}

method LC_dynamics(
	IGRint *msg;
	struct GRid *obj;
	struct GRevent *event)
{
	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method LC_selection(IGRint *msg; struct GRlc_info *lc_info)
{
	IGRint status, rc;
	extern GRclassid OPP_DMroot_class_id;
	extern GRclassid OPP_DMtext_class_id;


/*	if (DMancestry_valid(
		lc_info->located_obj,
		OPP_DMroot_class_id))
	{
		me->dim_grid = lc_info->located_obj;
		me->comp_type = 0;

		*msg = TRUE;
		return(OM_S_SUCCESS);
	}
*/

	if (!DMancestry_valid(
		lc_info->located_obj,
		OPP_DMtext_class_id))
	{
		/*| Not a text object */

		*msg = FALSE;
		return(OM_S_SUCCESS);
	}

	status =
	om$get_objid_at_index(
		osnum = lc_info->located_obj.osnum,
		objid = lc_info->located_obj.objid,
		p_chanselect = &AS_to_owner,
		index = 0,
		objidaddr = &me->dim_grid.objid,
		osnumaddr = &me->dim_grid.osnum);
	if (!(status & 1))
	{
		/*| Not a rigid component */

		*msg = FALSE;
		return(OM_S_SUCCESS);
	}

	if (!DMancestry_valid(me->dim_grid, OPP_DMroot_class_id))
	{
		/*| Parent not a dimension */

		*msg = FALSE;
		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message DMroot.return_go_index(
						&rc,
						lc_info->located_obj,
						&me->comp_type),
		targetid = me->dim_grid.objid,
		targetos = me->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	if ((me->comp_type != DIM_ORI_TERM)
	&&  (me->comp_type != DIM_MEA_TERM))
	{
		/*| Not a terminator */

		*msg = FALSE;
		return(OM_S_SUCCESS);
	}

	*msg = TRUE;
	return(OM_S_SUCCESS);
}

method display_form()
{
	IGRint status, mask;
	IGRint map_size, index;
	struct lab_val *map;
	extern struct DMform_info DMform_list[];

	map_size = DMform_list[FORM_DIMTERM].map_size;
	map = DMform_list[FORM_DIMTERM].map;

	status = FIf_set_location(me->form, 0, 105);
	fi$status(sts = status, comment = "FIf_set_location");

	status = FIf_get_attr(me->form, &mask);
	fi$status(sts = status, comment = "FIf_get_attr");

	mask = mask | FI_SAVE_RESTORE;

	status = FIf_set_attr(me->form, mask);
	fi$status(sts = status, comment = "FIf_set_attr");

	for (index=0; index<map_size; index++)
	{
		status =
		FIg_set_value(
			me->form,
			map[index].label,
			(double)(map[index].ivalue == (int)me->ter_type));
		fi$status(sts = status, comment = "FIg_set_value");
	}

	status = FIf_display(me->form);
	fi$status(sts = status, comment = "FIf_display");

	return(OM_S_SUCCESS);
}

method notify_form(
	int form_label;
	int label;
	double value;
	Form form)
{
	IGRint status;
	IGRint index, map_size;
	IGRchar *opt_name;
	struct lab_val *map;
	extern struct DMform_info DMform_list[];

	status = FIf_erase(me->form);
	fi$status(sts = status, comment = "FIf_erase");

	me->form_is_displayed = FALSE;

	map_size = DMform_list[FORM_DIMTERM].map_size;
	map = DMform_list[FORM_DIMTERM].map;

	for (index=0; index<map_size; index++)
	if (label == map[index].label)
	{
		me->ter_type = map[index].ivalue;
		break;
	}

	if (index < map_size)
	{
		opt_name = (char *)DMget_option(
				FORM_DIMTERM,
				SUB_FORM_LABEL,
				me->ter_type);
		strcpy(me->ter_name, opt_name);
	}
	else	printf("ERROR: label=%d\n", label);

        ex$message(msgnumb = DM_I_ActiveTermType,
                   type = "%s",
                   var = `me->ter_name`);

	return(OM_S_SUCCESS);
}

method wakeup(int pos)
{
	IGRint status;

	status =
	om$send(msg = message COdim.wakeup(pos),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->form_is_displayed)
	{
		status = FIf_display(me->form);
		if (status != FI_SUCCESS)
		{
			/*|FIf_display fails*/
			return(OM_E_ABORT);
		}
	}

        ex$message(msgnumb = DM_I_StatFormAvForOpt);
        GRstatus_display_button(1);

	return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
	IGRint status;

	status =
	om$send(msg = message COdim.sleep(pos),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status = FIf_erase(me->form);
	if (status != FI_SUCCESS)
	{
		/*|FIf_erase fails*/
		return(OM_E_ABORT);
	}

        ex$message(msgnumb = GR_I_Clear);
        GRstatus_display_button(0);

	return(OM_S_SUCCESS);
}

method delete(int f_defer_flag)
{
	IGRint status;

	status =
	om$send(msg = message COdim.delete(f_defer_flag),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status = FIf_delete(me->form);
	if (status != FI_SUCCESS)
	{
		/*|FIf_delete fails*/
		return(OM_E_ABORT);
	}

	return(OM_S_SUCCESS);
}

method change_terminator()
{
	IGRint status;
	struct DMenv_param par_env;

	/*| Get environment */

	status =
	dm$get_dim_param(
		type = DM_ENV_PARAM,
		dim_objid = me->dim_grid.objid,
		dim_osnum = me->dim_grid.osnum,
		p_data = (char*) &par_env);
	dm$status(action = RET_STATUS);

	if (me->comp_type == DIM_ORI_TERM)
		par_env.ter_type0 = me->ter_type;
	else if (me->comp_type == DIM_MEA_TERM)
		par_env.ter_type  = me->ter_type;
	else
	{
		par_env.ter_type0 =
		par_env.ter_type  = me->ter_type;
	}

	/*| Set dim to state EDIT */

	status =
	om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_IN_EDIT),
		targetid = me->dim_grid.objid,
		targetos = me->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	/*| Put environment */

	status =
	dm$put_dim_param(
		type = DM_ENV_PARAM,
		dim_objid = me->dim_grid.objid,
		dim_osnum = me->dim_grid.osnum,
		p_data = (char*) &par_env);
	dm$status(action = RET_STATUS);

	/*| Clear EDIT state */

	status =
	om$send(msg = message DMroot.set_dim_state(BIT_XOR, DIM_IN_EDIT),
		targetid = me->dim_grid.objid,
		targetos = me->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	/*| Compute dimension */

	status =
	dm$change_node(
		broadcast = FALSE,
		as_grid = me->dim_grid,
		md_env = &me->md_env);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

end implementation COchgter;
