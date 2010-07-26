command_string    GRC_M_PlTexAlEl
class             COtxalel
start_state       start
product_name      "$GRNUC"
options           "sicT"

state_table

#include "grmessage.h"
#include "copltxdef.h"
#include "lcdef.h"

at sleep  do erase_highlight()

state start

    execute           get_construct_attr() 
    message_key       GRC_M_PlTexAlEl
    execute           dyn_set_prompt(GR_P_KeyintxtIdEl,GR_P_EntTxt)
    dynamics          GRdyntext 
    filter            get_event

        on EX_DATA   do is_it_empty_text()

            on RETURN_CODE = GRTEXT_NOT_EMPTY

                     do put_pt_on_queue()   state get_elem

            on RETURN_CODE = GRTEXT_EMPTY 

                     do status_key GR_E_EntTxtFst state .
             
            state .

        on EX_STRING do append_text_to_buffer()

                        on RETURN_CODE = MSINARG
                           do status_key GR_E_MaxTxLnExTxTr
                                                         state have_text


                        on RETURN_CODE = MSFAIL
                             do status_key GR_E_InsfMemTxTr
                                                         state have_text

                        state have_text 

        on EX_FORM_FINISHED   				 state .

        on EX_RJT_MOVEON or EX_BACK_UP or EX_RESTART do clear_buffer() state start

state get_elem

    execute           get_construct_attr() 
    execute           dyn_set_prompt(GR_P_IdElStrtPt,GR_P_IdElKeyText)
    relocate_key      GR_E_EleNotFnd
    accept_key        GR_P_AccSidePoint
    locate_eligible   "+GRcurve"
    locate_display    "ELEM_HILIGHT | PROJ_ACCEPT_POINT | ALL_WINDOWS | LC_ERASE_ALL"
    unhilight_mode    GRhe
    filter            locate

       on LC_OBJ_LOCATED
                          do get_curve_geom()
                          do save_point1()
                          do save_side_point()
                          do get_construct_attr()
                          do init_text_attr() 
                          do get_text_along(1)            state get_direction

       on EX_RESTART     state start  

       on EX_RJT_MOVEON or EX_BACK_UP     state start

state get_direction

    execute           highlight_text_along()
    prompt_key        GR_P_AccMvRevDir
    filter            get_event

        on EX_DATA   do erase_highlight()
                     do construct_text_along()   state start

        on EX_RJT_MOVEON do erase_highlight()
                         do get_text_along(2) state .

        on EX_BACK_UP do erase_highlight()
                      state get_side

        on EX_RESTART do erase_highlight()
                      do clear_buffer() state start

        on EX_FORM_FINISHED   				 state .

state get_side

    prompt_key        GR_P_AccSidePoint
    filter            get_event

        on EX_DATA   do save_side_point()
                     do get_text_along(1)   state get_direction

        on EX_BACK_UP state start

        on EX_RESTART do clear_buffer() state start

        on EX_FORM_FINISHED   				 state .

state have_text

    execute           get_construct_attr() 
    execute           dyn_set_prompt(GR_P_EntTxtDtPtOrg, GR_P_IdElKeyText)
    dynamics          GRdyntext
    filter            get_event

        on EX_DATA    do put_pt_on_queue()   state start

        on EX_STRING do append_text_to_buffer()

                     on RETURN_CODE = MSINARG
                        do status_key GR_E_MaxTxLnExTxTr
                                                      state .

                     on RETURN_CODE = MSFAIL
                        do status_key GR_E_InsfMemTxTr
                                                      state .

                     state .

        on EX_FORM_FINISHED   				 state .

        on EX_RJT_MOVEON or EX_BACK_UP or EX_RESTART do clear_buffer() state start
