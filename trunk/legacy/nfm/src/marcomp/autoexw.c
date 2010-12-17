
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* AUTOEXW.C --
   This is an example of a simple program to write an AutoCAD drawing file.
Please use this program as a guide for designing your own.  */

/* Note that the type conversions from long to short for such values as
   numlayers, numblocks etc. limit the number of these entries that can
   be processed to 32768.  This should work for most applications; you can
   always use counters that are long ints instead of the short we have used
   to get the full range */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
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
#include "adwproto.h"

#define pi 3.141592653589793

short returnval;
double tdcreate,tdupdate,tdusrtimer,tdindwg;

/* Function prototypes */
#ifdef PROTOTYPES
double degreestoradians(double degrees);
void setheaderdefaults(void);
void setupdefaultviewport(void);
void process(char outfile[]);
void main(int argc,char *argv[]);
#else
double degreestoradians();
void setheaderdefaults();
void setupdefaultviewport();
void process();
void main();
#endif

double degreestoradians(degrees)
double degrees;
{
  return(degrees*pi/180.0);
}

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
  adhd.cyclekeep     =   5;
  adhd.cyclecurr     =   1;
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
  adhd.extmin[0]     =   1.0e+20;
  adhd.extmax[0]     =  -1.0e+20;
  adhd.fastzoom      =   1;
  adhd.filletrad     =   0.0;
  adhd.fillmode      =   1;
  adhd.flatland      =   0;
  adhd.frontz        =   0.0;
  adhd.gridmode      =   0;
  adhd.gridunit[0]   =   0.0;
  adhd.gridunit[1]   =   0.0;
  adhd.enthandles    =   1;                  /* allow handles */
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

void setupdefaultviewport()
{
/* under Release 10, the initial display takes on the characteristics of
   the default viewport */
  strcpy(adtb.vport.name,"*ACTIVE");
  adtb.vport.flag       =0;
  adtb.vport.ll[0]      =0.0;  /* the area of the screen allocated to the vport */
  adtb.vport.ll[1]      =0.0;
  adtb.vport.ur[0]      =1.0;
  adtb.vport.ur[1]      =1.0;
  adtb.vport.target[0]  =0.0;
  adtb.vport.target[1]  =0.0;
  adtb.vport.target[2]  =0.0;
  adtb.vport.viewdir[0] =0.0;
  adtb.vport.viewdir[1] =0.0;
  adtb.vport.viewdir[2] =1.0;
  adtb.vport.snaprot    =0.0;
  adtb.vport.viewheight =76.0;
  adtb.vport.center[0]  =36.0;
  adtb.vport.center[1]  =36.0;
/* these are the acad default values for ega
  adtb.vport.viewheight =9.176568;
  adtb.vport.center[0]  =7.360658;
  adtb.vport.center[1]  =4.588284;
*/
  adtb.vport.aspect     =1.604229;
  adtb.vport.lenslength =50.0;
  adtb.vport.frontclip  =0.0;
  adtb.vport.backclip   =0.0;
  adtb.vport.viewmode   =0;
  adtb.vport.zoomperc   =100;
  adtb.vport.fastzoom   =1;
  adtb.vport.ucsicon    =1;
  adtb.vport.snapmode   =0;
  adtb.vport.gridmode   =0;
  adtb.vport.snapstyle  =0;
  adtb.vport.snapisopair=0;

  adtb.vport.viewtwist  =0.0;
  adtb.vport.snapbase[0]=0.0;
  adtb.vport.snapbase[1]=0.0;
  adtb.vport.snapdist[0]=1.0;
  adtb.vport.snapdist[1]=1.0;
  adtb.vport.griddist[0]=0.0;
  adtb.vport.griddist[1]=0.0;
}

void process(outfile)
char outfile[];
{
  short i,row,col;
  double angle;

/* comment in this statement if you are using AUTODIRECT 3 */
/* InitAvEng(4096,4096,4096); */
  if (!initializewrite(outfile,4096)) {           /* initialize output */
    printf("Error opening file %s\n",outfile);
    terminatewrite();
    exit(1);
  }

  setheaderdefaults();			/* set default header values */
  setoutputversion(ACAD11);
  inithandles();                        /* initialize handle writing to start */
                                        /* do not initialize if adding */
                                        /* entities to an existing drawing */
  generatehandle();                     /* generate initial handle */
  writeheader();			/* write out header */

  startentitywrite();			/* initialize for entity write */
  adenhd.enttype=1;				/* write a line */
  adenhd.layerindex=0;				/* on the 0th layer */
  adenhd.entcolor=0;				/* bylayer color and linetype */
  adenhd.entlinetype=256;                   /* 1st linetype */
/* adenhd.entlinetype is 32767 for R11 bylayer linetype */
  adenhd.entthickness=0.0;			/* no thickness */
  adenhd.paperspace=0;
  aden.line.pt0[2]=aden.line.pt1[2]=0.0;				/* elevations are 0 as well */
  adenhd.xddatapresent=0;                      /* no extended data */
  for (row=0; row<5; row++)		/* write an array of entities */
    for (col=0; col<5; col++) {
      aden.line.pt0[0]=cos((double)0.0)+row*3.0;
      aden.line.pt0[1]=sin((double)0.0)+col*3.0;
      angle=0.0;
      for (i=0; i<12; i++) {
        aden.line.pt1[0]=cos(angle)+row*3.0;		/* note that enttype, color etc */
        aden.line.pt1[1]=sin(angle)+col*3.0;		/* do not need to be reset each time */
        writeentity1();			/* we write a new entity */
        writeentity2();
        emitentity();
        generatehandle();               /* generate next entity handle */
        aden.line.pt0[0]=aden.line.pt1[0]; aden.line.pt0[1]=aden.line.pt1[1];
        angle+=degreestoradians(160.0);
        adenhd.layerindex=1-adenhd.layerindex;	/* they are fixed until changed */
      }					/* we do jump from layer 0 to 1 */
    }

/* insert a couple of blocks here */
  adenhd.enttype=14;
  aden.insert.blockno=0;
  adenhd.layerindex=0;
  adenhd.entlinetype=adenhd.entcolor=0;
  aden.insert.pt0[0]=6.0;
  aden.insert.pt0[1]=6.0;
  aden.insert.pt0[2]=0.0;
  aden.insert.numrows=aden.insert.numcols=1;
  aden.insert.attribsfollow=0;
  aden.insert.xscale=4.0;
  aden.insert.yscale=4.0;
  aden.insert.rotang=0.0;
  aden.insert.zscale=1.0;
  aden.insert.coldist=aden.insert.rowdist=0.0;
  writeentity1();
  writeentity2();
  emitentity();
  generatehandle();

  adenhd.enttype=14;
  aden.insert.blockno=1;
  adenhd.layerindex=0;
  adenhd.entlinetype=adenhd.entcolor=0;
  aden.insert.pt0[0]=6.0;
  aden.insert.pt0[1]=6.0;
  aden.insert.pt0[2]=0.0;
  aden.insert.numrows=aden.insert.numcols=1;
  aden.insert.attribsfollow=0;
  aden.insert.xscale=6.0;
  aden.insert.yscale=2.0;
  aden.insert.rotang=0.0;
  aden.insert.zscale=1.0;
  aden.insert.coldist=aden.insert.rowdist=0.0;
  writeentity1();
  writeentity2();
  emitentity();
  generatehandle();

if (adct.ouracadverw SUBN>=ACAD11) {
  adenhd.enttype=24;    /* viewport entity */
  adenhd.paperspace=1;
  adenhd.xddatapresent=1;
  aden.vpent.cen[0]=4.5;
  aden.vpent.cen[1]=3.259162;
  aden.vpent.cen[2]=0.0;
  aden.vpent.width=12.857143;
  aden.vpent.height=9.311892;
  aden.vpent.id=1;
  aden.vpent.stackval=1;
  writeentity1();
/* now write extended data for the viewport entity */
  startextendeddatawrite();

  adxd.xddxfnumber=1001;
  adxd.xddata.xdappindex=0;  /* ACAD, the default */
  writeextendeddata();

  adxd.xddxfnumber=1000;
  strcpy(adxd.xddata.xdstring,"MVIEW");
  writeextendeddata();

  adxd.xddxfnumber=1002;
  adxd.xddata.xdcontrol='{';
  writeextendeddata();

  adxd.xddxfnumber=1070;
  adxd.xddata.xdint=16;
  writeextendeddata();

  adxd.xddxfnumber=1010;
  adxd.xddata.xd3dpt[0]=
  adxd.xddata.xd3dpt[1]=
  adxd.xddata.xd3dpt[2]=0.0;
  writeextendeddata();

  adxd.xddxfnumber=1010;
  adxd.xddata.xd3dpt[0]=
  adxd.xddata.xd3dpt[1]=0.0;
  adxd.xddata.xd3dpt[2]=1.0;
  writeextendeddata();

  adxd.xddxfnumber=1040;
  adxd.xddata.xdreal=0.0;
  writeextendeddata();

  adxd.xddata.xdreal=9.311892;
  writeextendeddata();

  adxd.xddata.xdreal=4.5;
  writeextendeddata();

  adxd.xddata.xdreal=3.259162;
  writeextendeddata();

  adxd.xddata.xdreal=50.0;
  writeextendeddata();

  adxd.xddata.xdreal=0.0;
  writeextendeddata();
  writeextendeddata();

  adxd.xddxfnumber=1070;
  adxd.xddata.xdint=   0;
  writeextendeddata();

  adxd.xddata.xdint= 100;
  writeextendeddata();

  adxd.xddata.xdint=   1;
  writeextendeddata();
  writeextendeddata();

  adxd.xddata.xdint=   0;
  writeextendeddata();
  writeextendeddata();
  writeextendeddata();
  writeextendeddata();

  adxd.xddxfnumber=1040;
  adxd.xddata.xdreal=0.0;
  writeextendeddata();
  writeextendeddata();
  writeextendeddata();

  adxd.xddata.xdreal=1.0;
  writeextendeddata();
  writeextendeddata();

  adxd.xddata.xdreal=0.0;
  writeextendeddata();
  writeextendeddata();

  adxd.xddxfnumber=1070;
  adxd.xddata.xdint=   0;
  writeextendeddata();

  adxd.xddxfnumber=1002;
  adxd.xddata.xdcontrol='{';
  writeextendeddata();

  adxd.xddata.xdcontrol='}';
  writeextendeddata();

  adxd.xddata.xdcontrol='}';
  writeextendeddata();

  writeentity2();
  emitentity();
  generatehandle();

  adenhd.enttype=24;    /* viewport entity */
  adenhd.paperspace=1;
  adenhd.xddatapresent=1;
  aden.vpent.cen[0]=3.467838;
  aden.vpent.cen[1]=1.834331;
  aden.vpent.cen[2]=0.0;
  aden.vpent.width=6.756171;
  aden.vpent.height=3.399402;
  aden.vpent.id=2;
  aden.vpent.stackval=0;
  writeentity1();
/* now write extended data for the viewport entity */
  startextendeddatawrite();

  adxd.xddxfnumber=1001;
  adxd.xddata.xdappindex=0;  /* ACAD, the default */
  writeextendeddata();

  adxd.xddxfnumber=1000;
  strcpy(adxd.xddata.xdstring,"MVIEW");
  writeextendeddata();

  adxd.xddxfnumber=1002;
  adxd.xddata.xdcontrol='{';
  writeextendeddata();

  adxd.xddxfnumber=1070;
  adxd.xddata.xdint=16;
  writeextendeddata();

  adxd.xddxfnumber=1010;
  adxd.xddata.xd3dpt[0]=
  adxd.xddata.xd3dpt[1]=
  adxd.xddata.xd3dpt[2]=0.0;
  writeextendeddata();

  adxd.xddata.xd3dpt[0]=
  adxd.xddata.xd3dpt[1]=0.0;
  adxd.xddata.xd3dpt[2]=1.0;
  writeextendeddata();

  adxd.xddxfnumber=1040;
  adxd.xddata.xdreal=0.0;
  writeextendeddata();

  adxd.xddata.xdreal=7.285359;
  writeextendeddata();

  adxd.xddata.xdreal=6.492335;
  writeextendeddata();

  adxd.xddata.xdreal=2.946401;
  writeextendeddata();

  adxd.xddata.xdreal=50.0;
  writeextendeddata();

  adxd.xddata.xdreal=0.0;
  writeextendeddata();
  writeextendeddata();

  adxd.xddxfnumber=1070;
  adxd.xddata.xdint=   0;
  writeextendeddata();

  adxd.xddata.xdint= 100;
  writeextendeddata();

  adxd.xddata.xdint=   1;
  writeextendeddata();
  writeextendeddata();

  adxd.xddata.xdint=   0;
  writeextendeddata();
  writeextendeddata();
  writeextendeddata();
  writeextendeddata();

  adxd.xddxfnumber=1040;
  adxd.xddata.xdreal=0.0;
  writeextendeddata();
  writeextendeddata();
  writeextendeddata();

  adxd.xddata.xdreal=1.0;
  writeextendeddata();
  writeextendeddata();

  adxd.xddata.xdreal=0.0;
  writeextendeddata();
  writeextendeddata();

  adxd.xddxfnumber=1070;
  adxd.xddata.xdint=   0;
  writeextendeddata();

  adxd.xddxfnumber=1002;
  adxd.xddata.xdcontrol='{';
  writeextendeddata();

  adxd.xddata.xdcontrol='}';
  writeextendeddata();

  adxd.xddata.xdcontrol='}';
  writeextendeddata();

  writeentity2();
  emitentity();
  generatehandle();
}

  startblockheaderwrite();		/* define a block header */
  adtb.blkh.flag=0;
  strcpy(adtb.blkh.name,"TESTBLK");
  writeblockheader();			/* and write it */

  adtb.blkh.flag=0;				/* another */
  strcpy(adtb.blkh.name,"TESTBLK2");
  writeblockheader();

  startlayerwrite();			/* define layers 0 and 1 */
  adtb.lay.flag=0;
  strcpy(adtb.lay.name,"0");
  adtb.lay.color=7;
  adtb.lay.linetype=0;
  writelayer();

  adtb.lay.flag=0;
  strcpy(adtb.lay.name,"1");
  adtb.lay.color=1;
  adtb.lay.linetype=0;
  writelayer();

  startshapewrite();			/* define a style */
  adtb.shape.flag=0;
  strcpy(adtb.shape.name,"STANDARD");
  adtb.shape.height=0.2;
  adtb.shape.width=1.0;
  adtb.shape.angle=0.0;
  adtb.shape.flag2=0;
  adtb.shape.lastshapeheight=0.2;
  strcpy(adtb.shape.file,"txt");
  adtb.shape.bigfontname[0]='\0';
  writeshapefile();

  startlinetypewrite();			/* and a linetype */
  adtb.ltype.flag=0;
  strcpy(adtb.ltype.name,"CONTINUOUS");
  strcpy(adtb.ltype.text,"Solid line");
  adtb.ltype.alignflag=(char)65;
  adtb.ltype.numlinetypevals=0;
  adtb.ltype.patternlength=0.0;
  writelinetype();

  strcpy(adtb.ltype.name,"DASHED");
  strcpy(adtb.ltype.text,"__ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __");
  adtb.ltype.numlinetypevals=2;
  adtb.ltype.patternlength=0.75;
  adtb.ltype.val[0]=0.5;
  adtb.ltype.val[1]=-0.25;
  writelinetype();


  startviewwrite();			/* no views in this drawing, */
					/* but you are required to execute */
					/* this procedure anyway */

  if (adct.ouracadverw SUBN>=ACAD10) {
    startucswrite();                      /* same */

    startvportwrite();
    setupdefaultviewport();
    writevport();
  }

  if (adct.ouracadverw SUBN>=ACAD11) {
    startregappwrite();

    startdimstylewrite();

    startvportenthdrwrite();
    writevportenthdr(0);
    aden.vpent.flag=1;
    aden.vpent.name[0]='\0';
    aden.vpent.stackval=1;
    writevportenthdr(1);
    aden.vpent.flag=1;
    aden.vpent.name[0]='\0';
    aden.vpent.stackval=2;
    writevportenthdr(2);
  }

  startblockdefwrite();			/* define blocks */
  initializeblockdef(0L);
  adenhd.paperspace=0;
  adenhd.xddatapresent=0;
  adenhd.enttype=12;  /* start of block */	/* write block start entity */
  aden.block.base[0]=0.0;
  aden.block.base[1]=0.0;
  writeentity1();
  writeentity2();
  emitentity();
  generatehandle();

  adenhd.enttype=1;   /* line */		/* write out the block's entities */
  adenhd.layerindex=0;
  aden.line.pt0[2]=aden.line.pt1[2]=0.0;
  for (i=0; i<12; i++) {
    angle=degreestoradians(i*30.0);
    aden.line.pt0[0]=cos(angle);
    aden.line.pt0[1]=sin(angle);
    angle+=degreestoradians(120.0);
    aden.line.pt1[0]=cos(angle);
    aden.line.pt1[1]=sin(angle);
    writeentity1();
    writeentity2();
    emitentity();
    generatehandle();
  }
  adenhd.enttype=13;  /* end of block */	/* and end it */
  writeentity1();
  writeentity2();
  emitentity();
  generatehandle();

  initializeblockdef(1L);		/* start next block def */
  adenhd.enttype=12;  /* start of block */
  aden.block.base[0]=0.0;
  aden.block.base[1]=0.0;
  writeentity1();
  writeentity2();
  emitentity();
  generatehandle();

  adenhd.enttype=1;   /* line */		/* define */
  adenhd.layerindex=0;
  for (i=0; i<9; i++) {
    angle=degreestoradians(i*40.0);
    aden.line.pt0[0]=cos(angle);
    aden.line.pt0[1]=sin(angle);
    angle+=degreestoradians(120.0);
    aden.line.pt1[0]=cos(angle);
    aden.line.pt1[1]=sin(angle);
    writeentity1();
    writeentity2();
    emitentity();
    generatehandle();
  }
  adenhd.enttype=13;  /* end of block */	/* and end */
  writeentity1();
  writeentity2();
  emitentity();
  generatehandle();

  terminatewrite();			/* close file and update all info */

/* comment in this statement if you are using AUTODIRECT 3 */
/* CloseAvEng(); */
}

void main(argc,argv)
int argc;
char *argv[];
{
  char outfilename[65];

  initad();
  adct.dwgno=0;

  printf("AUTODIRECT write example program\n");
  printf("Copyright (C) 1988,1989,1990 Stephen M. Richards\n\n");

  if (argc<2) {
    printf("Usage: autoexw filename\n");
    exit(1);
  }
  strcpy(outfilename,argv[1]);
  process(outfilename);
}
