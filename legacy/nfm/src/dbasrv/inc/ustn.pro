#ifndef ustn_pro
#define ustn_pro

/* From as_get.c */
extern int dba_as_get_input (
);

/* From attach_ms.c */
extern int dba_attach_ms (
);

/* From batch_dap.c */
extern int dba_batch_dap (
);

/* From build_fence.c */
extern int dba_build_fence (
  int  create_flag,
  int  *got_where,
  struct dba_ent  *ent_ptr,
  char  **s1_ptr,
  unsigned long  *s1_size,
  Form  fpt,
  int  label,
  int  row);

/* From build_ulf.c */
extern int dba_build_ulf (
  char  *filename,
  int  *input_type);

/* From connect_ustn.c */
extern int dba_connect_ustn (
);

/* From d_att_ms.c */
extern int dba_displayable_attributes_ms (
);

/* From dap_batch_ms.c */
extern int dba_dap_batch_processor_ms (
);

/* From dba_filter.c */
extern int dba_filter (
);

/* From dbd_att_dap.c */
extern int dba_attach_dap_link (
);

/* From dbd_ustation.c */
extern int dba_microstation (
  char  *comm);

/* From del_ent.c */
extern int dba_delete_entity (
  char  *entnam,
  int  mslink);

/* From disp_att.c */
extern int dba_displayable_attributes (
);

/* From e_ustn.c */
extern int dba_exit_ustn (
);

/* From el_where.c */
extern int dba_build_el_where (
  char  *ulfnam,
  int  *got_where,
  struct dba_ent  *ent_ptr,
  char  **s1_ptr,
  unsigned long  *s1_size,
  Form  fpt,
  int  label,
  int  row);
extern int dba_compare_integers (
  const void *x,
  const void *y);
extern void dba_get_where_condition_for_integer_list (
  char *att_name,
  int no_integers,
  int *integers,
  char **cond);
extern void dba_in_where_sprintf1 (
  char *tcondp,
  char *fmt,
  char *att,
  int low,
  int high,
  char **tcond,
  unsigned long *tc_size);
extern void dba_in_where_sprintf2 (
  char *tcondp,
  char *fmt,
  char *in_clause,
  char **tcond,
  unsigned long *tc_size);
extern void dba_update_in_list (
  int *first,
  int *in_flag,
  int *no_of_in_clause_items,
  char **tcondp,
  char *att_name,
  char **in_clause,
  unsigned long *in_size,
  int value);

/* From f_appl_event.c */
extern int dba_handle_appl_events (
  int  event,
  char  *ch);

/* From f_choose_rpt.c */
extern int dba_choose_report (
  int  option);

/* From fence_exists.c */
extern int dba_fence_exists (
);

/* From i_ustn.c */
extern int dba_init_ustn (
);

/* From loc_elem.c */
extern int dba_locate_elements (
  int  set,
  double  zoom,
  int  view,
  int  **file,
  int  **block,
  int  **blbyte,
  int  *total);

/* From locate_ms.c */
extern int dba_locate_ustn_graphics (
  int  set,
  int  mode,
  int  view,
  double  zoom,
  int  blink);

/* From n_ustn.c */
extern int dba_notify_ustn (
  int  form_label);

/* From process_ud.c */
extern int dba_process_userdata (
  char  **mem_ptr,
  unsigned long  *mem_size,
  int  rec_length,
  char  *ulfnam,
  long  *univ_size);
extern int dba_ulferr (
  int  status,
  int  irc);

/* From r_fnc_ms.c */
extern int dba_remove_fence_ms (
);

/* From ref_locate.c */
extern int dba_ref_locate_off (
  int  reset[]);
extern int dba_ref_locate_on (
  int  reset[]);

/* From reg_ustn.c */
extern int dba_register_microstation(
);

/* From revele_ms.c */
extern int dba_review_ustn_element (
  int  change_table,
  int  no_verify,
  int  multiple);

/* From rm_link_ms.c */
extern int dba_remove_linkage_ms(
);

/* From s_ustn.c */
extern void dba_setup_ustn (
);

/* From send_key.c */
extern int dba_send_key (
  char  *command);

/* From send_reset.c */
extern int dba_send_reset (
);

/* From ulf_mslink.c */
extern int dba_ulf_mslink (
  int  entnum,
  int  *ulfid,
  unsigned long  *mslink);

/* From ustn_done.c */
extern void dba_ustn_done (
);

/* From ustn_g.c */
extern int dba_ustn_gadgets (
  int  option);

/* From ws_add.c */
extern int dba_ws_add (
  int  *ubuf,
  int  usize,
  int  block,
  int  blbyte,
  int  file);

/* From ws_close.c */
extern int dba_ws_close (
  int  *ubuf,
  short  *ws_sector);

/* From ws_init.c */
extern int dba_ws_init (
  int  **ubuf,
  int  *usize,
  short  *ws_sector);

#endif
