/*

Name
  pardelet.t

Description
  State table for  "Partial Delete Element" command.
  Command Key = GRPrDlE

Notes

 */
command_string  GRMPartDel,CO_ni_partial_delete,GRPrDlE
class           COnpt
spec_path       "$PLATFORM/co/spec"
start_state     start
product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"

at wakeup
  do SSenter()

at sleep
  do SSexit()

state *
on   EX_RESTART                                          state start
on   EX_BACK_UP                                          state -

state start
   execute SSactivate()
   message_key     GRC_M_PartDelete
   prompt_key      GR_P_IdElePartDel
   accept_key      GR_P_AccFrPt
   relocate_key     GR_E_CouNoFndEle
   locate_rtree    "GRvg"
   locate_eligible "+GRlineseg,GRlinestr,GRplanar,GRconic,GRsubbc,GRcompcurve"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY"
   locate_owner         "LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
   locate_display       "ELEM_HILIGHT | ALL_WINDOWS"
   filter locate
   on EX_DATA        
        do store_event_by_index( sts, 0 )
        do store_locate_context                 
        do erase_hilite                                   state have_element
   on EX_BACK_UP do erase_hilite                          state start


state have_element
   execute SSactivate()
   prompt_key GR_P_IdToPtOnEle
   dynamics DYrbproject_linear
   filter get_event

   on EX_DATA
        do store_event_by_index( sts, 1 )
        do isopen
           on SUCCESS
                do display_mode GRbehe
                do display_located
                do use_one_element
                   on ERROR
                        do display_mode GRbd
                        do display_located
                                                         state start
                                                         state start

           on ERROR                                      state closed_element
                                                         state .

   on EX_BACK_UP 
	do erase_hilite                                  state start

   on EX_RJT_MOVEON                                      state start


state closed_element
   execute SSdeactivate()
   prompt_key  GR_P_EntDirPt
   dynamics DYrbfixed_linear
   filter get_event

   on EX_DATA
	do erase_hilite   
        do store_event_by_index( sts, 2 )
        do display_mode GRbehe
        do display_located
        do use_one_element
           on ERROR
                do display_mode GRbd
                do display_located
                                                         state start
                                                         state start

   on EX_BACK_UP 
	do erase_hilite                                  state have_element
