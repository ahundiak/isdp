/* adwhdr.h -- header for autodirect write modules */
#ifdef WIN
#include <windows.h>
#endif
#include "adcomp.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef OS_UNIX
#include <io.h>
#ifdef microsoftc
#pragma function(strcpy,strcat,strlen)
#endif
#endif

#ifdef turboc
#include "all.h"
#endif

#ifdef SUFF
#define SUFFIX [4]
#define SUBN [adct.dwgno]
#else
#define SUFFIX
#define SUBN
#endif

#ifdef OS_UNIX
/* changed the path of include file - SSRS - 25/1/93 */
/*#include "../ad3/ad3disg.h"*/
#include "./ad3disg.h"
#else
#include "\p\ad3\ad3disg.h"
#include "\p\ad11\adwproto.h"
#endif

#include "autovar.h"
#include "autodir.h"

#if defined(microsoftc) || defined(watcomc) || defined(zortechc) || defined(highc)
#include <sys\types.h>
#include <sys\stat.h>
#endif

#if defined(microsoftc) || defined(watcomc)
#include <malloc.h>
#endif


/* variables local to this module (hope this works) */

#define  clearbuffer(a)   memset(adin.writebuf,'\0',a)

#define fwrw(ch) putc((ch) & 255,adin.dwgfilew SUBN),putc(((ch) >> 8),adin.dwgfilew SUBN)
#define fwrc(ch) putc((ch),adin.dwgfilew SUBN)

/* this routine controls the writing of AutoCAD drawing files.
   setoutputversion, sets the version of AutoCAD dwg written, and whatever
   parameters we know to their correct values for that version.
*/

/* function prototypes */

extern  void fwrreal _((double r));
extern  void fwrlong _((long l));
extern  void wrreal _((double r));
#ifndef BIGENDIAN
extern  void wr2real _((void *a));
extern  void wr3real _((void *a));
#else
extern void wr2real _((char *a));
extern void wr3real _((char *a));
#endif
extern  void wrw _((short w));
extern  void wrlong _((long l));
extern  void wracadstr _((char *strng));
extern  void writeextrusioninfo _((void));
extern  void linewqq _((unsigned short entmask));
extern  void pointwqq _((unsigned short entmask));
extern  void circlewqq _((unsigned short entmask));
extern  void shapewqq _((unsigned short entmask));
extern  void text2wqq _((unsigned short entmask,struct adtdatastru *tdata));
extern  void textwqq _((unsigned short entmask));
extern  void arcwqq _((unsigned short entmask));
extern  void tracewqq _((unsigned short entmask));
extern  void solidwqq _((unsigned short entmask));
extern  void sblockwqq _((unsigned short entmask));
extern  void eblockwqq _((void));
extern  void insertwqq _((unsigned short entmask));
extern  void attdefwqq _((unsigned short entmask));
extern  void attribwqq _((unsigned short entmask));
extern  void seqendwqq _((void));
extern  void plinewqq _((unsigned short entmask));
extern  void vertexwqq _((unsigned short entmask));
extern  void line3dwqq _((unsigned short entmask));
extern  void face3dwqq _((unsigned short entmask));
extern  void assodimwqq _((unsigned short entmask));
extern  void vportentwqq _((void));
extern  void dogarbage1 _((void));
extern  void dogarbage2 _((void));
extern  void dogarbage9 _((void));
extern  void dogarbage10 _((void));
extern  void dogarbage11 _((void));
extern  void dogarbage12 _((void));
extern  void dogarbage14 _((void));
extern  void dogarbage15 _((void));
extern  void dogarbage16 _((void));
extern  void dogarbage17 _((void));
extern  void dogarbage18 _((void));
extern  void dogarbage20 _((void));
extern  void dogarbage21 _((void));
extern  void dogarbage22 _((void));
extern  void dogarbage23 _((void));
extern  void dogarbage24 _((void));
extern  void dogarbage25 _((void));
extern  void zeroes _((short count));
#ifdef WIN
extern LPSTR winmalloc _((size_t size));
extern void  winfree _((LPSTR lptr));
#endif

