/*

Name
  mscumul.t

Description
  State table for "Measure Cumulative Distance" command

Notes


 */
command_string  GRMMsCumDist,CO_ni_measure_distance_btwn_2pts,GRMCmDs   
class           COmeasure
start_state     start
spec_path       "$PLATFORM/co/spec"
product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "grmessage.h"
#include "SSdef.h"


state *
on  EX_RESTART    do clear_sum                    state start
on  EX_BACK_UP                                    state -

at wakeup
  do SSenter()
  do SSactivate()

at sleep
  do SSexit()

state start
   message_key   GRC_M_MsCumDist
   prompt_key    GR_P_EntFirstPt
   execute SSSetNewElement (sts, SSNONE, 0)
   filter        get_event

   on EX_DATA.GRst_PERPEND_FROM   or  
      EX_DATA.GRst_TANGENT_TO     or
      EX_DATA.GRst_TANGENT_FROM   or
      EX_DATA.GRst_PERPEND_TO     or
      EX_DATA.GRst_ANGLE_FROM     or 
      EX_DATA.GRst_ANGLE_TO
        do status_key   GR_E_InvDtTyp               state .


   on EX_DATA
        do clear_sum
        do store_event_by_index( sts, 0 )           state have_first_event

state have_first_event
   prompt_key           GR_P_EntNextPt
   execute SSSetNewElement (sts, SSLINE, 0)
   dynamics             DYrblinear
   filter               get_event
   on EX_DATA.GRst_PERPEND_FROM   or  
      EX_DATA.GRst_TANGENT_TO     or
      EX_DATA.GRst_TANGENT_FROM   or
      EX_DATA.GRst_PERPEND_TO     or
      EX_DATA.GRst_ANGLE_FROM     or 
      EX_DATA.GRst_ANGLE_TO
        do status_key   GR_E_InvDtTyp               state .

   on EX_DATA
        do store_event_by_index( sts, 1 )
        do measure
        do display_sum
        do copy_event_by_index( sts, 0, 1 )         state .

