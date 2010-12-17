/* can_item.c */
long CLIcancel_item_archive (void);
long CLIcancel_item_backup (void);
long CLIcancel_item_restore (void);
long CLIcancel_item_checkout (void);

/* can_set.c */
long CLIcancel_set_archive (void);
long CLIcancel_set_backup (void);
long CLIcancel_set_restore (void);
long CLIcancel_set_checkout (void);

/* chkin_i.c */
long CLIcheckin_item (void);

/* chkin_s.c */
long CLIcheckin_set (void);

/* chkout_i.c */
long CLIcheckout_item (void);

/* chkout_s.c */
long CLIcheckout_set (void);

/* connect.c */
long CLIconnect (void);
long CLIdisconnect (void);

/* copy_i.c */
long CLIcopy_item (void);

/* copy_s.c */
long CLIcopy_set (void);

/* di_ftp.c */
int DoFTP (char *path_name, char *server, int which_nfs);

/* fileserv.c */
long NFMpcfile_server (void);
long _NFMpcfs_send_files (void);
long NFMpcrm_co_files (void);
long _NFMpcfs_recv_files (void);
long NFMpcfs_undo_recv_files (void);
long NFMpcfs_undo_send_files (void);
long NFMpcfs_chg_files (void);
long NFMpcfs_undo_chg_files (void);
long NFMpcfs_purge (void);
void r50asc (int length, short *input, char *output);
long NFMpcfs_attached_files (void);
long _NFMsend_buf_pc_fs_by_row (char *list);
long _NFMpc_display_items ( void );

/* flag_i.c */
long CLIflag_item_archive (void);
long CLIflag_item_backup (void);
long CLIflag_item_restore (void);

/* flag_s.c */
long CLIflag_set_archive (void);
long CLIflag_set_backup (void);
long CLIflag_set_restore (void);

/* flib.c */
int mkclient (char *node, int port);
int client_read (int fd, char *buf, int nfsbytes, int *flag);
int client_write (int fd, char *buf, int nfsbytes, int flag);
int client_stop (int fd);
int client_init (char *node, int port, long client_id);
int get_tcp (char *srv_node, char *address);
int client_send (int fd, char *buf, long bytes);
int client_recv_size (int fd, long *size);
int client_recv (int fd, char *buf);

/* ftpscan.c */
long NFMcount_ftp_output (char *out_file, long *rfilesize);
long NFMscan_ftp_output (char *out_file);
long NFMscan_ftp_output1 (char *out_file);

/* getopt.c */
char getopt (int argc, char **argv, char *opts);

/* globals.c */

/* login.c */
long CLIlogin (void);
long CLIlogout (void);

/* main.c */
void main (int argc, char **argv);
void CLIinit_all_globals (void) ;

/* nettools.c */
long NETbuffer_receive (char *buffer, long *bytes);
long NETbuffer_send (char *buffer, long *bytes);

/* nfmrfunc.c */
long ERRget_message ( char *msg );
long NFMRcheckin_item (char *catalog, long cat_num, char *item, char *rev, char *storage, struct NFMwf_info wf_info, struct NFMoperation operation);
long NFMRcheckout_item (char *catalog, long cat_num, char *item, char *rev, char *storage, struct NFMwf_info wf_info, struct NFMoperation operation);
long NFMRcheckin_set (char *catalog, long cat_num, char *set, char *rev, long set_num, char *storage, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level);
long NFMRcheckout_set (char *catalog, long cat_num, char *set, char *rev, long set_num, char *storage, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level);
long NFMRcopy_item (char *catalog, long cat_num, char *item, char *rev, char *storage, struct NFMwf_info wf_info, struct NFMoperation operation);
long NFMRcopy_set (char *catalog, long cat_num, char *set, char *rev, long set_num, char *storage, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level);
long NFMRflag_item_archive (long user_id, char *catalog, char *item, char *rev);
long NFMRflag_item_backup (long user_id, char *catalog, char *item, char *rev);
long NFMRflag_item_restore (long user_id, char *catalog, char *item, char *rev);
long NFMRflag_set_archive (long user_id, char *catalog, char *set, char *rev);
long NFMRflag_set_backup (long user_id, char *catalog, char *set, char *rev);
long NFMRflag_set_restore (long user_id, char *catalog, char *set, char *rev);
long NFMRcancel_item_archive_flag (long user_id, char *catalog, char *item, char *rev);
long NFMRcancel_item_backup_flag (long user_id, char *catalog, char *item, char *rev);
long NFMRcancel_item_restore_flag (long user_id, char *catalog, char *item, char *rev);
long NFMRcancel_set_archive_flag (long user_id, char *catalog, char *set, char *rev);
long NFMRcancel_set_backup_flag (long user_id, char *catalog, char *set, char *rev);
long NFMRcancel_set_restore_flag (long user_id, char *catalog, char *set, char *rev);
long NFMRpc_post_log_in (char internet_address[31 ], char default_st_area[16 ], char cwd[51 ], char nfs_node[2 ], char nfs_sa[2 ]);
long NFMRlog_in (char *username, char *password, char *environment, char *application);
long NFMRlogout (void);
long ERRget_message () ;
long NFMRconnect (char *node, char *username);
long NFMRdisconnect (void);
long NFMRcancel_check_out_item (char *catalog, long cat_num, char *item, char *rev, struct NFMwf_info wf_info, struct NFMoperation operation);
long NFMRcancel_check_out_set (char *catalog, long cat_num, char *item, char *rev, long set_num, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level);
long NFMRvalidate_user_access (long user_id, char *command, char *workflow, char *project, char *catalog_name, char *item_name, char *item_rev);
long NFMRset_wf_state( char *application, long err_no, char *message);
long NFMRpc_add_item ( void );
long NFMRpc_display_items ( char *catalog_name, char *search_name, char *sort_name);
long NFMRpc_query_add_item( void ) ;

/* pcfuncts.c */
long finddisk (char *drive);
long checkdisk (char *drive);
long mountdisk (char *drive, char *interaddr, char *n_username, char *n_passwd, char *n_pathname);
long unmountdisk (char *drive);
long ftpget (char *interaddr, char *n_username, char *n_passwd, char *n_pathname, char *n_cifilename, char *localpath, char *n_cofilename);
long ftpput (char *interaddr, char *n_username, char *n_passwd, char *n_pathname, char *n_cifilename, char *localpath, char *n_cofilename);
long ftpdel (char *interaddr, char *n_username, char *n_passwd, char *n_pathname, char *n_cifilename, char *localpath);

/* pcmem.c */
long PCmem_no_rows_columns (char *serverbuf, long *num_rows, long *num_cols);
long PCmem_get_row_size (char *serverbuf, long row_number, long *row_size);
long PCmem_read_data (char *serverbuf, long row_number, long column_number, char *value);
long PCmem_write_data (char *serverbuf, long row_number, long column_number, char *new_data);
long PCmem_read_data_non_string (char *serverbuf, long row_number, long column_number, char *value);
long _NFMpc_write_row (char **list_ptr, char *str);
long _NFMpc_print_mem_buffer (char *title, char *list, char *filename);
long _NFMpc_build_buffer (char **list_ptr, long no_columns);

/* pctools.c */
long _NFMget_server_response (long err_no,char *message,char *returned_string);

/* process.c */
long CLIread_default_data (void);
long CLIprocess_command_file (char *command_file);
long CLIlookup_keyword (struct entry keywords[], char search[]);
short CLIequal_strings (char *search, char *word);
void _CLI_num (char *str, long var);
void _CLI_str (char *str, ... );
long CLIget_key_or_command (char *record, char *key, char *data);
void CLIcheck_connect_and_login (void);
void CLIshow_active_data(void);
void CLIhelp(void);
void CLIprint(FILE *file_ptr, char *format, ...);
void CLIsuspend_to_DOS (void) ;
void CLIwrite_default_data (void) ;
