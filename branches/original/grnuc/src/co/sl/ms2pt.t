/*

Name
  ms2pt.t

Description
  State table for "Measure Distance between 2 Points" command

Notes

 */
command_string  GRMMsDist2Pts,CO_ni_measure_distance_btwn_2pts,GRMDsBt2Pn   
class           COmeasure
spec_path       "$PLATFORM/co/spec"
start_state     start
product_name    "$PLATFORM"
command_table   "3416.dpt"



state_table
#include "coniindex.h"
#include "grmessage.h"
#include "COBmsg.h"
#include "SSdef.h"


state *
on  EX_RESTART                                        state start
on  EX_BACK_UP                                        state -


at wakeup        do SSenter()
                 do SSactivate()
at sleep         do SSexit()

state start
   message_key            GRC_M_MsDist2Pts
   prompt_key             GR_P_EntFirstPt
   filter               get_event
   on EX_DATA.GRst_PERPEND_FROM   or  
      EX_DATA.GRst_TANGENT_TO     or
      EX_DATA.GRst_TANGENT_FROM   or
      EX_DATA.GRst_PERPEND_TO     or
      EX_DATA.GRst_ANGLE_FROM     or 
      EX_DATA.GRst_ANGLE_TO
        do status_key   GR_E_InvDtTyp                  state .


   on EX_DATA
        do store_event_by_index( sts, 0 )              state have_first_event




state have_first_event
   prompt_key             GR_P_Ent2ndPt
   dynamics DYrblinear
   filter               get_event
   on EX_DATA.GRst_PERPEND_FROM   or  
      EX_DATA.GRst_TANGENT_TO     or
      EX_DATA.GRst_TANGENT_FROM   or
      EX_DATA.GRst_PERPEND_TO     or
      EX_DATA.GRst_ANGLE_FROM     or 
      EX_DATA.GRst_ANGLE_TO
        do status_key   GR_E_InvDtTyp                  state .

   on EX_DATA
        do store_event_by_index( sts, 1 )
        do clear_sum
        do measure
        do display_measurement
        do store_event_by_index( sts, 0 )              state have_first_event
