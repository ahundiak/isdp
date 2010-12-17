#ifndef c_rundba_pro
#define c_rundba_pro

/* From c_cl_msg.c */
extern int dba_clear_msg (
);

/* From c_cl_pro.c */
extern int dba_clear_prompt (
);

/* From c_cre_me.c */
extern int dba_create_menu (
  int  mnunum,
  int  x,
  int  y,
  int  width,
  int  height,
  int  mask,
  int  color,
  char  *file,
  int  icon,
  int  clps_x,
  int  clps_y);

/* From c_exit.c */
extern void dba_exit_cforms (
);

/* From c_lkmnu.c */
extern int dba_lock_menu_display (
  int  locked,
  Form  fpt,
  int  mnunum);

/* From c_pr_msg.c */
extern int dba_print_msg (
  char  *message);

/* From c_pr_pro.c */
extern int dba_print_prompt (
  char  *prompt_text);

/* From c_rdba_main.c */
extern main (
  int  argc,
  char  *argv[]);

/* From c_rdba_stub.c */
extern void Enter_tools                        (
);

/* From c_rundba.c */
extern dba_c_rundba (
  int  argc,
  char  *argv[]);

#endif
