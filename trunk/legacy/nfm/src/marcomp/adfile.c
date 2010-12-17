#include "machine.h"

/* adfile.c -- a file access package for dwgs, built on low-level
   functions for speed */
/* AV version only -- uses _dos_xxx functions */
/* note that, among other things, this module assumes we NEVER hit EOF */
#ifdef WIN
#include <windows.h>
#define winmalloc qq262
#define winfree   qq263
#endif
/*	Changed for SCO/SOLARIS/SUNOS port MVR 22 Dec 1993 */
/*	Changed for SGI port MaC 032094 */
#if !defined (__sgi) &&!defined(OS_SUNOS) && \
    !defined(OS_SOLARIS) && !defined(dec) && \
    !defined(rs6000) && !defined(hp) &&      \
    !defined(OS_SCO_UNIX) && !defined(OS_CLIX) && !defined(OS_HPUX) 
#include "c:\p\ad11\adcomp.h"
#else
/* changed path of include file - SSRS - 25/22/93 */
/*#include "../ad11/adcomp.h"*/
#include "adcomp.h"
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef bc286
#pragma warn -par
#endif
#ifdef microsoftc
#pragma function(memcpy,strcpy,strcat,strlen)
#endif
/* MSSP - 29 Dec 93. UNIXOS replaced with OS_UNIX */
#ifndef OS_UNIX
#include <io.h>
#include <dos.h>
#endif
#include <fcntl.h>
/*
#define FILEDEBUG
*/
#ifdef WIN
extern LPSTR winmalloc(size_t size);
extern void  winfree(LPSTR lptr);
#endif

#include "adfile.h"

#ifdef OLDCHDR
long ad_ftell(f)
AD_FILE *f;
#else
long ad_ftell(AD_FILE *f)
#endif
{
  return(f->bufpos+f->nexchind);
}

#ifdef OLDCHDR
void ad_filbuf(f)
AD_FILE *f;
#else
void ad_filbuf(AD_FILE *f)
#endif
{
#ifdef FILEDEBUG
short i;
#endif

#ifdef FILEDEBUG
for (i=0; i<20; i++)
  if (f==&adfcb[i]) printf("Filling file %d\n",i);
printf("filbuf, trying to read %d bytes\n",(f)->cbufsiz);
#endif

#ifdef DF
  _dos_read((f)->handle,(f)->cbuf,(f)->cbufsiz,(unsigned *)&(f)->lvl);
#else
  (f)->lvl=ad_read((f)->handle,(char *)(f)->cbuf,(f)->cbufsiz);
#endif

#ifdef FILEDEBUG
printf("filled with %d bytes\n",(f)->lvl);
#endif

  if ((f)->lvl==0) (f)->eofflag=1;
  (f)->bufbytes=(f)->lvl;
  (f)->nexchind=0;
}

#ifdef OLDCHDR
unsigned char ad_fgetc(f)
AD_FILE *f;
#else
unsigned char ad_fgetc(AD_FILE *f)
#endif
{
  if (((f)->lvl)<=0) {  /* <= cuz getc decrements */
    (f)->bufpos+=(f)->bufbytes;
    ad_filbuf(f);
  }
  (f)->lvl--;
  return((f)->cbuf[(f)->nexchind++]);
}

#ifdef OLDCHDR
AD_FILE *ad_fopen(path,accessmodes)
void *path;
void *accessmodes;
#else
AD_FILE *ad_fopen(void *path,void *accessmodes)
#endif
/* access is always read, binary, so ignore accessmodes */
{
  AD_FILE *f;
  short i,whichfcb;
  int oflags;

#ifdef FILEDEBUG
printf("ad_fopen %s\n",path);
#endif
  whichfcb = -1;
  for (i=0; i<20; i++)
    if (adfcb[i].handle==-1) {
      whichfcb=i;
      break;
    }
  if (whichfcb==-1) return(NULL);

  f = &adfcb[whichfcb];

#ifdef DF
  oflags=O_RDONLY;
  if (_dos_open(path,oflags,&(f)->handle)) return(NULL);
#else
/* MSSP 29 Dec 93. UNIXOS replaced with OS_UNIX */
#ifndef OS_UNIX
  oflags=O_RDONLY | O_BINARY;
#else
  oflags=O_RDONLY;
#endif
  if (((f)->handle=ad_open(path,oflags))==-1) return(NULL);
#endif
  (f)->flags=oflags;
  (f)->eofflag=(f)->bufbytes=(f)->lvl=(f)->cbufsiz=0;
  (f)->bufpos=0L;
  (f)->cbuf=NULL;
  (f)->nexchind=(f)->mallocedbuf=0;
  return(f);
}

#ifdef OLDCHDR
int ad_fclose(f)
AD_FILE *f;
#else
int ad_fclose(AD_FILE *f)
#endif
{
  short retval;

  if ((f)->mallocedbuf && (f)->cbuf!=NULL) ad_free((f)->cbuf);
  (f)->cbuf=NULL;
#ifdef DF
  retval=_dos_close((f)->handle);
#else
  retval=ad_close((f)->handle);
#endif
  (f)->handle = -1;
  (f)->bufpos=0L;
  (f)->nexchind=(f)->cbufsiz=(f)->lvl=(f)->bufbytes=(f)->flags=0;
  (f)->mallocedbuf=0;
  return(retval);
}

#ifdef OLDCHDR
int ad_setvbuf(f,buf,buftype,size)
AD_FILE *f;
char *buf;
int buftype;
unsigned short size;
#else
int ad_setvbuf(AD_FILE *f, char *buf, int buftype, unsigned short size)
#endif
/* always IOFBF, so we ignore buftype */
{
  if (buf==NULL) {
    (f)->cbuf=ad_malloc(size);
    if ((f)->cbuf!=NULL)
      (f)->mallocedbuf=1;
    else return(1);  /* error */
  }
  else {
    (f)->cbuf=buf;
    (f)->mallocedbuf=0;
  }
  (f)->nexchind=0;  /* probably unnecessary */
  (f)->cbufsiz=size;
  return(0);
}

#ifdef DF
void mylseek(int handle,long pos,int method)
{
  union REGS regs;

  regs.x.bx=handle;
  regs.x.cx=(pos >> 16);
  regs.x.dx=(pos & 0xFFFFL);
  regs.h.al=method;
  regs.h.ah=0x42;
  int86(0x21,&regs,&regs);
}
#endif


#ifdef OLDCHDR
int ad_fseek(f,offset,whence)
AD_FILE *f;
long offset;
int whence;
#else
int ad_fseek(AD_FILE *f, long offset, int whence)
#endif
{
  if (whence==1) {  /* change it to 0 -- note, whence==2 not supported */
    offset+=(f->bufpos+f->nexchind);
    whence=0;
  }
/* from here on assume whence is 0 */
  if (offset>=(f)->bufpos && offset<(f)->bufpos+(f)->bufbytes) {
/* it's in the area we're already holding, so just move the pointer */
    (f)->nexchind=(unsigned short)(offset - (f)->bufpos);
    (f)->lvl=(f)->bufbytes-(unsigned short)(offset - (f)->bufpos);
  }
  else {
    (f)->bufpos = offset & 0xFFFFFE00L;
#ifdef DF
    mylseek((f)->handle,(f)->bufpos,0);
#else
    ad_lseek((f)->handle,(f)->bufpos,0);
#endif
    ad_filbuf(f);
    (f)->lvl -= (short)(offset - (f)->bufpos);  /* now move to the right position */
    (f)->nexchind = (short)(offset - (f)->bufpos);
  }
  (f)->eofflag=0;
  return(0);
}

#ifdef OLDCHDR
int ad_fread(bufvoid,size,num,f)
void *bufvoid;
unsigned int size;
unsigned int num;
AD_FILE *f;
#else
int ad_fread(void *bufvoid, unsigned int size, unsigned int num, AD_FILE *f)
#endif
/* this assumes we will always find enough data to satisfy the request */
{
  long bytesleft;
  unsigned short bytestoread;
  unsigned char *buf=(unsigned char *)bufvoid;

#ifdef FILEDEBUG
printf("ad_fread size:%d, num:%d\n",size,num);
#endif
  bytesleft=(long)size*(long)num;

  while (bytesleft > 0L) {
#ifdef FILEDEBUG
printf("(f)->lvl is %d\n",(f)->lvl);
#endif
    if (!(f)->lvl) {
      (f)->bufpos+=(f)->bufbytes;
#ifdef FILEDEBUG
printf("Filling buf\n");
#endif
      ad_filbuf(f);  /* get something in here */
    }
    bytestoread=(short)min((long)(f)->lvl,bytesleft);
#ifdef FILEDEBUG
printf("bytestoread is %d\n",bytestoread);
#endif
    memcpy(buf,&((f)->cbuf[(f)->nexchind]),bytestoread);
    (f)->lvl-=bytestoread;
    (f)->nexchind+=bytestoread;
    buf+=bytestoread;
    bytesleft-=bytestoread;
  }
#ifdef FILEDEBUG
printf("returning from ad_fread %d\n",num);
printf("With level %d\n",(f)->lvl);
#endif
  return(num);
}

#ifdef OLDCHDR
char *ad_fgets(s,n,f)
char *s;
int n;
AD_FILE *f;
#else
char *ad_fgets(char *s, int n, AD_FILE *f)
#endif
{
  short count;
  char lastchar;

#ifdef FILEDEBUG
printf("in ad_fgets ");
#endif
  count=n;
  do {
    if (count) {
/*      *s++ = lastchar = ad_getc(f); */
      *s++ = lastchar = ((--((f)->lvl) >= 0) ? ((f)->cbuf[(f)->nexchind++]) : ad_fgetc(f));
#ifdef FILEDEBUG
printf("%c",lastchar);
#endif
      count--;
    }
  } while (count && lastchar!='\n' && !ad_feof(f));
  if (ad_feof(f)) s--;
  *s=0;
#ifdef FILEDEBUG
#endif
  return(s);
}

#ifdef OLDCHDR
void initadfilepak()
#else
void initadfilepak(void)
#endif
{
  short i;

  for (i=0; i<20; i++) adfcb[i].handle = -1;
}
