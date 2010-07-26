command_string  "query",0,Query
class           QYnpt
start_state     start
spec_path       "$GRNUC/co/spec"
spec_path       "$GRNUC/query/sl"
product_name    "$GRNUC"
status_display  "GRQuery","-1","-1",1
command_table   "command_table"
options         "TCsi"

state_table
#include "coniindex.h"
#include "dedef.h"
#include "lcdef.h"
#include "grmessage.h"

state *
on  EX_RESTART      do erase_hilite 
                    do init_query ()                 state start

state start
    msg_key      GRC_M_QueryDir
    status_key   GR_I_StFmAvail
on  ELSE
    do store_query
                                                     state get_query


state get_directory
    prompt_key        GR_P_LocDir
    accept_key        GR_P_Acc
    relocate_key      GR_E_CouNoFndEle
    locate_mask       "GRm_DATA | GRm_OBJID | GRm_STRING | GRm_BACK_UP"
    locate_properties "LC_LC_ONLY | LC_RW | LC_DP_ONLY | LC_REGEX_ON" 
    locate_owner      "LC_FLEX_COMP | LC_REF_OBJECTS | LC_NO_REF_HEADER" 
    locate_display    "ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | ALL_WINDOWS | LC_ERASE_ALL" 
    filter            gs_locate

on  EX_BACK_UP  do store_query                       state get_query

on  DATA   or
    EX_OBJID         
                do store_event_by_index( sts, 0 )
                do store_locate_context
                do erase_hilite
                do display_mode GRhd
                do display_object
                do store_event_by_index ( sts, 1 )
                do send_query
		   on ERROR
                      do status_key GR_I_NoDirLoc
                                                       state get_directory
                                                       state terminate

on TEXT_VALUE
                do store_locate_context
                on RETURN_CODE = DIR_W_NAME_NOT_FOUND
                   do status_key GR_I_NoDirLoc
                                                       state get_directory
                do erase_hilite
                do display_mode GRhd
                do display_object
                do store_event_by_index ( sts, 1 )
                do send_query
		   on ERROR
                      do status_key GR_I_NoDirLoc
                                                       state get_directory
                                                       state terminate

state get_query
    prompt_key	GR_P_EntQuery
    filter      get_event
on EX_BACK_UP   do back_up_query()                     state .
on TEXT_VALUE   do store_query
		    on RETURN_CODE = MSFAIL
		                                       state get_query
                                 		       state get_directory

at init do init_query()

