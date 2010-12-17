
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrstend.c -- library routines for accessing autocad drawing files */
/* initialize and terminate read functions */
#include "adrhdr.h"

#ifndef OLDCHDR
void terminateread(void)
#else
void terminateread()
#endif
{
  ad_fclose(adin.dwgfilerent SUBN);
  ad_fclose(adin.dwgfilerext SUBN);
  ad_fclose(adin.dwgfilerblk SUBN );
#ifdef AD3
  ad_fclose(adin.dwgfilerblk2 SUBN);
#endif
}

#ifndef OLDCHDR
short initializeread(char *fn,unsigned short buffersize,
                     unsigned short blkbufsize,unsigned short extbufsize)
#else
short initializeread(fn,buffersize,blkbufsize,extbufsize)
char *fn;
unsigned short buffersize;
unsigned short blkbufsize;
unsigned short extbufsize;
#endif
{
  short i;
  char *cptr,*cptr2;

#ifdef AD3
#define AVBUF  ad3in.avbuf
#define AVBUF2 ad3in.avbuf2
#define AVBUF3 ad3in.avbuf3
#define AVBUF4 ad3in.avbuf4
#else
#define AVBUF  NULL
#define AVBUF2 NULL
#define AVBUF3 NULL
#define AVBUF4 NULL
#endif

  adin.needtoreadsequencestart SUBN=0;
#ifndef AV
  adct.copymode SUBN=0;
#endif

/* store the filename part of the filename */
  cptr2=cptr=fn;

/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifdef OS_UNIX
  while ((cptr=strchr(cptr,'/'))!=NULL) {
#else
  while ((cptr=strchr(cptr,'\\'))!=NULL) {
#endif
    cptr++;
    cptr2=cptr;
  }
/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifdef OS_UNIX
if (cptr2[1]==':') cptr2+=2;  /* skip drive identifier, if any */
#endif
  cptr=adin.dwgrootname;
  while (*cptr2!='.') *cptr++=*cptr2++;
  *cptr=0;
  i=strlen(adin.dwgrootname)-1;
  while (i>=0) {
    if (adin.dwgrootname[i]>='a' && adin.dwgrootname[i]<='z')
      adin.dwgrootname[i]=adin.dwgrootname[i]+'A'-'a';
    i--;
  }

  if ((adin.dwgfilerent SUBN=ad_fopen(fn,"rb"))==NULL) {
    return(0);
  }
/* setvbuf returns 0 if successful */

  i=ad_setvbuf(adin.dwgfilerent SUBN,AVBUF,_IOFBF,(size_t)buffersize);
  if (i) {
    ad_fclose(adin.dwgfilerent SUBN);
    return(0);
  }

  if ((adin.dwgfilerext SUBN=ad_fopen(fn,"rb"))==NULL) {
    ad_fclose(adin.dwgfilerent SUBN);
    return(0);
  }
/* setvbuf returns 0 if successful */
  i=ad_setvbuf(adin.dwgfilerext SUBN,AVBUF3,_IOFBF,(size_t)extbufsize);
  if (i) {
    ad_fclose(adin.dwgfilerent SUBN);
    ad_fclose(adin.dwgfilerext SUBN);
    return(0);
  }

#ifdef AD3       /* only use adin.dwgfilerblk2 SUBN for autoview */
  if ((adin.dwgfilerblk2 SUBN=ad_fopen(fn,"rb"))==NULL) {
    ad_fclose(adin.dwgfilerent SUBN);
    ad_fclose(adin.dwgfilerext SUBN);
    return(0);
  }
/* setvbuf returns 0 if successful */
  i=ad_setvbuf(adin.dwgfilerblk2 SUBN,AVBUF4,_IOFBF,(size_t)ad3in.maxavbufsiz);
  if (i) {
    ad_fclose(adin.dwgfilerent SUBN);
    ad_fclose(adin.dwgfilerext SUBN);
    ad_fclose(adin.dwgfilerblk2 SUBN);
    return(0);
  }
#endif

  if ((adin.dwgfilerblk SUBN =ad_fopen(fn,"rb"))==NULL) {
    ad_fclose(adin.dwgfilerent SUBN);
    ad_fclose(adin.dwgfilerext SUBN);
#ifdef AD3
    ad_fclose(adin.dwgfilerblk2 SUBN);
#endif
    return(0);
  }
/* setvbuf returns 0 if successful */
  i=ad_setvbuf(adin.dwgfilerblk SUBN ,AVBUF2,_IOFBF,(size_t)blkbufsize);
  if (i) {
    ad_fclose(adin.dwgfilerent SUBN);
    ad_fclose(adin.dwgfilerext SUBN);
    ad_fclose(adin.dwgfilerblk SUBN);
#ifdef AD3
    ad_fclose(adin.dwgfilerblk2 SUBN);
#endif
    return(0);
  }
  else return(1);
}
