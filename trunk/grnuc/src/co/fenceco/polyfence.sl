command_string  GRMPlcPyFnc,CO_ni_place_polygon,GRPPlFn
class           COplfence
spec_path       "$grnuc/co/spec"
start_state     start
product_name    "$SOURCE"
command_table   "4853.dpt"
options         "siTC"


state_table
#include "coniindex.h"
#include "grmessage.h"
#include "dp.h"


state *
on  EX_RESTART             do disconnect_constructed         state start
on  EX_BACK_UP                                               state -
on  EX_RJT_MOVEON          do disconnect_constructed         state .

   at wakeup
         do display_mode GRbehd
         do display_constructed

   at sleep
         do display_mode GRbdhe
         do display_constructed


state start
   message_key      GRC_M_PlcPyFnc
   prompt_key       GR_P_EntFstVtx
   filter        get_event
   construct_class "GR3dpolygon"

   on EX_DATA.GRst_PERPEND_FROM  or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_FROM
         do get_construct_env_from_dpb
         do store_event_by_index( sts, 0 )                            state have_from_pt   

   on EX_DATA.GRst_PERPEND_TO  or
      EX_DATA.GRst_ANGLE_TO    or
      EX_DATA.GRst_TANGENT_TO
         do get_construct_env_from_dpb
         do store_event_by_index( sts, 0 )                            state have_to_pt   

   on EX_DATA      
         do get_construct_env_from_dpb
         do store_event_by_index( sts, 0 )                            state have_reg_pt   



state have_from_pt   
   prompt_key GR_P_EntSecVtx
   dynamics   DYrblinear
   filter     get_event

   on EX_DATA.GRst_PERPEND_FROM   or
      EX_DATA.GRst_ANGLE_FROM     or
      EX_DATA.GRst_TANGENT_FROM   or
      EX_DATA.GRst_PERPEND_TO     or
      EX_DATA.GRst_ANGLE_TO       or
      EX_DATA.GRst_TANGENT_TO
         do status_key GR_E_IllCmbSpPts           state .

   on EX_DATA
         do store_event_by_index( sts, 1 )                    state have_two_good_pts



state have_to_pt   
   prompt_key  GR_P_EntSecVtx
   dynamics    DYrblinear
   filter      get_event

   on EX_DATA.GRst_PERPEND_FROM  or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_FROM
         do status_key GR_E_CantDfnVtx                 state .
   on EX_DATA
         do store_event_by_index( sts, 1 )                    state have_two_good_pts


state have_reg_pt   
   prompt_key  GR_P_EntSecVtx
   dynamics    DYrblinear
   filter      get_event

   on EX_DATA 
         do store_event_by_index( sts, 1 )                    state have_two_good_pts


state have_two_good_pts
   prompt_key  GR_P_EntThdVtx
   dynamics    DYrbtriangle
   filter      get_event

   on EX_DATA.GRst_PERPEND_FROM  or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_FROM
         do status_key GR_E_CantDfnVtx                 state .
   on EX_DATA   
         do store_event_by_index( sts, 2 )
         do clear_fill_mode ()
         do construct_object
         do restore_fill_mode ()
         do store_event_by_index( sts, 0 )
         do display_mode GRhd
         do display_constructed
         do reload_last_point
         do store_event_by_index( sts, 2 )                     state have_polygon 



state have_polygon
   execute get_channel_count( sts, 0 )
   on  RETURN_CODE != 1
       do status_key GR_E_MnpObjLost                   state start
   prompt_key    GR_P_EntNextVertex
   execute const_dynamics ( sts, DYrb_add_pt_modify )
   filter        get_event

   on EX_DATA.GRst_PERPEND_FROM  or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_FROM
         do status_key GR_E_CantDfnVtx                   state .
   on EX_DATA 
         do store_event_by_index( sts, 1 )
         do display_mode GRhe
         do display_constructed
         do add_point
         do store_event_by_index( sts, 0 )
         do display_mode GRhd
         do display_constructed                          state .

   on EX_BACK_UP
         do display_mode GRhe
         do display_constructed
         do delete_point
         do reload_last_point
         do display_mode GRhd
         do display_constructed                          state .

   on EX_RJT_MOVEON
         do display_mode GRbdhe
         do display_constructed
         do disconnect_constructed                       state terminate