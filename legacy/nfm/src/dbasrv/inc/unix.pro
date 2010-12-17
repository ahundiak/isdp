#ifndef unix_pro
#define unix_pro

/* From call_var_arg.c */
extern void dba_call_var_args (
  void  (*func)(),
  long  num,
  void  **args,
  char  *types,
  void  *retval,
  long  rettype,
  int  is_pascal);

/* From crshpruf.c */
extern char *dba_crash_getmsg (
);
extern int dba_crashproof_char (
  char  *str,
  char  *ptr);
extern int dba_crashproof_short (
  char  *str,
  char  *fmt,
  short  *ptr);
extern int dba_crashproof_long (
  char  *str,
  char  *fmt,
  long  *ptr);
extern int dba_crashproof_float (
  char  *str,
  char  *fmt,
  float  *ptr);
extern int dba_crashproof_double (
  char  *str,
  char  *fmt,
  double  *ptr);
extern int dba_crashproof_lvoid (
  char  *str,
  char  *fmt,
  lvoid  *lvp);
extern int dba_crashproof_assign (
  void  **dest,
  void  **src);
extern int dba_crashproof_fld_txt (
  Form  form,
  int  lab,
  int  row,
  int  col,
  char  *text,
  int  sel);

/* From direct.c */
extern int dba_opendir(
  char  *string);
extern int dba_readdir(
  char  *name);
extern int dba_closedir(
);

/* From dirlist.c */
extern int dba_build_dir_list (
  char  *menu,
  int  label,
  char  *path);
extern int dba_build_file_list (
  char  *menu,
  int  label,
  char  *path);

/* From dload.c */
extern void dba_init_dloading (
  int  flag);
extern int dba_dload2 (
  char  *path,
  int  options);
extern int dba_dload (
  char  *path);
extern void *dba_lookup_func_symbol (
  char  *name);
extern void *dba_lookup_var_symbol (
  char  *name);
extern int dba_dload_incremental (
  char  *path);
extern int dba_dload_complete (
);

/* From dload20.c */
extern void dba_init_dloading (
  int  flag);
extern int dba_dload (
  char  *path);
extern void *dba_lookup_func_symbol (
  char  *name);
extern void *dba_lookup_var_symbol (
  char  *name);
extern int dba_dload_incremental (
  char  *path);
extern int dba_dload_complete (
);

/* From file_lock.c */
extern int dba_file_lock(
  int fd,
  char *mode);
extern int dba_file_unlock(
  int fd);

/* From fnd_dir.c */
extern int dba_find_dirs(
  char  *dir_buf,
  char  *usr_buf,
  int   fresh_start);

/* From fnd_file.c */
extern int dba_find_files(
  char  *file_buf,
  char  *usr_buf,
  int   fresh_start);

/* From font_lst.c */
extern void build_font_list (
  Form  fpt,
  int  label);

/* From interrupt.c */
extern void dba_interrupt (
);

/* From license.c */
extern dba_get_license (
);
extern dba_return_license (
);

/* From print.c */
extern int dba_printf(
);
extern int dba_dprintf(
);

/* From pubtst.c */
extern int dba_pub_test (
);

/* From sleep.c */
extern int dba_sleep(
  int  val);

/* From spell.c */
extern int dba_spellcheck (
  char  *string);

/* From start_help.c */
extern int dba_start_help (
  int  option);

/* From stop.c */
extern main (
  int  argc,
  char  *argv[]);

/* From system.c */
extern int dba_system (
  char  *command);

/* From tmpnam.c */
extern int dba_tmpnam (
  char  *file);

/* From usleep.c */
extern int dba_usleep(
  int  val);

/* From ustn_wait.c */
extern int dba_microstation_wait (
  char  *command);

#endif
