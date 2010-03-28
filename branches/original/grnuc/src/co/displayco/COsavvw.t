options			"si" 
product_name		"$GRNUC"
class			COviewmnpl
command_string		GRMSavVw,0,GRSvV
synonym 		GRMSv,0,GRSvV

start_state	id_wnd

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

at init do init_act

state *

	on EX_RESTART 	state 	id_wnd
	on EX_BACK_UP 	state   previous_state 

state	id_wnd

	msg_key         GRC_M_SavVw
	prompt_key	GR_P_IdWin
	filter		get_event

 on EX_DATA or TEXT_VALUE  do get_graphic_gadget(DstGGid,OneWnd,ExstGG)
                              	      on SrchFlt  state id_wnd 
			              on SUCCESS state nme_savvw
                         state terminate
state	nme_savvw

	msg_key         GRC_M_SavVw
	prompt_key	GR_P_KySavVwNme
	filter		get_event


   on NULL_TEXT_VALUE   state .

   on TEXT_VALUE 		do nme_savvw
				   on SrchFlt state nme_savvw
                                   on Cnstr state cnstr
                                   on Descr state  descr
                                state terminate 

state	descr

	msg_key         GRC_M_SavVw
	prompt_key	GR_P_KySavVwDes

	filter		get_event

   on TEXT_VALUE or EX_RJT_MOVEON do descr state origin 

state	origin

	msg_key         GRC_M_SavVw
	prompt_key	GR_P_EntNewOrg
	filter		get_event

   on EX_DATA or NULL_TEXT_VALUE or EX_RJT_MOVEON 	do origin
					   on ERROR   state terminate
			    		   on FunFail state terminate
				        state cnstr 
state  cnstr
/*
	filter   	none
*/	
	on ELSE      	do cnstr
                           on SrchFlt  state nme_savvw
			state id_wnd


