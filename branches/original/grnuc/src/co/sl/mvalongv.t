/*

Name
  mvalongv.t

Description
  State table for  "Move Element along Vector" command.
  Command Key = GRMvEAlVc

Notes


 */
command_string      GRMMvElVec,0,GRMvEAlVc
class               COexp
start_state         start 
spec_path           "$PLATFORM/spec"

product_name        "$PLATFORM"
command_table       "3416.dpt"


state_table
#include "coniindex.h"
#include "grmessage.h"
#include "lcdef.h"

at wakeup
  do SSenter()
  do SSactivate()

at sleep
  do SSexit()

state *
on   EX_RESTART      do erase_hilite                   state start
on   EX_BACK_UP                                        state -

state start
   message_key      GRC_M_MvElVec
   prompt_key       GR_P_EntSpMManM
   filter           get_event
   on DISTANCE <= 0
        do status_key   GR_E_ValBePos             state . 
   on DISTANCE
        do set_manual_explode( sts, 0 )
        do store_event_by_index( sts, 2 )         state have_spacing
   on EX_RJT_MOVEON 
        do set_manual_explode( sts, 1 )           state have_spacing
   on EX_BACK_UP                                  state .

   /******************* GET DIRECTION VECTOR **********************/

state have_spacing
   prompt_key    GR_P_EntStDirVec
   filter        get_event
   on EX_BACK_UP
         do set_manual_explode( sts, 0 )          state start
   on EX_DATA.GRst_PERPEND_FROM or
      EX_DATA.GRst_ANGLE_FROM   or
      EX_DATA.GRst_TANGENT_FROM
         do store_event_by_index( sts, 0 )        state have_from_event

   on EX_DATA.GRst_PERPEND_TO or
      EX_DATA.GRst_ANGLE_TO   or
      EX_DATA.GRst_TANGENT_TO
         do store_event_by_index( sts, 0 )        state have_to_event
   on EX_DATA
         do store_event_by_index( sts, 0 )        state have_first_event


state have_from_event
   prompt_key    GR_P_EntEndDirVec
   dynamics      DYrblinear
   filter        get_event
   on EX_BACK_UP                                  state start
   on EX_DATA.GRst_PERPEND_FROM or
      EX_DATA.GRst_ANGLE_FROM   or
      EX_DATA.GRst_TANGENT_FROM
         do status_key GR_E_TwoFroPtNoAll         state .
   on EX_DATA.GRst_PERPEND_TO   or
      EX_DATA.GRst_ANGLE_TO     or
      EX_DATA.GRst_TANGENT_TO
         do status_key GR_E_ToFroPtNoAll          state .
   on EX_DATA
         do store_event_by_index( sts, 1 )
         do check_manual_explode
            on SUCCESS                            state id_elem_manual
            on ERROR                              state id_elem_auto
                                                  state id_elem_auto

state have_to_event
   prompt_key    GR_P_EntEndDirVec
   dynamics      DYrblinear
   filter        get_event
   on EX_BACK_UP                                  state start
   on EX_DATA.GRst_PERPEND_FROM or
      EX_DATA.GRst_ANGLE_FROM   or
      EX_DATA.GRst_TANGENT_FROM
         do status_key GR_E_ToFroPtNoAll          state .
   on EX_DATA    
         do store_event_by_index( sts, 1 )
         do check_manual_explode
            on SUCCESS                            state id_elem_manual
            on ERROR                              state id_elem_auto
                                                  state id_elem_auto

state have_first_event
   prompt_key    GR_P_EntEndDirVec
   dynamics      DYrblinear
   filter        get_event
   on EX_BACK_UP                                  state start
   on EX_DATA
         do store_event_by_index( sts, 1 )
         do check_manual_explode
            on SUCCESS                            state id_elem_manual
            on ERROR                              state id_elem_auto
                                                  state id_elem_auto

state have_two_events
   prompt_key    GR_P_EntEndDirVec
   dynamics      DYrblinear
   filter        get_event
   on EX_BACK_UP                                  state start
   on EX_DATA.GRst_PERPEND_FROM  or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_FROM
         do status_key GR_E_FroPtNoAllow          state .
   on EX_DATA
         do store_event_by_index( sts, 1 )
         do check_manual_explode
            on SUCCESS                            state id_elem_manual
            on ERROR                              state id_elem_auto
                                                  state id_elem_auto

   /******************* AUTOMATIC MODE STATES **********************/



state id_elem_auto
   prompt_key          GR_P_IdStation 
   accept_key          GR_P_AccMvOn
   gslocate_spec_prompt1_key GR_P_AccMvOn
   relocate_key        GR_E_EleNotFnd
   gslocate_num_inputs 1
   locate_eligible     "+GRgraphics,GRgrgrp"
   locate_mask         "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
   accept_mask         "GRm_DATA | GRm_RESTART"
   gslocate_spec_mask1 "GRm_DATA | GRm_RESTART | GRm_RJT_MOVEON"
   locate_properties   "LC_WRITE_ONLY | LC_LC_ONLY | LC_DP_ONLY"
   locate_owner      "LC_NO_RIGID_COMP | LC_RIGID_OWNER | LC_NO_FLEX_COMP | LC_FLEX_OWNER | LC_NO_REF_OBJECTS | LC_REF_HEADER"
   locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT | LC_ERASE_ALL"
   filter gs_locate
      on  EX_DATA
               do get_stationary
                  on ERROR
                        do erase_hilite          
                        do status_key  GR_E_InvElement
                                                  state .
                  on SUCCESS
                        do erase_hilite
                                                  state explode_view
                                                  state explode_view
      on EX_BACK_UP
                                                  state have_spacing


state explode_view
   prompt_key          GR_P_IdElemExp 
   accept_key          GR_P_AccMvOn
   gslocate_spec_prompt1_key  GR_P_AccMvOn
   relocate_key        GR_E_EleNotFnd
   gslocate_num_inputs 1
   locate_eligible     "+GRgraphics,GRgrgrp"
   locate_mask         "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
   accept_mask         "GRm_DATA | GRm_RESTART"
   gslocate_spec_mask1 "GRm_DATA | GRm_RESTART | GRm_RJT_MOVEON"
   locate_properties   "LC_WRITE_ONLY | LC_LC_ONLY | LC_DP_ONLY"
   locate_owner      "LC_NO_RIGID_COMP | LC_RIGID_OWNER | LC_NO_FLEX_COMP | LC_FLEX_OWNER | LC_NO_REF_OBJECTS | LC_REF_HEADER"
   locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT | LC_ERASE_ALL"
   filter gs_locate
       on EX_DATA 
           do store_event_by_index( sts, 4 )
           do explode_view
               on SUCCESS or 
                  WARNING
                    do erase_hilite
                    do clear_channels
                                                  state direction_point_optional
               on ERROR
                    do status_key GR_E_ErrEncCmdRst
                    do erase_hilite
                    do clear_channels
                                                  state id_elem_auto
                                                  state terminate 
       on EX_RJT_MOVEON or
          EX_RESTART
           do erase_hilite
           do clear_channels
                                                  state start
       on EX_BACK_UP
                                                  state direction_point_optional


state direction_point_optional
   prompt_key      GR_P_EntStDirMo 
   filter get_event
   on EX_BACK_UP or 
      EX_RESTART
         do erase_hilite
         do clear_channels
                                                  state start
   on EX_RJT_MOVEON
         do erase_hilite
         do clear_channels
         do set_manual_explode( sts, 1 )
                                                  state id_elem_manual
   on EX_DATA.GRst_PERPEND_FROM or
      EX_DATA.GRst_ANGLE_FROM   or
      EX_DATA.GRst_TANGENT_FROM
         do store_event_by_index( sts, 0 )        state have_from_event

   on EX_DATA.GRst_PERPEND_TO or
      EX_DATA.GRst_ANGLE_TO   or
      EX_DATA.GRst_TANGENT_TO
         do store_event_by_index( sts, 0 )        state have_to_event
   on EX_DATA
         do store_event_by_index( sts, 0 )        state have_first_event



   /******************* MANUAL MODE STATES **********************/


state id_elem_manual
   prompt_key          GR_P_IdEleMove
   accept_key          GR_P_AccFrPtMo 
   gslocate_spec_prompt1_key  GR_P_AccFrPtMo 
   relocate_key        GR_E_EleNotFnd
   gslocate_num_inputs 1
   locate_eligible     "+GRgraphics"
   locate_mask         "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
   accept_mask         "GRm_DATA | GRm_RESTART"
   gslocate_spec_mask1 "GRm_DATA | GRm_RESTART | GRm_RJT_MOVEON"
   locate_properties   "LC_WRITE_ONLY | LC_LC_ONLY | LC_DP_ONLY"
   locate_owner      "LC_NO_RIGID_COMP | LC_RIGID_OWNER | LC_NO_FLEX_COMP | LC_FLEX_OWNER | LC_NO_REF_OBJECTS | LC_REF_HEADER"
   locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT | LC_ERASE_ALL"
   filter gs_locate
      on  EX_DATA 
           do store_event_by_index( sts, 2 )
                                                  state move_object
      on EX_BACK_UP or
         EX_RESTART
           do erase_hilite
           do clear_channels
                                                  state start


state move_object
   prompt_key  GR_P_EntEndDirMo 
   execute   DYmove_vector
   filter get_event
       on EX_DATA
           do store_event_by_index( sts, 3 )
           do move_along_vec
               on SUCCESS or WARNING
                    do copy_event_by_index( sts, 2, 3 )
                                                  state .
               on ERROR
                    do status_key GR_E_ErrEncCmdRst
                    do erase_hilite
                    do clear_channels
                                                  state id_elem_manual
                                                  state terminate 
       on EX_RJT_MOVEON or
          EX_RESTART
           do erase_hilite
           do clear_channels
                                                  state id_elem_manual
       on EX_BACK_UP
                                                  state from_point


state from_point
   prompt_key  GR_P_AccFrPtMo 
   filter get_event
       on EX_DATA
           do store_event_by_index( sts, 3 )  /* store "from" point */
                                                  state move_object
       on EX_BACK_UP or
          EX_RESTART or
          EX_RJT_MOVEON
           do erase_hilite
           do clear_channels
                                                  state have_spacing

