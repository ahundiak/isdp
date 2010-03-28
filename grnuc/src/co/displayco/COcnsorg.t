options			"si" 
product_name		"$GRNUC"
class			COcnstrpl
command_string		GRMRedfnCnsPlOrg,2,GRCCnPlOr
synonym 		GRMMvCnsPl,3,GRMvCnPl

start_state       	strt_state

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	strt_state
	on EX_BACK_UP 	state   previous_state 


state   strt_state
        on CMD_TYPE = 2      state      get_orgn
        on CMD_TYPE = 3      state      frm_pt

state	get_orgn

	msg_key       	GRC_M_RedfnCnsPlOrg
	prompt_key	GR_P_EntCnsOrg
	filter		get_event

	on EX_DATA  	do get_dt_pt(FrstPt) 
                           state mv_cnspl 

state   mv_cnspl

	msg_key       	GRC_M_RedfnCnsPlOrg
	prompt_key	GR_P_IdWin
	filter		get_event

  on EX_DATA or TEXT_VALUE  	do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
			 	   on SrchFlt state mv_cnspl
                                   on SUCCESS do mv_cnspl
				   		on ERROR state terminate
                                	      state mv_cnspl 
                                state mv_cnspl 

  on EX_RJT_MOVEON	        state get_orgn

state frm_pt

	msg_key         GRC_M_MvCnsPl
	prompt_key	GR_P_FromPt
	filter		get_event

        on EX_DATA	do get_dt_pt(FrstPt)
                        state dst_pt 

state dst_pt

	msg_key         GRC_M_MvCnsPl
	prompt_key	GR_P_EntDesPt
	filter		get_event

        on EX_DATA	do get_dt_pt(ScndPt)
                        state idnt_wnd2
state	idnt_wnd2

	prompt_key	GR_P_IdWin
	filter		get_event

  on EX_DATA or TEXT_VALUE   do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
                                on SrchFlt  state idnt_wnd2
                                on SUCCESS do idnt_wnd2
                                              on ERROR state terminate
                                              state idnt_wnd2
                             state idnt_wnd2

on  EX_RJT_MOVEON 	    state  frm_pt

