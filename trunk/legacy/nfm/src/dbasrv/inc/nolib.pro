#ifndef nolib_pro
#define nolib_pro

/* From dba_main.c */
extern main (
  int  argc,
  char  *argv[]);

/* From form_new.c */
extern int dba_menu_new (
  int  label,
  char  *name,
  int  (*notify)(),
  Form  *fpt);

/* From ftr_stub.c */
extern void NFT_delete_entry                   (
);

/* From mm_risrpt.c */
extern int main_menu (
  int  option);

/* From mm_rundba.c */
extern int main_menu (
  int  option);

/* From risrpt_main.c */
extern main (
  int  argc,
  char  *argv[]);

/* From risrpt_rt.c */
extern main (
  int  argc,
  char  *argv[]);
extern int main_menu (
  int  option);

/* From rundba_main.c */
extern main (
  int  argc,
  char  *argv[]);

/* From sco_stub.c */
extern void dba_call_var_args                   (
);

/* From sol_stub.c */
extern void dba_call_var_args                   (
);

/* From stop_dummy.c */
extern void dba_init_notify(
);

/* From x_stop_dummy.c */
extern void dba_display_raster(
);

/* From xras_stub.c */

#endif
