
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* addata.c -- library routines for accessing autocad drawing files */

#ifdef WIN
#include <windows.h>
#endif

#include "adcomp.h"
#ifdef SUFF
#define SUFFIX [4]
#define SUBN [adct.dwgno]
#else
#define SUFFIX
#define SUBN
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(microsoftc ) || defined(watcomc) || defined(zortechc)
#include <sys\types.h>
#include <sys\stat.h>
#endif

#include "autodir.h"  /* external defs */
#include "autodirm.h"
#include "autovar.h"  /* external defs */
#include "autovarm.h" /* actual defs */
#include "mess.h"

#ifndef OLDCHDR
void initad(void)
#else
void initad()
#endif
{
  initadfilepak();
}

#ifdef WIN

LPSTR winmalloc(size_t size)   /* windows memory allocation */
{
  return(GlobalLock(GlobalAlloc(GMEM_MOVEABLE,(unsigned long)size)));
}

void winfree(LPSTR lptr)
{
  HGLOBAL h;

  h = (HANDLE)GlobalHandle(HIWORD(lptr));
  GlobalUnlock(h);
  GlobalFree(h);
}
#endif
