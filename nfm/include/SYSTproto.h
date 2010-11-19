#ifndef SYST_PROTO_H
#define SYST_PROTO_H

#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

#if defined(__STDC__) || defined(__cplusplus)
# define __SYST(s) s
#else
# define __SYST(s) ()
#endif


/* NFMbase36.c */
extern int NFMbase36 __SYST((long b10num, char *b36num));

/* NFMcrypt.c */
extern int NFMencrypt __SYST((char *passwd, char *e_passwd));
extern int NFMdecrypt __SYST((char *e_passwd, char *passwd));

/* NFMdatetime.c */
extern long NFMget_RISdatetime __SYST((char *ret_datetime));
extern long NFMget_RISdate __SYST((char *ret_date));
extern long NFMget_RIStime __SYST((char *ret_time));

/* NFMerror.c */
extern int _sql_error __SYST((long status));
extern int _INIT_str __SYST((char *str, char *var));
extern int _INIT_num __SYST((char *str, long var));
extern int _NFM_num __SYST((char *str, long var));
extern int _NFM_str __SYST((char *str, char *var));
extern long NFMerror __SYST((long err));
extern long _SER_str __SYST((char *str, char *var));
extern long _SER_num __SYST((char *str, char *var));

/* NFMfile_oper.c */
extern int NFMcopy_file __SYST((char *src_file, char *dst_file, char *type, long *size, long delete_src_flag));
extern int NFMappend_str_to_file __SYST((char *line, char *file));
extern int NFMcheck_str_entry_in_file __SYST((char *identifier, char *identifier2, char *file, int type, int *line_num, char *line_in));
extern int NFMdelete_str_entry_from_file __SYST((char *identifier, char *file, int type));
extern int NFMfopen_write __SYST((char *filename, char *attr, FILE **outfile));
extern int NFMverify_file_info __SYST((char *file_name, struct stat *fbuff, NFMfile_info *file_info));
extern int NFMcp_file __SYST((char *src_file, char *dst_file, long delete_src_flag));
extern int NFMconvert_to_vax_file __SYST((char *filename));

/* NFMg_f_name.c */
extern long NFMget_file_name __SYST((long user_id, long cat_no, long file_no, char *file_name));

/* NFMgen_tools.c */
extern int NFMload_user_info __SYST((char *user_name));
extern int NFMset_file_mode __SYST((char *filename, NFMfile_info *file_info));
extern int NFMget_full_name __SYST((char *file_name, char *full_name));
extern int NFMmk_name __SYST((char *name));
extern int NFMmk_unique_mountpoint __SYST((char *path));
extern long NFMappend_path_file __SYST((char *op_sys, char *path_name, char *file_name, char *name));
extern int NFMscan_ftp_output __SYST((char *out_file));
extern int NFMscan_ftp_output1 __SYST((char *out_file));
extern int NFM_mkpath __SYST((char *path, mode_t mode));
extern int NFM_mkdir __SYST((char *path, int user_id, int group_id, mode_t mode));

/* NFMnewf_name.c */
extern long NFMnew_file_name __SYST((long user_id, long catalog_no, long file_no, char *new_file_name));

/* NFMnfs.c */
extern int NFMnfs_file_transfer __SYST((char *local_nodename, char *nodename, char *resource, char *cifilename, char *cofilename, char *cofilepath, char *mountpoint, long lfm_check));
extern int NFMnfs_file_remove __SYST((char *local_nodename, char *nodename, char *resource, char *cifilename, char *cofilename, char *cofilepath, char *mountpoint, long umount_flag));
extern int NFMnfs_mount __SYST((char *mountpoint, char *nodename, char *resource, char *options));
extern int NFMnfs_umount __SYST((char *mountpoint));
extern int NFMget_mount_point __SYST((char *nodename, char *resource, char *mountpoint));
extern int NFMis_nfs_copy __SYST((char *mountpoint, char *cofilename, char *source));

/* NFMreset_msg.c */
extern void NFMreset_message_struct __SYST((int user_id));

/* NFMstools.c */
extern int NFMparse_local_filename __SYST((char *i_name));

/* NFMstring.c */
extern long NFMchange_case __SYST((char *str, long type));
extern long NFMupper_case __SYST((char *in_str, char *out_str));
extern long NFMlower_case __SYST((char *in_str, char *out_str));
extern long NFMparse_string __SYST((char *in_str, char *out_str));
extern int NFMj_tic_search __SYST((char *pwd, char *temp));
extern int _NFMcat_f_cat __SYST((char *from_clause, int *return_flag));
extern int _NFMf_cat __SYST((char *clause, int *return_flag));
extern long _DMins_bs __SYST((char *string, long length));

/* NFMsys_func.c */
extern int NFMln __SYST((char *path1, char *path2));
extern int NFMcp __SYST((char *path1, char *path2));
extern int NFMunln __SYST((char *path));
extern int NFMchmod __SYST((char *path, int mode));
extern int NFMmkdir __SYST((char *path, int mode));
extern int NFMsystem __SYST((char *shell_str));
extern int NFMsystem2 __SYST((char *shell_str, char *error_file));
extern int NFMsystem_imm __SYST((char *shell_str));
extern int NFMmalloc __SYST((char **buf_ptr, long size, long *malloced_size));
extern int pw __SYST((int x));

/* stubs.c */
extern int Stat __SYST((char *path, struct stat *buf));
extern void Exit __SYST((int status));

#undef __SYST

#endif
