/*

Name
  crrad.t

Description
  State table for "Place Circle by Diameter Key-in and Center Point" command

Notes


 */
command_string  GRMPCrDmKCP,CO_ni_place_circle_by_center,GRPCrCnDm
synonym         GRMPCrDmKCP,CO_ni_place_circle_by_center,EMPCrCnDm
class           COnpt
start_state     start
spec_path       "$PLATFORM/spec"
product_name    "$PLATFORM"


state_table
#include "coniindex.h"
#include "grmessage.h"
#include "comisc.h"
#include "SSdef.h"



state *
on   EX_RESTART                                        state start
on   RETURN_CODE = GRw_no_value                        state .

at init
  do construct_class "GR3dcircle"

at wakeup 
  do show_assoc_mode(1)
  do SSenter()

at sleep 
  do show_assoc_mode(0)
  do SSexit()


state start
   execute SSactivate ()
   message_key      GRC_M_PCrDmKCP
   prompt_key       GR_P_EnDmVl
   filter           get_event

   on DISTANCE <= 0.0
        do status_key GR_E_CEnNPsDv                    state .

   on DISTANCE
        do store_event_by_index( sts, 1 )
	do diameter_to_radius( sts, 1 )                state have_first_event


state have_first_event
   execute SSactivate ()
   prompt_key    GR_P_EntCenPt
   dynamics      DYrbcirrad
   filter        get_event
   on EX_DATA.GRst_PERPEND_FROM  or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_FROM  or
      EX_DATA.GRst_PERPEND_TO    or
      EX_DATA.GRst_ANGLE_TO      or
      EX_DATA.GRst_TANGENT_TO
        do status_key  GR_E_InvDtTyp                   state . 

   on EX_DATA
        do store_event_by_index( sts, 0 )
        do get_construct_env_from_dpb
        do construct_object
           on ERROR                                    state start
        do display_mode GRbd
        do display_constructed
	do convert_to_profile                          state .

   on DISTANCE <= 0
        do status_key GR_E_CEnNPsDv                    state .

   on DISTANCE
        do store_event_by_index( sts, 1 )
	do diameter_to_radius( sts, 1 )                state .


   on EX_BACK_UP                                       state -

