
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* avdraw.c -- autoview drawentitygroup routine */

#include "avhdr.h"
#ifdef PROTOTYPES
extern void readpastentity(short numbytes);
extern void dwgfilerseek(long newloc);
#else
extern void readpastentity();
extern void dwgfilerseek();
#endif

/* #define CACHEDBG 1  */

double bs,minvisplinex,minvispliney;

#ifdef AV
  char *nextcacheloc;
  short exts;
  long newloc;
#endif

#if !defined(BIGENDIAN) && !defined(QUADWORDALIGNED)
#define rdreal() *((double *)adin.entptr), adin.entptr+=sizeof(double)
#define rdlong() *((long *)  adin.entptr), adin.entptr+=sizeof(long)
#define rdc()    *((char *)  adin.entptr), adin.entptr+=sizeof(char)
#define rdw()    *((short *) adin.entptr), adin.entptr+=sizeof(short)
#else
extern double rdreal();    /* hope these carry in from AD2 */
extern long rdlong();
extern char rdc();
extern short rdw();
#endif

extern long entcount;
long entcount=0;
short holdperc,odomflip;
double ptpt0[4],ptpt1[4];
short truncpdmode;

#ifndef OLDCHDR
void DrawVportRect(double x1,double y1,double x2,double y2,double z1,double (*viewmat)[4][4])
#else
void DrawVportRect(x1,y1,x2,y2,z1,viewmat)
double x1,y1,x2,y2,z1,(*viewmat)[4][4];
#endif
{
  double pt0[3],pt1[3],pt2[3],pt3[3];
  pt0[X]=pt3[X]=x1;
  pt1[X]=pt2[X]=x2;
  pt0[Y]=pt1[Y]=y1;
  pt2[Y]=pt3[Y]=y2;
  pt0[Z]=pt1[Z]=pt2[Z]=pt3[Z]=z1;
  OutlinePoly(pt0,pt1,pt2,pt3,viewmat);
}

#ifndef OLDCHDR
void RotDrawSeg3d(double pt0[4],double pt1[4],double (*viewmat)[4][4],double rotang,double aboutpt[4])
#else
void RotDrawSeg3d(pt0,pt1,viewmat,rotang,aboutpt)
double pt0[4],pt1[4],(*viewmat)[4][4],rotang,aboutpt[4];
#endif
{
/* draw segments for points, taking into account ucs x angle rotation */
  double newpt0[4],newpt1[4];
  double tempx,tempy;
  double cosa,sina;

  rotang=2.0*PI-rotang;
  cosa=cos(rotang);
  sina=sin(rotang);
  memcpy(newpt0,pt0,3*sizeof(double));
  newpt0[0] -= aboutpt[0];
  newpt0[1] -= aboutpt[1];
  tempx=cosa*newpt0[0]-sina*newpt0[1];
  tempy=sina*newpt0[0]+cosa*newpt0[1];
  newpt0[0]=tempx+aboutpt[0];
  newpt0[1]=tempy+aboutpt[1];

  memcpy(newpt1,pt1,3*sizeof(double));
  newpt1[0] -= aboutpt[0];
  newpt1[1] -= aboutpt[1];
  tempx=cosa*newpt1[0]-sina*newpt1[1];
  tempy=sina*newpt1[0]+cosa*newpt1[1];
  newpt1[0]=tempx+aboutpt[0];
  newpt1[1]=tempy+aboutpt[1];

  DrawSeg3d(newpt0,newpt1,viewmat);
}

#ifndef OLDCHDR
short DrawEntityGroup(double oldmatrix[4][4],double newpt[3],
  double neworient,double newxscale,double newyscale,double newzscale,
  short byblockcolor,short byblockltp,short level,short readingfromcache,
  unsigned short vpflags)
#else
short DrawEntityGroup(oldmatrix,newpt,neworient,newxscale,newyscale,
                      newzscale,byblockcolor,byblockltp,level,readingfromcache,vpflags)
double oldmatrix[4][4];
double newpt[3];
double neworient,newxscale,newyscale,newzscale;
short byblockcolor,byblockltp,level;
short readingfromcache;
unsigned short vpflags;
#endif
/* draw until you reach the end of entities or an endblock ent */
{
  short returnval,i,j,k;
  double worldmat[4][4];      /* puts drawing stuff into world coords */
  double (*viewmat)[4][4];    /* puts drawing stuff to view coords */
  double *vm0,*vm1;           /* point at a specific viewmat */
  double (*shmat)[4][4];      /* shape draw matrices */
  double blkmat[4][4];        /* for things with non parallel extru */
  double inspt[4];            /* for recursive calls */
  struct blkstru *bv;
  long holdloc,temploc;
  unsigned short thisentcolor;
  short flaghold,plinespace;
  AD_FILE *holdfile;
  double plthik,plwidhold,arcscalehold;
  short cacheblock,holdcachereadstate;
  char *holdcacheptr;
  short holdinsentlayer,holdneed;
  double minvistextht,temp,temp2,temp3,temp4;
  short paperspaceinsert;
  unsigned short holdvpflags;
  short attribzerocolor;  /* for attrib on layer 0 */
  short insdim;

  odomflip=2;

  ad3in.globalreadingfromcache=readingfromcache;

  if (ad3in.globalreadingfromcache!=-1) {
    adin.entptr=ad3in.blockcache[ad3in.globalreadingfromcache].blkdata;
#ifdef CACHEDBG
    printf("adin.entptr is %lX at start of cache entry\n",adin.entptr);
#endif
  }
  ad3in.mypoly=NULL;
  memcpy(worldmat,oldmatrix,(size_t)16*sizeof(double));
  translatematrix(newpt,worldmat);
  if (neworient!=0.0) rotatematrixz(neworient,worldmat);
  scalematrix(newxscale,newyscale,newzscale,worldmat);

  viewmat=(double (*)[4][4])ad_malloc(ad3in.numvptmats*sizeof(*viewmat));


  if (viewmat==NULL) {
    clearunusedcacheitems();
    viewmat=(double (*)[4][4])ad_malloc(ad3in.numvptmats*sizeof(*viewmat));
    if (viewmat==NULL) {
	  closeshapefiles();
      viewmat=(double (*)[4][4])ad_malloc(ad3in.numvptmats*sizeof(*viewmat));
      if (viewmat==NULL) {  /* really should set a flag here */
        return(1);
      }
    }
  }

  temp=temp2=1.0E+300;
  temp3=1.0E-300;
  for (i=0; i<ad3in.numvptmats; i++) {
    vm0=viewmat[i][X]; vm1=viewmat[i][Y];
    matmult(worldmat,ad3in.viewplanetransmat[i],viewmat[i]);
  /* determine the minimum text height for text to be drawn */
/* this is equivalent to taking two points, one at 0,0,0 and one at 0,1,0,
   transforming, then determining the distance between the two new points.
   That is our way of pretending we did the transform, and therefore determining
   what the new height of the segment would be */
    minvistextht=sqrt(vm1[X]*vm1[X]+
                         vm1[Y]*vm1[Y]+
                         vm1[Z]*vm1[Z]);

    /* that is the transformed height in pixels of a 1.0 height text line */
    minvispliney=1.3333/minvistextht;  /* grab this while it's here */
    /* so we determine what height would make the # pixels be 3 */
    minvistextht=3.0/minvistextht;

    minvisplinex=1.333/sqrt(vm0[X]*vm0[X]+
                            vm0[Y]*vm0[Y]+
                            vm0[Z]*vm0[Z]);
    if (minvisplinex<minvispliney) ad3in.minvisplinewid=minvisplinex;
                              else ad3in.minvisplinewid=minvispliney;
    ad3in.minvisplinewid*=2.0;
    if (ad3in.minvisplinewid<temp) temp=ad3in.minvisplinewid;
    if (minvistextht<temp2) temp2=minvistextht;
/* find maximum scale # for arcs */
/* do this a little differently (again).  Pretend you have a point 1,1,
and see how large it gets transformed to (not including the fourth array
item).  Take the larger one */
    if (fabs(vm0[X])+fabs(vm1[X])>temp3)
      temp3=fabs(vm0[X])+fabs(vm1[X]);
    if (fabs(vm0[Y])+fabs(vm1[Y])>temp3)
      temp3=fabs(vm0[Y])+fabs(vm1[Y]);
  }
  minvistextht=temp2;
  ad3in.minvisplinewid=temp;
  ad3in.arcscalemult=temp3*ad3ct.accuracy*0.2;  /* was .125 */

#ifndef AV
  if (ad3in.genfaces) {
    /* lose viewmat cuz we don't need it now, and point it to worldmat */
    ad_free(viewmat);
    viewmat=(double (*)[4][4])worldmat;
    ad3in.minvisplinewid=0.0;
    minvistextht=0.0;
  }
#endif

/* here was here */
  do {
    ad3in.globalvpflags=vpflags;    /* init to whatever was passed in */

    if (level==0
#ifdef AV
 && odomflip==0
#endif
                ) {
      if (ad_Odometer!=NULL) {
        holdperc=ad3in.lastperc;
        holdloc=ad_ftell(adin.dwgfilerent);
        while (holdloc>ad3in.entlisttarg && ad3in.lastperc<100) {
          ad3in.lastperc+=5;
          ad3in.entlisttarg+=ad3in.entlisttargstep;
        }
        if (ad3in.lastperc!=holdperc) (*ad_Odometer)(ad3in.lastperc);
      }
    }
#ifdef AV
    odomflip--;
    if (odomflip<0) odomflip=4;
#endif

    if (!(returnval=readentityav())) continue;

    if (ad3in.enginespace==MODELSPACE && (adenhd.paperspace || ad3in.overridepaperspace)) {
     if (adenhd.enttype!=19) continue;  /* skip this ent */
      else {   /* skip polyline -- need to do this here */
        if ((ad3in.vert=(struct vertexstru *)ad_malloc(sizeof(*ad3in.vert)))==NULL)
          (*ad_Closegraph)(ad3in.mallocmsg);
        do {
          readentityav();
        } while (adenhd.enttype!=17);  /* end sequence */
        ad_free(ad3in.vert);
        continue;
      }
    }

    if (adenhd.paperspace && ad3in.ignorepspaceents) continue;  /* for xrefs -- don't import pspace ents */
    /* set ad3in.insentlayer if this is an insert or asso dim */
    if (adenhd.enttype==14 || adenhd.enttype==23) {
      holdinsentlayer=ad3in.insentlayer;
      ad3in.insentlayer=adenhd.layerindex;
    }

    adenhd.layerindex=newlayno(adenhd.layerindex);  /* map to the current actual index */

/* per osiris, change linetype if appropriate */

    if (adenhd.entlinetype==ad3in.byblockltpval)
      adenhd.entlinetype=byblockltp;

    if (adenhd.entlinetype==ad3in.bylayerltpval) /* bylayer */
      adenhd.entlinetype=lay[adenhd.layerindex]->laylinetype;
    adenhd.entlinetype=newltpno(adenhd.entlinetype);  /* same, for linetype */

    /* if legit, not a pointer, not erased, and not a start or end block and not frozen */
    if (adenhd.enttype<25 && returnval==1 && adenhd.enttype!=18 && !adenhd.erasedflag && (adenhd.enttype==12 || adenhd.enttype==13 || !(lay[adenhd.layerindex]->layflag & 1))) {

/* set vpflags for this layer */
      ad3in.globalvpflags|=lay[adenhd.layerindex]->vpfrozflags;

/* set the entity color */
      if ((adin.inblockdefrflag && adenhd.layerindex==0 && adenhd.entcolor==0) || adenhd.entcolor==BYBLOCK)
        thisentcolor=byblockcolor;
      else if (adenhd.entcolor==0)  /* bylayer */
        thisentcolor=lay[adenhd.layerindex]->laycolor;
      else thisentcolor=adenhd.entcolor;

/*
printf("level %d: adenhd.enttype is %d, length is %d, color is %d \n",level,adenhd.enttype,adin.entlengthr,thisentcolor);
if (adenhd.enttype==14) printf("Insert of %d: %s\n",aden.insert.blockno,ad3in.blk[newblkno(aden.insert.blockno)]->blkname);
*/

      if ((short)thisentcolor>=0) {
        (*ad_PenColor)(ad3ct.colormap[thisentcolor]);
      }

/* set the entity linetype */
      if ((adin.inblockdefrflag && adenhd.layerindex==0 && adenhd.entlinetype==ad3in.bylayerltpval)
         || adenhd.entlinetype==ad3in.byblockltpval) {
        ad3in.thisentlinetype=byblockltp;
      }
      else if (adenhd.entlinetype==ad3in.bylayerltpval) {
        ad3in.thisentlinetype=lay[adenhd.layerindex]->laylinetype;
      }
      else {
        ad3in.thisentlinetype=adenhd.entlinetype;
      }

if (lay[adenhd.layerindex]->laycolor<=0              /* layer ent is on is off */
   && !((adenhd.enttype>=12 && adenhd.enttype<=14) || adenhd.enttype==19)) continue;
/* don't continue on start blk, end blk, insert, or polyline */

      if (adenhd.enttype==1) {       /* line */
        DrawSeg3d(aden.line.pt0,aden.line.pt1,viewmat);
      }
      else if (adenhd.enttype==21) {       /* 3d line */
        DrawSeg3d(aden.line3d.pt0,aden.line3d.pt1,viewmat);
      }
      else if (adenhd.enttype==2) {  /* point */
        if (adhd.pdmode==1) continue;  /* no draw */
        if (!(adhd.pdmode & 1))
        DrawSeg3d(aden.point.pt0,aden.point.pt0,viewmat);

        if (adhd.pdmode!=0 && adhd.pdsize>0.0) {
          ptpt0[2]=ptpt1[2]=0.0;
          truncpdmode=adhd.pdmode & 7;
          if (truncpdmode == 2) {  /* a cross through it */
            ptpt0[0]=ptpt1[0]=aden.point.pt0[0];
            ptpt0[1]=aden.point.pt0[1]-adhd.pdsize;
            ptpt1[1]=aden.point.pt0[1]+adhd.pdsize;
            RotDrawSeg3d(ptpt0,ptpt1,viewmat,aden.point.ucsxangle,aden.point.pt0);
            ptpt0[1]=ptpt1[1]=aden.point.pt0[1];
            ptpt0[0]=aden.point.pt0[0]-adhd.pdsize;
            ptpt1[0]=aden.point.pt0[0]+adhd.pdsize;
            RotDrawSeg3d(ptpt0,ptpt1,viewmat,aden.point.ucsxangle,aden.point.pt0);
          }
          if (truncpdmode == 3) {  /* an x through it */
            ptpt0[0]=aden.point.pt0[0]-0.707107*adhd.pdsize;
            ptpt1[0]=aden.point.pt0[0]+0.707107*adhd.pdsize;
            ptpt0[1]=aden.point.pt0[1]-0.707107*adhd.pdsize;
            ptpt1[1]=aden.point.pt0[1]+0.707107*adhd.pdsize;
            RotDrawSeg3d(ptpt0,ptpt1,viewmat,aden.point.ucsxangle,aden.point.pt0);
            ptpt0[1]=aden.point.pt0[1]+0.707107*adhd.pdsize;
            ptpt1[1]=aden.point.pt0[1]-0.707107*adhd.pdsize;
            RotDrawSeg3d(ptpt0,ptpt1,viewmat,aden.point.ucsxangle,aden.point.pt0);
          }
          if (truncpdmode == 4) {  /* vertical line up */
            ptpt0[0]=aden.point.pt0[0];
            ptpt1[0]=aden.point.pt0[0];
            ptpt0[1]=aden.point.pt0[1];
            ptpt1[1]=aden.point.pt0[1]+0.5*adhd.pdsize;
            RotDrawSeg3d(ptpt0,ptpt1,viewmat,aden.point.ucsxangle,aden.point.pt0);
          }
          if (adhd.pdmode & 32)  /* circle around it */
            DrawArc(aden.point.pt0,0.0,2.0*PI,0.5*adhd.pdsize,viewmat);
          if (adhd.pdmode & 64) {  /* square around it */
            ptpt0[0]=aden.point.pt0[0]-0.5*adhd.pdsize;
            ptpt1[0]=aden.point.pt0[0]+0.5*adhd.pdsize;
            ptpt0[1]=ptpt1[1]=aden.point.pt0[1]+0.5*adhd.pdsize;
            RotDrawSeg3d(ptpt0,ptpt1,viewmat,aden.point.ucsxangle,aden.point.pt0);
			ptpt0[0]=ptpt1[0];
			ptpt0[1]-=adhd.pdsize;
            RotDrawSeg3d(ptpt1,ptpt0,viewmat,aden.point.ucsxangle,aden.point.pt0);
			ptpt1[1]=ptpt0[1];
			ptpt1[0]-=adhd.pdsize;
            RotDrawSeg3d(ptpt0,ptpt1,viewmat,aden.point.ucsxangle,aden.point.pt0);
			ptpt0[0]=ptpt1[0];
			ptpt0[1]+=adhd.pdsize;
            RotDrawSeg3d(ptpt1,ptpt0,viewmat,aden.point.ucsxangle,aden.point.pt0);
          }
        }
      }

      else if (adenhd.enttype==3 || adenhd.enttype==8) { /* circle or arc */
        ad3in.ltloc=0;
        ad3in.amtofsegdrawn=0.0;
        if (adenhd.enttype==3) DrawArc(aden.circle.pt0,0.0,2.0*PI,aden.circle.radius,viewmat);
        else {
          if (aden.arc.endang<aden.arc.stang) aden.arc.endang+=2.0*PI;
          DrawArc(aden.arc.pt0,aden.arc.stang,aden.arc.endang,aden.arc.radius,viewmat);
        }
      } /* end of arc and circle */

      else if (adenhd.enttype==4) {    /* shape */
        memcpy(blkmat,worldmat,16*sizeof(double));
        if (adenhd.extrusioninfovalid) {   /* get non parallel extrusion matrix */
          geta4by4(adenhd.extrusion,blkmat);
          matmult(blkmat,worldmat,blkmat);
        }
        translatematrix(aden.shape.pt0,blkmat);
        if (aden.shape.rotang!=0.0) rotatematrixz(aden.shape.rotang,blkmat);
        if (aden.shape.oblique!=0.0) {
          if (aden.shape.oblique>PI2) aden.shape.oblique-=2*PI;
          for (i=0; i<4; i++) blkmat[1][i]+=blkmat[0][i]*tan(aden.shape.oblique);
        }
        scalematrix(aden.shape.widthfactor*aden.shape.scale,aden.shape.scale,1.0,blkmat);

        shmat=(double (*)[4][4])ad_malloc(ad3in.numvptmats*sizeof(*shmat));
        if (shmat==NULL) {
          clearunusedcacheitems();
          shmat=(double (*)[4][4])ad_malloc(ad3in.numvptmats*sizeof(*shmat));
        }
        if (shmat==NULL) continue;

        if (ad3in.enginespace==MODELSPACE || adenhd.paperspace || ad3in.overridepaperspace)
          { j=0; k=1; }
        else /* a modelspace entity in paperspace */
          { j=1; k=ad3in.numvptmats; }

        for (i=j; i<k; i++) {
          matmult(blkmat,ad3in.viewplanetransmat[i],shmat[i]);
        }

#ifndef AV
if (ad3in.genfaces) { ad_free(shmat); shmat=(double (*)[4][4])blkmat; }
#endif
        DrawSlowText(&aden.shape.whichshape,1,&aden.shape.pt0[X],&aden.shape.pt0[Y],aden.shape.shapefileno,DODRAW+1,shmat,NULL);
#ifndef AV
if (!ad3in.genfaces)
#endif
        ad_free(shmat);
      }

      /* text */
      else if (adenhd.enttype==7) {
        DrawGrText(aden.text.pt0,(unsigned char *)aden.text.textstr,strlen(aden.text.textstr),&aden.text.tdata,worldmat,viewmat,minvistextht); /*pick up the globals */
      }

      /* polyline ent */
      else if (adenhd.enttype==19) {
        ad3in.ltloc=0;
        ad3in.amtofsegdrawn=0.0;
        plinespace=adenhd.paperspace;
        if (lay[adenhd.layerindex]->laycolor < 0) {  /* off */
/* need to malloc ad3in.vert here, because readentityav will read into it  */
          if ((ad3in.vert=(struct vertexstru *)ad_malloc(sizeof(*ad3in.vert)))==NULL)
            (*ad_Closegraph)(ad3in.mallocmsg);
          do {
            readentityav();
          } while (adenhd.enttype!=17);  /* end sequence */
          ad_free(ad3in.vert);
        }
        else {
          if ((ad3in.mypoly=(struct polystru *)ad_malloc(sizeof(*ad3in.mypoly)))==NULL)
            (*ad_Closegraph)(ad3in.mallocmsg);
          ad3in.mypoly->pflag=(char)aden.pline.polyflag;
          ad3in.mypoly->stwid=aden.pline.startwidth;
          ad3in.mypoly->endwid=aden.pline.endwidth;
          ad3in.mypoly->mshm=aden.pline.meshm;
          ad3in.mypoly->mshn=aden.pline.meshn;
          ad3in.mypoly->meshmdens=aden.pline.meshmdensity;
          ad3in.mypoly->meshndens=aden.pline.meshndensity;
          ad3in.mypoly->fittyp=aden.pline.fittype;
          ad3in.mypoly->polyelev=aden.pline.z1;
          ad3in.mypoly->polycolor=thisentcolor;
          ad3in.plineextrusioninfovalid=adenhd.extrusioninfovalid;
          memcpy(ad3in.plineextrusion,adenhd.extrusion,3*sizeof(double));
          plthik=adenhd.entthickness;
          if ((short)ad3in.mypoly->polycolor>=0) {
            (*ad_PenColor)(ad3ct.colormap[ad3in.mypoly->polycolor]);
          }
          if (ad3in.mypoly->pflag & 32) ad3in.pline3dflag=1;
          else ad3in.pline3dflag=0;
          if (ad3in.mypoly->pflag & 16) DrawPolymesh(viewmat);
          else if (ad3in.mypoly->pflag & 64) {
            DrawPolyfacemesh(viewmat);
          }
        else {
          if ((ad3in.vert=(struct vertexstru *)ad_malloc(sizeof(*ad3in.vert)))==NULL ||
              (ad3in.vert1=(struct vertexstru *)ad_malloc(sizeof(*ad3in.vert1)))==NULL ||
              (ad3in.firstactualvertex=(struct vertexstru *)ad_malloc(sizeof(*ad3in.firstactualvertex)))==NULL)
            (*ad_Closegraph)(ad3in.mallocmsg);
          ad3in.vertexcount=ad3in.polylinestate=0;
          ad3in.secondactualvertex=NULL;
/* start reading vertices and processing them */
          do {
/* do the following only in AD3, not in autoview */
#ifndef AV
            readentityav();
  memcpy(ad3in.vert->pt0,aden.vertex.pt0,3*sizeof(double));
  ad3in.vert->startwidth=aden.vertex.startwidth;
  ad3in.vert->endwidth=aden.vertex.endwidth;
  ad3in.vert->bulge=aden.vertex.bulge;
  ad3in.vert->vertflag=aden.vertex.vertexflag;
  ad3in.vert->tangentdir=aden.vertex.tangentdir;
#else
#include "avpolyr.c"
#endif
            adenhd.paperspace=plinespace;
            if (adenhd.enttype==20 && !(ad3in.vert->vertflag & 16)) {
              if (fabs(ad3in.vert->bulge)<0.00005) ad3in.vert->bulge=0.0;  /* fix bug */

              if (!aden.vertex.startwidthvalid) ad3in.vert->startwidth=ad3in.mypoly->stwid;
              if (!aden.vertex.endwidthvalid)   ad3in.vert->endwidth  =ad3in.mypoly->endwid;
              if (ad3in.plineextrusioninfovalid) {
                adenhd.extrusioninfovalid=1;
                memcpy(adenhd.extrusion,ad3in.plineextrusion,3*sizeof(double));
              }
              else adenhd.extrusioninfovalid=0;
/* end of that */
              if (ad3in.vert->startwidth<ad3in.minvisplinewid) ad3in.vert->startwidth=0.0;
              if (ad3in.vert->endwidth<ad3in.minvisplinewid) ad3in.vert->endwidth=0.0;

              if (ad3in.vertexcount==0) {
                memcpy(ad3in.firstactualvertex,ad3in.vert,sizeof(*ad3in.vert));
                ad3in.firstactualvertex->bulge=0.0;
              }
              adenhd.entthickness=plthik;
              DrawPolyline(viewmat);
            }
          } while (adenhd.enttype!=17);  /* end sequence */

/* this is the clean up section after the polyline is finished */
          if (ad3in.plineextrusioninfovalid) {
            adenhd.extrusioninfovalid=1;
            memcpy(adenhd.extrusion,ad3in.plineextrusion,3*sizeof(double));
          }
          else adenhd.extrusioninfovalid=0;
          if (ad3in.mypoly->pflag & 1) { /* closed */
            if (ad3in.vert==NULL)
              if ((ad3in.vert=(struct vertexstru *)ad_malloc(sizeof(*ad3in.vert)))==NULL)
                (*ad_Closegraph)(ad3in.mallocmsg);
            adenhd.entthickness=plthik;

            memcpy(ad3in.vert,ad3in.firstactualvertex,sizeof(*ad3in.firstactualvertex));
            DrawPolyline(viewmat);
            adenhd.entthickness=plthik;
            if (ad3in.secondactualvertex!=NULL) {
              memcpy(ad3in.vert,ad3in.secondactualvertex,sizeof(*ad3in.secondactualvertex));
              DrawPolyline(viewmat);
            }

            ad_free(ad3in.vert);
            ad3in.vert=NULL;
          }
          adenhd.entthickness=plthik;
          terminatepolyline(viewmat);
/* free the associated pointers */
          if (ad3in.vert!=NULL) ad_free(ad3in.vert);
          if (ad3in.vert1!=NULL) ad_free(ad3in.vert1);
          if (ad3in.mypoly!=NULL) ad_free(ad3in.mypoly);
          if (ad3in.dvert2!=NULL) ad_free(ad3in.dvert2);
          if (ad3in.dvert1!=NULL) ad_free(ad3in.dvert1);
          if (ad3in.dvert!=NULL) ad_free(ad3in.dvert);
          ad_free(ad3in.firstactualvertex);
          if (ad3in.secondactualvertex!=NULL) ad_free(ad3in.secondactualvertex);
          ad3in.vert=ad3in.vert1=ad3in.dvert2=ad3in.dvert1=ad3in.dvert=(struct vertexstru *)NULL;
          ad3in.mypoly=NULL;
}     /* not a mesh */
        }   /* layer is not off */
        ad3in.pline3dflag=0;
      } /* polyline */

      /* insert or asso dim */
      else if (adenhd.enttype==14 || adenhd.enttype==23) {
        insdim=adenhd.enttype;
        attribzerocolor=thisentcolor;
        holdvpflags=ad3in.globalvpflags;
        if (ad3in.overridepaperspace) paperspaceinsert=0;  /* cuz it is already */
          else paperspaceinsert=adenhd.paperspace;
        if (paperspaceinsert) ad3in.overridepaperspace=1;
        holdneed=adin.needtoreadsequencestart;
        if ((bv=(struct blkstru *)ad_malloc(sizeof(*bv)))==NULL)
            (*ad_Closegraph)(ad3in.mallocmsg);

        if (adenhd.extrusioninfovalid) {
          geta4by4(adenhd.extrusion,blkmat);  /* set the extrumat */
          matmult(blkmat,worldmat,blkmat);
        }
        else memcpy(blkmat,worldmat,16*sizeof(double));

        holdloc=ad_ftell(adin.dwgfiler);
        holdfile=adin.dwgfiler;
        flaghold=adin.inblockdefrflag;
        adin.inblockdefrflag++;
        if (adin.inblockdefrflag==1) adin.dwgfiler=adin.dwgfilerblk;
                           else adin.dwgfiler=adin.dwgfilerblk2;

        if (insdim==23) {
          bv->tminsrows=bv->tminscols=1;
          bv->tcoldist=bv->trowdist=bv->trotang=0.0;
          bv->txscale=bv->tyscale=bv->tzscale=1.0;
          memcpy(bv->pt0,aden.dim.dimcloneinspt,3*sizeof(double));
          bv->tblockno=newblkno(aden.dim.dimblkno);
          ad3in.blockisxref=0;
        }
        else {
          bv->tminsrows=aden.insert.numrows; bv->tminscols=aden.insert.numcols;
          bv->tcoldist=aden.insert.coldist; bv->trowdist=aden.insert.rowdist;
          bv->trotang=aden.insert.rotang;
          bv->txscale=aden.insert.xscale;
          bv->tyscale=aden.insert.yscale;
          bv->tzscale=aden.insert.zscale;
          memcpy(bv->pt0,aden.insert.pt0,3*sizeof(double));
          bv->tblockno=newblkno(aden.insert.blockno);
          if (adct.ouracadverr>=ACAD11 && (ad3in.blk[newblkno(aden.insert.blockno)]->blkflag & 4))
            ad3in.blockisxref=1;
          else ad3in.blockisxref=0;
        }

/* Check to see if block is in cache.  If it is, don't do any of the file
   crap.  If not, see if it can be loaded into the cache.  If so, load it,
   if not, do the file crap. */
        cacheblock=incache(bv->tblockno); /* -1 if not there, otherwise index */
        if (cacheblock==-1 && insdim!=23 &&
            ad3in.blk[bv->tblockno]->blksize<16384L)
          cacheblock=putblockincache(bv->tblockno);  /* -1 if fail, otherwise index */

#ifdef CACHEDBG
printf("\nBlock: %s  size %XH\n",ad3in.blk[bv->tblockno]->blkname,ad3in.blk[bv->tblockno]->blksize);
printf("Current location in adin.dwgfiler is %lX ",ftell(adin.dwgfiler));
if (adin.dwgfiler==adin.dwgfilerent) printf("in adin.dwgfilerent\n");
if (adin.dwgfiler==adin.dwgfilerext) printf("in adin.dwgfilerext\n");
if (adin.dwgfiler==adin.dwgfilerblk) printf("in adin.dwgfilerblk\n");
if (adin.dwgfiler==adin.dwgfilerblk2) printf("in adin.dwgfilerblk2\n");
printf("Cacheblock is %d\n",cacheblock);
#endif

        holdcachereadstate=ad3in.globalreadingfromcache;
        holdcacheptr=adin.entptr;
        plwidhold=ad3in.minvisplinewid;
        arcscalehold=ad3in.arcscalemult;

        for (bv->minsrows=0; bv->minsrows<bv->tminsrows; bv->minsrows++)
          for (bv->minscols=0; bv->minscols<bv->tminscols; bv->minscols++) {
            if (cacheblock==-1) { /* not successful from cache */
              adin.blockdefoffsetr=ad3in.blk[bv->tblockno]->blkdefoffsetr;
              dwgfilerseek(adin.blkdefstartr + adin.blockdefoffsetr);
            }  /* if no cache action */
            else {
#ifdef CACHEDBG
              printf("Successful cache hit\n");
#endif
              ad3in.blockcache[cacheblock].lru=ad3in.globallru++;
            }
            /* recursive call */
            memcpy(inspt,bv->pt0,3*sizeof(double));
            if (insdim==14) {
              inspt[X]=inspt[X]+bv->minscols*bv->tcoldist*cos(bv->trotang)-bv->minsrows*bv->trowdist*sin(bv->trotang);
              inspt[Y]=inspt[Y]+bv->minscols*bv->tcoldist*sin(bv->trotang)+bv->minsrows*bv->trowdist*cos(bv->trotang);
              if (cacheblock!=-1) adin.entptr=ad3in.blockcache[cacheblock].blkdata;
            }
            DrawEntityGroup(blkmat,inspt,bv->trotang,bv->txscale,bv->tyscale,bv->tzscale,
              thisentcolor,ad3in.thisentlinetype,level+1,cacheblock,ad3in.globalvpflags);
          }
        adin.needtoreadsequencestart=holdneed;
        ad3in.insentlayer=holdinsentlayer;
        ad3in.minvisplinewid=plwidhold;
        ad3in.arcscalemult=arcscalehold;
        ad3in.globalreadingfromcache=holdcachereadstate;
        adin.entptr=holdcacheptr;
/* probably should really have an endblockdefread here (and same place in
   asso dim) but since the adin.inblockdefrflag is being stacked, I won't bother */
        adin.inblockdefrflag=flaghold;
        adin.dwgfiler=holdfile;
        ad3in.globalvpflags=holdvpflags;
/* note -- the conditional here is a BIG change */
/* added level>1 today */
        if (cacheblock==-1 && level>1) ad_fseek(adin.dwgfiler,holdloc,SEEK_SET);

        adenhd.enttype='\1';  /* avoid exiting loop */
        ad_free(bv);
        if (paperspaceinsert) ad3in.overridepaperspace=0;
        /* end of insert entity */
      }

      /* attribute definition */
      else if (adenhd.enttype==15) {
        /* don't draw it if you're in a block */
/* if it is constant, non invisible, and attribs are normal or on, draw */
        if (adin.inblockdefrflag && (aden.attdef.attflag & 2) && !(aden.attdef.attflag & 1)
          && ((adhd.attmode==1) || adhd.attmode==2))
            DrawGrText(aden.attdef.pt0,(unsigned char *)aden.attdef.defaultval,strlen((char *)aden.attdef.defaultval),&aden.attdef.tdata,worldmat,viewmat,minvistextht);
        else if (!adin.inblockdefrflag) DrawGrText(aden.attdef.pt0,(unsigned char *)aden.attdef.tag,strlen((char *)aden.attdef.tag),&aden.attdef.tdata,worldmat,viewmat,minvistextht);
      }

      /* attribute */
      else if (adenhd.enttype==16) {
/* only display attrib if attribs are on or if it is visible */
        if ((adenhd.layerindex==0 && adenhd.entcolor==0) || adenhd.entcolor==BYBLOCK) {
          thisentcolor=attribzerocolor;
          if ((short)thisentcolor>=0) (*ad_PenColor)(ad3ct.colormap[thisentcolor]);
        }

        if (adhd.attmode==2 || (adhd.attmode==1 && !(aden.attrib.attflag & 1))) {
          DrawGrText(aden.attrib.pt0,(unsigned char *)aden.attrib.attval,strlen(aden.attrib.attval),&aden.attrib.tdata,worldmat,viewmat,minvistextht);
        }
      }

      else if (adenhd.enttype==17) {  /* end sequence */
        /* no action at this time */
      }

      /* 3d face */
      else if (adenhd.enttype==22) {
#ifndef AV
        if (ad3in.genfaces) {
          adenhd.entthickness=0.0;  /* make damned sure */
          genextrudedface(aden.face3d.pt0,aden.face3d.pt1,aden.face3d.pt2,aden.face3d.pt3,viewmat);
        }
        else {
#endif
          if (!(aden.face3d.faceflag & 1)) DrawSeg3d(aden.face3d.pt0,aden.face3d.pt1,viewmat);
          if (!(aden.face3d.faceflag & 2)) DrawSeg3d(aden.face3d.pt1,aden.face3d.pt2,viewmat);
          if (!(aden.face3d.faceflag & 4)) DrawSeg3d(aden.face3d.pt2,aden.face3d.pt3,viewmat);
          if (!(aden.face3d.faceflag & 8)) DrawSeg3d(aden.face3d.pt3,aden.face3d.pt0,viewmat);
#ifndef AV
        }
#endif
      }

#ifdef NOTNEEDEDNOW
      /* associative dimension */
      else if (adenhd.enttype==23) {
/*
printf("On entry to dim:\n");
printf("Grfc is %d\n",ad3in.globalreadingfromcache);
printf("adin.entptr is %lX\n",adin.entptr);
printf("Next ent is %d\n",*adin.entptr);
if (adin.dwgfiler==adin.dwgfilerent) printf("adin.dwgfiler is adin.dwgfilerent\n");
if (adin.dwgfiler==adin.dwgfilerext) printf("adin.dwgfiler is adin.dwgfilerext\n");
if (adin.dwgfiler==adin.dwgfilerblk) printf("adin.dwgfiler is adin.dwgfilerblk\n");
if (adin.dwgfiler==adin.dwgfilerblk2) printf("adin.dwgfiler is adin.dwgfilerblk2\n");
printf("End of dimen settings\n\n");
*/
        if (ad3in.overridepaperspace) paperspaceinsert=0;  /* cuz it is already */
          else paperspaceinsert=adenhd.paperspace;
        if (paperspaceinsert) ad3in.overridepaperspace=1;
        holdloc=ad_ftell(adin.dwgfiler);
        holdfile=adin.dwgfiler;
        holdvpflags=ad3in.globalvpflags;
        flaghold=adin.inblockdefrflag;
        holdcachereadstate=ad3in.globalreadingfromcache;
        holdcacheptr=adin.entptr;
        if (!adin.inblockdefrflag) adin.dwgfiler=adin.dwgfilerblk;
                         else adin.dwgfiler=adin.dwgfilerblk2;
                                /* make this move now, even though we know */
                                /* startblockdefread will do it, because we */
                                /* need to be here if we resize the buffer */

        i=newblkno(aden.dim.dimblkno);
        /* fool Autodirect to move to correct location */
        adin.blockdefoffsetr=ad3in.blk[i]->blkdefoffsetr;
        startblockdefread();

        plwidhold=ad3in.minvisplinewid;
        arcscalehold=ad3in.arcscalemult;
/* added this section, changed the deg call to use blkmat instead
   of worldmat.  also added aden.dim.z1 parm */
        if (adenhd.extrusioninfovalid) {
          geta4by4(adenhd.extrusion,blkmat);  /* set the extrumat */
          matmult(blkmat,worldmat,blkmat);
        }
        else memcpy(blkmat,worldmat,16*sizeof(double));
        DrawEntityGroup(blkmat,aden.dim.dimcloneinspt,0.0,1.0,1.0,
                        1.0,thisentcolor,ad3in.thisentlinetype,level+1,-1,ad3in.globalvpflags);

        ad3in.insentlayer=holdinsentlayer;
        ad3in.minvisplinewid=plwidhold;
        ad3in.arcscalemult=arcscalehold;
        adin.inblockdefrflag=flaghold;
        adin.dwgfiler=holdfile;
        adin.entptr=holdcacheptr;
        ad3in.globalvpflags=holdvpflags;
        ad3in.globalreadingfromcache=holdcachereadstate;
/* this bears further investigation to see if this fseek is always
   necessary */
        if (ad3in.globalreadingfromcache==-1 && level>1) ad_fseek(adin.dwgfiler,holdloc,SEEK_SET);
/*
printf("After asso dim, grfc is %d\n",ad3in.globalreadingfromcache);
printf("adin.entptr is %lX\n",adin.entptr);
if (adin.dwgfiler==adin.dwgfilerent) printf("adin.dwgfiler is adin.dwgfilerent\n");
if (adin.dwgfiler==adin.dwgfilerext) printf("adin.dwgfiler is adin.dwgfilerext\n");
if (adin.dwgfiler==adin.dwgfilerblk) printf("adin.dwgfiler is adin.dwgfilerblk\n");
if (adin.dwgfiler==adin.dwgfilerblk2) printf("adin.dwgfiler is adin.dwgfilerblk2\n");
*/
        if (paperspaceinsert) ad3in.overridepaperspace=0;
        adenhd.enttype='\1';  /* avoid exiting loop */
      }
#endif

      /* trace/solid */
      else if (adenhd.enttype==9 || adenhd.enttype==11) {
#ifndef AV
        if (ad3in.genfaces) {
          genextrudedface(aden.trace.pt0,aden.trace.pt1,aden.trace.pt3,aden.trace.pt2,viewmat);
        }
        else {
#endif
          if (!adhd.fillmode) {
            DrawSeg3d(aden.trace.pt0,aden.trace.pt1,viewmat);
            DrawSeg3d(aden.trace.pt1,aden.trace.pt3,viewmat);
            DrawSeg3d(aden.trace.pt3,aden.trace.pt2,viewmat);
            DrawSeg3d(aden.trace.pt2,aden.trace.pt0,viewmat);
          }
          else {
            DrawFilledPoly(aden.trace.pt0,aden.trace.pt1,aden.trace.pt2,aden.trace.pt3,viewmat);
          }
#ifndef AV
        }
#endif
      }

      /* start block */
      else if (adenhd.enttype==12) {
        if (ad3in.globalreadingfromcache!=-1)
          ad3in.blockcache[ad3in.globalreadingfromcache].inuse=level;
/*
        if (ouracadverr<ACAD11 || !ad3in.blockisxref)
*/
        for (i=0; i<3; i++) aden.block.base[i] = -aden.block.base[i];
        translatematrix(aden.block.base,worldmat);

#ifndef AV
        if (ad3in.genfaces) viewmat=ad_malloc(16*sizeof(double));
#endif

        temp=temp2=1.0E+300;
        temp3=1.0E-300;
        for (i=0; i<ad3in.numvptmats; i++) {
          vm0=viewmat[i][X]; vm1=viewmat[i][Y];
          matmult(worldmat,ad3in.viewplanetransmat[i],viewmat[i]);
  /* determine the minimum text height for text to be drawn */
          minvistextht=sqrt(vm1[X]*vm1[X]+
                               vm1[Y]*vm1[Y]+
                               vm1[Z]*vm1[Z]);
          minvispliney=1.3333/minvistextht;  /* grab this while it's here */
          minvisplinex=1.333/sqrt(vm0[X]*vm0[X]+
                                  vm0[Y]*vm0[Y]+
                                  vm0[Z]*vm0[Z]);
          if (minvisplinex<minvispliney) ad3in.minvisplinewid=minvisplinex;
                                    else ad3in.minvisplinewid=minvispliney;
          ad3in.minvisplinewid*=2.0;
          minvistextht=3.0/minvistextht;
          if (minvistextht<temp) temp=minvistextht;
          if (ad3in.minvisplinewid<temp2) temp2=ad3in.minvisplinewid;




          if (fabs(vm0[X])+fabs(vm1[X])>temp3)
            temp3=fabs(vm0[X])+fabs(vm1[X]);
          if (fabs(vm0[Y])+fabs(vm1[Y])>temp3)
            temp3=fabs(vm0[Y])+fabs(vm1[Y]);
        }
        minvistextht=temp;
        ad3in.minvisplinewid=temp2;
        ad3in.arcscalemult=temp3*ad3ct.accuracy*0.13;

#ifndef AV
        if (ad3in.genfaces) {
          ad_free(viewmat);
          viewmat=(double (*)[4][4])worldmat;
        }
#endif
        if (adct.ouracadverr>=ACAD11 && ad3in.blockisxref) {
          if (ad3in.xreffile==NULL) {
            strcpy(ad3in.pathbuf,ad3ct.tempfilepath);
			strcat(ad3in.pathbuf,"AVX.TMP");
/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifndef OS_UNIX
			ad3in.xreffile=fopen(ad3in.pathbuf,"wb+");
#else
            ad3in.xreffile=fopen(ad3in.pathbuf,"w+");
#endif
          }
          fseek(ad3in.xreffile,ad3in.xrefwriteptr,SEEK_SET);
          i=strlen(aden.block.xrefpath);
          fwrite(&i,1,sizeof(short),ad3in.xreffile);
          fwrite(aden.block.xrefpath,i,sizeof(char),ad3in.xreffile);
          fwrite(worldmat,1,4*4*sizeof(double),ad3in.xreffile);
          fwrite(&byblockcolor,1,sizeof(short),ad3in.xreffile);
          fwrite(&level,1,sizeof(short),ad3in.xreffile);
          fwrite(&ad3in.overridepaperspace,1,sizeof(short),ad3in.xreffile);
          adenhd.enttype=13;  /* force exit processing of this block */
          ad3in.xrefwriteptr=ftell(ad3in.xreffile);
        }
        ad3in.blockisxref=0;
      }

      /* end block */
      else if (adenhd.enttype==13) {
        if (ad3in.globalreadingfromcache!=-1)
          ad3in.blockcache[ad3in.globalreadingfromcache].inuse=0;
      }

      else if (adenhd.enttype==24) {   /* vport entity */
        if (level!=0 || ad3in.firstvpentfound) {
          temp= aden.vpent.cen[X]+aden.vpent.width/2.0;
          temp2=temp-aden.vpent.width;
          temp3=aden.vpent.cen[Y]+aden.vpent.height/2.0;
          temp4=temp3-aden.vpent.height;
          DrawVportRect(temp2,temp4,temp,temp3,aden.vpent.cen[Z],viewmat);
        }
        if (level==0) ad3in.firstvpentfound=1;
      }
    } /* if a valid entity */
  } while (returnval==1 && adenhd.enttype!=13 /* end block */ && ad3ct.keepvectorizing);
/*
printf("Avdraw exit -- returnval is %d, adenhd.enttype is %d, ad3ct.keepvectorizing is %d\n",
  returnval,adenhd.enttype,ad3ct.keepvectorizing);
*/
#ifndef AV
  if (!ad3in.genfaces)
#endif
    ad_free(viewmat);
  return(1);
}

