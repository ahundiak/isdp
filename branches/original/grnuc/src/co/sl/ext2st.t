/*

Name
  ext2st.t

Description
  State table for "Extend 2 Elements to Intersection" command

Notes


 */
command_string  GRMExt2EleToInt,CO_ni_extend_2_insect,GREx2ETIn
class           COnpt
spec_path       "$PLATFORM/co/spec"
start_state     start
product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"
#include "comisc.h"
#include "SSdef.h"

at init          do display_active_parms(sts,CO_APPARENT)
at wakeup        do SSenter()
                 do SSactivate ()
at sleep         do SSexit()

state *
on   EX_RESTART    do erase_hilite                       state start
on   EX_BACK_UP                                          state -

state start
  message_key     GRC_M_Ext2EleToInt
  prompt_key      GR_P_Id1stEleExt
  accept_key      GR_P_AccId2ndElEndEx
  relocate_key    GR_E_CouNoFndEle
  locate_eligible "+GRlineseg,GRlinestr,GRpllnstr,GRcirarc,GRellarc,GRorthlnst,GRsubbc,GRcompcurve"
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY"
  locate_owner         "LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
  locate_display       "SEGMENT_HILIGHT | ALL_WINDOWS"
  filter locate

  on EX_DATA
     do save_first_element
     do store_locate_event_by_index( sts, 0 )
     do push_accept_event_on_queue
                                                         state have_element1

state have_element1
  prompt_key      GR_P_Id2ndEleExt
  accept_key      GR_P_AccApIscPt
  relocate_key    GR_E_CouNoFndEle
  locate_eligible "+GRlineseg,GRlinestr,GRpllnstr,GRcirarc,GRellarc,GRorthlnst,GRsubbc,GRcompcurve"
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY"
  locate_owner         "LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
  locate_display       "SEGMENT_HILIGHT | ALL_WINDOWS"
  filter locate

  on EX_DATA
     do save_second_element
     do store_locate_event_by_index( sts, 1 )
     do push_accept_event_on_queue
                                                          state have_element2

state have_element2
  execute SSSetNewElement (sts, SSINQUIRE, 0)                         
  prompt_key    GR_P_IndApprInt
  filter        get_event
  on EX_DATA
     do erase_hilite
     do store_event_by_index( sts, 2 )
     do use_two_elements
        on ERROR
              do status_key GR_E_CouNoExtEle              state start
                                                          state start
