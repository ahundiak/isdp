
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* avtext.c -- AUTODIRECT text handling routines */
#include "avhdr.h"
extern long shlru;
struct scorestru {
  struct scorestru *next;
  short startchar;
  short endchar;
} ;

#ifndef OLDCHDR
void DrawFastText(unsigned char *sn,short numshapes,double *xloc,double *yloc,
  short whichshpfile,short dodraw,double (*shmat)[4][4],double (*bfmat)[4][4])
#else
void DrawFastText(sn,numshapes,xloc,yloc,whichshpfile,dodraw,shmat,bfmat)
unsigned char *sn;
short numshapes;
double *xloc,*yloc;
short whichshpfile;     /* style to draw it in */
short dodraw;           /* 1 if it is actually to be drawn, 0 to get size */
double (*shmat)[4][4];
double (*bfmat)[4][4];
#endif
{
  short drawon,ignorenextcommand;
  short mult,m2;
  short count;
  struct shfilestru *sptr;
  char cmdno;
  unsigned short shapeno;
/*  double mx1,my1,mx2,my2; */
  short vertstyle;
  short shiftamt,holdw;
  short locationstackx[5],locationstacky[5];
  short stacktop;
  short drawflag;  /* set this to 1 if we're going to draw */
  short xl,xl2,yl,yl2;
  char shchar,shchar2;
  char zzz;
  double drawpt1[3],drawpt2[3];
  short shfileno;

/* z is legitimately zero in here, because it is in the trans matrix */
/* from the calling routine */
  holdw=whichshpfile;
  stacktop = -1;
  shiftamt=1;
  vertstyle=ad3in.shflag[whichshpfile] & 4;

  shfileno=sh_open(ad3in.shapeinfo[whichshpfile]);
  sptr = &ad3in.shfile[shfileno];

  if (!(sptr->flags & ACADFONT) || bfmat!=NULL) {
    DrawSlowText(sn,numshapes,xloc,yloc,holdw,dodraw,shmat,bfmat);
    return;
  }

  xl2=yl2=xl=yl=0;
for (count=0; count<numshapes; count++) {
  shapeno = *sn;
  shapeno &= 255;
  sptr->lru=shlru++;
/* adjust to 1.1 version shape file -- ensure 1.1 or later, a special char,
   AND it is a font (not just a shape file ) */
  if ((sptr->flags & FONT11) && shapeno>=127 && shapeno<=129 && sptr->minshp==0)
    shapeno+=129;

  ignorenextcommand=0;
  drawon=dodraw;                        /* if we are drawing, turn drawing on */
  sh_seeksh(shfileno,shapeno);
  while ((shchar=sh_getc(shfileno))!='\0') ;
  shchar=sh_getc(shfileno);
  while (shchar!='\0') {
    drawflag=0;

/*  printf("Xloc, *yloc is %lf,%lf  drawon is %d\n",*xloc,*yloc,drawon); */
    if (ignorenextcommand) {
      cmdno = shchar;
#ifndef OCTALONLY
      if ((cmdno & '\xF0') || cmdno=='\1' || cmdno=='\2' ||
#else
      if ((cmdno & 240) || cmdno=='\1' || cmdno=='\2' ||
#endif
        cmdno=='\5' || cmdno=='\6') shchar=sh_getc(shfileno);
      else {
        shchar=sh_getc(shfileno);
        shchar=sh_getc(shfileno);
        if (cmdno==8)
          shchar=sh_getc(shfileno);
      }
      if (shchar!=14) ignorenextcommand=0;
      else shchar=sh_getc(shfileno);  /* get command to ignore */
    }
    else {
      if (shchar=='\1') {              /* turn draw on */
        drawon=dodraw;                /* if drawing, draw */
      }
      else if (shchar=='\2') {         /* turn draw off */
        drawon=0;
      }
      else if (shchar==8) {        /* line segment */
        shchar2=sh_getc(shfileno);
        xl2=xl; yl2=yl;
        xl+=(shchar2 << shiftamt);
        shchar2=sh_getc(shfileno);
        yl+=(shchar2 << shiftamt);
        drawflag=drawon;
      }
      else if (shchar==9) {        /* multiple vertices */
        do {
          shchar  = sh_getc(shfileno);
          shchar2 = sh_getc(shfileno);
          if (shchar!='\0' || shchar2!='\0') {
            xl2=xl; yl2=yl;
            xl+=(shchar  << shiftamt);
            yl+=(shchar2 << shiftamt);
            if (drawon) {
              drawpt1[X]=(double)(xl>>1);
              drawpt1[Y]=(double)(yl>>1);
              drawpt2[X]=(double)(xl2>>1);
              drawpt2[Y]=(double)(yl2>>1);
              drawpt1[2]=drawpt2[2]=0.0;
              DrawSeg3d(drawpt1,drawpt2,shmat);
            }
          }
        } while (shchar!='\0' || shchar2!='\0');
      }
      else if (shchar==14) {
        if (!vertstyle) ignorenextcommand=1;
      }
      else if (shchar & 240) {
/* for this one, set xl2 and yl2 to the old xl and yl */
        xl2=xl; yl2=yl;
        mult=(((shchar & 240)>>4) & 15);   /* 240 is \xF0 */
        m2=mult<<shiftamt;

        zzz=(char)(shchar & 15);
        if      (zzz>=14 || zzz<=2 ) xl+=m2;
        else if (zzz>=6  && zzz<=10) xl-=m2;
        else if (zzz==3  || zzz==13) xl+=mult;
        else if (zzz==5  || zzz==11) xl-=mult;
        if      (zzz>=2  && zzz<=6 ) yl+=m2;
        else if (zzz>=10 && zzz<=14) yl-=m2;
        else if (zzz==1  || zzz==7 ) yl+=mult;
        else if (zzz==9  || zzz==15) yl-=mult;

        drawflag=drawon;
      } /* F0 case */
      else if (shchar==10) {   /* octant arc -- assume this is a circle */
                                  /* starting from octant 4 */
        shchar=sh_getc(shfileno);
        shchar=sh_getc(shfileno);       /* skip over real values */
        if (dodraw && drawon) {
          drawpt1[X]=(double)(xl>>1);
          drawpt1[Y]=(double)(yl>>1);
          drawpt2[X]=(double)((xl+2)>>1);
          drawpt2[Y]=(double)((yl+2)>>1);
          drawpt1[2]=drawpt2[2]=0.0;
          DrawSeg3d(drawpt1,drawpt2,shmat);
          drawpt1[X]=(double)((xl+4)>>1);
          drawpt1[Y]=(double)(yl>>1);
          DrawSeg3d(drawpt2,drawpt1,shmat);
          drawpt2[Y]=(double)((yl-2)>>1);
          DrawSeg3d(drawpt1,drawpt2,shmat);
          drawpt1[X]=(double)(xl>>1);
          drawpt1[Y]=(double)(yl>>1);
          DrawSeg3d(drawpt2,drawpt1,shmat);
        }
        /* xl and yl do not change */
      }
      else if (shchar=='\3') {         /* divide lengths -- only do this */
        shiftamt--;                   /* for the value 2 */
        shchar=sh_getc(shfileno);
      }
      else if (shchar=='\4') {         /* multiply lengths -- only do this */
        shiftamt++;                   /* for the value 2 */
        shchar=sh_getc(shfileno);
      }
      else if (shchar=='\5') {         /* push loc on stack */
        stacktop++;
        locationstackx[stacktop]=xl;
        locationstacky[stacktop]=yl;
      }

      else if (shchar=='\6') {         /* pop loc from stack */
        xl=locationstackx[stacktop];
        yl=locationstacky[stacktop];
        stacktop--;
      }

      shchar=sh_getc(shfileno);
    }   /* not ignore */

    if (drawflag) {
      drawpt1[X]=(double)(xl>>1);
      drawpt1[Y]=(double)(yl>>1);
      drawpt2[X]=(double)(xl2>>1);
      drawpt2[Y]=(double)(yl2>>1);
      drawpt1[2]=drawpt2[2]=0.0;
      DrawSeg3d(drawpt1,drawpt2,shmat);
    }
  }     /* while loop */
  sn++;
}
*xloc=(double)(xl>>1);
*yloc=(double)(yl>>1);
}

#ifndef OLDCHDR
void DrawSlowText(unsigned char *sn,short numshapes,double *xloc,double *yloc,
  short whichshpfile,short dodraw,double (*shmat)[4][4],double (*bfmat)[4][4])
#else
void DrawSlowText(sn,numshapes,xloc,yloc,whichshpfile,dodraw,shmat,bfmat)
unsigned char *sn;
short numshapes;
double *xloc,*yloc;
short whichshpfile;     /* style to draw it in */
short dodraw;           /* 2 for shape, 1 if it is actually to be drawn, 0 to get size */
double (*shmat)[4][4];
double (*bfmat)[4][4];
#endif
{
  short drawon,ignorenextcommand,i;
  double mult;
  short count;
  struct shfilestru *sptr;
  char cmdno,*cptr,xsubshp;
  unsigned short shapeno;
  short vertstyle;
  double multamtx,multamty,mul2;
  double locationstackx[5],locationstacky[5];
  short stacktop;
  short drawflag;  /* set this to 1 if we're going to draw */
/*  double xl,xl2,yl,yl2; */
  double drawpt1[3],drawpt2[3];
  double holddrawpt1[3],holdmultx,holdmulty;
  double shapedrawstartx,shapedrawstarty;
  char shchar,shchar2;
  long shapefileholdloc;
  char zzz;
  double rstang,rendang,arcrad,temp,arccen[3];
  short stoct,endoct,arcnum,ccw,numocts,startoffset,endoffset;
  double bx1,by1,bx2,by2,bx3,by3,b1,b2,xdisp,ydisp,h,m1,m2,bulge;
  short bisvert,reversed;
  short isshape,shfileno,bffileno,filenoinuse;
  double (*matinuse)[4][4];

  drawpt1[2]=drawpt2[2]=0.0;
 if (dodraw==2) { isshape=1; dodraw=1; }
  else isshape=0;

/* z is legitimately zero in here, because it is in the trans matrix */
/* from the calling routine */
  shapefileholdloc=0L;
  stacktop = -1;
  multamtx=multamty=1.0;
  vertstyle=ad3in.shflag[whichshpfile] & 4;
  shfileno=sh_open(ad3in.shapeinfo[whichshpfile]);

  if (isshape && shfileno==0) return;  /* don't draw it in simplex */

/* see if there is an associated bigfont.  if so, load it */
  if (bfmat!=NULL) {
    cptr=ad3in.shapeinfo[whichshpfile];
    cptr=cptr+strlen(cptr)+1;  /* now pointing at style name */
    cptr=cptr+strlen(cptr)+1;  /* now pointing at bigfont file, if any */
    if (strlen(cptr)) bffileno=sh_open(cptr);
  }
  else bffileno=-1;


  drawpt2[X]=drawpt2[Y]=drawpt1[X]=drawpt1[Y]=0.0;
for (count=0; count<numshapes && *sn!=0; count++) {  /* numshapes not necessarily correct now */
  shapedrawstartx=drawpt1[X];
  shapedrawstarty=drawpt1[Y];
  shapeno = *sn;
  filenoinuse=shfileno;
  matinuse=shmat;
  if (bffileno!=-1 && bffileno!=0) {  /* 0 if not found */
    for (i=0; i<(short)ad3in.shfile[bffileno].bfnumranges; i++) {
      if (shapeno>=ad3in.shfile[bffileno].bfrange[i][0]
        && shapeno <= ad3in.shfile[bffileno].bfrange[i][1])
        break;
    }
    if (i<(short)ad3in.shfile[bffileno].bfnumranges) {
      sn++;
      shapeno<<=8;
      shapeno |= (*sn & 255);
      filenoinuse=bffileno;
      matinuse=bfmat;
    }
    else shapeno &= 255;
  }
  else shapeno &= 255;
  sptr = &ad3in.shfile[filenoinuse];
  sptr->lru=shlru++;
/* adjust to 1.1 version shape file -- ensure 1.1 or later, a special char,
   AND it is a font (not just a shape file ) */
  if ((sptr->flags & FONT11) && shapeno>=127 && shapeno<=129 && sptr->minshp==0) shapeno+=129;

  ignorenextcommand=0;
  drawon=dodraw;                        /* if we are drawing, turn drawing on */
  sh_seeksh(filenoinuse,shapeno);
  while ((shchar=sh_getc(filenoinuse))!='\0') ; /* skip shape name */
  shchar=sh_getc(filenoinuse);

  while (shchar!='\0') {
    drawflag=0;
/*
  printf("Xloc, *yloc is %lf,%lf  drawon is %d\n",*xloc,*yloc,drawon);
  printf("Command %2XH ",(shchar) & 255);
*/
    if (ignorenextcommand) {
      cmdno = shchar;
      if (cmdno & 240 || cmdno=='\1' || cmdno=='\2' ||
        cmdno=='\5' || cmdno=='\6') shchar=sh_getc(filenoinuse);
      else {
        shchar=sh_getc(filenoinuse);
        shchar=sh_getc(filenoinuse);
        if (cmdno==8) shchar=sh_getc(filenoinuse);
      }
      if (shchar!=14) ignorenextcommand=0;
      else shchar=sh_getc(filenoinuse);  /* get command to ignore */
    }
    else {
      if (shchar=='\1') {              /* turn draw on */
        drawon=dodraw;                /* if drawing, draw */
      }
      else if (shchar=='\2') {         /* turn draw off */
        drawon=0;
      }
      else if (shchar=='\7') {         /* draw subshape */
        shapeno = sh_getc(filenoinuse);
        xsubshp=0;
        if (ad3in.shfile[filenoinuse].flags & BIGFONT10) {
          if (shapeno==0) {   /* extended bigfont */
			shapeno=sh_getc(filenoinuse);
            xsubshp=1;            /* mark extended bigfont */
          }
          for (i=0; i<(short)ad3in.shfile[filenoinuse].bfnumranges; i++)
            if (shapeno>=ad3in.shfile[filenoinuse].bfrange[i][0]
              && shapeno <= ad3in.shfile[filenoinuse].bfrange[i][1])
              break;
          if (i<(short)ad3in.shfile[filenoinuse].bfnumranges) {
            shapeno<<=8;
            shapeno |= (sh_getc(filenoinuse) & 255);
            if (xsubshp) {
              memcpy(holddrawpt1,drawpt1,3*sizeof(double));
              holdmultx=multamtx;
              holdmulty=multamty;
              drawpt1[X]=shapedrawstartx+(double)(char)sh_getc(filenoinuse);
              drawpt1[Y]=shapedrawstarty+(double)(char)sh_getc(filenoinuse);
              multamtx=((double)(char)sh_getc(filenoinuse))/ad3in.shfile[filenoinuse].bfwidth;
              multamty=((double)(char)sh_getc(filenoinuse))/ad3in.shfile[filenoinuse].bfheight;
            }
          }
          else shapeno &= 255;
        }
        else shapeno &= 255;
        shapefileholdloc=sh_tell(filenoinuse);  /* return to this point */
        sh_seeksh(filenoinuse,shapeno);
        while ((shchar=sh_getc(filenoinuse))!='\0') ;   /* skip shape name */
      }
      else if (shchar==8) {        /* line segment */
        drawpt2[X]=drawpt1[X]; drawpt2[Y]=drawpt1[Y];
        drawpt1[X]+=(((double)(char)sh_getc(filenoinuse))*multamtx);
        drawpt1[Y]+=(((double)(char)sh_getc(filenoinuse))*multamty);
        drawflag=drawon;
      }
      else if (shchar==9) {        /* multiple vertices */
        shchar  = sh_getc(filenoinuse);
        shchar2 = sh_getc(filenoinuse);
        while (shchar!='\0' || shchar2!='\0') {
          drawpt2[X]=drawpt1[X]; drawpt2[Y]=drawpt1[Y];
          drawpt1[X]+=(shchar  * multamtx);
          drawpt1[Y]+=(shchar2 * multamty);
          if (drawon) DrawSeg3d(drawpt1,drawpt2,matinuse);
          shchar  = sh_getc(filenoinuse);
          shchar2 = sh_getc(filenoinuse);
        }
      }
      else if (shchar==14) {
        if (!vertstyle) ignorenextcommand=1;
      }
      else if (shchar & 240) {
/* for this one, set drawpt2[X] and drawpt2[Y] to the old drawpt1[X] and yl */
        drawpt2[X]=drawpt1[X]; drawpt2[Y]=drawpt1[Y];
        mult=(((shchar & 240)>>4) & 15);

        zzz=(char)(shchar & 15);
        if      (zzz>=14 || zzz<=2 ) drawpt1[X]+=mult*multamtx;
        else if (zzz>=6  && zzz<=10) drawpt1[X]-=mult*multamtx;
        else if (zzz==3  || zzz==13) drawpt1[X]+=mult/2.0*multamtx;
        else if (zzz==5  || zzz==11) drawpt1[X]-=mult/2.0*multamtx;
        if      (zzz>=2  && zzz<=6 ) drawpt1[Y]+=mult*multamty;
        else if (zzz>=10 && zzz<=14) drawpt1[Y]-=mult*multamty;
        else if (zzz==1  || zzz==7 ) drawpt1[Y]+=mult/2.0*multamty;
        else if (zzz==9  || zzz==15) drawpt1[Y]-=mult/2.0*multamty;

        drawflag=drawon;
      } /* F0 case */
/* start here */
      else if (shchar=='\3') {         /* divide lengths */
        mul2 = (double)(char)sh_getc(filenoinuse);
        multamtx/=mul2;
		multamty/=mul2;
      }
      else if (shchar=='\4') {         /* multiply lengths */
        mul2 = (double)(char)sh_getc(filenoinuse);
        multamtx *= mul2;
        multamty *= mul2;
      }
      else if (shchar=='\5') {         /* push loc on stack */
        stacktop++;
        locationstackx[stacktop]=drawpt1[X];
        locationstacky[stacktop]=drawpt1[Y];
      }

      else if (shchar=='\6') {         /* pop loc from stack */
        drawpt1[X]=locationstackx[stacktop];
        drawpt1[Y]=locationstacky[stacktop];
        stacktop--;
      }
      else if (shchar==10 || shchar==11) {       /* octant arc */
        if (shchar==11) {
/* I'm not 100% sure why the (double) is present in the next line . . . I
   added the (short) to eliminate some MSC warning errors */
          startoffset=(short)(double)(char)sh_getc(filenoinuse);
          endoffset  =(short)(double)(char)sh_getc(filenoinuse);
          startoffset &= 255;
          endoffset &= 255;
          arcrad=(double)((char)sh_getc(filenoinuse));
          arcrad=arcrad*256.0+((double)(char)sh_getc(filenoinuse));
        }
        else {
          startoffset=endoffset=0;
          arcrad=(double)((char)sh_getc(filenoinuse));
        }
        arcnum = sh_getc(filenoinuse);
        if (arcnum>=128) arcnum-=256;
        if (arcnum<0) {
          ccw=0;
          arcnum &= 127;
        }
        else ccw=1;
        stoct=(arcnum>>4) & 15;
        numocts=arcnum & 15;
        if (numocts==0) numocts=8;
        if (endoffset>0)
          numocts--;      /* really debatable */
/* was - for ccw, + for non */

        if (ccw) {
          endoct=stoct+numocts;
          if (endoct>=8) endoct-=8;
          rstang =PI/4.0*(stoct +((double)startoffset)/256.0);
          rendang=PI/4.0*(endoct+((double)endoffset  )/256.0);
        }
        else {
          endoct=stoct-numocts;
          if (endoct<0) endoct+=8;
          rstang =PI/4.0*(stoct -((double)startoffset)/256.0);
          rendang=PI/4.0*(endoct-((double)endoffset  )/256.0);
        }
        arccen[X]=drawpt1[X]-multamtx*cos(rstang)*arcrad;
        arccen[Y]=drawpt1[Y]-multamty*sin(rstang)*arcrad;
        arccen[Z]=0.0;
  /* make it ccw if it isn't now */
        reversed=0;
        if (!ccw) {
          temp=rendang; rendang=rstang; rstang=temp;
          reversed=1;
        }
        if (rendang<=rstang) rendang+=2.0*PI;

/* have to assume this multamtx, because we have no better assumption now */
        if (drawon) DrawArc(arccen,rstang,rendang,arcrad*multamtx,matinuse);
        /* get end point of the arc */
        if (reversed) rendang=rstang;
        drawpt1[X]=cos(rendang)*multamtx*arcrad+arccen[X];
        drawpt1[Y]=sin(rendang)*multamtx*arcrad+arccen[Y];
      }
      else if (shchar==12 || shchar==13) {       /* bulged arc */
        cmdno=shchar;
        do {
          xdisp=((double)(char)sh_getc(filenoinuse))*multamtx;
          ydisp=((double)(char)sh_getc(filenoinuse))*multamty;
          if (xdisp!=0.0 || ydisp!=0.0) {
            bulge=(double)((char)sh_getc(filenoinuse));
            if (bulge==0.0) {  /* a straight segment */
              drawpt2[X]=drawpt1[X]; drawpt2[Y]=drawpt1[Y];
              drawpt1[X]+=(xdisp * multamtx);
              drawpt1[Y]+=(ydisp * multamty);
              if (drawon) DrawSeg3d(drawpt1,drawpt2,matinuse);
              continue;
            }
            bx1=drawpt1[X];
            bx2=bx1+xdisp;
            by1=drawpt1[Y];
            by2=by1+ydisp;
            h=(double)bulge/254.0*sqrt((bx2-bx1)*(bx2-bx1)+(by2-by1)*(by2-by1));
            if (bx2==bx1) {
              if (by2>by1) rstang=PI2;
              else rstang = -PI2;
            }
            else {
              rstang=atan((by2-by1)/(bx2-bx1));  /* reuse rstang */
              if (bx2<bx1) rstang+=PI;
            }
            rstang-=PI2;
            bx3=(bx2+bx1)/2.0+h*cos(rstang);
            by3=(by2+by1)/2.0+h*sin(rstang);   /* third point calculated */
            bisvert=0;
            if (fabs(by1-by2)<1.0E-13) bisvert=1;
            else {
              /* compute slope/intercept of perp bis from bx1 by1 to bx2 by2 */
              m1 = -(bx2-bx1)/(by2-by1);   /* point on line is midpt */
              b1=(by1+by2)/2.0-m1*(bx1+bx2)/2.0;
            }
            if (fabs(by2-by3)<1.0E-13) bisvert=2;
            else {
              /* compute slope/intercept of perp bis from bx2 by2 to bx3 by3 */
              m2 = -(bx3-bx2)/(by3-by2);   /* point on line is midpt */
              b2=(by2+by3)/2.0-m2*(bx2+bx3)/2.0;
            }
  /* need to handle other cases */
            if (!bisvert) {
              arccen[X] = -(b1-b2)/(m1-m2);
              arccen[Y]=m2*arccen[X]+b2;
            }
            else if (bisvert==1) {
              arccen[X]=(bx1+bx2)/2.0;
              arccen[Y]=m2*arccen[X]+b2;
            }
            else if (bisvert==2) {
              arccen[X]=(bx2+bx3)/2.0;
              arccen[Y]=m1*arccen[X]+b1;
            }
/* also need to check clockwise vs counterclockwise */
            if (arccen[X]!=bx1) {
              rstang =atan((by1-arccen[Y])/(bx1-arccen[X]));
              if (arccen[X]<bx1) {
                rstang+=PI;
              }
            }
            else {
              if (arccen[Y]>by1) rstang=PI/2.0;
              else rstang=1.5*PI;
            }
            if (arccen[X]!=bx2) {
              rendang =atan((by2-arccen[Y])/(bx2-arccen[X]));
              if (arccen[X]<bx2) {
                rendang+=PI;
              }
            }
            else {
              if (arccen[Y]>by2) rendang=PI/2.0;
              else rendang=1.5*PI;
            }
            arcrad=sqrt((arccen[X]-bx1)*(arccen[X]-bx1)+(arccen[Y]-by1)*(arccen[Y]-by1));
            rstang+=PI; rendang+=PI;
            if (h<0.0) {  /* reverse draw direction */
              temp=rstang; rstang=rendang; rendang=temp;
            }
            if (rstang>rendang) rendang+=2.0*PI;

            arccen[Z]=0.0;
            if (drawon) DrawArc(arccen,rstang,rendang,arcrad,matinuse);
            drawpt1[X]=bx2; drawpt1[Y]=by2;
          } /* if either disp is > 0.0 */
        } while (cmdno!=12 && (xdisp!=0.0 || ydisp!=0.0));
      } /* if 0C or 0D */
/*  getch(); */
    shchar=sh_getc(filenoinuse);
    }   /* not ignore */
    if (drawflag) {
      DrawSeg3d(drawpt1,drawpt2,matinuse);
    }
    if (shchar==0 && shapefileholdloc!=0L) {
	  sh_seek(filenoinuse,shapefileholdloc);
      shapefileholdloc=0L;
      shchar=sh_getc(filenoinuse);  /* get next command char */
      if (xsubshp) {
        memcpy(drawpt1,holddrawpt1,3*sizeof(double));
        multamtx=holdmultx;
        multamty=holdmulty;
        xsubshp=0;
      }
    }
  }     /* while loop */
  sn++;
}
*xloc=drawpt1[X];
*yloc=drawpt1[Y];
}


#ifndef OLDCHDR
void updatescoreptr(struct scorestru ***optr,short j)
#else
void updatescoreptr(optr,j)
struct scorestru ***optr;
short j;
#endif
{
  if ((**optr)!=NULL) {   /* we were already scoring */
    (**optr)->endchar=j;
    *optr=&((**optr)->next);   /* which is null until next node added */
  }
  else {
    (**optr)=(struct scorestru *)ad_malloc(sizeof(struct scorestru));
    (**optr)->next=NULL;
    (**optr)->startchar=j;
    (**optr)->endchar=30000;  /* means to the end of the string */
  }
}

#ifndef OLDCHDR
void DrawGrText(double pt0[3],unsigned char *textstr,short textstrlen,struct adtdatastru *tdata,
  double textmat[4][4],double (*segmat)[4][4],double minvistextht)
#else
void DrawGrText(pt0,textstr,textstrlen,tdata,textmat,segmat,minvistextht)
double pt0[3];
unsigned char *textstr;
short textstrlen;
struct adtdatastru *tdata;
double textmat[4][4];  /* worldmat */
double (*segmat)[4][4];   /* viewmat -- use this if just drawing a segment */
double minvistextht;
#endif
{
  double pt1[4],pt2[4];  /* draw points */
  double nonparmat[4][4];
/*  double junkmat[4][4]; */
  register short i;
  short whichshpfile,bfshpfile;
  short symval;
  short j,state;
  double tw,tx1,ty1;
/*  double tx2,ty2,tx3,ty3,tx4,ty4,sinr,cosr; */
  double junk1,junk2;
  double newmat[4][4],bfnewmat[4][4],xdist;
  double (*textvpmats)[4][4],(*bfvpmats)[4][4];
  short start,end;
  double holdarcscalemult;
  char *cptr;
  short nextchartodraw;
  struct scorestru *over,*under,**optr,**uptr,*o2,*sptr;

  if (!textstr[0]) return;

  over=under=NULL;
  optr=&over; uptr=&under;

  whichshpfile=sh_open(ad3in.shapeinfo[tdata->styleno]);
/* reduce size of postscript text by a factor of 2 */
  if (strstr(ad3in.shapeinfo[tdata->styleno],".PFB")!=NULL ||
      strstr(ad3in.shapeinfo[tdata->styleno],".pfb")!=NULL)
	tdata->height /= 2.0;
  cptr=ad3in.shapeinfo[tdata->styleno];
  cptr=cptr+strlen(cptr)+1;
  cptr=cptr+strlen(cptr)+1;
  if (strlen(cptr)) bfshpfile=sh_open(cptr);
  else bfshpfile=-1;

  if (adhd.qtextmode) {    /* implement qtext */
    tw=(double)(strlen((char *)textstr))*tdata->height*tdata->widthfactor;
    /* draw a line of that length at the proper location */
    if (tdata->generationflag & '\2') tw = -tw;  /* backwards */
    tx1=pt0[X]+tw*cos(tdata->rotang);
    ty1=pt0[Y]+tw*sin(tdata->rotang);
/* MAJOR KLUDGE HERE --
   we tell DrawSeg3d that this is a type 3 entity (circle), in order
   that non-parallel ecs's of this line will be computed properly */
    adenhd.enttype=3;
    pt1[X]=tx1; pt1[Y]=ty1; pt1[Z]=pt0[Z];
    DrawSeg3d(pt0,pt1,segmat);
    if (tdata->height>=minvistextht) {  /* draw box */
      if (tdata->generationflag & '\4') tdata->height = -tdata->height;
      junk1 = -sin(tdata->rotang)*tdata->height;  /* x diff */
      junk2= cos(tdata->rotang)*tdata->height;  /* y diff */
      memcpy(pt1,pt0,3*sizeof(double));
      pt1[X]+=junk1;
      pt1[Y]+=junk2;
      DrawSeg3d( pt0,pt1,segmat);
      pt2[X]=tx1+junk1; pt2[Y]=ty1+junk2; pt2[Z]=pt0[Z];
      DrawSeg3d( pt1,pt2,segmat);
      pt1[X]=tx1; pt1[Y]=ty1; pt1[Z]=pt0[Z];
      DrawSeg3d(pt2,pt1,segmat);
    }
    return;
  }
  if (tdata->height<minvistextht) { /* if it is ridiculously small */
    tw=((double)strlen((char *)textstr))*tdata->height*tdata->widthfactor;

    if (tdata->generationflag & '\2') tw = -tw;  /* backwards */
    /* draw a line of that length at the proper location */
    pt1[X]=pt0[X]+tw*cos(tdata->rotang);
    pt1[Y]=pt0[Y]+tw*sin(tdata->rotang);
    pt1[Z]=pt0[Z];
/* MAJOR KLUDGE HERE --
   we tell DrawSeg3d that this is a type 3 entity (circle), in order
   that non-parallel ecs's of this line will be computed properly */
    adenhd.enttype=3;
    DrawSeg3d(pt0,pt1,segmat);
    return;
  }
/* at this point, we change the enttype to 7 (text) */
/* it could be attdef or attrib, but we don't wanna keep testing for those */
  adenhd.enttype=7;
  state=j=0;
  /* first modify the text string to handle the special chars */
  for (i=0; i<textstrlen; i++) {
    if (state==0) {
      if (textstr[i]=='%') state=1;
      else textstr[j++]=textstr[i];
    }
    else if (state==1) {
      if (textstr[i]=='%') state=2;
      else {
        textstr[j++]='%';
        textstr[j++]=textstr[i];
        state=0;
      }
    }
    else if (state==2) {
      if (textstr[i]=='%') {
        textstr[j++]='%';
        state=0;
      }
      else if (textstr[i]=='o' || textstr[i]=='O') {   /* draw overscore */
        updatescoreptr(&optr,j);
        state=0;
      }
      else if (textstr[i]=='u' || textstr[i]=='U') {   /* draw underscore */
        updatescoreptr(&uptr,j);
        state=0;
      }
      else if (textstr[i]=='d' || textstr[i]=='D') {
        /* draw degree symbol */
        textstr[j++]=127;
        state=0;
      }
      else if (textstr[i]=='p' || textstr[i]=='P') {
        /* draw plus/minus symbol */
        textstr[j++]=128;
        state=0;
      }
      else if (textstr[i]=='c' || textstr[i]=='C') {
        /* draw circle diameter symbol */
        textstr[j++]=129;
        state=0;
      }
      else if (textstr[i]>='0' && textstr[i]<='9') {  /* special char */
        symval=textstr[i]-'0';
        if (textstr[i+1]>='0' && textstr[i+1]<='9') {
          i++;
          symval=symval*10+textstr[i]-'0';
          if (textstr[i+1]>='0' && textstr[i+1]<='9') {
            i++;
            symval=symval*10+textstr[i]-'0';
          }
        }
        textstr[j++]=(char)symval;
        state=0;
      }  /* special char */
      else {  /* a special character that we don't understand */
/*        textstr[j++]=textstr[i]; */
        state=0;
      }
    }    /* state==2 */
  }  /* for loop */

  if (state==1) textstr[j++]='%';  /* '%' is last character */
  textstr[j]='\0';
  textstrlen=strlen((char *)textstr);

/* printf("After, text is %d: %s\n",strlen(textstr),textstr); */

  if ((tdata->generationflag & '\4') && (tdata->generationflag & '\2'))  /* ud & back */
    {
      tdata->height *= -1.0;  /* effectively does both */
    }
  else if (tdata->generationflag & '\4') {                    /* ud */
    tdata->height *= -1.0;
    tdata->widthfactor *= -1.0;  /* gets undone on mult in DrawShape */
  }
  else if (tdata->generationflag & '\2') {
    tdata->widthfactor *= -1.0;   /* back */
  }
/* now check to see if the text is on the screen, if not, do not print it */
/* text is onscreen if either all its points are inside the boundaries or */
/* the bounding lines intersect the screen boundaries */
/* calculate corners of text box */
/* corners are
   tx3,ty3     tx4,ty4
   pt0[X],pt0[Y]       tx2,ty2
*/

  junk1=junk2=0.0;
  memcpy(newmat,textmat,16*sizeof(double));
  if (adenhd.extrusioninfovalid) {   /* get non parallel extrusion matrix */
    geta4by4(adenhd.extrusion,nonparmat);
    matmult(nonparmat,newmat,newmat);
  }
  translatematrix(pt0,newmat);
  if (tdata->rotang!=0.0) rotatematrixz(tdata->rotang,newmat);
/* add shear to x for oblique angle */
  if (tdata->oblique!=0.0) {
/* new -- the following statement which is not commented out is equivalent
   to this process --
    identity(nonparmat);
    nonparmat[1][0]=tan(tdata->oblique);
    matmult(nonparmat,newmat,newmat);
*/
    if (tdata->oblique>PI2) tdata->oblique-=2*PI;
    for (i=0; i<4; i++) newmat[1][i]+=newmat[0][i]*tan(tdata->oblique);
  }

  if (bfshpfile!=-1 && bfshpfile!=0) {   /* we have a bigfont to deal with */
    memcpy(bfnewmat,newmat,16*sizeof(double));
    tw=tdata->height/ad3in.shfile[bfshpfile].bfheight;
    scalematrix(tw,tw,1.0,bfnewmat);
    bfvpmats=(double (*)[4][4])ad_malloc(ad3in.numvptmats*sizeof(*bfvpmats));
  }
  else bfvpmats=NULL;

  scalematrix(tdata->widthfactor*tdata->height/ad3in.shfile[whichshpfile].above,
    tdata->height/ad3in.shfile[whichshpfile].above,1.0,newmat);
  textvpmats=(double (*)[4][4])ad_malloc(ad3in.numvptmats*sizeof(*textvpmats));

  if (ad3in.enginespace==MODELSPACE || adenhd.paperspace || ad3in.overridepaperspace)
    { start=0; end=1; }
  else /* a modelspace entity in paperspace */
    { start=1; end=ad3in.numvptmats; }
  for (i=start; i<end; i++) {
    matmult(newmat,ad3in.viewplanetransmat[i],textvpmats[i]);
    if (bfvpmats!=NULL)
      matmult(bfnewmat,ad3in.viewplanetransmat[i],bfvpmats[i]);
  }
#ifndef AV
if (ad3in.genfaces) {
  ad_free(textvpmats);
  ad_free(bfvpmats);
  textvpmats = &newmat;
}
#endif
  holdarcscalemult=ad3in.arcscalemult;
  ad3in.arcscalemult *= fabs(tdata->height/ad3in.shfile[whichshpfile].above);

  DrawFastText(textstr,textstrlen,&junk1,&junk2,tdata->styleno,DODRAW,textvpmats,bfvpmats);

  for (i=0; i<2; i++) {
    if (i==0) {
      sptr=over;
      tw=1.2;
    }
    else {
      sptr=under;
      tw=-0.2;
    }
    if (sptr!=NULL) {
      o2=sptr;
      pt1[2]=pt2[2]=junk1=junk2=xdist=0.0;
	  nextchartodraw=0;
      while (o2!=NULL) {
        if (nextchartodraw<o2->startchar) { /* draw up to the underscore */
          DrawFastText(&textstr[nextchartodraw],o2->startchar-nextchartodraw,&junk1,&junk2,tdata->styleno,DONOTDRAW,textvpmats,bfvpmats);
        }
        xdist=pt1[0]=junk1+xdist;
        pt1[1]=pt2[1]=(double)ad3in.shfile[whichshpfile].above*tw;
        if (o2->endchar==30000) o2->endchar=textstrlen;
        if (o2->endchar>o2->startchar)
          DrawFastText(&textstr[o2->startchar],o2->endchar-o2->startchar,&junk1,&junk2,tdata->styleno,DONOTDRAW,textvpmats,bfvpmats);
        else junk1=0.0;  /* draw a dot for underscore if %%u is last char on line */
        xdist=pt2[0]=pt1[0]+junk1;
        /* heuristic -- reduce by a small amount to approximate AutoCAD's
           not drawing the score past the actual drawn part of the letter */
        if (o2->endchar!=o2->startchar)
          pt2[0]-=(pt2[0]-pt1[0])/(o2->endchar-o2->startchar)*0.25;
        DrawSeg3d(pt1,pt2,((bfvpmats!=NULL) ? bfvpmats : textvpmats));
        nextchartodraw=o2->endchar;
        sptr=o2;
        o2=o2->next;
        ad_free(sptr);
      }
    }
  }
  ad3in.arcscalemult=holdarcscalemult;
#ifndef AV
  if (!ad3in.genfaces)
#endif
    ad_free(textvpmats);
    if (bfvpmats!=NULL) ad_free(bfvpmats);
}

#ifndef OLDCHDR
double GetTextWidth(unsigned char *str,double height,double widthfac,
  short styleno,double tmat[4][4])
#else
double GetTextWidth(str,height,widthfac,styleno,tmat)
unsigned char *str;
double height,widthfac;
short styleno;
double tmat[4][4];
#endif
{
  double xl,yl;
  short whichshpfile;
  double (*mrmat)[4][4];  /* make the compiler happy */

  whichshpfile=sh_open(ad3in.shapeinfo[styleno]);

  xl=yl=0.0;
  mrmat=(double (*)[4][4])&tmat;
  DrawFastText(str,strlen((char *)str),&xl,&yl,styleno,DONOTDRAW,mrmat,NULL); /* is text */
  /* affect it by the widthfactor */
  xl *= widthfac*height/ad3in.shfile[whichshpfile].above;
  return(fabs(xl));
}
