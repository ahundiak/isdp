/*\
Abstract	

    This command provides the user interface for the following commands:

     1. Place Fitted Text
     2. Place View Independent Fitted Text

Notes

    COMMAND TABLE ENTRIES FOR GRSAn.sl
   ------------------------------------------------------------------------
    cmd_str                             cmd_t         cmd_key     cmd_class  
   ------------------------------------------------------------------------
    place fitted text                   GRPlcCFTx     2           COtext
   ------------------------------------------------------------------------
    place view independent fitted text  GRPVInFtTx    3           COtext
   ------------------------------------------------------------------------

History

     WBC     03/10/89  Design and Implementation
\*/

/* 
     
     GRPlcCFTx

*/

command_string    GRMPlcFitTxt,PL_FIT_TEXT,GRPFtTx
synonym           GRMPlcVIFitTxt,PL_VI_FIT_TEXT,GRPVInFtTx
class             COtext
super_class       CEO_LOCATE
start_state       start
product_name      "$SOURCE"
options           "siCT"

state_table

#include "grmessage.h"
#include "copltxdef.h"

state start

on CMD_TYPE = PL_FIT_TEXT
    do message_key       GRC_M_PlcFitTxt      state place_fitted_text

on CMD_TYPE = PL_VI_FIT_TEXT
    do message_key       GRC_M_PlcVIFitTxt    state place_fitted_text

state place_fitted_text

    execute           get_construct_attr()
    execute           dyn_set_prompt(GR_P_EntTxtDtPtAnc, GR_P_EntTxt)
    dynamics          GRdyntext 
    filter            get_event

        on EX_DATA   do store_origin()
                     do get_view_rot_matrix()            state get_second_pt

        on EX_STRING do append_text_to_buffer()

                        on RETURN_CODE = MSINARG
                           do status_key GR_E_MaxTxLnExTxTr
                                                         state have_text

                        on RETURN_CODE = MSFAIL
                           do status_key GR_E_InsfMemTxTr
                                                         state have_text

                        state have_text

        on EX_FORM_FINISHED   				 state .

        on EX_RJT_MOVEON or EX_BACK_UP or EX_RESTART
			do clear_buffer() 		 state start

state text_constructed

    execute           get_construct_attr()
    execute           dyn_set_prompt(GR_P_EntTxtDtPtAnc, GR_P_EntTxtFstPt)
    dynamics          GRdyntext 
    filter            get_event

        on EX_DATA   do store_origin()
                     do get_view_rot_matrix()             state get_second_pt

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
    execute           dyn_set_prompt(GR_P_EntTxtDtPtAnc, GR_P_EntFstPt)
    dynamics          GRdyntext 
    filter            get_event

        on EX_DATA   do store_origin()
                     do get_view_rot_matrix()             state get_second_pt

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

state get_second_pt

    prompt_key        GR_P_EntSecPt
    dynamics          GRdynfittext 
    filter            get_event

        on EX_DATA   do get_construct_attr()
                     do calc_angle_size()
                     do init_text_attr()
                     do construct_text()                 state text_constructed

        on EX_STRING or EX_CHAR do status_key GR_E_EntSecPt     state .

        on EX_BACK_UP state have_text

        on EX_FORM_FINISHED state .

        on EX_RJT_MOVEON or EX_RESTART do clear_buffer() state start
