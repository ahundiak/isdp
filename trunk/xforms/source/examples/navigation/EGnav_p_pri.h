/****************************************************************/
/* EGnav_p_pri.h -                                             */
/*    This is the X/Forms (XFORMSDP SN01252) ANSI-C             */
/*    function prototype header file for private functions      */
/****************************************************************/
/* Copyright 1992 Intergraph Corporation                        */
/* All Rights Reserved, Including this Release Note, the        */
/* Product it Describes, its File Formats, and Visual Displays  */
/****************************************************************/


#ifndef EGNAV_P_PRI_H_INCLUDED 
#define EGNAV_P_PRI_H_INCLUDED 1

#include <X11/Xproto.h>

    /***************************************/
    /***  Navigation Example Functions  ****/
    /***************************************/


/* exec.c */
extern int Syntax(char *pn, char *arg);
extern int Sync_on(void);
extern int Sync_off(void);
extern void notification_routine(int form_label, int gadget_label, double value, Form form);
extern int InitExec(void);
extern int main(int argc, char *argv[]);

/* main.c */
extern int Syntax(char *pn, char *arg);
extern int Sync_on(void);
extern int Sync_off(void);
extern void notification_routine(int form_label, int gadget_label, double value, Form form);
extern int main(int argc, char *argv[]);

#endif
