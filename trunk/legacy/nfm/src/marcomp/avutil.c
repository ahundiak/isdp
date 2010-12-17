
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* avutil -- utilities which the engine needs */
#include "avhdr.h"

#ifndef OLDCHDR
short InitAvEng(short firstbufsz,short secondbufsz,short thirdbufsz)
#else
short InitAvEng(firstbufsz,secondbufsz,thirdbufsz)
short firstbufsz,secondbufsz,thirdbufsz;
#endif
{
  short i;
  static char msg[]="AUTODIRECT 3 V2.05  Serial #1111  Copyright (c) 1991-1992  Stephen M. Richards";

  initsh();
  ad3ct.tempfilepath[0]=0;
  ad3in.topleveldrawing=1;
  ad3in.isvisretfile=0;
  ad3in.visretfilename[0]=0;
  if ((ad3in.adpp=(void **)ad_malloc(MAXADPP*sizeof(void *)))==NULL) return(0);
  strcpy(ad3in.mallocmsg,"Malloc error\n");
  ad3in.nextavailshapefile=1;
  ad3in.avbufsz1=firstbufsz; ad3in.avbufsz2=secondbufsz; ad3in.avbufsz3=thirdbufsz;
/* initialize color map */
  for (i=0; i<17; i++) ad3ct.colormap[i]=i;
  ad3ct.aspectratio=ad3ct.accuracy=1.0;  /* init to medium accuracy */
  ad3in.perspdist=0.0;  /* no perspective */
  ad3in.globalreadingfromcache = -1;
  ad3ct.maxcirclesegs=ad3in.genfaces=ad3in.overridepaperspace=0;

  ad3in.simpfont=(char *)&simpfontstrs[0][0];

  ad3ct.shapepath[0]='\0';

  clearblockcache(0);

  ad3in.maxavbufsiz=secondbufsz; /* 16384 */
  ad3in.avbuf=ad3in.avbuf2=ad3in.avbuf3=ad3in.avbuf4=NULL;

/* the main allocation section */
  if ((ad3in.avbuf=ad_malloc(firstbufsz))!=NULL) {
    if ((ad3in.avbuf2=ad_malloc(ad3in.maxavbufsiz))!=NULL) {
      if ((ad3in.avbuf3=ad_malloc(thirdbufsz))!=NULL) {        /* 8192 */
        if ((ad3in.avbuf4=ad_malloc(ad3in.maxavbufsiz))!=NULL) {
          if ((ad3in.viewplanetransmat=(double (*)[4][4])ad_malloc(16*4*4*sizeof(double)))!=NULL) {
            goto success;
          }
          ad_free(ad3in.avbuf4);
        }
        ad_free(ad3in.avbuf3);
      }
      ad_free(ad3in.avbuf2);
    }
    ad_free(ad3in.avbuf);
  }
  ad_free(ad3in.adpp);
  return(0);

success:
 ad3in.vptmallocated=1;

#ifdef EASYNULL
  ad_Odometer=NULL;
  ad_Vecfunc=NULL;
  ad_Badxref=NULL;
  ad_Examinexref=DefaultExamineXref;
  ad_Examineshapefile=DefaultExamineshapefile;
  ad_Examineentity=NULL;
#else
  ad_Odometer=(void (*)(short))NULL;
  ad_Vecfunc=(void (*)(void))NULL;
  ad_Badxref=(void (*)(char *))NULL;
  ad_Examinexref=DefaultExamineXref;
  ad_Examineshapefile=DefaultExamineshapefile;
  ad_Examineentity=NULL;
#endif
  ad3ct.vecfunclimit=25;
  ad3ct.dolinetypes=1;  /* do them by default */
  ad3in.displayitemtype=0; /* dwg */
  ad3in.amtofsegdrawn=0.0;
  ad3in.vpdrawflags=0xFFFF;
  return(1);
}


#ifndef OLDCHDR
void CloseAvEng(void)
#else
void CloseAvEng()
#endif
{
  if (ad3in.avbuf !=NULL) ad_free(ad3in.avbuf);
  if (ad3in.avbuf2!=NULL) ad_free(ad3in.avbuf2);
#ifndef AV
  if (ad3in.avbuf3!=NULL) ad_free(ad3in.avbuf3);
#endif
  if (ad3in.avbuf4!=NULL) ad_free(ad3in.avbuf4);
  if (ad3in.vptmallocated) ad_free(ad3in.viewplanetransmat);
  if (ad3in.adpp!=NULL) ad_free(ad3in.adpp);
  if (ad3in.visretfile!=NULL) fclose(ad3in.visretfile);
  if (ad3in.visretfilename[0]) unlink(ad3in.visretfilename);
}

#ifndef OLDCHDR
short dwgwithinlimits(short *tableentrylimit)
#else
short dwgwithinlimits(tableentrylimit)
short *tableentrylimit;
#endif
{
/* check whether the drawing fits within the capacity of AUTODIRECT */
  *tableentrylimit=MAXADPP;
  if (adct.numlayersr+adct.numblocksr+adct.numviewsr+adct.numlinetypesr >=(long)MAXADPP) return(0);
  else return(1);
}
