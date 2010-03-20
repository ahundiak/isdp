/****************************************************************/
/* EGwall_p_pri.h -                                             */
/*    This is the X/Forms (XFORMSDP SN01252) ANSI-C             */
/*    function prototype header file for private functions      */
/****************************************************************/
/* Copyright 1992 Intergraph Corporation                        */
/* All Rights Reserved, Including this Release Note, the        */
/* Product it Describes, its File Formats, and Visual Displays  */
/****************************************************************/


#ifndef EGWALL_P_PRI_H_INCLUDED 
#define EGWALL_P_PRI_H_INCLUDED 1

#include <X11/Xproto.h>

    /*********************************/
    /***  Wall Example Functions  ****/
    /*********************************/


/* accessform.c */
extern void acc_form(void);

/* chkerror.c */
extern int chkerror(int sts, char *string);

/* continuous.c */
extern void continuous_routine(int form_label, int gadget_label, double value, Form *form_ptr);

/* createlist.c */
extern void create_list(void);

/* createmulti.c */
extern void create_multi(void);

/* doresults.c */
extern void do_results(void);

/* main.c */
extern int Syntax(char *pn, char *arg);
extern int Sync_on(void);
extern int Sync_off(void);
extern int main(int argc, char *argv[]);

/* notify.c */
extern void notification_routine(int form_label, int gadget_label, double value, Form form);

/* switchsymbol.c */
extern void switch_symbol(Form form, int gadget_label, int sym_index);

/* wallform.c */
extern int wall_form(void);

#endif
