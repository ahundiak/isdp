
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* avpoly.c -- the polyline routines */

#include "avhdr.h"

#define INTEPS 1.0E-30

double inttest,inttest2;
/* these are globals for polymesh draws */
double v3[3],v4[3],nextcolstart[3],colstart[3];

double
/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#if defined(AV) && !defined(OS_UNIX)
far
#endif
ms[256][3];

short m,n,v1,v2;
short mcount,ncount;
long plinefilepos,plinefilepos2;
double (*vptr)[3];
short useheldverts,heldvertindex;
double sidept2[2][3];  /* side pts of segvert2 */
double sidept2[2][3];
double sidept12[2][3]; /* side points of segvert1 to go with segvert2 */
double sidept12[2][3];
double sidept1[2][3];
double sidept1[2][3];
double sidept[2][3];
double sidept[2][3];
double lastint[2][3],closeint[2][3];

#ifndef OLDCHDR
double anglebtwnlines(double x1,double y1,double x2,double y2,
                      double x3,double y3)
#else
double anglebtwnlines(x1,y1,x2,y2,x3,y3)
double x1,y1,x2,y2,x3,y3;
#endif
/* compute angle between x2,y2 -- x1,y1 and x2,y2 -- x3,y3 */
{
  double firstang,secondang,retang;

  if (x1==x2) {
    if (y2>y1) firstang = -PI/2.0;
    else firstang=PI/2.0;
  }
  else {
    firstang=atan((y1-y2)/(x1-x2));
    if (x1<x2)  /* goes into one of the other quadrants */
      firstang+=PI;
  }

  if (x2==x3) {
    if (y2>y3) secondang = -PI/2.0;
    else secondang=PI/2.0;
  }
  else {
    secondang=atan((y3-y2)/(x3-x2));
    if (x3<x2)
      secondang+=PI;
  }

  retang=fabs(secondang-firstang);
  if (retang>PI) retang=2.0*PI-retang;
  return(retang);
}


#ifndef OLDCHDR
void OutlinePoly(double pt0[3],double pt1[3],double pt2[3],double pt3[3],
                 double (*matlist)[4][4])
#else
void OutlinePoly(pt0,pt1,pt2,pt3,matlist)
double pt0[3],pt1[3],pt2[3],pt3[3];
double (*matlist)[4][4];
#endif
{
  DrawSeg3d(pt0,pt1,matlist);
  DrawSeg3d(pt1,pt2,matlist);
  DrawSeg3d(pt2,pt3,matlist);
  DrawSeg3d(pt3,pt0,matlist);
}


short intersection(x1,y1,x2,y2,x3,y3,x4,y4,xint,yint)
/* returns intersection, 1 if parallel, 0 if ok */
double x1,y1,x2,y2,x3,y3,x4,y4;
double *xint,*yint;
{
  double mu,delta;

/*
 printf("Calculating intersection of %lf,%lf -- %lf,%lf with %lf,%lf -- %lf,%lf\n",x1,y1,x2,y2,x3,y3,x4,y4);
*/
  delta=(x2-=x1)*(y4-=y3)-(y2-=y1)*(x4-=x3);
  if (fabs(delta)<INTEPS) return(1);

  else {
    mu=((x3-x1)*y4-(y3-y1)*x4)/delta;
    *xint=x1+mu*x2;
    *yint=y1+mu*y2;
  }
  return(0);
}


short segintersection(x1,y1,x2,y2,x3,y3,x4,y4,xint,yint)
/* do two lines intersect AND the intersection is on the lines */
/* returns 0 if true, 1 if false */
double x1,y1,x2,y2,x3,y3,x4,y4;
double *xint,*yint;
 {
  short i;

  i=intersection(x1,y1,x2,y2,x3,y3,x4,y4,xint,yint);
/*
  printf("Return from intersection is %d\n",i);
  printf("Intersection of %lf,%lf -- %lf,%lf\n",x1,y1,x2,y2);
  printf("with %lf,%lf -- %lf,%lf\n",x3,y3,x4,y4);
  printf("is %lf,%lf\n",*xint,*yint);
*/
  if (i) return(i);
  /* they do intersect, so find out if it's on both segments */
  if   (((*xint<=x1 && *xint>=x2) || (*xint<=x2 && *xint>=x1))
     && ((*xint<=x3 && *xint>=x4) || (*xint<=x4 && *xint>=x3))
     && ((*yint<=y1 && *yint>=y2) || (*yint<=y2 && *yint>=y1))
     && ((*yint<=y3 && *yint>=y4) || (*yint<=y4 && *yint>=y3)))
  return(0);
  else return(1);

}


void CalcPlineArcCenterOffset(x1,y1,x2,y2,inclang,deltax,deltay,rad)
double x1,y1,x2,y2,inclang,*deltax,*deltay,*rad;
{
  double u,v,m,mp,z,bp,cenx,ceny;
  double treal;

  u=(x1+x2)/2.0;
  v=(y1+y2)/2.0;
  if (fabs(x1-x2)<1.0E-14) mp=0.0;
  else {
    m=(y1-y2)/(x1-x2);
    if (fabs(m)<1.0E-14) {     /* special case -- perp line is vertical */
      ceny=v-(x1-u)/tan(inclang/2.0);
      cenx=u;
      *deltax=u-cenx;
      *deltay=v-ceny;
      *rad=sqrt((x2-cenx)*(x2-cenx)+(y2-ceny)*(y2-ceny));
      return;
    }
    else mp = -1.0/m;
  }
  bp=v-mp*u;
  z=atan(mp)-inclang/2.0;
  if (modf(fabs((z-PI2)/PI),&treal)<INTEPS) {   /* is it PI/2 or 3PI/2 */
    z-=2*INTEPS;  /* is so, knock it off a bit, so the tan doesn't fail */
  }
  z=tan(z);
  /* divide */
  cenx=(y1-z*x1-bp)/(mp-z);
  ceny=mp*cenx+bp;
  *deltax=u-cenx;
  *deltay=v-ceny;
  *rad=sqrt((x2-cenx)*(x2-cenx)+(y2-ceny)*(y2-ceny));
}

void computesidepts(svert1,svert,sidept1,sidept)
struct vertexstru *svert1,*svert;
double sidept1[2][3],sidept[2][3];
{
  short side;
  double plineangle;
  double cosa,sina;

  if (svert->pt0[X]==svert1->pt0[X]) {
    if (svert->pt0[Y]>svert1->pt0[Y]) plineangle=PI2;
      else plineangle = -PI2;
  }
  else plineangle=atan2((svert->pt0[Y])-(svert1->pt0[Y]),(svert->pt0[X])-(svert1->pt0[X]));
  plineangle+=PI2;
  for (side=0; side<2; side++) {
/* a slight optimization -- removed the /2's to up here */
    cosa=cos(plineangle)/2.0;
    sina=sin(plineangle)/2.0;
/* also, just set these at the start, add to them if widths not 0.0 */
    sidept1[side][X]=svert1->pt0[X];
    sidept1[side][Y]=svert1->pt0[Y];
    sidept[side][X]=svert->pt0[X];
    sidept[side][Y]=svert->pt0[Y];
    if (svert1->startwidth!=0.0) {
      sidept1[side][X]+=svert1->startwidth*cosa;
      sidept1[side][Y]+=svert1->startwidth*sina;
    }
    if (svert1->endwidth!=0.0) {
      sidept[side][X]+=svert1->endwidth*cosa;
      sidept[side][Y]+=svert1->endwidth*sina;
    }
    plineangle-=PI;
  } /* for side */

}

void PolylineSeg(matrix)
double (*matrix)[4][4];
{
  double inter[2][3];
  short side;
/* lastint is globally defined */
  double tint1,tint2;
  short smallorbigangleflag;
  double ang;

  smallorbigangleflag=0;
/* the easy case -- no width, draw the seg and go */
  if (ad3in.dvert2->startwidth==0.0 && ad3in.dvert2->endwidth==0.0) {
    DrawSeg3d(ad3in.dvert2->pt0,ad3in.dvert1->pt0,matrix);

    if (ad3in.firstsegflag) {
      if (ad3in.secondactualvertex==NULL)
        if ((ad3in.secondactualvertex=(struct vertexstru *)ad_malloc(sizeof(*ad3in.secondactualvertex)))==NULL)
            (*ad_Closegraph)(ad3in.mallocmsg);
      memcpy(ad3in.secondactualvertex,ad3in.dvert1,sizeof(*ad3in.dvert1));
      ad3in.secondactualvertex->bulge=0.0;
      ad3in.firstsegflag=0;
    }
    lastint[0][X]=lastint[1][X]=ad3in.dvert1->pt0[X];
    lastint[0][Y]=lastint[1][Y]=ad3in.dvert1->pt0[Y];
    return;
  }
/* even easier case -- if the endpoints are the same, don't draw it */
if (ad3in.dvert2->pt0[X]==ad3in.dvert1->pt0[X] &&
    ad3in.dvert2->pt0[Y]==ad3in.dvert1->pt0[Y]) return;

/* first, compute side points for ad3in.dvert2--ad3in.dvert1 seg */

  computesidepts(ad3in.dvert2,ad3in.dvert1,sidept2,sidept12);

  if (ad3in.firstsegflag) { /* first vert only -- set lastint values */
    memcpy(lastint,sidept2,6*sizeof(double));
  }
/* now same for ad3in.dvert1 -- ad3in.dvert */
  if (ad3in.dvert!=NULL) {
    computesidepts(ad3in.dvert1,ad3in.dvert,sidept1,sidept);
    if ( ((ad3in.dvert2->pt0[X]==ad3in.dvert1->pt0[X] && ad3in.dvert1->pt0[X]==ad3in.dvert->pt0[X])
        || (ad3in.dvert2->pt0[Y]==ad3in.dvert1->pt0[Y] && ad3in.dvert1->pt0[Y]==ad3in.dvert->pt0[Y])) &&
           (ad3in.dvert2->endwidth==ad3in.dvert1->startwidth)) {
      memcpy(inter,sidept1,6*sizeof(double));
    }
    else {
      ang=anglebtwnlines(ad3in.dvert2->pt0[X],ad3in.dvert2->pt0[Y],ad3in.dvert1->pt0[X],ad3in.dvert1->pt0[Y],
        ad3in.dvert->pt0[X],ad3in.dvert->pt0[Y]);
      if (ang<0.5 ||
        (ang>PI-0.1273524234069 &&
         ad3in.dvert2->endwidth!=ad3in.dvert1->startwidth)) {
        memcpy(inter,sidept12,6*sizeof(double));
        smallorbigangleflag=1;
      }
      else {
      /* now compute the two intersection points */
        for (side=0; side<2; side++) {
          intersection(sidept2[side][X],sidept2[side][Y],sidept12[side][X],sidept12[side][Y],
                       sidept1[side][X],sidept1[side][Y],sidept[side][X],sidept[side][Y],
                       &inter[side][X],&inter[side][Y]);

        }
      }
    }
  }        /* if ad3in.dvert is not null */
  else {   /* it is null, so inter is at sidepts of 1st seg 2nd point */
    memcpy(inter,sidept12,6*sizeof(double));
  }
/* if lines cross, flip them over so they don't */
  if (!segintersection(inter[0][X],inter[0][Y],lastint[0][X],lastint[0][Y],
                       inter[1][X],inter[1][Y],lastint[1][X],lastint[1][Y],
                       &tint1,&tint2)) {
    tint1  =inter[0][X];
    inter[0][X]=inter[1][X];
    inter[1][X]=tint1;
    tint1  =inter[0][Y];
    inter[0][Y]=inter[1][Y];
    inter[1][Y]=tint1;
  }

/* for first segment of a closed polyline, do not draw, just save the computed
   intersection points and put the start point at the end of the list */
  if ((ad3in.mypoly->pflag & 1) && ad3in.firstsegflag) {
    if (ad3in.secondactualvertex==NULL)
      if ((ad3in.secondactualvertex=(struct vertexstru *)ad_malloc(sizeof(*ad3in.secondactualvertex)))==NULL)
        (*ad_Closegraph)(ad3in.mallocmsg);
    memcpy(ad3in.secondactualvertex,ad3in.dvert1,sizeof(*ad3in.dvert1));
    ad3in.secondactualvertex->bulge=0.0;
    if (ad3in.dvert2->startwidth!=0.0) ad3in.firstvertexhaswidth=1;
#ifdef zortechc
  /* zortech gave me type cast hassles */
    for (side=0; side<2; side++) {
  /* a real test */
      if (smallorbigangleflag) {
        lastint[side][X]=closeint[side][X]=sidept1[side][X];
        lastint[side][Y]=closeint[side][Y]=sidept1[side][Y];
      }
      else {
         lastint[side][X]=closeint[side][X]=inter[side][X];
       lastint[side][Y]=closeint[side][Y]=inter[side][Y];
      }
    }
#else
    memcpy(lastint,((smallorbigangleflag) ? sidept1 : inter),6*sizeof(double));
    memcpy(closeint,lastint,6*sizeof(double));
#endif
    ad3in.firstsegflag=0;
    return;
  }
  lastint[0][Z]=lastint[1][Z]=ad3in.dvert2->pt0[Z];
  inter[0][Z]=inter[1][Z]=ad3in.dvert1->pt0[Z];
#ifndef AV
  if (ad3in.genfaces) {
    genextrudedface(lastint[1],lastint[0],inter[0],inter[1],matrix);
  }
  else {
#endif
    if (!adhd.fillmode || adenhd.entthickness!=0.0) {
      OutlinePoly(lastint[1],lastint[0],inter[0],inter[1],matrix);
    }
  /* change order to be like a solid */
    else {
      DrawFilledPoly(inter[0],inter[1],lastint[0],lastint[1],matrix);
    }
#ifndef AV
  }
#endif
#ifdef zortechc
  for (side=0; side<2; side++) {
    if (smallorbigangleflag) {
      lastint[side][X]=sidept1[side][X];
      lastint[side][Y]=sidept1[side][Y];
    }
    else {
      lastint[side][X]=inter[side][X];
      lastint[side][Y]=inter[side][Y];
    }
  }
#else
  memcpy(lastint,((smallorbigangleflag) ? sidept1 : inter),6*sizeof(double));
#endif
  ad3in.firstsegflag=0;
}


void putvertinsequence(vert)
struct vertexstru *vert;
{
  struct vertexstru *tempptr;

  /* put the next vertex in the sequence */
/* avoid memcpy by just moving the pointers around */
  if (ad3in.dvert2==NULL) {
    if ((tempptr=(struct vertexstru *)ad_malloc(sizeof(*ad3in.dvert2)))==NULL)
      (*ad_Closegraph)(ad3in.mallocmsg);
  }
  else tempptr=ad3in.dvert2;
  ad3in.dvert2=ad3in.dvert1;
  ad3in.dvert1=ad3in.dvert;
  ad3in.dvert=tempptr;
  memcpy(ad3in.dvert,vert,sizeof(*vert));
}


void Polyarc(arcvert2,arcvert1,matrix)
struct vertexstru *arcvert2,*arcvert1;
double (*matrix)[4][4];
{
  short numsegs;
  double inclang;
  double deltax,deltay,rad;
  double cenx,ceny;
  short i,maxarcsegs;
  double startang,fabsinc;
  double angstep,arcwidthstep;
  struct vertexstru *tvert;
  double tx,ty;

  if (arcvert2->pt0[X]==arcvert1->pt0[X] &&
      arcvert2->pt0[Y]==arcvert1->pt0[Y]) return;
  inclang=4.0*atan(arcvert2->bulge);
  if (inclang==0.0) return;
/* printf("Inclang is %lf\n",inclang); */

/* strategy -- generate verticies, call the drawseg routines
   to draw them */
  CalcPlineArcCenterOffset(arcvert2->pt0[X],arcvert2->pt0[Y],arcvert1->pt0[X],
    arcvert1->pt0[Y],inclang,&deltax,&deltay,&rad);
  cenx=(arcvert2->pt0[X]+arcvert1->pt0[X])/2.0-deltax;
  ceny=(arcvert2->pt0[Y]+arcvert1->pt0[Y])/2.0-deltay;
  ty=arcvert2->pt0[Y]-ceny;
  tx=arcvert2->pt0[X]-cenx;
  if (tx==0.0) {
    if (ty<0.0) startang = -PI2;
    else startang=PI2;
  }
  else {
    startang=atan(ty/tx);
    if (tx<0.0) startang+=PI;
  }

  fabsinc=fabs(inclang);
  numsegs=(short)(sqrt(ad3in.arcscalemult*rad)*fabsinc);
/*
 printf("Polyarc radius %lf, steps %d\n",rad,numsegs);
 printf("Polyarc fabsinc is %lf\n",fabsinc);
*/
  if (ad3ct.maxcirclesegs!=0) {
    maxarcsegs=(short)((ad3ct.maxcirclesegs*fabsinc)/(2.0*PI));
    if (numsegs>maxarcsegs) numsegs=maxarcsegs;
  }

  if (numsegs<(short)(1.5*fabsinc)) numsegs=(short)(1.5*fabsinc);
  if (numsegs<2) numsegs=2;

  angstep=inclang/numsegs;
  arcwidthstep=(arcvert2->endwidth-arcvert2->startwidth)/numsegs;

  if ((tvert=(struct vertexstru *)ad_malloc(sizeof(*tvert)))==NULL)
    (*ad_Closegraph)(ad3in.mallocmsg);
  tvert->endwidth=arcvert2->startwidth;
  tvert->pt0[Z]=arcvert2->pt0[Z];
  tvert->bulge=0.0;

  for (i=0; i<numsegs; i++) {
    tvert->startwidth=tvert->endwidth;
    tvert->endwidth+=arcwidthstep;
    tvert->pt0[X]=cenx+rad*cos(startang);
    tvert->pt0[Y]=ceny+rad*sin(startang);
    putvertinsequence(tvert);
    if (ad3in.dvert2!=NULL) {
      PolylineSeg(matrix);
    }
    startang+=angstep;
  } /* for i=0 i<numsegs */
  ad_free(tvert);
}

void DrawPolyline(matrix)
double (*matrix)[4][4];
{
  struct vertexstru *tempptr;

  if (ad3in.polylinestate==0) {
    /* point the pointers to the vertices */
    ad3in.dvert=ad3in.dvert1=ad3in.dvert2=NULL;
    ad3in.firstsegflag=ad3in.polylinestate=1;
    ad3in.firstvertexhaswidth=0;
  }

  if (ad3in.polylinestate==1) { /* which means that the last was not an arc */
    if (ad3in.vert->bulge==0.0) {  /* straight segment */
      if (ad3in.dvert==NULL || fabs(ad3in.vert->pt0[X]-ad3in.dvert->pt0[X]) > ad3in.minvisplinewid ||
          fabs(ad3in.vert->pt0[Y]-ad3in.dvert->pt0[Y]) > ad3in.minvisplinewid) {
        putvertinsequence(ad3in.vert);
        if (ad3in.dvert2!=NULL) {
          PolylineSeg(matrix);
        }
        tempptr=ad3in.vert1;
        ad3in.vert1=ad3in.vert;
        ad3in.vert=tempptr;
        ad3in.vertexcount++;
      }
    }
    else {                   /* start of arc segment */
      tempptr=ad3in.vert1;
      ad3in.vert1=ad3in.vert;
      ad3in.vert=tempptr;
      ad3in.polylinestate=2;
      ad3in.vertexcount++;
    }
  }  /* ad3in.polylinestate was 1 */
  else if (ad3in.polylinestate==2) {  /* ready to draw an arc segment */
    Polyarc(ad3in.vert1,ad3in.vert,matrix);
    if (ad3in.vert->bulge!=0.0) {
      tempptr=ad3in.vert1;
      ad3in.vert1=ad3in.vert;
      ad3in.vert=tempptr;
    }
    else {
      ad3in.polylinestate=1;
      putvertinsequence(ad3in.vert);
      if (ad3in.dvert2!=NULL) {
        PolylineSeg(matrix);
      }
    }
    ad3in.vertexcount++;
  } /* ad3in.polylinestate was 2 */
}


void terminatepolyline(matrix)
double (*matrix)[4][4];
{
  struct vertexstru *tempptr;
  double tint1,tint2;

  if (ad3in.vertexcount==1) {   /* if only one vertex made it through */
    if (ad3in.dvert!=NULL)
      DrawSeg3d(ad3in.dvert->pt0,ad3in.dvert->pt0,matrix);
    return;
  }
  if (!(ad3in.mypoly->pflag & 1)) {  /* not closed */
  /* if we were waiting for another vertex so we could draw an arc, it means
     that this vertex was not used */
    if (ad3in.polylinestate==2) {
      putvertinsequence(ad3in.vert1);
      if (ad3in.dvert2!=NULL) {
        PolylineSeg(matrix);
      }
    }

    tempptr=ad3in.dvert2;
    ad3in.dvert2=ad3in.dvert1;
    ad3in.dvert1=ad3in.dvert;
    ad3in.dvert=tempptr;
    ad_free(ad3in.dvert);
    ad3in.dvert=NULL;
    if (ad3in.dvert2!=NULL) {
      PolylineSeg(matrix);
    }
  }
   else {    /* if closed */
    if (!ad3in.firstvertexhaswidth) {  /* closed, but no width at the start */
      if (ad3in.dvert2!=NULL) {
        PolylineSeg(matrix);
      }
    }
    /* if lines cross, flip them over so they don't */
    else {
      if (!segintersection(closeint[0][X],closeint[0][Y],lastint[0][X],lastint[0][Y],
                           closeint[1][X],closeint[1][Y],lastint[1][X],lastint[1][Y],
                           &tint1,&tint2)) {
        tint1  =closeint[0][X];
        closeint[0][X]=closeint[1][X];
        closeint[1][X]=tint1;
        tint1  =closeint[0][Y];
        closeint[0][Y]=closeint[1][Y];
        closeint[1][Y]=tint1;
      }

closeint[0][Z]=closeint[1][Z]=ad3in.firstactualvertex->pt0[Z];
lastint[0][Z]=lastint[1][Z]=ad3in.dvert2->pt0[Z];
#ifndef AV
      if (ad3in.genfaces) {
        genextrudedface(closeint[0],closeint[1],lastint[1],lastint[0],matrix);
      }
      else {
#endif
        if (!adhd.fillmode || adenhd.entthickness!=0.0) {
          OutlinePoly(closeint[0],closeint[1],lastint[1],lastint[0],matrix);
        }
        /* change order to be like a solid */
        else {
          DrawFilledPoly(closeint[0],closeint[1],lastint[0],lastint[1],matrix);
        }
#ifndef AV
      }
#endif
    }  /* if first vert had width */
  }    /* if closed */
}


void DrawPolyfacemesh(matrix)
double (*matrix)[4][4];
{
  short i,vertindex,lastvertex,thisvertex,tv;
  double (*pfacepoint)[3];
  long holdloc;
  short meshvertcount;
#ifndef AV
  short i0,i1,i2,i3;
#endif
/* on 1/27/91, added the routine below that COUNTS the number of
   vertices in this pfacemesh.  slow but works, I hope */

/* in acad file, vertex indices start from 1, not 0 */
  meshvertcount=lastvertex=0;
  vertindex=1;
  if ((ad3in.vert=(struct vertexstru *)ad_malloc(sizeof(*ad3in.vert)))==NULL)
    (*ad_Closegraph)(ad3in.mallocmsg);

/* save the current location and count the number of vertices */
  if (ad3in.globalreadingfromcache==-1) holdloc=ad_ftell(adin.dwgfiler);
    else holdloc=(long)adin.entptr;
  do {
    readentityav();

#ifdef AV
    if (adenhd.enttype==20 && (ad3in.vert->vertflag & 64))
#else
    if (adenhd.enttype==20 && (aden.vertex.vertexflag & 64))
#endif
      meshvertcount++;             /* add a point */
  } while (adenhd.enttype!=17);
  ad3in.mypoly->mshm=meshvertcount;
  if (ad3in.globalreadingfromcache==-1) ad_fseek(adin.dwgfiler,holdloc,SEEK_SET);
    else adin.entptr=(char *)holdloc;

  /* allocate one extra so we can use the acad indices */
  if ((pfacepoint=(void *)ad_malloc((ad3in.mypoly->mshm+1)*3*sizeof(double)))==NULL)
    (*ad_Closegraph)(ad3in.mallocmsg);
  do {
    readentityav();
#ifndef AV
  memcpy(ad3in.vert->pt0,aden.vertex.pt0,3*sizeof(double));
  ad3in.vert->startwidth=aden.vertex.startwidth;
  ad3in.vert->endwidth=aden.vertex.endwidth;
  ad3in.vert->bulge=aden.vertex.bulge;
  ad3in.vert->vertflag=(char)aden.vertex.vertexflag;
  ad3in.vert->tangentdir=aden.vertex.tangentdir;
#endif
    if (adenhd.enttype==20) {    /* vertex */
      if (ad3in.vert->vertflag & 64) {             /* add a point */
        memcpy(pfacepoint[vertindex++],ad3in.vert->pt0,3*sizeof(double));
      }
      else if (ad3in.vert->vertflag & 128) {
#ifndef AV
if (ad3in.genfaces) {
  i0=abs(aden.vertex.polyfacevert[0]);
  i1=abs(aden.vertex.polyfacevert[1]);
  i2=abs(aden.vertex.polyfacevert[2]);
  if (aden.vertex.polyfacevertcount==3) i3=i0; else i3=abs(aden.vertex.polyfacevert[3]);

  genextrudedface(pfacepoint[i0],pfacepoint[i1],pfacepoint[i2],pfacepoint[i3],
                  matrix);
}
else {
#endif
        lastvertex=0;
        for (i=0; i<aden.vertex.polyfacevertcount; i++) {
          thisvertex=aden.vertex.polyfacevert[i];
          if (lastvertex>0) {      /* draw it */
            tv=abs(thisvertex);
            DrawSeg3d(pfacepoint[lastvertex],
                      pfacepoint[tv],matrix);
          }
          lastvertex=thisvertex;
        }  /* for i<polyfacevertcount */
        if (lastvertex>0) {
          tv=abs(aden.vertex.polyfacevert[0]);
          DrawSeg3d(pfacepoint[lastvertex],
                    pfacepoint[tv],matrix);
        }
      }    /* a vertex with point listing */
#ifndef AV
}
#endif
    }      /* a vertex */
  } while (adenhd.enttype!=17);
  ad_free(pfacepoint);
  ad_free(ad3in.vert);
  ad_free(ad3in.mypoly);
}

void processcol(matrix)
double (*matrix)[4][4];
{
  memcpy(colstart,&ms[0],sizeof(ms[0]));
  v1=0;
  v2=1;
  if (useheldverts) {
    memcpy(v3,&(vptr[heldvertindex++]),3*sizeof(double));
  }
  else {
    readentityav();
#ifndef AV
    memcpy(ad3in.vert->pt0,aden.vertex.pt0,3*sizeof(double));
    ad3in.vert->startwidth=aden.vertex.startwidth;
    ad3in.vert->endwidth=aden.vertex.endwidth;
    ad3in.vert->bulge=aden.vertex.bulge;
    ad3in.vert->vertflag=(char)aden.vertex.vertexflag;
    ad3in.vert->tangentdir=aden.vertex.tangentdir;
#endif
    memcpy(v3,ad3in.vert->pt0,3*sizeof(double));
  }
  memcpy(nextcolstart,v3,sizeof(v3));
  for (ncount=0; ncount<n-1; ncount++) {
    if (useheldverts) {
      memcpy(v4,&(vptr[heldvertindex++]),3*sizeof(double));
    }
    else {
      readentityav();
#ifndef AV
      memcpy(ad3in.vert->pt0,aden.vertex.pt0,3*sizeof(double));
      ad3in.vert->startwidth=aden.vertex.startwidth;
      ad3in.vert->endwidth=aden.vertex.endwidth;
      ad3in.vert->bulge=aden.vertex.bulge;
      ad3in.vert->vertflag=(char)aden.vertex.vertexflag;
      ad3in.vert->tangentdir=aden.vertex.tangentdir;
#endif
      memcpy(v4,ad3in.vert->pt0,3*sizeof(double));
    }
#ifndef AV
    if (ad3in.genfaces) {
      genextrudedface(ms[v1],ms[v2],v4,v3,matrix);
    }
    else
#endif
/* draw across, then down */
      DrawSeg3d(ms[v1],v3,matrix);
      DrawSeg3d(v3,v4,matrix);
      if (ncount==n-2)  /* the final leg across */
        DrawSeg3d(v4,ms[v2],matrix);
    memcpy(&ms[v1],v3,sizeof(v3));
    v1=v2;
    v2++;
    memcpy(v3,v4,sizeof(v4));
  }
  if (ad3in.mypoly->pflag & 32) {  /* n-closed */
#ifndef AV
    if (ad3in.genfaces) {
      genextrudedface(ms[v1],colstart,nextcolstart,v3,matrix);
    }
    else
#endif
/* didn't bother to optimize this one */
      OutlinePoly(ms[v1],colstart,nextcolstart,v3,matrix);
  }
  memcpy(&ms[v1],v3,sizeof(v3));
} /* end of processcol */


void DrawPolymesh(matrix)
double (*matrix)[4][4];
{
  heldvertindex=useheldverts=0;
  vptr=NULL;
  if ((ad3in.vert=(struct vertexstru *)ad_malloc(sizeof(*ad3in.vert)))==NULL)
    (*ad_Closegraph)(ad3in.mallocmsg);

  if (ad3in.globalreadingfromcache==-1) plinefilepos=ad_ftell(adin.dwgfiler);
  else plinefilepos=(long)adin.entptr;

  m=ad3in.mypoly->mshm;
  n=ad3in.mypoly->mshn;

  for (ncount=0; ncount<ad3in.mypoly->mshn; ncount++) {
    readentityav();
#ifndef AV
  memcpy(ad3in.vert->pt0,aden.vertex.pt0,3*sizeof(double));
  ad3in.vert->startwidth=aden.vertex.startwidth;
  ad3in.vert->endwidth=aden.vertex.endwidth;
  ad3in.vert->bulge=aden.vertex.bulge;
  ad3in.vert->vertflag=(char)aden.vertex.vertexflag;
  ad3in.vert->tangentdir=aden.vertex.tangentdir;
#endif
    memcpy(ms[ncount],ad3in.vert->pt0,3*sizeof(double));
    if (ncount>0) DrawSeg3d(ms[ncount-1],ms[ncount],matrix);
  }
  if ((ad3in.mypoly->pflag & 1) &&  /* if m-closed, try to hold the vertices */
     (vptr=(double (*)[3])ad_malloc(3*sizeof(double)*ad3in.mypoly->mshn))!=NULL)
      memcpy(vptr,ms,3*sizeof(double)*ad3in.mypoly->mshn);

  for (mcount=0; mcount<m-1; mcount++) processcol(matrix);

  if (ad3in.mypoly->pflag & 1) {  /* m-closed */
  /* return to start of pline, process one more column, done */
    if (vptr!=NULL) {
      useheldverts=1;
    }
    else {
      if (ad3in.globalreadingfromcache==-1) {
        plinefilepos2=ad_ftell(adin.dwgfiler);
        ad_fseek(adin.dwgfiler,plinefilepos,SEEK_SET);
      }
      else {
        plinefilepos2=(long)adin.entptr;
        adin.entptr=(char *)plinefilepos;
      }
    }
    processcol(matrix);
    if (vptr!=NULL) ad_free(vptr);
    else {
      if (ad3in.globalreadingfromcache==-1) ad_fseek(adin.dwgfiler,plinefilepos2,SEEK_SET);
      else adin.entptr=(char *)plinefilepos2;
    }
  } /* m-closed */
  do readentityav();
  while (adenhd.enttype!=17);  /* seqend */
  ad_free(ad3in.vert);
  ad_free(ad3in.mypoly);
}
