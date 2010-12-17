#ifndef PDU_PROTO_H
#define PDU_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif


/* ./misc/PDUget_node.c */
extern int MYget_node_name __PDU((char *name));

/* ./misc/PDUnode_info.c */
extern int PDUget_user_node_info __PDU((void));
extern void PDUload_storage_area __PDU((void));
extern int PDUget_storage_buffer __PDU((MEMptr *storage_area));
extern int PDUget_sun_nodename __PDU((char **node));
extern void PDUprint_storage_area __PDU((void));

/* ./misc/PDUsunstub.c */
extern int Display_message __PDU((int no, int where, char *mtext));
extern int Stat __PDU((char *buf, struct stat *st));
extern int Exit __PDU((void));
extern int RPScreate_report_file __PDU((int flg, char *fpath, char *tblnm, char *grpnm, MEMptr inbuf, MEMptr inlist));

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
