command_string  GRMMsRadOfEle,CO_ni_measure_radius,GRMRE
class           COmeasure
start_state     start
spec_path       "$PLATFORM/co/spec"
product_name    "$PLATFORM"



state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"



state *
on  EX_RESTART                                    state start
on  EX_BACK_UP                                    state -


state start
    message_key        GRC_M_MsRadOfEle
    prompt_key         GR_P_IdEle
    accept_key         GR_P_AccMvOn
    locate_mask        "GRm_TEXT_VALUE | GRm_DATA"
    relocate_key       GR_E_CouNoFndEle
    locate_eligible    "+GRconic"
    locate_properties  "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
    locate_owner       "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
    locate_display     "NO_PROJ_ACCEPT_POINT | ELEM_HILIGHT | ALL_WINDOWS"
    filter      locate

on  TEXT_VALUE = "" or
    EX_DATA         
                do store_locate_context
                do erase_hilite
                do measure_by_object
 	           on ERROR 
		      do status_key GR_E_ErrInCalc            state start
		do display_measurement                        state start
