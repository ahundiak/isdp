#if defined(__STDC__) || defined(__cplusplus)
# define _P(s) s
#else
# define _P(s) ()
#endif


/* add_item.c */
long CLIadd_item _P((void));
long clix_add_item _P((void));
long pc_add_item _P((void));

/* can_item.c */
long CLIcancel_item_archive _P((void));
long CLIcancel_item_backup _P((void));
long CLIcancel_item_restore _P((void));
long CLIcancel_item_checkout _P((void));

/* can_set.c */
long CLIcancel_set_archive _P((void));
long CLIcancel_set_backup _P((void));
long CLIcancel_set_restore _P((void));
long CLIcancel_set_checkout _P((void));

/* chkin_i.c */
long CLIcheckin_item _P((void));

/* chkin_s.c */
long CLIcheckin_set _P((void));

/* chkout_i.c */
long CLIcheckout_item _P((void));

/* chkout_s.c */
long CLIcheckout_set _P((void));

/* connect.c */
long CLIconnect _P((void));
long CLIdisconnect _P((void));

/* copy_i.c */
long CLIcopy_item _P((void));

/* copy_s.c */
long CLIcopy_set _P((void));

/* displays.c */
long CLIdisplay_items _P((void));
long clix_display_items _P((void));
long pc_display_items _P((void));

/* edit_ai.c */
long CLIread_add_item_data _P((void));
void CLIwrite_add_item_data _P((char *filename));
long CLIedit_add_item _P((long *interactive, long *process));
void CLIshow_add_item_data _P((void));
void CLIadd_item_help _P((void));
long CLIreset_add_item_st _P((void));
long CLIedit_ai_mode _P((long *interactive, long *process, long process_mode));

/* flag_i.c */
long CLIflag_item_archive _P((void));
long CLIflag_item_backup _P((void));
long CLIflag_item_restore _P((void));

/* flag_s.c */
long CLIflag_set_archive _P((void));
long CLIflag_set_backup _P((void));
long CLIflag_set_restore _P((void));

/* globals.c */

/* login.c */
long CLIlogin _P((void));
long CLIlogout _P((void));

/* main.c */
void main _P((int argc, char **argv));
void CLIinit_all_globals _P((void));

/* process.c */
long CLIread_default_data _P((void));
void CLIwrite_default_data _P((void));
long CLIprocess_command_file _P((char *command_file));
/* HP PORT - IGI - 14 Jun 94 */
long CLIlookup_keyword _P((struct entry *keywords, char search[], long no_keywords));
short CLIequal_strings _P((char *search, char *word));
void _CLI_num _P((char *str, long var));
void _CLI_str _P((char *str, char *var));
long CLIget_key_or_command _P((char *record, char *key, char *data, long *no_words));
void CLIcheck_connect_and_login _P((void));
void CLIshow_active_data _P((void));
void CLIhelp _P((void));

/* cliprint.c */
void CLIprint _P((FILE *file_ptr, char *format, ...));

#undef _P
