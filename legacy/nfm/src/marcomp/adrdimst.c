
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrdimst.c -- library routines for accessing autocad drawing files */
/* read dimstyle listings from file */
#include "adrhdr.h"

#ifndef OLDCHDR
void startdimstyleread(void)
#else
void startdimstyleread()
#endif
{
  adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
  ad_fseek(adin.dwgfiler SUBN ,adin.dimstyleliststartr SUBN,0);
}

#ifndef OLDCHDR
void readdimstyle(void)
#else
void readdimstyle()
#endif
{
/* since this is an R11 innovation, we don't need to use the offset variable
   used in other places; we simply skip those two bytes at 33 and 34 */
  ad_fread(adin.readbuf,adin.sizeofdimstyleentryr SUBN,1,adin.dwgfiler SUBN );
  adtb.dimst.flag=adin.readbuf[0];
#ifndef OCTALONLY
  if (adin.readbuf[0] & '\x80')
#else
  if (adin.readbuf[0] & '\200')
#endif
    adtb.dimst.purgedflag=1;
  else adtb.dimst.purgedflag=0;
  memcpy(adtb.dimst.name,&adin.readbuf[1],32);
  adtb.dimst.xrefindex  = buf2short(&adin.readbuf[33]);
  adtb.dimst.dimscale = buf2double(&adin.readbuf[35]);
  adtb.dimst.dimasz   = buf2double(&adin.readbuf[43]);
  adtb.dimst.dimexo   = buf2double(&adin.readbuf[51]);
  adtb.dimst.dimdli   = buf2double(&adin.readbuf[59]);
  adtb.dimst.dimexe   = buf2double(&adin.readbuf[67]);
  adtb.dimst.dimrnd   = buf2double(&adin.readbuf[75]);
  adtb.dimst.dimdle   = buf2double(&adin.readbuf[83]);
  adtb.dimst.dimtp    = buf2double(&adin.readbuf[91]);
  adtb.dimst.dimtm    = buf2double(&adin.readbuf[99]);
  adtb.dimst.dimtxt   = buf2double(&adin.readbuf[107]);
  adtb.dimst.dimcen   = buf2double(&adin.readbuf[115]);
  adtb.dimst.dimtsz   = buf2double(&adin.readbuf[123]);
  adtb.dimst.dimaltf  = buf2double(&adin.readbuf[131]);
  adtb.dimst.dimlfac  = buf2double(&adin.readbuf[139]);
  adtb.dimst.dimtvp   = buf2double(&adin.readbuf[147]);
  adtb.dimst.dimtol   =adin.readbuf[155];
  adtb.dimst.dimlim   =adin.readbuf[156];
  adtb.dimst.dimtih   =adin.readbuf[157];
  adtb.dimst.dimtoh   =adin.readbuf[158];
  adtb.dimst.dimse1   =adin.readbuf[159];
  adtb.dimst.dimse2   =adin.readbuf[160];
  adtb.dimst.dimtad   =adin.readbuf[161];
  adtb.dimst.dimzin   =adin.readbuf[162];
  adtb.dimst.dimalt   =adin.readbuf[163];
  adtb.dimst.dimaltd  =adin.readbuf[164];
  adtb.dimst.dimtofl  =adin.readbuf[165];
  adtb.dimst.dimsah   =adin.readbuf[166];
  adtb.dimst.dimtix   =adin.readbuf[167];
  adtb.dimst.dimsoxd  =adin.readbuf[168];
  memcpy(adtb.dimst.dimpost, &adin.readbuf[169],16);
  memcpy(adtb.dimst.dimapost,&adin.readbuf[185],16);
  memcpy(adtb.dimst.dimblk, &adin.readbuf[201],33);
  memcpy(adtb.dimst.dimblk1,&adin.readbuf[234],33);
  memcpy(adtb.dimst.dimblk2,&adin.readbuf[267],33);
  adtb.dimst.dimclrd  = buf2short(&adin.readbuf[300]);
  adtb.dimst.dimclre  = buf2short(&adin.readbuf[302]);
  adtb.dimst.dimclrt  = buf2short(&adin.readbuf[304]);
  adtb.dimst.dimtfac  = buf2double(&adin.readbuf[306]);
  adtb.dimst.dimgap   = buf2double(&adin.readbuf[314]);
}
