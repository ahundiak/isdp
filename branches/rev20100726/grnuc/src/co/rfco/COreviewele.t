command_string	"Review Element",0,GRRvE
class           COreviewele
super_class	COtools
super_class	CEO_LOCATE
start_state     start
product_name    "$GRNUC"
options		"si"
spec_path	"$GRNUC/co/spec"
form		"GRReviewEle", 0, 0,"-1","-1"

state_table

#include "lcdef.h"
#include "grmessage.h"

state *
	on RESET		state -

state start
    message_key		GRC_M_ShowEle
    prompt_key		GR_P_IdEle
    locate_class	"GRgraphics"
    locate_display      "ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | ALL_WINDOWS"     
    locate_properties	"LC_LC_ONLY | LC_DP_ONLY"
    locate_owner	"LC_RIGID_COMP | LC_FLEX_COMP | LC_RIGID_OWNER | LC_FLEX_OWNER | LC_REF_OBJECTS | LC_REF_HEADER | LC_HANDLES"
    filter		locate
    on DATA or STRING	do COtools.erase_highlight()
			do inquire_data_main_form
			do display_data_main_form	state start
