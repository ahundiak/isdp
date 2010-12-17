
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* avendr.c -- autoview end drawing read, also clearblockcache */

#include "avhdr.h"

void closeshapefiles()
{
  short i;

  for (i=1; i<MAXSHFILESTRU; i++)   /* don't close simplex */
    if (ad3in.shfile[i].name[0])
      sh_close(ad3in.shfile[i].name);
}

void endread()
{
  register short i;

  terminateread();

  for (i=0; i<(short)adct.numblocksr && ad3in.blkppindex+i<MAXADPP; i++)
    if (ad3in.blk[i]!=NULL)
      ad_free(ad3in.blk[i]);

  for (i=0; i<(short)adct.numlinetypesr && ad3in.ltpppindex+i<MAXADPP; i++) {
    if (ad3in.ltp[i]!=NULL) {
      if (ad3in.ltp[i]->patternval!=NULL)
        ad_free(ad3in.ltp[i]->patternval);
      ad_free(ad3in.ltp[i]);
    }
  }

  for (i=0; i<(short)adct.numlayersr && ad3in.layppindex+i<MAXADPP; i++)
    if (lay[i]!=NULL)
      ad_free(lay[i]);

  closeshapefiles();

  for (i=0; i<min((short)adct.numshapefilesr,MAXSHAPEFILENAMES); i++) {
    if (ad3in.shapeinfo[i]!=NULL)
      ad_free(ad3in.shapeinfo[i]);
    ad3in.shapeinfo[i]=NULL;
  }
#ifdef AV
  for (i=0; i<(short)adct.numviewsr && ad3in.vwppindex+i<MAXADPP; i++)
    if (ad3in.vw[i]!=NULL)
      ad_free(ad3in.vw[i]);
#endif
  clearblockcache(1);
  ad3in.nextavailshapefile=1;
  for (i=0; i<MAXADPP; i++) ad3in.adpp[i]=NULL;
  ad3in.adppcount=0;
  initsh();  /* restart shape subsystem */
}

#ifndef OLDCHDR
void clearblockcache(short dofree)
#else
void clearblockcache(dofree)
short dofree;
#endif
{
  short i;

  ad3in.globallru=0L;
  for (i=0; i<MAXBLOCKCACHE; i++) {
    ad3in.blockcache[i].lru=0L;
    ad3in.blockcache[i].inuse=0;
    if (dofree && ad3in.blockcache[i].blkdata!=NULL)
      ad_free(ad3in.blockcache[i].blkdata);
    ad3in.blockcache[i].blkdata=NULL;
    ad3in.blockcache[i].blockno = -1;
  }
}
