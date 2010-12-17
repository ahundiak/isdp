
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* avgraf.c -- autoview graphics */

#include "avhdr.h"
/*  #define CACHEDBG 1 */
#define ROUNDOFF 1.0E-30
/* from autodirect */

short globvp;
double gxclipmin,gxclipmax,gyclipmin,gyclipmax;

short
#ifdef AV
/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifndef OS_UNIX
 _fastcall
#endif
#endif
#ifndef OLDCHDR
sign(double r)
#else
sign(r)
double r;
#endif
{
  if (r>ROUNDOFF) return(1);
  else if (r<-ROUNDOFF) return(-1);
  else return(0);
}

#define SIZE2 2*sizeof(double)

short
#ifdef AV
/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifndef OS_UNIX
_fastcall
#endif
#endif
#ifndef OLDCHDR
overlap(short numa,double (*apoly)[2],short *numc,struct _point *cpoly)
#else
overlap(numa,apoly,numc,cpoly)
short numa;
double (*apoly)[2];
short *numc;
struct _point *cpoly;
#endif
{
  short i,j,index1,index2,l1,l2,numcdash;
  double f[2][20][2],end1[2],end2[2],v1[2],v2[2];
  double ca,cb,cc,fv1,fv2,absfv1,absfv2,delta;
  short numb,orientation;
  double bpoly[20][2];

/*
printf("Clipping:\n");
for (i=0; i<numa; i++) printf("%d: %lf,%lf\n",i,apoly[i][0],apoly[i][1]);
printf("\nagainst %lf,%lf -- %lf,%lf\n",gxclipmin,gyclipmin,gxclipmax,gyclipmax);
*/
/* first, set up bpoly as the screen coords */
  numb=4;
  bpoly[0][0]=bpoly[3][0]=gxclipmin;
  bpoly[0][1]=bpoly[1][1]=gyclipmin;
  bpoly[1][0]=bpoly[2][0]=gxclipmax;
  bpoly[2][1]=bpoly[3][1]=gyclipmax;

/* establish orientation of the polygon */
  orientation=sign((apoly[1][0]-apoly[0][0])*(apoly[2][1]-apoly[1][1])-
                   (apoly[1][1]-apoly[0][1])*(apoly[2][0]-apoly[1][0]));

  if (orientation==-1) {
    for (i=0; i<numa/2; i++) {
      j=numa-1-i;
      if (i!=j) {  /* swap the buggers */
        memcpy(end1,apoly[i],SIZE2);
        memcpy(apoly[i],apoly[j],SIZE2);
        memcpy(apoly[j],end1,SIZE2);
      }
    }
    orientation=1;
  }

  l1=0; *numc=numa;
  for (i=0; i<*numc; i++) memcpy(f[l1][i],apoly[i],SIZE2);

  memcpy(end1,bpoly[numb-1],SIZE2);
  for (i=0; i<numb; i++) {
    l2=1-l1;
    memcpy(end2,bpoly[i],SIZE2);

    ca=end2[0]-end1[0]; cb=end1[1]-end2[1];
    cc = -end1[0]*cb-end1[1]*ca;

    memcpy(v1,f[l1][*numc-1],SIZE2);

    fv1=ca*v1[1]+cb*v1[0]+cc;  absfv1=fabs(fv1);
    if (absfv1 < ROUNDOFF) index1=0;
    else {
      index1=sign(fv1)*orientation;
      numcdash=0;
      for (j=0; j<*numc; j++) {
        memcpy(v2,f[l1][j],SIZE2);
        fv2=ca*v2[1]+cb*v2[0]+cc; absfv2=fabs(fv2);
        if (absfv2 < ROUNDOFF) index2=0;
        else index2=sign(fv2)*orientation;

        if (index1 >= 0) {
          memcpy(f[l2][numcdash],v1,SIZE2);
          numcdash++;
        }

        if ((index1!=0) && (index1!=index2) && (index2!=0)) {
          delta=absfv1+absfv2;
          f[l2][numcdash][0] = (absfv2*v1[0] + absfv1*v2[0])/delta;
          f[l2][numcdash][1] = (absfv2*v1[1] + absfv1*v2[1])/delta;
          numcdash++;
        }
        fv1=fv2; absfv1=absfv2;
        index1=index2; memcpy(v1,v2,SIZE2);
      } /* for j */

      if (numcdash < 3) {
        *numc=0; return(0);
      }
      else {
        *numc=numcdash; l1=l2; memcpy(end1,end2,SIZE2);
      }
    } /* big else */
  } /* for i */
  for (i=0; i<*numc; i++) {
    cpoly[i].XC=(short)(f[l1][i][0]+0.1);  /* hope this brings it in range */
    cpoly[i].YC=(short)(f[l1][i][1]+0.1);
/*
    if (cpoly[i].XC<(short)gxclipmin) cpoly[i].XC++;
    if (cpoly[i].YC<(short)gyclipmin) cpoly[i].YC++;
    if (cpoly[i].XC>(short)gxclipmax) cpoly[i].XC--;
    if (cpoly[i].YC>(short)gyclipmax) cpoly[i].YC--;
*/
  }
/*
printf("at end of overlap, cpoly is:\n");
for (i=0; i<*numc; i++) printf("%d, %d\n",cpoly[i].XC,cpoly[i].YC);
*/
  return(1);
}

#ifndef OLDCHDR
void intmatmult(double pt0[3],double (*solmat)[4],double pp[2])
#else
void intmatmult(pt0,solmat,pp)
double pt0[3],(*solmat)[4],pp[2];
#endif
{
  pp[0]=pt0[0]*solmat[0][0]+pt0[1]*solmat[1][0]+pt0[2]*solmat[2][0]+solmat[3][0];
  pp[1]=pt0[0]*solmat[0][1]+pt0[1]*solmat[1][1]+pt0[2]*solmat[2][1]+solmat[3][1];
}

#ifndef OLDCHDR
void DrawFilledPoly(double pt0[3],double pt1[3],double pt2[3],double pt3[3],
  double (*mat)[4][4])
#else
void DrawFilledPoly(pt0,pt1,pt2,pt3,mat)
double pt0[3],pt1[3],pt2[3],pt3[3],(*mat)[4][4];
#endif
{
  double (*mysolmat)[4][4];
  double fourmat[4][4];
  double (*solmat)[4];
  short i,diffx,diffy,start,end,matcount;
  short hadint,n,numout;
  static polyHead polyhdr={ 0, 0, {-32767,-32767,32767,32767}};

#ifdef EVAL
  static short clipit=0;

  clipit++;
  if (clipit==5) {
    clipit=0;
    return;
  }
#endif

/* needed this here also */
  ad3in.vecfunccount++;
  if (ad_Vecfunc!=NULL && ad3in.vecfunccount==ad3ct.vecfunclimit) {
    (*ad_Vecfunc)();
    ad3in.vecfunccount=0;
  }

/*
printf("drawfilledpoly -- %lf,%lf,%lf  %lf,%lf,%lf\n",pt0[0],pt0[1],pt0[2],pt1[0],pt1[1],pt1[2]);
printf("                  %lf,%lf,%lf  %lf,%lf,%lf\n",pt2[0],pt2[1],pt2[2],pt3[0],pt3[1],pt3[2]);
*/
/* set up bounds of matrices to be calculated */
  if (ad3in.enginespace==MODELSPACE || adenhd.paperspace || ad3in.overridepaperspace)
    { start=0; end=1; }
  else /* a modelspace entity in paperspace */
    { start=1; end=ad3in.numvptmats; }

/* don't mess with mat in this function */
  if (adenhd.extrusioninfovalid) {
    geta4by4(adenhd.extrusion,fourmat);  /* set the extrumat */
    mysolmat=(double (*)[4][4])ad_malloc(ad3in.numvptmats*sizeof(*mysolmat));
    for (i=start; i<end; i++) matmult(fourmat,mat[i],mysolmat[i]);
  }
  else mysolmat=mat;

  for (matcount=start; matcount<end; matcount++) {
  /* avoid frozen viewports and ones we've turned off */
    if ((ad3in.globalvpflags & (1<<matcount)) || !(ad3in.vpdrawflags & (1<<matcount)))
      continue;

    solmat=mysolmat[matcount];
    intmatmult(pt0,solmat,ad3in.pp[0]);
    intmatmult(pt1,solmat,ad3in.pp[1]);
    intmatmult(pt2,solmat,ad3in.pp[3]);
    intmatmult(pt3,solmat,ad3in.pp[2]);
/*
    ad3in.pp[0][0]=pt0[0]*solmat[0][0]+pt0[1]*solmat[1][0]+pt0[2]*solmat[2][0]+solmat[3][0];
    ad3in.pp[0][1]=pt0[0]*solmat[0][1]+pt0[1]*solmat[1][1]+pt0[2]*solmat[2][1]+solmat[3][1];
    ad3in.pp[1][0]=pt1[0]*solmat[0][0]+pt1[1]*solmat[1][0]+pt1[2]*solmat[2][0]+solmat[3][0];
    ad3in.pp[1][1]=pt1[0]*solmat[0][1]+pt1[1]*solmat[1][1]+pt1[2]*solmat[2][1]+solmat[3][1];
    ad3in.pp[3][0]=pt2[0]*solmat[0][0]+pt2[1]*solmat[1][0]+pt2[2]*solmat[2][0]+solmat[3][0];
    ad3in.pp[3][1]=pt2[0]*solmat[0][1]+pt2[1]*solmat[1][1]+pt2[2]*solmat[2][1]+solmat[3][1];
    ad3in.pp[2][0]=pt3[0]*solmat[0][0]+pt3[1]*solmat[1][0]+pt3[2]*solmat[2][0]+solmat[3][0];
    ad3in.pp[2][1]=pt3[0]*solmat[0][1]+pt3[1]*solmat[1][1]+pt3[2]*solmat[2][1]+solmat[3][1];
*/
    n=4;
    if (ad3in.pp[3][0]==ad3in.pp[0][0] && ad3in.pp[3][1]==ad3in.pp[0][1]) n=3;

    if (ad3in.pp[0][0]==ad3in.pp[1][0] && ad3in.pp[0][1]==ad3in.pp[1][1]) {
      memmove(ad3in.pp[0],ad3in.pp[1],6*sizeof(double));
      n=3;
    }
/* set a global to the vp index to avoid all the passing crap */
    globvp=matcount;
/* also set global clip limits -- makes pgm shorter */
    gxclipmin=ad3in.xclipmin[matcount];
    gxclipmax=ad3in.xclipmax[matcount]-0.5;
    gyclipmin=ad3in.yclipmin[matcount];
    gyclipmax=ad3in.yclipmax[matcount]-0.5;

    hadint=overlap(n,ad3in.pp,&numout,ad3in.polypts);

    if (hadint) { /* must be at least 3 valid line draws for pgon */
  /* check to see if all points share a common x or y value.  If they do,
     it would seem that Metagraphics does not draw anything.  */
      diffx=diffy=0;
      for (i=1; i<numout; i++) {
        if (ad3in.polypts[0].XC!=ad3in.polypts[i].XC) diffx=1;
        if (ad3in.polypts[0].YC!=ad3in.polypts[i].YC) diffy=1;
      }
      if (!(diffx && diffy)) {
        DrawSeg3d(pt0,pt2,mat);
      }
      else {
        polyhdr.polyBgn=0;
        polyhdr.polyEnd=numout-1;
        (*ad_PaintPoly)(1,&polyhdr,(point *)ad3in.polypts);
      }
    }   /* if there were 3 or more vertices */
  }     /* loop over matrices */
  if (mysolmat!=mat) ad_free(mysolmat);
}

#ifdef OLDVERSION
#ifndef OLDCHDR
void DrawArc(double pt0[3],double dstang,double dendang,
  double arcradius,double (*matrix)[4][4])
#else
void DrawArc(pt0,dstang,dendang,arcradius,matrix)
double pt0[3],dstang,dendang,arcradius;
double (*matrix)[4][4];
#endif
{
  unsigned short steps,i;
  double ang,angstep;
  double fabsden;
  short maxarcsegs;
  double drawpt1[3],drawpt2[3];

  fabsden=fabs(dendang-dstang);

  steps=(short)(sqrt(ad3in.arcscalemult*arcradius)*fabsden);
/* printf("Radius %lf, steps %d\n",arcradius,steps); */

  if (ad3ct.maxcirclesegs!=0) {
    maxarcsegs=(short)(ad3ct.maxcirclesegs*fabsden/(2.0*PI));
    if (steps>(unsigned short)maxarcsegs) steps=(unsigned short)maxarcsegs;
  }

  if (steps<(unsigned short)(1.5*fabsden)) steps=(unsigned short)(1.5*fabsden);
  if (steps<2) steps=2;

  angstep=(dendang-dstang)/((double)steps);
  ang=dstang;
  drawpt1[X]=cos(dstang)*arcradius+pt0[0];
  drawpt1[Y]=sin(dstang)*arcradius+pt0[1];
  drawpt1[2]=drawpt2[2]=pt0[2];
  for (i=0; i<steps; i++) {
    ang+=angstep;
    drawpt2[X]=cos(ang)*arcradius+pt0[0];
    drawpt2[Y]=sin(ang)*arcradius+pt0[1];
    DrawSeg3d(drawpt1,drawpt2,matrix);
    memcpy(drawpt1,drawpt2,3*sizeof(double));
  }
}
#endif

#ifndef OLDCHDR
void DrawArc(double pt0[3],double dstang,double dendang,
  double arcradius,double (*matrix)[4][4])
#else
void DrawArc(pt0,dstang,dendang,arcradius,matrix)
double pt0[3],dstang,dendang,arcradius;
double (*matrix)[4][4];
#endif
{
  unsigned short steps,i;
  double angstep;
  double fabsden;
  short maxarcsegs;
  double drawpt1[3],drawpt2[3];
  double c1,s1;

  fabsden=fabs(dendang-dstang);

  steps=(short)(sqrt(ad3in.arcscalemult*arcradius)*fabsden);
/* printf("Radius %lf, steps %d\n",arcradius,steps); */

  if (ad3ct.maxcirclesegs!=0) {
    maxarcsegs=(short)(ad3ct.maxcirclesegs*fabsden/(2.0*PI));
    if (steps>(unsigned short)maxarcsegs) steps=(unsigned short)maxarcsegs;
  }

  if (steps<(unsigned short)(1.5*fabsden)) steps=(unsigned short)(1.5*fabsden);
  if (steps<2) steps=2;

  angstep=(dendang-dstang)/((double)steps);
  drawpt1[X]=cos(dstang)*arcradius+pt0[0];
  drawpt1[Y]=sin(dstang)*arcradius+pt0[1];
  drawpt1[2]=drawpt2[2]=pt0[2];
  c1=cos(angstep);
  s1=sin(angstep);
  for (i=0; i<steps; i++) {
    drawpt2[X]=pt0[0]+(drawpt1[X]-pt0[0])*c1-(drawpt1[Y]-pt0[1])*s1;
    drawpt2[Y]=pt0[1]+(drawpt1[X]-pt0[0])*s1+(drawpt1[Y]-pt0[1])*c1;
    DrawSeg3d(drawpt1,drawpt2,matrix);
    memcpy(drawpt1,drawpt2,3*sizeof(double));
  }
}



#ifndef OLDCHDR
short incache(short blkno)
#else
short incache(blkno)
short blkno;
#endif
/* return -1 if block is not in cache, otherwise index of cache entry */
{
  register short i;

  for (i=0; i<MAXBLOCKCACHE; i++)
    if (ad3in.blockcache[i].blockno==blkno) return(i);
  return(-1);
}

void clearunusedcacheitems()
/* free any blocks which are cached but not currently open */
{
  register short i;
  struct blockcachestru *bptr;

  for (i=0; i<MAXBLOCKCACHE; i++) {
    bptr = &ad3in.blockcache[i];
    if (bptr->blockno!=-1 && !bptr->inuse) {
      bptr->lru=0L;
      bptr->inuse=0;
      if (bptr->blkdata!=NULL) ad_free(bptr->blkdata);
      bptr->blkdata=NULL;
      bptr->blockno = -1;
    }
  }
}

#ifndef OLDCHDR
short putblockincache(short blkno)
#else
short putblockincache(blkno)
short blkno;
#endif
{
  register short i;
  short index,sz;
  long minlru,holdloc;
  AD_FILE *tfile;
  char *cptr;

  cptr=ad_malloc(4096);
  if (cptr==NULL) return(-1);  /* couldn't put it in */
  ad_free(cptr);

  minlru=32000000;
  index = -1;
/* if there's a free spot, grab it */
  for (i=0; i<MAXBLOCKCACHE; i++)
    if (ad3in.blockcache[i].blockno==-1) {
      index=i;
      break;
    }
/* otherwise look for the least recently used item */
  if (index==-1) {
    for (i=0; i<MAXBLOCKCACHE; i++) {
      if (ad3in.blockcache[i].lru<minlru) {
        minlru=ad3in.blockcache[i].lru;
        index=i;
      }
    }
  }

  if (ad3in.blockcache[index].blkdata!=NULL) ad_free(ad3in.blockcache[index].blkdata);
  sz=(short)ad3in.blk[blkno]->blksize;
  if ((ad3in.blockcache[index].blkdata=ad_malloc(sz+5))==NULL) return(-1);
  ad3in.blockcache[index].lru=ad3in.globallru++;
  ad3in.blockcache[index].blockno=blkno;

  tfile=adin.dwgfiler;

  holdloc=ad_ftell(tfile);
  ad_fseek(tfile,ad3in.blk[blkno]->blkdefoffsetr+adin.blkdefstartr,SEEK_SET);

  ad_fread(ad3in.blockcache[index].blkdata,sz,1,tfile);

  /* try to do this fseek ONLY if it is necessary */
  if ((tfile==adin.dwgfilerblk && adin.inblockdefrflag>1) ||
      (tfile==adin.dwgfilerblk2 && adin.inblockdefrflag>2))
    ad_fseek(tfile,holdloc,SEEK_SET);
#ifdef CACHEDBG
 printf("Leaving put\n\n");
#endif
  return(index);
}
