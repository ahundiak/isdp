command_string  GRMCreDrwSht,CO_drawsheet,GRCrDrSh
class           COdetail
product_name    "$SOURCE"
super_class     COtools
super_class     CEO_GSLOCATE
spec_path       "$grnuc/co/spec"
form            "GRCrDrSht",MAIN_FORM,0,"-1","-1"
start_state     start
options	        "siTC"
 
state_table

#include <OMerrordef.h>
#include <execmsg.h>
#include <grmessage.h>
#include "detailco.h"
#include <DIdef.h>
#include "grsymdef.h"
#include <toolco.h>

#define  GR_E_NO_SYM 4
#define  GR_E_NO_REF 6

state *

on EX_RESTART                                     state start

state start

execute review_elements_exist ()

on MSSUCC                                         state show_form
on MSFAIL   do status_key GR_E_NoShtDfn           state terminate

state show_form

message_key    GRC_M_CreDrwSht
execute display_form_by_label(MAIN_FORM, sts)
prompt_key     GR_P_SelSht

filter    wfi

on MOVE_ON     do erase_form_by_label(MAIN_FORM,0,sts)
                                                  state get_name
on FORM_FINISHED
               do erase_form_by_label(MAIN_FORM,0,sts)
                                                  state get_name

state get_name

prompt_key GR_P_EntShtNm

filter    get_event

on EX_BACK_UP                                     state -
on EX_RJT_MOVEON                                  state place_sheet
on NULL_TEXT_VALUE  				  state place_sheet
on EX_STRING    do COtools.translate ( sts,
                                      me->event1.event.keyin,
                                      0, 0 )
                    on RETURN_CODE = DIR_W_NAME_NOT_FOUND
                        do COtools.assign ( me->event1.event.keyin,
                                            me->name,
                                            CO_str_to_str )
                                                  state place_sheet

                    on SUCCESS
                         do status_key GR_E_DupNme
                                                  state .
                    on ERROR or SEVERE or WARNING  
                        do status_key GR_E_InvNme
                                                  state .
               do status_key GR_E_ErrEncCmdTrm
                                                  state terminate

state place_sheet

prompt_key     GR_P_EntPtSht

filter get_event

on EX_BACK_UP                                     state -
on EX_RJT_MOVEON                                  state -
on EX_DATA     do construct_drawsheet ()
                    on RETURN_CODE = GR_E_NO_REF
                         do status_key GR_E_ErrFlAtch
                                                  state terminate
                    on RETURN_CODE = GR_E_NO_FILE
                         do status_key GR_E_ErrFlAtch
                                                  state terminate
                    on RETURN_CODE = GR_E_NO_SYM
                         do status_key GR_E_CelNotFnd
                                                  state terminate
                    on RETURN_CODE = MSFAIL
                         do status_key GR_E_ErrEncCmdTrm
                                                  state terminate
                    on RETURN_CODE = MSSUCC
                                                  state terminate
                    on RETURN_CODE = OM_I_DUPLICATE_OS
                         do status_key EX_F_DupIntOSName
                                                  state -
                                                  state terminate


at init do set_defaults ()
at wakeup do set_gadgets ()

