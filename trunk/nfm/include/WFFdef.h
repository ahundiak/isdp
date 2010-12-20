#ifndef WFFDEF_H
#define WFFDEF_H

#ifndef TRUE 
#define TRUE  1
#endif
#ifndef FALSE 
#define FALSE 0
#endif

/*  Form types  */

#define WFF_LOGIN_TYPE           1 
#define WFF_DEBUG_TYPE           2 
#define WFF_PASSWD_TYPE          3 
#define WFF_ERROR_TYPE           4
#define WFF_RECORD_TYPE          5
#define WFF_PLAYBACK_TYPE        6
#define WFF_CONFIRM_TYPE         7
#define WFF_ADD_WF_TYPE          8 
#define WFF_CHANGE_WF_TYPE       9 
#define WFF_ADD_COMMAND_TYPE    10 
#define WFF_DELETE_COMMAND_TYPE 11 
#define WFF_LOAD_WF_TYPE        12 
#define WFF_DUMP_WF_TYPE        13 
#define WFF_CONFIRM_DELETE_CLASS_TYPE     14
#define WFF_CONFIRM_DELETE_STATE_TYPE     15

#define WFF_COMMAND_FILE   ".WFFcommands"
#define WFF_DEFAULTS_FILE  ".WFFdefaults"
#define WFF_HELP_FILE      "help_file.hp"

#define WFF_ADD            "ADD"
#define WFF_DROP           "DROP"

/*  Values for WFFglobal.where_message_is  */

#define WFF_MESSAGE_FORM   1
#define WFF_CURRENT_FORM   2
#define WFF_MAIN_FORM      3

/*  All forms have the same definition for these labels  */

#define LEFT_SCROLL_BUTTON   700
#define RIGHT_SCROLL_BUTTON  701
#define ERROR_BEZEL          888
#define ERROR_TEXT           999

/*  Default screen positions for form centering  */
#define X_FORM_POS  50
#define Y_FORM_POS  50
/*  Offset for hourglass symbol  */

#define MSG_FORM_SYMBOL    12


/*  Generated from MS_save_locations ()  */

#if defined(OS_INTELSOL)
#define PANEL_MENU_WIDTH  186 
#define BAR_MENU_HEIGHT    60 
#else
#define PANEL_MENU_WIDTH  186
#define BAR_MENU_HEIGHT    60
#endif

/*  Form labels for command notification routines  */

#define MAIN_FORM_LABEL                 1
#define ERROR_FORM_LABEL                2
#define CONFIRM_LABEL                   3  
#define DEBUG_LABEL                     4 
#define CLIENT_DEBUG_LABEL              5 
#define POPUP_LABEL                     6 
#define BEGIN_RECORD_LABEL              7 
#define BEGIN_PLAYBACK_LABEL            8 
#define LOGIN_LABEL                     9 
#define ENV_POPUP_LABEL                10 
#define CONNECT_LABEL                  11  
#define LOAD_WF_LABEL                  12 
#define LIST_LABEL                     13
#define ADD_WORKFLOW_LABEL             14
#define PAGE1_LABEL                    15
#define PAGE2_LABEL                    16
#define PAGE3_LABEL                    17
#define PAGE4_LABEL                    18
#define CHANGE_WORKFLOW_LABEL          19
#define ADD_COMMAND_LABEL              20
#define DELETE_COMMAND_LABEL           21
#define DUMP_WF_LABEL                  22 
#define CONFIRM_LABEL_DELETE_CLASS     23
#define CONFIRM_LABEL_DELETE_STATE     24
#endif
