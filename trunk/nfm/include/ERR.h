#ifndef ERR_H
#define ERR_H

#include <stdio.h>

#include "ERRerrordef.h"
#include "ERRproto.h"

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
    long    NFIstatus;      /*  NFM Interface status                    */
    char    **NFIargv;      /*  Contains context specific data          */

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

    long    MEMstatus;      /*  MEM subsystem status                    */
    char    **MEMargv;      /*  Contains context specific data          */

    long    UTIstatus;      /*  Utilities client status                 */
    char    **UTIargv;      /*  Contains context specific data          */

	int		debug_on;       /*  TRUE = on, FALSE = off                  */
	char	debug_file[80]; /*  path or device for debug output         */
  };

/*  Subsystem definitions  */

#define NFI    1
#define NFMR   2
#define NETC   3
#define NETS   4
#define NFMS   5
#define NFM    6
#define SQL    7
#define MEM    8
#define UTI    9

/*  Message files  */

#define NUMBER_OF_MESSAGE_FILES      7

#define NFI_MSG_FILE       "NFImsg.msg"
#define NFM_MSG_FILE       "NFMmsg.msg"
#define NET_MSG_FILE       "NETmsg.msg"
#define SQL_MSG_FILE       "SQLmsg.msg"
#define MEM_MSG_FILE       "MEMmsg.msg"
#define UTI_MSG_FILE       "UTImsg.msg"
#define ERR_MSG_FILE       "ERRmsg.msg"

#endif
