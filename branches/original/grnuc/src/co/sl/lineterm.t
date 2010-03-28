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

command_string  GRMPlcLinTerm,CO_ni_place_line_terminator,GRPLTr
class           COnpt
spec_path       "$PLATFORM/co/spec"
start_state     start
product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"
#include "comisc.h"

at wakeup  do is_active_cell_defined
at init    do display_active_parms(sts,CO_ACTIVE_CELL)

state *
on   EX_RESTART      do erase_hilite                   state start
on   EX_BACK_UP      do erase_hilite                   state start


state start
    message_key GRC_M_PlcLinTerm
    prompt_key  GR_P_IdLnToTerm
    accept_key  GR_P_AccMvOn
    relocate_key    GR_E_CouNoFndEle
/*  locate_rtree is currently not supported by locate. */
    locate_class        "GRlinear,GRconic,EMScomposite,GRcurve"
    locate_properties   "LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY | LC_PHY_OPEN"
    locate_owner        "LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
    locate_display      ELEM_HILIGHT
    filter      locate
on  EX_DATA        
                do store_event_by_index( sts, 0 )
                do store_locate_context        
                                                       state have_element


state have_element
    prompt_key  GR_P_IdEnPtTerm
    filter      get_event

on  EX_DATA     do store_event_by_index( sts, 1 )
                do display_mode GRbdhe
                do display_located
                do use_one_element
                    on ERROR  do status_key  GR_E_ErrEncCmdRst     state start
                                                                   state start

on EX_RJT_MOVEON                                                   state start


