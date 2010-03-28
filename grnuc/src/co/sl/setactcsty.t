
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

command_string  GRMSetActCSTyp,"CO_ni_set_active_CS_type,0,1",GRSCrSyTy
class           COnpt
start_state     start
spec_path       "$PLATFORM/co/spec"

product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "grmessage.h"


state *
on  EX_RESTART                                       state start
on  EX_BACK_UP                                       state start
on  EX_RJT_MOVEON                                    state start


state start

message_key GRC_M_SetActCSTyp
on NO_INPUT_PENDING    do display_cs_type            state get_cs_type
on ELSE                                              state get_cs_type

state get_cs_type
   prompt_key  GR_P_EntCSTyp
   filter      get_event

   on TEXT_VALUE = ""   do display_cs_type           state terminate 

   on TEXT_VALUE
      do store_event_by_index( sts, 0 )
      do use_events
         on ERROR 
	      do status_key GR_E_NotValCSTyp         state .
      do display_cs_type                             state terminate
