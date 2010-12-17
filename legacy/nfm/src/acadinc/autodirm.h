  /* AUTODIRM.H -- header values for autocad drawing
     this version of the header file is used in the autodir.c file for compile
     note that this file is formatted so that to create autodir.h, all
     lines which need an extern in front of them are all the way against
     the left margin; all other lines have a leading blank.  Use the program
     mkext.exe to create autodir.c */
  /* autodir.h */
  /* include file for AUTODIRECT 2 */
  /* these are the equates for the constants which define the version of
     the drawing being processed */
#define ACAD25 0  /* ac1002 */
#define ACAD26 1  /* ac1003 */
#define ACAD9  2  /* ac1004 */
#define ACAD10 3  /* ac1006 */
#define ACAD11 4  /* ac1009 */
#define LINE 1
#define POINT 2
#define CIRCLE 3
#define SHAPE 4
#define TEXT 7
#define ARC 8
#define TRACE 9
#define SOLID 11
#define BLOCK 12
#define ENDBLK 13
#define INSERT 14
#define ATTDEF 15
#define ATTRIB 16
#define SEQEND 17
#define MYSTER 18
#define POLYLINE 19
#define VERTEX 20
#define LINE3D 21
#define FACE3D 22
#define DIMENSION 23
  /* DXF HEADER VALUES */
  /* values are as described in the AutoCAD reference manual */
#ifndef ADHSTRUDEFINED
#define ADHSTRUDEFINED
struct adhdstru {
#ifndef AV
char   acadmenu[61];
#endif
char   acadverr[7];
#ifndef AV
char   acadverw[7];
double angbase;
short  angdir;
short  attdia;
#endif
short  attmode;
#ifndef AV
short  attreq;
short  aunits;
short  auprec;
short  axismode;
double axisunitx;
double axisunit[2];
double backz;
#endif
double base[3];
#ifndef AV
short  blipmode;
short  cecolor;
short  celtype;
double chamfera;
double chamferb;
short  coords;
short  curdimstyleno;
short  curlayerindex;
short  curstyleindex;
short  curucsindex;
#endif
short  cvport;
#ifndef AV
short  cyclecurr;
short  cyclekeep;
char   dimalt;
char   dimaltd;
double dimaltf;
char   dimapost[16];
char   dimaso;
double dimasz;
char   dimblk[32];
char   dimblk1[32];
char   dimblk2[32];
double dimcen;
short  dimclrd;
short  dimclre;
short  dimclrt;
double dimdle;
double dimdli;
double dimexe;
double dimexo;
double dimgap;
double dimlfac;
char   dimlim;
char   dimpost[16];
double dimrnd;
char   dimsah;
double dimscale;
char   dimse1;
char   dimse2;
char   dimsho;
char   dimsoxd;
short  dimstyleindex;
char   dimtad;
double dimtfac;
char   dimtih;
char   dimtix;
double dimtm;
char   dimtofl;
char   dimtoh;
char   dimtol;
double dimtp;
double dimtsz;
double dimtvp;
double dimtxt;
char   dimzin;
short  dragmode;
short  dwgcodepage;
double elevation;
#endif
short  enthandles;
#ifndef AV
unsigned char   enthandseed[8];
#endif
double extmin[3];
double extmax[3];
#ifndef AV
short  fastzoom;
double filletrad;
#endif
short  fillmode;
#ifndef AV
short  flatland;
double frontz;
short  gridmode;
double gridunit[2];
double lenslength;
short  limcheck;
double limmin[2];
double limmax[2];
#endif
double ltscale;
#ifndef AV
short  lunits;
short  luprec;
#endif
short  maxactvp;
#ifndef AV
short  mirrtext;
short  orthomode;
short  osmode;
#endif
short  pdmode;
double pdsize;
#ifndef AV
double pelevation;
#endif
double pextmin[3];
double pextmax[3];
double pinsbase[3];
#ifndef AV
short  plimcheck;
double plimmin[2];
double plimmax[2];
short  plinegen;
double plinewid;
short  psltscale;
short  pucsnameindex;  /* (R11) -1 if none */
double pucsorg[3];     /* (R11) */
double pucsxdir[3];    /* (R11) */
double pucsydir[3];    /* (R11) */
#endif
short  qtextmode;
#ifndef AV
short  regenmode;
short  shadedge;
short  shadedif;
double sketchinc;
short  skpoly;
double snapang;
double snapbase[2];
short  snapisopair;
short  snapmode;
short  snapstyle;
double snapunit[2];
short  splframe;
short  splinesegs;
short  splinetype;
short  surftab1;
short  surftab2;
short  surftype;
short  surfu;
short  surfv;
double target[3];
#endif
long   tdcreate1;
long   tdcreate2;
long   tdindwg1;
long   tdindwg2;
long   tdupdate1;
long   tdupdate2;
long   tdusrtimer1;
long   tdusrtimer2;
#ifndef AV
double textsize;
double thickness;
#endif
short  tilemode;
#ifndef AV
double tracewid;
short  treedepth;
short  ucsflag;
short  ucsicon;
char   ucsname[32];
double ucsorih[3];
double ucsxdirh[3];
double ucsydirh[3];
short  unitmode;
short  useri[5];
double userr[5];
short  usrtimer;
#endif
double viewctr[3];
double viewsize;
double viewdir[3];
#ifndef AV
double viewtwisthdr;
short  visretain;
double vpointhdr[3];
short  worldview;
#endif
} ;
#endif
struct adhdstru adhd;
  /* end of dxf header variables */

  /* entity values for autocad drawing */
#ifndef ADENHDSTRUDEFINED
#define ADENHDSTRUDEFINED
struct adenthdrstru {
  unsigned char enttype;
  short  entlinetype;
  double entelevation;
  double entthickness;
  short  entcolor;
  short  paperspace;
  double extrusion[3];
  short  extrusioninfovalid;
  short  xddatapresent;          /* 1 if extended data is present */
  char   erasedflag;
  short  layerindex;
  unsigned char enthandle[10];
  unsigned short enthandlelength;
} ;
#endif
#ifndef ADTDATADEFINED
#define ADTDATADEFINED
  struct adtdatastru {
    double height;
    double rotang;
    double widthfactor;
    double oblique;
    char   styleno;
    char   generationflag;
    char   justification;
    char   vertalignment;
    double secondtextloc[2];
  };
#endif
#ifndef ADENSTRUDEFINED
#define ADENSTRUDEFINED
union adenunion {
  struct adlinestru {
    double pt0[3];
    double pt1[3];
  } line;
  struct adpointstru {
    double pt0[3];
    double ucsxangle;
  } point;
  struct adcirclestru {
    double pt0[3];
    double radius;
  } circle;
  struct adshapestru {
    double pt0[3];
    double scale;
    char   shapefileno;
    unsigned char whichshape;
    double rotang;
    double widthfactor;
    double oblique;
  } shape;
  struct adtextstru {
    double pt0[3];
    struct adtdatastru tdata;
    char   textstr[1024];
  } text;
  struct adarcstru {
    double pt0[3];
    double radius;
    double stang;
    double endang;
  } arc;
  struct adtracestru {
    double pt0[3];
    double pt1[3];
    double pt2[3];
    double pt3[3];
  } trace;
  struct adblockstru {
    double base[3];
    char   name2[33];
    char   xrefpath[80];
  } block;
  struct adinsertstru {
    short  attribsfollow;
    short  blockno;
    double pt0[3];
    double xscale;
    double yscale;
    double zscale;
    double rotang;
    double rowdist;
    double coldist;
    short  numrows;
    short  numcols;
  } insert;
  struct adattdefstru {
    double pt0[3];
    char   attflag;
    struct adtdatastru tdata;
    char   prompt[257];
    char   tag[257];
    char   defaultval[257];
  } attdef;
  struct adattribstru {
    double pt0[3];
    char   attflag;
    short  fieldwidth;
    struct adtdatastru tdata;
    char   prompt[257];
    char   tag[257];
    char   attval[257];
  } attrib;
  struct adpolylinestru {
    double z1;
    double rotang;
    double startwidth;
    double endwidth;
    short  fittype;
    short  meshmdensity;
    short  meshndensity;
    short  meshm;
    short  meshn;
    short  polyflag;
  } pline;
  struct advertexstru {
    double pt0[3];
    double startwidth;
    double endwidth;
    short  startwidthvalid;
    short  endwidthvalid;
    double bulge;
    short  vertexflag;
    double tangentdir;
    short  polyfacevertcount;
    short  polyfacevert[4];
  } vertex;
  struct adline3dstru {
    double pt0[3];
    double pt1[3];
  } line3d;
  struct adface3dstru {
    double pt0[3];
    double pt1[3];
    double pt2[3];
    double pt3[3];
    short  faceflag;
  } face3d;
  struct addimensionstru {
    short  dimcloneinfopresent;
    double dimcloneinspt[3];
    short  dimblkno;
    char   dimflag;
    short  dimstyle;
    double arcdefpt[3];
    double defpt2[3];
    double defpt3[3];
    double defpt4[3];
    double leaderlen;
    double dimrotang;
    double dimtextrot;
    double dimoblique;
    double dimtextmidpt[2];
    double dimlinedefpt[3];
    double ucsxangle;
    char   dimtext[257];
  } dim;
  struct advpentstru {
    short  flag;
    short  stackval;
    double cen[3];
    double width;
    double height;
    short  id;
    char   purgedflag;             /* flag indicating entry has been purged */
    short  xrefindex;     /* index of xref from which this item came */
    char   name[32];
  } vpent;
} ;
#endif

#ifndef ADXDSTRUDEFINED
#define ADXDSTRUDEFINED
struct adxdstru {
  short xddxfnumber;
  char   xdbindatalength;        /* size of the data for binary data */
  union xdunion {
    double xd3dpt[3];              /* extended data 3d point x, */
    short  xdappindex;             /* ext data index of application name */
    char   xdbindata[128];         /* extended data binary data */
    char   xdcontrol;              /* { or } */
    char   xdhandle[8];            /* extended data database handle */
    double xddist;                 /* extended data distance */
    short  xdint;                  /* extended data integer */
    short  xdlayerindex;           /* extended data layer index ??? */
    long   xdlong;                 /* extended data long integer */
    double xdreal;                 /* extended data real number */
    double xdscale;                /* extended data scale factor */
    char   xdstring[256];          /* extended data string */
    double xdworlddir[3];          /* extended data world direction xyz */
    double xdworlddisp[3];         /* extended data world displacement xyz */
    double xdworldpos[3];          /* extended data world position xyz */
  } xddata;
} ;
#endif
union  adenunion aden;
struct adenthdrstru adenhd;
struct adxdstru adxd;
  /* end of entity values */
  /* table values for autocad drawing */
#ifndef ADTBSTRUDEFINED
#define ADTBSTRUDEFINED
union adtbunion {
  struct adshptbstru {
    char   bigfontname[65];        /* big font filename for text style */
    char   purgedflag;             /* flag indicating entry has been purged */
    short  xrefindex;     /* index of xref from which this item came */
    char   flag2;                  /* secondary shape flag */
    char   flag;                   /* shape flag */
    char   name[33];               /* name of shape */
    char   file[65];               /* shape file name */
    double angle;                  /* angle for shape entity */
    double height;                 /* shape height */
    double width;                  /* width of shape */
    double lastshapeheight;        /* last shape height */
  } shape;
  struct addimstylestru {
    short  xrefindex;     /* index of xref from which this item came */
    char   flag;                   /* flag for dimstyle */
    char   purgedflag;             /* 1 if purged */
    char   name[33];               /* name of dimension style */
    char   dimalt;                 /* these ds variables are the dim vars */
    char   dimaltd;                /* associated with the dimension style */
    double dimaltf;                /* currently being read from the */
    char   dimapost[16];           /* dimstyle table (R11) */
    double dimasz;
    char   dimblk[33];
    char   dimblk1[33];
    char   dimblk2[33];
    double dimcen;
    short  dimclrd;
    short  dimclre;
    short  dimclrt;
    double dimdle;
    double dimdli;
    double dimexe;
    double dimexo;
    double dimgap;
    double dimlfac;
    char   dimlim;
    char   dimpost[16];
    double dimrnd;
    char   dimsah;
    double dimscale;
    char   dimse1;
    char   dimse2;
    double dimtfac;
    char   dimtih;
    double dimtm;
    char   dimtoh;
    char   dimtofl;
    char   dimtol;
    double dimtp;
    double dimtsz;
    double dimtxt;
    double dimtvp;
    char   dimsoxd;
    char   dimtad;
    char   dimtix;
    char   dimzin;
  } dimst;
  struct adblkhstru {
    char   flag;              /* flag for block */
    char   name[33];          /* name of block */
    char   defpresent;             /* flag indicating block def is present in dwg */
    char   purgedflag;             /* flag indicating entry has been purged */
    short  xrefindex;     /* index of xref from which this item came */
  } blkh;
  struct adlaystru {
    char   purgedflag;             /* flag indicating entry has been purged */
    short  xrefindex;     /* index of xref from which this item came */
    short  color;                  /* index of layer color */
    char   flag;                   /* layer flag */
    short  linetype;               /* index of layer linetype */
    char   name[33];               /* name of layer */
  } lay;
  struct adltpstru {
    char   purgedflag;             /* flag indicating entry has been purged */
    short  xrefindex;     /* index of xref from which this item came */
    char   name[33];               /* name of linetype */
    char   text[48];               /* "picture" of linetype */
    double val[15];                /* values which define linetype */
    char   alignflag;              /* linetype alignment flag */
    char   flag;                   /* linetype flag */
    short  numlinetypevals;        /* number of valid entries in linetypeval array */
    double patternlength;          /* length of linetype pattern */
  } ltype;
  struct adviewstru {
    short  xrefindex;     /* index of xref from which this item came */
    double backclip;
    double center[2];            /* view center */
    double dir[3];               /* view direction */
    char   flag;
    char   flag2;
    double frontclip;
    double ht;
    double lenslength;
    char   name[33];
    double target[3];
    double twist;
    short  viewmode;
    double width;
  } view;
  struct appstru {
    short  xrefindex;     /* index of xref from which this item came */
    char   purgedflag;             /* flag indicating entry has been purged */
    short  flag;
    char   name[33];
  } app;
  struct ucsstru {
    char   purgedflag;             /* flag indicating entry has been purged */
    short  xrefindex;     /* index of xref from which this item came */
    char   flag;
    char   name[32];
    double org[3];
    double xdir[3];
    double ydir[3];
  } ucs;
  struct vportstru {
    char   purgedflag;             /* flag indicating entry has been purged */
    short  xrefindex;     /* index of xref from which this item came */
    char   flag;
    char   name[32];
    double ll[2];
    double ur[2];
    double snapbase[2];
    double snapdist[2];
    double griddist[2];
    double center[2];
    double viewdir[3];
    double target[3];
    double viewtwist;
    double viewheight;
    short  viewmode;
    short  zoomperc;
    short  fastzoom;
    short  ucsicon;
    double aspect;
    double backclip;
    double frontclip;
    short  gridmode;
    double lenslength;
    short  snapisopair;
    short  snapmode;
    double snaprot;
    short  snapstyle;
  } vport;
} ;
#endif
union adtbunion adtb;
  /* end of table values */
  /* other variables */
#ifndef ADCTSTRUDEFINED
#define ADCTSTRUDEFINED
struct adctstru {
#ifndef AV
short dwgno;       /* which dwg are we reading ? */
short copymode SUFFIX;
long numblocksw SUFFIX;
long numlayersw SUFFIX;
long numlinetypesw SUFFIX;
long numshapefilesw SUFFIX;
long numviewsw SUFFIX;
long numucsw SUFFIX;
long numvportsw SUFFIX;
long numdimstylesw SUFFIX;
long numregappsw SUFFIX;
long numvportenthdrsw SUFFIX;
#endif
long numblocksr SUFFIX;    /* number of each table entry type */
long numlayersr SUFFIX;    /* includes purged items */
long numshapefilesr SUFFIX;
long numviewsr SUFFIX;
long numvportsr SUFFIX;    /* number of ucs in drawing */
long numvportenthdrsr SUFFIX;
long numucsr SUFFIX;
long numlinetypesr SUFFIX;
long numdimstylesr SUFFIX;
long numregappsr SUFFIX;
#ifndef AV
short ouracadverw SUFFIX;
#endif
short ouracadverr SUFFIX;   /* index of acad version read or written */
} ;
#endif
struct adctstru adct;
#define BYLAYER 256
#define BYBLOCK -1
#ifdef PROTOTYPES
#define _(a) a
#else
#define _(a) ()
#endif
extern  void  endblockdefread _((void));
extern  short initializeread _((char *fn,unsigned short buffersize,unsigned short blkbufsize, unsigned short extbufsize));
extern  short readentity _((void));
extern  short readheader _((void));
extern  short readlayer _((void));
extern  short readlinetype _((void));
extern  short readblockheader _((void));
extern  short readshapefile _((void));
extern  void  readucs _((void));
extern  short readview _((void));
extern  short readvport _((void));
extern  void  startblockheaderread _((void));
extern  void  startblockdefread _((void));
extern  void  startentityread _((void));
extern  void  startlayerread _((void));
extern  void  startlinetyperead _((void));
extern  void  startshaperead _((void));
extern  void  startucsread _((void));
extern  void  startviewread _((void));
extern  void  startvportread _((void));
extern  void  terminateread _((void));
extern  short distancethroughentities _((void));
extern  void writeentity _((void));
extern  void writeheader _((void));
extern  void writeblockheader _((void));
extern  void writelayer _((void));
extern  void writeshapefile _((void));
extern  void writelinetype _((void));
extern  void writeview _((void));
extern  void writeucs _((void));
extern  void writevport _((void));
extern  void startblockheaderwrite _((void));
extern  void startblockdefwrite _((void));
extern  void initializeblockdef _((long defno));
extern  void endblockdefwrite _((void));
extern  void startlayerwrite _((void));
extern  void startshapewrite _((void));
extern  void startlinetypewrite _((void));
extern  void startviewwrite _((void));
extern  void startentitywrite _((void));
extern  void startucswrite _((void));
extern  void startvportwrite _((void));
extern  void terminatewrite _((void));
extern  short initializewrite _((char *fn,short buffersize));
extern  void generatehandle _((void));
extern  void inithandles _((void));
extern  void setoutputversion _((short version));

