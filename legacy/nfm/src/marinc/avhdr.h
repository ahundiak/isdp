/* avhdr.h -- header for AUTODIRECT 3 */
#ifdef WIN
#include <windows.h>
#define winmalloc qq262
#define winfree   qq263
extern HWND hwnd;                                      /* handle to main window */
extern void winmsg(LPSTR str);
#endif
/* Added for SCO and SOLARIS  port MVR 23 Dec 1993 */

#if (defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_CLIX))
#include <sys/stat.h>
#endif
/* Changed for SCO/SUNOS/SOLARIS port MVR 23 Dec 1993 */
/* HP PORT - IGI - 10 Jun 94 */
#if !defined(OS_SUNOS) && !defined(OS_SOLARIS) && !defined(dec) && !defined(rs6000) && !defined(hp) && !defined(OS_SCO_UNIX) && !defined(OS_CLIX) && !defined(OS_HPUX)
/* changed path of include file - SSRS - 26/11/93 */
/*#include "\p\ad11\adcomp.h"*/
#include "./include/adcomp.h"
#else
/* changed path of include file - SSRS - 26/11/93 */
/*#include "../ad11/adcomp.h"*/
#include "adcomp.h"
#endif
#if defined(AV) && !defined(NOREDEFINECALLS)
#define readheader            callreadheader
#define startshaperead        callstartshaperead
#define readshapefile         callreadshapefile
#define startlayerread        callstartlayerread
#define readlayer             callreadlayer
#define startlinetyperead     callstartlinetyperead
#define readlinetype          callreadlinetype
#define startvportread        callstartvportread
#define readvport             callreadvport
#define readentityav          callreadentityav
#define startviewread         callstartviewread
#define readview              callreadview
#define startentityread       callstartentityread
#define readblockheader       callreadblockheader
#define startblockheaderread  callstartblockheaderread
#endif


#include <stdio.h>
#include <stdlib.h>

#ifndef OS_UNIX
#  include <dos.h>
#endif

#include <math.h>
#include <ctype.h>
#include <string.h>

#ifdef microsoftc
#  include <malloc.h>
#  include <direct.h>
#  pragma function(strlen,strcat,strcpy,memcpy)
#endif

#ifdef turboc
#  include <alloc.h>
#endif

#ifdef highc
#  include <malloc.h>
#  include <errno.h>
#endif

#include <fcntl.h>

#ifndef OS_UNIX
#  include <io.h>
#  include <sys/types.h>
#  include <sys/stat.h>

#else

#  define SEEK_SET 0
#  define SEEK_CUR 1
#  define SEEK_END 2

#endif

#define SUFFIX
#include "ad3disg.h"

#ifndef OS_UNIX
  /*changed path of include file */
  /*#include "\p\ad11\ad2disg.h"
#  include "\p\ad11\autodir.h"
#  include "\p\ad11\adrproto.h"*/
#  include "ad2disg.h"
#  include "autodir.h"
#  include "adrproto.h"

#  define frdw() ((unsigned short)ad_getc(adin.dwgfiler) & (unsigned short)0xFF) | ((unsigned short)(ad_getc(adin.dwgfiler)<<8))
#  define frdc() ad_getc(adin.dwgfiler)

#else

/*changed the include path - SSRS - 26/11/93 */
/*#include "../ad11/ad2disg.h"
#  include "../ad11/autodir.h"
#  include "../ad11/adrproto.h"*/

#  include "ad2disg.h"
#  include "autodir.h"
#  include "adrproto.h"
   extern short frdw();
#  define frdc() ad_getc(adin.dwgfiler)
#  define flipbytes(a) a=((a & 255)<<8) + ((a & 0xFF00) >> 8)
#endif

#include "simple2x.h"
#include "avengpro.h"
#include "avdatax.h"
#include "avprotos.h"
#define ROUNDOFF 1.0E-30

#ifndef OS_UNIX
/* changed path of include file - SSRS - 26/22/93 */
/*#include "\p\ad11\autovar.h"*/
#include "autovar.h"
#else
/* changed path of include file - SSRS - 26/22/93 */
/*#include "../ad11/autovar.h"*/
#include "autovar.h"
#endif

#ifdef bc286
#pragma hdrstop
#endif

#ifdef WIN
LPSTR winmalloc(size_t size);
void winfree(LPSTR lptr);
#endif

#define sh_getc(which) \
  (unsigned char)((ad3in.shfile[which].curdataindex<ad3in.shdata[ad3in.shfile[which].curdatablock].numchars) ? \
   (ad3in.shdata[ad3in.shfile[which].curdatablock].data[ad3in.shfile[which].curdataindex++]) :   \
   (sh_fgetc(which)) )


