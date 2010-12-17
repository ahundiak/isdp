#include "machine.h"

/* avdata.c -- global data defs */

#ifdef WIN
#include <windows.h>
#endif
#include <stdio.h>
#include <stdlib.h>
/*	Changed for SCO/SOLARIS/SUNOS port MVR 22 Dec 1993 */
/*	Changed for SGI port MaC 032094 */
#if defined (__sgi) ||defined(OS_SUNOS) || defined(OS_SOLARIS) || defined(dec) || defined(rs6000) || defined(hp) || defined(OS_SCO_UNIX) || defined(OS_CLIX) || defined(OS_HPUX) 
/* changed the path of include file SSRS- 26/11/93 */
/*#include "../ad11/adcomp.h"*/
#include "../marinc/adcomp.h"
#else
#include <dos.h>
#include "\p\ad11\adcomp.h"
#endif

#include <math.h>
#include <ctype.h>
#include <string.h>
#ifdef microsoftc
#include <malloc.h>
#endif
#ifdef turboc
#include <alloc.h>
#endif
#include <fcntl.h>

/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifndef OS_UNIX
#include <sys/types.h> /* reversed slash - SSRS */
#include <sys/stat.h> /* reversed slash - SSRS */
#include <io.h>
#endif
#define SUFFIX
/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifndef OS_UNIX
/* changed the path of include file - SSRS - 26/11/93 */
/*#include "\p\ad11\autodir.h"*/
#include "\p\ad11\autodir.h"
#else
/* changed the path of include file - SSRS 26/11/93 */
/*#include "../ad11/autodir.h"*/
#include "../marinc/autodir.h"
#endif

#include "ad3disg.h"
#include "simple2x.h"
#include "simple2.h"
#include "avdatax.h"
#include "avprotos.h"

#include "avdata.h"

