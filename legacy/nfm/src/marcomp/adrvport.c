
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrvport.c -- library routines for accessing autocad drawing files */
/* read vport listings from file */
#include "adrhdr.h"

#ifndef OLDCHDR
void startvportread(void)
#else
void startvportread()
#endif
{
  adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
  ad_fseek(adin.dwgfiler SUBN ,adin.vportliststartr SUBN,0);
}

#ifndef OLDCHDR
short readvport(void)
#else
short readvport()
#endif
{
  short offset;
  ad_fread(adin.readbuf,adin.sizeofvportentryr SUBN,1,adin.dwgfiler SUBN );
#ifndef OCTALONLY
  if (adin.readbuf[0] & '\x80') adtb.vport.purgedflag=1;
#else
  if (adin.readbuf[0] & '\200') adtb.vport.purgedflag=1;
#endif
    else adtb.vport.purgedflag=0;
  adtb.vport.flag=(char)(adin.readbuf[0] & 127);
  memcpy(adtb.vport.name,&adin.readbuf[1],32);
  if (adct.ouracadverr SUBN >=ACAD11) {
    adtb.vport.xrefindex = buf2short(&adin.readbuf[33]);
    offset=2;
  }
  else {
    offset=0;
    adtb.vport.xrefindex = -1;
  }
#ifndef AV
  adtb.vport.ll[0]       = buf2double(&adin.readbuf[33+offset]);  /* 10 group */
  adtb.vport.ll[1]       = buf2double(&adin.readbuf[41+offset]);  /* 20 group */
  adtb.vport.ur[0]       = buf2double(&adin.readbuf[49+offset]);  /* 11 group */
  adtb.vport.ur[1]       = buf2double(&adin.readbuf[57+offset]);  /* 21 group */
#endif
  adtb.vport.target[0]   = buf2double(&adin.readbuf[65+offset]);  /* 17 group */
  adtb.vport.target[1]   = buf2double(&adin.readbuf[73+offset]);  /* 27 group */
  adtb.vport.target[2]   = buf2double(&adin.readbuf[81+offset]);  /* 37 group */
  adtb.vport.viewdir[0]  = buf2double(&adin.readbuf[89+offset]);  /* 16 group */
  adtb.vport.viewdir[1]  = buf2double(&adin.readbuf[97+offset]);  /* 26 group */
  adtb.vport.viewdir[2]  = buf2double(&adin.readbuf[105+offset]); /* 36 group */
  adtb.vport.viewtwist   = buf2double(&adin.readbuf[113+offset]); /* 50 group */
  adtb.vport.viewheight  = buf2double(&adin.readbuf[121+offset]); /* 40 group */
  adtb.vport.center[0]   = buf2double(&adin.readbuf[129+offset]); /* 12 group */
  adtb.vport.center[1]   = buf2double(&adin.readbuf[137+offset]); /* 22 group */
#ifndef AV
  adtb.vport.aspect      = buf2double(&adin.readbuf[145+offset]); /* 41 group */
  adtb.vport.lenslength  = buf2double(&adin.readbuf[153+offset]); /* 42 group */
  adtb.vport.frontclip   = buf2double(&adin.readbuf[161+offset]); /* 43 group */
  adtb.vport.backclip    = buf2double(&adin.readbuf[169+offset]); /* 44 group */
  adtb.vport.viewmode    = buf2short( &adin.readbuf[177+offset]);
  adtb.vport.zoomperc    = buf2short( &adin.readbuf[179+offset]);
  adtb.vport.fastzoom    = buf2short( &adin.readbuf[181+offset]);
  adtb.vport.ucsicon     = buf2short( &adin.readbuf[183+offset]);
  adtb.vport.snapmode    = buf2short( &adin.readbuf[185+offset]);
  adtb.vport.gridmode    = buf2short( &adin.readbuf[187+offset]);
  adtb.vport.snapstyle   = buf2short( &adin.readbuf[189+offset]);
  adtb.vport.snapisopair = buf2short( &adin.readbuf[191+offset]);
  adtb.vport.snaprot     = buf2double(&adin.readbuf[193+offset]); /* 51 group */
  adtb.vport.snapbase[0] = buf2double(&adin.readbuf[201+offset]); /* 13 group */
  adtb.vport.snapbase[1] = buf2double(&adin.readbuf[209+offset]); /* 23 group */
  adtb.vport.snapdist[0] = buf2double(&adin.readbuf[217+offset]); /* 14 group */
  adtb.vport.snapdist[1] = buf2double(&adin.readbuf[225+offset]); /* 24 group */
  adtb.vport.griddist[0] = buf2double(&adin.readbuf[233+offset]); /* 15 group */
  adtb.vport.griddist[1] = buf2double(&adin.readbuf[241+offset]); /* 25 group */
#endif
  return(1);
}

