
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrapp.c -- library routines for accessing autocad drawing files */
/* read regapp listings from file */
#include "adrhdr.h"

#ifndef OLDCHDR
void startregappread(void)
#else
void startregappread()
#endif
{
  adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
  ad_fseek(adin.dwgfiler SUBN ,adin.regappliststartr SUBN,0);
}

#ifndef OLDCHDR
void readregapp(void)
#else
void readregapp()
#endif
{
  adtb.app.purgedflag=0;   /* not relevant here, but set to 0 anyway */
  ad_fread(adin.readbuf,adin.sizeofregappentryr SUBN,1,adin.dwgfiler SUBN );
  adtb.app.flag=adin.readbuf[0];
  memcpy(adtb.app.name,&adin.readbuf[1],32);
  adtb.app.xrefindex = buf2short(&adin.readbuf[33]);
}

