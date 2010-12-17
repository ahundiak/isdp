
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrblkdf.c -- library routines for accessing autocad drawing files */
/* read block defs from file */
#include "adrhdr.h"

#ifndef OLDCHDR
void startblockdefread(void)
#else
void startblockdefread()
#endif
/* this is very much dependent on adin.blockdefoffsetr having been set to
   the proper value by a prior call to readblockheader */
{
#ifdef AD3
  adin.inblockdefrflag SUBN++;
  if (adin.inblockdefrflag SUBN==1) adin.dwgfiler SUBN =adin.dwgfilerblk SUBN ;
  else adin.dwgfiler SUBN =adin.dwgfilerblk2 SUBN;
#endif
#ifndef AD3
  adin.inblockdefrflag SUBN=1;
#endif
  dwgfilerseek(adin.blkdefstartr SUBN + adin.blockdefoffsetr SUBN);
}

#ifndef OLDCHDR
void endblockdefread(void)
#else
void endblockdefread()
#endif
{
  adin.inblockdefrflag SUBN=0;
}

