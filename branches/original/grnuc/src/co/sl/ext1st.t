/*

Name
  ext1st.t

Description
  State table for "Extend Elements to Intersection" command

Notes


 */
command_string  GRMExt1EleToInt,CO_ni_extend_1_insect,GRExETIn
class           COnpt
spec_path       "$PLATFORM/co/spec"
start_state     start
product_name    "$PLATFORM"


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
on EX_RESTART    do erase_hilite                  state start

state start
  message_key     GRC_M_Ext1EleToInt
  prompt_key      GR_P_IdEleToIntsect
  accept_key      GR_P_AccId1stElEndEx
  relocate_key    GR_E_CouNoFndEle
  locate_eligible "+GRlineseg,GRlinestr,GRinfline,GRplanar,GRconic,GRsubbc,GRcurve,EMSsubbs"
  locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner      "LC_READ | LC_NO_REF_HEADER | LC_REF_OBJECTS"
  locate_display    "ELEM_HILIGHT | ALL_WINDOWS"
  filter locate
  on EX_DATA
     do save_first_element
     do store_locate_event_by_index( sts, 1 )
     do push_accept_event_on_queue
                                                      state have_intersect

state have_intersect
  prompt_key      GR_P_IdEleEndEx
  accept_key      GR_P_AccApIscPt
  relocate_key    GR_E_CouNoFndEle
  locate_eligible"+GRlineseg,GRlinestr,GRpllnstr,GRcirarc,GRellarc,GRorthlnst,GRsubbc,GRcompcurve"
  locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW | LC_PHY_OPEN"
  locate_owner      "LC_READ | LC_NO_REF_HEADER | LC_REF_OBJECTS"
  locate_display    "ELEM_HILIGHT | ALL_WINDOWS"
  execute ignore_skobj
  filter locate
  on EX_DATA
     do save_second_element
     do store_locate_event_by_index( sts, 0 )
     do push_accept_event_on_queue
                                                       state have_element2
  on EX_BACK_UP                                        state start
  on EX_RJT_MOVEON                                     state start

state have_element2
  execute SSSetNewElement (sts, SSINQUIRE, 0)                         
  prompt_key    GR_P_IndApprInt
  filter        get_event
  on EX_DATA
     do erase_hilite
     do store_event_by_index( sts, 2 )
     do use_two_elements
        on ERROR
           do status_key  GR_E_CouNoExtEle             state have_intersect
                                                       state have_intersect
