
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* AUTOCOPY.C --
   This is an example of a program to copy one AutoCAD drawing file into another
one.  Please use this program as a guide for designing your own.  */

/* Note that the type conversions from long to short for such values as
   numlayers, numblocks etc. limit the number of these entries that can
   be processed to 32768.  This should work for most applications; you can
   always use counters that are long ints instead of the short we have used
   to get the full range */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
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

/* function prototypes */
#ifdef PROTOTYPES
void process(char infile[],char outfile[]);
void main(int argc,char *argv[]);
#else
void process();
void main();
#endif

void process(infile,outfile)
char infile[],outfile[];
{
  register short i;
  long ec;

  adct.dwgno=0;

  if (!initializewrite(outfile,4096)) {           /* initialize output */
    printf("Error opening output file %s\n",outfile);
    exit(1);
  }

  if (!initializeread(infile,4096,4096,4096)) {           /* initialize input */
    printf("Error opening input file %s\n",infile);
    exit(1);
  }

  adct.copymode SUBN=1;
  printf("Copying header\n");
  if (!readheader()) {
    printf("%s -- Invalid AutoCAD version\n",infile);
    terminateread();
    terminatewrite();
    return;
  }

/* readheader sets adct.ouracadverr to the right version number, so set that
   as the output version */
 setoutputversion(adct.ouracadverr SUBN);

/* write header from infile to outfile */
  writeheader();
  ec=0;

/* copy entities */
  startentityread();
  startentitywrite();
  do {
    if ((ec % 100) == 0) printf("\rCopying entities %d%%",distancethroughentities());
    returnval=readentity1();

    if (returnval==1) {
      writeentity1();
      if (adenhd.xddatapresent) {
        startextendeddataread();
        startextendeddatawrite();
        while (readextendeddata()) {
          writeextendeddata();
        }
      }

      readentity2();
      writeentity2();
      emitentity();

    }
    ec++;
  } while (returnval==1);

  printf("\nCopying tables\n");
  startblockheaderread();
  startblockheaderwrite();
  for (i=0; i<(short)adct.numblocksr SUBN; i++) {
    readblockheader();
    writeblockheader();
  }

  startlayerread();
  startlayerwrite();
  for (i=0; i<(short)adct.numlayersr SUBN; i++) {
    readlayer();
    writelayer();
  }

  startshaperead();
  startshapewrite();
  for (i=0; i<(short)adct.numshapefilesr SUBN; i++) {
    readshapefile();
    writeshapefile();
  }

  startlinetyperead();
  startlinetypewrite();
  for (i=0; i<(short)adct.numlinetypesr SUBN; i++) {
    readlinetype();
    writelinetype();
  }

  startviewread();
  startviewwrite();
  for (i=0; i<(short)adct.numviewsr SUBN; i++) {
    readview();
    writeview();
  }

  if (adct.ouracadverw SUBN>=ACAD10) {
    startucsread();
    startucswrite();
    for (i=0; i<(short)adct.numucsr SUBN; i++) {
      readucs();
      writeucs();
    }

    startvportread();
    startvportwrite();
    for (i=0; i<(short)adct.numvportsr SUBN; i++) {
      readvport();
      writevport();
    }
  }

  if (adct.ouracadverw SUBN>=ACAD11) {
    startregappread();
    startregappwrite();
    for (i=0; i<(short)adct.numregappsr SUBN; i++) {
      readregapp();
      writeregapp();
    }

    startdimstyleread();
    startdimstylewrite();
    for (i=0; i<(short)adct.numdimstylesr SUBN; i++) {
      readdimstyle();
      writedimstyle();
    }

    startvportenthdrread();
    startvportenthdrwrite();
    for (i=0; i<(short)adct.numvportenthdrsr SUBN; i++) {
      readvportenthdr();
      writevportenthdr(i);
    }
  }

  printf("Copying block definitions\n");
  startblockdefwrite();
  startblockheaderread();

  for (i=0; i<(short)adct.numblocksr SUBN; i++) {
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
          while (readextendeddata()) {
            writeextendeddata();
          }
        }
        readentity2();
        writeentity2();
        emitentity();
      }
      while (adenhd.enttype!=13);
      endblockdefread();
    }
  }

  printf("Done\n");
  terminateread();
  terminatewrite();
}

void main(argc,argv)
int argc;
char *argv[];
{
  adct.dwgno=0;

  initad();

  printf("AUTOCOPY -- AUTODIRECT 2 example program\n");
  printf("Copyright (C) 1990 Stephen M. Richards\n\n");

  if (argc<3) {
    printf("Usage: autocopy infile outfile\n");
    exit(1);
  }
  process(argv[1],argv[2]);
}
