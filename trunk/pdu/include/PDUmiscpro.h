#ifndef PDU_MISC_PRO_H
#define PDU_MISC_PRO_H

#include "MEMstruct.h"

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./misc/PDUget_node.c */
extern int MYget_node_name     __PDU((char *name));

/* ./misc/PDUmiscapi.c */
extern int PDUget_sun_nodename __PDU((char **node));

/* ./misc/PDUnode_info.c */
extern int PDUget_user_node_info  __PDU((void));
extern void PDUload_storage_area  __PDU((void));
extern int PDUget_storage_buffer  __PDU((MEMptr *storage_area));
extern void PDUprint_storage_area __PDU((void));

/* ./misc/PDUsunstub.c */
extern int Display_message       __PDU((int no, int where, char *mtext));
extern int Stat                  __PDU((char *buf, struct stat *st));
extern int Exit                  __PDU((void));
extern int RPScreate_report_file __PDU((int flg, char *fpath, char *tblnm, char *grpnm, MEMptr inbuf, MEMptr inlist));

#if defined(__cplusplus)
}
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#endif
