
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* avloads2.c -- 2nd shape control routine set */
#include "avhdr.h"

/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifdef OS_UNIX
  static char legalshapefiles[]="complexcyrilliccyriltlcgothicegothicggothicigreekcgreeksitalicitaliccitalictmonotxtromancromandromansromantscriptcscriptssimplexsyastrosymapsymathsymeteosymusictxt";
#else
  static char legalshapefiles[]="COMPLEXCYRILLICCYRILTLCGOTHICEGOTHICGGOTHICIGREEKCGREEKSITALICITALICCITALICTMONOTXTROMANCROMANDROMANSROMANTSCRIPTCSCRIPTSSIMPLEXSYASTROSYMAPSYMATHSYMETEOSYMUSICTXT";
#endif
#define ushort unsigned short
long shlru,zeroloc;

/* prototypes */

short createsmallindex _((struct shfilestru *shf,int fh));
short fillbigindex _((struct shfilestru *shf, int fh, long *fromwhere, unsigned short shapeno));
short createbigindex _((struct shfilestru *shf,int fh));
short getdatablock _((short shfileno, long fileloc));
short findavailblock _((short shfileno));
struct shindexstru *lfindsh _((struct shindexstru *shi,short num,unsigned short shapeno));
long  compatiblefilelength _((int handle));
#ifdef BIGENDIAN
void  fliplong _((long *l));
#endif


#ifndef OLDCHDR
void fliplong(long *l)
#else
void fliplong(l)
long *l;
#endif
{
  char *cptr,ch;

  cptr=(char *)l;
  ch=cptr[0]; cptr[0]=cptr[3]; cptr[3]=ch;
  ch=cptr[1]; cptr[1]=cptr[2]; cptr[2]=ch;
}

#ifndef OLDCHDR
void initsh(void)
#else
void initsh()
#endif
{
  short i;
  struct shfilestru *sptr;
  struct shdatastru *sdptr;

  shlru=0L;
  sptr=&ad3in.shfile[0];
  for (i=0; i<MAXSHFILESTRU; i++) {      /* initialize file control blocks */
    sptr->name[0]=0;
    sptr->index=NULL;
    sptr->bffh=-1;
    (sptr++)->lru=-1L;
  }
  sdptr=&ad3in.shdata[0];
  for (i=0; i<MAXSHDATABLOCKS; i++) {    /* initialize data blocks */
    sdptr->data=NULL;
    sdptr->startaddr=0L;
    sdptr->shfileno=-1;
    sdptr->lru=-1L;
    (sdptr++)->numchars=0;
  }
/* initialize simplex */
  sptr=&ad3in.shfile[0];
  strcpy(sptr->name,"SIMPLEX.SHX");
  sptr->index=simpindptr;
  sptr->flags=FONT10 | ACADFONT;
  sptr->validindexentries=100;
  sptr->above=21;
  sptr->below=7;
  sptr->modes=2;
  sptr->minshp=0;
  sptr->maxshp=129;
  sptr->numshp=100;
  sdptr=&ad3in.shdata[0];
  sdptr->shfileno=0;
  sdptr->startaddr=0L;
  sdptr->numchars=4608;
  sdptr->data=(char *)simpfontstrs;
}

#ifndef OLDCHDR
long compatiblefilelength(int handle)
#else
long compatiblefilelength(handle)
int handle;
#endif
/* a filelength function that works under UNIX and DOS */
{
  struct stat statbuf;

  fstat(handle,&statbuf);
  return(statbuf.st_size);
}

#ifndef OLDCHDR
short createsmallindex(struct shfilestru *shf,int fh)
#else
short createsmallindex(shf,fh)
struct shfilestru *shf;
int fh;
#endif
{
  short *tmp,*tmp2;
  short i,len;
  long floc;
  struct shindexstru *sptr;

  if ((shf->index=(struct shindexstru *)ad_malloc(shf->numshp*sizeof(struct shindexstru)))==NULL)
	return(0);
  if ((tmp=(short *)ad_malloc(shf->numshp*4))==NULL) {   /* read index into this temp area */
    ad_free(shf->index);
    return(0);
  }
  ad_read(fh,(char *)tmp,shf->numshp*4);
  tmp2=tmp;

  zeroloc=-1L;
  floc=0L;
  sptr=shf->index;
  for (i=0; i<shf->numshp; i++) {
	sptr->whichshape=*tmp2++;
    sptr->fileloc=floc;
#ifdef BIGENDIAN
    flipbytes(sptr->whichshape);  /* don't flip fileloc, it's correct already */
#endif
    if (sptr->whichshape==0) zeroloc=sptr->fileloc;
    sptr++;
    len = *tmp2++;
#ifdef BIGENDIAN
    flipbytes(len);
#endif
	floc+=len;
  }
  ad_free(tmp);
  shf->validindexentries=shf->numshp;

  floc=ad_lseek(fh,0L,1);           /* get current loc */
  for (i=0; i<shf->numshp; i++)
    shf->index[i].fileloc+=floc;
  if (zeroloc!=-1L) zeroloc+=floc;

  return(1);
}

#ifndef OLDCHDR
int indcomp(const void *a,const void *b)    /* comparison function for sort & search */
#else
int indcomp(a,b)    /* comparison function for sort & search */
void *a,*b;
#endif
{
  if (*(unsigned short *)a < *(unsigned short *)b) return(-1);
  else if (*(unsigned short *)a > *(unsigned short *)b) return(1);
  else return(0);
}

#ifndef OLDCHDR
struct shindexstru *lfindsh(struct shindexstru *shi,short num,unsigned short shapeno)
#else
struct shindexstru *lfindsh(shi,num,shapeno)
struct shindexstru *shi;
short num;
unsigned short shapeno;
#endif
/* find shapeno in the index */
{
  struct shindexstru *sptr;
  register short count;

  sptr=shi;
  count=0;
  while (count<num && sptr->whichshape!=shapeno) {
	count++; sptr++;
  }
  if (count<num) return(sptr);
  else return(NULL);
}

#ifndef OLDCHDR
short fillbigindex(struct shfilestru *shf, int fh, long *fromwhere,unsigned short shapeno)
#else
short fillbigindex(shf,fh,fromwhere,shapeno)
struct shfilestru *shf;
int fh;
long *fromwhere;
unsigned short shapeno;
#endif
/* fills from current location in file */
/* returns 0 if couldn't load index, 1 if loaded, 2 if loaded and target
   shape is found */
{
  char *tmp,*tmp2;
  unsigned short bytesavail,bytestoread;
  long fileloc,nextfileloc;
  struct shindexstru *sptr;
  short retval;

  shf->bflastindexreadloc=fileloc=*fromwhere;

  shf->validindexentries=0;
  if ((tmp=ad_malloc((size_t)BIGFONTINDEXSIZE*8))==NULL) return(0);
  bytestoread=(ushort)min((long)((ushort)BIGFONTINDEXSIZE)*((ushort)8),
                         shf->bfindexend - fileloc);
  bytesavail=ad_read(fh,tmp,bytestoread);
  nextfileloc=fileloc+bytesavail;
  tmp2=tmp;

  zeroloc=-1L;
  retval=1;
  sptr=&shf->index[0];
  for (;;) {
    if (bytesavail==0) {
      fileloc=nextfileloc;
      bytestoread=(short)min((long)(BIGFONTINDEXSIZE - shf->validindexentries)*8,shf->bfindexend - fileloc);
      if (bytestoread==0) break;
      bytesavail=ad_read(fh,tmp,bytestoread);
      nextfileloc=fileloc+bytesavail;
      tmp2=tmp;
    }

    if (bytesavail==0) break;  /* don't read more than there are */

    sptr->whichshape=*(short *)tmp2;
	tmp2+=4;  /* skip the number and length */
    if (shapeno!=0 && shapeno==sptr->whichshape) {
      retval=2;  /* found */
    }
	sptr->fileloc=*(long *)tmp2;
    tmp2+=4;
    bytesavail-=8;
#ifdef BIGENDIAN
    flipbytes(sptr->whichshape);
    fliplong(&sptr->fileloc);
#endif
    if (sptr->fileloc!=0L) {
      if (sptr->whichshape==0) {
        zeroloc=sptr->fileloc;     /* hold for later */
      }
      sptr++;
      shf->validindexentries++;
    }
    if (shf->validindexentries==BIGFONTINDEXSIZE) break;
  }

  *fromwhere=nextfileloc;
  ad_free(tmp);

/*
for (i=0; i<shf->validindexentries; i++)
  printf("Shape[%d] is %u  loc: %ld\n",
    i,shf->index[i].whichshape,shf->index[i].fileloc);
*/

  return(retval);
}

#ifndef OLDCHDR
short createbigindex(struct shfilestru *shf,int fh)
#else
short createbigindex(shf,fh)
struct shfilestru *shf;
int fh;
#endif
{
  long fileloc;

  if ((shf->index=(struct shindexstru *)ad_malloc(BIGFONTINDEXSIZE*sizeof(struct shindexstru)))==NULL)
    return(0);
  fileloc=shf->bflastindexreadloc=shf->bfindexstart=ad_lseek(fh,0L,1);
  shf->bfindexend=shf->bfindexstart + (long)(shf->bfnumindexentries)*8L;

  if (!fillbigindex(shf,fh,&fileloc,0)) {
    ad_free(shf->index);
    shf->index=NULL;
    shf->bflastindexreadloc=0L;
    return(0);
  }
  return(1);
}

#ifndef OLDCHDR
short readshapesignature(int filehandle, struct shfilestru *shfptr)
#else
short readshapesignature(filehandle,shfptr)
int filehandle;
struct shfilestru *shfptr;
#endif
{
  char signature[40];
  short i;

/* identify the file type */
  ad_read(filehandle,signature,24);    /* read signature string */

  i=24;
  if (signature[23]!=26) {
    do
      ad_read(filehandle,&signature[i],1);    /* read more signature string */
    while (i<40 && signature[i++]!=26);
  }
  signature[i]=0;

  shfptr->flags=0;
  if (strstr(signature,"bigfont"))  shfptr->flags |= BIGFONT10;
  else if (strstr(signature,"1.0")) shfptr->flags |= FONT10;
  else if (strstr(signature,"1.1")) shfptr->flags |= FONT11;

  if (shfptr->flags & (BIGFONT10 | FONT10 | FONT11)) return(1);
  else return(0);
}

#ifndef OLDCHDR
void readbigfontheaderinfo(int filehandle,struct shfilestru *shfptr)
#else
void readbigfontheaderinfo(filehandle,shfptr)
int filehandle;
struct shfilestru *shfptr;
#endif
{
  short i;
  short *rptr;

  ad_read(filehandle,(char *)&shfptr->bfindexentrysize,2);
  ad_read(filehandle,(char *)&shfptr->bfnumindexentries,2);
  ad_read(filehandle,(char *)&shfptr->bfnumranges,2);
#ifdef BIGENDIAN
  flipbytes(shfptr->bfindexentrysize);
  flipbytes(shfptr->bfnumindexentries);
  flipbytes(shfptr->bfnumranges);
#endif
  rptr=(short *)&shfptr->bfrange[0][0];
  for (i=0; i<(short)shfptr->bfnumranges; i++) {
    ad_read(filehandle,(char *)rptr,4);
#ifdef BIGENDIAN
    flipbytes(rptr[0]);
    flipbytes(rptr[1]);
#endif
    rptr+=2;
  }
}


#ifndef OLDCHDR
void readsmallfontheaderinfo(int filehandle,struct shfilestru *shfptr)
#else
void readsmallfontheaderinfo(filehandle,shfptr)
int filehandle;
struct shfilestru *shfptr;
#endif
{
  ad_read(filehandle,(char *)&shfptr->minshp,2);
  ad_read(filehandle,(char *)&shfptr->maxshp,2);
  ad_read(filehandle,(char *)&shfptr->numshp,2);
#ifdef BIGENDIAN
  flipbytes(shfptr->minshp);
  flipbytes(shfptr->maxshp);
  flipbytes(shfptr->numshp);
#endif
}

#ifndef OLDCHDR
short findavailblock(short shfileno)
#else
short findavailblock(shfileno)
short shfileno;
#endif
/* returns 0 if none found, else the blockno which was found */
{
  short i;
  short blockno;
  long minlru;

  for (i=1; i<MAXSHDATABLOCKS; i++)    /* look for one that's totally unused */
	if (ad3in.shdata[i].data==NULL) break;   /* avoiding the simplex block */
  if (i<MAXSHDATABLOCKS) {             /* allocate and use this block */
    blockno=i;
    if ((ad3in.shdata[blockno].data=ad_malloc(DATABLOCKSIZE))==NULL) {
      return(0);
    }
  }
  else {
    minlru=0x3FFFFFFFL;
    for (i=1; i<MAXSHDATABLOCKS; i++)  /* now find least recently used */
                                       /* avoiding blocks from this file */
      if (ad3in.shdata[i].shfileno!=shfileno && ad3in.shdata[i].lru<minlru) {      /* again avoiding simplex block */
        minlru=ad3in.shdata[i].lru;
        blockno=i;
      }
    if (minlru==0x3FFFFFFFL) {           /* no blocks found not from this file */
      for (i=1; i<MAXSHDATABLOCKS; i++)  /* now find least recently used */
                                         /* INCLUDING blocks from this file */
        if (ad3in.shdata[i].lru<minlru) {      /* again avoiding simplex block */
          minlru=ad3in.shdata[i].lru;
          blockno=i;
        }
    }
  }
  return(blockno);
}

#ifndef OLDCHDR
void DefaultExamineshapefile(char *shapefile,char *pathbuf)
#else
void DefaultExamineshapefile(shapefile,pathbuf)
char *shapefile;
char *pathbuf;
#endif
/* the default shape file examine -- if the file isn't pathed to the right place,
   then search the ACAD environment variable for the shapefile */
{
  char *envptr,*cptr;
  char testpath[128];
  short lastone,z,i;
  char acadenv[128];

/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifdef OS_UNIX
  static char pathchar='\\';
  static char oldpathchar='/';
#else
  static char pathchar='/';
  static char oldpathchar='\\';
#endif

  for (i=0; i<(short)strlen(shapefile); i++)
    if (shapefile[i]==oldpathchar) shapefile[i]=pathchar;

/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifdef OS_UNIX
/* remove DOS drive specifier if present */
  if (shapefile[1]==':')
    for (i=0; i<(short)strlen(shapefile)-1; i++)  /* get the null also */
      shapefile[i]=shapefile[i+2];
#endif

/* make sure it has an extension */
  if (strstr(shapefile,".shx")==NULL && strstr(shapefile,".SHX")==NULL
    && shapefile[strlen(shapefile)-4]!='.')
    strcat(shapefile,".shx");

/* if it's a fully qualified path, just copy it back and return */
  if (strchr(shapefile,pathchar)!=NULL) {
    strcpy(pathbuf,shapefile);
    return;
  }

  if (ad3ct.shapepath[0]) {   /* try the shapepath variable */
    strcpy(pathbuf,ad3ct.shapepath);
    strcat(pathbuf,shapefile);
    if (!access(pathbuf,0)) return;
  }

  strcpy(pathbuf,shapefile);  /* this is the current valid option */
        					/* filename w/o path (poss drive id, though) */

  if (!access(shapefile,0)) return;   /* it is there (current dir) */
  else {

/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifdef OS_UNIX
    if (strchr(shapefile,':')!=NULL) return;  /* path with drive id */
#endif

    if ((envptr=getenv("ACAD"))==NULL) return;  /* no environment to search */
    if (strlen(envptr) > 127) return;
	strcpy(acadenv,envptr);
	envptr=acadenv;

    lastone=0;
    cptr=envptr;
    do {
      while (*cptr!=';' && *cptr!=0) cptr++;
      if (*cptr==0) lastone=1;
      *cptr=0;
      strcpy(testpath,envptr);
      if (testpath[(z=strlen(testpath))-1]!=pathchar) {
        testpath[z]=pathchar;
        testpath[z+1]=0;
      }

      strcat(testpath,shapefile);
      if (!access(testpath,0)) {
        strcpy(pathbuf,testpath);
        return;
      }
	  cptr++;
	  envptr=cptr;
    } while (!lastone);
  }
}

#ifndef OLDCHDR
short sh_open(char *fn)  /* open a shape file */
#else
short sh_open(fn)  /* open a shape file */
char *fn;
#endif
{
  short i,j,which,blockstoload;
  long minlru,temploc;
  int filehandle;
  char *cptr,*cptr2,ch;
  struct shfilestru *shfptr;
  struct shdatastru *sdptr;
  char tempdata[5];
  char filename[128];
  char tfn[128];

  if (fn[0] & 128) return(0);  /* already tried and failed */

/* cut off "pfb" types (really, any non-shx) */
  if (strchr(fn,'.')!=NULL &&
      strstr(fn,".shx")==NULL &&
      strstr(fn,".SHX")==NULL) {
    return(0);
  }
/* see if we have it open already */
  for (i=0; i<MAXSHFILESTRU; i++)
    if (!strcmp(fn,ad3in.shfile[i].origname)) break;

  if (i<MAXSHFILESTRU) {
    return(i);
  }
  strcpy(tfn,fn);
  cptr=tfn;                       /* strlwr */
  while (*cptr!=0) {

/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifdef OS_UNIX
    if (*cptr>='A' && *cptr<='Z') *cptr+='a'-'A';
#else
    if (*cptr>='a' && *cptr<='z') *cptr+='A'-'a';
#endif
    cptr++;
  }

  if (ad_Examineshapefile!=NULL) (*ad_Examineshapefile)(tfn,filename);
  else {
    strcpy(filename,ad3ct.shapepath);
    memcpy(&filename[strlen(filename)],tfn,strlen(tfn)+1);
  }

/* if we don't have it open already, try to open it */
  if ((filehandle=ad_open(filename,OPENFLAGS))==-1) {
    fn[0] |= 128;  /* indicate failure */
    return(0);
  }

 /* now, find an available shfile struct */
  minlru=0x3FFFFFFFL;
  which=-1;
  for (i=1; i<MAXSHFILESTRU; i++) {  /* avoid simplex */
    if (ad3in.shfile[i].lru<minlru) {
      minlru=ad3in.shfile[i].lru;
      which=i;
    }
  }
  if (ad3in.shfile[which].name[0])
    sh_close(ad3in.shfile[which].name);

  shfptr=&ad3in.shfile[which];

  if (!readshapesignature(filehandle,shfptr)) {
    ad_close(filehandle);
    fn[0] |= 128;
    return(0);
  }

/* see if this is an AutoCAD - supplied font */
  cptr=strrchr(filename,'\\');
  if (cptr==NULL) cptr=strrchr(filename,':');
  if (cptr!=NULL) cptr++;
	else cptr=filename;
  cptr2=strrchr(filename,'.');
  if (cptr2!=NULL) *cptr2=0;
  if (strstr(legalshapefiles,cptr)!=NULL)
    shfptr->flags|=ACADFONT;
  if (cptr2!=NULL) *cptr2='.';

/* initialize other info */
  strcpy(shfptr->name,filename);
  strcpy(shfptr->origname,fn);
  shfptr->len=compatiblefilelength(filehandle);
  shfptr->lru=0L;  /* so we don't just close and reuse it */

/* we don't indicate read failure for these, because we DID apparently
   get a valid file, we just didn't have room for the index */

  if (shfptr->flags & BIGFONT10) {
/* close any other open bigfonts */
    for (i=0; i<MAXSHFILESTRU; i++) {
	  if (i!=which && ad3in.shfile[i].name[0] &&
         (ad3in.shfile[i].flags & BIGFONT10)) {
        if (ad3in.shfile[i].bffh!=-1)
          sh_close(ad3in.shfile[i].name);
      }
    }

    readbigfontheaderinfo(filehandle,shfptr);
    if (!createbigindex(shfptr,filehandle)) {
      ad_close(filehandle);
      return(0);
    }
    shfptr->bffh=filehandle;
  }
  else {
    readsmallfontheaderinfo(filehandle,shfptr);
    if (!createsmallindex(shfptr,filehandle)) {
      ad_close(filehandle);
      return(0);
    }
    shfptr->bffh=-1;
  }

  temploc=0L;
#ifndef HIGHCAPACITY
  if (!(shfptr->flags & BIGFONT10)) {
#else
    if (shfptr->flags & BIGFONT10) { /* for a bigfont, skip the index */
      temploc = shfptr->bfindexend & ((0xFFFFFFFFL ^ (long)(DATABLOCKSIZE-1L)));   /* nearest full block start */
    }
#endif

/* load up to the first half of the blocks of the file into memory */
    blockstoload=(short)min(shfptr->len/DATABLOCKSIZE+1,MAXSHDATABLOCKS/2+1);
    ad_lseek(filehandle,temploc,0);
    for (i=0; i<blockstoload; i++) {
      j=findavailblock(which);
      if (j!=0) {
        sdptr=&ad3in.shdata[j];
        sdptr->startaddr=temploc+((long)i)*DATABLOCKSIZE;
        sdptr->numchars=ad_read(filehandle,sdptr->data,DATABLOCKSIZE);
        sdptr->lru=-1L;
        sdptr->shfileno=(char)which;
      }
    }
#ifndef HIGHCAPACITY
  }
#endif
/* now, read the text item 0 information */
  if (zeroloc!=-1L) {
    ad_lseek(filehandle,zeroloc,0);
    do {
      ad_read(filehandle,&ch,1);
    } while (ch!=0);
    ad_read(filehandle,tempdata,5);
    i=0;
    if (!(shfptr->flags & BIGFONT10)) {
      shfptr->above=tempdata[0];
      shfptr->below=tempdata[1];
      shfptr->modes=tempdata[2];
    }
    else {
      shfptr->bfheight=tempdata[0];
      if (tempdata[1]==0) {  /* extended bf format */
    	shfptr->modes=tempdata[2];
  	    shfptr->bfwidth=tempdata[3];
      }
      else {
    	shfptr->bfwidth=tempdata[1];
  	    shfptr->modes=tempdata[2];
      }
    }
  }

/* keep the file open if it's a bigfont */
  if (!(shfptr->flags & BIGFONT10)) ad_close(filehandle);
  return(which);
}

#ifndef OLDCHDR
void sh_close(char *fn)
#else
void sh_close(fn)
char *fn;
#endif
{
  short i,j;
  struct shdatastru *sdptr;
  struct shfilestru *shfptr;

  for (i=1; i<MAXSHFILESTRU; i++) {
    shfptr=&ad3in.shfile[i];
    if (!strcmp(shfptr->name,fn)) break;
  }
  if (i>=MAXSHFILESTRU) return;  /* not there */

  if (shfptr->index!=NULL) ad_free(shfptr->index);
  shfptr->index=NULL;
  if (shfptr->bffh!=-1) ad_close(shfptr->bffh);
  shfptr->bffh=-1;
  shfptr->origname[0]=shfptr->name[0]=0;
  shfptr->lru=-1L;

  for (j=1; j<MAXSHDATABLOCKS; j++) {
    sdptr=&ad3in.shdata[j];
	if ((short)sdptr->shfileno==i) {
      if (sdptr->data!=NULL) ad_free(sdptr->data);
      sdptr->data=NULL;
      sdptr->startaddr=0L;
      sdptr->shfileno=-1;
      sdptr->lru=-1L;
      (sdptr++)->numchars=0;
	}
  }
}

#ifndef OLDCHDR
short getdatablock(short shfileno, long fileloc)
#else
short getdatablock(shfileno,fileloc)
short shfileno;
long fileloc;
#endif
/* returns -1 if no available block, otherwise brings the block and
   returns its number */
{
  int fh;
  short blockno;
  struct shdatastru *sdptr;

/* determine block to use */
  if ((blockno=findavailblock(shfileno))==0) return(-1);

  fileloc &= (0xFFFFFFFFL ^ (long)(DATABLOCKSIZE-1L));   /* nearest full block start */
  if (ad3in.shfile[shfileno].flags & BIGFONT10)
    fh=ad3in.shfile[shfileno].bffh;
  else fh=ad_open(ad3in.shfile[shfileno].name,OPENFLAGS);
  ad_lseek(fh,fileloc,0);

  sdptr=&ad3in.shdata[blockno];
  sdptr->startaddr=fileloc;
  sdptr->numchars=ad_read(fh,sdptr->data,DATABLOCKSIZE);
  sdptr->lru=shlru++;
  sdptr->shfileno=(char)shfileno;
  if (!(ad3in.shfile[shfileno].flags & BIGFONT10))
    ad_close(fh);      /* keep open if a bigfont */
  return(blockno);
}

#ifndef OLDCHDR
short sh_seek(short shfileno, long fileloc)
#else
short sh_seek(shfileno,fileloc)
short shfileno;
long fileloc;
#endif
/* returns 1 if seek is successful, 0 if not */
{
  short whichdatablk;
  struct shdatastru *sdptr;

  sdptr=&ad3in.shdata[0];
  for (whichdatablk=0; whichdatablk<MAXSHDATABLOCKS; whichdatablk++) {
    if (sdptr->data==NULL || sdptr->numchars==0) {
      sdptr++;
      continue;  /* skip unused */
    }
    if (sdptr->shfileno==(char)shfileno &&
        fileloc >= sdptr->startaddr &&
        fileloc < sdptr->startaddr+sdptr->numchars)
      break;
    sdptr++;
  }
  if (whichdatablk>=MAXSHDATABLOCKS) {   /* we didn't find it */
    whichdatablk=getdatablock(shfileno,fileloc);  /* 0 return here is an error */
												  /* cuz simplex would be found above */
  }

  if (whichdatablk==-1) return(0);

/* set the data block and address within the data */
  ad3in.shfile[shfileno].curdatablock=whichdatablk;
  ad3in.shfile[shfileno].curdataindex=(short)(fileloc-ad3in.shdata[whichdatablk].startaddr);
  return(1);
}

#ifndef OLDCHDR
short sh_seeksh(short which,unsigned short shapeno)
#else
short sh_seeksh(which,shapeno)
short which;
unsigned short shapeno;
#endif
/* seek a shape.  which tells which shape fileno,
   shapeno is the shape to find */
{
  struct shindexstru *indptr;
  short questionmark='?';
  struct shfilestru *sptr;
  int fh;
  long fileloc;
  short retval;
  sptr=&ad3in.shfile[which];
  sptr->lru++;

/* first, get file location for this shape */
  if (sptr->flags & BIGFONT10)
    indptr=lfindsh(sptr->index,sptr->validindexentries,shapeno);
  else indptr=(struct shindexstru *)bsearch(&shapeno,&sptr->index[0],sptr->validindexentries,
	sizeof(struct shindexstru),indcomp);

  if (indptr==NULL) {
    if (sptr->flags & BIGFONT10) {
/* try to find the entry in the bigfont file's index */
      if (sptr->flags & BIGFONT10)
        fh=sptr->bffh;
      else fh=ad_open(sptr->name,OPENFLAGS);  /* assume we can reopen */
      ad_lseek(fh,sptr->bfindexstart,0);
      fileloc=sptr->bfindexstart;
      do {
        retval=fillbigindex(sptr,fh,&fileloc,shapeno);
      } while (sptr->validindexentries!=0 && retval==1);
/* don't close if it's a bigfont */
      if (!(sptr->flags & BIGFONT10))
        ad_close(fh);
      if (retval==2) {  /* we did find it */
		indptr=lfindsh(sptr->index,sptr->validindexentries,shapeno);
      }
	  else {  /* pick a shape at random, since we couldn't find one */
		indptr=sptr->index;
		while (indptr->whichshape==0) indptr++;
      }
      return(sh_seek(which,indptr->fileloc));

    }
    else {   /* small font, return question mark */
      indptr=(struct shindexstru *)bsearch(&questionmark,&sptr->index[0],
        sptr->validindexentries,sizeof(struct shindexstru),indcomp);
    }
  }

  return(sh_seek(which,indptr->fileloc));
}

#ifndef OLDCHDR
long sh_tell(short which)
#else
long sh_tell(which)
short which;
#endif
{
  return(ad3in.shdata[ad3in.shfile[which].curdatablock].startaddr+
		 ad3in.shfile[which].curdataindex);
}


#ifndef OLDCHDR
unsigned char sh_fgetc(short which)   /* return next shape char */
#else
unsigned char sh_fgetc(which)   /* return next shape char */
short which;
#endif
                                      /* by a seek from the file */
{
  short curblk;

/*  printf("getting char from %d\n",which); */
  sh_seek(which,ad3in.shdata[ad3in.shfile[which].curdatablock].startaddr+DATABLOCKSIZE);
  curblk=ad3in.shfile[which].curdatablock;  /* set in sh_seek */

/* printf("returning char in block %d, index %d\n",
  curblk,ad3in.shfile[which].curdataindex); */
  return(ad3in.shdata[curblk].data[ad3in.shfile[which].curdataindex++]);
}



