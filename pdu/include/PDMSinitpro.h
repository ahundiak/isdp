#ifndef PDMS_INIT_PRO_H
#define PDMS_INIT_PRO_H

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./init/PDMcp_env.c */
extern long PDMcreate_env_file __PDMS((char *env));
extern long PDMcreate_ser_file __PDMS((char *ser));
extern int menu __PDMS((char *main_title, char *titles[], char *def_val[], short *attr, char *extra_char[], UNIT_INFO *data, char *o_titles[]));
extern int PDMadd_reports_dir __PDMS((void));

/* ./init/PDMdebug.c */
// extern int _PDMdebug __PDMS((int va_alist));

/* ./init/PDMi_dbg.c */
extern int PDMdebug __PDMS((char s[300 ]));
extern int PDMcreate_rptopts __PDMS((void));
extern int PDMcreate_reports_tables __PDMS((void));
extern int PDMmap_attribute_function __PDMS((void));

/* ./init/PDMi_file.c */
extern int PDMattrfile_to_buffer __PDMS((char *filename, MEMptr buffer));
extern int PDMdatafile_to_buffer __PDMS((char *filename, MEMptr attr_buffer, MEMptr *data_buffer));
extern int PDMlistfile_to_buffer __PDMS((char *file[], MEMptr *list_buffer));
extern int PDMsub_catalog_attr_names __PDMS((char *file_name, int indx[], int no_fields, MEMptr buffer));
extern void PDMheading __PDMS((void));

// Declared elsewhere with different protos
// extern int PDMi_query_familyno __PDMS((void));
// extern int PDMcheck_for_view __PDMS((void));
// extern int PDMget_proddir __PDMS((char *pdm_proddir));

extern int PDMget_substr __PDMS((const char *mainstr, char *delim, char *searchstr));

/* ./init/PDMi_main.c */
extern int PDMinit_cleanup __PDMS((long user_id, int id));

/* ./init/PDMi_rtns.c */
extern int PDMinit_init __PDMS((long user_id));
extern int PDMiexpand_databuffer __PDMS((MEMptr attr_buffer, MEMptr data_buffer, MEMptr *data1_buffer));
extern int PDMwrite_initlog __PDMS((void));

/* ./init/PDMi_scoutl.c */
extern int PDMget_substr __PDMS((const char *mainstr, char *delim, char *searchstr));
extern char *PDMget_proddir __PDMS((void));

/* ./init/PDMi_table.c */
extern int PDMcreate_required_table __PDMS((long user_id, int table_id));
extern int PDMcreate_table __PDMS((long user_id, char *attr_file, char *data_file, char *list_file, char *table_name));
extern long PDMi_create_pdm_catalog __PDMS((long user_id, char *pdm_catalog, char *n_type));
extern int PDMcreate_pdmfilename_table __PDMS((char *tablename));
extern long PDMi_create_drawing_catalog __PDMS((long user_id, char *pdm_catalog, char *n_type));
extern int PDMi_get_attribute_no __PDMS((int n_tableno, char *n_name, int *n_attrno));
extern int PDMcreate_nfmpdmcat_view __PDMS((void));

/* ./init/PDMi_tmplt.c */
extern int PDMcreate_catalog_template1 __PDMS((long user_id));
extern int PDMcreate_catalog_template2 __PDMS((long user_id));
extern int PDMcreate_required_template __PDMS((long user_id, int template_id));
extern int PDMcreate_template __PDMS((long user_id, char *attr_file, char *data_file, char *list_file, char *template, char *table_name, char *identifier));
extern long PDMload_acl __PDMS((long user_id, char *user_name, char *wf_name, char *acl_name));
extern int PDMcreate_drawing_template __PDMS((long user_id));

#if defined(__cplusplus)
}
#endif


#endif
