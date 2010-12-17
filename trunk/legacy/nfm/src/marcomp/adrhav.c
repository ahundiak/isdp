
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrhav.c -- library routines for accessing autocad drawing files */
/* header read section */
/* version 12/28/90 */
/* autoview shortened version */
#include "adrhdr.h"


#ifndef OLDCHDR
short valhdrstr(char *acadverr)
#else
short valhdrstr(acadverr)
char *acadverr;
#endif
{
  if (!strcmp(acadverr,"AC1002")) return(ACAD25);
  else if (!strcmp(acadverr,"AC1003")) return(ACAD26);
  else if (!strcmp(acadverr,"AC1004")) return(ACAD9);
  else if (!strcmp(acadverr,"AC1006")) return(ACAD10);
  else if (!strcmp(acadverr,"AC1009")) return(ACAD11);
  return(-1);
}

#ifndef OLDCHDR
short readheader(void)
#else
short readheader()
#endif
{
  register char *hptr;

  adct.numblocksr SUBN=adct.numlayersr SUBN=adct.numshapefilesr SUBN=adct.numlinetypesr SUBN=
    adct.numviewsr SUBN=adct.numucsr SUBN=adct.numvportsr SUBN=
    adct.numregappsr SUBN=adct.numdimstylesr SUBN=adct.numvportenthdrsr SUBN=0L;

  adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
  ad_fseek(adin.dwgfiler SUBN,0L,0 );
  /* read autocad version */
  ad_fread(adhd.acadverr,6,1,adin.dwgfiler SUBN );
  adhd.acadverr[6]='\0';
  adct.ouracadverr SUBN=valhdrstr(adhd.acadverr);
  if (adct.ouracadverr SUBN==-1) {
    return(0);
  }

/* these are the former readheader1 and readheader2 */

  ad_fread(adin.readbuf,1,14,adin.dwgfiler SUBN);
  adin.entliststartr SUBN =frdlong();				/* offset 14 */

  ad_fseek(adin.dwgfiler SUBN,0,0);                                  /* back to start */
  hptr=ad_malloc((short)(adin.entliststartr SUBN));
  if (hptr==NULL) return(0);
  ad_fread(hptr,(short)(adin.entliststartr SUBN),1,adin.dwgfiler SUBN);  /* read whole thing */

  adin.entlistendr SUBN             = buf2long(&hptr[0x18]);		/* offset 18 */
  adin.blkdefstartr SUBN            = buf2long(&hptr[0x1C]);
  adin.blkdefsizer SUBN             = buf2long(&hptr[0x20]) & 0x3FFFFFFFL;
  adin.extraentlocr SUBN            = buf2long(&hptr[0x24]);
  if (adin.extraentlocr SUBN==0L) adin.extraentlocr SUBN=adin.blkdefstartr SUBN+adin.blkdefsizer SUBN;
  adin.extraentsizer SUBN           = buf2long(&hptr[0x28]) & 0x3FFFFFFFL;
  adin.sizeofblockheaderentryr SUBN = buf2short(&hptr[0x2C]);
  adct.numblocksr SUBN              = buf2long(&hptr[0x2E]);
  if (adct.ouracadverr SUBN <ACAD9)
    adct.numblocksr SUBN &= (long)0xFFFF;
  adin.blkliststartr SUBN           = buf2long(&hptr[0x32]);

  adin.sizeoflayerentryr SUBN       = buf2short(&hptr[0x36]);
  adct.numlayersr SUBN              = buf2long(&hptr[0x38]);
  if (adct.ouracadverr SUBN <ACAD9)
    adct.numlayersr SUBN &= (long)0xFFFF;
  adin.layerliststartr SUBN         = buf2long(&hptr[0x3C]);

  adin.sizeofshapefileentryr SUBN   = buf2short(&hptr[0x40]);
  adct.numshapefilesr SUBN          = buf2long(&hptr[0x42]);
  if (adct.ouracadverr SUBN <ACAD9)
    adct.numshapefilesr SUBN &= (long)0xFFFF;
  adin.shapeliststartr SUBN         = buf2long(&hptr[0x46]);

  adin.sizeoflinetypeentryr SUBN    = buf2short(&hptr[0x4A]);
  adct.numlinetypesr SUBN           = buf2short(&hptr[0x4C]);
  if (adct.ouracadverr SUBN <ACAD9)
    adct.numlinetypesr SUBN &= (long)0xFFFF;
  adin.linetypeliststartr SUBN      = buf2long(&hptr[0x50]);

  adin.sizeofviewentryr SUBN        = buf2short(&hptr[0x54]);
  adct.numviewsr SUBN               = buf2long(&hptr[0x56]);
  if (adct.ouracadverr SUBN <ACAD9)
    adct.numviewsr SUBN &= (long)0xFFFF;
  adin.viewliststartr SUBN          = buf2long(&hptr[0x5A]);

  adhd.base[0]                    = buf2double(&hptr[0x5E]);
  adhd.base[1]                    = buf2double(&hptr[0x66]);
  adhd.base[2]                    = buf2double(&hptr[0x6E]);

  adhd.extmin[0]                  = buf2double(&hptr[0x78]);
  adhd.extmin[1]                  = buf2double(&hptr[0x80]);
  adhd.extmin[2]                  = buf2double(&hptr[0x88]);
  adhd.extmax[0]                  = buf2double(&hptr[0x90]);
  adhd.extmax[1]                  = buf2double(&hptr[0x98]);
  adhd.extmax[2]                  = buf2double(&hptr[0xA0]);

  adhd.viewctr[0]                 = buf2double(&hptr[0xC8]);
  adhd.viewctr[1]                 = buf2double(&hptr[0xD0]);
  adhd.viewctr[2]                 = buf2double(&hptr[0xD8]);
  adhd.viewsize                   = buf2double(&hptr[0xE0]);
  adhd.fillmode                   = buf2short(&hptr[0x12C]);
  adhd.qtextmode                  = buf2short(&hptr[0x12E]);
  adhd.ltscale                    = buf2double(&hptr[0x132]);
  if (adct.ouracadverr SUBN >= ACAD11)
    adhd.psltscale                = buf2short(&hptr[0x156]);
  else adhd.psltscale=0;
  adhd.attmode                    = buf2short(&hptr[0x192]);
  adhd.vpointhdr[0]               = buf2double(&hptr[0x239]);
  adhd.vpointhdr[1]               = buf2double(&hptr[0x241]);
  adhd.vpointhdr[2]               = buf2double(&hptr[0x249]);

  adhd.tdcreate1                  = buf2long(&hptr[0x31F]);
  adhd.tdcreate2                  = buf2long(&hptr[0x323]);
  adhd.tdupdate1                  = buf2long(&hptr[0x327]);
  adhd.tdupdate2                  = buf2long(&hptr[0x32B]);
  adhd.tdindwg1                   = buf2long(&hptr[0x32F]);
  adhd.tdindwg2                   = buf2long(&hptr[0x333]);
  adhd.tdusrtimer1                = buf2long(&hptr[0x337]);
  adhd.tdusrtimer2                = buf2long(&hptr[0x33B]);
  adhd.pdmode                     = buf2short(&hptr[0x35D]);
  adhd.pdsize                     = buf2double(&hptr[0x35F]);

  if (adct.ouracadverr SUBN>=ACAD10) {
#ifdef YAMAMA
/* not necessary */
    adhd.target[0]                = buf2double(&hptr[0x443]);
    adhd.target[1]                = buf2double(&hptr[0x44B]);
    adhd.target[2]                = buf2double(&hptr[0x453]);
    adhd.viewtwisthdr             = buf2double(&hptr[0x463]);
#endif
    adhd.enthandles               = buf2short(&hptr[0x4EC]);
    adin.sizeofvportentryr SUBN     = buf2short(&hptr[0x500]);
    adct.numvportsr SUBN            = buf2long(&hptr[0x502]);
    adin.vportliststartr SUBN       = buf2long(&hptr[0x506]);
  }
  if (adct.ouracadverr SUBN>=ACAD11) {
    adhd.tilemode                  = buf2short(&hptr[0x631]);
    adhd.cvport                    = buf2short(&hptr[0x635]);
    adhd.pextmin[0]                = buf2double(&hptr[0x637]);
    adhd.pextmin[1]                = buf2double(&hptr[0x63F]);
    adhd.pextmin[2]                = buf2double(&hptr[0x647]);
    adhd.pextmax[0]                = buf2double(&hptr[0x64F]);
    adhd.pextmax[1]                = buf2double(&hptr[0x657]);
    adhd.pextmax[2]                = buf2double(&hptr[0x65F]);
    adin.sizeofvportenthdrentryr SUBN= buf2short(&hptr[0x69F]);
    adct.numvportenthdrsr SUBN       = buf2long(&hptr[0x6A1]);
    adin.vportenthdrliststartr SUBN  = buf2long(&hptr[0x6A5]);
    adhd.maxactvp                  = buf2short(&hptr[0x6A9]);
    adhd.visretain                 = buf2short(&hptr[0x6BB]);
  }
  ad_free(hptr);

  return(1);
}
