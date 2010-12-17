
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adw.c -- library routines for writing autocad drawing files */
/* version 1/12/89 */
/* define one of the following for turbo c or microsoft c */
/* #define turboc 1 */
/* #define microsoftc 1 */

#include "adwhdr.h"
#include "sentmag.h"

/* prototypes for local functions */

#ifdef PROTOTYPES
void tablecrc(char *tblinfo,short tblentrysize,short tblmagic);
short  crc8(short dx,char *p, short n);
#else
void tablecrc();
short crc8();
#endif

int crctable[]= {
0x0000,0xC0C1,0xC181,0x0140,0xC301,0x03C0,0x0280,0xC241,
0xC601,0x06C0,0x0780,0xC741,0x0500,0xC5C1,0xC481,0x0440,
0xCC01,0x0CC0,0x0D80,0xCD41,0x0F00,0xCFC1,0xCE81,0x0E40,
0x0A00,0xCAC1,0xCB81,0x0B40,0xC901,0x09C0,0x0880,0xC841,
0xD801,0x18C0,0x1980,0xD941,0x1B00,0xDBC1,0xDA81,0x1A40,
0x1E00,0xDEC1,0xDF81,0x1F40,0xDD01,0x1DC0,0x1C80,0xDC41,
0x1400,0xD4C1,0xD581,0x1540,0xD701,0x17C0,0x1680,0xD641,
0xD201,0x12C0,0x1380,0xD341,0x1100,0xD1C1,0xD081,0x1040,
0xF001,0x30C0,0x3180,0xF141,0x3300,0xF3C1,0xF281,0x3240,
0x3600,0xF6C1,0xF781,0x3740,0xF501,0x35C0,0x3480,0xF441,
0x3C00,0xFCC1,0xFD81,0x3D40,0xFF01,0x3FC0,0x3E80,0xFE41,
0xFA01,0x3AC0,0x3B80,0xFB41,0x3900,0xF9C1,0xF881,0x3840,
0x2800,0xE8C1,0xE981,0x2940,0xEB01,0x2BC0,0x2A80,0xEA41,
0xEE01,0x2EC0,0x2F80,0xEF41,0x2D00,0xEDC1,0xEC81,0x2C40,
0xE401,0x24C0,0x2580,0xE541,0x2700,0xE7C1,0xE681,0x2640,
0x2200,0xE2C1,0xE381,0x2340,0xE101,0x21C0,0x2080,0xE041,
0xA001,0x60C0,0x6180,0xA141,0x6300,0xA3C1,0xA281,0x6240,
0x6600,0xA6C1,0xA781,0x6740,0xA501,0x65C0,0x6480,0xA441,
0x6C00,0xACC1,0xAD81,0x6D40,0xAF01,0x6FC0,0x6E80,0xAE41,
0xAA01,0x6AC0,0x6B80,0xAB41,0x6900,0xA9C1,0xA881,0x6840,
0x7800,0xB8C1,0xB981,0x7940,0xBB01,0x7BC0,0x7A80,0xBA41,
0xBE01,0x7EC0,0x7F80,0xBF41,0x7D00,0xBDC1,0xBC81,0x7C40,
0xB401,0x74C0,0x7580,0xB541,0x7700,0xB7C1,0xB681,0x7640,
0x7200,0xB2C1,0xB381,0x7340,0xB101,0x71C0,0x7080,0xB041,
0x5000,0x90C1,0x9181,0x5140,0x9301,0x53C0,0x5280,0x9241,
0x9601,0x56C0,0x5780,0x9741,0x5500,0x95C1,0x9481,0x5440,
0x9C01,0x5CC0,0x5D80,0x9D41,0x5F00,0x9FC1,0x9E81,0x5E40,
0x5A00,0x9AC1,0x9B81,0x5B40,0x9901,0x59C0,0x5880,0x9841,
0x8801,0x48C0,0x4980,0x8941,0x4B00,0x8BC1,0x8A81,0x4A40,
0x4E00,0x8EC1,0x8F81,0x4F40,0x8D01,0x4DC0,0x4C80,0x8C41,
0x4400,0x84C1,0x8581,0x4540,0x8701,0x47C0,0x4680,0x8641,
0x8201,0x42C0,0x4380,0x8341,0x4100,0x81C1,0x8081,0x4040 };

#ifndef OLDCHDR
short crc8(short dx,char *p,short n)
#else
short crc8(dx,p,n)
short dx;     /* initial crc value */
char *p;    /* pointer to data */
short n;      /* number of items */
#endif
{
  register unsigned char al;

  while (n-- > 0) {
    al = (unsigned char)((*p) ^ ((char)(dx & 0xFF)));
    /* bx removed completely, al used in the next place bx did appear */
    dx = (dx>>8) & 0xFF;     /* combining these two stmts didn't get faster */
    dx = dx ^ crctable[al & 0xFF];
    p++;
  }
  return(dx);
}


#ifndef OLDCHDR
void zeroes(short count)  /* write count zeroes to adin.dwgfilew SUBN */
#else
void zeroes(count)  /* write count zeroes to adin.dwgfilew SUBN */
short count;
#endif
{
  while (count>0) {
    fputc('\0',adin.dwgfilew SUBN);
    count--;
  }
}

#ifndef OLDCHDR
void setoutputversion(short version)
#else
void setoutputversion(version)
short version;
#endif
{
  adct.ouracadverw SUBN=version;
  if (version==ACAD25) {
    strcpy(adhd.acadverw,"AC1002");
    adin.sizeofblockheaderentryw SUBN=38;
    adin.sizeoflayerentryw SUBN=38;
    adin.sizeofshapefileentryw SUBN=194;
    adin.sizeoflinetypeentryw SUBN=188;
    adin.sizeofviewentryw SUBN=92;
    adin.sizeofucsentryw SUBN=0;
    adin.sizeofvportentryw SUBN=0;
  }
  if (version==ACAD26) {
    strcpy(adhd.acadverw,"AC1003");
    adin.sizeofblockheaderentryw SUBN=38;
    adin.sizeoflayerentryw SUBN=38;
    adin.sizeofshapefileentryw SUBN=194;
    adin.sizeoflinetypeentryw SUBN=188;
    adin.sizeofviewentryw SUBN=92;
    adin.sizeofucsentryw SUBN=0;
    adin.sizeofvportentryw SUBN=0;
  }
  if (version==ACAD9) {
    strcpy(adhd.acadverw,"AC1004");
    adin.sizeofblockheaderentryw SUBN=37;
    adin.sizeoflayerentryw SUBN=37;
    adin.sizeofshapefileentryw SUBN=194;
    adin.sizeoflinetypeentryw SUBN=187;
    adin.sizeofviewentryw SUBN=91;
    adin.sizeofucsentryw SUBN=0;
    adin.sizeofvportentryw SUBN=0;
  }
  if (version==ACAD10) {
    strcpy(adhd.acadverw,"AC1006");
    adin.sizeofblockheaderentryw SUBN=37;
    adin.sizeoflayerentryw SUBN=37;
    adin.sizeofshapefileentryw SUBN=194;
    adin.sizeoflinetypeentryw SUBN=187;
    adin.sizeofviewentryw SUBN=149;
    adin.sizeofucsentryw SUBN=105;
    adin.sizeofvportentryw SUBN=249;
  }
  if (version==ACAD11) {
    strcpy(adhd.acadverw,"AC1009");
    adin.sizeofblockheaderentryw SUBN=45;
    adin.sizeoflayerentryw SUBN=41;
    adin.sizeofshapefileentryw SUBN=198;
    adin.sizeoflinetypeentryw SUBN=191;
    adin.sizeofviewentryw SUBN=153;
    adin.sizeofucsentryw SUBN=109;
    adin.sizeofvportentryw SUBN=253;
    adin.sizeofregappentryw SUBN=37;
    adin.sizeofdimstyleentryw SUBN=324;
    adin.sizeofvportenthdrentryw SUBN=43;
  }
}

#ifndef BIGENDIAN
void fwrreal(double r)  /* write a double precision real to file */
{
 fwrite(&r,SIZEOFDOUBLE,1,adin.dwgfilew SUBN);
}
#else
void fwrreal(r)  /* write a double precision real to file */
double r;
{
  char *cptr;
  short i;
  double tmp;

  tmp=r;
  cptr=(char *)&tmp;
  for (i=7; i>=0; i--) {
    adin.unixunion.unixdata[i] = *cptr;
    cptr++;
  }
  fwrite(adin.unixunion.unixdata,SIZEOFDOUBLE,1,adin.dwgfilew SUBN);
}
#endif

#ifndef BIGENDIAN
void fwrlong(long l)  /* write a long integer to file */
{
  fwrite(&l,SIZEOFLONG,1,adin.dwgfilew SUBN);
}
#else
void fwrlong(l)
long l;
{
  char *cptr;
  short i;
  long tmp;

  tmp=l;
  cptr=(char *)&tmp;
  for (i=3; i>=0; i--) {
    adin.unixunion.unixdata[i] = *cptr;
    cptr++;
  }
  fwrite(adin.unixunion.unixdata,SIZEOFLONG,1,adin.dwgfilew SUBN);
}
#endif

#ifndef BIGENDIAN
void wrreal(double r)  /* write a double precision real to entity */
{
  memcpy(&adin.writebuf[adin.entlengthw],&r,SIZEOFDOUBLE);
  adin.entlengthw+=SIZEOFDOUBLE;
}
#else
void wrreal(r)  /* write a double precision real to file */
double r;
{
  char *cptr;
  short i;
  double tmp;

  tmp=r;
  cptr=(char *)&tmp;
  for (i=7; i>=0; i--) {
    adin.writebuf[adin.entlengthw+i] = *cptr;
    cptr++;
  }
  adin.entlengthw+=SIZEOFDOUBLE;
}
#endif


#ifndef BIGENDIAN
void wr2real(void *a)  /* write a double precision real to entity */
{
  memcpy(&adin.writebuf[adin.entlengthw],a,2*SIZEOFDOUBLE);
  adin.entlengthw+=2*SIZEOFDOUBLE;
}
#else
void wr2real(a)  /* write a double precision real to file */
char *a;
{
  short i,j;
  double tmp;

  for (j=0; j<2; j++) {
    for (i=7; i>=0; i--) {
      adin.writebuf[adin.entlengthw+i] = *a;
      a++;
    }
    adin.entlengthw+=SIZEOFDOUBLE;
  }
}
#endif

#ifndef BIGENDIAN
void wr3real(void *a)  /* write a double precision real to entity */
{
  memcpy(&adin.writebuf[adin.entlengthw],a,3*SIZEOFDOUBLE);
  adin.entlengthw+=3*SIZEOFDOUBLE;
}
#else
void wr3real(a)  /* write a double precision real to file */
char *a;
{
  short i,j;
  double tmp;

  for (j=0; j<3; j++) {
    for (i=7; i>=0; i--) {
      adin.writebuf[adin.entlengthw+i] = *a;
      a++;
    }
    adin.entlengthw+=SIZEOFDOUBLE;
  }
}
#endif


#define wrc(c) adin.writebuf[adin.entlengthw++]=c

#ifndef BIGENDIAN
#ifndef OLDCHDR
void wrw(short w)
#else
void wrw(w)
short w;
#endif
{
  memcpy(&adin.writebuf[adin.entlengthw],&w,SIZEOFSHORT);
  adin.entlengthw+=SIZEOFSHORT;
}
#else
#ifndef OLDCHDR
void wrw(short w)  /* write a short to file */
#else
void wrw(w)
short w;
#endif
{
  char *cptr;
  short tmp,i;

  tmp=w;
  cptr=(char *)&tmp;
  for (i=1; i>=0; i--) {
    adin.writebuf[adin.entlengthw+i] = *cptr;
    cptr++;
  }
  adin.entlengthw+=SIZEOFSHORT;
}
#endif

#ifndef BIGENDIAN
void wrlong(long l)  /* write a long integer to entity */
{
  memcpy(&adin.writebuf[adin.entlengthw],&l,SIZEOFLONG);
  adin.entlengthw+=SIZEOFLONG;
}
#else
void wrlong(l)
long l;
{
  char *cptr;
  short i;
  long tmp;

  tmp=l;
  cptr=(char *)&tmp;
  for (i=3; i>=0; i--) {
    adin.writebuf[adin.entlengthw+i] = *cptr;
    cptr++;
  }
  adin.entlengthw+=SIZEOFLONG;
}
#endif


#ifndef OLDCHDR
void wracadstr(char *strng)  /* write autocad string to entity */
#else
void wracadstr(strng)  /* write autocad string to entity */
char *strng;
#endif
{
  wrw(strlen(strng));
  strcpy(&adin.writebuf[adin.entlengthw],strng);
  adin.entlengthw+=strlen(strng);
}

#ifndef OLDCHDR
void wrxdstr(char *strng)  /* write autocad xdata string to entity */
#else
void wrxdstr(strng)  /* write autocad xdata string to entity */
char *strng;
#endif
{
  wrc((char)strlen(strng));
  strcpy(&adin.writebuf[adin.entlengthw],strng);
  adin.entlengthw+=strlen(strng);
}

#ifndef OLDCHDR
void writeextrusioninfo(void)
#else
void writeextrusioninfo()
#endif
{
  wr3real(adenhd.extrusion);
}

#ifndef OLDCHDR
void linewqq(unsigned short entmaskw)
#else
void linewqq(entmaskw)
unsigned short entmaskw;
#endif
{
  wr2real(aden.line.pt0);
  if (adct.ouracadverw SUBN>=ACAD10) {
    if (aden.line.pt0[2]!=0.0 || aden.line.pt1[2]!=0.0) {
      wrreal(aden.line.pt0[2]);
    }
    else {
      adin.entpropw|=4;
    }
  }
  wr2real(aden.line.pt1);
  if (adct.ouracadverw SUBN>=ACAD10) {
    if (!(adin.entpropw & 4)) wrreal(aden.line.pt1[2]);
    if (adenhd.extrusioninfovalid) {
      writeextrusioninfo();
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
  }
}

#ifndef OLDCHDR
void pointwqq(unsigned short entmaskw)
#else
void pointwqq(entmaskw)
unsigned short entmaskw;
#endif
{
  wr2real(aden.point.pt0);
  if (adct.ouracadverw SUBN>=ACAD10) {
    if (aden.point.pt0[2]!=0.0) wrreal(aden.point.pt0[2]);
    else adin.entpropw|=4;
    if (adenhd.extrusioninfovalid) {
      writeextrusioninfo();
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
    if (aden.point.ucsxangle!=0.0) {
      wrreal(aden.point.ucsxangle);
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
  }
}

#ifndef OLDCHDR
void circlewqq(unsigned short entmaskw)
#else
void circlewqq(entmaskw)
unsigned short entmaskw;
#endif
{
/* z is already in elev */
  wr2real(aden.circle.pt0);
  wrreal(aden.circle.radius);
  if (adct.ouracadverw SUBN>=ACAD10) {
    if (adenhd.extrusioninfovalid) {
      writeextrusioninfo();
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
  }
}

#ifndef OLDCHDR
void shapewqq(unsigned short entmaskw)
#else
void shapewqq(entmaskw)
unsigned short entmaskw;
#endif
{
  wr2real(aden.shape.pt0);
  wrreal(aden.shape.scale);
  wrc((char)aden.shape.whichshape);
  if (aden.shape.rotang!=0.0) {
    adin.entflagw|=entmaskw;           /* set that bit */
    wrreal(aden.shape.rotang);
  }
  entmaskw<<=1;   /* mysterious 2 bit */
  adin.entflagw|=entmaskw;             /* for now, hardwired to set this */
  wrc(aden.shape.shapefileno);
  entmaskw<<=1;   /* move to 4 */
  if (aden.shape.widthfactor!=1.0) {
    adin.entflagw|=entmaskw;           /* 4 bit */
    wrreal(aden.shape.widthfactor);
  }
  entmaskw<<=1;   /* move to 8 */
  if (aden.shape.oblique!=0.0) {
    adin.entflagw|=entmaskw;           /* 8 bit */
    wrreal(aden.shape.oblique);
  }
  entmaskw<<=1;
  if (adct.ouracadverw SUBN>=ACAD10) {
    if (adenhd.extrusioninfovalid) {
      writeextrusioninfo();
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
  }
}

#ifndef OLDCHDR
void text2wqq(unsigned short entmaskw,struct adtdatastru *tdata)
#else
void text2wqq(entmaskw,tdata)
unsigned short entmaskw;
struct adtdatastru *tdata;
#endif
{
  if (tdata->rotang!=0.0) {
    adin.entflagw|=entmaskw;
    wrreal(tdata->rotang);
  }
  entmaskw<<=1;
  if (tdata->widthfactor!=1.0) {
    adin.entflagw|=entmaskw;
    wrreal(tdata->widthfactor);
  }
  entmaskw<<=1;
  if (tdata->oblique!=0.0) {
    adin.entflagw|=entmaskw;
    wrreal(tdata->oblique);
  }
  entmaskw<<=1;
  if (tdata->styleno!=0) {
    adin.entflagw|=entmaskw;
    wrc(tdata->styleno);
  }
  entmaskw<<=1;
 /* true for backward, upside down */
  if (tdata->generationflag!=0) {
    adin.entflagw|=entmaskw;
    wrc(tdata->generationflag);
  }
  entmaskw<<=1;
  if (tdata->justification!=0) {
    adin.entflagw|=entmaskw;
    wrc(tdata->justification);
  }
  entmaskw<<=1;
  if (tdata->secondtextloc[0]!=0.0 || tdata->secondtextloc[1]!=0.0) {
    adin.entflagw|=entmaskw;
    wr2real(tdata->secondtextloc);
  }
  entmaskw<<=1;
  if (adct.ouracadverw SUBN>=ACAD10) {
    if (adenhd.extrusioninfovalid) {
      writeextrusioninfo();
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
  }
  if (adct.ouracadverw SUBN>=ACAD11) {
    if (tdata->vertalignment!=0) {
      wrc(tdata->vertalignment);
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
  }
}

#ifndef OLDCHDR
void textwqq(unsigned short entmaskw)
#else
void textwqq(entmaskw)
unsigned short entmaskw;
#endif
{
  wr2real(aden.text.pt0);
  wrreal(aden.text.tdata.height);
  wracadstr(aden.text.textstr);
  text2wqq(entmaskw,&aden.text.tdata);
}

#ifndef OLDCHDR
void arcwqq(unsigned short entmaskw)
#else
void arcwqq(entmaskw)
unsigned short entmaskw;
#endif
{
  wr2real(aden.arc.pt0);
  wrreal(aden.arc.radius);
  wrreal(aden.arc.stang);
  wrreal(aden.arc.endang);
  if (adct.ouracadverw SUBN>=ACAD10) {
    if (adenhd.extrusioninfovalid) {
      writeextrusioninfo();
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
  }
}

#ifndef OLDCHDR
void tracewqq(unsigned short entmaskw)
#else
void tracewqq(entmaskw)
unsigned short entmaskw;
#endif
{ /* trace */
  wr2real(aden.trace.pt0);
  wr2real(aden.trace.pt1);
  wr2real(aden.trace.pt2);
  wr2real(aden.trace.pt3);
  if (adct.ouracadverw SUBN>=ACAD10) {
    if (adenhd.extrusioninfovalid) {
      writeextrusioninfo();
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
  }
}

#ifndef OLDCHDR
void solidwqq(unsigned short entmaskw)
#else
void solidwqq(entmaskw)
unsigned short entmaskw;
#endif
{
  tracewqq(entmaskw);
}

#ifndef OLDCHDR
void sblockwqq(unsigned short entmaskw)
#else
void sblockwqq(entmaskw)
unsigned short entmaskw;
#endif
{ /* start of block */
  wr2real(aden.block.base);
  if (adct.ouracadverw SUBN >= ACAD10) {
    if (aden.block.base[2]!=0.0) {
      wrreal(aden.block.base[2]);
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
  }
  if (adct.ouracadverw SUBN >= ACAD11) {
    if (strlen(aden.block.xrefpath)) {
      wracadstr(aden.block.xrefpath);
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
    if (strlen(aden.block.name2)) {
      wracadstr(aden.block.name2);
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
  }
}

#ifndef OLDCHDR
void eblockwqq(void)
#else
void eblockwqq()
#endif
{ /* end of block */
}

#ifndef OLDCHDR
void insertwqq(unsigned short entmaskw) /* Insert */
#else
void insertwqq(entmaskw) /* Insert */
unsigned short entmaskw;
#endif
{
  wrw(aden.insert.blockno);
  wr2real(aden.insert.pt0);
  if (aden.insert.attribsfollow) {
    adin.entpropw |= 128;  /* adin.entpropw */
    adin.needtowritesequencestart SUBN=1;
    adin.sequencestart SUBN=ftell(adin.dwgfilew SUBN);
    if (adin.inblockdefwflag SUBN) adin.sequencestart SUBN-=adin.blkdefstartw SUBN;
  }

  if (aden.insert.xscale!=1.0) {
    adin.entflagw|=entmaskw;
    wrreal(aden.insert.xscale);
  }
  entmaskw<<=1;
  if (aden.insert.yscale!=1.0) {
    adin.entflagw|=entmaskw;
    wrreal(aden.insert.yscale);
  }
  entmaskw<<=1;
  if (aden.insert.rotang!=0.0) {
    adin.entflagw|=entmaskw;
    wrreal(aden.insert.rotang);
  }
  entmaskw<<=1;
  if (aden.insert.zscale!=1.0) {
    adin.entflagw|=entmaskw;
    wrreal(aden.insert.zscale);
  }
  entmaskw<<=1;
  if (aden.insert.numcols!=1) {
    adin.entflagw|=entmaskw;
    wrw(aden.insert.numcols);
  }
  entmaskw<<=1;
  if (aden.insert.numrows!=1) {
    adin.entflagw|=entmaskw;
    wrw(aden.insert.numrows);
  }
  entmaskw<<=1;
  if (aden.insert.coldist!=0.0) {
    adin.entflagw|=entmaskw;
    wrreal(aden.insert.coldist);
  }
  entmaskw<<=1;
  if (aden.insert.rowdist!=0.0) {
    adin.entflagw|=entmaskw;
    wrreal(aden.insert.rowdist);
  }
  entmaskw<<=1;
  if (adct.ouracadverw SUBN>=ACAD10) {
    if (adenhd.extrusioninfovalid) {
      writeextrusioninfo();
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
  }
}

#ifndef OLDCHDR
void attdefwqq(unsigned short entmaskw) /* attdef */
#else
void attdefwqq(entmaskw) /* attdef */
unsigned short entmaskw;
#endif
{
  wr2real(aden.attdef.pt0);
  wrreal(aden.attdef.tdata.height);
  wracadstr(aden.attdef.defaultval);
  wracadstr(aden.attdef.prompt);
  wracadstr(aden.attdef.tag);
  wrc(aden.attdef.attflag);

  entmaskw<<=1;
  /* rest of entity is a text item */
  text2wqq(entmaskw,&aden.attdef.tdata);
}

#ifndef OLDCHDR
void attribwqq(unsigned short entmaskw) /* attrib */
#else
void attribwqq(entmaskw) /* attrib */
unsigned short entmaskw;
#endif
{
  wr2real(aden.attrib.pt0);
  wrreal(aden.attrib.tdata.height);
  wracadstr(aden.attrib.attval);
  wracadstr(aden.attrib.tag);
  wrc(aden.attrib.attflag);
  if (aden.attrib.fieldwidth) {
    wrc(aden.attrib.fieldwidth);
    adin.entflagw|=entmaskw;
  }
  entmaskw<<=1;
  /* rest of this entity is a text entity */
  text2wqq(entmaskw,&aden.attrib.tdata);
}

#ifndef OLDCHDR
void seqendwqq(void) /* seqend */
#else
void seqendwqq() /* seqend */
#endif
{
  if (adin.needtowritesequencestart SUBN) {
    wrlong(adin.sequencestart SUBN);
    adin.needtowritesequencestart SUBN=0;
  }
}

#ifndef OLDCHDR
void plinewqq(unsigned short entmaskw) /* polyline start */
#else
void plinewqq(entmaskw) /* polyline start */
unsigned short entmaskw;
#endif
{
  if (aden.pline.polyflag!=0) {
    adin.entflagw|=entmaskw;
    wrc((char)aden.pline.polyflag);
  }
  entmaskw<<=1;
  adin.needtowritesequencestart SUBN=1;
  adin.sequencestart SUBN=ftell(adin.dwgfilew SUBN);
  if (adin.inblockdefwflag SUBN) adin.sequencestart SUBN-=adin.blkdefstartw SUBN;

  if (aden.pline.startwidth!=0.0) {
    adin.entflagw|=entmaskw;
    wrreal(aden.pline.startwidth);
  }
  entmaskw<<=1;
  if (aden.pline.endwidth!=0.0) {
    adin.entflagw|=entmaskw;
    wrreal(aden.pline.endwidth);
  }
  entmaskw<<=1;
  if (adct.ouracadverw SUBN>=ACAD10) {
    if (adenhd.extrusioninfovalid) {
      writeextrusioninfo();
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
    if (aden.pline.meshm!=0) {
      wrw(aden.pline.meshm);
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
    if (aden.pline.meshn!=0) {
      wrw(aden.pline.meshn);
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
    if (aden.pline.meshmdensity!=0) {
      wrw(aden.pline.meshmdensity);
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
    if (aden.pline.meshndensity!=0) {
      wrw(aden.pline.meshndensity);
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
    if (aden.pline.fittype!=0) {
      wrw(aden.pline.fittype);
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
  }
}

#ifndef OLDCHDR
void vertexwqq(unsigned short entmaskw) /* vertex */
#else
void vertexwqq(entmaskw) /* vertex */
unsigned short entmaskw;
#endif
{
  short i;

  if (adct.ouracadverw SUBN < ACAD11 || aden.vertex.polyfacevertcount==0) {
    wr2real(aden.vertex.pt0);
  }
  if (aden.vertex.startwidthvalid) {
    adin.entflagw|=entmaskw;
    wrreal(aden.vertex.startwidth);
  }
  entmaskw<<=1;
  if (aden.vertex.endwidthvalid) {
    adin.entflagw|=entmaskw;
    wrreal(aden.vertex.endwidth);
  }
  entmaskw<<=1;
  if (aden.vertex.bulge!=0.0) {
    adin.entflagw|=entmaskw;
    wrreal(aden.vertex.bulge);
  }
  entmaskw<<=1;
  if (aden.vertex.vertexflag!=0) {
    adin.entflagw|=entmaskw;
    wrc((char)aden.vertex.vertexflag);
  }
  entmaskw<<=1;
  if (aden.vertex.tangentdir!=0.0) {
    adin.entflagw|=entmaskw;
    wrreal(aden.vertex.tangentdir);
  }
  entmaskw<<=1;
  if (adct.ouracadverw SUBN==ACAD10) {
    if (adenhd.extrusioninfovalid) {
      writeextrusioninfo();
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
  }
  if (adct.ouracadverw SUBN > ACAD10) {
    if (aden.vertex.polyfacevertcount==0) {          /* not a polyface defining vertices */
      if (adenhd.extrusioninfovalid) {
        writeextrusioninfo();
        adin.entflagw|=entmaskw;
      }
      entmaskw<<=1;
    }
    else {
      adin.entflagw |= 0x4000;
      for (i=0; i<4; i++) {
        if (i<aden.vertex.polyfacevertcount) {
          wrw(aden.vertex.polyfacevert[i]);
          adin.entflagw|=entmaskw;
        }
        entmaskw<<=1;
      }
    }
  }
}

#ifndef OLDCHDR
void line3dwqq(unsigned short entmaskw)
#else
void line3dwqq(entmaskw)
unsigned short entmaskw;
#endif
{
  wr2real(aden.line3d.pt0);
  if (adct.ouracadverw SUBN<ACAD10) {
    if (aden.line3d.pt0[2]!=0.0) {
      adin.entflagw|=entmaskw;
      wrreal(aden.line3d.pt0[2]);
    }
    entmaskw<<=1;
    wr2real(aden.line3d.pt1);
    if (aden.line3d.pt1[2]!=0.0) {
      adin.entflagw|=entmaskw;
      wrreal(aden.line3d.pt1[2]);
    }
    entmaskw<<=1;
  }
  else {
    if (aden.line3d.pt0[2]!=0.0 || aden.line3d.pt1[2]!=0.0) {
      wrreal(aden.line3d.pt0[2]);
    }
    else adin.entpropw|=4;
    wr2real(aden.line3d.pt1);
    if (!(adin.entpropw & 4)) wrreal(aden.line3d.pt1[2]);
    if (adenhd.extrusioninfovalid) {
      writeextrusioninfo();
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
  }
}

#ifndef OLDCHDR
void face3dwqq(unsigned short entmaskw)
#else
void face3dwqq(entmaskw)
unsigned short entmaskw;
#endif
{
  wr2real(aden.face3d.pt0);
  if (adct.ouracadverw SUBN<ACAD10) {
    if (aden.face3d.pt0[2]!=0.0) {
      adin.entflagw|=entmaskw;
      wrreal(aden.face3d.pt0[2]);
    }
    entmaskw<<=1;
    wr2real(aden.face3d.pt1);
    if (aden.face3d.pt1[2]!=0.0) {
      adin.entflagw|=entmaskw;
      wrreal(aden.face3d.pt1[2]);
    }
    entmaskw<<=1;
    wr2real(aden.face3d.pt2);
    if (aden.face3d.pt2[2]!=0.0) {
      adin.entflagw|=entmaskw;
      wrreal(aden.face3d.pt2[2]);
    }
    entmaskw<<=1;
    wr2real(aden.face3d.pt3);
    if (aden.face3d.pt3[2]!=0.0) {
      adin.entflagw|=entmaskw;
      wrreal(aden.face3d.pt3[2]);
    }
    entmaskw<<=1;
  }
  else { /* 10 or later */
    if (aden.face3d.pt0[2]!=0.0 || aden.face3d.pt1[2]!=0.0
     || aden.face3d.pt2[2]!=0.0 || aden.face3d.pt3[2]!=0.0) wrreal(aden.face3d.pt0[2]);
      else adin.entpropw|=4;
    wr2real(aden.face3d.pt1);
    if (!(adin.entpropw & 4)) wrreal(aden.face3d.pt1[2]);
    wr2real(aden.face3d.pt2);
    if (!(adin.entpropw & 4)) wrreal(aden.face3d.pt2[2]);
    wr2real(aden.face3d.pt3);
    if (!(adin.entpropw & 4)) wrreal(aden.face3d.pt3[2]);
    if (aden.face3d.faceflag!=0) {  /* invisible edges */
      adin.entflagw |= 1;
      wrw(aden.face3d.faceflag);
    }
  }  /* 3d faces cannot be extruded */
}

#ifndef OLDCHDR
void assodimwqq(unsigned short entmaskw) /* associative dimension */
#else
void assodimwqq(entmaskw) /* associative dimension */
unsigned short entmaskw;
#endif
{
  char flag2;

  wrw(aden.dim.dimblkno); /* index of the block that is this dim */
  wr2real(aden.dim.dimlinedefpt);
  if (adct.ouracadverw SUBN>=ACAD10) wrreal(aden.dim.dimlinedefpt[2]);
  wr2real(aden.dim.dimtextmidpt);
/* this needs to be fixed */
  if (aden.dim.dimcloneinfopresent) { /* is this info present ? */
    adin.entflagw|=entmaskw;
    wr2real(aden.dim.dimcloneinspt);
  }
  entmaskw<<=1;
  /* aden.dim.dimflag is -- 0 for horizontal, rotated, or vertical, 1 for aligned,
     2 for angular, 3 for diameter, 4 for radius.  128 is added if dimension
     text is located at other than the default position */
/* for release 11, 5 is angular 3 point dimen, 6 is ordinate (64 bit set for x,
default is y) */
  if (aden.dim.dimflag!=0) {
    adin.entflagw|=entmaskw;
    wrc(aden.dim.dimflag);
  }
  entmaskw<<=1;
  /* write dimension text if present */
  if (strlen(aden.dim.dimtext)!=0) {
    adin.entflagw|=entmaskw;
    wracadstr(aden.dim.dimtext);
  }
  entmaskw<<=1;
/* this is an attempt to use read the data in a useful fashion */
  flag2=(char)(aden.dim.dimflag & '\07');
  if (flag2==0 || flag2==1 ||
    (adct.ouracadverw SUBN>=ACAD11 && flag2==6)) { /* lin, ali, ord */
    wr2real(aden.dim.defpt2);
    if (adct.ouracadverw SUBN>=ACAD10) wrreal(aden.dim.defpt2[2]);
    wr2real(aden.dim.defpt3);
    if (adct.ouracadverw SUBN>=ACAD10) wrreal(aden.dim.defpt3[2]);
    adin.entflagw|=entmaskw;
    entmaskw<<=1;
    adin.entflagw|=entmaskw;
    entmaskw<<=3;
  }
  else if (flag2==2 || (adct.ouracadverw SUBN>=ACAD11 && flag2==5)) {  /* ang, ang3pt */
    wr2real(aden.dim.defpt2);
    if (adct.ouracadverw SUBN>=ACAD10) wrreal(aden.dim.defpt2[2]);
    wr2real(aden.dim.defpt3);
    if (adct.ouracadverw SUBN>=ACAD10) wrreal(aden.dim.defpt3[2]);
    wr2real(aden.dim.defpt4);
    if (adct.ouracadverw SUBN>=ACAD10) wrreal(aden.dim.defpt4[2]);
    wr2real(aden.dim.arcdefpt);
/*    if (adct.ouracadverw SUBN>=ACAD10) wrreal(aden.dim.arcdefptz); */
    adin.entflagw|=entmaskw;
    entmaskw<<=1;
    adin.entflagw|=entmaskw;
    entmaskw<<=1;
    adin.entflagw|=entmaskw;
    entmaskw<<=1;
    adin.entflagw|=entmaskw;
    entmaskw<<=1;
  }
  else if (flag2==3 || flag2==4) {   /* diam or radius */
    entmaskw<<=1;
    entmaskw<<=1;
    wr2real(aden.dim.defpt4);
    if (adct.ouracadverw SUBN>=ACAD10) wrreal(aden.dim.defpt4[2]);
    adin.entflagw|=entmaskw;
    entmaskw<<=1;
    entmaskw<<=1;
  }
  else entmaskw<<=4;
  if (aden.dim.leaderlen!=0.0) {
    adin.entflagw|=entmaskw;
    wrreal(aden.dim.leaderlen);
  }
  entmaskw<<=1;
  if (aden.dim.dimrotang!=0.0) {
    adin.entflagw|=entmaskw;
    wrreal(aden.dim.dimrotang);
  }
  if (adct.ouracadverw SUBN <=ACAD10) {
    entmaskw<<=5;
    if (adct.ouracadverw SUBN==ACAD10) {
      if (aden.dim.ucsxangle!=0.0) {
        adin.entflagw|=entmaskw;
        wrreal(aden.dim.ucsxangle);
      }
      entmaskw<<=1;
      if (adenhd.extrusioninfovalid) {
        writeextrusioninfo();
        adin.entflagw|=entmaskw;
      }
      entmaskw<<=1;
    }
  }
  if (adct.ouracadverw SUBN >= ACAD11) {
    entmaskw<<=1;
    if (aden.dim.dimoblique!=0.0) {
      wrreal(aden.dim.dimoblique);
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
    if (aden.dim.dimtextrot!=0.0) {
      wrreal(aden.dim.dimtextrot);
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=3;
    if (aden.dim.ucsxangle!=0.0) {
      wrreal(aden.dim.ucsxangle);
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;
    if (adenhd.extrusioninfovalid) {
      writeextrusioninfo();
      adin.entflagw|=entmaskw;
    }
    entmaskw<<=1;                      /* bit 15 */
    if (aden.dim.dimstyle!=-1) {
      wrw(aden.dim.dimstyle);
      adin.entflagw|=entmaskw;
    }
  }
}

#ifndef OLDCHDR
void vportentwqq(void)
#else
void vportentwqq()
#endif
{
  wr3real(aden.vpent.cen);
  wrreal(aden.vpent.width);
  wrreal(aden.vpent.height);
  wrw(aden.vpent.id);
}


#ifndef OLDCHDR
void startextendeddatawrite(void)
#else
void startextendeddatawrite()
#endif
{
  adin.xddatalengthw=0;
  wrw(adin.xddatalengthw);    /* a dummy -- update when done writing */
  adin.xddatastart=adin.entlengthw;  /* to compute the length */
}

#ifndef OLDCHDR
short writeextendeddata(void)
#else
short writeextendeddata()
#endif
{
  short i;

  wrc((char)(adxd.xddxfnumber-1000));
  if (adxd.xddxfnumber==1000) {           /* string */
    wrxdstr(adxd.xddata.xdstring);
  }
  else if (adxd.xddxfnumber==1001) {          /* regapp index */
    wrw(adxd.xddata.xdappindex);
  }
  else if (adxd.xddxfnumber==1003) {
    wrw(adxd.xddata.xdlayerindex);
  }
  else if (adxd.xddxfnumber==1005) {
    for (i=0; i<8; i++) wrc(adxd.xddata.xdhandle[i]);
  }
  else if (adxd.xddxfnumber==1010) {
    wr3real(adxd.xddata.xd3dpt);
  }
  else if (adxd.xddxfnumber==1040) {
    wrreal(adxd.xddata.xdreal);
  }
  else if (adxd.xddxfnumber==1070) {
    wrw(adxd.xddata.xdint);
  }
  else if (adxd.xddxfnumber==1071) {
    wrlong(adxd.xddata.xdlong);
  }
  else if (adxd.xddxfnumber==1002) {
    if (adxd.xddata.xdcontrol=='{')
      wrc(0);
    else wrc(1);
  }
  else if (adxd.xddxfnumber==1004) {            /* NEED TO CHECK */
    wrc((char)adxd.xdbindatalength);                /* binary data */
    memcpy(&adin.writebuf[adin.entlengthw],adxd.xddata.xdbindata,adxd.xdbindatalength);
    adin.entlengthw+=adxd.xdbindatalength;
  }
  else if (adxd.xddxfnumber==1011) {
    wr3real(adxd.xddata.xdworldpos);
  }
  else if (adxd.xddxfnumber==1012) {
    wr3real(adxd.xddata.xdworlddisp);
  }
  else if (adxd.xddxfnumber==1013) {
    wr3real(adxd.xddata.xdworlddir);
  }
  else if (adxd.xddxfnumber==1041) {
    wrreal(adxd.xddata.xddist);
  }
  else if (adxd.xddxfnumber==1042) {
    wrreal(adxd.xddata.xdscale);
  }
  return(1);
}

#ifndef OLDCHDR
void writeentity1(void)
#else
void writeentity1()
#endif
{
/*  clearbuffer(); */
  adin.writebuf[0]=adenhd.enttype;
  adin.entpropw=adin.entflagw=adin.entflagw2=0;
  if (adenhd.erasedflag) adin.writebuf[0] |=128;
                             /* adin.writebuf[2],[3] are length of entity */
  adin.entlengthw=4;               /* write at 4 */
  wrw(adenhd.layerindex);
  adin.entlengthw=8;  /* skip over ent length, flags */

  if (adct.ouracadverw SUBN >= ACAD11) {
    wrc(0);         /* leave a space for xddataflag, could come back */
                    /* later and update, for adin.entflagw2 presence or just lose it */
  }
}

#ifndef OLDCHDR
void writeentity2(void)
#else
void writeentity2()
#endif
{
  short i;

/* make it so that enttype and layer index can change on output */
  adin.writebuf[0]=adenhd.enttype;
  if (adenhd.erasedflag) adin.writebuf[0] |=128;
  i=adin.entlengthw;  /* hold this */
  adin.entlengthw=4;               /* write at 4 */
  wrw(adenhd.layerindex);
  adin.entlengthw=i;  /* and restore */

  if (adct.ouracadverw SUBN>=ACAD11) {
    adin.entflagw2=0;
    if (adenhd.paperspace) adin.entflagw2 |= 1;

    if (!adenhd.xddatapresent && !adin.entflagw2) {   /* don't need the xddataflag */
      adin.entlengthw--;                        /* so back up one */
    }
    else {
      adin.entpropw |= 0x40;
      if (adenhd.xddatapresent) {
        adin.writebuf[8] |= 2;
        adin.xddatalengthw=adin.entlengthw-adin.xddatastart;
#if !defined(QUADWORDALIGNED) && !defined(BIGENDIAN)
        *(short *)&adin.writebuf[9]=adin.xddatalengthw;
#else
        adin.writebuf[10]=adin.xddatalengthw >> 8;
        adin.writebuf[9] =adin.xddatalengthw & 255;
#endif
      }
    }
  }

  if (adenhd.entcolor!=0) {
    adin.entpropw |=1;
    if (adenhd.entcolor==BYBLOCK) wrc('\0');
      else wrc((char)adenhd.entcolor);
  }
  if ((adct.ouracadverw SUBN < ACAD11 && adenhd.entlinetype!=256) ||
      (adct.ouracadverw SUBN >=ACAD11 && adenhd.entlinetype!=32767)) {
    adin.entpropw |=2;
    if (adct.ouracadverw SUBN <ACAD11) wrc((char)adenhd.entlinetype);  /* 2 bytes for r11 */
    else wrw(adenhd.entlinetype);
  }
/* changed this to require the value to be in entelevation again */
  if (adenhd.entelevation!=0.0 &&
       (adct.ouracadverw SUBN<ACAD10 ||
          (adenhd.enttype!=1 && adenhd.enttype!=2 && adenhd.enttype!=13 && adenhd.enttype!=21 && adenhd.enttype!=22))
     )
  {
    adin.entpropw |= 4;
    wrreal(adenhd.entelevation);
  }
  if (adenhd.entthickness!=0.0) {
    adin.entpropw |= 8;
    wrreal(adenhd.entthickness);
  }
  if ((adct.ouracadverw SUBN >ACAD10 || (adct.ouracadverw SUBN==ACAD10 && !adin.inblockdefwflag SUBN))
       && adhd.enthandles) { /* handle present */
    wrc((char)adenhd.enthandlelength);
    for (i=8-adenhd.enthandlelength; i<8; i++)
      wrc(adenhd.enthandle[i]);
#ifndef OCTALONLY
    adin.entpropw |= '\x20';
#else
    adin.entpropw |= (char)32;
#endif
  } /* if ACAD10 */
  if (adct.ouracadverw SUBN >=ACAD11) {
    if (adin.entflagw2) {
      wrw(adin.entflagw2);
#ifndef OCTALONLY
      adin.entpropw |= 0x40;
#else
      adin.entpropw |= (char)64;
#endif
      adin.writebuf[8] |= 4;
    }
  }

  switch (adenhd.enttype) {
    case 1:  linewqq(1);    break;
    case 2:  pointwqq(1);   break;
    case 3:  circlewqq(1);  break;
    case 4:  shapewqq(1);   break;
    case 7:  textwqq(1);    break;
    case 8:  arcwqq(1);     break;
    case 9:  tracewqq(1);   break;
    case 11: solidwqq(1);   break;
    case 12: sblockwqq(1);  break;
    case 13: eblockwqq();          break;
    case 14: insertwqq(1);  break;
    case 15: attdefwqq(1);  break;
    case 16: attribwqq(1);  break;
    case 17: seqendwqq();          break;
    case 19: plinewqq(1);   break;
    case 20: vertexwqq(1);  break;
    case 21: if (adct.ouracadverw SUBN>ACAD25) line3dwqq(1);  break;
    case 22: if (adct.ouracadverw SUBN>ACAD25) face3dwqq(1);  break;
    case 23: if (adct.ouracadverw SUBN>ACAD25) assodimwqq(1); break;
    case 24: if (adct.ouracadverw SUBN>=ACAD11) vportentwqq(); break;
  };
#if !defined(BIGENDIAN) && !defined(QUADWORDALIGNED)
  memcpy(&adin.writebuf[2],&adin.entlengthw,SIZEOFSHORT);
  memcpy(&adin.writebuf[6],&adin.entflagw,SIZEOFSHORT);
#else
  adin.writebuf[3]=adin.entlengthw >> 8;
  adin.writebuf[2]=adin.entlengthw & 255;
  adin.writebuf[7]=adin.entflagw >> 8;
  adin.writebuf[6]=adin.entflagw & 255;
#endif
  adin.writebuf[1]=(char)adin.entpropw;
  if (adct.ouracadverw SUBN >= ACAD11) {  /* do crc */
    i=adin.entlengthw;  /* hold temporarily */
    adin.entlengthw=2;
    wrw(i+2);   /* lengthen it by 2 for crc */
    adin.entlengthw=i;
    i=crc8(0xC0C1,adin.writebuf,adin.entlengthw);
    wrw(i);
/* save vport location */
    if (adenhd.enttype==24 && !adenhd.erasedflag) {
      adin.vportentloc SUBN[adin.vportentcount SUBN++]=ftell(adin.dwgfilew SUBN);
    }
  }
}

