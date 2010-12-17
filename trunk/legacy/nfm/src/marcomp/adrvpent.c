
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrvpent.c -- library routines for accessing autocad drawing files */
/* read viewport entity listings from file */
#include "adrhdr.h"

#ifndef OLDCHDR
void startvportenthdrread(void)
#else
void startvportenthdrread()
#endif
{
  adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
  ad_fseek(adin.dwgfiler SUBN ,adin.vportenthdrliststartr SUBN,0);
}

#ifndef OLDCHDR
void readvportenthdr(void)
#else
void readvportenthdr()
#endif
{
  ad_fread(adin.readbuf,adin.sizeofvportenthdrentryr SUBN,1,adin.dwgfiler SUBN );
  aden.vpent.flag=adin.readbuf[0];
  if (aden.vpent.flag & 128) aden.vpent.purgedflag=1;
  else aden.vpent.purgedflag=0;
  memcpy(aden.vpent.name,&adin.readbuf[1],32);
  aden.vpent.xrefindex = buf2short(&adin.readbuf[33]);
  adin.vportentlocr = buf2long(&adin.readbuf[35]);
  aden.vpent.stackval = buf2short(&adin.readbuf[39]);
}

