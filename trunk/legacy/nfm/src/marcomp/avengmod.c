
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* avengmod.c -- autoview engine driver routine */
#include "avhdr.h"
/* #include "aveng.h" */

#ifdef AV
extern char dxflayerlinetype[33];
extern short blockscan;
#endif

#ifndef OLDCHDR
void SetSpace(short space)
#else
void SetSpace(space)
short space;
#endif
{
  ad3in.enginespace=space;
  if (ad3in.enginespace==MODELSPACE) ad3in.numvptmats=1;
  else ad3in.numvptmats=ad3in.numpspvptmats;
  ad3in.clipping=1;
}

#ifndef OLDCHDR
void SetLayerState(short index,short frtha,short onoff)
#else
void SetLayerState(index,frtha,onoff)
short index,frtha,onoff;
#endif
{
  struct layerstru *lptr;

  lptr=lay[index];
  if (frtha!=NOCHANGE) {
    if      (frtha==LAYFREEZE) lptr->layflag |= 1;
    else if (frtha==LAYTHAW)   lptr->layflag &= 254;
  }
  if (onoff!=NOCHANGE) {
    if      (onoff==LAYON)  lptr->laycolor= abs(lptr->laycolor);
    else if (onoff==LAYOFF) lptr->laycolor = -abs(lptr->laycolor);
  }
}

#ifndef OLDCHDR
void GetLayerState(short index,short *frtha,short *onoff)
#else
void GetLayerState(index,frtha,onoff)
short index,*frtha,*onoff;
#endif
{
  if (lay[index]->layflag & 1) *frtha=LAYFROZEN;
  else *frtha=LAYTHAWED;
  if (lay[index]->laycolor>=0) *onoff=LAYON;
  else *onoff=LAYOFF;
}

#ifdef YOMAMA
void estremainingmem()
{
  short grabcount;
  struct memgrabstru {
    char takeupspace[1020];
    struct memgrabstru *next;
  } *firstgrab,*nextgrab;

/* see how much allocatable memory we have */
    firstgrab=ad_malloc(sizeof(*firstgrab));
    nextgrab=firstgrab;
    grabcount=0;
    do {
      grabcount++;
      nextgrab->next=ad_malloc(sizeof(*firstgrab));
      nextgrab=nextgrab->next;
    } while (nextgrab!=NULL);
printf("estimated mem remaining is %dK   \r",grabcount);
    do {
      nextgrab=firstgrab->next;
      ad_free(firstgrab);
      firstgrab=nextgrab;
    } while (firstgrab!=NULL);
}

#endif

#ifndef OLDCHDR
void PanTarget(double viewdir[4],double target[4],double up[4],double deltax,double deltay)
#else
void PanTarget(viewdir,target,up,deltax,deltay)
double viewdir[4],target[4],up[4],deltax,deltay;
#endif
/* move target parallel to display */
{
  double tempvec[4];
  short i;

/* get "sideways" vector */
  crossproduct(up,viewdir,tempvec);
/* now move y units on "up", x units on "sideways" -- clever, eh? */
  normalize(up);

  for (i=0; i<3; i++) {
    target[i]+=deltax*tempvec[i]+deltay*up[i];
  }
}

#ifndef OLDCHDR
short newlayno(short index)
#else
short newlayno(index)
short index;
#endif
/* return the new layer number for this original number */
{
  register short i;

  for (i=0; i<(short)adct.numlayersr; i++)
    if (lay[i]->origlayno==(unsigned short)index) return(i);
  return(0);
}

#ifndef OLDCHDR
short newltpno(short index)
#else
short newltpno(index)
short index;
#endif
/* return the new linetype number for this original number */
{
  register short i;

/* removed validity test for index . . . just look for it */
  for (i=0; i<(short)adct.numlinetypesr; i++)
    if (ad3in.ltp[i]->origltpno==(unsigned short)index) return(i);
  return(0);
}

#ifndef OLDCHDR
short newblkno(short index)
#else
short newblkno(index)
short index;
#endif
/* return the new block number for this original number */
{
  register short i;

  for (i=0; i<(short)adct.numblocksr; i++)
    if (ad3in.blk[i]->origblkno==index) return(i);
  return(0);
}

#ifndef OLDCHDR
void *returnblockptr(short index)
#else
void *returnblockptr(index)
short index;
#endif
{
  return((void *)ad3in.blk[index]);
}

#ifndef OLDCHDR
void *returnlayerptr(short index)
#else
void *returnlayerptr(index)
short index;
#endif
{
  return((void *)lay[index]);
}


