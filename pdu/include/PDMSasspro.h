#ifndef PDMS_ASSY_PRO_H
#define PDMS_ASSY_PRO_H

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

/* ./ass/PDMass_struc.c */
extern int PDMcreate_temp_pdmcit __PDMS((char *temp_table));
extern int PDMsget_assembly_structure __PDMS((MEMptr *attr_bufr, long PlaceFlag));

/* ./ass/PDMatt_struc.c */
extern int PDMprocess_struc_attach __PDMS((int n_catalogno, int p_itemno, MEMptr data_bufr, int parent_row, int parent_row_offset));

/* ./ass/PDMchkin_cit.c */
extern int PDMXXinsert_citinfo __PDMS((int p_catalogno, int p_itemno, MEMptr child_bufr, MEMptr parm_buffer, MEMptr data_buffers, MEMptr parmdata_buffers, MEMptr citno, char *p_update));

/* ./ass/PDMqry_mem.c */
extern long PDMquery_ass_struc __PDMS((char *cat_name, char *item_name, char *item_rev, long level, char *p_assind, long place_flag, MEMptr *attr_list));
extern long PDMload_ass_members __PDMS((long c_catoffset, long c_itemoffset, char *cit_str, long max_level, long curr_level, long cat_no, long item_no, MEMptr attr_list, int p_pchildno, long place_flag));
extern long PDMassembly_attributes __PDMS((MEMptr *attr_list));

/* ./ass/PDMqry_struc.c */
extern int PDMrecursive_structuring __PDMS((int n_acatalogno, int n_aitemno, char *temp_table, MEMptr old_struc, MEMptr *new_struc));
extern void PDMrecur_load_tempcit __PDMS((int p_catno, int p_itemno, short max_level, short curr_level, int p_pchildno, char *temp_table));
extern int PDMdevelop_ass_struc_chkin __PDMS((int p_catno, int p_itemno, MEMptr child_bufr));
extern int PDMquery_assembly_structure __PDMS((PDMexec_ptr PDMexec));

#if defined(__cplusplus)
}
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#endif
