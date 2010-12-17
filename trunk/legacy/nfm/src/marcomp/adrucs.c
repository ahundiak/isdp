
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrucs.c -- library routines for accessing autocad drawing files */
/* read ucs listings from file */
#include "adrhdr.h"

#ifndef OLDCHDR
void startucsread(void)
#else
void startucsread()
#endif
{
  adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
  ad_fseek(adin.dwgfiler SUBN ,adin.ucsliststartr SUBN,0);
}

#ifndef OLDCHDR
void readucs(void)
#else
void readucs()
#endif
{
  short offset;

  ad_fread(adin.readbuf,adin.sizeofucsentryr SUBN,1,adin.dwgfiler SUBN );
  if (adin.readbuf[0] & 128) adtb.ucs.purgedflag=1;
    else adtb.ucs.purgedflag=0;
  adtb.ucs.flag=adin.readbuf[0];
  memcpy(adtb.ucs.name,&adin.readbuf[1],32);
  if (adct.ouracadverr SUBN>=ACAD11) {
    adtb.ucs.xrefindex = buf2short(&adin.readbuf[33]);
    offset=2;
  }
  else {
    offset=0;
    adtb.ucs.xrefindex = -1;
  }
  adtb.ucs.org[0]  = buf2double(&adin.readbuf[33+offset]);
  adtb.ucs.org[1]  = buf2double(&adin.readbuf[41+offset]);
  adtb.ucs.org[2]  = buf2double(&adin.readbuf[49+offset]);
  adtb.ucs.xdir[0] = buf2double(&adin.readbuf[57+offset]);
  adtb.ucs.xdir[1] = buf2double(&adin.readbuf[65+offset]);
  adtb.ucs.xdir[2] = buf2double(&adin.readbuf[73+offset]);
  adtb.ucs.ydir[0] = buf2double(&adin.readbuf[81+offset]);
  adtb.ucs.ydir[1] = buf2double(&adin.readbuf[89+offset]);
  adtb.ucs.ydir[2] = buf2double(&adin.readbuf[97+offset]);
}

