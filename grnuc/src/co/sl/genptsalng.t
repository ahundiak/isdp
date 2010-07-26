/*

Name
  genptsalng.t

Description
  State table for "Generate Points along Element by Spacing" command.
  Command Key = GRGnPnAESp

Notes


 */
command_string  GRMGnPtsAlEl,0,GRGnPnAESp
class           COnpt
spec_path       "$PLATFORM/co/spec"
start_state     start
product_name    "$PLATFORM"
command_table    "3416.dpt"


state_table

#include "lcdef.h"
#include "grmessage.h"

at wakeup
  do SSenter()
  do SSactivate()

at sleep
  do erase_hilite
  do SSexit()

state *
on   EX_RESTART                                     state start
on   EX_BACK_UP                                     state -
on   RETURN_CODE=GRw_no_value                       state .
                                                  

state start
   message_key GRC_M_GnPtsAlEl
   prompt_key GR_P_EntDsBtwPts 
   filter      get_event
   on DISTANCE <= 0.0
	do status_key GR_E_DsLT1                     state .

   on DISTANCE      
        do store_event_by_index( sts, 0 )
						     state have_num_points

state have_num_points
   prompt_key    GR_P_IdElePlcPtAl
   accept_key    GR_P_AccFrPt
   relocate_key  GR_E_CouNoFndEle
   locate_class  "+GRconic, GRinfline, GRlinestr, GRplanar, GRlineseg, GRsubbc"
   locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner      "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
   locate_display    "ELEM_HILIGHT | ALL_WINDOWS"
   filter      locate
   on EX_DATA
	do store_event_by_index( sts, 1 )
        do save_first_element
        do get_construct_env_from_dpb
        do erase_hilite
                                                        state have_element


state have_element
   prompt_key      GR_P_IdWherePtsEnd
   filter      get_event

   on EX_DATA.GRst_ANGLE_TO      or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_TO    or
      EX_DATA.GRst_TANGENT_FROM  or
      EX_DATA.GRst_PERPEND_TO    or
      EX_DATA.GRst_PERPEND_FROM
        do status_key GR_E_InvDtTyp                    state .

   on EX_DATA
        do store_event_by_index( sts, 2 )
        do store_event_by_index( sts, 3 )
        do store_locate_context
        do isopen
           on SUCCESS
                do erase_hilite
                do get_construct_env_from_dpb
                do gen_pts_by_spacing_along_element    state terminate
           on ERROR                                    state closed_element
                                                       state .



state closed_element
   prompt_key  GR_P_EntDirPt
   filter      get_event
   on EX_DATA.GRst_ANGLE_TO      or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_TO    or
      EX_DATA.GRst_TANGENT_FROM  or
      EX_DATA.GRst_PERPEND_TO    or
      EX_DATA.GRst_PERPEND_FROM
        do status_key GR_E_InvDtTyp                    state .

   on EX_DATA         
        do store_event_by_index( sts, 3 )
        do erase_hilite
        do get_construct_env_from_dpb
        do gen_pts_by_spacing_along_element               state terminate

