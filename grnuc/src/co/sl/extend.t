/*

Name
  extend.t

Description
  State table for the "Extend Element" command ( now obsolete )

Notes
  09/22/93	SY	Reviving it.

 */
command_string	GRMExtEle,CO_ni_extend_element,IDExEDyn
class           COnpt
spec_path       "$PLATFORM/co/spec"
start_state     start
product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grcmd.h"
#include "grmessage.h"
#include "SSdef.h"

at wakeup        do SSenter()
                 do SSactivate ()
at sleep         do SSexit()

state start
  message_key     GRC_M_ExtEle
  prompt_key      GR_P_IdEleEndEx
  accept_key      GR_P_AccPtDis
  locate_mask     "GRm_DATA"
  accept_mask     "GRm_DATA | GRm_VALUE"
  value_accept    "UOM_DISTANCE"
  relocate_key    GR_E_CouNoFndEle
  locate_eligible "+GRlineseg,GRlinestr,GRpllnstr,GRcirarc,GRellarc,GRorthlnst,GRsubbc,GRcompcurve"
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY"
  locate_owner         "LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
  locate_display       "ALL_WINDOWS | ELEM_HILIGHT"
  execute SSactivate()
  execute setup_dyn_info
  filter locate
  on EX_DATA or
     DISTANCE
     do save_first_element
     do store_locate_event_by_index( sts, 0 )
     do push_accept_event_on_queue                  state have_element

state have_element
  execute SSSetNewElement (sts, SSINQUIRE, 0)                         
  prompt_key        GR_P_EntPtDisEx
  filter get_event
  on EX_DATA or
     DISTANCE
     do SSdeactivate()
     do store_event_by_index( sts, 1 )
     do erase_hilite
     do use_one_element                             state start
