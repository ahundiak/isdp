/*

Name
  msalong.t

Description
  State table for "Measure Length along Element" command.
  Command Key = GRMLnAlE

Notes

 */
command_string  GRMMsLenAlongEle,CO_ni_measure_length_along_element,GRMLnAlE   
class           COmeasure
start_state     start
spec_path       "$PLATFORM/co/spec"

product_name    "$PLATFORM"
command_table   "3416.dpt"




state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"
#include "SSdef.h"



state *
on  EX_RESTART                                    state start
on  EX_BACK_UP       do erase_hilite
                     do display_mode GRhhd
                     do display_located           state -
on  EX_RJT_MOVEON    do erase_hilite              state start

at wakeup
  do SSenter()
  do SSactivate()

at sleep
  do SSexit()

state start
   message_key    GRC_M_MsLenAlongEle
   prompt_key     GR_P_IdEle
   accept_key     GR_P_AccFrPt
   locate_mask     "GRm_TEXT_VALUE | GRm_DATA"
   relocate_key   GR_E_CouNoFndEle
   locate_eligible  "+GRlineseg,GRlinestr,GRinfline,GRplanar,GRconic,GRsubbc,GRcompcurve"
    locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
    locate_owner         "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
    locate_display       "NO_PROJ_ACCEPT_POINT | ELEM_HILIGHT | ALL_WINDOWS"
    filter      locate

on  EX_DATA 
      do store_event_by_index( sts, 0 )
      do store_locate_context                 state have_element


state have_element
   prompt_key     GR_P_EntDesPt
   filter         get_event
   on EX_DATA
	do store_event_by_index( sts, 1 )
        do isopen
           on SUCCESS
              do measure_by_object
                 on ERROR 
		    do status_key GR_E_ErrInCalc        state start
              do display_measurement
              do display_mode GRhhd
              do display_located                        state have_measured

                                                        state closed_element




state closed_element
   prompt_key   GR_P_EntDirPt
   dynamics     DYrbfixed_linear
   execute SSdeactivate()
   filter       get_event
   on EX_DATA
      do store_event_by_index( sts, 2 )
      do measure_by_object 
         on ERROR 
	    do status_key GR_E_ErrInCalc                 state start
      do display_measurement
      do erase_hilite
      do display_mode GRhhd
      do SSactivate( )
      do display_located                                 state have_measured



state have_measured
   prompt_key    GR_P_EntStartPt
   filter        get_event
   on EX_DATA
      do store_event_by_index( sts, 0 )                  state have_element

   on  EX_BACK_UP 
      do erase_hilite                                    state start

