/*

Name
  crdiam.t

Description
  State table for "Place Circle by Diameter Points" command

Notes


 */
command_string  GRMPlcCirDiaPts,CO_ni_place_circle_by_diameter,GRPCrDmPn
synonym         GRMPlcCirDiaPts,CO_ni_place_circle_by_diameter,EMPCrDmPn
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
on   EX_BACK_UP                                        state -

at init
  do construct_class  "GR3dcircle"

at wakeup 
  do clear_channels
  do show_assoc_mode(1)
  do SSenter()

at sleep 
  do show_assoc_mode(0)
  do SSexit()


state start
  execute SSactivate ()
  message_key      GRC_M_PlcCirDiaPts
  prompt_key       GR_P_Ent1stDiamPt
  filter           get_event
  on  EX_BACK_UP                                    state .

  on EX_DATA.GRst_PERPEND_FROM   or  
     EX_DATA.GRst_ANGLE_FROM     or 
     EX_DATA.GRst_TANGENT_FROM   or
     EX_DATA.GRst_PERPEND_TO     or
     EX_DATA.GRst_ANGLE_TO
     do status_key   GR_E_InvDtTyp               state .

  on EX_DATA
     do store_event_by_index( sts, 0 )         
     do get_construct_env_from_dpb     state have_first_event

state have_first_event
  execute SSactivate ()
  prompt_key       GR_P_Ent2ndDiamPt
  dynamics      DYrbcirdiam
  filter        get_event

  on EX_DATA.GRst_PERPEND_FROM   or  
     EX_DATA.GRst_TANGENT_FROM   or
     EX_DATA.GRst_PERPEND_TO     or
     EX_DATA.GRst_ANGLE_FROM     or 
     EX_DATA.GRst_ANGLE_TO
     do status_key   GR_E_InvDtTyp               state .

  on EX_DATA
     do store_event_by_index( sts, 1 )
     do construct_object
     do display_mode GRbd
     do display_constructed
     do convert_to_profile                       state start

