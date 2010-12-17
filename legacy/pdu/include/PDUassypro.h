#ifndef PDU_PROTO_H
#define PDU_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif


/* ./assembly/PDUassy_tls.c */
extern int PDUdisplay_review_structure __PDU((MEMptr assy_buffer));
extern int PDUload_assembly_structure __PDU((void));
extern int PDUcheck_file_for_activate __PDU((void));
extern int PDUadd_part_to_assy_structure __PDU((void));
extern int PDUdelete_assy_part __PDU((void));
extern int PDUadd_row_to_assy_mcf __PDU((Form form, int field, int rows, int level, int parent, int child, char *catalog, char *partid, char *revision, char *attach, char *quantity, char *usage));
extern int PDUcreate_assembly_parts_buffer __PDU((Form form, int field, MEMptr *buffer));
extern int PDUcheck_level_no __PDU((Form form, int field, int row));
extern int PDUdefault_usageid __PDU((char *catalog, char *partid, char *revision, int childno, char **usageid));
extern int PDUget_assembly __PDU((int get_level));
extern int PDUfreeze_assy_refresh __PDU((void));
extern int PDUunfreeze_assy_refresh __PDU((void));
extern int PDUget_file_status __PDU((char *catalog, char *partid, char *revision, char **state));
extern int PDUget_max_level __PDU((int *level));
extern int PDUfreeze_assy_part_area __PDU((void));
extern int PDUunfreeze_assy_part_area __PDU((void));
extern int PDUgenerate_ng_usageid __PDU((char *catalog, char *partid, char *revision));
extern int PDUplace_ng_assembly __PDU((void));

/* ./assembly/PDUdef_assy.c */
extern int define_assy_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUdefine_assy_form __PDU((void));
extern int PDUrefresh_gadgets_init __PDU((void));
extern int PDUassy_gadgets_init __PDU((void));
extern int PDUprint_assy_refresh __PDU((void));
extern int PDUcheck_assy_commands __PDU((void));
extern int PDUrestore_assy_part_selection_area __PDU((void));
extern int PDUsave_assy_part_selection_area __PDU((void));
extern int PDUfreeze_assy_mcf __PDU((void));
extern int PDUunfreeze_assy_mcf __PDU((void));

/* ./assembly/assy_global.c */

#undef __PDU
#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#endif
