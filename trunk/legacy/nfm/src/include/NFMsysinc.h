#include <stdio.h>
#include <string.h>
#include <sys/utsname.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
#include <errno.h>
#include <time.h>
#include "NFMschema.h"
#include "NFMsysstruct.h"
#include "NFMstruct.h"
#include "NFMattr.h"
#include "NFMnfs.h"
#include "MSGstruct.h"
#ifdef INCLUDE_EXTERN
#include "NFMsysextern.h"
#endif
#include "NFMsysdef.h"
#include "DEBUG.h"
#include "NFMerrordef.h"
#include "ERR.h"


#include "SYSTproto.h"
/* modified to support SGI Port 030394 MaC */
#if !defined (__sgi)
#include "ERRproto.h"
#endif


