
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* avrdtabl.c -- autoview engine table read routines */
#include "avhdr.h"
/* #include "aveng.h" */

#ifdef AV
extern char dxflayerlinetype[33];
extern short blockscan;
#endif

struct ltpmemstru {
  struct adltpstru ltpdata;
  struct ltpmemstru *next;
} *ltpmem;


#ifndef OLDCHDR
void freeltpmem(void)
#else
void freeltpmem()
#endif
{
  struct ltpmemstru *ltpptr;

  while (ltpmem!=NULL) {
    ltpptr=ltpmem->next;
    free(ltpmem);
    ltpmem=ltpptr;
  }
}

#ifndef OLDCHDR
short ReadTables(void)
#else
short ReadTables()
#endif
{
  short i;

/* delete any existing visretfile */
  if (ad3in.topleveldrawing && ad3in.isvisretfile) {
    if (ad3in.visretfile!=NULL) fclose(ad3in.visretfile);
    ad3in.visretfile=NULL;
    if (ad3in.visretfilename[0]) unlink(ad3in.visretfilename);
    ad3in.visretfilename[0]=0;
    ad3in.isvisretfile=0;
  }
  ad3in.blkppindex=ad3in.adppcount=0;
  for (i=0; i<MAXADPP; i++) ad3in.adpp[i]=NULL;

  ad3in.blk=(struct blockstru **)ad3in.adpp;

#ifdef AV
  blockscan=1;
  if (!readtheblockheaders()) return(0);
  blockscan=0;
#else
  if (!readtheblockheaders()) return(0);
#endif

  ad3in.ltpppindex=ad3in.adppcount;
  ad3in.ltp=(struct ltpstru **)&ad3in.adpp[ad3in.adppcount];
  if (!readthelinetypes()) return(0);

  ad3in.layppindex=ad3in.adppcount;
  lay=(struct layerstru **)&ad3in.adpp[ad3in.adppcount];
  if (!readthelayers()) return(0);

  if (!readtheshapefiles()) {
    if (ad3in.isvisretfile) {
      unlink(ad3in.visretfilename);
      ad3in.isvisretfile=0;
    }
    return(0);
  }
  return(1);
}

#ifndef OLDCHDR
short readtheblockheaders(void)
#else
short readtheblockheaders()
#endif
{
  short i,j,blockcount;
  short lowblock,nextlowblock;
  long lowsize;
  struct blockstru *bptr;

  blockcount=ad3in.maxblocknamesize=0;
  startblockheaderread();
  for (i=0; i<(short)adct.numblocksr; i++) {
    if (!readblockheader()) break;
    if (!adtb.blkh.purgedflag) {
      if ((ad3in.blk[blockcount]=(struct blockstru *)ad_malloc(sizeof(struct blockstru)))==NULL) {
        for (j=0; j<blockcount; j++) ad_free(ad3in.blk[j]);
        return(0);
      }
      ad3in.adppcount++;
      bptr=ad3in.blk[blockcount];
      strcpy(bptr->blkname,adtb.blkh.name);
      if (strlen(bptr->blkname)>ad3in.maxblocknamesize)
        ad3in.maxblocknamesize=strlen(bptr->blkname);

      bptr->blkflag=adtb.blkh.flag;
      bptr->blkdefoffsetr=adin.blockdefoffsetr;

      bptr->blksize = -1L;     /* a marker for later */
      bptr->origblkno=i;
      blockcount++;
    } /* if !purgedflag */
  } /* for i */
  adct.numblocksr=blockcount;

/* fix up block sizes */
  for (i=0; i<(short)adct.numblocksr-1; i++) {
    /* find lowest unsized block */
    lowblock = -1; lowsize=999999999L;
    for (j=0; j<(short)adct.numblocksr; j++) {
      if (ad3in.blk[j]->blksize==-1 && ad3in.blk[j]->blkdefoffsetr<lowsize) {
        lowblock=j;
        lowsize=ad3in.blk[j]->blkdefoffsetr;
      }
    }
    /* find next lowest */
    nextlowblock = -1; lowsize=999999999L;
    for (j=0; j<(short)adct.numblocksr; j++) {
      if (ad3in.blk[j]->blksize==-1 && ad3in.blk[j]->blkdefoffsetr<lowsize &&
          ad3in.blk[j]->blkdefoffsetr>ad3in.blk[lowblock]->blkdefoffsetr) {
        nextlowblock=j;
        lowsize=ad3in.blk[j]->blkdefoffsetr;
      }
    }
    ad3in.blk[lowblock]->blksize=
      ad3in.blk[nextlowblock]->blkdefoffsetr-ad3in.blk[lowblock]->blkdefoffsetr;
  }
/* this should leave one unsized block (the highest positioned one),
   so mark it as sized against extraentloc */

  for (i=0; i<(short)adct.numblocksr; i++)
    if (ad3in.blk[i]->blksize==-1)
      ad3in.blk[i]->blksize=adin.extraentlocr-(adin.blkdefstartr+ad3in.blk[i]->blkdefoffsetr);

  if (ad3in.maxblocknamesize<9) ad3in.maxblocknamesize=9;  /* *DRAWING* */


  if (adct.numblocksr>0) {
    i=quicksort(returnblockptr,(short)adct.numblocksr,sizeof(*ad3in.blk[0]),strcmp);
    return(i);
  }

  return(1);
}


#ifndef OLDCHDR
short getvislay(struct adlaystru *getlay,struct adltpstru *getltp)
#else
short getvislay(getlay,getltp)
struct adlaystru *getlay;
struct adltpstru *getltp;
#endif
{
  char *cptr;
  static short entryindex;

  if (getlay==NULL) {
    entryindex=10000;
    return(0);
  }

  for (;;) {
    entryindex++;
    if (fread(getlay,sizeof(struct adlaystru),1,ad3in.visretfile)==0) break;
    fread(getltp,sizeof(struct adltpstru),1,ad3in.visretfile);
    if ((cptr=strchr(getlay->name,'|'))!=NULL) {
      *cptr=0;
      if (!strcmp(adin.dwgrootname,getlay->name)) /* a layer from this DWG */
        return(entryindex);
    }
  }
  return(0);
}


void *laybsearch(const void *key, const void *base, size_t nelem,
size_t width, int (*fcmp)(const void *, const void *))
{
  char  *kmin, *probe;
  int i, j;

  kmin = (char *) base;
  while (nelem > 0){
    i = nelem >> 1;
    probe = kmin + i * width;
    j = (*fcmp)(key, probe);
    if (j == 0)
      return(probe);
    else if (j < 0)
      nelem = i;
    else  {
      kmin = probe + width;
      nelem = nelem - i - 1;
    }
  }
  return(0);
}

#ifndef OLDCHDR
int laycomp(const void *a,const void *b)
#else
/*int laycomp(a,b);*/   /* This is not a function declaration -SSRS - 26/11/93*/
int laycomp(a,b)
void *a,*b;
#endif
{
  char laynm[36],*cptr;
  short count;

  memcpy(laynm,(**(struct layerstru **)b).layname,35);
  cptr=laynm;
  count=0;
  while ((*cptr)!=' ' && count<35) {
    cptr++;
    count++;
  }
  *cptr=0;
  return(strcmp((char *)a,laynm));
}


#ifndef OLDCHDR
short readthelayers(void)
#else
short readthelayers()
#endif
/* for now, this routine has been set up to ignore xref'ed layers (ones
   with | characters in them */
{
  short i,j,laycount;
  struct layerstru *lptr;
  char triedtoopenvrf,*cptr;
  struct adlaystru getlay;
  struct layerstru **layptr;
  struct adltpstru getltp;
  struct ltpmemstru *ltpmem2;

  if (ad3in.topleveldrawing) {
    ad3in.visretfile=NULL;
    ad3in.visretfilename[0]=0;
    ad3in.isvisretfile=triedtoopenvrf=0;
  }

  laycount=ad3in.maxlayernamesize=0;
  startlayerread();
  for (i=0; i<(short)adct.numlayersr; i++) {
    if (!readlayer()) break;

    if (!adtb.lay.purgedflag) {
      if (ad3in.topleveldrawing && adhd.visretain && adtb.lay.xrefindex!=-1) {  /* write to visretain file if necessary */
        if (!triedtoopenvrf) {
          strcpy(ad3in.visretfilename,ad3ct.tempfilepath);
		  strcat(ad3in.visretfilename,"advisret.dat");
          ad3in.visretfile=fopen(ad3in.visretfilename,"wb");
          triedtoopenvrf=1;
        }
        if (ad3in.visretfile!=NULL) {
          fwrite(&adtb.lay,sizeof(struct adlaystru),1,ad3in.visretfile);
/* now look up linetype for this layer */
		  ltpmem2=ltpmem;
		  for (j=0; j<adtb.lay.linetype; j++)
            if (ltpmem2->next!=NULL) ltpmem2=ltpmem2->next;
          fwrite(&ltpmem2->ltpdata,sizeof(struct adltpstru),1,ad3in.visretfile);
        }
        continue;  /* loop to next layer */
      }
      if ((lay[laycount]=(struct layerstru *)ad_malloc(sizeof(*lay[0])))==NULL) {
        for (j=0; j<laycount; j++) ad_free(lay[j]);
        if (ad3in.visretfile!=NULL) {
          fclose(ad3in.visretfile);
          unlink(ad3in.visretfilename);
          ad3in.visretfile=NULL;
          ad3in.isvisretfile=0;
        }
        freeltpmem();
        return(0);
      }
      ad3in.adppcount++;
      lptr=lay[laycount];
      lptr->origlayno=i;
      lptr->layflag=adtb.lay.flag;
      lptr->vpfrozflags=0;
      memset(lptr->layname,' ',41);
      memcpy(lptr->layname,adtb.lay.name,strlen(adtb.lay.name));
/*      strcpy(lptr->layname,adtb.lay.name); */
      lptr->laycolor=adtb.lay.color;
      if (ad3in.displayitemtype==0)  /* a drawing */
        lptr->laylinetype=adtb.lay.linetype;
      else {  /* for dxf */
#ifdef AV
        lptr->laylinetype=0;
        for (j=0; j<adct.numlinetypesr; j++) {
          if (!strcmp(ad3in.ltp[j]->ltpname,dxflayerlinetype)) {
            lptr->laylinetype=ad3in.ltp[j]->origltpno;
            break;
          }
        }
#endif
      }
      if ((short)strlen(adtb.lay.name)>ad3in.maxlayernamesize)
        ad3in.maxlayernamesize=strlen(adtb.lay.name);
      laycount++;
    }
  }
  adct.numlayersr=laycount;

  i=quicksort(returnlayerptr,(short)adct.numlayersr,sizeof(*lay[0]),strcmp);

  if (ad3in.topleveldrawing && ad3in.visretfile!=NULL) {
    fclose(ad3in.visretfile);
    ad3in.visretfile=NULL;
    ad3in.isvisretfile=1;
  }
  else if (!ad3in.topleveldrawing && ad3in.isvisretfile) {
/* apply layer state info from file to layers */
    rewind(ad3in.visretfile);      /* still open from ltp read */
    getvislay(NULL,NULL);          /* reset index count */
    while (getvislay(&getlay,&getltp)) {
      cptr=getlay.name;
      while (*cptr++!=0) ;         /* skip drawing name to layer name */
      layptr=laybsearch(cptr,&lay[0],(short)adct.numlayersr,
        sizeof(struct layerstru *),laycomp);

      if (layptr!=NULL) {          /* found the layer */
        (*layptr)->laycolor=getlay.color;   /* set its color and frtha */
		(*layptr)->layflag=(((*layptr)->layflag) & 254) | (getlay.flag & 1);
        if (strchr(getltp.name,'|')==NULL) {
          for (j=0; j<(short)adct.numlinetypesr; j++)
			if (!strcmp(getltp.name,ad3in.ltp[j]->ltpname)) break;
		  if (j<(short)adct.numlinetypesr)  /* found */
			(*layptr)->laylinetype=ad3in.ltp[j]->origltpno;
   /* need to reset linetype */
        }
      }
    }
  }
  freeltpmem();
  return(1);
}


#ifndef OLDCHDR
short getvisltp(short reset)
#else
short getvisltp(reset)
short reset;
#endif
{
  struct adlaystru getlay;
  short numchars;
  char *cptr;
  static short entryindex;

  if (reset) {
    entryindex=10000;
    return(0);
  }

  if (!ad3in.isvisretfile) return(10000);
  if (ad3in.visretfile==NULL) {
    ad3in.visretfile=fopen(ad3in.visretfilename,"rb");
  }

  for (;;) {
    entryindex++;
    numchars=fread(&getlay,sizeof(struct adlaystru),1,ad3in.visretfile);
    if (numchars==0) break;
    fread(&adtb.ltype,sizeof(struct adltpstru),1,ad3in.visretfile);
    cptr=strchr(getlay.name,'|');
    if (cptr!=NULL) {
      *cptr=0;
      if (!strcmp(adin.dwgrootname,getlay.name) && /* a layer from this DWG */
        strchr(adtb.ltype.name,'|')==NULL)  /* ltype not from xref */
        return(entryindex);
    }
  }
  return(10000);
}

#ifndef OLDCHDR
short readthelinetypes(void)
#else
short readthelinetypes()
#endif
{
  short i,j;
  struct ltpstru *lptr;
  short ltpcount,done,vlindex;
  struct ltpmemstru **curltpmemptr;

  ltpmem=NULL;
  curltpmemptr=&ltpmem;
  i=done=ltpcount=0;
  getvisltp(1);  /* reset the counter */
  if (!ad3in.topleveldrawing && ad3in.isvisretfile && ad3in.visretfile!=NULL)
    rewind(ad3in.visretfile);
  startlinetyperead();
  vlindex=0;
  while (!done) {
    if (i<(short)adct.numlinetypesr)
      readlinetype();
    else {
      if ((vlindex=getvisltp(0))==10000) break;
      for (j=0; j<ltpcount; j++)  /* see if we already have this linetype */
        if (!strcmp(adtb.ltype.name,ad3in.ltp[j]->ltpname))
          break;  /* already have it, so don't add */
      if (j<ltpcount) continue;
    }
    if (ad3in.topleveldrawing && adhd.visretain) {
/* hold linetype info in memory for layer resolution */
      *curltpmemptr=malloc(sizeof(struct ltpmemstru));
      memcpy(&(*curltpmemptr)->ltpdata,&adtb.ltype,sizeof(struct adltpstru));
      (*curltpmemptr)->next=NULL;
      curltpmemptr=&((*curltpmemptr)->next);
    }
    if (!adtb.ltype.purgedflag && adtb.ltype.xrefindex==-1) {
      if ((ad3in.ltp[ltpcount]=(struct ltpstru *)ad_malloc(sizeof(*ad3in.ltp[0])))==NULL) {
        for (j=0; j<ltpcount; j++) {
          ad_free(ad3in.ltp[j]->patternval);
          ad_free(ad3in.ltp[j]);
          freeltpmem();
        }
        return(0);
      }
      ad3in.adppcount++;
      lptr=ad3in.ltp[ltpcount];
      if (vlindex!=0) lptr->origltpno=vlindex;
      else lptr->origltpno=i;
      lptr->patternval=NULL;
      strcpy(lptr->ltpname,adtb.ltype.name);
      ltpcount++;
      if (adtb.ltype.numlinetypevals>0) {
        if ((lptr->patternval=(double *)ad_malloc(adtb.ltype.numlinetypevals*sizeof(double)))==NULL) {
          ad_free(lptr);
          for (j=0; j<ltpcount; j++) {
            ad_free(ad3in.ltp[j]->patternval);
            ad_free(ad3in.ltp[j]);
          }
          return(0);
        }

        for (j=0; j<adtb.ltype.numlinetypevals; j++)
          lptr->patternval[j]=adtb.ltype.val[j];
      }
      lptr->numltpvals=adtb.ltype.numlinetypevals;
      lptr->patternlength=adtb.ltype.patternlength;
      if (lptr->numltpvals>0)
        lptr->avgseglen=lptr->patternlength/(double)lptr->numltpvals;
    }
    i++;
    if (i>=(short)adct.numlinetypesr && !ad3in.isvisretfile) done=1;
  }
  adct.numlinetypesr=ltpcount;
  return(1);
}


#ifndef OLDCHDR
short readtheshapefiles(void)
#else
short readtheshapefiles()
#endif
{
  short i,j,allocamt;

/* shapename contains the style name, shapefile is the font file */
  startshaperead();
  for (i=0; i<(short)adct.numshapefilesr; i++) {
    ad3in.shapeinfo[i]=NULL;
    readshapefile();
    if (!adtb.shape.purgedflag) {
      allocamt=strlen(adtb.shape.file)+strlen(adtb.shape.name)+strlen(adtb.shape.bigfontname)+3;
      if ((ad3in.shapeinfo[i]=ad_malloc(allocamt))==NULL) {
        for (j=0; j<i; j++)
          if (ad3in.shapeinfo[j]!=NULL) ad_free(ad3in.shapeinfo[j]);
        return(0);
      }
      strcpy(ad3in.shapeinfo[i],adtb.shape.file);
/* attach the shapename, which is the name of the style (for dxf) */
      strcpy(&ad3in.shapeinfo[i][strlen(ad3in.shapeinfo[i])+1],adtb.shape.name);
/* attach the bigfont file name, if any */
      strcpy(&ad3in.shapeinfo[i][strlen(adtb.shape.file)+strlen(adtb.shape.name)+2],adtb.shape.bigfontname);
      ad3in.shflag[i]=adtb.shape.flag;

/* we no longer load them here */
    } /* if !adtb.shape.purgedflag */
  }
  return(1);
}


#ifndef OLDCHDR
short quicksort(void *(*returnitemptr)(short),short numitems,short width,int (*compare)(const char *,const char *))
#else
short quicksort(returnitemptr,numitems,width,compare)
void *(*returnitemptr)();
short numitems;
short width;
int (*compare)();
#endif
{
  register short i,j;
  short l,r,s;
  void *x,*w;
  struct stackstru {
    short lf,rt;
  } stack[15];  /* 2 ^15 is much greater than we'll need */

  if ((x=(void *)ad_malloc(width))==NULL) return(0);
  if ((w=(void *)ad_malloc(width))==NULL) {
    ad_free(x);
    return(0);
  }
  /* find highest index */
  j=numitems-1;
  s=0; stack[0].lf=0; stack[0].rt=j;
  do {
    l=stack[s].lf; r=stack[s--].rt;
    do {
      i=l; j=r; memcpy(x,(*returnitemptr)((l+r)/2),width);
      do {
        while ((*compare)((*returnitemptr)(i),x)<0) i++;
        while ((*compare)(x,(*returnitemptr)(j))<0) j--;
        if (i<=j) {
          memcpy(w,(*returnitemptr)(i),width);
          memcpy((*returnitemptr)(i++),(*returnitemptr)(j),width);
          memcpy((*returnitemptr)(j--),w,width);
        }
      } while (i<=j);
      if (j-l<r-i) {
        if (i<r) {
          stack[++s].lf=i;
          stack[s].rt=r;
        }
        r=j;
      }
      else {
        if (l<j) {
          stack[++s].lf=l;
          stack[s].rt=j;
        }
        l=i;
      }
    } while (l<r);
  } while (s!=-1);
  ad_free(x);
  ad_free(w);
  return(1);
}
