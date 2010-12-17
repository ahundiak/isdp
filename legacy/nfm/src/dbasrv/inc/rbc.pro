#ifndef rbc_pro
#define rbc_pro

/* From add_field.c */
extern int add_field (
  struct dba_field  *fld_ptr);

/* From add_sort.c */
extern int add_sort_field (
  struct dba_line  *sline,
  struct dba_field  *sfield,
  struct dba_field  *nfield);

/* From add_usact.c */
extern int add_user_action (
  struct dba_usact  **fusact,
  struct dba_usact  **lusact,
  char  *utext);

/* From blank_rpt.c */
extern int load_blank_report (
  struct dba_ent  *ent_ptr);

/* From change_field.c */
extern int change_field (
);

/* From check_user.c */
extern int check_user_name (
  char  *name);

/* From default_rpt.c */
extern int dba_default_report (
  struct dba_ent  *ent_ptr);

/* From delete_field.c */
extern int delete_field (
);

/* From delete_line.c */
extern int delete_line (
);

/* From i_rb.c */
extern int dba_init_rb (
);

/* From layout_form.c */
extern int dba_layout_form (
  int  option);

/* From s_rb.c */
extern void dba_setup_rb (
);

/* From set_cfield.c */
extern int set_current_field (
);

/* From sort_delete.c */
extern int delete_sort_line (
  struct dba_line  *dline);
extern int undelete_sort_line (
  struct dba_line  *dline);

/* From space.c */
extern int delete_space (
);
extern int dba_insert_space (
);

/* From undelete.c */
extern int undelete_line (
);
extern int undelete_field (
);
extern int dba_copy_line_field (
  struct dba_line  *nline,
  struct dba_line  *dline);
extern int dba_copy_line_ua (
  struct dba_line  *to_line,
  struct dba_line  *from_line);

/* From up_fldtxt.c */
extern int update_field_text (
  struct dba_field  *fld_ptr);

/* From up_srttxt.c */
extern int update_sort_text (
  struct dba_field  *fld_ptr,
  int  sort_num);

/* From write_struct.c */
extern int dba_write_structure (
  char  *library,
  char  *template,
  int  verify_lib,
  int  verify_temp);

#endif
