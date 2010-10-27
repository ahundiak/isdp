#include <stdio.h>
#include <string.h>
#include <ctype.h>

/* 12/8/92 - KT - SUN port */
/* MSSP - 29 Dec 93. sparc replaced by solaris and sunos */
/* MaC 030394: Added SGI */

/* HP PORT - IGI - 10 Jun 94 */
/* ---------------------------------
 * 23 April 1999, ah, Commented out for solaris x86
xif ( ! defined OS_SUNOS && ! defined OS_SOLARIS && !defined (__sgi) && !defined (OS_HPUX) )
xinclude <stand.h>
xendif
 */

#include <sys/types.h>
#include <sys/stat.h>

/* 12/8/92 - KT - SUN port */
#ifdef OS_CLIX
#include <sys/statfs.h>
#endif
/*Added for SUN/SCO version. MVR 16/12/93 */
/*Added for SOLARIS version. KMM 28/12/93 */
/* MaC 030394: Added SGI */

/* HP PORT - IGI - 10 Jun 94 */

#if (defined (__sgi) || defined OS_SUNOS  || defined OS_SOLARIS || defined OS_SCO_UNIX || defined (OS_HPUX) )
#include <ustat.h>
#endif

#include <sys/utsname.h>
#include <errno.h>
#include <netdb.h>
#include "NFMschema.h"
#include "NFMfto_buf.h"
#include "DEBUG.h"
#include "NFMerrordef.h"
#include "NFMxferstrct.h"
#include "NDXstruct.h"
#include "NFMapi.h"
#ifdef INCLUDE_EXTERN
#include "NFMxferextrn.h"
#endif
#include "NFMxfer_def.h"
#include "NFMsysstruct.h"
#include "NFMsysextern.h"
#include "NETnetstruct.h"
#include "NETnetextern.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NETdef.h"
#include "NETstruct.h"
#include "ERR.h"

#include "TFERproto.h"
#include "NFMTproto.h"
#include "SYSTproto.h"
#include "MEMproto.h"
#include "NETproto.h"
#include "ERRproto.h"

extern int CHECKSUM;

/* 12/9/92 - KT - SUN port: Defined for Swap functions */

#define  NFMBUFFER_INFO  1
#define  NFMFILE_INFO    2
#define  NFMFTO_STATUS   3
#define  NFMCP_BUFFER    4
#define  NFMSTATUS_BUF   5




