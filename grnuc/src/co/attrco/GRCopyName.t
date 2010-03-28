/*\
Abstract
	This class implements commands to change any of the following 
	attributes:

History
     

Notes

    COMMAND TABLE ENTRIES FOR GRLstNms.sl:
   -----------------------------------------------------------------
    cmd_str                            cmd_key        cmd_class  
   -----------------------------------------------------------------        
     list names                         93            COcpattr
   -----------------------------------------------------------------        
\*/

command_string GRMLstEleNme,LISTNAMES,GRCrLsNmE 
class          COcpattr
product_name   "$SOURCE"
super_class    COtools
super_class    COdpb
super_class    CEO_GSLOCATE
spec_path      "$grnuc/co/spec"
path           "."
start_state    start
options	       "siTC"
 
state_table

#include <grmessage.h>
#include <lcdef.h>
#include <FI.h>
#include <toolco.h>
#include "cpattrco.h"

state *
     on EX_RESTART                                             state start

state start
     message_key    GRC_M_LstEleNme
     prompt_key     GR_P_EntFil
     
     filter    get_event

     on EX_STRING   do COtools.access_file ( sts, 
                                             (CO_file_exists | CO_file_reg | CO_file_write ),
                                             me->event1.event.keyin,
                                             0 )
            on MSFAIL
                    do COtools.open_file ( sts,
                                           me->event1.event.keyin, 
                                           "w")                
                on MSSUCC                                       state select
                on MSFAIL   do status_key GR_E_FlCantOpn        state .
                                                                state terminate
            on MSSUCC
                    do COtools.store_event ( &me->event1, 0 )   state overwrite
                                                                state terminate
     on EX_BACK_UP                                              state .

state overwrite
     prompt_key	    GR_P_FlExOv

     filter    get_event

     on EX_STRING="y" or EX_STRING="Y" or EX_STRING="yes" or EX_STRING="YES"
                    do COtools.fetch_event ( 0, &me->event1 )
                    do COtools.open_file ( sts,
                                           me->event1.event.keyin, 
                                           "w" )                
            on MSSUCC                                           state select
            on MSFAIL   do status_key GR_E_FlCantOpn            state -
                                                                state terminate

     on EX_STRING="n" or EX_STRING="N" or EX_STRING="no" or EX_STRING="NO"
                                                                state append
     on EX_BACK_UP                                              state -

state append
     prompt_key     GR_P_FlExApp
     
     filter    get_event

     on EX_STRING="y" or EX_STRING="Y" or EX_STRING="yes" or EX_STRING="YES"
                    do COtools.fetch_event ( 0, &me->event1 )
                    do COtools.open_file ( sts,
                                           me->event1.event.keyin,
                                           "a" )                
            on MSSUCC                                           state select
            on MSFAIL   do status_key GR_E_FlCantOpn            state -
                                                                state terminate

     on EX_STRING="n" or EX_STRING="N" or EX_STRING="no" or EX_STRING="NO"
                                                                state start
     on EX_BACK_UP                                              state -

state select

     prompt_key          GR_P_IdEleLst
     accept_key          GR_P_AccNxtMvOn
     relocate_key        GR_E_EleNotFnd
     gslocate_num_inputs 1
     gslocate_spec_mask1 "GRm_DATA | GRm_RJT_MOVEON | GRm_MOVE_ON | GRm_BACK_UP |
                          GRm_RESTART | GRm_OBJID"
     gslocate_spec_prompt1_key     GR_P_AccFnc
     locate_owner        "LC_READ | LC_NO_REF_HEADER | LC_REF_OBJECTS"
     locate_mask         "GRm_DATA | GRm_OBJID | GRm_BACK_UP | GRm_RESTART |
                          GRm_RJT_MOVEON"
     accept_mask         "GRm_DATA | GRm_OBJID | GRm_BACK_UP | GRm_RESTART |
                          GRm_RJT_MOVEON"
     locate_class        "GRvg"
     locate_display      "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                          ACC_REJ_CYCLE | RELOCATE | LC_ERASE_LOC_ELEMENT |
                          2147483648"
     locate_properties   "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY | LC_NEW_MOD |
                          LC_PLANAR_NON_PLANAR"
     filter gs_locate

on EX_BACK_UP or EX_RJT_MOVEON
                    do COtools.close_file ()                        state start

on EX_DATA or EX_OBJID
                    do list_names () 
     on SUCCESS     do COtools.push_event ( &me->event1 )     state .

     on ERROR or WARNING or SEVERE
                    do error_box_key GR_E_ErrEncCmdTrm              state terminate
                                                                    state terminate
at delete           do COtools.close_file ()

