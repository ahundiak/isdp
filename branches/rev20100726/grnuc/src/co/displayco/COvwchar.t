options	        "si" 
product_name    "$GRNUC"
class           COvwchar
command_string  GRC_M_ModVwPar,0,GRShVPr
start_state     get_view
form            "GRView",VIEW_FORM,0,"-1","-1"
form            "GRLayers",GRLAYERS_FORM,0,"-1","-1"
 

state_table

#include 	"grmessage.h"
#include	"codpdef.h"
#include    "lydef.h"
#include    "viewdef.h"


state  get_view

msg_key	    GRC_M_ModVwPar
prompt_key	GR_P_IdWin
filter		get_event
on EX_DATA or TEXT_VALUE  do get_graphic_gadget(SrcGGid,OneWnd,ExstGG)  
                            on SrchFlt  state get_view
                            on SUCCESS do gather_gg_data (sts)
                                       do display_form 0
                                         on ERROR  state terminate
                            state get_view
                          state get_view


