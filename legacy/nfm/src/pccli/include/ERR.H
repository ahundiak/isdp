#ifndef ERR_H
#define ERR_H

#include <stdio.h>
#include <stdarg.h>
/* #include "ERRerrordef.h" */
/* #include "ERRproto.h" */

#ifndef TRUE
#define TRUE  1
#endif
#ifndef FALSE
#define FALSE 0
#endif

#define DEFAULT_LANGUAGE  "english"

/*  Maximum allowable arguments  */

#define MAX_ARGS  16        /*  If this changes, ERRget_message ()
                                must change its initialization also     */

/*  Global I/NFM error structure  */

struct _ERRstruct
  {
    long    NFAstatus;      /*  Alphanumeric interface status           */
    char    **NFAargv;      /*  Contains context specific data          */

    long    NFFstatus;      /*  Forms interface status                  */
    char    **NFFargv;      /*  Contains context specific data          */

    long    NFMRstatus;     /*  NFM Requestor interface status          */
    char    **NFMRargv;     /*  Contains context specific data          */

    long    NETCstatus;     /*  Client Network interface status         */
    char    **NETCargv;     /*  Contains context specific data          */

    long    NETSstatus;     /*  Server Network interface status         */
    char    **NETSargv;     /*  Contains context specific data          */

    long    NFMSstatus;     /*  NFM Server interface status             */
    char    **NFMSargv;     /*  Contains context specific data          */

    long    NFMstatus;      /*  NFM server status                       */
    char    **NFMargv;      /*  Contains context specific data          */

    long    SQLstatus;      /*  SQL interface status                    */
    char    **SQLargv;      /*  Contains context specific data          */

    long    RDBstatus;      /*  Relational Database status              */
    char    **RDBargv;      /*  Contains context specific data          */

    long    MEMstatus;      /*  MEM subsystem status                    */
    char    **MEMargv;      /*  Contains context specific data          */

    long    UTIstatus;      /*  Utilities client status                 */
    char    **UTIargv;      /*  Contains context specific data          */

    long    RPSstatus;      /*  Report subsystem status                 */
    char    **RPSargv;      /*  Contains context specific data          */

	int		debug_on;       /*  TRUE = on, FALSE = off                  */
	char	debug_file[80]; /*  path or device for debug output         */
  };

/*  Subsystem definitions  */

#define NFA    1
#define NFF    2
#define NFMR   3
#define NETC   4
#define NETS   5
#define NFMS   6
#define NFM    7
#define SQL    8
#define RDB    9
#define MEM   10
#define UTI   11
#define RPS   12

/*  Message files  */

#define NUMBER_OF_MESSAGE_FILES     9

#define NFA_MSG_FILE       "NFAmsg.msg"
#define NFI_MSG_FILE       "NFFmsg.msg"
#define NFM_MSG_FILE       "NFMmsg.msg"
#define NET_MSG_FILE       "NETmsg.msg"
#define SQL_MSG_FILE       "SQLmsg.msg"
#define MEM_MSG_FILE       "MEMmsg.msg"
#define UTI_MSG_FILE       "UTImsg.msg"
#define RPS_MSG_FILE       "RPSmsg.msg"
#define ERR_MSG_FILE       "ERRmsg.msg"

#endif
