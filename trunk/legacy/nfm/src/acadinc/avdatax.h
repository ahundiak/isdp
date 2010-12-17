#define TRUE	1			/* Define some handy constants	*/
#define FALSE	0
#define PI2     1.5707963267949
#define ROOT2	1.4142135623731
#define EIGHTH2 1.0905077326653
#define DODRAW  1
#define DONOTDRAW 0
#define ISTEXT  1
#define ISNOTTEXT 0
#define MAXSHAPES 256
#define MAXSHAPEFILENAMES 128
#ifdef HIGHCAPACITY
#define MAXADPP 2500
#define MAXBLOCKCACHE 200
#define MAXSHFILESTRU 11
#define MAXSHDATABLOCKS 41
#define BIGFONTINDEXSIZE 8000
#define DATABLOCKSIZE 4096
#else
#define MAXADPP 1100
#define MAXBLOCKCACHE 75
#define MAXSHFILESTRU 6
#define MAXSHDATABLOCKS 21
#define BIGFONTINDEXSIZE 384
#define DATABLOCKSIZE 1024
#endif
#ifdef UNIXOS
#define OPENFLAGS O_RDONLY
#else
#define OPENFLAGS O_RDONLY|O_BINARY
#endif
#define ACADFONT  1
#define FONT10    2
#define FONT11    4
#define BIGFONT10 8


#define X  0			   /* Coordinate indices */
#define Y  1
#define Z  2

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

#define LAYERSTRUDEFINED
 struct layerstru {
    char layname[41];
    unsigned char layflag;
    short laycolor;
    unsigned short laylinetype,origlayno;
    unsigned short vpfrozflags;
  } ;

  extern struct layerstru **lay;

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

#ifndef AD3INSTRUDEFINED
#define AD3INSTRUDEFINED
struct viewstru {
  char viewname[33];
  double adviewdir[4];
  double adtarget[4];
  double adup[4];
  double ysize;
} ;
  struct ltpstru {
      char   numltpvals;
      char   ltpname[33];
      short  origltpno;
      double patternlength;
      double *patternval;
      double avgseglen;
  } ;
  struct blockstru {
    char blkname[33];
    char blkflag;
    long blkdefoffsetr;
    long blksize;
    short origblkno;
  } ;
struct polystru {
    char pflag;
    unsigned short polycolor;
    double stwid,endwid;
    short mshm,mshn,meshmdens,meshndens;
    short fittyp;
    double polyelev;
  } ;

struct vertexstru {
    double pt0[3];
    double startwidth,endwidth;
    double bulge;
    char vertflag;
    double tangentdir;
    struct vertexstru *link;
  } ;
struct blkstru {
    short minsrows,minscols,tminscols,tminsrows,tblockno;
    double trotang,txscale,tyscale,tzscale,pt0[3];
    double tx1offset,ty1offset;
    double tcoldist,trowdist;
    short tbyblockcolor;
  } ;
  struct blockcachestru {
    short blockno;
    short inuse;
    long lru;
    char *blkdata;
  } ;

#ifndef SHINDEXSTRUDEFINED
#define SHINDEXSTRUDEFINED
struct shindexstru {
  unsigned short whichshape;
  unsigned long  fileloc;
} ;
#endif

struct shfilestru {
  char name[80];             /* name of file */
  char origname[80];
  long len;                  /* file length -- may be unnecessary */
  long lru;
  char flags;                /* acadfont, bigfont, etc */
  short minshp,maxshp,numshp,above,below,modes;
  char bfheight,bfwidth;
  unsigned short bfindexentrysize;    /* bigfont -- size of an index entry */
  unsigned short bfnumindexentries;   /* bigfont -- number of index entries */
  unsigned short bfnumranges;         /* bigfont -- number of ranges */
  unsigned short bfrange[20][2];      /* bigfont -- character ranges */
  long bflastindexreadloc;
  long bfindexstart,bfindexend;
  struct shindexstru *index;               /* pointer to index data */
  unsigned short validindexentries;
  short curdatablock, curdataindex,bffh;
} ;

struct shdatastru {
  char shfileno;             /* which shfile is this data for */
  long startaddr;            /* address in file from which this data comes */
  short numchars;            /* length of valid data */
  char *data;                /* the shape data */
  long lru;
} ;

struct ad3instru {
  struct shfilestru shfile[MAXSHFILESTRU];
  struct shdatastru shdata[MAXSHDATABLOCKS];
/* AUTODIRECT POINTER PILE -- general purpose pointers shared among layer,
   linetype, block header, and view tables */
/*  void *adpp[MAXADPP]; */
  void **adpp;          /* malloc in initaveng, free in closeaveng */
  short adppcount;

  short blkppindex,layppindex,ltpppindex,vwppindex,shpppindex;

  char pathbuf[80];
  struct viewstru **vw;

  struct _point polypts[20];
  struct ltpstru **ltp;
  struct blockstru **blk;

  char *shapeinfo[MAXSHAPEFILENAMES];
  short nextavailshapefile;
  char shflag[MAXSHAPEFILENAMES];

  struct polystru *mypoly;
  struct vertexstru *vertliststart, *vert, *vert1;

/* moved polyline draw variables out to this level, because they were
   causing stack overflow in drawentitygroup.  There is no reason
   to stack them during the recursive call anyway, since the values
   do not need to be preserved */

/* polyline draw variables */
  short firstsegflag,firstvertexhaswidth;

  struct vertexstru *dvert2,*dvert1,*dvert;  /* the draw chain */
  short  plineextrusioninfovalid;
  double plineextrusion[3];
  double minvisplinewid;

  short maxlayernamesize;
  short maxblocknamesize;
  short maxviewnamesize;

  char *simpfont;  /* pointer to simplex def */

/* 3d data */
  double (*viewplanetransmat)[4][4];
  short  vptmallocated;
  double dcsmat[4][4];
  double dcstoscrnmat[4][4];

  short  polylinestate;
  struct vertexstru *firstactualvertex,*secondactualvertex;
  short vertexcount;

  double viewx1real,viewy1real,viewx2real,viewy2real;
  double extrumat[4][4];

  char   *avbuf;
  char   *avbuf2;
  char   *avbuf3;
  char   *avbuf4;
  short  maxavbufsiz;

  struct blockcachestru blockcache[MAXBLOCKCACHE];
  short globalreadingfromcache;
  long  globallru;

  short pixperinx,pixperiny;
  short insentlayer;
  char mallocmsg[14];

  short  pline3dflag;
  short  clipping;
  /* clip coords in pixel space */
  double xclipmin[16],yclipmin[16],xclipmax[16],yclipmax[16];
  /* actual coords for scaling, etc */
  double xrealmin[16],yrealmin[16],xrealmax[16],yrealmax[16];
  double pp[5][2];
  short  overrideattmode,overrideqtextmode;
  short  enginespace;
  short  numvptmats;               /* number of active vptmats */
  short  totalvptmats;             /* total number of vptmats */
  short  overridepaperspace;

  short lastperc;
  long entlisttarg,entlisttargstep;
  short vecfunccount;
  double arcscalemult;
  short firstvpentfound;
  FILE *xreffile;
  short avbufsz1,avbufsz2,avbufsz3;
  long  xrefreadptr,xrefwriteptr;
  short ignorepspaceents;
  unsigned short layvpflags,globalvpflags;
  short  blockisxref;
  short genfaces;
#ifndef AV
  double facept[4][4];
  double facepthold[4][4];
#endif
  double perspdist;
  short byblockltpval;
  short bylayerltpval;
  short numpspvptmats;
  short displayitemtype;
  short whichvp;

  /* location in linetype */
  short ltloc;
  short thisentlinetype;
  double amtofsegdrawn;

  unsigned short vpdrawflags;
#ifdef AV
  long xclipminl[16],yclipminl[16],xclipmaxl[16],yclipmaxl[16];
#endif
  short  overridedolinetypes;
  double stretchamt[16];
} ;
#endif
extern struct ad3instru ad3in;

#ifdef PROTOTYPES
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
extern void (*ad_Closegraph)();
extern void (*ad_Examineentity)();
#endif

