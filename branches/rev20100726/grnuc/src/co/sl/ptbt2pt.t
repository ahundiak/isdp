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

command_string  GRMPtDstBt2Pts,"CO_ni_point_between_2_pts,0,1",GRSlPnDsBt
class           COnpt
start_state     start
spec_path       "$PLATFORM/co/spec"
product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "grmessage.h"


state *
on   EX_RESTART                                    state start
on   EX_BACK_UP                                    state -
on   RETURN_CODE = GRw_no_value                    state .



state start
   message_key      GRC_M_PtDstBt2Pts
   prompt_key       GR_P_EntDist
   filter           get_event
   on EX_BACK_UP                                  state .
   on DISTANCE
        do store_event_by_index( sts, 1 )                     state have_distance



state have_distance 
   prompt_key        GR_P_EntFirstPt
   filter            get_event

   on EX_DATA.GRst_PERPEND_FROM  or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_FROM  or
      EX_DATA.GRst_PERPEND_TO    or
      EX_DATA.GRst_ANGLE_TO      or
      EX_DATA.GRst_TANGENT_TO
         do status_key        GR_E_InvDtTyp          state .

   on EX_DATA
        do store_event_by_index( sts, 2 )
        do store_event_by_index( sts, 0 )                       state have_first_point



state have_first_point
   prompt_key        GR_P_EntDirPt
   dynamics          DYrbconstruct_line
   filter            get_event

   on EX_DATA.GRst_PERPEND_FROM  or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_FROM  or
      EX_DATA.GRst_PERPEND_TO    or
      EX_DATA.GRst_ANGLE_TO      or
      EX_DATA.GRst_TANGENT_TO
         do status_key        GR_E_InvDtTyp          state .

   on EX_DATA
        do store_event_by_index( sts, 3 )
        do use_events
	do push_first_event_on_queue 	      	     state terminate




 
