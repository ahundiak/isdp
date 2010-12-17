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

/* ./ass/PDMass_struc.c */
extern int PDMcreate_temp_pdmcit __PDM((char *temp_table));
extern int PDMsget_assembly_structure __PDM((MEMptr *attr_bufr, long PlaceFlag));

/* ./ass/PDMatt_struc.c */
extern int PDMprocess_struc_attach __PDM((int n_catalogno, int p_itemno, MEMptr data_bufr, int parent_row, int parent_row_offset));

/* ./ass/PDMchkin_cit.c */
extern int PDMXXinsert_citinfo __PDM((int p_catalogno, int p_itemno, MEMptr child_bufr, MEMptr parm_buffer, MEMptr data_buffers, MEMptr parmdata_buffers, MEMptr citno, char *p_update));

/* ./ass/PDMqry_mem.c */
extern long PDMquery_ass_struc __PDM((char *cat_name, char *item_name, char *item_rev, long level, char *p_assind, long place_flag, MEMptr *attr_list));
extern long PDMload_ass_members __PDM((long c_catoffset, long c_itemoffset, char *cit_str, long max_level, long curr_level, long cat_no, long item_no, MEMptr attr_list, int p_pchildno, long PlaceFlag));
extern long PDMassembly_attributes __PDM((MEMptr *attr_list));

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
