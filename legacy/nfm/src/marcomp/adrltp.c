
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrltp.c -- library routines for accessing autocad drawing files */
/* read linetype listings from file */
#include "adrhdr.h"
#ifndef OLDCHDR
void startlinetyperead(void)
#else
void startlinetyperead()
#endif
{
  adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
  ad_fseek(adin.dwgfiler SUBN ,adin.linetypeliststartr SUBN,0);
}

#ifndef OLDCHDR
short readlinetype(void)  /* fixed */
#else
short readlinetype()
#endif
{
  short i, rindex,offset;

/* linetype name is at location 1
   should also be an alignment code, number of dash length items, total
   pattern length, and dash lengths 1 .. n */
  ad_fread(adin.readbuf,adin.sizeoflinetypeentryr SUBN,1,adin.dwgfiler SUBN );
#ifndef OCTALONLY
  if (adin.readbuf[0] & '\x80') adtb.ltype.purgedflag=1;
#else
  if (adin.readbuf[0] & '\200') adtb.ltype.purgedflag=1;
#endif
    else adtb.ltype.purgedflag=0;
  adtb.ltype.flag=adin.readbuf[0];
  memcpy(adtb.ltype.name,&adin.readbuf[1],32);
  if (adct.ouracadverr SUBN>=ACAD11) {
    adtb.ltype.xrefindex = buf2short(&adin.readbuf[33]);
    offset=2;
  }
  else {
    offset=0;
    adtb.ltype.xrefindex = -1;
  }
  strcpy(adtb.ltype.text,&adin.readbuf[33+offset]);
  adtb.ltype.alignflag=adin.readbuf[81+offset];
  adtb.ltype.numlinetypevals=adin.readbuf[82+offset];
  adtb.ltype.patternlength = buf2double(&adin.readbuf[83+offset]);
  rindex=91+offset;
  for (i=0; i<adtb.ltype.numlinetypevals && i<15; i++) {
    adtb.ltype.val[i] = buf2double(&adin.readbuf[rindex]);
    rindex+=8;
  }
  adtb.ltype.numlinetypevals=min(adtb.ltype.numlinetypevals,15);
  adtb.ltype.numlinetypevals=max(0,adtb.ltype.numlinetypevals);
  return(1);
}
