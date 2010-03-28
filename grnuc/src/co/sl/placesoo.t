/*

Name
  placesoo.t

Description

  State table for  "Place Symbology Override" command.
  Command Key = GRPSyOv

Notes


 */
command_string  GRMPSyOv,0,GRPSyOv
class           DEnpt
status_display  "GRSymbOride","-1","-1"
start_state     start
spec_path       "$PLATFORM/spec"
product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "dedef.h"
#include "lcdef.h"
#include "grmessage.h"
#include "comisc.h"

at init
  do display_active_parms(sts,CO_STATUS_FORM)

at wakeup
  do SSenter()
  do SSactivate()
  do status_display_button(1)

at sleep
  do status_display_button(0)
  do SSexit()

state *
   on EX_BACK_UP
      do erase_hilite
      do set_all_windows
         state start

state start
   message_key        GRC_M_PSyOv
   relocate_key       GR_E_CouNoFndEle
   locate_properties  "LC_LC_ONLY | LC_RW | LC_DP_ONLY"
   locate_owner       "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER |
                       LC_REF_OBJECTS | LC_INVIS_OVERRIDE"
   execute             some_or_all

      on RETURN_CODE = 55
         state start_open_partial
      on RETURN_CODE = 77
         state total
      on RETURN_CODE = 99
         state total_no_text
      on ELSE
         state terminate

state start_open_partial
   prompt_key      GR_P_IdEle
   accept_key      GR_P_AccEleStrtPt
   locate_class    "GRlineseg, GRlinestr, GRconic, GRpolygon, GRorthpoly,
                    GRorthlnst, GRpllnstr, GRbcsubbc"
   locate_display  "ELEM_HILIGHT | LC_HALF_HIGHLIGHT"
   filter          locate

   on EX_FORM_FINISHED
      do some_or_all
         on RETURN_CODE = 77
            state total
         on RETURN_CODE = 99
            state total_no_text
         on RETURN_CODE = 55
            state .
      state terminate

   on EX_DATA
      do store_event( 1, 0)                /* store from point */
      do erase_hilite_plane ()
      state finish_open_partial


state finish_open_partial
   prompt_key  GR_P_EntStpPt
   dynamics    DYrblinear
   filter      get_event

   on EX_DATA.GRst_KEYPOINT
      do store_event( 1, 1)                /* store to point */
      do create_soo
      do so_flip_off
      do get_window
      do show_all
      do is_keypoint
         on RETURN_CODE = 1
            do project_locate_point( sts, 0, 1 )
            state open_key_par
	 on RETURN_CODE = 0
            do project_locate_point( sts, 0, 1 )
            do push_accept_event_on_queue
	    state open_key_par
      state terminate

   on EX_DATA
      do store_event( 1, 1)                /* store to point */
      do create_soo
      do so_flip_off
      do get_window
      do show_all
      do project_locate_point( sts, 0, 1 )
      do project_data_point( sts, 1 )
      do store_locate_context
      do set_one_window
      do display_mode GRbehe
      do display_object
      do place_sym_o_form
      do display_mode GRbd
      do display_object
      do set_all_windows
      do show_all
      do isopen
         on SUCCESS
            state start_open_partial
         on ERROR
            state start_closed_partial
      state start_closed_partial


state start_closed_partial
   prompt_key      GR_P_IdElMvOnFlp
   accept_key      GR_P_AccEleStrtPt
   locate_class    "GRlineseg, GRlinestr, GRconic, GRpolygon, GRorthpoly,
                    GRorthlnst, GRpllnstr, GRbcsubbc"
   locate_display  "ELEM_HILIGHT | LC_HALF_HIGHLIGHT"
   filter          locate

   on EX_FORM_FINISHED
      do some_or_all
         on RETURN_CODE = 77
            state total
         on RETURN_CODE = 99
            state total_no_text
         on RETURN_CODE = 55
            state .
      state terminate

   on EX_DATA
      do store_event( 1, 0 )                /* store from point */
      do erase_hilite_plane ()
      state finish_closed_partial

   on EX_RJT_MOVEON
      do so_flip_flop
      do set_one_window
      do display_mode GRbehe
      do display_objid( sts, 1 )
      do place_sym_o_form
      do display_mode GRbd
      do display_objid( sts, 1 )
      do show_all
      do set_all_windows
      state start_closed_partial


state finish_closed_partial
   prompt_key  GR_P_EntStpPt
   dynamics    DYrblinear
   filter      get_event

   on EX_DATA
      do store_event( 1, 1 )                /* store to point */
      do so_flip_off
      do get_window
      do show_all
      do project_locate_point( sts, 0, 1 )
      do project_data_point( sts, 1 )
      do store_locate_context
      do set_one_window
      do display_mode GRbehe
      do display_object
      do place_sym_o_form
      do display_mode GRbd
      do display_object
      do set_all_windows
      do show_all
      do isopen
         on SUCCESS
            state start_open_partial
      state start_closed_partial


state open_key_par
   prompt_key  GR_P_AccDstPt
   filter      get_event

   on EX_DATA
      do store_event( 1, 1 )
      do project_data_point( sts, 1 )
      do store_locate_context
      do set_one_window
      do display_mode GRbehe
      do display_object
      do place_sym_o_form
      do display_mode GRbd
      do display_object
      do set_all_windows
      do show_all
      do isopen
         on SUCCESS
            state start_open_partial
         on ERROR
            state start_closed_partial
      state start_closed_partial


state total
   prompt_key      GR_P_IdEle
   accept_key      GR_P_AccNxtEle
   locate_class    "GRlineseg, GRlinestr, GRconic, GRpolygon, GRorthpoly,
                    GRorthlnst, GRpllnstr, GRbcsubbc, GRtext"
   locate_display  "ELEM_HILIGHT | LC_HALF_HIGHLIGHT"
   filter          locate

   on EX_FORM_FINISHED
      do some_or_all
         on RETURN_CODE = 77
            state .
         on RETURN_CODE = 99
            state total_no_text
         on RETURN_CODE = 55
            state start_open_partial
      state terminate

   on EX_DATA
      do create_soo
      do get_locate_window
      do show_all
      do store_locate_context
      do set_one_window
      do display_mode GRbehe
      do display_object
      do place_sym_o_form
      do display_mode GRbd
      do display_object
      do get_window
      do set_all_windows
         on EX_DATA.GRst_REGULAR
            do push_accept_event_on_queue
            state get_next_tot
      state get_next_tot

   on EX_RJT_MOVEON
      state start
       

state get_next_tot
   prompt_key GR_P_AccNxtEle
   filter locate

   on EX_FORM_FINISHED
      do some_or_all
         on RETURN_CODE = 77
            state .
         on RETURN_CODE = 99
            state total_no_text
         on RETURN_CODE = 55
            state start_open_partial
      state terminate

   on EX_DATA
      do get_locate_window
      do show_all
      do store_locate_context
      do display_mode GRbehe
      do display_object
      do place_sym_o_form
      do display_mode GRbd
      do display_object
      do get_window
      do set_all_windows
         on EX_DATA.GRst_REGULAR
            do push_accept_event_on_queue
            state get_next_tot
      state get_next_tot

   on EX_RJT_MOVEON
      state start


state total_no_text
   prompt_key      GR_P_IdEle
   accept_key      GR_P_AccNxtEle
   locate_class    "GRlineseg, GRlinestr, GRconic, GRpolygon, GRorthpoly,
                    GRorthlnst, GRpllnstr, GRbcsubbc"
   locate_display  "ELEM_HILIGHT | LC_HALF_HIGHLIGHT"
   filter          locate

   on EX_FORM_FINISHED
      do some_or_all
         on RETURN_CODE = 99
            state .
         on RETURN_CODE = 77
            state total
         on RETURN_CODE = 55
            state start_open_partial
      state terminate

   on EX_DATA
      do create_soo
      do get_locate_window
      do show_all
      do store_locate_context
      do set_one_window
      do display_mode GRbehe
      do display_object
      do place_sym_o_form
      do display_mode GRbd
      do display_object
      do get_window
      do set_all_windows
         on EX_DATA.GRst_REGULAR
            do push_accept_event_on_queue
            state get_next_tot1
      state get_next_tot1

   on EX_RJT_MOVEON
      state start
       

state get_next_tot1
   prompt_key  GR_P_AccNxtEle
   filter      locate

   on EX_FORM_FINISHED
      do some_or_all
         on RETURN_CODE = 99
            state .
         on RETURN_CODE = 77
            state total
         on RETURN_CODE = 55
            state start_open_partial
      state terminate

   on EX_DATA
      do get_locate_window
      do show_all
      do store_locate_context
      do display_mode GRbehe
      do display_object
      do place_sym_o_form
      do display_mode GRbd
      do display_object
      do get_window
      do set_all_windows
         on EX_DATA.GRst_REGULAR
            do push_accept_event_on_queue
            state get_next_tot1
      state get_next_tot1

   on EX_RJT_MOVEON
      state start

 
