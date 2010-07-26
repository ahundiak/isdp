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

command_string  GRMCArTDgCm,0,GRCArTDgCm
class           COnpt
start_state     start
spec_path       "$PLATFORM/co/spec"
product_name    "$PLATFORM",2
command_table   "3416.dpt"

state_table
#include "coniindex.h"
#include "grmessage.h"
#include "lcdef.h"

state start
    message_key    GRC_M_CArTDgCm
    prompt_key     GR_P_IdEle
    accept_key     GR_P_AccMvOn
    relocate_key   GR_E_CouNoFndEle
    locate_eligible "+GRcirarc,GRellarc"
    locate_properties   "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY" 
    locate_owner   "LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS" 
    locate_display   "ELEM_HILIGHT | ALL_WINDOWS | LC_ERASE_ALL" 
    filter      locate
on  EX_DATA         
                do store_event_by_index( sts, 0 )
                do save_first_element
		do display_mode GRbehe
		do display_first_located_object
		do arc_to_comp_arc
		do clear_channels
                                                          state .
