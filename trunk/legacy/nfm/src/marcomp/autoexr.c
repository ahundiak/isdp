
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* AUTOEXR.C --
   This is an example of a simple program to read an AutoCAD drawing file
and report on its contents.  Please use this program as a guide for designing
your own.  */

/* Note that the type conversions from long to short for such values as
   numlayers, numblocks etc. limit the number of these entries that can
   be processed to 32768.  This should work for most applications; you can
   always use counters that are long ints instead of the short we have used
   to get the full range */

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


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "autodir.h"
#include "adrproto.h"
#define ACAD25 0  /* ac1002 */
#define ACAD26 1  /* ac1003 */
#define ACAD9  2  /* ac1004 */
#define ACAD10 3  /* ac1006 */
#define ACAD11 4  /* ac1009 */

short returnval;

/* Function prototypes */
#ifdef PROTOTYPES
void writeheaderinfo(void);
void printentity(void);
void att2(void);
void process(char infile[]);
void main(int argc,char *argv[]);
#endif

#include "prnstuff.c"    /* this file contains routines for printing out */
                         /* various info being read to verify that the */
                         /* program is working */

void process(infile)
char infile[];
{
  short i;

/* comment this statement in if you are using AUTODIRECT 3 */
/* InitAvEng(4096,4096,4096); */

  if (!initializeread(infile,4096,4096,4096)) {      /* initialize input */
    printf("Error opening file %s\n",infile);
    exit(1);
  }

/* read header */
  if (!readheader()) {                               /* read header info */
    printf("%s -- Invalid AutoCAD version\n",infile);
    terminateread();
    return;
  }

  writeheaderinfo();                                 /* print it */

  printf("\nENTITIES:\n");                           /* read entities */
  startentityread();
  do {
    returnval=readentity1();
    if (returnval) {
      if (adenhd.xddatapresent) {
        startextendeddataread();
        while (readextendeddata()) {
        }
      }
      readentity2();
      if (returnval==1 && adenhd.enttype!=18) {
        if (!adenhd.erasedflag) printentity();
      }
    }
  } while (returnval==1);

  printf("\nLAYERS:\n");                             /* read layer list */
  startlayerread();
  for (i=0; i<(short)adct.numlayersr SUBN; i++) {
    readlayer();
    if (!adtb.lay.purgedflag) printf("%s\n",adtb.lay.name);
  }

  printf("\nSHAPE FILES:\n");                        /* read shape file list */
  startshaperead();
  for (i=0; i<(short)adct.numshapefilesr SUBN; i++) {
    readshapefile();
    if (!adtb.shape.purgedflag) printf("%s\n",adtb.shape.file);
  }

  printf("VPORTS:\n");
  startvportread();
  for (i=0; i<(short)adct.numvportsr SUBN; i++) {
    readvport();
    if (!adtb.vport.purgedflag) printf("%s\n",adtb.vport.name);
  }

  printf("UCS:\n");
  startucsread();
  for (i=0; i<(short)adct.numucsr SUBN; i++) {
    readucs();
    if (!adtb.ucs.purgedflag) printf("%s\n",adtb.ucs.name);
  }

  printf("LINETYPES:\n");                            /* read linetype list */
  startlinetyperead();
  for (i=0; i<(short)adct.numlinetypesr SUBN; i++) {
    readlinetype();
    if (!adtb.ltype.purgedflag) printf("%s\n",adtb.ltype.name);
  }

  printf("REGAPPS:\n");                            /* read linetype list */
  startregappread();
  for (i=0; i<(short)adct.numregappsr SUBN; i++) {
    readregapp();
    printf("%s\n",adtb.app.name);
  }

/* no such thing as a "purged" view, only deleted */
  printf("\nVIEWS:\n");                              /* read view list */
  startviewread();
  for (i=0; i<(short)adct.numviewsr SUBN; i++) {
    readview();
    printf("%s\n",adtb.view.name);
  }

  printf("\nDIMSTYLES:\n");                          /* read dimstyle list */
  startdimstyleread();
  for (i=0; i<(short)adct.numdimstylesr SUBN; i++) {
    readdimstyle();
    printf("%s\n",adtb.dimst.name);
  }

  printf("\nBLOCKS:\n");                             /* read block list */
  startblockheaderread();

  for (i=0; i<(short)adct.numblocksr SUBN; i++) {
    readblockheader();   /* gives block name, which we need */
    /* if either not purged, or purged but the definition is still present */
    if (!adtb.blkh.purgedflag || adtb.blkh.defpresent) {
      startblockdefread();
      do {                          /* read block def ent, then rest of block */
        returnval=readentity1();    /* read next entity */

        if (returnval) {
          if (adenhd.xddatapresent) {
            startextendeddataread();
            while (readextendeddata()) {
            }
          }
          readentity2();
          if (!adenhd.erasedflag &&          /* if this entity is not erased */
              !adtb.blkh.purgedflag)            /* and the block has not been purged */
            printentity();
        }
      }
      while (adenhd.enttype!=13);
      endblockdefread();
    }
  }
  terminateread();
/* comment this statement in if you are using AUTODIRECT 3 */
/* CloseAvEng(); */

}

void main(argc,argv)
int argc;
char *argv[];
{
  char infilename[65];

  initad();

  printf("AUTODIRECT read example program\n");
  printf("Copyright (C) 1988, 1989, 1990 Stephen M. Richards\n\n");

  if (argc<2) {
    printf("Usage: autoexr filename\n");
    exit(1);
  }
  strcpy(infilename,argv[1]);
  process(infilename);
}
