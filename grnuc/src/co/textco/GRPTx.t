/*\
Abstract	

    This command provides the user interface for the following commands:

     1. Place Text
     2. Place View Independent Text

Notes

    COMMAND TABLE ENTRIES FOR GRPTx.t
   ---------------------------------------------------------------------
    cmd_str                       cmd_t         cmd_key        cmd_class  
   ---------------------------------------------------------------------
    place text                    GRPTx         0              COtext
   ---------------------------------------------------------------------
    place view independent text   GRPVInTx      1              COtext
   ---------------------------------------------------------------------

History

     WBC     03/10/89  Design and Implementation
\*/

/* 
     
     GRPTx

*/
command_string    GRMPlcTxt,PL_TEXT,GRPTx
synonym           GRMPlcVITxt,PL_VI_TEXT,GRPVInTx
class             COtext
super_class       CEO_LOCATE
start_state       start
product_name      "$GRNUC"
options           "siCT"

state_table

#include "grmessage.h"
#include "copltxdef.h"

state start

on CMD_TYPE = PL_TEXT
    do message_key       GRC_M_PlcTxt      state place_text

on CMD_TYPE = PL_VI_TEXT
    do message_key       GRC_M_PlcVITxt    state place_text

state place_text

    execute           get_construct_attr()
    execute           dyn_set_prompt(GR_P_EntTxtDtPtOrg, GR_P_EntTxt)
    dynamics          GRdyntext 
    filter            get_event

        on EX_DATA   do store_origin()
                     do get_view_rot_matrix()
                     do is_it_empty_text()

            on RETURN_CODE = GRTEXT_NOT_EMPTY
                                  do get_construct_attr()
                                  do init_text_attr()
                                  do construct_text()    state text_constructed

            on RETURN_CODE = GRTEXT_EMPTY                state empty_text

            state .

        on EX_STRING do append_text_to_buffer()

                        on RETURN_CODE = MSINARG
                           do status_key GR_E_MaxTxLnExTxTr
                                                         state have_text

                        on RETURN_CODE = MSFAIL
                           do status_key GR_E_InsfMemTxTr
                                                         state have_text

                        state have_text

        on EX_FORM_FINISHED
                     do is_it_empty_text()

            on RETURN_CODE = GRTEXT_EMPTY                state .

            on RETURN_CODE = GRTEXT_NOT_EMPTY		 state have_text

            state .

        on EX_RJT_MOVEON or EX_BACK_UP or EX_RESTART do clear_buffer() state start

state empty_text

    prompt_key        GR_P_KeyinEmptyTxtNmMvOnNoNm
    filter            get_event

        on EX_STRING        do named_empty_text()

                                on RETURN_CODE = MSSUCC do get_construct_attr()
                                                        do init_text_attr()
                                                        do set_empty_flag()
                                                        do construct_text()
                                                        do clear_buffer()
                                                        state start

                                on ELSE                 state .

                            state .

        on EX_RJT_MOVEON    do get_construct_attr()
                            do init_text_attr()
                            do empty_text_no_name()
                            do construct_text()           state start

        on EX_FORM_FINISHED   				  state .

        on EX_BACK_UP or EX_RESTART                       state start

state text_constructed

    execute           get_construct_attr()
    execute           dyn_set_prompt(GR_P_EntTxtDtPtOrg, GR_P_EntTxtPlcPt)
    dynamics          GRdyntext 
    filter            get_event

        on EX_DATA   do store_origin()
                     do get_view_rot_matrix()
                     do get_construct_attr()
                     do init_text_attr()
                     do construct_text()    state .

        on EX_STRING do check_dynamics()

                     on RETURN_CODE = GRdynamics_on do append_text_to_buffer()

                        on RETURN_CODE = MSINARG
                           do status_key GR_E_MaxTxLnExTxTr
                                                         state .

                        on RETURN_CODE = MSFAIL
                           do status_key GR_E_InsfMemTxTr
                                                         state .

                        state .

                     on ELSE do clear_buffer()
                             do append_text_to_buffer()

                             on RETURN_CODE = MSINARG
                                do status_key GR_E_MaxTxLnExTxTr
                                                         state have_text

                             on RETURN_CODE = MSFAIL
                                do status_key GR_E_InsfMemTxTr
                                                         state have_text

                             state have_text

                     state .

        on EX_FORM_FINISHED   				 state .

        on EX_RJT_MOVEON or EX_BACK_UP or EX_RESTART do clear_buffer() state start

state have_text

    execute           get_construct_attr()
    execute           dyn_set_prompt(GR_P_EntTxtDtPtOrg, GR_P_EntPlcPt)
    dynamics          GRdyntext 
    filter            get_event

        on EX_DATA   do store_origin()
                     do get_view_rot_matrix()
                     do get_construct_attr()
                     do init_text_attr()
                     do construct_text()    state text_constructed

        on EX_STRING do append_text_to_buffer()

                     on RETURN_CODE = MSINARG
                        do status_key GR_E_MaxTxLnExTxTr
                                                      state .

                     on RETURN_CODE = MSFAIL
                        do status_key GR_E_InsfMemTxTr
                                                      state .

                     state .

        on EX_FORM_FINISHED
	             state .

        on EX_RJT_MOVEON or EX_BACK_UP or EX_RESTART do clear_buffer() state start
