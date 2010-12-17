
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrshp.c -- library routines for accessing autocad drawing files */
/* read shape listings from file */
#include "adrhdr.h"

#ifndef OLDCHDR
void startshaperead(void)
#else
void startshaperead()
#endif
{
  adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
  ad_fseek(adin.dwgfiler SUBN ,adin.shapeliststartr SUBN,0);
}

#ifndef OLDCHDR
short readshapefile(void)   /* no fix necessary (checked) */
#else
short readshapefile()
#endif
{
  short offset;
/* structure of style array -- 0th char is 4 if vertical font, 1-32 are style
   name, then double-prec height, width factor, obliquing angle.  Style byte
   is bit coded 2 for backwards, 4 for upside down.  Then an unidentified
   floating point real.  Associated text file is next.
*/
  ad_fread(adin.readbuf,adin.sizeofshapefileentryr SUBN,1,adin.dwgfiler SUBN );
#ifndef OCTALONLY
  if (adin.readbuf[0] & '\x80') adtb.shape.purgedflag=1;
#else
  if (adin.readbuf[0] & '\200') adtb.shape.purgedflag=1;
#endif
    else adtb.shape.purgedflag=0;
  adtb.shape.flag=adin.readbuf[0]; /* 0 for text font, 1 for shape file */
  memcpy(adtb.shape.name,&(adin.readbuf[1]),32);
  /* this needs to be looked into further */
  if (adct.ouracadverr SUBN>=ACAD11) {
    adtb.shape.xrefindex = buf2short(&adin.readbuf[33]);
    offset=2;
  }
  else {
    offset=0;
    adtb.shape.xrefindex=-1;
  }
#ifndef AV
  adtb.shape.height = buf2double(&adin.readbuf[33+offset]);
  adtb.shape.width = buf2double(&adin.readbuf[41+offset]);
  adtb.shape.angle = buf2double(&adin.readbuf[49+offset]);
  adtb.shape.flag2=adin.readbuf[57+offset];
  adtb.shape.lastshapeheight = buf2double(&adin.readbuf[58+offset]);
#endif
  memcpy(adtb.shape.file,&(adin.readbuf[66+offset]),64);
  adtb.shape.bigfontname[0]='\0';
  if ((adtb.shape.flag & 1) ==0) /* it is a text style */
    memcpy(adtb.shape.bigfontname,&(adin.readbuf[130+offset]),64);
  return(1);
}

