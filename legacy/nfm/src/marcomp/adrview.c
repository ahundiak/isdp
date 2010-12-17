
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrview.c -- library routines for accessing autocad drawing files */
/* read view listings from file */
#include "adrhdr.h"

#ifndef OLDCHDR
void startviewread(void)
#else
void startviewread()
#endif
{
  adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
  ad_fseek(adin.dwgfiler SUBN ,adin.viewliststartr SUBN,0);
}

#ifndef OLDCHDR
short readview(void)
#else
short readview()
#endif
{
  short offset;

/* views.  1-32 is view name.  then real viewht, real viewctrx and viewctry,
   real viewwidth, real viewdir from origin x,y,z. (3 reals). then 3 bytes */
  ad_fread(adin.readbuf,adin.sizeofviewentryr SUBN,1,adin.dwgfiler SUBN );
#ifndef AV
  adtb.view.flag=adin.readbuf[0];
#endif
  memcpy(adtb.view.name,&adin.readbuf[1],32);
  if (adct.ouracadverr SUBN>=ACAD11) {
    adtb.view.xrefindex = buf2short(&adin.readbuf[33]);
    offset=2;
  }
  else {
    offset=0;
    adtb.view.xrefindex = -1;
  }
  adtb.view.ht       = buf2double(&adin.readbuf[33+offset]);
  adtb.view.center[0] = buf2double(&adin.readbuf[41+offset]);
  adtb.view.center[1] = buf2double(&adin.readbuf[49+offset]);
#ifndef AV
  adtb.view.width    = buf2double(&adin.readbuf[57+offset]);
#endif
  adtb.view.dir[0]   = buf2double(&adin.readbuf[65+offset]);
  adtb.view.dir[1]   = buf2double(&adin.readbuf[73+offset]);
  adtb.view.dir[2]   = buf2double(&adin.readbuf[81+offset]);
  if (adct.ouracadverr SUBN>ACAD9) {
    adtb.view.target[0]  = buf2double(&adin.readbuf[91+offset]);
    adtb.view.target[1]  = buf2double(&adin.readbuf[99+offset]);
    adtb.view.target[2]  = buf2double(&adin.readbuf[107+offset]);
    adtb.view.twist      = buf2double(&adin.readbuf[123+offset]);
#ifndef AV
    adtb.view.flag2     =adin.readbuf[89+offset];
    adtb.view.lenslength = buf2double(&adin.readbuf[115+offset]);
    adtb.view.frontclip  = buf2double(&adin.readbuf[131+offset]);
    adtb.view.backclip   = buf2double(&adin.readbuf[139+offset]);
    adtb.view.viewmode   = buf2short(&adin.readbuf[147+offset]);
#endif
  }
  return(1);
}

