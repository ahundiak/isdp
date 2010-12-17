
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* avdseg.c -- autoview graphics */

#include "avhdr.h"

#ifdef AV
#ifdef PROTOTYPES
  extern MoveTo(short x,short y);
  extern LineTo(short x,short y);
  extern PolyLine(short count,struct _point *points);
#else
  extern MoveTo();
  extern LineTo();
#endif
  extern short shadowypixmax,shadowypixmin;
  extern short outputto;
#define SCREEN 0
#define PRPLOT 1
#define PLOT   2
#endif

double linescale,ltdelx,ltdely,ltdelz,ltlinelen;

/* clip two points to the screen */
/* this is a translation from foley/van dam, page 148 */

#ifdef microsoftc
#pragma optimize("z",on)
#endif
#ifndef OLDCHDR
short clip(double x1,double y1,double x2,double y2)
#else
short clip(x1,y1,x2,y2)
double x1,y1,x2,y2;
#endif
{
  unsigned char outcode1,outcode2;  /* was short */
  char accept,done;  /* was short */
  double t;

/*
printf("Clipping %14.3lf,%14.3lf -- %14.3lf,%14.3lf against bounding rectangle\n",x1,y1,x2,y2);
printf("%14.3lf,%14.3lf -- %14.3lf,%14.3lf\n",ad3in.xclipmin[ad3in.whichvp],ad3in.yclipmin[ad3in.whichvp],
  ad3in.xclipmax[ad3in.whichvp],ad3in.yclipmax[ad3in.whichvp]);
*/

  if (ad_Vecfunc!=NULL) {
    ad3in.vecfunccount++;
    if (ad3in.vecfunccount==ad3ct.vecfunclimit) {
      (*ad_Vecfunc)();
      ad3in.vecfunccount=0;
    }
  }
/* ad3in.xclipmax[ad3in.whichvp],ad3in.yclipmax[ad3in.whichvp] are max pixel indices in real units, global */

  accept=done=0;
  do {
    /* set outcodes for the two points */
    outcode1=outcode2=0;
    if (x1<ad3in.xclipmin[ad3in.whichvp]) outcode1 |= 1;
    if (x2<ad3in.xclipmin[ad3in.whichvp]) outcode2 |= 1;
    if (x1>ad3in.xclipmax[ad3in.whichvp]) outcode1 |= 2;
    if (x2>ad3in.xclipmax[ad3in.whichvp]) outcode2 |= 2;
    if (y1<ad3in.yclipmin[ad3in.whichvp]) outcode1 |= 4;
    if (y2<ad3in.yclipmin[ad3in.whichvp]) outcode2 |= 4;
    if (y1>ad3in.yclipmax[ad3in.whichvp]) outcode1 |= 8;
    if (y2>ad3in.yclipmax[ad3in.whichvp]) outcode2 |= 8;

    if (outcode1 & outcode2) done=1;  /* do not accept */
    else {  /* possible accept */
      if ((outcode1 | outcode2)==0) accept=done=1;
      else {  /* subdivide line since at most one endpoint is inside */
        /* first, make sure p1 is outside the window */
        if (outcode1==0) {  /* swap p1 and p2 */
          t=x1; x1=x2; x2=t;
          t=y1; y1=y2; y2=t;
          outcode1=outcode2;  /* can safely discard outcode2 for now */
        }
        if      (outcode1 & 8) {
          x1+=(ad3in.yclipmax[ad3in.whichvp]-y1)*(x2-x1)/(y2-y1);
          y1=  ad3in.yclipmax[ad3in.whichvp];
        }
        else if (outcode1 & 4) {
          x1+=(ad3in.yclipmin[ad3in.whichvp]-y1)*(x2-x1)/(y2-y1);
          y1=  ad3in.yclipmin[ad3in.whichvp];
        }
        else if (outcode1 & 2) {
          y1+=(ad3in.xclipmax[ad3in.whichvp]-x1)*(y2-y1)/(x2-x1);
          x1=  ad3in.xclipmax[ad3in.whichvp];
        }
        else if (outcode1 & 1) {
          y1+=(ad3in.xclipmin[ad3in.whichvp]-x1)*(y2-y1)/(x2-x1);
          x1=  ad3in.xclipmin[ad3in.whichvp];
        }
      } /* end of line subdivision */
    }   /* end of possible accept */
  } while (!done);

  if (accept) {
#ifdef AV
    if (outputto==SCREEN) {
      MoveTo((short)x1,(shadowypixmax-(short)y1)+shadowypixmin);
      LineTo((short)x2,(shadowypixmax-(short)y2)+shadowypixmin);
    }
    else
#endif
    {
      (*ad_MoveTo)((short)x1,(short)y1);
      (*ad_LineTo)((short)x2,(short)y2);
    }
  }
  return(accept);
}



#ifndef OLDCHDR
double lineleninpixels(double pt0[3],double pt1[3],double (*matlist)[4][4],short whichvp)
#else
double lineleninpixels(pt0,pt1,matlist,whichvp)
double pt0[3],pt1[3],(*matlist)[4][4];
short whichvp;
#endif
{
  double deltax,deltay,deltaz;

/* translations removed -- they wash */
  deltax=pt0[X]*matlist[whichvp][0][0]+pt0[Y]*matlist[whichvp][1][0]+pt0[Z]*matlist[whichvp][2][0]
       -(pt1[X]*matlist[whichvp][0][0]+pt1[Y]*matlist[whichvp][1][0]+pt1[Z]*matlist[whichvp][2][0]);
  deltay=pt0[X]*matlist[whichvp][0][1]+pt0[Y]*matlist[whichvp][1][1]+pt0[Z]*matlist[whichvp][2][1]
       -(pt1[X]*matlist[whichvp][0][1]+pt1[Y]*matlist[whichvp][1][1]+pt1[Z]*matlist[whichvp][2][1]);
  deltaz=pt0[X]*matlist[whichvp][0][2]+pt0[Y]*matlist[whichvp][1][2]+pt0[Z]*matlist[whichvp][2][2]
       -(pt1[X]*matlist[whichvp][0][2]+pt1[Y]*matlist[whichvp][1][2]+pt1[Z]*matlist[whichvp][2][2]);
  return(sqrt(deltax*deltax+deltay*deltay+deltaz*deltaz));
}


#ifndef OLDCHDR
void drawthesegment(double pt0[3],double pt1[3],double (*matlist)[4][4],short whichvp)
#else
void drawthesegment(pt0,pt1,matlist,whichvp)
double pt0[3],pt1[3];
double (*matlist)[4][4];
short whichvp;
#endif
{
  double viewx3real,viewy3real,viewx4real,viewy4real;
  double mmx1,mmy1,mmz1,mmx2,mmy2,mmz2,t1,t2;
  double thispt[4];
  double (*mat)[4];

  ad3in.whichvp=whichvp;  /* this module's indication of the current vp */
  mat=matlist[whichvp];  /* faster? */
  if (adenhd.extrusioninfovalid && adenhd.enttype!=1 && adenhd.enttype!=21 && adenhd.enttype!=2 && adenhd.enttype!=7 && adenhd.enttype!=4 && !ad3in.pline3dflag) {
    memcpy(thispt,pt0,3*sizeof(double));
    geta4by4(adenhd.extrusion,ad3in.extrumat);  /* set the ad3in.extrumat */
    acadtrans(thispt);
  /* can't destroy the m's */
    ad3in.viewx1real=thispt[X]*mat[0][0]+thispt[Y]*mat[1][0]+thispt[Z]*mat[2][0]+mat[3][0];
    ad3in.viewy1real=thispt[X]*mat[0][1]+thispt[Y]*mat[1][1]+thispt[Z]*mat[2][1]+mat[3][1];
    memcpy(thispt,pt1,3*sizeof(double));
    acadtrans(thispt);
    ad3in.viewx2real=thispt[X]*mat[0][0]+thispt[Y]*mat[1][0]+thispt[Z]*mat[2][0]+mat[3][0];
    ad3in.viewy2real=thispt[X]*mat[0][1]+thispt[Y]*mat[1][1]+thispt[Z]*mat[2][1]+mat[3][1];
  }
  else {
    ad3in.viewx1real=pt0[X]*mat[0][0]+pt0[Y]*mat[1][0]+pt0[Z]*mat[2][0]+mat[3][0];
    ad3in.viewx2real=pt1[X]*mat[0][0]+pt1[Y]*mat[1][0]+pt1[Z]*mat[2][0]+mat[3][0];
    ad3in.viewy1real=pt0[X]*mat[0][1]+pt0[Y]*mat[1][1]+pt0[Z]*mat[2][1]+mat[3][1];
    ad3in.viewy2real=pt1[X]*mat[0][1]+pt1[Y]*mat[1][1]+pt1[Z]*mat[2][1]+mat[3][1];
  }
  clip(ad3in.viewx1real,ad3in.viewy1real,ad3in.viewx2real,ad3in.viewy2real);

  if (adenhd.entthickness!=0.0) {
    if (!adenhd.extrusioninfovalid || adenhd.enttype==7 || adenhd.enttype==4) {
      /* adenhd.enttype==7 makes later part unnec */
      t1=adenhd.entthickness*mat[2][0];
      t2=adenhd.entthickness*mat[2][1];
      viewx3real=ad3in.viewx2real+t1;
      viewy3real=ad3in.viewy2real+t2;
      viewx4real=ad3in.viewx1real+t1;
      viewy4real=ad3in.viewy1real+t2;
    }
    else if (adenhd.enttype==1 || adenhd.enttype==2 || adenhd.enttype==21) { /* line or point or 3dline */
      mmx1=pt0[X]+adenhd.entthickness*adenhd.extrusion[X];
      mmx2=pt1[X]+adenhd.entthickness*adenhd.extrusion[X];
      mmy1=pt0[Y]+adenhd.entthickness*adenhd.extrusion[Y];
      mmy2=pt1[Y]+adenhd.entthickness*adenhd.extrusion[Y];
      mmz1=pt0[Z]+adenhd.entthickness*adenhd.extrusion[Z];
      mmz2=pt1[Z]+adenhd.entthickness*adenhd.extrusion[Z];
      viewx4real=mmx1*mat[0][0]+mmy1*mat[1][0]+mmz1*mat[2][0]+mat[3][0];
      viewx3real=mmx2*mat[0][0]+mmy2*mat[1][0]+mmz2*mat[2][0]+mat[3][0];
      viewy4real=mmx1*mat[0][1]+mmy1*mat[1][1]+mmz1*mat[2][1]+mat[3][1];
      viewy3real=mmx2*mat[0][1]+mmy2*mat[1][1]+mmz2*mat[2][1]+mat[3][1];
    }
    else {  /* other entity types */
      memcpy(thispt,pt1,3*sizeof(double));
      thispt[Z]+=adenhd.entthickness;
      acadtrans(thispt);
      viewx3real=thispt[X]*mat[0][0]+thispt[Y]*mat[1][0]+thispt[Z]*mat[2][0]+mat[3][0];
      viewy3real=thispt[X]*mat[0][1]+thispt[Y]*mat[1][1]+thispt[Z]*mat[2][1]+mat[3][1];

      memcpy(thispt,pt0,3*sizeof(double));
      thispt[Z]+=adenhd.entthickness;
      acadtrans(thispt);
      viewx4real=thispt[X]*mat[0][0]+thispt[Y]*mat[1][0]+thispt[Z]*mat[2][0]+mat[3][0];
      viewy4real=thispt[X]*mat[0][1]+thispt[Y]*mat[1][1]+thispt[Z]*mat[2][1]+mat[3][1];
    }

    clip(ad3in.viewx2real,ad3in.viewy2real,viewx3real,viewy3real);
    clip(viewx3real,viewy3real,viewx4real,viewy4real);
    clip(viewx4real,viewy4real,ad3in.viewx1real,ad3in.viewy1real);
  } /* if adenhd.entthickness is not 0 */
}


#ifndef OLDCHDR
double computenextltypepoint(double pt0[3],double pt1[3],double nextm[3])
#else
double computenextltypepoint(pt0,pt1,nextm)
double pt0[3],pt1[3],nextm[3];
#endif
{
  double abssize,segsize;

  segsize=ad3in.ltp[ad3in.thisentlinetype]->patternval[ad3in.ltloc]*linescale;

  if (ad3in.amtofsegdrawn!=0.0) {  /* partial seg was drawn last time */
    if (segsize<0.0) segsize+=ad3in.amtofsegdrawn;
      else segsize-=ad3in.amtofsegdrawn;
  }

  abssize=fabs(segsize);

  if (abssize>ltlinelen) {
    abssize=ltlinelen;
    ad3in.amtofsegdrawn+=abssize;
  }
  else {
    ad3in.amtofsegdrawn=0.0;
    ad3in.ltloc++;
  }
  nextm[X]=pt1[X]=pt0[X]+abssize*ltdelx;
  nextm[Y]=pt1[Y]=pt0[Y]+abssize*ltdely;
  nextm[Z]=pt1[Z]=pt0[Z]+abssize*ltdelz;

  return(segsize);
}


#ifdef microsoftc
#pragma optimize("z",off)
#endif

/* mightn't there be some way to affect the matrix by the extru mat ONCE,
   rather than constantly calling acadtrans to translate points before
   transforming them?  I bet there is */

/* lines and points are different, and text matrix is fully computed, i.e. including
   the view translation, extrusion, etc.  So they are not extruded non parallel
   in the same way as other entities */
void DrawSeg3d(pt0,pt1,matlist)
double pt0[3],pt1[3],(*matlist)[4][4];
{
  double holdpt0[3],holdpt1[3];
  short i,start,end;
  short done,drawinglinetype;
  double nextm[3];
  double segsize;
  short drawseg;
  double mmx1,mmy1,mmz1,mmx2,mmy2,mmz2;

/*
  printf("Drawseg3d: %lf,%lf,%lf -- %lf,%lf,%lf\n",pt0[X],pt0[Y],pt0[Z],pt1[X],pt1[Y],pt1[Z]);
*/

#ifdef EVAL
  static short clipit=0;

  clipit++;
  if (clipit==5) {
    clipit=0;
    return;
  }
#endif

#ifndef AV
  if (ad3in.genfaces) {
    if (adenhd.entthickness==0.0) return;  /* no face to generate */
    if (adenhd.extrusioninfovalid && adenhd.enttype!=1 && adenhd.enttype!=21 && adenhd.enttype!=2 && adenhd.enttype!=7 && adenhd.enttype!=4 && !ad3in.pline3dflag) {
      geta4by4(adenhd.extrusion,ad3in.extrumat);  /* set the ad3in.extrumat */
      memcpy(ad3in.facept[0],pt0,3*sizeof(double));
      acadtrans(ad3in.facept[0]);

      memcpy(ad3in.facept[1],pt1,3*sizeof(double));
      acadtrans(ad3in.facept[1]);
    }
    else {
      memcpy(ad3in.facept[0],pt0,3*sizeof(double));
      memcpy(ad3in.facept[1],pt1,3*sizeof(double));
    }

/* adenhd.entthickness is not 0, tested already */
    if (!adenhd.extrusioninfovalid || adenhd.enttype==7 || adenhd.enttype==4) {
      /* adenhd.enttype==7 makes later part unnec */
      memcpy(ad3in.facept[2],ad3in.facept[1],3*sizeof(double));
      ad3in.facept[2][2]+=adenhd.entthickness;
      memcpy(ad3in.facept[3],ad3in.facept[0],3*sizeof(double));
      ad3in.facept[3][2]+=adenhd.entthickness;
    }
    else if (adenhd.enttype==1 || adenhd.enttype==2 || adenhd.enttype==21) { /* line or point or 3dline */
      mmx1=pt0[X]+adenhd.entthickness*adenhd.extrusion[X];
      mmx2=pt1[X]+adenhd.entthickness*adenhd.extrusion[X];
      mmy1=pt0[Y]+adenhd.entthickness*adenhd.extrusion[Y];
      mmy2=pt1[Y]+adenhd.entthickness*adenhd.extrusion[Y];
      mmz1=pt0[Z]+adenhd.entthickness*adenhd.extrusion[Z];
      mmz2=pt1[Z]+adenhd.entthickness*adenhd.extrusion[Z];
/* redundant */
      ad3in.facept[3][X]=mmx1; ad3in.facept[3][Y]=mmy1; ad3in.facept[3][Z]=mmz1;
      ad3in.facept[2][X]=mmx2; ad3in.facept[2][Y]=mmy2; ad3in.facept[2][Z]=mmz2;
    }
    else {  /* other entity types */
      memcpy(ad3in.facept[2],pt1,3*sizeof(double));
      ad3in.facept[2][Z]+=adenhd.entthickness;
      acadtrans(ad3in.facept[2]);

      memcpy(ad3in.facept[3],pt0,3*sizeof(double));
      ad3in.facept[3][Z]+=adenhd.entthickness;
      acadtrans(ad3in.facept[3]);
    }
    for (i=0; i<4; i++) {   /* transform to wcs */
      ad3in.facept[i][3]=1.0;
      transformpoint3d(ad3in.facept[i],matlist[X],ad3in.facept[i]);
    }
    if (ad_3dface!=NULL) ad_3dface(ad3in.facept);
    return;
  }
#endif

 if (ad3in.enginespace==MODELSPACE || adenhd.paperspace || ad3in.overridepaperspace)
    { start=0; end=1; }
  else /* a modelspace entity in a "paperspaced" drawing */
    { start=1; end=ad3in.numvptmats; }

  drawseg=1;

  if (!adhd.psltscale || end==1) {  /* end==1 -- pspace entity or modelspace dwg */
    if (ad3in.overridedolinetypes && ad3ct.dolinetypes && ad3in.thisentlinetype!=0 && ad3in.ltp[ad3in.thisentlinetype]->numltpvals!=0 &&

       (adenhd.enttype==1 || adenhd.enttype==3 || adenhd.enttype==8 || (ad3in.mypoly!=NULL && !ad3in.pline3dflag))) {
      drawinglinetype=1;
      done=0;
      memcpy(nextm,pt0,3*sizeof(double));
    /* ltlinelen is length of the segment being drawn */
    /* ltdelx,y,z are a scaled one unit step along the line */
    /* ad3in.ltloc is the index within the linetype pattern */

    /* compute length of line in pixel space */
      ltlinelen=lineleninpixels(pt0,pt1,matlist,0);
    /* line scale is -- how much is this line scaled up by the view matrix
       and ltscale */
      linescale=adhd.ltscale*ad3in.stretchamt[0];

	  if (linescale*ad3in.ltp[ad3in.thisentlinetype]->avgseglen < 2.0) {
        /* too many segments */
		drawinglinetype=0;
		done=1;
      }
      else {
        if (ltlinelen==0.0) ltdelx=ltdely=ltdelz=0.0;
        else {
          ltdelx =(pt1[X]-pt0[X])*(ltdely=ltdelz=1.0/ltlinelen);
          ltdely*=(pt1[Y]-pt0[Y]);
          ltdelz*=(pt1[Z]-pt0[Z]);
        }
        if (adenhd.enttype==1) {
          ad3in.ltloc=0; /* restart the linetype */
          ad3in.amtofsegdrawn=0.0;
        }
      }
    }
    else {
      drawinglinetype=0;
      done=1;
    }

    do {
    /* while !done */
      if (drawinglinetype) {
        if (ltlinelen<0.0) {
          done=1;
          drawseg=0;
        }
        else {
          if (ad3in.ltloc>=ad3in.ltp[ad3in.thisentlinetype]->numltpvals) ad3in.ltloc=0;
          memcpy(pt0,nextm,3*sizeof(double));

          if ((segsize=computenextltypepoint(pt0,pt1,nextm))<0.0) drawseg=0;
          else drawseg=1;

          ltlinelen-=fabs(segsize);
          if (ltlinelen==0.0 && (drawseg || segsize==0.0)) done=1;  /* force end */
        }
      } /* if drawinglinetype */

      if (drawseg) for (i=start; i<end; i++) {
     /* skip frozen and turned-off-by-us viewports */
        if ((ad3in.globalvpflags & (1<<i)) || !(ad3in.vpdrawflags & (1<<i))) continue;

        drawthesegment(pt0,pt1,matlist,i);
      } /* for i */
    } while (!done);
  } /* if psltscale is 0 */

  else {  /* psltscale is 1 */
    memcpy(holdpt0,pt0,3*sizeof(double));
	memcpy(holdpt1,pt1,3*sizeof(double));
	if (ad3in.overridedolinetypes && ad3ct.dolinetypes && ad3in.thisentlinetype!=0 && ad3in.ltp[ad3in.thisentlinetype]->numltpvals!=0 &&
       (adenhd.enttype==1 || adenhd.enttype==3 || adenhd.enttype==8 || (ad3in.mypoly!=NULL && !ad3in.pline3dflag))) {
      drawinglinetype=1;
      done=0;
    }
    else {
      drawinglinetype=0;
      done=1;
    }

	for (i=start; i<end; i++) {  /* draw the segment in each vport */
	  /* skip frozen and turned-off-by-us viewports */
      if ((ad3in.globalvpflags & (1<<i)) || !(ad3in.vpdrawflags & (1<<i))) continue;

      if (drawinglinetype) done=0;
      memcpy(pt0,holdpt0,3*sizeof(double));
	  memcpy(pt1,holdpt1,3*sizeof(double));

	  drawseg=1;
      if (drawinglinetype) {
	  	memcpy(nextm,pt0,3*sizeof(double));
      /* ltlinelen is length of the segment being drawn in pixel units */
      /* ltdelx,y,z are a scaled one unit step along the line */
      /* ad3in.ltloc is the index within the linetype pattern */

      /* compute length of line in pixel space */
        ltlinelen=lineleninpixels(pt0,pt1,matlist,i);
      /* line scale is -- how much is this line scaled up by the view matrix */

/* this is the tricky part -- we scale to the PAPERSPACE viewport */

        linescale=adhd.ltscale*ad3in.stretchamt[0];

	    if (linescale*ad3in.ltp[ad3in.thisentlinetype]->avgseglen < 2.0) {
          /* too many segments */
		  drawinglinetype=0;
		  done=1;
        }
		else {
          if (ltlinelen==0.0) ltdelx=ltdely=ltdelz=0.0;
          else {
            ltdelx =(pt1[X]-pt0[X])*(ltdely=ltdelz=1.0/ltlinelen);
            ltdely*=(pt1[Y]-pt0[Y]);
            ltdelz*=(pt1[Z]-pt0[Z]);
          }
          if (adenhd.enttype==1) {
            ad3in.ltloc=0; /* restart the linetype */
            ad3in.amtofsegdrawn=0.0;
          }
        }
	  }

      do {
      /* while !done */
        if (drawinglinetype) {
          if (ltlinelen<0.0) {
            done=1;
            drawseg=0;
          }
          else {
            if (ad3in.ltloc>=ad3in.ltp[ad3in.thisentlinetype]->numltpvals) ad3in.ltloc=0;
            memcpy(pt0,nextm,3*sizeof(double));

            if ((segsize=computenextltypepoint(pt0,pt1,nextm))<0.0) drawseg=0;
            else drawseg=1;

            ltlinelen-=fabs(segsize);
            if (ltlinelen==0.0 && (drawseg || segsize==0.0)) done=1;  /* force end */
          }
        } /* if drawinglinetype */

        if (drawseg) drawthesegment(pt0,pt1,matlist,i);

      } while (!done);
    } /* for i */
  }
}

#ifndef AV
#ifndef OLDCHDR
void genextrudedface(double pt0[3],double pt1[3],double pt2[3],double pt3[3],double (*matlist)[4][4])
#else
void genextrudedface(pt0,pt1,pt2,pt3,matlist)
double pt0[3],pt1[3],pt2[3],pt3[3],(*matlist)[4][4];
#endif
{
  short i;

  memcpy(ad3in.facept[0],pt0,3*sizeof(double));
  memcpy(ad3in.facept[1],pt1,3*sizeof(double));
  memcpy(ad3in.facept[2],pt2,3*sizeof(double));
  memcpy(ad3in.facept[3],pt3,3*sizeof(double));
  for (i=0; i<4; i++) {
    ad3in.facept[i][3]=1.0;
    if (adenhd.extrusioninfovalid && adenhd.enttype!=1 && adenhd.enttype!=21 && adenhd.enttype!=2 && adenhd.enttype!=7 && adenhd.enttype!=4 && !ad3in.pline3dflag) {
      geta4by4(adenhd.extrusion,ad3in.extrumat);  /* set the ad3in.extrumat */
      acadtrans(ad3in.facept[i]);
    }
    transformpoint3d(ad3in.facept[i],matlist[0],ad3in.facept[i]);
  }
  if (ad_3dface!=NULL) ad_3dface(ad3in.facept);  /* basic face, bottom if extruded */
  if (adenhd.entthickness!=0.0) {
/* these drawseg3d's will cause the extruded face for each segment */
/* of the trace/solid to be drawn.  We capture the top and emit at the end */
    DrawSeg3d(pt0,pt1,matlist);
    memcpy(ad3in.facepthold[0],ad3in.facept[3],3*sizeof(double));
    memcpy(ad3in.facepthold[1],ad3in.facept[2],3*sizeof(double));
    DrawSeg3d(pt1,pt2,matlist);
    DrawSeg3d(pt2,pt3,matlist);
    memcpy(ad3in.facepthold[3],ad3in.facept[2],3*sizeof(double));
    memcpy(ad3in.facepthold[2],ad3in.facept[3],3*sizeof(double));
    DrawSeg3d(pt3,pt0,matlist);
    if (ad_3dface!=NULL) ad_3dface(ad3in.facepthold);  /* top of figure */
  }  /* if extruded */
}
#endif

