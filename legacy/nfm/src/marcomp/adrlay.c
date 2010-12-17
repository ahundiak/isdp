
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrlay.c -- library routines for accessing autocad drawing files */
/* read layers from file */
#include "adrhdr.h"

#ifndef OLDCHDR
void startlayerread(void)
#else
void startlayerread()
#endif
{
  adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
  ad_fseek(adin.dwgfiler SUBN ,adin.layerliststartr SUBN,0);
}

#ifndef OLDCHDR
short readlayer(void)   /* fixed */
#else
short readlayer()
#endif
{
  short offset;

/* structure of layer array -- 0th char is flag, where '\x80' bit indicates
   that the layer was purged, 1 bit indicates it is frozen, 1--31 are name,
   32 is not known, 33-4 are color, 35 is linetype, 36-7 not known */

  ad_fread(adin.readbuf,adin.sizeoflayerentryr SUBN,1,adin.dwgfiler SUBN );
#ifndef OCTALONLY
  if (adin.readbuf[0] & '\x80')
#else
  if (adin.readbuf[0] & '\200')
#endif
    adtb.lay.purgedflag=1;
  else adtb.lay.purgedflag=0;
  adtb.lay.flag=adin.readbuf[0];
  memcpy(adtb.lay.name,&(adin.readbuf[1]),32);
  if (adct.ouracadverr SUBN>=ACAD11) {
    adtb.lay.xrefindex = buf2short(&adin.readbuf[33]);
    offset=2;
  }
  else {
    offset=0;
    adtb.lay.xrefindex=-1;
  }
  adtb.lay.color = buf2short(&adin.readbuf[33+offset]);
  adtb.lay.linetype = buf2short(&adin.readbuf[35+offset]);
  return(1);
}

