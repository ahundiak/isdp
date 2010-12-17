#ifdef UNIXOS
#include "ad2disg.h"
#else
#include "ad2disg.h"
#endif

#define MAXENTSIZE 1280
#define WRITEBUFSZ 16384
#define SIZEOFDOUBLE 8
#define SIZEOFLONG   4
#define SIZEOFSHORT  2
#define SIZEOFCHAR   1

#ifndef ADINSTRUDEFINED
#define ADINSTRUDEFINED
struct adinstru {

  unsigned entflagr,entprop,entmask,entflagr2,
           xddataflagr,xddataflagw;
#ifndef AV
  unsigned entflagw,entpropw,entflagw2,entmaskw;
#endif

/* variables local to this module (hope this works) */

  AD_FILE *dwgfilerblk SUFFIX;         /* read block defs from this stream */
  AD_FILE *dwgfilerent SUFFIX;  /* read header, tables, and entities from this one */
  AD_FILE *dwgfilerext SUFFIX;         /* read extra ents from this one */

#ifdef AD3
  AD_FILE *dwgfilerblk2 SUFFIX;        /* and this one */
#endif

/* vbles to track actual positions in file during run */
  long nextentloc SUFFIX,
       blkliststartr SUFFIX,
       extraentlocr SUFFIX,
       extraentsizer SUFFIX,         /* how many bytes of extra */
       entliststartr SUFFIX,
       viewliststartr SUFFIX,
       entlistendr SUFFIX,
       layerliststartr SUFFIX,
       blkdefstartr SUFFIX,
       blkdefsizer SUFFIX,           /* how many bytes of blkdef */
       shapeliststartr SUFFIX,
       linetypeliststartr SUFFIX,
#ifndef AV
       ucsliststartr SUFFIX,
#endif
       vportliststartr SUFFIX,
#ifndef AV
       curvportlocr SUFFIX,
       dimstyleliststartr SUFFIX,
       regappliststartr SUFFIX,
#endif
       vportenthdrliststartr SUFFIX;

  short sizeofblockheaderentryr SUFFIX,
        sizeofshapefileentryr SUFFIX,
        sizeoflinetypeentryr SUFFIX,
#ifndef AV
        sizeofucsentryr SUFFIX,
#endif
        sizeofviewentryr SUFFIX,
        sizeofvportentryr SUFFIX,
        sizeoflayerentryr SUFFIX,
#ifndef AV
        sizeofdimstyleentryr SUFFIX,
        sizeofregappentryr SUFFIX,
#endif
        sizeofvportenthdrentryr SUFFIX;

  unsigned actualdrawingversionr SUFFIX;

#ifndef AV
/* vbles to track actual positions in file during run */
  long blkliststartw SUFFIX,
       extraentlocw SUFFIX,
       entliststartw SUFFIX,
       viewliststartw SUFFIX,
       entlistendw SUFFIX,
       layerliststartw SUFFIX,
       blkdefstartw SUFFIX,
       shapeliststartw SUFFIX,
       linetypeliststartw SUFFIX,
       vportliststartw SUFFIX,
       ucsliststartw SUFFIX,
       dimstyleliststartw SUFFIX,
       regappliststartw SUFFIX,
       vportenthdrliststartw SUFFIX;

  short sizeofblockheaderentryw SUFFIX,
        sizeofshapefileentryw SUFFIX,
        sizeoflinetypeentryw SUFFIX,
        sizeofviewentryw SUFFIX,
        sizeofucsentryw SUFFIX,
        sizeofvportentryw SUFFIX,
        sizeoflayerentryw SUFFIX,
        sizeofdimstyleentryw SUFFIX,
        sizeofregappentryw SUFFIX,
        sizeofvportenthdrentryw SUFFIX;


#ifndef WIN
  char *writebuf;
#else
  LPSTR writebuf;
#endif
  short entlengthw;
  unsigned numentitiesw SUFFIX;
  long curvportlocw SUFFIX;

#endif

  char readbuf[MAXENTSIZE],*entptr;
  short entlengthr;
  unsigned numentitiesr SUFFIX;
  long blkh SUFFIX;
  long blockdefoffsetr SUFFIX;  /* offset of block from blkdefstartr */
#ifndef AV
  short needtowritesequencestart SUFFIX;
#endif
  short needtoreadsequencestart SUFFIX;
  long sequencestart SUFFIX;  /* location of an entity */
  short inblockdefrflag SUFFIX;
#ifndef AV
  short inblockdefwflag SUFFIX;
  short mysttwopresent SUFFIX;
  char garbage1 SUFFIX [14],
       garbage2 SUFFIX [4],
       garbage3 SUFFIX [4],
       garbage9 SUFFIX [24],
       garbage10 SUFFIX [146],
       garbage11 SUFFIX [4],
       garbage12 SUFFIX [14],
       garbage22 SUFFIX [3],
       garbage24 SUFFIX [160];
  short
       garbage14 SUFFIX,
       garbage15 SUFFIX,
       garbage16 SUFFIX,
       garbage17 SUFFIX,
       garbage18 SUFFIX,
       garbage20 SUFFIX,
       garbage21 SUFFIX,
       garbage23 SUFFIX,
       garbage26 SUFFIX;

  long garbage25 SUFFIX;

#endif
  short inblockr SUFFIX;
#ifndef AV
  short inblockw SUFFIX;
#endif
  short crc1;
  short xddatalengthr;
#ifndef AV
  short xddatalengthw;
  long vportentloc SUFFIX [128];
  short vportentcount SUFFIX;
#endif
  short xddatastart;
  short headersize SUFFIX;
  AD_FILE *dwgfiler SUFFIX;                /* file to be read */
#ifndef AV
  FILE *dwgfilew SUFFIX;                /* file to be written */
#endif

/* other viewport entity values, just for us */
  long vportentlocr;
  double vportenttarget[3];
  double vportentviewdir[3];
  double vportentviewtwist;
  double vportentviewheight;
  double vportentviewctr[2];


  short readfrozen;
  short ztemp,ztest;  /* for some compilers */
  union _unixunion {
    char unixtemp[8];
    double unixdoub;
    long unixlong;
    short unixshort;
  } unixunion;
  char unixchar;
} ;
#endif

struct adinstru adin;

