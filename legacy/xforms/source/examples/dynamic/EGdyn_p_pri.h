/****************************************************************/
/* EGdyn_p_pri.h -                                             */
/*    This is the X/Forms (XFORMSDP SN01252) ANSI-C             */
/*    function prototype header file for private functions      */
/****************************************************************/
/* Copyright 1992 Intergraph Corporation                        */
/* All Rights Reserved, Including this Release Note, the        */
/* Product it Describes, its File Formats, and Visual Displays  */
/****************************************************************/


#ifndef EGDYN_P_PRI_H_INCLUDED 
#define EGDYN_P_PRI_H_INCLUDED 1

#include <X11/Xproto.h>

    /************************************/
    /***  Dynamic Example Functions  ****/
    /************************************/


/* chkerror.c */
extern int chkerror(int sts, char *string);

/* command.c */
extern int process_menu_command(int cmd_type, char *cmd);

/* do_cbar.c */
extern void do_cbar(void);

/* dobezel.c */
extern void do_bezel(void);

/* dobutton.c */
extern void do_button(void);

/* docheck.c */
extern void do_check(void);

/* dodial.c */
extern void do_dial(void);

/* dofield.c */
extern void do_field(void);

/* doform.c */
extern void do_form(int action);

/* dogauge.c */
extern void do_gauge(void);

/* doline.c */
extern void do_line(void);

/* domcf.c */
extern void do_mcf(void);

/* doscroll.c */
extern void do_scroll(void);

/* doslider.c */
extern void do_slider(void);

/* dosym.c */
extern void do_sym(void);

/* dotext.c */
extern void do_text(void);

/* dotoggle.c */
extern void do_toggle(void);

/* main.c */
extern int Syntax(char *pn, char *arg);
extern int Sync_on(void);
extern int Sync_off(void);
extern int main(int argc, char *argv[]);

/* notify.c */
extern void notification_routine(int form_label, int gadget_label, double value, Form form);

#endif
