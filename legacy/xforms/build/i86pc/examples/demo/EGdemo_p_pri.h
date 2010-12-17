/****************************************************************/
/* EGdemo_p_pri.h -                                             */
/*    This is the X/Forms (XFORMSDP SN01252) ANSI-C             */
/*    function prototype header file for private functions      */
/****************************************************************/
/* Copyright 1992 Intergraph Corporation                        */
/* All Rights Reserved, Including this Release Note, the        */
/* Product it Describes, its File Formats, and Visual Displays  */
/****************************************************************/


#ifndef EGDEMO_P_PRI_H_INCLUDED 
#define EGDEMO_P_PRI_H_INCLUDED 1

#include <X11/Xproto.h>

    /*********************************/
    /***  Demo Example Functions  ****/
    /*********************************/


/* command.c */
extern void DEMO_do_msg_box(void);
extern int DEMO_process_command(int cmd_type, char *cmd_or_help_topic);

/* exec.c */
extern int Syntax(char *pn, char *arg);
extern int Sync_on(void);
extern int Sync_off(void);
extern int main(int argc, char *argv[]);

/* notify.c */
extern void DEMO_notification_routine(int form_label, int gadget_label, double value, Form form);

#endif
