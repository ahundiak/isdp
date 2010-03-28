/*

Name
  point.t

Description
  State table for "Place Point" command

Notes


 */
command_string  GRMPlcPoint,CO_ni_place_point,GRPPn  
synonym         GRMPlcPoint,CO_ni_place_point,EMPPn  
class           COnpt
spec_path       "$PLATFORM/spec"
start_state     start
product_name    "$PLATFORM"


state_table
#include "coniindex.h"
#include "grmessage.h"
#include "comisc.h"
#include "SSdef.h"


state *
on   EX_RESTART                                        state start
on   EX_BACK_UP                                        state .

at init   
  do construct_class "GR3dpoint"

at wakeup 
  do clear_channels
  do show_assoc_mode(1)
  do SSenter()

at sleep 
  do show_assoc_mode(0)
  do SSexit()


state start
   execute SSactivate ()
   message_key     GRC_M_PlcPoint
   prompt_key      GR_P_EntPt
   filter          get_event
   on  EX_BACK_UP                                      state .
   on EX_DATA.GRst_PERPEND_FROM   or  
      EX_DATA.GRst_TANGENT_TO     or
      EX_DATA.GRst_TANGENT_FROM   or
      EX_DATA.GRst_PERPEND_TO     or
      EX_DATA.GRst_ANGLE_FROM     or 
      EX_DATA.GRst_ANGLE_TO
        do status_key   GR_E_InvDtTyp                  state .

   on EX_DATA     
	do store_event_by_index( sts, 0 )
        do get_construct_env_from_dpb 
        do construct_object                 
        do display_mode GRbd
        do display_constructed
	do convert_to_profile                          state .

