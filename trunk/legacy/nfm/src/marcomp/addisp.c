
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* addisp.c -- Autodirect 3 display program */
/* comment in one of the following to set microsoft or turbo c */
/* comment in both MICROSOFT and METAWARE for the METAWARE example
   using MS graphics */
#define SUFFIX
#define PROTOTYPES

#ifdef PROTOTYPES
#define _(a) a
#endif

/*
#define TURBO 1
#define METAWARE 1
#define MICROSOFT 1
#define ZORTECH 1
*/

#ifdef WATCOM
#define MICROSOFT 1
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#ifdef MICROSOFT
  #include <graph.h>
  #include <conio.h>
#endif

#ifdef TURBO
  #include <graphics.h>
  #define _lineto lineto
  #define _moveto moveto
  #define _setcolor setcolor
  #include "alloc.h"
#endif

#ifdef ZORTECH
  #include <fg.h>
  fg_color_t ztcolor;
  fg_line_t ztline;
  #define _setcolor ztsetcolor
  #define _moveto   ztmoveto
  #define _lineto   ztlineto
#endif

/* changed path of include file - SSRS - 25/11/93 */
/*#include "\p\ad11\autodir.h"*/
#include "autodir.h"
/* changed path of include file - SSRS - 25/11/93 */
/*#include "\p\ad11\adrproto.h"*/
#include "adrproto.h"
#include "avengpro.h"

struct layerstru {
  char layname[41];
  unsigned char layflag;
  short laycolor;
  unsigned short laylinetype,origlayno;
  unsigned short vpfrozflags;
} ;

extern struct layerstru **lay;

short maxxpixel,maxypixel;

/* Function Prototypes */
void setcolormap(void);
void PaintPoly(short num,polyHead *head,struct _point *pt);
void closegraphics(void);
void usagemessage(void);
void initializegraphics(void);
void clearthescreen(void);

#ifdef ZORTECH
void ztsetcolor(short color)
{
  ztcolor=color;
}

void ztmoveto(short x,short y)
{
  ztline[FG_X1]=x;
  ztline[FG_Y1]=maxypixel-y;  /* flip it over again, flash graphics has */
}                             /* origin in lower left */

void ztlineto(short x,short y)
{
  ztline[FG_X2]=x;
  ztline[FG_Y2]=maxypixel-y;  /* same as moveto -- reflip */
  fg_drawline(ztcolor,FG_MODE_SET,~0,
    FG_LINE_SOLID,ztline);
  ztline[FG_X1]=ztline[FG_X2];
  ztline[FG_Y1]=ztline[FG_Y2];
}
#endif

void setcolormap()
/* establish color map values.  AD3 will return the mapped color to PenColor,
   e.g. if the AutoCAD color is 7, and colormap[7] is 15, AD3 will return 15
*/
{
  short i;

  for (i=15; i<256; i++) ad3ct.colormap[i]=8;
  ad3ct.colormap[1]=12;   /* red */
  ad3ct.colormap[2]=14;   /* yellow */
  ad3ct.colormap[3]=10;   /* green */
  ad3ct.colormap[4]=11;   /* cyan */
  ad3ct.colormap[5]=9;    /* blue */
  ad3ct.colormap[6]=13;   /* magenta */
  ad3ct.colormap[7]=15;   /* white */
  ad3ct.colormap[8]=8;    /* gray */
  ad3ct.colormap[9]=4;    /* dk red */
  ad3ct.colormap[10]=6;   /* dk yel */
  ad3ct.colormap[11]=2;   /* dk gr */
  ad3ct.colormap[12]=3;   /* dk cy */
  ad3ct.colormap[13]=1;   /* dk blu */
  ad3ct.colormap[14]=5;   /* dk mag */
}

void PenColor(short color)
{
  _setcolor(color);
}

void MoveTo(short x,short y)
/* moveto and line to invert the y value, because both Microsoft and Turbo
   view the screen y origin as being in the upper left, not lower left */
{
  _moveto(x,maxypixel-y);
}

void LineTo(short x,short y)
{
  _lineto(x,maxypixel-y);
}


void PaintPoly(short num,polyHead *head,struct _point *pt)
/* Draw a polygon.  Num, which would be the number of polygons to be drawn,
   is always 1 for time being.  Pt is an array of points through which to
   draw the polygon, head->polyBgn is the index of the first point in
   the polygon, and head->polyEnd is the index of the last */
/* note -- this routine does not fill the polygon, it just outlines it.  You
   would normally fill this polygon if FILLMODE is 1 */
{
  short i;

  _moveto(pt[head->polyBgn].XC,maxypixel-pt[head->polyBgn].YC);
  for (i=head->polyBgn+1; i<=head->polyEnd; i++)
    _lineto(pt[i].XC,maxypixel-pt[i].YC);
  _lineto(pt[head->polyBgn].XC,maxypixel-pt[head->polyBgn].YC);
}

void adclosegraph(char *msg)
{
  closegraphics();
  printf("%s\n",msg);
  exit(1);
}

void usagemessage()
{
  printf("Usage: addisp? filename\n");
  exit(1);
}


void printit(void)
{
  printf("enttype %d\n",adenhd.enttype);
}


void initializegraphics()        /* initialize screen graphics */
{
#ifdef MICROSOFT
  struct videoconfig config; /* for MS graphics */

  _setvideomode(_VRES16COLOR);
  _getvideoconfig(&config);
  maxypixel=config.numypixels-1;
  maxxpixel=config.numxpixels-1;
#endif
#ifdef TURBO
  int grafdriver,grafmode,g_error;   /* for TURBO graphics */

  grafdriver=VGA;
  grafmode=VGAHI;
  initgraph(&grafdriver,&grafmode,"d:\\c\\tc\\");  /* use your own path here */
  g_error=graphresult();
  if (g_error<0) {
    printf("initgraph error: %s.\n",
      grapherrormsg(g_error));
    exit(1);
  }
  maxypixel=479;   /* 480 - 1 */
  maxxpixel=639;
#endif
#ifdef ZORTECH
  fg_init_vga12();
  maxypixel=479;   /* 480 - 1 */
  maxxpixel=639;
#endif
}

void closegraphics()
{
#ifdef MICROSOFT
  _setvideomode(_DEFAULTMODE);
#endif
#ifdef TURBO
  restorecrtmode();
#endif
}

void clearthescreen()
{
#ifdef MICROSOFT
    _clearscreen(_GCLEARSCREEN);
#endif
#ifdef TURBO
    cleardevice();
#endif
#ifdef ZORTECH
  fg_fillbox(FG_BLACK,FG_MODE_SET,~0,fg.displaybox);
#endif
}

void main(int argc, char **argv)
{
  char infile[64];
  double adviewdir[4],adtarget[4],adup[4];
  double xsize,ysize,origxsize,origysize;
  short firsttime;
  short i,j,frtha,onoff,limit;
  double magni;


  if (argc<2) usagemessage();

  initializegraphics();
#ifdef METAWARE
  _gbuffmode(1);
#endif
  initad();                    /* initialize autodirect */
  InitAvEng(30720,16384,8192); /* initialize the autoview engine */

  setcolormap();

  ad_MoveTo=MoveTo;
  ad_LineTo=LineTo;
  ad_PaintPoly=PaintPoly;
  ad_PenColor=PenColor;
  ad_Vecfunc=NULL;
  ad_Odometer=NULL;
  ad_Closegraph=adclosegraph;
  ad_Badxref=NULL;

  strcpy(ad3ct.shapepath,"d:\\acadfont\\");

  ad3ct.accuracy=1.0;
  strcpy(infile,argv[1]);
  ad3ct.genfaces=0; /* this should always be 0 for now */
  firsttime=1;

  for (magni=1.0; magni<=3.0; magni+=0.5) {
    clearthescreen();

    if (!initializeread(infile,30720,16384,8192)) { /* open file for read */
      CloseAvEng();
      adclosegraph("Error opening file");
      exit(1);
    }

/* note that the "endread" function frees the table entries read by
   ReadTables, then calls "terminateread".  Thus, since we have not yet
   read the tables, any errors here simply require "terminateread" to be
   called to terminate reading, rather than "endread" */

     /* read header */

    if (!readheader()) {
      terminateread();
      CloseAvEng();
      adclosegraph("Header was not ok\n");
	}

    if (!dwgwithinlimits(&limit)) {
      terminateread();
      CloseAvEng();
      adclosegraph("Drawing exceeds table entry limit");
/* note -- "limit" contains the actual limit, if you wish to use it */
    }

    if (ad3ct.genfaces) SetSpace(MODELSPACE);
    else if (adct.ouracadverr>=ACAD11 && adhd.tilemode==0) SetSpace(PAPERSPACE);
      else SetSpace(MODELSPACE);

    /* note -- you can change attmode, qtextmode, or fillmode here as desired,
       once the header has been read. */

    if (!ReadTables()) {
      endread();
      CloseAvEng();
      adclosegraph("Error in readtables\n");
	}

/* always call setinitialview, even on subsequent viewings of the same dwg */
    setinitialview(adviewdir,adtarget,adup,0,0,maxxpixel,
      maxypixel,&xsize,&ysize);

    if (firsttime) {
      origxsize=xsize; origysize=ysize;
    }
    else {
      xsize=origxsize/magni;
      ysize=origysize/magni;
    }

    firsttime=0;

    makeviewtransform(adviewdir,adtarget,adup,0,0,
      maxxpixel,maxypixel,xsize,ysize);

  /* this is an example of getting and setting layer info */
#ifdef COMMENTEDOUT
    for (i=0; i<(short)adct.numlayersr; i++) {
      GetLayerState(i,&frtha,&onoff);
      for (j=0; lay[i]->layname[j]!=' '; j++)
        printf("%c",lay[i]->layname[j]);
      for (;j<32; j++) printf(" ");
      if (frtha==LAYFROZEN) printf("Frozen ");
      else printf("Thawed ");
      if (onoff==LAYON) printf("On\n");
      else printf("Off\n");
    }
    for (i=0; i<(short)adct.numlayersr; i++)
      SetLayerState(i,LAYTHAWED,LAYON);
#endif
/*  */

  /* draw it */
    if (!DrawDrawing()) endread();
/* drawdrawing returns 1 if xrefs were found, need to close if not */

#ifdef METAWARE
    _gflush();
#endif
   getch();
  }

  CloseAvEng();
  closegraphics();
}
