
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adw2.c -- library routines for writing autocad drawing files */
/* define one of the following for turbo c or microsoft c */
/* #define turboc 1 */
/* #define microsoftc 1 */

#include "adwhdr.h"
#include "sentmage.h"

/* prototypes for local functions */
#ifdef PROTOTYPES
void tablecrc(char *tblinfo,short tblentrysize,short tblmagic);
short  crc8(short dx,char *p, short n);
#else
void tablecrc();
short crc8();
#endif


/* also defined in adw.c */
#define wrc(c) adin.writebuf[adin.entlengthw++]=c

#ifndef OLDCHDR
void emitentity(void)
#else
void emitentity()
#endif
{
  fwrite(adin.writebuf,adin.entlengthw,1,adin.dwgfilew SUBN);
  if (!adin.inblockdefwflag SUBN) adin.entlistendw SUBN=ftell(adin.dwgfilew SUBN);
}

#ifndef OLDCHDR
void dogarbage1(void)
#else
void dogarbage1()
#endif
{
  if (adct.copymode SUBN) {
    /* set acad file verion # being written */
#ifndef OCTALONLY
    if (adct.ouracadverw SUBN==ACAD25) adin.garbage1 SUBN [11]='\x72';
    if (adct.ouracadverw SUBN==ACAD26) adin.garbage1 SUBN [11]='\x7A';
    if (adct.ouracadverw SUBN==ACAD9)  adin.garbage1 SUBN [11]='\x81';
    if (adct.ouracadverw SUBN==ACAD10) adin.garbage1 SUBN [11]='\xA0';
    if (adct.ouracadverw SUBN==ACAD11) adin.garbage1 SUBN [11]='\xCD';
#else
    if (adct.ouracadverw SUBN==ACAD25) adin.garbage1 SUBN [11]='\162';
    if (adct.ouracadverw SUBN==ACAD26) adin.garbage1 SUBN [11]='\172';
    if (adct.ouracadverw SUBN==ACAD9)  adin.garbage1 SUBN [11]='\201';
    if (adct.ouracadverw SUBN==ACAD10) adin.garbage1 SUBN [11]='\240';
    if (adct.ouracadverw SUBN==ACAD11) adin.garbage1 SUBN [11]='\315';
#endif

    fwrite(adin.garbage1 SUBN ,14,1,adin.dwgfilew SUBN);
  }
  else {
    zeroes(6);
#ifndef OCTALONLY
    if (adct.ouracadverw SUBN==ACAD25) fwrite("\0\3\0\5\0\x72\0\0",8,1,adin.dwgfilew SUBN);
    else if (adct.ouracadverw SUBN==ACAD26) fwrite("\1\3\0\5\0\x7A\0\0",8,1,adin.dwgfilew SUBN);
    else if (adct.ouracadverw SUBN==ACAD9) fwrite("\1\3\0\5\0\x81\0\0",8,1,adin.dwgfilew SUBN);
    else if (adct.ouracadverw SUBN==ACAD10) fwrite("\1\3\0\5\0\xA0\0\0",8,1,adin.dwgfilew SUBN);
    else if (adct.ouracadverw SUBN==ACAD11) fwrite("\1\3\0\5\0\xCD\0\0",8,1,adin.dwgfilew SUBN);

#else
     if (adct.ouracadverw SUBN==ACAD25) fwrite("\0\3\0\5\0\162\0\0",8,1,adin.dwgfilew SUBN);
    else if (adct.ouracadverw SUBN==ACAD26) fwrite("\1\3\0\5\0\172\0\0",8,1,adin.dwgfilew SUBN);
    else if (adct.ouracadverw SUBN==ACAD9) fwrite("\1\3\0\5\0\201\0\0",8,1,adin.dwgfilew SUBN);
    else if (adct.ouracadverw SUBN==ACAD10) fwrite("\1\3\0\5\0\240\0\0",8,1,adin.dwgfilew SUBN);
    else if (adct.ouracadverw SUBN==ACAD11) fwrite("\1\3\0\5\0\315\0\0",8,1,adin.dwgfilew SUBN);
#endif
 }
}

#ifndef OLDCHDR
void dogarbage2(void)
#else
void dogarbage2()
#endif
{
  if (adct.copymode SUBN) fwrite(adin.garbage2 SUBN,4,1,adin.dwgfilew SUBN);
  else {
    if (adct.ouracadverw SUBN<ACAD10) {
      zeroes(3);
#ifndef OCTALONLY
      fputc('\x40',adin.dwgfilew SUBN);
#else
      fputc('\100',adin.dwgfilew SUBN);
#endif
    }
    else fwrlong(0x400003A1L);
  }
}

#ifndef OLDCHDR
void dogarbage9(void)
#else
void dogarbage9()
#endif
{
  if (adct.ouracadverw SUBN >=ACAD11) {
    adin.garbage9 SUBN [10]=adhd.psltscale;
    adin.garbage9 SUBN [12]=adhd.treedepth & 255;
    adin.garbage9 SUBN [13]=(adhd.treedepth >> 8);
  }
  if (adct.copymode SUBN) fwrite(adin.garbage9 SUBN,1,24,adin.dwgfilew SUBN);
  else { /* a real */
#ifndef OCTALONLY
    fputc('\x0F',adin.dwgfilew SUBN);
#else
    fputc('\17',adin.dwgfilew SUBN);
#endif
    zeroes(8);
    if (adct.ouracadverw SUBN >=ACAD11)
      fwrw(adhd.psltscale);
    else zeroes(2);
    if (adct.ouracadverw SUBN >=ACAD11)
      fwrw(adhd.treedepth);
    else zeroes(2);
    zeroes(3);
#ifndef OCTALONLY
    fwrite("\xD\xCB\x26\x32\x69\x96\xF6\x3F",8,1,adin.dwgfilew SUBN);
#else
    fwrite("\15\313\46\62\151\226\366\77",8,1,adin.dwgfilew SUBN);
#endif
  }
}

#ifndef OLDCHDR
void dogarbage10(void)
#else
void dogarbage10()
#endif
{
  short i,j;

  if (adct.copymode SUBN) fwrite(adin.garbage10 SUBN,1,146,adin.dwgfilew SUBN);
  else {
    if (adct.ouracadverw SUBN<ACAD10) {
      /*1 0 0, 0 1 0, 0 0 1, 1 0 0, 0 1 0, 0 0 1 */
      for (j=0; j<4; j++) {
        fwrreal(1.0);
        for (i=0; i<3; i++) fwrreal(0.0);
        if (j % 2 ==1) fwrreal(1.0);
      }
      fwrw(0);
    }
    else {
      for (i=0; i<18; i++) fwrreal(0.0);
      fwrw(0);
    }
  }
}

#ifndef OLDCHDR
void dogarbage11(void)
#else
void dogarbage11()
#endif
{
  if (adct.copymode SUBN) fwrite(adin.garbage11 SUBN,1,4,adin.dwgfilew SUBN);
  else {
    zeroes(2);
    fwrw(100);  /* 64 hex */
  }
}

#ifndef OLDCHDR
void dogarbage12(void)
#else
void dogarbage12()
#endif
{
  if (adct.copymode SUBN) fwrite(adin.garbage12 SUBN,1,14,adin.dwgfilew SUBN);
    else zeroes(14);
}

#ifndef OLDCHDR
void dogarbage14(void)
#else
void dogarbage14()
#endif
{
  if (adct.copymode SUBN) fwrw(adin.garbage14 SUBN);
  else fwrw(0);
}

#ifndef OLDCHDR
void dogarbage15(void)
#else
void dogarbage15()
#endif
{
  if (adct.ouracadverw SUBN >= ACAD11)
    adin.garbage15 SUBN=adhd.dwgcodepage;
  if (adct.copymode SUBN) fwrw(adin.garbage15 SUBN); else fwrw(0);
}

#ifndef OLDCHDR
void dogarbage16(void)
#else
void dogarbage16()
#endif
{
  if (adct.copymode SUBN) fwrc(adin.garbage16 SUBN);
  else fwrc('\0');
}

#ifndef OLDCHDR
void dogarbage17(void)
#else
void dogarbage17()
#endif
{
  if (adct.copymode SUBN) fwrc(adin.garbage17 SUBN);
  else fwrc('\0');
}

#ifndef OLDCHDR
void dogarbage18(void)
#else
void dogarbage18()
#endif
{
  if (adct.copymode SUBN) fwrc(adin.garbage18 SUBN);
  else fwrc('\0');
}

#ifndef OLDCHDR
void dogarbage20(void)
#else
void dogarbage20()
#endif
{
  if (adct.copymode SUBN) fwrw(adin.garbage20 SUBN);
  else fwrw(0);
}

#ifndef OLDCHDR
void dogarbage21(void)
#else
void dogarbage21()
#endif
{
  if (adct.copymode SUBN) fwrw(adin.garbage21 SUBN);
  else fwrw(33); /* hex 21 */
}

#ifndef OLDCHDR
void dogarbage25(void)
#else
void dogarbage25()
#endif
{
  if (adct.copymode SUBN) fwrlong(adin.garbage25 SUBN);
  else fwrlong(0L);
}

#ifndef OLDCHDR
void dogarbage22(void)
#else
void dogarbage22()
#endif
{
  if (adct.copymode SUBN) fwrite(adin.garbage22 SUBN,3,1,adin.dwgfilew SUBN);
    else {
      fwrw(0);
      fwrc(0);
    }
}

#ifndef OLDCHDR
void dogarbage23(void)
#else
void dogarbage23()
#endif
{
  if (adct.copymode SUBN) fwrw(adin.garbage23 SUBN);
  else fwrw(0);
}

#ifndef OLDCHDR
void dogarbage24(void)
#else
void dogarbage24()
#endif
{
  short i;

  if (adct.copymode SUBN) fwrite(adin.garbage24 SUBN,160,1,adin.dwgfilew SUBN);
  else {
#ifndef OCTALONLY
    fwrite("\x0\x0\x1C\x0\x7E\xFD\x57\x42",8,1,adin.dwgfilew SUBN);
#else
    fwrite("\0\0\34\0\176\375\127\102",8,1,adin.dwgfilew SUBN);
#endif
    for (i=0; i<3; i++) fwrreal(1.0);
#ifndef OCTALONLY
    fwrc(0x6D);
#else
    fwrc('\155');
#endif
    zeroes(127);
  }
}

#ifndef OLDCHDR
void tablecrc(char *tblinfo,short tblentrysize,short tblmagic)
#else
void tablecrc(tblinfo,tblentrysize,tblmagic)
char *tblinfo;
short tblentrysize;
short tblmagic;
#endif
/* compute and place in string table crc value */
{
  short temp;

  temp=crc8(0,tblinfo,tblentrysize-2);
#if !defined(BIGENDIAN) && !defined(QUADWORDALIGNED)
  *(short *)&tblinfo[tblentrysize-2]=temp ^ tblmagic;
#else
  temp^=tblmagic;
  tblinfo[tblentrysize-2]=temp & 255;
  tblinfo[tblentrysize-1]=temp >> 8;
#endif
}


#ifndef OLDCHDR
void startblockheaderwrite(void)
#else
void startblockheaderwrite()
#endif
{
  if (adct.ouracadverw SUBN >= ACAD11) {
    fwrite(entendsentinel,16,1,adin.dwgfilew SUBN);
    fwrite(blockhdrstartsentinel,16,1,adin.dwgfilew SUBN);
  }
  adin.blkliststartw SUBN=ftell(adin.dwgfilew SUBN);
  adct.numblocksw SUBN=0;
}

#ifndef OLDCHDR
void writeblockheader(void)
#else
void writeblockheader()
#endif
{
  clearbuffer(adin.sizeofblockheaderentryw SUBN);
/* block array -- 0th char is flag, '\x40' if referenced currently,
   1-32 is block name */
  adin.writebuf[0]=adtb.blkh.flag;
  memcpy(&(adin.writebuf[1]),adtb.blkh.name,32);
  /* need to fixup block offset later */
  if (adct.ouracadverw SUBN >=ACAD11) {
    adin.entlengthw=33;
    wrw(adtb.blkh.xrefindex);
    adin.entlengthw=39;
    wrlong(-1L);
  }
/* NOTE -- no crc update here, as it is done in the "initializeblockdef"
   routine when the definition is actually being written */
  fwrite(adin.writebuf,adin.sizeofblockheaderentryw SUBN,1,adin.dwgfilew SUBN);
  adct.numblocksw SUBN++;
}

#ifndef OLDCHDR
void startlayerwrite(void)
#else
void startlayerwrite()
#endif
{
  if (adct.ouracadverw SUBN >= ACAD11) {
    fwrite(blockhdrendsentinel,16,1,adin.dwgfilew SUBN);
    fwrite(layerstartsentinel,16,1,adin.dwgfilew SUBN);
  }
  adin.layerliststartw SUBN=ftell(adin.dwgfilew SUBN);
  adct.numlayersw SUBN=0;
}

#ifndef OLDCHDR
void writelayer(void)
#else
void writelayer()
#endif
{
/* structure of layer array -- 0th char is flag, where '\x80' bit indicates
   that the layer was purged, 1 bit indicates it is frozen, 1--31 are name,
   32 is not known, 33-4 are color, 35 is linetype, 36-7 not known */

  clearbuffer(adin.sizeoflayerentryw SUBN);
  adin.writebuf[0]=adtb.lay.flag;
  memcpy(&adin.writebuf[1],adtb.lay.name,32);
  adin.entlengthw=33;
  if (adct.ouracadverw SUBN >= ACAD11) wrw(adtb.lay.xrefindex);
  wrw(adtb.lay.color);
  wrw(adtb.lay.linetype);
  if (adct.ouracadverw SUBN >=ACAD11)
    tablecrc(adin.writebuf,adin.sizeoflayerentryw SUBN,layermagic);
  fwrite(adin.writebuf,adin.sizeoflayerentryw SUBN,1,adin.dwgfilew SUBN);
  adct.numlayersw SUBN++;
}

#ifndef OLDCHDR
void startshapewrite(void)
#else
void startshapewrite()
#endif
{
  if (adct.ouracadverw SUBN >= ACAD11) {
    fwrite(layerendsentinel,16,1,adin.dwgfilew SUBN);
    fwrite(shapestartsentinel,16,1,adin.dwgfilew SUBN);
  }
  adin.shapeliststartw SUBN=ftell(adin.dwgfilew SUBN);
  adct.numshapefilesw SUBN=0;
}

#ifndef OLDCHDR
void writeshapefile(void)
#else
void writeshapefile()
#endif
{
/* structure of style array -- 0th char is 4 if vertical font, 1-32 are style
   name, then double-prec height, width factor, obliquing angle.  Style byte
   is bit coded 2 for backwards, 4 for upside down.  Then last shape height.
   Associated text file is next.
*/
  short offset;

  if (adct.ouracadverw SUBN >=ACAD11) offset=2; else offset=0;
  clearbuffer(adin.sizeofshapefileentryw SUBN);
  adin.writebuf[0]=adtb.shape.flag; /* 0 for text file, 1 for shape file */
  memcpy(&(adin.writebuf[1]),adtb.shape.name,32);
  /* this needs to be looked into further, i.e. there is too much */
  /* unaccounted for space */
  adin.entlengthw=33;
  if (adct.ouracadverw SUBN >= ACAD11) wrw(adtb.shape.xrefindex);
  wrreal(adtb.shape.height);
  wrreal(adtb.shape.width);
  wrreal(adtb.shape.angle);
  wrc(adtb.shape.flag2);
  wrreal(adtb.shape.lastshapeheight);
  strcpy(&(adin.writebuf[66+offset]),adtb.shape.file);
  strcpy(&(adin.writebuf[130+offset]),adtb.shape.bigfontname);
/*  if (strlen(bigfontname)>0) adin.writebuf[0] |=1; */
  if (adct.ouracadverw SUBN >=ACAD11)
    tablecrc(adin.writebuf,adin.sizeofshapefileentryw SUBN,shapemagic);
  fwrite(adin.writebuf,adin.sizeofshapefileentryw SUBN,1,adin.dwgfilew SUBN);
  adct.numshapefilesw SUBN++;
}

#ifndef OLDCHDR
void startlinetypewrite(void)
#else
void startlinetypewrite()
#endif
{
  if (adct.ouracadverw SUBN >= ACAD11) {
    fwrite(shapeendsentinel,16,1,adin.dwgfilew SUBN);
    fwrite(linetypestartsentinel,16,1,adin.dwgfilew SUBN);
  }
  adin.linetypeliststartw SUBN=ftell(adin.dwgfilew SUBN);
  adct.numlinetypesw SUBN=0;
}

#ifndef OLDCHDR
void writelinetype(void)
#else
void writelinetype()
#endif
{
  short i;

/* linetype name is at location 1
   should also be an alignment code, number of dash length items, total
   pattern length, and dash lengths 1 .. n */

  clearbuffer(adin.sizeoflinetypeentryw SUBN);
  adin.writebuf[0]=adtb.ltype.flag;
  memcpy(&adin.writebuf[1],adtb.ltype.name,32);
  adin.entlengthw=33;
  if (adct.ouracadverw SUBN >= ACAD11) wrw(adtb.ltype.xrefindex);
  strcpy(&adin.writebuf[adin.entlengthw],adtb.ltype.text);
  adin.entlengthw=81;
  if (adct.ouracadverw SUBN >=ACAD11) adin.entlengthw+=2;

  wrc((char)adtb.ltype.alignflag);
  wrc((char)adtb.ltype.numlinetypevals);
  wrreal(adtb.ltype.patternlength);
  for (i=0; i<adtb.ltype.numlinetypevals; i++) wrreal(adtb.ltype.val[i]);
  if (adct.ouracadverw SUBN >=ACAD11)
    tablecrc(adin.writebuf,adin.sizeoflinetypeentryw SUBN,linetypemagic);
  fwrite(adin.writebuf,adin.sizeoflinetypeentryw SUBN,1,adin.dwgfilew SUBN);
  adct.numlinetypesw SUBN++;
}

#ifndef OLDCHDR
void startviewwrite(void)
#else
void startviewwrite()
#endif
{
  if (adct.ouracadverw SUBN >= ACAD11) {
    fwrite(linetypeendsentinel,16,1,adin.dwgfilew SUBN);
    fwrite(viewstartsentinel,16,1,adin.dwgfilew SUBN);
  }
  adin.viewliststartw SUBN=ftell(adin.dwgfilew SUBN);
  adct.numviewsw SUBN=0;
}

#ifndef OLDCHDR
void writeview(void)
#else
void writeview()
#endif
{
/* views.  1-32 is view name.  then real viewht, real viewctrx and viewctry,
   real viewwidth, real viewdir from origin x,y,z. (3 reals). then 3 bytes */
  clearbuffer(adin.sizeofviewentryw SUBN);
  adin.writebuf[0]=adtb.view.flag;
  memcpy(&adin.writebuf[1],adtb.view.name,32);
  adin.entlengthw=33;
  if (adct.ouracadverw SUBN >= ACAD11) wrw(adtb.view.xrefindex);
  wrreal(adtb.view.ht);
  wrreal(adtb.view.center[0]);
  wrreal(adtb.view.center[1]);
  wrreal(adtb.view.width);
  wrreal(adtb.view.dir[0]);
  wrreal(adtb.view.dir[1]);
  wrreal(adtb.view.dir[2]);
  if (adct.ouracadverw SUBN>ACAD9) {
    wrw(adtb.view.flag2);
    wrreal(adtb.view.target[0]);
    wrreal(adtb.view.target[1]);
    wrreal(adtb.view.target[2]);
    wrreal(adtb.view.lenslength);
    wrreal(adtb.view.twist);
    wrreal(adtb.view.frontclip);
    wrreal(adtb.view.backclip);
    wrw(adtb.view.viewmode);
  }
  if (adct.ouracadverw SUBN >=ACAD11)
    tablecrc(adin.writebuf,adin.sizeofviewentryw SUBN,viewmagic);

  fwrite(adin.writebuf,adin.sizeofviewentryw SUBN,1,adin.dwgfilew SUBN);
  adct.numviewsw SUBN++;
}

#ifndef OLDCHDR
void startucswrite(void)
#else
void startucswrite()
#endif
{
  if (adct.ouracadverw SUBN >= ACAD11) {
    fwrite(viewendsentinel,16,1,adin.dwgfilew SUBN);
    fwrite(ucsstartsentinel,16,1,adin.dwgfilew SUBN);
  }
  adin.ucsliststartw SUBN=ftell(adin.dwgfilew SUBN);
  adct.numucsw SUBN=0L;
}

#ifndef OLDCHDR
void writeucs(void)
#else
void writeucs()
#endif
{
  clearbuffer(adin.sizeofucsentryw SUBN);
  if (adtb.ucs.purgedflag==1) adtb.ucs.flag |= 128;
  adin.writebuf[0]=adtb.ucs.flag;
  memcpy(&adin.writebuf[1],adtb.ucs.name,32);
  adin.entlengthw=33;
  if (adct.ouracadverw SUBN >= ACAD11) wrw(adtb.ucs.xrefindex);
  wrreal(adtb.ucs.org[0]);
  wrreal(adtb.ucs.org[1]);
  wrreal(adtb.ucs.org[2]);
  wrreal(adtb.ucs.xdir[0]);
  wrreal(adtb.ucs.xdir[1]);
  wrreal(adtb.ucs.xdir[2]);
  wrreal(adtb.ucs.ydir[0]);
  wrreal(adtb.ucs.ydir[1]);
  wrreal(adtb.ucs.ydir[2]);
  if (adct.ouracadverw SUBN >=ACAD11)
    tablecrc(adin.writebuf,adin.sizeofucsentryw SUBN,ucsmagic);
  fwrite(adin.writebuf,adin.sizeofucsentryw SUBN,1,adin.dwgfilew SUBN);
  adct.numucsw SUBN++;
}

#ifndef OLDCHDR
void startvportwrite(void)
#else
void startvportwrite()
#endif
{
  if (adct.ouracadverw SUBN >= ACAD11) {
    fwrite(ucsendsentinel,16,1,adin.dwgfilew SUBN);
    fwrite(vportstartsentinel,16,1,adin.dwgfilew SUBN);
  }
  adin.vportliststartw SUBN=ftell(adin.dwgfilew SUBN);
  adct.numvportsw SUBN=0L;
}

#ifndef OLDCHDR
void writevport(void)
#else
void writevport()
#endif
{
  clearbuffer(adin.sizeofvportentryw SUBN);
  if (adtb.vport.purgedflag) adtb.vport.flag |=128;
  adin.writebuf[0]=adtb.vport.flag;
  memcpy(&adin.writebuf[1],adtb.vport.name,32);
  adin.entlengthw=33;
  if (adct.ouracadverw SUBN >= ACAD11) wrw(adtb.vport.xrefindex);
  wrreal(adtb.vport.ll[0]);
  wrreal(adtb.vport.ll[1]);
  wrreal(adtb.vport.ur[0]);
  wrreal(adtb.vport.ur[1]);
  wr3real(adtb.vport.target);
  wr3real(adtb.vport.viewdir);
  wrreal(adtb.vport.viewtwist);
  wrreal(adtb.vport.viewheight);
  wr2real(adtb.vport.center);
  wrreal(adtb.vport.aspect);
  wrreal(adtb.vport.lenslength);
  wrreal(adtb.vport.frontclip);
  wrreal(adtb.vport.backclip);
  wrw(adtb.vport.viewmode);
  wrw(adtb.vport.zoomperc);
  wrw(adtb.vport.fastzoom);
  wrw(adtb.vport.ucsicon);
  wrw(adtb.vport.snapmode);
  wrw(adtb.vport.gridmode);
  wrw(adtb.vport.snapstyle);
  wrw(adtb.vport.snapisopair);
  wrreal(adtb.vport.snaprot);
  wrreal(adtb.vport.snapbase[0]);
  wrreal(adtb.vport.snapbase[1]);
  wrreal(adtb.vport.snapdist[0]);
  wrreal(adtb.vport.snapdist[1]);
  wrreal(adtb.vport.griddist[0]);
  wrreal(adtb.vport.griddist[1]);
  if (adct.ouracadverw SUBN >= ACAD11)
    tablecrc(adin.writebuf,adin.sizeofvportentryw SUBN,vportmagic);
  fwrite(adin.writebuf,adin.sizeofvportentryw SUBN,1,adin.dwgfilew SUBN);
  adct.numvportsw SUBN++;
}

#ifndef OLDCHDR
void startvportenthdrwrite(void)
#else
void startvportenthdrwrite()
#endif
{
  if (adct.ouracadverw SUBN < ACAD11) return;
  fwrite(dimstyleendsentinel,16,1,adin.dwgfilew SUBN);
  fwrite(vportenthdrstartsentinel,16,1,adin.dwgfilew SUBN);
  adin.vportenthdrliststartw SUBN=ftell(adin.dwgfilew SUBN);
  adct.numvportenthdrsw SUBN=0L;
}

#ifndef OLDCHDR
void writevportenthdr(short whichvportent)
#else
void writevportenthdr(whichvportent)
short whichvportent;
#endif
{
  static short nonpurgedvportcount;

  if (whichvportent==0) nonpurgedvportcount=0;
  if (adct.ouracadverw SUBN < ACAD11) return;
  clearbuffer(adin.sizeofvportenthdrentryw SUBN);
  if (aden.vpent.purgedflag) aden.vpent.flag |=128;
  adin.writebuf[0]=(char)aden.vpent.flag;
  memcpy(&adin.writebuf[1],aden.vpent.name,32);
  adin.entlengthw=33;
  wrw(aden.vpent.xrefindex);
  if (whichvportent==0 || aden.vpent.purgedflag) {
    wrlong(-1L);
    wrw(0);
if (whichvportent!=0) nonpurgedvportcount++;  /* obviously, it no longer means that */
  }
  else {
    wrlong(adin.vportentloc SUBN[nonpurgedvportcount++]);
    wrw(aden.vpent.stackval);
  }
/* only in r11 and up dwgs */
  tablecrc(adin.writebuf,adin.sizeofvportenthdrentryw SUBN,vportenthdrmagic);
  fwrite(adin.writebuf,adin.sizeofvportenthdrentryw SUBN,1,adin.dwgfilew SUBN);
  adct.numvportenthdrsw SUBN++;
}

#ifndef OLDCHDR
void startregappwrite(void)
#else
void startregappwrite()
#endif
{
  if (adct.ouracadverw SUBN <ACAD11) return;
  fwrite(vportendsentinel,16,1,adin.dwgfilew SUBN);
  fwrite(regappstartsentinel,16,1,adin.dwgfilew SUBN);
  adin.regappliststartw SUBN=ftell(adin.dwgfilew SUBN);
  adct.numregappsw SUBN=0L;
}

#ifndef OLDCHDR
void writeregapp(void)
#else
void writeregapp()
#endif
{
  if (adct.ouracadverw SUBN <ACAD11) return;
  clearbuffer(adin.sizeofregappentryw SUBN);
  adin.writebuf[0]=(char)adtb.app.flag;
  memcpy(&adin.writebuf[1],adtb.app.name,32);
  adin.entlengthw=33;
  wrw(adtb.app.xrefindex);
  tablecrc(adin.writebuf,adin.sizeofregappentryw SUBN,regappmagic);
  fwrite(adin.writebuf,adin.sizeofregappentryw SUBN,1,adin.dwgfilew SUBN);
  adct.numregappsw SUBN++;
}

#ifndef OLDCHDR
void startdimstylewrite(void)
#else
void startdimstylewrite()
#endif
{
  if (adct.ouracadverw SUBN < ACAD11) return;
  fwrite(regappendsentinel,16,1,adin.dwgfilew SUBN);
  fwrite(dimstylestartsentinel,16,1,adin.dwgfilew SUBN);
  adin.dimstyleliststartw SUBN=ftell(adin.dwgfilew SUBN);
  adct.numdimstylesw SUBN=0L;
}

#ifndef OLDCHDR
void writedimstyle(void)
#else
void writedimstyle()
#endif
{
  if (adct.ouracadverw SUBN<ACAD11) return;

  clearbuffer(adin.sizeofdimstyleentryw SUBN);

  adin.writebuf[0]=adtb.dimst.flag;
  memcpy(&adin.writebuf[1],adtb.dimst.name,32);
  adin.entlengthw=33;
  wrw(adtb.dimst.xrefindex);
  wrreal(adtb.dimst.dimscale);
  wrreal(adtb.dimst.dimasz);
  wrreal(adtb.dimst.dimexo);
  wrreal(adtb.dimst.dimdli);
  wrreal(adtb.dimst.dimexe);
  wrreal(adtb.dimst.dimrnd);
  wrreal(adtb.dimst.dimdle);
  wrreal(adtb.dimst.dimtp);
  wrreal(adtb.dimst.dimtm);
  wrreal(adtb.dimst.dimtxt);
  wrreal(adtb.dimst.dimcen);
  wrreal(adtb.dimst.dimtsz);
  wrreal(adtb.dimst.dimaltf);
  wrreal(adtb.dimst.dimlfac);
  wrreal(adtb.dimst.dimtvp);
  wrc(adtb.dimst.dimtol);
  wrc(adtb.dimst.dimlim);
  wrc(adtb.dimst.dimtih);
  wrc(adtb.dimst.dimtoh);
  wrc(adtb.dimst.dimse1);
  wrc(adtb.dimst.dimse2);
  wrc(adtb.dimst.dimtad);
  wrc(adtb.dimst.dimzin);
  wrc(adtb.dimst.dimalt);
  wrc(adtb.dimst.dimaltd);
  wrc(adtb.dimst.dimtofl);
  wrc(adtb.dimst.dimsah);
  wrc(adtb.dimst.dimtix);
  wrc(adtb.dimst.dimsoxd);
  memcpy(&adin.writebuf[169],adtb.dimst.dimpost,16);
  memcpy(&adin.writebuf[185],adtb.dimst.dimapost,16);
  memcpy(&adin.writebuf[201],adtb.dimst.dimblk,33);
  memcpy(&adin.writebuf[234],adtb.dimst.dimblk1,33);
  memcpy(&adin.writebuf[267],adtb.dimst.dimblk2,33);
  adin.entlengthw=300;
  wrw(adtb.dimst.dimclrd);
  wrw(adtb.dimst.dimclre);
  wrw(adtb.dimst.dimclrt);
  wrreal(adtb.dimst.dimtfac);
  wrreal(adtb.dimst.dimgap);
  tablecrc(adin.writebuf,adin.sizeofdimstyleentryw SUBN,dimstylemagic);
  fwrite(adin.writebuf,adin.sizeofdimstyleentryw SUBN,1,adin.dwgfilew SUBN);
  adct.numdimstylesw SUBN++;
}

#ifndef OLDCHDR
void startblockdefwrite(void)
#else
void startblockdefwrite()
#endif
{
  if (adct.ouracadverw SUBN >= ACAD11) {
    fwrite(vportenthdrendsentinel,16,1,adin.dwgfilew SUBN);
    fwrite(blockdefstartsentinel,16,1,adin.dwgfilew SUBN);
  }
  adin.inblockdefwflag SUBN=1;
  adin.blkdefstartw SUBN=ftell(adin.dwgfilew SUBN);
}

#ifndef OLDCHDR
void initializeblockdef(long defno)
#else
void initializeblockdef(defno)
long defno;
#endif
{
  long holdloc;
  short offset;
  char defbuf[50];

  holdloc=ftell(adin.dwgfilew SUBN);      /* hold current location, position to loc of */
                                   /* this header item's offset locator */
  if (adct.ouracadverw SUBN<ACAD11) {
    offset=33;
    fseek(adin.dwgfilew SUBN,adin.blkliststartw SUBN+(long)adin.sizeofblockheaderentryw SUBN*defno+offset,0);
    fwrlong((holdloc-adin.blkdefstartw SUBN) & (long)0x03FFFFFF);
  }
  else {
    offset=35;
/* for 11, need to reread the header, put in offset, calculate crc, */
/* and replace the entry */
    fseek(adin.dwgfilew SUBN,adin.blkliststartw SUBN+(long)adin.sizeofblockheaderentryw SUBN*defno,0);
    fread(defbuf,adin.sizeofblockheaderentryw SUBN,1,adin.dwgfilew SUBN);
#if !defined(BIGENDIAN) && !defined(QUADWORDALIGNED)
    *(long *)&defbuf[offset]=((holdloc-adin.blkdefstartw SUBN) & (long)0x03FFFFFF) | 0x40000000L;
#else
#if defined(BIGENDIAN) && defined(QUADWORDALIGNED)
    adin.unixunion.unixlong=((holdloc-adin.blkdefstartw SUBN) & (long)0x03FFFFFF) | 0x40000000L;
    defbuf[offset]  =adin.unixunion.unixdata[3];
    defbuf[offset+1]=adin.unixunion.unixdata[2];
    defbuf[offset+2]=adin.unixunion.unixdata[1];
    defbuf[offset+3]=adin.unixunion.unixdata[0];
#endif
#if !defined(BIGENDIAN) && defined(QUADWORDALIGNED)
    adin.unixunion.unixlong=((holdloc-adin.blkdefstartw SUBN) & (long)0x03FFFFFF) | 0x40000000L;
    memcpy(&defbuf[offset],&adin.unixunion.unixlong,SIZEOFLONG);
#endif
#endif
/* return to where this goes */
    fseek(adin.dwgfilew SUBN,adin.blkliststartw SUBN+(long)adin.sizeofblockheaderentryw SUBN*defno,0);
    tablecrc(defbuf,adin.sizeofblockheaderentryw SUBN,blockheadermagic);
    fwrite(defbuf,adin.sizeofblockheaderentryw SUBN,1,adin.dwgfilew SUBN);
  }
  fseek(adin.dwgfilew SUBN,holdloc,0);
}

#ifndef OLDCHDR
void endblockdefwrite(void)
#else
void endblockdefwrite()
#endif
{
  /* update header? */
}

#ifndef OLDCHDR
void startentitywrite(void)
#else
void startentitywrite()
#endif
{
  adin.vportentcount SUBN=0;
  if (adct.ouracadverw SUBN >= ACAD11)
    fwrite(entstartsentinel,16,1,adin.dwgfilew SUBN);
  adin.entlistendw SUBN=adin.entliststartw SUBN=ftell(adin.dwgfilew SUBN);
  adin.inblockdefwflag SUBN=0;
}

#ifndef OLDCHDR
void terminatewrite(void)
#else
void terminatewrite()
#endif
{
  short i;
  long secondsentloc;
  short secondhdrlen;

  if (adct.ouracadverw SUBN >= ACAD11) {
    fwrite(blockdefendsentinel,16,1,adin.dwgfilew SUBN);
    fwrite(extraentstartsentinel,16,1,adin.dwgfilew SUBN);
    adin.extraentlocw SUBN=ftell(adin.dwgfilew SUBN);
    fwrite(extraentendsentinel,16,1,adin.dwgfilew SUBN);
    secondsentloc=ftell(adin.dwgfilew SUBN);
    fwrite(secondheadersentinel,16,1,adin.dwgfilew SUBN);
/* write second header */
    clearbuffer(16384);
    adin.entlengthw=0;
    wrw(16); /* 2nd hdr version */
    secondhdrlen=0x8A;
    wrw(secondhdrlen); /* its length */
    wrlong(adin.entliststartw SUBN);
    wrlong(adin.entlistendw SUBN);
    wrlong(adin.blkdefstartw SUBN);
    wrlong(adin.extraentlocw SUBN);  /* no extra ents, so write eof */
    wrlong(0L);
    wrlong(0L);
    wrw(0);
    wrw(10);  /* 10 table entries */

    wrw(1);   /* block header entry */
    wrw(adin.sizeofblockheaderentryw SUBN);
    wrw((short)adct.numblocksw SUBN);
    wrlong(adin.blkliststartw SUBN);

    wrw(2);   /* layer entry */
    wrw(adin.sizeoflayerentryw SUBN);
    wrw((short)adct.numlayersw SUBN);
    wrlong(adin.layerliststartw SUBN);

    wrw(3);  /* shape entry */
    wrw(adin.sizeofshapefileentryw SUBN);
    wrw((short)adct.numshapefilesw SUBN);
    wrlong(adin.shapeliststartw SUBN);

    wrw(5);  /* linetype entry */
    wrw(adin.sizeoflinetypeentryw SUBN);
    wrw((short)adct.numlinetypesw SUBN);
    wrlong(adin.linetypeliststartw SUBN);

    wrw(6);  /* view entry */
    wrw(adin.sizeofviewentryw SUBN);
    wrw((short)adct.numviewsw SUBN);
    wrlong(adin.viewliststartw SUBN);

    wrw(7);  /* ucs entry */
    wrw(adin.sizeofucsentryw SUBN);
    wrw((short)adct.numucsw SUBN);
    wrlong(adin.ucsliststartw SUBN);

    wrw(8);  /* vport entry */
    wrw(adin.sizeofvportentryw SUBN);
    wrw((short)adct.numvportsw SUBN);
    wrlong(adin.vportliststartw SUBN);

    wrw(9);  /* regapp entry */
    wrw(adin.sizeofregappentryw SUBN);
    wrw((short)adct.numregappsw SUBN);
    wrlong(adin.regappliststartw SUBN);

    wrw(10);  /* dimstyle entry */
    wrw(adin.sizeofdimstyleentryw SUBN);
    wrw((short)adct.numdimstylesw SUBN);
    wrlong(adin.dimstyleliststartw SUBN);

    wrw(11);  /* vport entity entry */
    wrw(adin.sizeofvportenthdrentryw SUBN);
    wrw((short)adct.numvportenthdrsw SUBN);
    wrlong(adin.vportenthdrliststartw SUBN);

    wrlong(secondsentloc);
    tablecrc(adin.writebuf,secondhdrlen,secondheadermagic);
    fwrite(adin.writebuf,secondhdrlen,1,adin.dwgfilew SUBN);
    fwrite(eofsentinel,16,1,adin.dwgfilew SUBN);
  } /* it was r11 or greater */
  else adin.extraentlocw SUBN=ftell(adin.dwgfilew SUBN);  /* end of file */

  rewind(adin.dwgfilew SUBN);     /* to beginning of file */
  for (i=0; i<6; i++) fputc(adhd.acadverw[i],adin.dwgfilew SUBN);
  dogarbage1();
  fwrlong(adin.entliststartw SUBN);
  fwrlong(adin.entlistendw SUBN);
  fwrlong(adin.blkdefstartw SUBN);
  if (adct.ouracadverw SUBN<ACAD11) fwrlong((adin.extraentlocw SUBN - adin.blkdefstartw SUBN) | 0x40000000L);  /* size of block def section */
  else fwrlong((adin.extraentlocw SUBN - adin.blkdefstartw SUBN - 32L) | 0x40000000L);  /* size of block def section */
/* dogarbage2(); */
  fwrlong(adin.extraentlocw SUBN);  /* no extra ents, so write eof */
  fwrlong(0x80000000L);      /* size of extra ent section */
  fwrw(adin.sizeofblockheaderentryw SUBN);
  fwrlong(adct.numblocksw SUBN);
  fwrlong(adin.blkliststartw SUBN);
  fwrw(adin.sizeoflayerentryw SUBN);
  fwrlong(adct.numlayersw SUBN);
  fwrlong(adin.layerliststartw SUBN);
  fwrw(adin.sizeofshapefileentryw SUBN);
  fwrlong(adct.numshapefilesw SUBN);
  fwrlong(adin.shapeliststartw SUBN);
  fwrw(adin.sizeoflinetypeentryw SUBN);
  fwrlong(adct.numlinetypesw SUBN);
  fwrlong(adin.linetypeliststartw SUBN);
  fwrw(adin.sizeofviewentryw SUBN);
  fwrlong(adct.numviewsw SUBN);
  fwrlong(adin.viewliststartw SUBN);
  if (adct.ouracadverw SUBN>=ACAD10) {  /* write ucs, vport locations */
    fseek(adin.dwgfilew SUBN,0x3EFL,0);
    fwrw(adin.sizeofucsentryw SUBN);
    fwrlong(adct.numucsw SUBN);
    fwrlong(adin.ucsliststartw SUBN);
    fseek(adin.dwgfilew SUBN,0x4EEL,0);
    fwrite(adhd.enthandseed,8,1,adin.dwgfilew SUBN); /* write out handseed */
    fseek(adin.dwgfilew SUBN,0x500L,0);
    fwrw(adin.sizeofvportentryw SUBN);
    fwrlong(adct.numvportsw SUBN);
    fwrlong(adin.vportliststartw SUBN);
    fseek(adin.dwgfilew SUBN,0x512L,0);
    if (adct.ouracadverw SUBN==ACAD10) {
      dogarbage21();
      dogarbage25();
      fwrlong(adin.curvportlocr SUBN);
    }
    if (adct.ouracadverw SUBN>=ACAD11) {
      fwrw(adin.sizeofregappentryw SUBN);
      fwrlong(adct.numregappsw SUBN);
      fwrlong(adin.regappliststartw SUBN);
      fseek(adin.dwgfilew SUBN,0x522L,0);
      fwrw(adin.sizeofdimstyleentryw SUBN);
      fwrlong(adct.numdimstylesw SUBN);
      fwrlong(adin.dimstyleliststartw SUBN);
      fseek(adin.dwgfilew SUBN,0x69FL,0);
      fwrw(adin.sizeofvportenthdrentryw SUBN);
      fwrlong(adct.numvportenthdrsw SUBN);
      fwrlong(adin.vportenthdrliststartw SUBN);

      rewind(adin.dwgfilew SUBN);
      fread(adin.writebuf,adin.headersize SUBN,1,adin.dwgfilew SUBN);
      tablecrc(adin.writebuf,adin.headersize SUBN,headermagic);
      rewind(adin.dwgfilew SUBN);
      fwrite(adin.writebuf,adin.headersize SUBN,1,adin.dwgfilew SUBN);
    }
  }
  fclose(adin.dwgfilew SUBN);
  ad_free(adin.writebuf);
}

#ifndef OLDCHDR
short initializewrite(char *fn,short buffersize)
#else
short initializewrite(fn,buffersize)
char *fn;
short buffersize;
#endif
{
  short retval;

  adin.needtowritesequencestart SUBN=0;
  if ((adin.dwgfilew SUBN=fopen(fn,"w+b"))==NULL) {
    return(0);
  }

  retval=setvbuf(adin.dwgfilew SUBN,NULL,_IOFBF,buffersize);
  if (retval) {
    fclose(adin.dwgfilew SUBN);
    return(0);  /* setvbuf unsuccessful */
  }

  if ((adin.writebuf=ad_malloc(WRITEBUFSZ))==NULL) {
    fclose(adin.dwgfilew SUBN);
    return(0);
  }

  adct.numblocksw SUBN=adct.numlayersw SUBN=adct.numshapefilesw SUBN=adct.numlinetypesw SUBN=
    adct.numviewsw SUBN=adct.numucsw SUBN=adct.numvportsw SUBN=
    adct.numregappsw SUBN=adct.numdimstylesw SUBN=adct.numvportenthdrsw SUBN=0L;
  adin.numentitiesw SUBN=0;
  return(1);
}

#ifndef OLDCHDR
void generatehandle(void)
#else
void generatehandle()
#endif
/* take enthandseed, move it to adenhd.enthandle, create new enthandseed */
{
  register short i;
  short carry;

  memcpy(adenhd.enthandle,adhd.enthandseed,8);

  /* increment enthandseed */
  carry=1;
  for (i=7; i>=0; i--) {
    adhd.enthandseed[i]+=(char)carry;
    if (carry==1 && adhd.enthandseed[i]=='\0') carry=1;
    else carry=0;
  }
  for (i=0; i<8; i++) {
    if (adenhd.enthandle[i]!=0) {
      adenhd.enthandlelength=8-i;
      break;
    }
  }
}

#ifndef OLDCHDR
void inithandles(void)
#else
void inithandles()
#endif
{
  memset(adhd.enthandseed,0,8);
  adhd.enthandseed[7]='\1';
}
