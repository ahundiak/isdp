
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* avmaths.c -- autoview math functions, screen related */

#include "avhdr.h"
/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#if defined(AV) && !defined(OS_UNIX)
double far engtarget[16][4];
double far engviewdir[16][4];
double far engup[16][4];
double far engvportcen[16][3];
double far engvportheight[16];
double far engvportwidth[16];
double far engvportsize[16];
#else
double engtarget[16][4];
double engviewdir[16][4];
double engup[16][4];
double engvportcen[16][3];
double engvportheight[16];
double engvportwidth[16];
double engvportsize[16];
#endif
extern void dwgfilerseek _((long newloc));  /* from adrent.c */

#ifdef OLDONE
#ifndef OLDCHDR
void rotate3(double s,double c,double mat[4][4],short axis) /* 0 for x, 1 for y, 2 for z */
#else
void rotate3(s,c,mat,axis) /* 0 for x, 1 for y, 2 for z */
double s,c;
double mat[4][4];
short axis;
#endif
{
  register short i;
  double tmp,signmult;
  short a,b;

  a=0; b=2; signmult= -1.0;
  if (axis==0) a=1;
  if (axis==1) signmult=1.0;
  if (axis==2) b=1;

  for (i=0; i<4; i++) {
    tmp=mat[i][a]*c+signmult*mat[i][b]*s;
    mat[i][b]=mat[i][a]*s+mat[i][b]*c;
    mat[i][a]=tmp;
  }
}
#endif

#ifndef OLDCHDR
void rotate3(double s,double c,double mat[4][4],short axis) /* 0 for x, 1 for y, 2 for z */
#else
void rotate3(s,c,mat,axis) /* 0 for x, 1 for y, 2 for z */
double s,c;
double mat[4][4];
short axis;
#endif
{
/* rewritten so that humans can understand it, also removes some incorrect
   assumptions that were screwing things up later */
  double rotmat[4][4];

  identity(rotmat);
  if (axis==0) {
    rotmat[1][1]=rotmat[2][2]=c;
    rotmat[1][2]=s;
    rotmat[2][1]=-s;
  }
  else if (axis==1) {
    rotmat[0][0]=rotmat[2][2]=c;
    rotmat[0][2]=-s;
    rotmat[2][0]=s;
  }
  else if (axis==2) {
    rotmat[0][0]=rotmat[1][1]=c;
    rotmat[0][1]=s;
    rotmat[1][0]=-s;
  }
  matmult(mat,rotmat,mat);
}

#ifdef microsoftc
#pragma loop_opt(off)
#endif
void invert(a)
double a[4][4];
/* cacm algorithm 120, implemented in C */
{
  double b[4],c[4];
  double w,y;
  short z[4];
  short i;
  register short j,k;

  z[0]=0; z[1]=1; z[2]=2; z[3]=3;

  for (i=0; i<4; i++) {
    k=i; y=a[i][i];

    for (j=i+1; j<4; j++) {
      w=a[i][j];
      if (fabs(w)>fabs(y)) {
        k=j;
        y=w;
      }
    } /* for j=i+1 */

    /* if fabs(y)<EPS goto alarm */
    y=1.0/y;
    for (j=0; j<4; j++) {
      c[j]=a[j][k];
      a[j][k]=a[j][i];
      a[j][i]= -c[j] * y;
      a[i][j]*=y;
      b[j]=a[i][j];
    }
    a[i][i]=y;
    j=z[i];
    z[i]=z[k];
    z[k]=j;
    for (k=0; k<4; k++)
      if (k!=i)
        for (j=0; j<4; j++)
          if (j!=i)
            a[k][j]=a[k][j]-b[j]*c[k];
  }

  for (i=0; i<4; i++) {
    do {
      k=z[i];
      if (k!=i) {
        for (j=0; j<4; j++) {
          w=a[i][j];
          a[i][j]=a[k][j];
          a[k][j]=w;
        }
        j=z[i];
        z[i]=z[k];
        z[k]=j;
      }
    } while (k!=i);
  }
}
#ifdef microsoftc
#pragma loop_opt(on)
#endif

#ifndef OLDCHDR
void makedcsmat(double viewdirvec[4],double mytarget[4],double upvec[4],
  double myviewctrx,double myviewctry)
#else
void makedcsmat(viewdirvec,mytarget,upvec,
  myviewctrx,myviewctry)
double viewdirvec[4];
double mytarget[4];
double upvec[4];
double myviewctrx;
double myviewctry;
#endif
{
  double xupvp,yupvp;
  double v;
  short i;

/* given a view direction vector and up vector, */
/* create the WCS to DCS matrix */

  identity(ad3in.dcsmat);
/* translate so that the target is the new origin */
  for (i=0; i<3; i++) ad3in.dcsmat[3][i]-=mytarget[i];

/* viewdirvec is the viewplane normal */
  v=sqrt(viewdirvec[1]*viewdirvec[1]+viewdirvec[2]*viewdirvec[2]);
/* dangerous change -- flipped sign on viewdirvec */
  if (v>ROUNDOFF) rotate3(viewdirvec[1]/v,viewdirvec[2]/v,ad3in.dcsmat,0);
  rotate3(-viewdirvec[0],v,ad3in.dcsmat,1);

/* determine the view-up direction in these new coords */

  xupvp=upvec[0]*ad3in.dcsmat[0][0]+upvec[1]*ad3in.dcsmat[1][0]+upvec[2]*ad3in.dcsmat[2][0];
  yupvp=upvec[0]*ad3in.dcsmat[0][1]+upvec[1]*ad3in.dcsmat[1][1]+upvec[2]*ad3in.dcsmat[2][1];

/* determine rotation needed to make view-up vertical */
  v=sqrt(xupvp*xupvp+yupvp*yupvp);
  rotate3(xupvp/v,yupvp/v,ad3in.dcsmat,2);

/* at this point, ad3in.dcsmat contains the transformation matrix to screen
   coordinates, before screen scaling */

/* after all that, put viewctr in the center of the screen */
  ad3in.dcsmat[3][0]-=myviewctrx; ad3in.dcsmat[3][1]-=myviewctry;
}

#ifndef OLDCHDR
double tvcalc(double tempvec3[4],double tempvec2[4],short a,short b)
#else
double tvcalc(tempvec3,tempvec2,a,b)
double tempvec3[4];
double tempvec2[4];
short a,b;
#endif
{
  return(tempvec3[a]-tempvec3[b]*(tempvec3[a]-tempvec2[a])/
                (tempvec3[b]-tempvec2[b]));
}

#ifndef OLDCHDR
void findtarget(double adtarget[4])
#else
void findtarget(adtarget)
double adtarget[4];
#endif
{
  double invdcsmat[4][4];
  double tempvec[4],tempvec2[4],tempvec3[4];

/* now we need to determine our real campos, target, and up vector for */
/* display purposes */
/* target is viewctrx, viewctry (in DCS), transformed to world coords */
/* with viewctrz==0.0.  We solve for the world coordinate value whose z */
/* coord is zero and which transforms to viewctrx,viewctry,0 */
/* then we compute campos from viewdir and target */
  memcpy(invdcsmat,ad3in.dcsmat,16*sizeof(double));
  invert(invdcsmat);

  /* we convert two known points to world coords, 0,0,0, and 0,0,1 */
  tempvec[0]=tempvec[1]=tempvec[2]=0.0; tempvec[3]=1.0;
  transformpoint3d(tempvec,invdcsmat,tempvec2);  /* transform to wcs */
  tempvec[2]=1.0;
  transformpoint3d(tempvec,invdcsmat,tempvec3);  /* transform to wcs */

/* now we compute using these two wcs points, which form a line normal */
/* to the screen out of its center, to find the point in wcs where z==0 */
/* to use as our target */
  /* compute x and y slopes (?terminology?) */
  adtarget[0]=adtarget[1]=adtarget[2]=0.0;
  if (tempvec3[2]!=tempvec2[2]) {   /* line not parallel to xy plane */
    /* now, what would x and y be at z==0.0? */
    adtarget[0]=tvcalc(tempvec3,tempvec2,0,2);
    adtarget[1]=tvcalc(tempvec3,tempvec2,1,2);
  }
  else if (tempvec3[1]!=tempvec2[1]) {
    adtarget[0]=tvcalc(tempvec3,tempvec2,0,1);
    adtarget[2]=tvcalc(tempvec3,tempvec2,2,1);
  }
  else if (tempvec3[0]!=tempvec2[0]) {
    adtarget[1]=tvcalc(tempvec3,tempvec2,1,0);
    adtarget[2]=tvcalc(tempvec3,tempvec2,2,0);
  }
  adtarget[3]=1.0;
}

#ifndef OLDCHDR
void makescrntransmat(double xmin,double ymin,double xmax,double ymax,double xsize, double ysize)
#else
void makescrntransmat(xmin,ymin,xmax,ymax,xsize,ysize)
double xmin,ymin,xmax,ymax,xsize,ysize;
#endif
{
/* now finish computing ad3in.viewplanetransmat */
  double xmapmult,ymapmult;
  double transpt[3];

  xmapmult=(xmax-xmin)/xsize;
  ymapmult=(ymax-ymin)/ysize;

  identity(ad3in.dcstoscrnmat);

 /* we offset by 1/2 pixel to make things fit right.  also, we increase the
   clip maxima by 0.5, which allows us to avoid having to do modf functions
   to truncate the floating point numbers in the clipper */
  transpt[0]=(xmax+xmin)/2.0+0.5;
  transpt[1]=(ymax+ymin)/2.0+0.5;
  transpt[2]=0.0;
  translatematrix(transpt,ad3in.dcstoscrnmat);
/* 2nd xmapmult was 1.0 */
  scalematrix(xmapmult,ymapmult,xmapmult,ad3in.dcstoscrnmat);
}

#ifndef OLDCHDR
void setinitialupvector(double viewdirvec[4],double viewtwist,double upvec[4])
#else
void setinitialupvector(viewdirvec,viewtwist,upvec)
double viewdirvec[4];
double viewtwist;
double upvec[4];
#endif
{
  double tempvec[4],zaxis[4];

/* establish viewdir vector, use it and target to create up vector */
  normalize(viewdirvec);
  if (viewdirvec[0]==0.0 && viewdirvec[1]==0.0) { /* if viewing down z axis, */
      upvec[0]=0.0; upvec[1]=1.0; upvec[2]=0.0;            /* set up to y axis */
  }
  else {
/* take cross product of viewdir vector with zaxis to get a temporary vector,
   then cross that vector with the viewdir to get the up vector */
    zaxis[0]=0.0; zaxis[1]=0.0; zaxis[2]=1.0; zaxis[3]=0.0;
    crossproduct(zaxis,viewdirvec,tempvec);
/* crossproduct now normalizes */
    crossproduct(viewdirvec,tempvec,upvec);
  }
  /* now rotate the view by viewtwist */
  /* construct point at end of up vector from cam pos */
  if (viewtwist!=0.0) {
/* this "unlooped" version actually produces shorter exe code */
    tempvec[0]=viewdirvec[0]+upvec[0];
    tempvec[1]=viewdirvec[1]+upvec[1];
    tempvec[2]=viewdirvec[2]+upvec[2];
    tempvec[3]=1.0;

    rotatearoundaxis(tempvec,viewdirvec,viewdirvec,-viewtwist);

    upvec[0]=tempvec[0]-viewdirvec[0];
    upvec[1]=tempvec[1]-viewdirvec[1];
    upvec[2]=tempvec[2]-viewdirvec[2];
    normalize(upvec);
  }
  if (fabs(upvec[0])<1.0E-13) upvec[0]=0.0;
  if (fabs(upvec[1])<1.0E-13) upvec[1]=0.0;
  if (fabs(upvec[2])<1.0E-13) upvec[2]=0.0;
}

#ifndef OLDCHDR
void setpspacevportentcliplimits(short xpixmin,short ypixmin,
  short xpixmax,short ypixmax,short whichvp)
#else
void setpspacevportentcliplimits(xpixmin,ypixmin,xpixmax,ypixmax,whichvp)
short xpixmin,ypixmin,xpixmax,ypixmax,whichvp;
#endif
{
  double temppt[4];
  double *evpc;

  evpc=engvportcen[whichvp];

  temppt[0]=evpc[0]-engvportwidth[whichvp]/2.0;
  temppt[1]=evpc[1]-engvportheight[whichvp]/2.0;
  temppt[2]=evpc[2];
  temppt[3]=1.0;
  transformpoint3d(temppt,ad3in.viewplanetransmat[0],temppt);  /* transform */
  ad3in.xrealmin[whichvp]=ad3in.xclipmin[whichvp]=temppt[0]+1.0;
  if (ad3in.xclipmin[whichvp]<(double)xpixmin) ad3in.xclipmin[whichvp]=(double)xpixmin;
#ifdef AV
  ad3in.xclipminl[whichvp]=(long)ad3in.xclipmin[whichvp];
#endif
  ad3in.yrealmin[whichvp]=ad3in.yclipmin[whichvp]=temppt[1]+1.0;
  if (ad3in.yclipmin[whichvp]<(double)ypixmin) ad3in.yclipmin[whichvp]=(double)ypixmin;
#ifdef AV
  ad3in.yclipminl[whichvp]=(long)ad3in.yclipmin[whichvp];
#endif
  temppt[0]=evpc[0]+engvportwidth[whichvp]/2.0;
  temppt[1]=evpc[1]+engvportheight[whichvp]/2.0;
  temppt[2]=evpc[2];
  temppt[3]=1.0;
  transformpoint3d(temppt,ad3in.viewplanetransmat[0],temppt);  /* transform */
  ad3in.xrealmax[whichvp]=ad3in.xclipmax[whichvp]=temppt[0]-1.0;
  if (ad3in.xclipmax[whichvp]>(double)xpixmax) ad3in.xclipmax[whichvp]=(double)xpixmax;
#ifdef AV
  ad3in.xclipmaxl[whichvp]=(long)ad3in.xclipmax[whichvp];
#endif
  ad3in.yrealmax[whichvp]=ad3in.yclipmax[whichvp]=temppt[1]-1.0;
  if (ad3in.yclipmax[whichvp]>(double)ypixmax) ad3in.yclipmax[whichvp]=(double)ypixmax;
#ifdef AV
  ad3in.yclipmaxl[whichvp]=(long)ad3in.yclipmax[whichvp];
#endif
}


#ifndef OLDCHDR
short readvp(short which)
#else
short readvp(which)
short which;
#endif
{
/* testing */
  adin.dwgfiler=adin.dwgfilerent;

  dwgfilerseek(adin.vportenthdrliststartr+which*adin.sizeofvportenthdrentryr);
/*  ad_fseek(adin.dwgfiler,adin.vportenthdrliststartr+which*adin.sizeofvportenthdrentryr,SEEK_SET); */
  readvportenthdr();
  return(aden.vpent.stackval);
}

#ifndef OLDCHDR
void resetcliplimits(short xpixmin,short ypixmin,short xpixmax,short ypixmax)
#else
void resetcliplimits(xpixmin,ypixmin,xpixmax,ypixmax)
short xpixmin,ypixmin,xpixmax,ypixmax;
#endif
{
  ad3in.xrealmin[0]=ad3in.xclipmin[0]=(double)xpixmin;
  ad3in.yrealmin[0]=ad3in.yclipmin[0]=(double)ypixmin;
  ad3in.xrealmax[0]=ad3in.xclipmax[0]=(double)xpixmax;
  ad3in.yrealmax[0]=ad3in.yclipmax[0]=(double)ypixmax;

#ifdef AV
  ad3in.xclipminl[0]=(long)ad3in.xclipmin[0];
  ad3in.yclipminl[0]=(long)ad3in.yclipmin[0];

  ad3in.xclipmaxl[0]=(long)ad3in.xclipmax[0];
  ad3in.yclipmaxl[0]=(long)ad3in.yclipmax[0];
#endif

/* increase the clip max so we don't have to round off in the clipper */
  ad3in.xclipmax[0]+=0.5;
  ad3in.yclipmax[0]+=0.5;
}

#ifndef OLDCHDR
void setinitialview(double adviewdir[4],double adtarget[4],double adup[4],
  short xpixmin,short ypixmin,short xpixmax,short ypixmax,double *xsize,double *ysize)
#else
void setinitialview(adviewdir,adtarget,adup,
                    xpixmin,ypixmin,xpixmax,ypixmax,
                    xsize,ysize)
double adviewdir[4],adtarget[4],adup[4];
short xpixmin,ypixmin,xpixmax,ypixmax;
double *xsize,*ysize;
#endif
{
  double myviewctrx,myviewctry,myviewsize,myviewtwist;
  short i,j,nextvpno;
  double *evd,*et;

/* first, set layer flags */
  for (i=0; i<(short)adct.numlayersr; i++) lay[i]->vpfrozflags=0;

  nextvpno=i=0;
  do {
    evd=engviewdir[i];
    et=engtarget[i];
  /* get viewdir and target info */
    if (ad3in.enginespace==MODELSPACE) {
      memcpy(evd,adhd.vpointhdr,3*sizeof(double));
      et[0]=0.0;
      et[1]=0.0;
      et[2]=0.0;
      myviewctrx=adhd.viewctr[X];
      myviewctry=adhd.viewctr[Y];
      myviewsize=adhd.viewsize;
      myviewtwist=0.0;
      if (adct.ouracadverr > ACAD9 && adct.numvportsr>0) { /* greater than acad 9 */
        startvportread();                        /* read active vport info */
        j=0;
        do {
          if (j<(short)adct.numvportsr) readvport();
          j++;
        } while (j<(short)adct.numvportsr && (adtb.vport.purgedflag || strcmp(adtb.vport.name,"*ACTIVE")));
        if (!strcmp(adtb.vport.name,"*ACTIVE")) {
          if (fabs(adtb.vport.viewdir[0])<1.0E-13) adtb.vport.viewdir[0]=0.0;
          if (fabs(adtb.vport.viewdir[1])<1.0E-13) adtb.vport.viewdir[1]=0.0;
          if (fabs(adtb.vport.viewdir[2])<1.0E-13) adtb.vport.viewdir[2]=0.0;
          memcpy(evd,adtb.vport.viewdir,3*sizeof(double));
          memcpy(et,adtb.vport.target,3*sizeof(double));
          myviewctrx=adtb.vport.center[0];
          myviewctry=adtb.vport.center[1];
          myviewsize=adtb.vport.viewheight;
          myviewtwist=adtb.vport.viewtwist;
        }
      } /* > acad9 */
      evd[3]=et[3]=1.0;
    } /* if ad3in.enginespace==MODELSPACE */
    else {  /* in paperspace */
/* remember to skip the dummy entry */
      if (nextvpno==0) {  /* get the main pspace vport first, which is index 1 */
        readvp(1);
        nextvpno=adhd.cvport;  /* go to start of chain */
      }
      else {
/* if the chain has come thru #1, skip it -- if the result of the skip is 0,
   there are no mspace vports in the chain */
        if (nextvpno==1 && (nextvpno=readvp(1))==0) continue;
        nextvpno=readvp(nextvpno);     /* the next one */
      }
      adin.dwgfiler=adin.dwgfilerblk;
/* new -- test to see if the vportentity is in the extra ent section */
      if (adin.vportentlocr & 0x80000000L)
        adin.vportentlocr=(adin.vportentlocr & 0x7FFFFFFFL)+adin.extraentlocr;
      dwgfilerseek(adin.vportentlocr);
/*      ad_fseek(adin.dwgfiler,adin.vportentlocr,SEEK_SET); */

      ad3in.layvpflags=1<<i;         /* adrentav uses this to set bits */

      adin.readfrozen=1;       /* doesn't work otherwise, cuz it might not get read */
      readentityav();          /* read the entity to get the id # */
      adin.readfrozen=0;

      memcpy(et,adin.vportenttarget,3*sizeof(double));
      memcpy(evd,adin.vportentviewdir,3*sizeof(double));;
      if (fabs(evd[0])<1.0E-13) evd[0]=0.0;
      if (fabs(evd[1])<1.0E-13) evd[1]=0.0;
      if (fabs(evd[2])<1.0E-13) evd[2]=0.0;
      myviewctrx=adin.vportentviewctr[X];
      myviewctry=adin.vportentviewctr[Y];

/* use engvportsize to recalc vport ents later on */
      engvportsize[i]=myviewsize=adin.vportentviewheight;
      myviewtwist=adin.vportentviewtwist;
      memcpy(engvportcen[i],aden.vpent.cen,3*sizeof(double));
      engvportheight[i]=aden.vpent.height;
      engvportwidth[i]=aden.vpent.width;
/*
      if (i==0) {
        printf("Target is %lf,%lf,%lf\n",et[0],et[1],et[2]);
        printf("Viewdir is %lf,%lf,%lf\n",evd[0],evd[1],evd[2]);
        printf("Myviewctr is %lf,%lf\n",myviewctrx,myviewctry);
        printf("Myviewsize, twist are %lf,%lf\n",myviewsize,myviewtwist);
      }
*/
      evd[3]=et[3]=1.0;
    }
    setinitialupvector(evd,myviewtwist,engup[i]);
    makedcsmat(evd,et,engup[i],myviewctrx,myviewctry);
    findtarget(et);
    if (i==0) {  /* MODELSPACE, or PAPERSPACE vport #0 */
      resetcliplimits(xpixmin,ypixmin,xpixmax,ypixmax);
    }
    else  /* PAPERSPACE upper vports */
/* transform paperspace corners of vport to pixel space to get the */
/* clipping boundaries */
      setpspacevportentcliplimits(xpixmin,ypixmin,xpixmax,ypixmax,i);

    if (i==0) {
      *ysize=myviewsize;
      *xsize=myviewsize*((double)xpixmax-(double)xpixmin)/((double)ypixmax-(double)ypixmin)*ad3ct.aspectratio;
    }
    makescrntransmat(ad3in.xrealmin[i],ad3in.yrealmin[i],ad3in.xrealmax[i],ad3in.yrealmax[i],
      myviewsize*(ad3in.xrealmax[i]-ad3in.xrealmin[i])/(ad3in.yrealmax[i]-ad3in.yrealmin[i])*ad3ct.aspectratio,
      myviewsize);
    matmult(ad3in.dcsmat,ad3in.dcstoscrnmat,ad3in.viewplanetransmat[i]);

    normalize(evd);  /* just to make sure */
    normalize(engup[i]);
    i++;
  } while (nextvpno!=0);

  memcpy(adviewdir,engviewdir[0],4*sizeof(double));
  memcpy(adtarget, engtarget[0], 4*sizeof(double));
  memcpy(adup,     engup[0],     4*sizeof(double));

  ad3in.numvptmats=i;  /* cut to the number of entries found */
  if (ad3in.enginespace==PAPERSPACE) ad3in.numpspvptmats=i;

  ad3in.layvpflags=0;  /* eliminate this */
/*
  for (i=0; i<numlayersr; i++)
    printf("Layer %2d: %32s   flags %X\n",i,lay[i]->layname,lay[i]->vpfrozflags);
getch();
*/
}

#ifndef OLDCHDR
void makeviewtransform(double viewdirvec[4],double target[4],double up[4],
  short xpixmin,short ypixmin,short xpixmax,short ypixmax,double xsize,double ysize)
#else
void makeviewtransform(viewdirvec,target,up,
  xpixmin,ypixmin,xpixmax,ypixmax,xsize,ysize)
double viewdirvec[4],target[4],up[4];
short xpixmin,ypixmin,xpixmax,ypixmax;
double xsize,ysize;
#endif
{
  short i;
  double pixperrealunitx,pixperrealunity,vportxsize;

  pixperrealunitx=(double)(xpixmax-xpixmin)/xsize;
  pixperrealunity=(double)(ypixmax-ypixmin)/ysize;

  memcpy(engviewdir[0],viewdirvec,4*sizeof(double));
  memcpy(engtarget[0], target,    4*sizeof(double));
  memcpy(engup[0],     up,        4*sizeof(double));
  makedcsmat(engviewdir[0],engtarget[0],engup[0],0.0,0.0);

  makescrntransmat((double)xpixmin,(double)ypixmin,(double)xpixmax,(double)ypixmax,
    xsize,ysize);
  matmult(ad3in.dcsmat,ad3in.dcstoscrnmat,ad3in.viewplanetransmat[0]);

  resetcliplimits(xpixmin,ypixmin,xpixmax,ypixmax);

  if (ad3in.enginespace==PAPERSPACE) {    /* fixup the vpent matrices */
    for (i=1; i<ad3in.numvptmats; i++) {
      makedcsmat(engviewdir[i],engtarget[i],engup[i],0.0,0.0);
      setpspacevportentcliplimits(xpixmin,ypixmin,xpixmax,ypixmax,i);
      vportxsize=engvportsize[i]
          *(ad3in.xrealmax[i]-ad3in.xrealmin[i])/(ad3in.yrealmax[i]-ad3in.yrealmin[i])
          *(pixperrealunity/pixperrealunitx);
      makescrntransmat(ad3in.xrealmin[i],ad3in.yrealmin[i],ad3in.xrealmax[i],ad3in.yrealmax[i],
        vportxsize,engvportsize[i]);
      matmult(ad3in.dcsmat,ad3in.dcstoscrnmat,ad3in.viewplanetransmat[i]);
    }
  }
}
