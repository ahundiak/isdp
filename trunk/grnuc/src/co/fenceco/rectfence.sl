/*\
Description
   The PLACE RECTANGULAR FENCE command is used to place a rectangular
   fence.  This command is identical to the PLACE BLOCK command except
   that it is a transition file for COplfence.  COplfence supplies class
   specific attributes to the fence object.

History
   Gray Winn    05/18/87    Creation date.
   WBC          06/08/88    Updated to use the updated COnpt actions.
\*/

command_string  GRMPlcRctFnc,CO_ni_place_block,GRPRcFn
class           COplfence
spec_path       "$grnuc/co/spec"
start_state     start
product_name    "$SOURCE"
command_table   "4853.dpt"
options         "siTC"

state_table
#include "coniindex.h"
#include "grmessage.h"

state *
on   EX_RESTART                                        state start
on   EX_BACK_UP                                        state -
at   wakeup  do clear_channels
at   init    do construct_class "GR3dorthpoly"


state start
  message_key   GRC_M_PlcRctFnc
  prompt_key    GR_P_EntFstDiaPt
  filter        get_event

   on EX_DATA.GRst_ANGLE_TO       or 
      EX_DATA.GRst_ANGLE_FROM     or 
      EX_DATA.GRst_TANGENT_TO     or 
      EX_DATA.GRst_TANGENT_FROM   or 
      EX_DATA.GRst_PERPEND_TO     or 
      EX_DATA.GRst_PERPEND_FROM
        do status_key  GR_E_InvDtTyp                   state .

   on EX_DATA
        do store_event_by_index( sts, 0 )             
        do get_construct_env_from_dpb 
                                                       state have_first_event

   on EX_BACK_UP                                       state .


state have_first_event
  prompt_key      GR_P_EntSecDiaPt
  dynamics        DYrbblock
  filter          get_event

   on EX_DATA.GRst_ANGLE_TO       or 
      EX_DATA.GRst_ANGLE_FROM     or 
      EX_DATA.GRst_TANGENT_TO     or 
      EX_DATA.GRst_TANGENT_FROM   or 
      EX_DATA.GRst_PERPEND_TO     or 
      EX_DATA.GRst_PERPEND_FROM
        do status_key  GR_E_InvDtTyp                   state .

   on EX_DATA
        do store_event_by_index( sts, 1 )
        do clear_fill_mode ()
        do construct_object
            on RETURN_CODE = MSSUCC
                do restore_fill_mode ()
                do display_mode GRbd
                do display_constructed                 state terminate
            on ELSE                                    state terminate

        state start
