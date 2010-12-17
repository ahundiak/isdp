/* adrhdr.h -- standard header for adr routines */
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
/*changed path of include file - SSRS - 25/11/93 */
/*#include "../ad3/ad3disg.h"*/
#include "./ad3disg.h"
#else
/* changed path of include file - SSRS - 25/11/93 */
/*#include "\p\ad3\ad3disg.h"*/
#include "./ad3disg.h"
/* changed path of include file - SSRS - 25/11/93 */
/*#include "\p\ad3\adrproto.h"*/
#include "./adrproto.h"
#endif

#include "autovar.h"
#include "autodir.h"

#if defined(microsoftc) || defined(watcomc) || defined(zortechc) || defined(highc) || defined(bc286)
#include <sys\types.h>
#include <sys\stat.h>
#endif

#if defined(microsoftc) || defined(watcomc)
#include <malloc.h>
#endif

/* this was where turboc was also */
#if defined(zortechc)
#define frdw() (adin.ztemp=(ad_getc(adin.dwgfiler SUBN) & 0xFF), adin.ztemp|=((unsigned short)(ad_getc(adin.dwgfiler SUBN)<<8)))
#else
#if defined(BIGENDIAN)
extern short frdw();
#else
#define frdw() ((unsigned short)ad_getc(adin.dwgfiler SUBN) & (unsigned short)0xFF) | ((unsigned short)(ad_getc(adin.dwgfiler SUBN)<<8))
#endif
#endif

#define frdc() ((char)ad_getc(adin.dwgfiler SUBN))

#ifdef AD3
#ifdef OS_UNIX
/* changed the path of include file - SSRS - 25/11/93 */
/*#include "../ad3/avprotos.h"*/
#include "./avprotos.h"
/* changed the path of include file - SSRS - 25/11/93 */
/*#include "../ad3/avdatax.h"*/
#include "./avdatax.h"
#else
#include "\p\ad3\avdatax.h"
#include "\p\ad3\avprotos.h"
#endif
#endif

#if !defined(QUADWORDALIGNED) && !defined(BIGENDIAN)
#ifdef AD3
#define rdreal()   *((double *)adin.entptr), adin.entptr+=SIZEOFDOUBLE
#define rd2real(a) memcpy(a,adin.entptr,2*SIZEOFDOUBLE), adin.entptr+=2*SIZEOFDOUBLE
#define rd3real(a) memcpy(a,adin.entptr,3*SIZEOFDOUBLE), adin.entptr+=3*SIZEOFDOUBLE
/*
struct vertexstru {
    double x1,y1,z1;
    double startwidth,endwidth;
    double bulge;
    char vertflag;
    double tangentdir;
    struct vertexstru *link;
  } ;
*/
#else
extern double rdreal(void);   /* for ad 2 */
extern void rd2real(void *a);
extern void rd3real(void *a);
#endif
#endif


#define rdc()    *adin.entptr, adin.entptr++

#if !defined(QUADWORDALIGNED) && !defined(BIGENDIAN)
#define rdlong() *((long *)  adin.entptr), adin.entptr+=SIZEOFLONG
#define rdw()    *((short *) adin.entptr), adin.entptr+=SIZEOFSHORT
#define buf2long *(long *)
#define buf2double *(double *)
#define buf2short *(short *)
#else
#define rdw() (adin.entptr[0] & 255)+((adin.entptr[1] & 255)<<8), adin.entptr+=SIZEOFSHORT
#define rdlong() (long)(adin.entptr[0] & 255)+(long)(adin.entptr[1] & 255)<<8+(long)(adin.entptr[2] & 255)<<16+(long)(adin.entptr[3] & 255)<<24,adin.entptr+=SIZEOFLONG
extern double rdreal();
extern void rd2real();
extern void rd3real();
/* these are defined as functions in adrfrd.c for bigendian/quadwordaligned */

extern long buf2long();
extern double buf2double();
extern short buf2short();
#endif


/* function prototypes */
extern  double frdreal _((void));
extern  long frdlong _((void));
extern  short readheaderqq _((void));
extern  void readheader1qq _((void));
extern  void readheader2qq _((void));
extern  void rdacadstr _((char *strng));
extern  void readextrusioninfo _((void));
extern  void linerqq _((void));
extern  void pointrqq _((void));
extern  void circlerqq _((void));
extern  void shaperqq _((void));
extern  void text2rqq _((unsigned short t_entmask, struct adtdatastru *tdata));
extern  void textrqq _((void));
extern  void arcrqq _((void));
extern  void tracerqq _((void));
extern  void solidrqq _((void));
extern  void sblockrqq _((void));
extern  void eblockrqq _((void));
extern  void insertrqq _((void));
extern  void attdefrqq _((void));
extern  void attribrqq _((void));
extern  void seqendrqq _((void));
extern  void plinerqq _((void));
extern  void vertexrqq _((void));
extern  void line3drqq _((void));
extern  void face3drqq _((void));
extern  void assodimrqq _((unsigned short entmask));
extern  void vportentrqq _((void));
extern  void skipentrqq _((void));
extern  short readentmainqq _((void));
extern  short readextendeddataqq _((void));
extern  short readentityav _((void));
extern void dwgfilerseek _((long newloc));
extern void readpastentity _((short numbytes));
extern void readgarbage _((char *garbagestr,short length));
#ifdef WIN
extern LPSTR winmalloc _((size_t size));
extern void  winfree _((LPSTR lptr));
#endif
