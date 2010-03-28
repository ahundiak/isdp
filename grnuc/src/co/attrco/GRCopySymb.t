/*
Abstract	
Notes
History
	mrm	08/12/93	added status_display_button calls
*/

command_string  GRMCopySymb,COPYSYMB,GRCpSy
class		COcpattr
super_class     COtools
super_class	COdpb
super_class	CEO_GSLOCATE
start_state	s1
spec_path       "$grnuc/co/spec"
product_name	"$SOURCE"
status_display  "GRCpSymb","-1","-1"
options		"siCT"

state_table

#include <lcdef.h>
#include <grmessage.h>
#include <FI.h>
#include <dpbco.h>
#include "cpattrco.h"


at init     do form_init ()

at wakeup
	do status_display_button(1)

at sleep
	do status_display_button(0)


at delete   do COdpb.get_dpb ( sts, CO_sym, 0 )
            do COdpb.put_dpb ( sts, CO_sym, 0 )

state *
     on EX_RESTART
	state s1

state s1
     
     message_key         GRC_M_CopySymb      
     prompt_key          GR_P_IdEleCpySymFrm
     accept_key          GR_P_Acc
     relocate_key        GR_E_EleNotFnd
     status_key          GR_I_StFmAvail
     locate_class        "GRvg" 
     locate_display      "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                          ACC_REJ_CYCLE | RELOCATE | LC_ERASE_LOC_ELEMENT |
                          2147483648"
     locate_properties   "LC_RW | LC_LC_ONLY | LC_DP_ONLY | LC_NEW_MOD |
                          LC_PLANAR_NON_PLANAR"
     locate_owner        "LC_READ | LC_NO_REF_HEADER | LC_REF_OBJECTS"
     locate_mask         "GRm_DATA | GRm_MOVE_ON | GRm_BACK_UP | 
                    	  GRm_RESTART | GRm_RJT_MOVEON"
     accept_mask         "GRm_DATA | GRm_MOVE_ON | GRm_BACK_UP | 
                          GRm_RESTART | GRm_RJT_MOVEON"
     unhilight_mode GRhe
     filter    gs_locate

	on EX_BACK_UP
		state .

	on EX_RJT_MOVEON 
		state s2

	on EX_DATA
		do COdpb.extract ( sts, 
                                 me->mask, 
                                 &me->located_chansel )

			on SUCCESS
				do form_update (me->mask, 0)
				state s2

			on ERROR or WARNING or SEVERE
        	                do error_box_key GR_E_ErrEncCmdTrm   
                	        state terminate
		state terminate

state s2

     prompt_key          GR_P_IdEleCpySymTo
     accept_key          GR_P_AccNxtMvOn
     relocate_key        GR_E_EleNotFnd
     gslocate_num_inputs 1
     gslocate_spec_mask1 "GRm_DATA | GRm_RJT_MOVEON | GRm_MOVE_ON |
			  GRm_BACK_UP | GRm_RESTART | GRm_OBJID"
     gslocate_spec_prompt1_key   GR_P_AccFnc
     locate_mask         "GRm_DATA | GRm_OBJID | GRm_BACK_UP | GRm_RESTART | 
                          GRm_RJT_MOVEON"
     accept_mask         "GRm_DATA | GRm_OBJID | GRm_BACK_UP | GRm_RESTART |
                          GRm_RJT_MOVEON"
     locate_class        "GRvg" 
     locate_owner        "LC_NON_GEOM_MOD"
     locate_display      "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                          ACC_REJ_CYCLE | RELOCATE | LC_ERASE_LOC_ELEMENT |
                          2147483648"
     locate_properties   "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY | 
			  LC_NEW_MOD | LC_PLANAR_NON_PLANAR"
     unhilight_mode GRhe
     filter gs_locate

	on EX_BACK_UP or EX_RJT_MOVEON
		state s1

	on EX_DATA or EX_OBJID
		do COdpb.change ( sts,
                                  me->mask,
                                  &me->located_chansel )

			on SUCCESS
				do COtools.push_event ( &me->event1 )
				state .
			on ERROR or WARNING or SEVERE
				do error_box_key GR_E_ErrEncCmdTrm
				state terminate
		state terminate
