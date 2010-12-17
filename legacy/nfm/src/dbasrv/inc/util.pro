#ifndef util_pro
#define util_pro

/* From ci_dummy.c */
extern void dba_get_opt                        (
);

/* From ci_main.c */
extern main (
  int  argc,
  char  *argv[]);

/* From cl_dummy.c */
extern int dba_open_msg (
);

/* From cl_ins_key.c */
extern int cl_insert_key (
  struct dba_library  *lib_ptr,
  char  *key_ptr,
  time_t  time_val,
  int  type);

/* From cl_look_key.c */
extern int cl_lookup_key (
  struct dba_library  *lib_ptr,
  char  *key_ptr,
  int  type,
  time_t  *time_val);

/* From cl_main.c */
extern main (
  int  argc,
  char  *argv[]);

/* From cr_convert.c */
extern int cr_convert (
  char  *name,
  int  add_mode,
  int  ttype);
extern int cr_put_record (
  char  *text_ptr);

/* From cr_cvt_form.c */
extern int cr_convert_formula (
  char  *text_ptr);

/* From cr_cvt_user.c */
extern int cr_convert_user (
  char  *text_ptr);

/* From cr_dummy.c */
extern int dba_yes_no (
);

/* From cr_get_opt.c */
extern int cr_get_options (
  int  argc,
  char  *argv[]);
extern int cr_show_options (
);

/* From cr_lower.c */
extern int cr_lower (
  char  *in_string);

/* From cr_main.c */
extern main (
  int  argc,
  char  *argv[]);

/* From cr_process.c */
extern int cr_process (
);

/* From cr_trim_user.c */
extern int cr_trim_user (
  char  *text_ptr,
  int  after);

/* From dba_grab.c */
extern main(
  int  argc,
  char  *argv[]);
extern dba_g_fence(
  int  wno,
  int  *x1,
  int  *y1,
  int  *x2,
  int  *y2,
  int  erase_flag);
extern int dba_g_get_point(
  int  *x,
  int  *y,
  int  *button);
extern int dba_g_get_motion(
  int  wno,
  int  *x,
  int  *y,
  int  *event,
  int  *button);

/* From dba_to_forms.c */
extern main (
  int  argc,
  char  *argv[]);

/* From mc_dummy.c */
extern void dba_get_opt                        (
);

/* From tl_comp_lib.c */
extern int tl_compress_library (
);

/* From tl_del_temp.c */
extern int tl_delete_template (
);

/* From tl_dummy.c */
extern int dba_system (
);

/* From tl_ext_temp.c */
extern int tl_extract_template (
);

/* From tl_get_opt.c */
extern int tl_get_options (
  int  argc,
  char  *argv[]);
extern int tl_show_options (
);

/* From tl_ins_temp.c */
extern int tl_insert_template (
);

/* From tl_list_lib.c */
extern int tl_list_library (
);
extern char *tl_timestring (
  time_t  time_val);
extern int tl_set_type (
  int  *type);

/* From tl_main.c */
extern main (
  int  argc,
  char  *argv[]);

/* From tl_merge_lib.c */
extern int tl_merge_library (
);
extern int tl_copy_template (
  struct dba_library  *in_lib,
  char  *name,
  time_t  time_val,
  struct dba_library  *out_lib,
  int  type);

/* From tl_process.c */
extern int tl_process (
);

/* From tl_timestamp.c */
extern int tl_timestamp_library (
);

/* From tl_undel.c */
extern int tl_list_undeleted_templates (
);

/* From ustn_tsk.c */
extern main (
  int  argc,
  char  *argv[]);

#endif
