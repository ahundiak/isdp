/* avengpro.h -- prototypes for aveng callable functions */

#ifndef STRUSDEFINED
#define STRUSDEFINED
typedef struct _rect       /* "Rectangle" structure type     */
 {short    Xmin;           /* minimum X                    */
  short    Ymin;           /* minimum Y                    */
  short    Xmax;           /* maximum X                    */
  short    Ymax;           /* maximum Y                    */
 }  rect;
typedef struct _polyHead   /* Polygon "header" structure     */
 {short    polyBgn;        /* beginning index              */
  short    polyEnd;        /* ending index                 */
  rect     polyRect;       /* boundry limits               */
 }  polyHead;
typedef struct _point       /* "Point" structure type        */
 {short    XC;             /* X coordinate                  */
  short    YC;             /* Y coordinate                  */
 }  point;
#endif

#define MODELSPACE 0
#define PAPERSPACE 1
#define NOCHANGE 0
#define LAYON       1
#define LAYOFF      2
#define LAYFREEZE   3
#define LAYFROZEN   3
#define LAYTHAW     4
#define LAYTHAWED   4

#ifndef AD3CTSTRUDEFINED
#define AD3CTSTRUDEFINED
struct ad3ctstru {
  short  colormap[256];
  double accuracy;
  short  vecfunclimit;
  char   shapepath[80];
  short  keepvectorizing;
  short  genfaces;
  unsigned short maxcirclesegs;  /* 0 for no limit */
  double aspectratio;
  short  dolinetypes;
  char   tempfilepath[65];
} ;
#endif
extern struct ad3ctstru ad3ct;

/* autoview engine function prototypes */
#ifdef PROTOTYPES
short InitAvEng(short firstbufsz, short secondbufsz, short thirdbufsz);
short DrawDrawing(void);
short ReadTables(void);
void SetLayerState(short index,short frtha,short onoff);
void GetLayerState(short index,short *frtha,short *onoff);
void setinitialview(double adviewdir[4],double adtarget[4],double adup[4],
  short xpixmin,short ypixmin, short xpixmax,short ypixmax,double *xsize,double *ysize);
void makeviewtransform(double viewdirvec[4],double target[4],double up[4],
  short xpixmin,short ypixmin, short xpixmax,short ypixmax,double xsize,double ysize);
void PanTarget(double viewdir[4],double target[4],double up[4],double deltax,double deltay);
void SetSpace(short space);
void  CloseAvEng(void);
void endread(void);
short dwgwithinlimits(short *limit);

extern void (*ad_MoveTo)(short x,short y);
extern void (*ad_LineTo)(short x,short y);
extern void (*ad_PaintPoly)(short num,polyHead *head,struct _point *pt);
extern void (*ad_3dface)(double facept[4][4]);
extern void (*ad_PenColor)(short color);
extern void (*ad_Odometer)(short lastperc);
extern void (*ad_Vecfunc)(void);
extern void (*ad_Badxref)(char *xreffilename);
extern void (*ad_Examinexref)(char *xreffilename);
extern void (*ad_Examineshapefile)(char *shapefile,char *pathbuf);
extern void (*ad_Examineentity)(void);
extern void (*ad_Closegraph)(char *msg);
#else
short InitAvEng();
short DrawDrawing();
short ReadTables();
void SetLayerState();
void GetLayerState();
void setinitialview();
void makeviewtransform();
void PanTarget();
void SetSpace();
void  CloseAvEng();
void endread();
short dwgwithinlimits();

extern void (*ad_MoveTo)();
extern void (*ad_LineTo)();
extern void (*ad_PaintPoly)();
extern void (*ad_3dface)();
extern void (*ad_PenColor)();
extern void (*ad_Odometer)();
extern void (*ad_Vecfunc)();
extern void (*ad_Badxref)();
extern void (*ad_Examinexref)();
extern void (*ad_Examineshapefile)();
extern void (*ad_Examineentity)();
extern void (*ad_Closegraph)();
#endif

