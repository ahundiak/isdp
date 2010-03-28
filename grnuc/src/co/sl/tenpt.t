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


command_string  GRMPlcTenPt,"CO_ni_place_tentat_point,0,1",GRPTnPn   
class           COnpt
spec_path       "$PLATFORM/co/spec"
start_state     start
product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "grmessage.h"

state *
on   EX_RESTART                                        state start
on   EX_BACK_UP                                        state .

state start
   message_key   GRC_M_PlcTenPt
   prompt_key    GR_P_EntPt
   filter        get_event

   on EX_DATA.GRst_ANGLE_TO      or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_TO    or
      EX_DATA.GRst_TANGENT_FROM  or
      EX_DATA.GRst_PERPEND_TO    or
      EX_DATA.GRst_PERPEND_FROM
        do status_key   GR_E_InvDtTyp                   state .

   on EX_DATA
	do store_event_by_index( sts, 0 )
        do get_construct_env_from_dpb 
        do construct_object                             state terminate

   on EX_BACK_UP                                          state .


