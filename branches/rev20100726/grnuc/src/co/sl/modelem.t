/*

Name
  modelem.t

Description
  State table for "Modify Element" command

Notes


 */
command_string  GRMModEle,CO_ni_modify_element,GRMdE
class           COnpt
start_state     start
spec_path       "$PLATFORM/co/spec"

product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "grmessage.h"
#include "lcdef.h"
#include "SSdef.h"


at wakeup
   do SSenter()
   do SSactivate()

at sleep
   do SSexit()

state *
on  EX_RESTART   state start
on  EX_BACK_UP   state -

state start
  message_key    GRC_M_ModEle
  prompt_key     GR_P_IdEle
  accept_key     GR_P_AccFrPt
  relocate_key   GR_E_CouNoFndEle
  locate_eligible "+GRclippoly,GRlineseg,GRlinestr,GRplanar,GRconic,GRsubbc,EMSsubbs,DEsome,GRpoint,ACcpx"
  locate_properties   "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY"
  locate_owner   "LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
  locate_display   "ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | ALL_WINDOWS | LC_ERASE_ALL"
  filter locate
  on EX_BACK_UP                                   state .
  on EX_RJT_MOVEON                                state .
  on EX_DATA
     do store_event_by_index( sts, 0 )
     do store_locate_context                      state have_element


state have_element
  execute SSSetNewElement (sts, SSINQUIRE, 0)
  prompt_key GR_P_EntDesPt
  dynamics DYrb2ptmodify
  filter get_event
  on EX_DATA
     do store_event_by_index( sts, 1 )
     do display_mode GRbehe
     do display_located
     do use_one_element
        on ERROR
           do display_mode GRbd
           do display_located                     state start
     do copy_event_by_index( sts, 0, 1 )          state have_element

  on EX_RJT_MOVEON
     do display_mode GRbd
     do display_located                           state start
