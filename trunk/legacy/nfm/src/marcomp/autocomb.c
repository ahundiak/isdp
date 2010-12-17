
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* AUTOCOMB.C --
   This is an example of a program to combine two AutoCAD drawing files into
one.  Please use this program as a guide for designing your own.  */

/* this program requires the "M" version of Autodirect */

/* Note that the type conversions from long to short for such values as
   numlayers, numblocks etc. limit the number of these entries that can
   be processed to 32768.  This should work for most applications; you can
   always use counters that are long ints instead of the short we have used
   to get the full range */

#include <stdio.h>
#include <stdlib.h>
/* #include <math.h> */
#include <string.h>
#ifdef SUFF
#define SUFFIX [4]
#define SUBN [adct.dwgno]
#else
#define SUFFIX
#define SUBN
#endif

#define PROTOTYPES

#ifdef PROTOTYPES
#define _(a) a
#else
#define _(a) ()
#endif

#include "autodir.h"
#include "adrproto.h"
#include "adwproto.h"

short returnval;

/* blockheader read stuff */
struct _block {
  char blockflag;
  char blockname[33];
  char purgedflag;
  char defpresent;
} *block;
short *blockmap;
short blockcount;

/* layer read stuff */
struct _layer {
  char purgedflag;
  char layerflag;
  char layername[33];
  short layercolor;
  short layerlinetype;
} *layer;
short *layermap;
short layercount;

/* vport read stuff */
struct _vport {
  char   purgedflag;
  char   vportname[33];
  double vportaspect,vportbackclip,vportcentx,vportcenty;
  short  vportfastzoom;
  char   vportflag;
  double vportfrontclip,vportgriddistx,vportgriddisty;
  short  vportgridmode;
  double vportlenslength,vportsnapbasex,vportsnapbasey,vportsnapdistx,
         vportsnapdisty;
  short  vportsnapisopair,vportsnapmode;
  double vportsnaprot;
  short  vportsnapstyle;
  double vporttargetx,vporttargety,vporttargetz;
  short  vportucsicon;
  double vportviewdirx,vportviewdiry,vportviewdirz,vportviewheight;
  short  vportviewmode;
  double vportviewtwist;
  short  vportzoomperc;
  double vportllx,vportlly,vporturx,vportury;
} *vport;
short *vportmap;
short vportcount;

/* view read stuff */
struct _view {
  char   viewflag;
  char   viewname[33];
  double viewht;
  double viewcenterx,viewcentery,viewwidth;
  double viewdirx,viewdiry,viewdirz;

/* r 10 variables */
  double viewbackclip;
  char   viewflag2;
  double viewfrontclip;
  double viewlenslength;
  double viewtargetx,viewtargety,viewtargetz;
  double viewtwist;
  short  viewviewmode;
} *view;
short *viewmap;
short viewcount;

/* shape read stuff */
struct _shape {
  char   purgedflag;
  char   shapeflag;
  char   shapename[33];
  double shapeheight;
  double shapewidth;
  double shapeangle;
  char   shapeflag2;
  double lastshapeheight;
  char   shapefile[33];
  char   bigfontname[33];
} *shape;
short *shapemap;
short shapefilecount;

/* ucs read stuff */
struct _ucs {
  char   purgedflag;
  char   ucsflag;
  char   ucsname[33];
  double ucsorgx,ucsorgy,ucsorgz;
  double ucsxdirx,ucsxdiry,ucsxdirz;
  double ucsydirx,ucsydiry,ucsydirz;
} *ucs;
short *ucsmap;
short ucscount;

/* linetype read stuff */
struct _linetype {
  char   purgedflag;
  char   ltflag;
  char   linetypename[33];
  char   linetypetext[48];
  char   ltalignflag;
  short  numlinetypevals;
  double patternlength;
  double linetypeval[15];
} *linetype;
short *linetypemap;
short linetypecount;

/* regapp read stuff */
struct _regapp {
  short regappflag;
  char regappname[32];
} *regapp;
short *regappmap;
short regappcount;

/* vportenthdr read stuff */
struct _vportenthdr {
  short vportentflag;
  char vportentname[32];
  short vportentstackval;
} *vportenthdr;
short *vportenthdrmap;
short vportenthdrcount;

/* dimstyle read stuff */
struct _dimstyle {
  char   dimstyleflag;
  char   dimstylename[32];
  char   dsdimalt;               /* these ds variables are the dim vars */
  char   dsdimaltd;              /* associated with the dimension style */
  double dsdimaltf;               /* currently being read from the */
  char   dsdimapost[16];
  double dsdimasz;
  char   dsdimblk[33];
  char   dsdimblk1[33];
  char   dsdimblk2[33];
  double dsdimcen;
  short  dsdimclrd;
  short  dsdimclre;
  short  dsdimclrt;
  double dsdimdle;
  double dsdimdli;               /* dimstyle table */
  double dsdimexe;               /* (R11) */
  double dsdimexo;
  double dsdimgap;
  double dsdimlfac;
  char   dsdimlim;
  char   dsdimpost[16];
  double dsdimrnd;
  char   dsdimsah;
  double dsdimscale;
  char   dsdimse1;
  char   dsdimse2;
  double dsdimtfac;
  char   dsdimtih;
  double dsdimtm;
  char   dsdimtoh;
  char   dsdimtofl;
  char   dsdimtol;
  double dsdimtp;
  double dsdimtsz;
  double dsdimtxt;
  double dsdimtvp;
  char   dsdimsoxd;
  char   dsdimtad;
  char   dsdimtix;
  char   dsdimzin;
} *dimstyle;
short *dimstylemap;
short dimstylecount;

/* function prototypes */
void process(char infile1[],char infile2[],char outfile[]);
void main(int argc,char *argv[]);
void readblocks(void);
void readlayers(void);
void readlinetypes(void);
void readshapefiles(void);
void readvports(void);
void readviews(void);
void readucss(void);
void readregapps(void);
void readdimstyles(void);
void readvportenthdrs(void);
void writeblocks(void);
void writelayers(void);
void writelinetypes(void);
void writeshapefiles(void);
void writevports(void);
void writeviews(void);
void writeucss(void);
void writeregapps(void);
void writedimstyles(void);
void writevportenthdrs(void);
void setheaderdefaults(void);

void setheaderdefaults()
{
  short i;

  strcpy(adhd.acadmenu,"acad");
  adhd.angbase       =   0.0;
  adhd.angdir        =   0;
  adhd.attdia        =   0;
  adhd.attmode       =   1;
  adhd.attreq        =   1;
  adhd.aunits        =   0;
  adhd.auprec        =   0;
  adhd.axismode      =   0;
  adhd.axisunit[0]   =   0.0;
  adhd.axisunit[1]   =   0.0;
  adhd.backz         =   0.0;
  adhd.base[0]       =   0.0;
  adhd.base[1]       =   0.0;
  adhd.base[2]       =   0.0;
  adhd.blipmode      =   1;
  adhd.cecolor       =   256;
  adhd.celtype       =   256; /* bylayer */
  adhd.chamfera      =   0.0;
  adhd.chamferb      =   0.0;
  adhd.coords        =   0;
  adhd.curdimstyleno =   0;
  adhd.curlayerindex =   0;
  adhd.curstyleindex =   0;
  adhd.curucsindex   =   0;
  adhd.cvport        =   0;
  adhd.dimalt        =   0;
  adhd.dimaltd       =   2;
  adhd.dimaltf       =   25.4;
  adhd.dimapost[0]   =   '\0';
  adhd.dimaso        =   1;
  adhd.dimasz        =   0.18;
  adhd.dimblk[0]     =   '\0';
  adhd.dimblk1[0]    =   '\0';
  adhd.dimblk2[0]    =   '\0';
  adhd.dimcen        =   0.09;
  adhd.dimclrd       =   0;
  adhd.dimclre       =   0;
  adhd.dimclrt       =   0;
  adhd.dimdle        =   0.0;
  adhd.dimdli        =   0.38;
  adhd.dimexe        =   0.18;
  adhd.dimexo        =   0.0625;
  adhd.dimgap        =   0.09;
  adhd.dimlfac       =   1.0;
  adhd.dimlim        =   0;
  adhd.dimpost[0]    =   '\0';
  adhd.dimrnd        =   0.0;
  adhd.dimsah        =   0;
  adhd.dimscale      =   1.0;
  adhd.dimse1        =   0;
  adhd.dimse2        =   0;
  adhd.dimsho        =   1;
  adhd.dimsoxd       =   0;
  adhd.dimstyleindex =   0;
  adhd.dimtad        =   0;
  adhd.dimtfac       =   1.0;
  adhd.dimtih        =   1;
  adhd.dimtix        =   0;
  adhd.dimtm         =   0.0;
  adhd.dimtofl       =   0;
  adhd.dimtoh        =   1;
  adhd.dimtol        =   0;
  adhd.dimtp         =   0.0;
  adhd.dimtsz        =   0.0;
  adhd.dimtvp        =   0.0;
  adhd.dimtxt        =   0.18;
  adhd.dimzin        =   0;
  adhd.dragmode      =   2;
  adhd.elevation     =   0.0;
  adhd.extmin[0]     =   1.0e+20;
  adhd.extmax[0]     =  -1.0e+20;
  adhd.extmin[1]     =   1.0e+20;
  adhd.extmax[1]     =  -1.0e+20;
  adhd.extmin[2]     =   1.0e+20;
  adhd.extmax[2]     =  -1.0e+20;
  adhd.fastzoom      =   1;
  adhd.filletrad     =   0.0;
  adhd.fillmode      =   1;
  adhd.flatland      =   0;
  adhd.frontz        =   0.0;
  adhd.gridmode      =   0;
  adhd.gridunit[0]   =   0.0;
  adhd.gridunit[1]   =   0.0;
  adhd.enthandles    =   0;                  /* handles off */
  for (i=0; i<8; i++) adhd.enthandseed[i] = 0;  /* start at start */
  adhd.lenslength    =   50.0;
  adhd.limcheck      =   0;
  adhd.limmin[0]     =   0.0;
  adhd.limmax[0]     =   12.0;
  adhd.limmin[1]     =   0.0;
  adhd.limmax[1]     =   9.0;
  adhd.ltscale       =   1.0;
  adhd.lunits        =   2;
  adhd.luprec        =   4;
  adhd.maxactvp      =   16;
  adhd.mirrtext      =   1;
  adhd.orthomode     =   0;
  adhd.osmode        =   0;
  adhd.pdmode        =   0;
  adhd.pdsize        =   0.0;
  adhd.pelevation    =   0.0;
  adhd.pextmax[0]    =   -1.0E+20;
  adhd.pextmax[1]    =   -1.0E+20;
  adhd.pextmax[2]    =   -1.0E+20;
  adhd.pextmin[0]    =   -1.0E+20;
  adhd.pextmin[1]    =   -1.0E+20;
  adhd.pextmin[2]    =   -1.0E+20;
  adhd.pinsbase[0]   =   0.0;
  adhd.pinsbase[1]   =   0.0;
  adhd.pinsbase[2]   =   0.0;
  adhd.plimcheck     =   0;
  adhd.plimmax[0]    =   12.0;
  adhd.plimmax[1]    =   9.0;
  adhd.plimmin[0]    =   0.0;
  adhd.plimmin[1]    =   0.0;
  adhd.plinewid      =   0.0;
  adhd.pucsnameindex =   -1;
  adhd.pucsorg[0]    =   0.0;
  adhd.pucsorg[1]    =   0.0;
  adhd.pucsorg[2]    =   0.0;
  adhd.pucsxdir[0]   =   1.0;
  adhd.pucsxdir[1]   =   0.0;
  adhd.pucsxdir[2]   =   0.0;
  adhd.pucsydir[0]   =   0.0;
  adhd.pucsydir[1]   =   1.0;
  adhd.pucsydir[2]   =   0.0;
  adhd.qtextmode     =   0;
  adhd.regenmode     =   1;
  adhd.shadedge      =   3;
  adhd.shadedif      =   70;
  adhd.sketchinc     =   0.1;
  adhd.skpoly        =   0;
  adhd.snapang       =   0.0;
  adhd.snapbase[0]   =   0.0;
  adhd.snapbase[1]   =   0.0;
  adhd.snapisopair   =   0;
  adhd.snapmode      =   0;
  adhd.snapstyle     =   0;
  adhd.snapunit[0]   =   1.0;
  adhd.snapunit[1]   =   1.0;
  adhd.splframe      =   0;
  adhd.splinesegs    =   8;
  adhd.splinetype    =   6;
  adhd.surftab1      =   6;
  adhd.surftab2      =   6;
  adhd.surftype      =   6;
  adhd.surfu         =   6;
  adhd.surfv         =   6;
  adhd.target[0]     =   0.0;
  adhd.target[1]     =   0.0;
  adhd.target[2]     =   0.0;
  adhd.tdcreate1     =   0;
  adhd.tdcreate2     =   0;
  adhd.tdindwg1      =   0;
  adhd.tdindwg2      =   0;
  adhd.tdupdate1     =   0;
  adhd.tdupdate2     =   0;
  adhd.tdusrtimer1   =   0;
  adhd.tdusrtimer2   =   0;
  adhd.textsize      =   0.2;
  adhd.thickness     =   0.0;
  adhd.tilemode      =   1;
  adhd.tracewid      =   0.05;
  adhd.ucsflag       =   0;
  adhd.ucsicon       =   1;
  adhd.ucsname[0]    =   '\0';
  adhd.ucsorih[0]    =   0.0;
  adhd.ucsorih[1]    =   0.0;
  adhd.ucsorih[2]    =   0.0;
  adhd.ucsxdirh[0]   =   1.0;
  adhd.ucsxdirh[1]   =   0.0;
  adhd.ucsxdirh[2]   =   0.0;
  adhd.ucsydirh[0]   =   0.0;
  adhd.ucsydirh[1]   =   1.0;
  adhd.ucsydirh[2]   =   0.0;
  adhd.unitmode      =   0;
  for (i=0; i<5; i++) {
    adhd.useri[i]=0;
    adhd.userr[i]=0.0;
  }
  adhd.usrtimer      =   1;
  adhd.viewctr[0]    =   6.591288;
  adhd.viewctr[1]    =   4.579184;
  adhd.viewctr[2]    =   0.0;
  adhd.viewsize      =   9.158369;
  adhd.viewtwisthdr  =   0.0;
  adhd.visretain     =   0;
  adhd.vpointhdr[0]  =   0.0;
  adhd.vpointhdr[1]  =   0.0;
  adhd.vpointhdr[2]  =   1.0;
  adhd.worldview     =   1;
}

void readblocks()
/* read the blockheaders from drawings 0 and 1, eliminate duplicates */
{
  short i,j;

  block=NULL;
  blockmap=NULL;

    if ((adct.numblocksr[0]+adct.numblocksr[1])==0) return;
/*  if (((short)adct.numblocksr[0]+(short)adct.numblocksr[1])==0) return; */

  block=(struct _block *)malloc(((short)adct.numblocksr[0]+(short)adct.numblocksr[1])*sizeof(*block));
  if (block==NULL) {
    printf("Unable to allocate block array\n");
    exit(1);
  }
  blockmap=(short *)malloc(((short)adct.numblocksr[0]+(short)adct.numblocksr[1])*sizeof(short));
  if (blockmap==NULL) {
    printf("Unable to allocate block map array\n");
    exit(1);
  }
  adct.dwgno=0;
/* read blocks from drawing 0 */
  startblockheaderread();
  for (i=0; i<(short)adct.numblocksr[0]; i++) {
    readblockheader();
    block[i].blockflag=adtb.blkh.flag;
    block[i].purgedflag=adtb.blkh.purgedflag;
    strcpy(block[i].blockname,adtb.blkh.name);
    block[i].defpresent=adtb.blkh.defpresent;
    blockmap[i]=i;
  }

  adct.dwgno=1;
  startblockheaderread();
  blockcount=(short)adct.numblocksr[0];
  for (i=0; i<(short)adct.numblocksr[1]; i++) {
    readblockheader();
 /* for blocks, handle duplicates differently.  If you detect that a block with
    the same name already exists in the drawing, add an "X" to the end of this
    new block. */

    for (j=0; j<(short)adct.numblocksr[0]; j++) {
      if (!strcmp(block[j].blockname,adtb.blkh.name) &&
 /* do not cut dimension or hatch blocks */
           adtb.blkh.name[0]!='*') {
        if (strlen(adtb.blkh.name)<32) strcat(adtb.blkh.name,"X");
        else adtb.blkh.name[31]='X';
        break;
      }
    }
    block[blockcount].blockflag=adtb.blkh.flag;
    block[blockcount].purgedflag=adtb.blkh.purgedflag;
    strcpy(block[blockcount].blockname,adtb.blkh.name);
    block[blockcount].defpresent=adtb.blkh.defpresent;
    blockmap[i+(short)adct.numblocksr[0]]=blockcount;
    blockcount++;
  }
}

void readlayers()
/* read the layers from drawings 0 and 1, eliminate duplicates */
{
  short i,j,isthere;

  layer=NULL;
  layermap=NULL;

  layer=(struct _layer *)malloc(((short)adct.numlayersr[0]+(short)adct.numlayersr[1])*sizeof(*layer));
  if (layer==NULL) {
    printf("Unable to allocate layer array\n");
    exit(1);
  }
  layermap=(short *)malloc(((short)adct.numlayersr[0]+(short)adct.numlayersr[1])*sizeof(short));
  if (layermap==NULL) {
    printf("Unable to allocate layer map array\n");
    exit(1);
  }
  adct.dwgno=0;
/* read layers from drawing 0 */
  startlayerread();
  for (i=0; i<(short)adct.numlayersr[0]; i++) {
    readlayer();
    layer[i].purgedflag=adtb.lay.purgedflag;
    layer[i].layerflag=adtb.lay.flag;
    strcpy(layer[i].layername,adtb.lay.name);
    layer[i].layercolor=adtb.lay.color;
    layer[i].layerlinetype=adtb.lay.linetype;
    layermap[i]=i;
  }

  adct.dwgno=1;
  startlayerread();
  layercount=(short)adct.numlayersr[0];
  for (i=0; i<(short)adct.numlayersr[1]; i++) {
    readlayer();
/* now see if this layer has already been read.  If so, skip it */
    isthere=0;
    for (j=0; j<(short)adct.numlayersr[0]; j++) {
      if (!strcmp(layer[j].layername,adtb.lay.name)) {
        isthere=j+1;  /* make sure the flag is > 0 */
        break;
      }
    }
    if (isthere) layermap[i+(short)adct.numlayersr[0]]=isthere-1;
    else {
      layer[layercount].purgedflag   =adtb.lay.purgedflag;
      layer[layercount].layerflag    =adtb.lay.flag;
      strcpy(layer[layercount].layername,adtb.lay.name);
      layer[layercount].layercolor   =adtb.lay.color;
      layer[layercount].layerlinetype=adtb.lay.linetype;
      layermap[i+(short)adct.numlayersr[0]]=layercount;
      layercount++;
    }
  }
/*
  printf("Layer list\n\n");
  for (i=0; i<layercount; i++) {
    printf("Layer %3d: %-32s   Color %3d\n",i,layer[i].layername,layer[i].layercolor);
  }
*/
}

void copyvportinfo(short i)
{
  vport[i].purgedflag       =adtb.vport.purgedflag;
  vport[i].vportaspect      =adtb.vport.aspect;
  vport[i].vportbackclip    =adtb.vport.backclip;
  vport[i].vportcentx       =adtb.vport.center[0];
  vport[i].vportcenty       =adtb.vport.center[1];
  vport[i].vportfastzoom    =adtb.vport.fastzoom;
  vport[i].vportflag        =adtb.vport.flag;
  vport[i].vportfrontclip   =adtb.vport.frontclip;
  vport[i].vportgriddistx   =adtb.vport.griddist[0];
  vport[i].vportgriddisty   =adtb.vport.griddist[1];
  vport[i].vportgridmode    =adtb.vport.gridmode;
  vport[i].vportlenslength  =adtb.vport.lenslength;
  strcpy(vport[i].vportname,adtb.vport.name);
  vport[i].vportsnapbasex   =adtb.vport.snapbase[0];
  vport[i].vportsnapbasey   =adtb.vport.snapbase[1];
  vport[i].vportsnapdistx   =adtb.vport.snapdist[0];
  vport[i].vportsnapdisty   =adtb.vport.snapdist[1];
  vport[i].vportsnapisopair =adtb.vport.snapisopair;
  vport[i].vportsnapmode    =adtb.vport.snapmode;
  vport[i].vportsnaprot     =adtb.vport.snaprot;
  vport[i].vportsnapstyle   =adtb.vport.snapstyle;
  vport[i].vporttargetx     =adtb.vport.target[0];
  vport[i].vporttargety     =adtb.vport.target[1];
  vport[i].vporttargetz     =adtb.vport.target[2];
  vport[i].vportucsicon     =adtb.vport.ucsicon;
  vport[i].vportviewdirx    =adtb.vport.viewdir[0];
  vport[i].vportviewdiry    =adtb.vport.viewdir[1];
  vport[i].vportviewdirz    =adtb.vport.viewdir[2];
  vport[i].vportviewheight  =adtb.vport.viewheight;
  vport[i].vportviewmode    =adtb.vport.viewmode;
  vport[i].vportviewtwist   =adtb.vport.viewtwist;
  vport[i].vportzoomperc    =adtb.vport.zoomperc;
  vport[i].vportllx         =adtb.vport.ll[0];
  vport[i].vportlly         =adtb.vport.ll[1];
  vport[i].vporturx         =adtb.vport.ur[0];
  vport[i].vportury         =adtb.vport.ur[1];
}


void readvports()
/* read the vports from drawings 0 and 1, eliminate duplicates */
{
  short i,j,isthere;

  vport=NULL;
  vportmap=NULL;

  if (((short)adct.numvportsr[0]+(short)adct.numvportsr[1])==0) return;

  vport=malloc(((short)adct.numvportsr[0]+(short)adct.numvportsr[1])*sizeof(*vport));
  if (vport==NULL) {
    printf("Unable to allocate vport array\n");
    exit(1);
  }
  vportmap=malloc(((short)adct.numvportsr[0]+(short)adct.numvportsr[1])*sizeof(short));
  if (vportmap==NULL) {
    printf("Unable to allocate vportmap array\n");
    exit(1);
  }
  adct.dwgno=0;
/* read vports from drawing 0 */
  startvportread();
  for (i=0; i<(short)adct.numvportsr[0]; i++) {
    readvport();
    copyvportinfo(i);
    vportmap[i]=i;
  }

  adct.dwgno=1;
  startvportread();
  vportcount=(short)adct.numvportsr[0];
  for (i=0; i<(short)adct.numvportsr[1]; i++) {
    readvport();
/* now see if this vport has already been read.  If so, skip it */
    isthere=0;
    for (j=0; j<(short)adct.numvportsr[0]; j++) {
      if (!strcmp(vport[j].vportname,adtb.vport.name)) {
        isthere=j+1;  /* make sure the flag is > 0 */
        break;
      }
    }
    if (isthere) vportmap[i+(short)adct.numvportsr[0]]=isthere-1;
    else {
      copyvportinfo(vportcount);
      vportmap[i+(short)adct.numvportsr[0]] =vportcount;
      vportcount++;
    }
  }
}

void readviews()
/* read the views from drawings 0 and 1, eliminate duplicates */
{
  short i,j,isthere;

  view=NULL;
  viewmap=NULL;

  if (((short)adct.numviewsr[0]+(short)adct.numviewsr[1])==0) return;

  view=malloc(((short)adct.numviewsr[0]+(short)adct.numviewsr[1])*sizeof(*view));
  if (view==NULL) {
    printf("Unable to allocate view array\n");
    exit(1);
  }
  viewmap=malloc(((short)adct.numviewsr[0]+(short)adct.numviewsr[1])*sizeof(short));
  if (viewmap==NULL) {
    printf("Unable to allocate viewmap array\n");
    exit(1);
  }
  adct.dwgno=0;
/* read views from drawing 0 */
  startviewread();
  for (i=0; i<(short)adct.numviewsr[0]; i++) {
    readview();
    view[i].viewflag    =adtb.view.flag;
    strcpy(view[i].viewname,adtb.view.name);
    view[i].viewht      =adtb.view.ht;
    view[i].viewcenterx =adtb.view.center[0];
    view[i].viewcentery =adtb.view.center[1];
    view[i].viewwidth   =adtb.view.width;
    view[i].viewdirx    =adtb.view.dir[0];
    view[i].viewdiry    =adtb.view.dir[1];
    view[i].viewdirz    =adtb.view.dir[2];

    if (adct.ouracadverr SUBN>=ACAD10) {   /* the rel 10 view variables */
      view[i].viewbackclip    =adtb.view.backclip;
      view[i].viewflag2       =adtb.view.flag2;
      view[i].viewfrontclip   =adtb.view.frontclip;
      view[i].viewlenslength  =adtb.view.lenslength;
      view[i].viewtargetx     =adtb.view.target[0];
      view[i].viewtargety     =adtb.view.target[1];
      view[i].viewtargetz     =adtb.view.target[2];
      view[i].viewtwist       =adtb.view.twist;
      view[i].viewviewmode    =adtb.view.viewmode;
    }
    viewmap[i]=i;
  }

  adct.dwgno=1;
  startviewread();
  viewcount=(short)adct.numviewsr[0];
  for (i=0; i<(short)adct.numviewsr[1]; i++) {
    readview();
/* now see if this view has already been read.  If so, skip it */
    isthere=0;
    for (j=0; j<(short)adct.numviewsr[0]; j++) {
      if (!strcmp(view[j].viewname,adtb.view.name)) {
        isthere=j+1;  /* make sure the flag is > 0 */
        break;
      }
    }
    if (isthere) viewmap[i+(short)adct.numviewsr[0]]=isthere-1;
    else {
      view[viewcount].viewflag    =adtb.view.flag;
      strcpy(view[viewcount].viewname,adtb.view.name);
      view[viewcount].viewht      =adtb.view.ht;
      view[viewcount].viewcenterx =adtb.view.center[0];
      view[viewcount].viewcentery =adtb.view.center[1];
      view[viewcount].viewwidth   =adtb.view.width;
      view[viewcount].viewdirx    =adtb.view.dir[0];
      view[viewcount].viewdiry    =adtb.view.dir[1];
      view[viewcount].viewdirz    =adtb.view.dir[2];

      if (adct.ouracadverr SUBN>=ACAD10) {   /* the rel 10 view variables */
        view[viewcount].viewbackclip    =adtb.view.backclip;
        view[viewcount].viewflag2       =adtb.view.flag2;
        view[viewcount].viewfrontclip   =adtb.view.frontclip;
        view[viewcount].viewlenslength  =adtb.view.lenslength;
        view[viewcount].viewtargetx     =adtb.view.target[0];
        view[viewcount].viewtargety     =adtb.view.target[1];
        view[viewcount].viewtargetz     =adtb.view.target[2];
        view[viewcount].viewtwist       =adtb.view.twist;
        view[viewcount].viewviewmode    =adtb.view.viewmode;
      }
      viewmap[i+(short)adct.numviewsr[0]]=viewcount;
      viewcount++;
    }
  }
/*
  printf("view list\n\n");
  for (i=0; i<viewcount; i++) {
    printf("view %3d: %-32s   Color %3d\n",i,view[i].viewname,view[i].viewcolor);
  }
*/
}

void readucss()
/* read the ucss from drawings 0 and 1, eliminate duplicates */
{
  short i,j,isthere;

  ucs=NULL;
  ucsmap=NULL;

  if (((short)adct.numucsr[0]+(short)adct.numucsr[1])==0) return;

  ucs=malloc(((short)adct.numucsr[0]+(short)adct.numucsr[1])*sizeof(*ucs));
  if (ucs==NULL) {
    printf("Unable to allocate ucs array\n");
    exit(1);
  }
  ucsmap=malloc(((short)adct.numucsr[0]+(short)adct.numucsr[1])*sizeof(short));
  if (ucsmap==NULL) {
    printf("Unable to allocate ucsmap array\n");
    exit(1);
  }
  adct.dwgno=0;
/* read ucss from drawing 0 */
  startucsread();
  for (i=0; i<(short)adct.numucsr[0]; i++) {
    readucs();
    ucs[i].purgedflag =adtb.ucs.purgedflag;
    ucs[i].ucsflag   =adtb.ucs.flag;
    strcpy(ucs[i].ucsname,adtb.ucs.name);
    ucs[i].ucsorgx    =adtb.ucs.org[0];
    ucs[i].ucsorgy    =adtb.ucs.org[1];
    ucs[i].ucsorgz    =adtb.ucs.org[2];
    ucs[i].ucsxdirx   =adtb.ucs.xdir[0];
    ucs[i].ucsxdiry   =adtb.ucs.xdir[1];
    ucs[i].ucsxdirz   =adtb.ucs.xdir[2];
    ucs[i].ucsydirx   =adtb.ucs.ydir[0];
    ucs[i].ucsydiry   =adtb.ucs.ydir[1];
    ucs[i].ucsydirz   =adtb.ucs.ydir[2];
    ucsmap[i]=i;
  }

  adct.dwgno=1;
  startucsread();
  ucscount=(short)adct.numucsr[0];
  for (i=0; i<(short)adct.numucsr[1]; i++) {
    readucs();
/* now see if this ucs has already been read.  If so, skip it */
    isthere=0;
    for (j=0; j<(short)adct.numucsr[0]; j++) {
      if (!strcmp(ucs[j].ucsname,adtb.ucs.name)) {
        isthere=j+1;  /* make sure the flag is > 0 */
        break;
      }
    }
    if (isthere) ucsmap[i+(short)adct.numucsr[0]]=isthere-1;
    else {
      ucs[ucscount].purgedflag =adtb.ucs.purgedflag;
      ucs[ucscount].ucsflag   =adtb.ucs.flag;
      strcpy(ucs[ucscount].ucsname,adtb.ucs.name);
      ucs[ucscount].ucsorgx    =adtb.ucs.org[0];
      ucs[ucscount].ucsorgy    =adtb.ucs.org[1];
      ucs[ucscount].ucsorgz    =adtb.ucs.org[2];
      ucs[ucscount].ucsxdirx   =adtb.ucs.xdir[0];
      ucs[ucscount].ucsxdiry   =adtb.ucs.xdir[1];
      ucs[ucscount].ucsxdirz   =adtb.ucs.xdir[2];
      ucs[ucscount].ucsydirx   =adtb.ucs.ydir[0];
      ucs[ucscount].ucsydiry   =adtb.ucs.ydir[1];
      ucs[ucscount].ucsydirz   =adtb.ucs.ydir[2];
      ucsmap[i+(short)adct.numucsr[0]]=ucscount;
      ucscount++;
    }
  }
/*
  printf("ucs list\n\n");
  for (i=0; i<ucscount; i++) {
    printf("ucs %3d: %-32s   Color %3d\n",i,ucs[i].ucsname,ucs[i].ucscolor);
  }
*/
}

void readshapefiles()
/* read the shapes from drawings 0 and 1, eliminate duplicates */
{
  short i,j,isthere;

  shape=NULL;
  shapemap=NULL;

  if (((short)adct.numshapefilesr[0]+(short)adct.numshapefilesr[1])==0) return;

  shape=malloc(((short)adct.numshapefilesr[0]+(short)adct.numshapefilesr[1])*sizeof(*shape));
  if (shape==NULL) {
    printf("Unable to allocate shape array\n");
    exit(1);
  }
  shapemap=malloc(((short)adct.numshapefilesr[0]+(short)adct.numshapefilesr[1])*sizeof(short));
  if (shapemap==NULL) {
    printf("Unable to allocate shape map array\n");
    exit(1);
  }
  adct.dwgno=0;
/* read shapes from drawing 0 */
  startshaperead();
  for (i=0; i<(short)adct.numshapefilesr[0]; i++) {
    readshapefile();
    shape[i].purgedflag    =adtb.shape.purgedflag;
    shape[i].shapeflag     =adtb.shape.flag;
    strcpy(shape[i].shapename,adtb.shape.name);
    shape[i].shapeheight   =adtb.shape.height;
    shape[i].shapewidth    =adtb.shape.width;
    shape[i].shapeangle    =adtb.shape.angle;
    shape[i].shapeflag2    =adtb.shape.flag2;
    shape[i].lastshapeheight = adtb.shape.lastshapeheight;
    strcpy(shape[i].shapefile,adtb.shape.file);
    strcpy(shape[i].bigfontname,adtb.shape.bigfontname);
    shapemap[i]=i;
  }

  adct.dwgno=1;
  startshaperead();
  shapefilecount=(short)adct.numshapefilesr[0];
  for (i=0; i<(short)adct.numshapefilesr[1]; i++) {
    readshapefile();
/* now see if this shape has already been read.  If so, skip it */
    isthere=0;
    for (j=0; j<(short)adct.numshapefilesr[0]; j++) {
      if (!strcmp(shape[j].shapename,adtb.shape.name)) {
        isthere=j+1;  /* make sure the flag is > 0 */
        break;
      }
    }
    if (isthere) shapemap[i+(short)adct.numshapefilesr[0]]=isthere-1;
    else {
      shape[shapefilecount].purgedflag    =adtb.shape.purgedflag;
      shape[shapefilecount].shapeflag     =adtb.shape.flag;
      strcpy(shape[shapefilecount].shapename,adtb.shape.name);
      shape[shapefilecount].shapeheight   =adtb.shape.height;
      shape[shapefilecount].shapewidth    =adtb.shape.width;
      shape[shapefilecount].shapeangle    =adtb.shape.angle;
      shape[shapefilecount].shapeflag2    =adtb.shape.flag2;
      shape[shapefilecount].lastshapeheight = adtb.shape.lastshapeheight;
      strcpy(shape[shapefilecount].shapefile,adtb.shape.file);
      strcpy(shape[shapefilecount].bigfontname,adtb.shape.bigfontname);
      shapemap[i+(short)adct.numshapefilesr[0]]=shapefilecount;
      shapefilecount++;
    }
  }
}

void readlinetypes()
/* read the linetypes from drawings 0 and 1, eliminate duplicates */
{
  short i,j,isthere;

  linetype=NULL;
  linetypemap=NULL;

  if (((short)adct.numlinetypesr[0]+(short)adct.numlinetypesr[1])==0) return;

  linetype=malloc(((short)adct.numlinetypesr[0]+(short)adct.numlinetypesr[1])*sizeof(*linetype));
  if (linetype==NULL) {
    printf("Unable to allocate linetype array\n");
    exit(1);
  }
  linetypemap=malloc(((short)adct.numlinetypesr[0]+(short)adct.numlinetypesr[1])*sizeof(short));
  if (linetypemap==NULL) {
    printf("Unable to allocate linetype map array\n");
    exit(1);
  }
  adct.dwgno=0;
/* read linetypes from drawing 0 */
  startlinetyperead();
  for (i=0; i<(short)adct.numlinetypesr[0]; i++) {
    readlinetype();
    linetype[i].purgedflag      =adtb.ltype.purgedflag;
    linetype[i].ltflag          =adtb.ltype.flag;
    strcpy(linetype[i].linetypename,adtb.ltype.name);
    strcpy(linetype[i].linetypetext,adtb.ltype.text);
    linetype[i].numlinetypevals =adtb.ltype.numlinetypevals;
    linetype[i].patternlength   =adtb.ltype.patternlength;
    for (j=0; j<adtb.ltype.numlinetypevals; j++)
      linetype[i].linetypeval[j]=adtb.ltype.val[j];
    linetypemap[i]=i;
  }

  adct.dwgno=1;
  startlinetyperead();
  linetypecount=(short)adct.numlinetypesr[0];
  for (i=0; i<(short)adct.numlinetypesr[1]; i++) {
    readlinetype();
/* now see if this linetype has already been read.  If so, skip it */
    isthere=0;
    for (j=0; j<(short)adct.numlinetypesr[0]; j++) {
      if (!strcmp(linetype[j].linetypename,adtb.ltype.name)) {
        isthere=j+1;  /* make sure the flag is > 0 */
        break;
      }
    }
    if (isthere) linetypemap[i+(short)adct.numlinetypesr[0]]=isthere-1;
    else {
      linetype[linetypecount].purgedflag      =adtb.ltype.purgedflag;
      linetype[linetypecount].ltflag          =adtb.ltype.flag;
      strcpy(linetype[linetypecount].linetypename,adtb.ltype.name);
      strcpy(linetype[linetypecount].linetypetext,adtb.ltype.text);
      linetype[linetypecount].numlinetypevals =adtb.ltype.numlinetypevals;
      linetype[linetypecount].patternlength   =adtb.ltype.patternlength;
      for (j=0; j<adtb.ltype.numlinetypevals; j++)
        linetype[linetypecount].linetypeval[j]=adtb.ltype.val[j];
      linetypemap[i+(short)adct.numlinetypesr[0]]=linetypecount;
      linetypecount++;
    }
  }
}

void readregapps()
/* read the registered applications from drawings 0 and 1, eliminate duplicates */
{
  short i,j,isthere;

  regapp=NULL;
  regappmap=NULL;

  if (((short)adct.numregappsr[0]+(short)adct.numregappsr[1])==0) return;

  regapp=(struct _regapp *)malloc(((short)adct.numregappsr[0]+(short)adct.numregappsr[1])*sizeof(*regapp));
  if (regapp==NULL) {
    printf("Unable to allocate regapp array\n");
    exit(1);
  }
  regappmap=(short *)malloc(((short)adct.numregappsr[0]+(short)adct.numregappsr[1])*sizeof(short));
  if (regappmap==NULL) {
    printf("Unable to allocate regapp map array\n");
    exit(1);
  }
  adct.dwgno=0;
/* read regapps from drawing 0 */
  startregappread();
  for (i=0; i<(short)adct.numregappsr[0]; i++) {
    readregapp();
    regapp[i].regappflag=adtb.app.flag;
    strcpy(regapp[i].regappname,adtb.app.name);
    regappmap[i]=i;
  }

  adct.dwgno=1;
  startregappread();
  regappcount=(short)adct.numregappsr[0];
  for (i=0; i<(short)adct.numregappsr[1]; i++) {
    readregapp();
/* now see if this regapp has already been read.  If so, skip it */
    isthere=0;
    for (j=0; j<(short)adct.numregappsr[0]; j++) {
      if (!strcmp(regapp[j].regappname,adtb.app.name)) {
        isthere=j+1;  /* make sure the flag is > 0 */
        break;
      }
    }
    if (isthere) regappmap[i+(short)adct.numregappsr[0]]=isthere-1;
    else {
      regapp[regappcount].regappflag    =adtb.app.flag;
      strcpy(regapp[regappcount].regappname,adtb.app.name);
      regappmap[i+(short)adct.numregappsr[0]]=regappcount;
      regappcount++;
    }
  }
/*
  printf("regapp list\n\n");
  for (i=0; i<regappcount; i++) {
    printf("regapp %3d: %-32s\n",i,regapp[i].regappname);
  }
*/
}

void copydimstyleinfo(short i)
{
  dimstyle[i].dimstyleflag=adtb.dimst.flag;
  strcpy(dimstyle[i].dimstylename,adtb.dimst.name);
  dimstyle[i].dsdimscale =adtb.dimst.dimscale;
  dimstyle[i].dsdimasz   =adtb.dimst.dimasz;
  dimstyle[i].dsdimexo   =adtb.dimst.dimexo;
  dimstyle[i].dsdimdli   =adtb.dimst.dimdli;
  dimstyle[i].dsdimexe   =adtb.dimst.dimexe;
  dimstyle[i].dsdimrnd   =adtb.dimst.dimrnd;
  dimstyle[i].dsdimdle   =adtb.dimst.dimdle;
  dimstyle[i].dsdimtp    =adtb.dimst.dimtp;
  dimstyle[i].dsdimtm    =adtb.dimst.dimtm;
  dimstyle[i].dsdimtxt   =adtb.dimst.dimtxt;
  dimstyle[i].dsdimcen   =adtb.dimst.dimcen;
  dimstyle[i].dsdimtsz   =adtb.dimst.dimtsz;
  dimstyle[i].dsdimaltf  =adtb.dimst.dimaltf;
  dimstyle[i].dsdimlfac  =adtb.dimst.dimlfac;
  dimstyle[i].dsdimtvp   =adtb.dimst.dimtvp;
  dimstyle[i].dsdimtol   =adtb.dimst.dimtol;
  dimstyle[i].dsdimlim   =adtb.dimst.dimlim;
  dimstyle[i].dsdimtih   =adtb.dimst.dimtih;
  dimstyle[i].dsdimtoh   =adtb.dimst.dimtoh;
  dimstyle[i].dsdimse1   =adtb.dimst.dimse1;
  dimstyle[i].dsdimse2   =adtb.dimst.dimse2;
  dimstyle[i].dsdimtad   =adtb.dimst.dimtad;
  dimstyle[i].dsdimzin   =adtb.dimst.dimzin;
  dimstyle[i].dsdimalt   =adtb.dimst.dimalt;
  dimstyle[i].dsdimaltd  =adtb.dimst.dimaltd;
  dimstyle[i].dsdimtofl  =adtb.dimst.dimtofl;
  dimstyle[i].dsdimsah   =adtb.dimst.dimsah;
  dimstyle[i].dsdimtix   =adtb.dimst.dimtix;
  dimstyle[i].dsdimsoxd  =adtb.dimst.dimsoxd;
  memcpy(dimstyle[i].dsdimpost,adtb.dimst.dimpost,16);
  memcpy(dimstyle[i].dsdimapost,adtb.dimst.dimapost,16);
  memcpy(dimstyle[i].dsdimblk,adtb.dimst.dimblk,33);
  memcpy(dimstyle[i].dsdimblk1,adtb.dimst.dimblk1,33);
  memcpy(dimstyle[i].dsdimblk2,adtb.dimst.dimblk2,33);
  dimstyle[i].dsdimclrd  =adtb.dimst.dimclrd;
  dimstyle[i].dsdimclre  =adtb.dimst.dimclre;
  dimstyle[i].dsdimclrt  =adtb.dimst.dimclrt;
  dimstyle[i].dsdimtfac  =adtb.dimst.dimtfac;
  dimstyle[i].dsdimgap   =adtb.dimst.dimgap;
}

void readdimstyles()
/* read the dimension styles from drawings 0 and 1, eliminate duplicates */
{
  short i,j,isthere;

  dimstyle=NULL;
  dimstylemap=NULL;

  if (((short)adct.numdimstylesr[0]+(short)adct.numdimstylesr[1])==0) return;

  dimstyle=(struct _dimstyle *)malloc(((short)adct.numdimstylesr[0]+(short)adct.numdimstylesr[1])*sizeof(*dimstyle));
  if (dimstyle==NULL) {
    printf("Unable to allocate dimstyle array\n");
    exit(1);
  }
  dimstylemap=(short *)malloc(((short)adct.numdimstylesr[0]+(short)adct.numdimstylesr[1])*sizeof(short));
  if (dimstylemap==NULL) {
    printf("Unable to allocate dimstylemap array\n");
    exit(1);
  }
  adct.dwgno=0;
/* read dimstyles from drawing 0 */
  startdimstyleread();
  for (i=0; i<(short)adct.numdimstylesr[0]; i++) {
    readdimstyle();
    copydimstyleinfo(i);
    dimstylemap[i]=i;
  }

  adct.dwgno=1;
  startdimstyleread();
  dimstylecount=(short)adct.numdimstylesr[0];
  for (i=0; i<(short)adct.numdimstylesr[1]; i++) {
    readdimstyle();
/* now see if this dimstyle has already been read.  If so, skip it */
    isthere=0;
    for (j=0; j<(short)adct.numdimstylesr[0]; j++) {
      if (!strcmp(dimstyle[j].dimstylename,adtb.dimst.name)) {
        isthere=j+1;  /* make sure the flag is > 0 */
        break;
      }
    }
    if (isthere) dimstylemap[i+(short)adct.numdimstylesr[0]]=isthere-1;
    else {
      copydimstyleinfo(dimstylecount);
      dimstylemap[i+(short)adct.numdimstylesr[0]]=dimstylecount;
      dimstylecount++;
    }
  }
/*
  printf("dimstyle list\n\n");
  for (i=0; i<dimstylecount; i++) {
    printf("dimstyle %3d: %-32s\n",i,dimstyle[i].dimstylename);
  }
*/
}

void readvportenthdrs()
/* read the vportenthdrs from drawings 0 and 1, eliminate duplicates */
{
  short i;

  vportenthdr=NULL;
  vportenthdrmap=NULL;

  if (((short)adct.numvportenthdrsr[0]+(short)adct.numvportenthdrsr[1])==0) return;

  vportenthdr=(struct _vportenthdr *)malloc(((short)adct.numvportenthdrsr[0]+(short)adct.numvportenthdrsr[1])*sizeof(*vportenthdr));
  if (vportenthdr==NULL) {
    printf("Unable to allocate vportenthdr array\n");
    exit(1);
  }
  vportenthdrmap=(short *)malloc(((short)adct.numvportenthdrsr[0]+(short)adct.numvportenthdrsr[1])*sizeof(short));
  if (vportenthdrmap==NULL) {
    printf("Unable to allocate vportenthdrmap array\n");
    exit(1);
  }
  adct.dwgno=0;
/* read vportenthdrs from drawing 0 */
  startvportenthdrread();
  for (i=0; i<(short)adct.numvportenthdrsr[0]; i++) {
    readvportenthdr();
    vportenthdr[i].vportentflag=aden.vpent.flag;
    strcpy(vportenthdr[i].vportentname,aden.vpent.name);
    vportenthdr[i].vportentstackval=aden.vpent.stackval;
    vportenthdrmap[i]=i;
  }

  adct.dwgno=1;
  startvportenthdrread();
  readvportenthdr();   /* skip over the dummy first entry */
  vportenthdrcount=(short)adct.numvportenthdrsr[0];
  for (i=1; i<(short)adct.numvportenthdrsr[1]; i++) {  /* 1 less for dummy */
    readvportenthdr();
    vportenthdr[vportenthdrcount].vportentflag    =aden.vpent.flag;
    strcpy(vportenthdr[vportenthdrcount].vportentname,aden.vpent.name);
    vportenthdr[vportenthdrcount].vportentstackval=aden.vpent.stackval;
    vportenthdrmap[i+(short)adct.numvportenthdrsr[0]]=vportenthdrcount;
    vportenthdrcount++;
  }
}

void writeblocks()
{
  short i;

  startblockheaderwrite();
  for (i=0; i<blockcount; i++) {
    adtb.blkh.flag=block[i].blockflag;
    adtb.blkh.purgedflag=block[i].purgedflag;
    strcpy(adtb.blkh.name,block[i].blockname);
    adtb.blkh.defpresent=block[i].defpresent;
    writeblockheader();
  }
}

void writelayers()
{
  short i;

  startlayerwrite();
  for (i=0; i<layercount; i++) {
    adtb.lay.purgedflag=layer[i].purgedflag;
    adtb.lay.flag =layer[i].layerflag;
    strcpy(adtb.lay.name,layer[i].layername);
    adtb.lay.color=layer[i].layercolor;
    adtb.lay.linetype=layer[i].layerlinetype;
    writelayer();
  }
}

void writeshapefiles()
{
  short i;

  startshapewrite();
  for (i=0; i<shapefilecount; i++) {
    adtb.shape.purgedflag=shape[i].purgedflag;
    adtb.shape.flag=shape[i].shapeflag;
    strcpy(adtb.shape.name,shape[i].shapename);
    adtb.shape.height=shape[i].shapeheight;
    adtb.shape.width=shape[i].shapewidth;
    adtb.shape.angle=shape[i].shapeangle;
    adtb.shape.flag2=shape[i].shapeflag2;
    adtb.shape.lastshapeheight=shape[i].lastshapeheight;
    strcpy(adtb.shape.file,shape[i].shapefile);
    strcpy(adtb.shape.bigfontname,shape[i].bigfontname);
    writeshapefile();
  }
}

void writelinetypes()
{
  short i,j;

  startlinetypewrite();
  for (i=0; i<linetypecount; i++) {
    adtb.ltype.purgedflag=linetype[i].purgedflag;
    adtb.ltype.flag=linetype[i].ltflag;
    strcpy(adtb.ltype.name,linetype[i].linetypename);
    strcpy(adtb.ltype.text,linetype[i].linetypetext);
    adtb.ltype.numlinetypevals=linetype[i].numlinetypevals ;
    adtb.ltype.patternlength=linetype[i].patternlength;
    for (j=0; j<adtb.ltype.numlinetypevals; j++)
      adtb.ltype.val[j]=linetype[i].linetypeval[j];
    writelinetype();
  }
}

void writeviews()
{
  short i;

  startviewwrite();
  for (i=0; i<viewcount; i++) {
    adtb.view.flag=    view[i].viewflag;
    strcpy(adtb.view.name,view[i].viewname);
    adtb.view.ht=        view[i].viewht;
    adtb.view.center[0]= view[i].viewcenterx;
    adtb.view.center[1]= view[i].viewcentery;
    adtb.view.width=     view[i].viewwidth;
    adtb.view.dir[0]=    view[i].viewdirx;
    adtb.view.dir[1]=    view[i].viewdiry;
    adtb.view.dir[2]=    view[i].viewdirz;

    if (adct.ouracadverw[0]>=ACAD10) {   /* the rel 10 view variables */
      adtb.view.backclip=   view[i].viewbackclip;
      adtb.view.flag2=      view[i].viewflag2;
      adtb.view.frontclip=  view[i].viewfrontclip;
      adtb.view.lenslength= view[i].viewlenslength;
      adtb.view.target[0]=  view[i].viewtargetx;
      adtb.view.target[1]=  view[i].viewtargety;
      adtb.view.target[2]=  view[i].viewtargetz;
      adtb.view.twist=      view[i].viewtwist;
      adtb.view.viewmode=   view[i].viewviewmode;
    }
    writeview();
  }
}

void writeucss()
{
  short i;

  startucswrite();
  for (i=0; i<ucscount; i++) {
    adtb.ucs.purgedflag= ucs[i].purgedflag;
    adtb.ucs.flag=   ucs[i].ucsflag;
    strcpy(adtb.ucs.name,ucs[i].ucsname);
    adtb.ucs.org[0]=  ucs[i].ucsorgx;
    adtb.ucs.org[1]=  ucs[i].ucsorgy;
    adtb.ucs.org[2]=  ucs[i].ucsorgz;
    adtb.ucs.xdir[0]= ucs[i].ucsxdirx;
    adtb.ucs.xdir[1]= ucs[i].ucsxdiry;
    adtb.ucs.xdir[2]= ucs[i].ucsxdirz;
    adtb.ucs.ydir[0]= ucs[i].ucsydirx;
    adtb.ucs.ydir[1]= ucs[i].ucsydiry;
    adtb.ucs.ydir[2]= ucs[i].ucsydirz;
    writeucs();
  }
}

void writevports()
{
  short i;

  startvportwrite();
  for (i=0; i<vportcount; i++) {
    adtb.vport.purgedflag= vport[i].purgedflag;
    adtb.vport.aspect=      vport[i].vportaspect;
    adtb.vport.backclip=    vport[i].vportbackclip;
    adtb.vport.center[0]=   vport[i].vportcentx;
    adtb.vport.center[1]=   vport[i].vportcenty;
    adtb.vport.fastzoom=    vport[i].vportfastzoom;
    adtb.vport.flag=        vport[i].vportflag;
    adtb.vport.frontclip=   vport[i].vportfrontclip;
    adtb.vport.griddist[0]= vport[i].vportgriddistx;
    adtb.vport.griddist[1]= vport[i].vportgriddisty;
    adtb.vport.gridmode=    vport[i].vportgridmode;
    adtb.vport.lenslength=  vport[i].vportlenslength;
    strcpy(adtb.vport.name,vport[i].vportname);
    adtb.vport.snapbase[0]= vport[i].vportsnapbasex;
    adtb.vport.snapbase[1]= vport[i].vportsnapbasey;
    adtb.vport.snapdist[0]= vport[i].vportsnapdistx;
    adtb.vport.snapdist[1]= vport[i].vportsnapdisty;
    adtb.vport.snapisopair= vport[i].vportsnapisopair;
    adtb.vport.snapmode=    vport[i].vportsnapmode;
    adtb.vport.snaprot=     vport[i].vportsnaprot;
    adtb.vport.snapstyle=   vport[i].vportsnapstyle;
    adtb.vport.target[0]=   vport[i].vporttargetx;
    adtb.vport.target[1]=   vport[i].vporttargety;
    adtb.vport.target[2]=   vport[i].vporttargetz;
    adtb.vport.ucsicon=     vport[i].vportucsicon;
    adtb.vport.viewdir[0]=  vport[i].vportviewdirx;
    adtb.vport.viewdir[1]=  vport[i].vportviewdiry;
    adtb.vport.viewdir[2]=  vport[i].vportviewdirz;
    adtb.vport.viewheight=  vport[i].vportviewheight;
    adtb.vport.viewmode=    vport[i].vportviewmode;
    adtb.vport.viewtwist=   vport[i].vportviewtwist;
    adtb.vport.zoomperc=    vport[i].vportzoomperc;
    adtb.vport.ll[0]=       vport[i].vportllx;
    adtb.vport.ll[1]=       vport[i].vportlly;
    adtb.vport.ur[0]=       vport[i].vporturx;
    adtb.vport.ur[1]=       vport[i].vportury;
    writevport();
  }
}


void writeregapps()
{
  short i;

  startregappwrite();
  for (i=0; i<regappcount; i++) {
    adtb.app.flag=regapp[i].regappflag;
    memcpy(adtb.app.name,regapp[i].regappname,32);
    writeregapp();
  }
}

void writedimstyles()
{
  short i;

  startdimstylewrite();
  for (i=0; i<dimstylecount; i++) {
    adtb.dimst.flag=dimstyle[i].dimstyleflag;
    strcpy(adtb.dimst.name,dimstyle[i].dimstylename);
    adtb.dimst.dimscale=dimstyle[i].dsdimscale;
    adtb.dimst.dimasz=dimstyle[i].dsdimasz;
    adtb.dimst.dimexo=dimstyle[i].dsdimexo;
    adtb.dimst.dimdli=dimstyle[i].dsdimdli;
    adtb.dimst.dimexe=dimstyle[i].dsdimexe;
    adtb.dimst.dimrnd=dimstyle[i].dsdimrnd;
    adtb.dimst.dimdle=dimstyle[i].dsdimdle;
    adtb.dimst.dimtp=dimstyle[i].dsdimtp;
    adtb.dimst.dimtm=dimstyle[i].dsdimtm;
    adtb.dimst.dimtxt=dimstyle[i].dsdimtxt;
    adtb.dimst.dimcen=dimstyle[i].dsdimcen;
    adtb.dimst.dimtsz=dimstyle[i].dsdimtsz;
    adtb.dimst.dimaltf=dimstyle[i].dsdimaltf;
    adtb.dimst.dimlfac=dimstyle[i].dsdimlfac;
    adtb.dimst.dimtvp=dimstyle[i].dsdimtvp;
    adtb.dimst.dimtol=dimstyle[i].dsdimtol;
    adtb.dimst.dimlim=dimstyle[i].dsdimlim;
    adtb.dimst.dimtih=dimstyle[i].dsdimtih;
    adtb.dimst.dimtoh=dimstyle[i].dsdimtoh;
    adtb.dimst.dimse1=dimstyle[i].dsdimse1;
    adtb.dimst.dimse2=dimstyle[i].dsdimse2;
    adtb.dimst.dimtad=dimstyle[i].dsdimtad;
    adtb.dimst.dimzin=dimstyle[i].dsdimzin;
    adtb.dimst.dimalt=dimstyle[i].dsdimalt;
    adtb.dimst.dimaltd=dimstyle[i].dsdimaltd;
    adtb.dimst.dimtofl=dimstyle[i].dsdimtofl;
    adtb.dimst.dimsah=dimstyle[i].dsdimsah;
    adtb.dimst.dimtix=dimstyle[i].dsdimtix;
    adtb.dimst.dimsoxd=dimstyle[i].dsdimsoxd;
    memcpy(adtb.dimst.dimpost,dimstyle[i].dsdimpost,16);
    memcpy(adtb.dimst.dimapost,dimstyle[i].dsdimapost,16);
    memcpy(adtb.dimst.dimblk,dimstyle[i].dsdimblk,33);
    memcpy(adtb.dimst.dimblk1,dimstyle[i].dsdimblk1,33);
    memcpy(adtb.dimst.dimblk2,dimstyle[i].dsdimblk2,33);
    adtb.dimst.dimclrd=dimstyle[i].dsdimclrd;
    adtb.dimst.dimclre=dimstyle[i].dsdimclre;
    adtb.dimst.dimclrt=dimstyle[i].dsdimclrt;
    adtb.dimst.dimtfac=dimstyle[i].dsdimtfac;
    adtb.dimst.dimgap=dimstyle[i].dsdimgap;
    writedimstyle();
  }
}

void writevportenthdrs()
{
  short i;

  startvportenthdrwrite();
  for (i=0; i<vportenthdrcount; i++) {
    aden.vpent.flag=vportenthdr[i].vportentflag;
    strcpy(aden.vpent.name,vportenthdr[i].vportentname);
    aden.vpent.stackval=vportenthdr[i].vportentstackval;
    writevportenthdr(i);
  }
}


void process(infile1,infile2,outfile)
char infile1[],infile2[],outfile[];
{
  short i;
  long ec;

  adct.dwgno=0;

  if (!initializewrite(outfile,4096)) {           /* initialize output */
    printf("Error opening output file %s\n",outfile);
    exit(1);
  }

  if (!initializeread(infile1,4096,4096,4096)) {      /* initialize input */
    printf("Error opening input file %s\n",infile1);
    exit(1);
  }

  adct.dwgno=1;

  if (!initializeread(infile2,4096,4096,4096)) {      /* initialize input */
    printf("Error opening input file %s\n",infile2);
    exit(1);
  }

  adct.dwgno=0;

  adct.copymode[0]=0;
  printf("Copying header\n");
  setheaderdefaults();
  if (!readheader()) {
    printf("%s -- Invalid AutoCAD version\n",infile1);
    terminateread();
    terminatewrite();
    return;
  }

/* must run setoutputversion AFTER readheader for dwg 0 */
  setoutputversion(ACAD11);

  adhd.enthandles=0;  /* disable handles */

/* write header from infile1 to outfile */
  writeheader();

/* read other header */
  adct.dwgno=1;
  readheader();
  readblocks();
  readlayers();
  readshapefiles();
  readlinetypes();
  readviews();
  readucss();
  readvports();
  readregapps();
  readdimstyles();
  readvportenthdrs();

  adct.dwgno=0;

  ec=0;
/* copy entities from drawing 0 to output file */
  startentityread();
  startentitywrite();
  do {
    if ((ec % 100) == 0)  printf("\rCopying entities from file 0   %ld",ec);
    adenhd.extrusion[0]=adenhd.extrusion[1]=adenhd.extrusion[2]=0.0;
    returnval=readentity1();
    if (returnval==1 && adenhd.enttype!='\x12') {
      writeentity1();
      if (adenhd.xddatapresent) {
        startextendeddataread();
        startextendeddatawrite();
        while (readextendeddata()) writeextendeddata();
      }
      readentity2();
      writeentity2();
      emitentity();
    }
    ec++;
  } while (returnval==1);

/* copy entities from drawing 1 to output file */
  printf("\n");
  adct.dwgno=1;
  startentityread();
  ec=0;
  do {
    if ((ec % 100) == 0) printf("\rCopying entities from file 1   %ld",ec);
    adenhd.extrusion[0]=adenhd.extrusion[1]=adenhd.extrusion[2]=0.0;
    adct.dwgno=1;
    returnval=readentity1();
    adct.dwgno=0;
    if (returnval==1 && adenhd.enttype!='\x12') {
      writeentity1();
      adct.dwgno=1;
      if (adenhd.xddatapresent) {
        startextendeddataread();
        adct.dwgno=0;
        startextendeddatawrite();
        adct.dwgno=1;
        while (readextendeddata()) {
          adct.dwgno=0;
          writeextendeddata();
          adct.dwgno=1;
        }
      }
      readentity2();
      adct.dwgno=0;
/* change layerindex, etc to new scheme */
    adenhd.layerindex=layermap[adenhd.layerindex+adct.numlayersr[0]];
    if (adenhd.enttype==14)  /* insert */    
      aden.insert.blockno=blockmap[aden.insert.blockno+adct.numblocksr[0]];
    if (adenhd.enttype==23)  /* asso dim */
      aden.dim.dimblkno=blockmap[aden.dim.dimblkno+adct.numblocksr[0]];
      writeentity2();
      emitentity();
    }
    ec++;
  } while (returnval==1);

  printf("\nCopying tables\n");

  adct.dwgno=0;

  writeblocks();
  writelayers();
  writeshapefiles();
  writelinetypes();
  writeviews();
  writeucss();
  writevports();
  writeregapps();
  writedimstyles();
  writevportenthdrs();

  printf("Copying block definitions from drawing 0\n");
  adct.dwgno=0;
  startblockdefwrite();
  startblockheaderread();

  for (i=0; i<(short)adct.numblocksr[0]; i++) {
    initializeblockdef((long)i);
    readblockheader();   /* gives block name, which we need */
                             /* these flags come from the header !!! */
    if (!adtb.blkh.purgedflag || adtb.blkh.defpresent) {
      startblockdefread();
      do {                          /* read block def ent, then rest of block */
        readentity1();               /* read next entity */
        writeentity1();              /* then write it out */
        if (adenhd.xddatapresent) {
          startextendeddataread();
          startextendeddatawrite();
          while (readextendeddata()) writeextendeddata();
        }
        readentity2();
        writeentity2();
        emitentity();
      }
      while (adenhd.enttype!='\x0D');
      endblockdefread();
    }
  }

  printf("Copying block definitions from drawing 1\n");
  adct.dwgno=1;
  startblockheaderread();

  for (i=(short)adct.numblocksr[0]; i<(short)adct.numblocksr[0]+(short)adct.numblocksr[1]; i++) {
    adct.dwgno=0;
    initializeblockdef((long)i);
    adct.dwgno=1;
    readblockheader();   /* gives block name, which we need */
                             /* these flags come from the header !!! */
    if (!adtb.blkh.purgedflag || adtb.blkh.defpresent) {
      adct.dwgno=1;
      startblockdefread();
      do {                          /* read block def ent, then rest of block */
        adct.dwgno=1;
        readentity1();               /* read next entity */
        adct.dwgno=0;
        writeentity1();
        adct.dwgno=1;
        if (adenhd.xddatapresent) {
          startextendeddataread();
          adct.dwgno=0;
          startextendeddatawrite();
          adct.dwgno=1;
          while (readextendeddata()) {
            adct.dwgno=0;
            writeextendeddata();
            adct.dwgno=1;
          }
        }
        readentity2();
        adct.dwgno=0;
        /* change layerindex to new scheme */
        adenhd.layerindex=layermap[adenhd.layerindex+adct.numlayersr[0]];
        if (adenhd.enttype==14)  /* insert */    
          aden.insert.blockno=blockmap[aden.insert.blockno+adct.numblocksr[0]];
        if (adenhd.enttype==23)  /* asso dim */
          aden.dim.dimblkno=blockmap[aden.dim.dimblkno+adct.numblocksr[0]];
        writeentity2();
        emitentity();
      }
      while (adenhd.enttype!='\x0D');
      adct.dwgno=1;
      endblockdefread();
    }
  }

  printf("Done\n");

  adct.dwgno=0;
  terminateread();
  terminatewrite();

  adct.dwgno=1;
  terminateread();

  if (block!=NULL)          free(block);
  if (blockmap!=NULL)       free(blockmap);
  if (layer!=NULL)          free(layer);
  if (layermap!=NULL)       free(layermap);
  if (shape!=NULL)          free(shape);
  if (shapemap!=NULL)       free(shapemap);
  if (linetype!=NULL)       free(linetype);
  if (linetypemap!=NULL)    free(linetypemap);
  if (view!=NULL)           free(view);
  if (viewmap!=NULL)        free(viewmap);
  if (ucs!=NULL)            free(ucs);
  if (ucsmap!=NULL)         free(ucsmap);
  if (vport!=NULL)          free(vport);
  if (vportmap!=NULL)       free(vportmap);
  if (regapp!=NULL)         free(regapp);
  if (regappmap!=NULL)      free(regappmap);
  if (dimstyle!=NULL)       free(dimstyle);
  if (dimstylemap!=NULL)    free(dimstylemap);
  if (vportenthdr!=NULL)    free(vportenthdr);
  if (vportenthdrmap!=NULL) free(vportenthdrmap);
}

void main(argc,argv)
int argc;
char *argv[];
{
  short i;

  adct.dwgno=0;

  initad();

  printf("AUTOCOMB -- AUTODIRECT 2 example program\n");
  printf("Copyright (C) 1990 Stephen M. Richards\n");

  if (argc<4) {
    printf("Usage: autocomb infile1 infile2 outfile\n");
    exit(1);
  }
  process(argv[1],argv[2],argv[3]);
}
