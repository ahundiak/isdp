command_string  GRMRevCroHatGem,0,GRRvCrGm
class           ECaxhatch
form            "RevXhatch",XHATCH_REV_FORM,0,"-1","-1"
spec_path       "$MODEL/co/spec"
start_state     start
product_name    "$MODEL"
options         "Tsic"


state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"
#include  "grxhdef.h"

state *
on   EX_RESTART      do erase_hilite                   state start
on   EX_BACK_UP      do erase_hilite                   state start

state start
  message_key       GRC_M_RevCroHatGem
  prompt_key        GR_P_IdentXHatch
  accept_key        GR_P_AccNxtMvOn
  relocate_key      GR_E_CouNoFndEle
  locate_class    "GRpolygon,GRcompcurve,GRorthpoly,GRcircle,GRellipse,GRbspline" 
  locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_PLANAR_ONLY | LC_PHY_CLOSED"
  locate_owner      "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER "
    filter      gs_locate
on  EX_DATA        
                do erase_hilite
                do push_accept_event_on_queue
                do copy_event(sts, &me->event1, &me->event2)
		do get_xhatch_objects
                  on ERROR   do status_key GR_E_ObjNotXHatch
	        state get_pat
	state get_pat

state get_pat
  prompt_key        GR_P_AccNxtMvOn
  accept_key        GR_P_AccNxtMvOn
  relocate_key      GR_E_CouNoFndEle
  locate_class   "GRpolygon,GRcompcurve,GRorthpoly,GRcircle,GRellipse,GRbspline"
  locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_PLANAR_ONLY | LC_PHY_CLOSED"
  locate_owner      "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER "
    filter      gs_locate
on EX_RJT_MOVEON
                  state load_pat 
on EX_DATA
                do push_accept_event_on_queue
                do copy_event(sts, &me->event1, &me->event2)
		do get_xhatch_objects
		   on SUCCESS state .
		   on ERROR   do status_key GR_E_ObjNotXHatch
		state .
                  state load_pat 
state load_pat
                execute load_pattern_from_element()
	        on SUCCESS
		do display_review_form     state start
