command_string  GRC_M_GRRmBnOpRg,0,GRRmBnOpRg
class           ECaxhatch
spec_path       "$MODEL/co/spec"
start_state     start
product_name    "$MODEL"
options         "Tsic"

state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"

state *
on   EX_RESTART      do erase_hilite                   state start

state start
  message_key        GRC_M_RmBnOpRg
  prompt_key         GR_P_IdOpaqueRg
  accept_key         GR_P_AccMvOn
  relocate_key       GR_E_CouNoFndEle
  locate_class    "GRpolygon,GRcompcurve,GRorthpoly,GRcircle,GRellipse,GRbspline" 
  locate_owner      "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
  locate_properties "LC_LC_ONLY | LC_DP_ONLY |  LC_PLANAR_ONLY | LC_PHY_CLOSED"
  filter      gs_locate
  on  DATA        
                do delete_collection
                do display_mode GRbdhe
                do display_located   
		do get_xhatch_objects
		  on ERROR     do status_key GR_E_ObjNotXHatch
				          state .
                do save_first_element     state have_xhatch_objects

on   EX_BACK_UP      do erase_hilite                   state start
              
state have_xhatch_objects
  prompt_key         GR_P_IdentBound
  accept_key         GR_P_AccNxtMvOn
  relocate_key       GR_E_CouNoFndEle
  locate_class      "GRpolygon,GRcompcurve,GRorthpoly,GRcircle,GRellipse,GRgrgrp,GRbspline"
  locate_mask       "GRm_DATA | GRm_OBJID | GRm_BACK_UP | GRm_RJT_MOVEON"
  locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_PLANAR_ONLY | LC_PHY_CLOSED"
  locate_owner      "LC_RIGID_COMP | LC_GEOM_MOD | LC_REF_OBJECTS | LC_NO_REF_HEADER" 
  locate_display    "ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | ALL_WINDOWS | LC_ERASE_ALL" 
  filter      gs_locate
  on DATA
                do display_mode GRbdhe
                do display_located   
		do is_this_a_hole
		  on ERROR     do status_key  GR_E_ObjNotBound
				                        state .
                do add_to_collection     
                do display_mode GRhhd
                do display_collection
                do push_accept_event_on_queue
                do copy_event(sts, &me->event1, &me->event2)
                                                        state .
  on EX_OBJID
                do display_mode GRbdhe
                do display_located   
		do is_this_a_hole
		  on ERROR     do status_key  GR_E_ObjNotBound
				                        state .
                do add_to_collection     
                do display_mode GRhhd
                do display_collection
                                                        state .

on EX_RJT_MOVEON          
                do display_mode GRbe
                do display_second_located_object
                do erase_hilite
                do add_remove_holes(0)
                do status_key GR_I_BndRemoved
                do display_mode GRbd
                do display_second_located_object
                do display_collection                   state start

on EX_BACK_UP   do delete_last_entry_collection
                do display_mode GRhhd
                do display_collection
                                                         state -





