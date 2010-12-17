#ifndef UTI_PROTO_H
#define UTI_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __UTI(s) s
#else
# define __UTI(s) ()
#endif


/* NFMRconnect.c */
extern long NFMRconnect __UTI((char *node));

/* NFMRerr_load.c */
extern int NFMRload_ERRstruct __UTI((MEMptr status_buffer, MEMptr csd_buffer));

/* NFMRerror.c */
extern int _NFMR_num __UTI((char *str, long var));
extern int _NFMR_str __UTI((char *str, char *var));

/* NFMRlogin.c */
extern long NFMRlogin __UTI((MEMptr login_attr, MEMptr login_data, MEMptr login_wf, long *user_id));
extern long NFMRquery_login_attributes __UTI((char *app_id, char *env_type, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list, MEMptr *wf_list));

/* NFMRrec_buff.c */
extern long NFMRreceive_buffer __UTI((long *NETid, long *ret_status, MEMptr *return_buffer));

/* NFMRterm.c */
extern long NFMRterminate __UTI((void));

/* NFMRvalid.c */
extern long NFMRvalidate_user_access __UTI((long user_id, char *command, char *workflow, char *project, char *catalog_name, char *item_name, char *item_rev));

/* UTICcmd.c */
extern int UTICarchive_cmd __UTI((char *script, script_header hdr));
extern int UTICbackup_cmd __UTI((char *script, script_header hdr));
extern int UTICrestore_cmd __UTI((char *script, srvdbg dbg));

/* UTICerrors.c */
extern int UTICerror __UTI((int errtype, char *ptr));

/* UTICinit_ums.c */
extern long UTICinit_ums __UTI((char *program_name));

/* UTICinput.c */
extern int UTICrequest __UTI((srvdbg dbg));
extern int UTICdocommand __UTI((char *script, srvdbg dbg));
extern strptr UTICparsecommand __UTI((char *str));
extern int UTICcommandline __UTI((int argc, char *argv[]));

/* UTICmain.c */
extern int main __UTI((int argc, char *argv[]));

/* UTICreq.c */
extern int UTICnfm_login __UTI((script_header hdr));
extern int UTIClogin __UTI((char *nfmenv, char *nfmlogin, char *nfmpassword));
extern int UTICupdate_db __UTI((int group_no, long scr_status, int utility, int no_copies));
extern int UTICvalidate_user __UTI((long utility));
extern int UTICerr_to_srv __UTI((long uti_error, char *msg_str, long nfm_error));
extern long UTICdebug __UTI((int nfm, char *nfm_file, int net, char *net_file, int sql, char *sql_file, int mem, char *mem_file));
extern int UTICtalk __UTI((script_header hdr, srvdbg dbg));
extern int UTIprocess_server_buffer __UTI((MEMptr info));
extern int UTICall_debug __UTI((int nfm, char *nfm_file, int net, char *net_file, int sql, char *sql_file, int uti, char *uti_file));

/* UTICscripts.c */
extern int UTICexecute_script __UTI((char *str));
extern int UTICexecute_group __UTI((char *str, srvdbg dbg));
extern int UTICread_script __UTI((char *script, script_header *return_header));
extern int UTICmerge_files __UTI((void));

/* UTICtools.c */
extern int UTICsys_stat __UTI((int stat));
extern int debug_setup __UTI((srvdbg *NFMserver_dbg));
extern int UTICprepare_media __UTI((script_header hdr));
extern int UTICprint_header __UTI((script_header hdr));
extern int UTICpast_colon __UTI((char *rec, char *ret_str));
extern int UTICupcase __UTI((char *str));

/* UTIRchoose.c */
extern int UTIchoose_sa __UTI((char *util_name, char *util_ch, MEMptr sa_attr, MEMptr label_value, char *sa_no, char *label));
extern int UTIchoose_flagged_files __UTI((char *util_name, char *util_ch, MEMptr file_value, MEMptr *file_list));
extern int UTIchoose_label __UTI((char *util_name, char *util_ch, char *device_type, MEMptr label_value, char *label));
extern int UTIyou_or_me __UTI((char *label));
extern int UTIget_label __UTI((char *label));
extern int UTIlist_labels __UTI((MEMptr label_value, char *label));
extern int UTIRlist_flagged_files __UTI((char *util, MEMptr file_value));
extern char *UTIup __UTI((char *text));
extern char *UTIload __UTI((char *membuf));

/* UTIRerrors.c */
extern int UTIerror __UTI((int errtype, char *ptr));

/* UTIRintern.c */
extern int UTIRprocess_status __UTI((MEMptr info));
extern int UTIRinfo_form __UTI((MEMptr msg_buf));

/* UTISarchive.c */
extern long UTIarchive_files __UTI((char *server, char *env, char *user, char *password, char *sa_num, char *label, MEMptr file_info, MEMptr *out_list));

/* UTISbackup.c */
extern long UTIbackup_files __UTI((char *server, char *env, char *user, char *password, char *sa_num, char *label, MEMptr file_info, MEMptr *out_list));

/* UTISdelete.c */
extern long UTIdelete_files __UTI((int server, int env, int user, int password, MEMptr file_info));

/* UTISerr.c */
extern long NFMS_utilities_error __UTI((MEMptr in_list, MEMptr *out_list));
extern int UTIreq_err __UTI((int errtype, char *ptr));

/* UTISglobals.c */
extern int UTIset_globals __UTI((char *flag));

/* UTISintern.c */
extern int UTIprocess_label __UTI((char *in_label, char *out_label));
extern int UTIget_sa_info __UTI((int sa_no, char *label, UTIpending flist, NFMarch *nfm_arch_loc, UTIarch *uti_arch_loc));
extern int UTISget_util_sa_info __UTI((int node_no));
extern int UTIprocess_files __UTI((NFMarch nfm_loc, UTIarch uti_loc, UTIpending flist));
extern int UTIbuild_script __UTI((int utility, int group_no, UTIarch arch_loc, UTIpending flist));
extern int UTIu_process_restore __UTI((UTIpending flist));
extern int UTIreturn_info __UTI((char *s_name, char *node_name, int node_no));
extern int UTIopen_buffers __UTI((void));
extern int UTIclose_buffers __UTI((void));
extern int UTIget_node_info __UTI((int sa_no, UTIarch *node_info, char *mach_id, char *tcp, char *xns, char *dec, char *net, char *nfs));
extern int UTIdelete_local_files __UTI((UTIpending flist));
extern int UTIget_reserved_sano __UTI((void));

/* UTISl_util.c */
extern long NFMSlist_archive __UTI((MEMptr in_list, MEMptr *out_list));
extern long NFMSlist_backup __UTI((MEMptr in_list, MEMptr *out_list));
extern long NFMSlist_restore __UTI((MEMptr in_list, MEMptr *out_list));
extern long NFMSlist_delete __UTI((MEMptr in_list, MEMptr *out_list));
extern int UTIlist_flagged_files __UTI((int utility, MEMptr *file_value));

/* UTISprarch.c */
extern int UTIprocess_archive __UTI((int sa_no, char *label, UTIpending flist));

/* UTISprback.c */
extern int UTIprocess_backup __UTI((int sa_no, char *label, UTIpending flist));

/* UTISprdel.c */
extern int UTIprocess_delete __UTI((UTIpending flist));

/* UTISprrstr.c */
extern int UTIprocess_restore __UTI((UTIpending flist));

/* UTISqry_arch.c */
extern long NFMSquery_archive __UTI((MEMptr in_list, MEMptr *out_list, UTIpending *flist));

/* UTISqry_back.c */
extern long NFMSquery_backup __UTI((MEMptr in_list, MEMptr *out_list, UTIpending *flist));

/* UTISqry_del.c */
extern long NFMSquery_delete __UTI((MEMptr in_list, MEMptr *out_list, UTIpending *flist));

/* UTISqry_rstr.c */
extern long NFMSquery_restore __UTI((MEMptr in_list, MEMptr *out_list, UTIpending *flist));

/* UTISrestore.c */
extern long UTIrestore_files __UTI((char *server, char *env, char *user, char *password, MEMptr file_info, MEMptr *out_list));

/* UTISscript.c */
extern int UTIdelete_script __UTI((char *script));
extern int UTIwrite_script __UTI((UTIpending wlist, char *script));
extern int UTIexecute_script __UTI((char *script));
extern int UTIsort_restore_requests __UTI((void));
extern UTIpending UTIfind_link __UTI((UTIpending flist, int link_no));
extern int UTIreturn_sorted_list __UTI((UTIpending rlist, UTIpending *r_on_list, UTIpending *r_off_list));
extern int UTIbuild_restore_master __UTI((UTIpending flist));
extern int UTIon_line_requests __UTI((UTIpending rlist));
extern int UTIoff_line_requests __UTI((UTIpending rlist));
extern int UTIrstr_same_node __UTI((UTIpending rlist));
extern int UTIprocess_on_line __UTI((char *script, UTIpending rlist, NFMarch nfmrec));

/* UTIStools.c */
extern int UTIgen_label __UTI((char *label));
extern char *UTIgen_date __UTI((void));
extern char *UTIgen_time __UTI((void));
extern int UTIbuild_file_name __UTI((int table_no, int file_num, char *host_file_name, char *destination));
extern int UTIget_next_spot __UTI((int *archive_no));
extern int UTIsys_stat __UTI((int stat));
extern int UTIsys_err __UTI((void));
extern char *UTIload __UTI((char *membuf));
extern char *UTIup __UTI((char *text));
extern char *UTIgood_path __UTI((char *path, char *op_sys));
extern int UTIlowcase __UTI((char *str));
extern int UTIupcase __UTI((char *str));
extern int UTIprint_list __UTI((UTIlist link));
extern int UTIprint_pending_files __UTI((UTIpending link));
extern int UTIprint_gen __UTI((struct gen gs));
extern int UTIprint_restore __UTI((struct restore rt));
extern int UTIprint_fs __UTI((struct fs home));
extern int UTIprint_nfmarchives __UTI((NFMarch ar));
extern int UTIprint_archive_loc __UTI((UTIarch srv));
extern int UTIprint_file_spec __UTI((UTIfiles spec));
extern int UTIcopy_link __UTI((UTIpending link, UTIpending list));
extern UTIpending UTImake_list __UTI((void));
extern UTIarch UTImake_rec __UTI((void));
extern int UTIset_protocol __UTI((char *xns, char *tcpip, char *dec, char *net, char *nfs));
extern int UTIunset_protocol __UTI((int protocol, char *xns, char *tcp, char *dec, char *net, char *nfs));
extern int UTIgen_saveset __UTI((int archive_no, char *label, char *saveset, int sa_no));
extern int UTIget_archive_size __UTI((UTIpending flist));
extern int UTIset_media __UTI((char *device));
extern char *ODname __UTI((char *text));
extern char *UTname __UTI((char *text));
extern char *UTIbuild_nfm_name __UTI((char *table_no, char *file_num));
extern int UTIscript_header __UTI((FILE *script_file, UTIarch rec, char *comment, int sa_no));
extern int UTIget_client_path __UTI((void));

/* UTISunix.c */
extern int UTIu_build_archive_script __UTI((UTIpending rlist, UTIarch rec));
extern int UTIu_build_restore_script __UTI((UTIpending rlist, UTIarch rec));
extern int UTIu_build_backup_script __UTI((UTIpending rlist, UTIarch rec));
extern int UTIu_archive_HDISK __UTI((int utility, UTIpending rlist, UTIarch rec));
extern int UTIu_archive_CACHE __UTI((int utility, UTIpending rlist, UTIarch rec));
extern int UTIu_archive_FDISK __UTI((int utility, UTIpending rlist, UTIarch rec));
extern int UTIu_archive_UTAPE __UTI((int utility, UTIpending rlist, UTIarch rec));
extern int UTIu_archive_CTAPE __UTI((int utility, UTIpending rlist, UTIarch rec));
extern int UTIu_rstr_HDISK __UTI((UTIpending rlist, UTIarch rec));
extern int UTIu_rstr_FDISK __UTI((UTIpending rlist, UTIarch rec));
extern int UTIu_rstr_CACHE __UTI((UTIpending rlist, UTIarch rec));
extern int UTIu_rstr_UTAPE __UTI((UTIpending rlist, UTIarch rec));
extern int UTIu_rstr_CTAPE __UTI((UTIpending rlist, UTIarch rec));
extern int UTIposition __UTI((UTIarch rec));
extern int UTIrstr_position __UTI((UTIarch rec, int old_saveset, int offset));

/* UTISupdate.c */
extern long NFMS_utilities_update __UTI((MEMptr in_list, MEMptr *out_list));
extern int UTIupdate_f_catalog __UTI((int utility, UTIpending flist));
extern int UTIupdate_catalog __UTI((int utility, UTIpending flist));
extern int UTIupdate_nfmarchives __UTI((int utility, NFMarch rec));
extern int UTIupdate_nfmarchives_p __UTI((int group_no, int no_copies));
extern int UTIupdate_nfmsavesets __UTI((int utility, int archive_no, UTIpending flist));
extern int UTIupdate_nfmsavesets_p __UTI((int utility, int group_no));
extern int UTIrm_saveset_entry __UTI((int archive_no));
extern int UTIclient_return_buffer __UTI((MEMptr *xfer, UTIpending flist));
extern int UTIupdate_nfmprojectcit __UTI((int utility, int archive_no, UTIpending flist));

/* UTISvms_sh.c */
extern int UTIv_archive_MTAPE __UTI((int utility, UTIpending rlist, UTIarch rec));
extern int UTIv_rstr_MTAPE __UTI((UTIpending rlist, UTIarch rec));
extern char *MTname __UTI((char *text));
extern char *UTIgood_vax_file __UTI((char *file));

/* UTISxfer.c */
extern int UTIxfer_non_nfm_file_in __UTI((long sa_no, char *file));
extern int UTIxfer_non_nfm_file_out __UTI((long sa_no, char *file));
extern int UTIxfer_files_in __UTI((MEMptr *xfer, long sa_no, UTIpending flist, char *action));
extern int UTIxfer_files_out __UTI((MEMptr *xfer, long sa_no, UTIpending flist, char *action));
extern int UTIxfer_delete_files __UTI((MEMptr *xfer, UTIpending flist));
extern int UTIcopy_f1_to_f2 __UTI((long sano, char *file1, char *file2, MEMptr *move_buffer));
extern long UTIcopy_ud_to_NFMencrypted __UTI((long sano, long cat_no, long file_no, char *filename, MEMptr *move_buffer));

/* UTIVcmd.c */
extern int UTIVarchive_cmd __UTI((char *script, script_header hdr));
extern int UTIVbackup_cmd __UTI((char *script, script_header hdr));
extern int UTIVrestore_cmd __UTI((char *script, srvdbg dbg));

/* UTIVerrors.c */
extern int UTIVerror __UTI((int errtype, char *ptr));

/* UTIVinput.c */
extern int UTIVrequest __UTI((srvdbg dbg));
extern int UTIVdocommand __UTI((char *script, srvdbg dbg));
extern strptr UTIVparsecommand __UTI((char *str));
extern int UTIVcommandline __UTI((int argc, char *argv[]));

/* UTIVmain.c */
extern int main __UTI((int argc, char *argv[]));

/* UTIVreq.c */
extern int UTIVnfm_login __UTI((script_header hdr));
extern int UTIVlogin __UTI((char *nfmenv, char *nfmlogin, char *nfmpassword));
extern int UTIVupdate_db __UTI((int group_no, long scr_status, int utility));
extern int UTIVvalidate_user __UTI((long utility));
extern long UTIVdebug __UTI((int nfm, char *nfm_file, int net, char *net_file, int sql, char *sql_file, int mem, char *mem_file));
extern int UTIVtalk __UTI((script_header hdr, srvdbg dbg));

/* UTIVscripts.c */
extern int UTIVexecute_script __UTI((char *str));
extern int UTIVexecute_group __UTI((char *str, srvdbg dbg));
extern int UTIVread_script __UTI((char *script, script_header *return_header));

/* UTIVtools.c */
extern int UTIVsys_stat __UTI((int stat));
extern int debug_setup __UTI((srvdbg *NFMserver_dbg));
extern int UTIVprepare_media __UTI((script_header hdr));
extern int UTIVprint_header __UTI((script_header hdr));
extern int UTIVpast_colon __UTI((char *rec, char *ret_str));
extern int UTIVupcase __UTI((char *str));

#undef __UTI

#endif
