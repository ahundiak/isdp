#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>

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




