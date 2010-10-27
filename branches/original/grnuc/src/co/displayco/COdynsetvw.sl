/*
Name
        COdynsetvw.sl

History
        mrm     08/12/93        union with COtools to hilite status display
                                button on the menu bar for Modify View Volume
*/

product_name    "$GRNUC"
class           COdynsetvw
super_class	COwindow
super_class     COtools
command_string  GRMModVwVol,6,GRMdVVl
synonym         GRMCvtPersParl,10,GRCPsPrTPl
synonym         GRMCvtParlPers,11,GRCPlPrTPs
status_display  "GRModViewVol","-1","-1"


start_state	strt_state

state_table

#include "dpdef.h"
#include "grmessage.h"
#include "codpdef.h"

specification

#include "FI.h"

instance
{
	IGRdouble	coi_pnt[3];
	IGRdouble	eye_pnt[3];
	IGRdouble	vup_pnt[3];
	IGRdouble 	vup_vec[3];
	IGRdouble	angle_radius;
	IGRdouble	vrp_pnt[3];
 	IGRdouble	depths[2];
	IGRdouble	near_pnt[3];
	IGRdouble	far_pnt[3];
	IGRdouble	proj_pt[3];
	IGRshort	input;
	IGRshort	dsp_on_off;
	IGRdouble	vpn_pnt[3];
	IGRdouble	vpn_vec[3];
	IGRint		state_flag;
	IGRint		form_flag;
	struct IGRdisplay *dis_attr[5];
	struct IGRdisplay solid;
	struct IGRdisplay dashed;	
	IGRboolean	vw_type_persp;
	IGRint 		cvt_flag;
	IGRint          dyn_state;
}


implementation

#include    <stdio.h>
#include    <FI.h>

#include    "dpstruct.h"
#include    "dp.h"
#include    "dperr.h"
#include    "dpdef.h"
#include    "grmessage.h"
#include    "msdef.h"
#include    "msmacros.h"
#include    "dpcodef.h"
#include    "dpcomacros.h"

%safe
/* dummy structure to allow DPdypyrm.h to compile without warnings */
struct dyn_pyrm_st
   {
      int    state1;
      int    status1;
   };

/* prototype files */
#include "dpexbell.h"

#include "marang2vc.h"
#include "maraddeg.h"
#include "macrossvc.h"
#include "madotvc.h"
#include "ma2ptdis.h"
#include "maptalln.h"
#include "maptln2di.h"
#include "masqrt.h"
#include "maptlnpro.h"

#include "DPdypyrm.h"
#include "DPordphigs.h"
#include "DPphigsord.h"
#include "DPcvtpersp.h"
#include "DPcal.h"
#include "DPsetpersp.h"
#include "DPsetinq.h"
#include "DPcodpbi.h"
%endsafe


#define 	DPCURPARAL 0x08078104
#define		DPCURPERSP 0x0807810C

#define 	SAV_CHK		1
#define		QUITX		4
#define		F_COI		12
#define		F_EYE		13
#define		F_UP		14
#define		F_ANGLE		15
#define		F_NEAR		16
#define		F_FAR		17
#define		F_VPN		18
#define		F_VRP		20
#define		F_NORM		21
#define		COI_NDX		0
#define		EYE_NDX		1
#define		UP_NDX		2
#define		ANGLE_NDX	3
#define		NEAR_NDX	4
#define		FAR_NDX		5
#define		VPN_NDX		6
#define		VRP_NDX		7
#define		NORM_NDX	8
#define 	FIRST_NOP	0x1000000

from IGEgragad	import DPupdate;


at init do dyninit

at sleep do status_display_button(0)

state *
    on EX_BACK_UP state -
    on EX_RESTART state strt_state
    on ERROR	state terminate

state strt_state

	on CMD_TYPE <= 5 state  persp
	on CMD_TYPE = 10 state cvtpar
	on CMD_TYPE = 11 state cvtper
	on CMD_TYPE = 6 state  modifyvw

state persp
    msg_key	GRC_M_SetVwPersp
	on CMD_TYPE <= 5 state default_gg

state modifyvw
    msg_key 	GRC_M_ModVwVol
    status_key  GR_I_ChOpStDiFo 
    execute     status_display_button(1)
	on CMD_TYPE = 6 state default_gg

state cvtpar
    msg_key	GRC_M_CvtPersParl
	on CMD_TYPE = 10 state id_gg

state cvtper
    msg_key 	GRC_M_CvtParlPers
	on CMD_TYPE = 11 state id_gg

state default_gg 
    prompt_key	GR_P_IdWinPar
    filter	get_event
 
    on EX_DATA or TEXT_VALUE do get_graphic_gadget(SrcGGid,1,ExstGG)
				on SrchFlt state default_gg
				on SUCCESS do default_setup 
					on SUCCESS do find_state state default_gg
					on ERROR or SEVERE or WARNING state terminate 
				state default_gg
				state default_gg
			
state get_coi
    prompt_key  GR_P_EntCenInts
    dynamics	DYN_COI_PNT
    filter	get_event
    on EX_DATA	do store_coi	do find_state
					state dest_gg
    on EX_RJT_MOVEON		do find_state
					state dest_gg
state get_eye_pnt
    prompt_key	GR_P_EntEyePt
    dynamics	DYN_EYE_PNT
    filter	get_event
    on EX_DATA	do store_eye_pnt 
		do find_state
 		    state dest_gg

    on EX_RJT_MOVEON  do find_state
			state dest_gg
/*
    on EX_DATA	
	on CMD_TYPE = 5 state get_angle
		do store_eye_pnt state get_vup

    on EX_RJT_MOVEON 
	on CMD_TYPE = 5 state get_angle
		state get_vup
*/
state get_vup
    prompt_key	GR_P_EntUpDir
    dynamics	DYN_UP
    filter	get_event
    on EX_DATA  do store_vup 
		do find_state	state dest_gg

    on EX_RJT_MOVEON do find_state state dest_gg

state get_angle
    prompt_key  GR_P_EntVwAng	
    dynamics	DYN_ANGLE
    filter	get_event
    on EX_DATA	do calc_angle	
		    on ERROR or SEVERE or WARNING 	state .
		    on SUCCESS do find_state    state dest_gg
		state dest_gg

    on ANGLE	do store_angle	
		    on ERROR or SEVERE or WARNING 	state .
		    on SUCCESS do find_state    state dest_gg
		state dest_gg
    on EX_RJT_MOVEON	do find_state	state dest_gg

state get_radius
    prompt_key	GR_P_EntPtDistVwVec
    dynamics	DYN_RADIUS
    filter	get_event
    on EX_DATA	do calc_radius
		do store_radius 
		do find_state state dest_gg

    on DISTANCE do store_radius  
		do find_state state dest_gg

    on EX_RJT_MOVEON	do find_state	state dest_gg
state get_near_depth
    prompt_key	GR_P_EntNrClpPl
    dynamics	DYN_NEAR
    filter	get_event
    on EX_DATA	do calc_dist
		do store_dist
		do find_state
		state dest_gg
    on DISTANCE	do store_dist
		do find_state
		state dest_gg

    on EX_RJT_MOVEON	do find_state	state dest_gg


state get_far_depth
    prompt_key	GR_P_EntFarClpPl
    dynamics	DYN_FAR
    filter	get_event
    on EX_DATA	do calc_dist
		do store_far_dist 
		    on ERROR or SEVERE or WARNING state .
		    on SUCCESS	do find_state state dest_gg
		state dest_gg
    on DISTANCE	do store_far_dist 
		do find_state
		state dest_gg
    on EX_RJT_MOVEON	do find_state
			state dest_gg
state normal
    prompt_key GR_P_ProjPlnSame
    filter  get_event
    on EX_STRING = "y" do norm_vwvec state dest_gg
    on EX_STRING = "n" state get_vrp


state get_vrp
    prompt_key GR_P_EntVwRefPt
    dynamics	DYN_VRP
    filter	get_event
    on EX_DATA	do store_vrp	do find_state state dest_gg
    on EX_RJT_MOVEON  do find_state  state dest_gg

state get_vpn_pnt
    prompt_key	GR_P_EntVwPlNormPt
    dynamics	DYN_VPN
    filter	get_event
    on EX_DATA	do store_vpn  do find_state state dest_gg
    on EX_RJT_MOVEON	do find_state state dest_gg

state dest_gg
    prompt_key	GR_P_IdDesWin
    filter	get_event
    on EX_DATA or TEXT_VALUE do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
				on SrchFlt state dest_gg
				on SUCCESS do set_view
					on SUCCESS state dest_gg
					on ERROR or SEVERE or WARNING state terminate
				    state dest_gg
			state dest_gg

state id_gg
    prompt_key	GR_P_IdWin
    filter	get_event
    on EX_DATA or TEXT_VALUE do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
				on SrchFlt state id_gg
				on SUCCESS do cvt
					on SUCCESS state id_gg
					on ERROR or SEVERE or WARNING state terminate
				    state id_gg
			state dest_gg


action find_state
{
    me->ret = 0;

    if (me->state_flag & DYN_COI_PNT && me->state < _get_coi)
    {
	me->next_state = _get_coi;
    }
    else if (me->state_flag & DYN_EYE_PNT && me->state < _get_eye_pnt)
    {
	me->next_state = _get_eye_pnt;
    }
    else if (me->state_flag & DYN_UP && me->state < _get_vup)
    {
	me->next_state = _get_vup;
    }
    else if (me->state_flag & DYN_ANGLE && me->state < _get_angle && me->vw_type_persp)
    {
	me->next_state = _get_angle;
    }
    else if (me->state_flag & DYN_RADIUS && me->state < _get_radius && !me->vw_type_persp)
    {
	me->next_state = _get_radius;
    }
    else if (me->state_flag & DYN_NEAR && me->state < _get_near_depth)
    {
	me->next_state = _get_near_depth;
    }
    else if (me->state_flag & DYN_FAR && me->state < _get_far_depth)
    {
	me->next_state = _get_far_depth;
    }
    else if (me->state_flag & DYN_VRP && me->state < _get_vrp)
    {
	me->next_state = _get_vrp;
    }
    else if (me->state_flag & DYN_NORMAL && me->state < _get_vpn_pnt)
    {
	me->next_state = _get_vpn_pnt;
    }
}


action dynamics
{
    IGRint display_state;
    IGRlong msg;

    if (me->mytype <= 6 && me->vw_type_persp)
    {
    	display_state =0;
    }
    else
    {
    	display_state = DYN_PARALLEL_P;
    }

    me->dyn_state = dynamics;
    switch (dynamics)
    {
    	case DYN_COI_PNT:
	    display_state |= DYN_COI_PNT | DYN_PY_NO_TRUN | DYN_VIEW_VECTOR;
	    me->dis_attr[0] = &me->dashed;
	    me->dis_attr[1] = &me->solid;
	break;

    	case DYN_EYE_PNT:
	    display_state |= DYN_EYE_PNT | DYN_PY_NO_TRUN | DYN_VIEW_VECTOR;
	    me->dis_attr[0] = &me->dashed;
	    me->dis_attr[1] = &me->solid;
	break;

    	case DYN_UP:
	    display_state |= DYN_UP | DYN_PY_NO_TRUN | DYN_VIEW_VECTOR | DYN_VUP;
	    me->dis_attr[0] = &me->dashed;
	    me->dis_attr[1] = &me->dashed;
	    me->dis_attr[2] = &me->solid;
	break;

	case DYN_ANGLE:
	    display_state |= DYN_ANGLE | DYN_PY_NO_TRUN | DYN_VIEW_VECTOR;
	    me->dis_attr[0] = &me->solid;
	    me->dis_attr[1] = &me->dashed;
	break;

	case DYN_RADIUS:
	    display_state |= DYN_RADIUS | DYN_PY_NO_TRUN | DYN_VIEW_VECTOR;
	    me->dis_attr[0] = &me->solid;
	    me->dis_attr[1] = &me->dashed;
	break;

	case DYN_NEAR:
	    display_state |= DYN_NEAR | DYN_PY_TRUN_NEAR | DYN_VIEW_VECTOR;
	    me->dis_attr[0] = &me->solid;
	    me->dis_attr[1] = &me->dashed;
	break;

	case DYN_FAR:
	    display_state |= DYN_FAR | DYN_PY_TRUN_NEAR_FAR | DYN_VIEW_VECTOR;
	    me->dis_attr[0] = &me->solid;
	    me->dis_attr[1] = &me->dashed;
	break;

	case DYN_VRP:
	    display_state |= DYN_VRP | DYN_PY_TRUN_NEAR_FAR | DYN_VIEW_VECTOR | DYN_PROJ_PLANE | DYN_NORMAL;
	    me->dis_attr[0] = &me->dashed;
	    me->dis_attr[1] = &me->dashed;
	    me->dis_attr[3] = &me->solid;
	    me->dis_attr[4] = &me->solid;
	break;

    	case DYN_VPN:
	    display_state |= DYN_VPN | DYN_PY_TRUN_NEAR_FAR | DYN_VIEW_VECTOR | DYN_PROJ_PLANE | DYN_NORMAL;
	    me->dis_attr[0] = &me->dashed;
	    me->dis_attr[1] = &me->dashed;
	    me->dis_attr[3] = &me->solid;
	    me->dis_attr[4] = &me->solid;
	break;	
    }
    MA2ptdis ( &msg, me->eye_pnt, me->near_pnt, &me->depths[0] );
    MA2ptdis ( &msg, me->eye_pnt, me->far_pnt, &me->depths[1] );
    DPdypyrminit ( me->dsp_on_off, display_state, me->dis_attr,
	me->coi_pnt, me->eye_pnt, me->vup_pnt, &me->angle_radius, &me->depths[0],
	&me->depths[1], me->vrp_pnt, me->vpn_pnt );
}

action dyninit
{
	IGRshort mvv_flags;

	dp$codpb_get_mvv_flags( mvv_flags = (IGRushort *)&mvv_flags );
	me->state_flag = mvv_flags;

	me->form_flag=0;
	if (me->state_flag & MVV_CHANGE_VRP) me->form_flag|=DYN_VRP;
	if (me->state_flag & MVV_CHANGE_VPN) me->form_flag|=DYN_VPN;
	if (me->state_flag & MVV_CHANGE_EYE) me->form_flag|=DYN_EYE_PNT;
	if (me->state_flag & MVV_CHANGE_COI) me->form_flag|=DYN_COI_PNT;
	if (me->state_flag & MVV_CHANGE_UP) me->form_flag|=DYN_UP;
	if (me->state_flag & MVV_CHANGE_ANGLE) me->form_flag|=(DYN_ANGLE|DYN_RADIUS);
	if (me->state_flag & MVV_CHANGE_NEAR) me->form_flag|=DYN_NEAR;
	if (me->state_flag & MVV_CHANGE_FAR) me->form_flag|=DYN_FAR;
	me->state_flag = me->form_flag;

	me->vw_type_persp = TRUE;

}


action status_disp
{

    IGRshort num_to_erase=2;

if ( me->mytype <= 6 )
{
	num_to_erase = 2;
	if (!me->vw_type_persp)
	{
      FIg_set_state_off(me->status_display_form_ptr, F_VPN);
	}

	if ((!(me->form_flag & DYN_VPN)) || !me->vw_type_persp)
	{
      FIg_erase(me->status_display_form_ptr, F_VRP);
      FIg_erase(me->status_display_form_ptr, F_NORM);
	}

	if (me->form_flag & DYN_COI_PNT)
	{
      FIg_set_state_on(me->status_display_form_ptr, F_COI);
	}
	else
	{
      FIg_set_state_off(me->status_display_form_ptr, F_COI);
	}

	if (me->form_flag & DYN_EYE_PNT)
	{
      FIg_set_state_on(me->status_display_form_ptr, F_EYE);
	}
	else
	{
      FIg_set_state_off(me->status_display_form_ptr, F_EYE);
	}

	if (me->form_flag & DYN_UP)
	{
      FIg_set_state_on(me->status_display_form_ptr, F_UP);
	}
	else
	{
      FIg_set_state_off(me->status_display_form_ptr, F_UP);
	}

	if (me->form_flag & DYN_ANGLE || me->form_flag & DYN_RADIUS)
	{
      FIg_set_state_on(me->status_display_form_ptr, F_ANGLE);
	}
	else
	{
      FIg_set_state_off(me->status_display_form_ptr, F_ANGLE);
	}

	if (me->form_flag & DYN_NEAR)
	{
      FIg_set_state_on(me->status_display_form_ptr, F_NEAR);
	}
	else
	{
      FIg_set_state_off(me->status_display_form_ptr, F_NEAR);
	}

	if (me->form_flag & DYN_FAR)
	{
      FIg_set_state_on(me->status_display_form_ptr, F_FAR);
	}
	else
	{
      FIg_set_state_off(me->status_display_form_ptr, F_FAR);
	}

	om$send(msg = message CEO.status_disp (),
            targetid = my_id,
            mode = OM_e_wrt_message);

}  /* end if */

}


action form_notification
{
  int      msg;
  IGRint   ck_state, ck_state2;
  IGRshort mvv_flags;

  switch(gadget_label)
  {
	case F_VPN:
		FIg_get_state(form_ptr, F_VPN, &ck_state);

		if (ck_state == 1)
	    {
			if (me->vw_type_persp)
			{
				me->form_flag |= DYN_VPN;
				FIg_display(form_ptr, F_VRP);
				FIg_display(form_ptr, F_NORM);
			}
			else
			{
				ex$message(msgnumb = GR_E_NmNtPlV);

				FIg_set_state_off(form_ptr, F_VPN);
				FIg_set_state_off(form_ptr, F_VRP);
				FIg_set_state_off(form_ptr, F_NORM);

				FIg_erase(form_ptr, F_VRP);
				FIg_erase(form_ptr, F_NORM);
			}
	    }
	    else
	    {
			FIg_erase(form_ptr, F_VRP);
			FIg_erase(form_ptr, F_NORM);
	    }
	    break;


	case F_VRP:
		FIg_get_state(form_ptr, F_VRP, &ck_state);

		if (ck_state == 1)
		{
			me->form_flag |= DYN_VRP;
		}
		else
		{
		    me->form_flag &= ~DYN_VRP;

			FIg_get_state(form_ptr, F_NORM, &ck_state2);

   		    if (ck_state2 == 0)
		    {
				FIg_erase(form_ptr, F_VRP);
				FIg_erase(form_ptr, F_NORM);
				FIg_set_state_off(form_ptr, F_VPN);
		    }
		}
		break;


	case F_NORM:
		FIg_get_state(form_ptr, F_NORM, &ck_state);

		if (ck_state == 1)
		{
		    me->form_flag |= DYN_NORMAL;
		}
		else
		{
		    me->form_flag &= ~DYN_NORMAL;

			FIg_get_state(form_ptr, F_VRP, &ck_state2);

   		    if (ck_state2 == 0)
		    {
				FIg_erase(form_ptr, F_VRP);
				FIg_erase(form_ptr, F_NORM);
				FIg_set_state_off(form_ptr, F_VPN);
		    }
		}
   	    break;

/* put the rest in */

	case SAV_CHK:
		FIg_get_state(form_ptr, F_COI, &ck_state);
		if (ck_state == 1)
		{
		    me->form_flag |= DYN_COI_PNT;
		}
		else
		{
		    me->form_flag &= ~DYN_COI_PNT;
		}

        FIg_get_state(form_ptr, F_EYE, &ck_state);
		if (ck_state == 1)
		{
		    me->form_flag |= DYN_EYE_PNT;
		}
		else
		{
		    me->form_flag &= ~DYN_EYE_PNT;
		}

        FIg_get_state(form_ptr, F_UP, &ck_state);
        if (ck_state == 1)
		{
		    me->form_flag |= DYN_UP;
		}
		else
		{
		    me->form_flag &= ~DYN_UP;
		}

        FIg_get_state(form_ptr, F_ANGLE, &ck_state);
        if (ck_state == 1)
		{
		    me->form_flag |= DYN_ANGLE;
		    me->form_flag |= DYN_RADIUS;
		}
		else
		{
		    me->form_flag &= ~DYN_ANGLE;
		    me->form_flag &= ~DYN_RADIUS;
		}

        FIg_get_state(form_ptr, F_NEAR, &ck_state);
        if (ck_state == 1)
		{
			me->form_flag |= DYN_NEAR;
		}
		else
		{
			me->form_flag &= ~DYN_NEAR;
		}

        FIg_get_state(form_ptr, F_FAR, &ck_state);
        if (ck_state == 1)
		{
		    me->form_flag |= DYN_FAR;
		}
		else
		{
		    me->form_flag &= ~DYN_FAR;
		}

        FIg_get_state(form_ptr, F_VPN, &ck_state);
        if (ck_state == 1)
		{
		    me->form_flag |= DYN_VPN;
		}
		else
		{
		    me->form_flag &= ~DYN_VRP;
		    me->form_flag &= ~DYN_VPN;
		    me->form_flag &= ~DYN_NORMAL;
		}

        FIg_get_state(form_ptr, F_VRP, &ck_state);
        if (ck_state == 1)
		{
		    me->form_flag |= DYN_VRP;
		}
		else
		{
		    me->form_flag &= ~DYN_VRP;
		}

        FIg_get_state(form_ptr, F_NORM, &ck_state);
        if (ck_state == 1)
		{
		    me->form_flag |= DYN_NORMAL;
		}
		else
		{
			FIg_get_state(form_ptr, F_VRP, &ck_state);
		    if (ck_state == 0)
		    {
		    	me->form_flag &= ~DYN_VPN;
		    }
		    me->form_flag &= ~DYN_NORMAL;
		}

	    /* double checks for both accounts */

	    if (!(me->form_flag & DYN_VPN))
	    {
	        me->form_flag &= ~DYN_VRP;
	        me->form_flag &= ~DYN_NORMAL;
			FIg_set_state_off(form_ptr, F_VPN);
	    }

	    me->state_flag = 0;
	    if (me->form_flag & DYN_VRP) me->state_flag|=MVV_CHANGE_VRP;
	    if (me->form_flag & DYN_VPN) me->state_flag|=MVV_CHANGE_VPN;
	    if (me->form_flag & DYN_EYE_PNT) me->state_flag|=MVV_CHANGE_EYE;
	    if (me->form_flag & DYN_COI_PNT) me->state_flag|=MVV_CHANGE_COI;
	    if (me->form_flag & DYN_UP) me->state_flag|=MVV_CHANGE_UP;
	    if (me->form_flag & (DYN_ANGLE|DYN_RADIUS)) me->state_flag|=MVV_CHANGE_ANGLE;
	    if (me->form_flag & DYN_NEAR) me->state_flag|=MVV_CHANGE_NEAR;
	    if (me->form_flag & DYN_FAR) me->state_flag|=MVV_CHANGE_FAR;
	    mvv_flags = me->state_flag;
	    dp$codpb_set_mvv_flags( mvv_flags = mvv_flags );
	    me->state_flag = me->form_flag;
	    om$send(msg = message CEO.erase_form_by_label(form_label, 1, &msg),
				targetid = my_id);
	    me->form_requested = 0;
		break;


	case QUITX:
		me->form_flag = me->state_flag;
		om$send(msg = message CEO.erase_form_by_label(form_label, 1, &msg),
				targetid = my_id);
		me->form_requested = 0;
		break;


	default:
		break;
 
  }  /* end switch */

    om$send(msg = message COdynsetvw.dynamics(me->dyn_state,&msg),
			targetid = my_id);

}


action default_setup
{
    IGRlong ret_bytes;
    IGRlong msg;
    IGRshort ret_flags;
    IGRshort direction = 1;
    struct var_list inq_list[4];
    IGRdouble act_z;
    IGRdouble new_z;
    IGRdouble vw_vol[6];
    IGRdouble wld_to_view[16];
    IGRlong which_error;
    IGRint gg_flag;
    struct IGRline line;
    
	inq_list[0].var = GRAGAD_FLAGS;
	inq_list[0].var_ptr = (IGRchar *)&gg_flag;
	inq_list[0].num_bytes = sizeof(IGRint);
	inq_list[0].bytes_returned = &ret_bytes;

	inq_list[1].var = END_PARAM;
	status = dp$inq_set_gragad(msg= &msg,
 					osnum=me->source_id.osnum,
					gragad_objid= me->source_id.objid,
					which_error= &which_error,
					var_list=inq_list);
    	if( ! (1 & status) )
	{
	    *sts = status;
#ifdef DEBUG
	    printf("\nIn rename inquire_gragad failed\n");
#endif
	 }

	if (gg_flag & IS_PERSP || me->mytype != 6)
	{
	    me->vw_type_persp = TRUE;
	}
	else
	{
	    me->vw_type_persp = FALSE;
	    me->form_flag |= FIRST_NOP;
            me->form_flag &= ~DYN_VRP;
            me->form_flag &= ~DYN_NORMAL;
            me->form_flag &= ~DYN_VPN;
	}
    if (me->vw_type_persp)
    {
    	status = dp$set_persp( msg = &msg, gg_id = &me->source_id, 
		in_flags = 0,
		ret_flags = &ret_flags,
		r_eye_pt = me->eye_pnt, r_coi= me->coi_pnt,
		r_vw_angle = &me->angle_radius, r_near = &me->depths[0],
		r_far = &me->depths[1], r_vup = me->vup_vec, 
		r_vpn = me->vpn_vec, r_vrp = me->vrp_pnt);
	line.point1 = me->eye_pnt;
	line.point2 = me->coi_pnt;
	MAptalln (&msg, &line, me->eye_pnt, &direction, &me->depths[0], me->near_pnt);
	MAptalln (&msg, &line, me->eye_pnt, &direction, &me->depths[1], me->far_pnt);
    }
    else
    {
	inq_list[0].var = VW_VOLUME;
	inq_list[0].var_ptr = (IGRchar *)vw_vol;
	inq_list[0].num_bytes = sizeof(IGRdouble) *6;
	inq_list[0].bytes_returned = &ret_bytes;

	inq_list[1].var = ACT_Z;
	inq_list[1].var_ptr = (IGRchar *)&act_z;
	inq_list[1].num_bytes = sizeof(IGRdouble);
	inq_list[1].bytes_returned = &ret_bytes;

	inq_list[2].var = WLD_TO_VIEW;
	inq_list[2].var_ptr = (IGRchar *)wld_to_view;
	inq_list[2].num_bytes = sizeof(IGRdouble)*16;
	inq_list[2].bytes_returned = &ret_bytes;

	inq_list[3].var = END_PARAM;

	status = dp$inq_set_gragad(msg= &msg,
 					osnum=me->source_id.osnum,
					gragad_objid= me->source_id.objid,
					which_error= &which_error,
					var_list=inq_list);
    	if( ! (1 & status) )
	{
	    *sts = status;
#ifdef DEBUG
	    printf("\nIn rename inquire_gragad failed\n");
#endif
	 }

	status = DPordphigs(&msg,0,vw_vol,&act_z,wld_to_view,
			me->vrp_pnt, me->vpn_vec, me->vup_vec,
			me->eye_pnt, me->coi_pnt, &me->angle_radius,
			&me->depths[0],	&me->depths[1], &new_z);
	line.point1 = me->eye_pnt;
	line.point2 = me->coi_pnt;
	MAptalln (&msg, &line, me->eye_pnt, &direction, &me->depths[0], me->near_pnt);
	MAptalln (&msg, &line, me->eye_pnt, &direction, &me->depths[1], me->far_pnt);
    }

    me->vup_pnt[0] = me->vup_vec[0] + me->coi_pnt[0];
    me->vup_pnt[1] = me->vup_vec[1] + me->coi_pnt[1];
    me->vup_pnt[2] = me->vup_vec[2] + me->coi_pnt[2];

    me->vpn_pnt[0] = me->vpn_vec[0] + me->vrp_pnt[0];
    me->vpn_pnt[1] = me->vpn_vec[1] + me->vrp_pnt[1];
    me->vpn_pnt[2] = me->vpn_vec[2] + me->vrp_pnt[2];

    me->dsp_on_off = 1;

    /* solid line */
	me->solid.color = 2;
	me->solid.weight = 0;
	me->solid.style = 0;

	/* dashed line */
	me->dashed.color = 2;
	me->dashed.weight = 0;
	me->dashed.style = 1;

}

action store_coi
{
    me->coi_pnt[0] = me->event1.event.button.x;
    me->coi_pnt[1] = me->event1.event.button.y;
    me->coi_pnt[2] = me->event1.event.button.z;

/* should I assume that they want the vrp to be the same as the coi
	if so then I need to reinitalize the vrp here. */

    me->vup_pnt[0] = me->vup_vec[0] + me->coi_pnt[0];
    me->vup_pnt[1] = me->vup_vec[1] + me->coi_pnt[1];
    me->vup_pnt[2] = me->vup_vec[2] + me->coi_pnt[2];

}
action store_eye_pnt
{
    me->eye_pnt[0] = me->event1.event.button.x;
    me->eye_pnt[1] = me->event1.event.button.y;
    me->eye_pnt[2] = me->event1.event.button.z;
}
/* should I assume that the user wants the vpn point to be the 
	same as the eye point
	if so then I need to have a def_vpn_pnt action that is 
	called from move on and data to (re)initalize the vpn
	here. */

action store_vup
{
    me->vup_pnt[0] = me->event1.event.button.x;
    me->vup_pnt[1] = me->event1.event.button.y;
    me->vup_pnt[2] = me->event1.event.button.z;
}

action calc_angle
{
    IGRdouble	pnt[3];
    IGRdouble	angle;
    IGRdouble	deg_angle;
    IGRlong	msg;
    IGRdouble	vec1[3];
    IGRdouble	vec2[3];
    IGRdouble 	cross_vec[3];
    IGRdouble    dot_prod;

    pnt[0] = me->event1.event.button.x;
    pnt[1] = me->event1.event.button.y;
    pnt[2] = me->event1.event.button.z;

	vec1[0] = me->coi_pnt[0] - me->eye_pnt[0];
	vec1[1] = me->coi_pnt[1] - me->eye_pnt[1];
	vec1[2] = me->coi_pnt[2] - me->eye_pnt[2];

	vec2[0] = pnt[0] - me->eye_pnt[0];
	vec2[1] = pnt[1] - me->eye_pnt[1];
	vec2[2] = pnt[2] - me->eye_pnt[2];

	status = MAcrossvc (&msg, vec1, vec2, cross_vec);
	if (status == FALSE)
	{
	    goto quit;
/*
	    ex$message(msgnumb = GR_E_InvAng);
*/
	}
	status = MArang2vc (&msg, vec1, vec2, cross_vec, &angle);
	if (status == FALSE)
	{
	    goto quit;
/*	    ex$message(msgnumb = GR_E_InvAng); */
	}
    	status = MAdotvc(&msg,vec1,vec2,&dot_prod);
	if (status == FALSE)
    	{
	    goto quit;
    	}
	status = MAraddeg(&msg,&angle,&deg_angle);	
	if (status == FALSE)
	{
	    goto quit;
/*	    ex$message(msgnumb = GR_E_InvAng); */
	}
	deg_angle = deg_angle * 2.0;
	if (deg_angle == 0)
	{
    		me->ret = DPAng0;
	    	ex$message(msgnumb = GR_E_AngGreatDeg);
	}
	else if ((dot_prod < 0) || (deg_angle >= 180))
	{
	    	me->ret = DPAng180;
	    	ex$message(msgnumb = GR_E_AngSmalDeg);
		me->angle_radius = 3.141;
	}
    	else
	{
		ex$message(msgnumb = GR_I_AngEq,
			type="%f",
			var=`deg_angle`);
   	    me->angle_radius = angle * 2;
	}
    sleep(3);

}
action calc_radius
{
    IGRdouble pnt[3];
    struct IGRline view_vec;
    IGRlong msg;


    pnt[0] = me->event1.event.button.x;
    pnt[1] = me->event1.event.button.y;
    pnt[2] = me->event1.event.button.z;

    view_vec.point1 = me->eye_pnt;
    view_vec.point2 = me->coi_pnt;

    status = MAptln2dis (&msg, pnt, &view_vec,&me->event1.event.value);
    me->event1.event.value = MAsqrt(&msg,&me->event1.event.value);
}
action store_radius
{
    me->angle_radius = me->event1.event.value;
}
action store_angle
{

    IGRdouble	deg_angle;
    IGRlong	msg;

	MAraddeg(&msg,&me->event1.event.value,&deg_angle);	

	if (deg_angle == 0 )
	{
    		me->ret = DPAng0;
	    	ex$message(msgnumb = GR_E_AngGreatDeg);
	}
	else if (deg_angle >= 180)
	{
	    	me->ret = DPAng180;
	    	ex$message(msgnumb = GR_E_AngSmalDeg);
	}
	else
	{
	    me->angle_radius = me->event1.event.value;
	}
    	sleep(3);
}
action calc_dist
{
    struct IGRline	line;
    IGRdouble		t;
    IGRlong		msg;
    IGRdouble		pnt[3];

    pnt[0] = me->event1.event.button.x;
    pnt[1] = me->event1.event.button.y;
    pnt[2] = me->event1.event.button.z;

    line.point1 = me->eye_pnt;
    line.point2 = me->coi_pnt;

    MAptlnproj ( &msg, pnt, &line, me->proj_pt, &t );
    if (t <= 0)
    {
	me->event1.event.value = 0;
    }
    else
    {
    	MA2ptdis ( &msg, me->eye_pnt, me->proj_pt, &me->event1.event.value);
    }
}

action store_dist
{
    struct IGRline line;
    IGRshort direction = 1;
    IGRlong msg;

    me->depths[0] = me->event1.event.value;
    if (me->event1.response == EX_VALUE)
    {
	line.point1 = me->eye_pnt;
	line.point2 = me->coi_pnt;
	MAptalln (&msg, &line, me->eye_pnt, &direction, &me->depths[0], me->near_pnt);
    }
    else
    {	
    	me->near_pnt[0] = me->proj_pt[0];
    	me->near_pnt[1] = me->proj_pt[1];
    	me->near_pnt[2] = me->proj_pt[2];
    }
}

action store_far_dist
{
    IGRlong msg;
    struct IGRline line;
    IGRshort direction = 1;

    if (me->event1.event.value == 0 && me->depths[0] == 0 && me->depths[1] !=0)
    {
	/* use the depth already stored */
	line.point1 = me->eye_pnt;
	line.point2 = me->coi_pnt;
	MAptalln (&msg, &line, me->eye_pnt, &direction, &me->depths[1], me->far_pnt);
    }
    else if (me->event1.event.value == me->depths[0])
    {
	me->ret = DPFarEqNear;
	ex$message(msgnumb = GR_E_ErrFarDepEqNr);
    }
    else
    {
    	me->depths[1] = me->event1.event.value;
    	if (me->event1.response == EX_VALUE)
    	{
	    line.point1 = me->eye_pnt;
	    line.point2 = me->coi_pnt;
	    MAptalln (&msg, &line, me->eye_pnt, &direction, &me->depths[1], me->far_pnt);
    	}
	else
	{
	    me->far_pnt[0] =  me->proj_pt[0];
	    me->far_pnt[1] =  me->proj_pt[1];
	    me->far_pnt[2] =  me->proj_pt[2];
	}
    }
}

action norm_vwvec
{
    me->vrp_pnt[0] = me->coi_pnt[0];
    me->vrp_pnt[1] = me->coi_pnt[1];
    me->vrp_pnt[2] = me->coi_pnt[2];

    me->vpn_pnt[0] = me->eye_pnt[0];
    me->vpn_pnt[1] = me->eye_pnt[1];
    me->vpn_pnt[2] = me->eye_pnt[2];
}
    
action store_vrp
{
    me->vrp_pnt[0] = me->event1.event.button.x;
    me->vrp_pnt[1] = me->event1.event.button.y;
    me->vrp_pnt[2] = me->event1.event.button.z;
}

action store_vpn
{
    me->vpn_pnt[0] = me->event1.event.button.x;
    me->vpn_pnt[1] = me->event1.event.button.y;
    me->vpn_pnt[2] = me->event1.event.button.z;
}

action set_view
{

    IGRshort idx;
    IGRshort phigs_ord_flag;
    IGRlong		msg;
    IGRlong		ret_bytes;
    IGRlong		which_error;
    IGRint		gg_flag;
    struct var_list     lister[5];
    IGRdouble		act_z;
    IGRdouble		vw_vol[6];
    IGRdouble 		rotation[16];
    IGRdouble		origin[3];
    IGRdouble		vpn[3];
    IGRdouble		vup[3];
    IGRboolean		flag = FALSE;

    vup[0] = me->vup_pnt[0] - me->coi_pnt[0];
    vup[1] = me->vup_pnt[1] - me->coi_pnt[1];
    vup[2] = me->vup_pnt[2] - me->coi_pnt[2];

    if (!(me->form_flag & DYN_VPN))
    {
	vpn[0] = me->coi_pnt[0] - me->eye_pnt[0];
	vpn[1] = me->coi_pnt[1] - me->eye_pnt[1];
	vpn[2] = me->coi_pnt[2] - me->eye_pnt[2];	
	
	me->vrp_pnt[0] = me->coi_pnt[0];
	me->vrp_pnt[1] = me->coi_pnt[1];
	me->vrp_pnt[2] = me->coi_pnt[2];
    }
    else
    {
    	vpn[0] = me->vpn_pnt[0] - me->vrp_pnt[0];
    	vpn[1] = me->vpn_pnt[1] - me->vrp_pnt[1];
    	vpn[2] = me->vpn_pnt[2] - me->vrp_pnt[2];
    }
    MA2ptdis ( &msg, me->eye_pnt, me->near_pnt, &me->depths[0] );
    MA2ptdis ( &msg, me->eye_pnt, me->far_pnt, &me->depths[1] );

    for (idx = 0; idx < me->num_id; idx++)
    {
	lister[0].var = GRAGAD_FLAGS;
	lister[0].var_ptr = (IGRchar *)&gg_flag;
	lister[0].num_bytes = sizeof(IGRint);
	lister[0].bytes_returned = &ret_bytes;

	lister[1].var = END_PARAM;
	status = dp$inq_set_gragad(msg= &msg,
 					osnum=me->ggid[idx].osnum,
					gragad_objid=me->ggid[idx].objid,
					which_error= &which_error,
					var_list=lister);
    	if( ! (1 & status) )
	{
	    *sts = status;
#ifdef DEBUG
	    printf("\nIn rename inquire_gragad failed\n");
#endif
	}
	if (me->vw_type_persp)
	{
	    if (me->mytype == 6)
	    {
	    	if (!(gg_flag & IS_PERSP))
	    	{
		    EX_bell();
		    ex$message(msgnumb = GR_E_SrDsVPs);
		    break;
		}
	    }
    	    status = dp$set_persp ( msg = &me->ret,
		   gg_id = &me->ggid[idx],
		   in_flags = DP_SET,
		   vup = vup,
		   vrp = me->vrp_pnt,
		   vpn = vpn,
		   eye_pt = me->eye_pnt,
		   coi = me->coi_pnt,
		   vw_angle = &me->angle_radius,
		   near = &me->depths[0],
		   far = &me->depths[1] );
    	    if (me->ret == DPVUPPRLVPN)
    	    {
	    	ex$message (msgnumb = GR_E_ErrEncCmdRst);
            }
	}
	else
	{
	    if (gg_flag & IS_PERSP)
	    {
		EX_bell();
		ex$message(msgnumb = GR_E_SrDsVPl);
		break;
	    }
            phigs_ord_flag = 0;
	    status = DPphigsord ( &me->ret,phigs_ord_flag,me->vrp_pnt,
				vpn,vup,me->eye_pnt,
				me->coi_pnt, &me->angle_radius,
				&me->depths[0],&me->depths[1],
				vw_vol,&act_z,rotation,origin);

	lister[0].var = VW_VOLUME;
	lister[0].var_ptr = (IGRchar *)vw_vol;
	lister[0].num_bytes = sizeof(IGRdouble) *6;
	lister[0].bytes_returned = &ret_bytes;

	lister[1].var = VIEW_ROTATION;
	lister[1].var_ptr = (IGRchar *)rotation;
	lister[1].num_bytes = sizeof(IGRdouble)*16;
	lister[1].bytes_returned = &ret_bytes;

	lister[2].var = VIEW_ORIGIN;
	lister[2].var_ptr = (IGRchar *)origin;
	lister[2].num_bytes = sizeof(IGRdouble)*3;
	lister[2].bytes_returned = &ret_bytes;

	lister[3].var = END_PARAM;

	status = dp$inq_set_gragad(msg= &msg,
				    inq0_set1=1,
 					osnum=me->ggid[idx].osnum,
					gragad_objid= me->ggid[idx].objid,
					which_error= &which_error,
					var_list=lister);
    	if( ! (1 & status) )
	{
	    *sts = status;
#ifdef DEBUG
	    printf("\nIn rename inquire_gragad failed\n");
#endif
	    goto fini;
	 }
	    status = dp$calc_gragad_info(msg = &msg,osnum = me->ggid[0].osnum,
					gragad_objid = me->ggid[0].objid);
	    if (!status &1)
	    {
#ifdef DEBUG
		printf("\ndp$cal failed\n");
#endif
		goto fini;
	    }
	} /* close for else */
    	if (status & 1)
    	{
    		status = om$send ( msg = message IGEgragad.DPupdate ( &msg,
					NULL, &flag ),
		   targetid = me->ggid[idx].objid,
		   targetos = me->ggid[idx].osnum );
        }
    } /* close for for */
fini:
;
}

action cvt
{

IGRlong msg;
IGRshort idx;

if (me->mytype == 10)
{
    me->cvt_flag = DP_CVT_TO_PARAL;
}
else if (me->mytype == 11)
{
    me->cvt_flag = DP_CVT_TO_PERSP;
}
me->cvt_flag |= DP_CAL | DP_CVT_UPDATE;
for (idx = 0; idx < me->num_id; idx++)
{
    status = DPcvtpersp(&msg,&me->ggid[idx],me->cvt_flag);
    if (!(status & 1))
    {
	if (msg == DPCURPERSP)
	{
	    ex$message(msgnumb = GR_E_VCrPs);
	}
	else if (msg == DPCURPARAL)
	{
	    ex$message(msgnumb = GR_E_VCrPl);
	}
	else
	{
#ifdef DEBUG
	    printf("\nDPcvtpersp failed\n");
#endif
	}
    }
}

}
