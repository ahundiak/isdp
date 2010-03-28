/*

Name
  arc3pt.t

Description
  State table for "Arc by end points"

Notes


 */
command_string  GRMPlcArcEndPts,CO_ni_place_arc_3pts,IDPAr3Pn
synonym         GRMPlcArcEndPts,CO_ni_place_arc_3pts,Z1PAr3Pn
class           COnpt
spec_path       "$PLATFORM/spec"
product_name    "$PLATFORM"


state_table
#include "coniindex.h"
#include "grcmd.h"
#include "grmessage.h"
#include "comisc.h"
#include "SSdef.h"


state *
on   EX_RESTART                                         state start
on   EX_BACK_UP                                         state -

at init
  do construct_class  "GR3dcirarc"
  do display_active_parms ( sts, CO_CLOCKWISE  )

at wakeup
  do clear_channels
  do show_assoc_mode(1)
  do SSenter()

at sleep
  do show_assoc_mode(0)
  do SSexit()

state start
   execute SSactivate ()
   message_key GRC_M_PlcArcEndPts
   prompt_key GR_P_EntFirstPt
   filter get_event
   on EX_DATA.GRst_ANGLE_TO          or
      EX_DATA.GRst_ANGLE_FROM        or
      EX_DATA.GRst_TANGENT_FROM      or
      EX_DATA.GRst_PERPEND_TO        or
      EX_DATA.GRst_PERPEND_FROM
        do status_key GR_E_InvDtTyp                        state .

   on EX_DATA
	do store_event_by_index( sts, 0 )               state have_first_event

   on EX_BACK_UP                                        state .

state have_first_event
   execute SSactivate ()
   prompt_key      GR_P_EntNextPt
   dynamics        DYrblinear
   filter          get_event

   on EX_DATA.GRst_ANGLE_TO          or
      EX_DATA.GRst_ANGLE_FROM        or
      EX_DATA.GRst_TANGENT_FROM      or
      EX_DATA.GRst_PERPEND_TO        or
      EX_DATA.GRst_PERPEND_FROM
        do status_key GR_E_InvDtTyp                    state .

   on EX_DATA
	 do store_event_by_index( sts, 2 )    
         do get_construct_env_from_dpb
                                                       state have_second_event
                           
state have_second_event
   execute SSactivate ()
   prompt_key      GR_P_EntLastPt
   dynamics        DYrbarcendpt
   filter          get_event
   on EX_DATA.GRst_ANGLE_TO          or
      EX_DATA.GRst_ANGLE_FROM        or
      EX_DATA.GRst_TANGENT_FROM      or
      EX_DATA.GRst_PERPEND_TO        or
      EX_DATA.GRst_PERPEND_FROM
        do status_key GR_E_InvDtTyp                    state .

   on EX_DATA
        do store_event_by_index( sts, 1 )
        do construct_object
        do display_mode GRbd
        do display_constructed
        do convert_to_profile
						state start

