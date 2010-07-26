class implementation COdmplace;

#include "msdef.h"
#include "msmacros.h"
#include "DMmessages.h"

#define AS_DEBUG 1

from GRgraphics import GRremwrng;
from DMroot import set_dim_state, chgdp;
/***

History:

	05/12/94 -- Satya -- Radial Dimension Constraints are also checked
			     for in init_type
	
***/

method display_dimension(
	IGRint level;
	IGRint control)
{
	IGRint status, rc;
	IGRshort dim_state;

	if (control & DISPLAY)
	{
		status =
		om$send(msg =  message COdmplace.dimension_driving(),
			targetid = my_id);
		dm$status(action = RET_STATUS);

                /* - Some cases it enters in rtree here ?*/

                status =
		om$send(msg = message GRgraphics.GRremwrng(
                                         (IGRlong *) &rc,
                                         &me->md_env),
                       targetid  = me->dim_grid.objid,
                       targetos  = me->dim_grid.osnum);

                /* Do not check the status*/
	}

	status =
	DMdisplay_dimension(
		&rc,
		level,
		control,
		&me->md_env,
		&me->dim_grid);
	dm$status(action = RET_STATUS);

	dim_state = (control & DISPLAY)?0:DIM_IN_PLACEMENT;

	status =
	om$send(msg = message DMroot.set_dim_state(BIT_SET, dim_state),
		targetid = me->dim_grid.objid,
		targetos = me->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method dimension_driving()
{
	return(OM_S_SUCCESS);
}

method init(int type; char *string_ptr)
{
	IGRint status, index;

	status =
	om$send(msg = message COdim.init(type, string_ptr),
		targetid = my_id,
		mode = OM_e_wrt_message);
	dm$status(action = RET_STATUS);

	me->draw_axis = FALSE;
	me->draw_sect = FALSE;
	me->axis_sel  = 0;
	me->form_displayed = FALSE;
	me->form = NULL;
	me->mask1 |= GRm_STRING;
	me->mask2 |= GRm_STRING;

	me->dim_grid.objid =
	me->first_dim.objid =
	me->prev_dim.objid = NULL_OBJID;

	for (index=0; index<MAX_DIM_ROOTS; index++)
	{
		me->list[index].objid =
		me->context[index].objid = NULL_OBJID;
	}

	/*"me->mytype=%d, type=%d\n", me->mytype, type*/

	me->state = STATE_P_LOC_ORIG;
	me->dim_type = me->mytype;

	status =
	om$send(msg = message COdmplace.init_type(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method init_type()
{
	IGRint status;
	IGRboolean is_cnstr;
	struct GRid my_grid;
        extern GRclassid
                OPP_ECdmcnstr_class_id,
                OPP_DMlincpx_class_id,
                OPP_DMsglpara_class_id,
                OPP_DMcirdia_class_id,
                OPP_DMlindia_class_id,
                OPP_DMradjog_class_id,
                OPP_DMcoordj_class_id,
                OPP_DMangular_class_id,
                OPP_DMcenline_class_id;
	extern IGRboolean Dim_coord_jog;

	me->ori_index = DIM_CPX_ORIG;
	me->mea_index = DIM_CPX_MEAS;
	me->cpx_type = STACKED_CPX;
	me->meas_needed = TRUE;
	me->axis_needed = TRUE;
	me->is_a_complex = FALSE;
	me->angular_dim = FALSE;
	me->orthogonal = FALSE;
	me->angle_center = FALSE;
	me->count = NO_CPX_DIM_ROOTS;
	me->sel_type = POINT_TYPE;

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	is_cnstr = DMancestry_valid(my_grid, OPP_ECdmcnstr_class_id);

	switch (me->dim_type)
	{
		case STACKED_LINEAR:

		me->msgnumb = (is_cnstr)?DMC_M_GRScLnDmC:DMC_M_DMLnStc;
		me->is_a_complex = TRUE;
		me->dim_classid = OPP_DMlincpx_class_id;
		break;

		case STRINGED_LINEAR:

		me->msgnumb = (is_cnstr)?DMC_M_GRSrLnDmC:DMC_M_DMLnStr;
		me->cpx_type = STRINGED_CPX;
		me->dim_classid = OPP_DMlincpx_class_id;
		me->is_a_complex = TRUE;
		break;

		case SYMMETRICAL_DIAMETER:

                me->msgnumb = (is_cnstr)?DMC_M_GRSyDiDmC:DMC_M_DMSmDia;
		me->dim_classid = OPP_DMlincpx_class_id;
		me->is_a_complex = TRUE;
		break;

		case SINGLE_PARALLEL:

		me->msgnumb = (is_cnstr)?DMC_M_GRSnPrDmC:DMC_M_DMLnPar;
		me->count = NO_SGPAR_DIM_ROOTS;
		me->dim_classid = OPP_DMsglpara_class_id;
		me->sel_type = LINE_TYPE;

		status =
		om$send(msg = message COdim.create_form(0, "DMSglArc", &me->form),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		ex$message(msgnumb = DM_I_StatFormAvForOpt);
                GRstatus_display_button(1);
		break;

		case CIRCULAR_DIAMETER:

		me->count = NO_CDIA_DIM_ROOTS;
		me->msgnumb = DMC_M_DMCrDia;
		me->dim_classid = OPP_DMcirdia_class_id;
		me->sel_type = ARC_TYPE;
		break;

		case LINEAR_DIAMETER:

		me->count = NO_LDIA_DIM_ROOTS;
		me->msgnumb = DMC_M_DMLnDia;
		me->dim_classid = OPP_DMlindia_class_id;
		break;

		case STACKED_ANGULAR:

		me->msgnumb = (is_cnstr)?DMC_M_GRScAnDmC:DMC_M_DMAnStc;
		me->dim_classid = OPP_DMangular_class_id;
		me->is_a_complex = TRUE;
		me->sel_type = POINT_TYPE;
		break;

		case STRINGED_ANGULAR:

		me->msgnumb = (is_cnstr)?DMC_M_GRSrAnDmC:DMC_M_DMAnStr;
		me->cpx_type = STRINGED_CPX;
		me->dim_classid = OPP_DMangular_class_id;
		me->is_a_complex = TRUE;
		me->sel_type = POINT_TYPE;
		break;

		case RADIAL:

		me->msgnumb = (is_cnstr)?DMC_M_GRRdDmCn:DMC_M_DMRd;
		me->count = NO_RAD_DIM_ROOTS;
		me->dim_classid = OPP_DMradjog_class_id;
		me->sel_type = ARC_TYPE;

		status =
		om$send(msg = message COdim.create_form(0, "DMPlRadDim", &me->form),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		ex$message(msgnumb = DM_I_StatFormAvForOpt);
                GRstatus_display_button(1);
		break;

		case RADIAL_DIAMETER:

		me->count = NO_RAD_DIM_ROOTS;
		me->msgnumb = (is_cnstr)?DMC_M_GRRdDiDmC:DMC_M_DMRdDia;
		me->dim_classid = OPP_DMradjog_class_id;
		me->sel_type = ARC_TYPE;
		break;

		case COORDINATE:

		me->msgnumb = DMC_M_DMLnCoo;
		me->cpx_type = COORDINATE_CPX;
		me->dim_classid = OPP_DMcoordj_class_id;
		me->is_a_complex = TRUE;
		Dim_coord_jog = FALSE;

		if (!me->form)
		{
			status =
			om$send(msg = message COdim.create_form(0, "DMPlCoordLin", &me->form),
				targetid = my_id);
			dm$status(action = RET_STATUS);

        	        ex$message(msgnumb = DM_I_StatFormAvForOpt);
                        GRstatus_display_button(1);
		}
		break;

		case CENTER_LINE:

		me->count = NO_CEN_DIM_ROOTS;
		me->ori_index = DIM_CEN_CURVE;
		me->msgnumb = DMC_M_DMCnLn;
		me->dim_classid = OPP_DMcenline_class_id;
		me->sel_type = ARC_TYPE;
		break;

		default:

		if (me->mytype == 100)
			me->msgnumb = DMC_M_DMAdMsTGr;
		else
		{
			printf("COdmplace: Invalid type=%d\n", me->mytype);
			return(OM_E_ABORT);
		}
		break;
	}

	switch (me->dim_type)
	{
		case SINGLE_PARALLEL:
		case RADIAL:
		case RADIAL_DIAMETER:

		me->meas_needed = FALSE;
		me->axis_needed = FALSE;
		me->loc_key = DM_P_LocElt;
		me->acc_key = DM_P_PosDim;
		me->rel_key = DM_E_EltNotFound;
		break;

		case STACKED_ANGULAR:
		case STRINGED_ANGULAR:

		me->angular_dim = TRUE;
		me->loc_key = DM_P_LocOrigOrt;
		me->acc_key = DM_P_LocMeas;
		me->rel_key = DM_E_OrigNotFound;
		break;

		case CIRCULAR_DIAMETER:
		case COORDINATE:

		me->meas_needed = FALSE;
		me->loc_key = (me->dim_type == COORDINATE) ? DM_P_LocZero:DM_P_LocElt;
		me->acc_key = DM_P_SelProjLin;
		me->rel_key = DM_E_EltNotFound;
		break;

		case CENTER_LINE:

		me->meas_needed = FALSE;
		me->axis_needed = FALSE;
		me->loc_key = DM_P_LocCurve;
		me->acc_key = DM_P_PtInOut;
		me->rel_key = DM_E_EltNotFound;
		break;

		default:

		me->loc_key = DM_P_LocOrig;
		me->acc_key = DM_P_LocMeas;
		me->rel_key = DM_E_OrigNotFound;
		break;
	}

	if (me->mytype == 100)
	{
		me->loc_key = DM_P_LocCmpx;
		me->acc_key = DM_P_LocMeas;
		me->rel_key = DM_E_EltNotFound;
	}

	return(OM_S_SUCCESS);
}

end implementation COdmplace;

