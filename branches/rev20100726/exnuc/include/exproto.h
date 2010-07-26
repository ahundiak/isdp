#ifndef exproto_include
#define exproto_include

#ifndef OM_D_MINIMUM
#include <OMminimum.h>
#endif
#ifndef ex_include
#include <ex.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#include <wl.h>

#ifdef X11
#include <X11/Xlib.h>
#if 0
#include <X11/Intrinsic.h>  /* opp bug */
#endif
#if defined (SUNOS5) || defined (IRIX)
#undef index
#undef rindex
#endif
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif
/*button.C*/
extern int EX_load_button __((long *msg, char *filename));

/* exfork.C */
extern int EX_fork __((int num_entry, char *argu[], int wait_flag, int redir_io, int *childpid, int mask, char *np1, char *np2, int delete_flag));

/* execi.I */
extern int close_visible __((int save_flag, OM_S_OBJID my_id));
extern int EX_execute_mod __((void));
extern int EX_start_cmdserver __((int init, int exec));
extern int EX_save_backup_file __((char *file_name));
extern int EX_stop_auto_backup __((void));
extern int EX_context_switch_to __((char *exec_name));
extern int EX_context_switch_1 __((char *exec_name));
extern int EX_set_logo __((char *logo));
extern int EX_get_mloc_file __((char *file_name, int *have_file));
extern int EX_exit_function __((int (*function_to_execute )(), int (**function_previous )()));


/* execj.I */
extern int EX_findmod __((OM_S_OBJID *objid, uword *osnum));
extern int EX_get_exec_id __((OM_S_OBJID *objid, uword *osnum));
extern int EX_conv_pnt __((int window, struct EX_button *pnt1, int *response));
extern int EX_get_win_class __((int hw_win_no, char *class_name));
#if defined (ENV5)
extern int EX_trans_win __((int hw_win, WLuint32 *lwin,
                            OMuword *win_os,OM_S_OBJID *win_oid));
#elif defined (X11)
extern int EX_trans_win __((unsigned int hw_win, WLuint32 *lwin,
                            OMuword *win_os,OM_S_OBJID *win_oid));
#endif
extern int EX_add_win __((int hw_win_no, OM_S_OBJID objid, OMuword osnum));
extern int EX_set_abs_dig __((int fm));
extern int EX_clear_abs_dig __((void));
extern int EX_wait_for_input __((int *response, char *response_data, int mode, int *num_bytes));
extern int EX_attach_listener __((OM_S_OBJID objid, OMuword osnum));
extern int EX_detach_listener __((OM_S_OBJID objid, OMuword osnum));
extern int EX_attach_generator __((OM_S_OBJID objid, OMuword osnum));
extern int EX_detach_generator __((OM_S_OBJID objid, OMuword osnum));
extern int EX_get_NOD __((char *NODname, OM_S_OBJID *pobjid, int create, OM_S_OBJID modid, OMuword mosnum));
extern int EX_get_oid_nodname __((char *NODname, char *objname, OM_S_OBJID *pobjid, OM_S_OBJID modid, OMuword mosnum, int errprint));
extern int EX_add_name_nodname __((char *NODname, char *objname, OM_S_OBJID objid, OMuword mosnum));
extern int EX_remove_name_nodname __((char *NODname, char *objname, OMuword mosnum));
extern int EX_get_oid_nodid __((OM_S_OBJID NODobjid, char *objname, OM_S_OBJID *pobjid, OM_S_OBJID modid, OMuword mosnum));
extern int EX_add_name_nodid __((OM_S_OBJID NODobjid, char *objname, OM_S_OBJID objid, OMuword mosnum));
extern int EX_remove_name_nodid __((OM_S_OBJID NODobjid, char *objname, OMuword mosnum));
extern int EX_attach_super __((IGRchar *super_class, OM_S_OBJID *super_id,
               OM_S_OBJID module_id, OMuword module_os,int wakeup_flag));
extern int EX_get_global __((IGRint mode, struct EX_var_list *var, IGRint *which_error));
extern int EX_inq_global __((struct EX_var_list *var, IGRint *which_error));
extern int EX_set_global __((struct EX_var_list *var, IGRint *which_error));
extern int EX_file_status __((OM_S_OBJID modid, uword modos, int *mode));
extern int EX_get_invis_info_by_index __((int index, OMuword *mod_osnum, OM_S_OBJID *mod_id, OM_S_OBJID *filed_id, int *flag, int *num_open, int *mod_type));
extern int EX_is_visible __((char *mod_name));
extern int EX_is_invis __((OMuword mod_osnum, int *index));
extern int EX_is_driver_exist __((void));
extern void EX_set_mod_no_scn_menu __((OMuword mod_osnum));
extern int EX_is_scn_menu_present __((void));
extern void EX_print_module_table __((void));
extern int EX_get_modid_given_osnum __((OMuword mod_osnum, OM_S_OBJID *mod_id));
extern int EX_get_super __((OM_S_OBJID mod_id, OMuword mod_osnum,
                           char *super_name, int create, char *super_classname,
                           OM_S_OBJID *super_id, OMuword *super_osnum,
                           int wakeup_flag));
extern int EX_mod_info __((OMuword mod_osnum, int mode, char *app, int applen));
extern int EX_is_help_active __((void));
extern int EX_help_flag __((int mode, int *flag));
extern int EX_help_on __((int *oldflag));
extern int EX_help_off __((int *oldflag));
extern int EX_disp_flag __((int mode, int *flag));
extern int EX_disp_on __((int *oldflag));
extern int EX_disp_off __((int *oldflag));
extern int EX_is_file_open __((char *filename));
extern int EX_get_file_path __((char *env, char *string, char *outfile, int *ftype, int size));
extern int EX_check_input __((void));
extern int EX_check_input __((void));
extern int EX_set_up_file __((char *filename, char *seedfile, char *firstcmd, int *create));
extern int EX_get_file_default __((char *filename, char *seedfile, char *firstcmd, int *create));
extern int EX_call_firstcmd __((void));
extern int EX_firstcmd_putque __((char *field, int type));
extern int EX_build_classlist __((char *classnames[], int size, OM_p_CLASSLIST p_clist));
extern int EX_get_working_dir __((char *name, int *len));
extern int EX_get_support_dir __((char *name, int *len));


/* exgetptr.C */
extern int EX_cmdgetptr __((char *instring, char **outstring));
extern int EX_cmdfreeptr __((void));

/* exintr.C */
extern void EX_interrupt_hup __((int signo));
extern void EX_interrupt_int __((int signo));
extern void EX_interrupt_quit __((int signo));
extern void EX_interrupt_iot __((int signo));
extern void EX_interrupt_emt __((int signo));
extern void EX_interrupt_fpe __((int signo));
extern void EX_interrupt_ill __((int signo));
extern void EX_interrupt_bus __((int signo));
extern void EX_interrupt_segv __((int signo));
extern void EX_interrupt_sys __((int signo));
extern void EX_interrupt_pipe __((int signo));
extern void EX_interrupt_term __((int signo));

/* exrececho.C */
extern int EX_init_rec_echo __((char *filename));
extern int EX_init_record __((char *filename));
extern int EX_init_echo __((char *filename));
extern int EX_close_rec_echo __((int flag));
extern int EX_clear_jnl_on_save __((void));
extern int EX_store_window_on_save __((void));
extern int EX_clear_command_on_save __((void));
extern int EX_restart_journal __((void));

/* exsharem.I */
extern int EX_mem_exist __((void));
extern int EX_add_mem __((char *mem_name, unsigned long int mem_val));
extern int EX_get_mem __((char *mem_name, unsigned long int *mem_val));
extern int EX_del_mem __((char *mem_name));
extern void EX_print_mem __((void));
extern void EX_free_mem __((void));

/* exsys.C */
extern int EX_mv __((char *source, char *target));
extern int EX_cp __((char *source, char *target));
extern int EX_rm __((char *file1));

/* extran.C */
extern void EX_add_fun __((struct EX_funnode **phead, int isfunc, void *f ));
extern void EX_del_fun __((struct EX_funnode **phead, int (*f)()));
extern void EX_empty_fun __((struct EX_funnode **phead));
extern void EX_print_fun __((struct EX_funnode **phead));
extern int EX_add_function __((int (*fun )(), int mode));
extern int EX_del_function __((int (*fun )(), int mode));
extern int EX_call_start_func __((void));
extern int EX_call_end_func __((void));
extern int EX_add_cmdserver_function __((int (*fun )()));
extern int EX_del_cmdserver_function __((int (*fun )()));
extern int EX_call_cmdserver_func __((int mode));
extern char *EX_get_and_del_first_fun __((struct EX_funnode **phead));

/* exwfi.I */
#ifndef X11
extern int EX_record_new_window __((int window));
#else
extern int EX_record_new_window __((Window window));
#endif
extern int EX_dyn_process_input_event __((int mask));
extern int EX_wait_for_next __((int mask, int *event));
extern int EX_inq_events __((int *event));
extern int EX_inq_button_data __((int *window, int *x, int *y, int *btype, int *state, int *timetag));
extern int EX_get_button_data __((int *window, int *x, int *y, int *btype, int *state, int *timetag));
extern int EX_get_refresh_area_data __((int *window, int *vs_no, int *x, int *y, int *x2, int *y2, int *ax1, int *ay1, int *ax2, int *ay2, int *opmask));
extern int EX_inq_refresh_area_data __((int *window, int *vs_no, int *x, int *y, int *x2, int *y2, int *ax1, int *ay1, int *ax2, int *ay2, int *opmask));
extern int EX_get_collapse_data __((int *window, int *opmask));
extern int EX_inq_collapse_data __((int *window, int *opmask));
extern int EX_get_delete_data __((int *window));
extern int EX_inq_delete_data __((int *window));
extern int EX_set_keyboard_buffer __((char *buffer, int count));
extern int EX_get_keyboard_data __((int *count));
extern int EX_inq_keyboard_data __((int *count));
extern int EX_dyn_process_input_event __((int mask));

/* file_backup.I */
extern int backup_filenames __((int mod_num, char *nfile, char *file));
extern int module_backup __((OM_S_OBJID my_id));
extern int remove_backup __((char *file));

/* file_test.C */
extern int file_exists __((char *fname, char *env, char *path_dir, char *ret_fname));
extern int filetest __((void));
extern int EX_check_file __((char *filename, int print_flag));
extern int EX_is_reg_file __((char *filename));

/* global_clasi.I */

/* igestartup.I */
extern void IGEExit __((int status));
extern int IGE_startup __((int argc, char *argv[], int mode));
#ifdef X11
extern int IGEEnter __((int argc, char *argv[]));
#else
extern int IGEEnter __((void));
#endif
extern void EX_set_sync __((void));
extern void EX_sync_on __((void));
extern void EX_sync_off __((void));
extern int EX_is_batch __((void));
extern int EX_is_interactive __((void));
extern void EX_clear_timing __((void));
extern void EX_start_timing __((void));
extern void EX_end_timing __((char *string));
extern void EX_print_timing __((void));
#ifdef RUNX
extern void EX_change_screen __((Widget w, caddr_t client_data, caddr_t call_data));
extern void ButtonCB __((Widget w, caddr_t client_data, caddr_t call_data));
extern int EX_PrintDefaultError __((Display *dpy, XErrorEvent *event));
extern int EX_DefaultIOError __((Display *dpy));
#endif
/* invis_funcs.I */
extern int get_modtype_data  __((char *run_name,
                                 char *logo_ptr,
                                 char  *module_class,
                                 char *srch_path,
                                 char *config_path,
                                 char *product_path));
extern int Retrieve_OS __((char *in_filename, int flags, int *file_no, int type, int *msg, char *mount_name));
extern int Retrieve_new_OS __((char *in_filename, int flags, int mod_type, int *file_no, int type, int *msg, char *mount_name));
extern int Close_OS __((int mod_num, int flag));
extern int Save_OS __((int mod_num));
extern int Save_As_OS __((int mod_num, char *filename));
extern int EX_retrieve_os __((char *in_filename, int flag, int mod_type, int *file_no, int f_stat, int type, int *msg, char *mount_name));
extern int print_invis __((void));

/* journal.c */
#ifdef ENV5
extern int JNL_init_journal __((char *filename, int excl_flag));
extern int JNL_init_playback __((char *filename, char *runname));
extern int JNL_echo_read_event_func __((void));
extern int JNL_record_new_window __((int window));
extern int JNL_echo_event __((int mask, int *event));
extern int JNL_process_info_event __((int new_window));
extern int JNL_process_del_info_event __((void));
extern int JNL_record_info_event __((int type, int event_nbytes, char *string));
extern int JNL_record_event __((int event));
extern int JNL_close_jnl __((void));
extern int JNL_close_jnl_pbk __((void));
extern int JNL_close_echo __((void));
extern int JNL_record_input __((int nbytes, char *buffer));
extern int JNL_echo_input __((int nbytes, char *buffer));
extern int JNL_adjust_echo __((void));
extern int JNL_adjust_echo_button __((void));
extern int JNL_adjust_echo_refresh_button __((void));
extern int JNL_adjust_echo_collapse_button __((void));
extern int JNL_adjust_delete_button __((void));
extern int JNL_wait_for_next __((int mask, int *event));
extern int JNL_inq_events __((int *event));
extern int JNL_inq_button_data __((int *window, int *x, int *y, int *btype, int *state, int *timetag));
extern int JNL_get_button_data __((int *window, int *x, int *y, int *btype, int *state, int *timetag));
extern int JNL_process_slow_echo __((void));
extern int JNL_oldwindow_to_window __((int oldwindow, int *window));
extern int JNL_get_refresh_area_data __((int *window, int *vs_no, int *x, int *y, int *x2, int *y2, int *ax1, int *ay1, int *ax2, int *ay2, int *opmask));
extern int JNL_inq_refresh_area_data __((int *window, int *vs_no, int *x, int *y, int *x2, int *y2, int *ax1, int *ay1, int *ax2, int *ay2, int *opmask));
extern int JNL_get_collapse_data __((int *window, int *opmask));
extern int JNL_inq_collapse_data __((int *window, int *opmask));
extern int JNL_get_delete_data __((int *window));
extern int JNL_inq_delete_data __((int *window));
extern int JNL_inq_user_data __((int *user_data));
extern int JNL_get_user_data __((int *user_data));
extern int JNL_inq_win_user_icon_data __((int *window, int *icon_id));
extern int JNL_get_win_user_icon_data __((int *window, int *icon_id));
extern int JNL_start_timer __((int delta_time, int repeatflag, int *timer_no));
extern int JNL_stop_timer __((int timer_no));
extern int JNL_get_timer_data __((int *timer_no));
extern int JNL_echo_timer_data __((int *timer_no));
extern int JNL_record_timer_data __((int *timer_no));
extern int JNL_set_keyboard_buffer __((char *buffer, int count));
extern int JNL_get_keyboard_data __((int *count));
extern int JNL_inq_keyboard_data __((int *count));
extern int JNL_inq_keyboard_buffer __((char *buf_addr[], int *count));
extern int JNL_set_timer_playback __((int mytime));
extern int JNL_playback __((void));
extern int JNL_journal __((void));
#endif
#ifdef X11
extern int JNL_init_journal __((char *filename, int excl_flag));
extern int JNL_init_playback __((char *filename, char *runname));
extern int JNL_XPending __((Display *display));
extern int JNL_save_panel __((void));
extern int JNL_playback __((void));
extern int JNL_journal __((void));
extern int JNL_XCreateWindow __((Display *display, Window parent, int x, int y, unsigned int width, unsigned int height, unsigned int border_width, int depth, unsigned int class, Visual *visual, unsigned long valuemask, XSetWindowAttributes *attributes));
extern int JNL_record_runtime_forms __((void));
extern int JNL_record_new_window __((Window window));
extern int JNL_XWithdrawWindow __((Display *display, Window w, int screen_no));
extern int JNL_XUnmapWindow __((Display *display, Window w));
extern int JNL_XMapWindow __((Display *display, Window w));
extern int JNL_XMapRaised __((Display *display, Window w));
extern int JNL_XNextEvent __((Display *display, XEvent *xevent));
#if 0
extern void JNL_XtAppNextEvent __((XtAppContext appContext, XEvent *xevent));
#else
extern void JNL_XtAppNextEvent __(());
#endif
extern int JNL_XGrabPointer __((Display *display, Window grab_window, Bool owner_events, unsigned int event_mask, int pointer_mode, int keyboard_mode, Window confine_to, Cursor cursor, Time time));
extern int JNL_XUngrabPointer __((Display *display, Time time));
extern int JNL_XCheckTypedEvent __((Display *display, int event_type, XEvent *xevent));
extern int JNL_XCheckTypedWindowEvent __((Display *display, Window w, int event_type, XEvent *xevent));
extern int JNL_XCheckMaskEvent __((Display *display, long event_mask, XEvent *xevent));
extern int JNL_XCheckWindowEvent __((Display *display, Window w, long event_mask, XEvent *xevent));
extern int JNL_XWindowEvent __((Display *display, Window w, long event_mask, XEvent *xevent));
extern int JNL_XMaskEvent __((Display *display, long event_mask, XEvent *xevent));
extern int JNL_XCheckIfEvent __((Display *display, XEvent *xevent, Bool (*predicate )(), char *arg));
extern int JNL_XPeekIfEvent __((Display *display, XEvent *xevent, Bool (*predicate )(), char *arg));
extern int JNL_XIfEvent __((Display *display, XEvent *xevent, Bool (*predicate )(), char *arg));
extern int JNL_clear_windows __((void));
extern int JNL_read_next_event __((XEvent *xevent));
extern int JNL_record_next_event __((XEvent *xevent, int record_flag));
extern int JNL_XPeekEvent __((Display *display, XEvent *xevent));
extern int JNL_peek_next_event __((XEvent *xevent));
extern int JNL_XPutBackEvent __((Display *display, XEvent *xevent));
extern int JNL_read_button_count __((int *count));
extern int JNL_record_info_event __((int type, int event_nbytes, char string[]));
extern int JNL_if_read_button_count __((int *count, XEvent *xevent));
extern int JNL_close_jnl __((void));
extern int JNL_close_jnl_pbk __((void));
extern int JNL_close_echo __((void));
extern int JNL_record_input __((int nbytes, char *buffer));
extern int JNL_echo_input __((int nbytes, char *buffer));
extern int JNL_oldwindow_to_window __((XEvent *xevent));
extern int JNL_process_slow_echo __((void));
#endif

/* set_paths.C */
extern int module_build_path __((char *path_name));
extern int module_set_pathname __((char *string));
extern int module_set_def_dir __((void));
extern int fix_directory __((char *string));
extern int module_get_def_dir __((int argc, char *argv[]));
extern int valid_filename __((char *str, char *path));
extern int EX_check_stat __((char *path, int *ftype));
extern int EX_use_default_dir __((void));
extern int EX_get_executable_path __((char *path));
extern int EX_get_user_srch_path __((char *path));

/* srch_path.C */
extern int EX_set_srch_path __((void));
extern int EX_get_srch_path1 __((char *runname, int flag, char *buff, int *size));
extern int EX_getpath __((int index, char *path, int len, int type));
extern int EX_get_srch_path __((char **path, int *num_entry));
extern int EX_set_search_path __((char *path));
extern int EX_restore_search_path __((void));

/* cmdserveri.I */
extern int EX_is_cmd_stack_empty __((void));
extern int EX_set_cmdserver_debug __((void));
extern int EX_help_init __((void));
extern int EX_blank_msg __((void));
extern int EX_ci_test_start __((char *filename));
extern int EX_ci_test_end __((void));
extern int EX_set_auto_jump __((void));
extern int EX_jump __((void));
extern int EX_is_auto_jump __((void));
extern int EX_is_auto_test __((void));
extern int EX_auto_test_print_err __((int signo));
extern int EX_cmdserver_save_last_cmd __((void));

/* attach.C */
extern int EX_print_cmd __((char *file_name));
extern int EX_dload_setup __((char *dload_name_ptr, char ***argv_ptr, int *argc_ptr));
extern int EX_dload_free __((void));


/* detach.C */
extern IGRint EX_cmddetach __((IGRlong *msg, IGRlong module_type));


/* quiet.C */
extern void EX_push_quiet __((int respon));
extern void EX_pop_quiet __((void));
extern void EX_swap_quiet __((void));
extern void EX_clear_quiet __((void));
extern void EX_print_quiet __((void));

/* search.C */
extern int CSclear_cache __((void));
extern int CSadd_to_cache __((char *name, int indx));
extern int CSget_from_cache __((char *name, int *p_indx));
extern int CSdump_cache __((void));


/* strip.C */
extern int EX_cmdstrip __((unsigned char *keyin));

/* exerror.C */
extern int UI_error __((char *msg));

/* filters.C */
extern int EX_get_keyin __((int *response, char *response_data, int mode));
extern int EX_keyin_no_cmd __((int *response, char *response_data, int mode));
extern int EX_get_input __((int *response, char *response_data, int mode));


/* messages.C */
extern void UI_message __((char *symstr));
extern void UI_status __((char *symstr));
extern void UI_prompt __((char *symstr));
extern void UI_echo __((char *symstr));

/* special.C */
extern int special_keyin __((int *response, char *response_data));

/* squeue.C */
extern IGRint EXgetq __((IGRlong *return_code, int *response, IGRint *bytes_returned, IGRchar *buffer));
extern IGRint EXputq __((IGRlong *msg, IGRlong position, int *response, IGRlong *byte_count, IGRchar *buffer));
extern IGRint EXputq2 __((IGRlong *msg, IGRlong position, int *response, IGRlong *byte_count, IGRchar *buffer, IGRint mode));
extern IGRint EXputq_back __((IGRlong *msg, int *response, IGRlong *byte_count, IGRchar *buffer));
extern IGRint EXputq_front __((IGRlong *msg, int *response, IGRlong *byte_count, IGRchar *buffer));
extern int print_queue __((void));
extern int EX_flush_event_queue __((void));
extern int EX_peek_event_queue __((int *resp));

/* waitmsg.C */
extern void EX_start_copyright __((void));
extern int EX_end_copyright __((void));
#ifdef RUNX
extern int EXget_decoration __((Window w, int x, int y, int *xdecor, int *ydecor, int *xoffset, int *yoffset));
#endif
/*extern int MS_store_status __((Form form, char *message));
extern int EX_fi_message_strip __((int form, int label, double value, Form M_form));*/
extern int EXget_form_decoration __((int *xdecor, int *ydecor));
extern int EXget_form_offset __((int *xoffset, int *yoffset));
/*extern int EXposition_form __((Form form_p, int position));*/

/* wfi.C */
extern int EX_extract_string __((void));
extern int EX_clean_str __((char *x, int no_space, int lower));

/* messages.C */
extern void UI_message __((char *symstr));
extern void UI_status __((char *symstr));
extern void UI_prompt __((char *symstr));
extern void UI_echo __((char *symstr));

/* filters.C */
extern int EX_get_keyin __((int *response, char *response_data, int mode));
extern int EX_keyin_no_cmd __((int *response, char *response_data, int mode));
extern int EX_get_input __((int *response, char *response_data, int mode));

/* keyin.C */
extern int EX_init_keyboard __((void));
extern IGRint EX_load_funckey __((int type, IGRchar *file_name));
extern int EX_update_funcky __((IGRchar *keynam, IGRint response, IGRshort waitf, IGRchar *key_str));
extern int pad_escape __((char *buffer, char *outbuffer));
extern int strip_esc_key __((char *response_data));
extern int EX_keybd_process_return __((char *response_data, int num_char));
extern int EX_clear_keyin __((void));
extern int EX_clear_keyin __((void));
extern int EX_is_logkbd_inactive __((void));
extern int EX_cut_calc_input __((void));
extern int EX_paste_calc_input __((void));


extern int EX_module_construct __((int *msg, uword os_num, OM_S_OBJID filed_id, int new_module, int read_only, int activate, OM_S_OBJID *mod_id));
extern int EX_get_seed_file __((char *seedfile, char *temp_file));
extern int EX_retrieve_module __((int *msg, char *inputstring, char *seedfile, int create, int activate, int save, OMuword *osnum, OM_S_OBJID *modid));
extern int EX_retrieve_function __((int (*function_to_execute )(), int (**function_previous )()));

/* EX_saveasi.I */
extern int EXupdatable_exist __((void));

/* EX_savei.I*/
extern int EX_save_module __((int active_module_num , int flag));

/* modulei.I */
extern int EX_is_temp_wakeup __((void));
extern void EX_init_session __((void));

/* ??? */
extern int EX_close1 __((int *last, int flag));
extern int EX_create_prompt __((int message_number, int left_prompt_number,
                int right_prompt_number, char *string, int *response,
                char *response_data));
extern void EX_exit1 __((int save));
extern int EX_filename1 __((char *result, int len));
extern int EX_get_cmd_info __((char *string, int mode, struct EX_cmd *cmdstr));
extern int EX_save1 __((char *fname));
extern int EX_saveas1 __((char *string));
extern int EXget_file __((char *title, char *startdir, char *in_file,
                char *pat, int file_type[], char *returned_filename,
                char *seedfile, int form_type, int *response,
                char *response_data));
extern int EX_get_prod_info __((char *product, int code, char **pstring));
extern int EX_get_prod_flag __((char *logo, int code, int flag));
extern int EX_get_prod_data __((char *runnameIn, char *logoIn,
                char *runnameOut, char *logoOut, char *module,
                char *dependency, char *configPath, char *prodPath,
                int *flags));

#if defined(__cplusplus)
}
#endif

#endif
