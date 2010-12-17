
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrblkh.c -- library routines for accessing autocad drawing files */
/* read block headers from file */
#include "adrhdr.h"

#ifndef OLDCHDR
void startblockheaderread(void)
#else
void startblockheaderread()
#endif
{
  adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
  ad_fseek(adin.dwgfiler SUBN ,adin.blkliststartr SUBN,0);
  adin.blkh SUBN=adin.blkliststartr SUBN;
}

#ifndef OLDCHDR
short readblockheader(void)   /* fixed */
#else
short readblockheader()
#endif
{
  short offset;

  if (ad_ftell(adin.dwgfiler SUBN)!=adin.blkh SUBN)
    ad_fseek(adin.dwgfiler SUBN ,adin.blkh SUBN,0);
/* block array -- 0th char is flag, '\x40' if referenced currently,
   1-32 is block name */
  ad_fread(adin.readbuf,adin.sizeofblockheaderentryr SUBN,1,adin.dwgfiler SUBN );
  adtb.blkh.flag=adin.readbuf[0];
  memcpy(adtb.blkh.name,&(adin.readbuf[1]),32);
  adin.blkh SUBN=ad_ftell(adin.dwgfiler SUBN );
  adtb.blkh.defpresent=adtb.blkh.purgedflag=0;
  if (adct.ouracadverr SUBN>=ACAD11) {
    adtb.blkh.xrefindex = buf2short(&adin.readbuf[33]);
    offset=2;
  }
  else {
    offset=0;
    adtb.blkh.xrefindex=-1;
  }
  adin.blockdefoffsetr SUBN = buf2long(&adin.readbuf[33+offset]);
  adin.blockdefoffsetr SUBN &=(long)0x03FFFFFF;
#ifndef OCTALONLY
  if (adtb.blkh.flag & '\x80')
#else
  if (adtb.blkh.flag & '\200')
#endif
    adtb.blkh.purgedflag=1;
  if (adtb.blkh.flag & '\1') adtb.blkh.defpresent=1;
  return(1);
}

