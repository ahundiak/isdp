product_name	"$GRNUC"
super_class         COtools
super_class         CEO_GSLOCATE
class 		COfillobj
command_string  GRC_M_CFlMdE,0,GRCFlMdE
start_state	strt_state

specification

instance
{
	IGRshort what_mode;
}

implementation

#include     <stdio.h>
#include     "grdpbmacros.h"
#include     "dpmacros.h"
#include     "godef.h"
#include     "execmsg.h"
#include     "grmessage.h"

%safe
#include "GRgs_fun.h"
#include "GRdpbfunc.h"
%endsafe

from GRgraphics import GRchgprops, GRgetprops;

state_table


#include "cochindex.h"
#include "comndef.h"
#include "grmessage.h"

at sleep
    do COtools.erase_highlight ()

at init
    do getdpb_props()

state   *
	
	on EX_RESTART  state strt_state
	on EX_BACK_UP  state -

state   strt_state

    msg_key     GRC_M_CFlMdE
    prompt_key  GR_P_EntNwFlMd
    filter      get_event

    on EX_STRING 
	do setfill_type
        on SUCCESS
	    state locate_elem
	on WARNING or ERROR
	    state strt_state
	state .

    on EX_RJT_MOVEON  state locate_elem


state  locate_elem
    prompt_key	GR_P_IdEle
    locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                           ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT |
                           LC_ERASE_ALL | LC_ACCEPT_CURSOR"
    locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_NEW_MOD | LC_PLANAR_NON_PLANAR"
    prompt_key GR_P_IdEle
    accept_key GR_P_Acc
    relocate_key GR_E_EleNotFnd
    gslocate_spec_prompt1_key GR_P_AccFnc
    gslocate_num_inputs 1
    locate_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE | GRm_BACK_UP"
    accept_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    gslocate_spec_mask1 "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    locate_eligible "-+GRrg"
    locate_owner "LC_NON_GEOM_MOD"
    filter gs_locate_noauto
            on EX_DATA or EX_OBJID or EX_STRING
                do display_mode GRbehe
                do display_located
                do obj_fill
                    on SUCCESS
                        do COtools.push_event (&me->event1)
                        do display_mode GRbd
                        do display_located
                        do disconnect_located 1
                        state .
                    on WARNING or ERROR
                        do disconnect_located 1
                        do status_key GR_E_ErrEncCmdRst
			state .
		state .


action getdpb_props
{
	IGRint      msg;
	IGRint      nret;
	IGRint      sizbuf;
	unsigned short   prop_wrd;

/* Get DPB's poperties word   */

        sizbuf = sizeof(unsigned short);
	status = gr$get_active_prop(msg=&msg,
	 		   	    sizbuf=&sizbuf,
			   	    buffer=(IGRchar *)&prop_wrd,
                           	    nret=&nret);
	if((msg == MSFAIL) || (!(status & 1)))
        {
#ifdef DEBUG
		om$report_error(sts = status);
		printf("\n get_active_prop failure in COfillmode ");
#endif
	}

/* Find out if GRFILLED_DISPLAY bit is set or not and 
						output appropriate message */

	me->what_mode = ((prop_wrd & GRFILLED_DISPLAY) ? 1 : 0);

	if (!me->what_mode)
	{
	     ex$message( msgnumb = GR_I_FillModeOff, field = ERROR_FIELD );
	}
	else
	{
	     ex$message( msgnumb = GR_I_FillModeOn, field = ERROR_FIELD );	
	}
}

action setfill_type
{
	if (me->event1.event.keyin[1] == 'n')
	{
	    me->what_mode=1;
	}
	else
	{
	    me->what_mode=0;
	}


	if (!me->what_mode)
	{
	     ex$message( msgnumb = GR_I_FillModeOff, field = ERROR_FIELD );
	}
	else
	{
	     ex$message( msgnumb = GR_I_FillModeOn, field = ERROR_FIELD );	
	}
}
        
        
action obj_fill
{
	IGRlong     msg;
	IGRshort     prop_wrd;

/* Set the bit in prop_wrd based on the what_mode */

	prop_wrd = GRFILLED_DISPLAY;


    status = gr$gsremove_fence (msg = &msg, p_chanselect = &me->located_chansel);

	if(!(status & 1))
 	{
		me->ret= status;
		om$report_error(sts = status);
	}

    status = gr$gspass (msg = &msg,
                     pass_msg = message GRgraphics.GRchgprops (&msg, &me->what_mode, &prop_wrd),
                     senderid = my_id,
                     p_chanselect = &me->located_chansel);

	if(!(status & 1))
 	{
		me->ret= status;
		om$report_error(sts = status);
	}
}
