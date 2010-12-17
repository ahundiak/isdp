/* Function prototypes for Autodirect 3 */

#ifdef PROTOTYPES
#define _(a) a
#else
#define _(a) ()
#endif

void  main _((int argc,char **argv));
short InitAvEng _((short firstbufsz, short secondbufsz, short thirdbufsz));
void CloseAvEng _((void));
void DrawFastText _((unsigned char *sn,short numshapes,double *xloc,double *yloc,short whichshpfile,short dodraw,double (*shmat)[4][4],double (*bfmat)[4][4]));
void DrawSlowText _((unsigned char *sn,short numshapes,double *xloc,double *yloc,short whichshpfile,short dodraw,double (*shmat)[4][4],double (*bfmat)[4][4]));
void transformpoint3d _((double point[4],double mat[4][4],double point2[4]));
short loadshapefile _((char *shapefilename));
short shloaded _((char *shapefname));
short newlayno _((short index));
short newblkno _((short index));
short newltpno _((short index));
short DrawEntityGroup _((double matrix[4][4],double newpt[3],
                      double neworient,double newxscale,double newyscale,
                      double newzscale,short byblockcolor,short byblockltp,
                      short level,short readingfromcache,unsigned short vpflags));
/* int  gprintf(int *xloc, int *yloc, char *fmt, ... ); */
double GetTextWidth _((unsigned char *str, double height, double widthfac, short styleno,double tmat[4][4]));

void identity _((double mat[4][4]));
void matmult _((double mata[4][4],double matb[4][4],double matc[4][4]));
void translatematrix _((double pt0[3],double mat[4][4]));
void moveforrotsc _((double x,double y,double z,double mat[4][4]));
void scalematrix _((double xscale,double yscale,double zscale,double mat[4][4]));
void rotatematrixz _((double angle,double mat[4][4]));
void rotatematrixx _((double angle,double mat[4][4]));
short quicksort _((void *(*returnitemptr)(short ),short numitems,short width,int (/* cdecl */*compare)(const char *,const char *)));

void endread _((void));
void DrawArc _((double pt0[3],double dstang,double dendang,
  double arcradius,double (*matrix)[4][4]));
void DrawFilledPoly _((double pt0[3],double pt1[3],double pt2[3],double pt3[3],
                    double (*matrix)[4][4]));
#ifdef DRAWSHAPE
void DrawShape _((unsigned char *shapeno,short numshapes,double *xloc,double *yloc,short whichshpfile,short istext,short dodraw,double (*shmat)[4][4]));
#endif
void DrawGrText _((double pt0[3],unsigned char *textstr,short textstrlen,struct adtdatastru *tdata,double textmat[4][4],double (*segmat)[4][4],double minvistextht));
short intersection _((double x1,double y1,double x2,double y2,double x3,double y3,double x4,double y4,double *xint,double *yint));
short segintersection _((double x1,double y1,double x2,double y2,double x3,double y3,double x4,double y4,double *xint,double *yint));
void CalcPlineArcCenterOffset _((double a,double b,double c,double d,double inclang,double *deltax,double *deltay,double *rad));
void PolylineSeg _((double (*matrix)[4][4]));
void putvertinsequence _((struct vertexstru *vert));
void Polyarc _((struct vertexstru *arcvert2,struct vertexstru *arcvert1,double (*matrix)[4][4]));
void DrawPolyline _((double (*matrix)[4][4]));
void terminatepolyline _((double (*matrix)[4][4]));
void DrawPolymesh _((double (*matrix)[4][4]));
void OutlinePoly _((double pt0[3],double pt1[3],double pt2[3],double pt3[3],
                 double (*matrix)[4][4]));
void computesidepts _((struct vertexstru *svert1,struct vertexstru *svert,double sidept1[2][3],double sidept[2][3]));

short nonstarblockno _((short index));
void *returnlayerptr _((short index));
void *returnblockptr _((short index));

/* 3d routines */
void translate3 _((double xdist,double ydist,double zdist,double mat[4][4]));
void rotatex3 _((double s,double c,double mat[4][4]));
void rotatey3 _((double s,double c,double mat[4][4]));
void rotatez3 _((double s,double c,double mat[4][4]));
void rotate3 _((double s,double c,double mat[4][4],short axis));
void makeviewplanetransformation _((double mat[4][4],double campos[4],double target[4],double up[4],
  double xdisp,double ydisp,double xsc,double ysc,double vcx,double vcy));
void rotatearoundaxis _((double pttorot[4],double targetpt[4],double rotaxis[4],double angle));

void readextrusioninfo _((void));
void processcol _((double (*matrix)[4][4]));

/* non-parallel extrusion stuff */
void arbaxis _((double *newaxis, double *givenaxis));
void geta4by4 _((double normaxis[4],double (*mat)[4]));
void acadtrans _((double pt[4]));
void DrawSeg3d _((double pt0[3],double pt1[3],double (*mat)[4][4]));
short clip _((double x1,double y1,double x2,double y2));
void crossproduct _((double a[4],double b[4],double c[4]));
void normalize _((double a[4]));
void dothis _((double a[5][5],double vv[],int indx[],int j));
void invert _((double mat[4][4]));
double frdreal _((void));
long frdlong _((void));
void clearblockcache _((short dofree));
short incache _((short blkno));
short blksize _((short blkno));
short putblockincache _((short blkno));
short readtheblockheaders _((void));
short readtheshapefiles _((void));
short readthelayers _((void));
short readthelinetypes _((void));
void makedcsmat _((double viewdirvec[4],double mytarget[4],double upvec[4],
  double myviewctrx,double myviewctry));
void findtarget _((double adtarget[4]));
void makevptransmatfromdcs _((short xpixmin,short ypixmin,short xpixmax,short ypixmax,double xsize, double ysize, short index));
void setinitialupvector _((double viewdirvec[4],double viewtwist,double upvec[4]));

void DrawPolyfacemesh _((double (*matrix)[4][4]));

/* autoview engine function prototypes */
short DrawDrawing _((void));
short ReadTables _((void));

void setinitialview _((double adviewdir[4],double adtarget[4],double adup[4],
  short xpixmin,short ypixmin,short xpixmax,short ypixmax,double *xsize,double *ysize));
void makeviewtransform _((double viewdirvec[4],double target[4],double up[4],
  short xpixmin,short ypixmin,short xpixmax,short ypixmax,double xsize,double ysize));

void SetLayerState _((short index,short frtha,short onoff));
void GetLayerState _((short index,short *frtha,short *onoff));
void SetSpace _((short space));

short readentityav _((void));
void clearunusedcacheitems _((void));
void genextrudedface _((double pt0[3],double pt1[3],double pt2[3],double pt3[3],double (*matlist)[4][4]));
void resetcliplimits _((short xpixmin,short ypixmin,short xpixmax,short ypixmax));
double computenextltypepoint _((double pt0[3],double pt1[3],double nextm[3]));
void drawthesegment _((double pt0[3],double pt1[3],double (*matlist)[4][4],short whichvp));
double lineleninpixels _((double pt0[3],double pt1[3],double (*matlist)[4][4],short whichvp));
short dwgwithinlimits _((short *limit));
void DefaultExamineshapefile _((char *shapefile,char *pathbuf));
void  DefaultExamineXref _((char *xrefname));
void initsh _((void));
short sh_open _((char *filename));
void sh_close _((char *filename));
short sh_seeksh _((short which,unsigned short shapeno));
long sh_tell _((short which));
short sh_seek _((short which, long fileloc));
unsigned char sh_fgetc _((short which));   /* return next shape char */
void closeshapefiles _((void));
