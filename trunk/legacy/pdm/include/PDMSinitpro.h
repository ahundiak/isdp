#ifndef PDM_PROTO_H
#define PDM_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDM
#define __PDM(args) args
#endif
#else
#ifndef __PDM
#define __PDM(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./init/PDMcp_env.c */
extern long PDMcreate_env_file __PDM((char *env));
extern long PDMcreate_ser_file __PDM((char *ser));
extern int menu __PDM((char *main_title, char *titles[], char *def_val[], short *attr, char *extra_char[], UNIT_INFO *data, char *o_titles[]));
extern int PDMadd_reports_dir __PDM((void));

/* ./init/PDMdebug.c */
extern int _PDMdebug __PDM((int va_alist));

/* ./init/PDMi_dbg.c */
extern int PDMdebug __PDM((char s[300 ]));
extern int PDMcreate_rptopts __PDM((void));
extern int PDMcreate_reports_tables __PDM((void));
extern int PDMmap_attribute_function __PDM((void));

/* ./init/PDMi_file.c */
extern int PDMattrfile_to_buffer __PDM((char *filename, MEMptr buffer));
extern int PDMdatafile_to_buffer __PDM((char *filename, MEMptr attr_buffer, MEMptr *data_buffer));
extern int PDMlistfile_to_buffer __PDM((char *file[], MEMptr *list_buffer));
extern int PDMsub_catalog_attr_names __PDM((char *file_name, int indx[], int no_fields, MEMptr buffer));
extern void PDMheading __PDM((void));
extern int PDMi_query_familyno __PDM((void));
extern int PDMcheck_for_view __PDM((void));

#if defined (sco)
/* ./init/PDMi_file.c */
extern int PDMget_proddir __PDM((char *pdm_proddir));
#endif

/* ./init/PDMi_main.c */
extern int main __PDM((int argc, char *argv[]));
extern int PDMinit_cleanup __PDM((long user_id, int id));

/* ./init/PDMi_rtns.c */
extern int PDMinit_init __PDM((long user_id));
extern int PDMiexpand_databuffer __PDM((MEMptr attr_buffer, MEMptr data_buffer, MEMptr *data1_buffer));
extern int PDMwrite_initlog __PDM((void));

/* ./init/PDMi_table.c */
extern int PDMcreate_required_table __PDM((long user_id, int table_id));
extern int PDMcreate_table __PDM((long user_id, char *attr_file, char *data_file, char *list_file, char *table_name));
extern long PDMi_create_pdm_catalog __PDM((long user_id, char *pdm_catalog, char *n_type));
extern int PDMcreate_pdmfilename_table __PDM((char *tablename));
extern long PDMi_create_drawing_catalog __PDM((long user_id, char *pdm_catalog, char *n_type));

/* ./init/PDMi_tmplt.c */
extern int PDMcreate_catalog_template1 __PDM((long user_id));
extern int PDMcreate_catalog_template2 __PDM((long user_id));
extern int PDMcreate_required_template __PDM((long user_id, int template_id));
extern int PDMcreate_template __PDM((long user_id, char *attr_file, char *data_file, char *list_file, char *template, char *table_name, char *identifier));
extern long PDMload_acl __PDM((long user_id, char *user_name, char *wf_name, char *acl_name));
extern int PDMcreate_drawing_template __PDM((long user_id));

#if defined(__cplusplus)
}
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDM
#define __PDM(args) args
#endif
#else
#ifndef __PDM
#define __PDM(args) ()
#endif
#endif

#endif
