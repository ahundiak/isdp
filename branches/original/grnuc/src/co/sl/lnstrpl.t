/*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
*/ 

command_string  GRMPlcPlanLnStrg,CO_ni_place_linear,GRPPlLn
class           COnpt
start_state     start
spec_path       "$PLATFORM/co/spec"

product_name    "$PLATFORM"
command_table    "3416.dpt"


state_table
#include "coniindex.h"
#include "grmessage.h"


state *
on EX_RJT_MOVEON                                     state start
on EX_RESTART                                        state start

at sleep
     do display_mode GRbdhe
     do display_constructed


state start
   message_key      GRC_M_PlcPlanLnStrg
   prompt_key       GR_P_EntFirstPt
   construct_class "GR3dpllnstr"
   filter get_event
   on EX_BACK_UP                                    state .

   on EX_DATA.GRst_PERPEND_FROM or
      EX_DATA.GRst_ANGLE_FROM   or
      EX_DATA.GRst_TANGENT_FROM
        do store_event_by_index( sts, 0 )
        do get_construct_env_from_dpb     state have_from_event

   on EX_DATA.GRst_PERPEND_TO or
      EX_DATA.GRst_ANGLE_TO   or
      EX_DATA.GRst_TANGENT_TO
        do store_event_by_index( sts, 0 )
        do get_construct_env_from_dpb     state have_to_event

   on EX_DATA
        do store_event_by_index( sts, 0 )
        do get_construct_env_from_dpb     state have_first_event


state have_from_event
   prompt_key    GR_P_EntNextPt
   dynamics      DYrblinear

   filter get_event
   on EX_BACK_UP                                       state start

   on EX_DATA.GRst_PERPEND_FROM  or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_FROM
        do status_key GR_E_TwoFroPtNoAll               state .

   on EX_DATA.GRst_PERPEND_TO    or
      EX_DATA.GRst_ANGLE_TO      or
      EX_DATA.GRst_TANGENT_TO
        do status_key GR_E_ToFroPtNoAll                state .

   on EX_DATA 
        do store_event_by_index( sts, 1 )
        do construct_object
         on ERROR                                      state start
        do display_mode  GRhd 
        do display_constructed
        do reload_last_point
        do store_event_by_index( sts, 0 )                 state have_created_element


state have_to_event
   prompt_key    GR_P_EntNextPt
   dynamics      DYrblinear
   filter        get_event
   on EX_BACK_UP                                       state start

   on EX_DATA.GRst_PERPEND_FROM  or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_FROM
        do status_key GR_E_ToFroPtNoAll                state .

   on EX_DATA
        do store_event_by_index( sts, 1 )
        do construct_object
         on ERROR                                      state start
        do display_mode GRhd
        do display_constructed
        do reload_last_point
        do store_event_by_index( sts, 0 )                          state have_created_element


state have_first_event
   prompt_key    GR_P_EntNextPt
   dynamics      DYrblinear
   filter        get_event
   on EX_BACK_UP                                    state start

   on EX_DATA
        do store_event_by_index( sts, 1 )
        do construct_object     
         on ERROR                                      state start
        do display_mode GRhd
        do display_constructed
        do reload_last_point
        do store_event_by_index( sts, 0 )              state have_created_element


state have_created_element
   prompt_key    GR_P_EntNextPt
   /* NULL ptr indicates const_chansel */
   execute get_channel_count( sts, 0 )
   on RETURN_CODE != 1
        do status_key GR_E_MnpObjLost                   state start
   execute const_dynamics ( sts, DYrb_add_pt_modify )
/* dynamics      DYrblinear */

   filter get_event
   on EX_DATA.GRst_PERPEND_FROM or 
      EX_DATA.GRst_ANGLE_FROM   or
      EX_DATA.GRst_TANGENT_FROM
        do status_key GR_E_FroPtNoAllow                 state .

   on EX_RJT_MOVEON or 
      EX_RESTART
        do display_mode GRbdhe
        do display_constructed
	do disconnect_constructed                      state start

   on EX_BACK_UP
        do display_mode GRhe
        do display_constructed
        do delete_point
        do display_mode GRbehd
        do display_constructed
        do reload_last_point
        do store_event_by_index( sts, 0 )                 state .

   on EX_DATA
        do store_event_by_index( sts, 1 )
        do add_point
        on ERROR                                    state start
        do display_mode GRhd
        do display_constructed
        do reload_last_point
        do store_event_by_index( sts, 0 )                            state .


