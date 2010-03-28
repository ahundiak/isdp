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


command_string  GRMPlcFillet,CO_ni_place_fillet,GRPFl
class           COnpt
spec_path       "$PLATFORM/co/spec"
start_state     start
product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"

state *
on   RETURN_CODE=GRw_no_value                         state .
on   EX_RESTART  do erase_hilite                      state start
on   EX_BACK_UP  do erase_hilite                      state -
at   wakeup      do clear_channels
at   init        do construct_class "GR3dcirarc"

state start
   message_key     GRC_M_PlcFillet
   prompt_key      GR_P_EntRadiusKyin
   filter          get_event
   on  EX_DATA.GRst_ANGLE_TO          or
       EX_DATA.GRst_ANGLE_FROM        or
       EX_DATA.GRst_TANGENT_TO        or
       EX_DATA.GRst_TANGENT_FROM      or
       EX_DATA.GRst_PERPEND_TO        or
       EX_DATA.GRst_PERPEND_FROM
         do status_key GR_E_InvDtTyp                   state .
 
   on DISTANCE <= 0.0
        do status_key  GR_E_RadValBePos             state .

   on DISTANCE > 0        
         do store_event_by_index( sts, 3 )
         do set_trim_flag_auto_both
         do store_event_by_index( sts, 6 )             state have_radius
on   EX_BACK_UP                                        state .

state have_radius
   prompt_key      GR_P_Id1stEleAppTan
   accept_key      GR_P_AccSel2ElTan
   relocate_key    GR_E_CouNoFndEle
   locate_eligible      "+GRlineseg,GRinfline,GRlinestr,GRplanar,GRconic,GRsubbc,GRcompcurve"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY"
   locate_owner         "LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS | LC_RIGID_OWNER"
   locate_display       "SEGMENT_HILIGHT | LC_ACCEPT_CURSOR | ALL_WINDOWS"
   filter      locate
   on EX_DATA 
        do erase_hilite
        do save_first_element 
        do push_accept_event_on_queue
        do store_locate_event_by_index( sts, 0 )
        do store_locate_event_by_index( sts, 4 )
        do get_construct_env_from_dpb                  state have_element1

   on EX_BACK_UP do erase_hilite                       state start

state have_element1
   prompt_key      GR_P_Id2ndEleAppTan
   accept_key      GR_P_AccAppCentPt
   relocate_key    GR_E_CouNoFndEle
   locate_eligible      "+GRlineseg,GRinfline,GRlinestr,GRplanar,GRconic,GRsubbc,GRcompcurve"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY"
   locate_owner         "LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS | LC_RIGID_OWNER"
   locate_display       "SEGMENT_HILIGHT | ALL_WINDOWS "
   filter      locate
   on EX_DATA        
        do erase_hilite
        do save_second_element 
        do push_accept_event_on_queue
        do store_locate_event_by_index( sts, 1 )
        do store_locate_event_by_index( sts, 5 )     state have_element2

   on EX_BACK_UP 
	do erase_hilite                               state have_radius

state have_element2
   prompt_key      GR_P_EntCenPt
   filter        get_event
   on EX_DATA.GRst_ANGLE_TO          or
      EX_DATA.GRst_ANGLE_FROM        or
      EX_DATA.GRst_TANGENT_TO        or
      EX_DATA.GRst_TANGENT_FROM      or
      EX_DATA.GRst_PERPEND_TO        or
      EX_DATA.GRst_PERPEND_FROM
        do status_key GR_E_InvDtTyp                     state .
   on EX_DATA
        do store_event_by_index( sts, 2 )
        do display_mode GRbe
        do display_first_located_object
        do display_second_located_object
        do locate_two_and_construct
                                                        state have_radius

   on EX_BACK_UP do erase_hilite
        do display_mode GRhd
        do display_first_located_object
                                                        state have_element1

