
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrent.c -- library routines for accessing autocad drawing files */
/* read entities from file */
#include "adrhdr.h"
#ifdef microsoftc
#pragma function(memcpy,strcpy,strcat)
#endif

static short holdneed;
static long entreadloc;
static short lastdist;

/* #ifndef microsoftc */
/* for the other compilers, read past rather than seeking */
#ifndef OLDCHDR
void readpastentity(short numbytes)
#else
void readpastentity(numbytes)
short numbytes;
#endif
{
  while (numbytes>0)
    numbytes-=ad_fread(adin.readbuf,1,min(1024,numbytes),adin.dwgfiler SUBN);
}
/* #endif */

#ifndef OLDCHDR
void dwgfilerseek(long newloc)
#else
void dwgfilerseek(newloc)
long newloc;
#endif
{
  long temploc;

/*
  printf("In dwgfilerseek: curloc %lX, newloc %lX, enttype %d\n",ad_ftell(adin.dwgfiler SUBN), newloc,adenhd.enttype);
*/

#ifndef AV

/* av is using the juiced version of ad_fseek */
  temploc=ad_ftell(adin.dwgfiler SUBN);
  if (temploc<newloc && ((temploc+8192L) >= newloc)) {
    readpastentity((short)(newloc-temploc));
  }
  else {

#endif

    ad_fseek(adin.dwgfiler SUBN ,newloc,0);      /* seek the ent that goes here */
#ifndef AV
  }
#endif
}
/* #endif */

#ifndef OLDCHDR
void rdacadstr(char *strng)
#else
void rdacadstr(strng)
char *strng;
#endif
{
  short len,i;

  len=rdw();
/*  memcpy(strng,adin.entptr,len); */
  for (i=0; i<len; i++) {
    strng[i] = rdc();
  }

/*  adin.entptr+=len; */
  strng[len]='\0';
}

#ifndef OLDCHDR
void readextrusioninfo(void)
#else
void readextrusioninfo()
#endif
{
  adenhd.extrusioninfovalid=1;
  rd3real(adenhd.extrusion);
  if (adenhd.extrusion[0]==0.0 && adenhd.extrusion[1]==0.0 && adenhd.extrusion[2]==0.0)
    adenhd.extrusioninfovalid=0;
}

#ifndef OLDCHDR
void linerqq(void)
#else
void linerqq()
#endif
{
  rd2real(aden.line.pt0);
  aden.line.pt0[2]=aden.line.pt1[2]=adenhd.entelevation;
  if (adct.ouracadverr SUBN>=ACAD10 && !(adin.entprop & 4)) {
    aden.line.pt0[2]=rdreal();
  }
  rd2real(aden.line.pt1);
  if (adct.ouracadverr SUBN>=ACAD10) {
    if (!(adin.entprop & 4)) aden.line.pt1[2]=rdreal();
    if (adin.entflagr & 1) readextrusioninfo();
  }
}

#ifndef OLDCHDR
void pointrqq(void)
#else
void pointrqq()
#endif
{
  rd2real(aden.point.pt0);
  aden.point.pt0[2]=adenhd.entelevation;
  aden.point.ucsxangle=0.0;
  if (adct.ouracadverr SUBN>=ACAD10) {
    if (!(adin.entprop & 4)) aden.point.pt0[2]=rdreal();
    if (adin.entflagr & 1)
      readextrusioninfo();
    if (adin.entflagr & 2)
      aden.point.ucsxangle=rdreal();
  }
}

#ifndef OLDCHDR
void circlerqq(void)
#else
void circlerqq()
#endif
{
  rd2real(aden.circle.pt0);
  aden.circle.pt0[2]=adenhd.entelevation;
  aden.circle.radius=rdreal();
  if (adct.ouracadverr SUBN>=ACAD10) {
    if (adin.entflagr & 1) readextrusioninfo();
  }
}

#ifndef OLDCHDR
void shaperqq(void)
#else
void shaperqq()
#endif
{
  rd2real(aden.shape.pt0);
  aden.shape.scale=rdreal();
/* elevation kept */
  aden.shape.pt0[2]=adenhd.entelevation;
  aden.shape.whichshape=rdc();
  aden.shape.oblique=aden.shape.rotang=0.0;
  if (adin.entflagr & 1) aden.shape.rotang=rdreal();
  aden.shape.shapefileno=rdc();
  /* skip the mysterious 2 bit */
  aden.shape.widthfactor=1.0;
  if (adin.entflagr & 4) aden.shape.widthfactor=rdreal();  /* rel x scale? */
  if (adin.entflagr & 8) aden.shape.oblique=rdreal();
  if (adct.ouracadverr SUBN>=ACAD10) {
    if (adin.entflagr & 16) readextrusioninfo();
  }
}

#ifndef OLDCHDR
void text2rqq(unsigned short t_entmask,struct adtdatastru *tdata)
#else
void text2rqq(t_entmask,tdata)
unsigned short t_entmask;
struct adtdatastru *tdata;
#endif
{
  tdata->vertalignment=0;
  tdata->secondtextloc[0]=tdata->secondtextloc[1]=tdata->rotang=tdata->oblique=0.0;
  tdata->widthfactor=1.0;
  tdata->generationflag=tdata->justification=tdata->styleno=0;
  if (adin.entflagr & t_entmask) tdata->rotang=rdreal();          /* 1 bit */
  t_entmask<<=1;
  if (adin.entflagr & t_entmask) tdata->widthfactor=rdreal();     /* 2 bit */
  t_entmask<<=1;
  if (adin.entflagr & t_entmask) tdata->oblique=rdreal();         /* 4 bit */
  t_entmask<<=1;
  if (adin.entflagr & t_entmask) tdata->styleno=rdc();            /* 8 bit */
  t_entmask<<=1;
 /* true for backward, upside down */
  if (adin.entflagr & t_entmask) tdata->generationflag=rdc();     /* 16 bit */
  t_entmask<<=1;
  if (adin.entflagr & t_entmask) tdata->justification=rdc();      /* 32 bit */
  t_entmask<<=1;
  if (adin.entflagr & t_entmask) {                         /* 64 bit */
    tdata->secondtextloc[0]=rdreal();
    tdata->secondtextloc[1]=rdreal();
  }
  t_entmask<<=1;
  if (adct.ouracadverr SUBN>=ACAD10) {
    if (adin.entflagr & t_entmask) readextrusioninfo();    /* 128 bit */
    t_entmask<<=1;
  }
  if (adct.ouracadverr SUBN>=ACAD11) {
    if (adin.entflagr & t_entmask) tdata->vertalignment=rdc();    /* 256 bit */
  }
}

#ifndef OLDCHDR
void textrqq(void)
#else
void textrqq()
#endif
{
  rd2real(aden.text.pt0);
  aden.text.pt0[2]=adenhd.entelevation;
  aden.text.tdata.height=rdreal();
  rdacadstr(aden.text.textstr);
  text2rqq(1,&aden.text.tdata);
}

#ifndef OLDCHDR
void arcrqq(void)
#else
void arcrqq()
#endif
{
  rd2real(aden.arc.pt0);
  aden.arc.pt0[2]=adenhd.entelevation;
  aden.arc.radius=rdreal();
  aden.arc.stang=rdreal();
  aden.arc.endang=rdreal();
  if (adct.ouracadverr SUBN>=ACAD10) {
    if (adin.entflagr & 1) readextrusioninfo();
  }
}

#ifndef OLDCHDR
void tracerqq(void)
#else
void tracerqq()
#endif
{ /* trace */
  rd2real(aden.trace.pt0);
  aden.trace.pt0[2]=aden.trace.pt1[2]=aden.trace.pt2[2]=aden.trace.pt3[2]=adenhd.entelevation;
  rd2real(aden.trace.pt1);
  rd2real(aden.trace.pt2);
  rd2real(aden.trace.pt3);
  if (adct.ouracadverr SUBN>=ACAD10) {
    if (adin.entflagr & 1) readextrusioninfo();
  }
}

#ifndef OLDCHDR
void sblockrqq(void)
#else
void sblockrqq()
#endif
{ /* start of block */
  aden.block.xrefpath[0]=aden.block.name2[0]='\0';
  aden.block.base[2]=adenhd.entelevation;
  rd2real(aden.block.base);
  if (adct.ouracadverr SUBN >= ACAD10) {
    if (adin.entflagr & 1) aden.block.base[2]=rdreal();
    if (adct.ouracadverr SUBN>=ACAD11) {
      if (adin.entflagr & 2) rdacadstr(aden.block.xrefpath);
      if (adin.entflagr & 4) rdacadstr(aden.block.name2);
    }
  }
/* no extrusion read */
}

#ifndef OLDCHDR
void eblockrqq(void)
#else
void eblockrqq()
#endif
{ /* end of block */
/* no extrusion read */
}

#ifndef OLDCHDR
void insertrqq(void) /*insert */
#else
void insertrqq()
#endif
{
  aden.insert.pt0[2]=adenhd.entelevation;
  aden.insert.blockno=rdw();
  rd2real(aden.insert.pt0);
  aden.insert.xscale=aden.insert.yscale=aden.insert.zscale=1.0;
  aden.insert.numrows=aden.insert.numcols=1;
  aden.insert.coldist=aden.insert.rowdist=aden.insert.rotang=0.0;
  aden.insert.attribsfollow=(adin.entprop & 128);
  if (aden.insert.attribsfollow) adin.needtoreadsequencestart SUBN=1;
  if (adin.entflagr & 1)   aden.insert.xscale=rdreal();
  if (adin.entflagr & 2)   aden.insert.yscale=rdreal();
  if (adin.entflagr & 4)   aden.insert.rotang=rdreal();
  if (adin.entflagr & 8)   aden.insert.zscale=rdreal();
  if (adin.entflagr & 16)  aden.insert.numcols=rdw();
  if (adin.entflagr & 32)  aden.insert.numrows=rdw();
  if (adin.entflagr & 64)  aden.insert.coldist=rdreal();
  if (adin.entflagr & 128) aden.insert.rowdist=rdreal();
  if (adct.ouracadverr SUBN>=ACAD10) {
    if (adin.entflagr & 256) readextrusioninfo();
  }
}

#ifndef OLDCHDR
void attdefrqq(void)
#else
void attdefrqq()
#endif
{                               /* attdef */
  rd2real(aden.attdef.pt0);
  aden.attdef.pt0[2]=adenhd.entelevation;
  aden.attdef.tdata.height=rdreal();
  rdacadstr(aden.attdef.defaultval);
  rdacadstr(aden.attdef.prompt);
  rdacadstr(aden.attdef.tag);
  aden.attdef.attflag=rdc();

  /* rest of entity is a text item */
  text2rqq(2,&aden.attdef.tdata);             /* see if this has changed */
/* extrusion is read in text2rqq */
}

#ifndef OLDCHDR
void attribrqq(void)  /* attrib */
#else
void attribrqq()
#endif
{
  rd2real(aden.attrib.pt0);
#ifndef AV
  aden.attrib.fieldwidth=0;
#endif
  aden.attrib.pt0[2]=adenhd.entelevation;
  aden.attrib.tdata.height=rdreal();
  rdacadstr(aden.attrib.attval);
  rdacadstr(aden.attrib.tag);
  aden.attrib.attflag=rdc();
  /* rest of this entity is a text entity */
  if (adin.entflagr & 1) aden.attrib.fieldwidth=rdc();
  text2rqq(2,&aden.attrib.tdata);
/* extrusion is read in text2rqq */
}

#ifndef OLDCHDR
void seqendrqq(void) /* seqend */
#else
void seqendrqq()
#endif
{
  if (adin.needtoreadsequencestart SUBN)
    adin.entptr+=SIZEOFLONG;/* skip it */
  adin.needtoreadsequencestart SUBN=0;
/* no extrusion for now, should it have? */
}

#ifndef OLDCHDR
void plinerqq(void) /* polyline start */
#else
void plinerqq()
#endif
{
  aden.pline.z1=adenhd.entelevation;

aden.pline.fittype=aden.pline.meshmdensity=aden.pline.meshndensity=aden.pline.
meshm=aden.pline.meshn=aden.pline.polyflag=0;
  aden.pline.rotang=aden.pline.endwidth=aden.pline.startwidth=0.0;
  adin.needtoreadsequencestart SUBN=1;
  if (adin.entflagr & 1) aden.pline.polyflag=rdc();           /* 1 bit */
  aden.pline.polyflag &= 255;
  if (adin.entflagr & 2) aden.pline.startwidth=rdreal();      /* 2 bit */
  if (adin.entflagr & 4) aden.pline.endwidth=rdreal();        /* 4 bit */

  if (adct.ouracadverr SUBN>=ACAD10) {
    if (adin.entflagr & 8)   readextrusioninfo();    /* 8 bit */
    if (adin.entflagr & 16)  aden.pline.meshm=rdw();            /* 16 bit */
    if (adin.entflagr & 32)  aden.pline.meshn=rdw();            /* 32 bit */
    if (adin.entflagr & 64)  aden.pline.meshmdensity=rdw();     /* 64 bit */
    if (adin.entflagr & 128) aden.pline.meshndensity=rdw();     /* 128 bit */
    if (adin.entflagr & 256) aden.pline.fittype=rdw();          /* 256 bit */
  }
}

#ifndef OLDCHDR
void vertexrqq(void) /* vertex */
#else
void vertexrqq()
#endif
{
#ifndef AV

aden.vertex.pt0[0]=aden.vertex.pt0[1]=aden.vertex.endwidth=aden.vertex.bulge=aden.vertex.tangentdir
=aden.vertex.startwidth=0.0;

aden.vertex.polyfacevertcount=aden.vertex.startwidthvalid=aden.vertex.endwidthvalid=aden.vertex.vertexflag=0;
  aden.vertex.pt0[2]=adenhd.entelevation;
  if (adct.ouracadverr SUBN < ACAD11 || (!(adin.entflagr & 0x4000))) {
    rd2real(aden.vertex.pt0);
  }
  if (adin.entflagr & 1) { /* start width present 1 bit */
    aden.vertex.startwidth=rdreal();
    aden.vertex.startwidthvalid=1;
  }
  if (adin.entflagr & 2) {                /* 2 bit */
 /* end width present */
    aden.vertex.endwidth=rdreal();
    aden.vertex.endwidthvalid=1;
  }
  if (adin.entflagr & 4)   /* has a aden.vertex.bulge value    4 bit */
    aden.vertex.bulge=rdreal();
  if (adin.entflagr & 8) { /* vertex flag present   8 bit */
    aden.vertex.vertexflag=rdc();
    aden.vertex.vertexflag &= 255;
  }
  if (adin.entflagr & 16) /* curve fit tangent direction  16 bit */
    aden.vertex.tangentdir=rdreal();
  if (adct.ouracadverr SUBN==ACAD10) {
    if (adin.entflagr & 32) readextrusioninfo();
  }
  if (adct.ouracadverr SUBN > ACAD10) {
    if (!(adin.entflagr & 0x4000)) {  /* not a polyface face defining vertices */
      if (adin.entflagr & 32) readextrusioninfo();
    }
    else {                         /* this is a face definition */
      if (adin.entflagr & 32)  { aden.vertex.polyfacevert[0]=rdw();
aden.vertex.polyfacevertcount++; }
      if (adin.entflagr & 64)  { aden.vertex.polyfacevert[1]=rdw();
aden.vertex.polyfacevertcount++; }
      if (adin.entflagr & 128) { aden.vertex.polyfacevert[2]=rdw();
aden.vertex.polyfacevertcount++; }
      if (adin.entflagr & 256) { aden.vertex.polyfacevert[3]=rdw();
aden.vertex.polyfacevertcount++; }
    }
  }
#else
/* just create this by copying the above and substituting */
  ad3in.vert->pt0[0]=ad3in.vert->pt0[1]=ad3in.vert->endwidth=ad3in.vert->bulge=ad3in.vert->tangentdir=ad3in.vert->startwidth=0.0;

aden.vertex.polyfacevertcount=aden.vertex.startwidthvalid=aden.vertex.endwidthvalid=ad3in.vert->vertflag=0;
  ad3in.vert->pt0[2]=adenhd.entelevation;
  if (adct.ouracadverr SUBN < ACAD11 || (!(adin.entflagr & 0x4000))) {
    ad3in.vert->pt0[0]=rdreal();
    ad3in.vert->pt0[1]=rdreal();
  }
  if (adin.entflagr & 1) { /* start width present 1 bit*/
    ad3in.vert->startwidth=rdreal();
    aden.vertex.startwidthvalid=1;
  }
  if (adin.entflagr & 2) {                /* 2 bit */
 /* end width present */
    ad3in.vert->endwidth=rdreal();
    aden.vertex.endwidthvalid=1;
  }
  if (adin.entflagr & 4)  /* has a aden.vertex.bulge value    4 bit */
    ad3in.vert->bulge=rdreal();
  if (adin.entflagr & 8) { /* vertex flag present   8 bit */
    ad3in.vert->vertflag=rdc();
    ad3in.vert->vertflag &= 255;
  }
  if (adin.entflagr & 16) /* curve fit tangent direction  16 bit */
    ad3in.vert->tangentdir=rdreal();
  if (adct.ouracadverr SUBN==ACAD10) {
    if (adin.entflagr & 32) readextrusioninfo();
  }
  if (adct.ouracadverr SUBN > ACAD10) {
    if (!(adin.entflagr & 0x4000)) {  /* not a polyface face defining vertices */
      if (adin.entflagr & 32) readextrusioninfo();
    }
    else {                         /* this is a face definition */
      if (adin.entflagr & 32)  { aden.vertex.polyfacevert[0]=rdw();
aden.vertex.polyfacevertcount++; }
      if (adin.entflagr & 64)  { aden.vertex.polyfacevert[1]=rdw();
aden.vertex.polyfacevertcount++; }
      if (adin.entflagr & 128) { aden.vertex.polyfacevert[2]=rdw();
aden.vertex.polyfacevertcount++; }
      if (adin.entflagr & 256) { aden.vertex.polyfacevert[3]=rdw();
aden.vertex.polyfacevertcount++; }
    }
  }
#endif
}

#ifndef OLDCHDR
void line3drqq(void)  /* 3dline */
#else
void line3drqq()
#endif
{
  aden.line3d.pt0[2]=aden.line3d.pt1[2]=0.0;
  aden.line3d.pt0[0]=rdreal();
  aden.line3d.pt0[1]=rdreal();
  if (adct.ouracadverr SUBN<ACAD10) {
    if (adin.entflagr & 1) aden.line3d.pt0[2]=rdreal();
    aden.line3d.pt1[0]=rdreal();
    aden.line3d.pt1[1]=rdreal();
    if (adin.entflagr & 2) aden.line3d.pt1[2]=rdreal();
  }
  else {  /* release 10 and later */
    if (!(adin.entprop & 4)) aden.line3d.pt0[2]=rdreal();
    aden.line3d.pt1[0]=rdreal();
    aden.line3d.pt1[1]=rdreal();
    if (!(adin.entprop & 4)) aden.line3d.pt1[2]=rdreal();
    if (adin.entflagr & 1) readextrusioninfo();
  }
}

#ifndef OLDCHDR
void face3drqq(void)   /* 3dface */
#else
void face3drqq()
#endif
{
  aden.face3d.pt0[2]=aden.face3d.pt1[2]=aden.face3d.pt2[2]=aden.face3d.pt3[2]=0.0;
  aden.face3d.faceflag=0;
  rd2real(aden.face3d.pt0);
  if (adct.ouracadverr SUBN<ACAD10) {
    if (adin.entflagr & 1) aden.face3d.pt0[2]=rdreal();
    rd2real(aden.face3d.pt1);
    if (adin.entflagr & 2) aden.face3d.pt1[2]=rdreal();
    rd2real(aden.face3d.pt2);
    if (adin.entflagr & 4) aden.face3d.pt2[2]=rdreal();
    rd2real(aden.face3d.pt3);
    if (adin.entflagr & 8) aden.face3d.pt3[2]=rdreal();
  }
  else { /* 10 and later */
    if (!(adin.entprop & 4)) aden.face3d.pt0[2]=rdreal();
    rd2real(aden.face3d.pt1);
    if (!(adin.entprop & 4)) aden.face3d.pt1[2]=rdreal();
    rd2real(aden.face3d.pt2);
    if (!(adin.entprop & 4)) aden.face3d.pt2[2]=rdreal();
    rd2real(aden.face3d.pt3);
    if (!(adin.entprop & 4)) aden.face3d.pt3[2]=rdreal();
  /* 3d faces cannot be extruded */
    if (adin.entflagr & 1) aden.face3d.faceflag=rdw();
  }
}

#ifndef OLDCHDR
void assodimrqq(unsigned short entmask) /* associative dimension */
#else
void assodimrqq(entmask) /* associative dimension */
unsigned short entmask;
#endif
{
#ifdef AV
  short i;

  aden.dim.dimcloneinspt[2]=adenhd.entelevation;
  aden.dim.dimcloneinspt[0]=aden.dim.dimcloneinspt[0]=0.0;
  aden.dim.dimblkno=rdw(); /* index of the block that is this dim */
  adin.entptr+=4*SIZEOFDOUBLE;    /* skip aden.dim.dimlinedefptx,y, and text midpts
*/
  if (adct.ouracadverr SUBN>=ACAD10) adin.entptr+=SIZEOFDOUBLE;  /* z if present */
  if (adin.entflagr & entmask) {
    aden.dim.dimcloneinfopresent=1;
    rd2real(aden.dim.dimcloneinspt);
  }
  entmask<<=1;
  if (adin.entflagr & entmask) adin.entptr++;    /* aden.dimflag */

  entmask<<=1;
  if (adin.entflagr & entmask) { i=rdw(); adin.entptr+=i; }  /* dimtext */

  for (i=0; i<4; i++) {       /* aden.defpt2,aden.defpt3,aden.defpt4,ang diam or rad */
    entmask<<=1;
    if (adin.entflagr & entmask) {
      adin.entptr+=2*SIZEOFDOUBLE;
      if (adct.ouracadverr SUBN>=ACAD10) adin.entptr+=SIZEOFDOUBLE;  /* z if present */
    }
  }

  for (i=0; i<2; i++) {                    /* leaderlen, dimrotang */
    entmask<<=1;
    if (adin.entflagr & entmask) adin.entptr+=SIZEOFDOUBLE;
  }

  if (adct.ouracadverr SUBN<=ACAD10) {
    entmask<<=5;
    if (adct.ouracadverr SUBN==ACAD10) {
      if (adin.entflagr & entmask) adin.entptr+=SIZEOFDOUBLE; /* ucsxangle */
      entmask<<=1;
      if (adin.entflagr & entmask) readextrusioninfo();
      entmask<<=1;
    }
  }
  else {  /* 11 or greater */
    for (i=0; i<2; i++) {        /* aden.dimoblique, aden.dimtextrot */
      entmask<<=1;
      if (adin.entflagr & entmask) adin.entptr+=SIZEOFDOUBLE;
    }
    entmask<<=3;                         /* ucsxangle */
    if (adin.entflagr & entmask) adin.entptr+=SIZEOFDOUBLE;
    entmask<<=1;
    if (adin.entflagr & entmask) readextrusioninfo();
  }
#else
  aden.dim.dimflag=0;
  aden.dim.dimstyle = -1;
  aden.dim.dimcloneinspt[2]=adenhd.entelevation;

aden.dim.arcdefpt[0]=aden.dim.arcdefpt[1]=aden.dim.arcdefpt[2]
  =aden.dim.defpt2[0]=aden.dim.defpt2[1]=aden.dim.defpt2[2]=
  aden.dim.dimcloneinspt[0]=aden.dim.dimcloneinspt[1]=

aden.dim.leaderlen=aden.dim.dimrotang=aden.dim.defpt3[0]=aden.dim.defpt3[1]
=aden.dim.defpt3[2]=aden.dim.defpt4[0]=aden.dim.defpt4[1]=aden.dim.defpt4[2]=
    aden.dim.dimtextrot=aden.dim.dimoblique=0.0;
  aden.dim.dimtext[0]='\0';
  aden.dim.dimblkno=rdw(); /* index of the block that is this dim */
  rd2real(aden.dim.dimlinedefpt);
  if (adct.ouracadverr SUBN>=ACAD10) aden.dim.dimlinedefpt[2]=rdreal();
  rd2real(aden.dim.dimtextmidpt);
  if (adin.entflagr & entmask) { /* is this info present ? */  /* 1 bit */
    aden.dim.dimcloneinfopresent=1;
    rd2real(aden.dim.dimcloneinspt);
/*    if (adct.ouracadverr SUBN>=ACAD10) aden.dim.dimcloneinspt[2]=rdreal(); */
  }
  else aden.dim.dimcloneinfopresent=0;
  entmask<<=1;
  /* aden.dim.dimflag is -- 0 for horizontal, rotated, or vertical, 1 for aligned,
     2 for angular, 3 for diameter, 4 for aden.dim.radius.  128 is added if dimension
     text is located at other than the default position */
  if (adin.entflagr & entmask) aden.dim.dimflag=rdc();                   /* 2 bit */
  entmask<<=1;
  /* read dimension text if present */
  if (adin.entflagr & entmask) rdacadstr(aden.dim.dimtext);              /* 4 bit */
  entmask<<=1;
/* this is an attempt to use read the data in a useful fashion */
  if (adin.entflagr & entmask) { /* lin, ali or ang */          /* 8 bit */
    rd2real(aden.dim.defpt2);
    if (adct.ouracadverr SUBN>=ACAD10) aden.dim.defpt2[2]=rdreal();
  }
  entmask<<=1;
  if (adin.entflagr & entmask) { /* lin, ali or ang */          /* 16 bit */
    rd2real(aden.dim.defpt3);
    if (adct.ouracadverr SUBN>=ACAD10) aden.dim.defpt3[2]=rdreal();
  }
  entmask<<=1;
  if (adin.entflagr & entmask) { /* ang diam or rad */          /* 32 bit */
    rd2real(aden.dim.defpt4);
    if (adct.ouracadverr SUBN>=ACAD10) aden.dim.defpt4[2]=rdreal();
  }
  entmask<<=1;
  if (adin.entflagr & entmask) { /* ang */                      /* 64 bit */
    rd2real(aden.dim.arcdefpt);
    if (adct.ouracadverr SUBN>=ACAD10) /* aden.dim.arcdefptz=rdreal(); */
      aden.dim.arcdefpt[2]=aden.dim.dimcloneinspt[2];
  }
  entmask<<=1;
  if (adin.entflagr & entmask) aden.dim.leaderlen=rdreal();             /* 128 bit */
  entmask<<=1;
  if (adin.entflagr & entmask) aden.dim.dimrotang=rdreal();             /* 256 bit */
  if (adct.ouracadverr SUBN<=ACAD10) {
    entmask<<=5;                                     /* don't ask me why */
    if (adct.ouracadverr SUBN==ACAD10) {
      if (adin.entflagr & entmask) aden.dim.ucsxangle=rdreal();             /* way out there
bit */
      entmask<<=1;
      if (adin.entflagr & entmask) readextrusioninfo();
      entmask<<=1;
    }
  }
  if (adct.ouracadverr SUBN >=ACAD11) {
/* basically, I've fit in these two variables and I'm hoping */
/* that the rest is positioned in the same place in the flag */
    entmask<<=1;
    if (adin.entflagr & entmask) aden.dim.dimoblique=rdreal();          /* bit 9 512 bit */
    entmask<<=1;
    if (adin.entflagr & entmask) aden.dim.dimtextrot=rdreal();          /* bit 10 1024 bit */
    entmask<<=3;
    if (adin.entflagr & entmask) aden.dim.ucsxangle=rdreal();            /* bit 11 bit */
    entmask<<=1;
    if (adin.entflagr & entmask) {                              /* bit 14 bit */
      readextrusioninfo();
    }
    entmask<<=1;                                           /* bit 15 */
    if (adin.entflagr & entmask) {
      aden.dim.dimstyle=rdw();
    }
  }
#endif
}

#ifndef OLDCHDR
void vportentrqq(void)
#else
void vportentrqq()
#endif
{
  rd3real(aden.vpent.cen);
  aden.vpent.width= rdreal();
  aden.vpent.height=rdreal();
  aden.vpent.id=    rdw();
}


#ifndef AV

#ifndef OLDCHDR
void skipentrqq(void)
#else
void skipentrqq()
#endif
/* if unknown entity found, skip it */
{
}

#ifndef OLDCHDR
void startextendeddataread(void)
#else
void startextendeddataread()
#endif
{
  adin.xddatalengthr=frdw();
  adin.entlengthr-=2;
}

#ifndef OLDCHDR
short readextendeddataqq(void)
#else
short readextendeddataqq()
#endif
{
  short i;

  adxd.xddxfnumber=frdc()+1000;
  if (adxd.xddxfnumber==1000) {      /* string */
    i=frdc();                   /* length of string */
    ad_fread(adxd.xddata.xdstring,i,1,adin.dwgfiler SUBN );
    adxd.xddata.xdstring[i]='\0';           /* terminate it */
  }
  else if (adxd.xddxfnumber==1001) {          /* regapp index */
    adxd.xddata.xdappindex=frdw();
  }
  else if (adxd.xddxfnumber==1003) {
    adxd.xddata.xdlayerindex=frdw();
  }
  else if (adxd.xddxfnumber==1005) {
    ad_fread(adxd.xddata.xdhandle,8,1,adin.dwgfiler SUBN);
  }
  else if (adxd.xddxfnumber==1010) {
    adxd.xddata.xd3dpt[0]=frdreal();
    adxd.xddata.xd3dpt[1]=frdreal();
    adxd.xddata.xd3dpt[2]=frdreal();
  }
  else if (adxd.xddxfnumber==1040) {
    adxd.xddata.xdreal=frdreal();
  }
  else if (adxd.xddxfnumber==1070) {
    adxd.xddata.xdint=frdw();
  }
  else if (adxd.xddxfnumber==1071) {
    adxd.xddata.xdlong=frdlong();
  }
  else if (adxd.xddxfnumber==1002) {
    if (frdc()=='\0') adxd.xddata.xdcontrol='{';
    else adxd.xddata.xdcontrol='}';
  }
  else if (adxd.xddxfnumber==1004) {            /* NEED TO CHECK */
    adxd.xdbindatalength=frdc();                /* binary data length */
    ad_fread(adxd.xddata.xdbindata,adxd.xdbindatalength,1,adin.dwgfiler SUBN);
  }
  else if (adxd.xddxfnumber==1011) {
    adxd.xddata.xdworldpos[0]=frdreal();
    adxd.xddata.xdworldpos[1]=frdreal();
    adxd.xddata.xdworldpos[2]=frdreal();
  }
  else if (adxd.xddxfnumber==1012) {
    adxd.xddata.xdworlddisp[0]=frdreal();
    adxd.xddata.xdworlddisp[1]=frdreal();
    adxd.xddata.xdworlddisp[2]=frdreal();
  }
  else if (adxd.xddxfnumber==1013) {
    adxd.xddata.xdworlddir[0]=frdreal();
    adxd.xddata.xdworlddir[1]=frdreal();
    adxd.xddata.xdworlddir[2]=frdreal();
  }
  else if (adxd.xddxfnumber==1041) {
    adxd.xddata.xddist=frdreal();
  }
  else if (adxd.xddxfnumber==1042) {
    adxd.xddata.xdscale=frdreal();
  }
  return(1);
}

#ifndef OLDCHDR
short readextendeddata(void)
#else
short readextendeddata()
#endif
{
  long wherewewere;

  if (adin.xddatalengthr==0) return(0);
  wherewewere=ad_ftell(adin.dwgfiler SUBN);
  readextendeddataqq();
  adin.entlengthr=adin.entlengthr - (short)(ad_ftell(adin.dwgfiler SUBN)-wherewewere);
  adin.xddatalengthr=adin.xddatalengthr - (short)(ad_ftell(adin.dwgfiler SUBN)-wherewewere);
  return(1);
}

#ifndef OLDCHDR
short readentmainqq(void)
#else
short readentmainqq()
#endif
{
  adenhd.enttype=frdc();

  if (adenhd.enttype==(unsigned char)EOF) {
    return(-1); /* means off end of entities */
  }


adenhd.xddatapresent=adenhd.paperspace=adin.xddataflagr=adenhd.extrusioninfovalid=adenhd.erasedflag=0;
/* removed set of z's to 0 here */
  if (adenhd.enttype & 128) adenhd.erasedflag=1;

  adenhd.enttype &= (unsigned char)127;

  /* else continue */
  if (adenhd.enttype>0 && adenhd.enttype<25 && adenhd.enttype!=5 && adenhd.enttype!=6 &&
adenhd.enttype!=10) {
    /* read stuff common to all entities */
    adin.entprop=frdc();
    adin.entlengthr=frdw();
    if (adenhd.enttype==18) {
      adin.nextentloc SUBN=frdlong();
/* skip the rest of this entity */
/* changed from ad_fseek */
      readpastentity(adin.entlengthr-8);
      return(1);
    }

    adenhd.layerindex=frdw();
    adin.entflagr=frdw();
    adin.entlengthr-=8;           /* 8 bytes less */
    adenhd.xddatapresent=adin.xddatalengthr=0;
#ifndef OCTALONLY
    if (adin.entprop & '\x40') {     /* extended data flag present */
#else
    if (adin.entprop & '\100') {     /* extended data flag present */
#endif
      adin.xddataflagr=frdc();
      adin.entlengthr--;
      if (adin.xddataflagr & 2) adenhd.xddatapresent=1;
    }
    return(1);
  }
  else return(0);
}  /* end of readentmainqq */


#ifndef OLDCHDR
short readentity2(void)
#else
short readentity2()
#endif
{
  unsigned short i;

  if (adenhd.enttype>0 && adenhd.enttype<25 && adenhd.enttype!=5 && adenhd.enttype!=6 &&
adenhd.enttype!=10) {
    ad_fread(adin.readbuf,adin.entlengthr,1,adin.dwgfiler SUBN );
    adin.entptr=adin.readbuf;
    adenhd.entcolor=0; /* bylayer */
    adenhd.entlinetype=256; /* bylayer */
    if (adct.ouracadverr SUBN>=ACAD11) adenhd.entlinetype=32767; /* bylayer for R11 */
    adenhd.extrusion[0]=adenhd.extrusion[1]=adenhd.extrusion[2]=adenhd.entelevation=adenhd.entthickness=0.0;
    /* if the "color present" flag is one but the color is zero, the
       entity color is BYBLOCK, NOT ZERO OR BYLAYER!!! */
    if (adin.entprop & 1) {
      adenhd.entcolor=rdc();
      adenhd.entcolor &= 255;
      if (adenhd.entcolor==0) adenhd.entcolor = BYBLOCK;
    }
    if (adin.entprop & 2) {
      if (adct.ouracadverr SUBN<=ACAD10) {
        adenhd.entlinetype=rdc();       /* for both, >254 is BYBLOCK */
        adenhd.entlinetype &= 255;
      }
      else {
        adenhd.entlinetype=rdw();
      }
    }
    if ((adin.entprop & 4) &&
       ((adct.ouracadverr SUBN<ACAD10) ||
            (adenhd.enttype!=1 && adenhd.enttype!=2 && adenhd.enttype!=21 && adenhd.enttype!=22))
       ) adenhd.entelevation=rdreal();
    if (adin.entprop & 8) adenhd.entthickness=rdreal();
    if (adct.ouracadverr SUBN >=ACAD11 ||
        (adct.ouracadverr SUBN>=ACAD10 && !adin.inblockdefrflag SUBN)) {
/* handles present for all ents in r11, not in blocks in r10 */
#ifndef OCTALONLY
      if (adin.entprop & '\x20') {    /* handle present */
#else
      if (adin.entprop & '\40') {    /* handle present */
#endif
        adenhd.enthandlelength=(unsigned char)rdc();
        for (i=0; i<8; i++) {
          if (i>=8-adenhd.enthandlelength) adenhd.enthandle[i]=(unsigned char)rdc();
          else adenhd.enthandle[i]='\0';
        }
      }
    } /* if ACAD10 */
    if (adct.ouracadverr SUBN >=ACAD11) {
      if (adin.xddataflagr & 4) {          /* adin.entflagr2 is present and valid */
        adin.entflagr2=rdw();               /* reads it and bumps the pointer */
        if (adin.entflagr2 & 1) adenhd.paperspace=1;
      }
    }
  }

/*  if (adenhd.enttype<=11) { aden.pt0[0]=rdreal(); aden.pt0[1]=rdreal(); } */

  switch (adenhd.enttype) {
    case 1:  linerqq();    break;
    case 2:  pointrqq();   break;
    case 3:  circlerqq();  break;
    case 4:  shaperqq();   break;
    case 7:  textrqq();    break;
    case 8:  arcrqq();     break;
    case 9:  tracerqq();   break;
    case 11: tracerqq();   break;
    case 12: sblockrqq();  break;
    case 13: eblockrqq();          break;
    case 14: insertrqq();  break;
    case 15: attdefrqq();  break;
    case 16: attribrqq();  break;
    case 17: seqendrqq();          break;
    case 19: plinerqq();   break;
    case 20: vertexrqq();  break;
    case 21: if (adct.ouracadverr SUBN>ACAD25) line3drqq();  break;
    case 22: if (adct.ouracadverr SUBN>ACAD25) face3drqq();  break;
    case 23: if (adct.ouracadverr SUBN>ACAD25) assodimrqq(1); break;
    case 24: if (adct.ouracadverr SUBN>=ACAD11) vportentrqq(); break;
    default: skipentrqq(); return(0);
  };
  return(1);
}
#ifndef OLDCHDR
short readentity1(void)
#else
short readentity1()
#endif
{
  short retval;
  short exts;
  long newloc;

  if (!adin.inblockdefrflag SUBN &&
       ad_ftell(adin.dwgfiler SUBN )<adin.extraentlocr SUBN &&       /* why is this part here? */
       ad_ftell(adin.dwgfiler SUBN )>=adin.entlistendr SUBN) {
    return(0);    /* if none left */
  }

  retval=readentmainqq();                    /* read an entity */
  if (retval!=1) {
    return(0);                               /* if invalid, out */
  }
  while (adenhd.enttype==18) {                      /* pointer to next ent */
    if (adin.nextentloc SUBN & (long)0x80000000L)
      exts=1; else exts=0;
   /* that flag determines whether we jump to the extra ent
      section or back to entities */
    adin.nextentloc SUBN &= (long)0x03FFFFFF;
    if (exts==1) {
      adin.dwgfiler SUBN =adin.dwgfilerext SUBN;
      if (!adin.inblockdefrflag SUBN) newloc=adin.extraentlocr SUBN+adin.nextentloc SUBN;
      else newloc=adin.blkdefstartr SUBN+adin.nextentloc SUBN;
    }
    else {
      newloc=adin.nextentloc SUBN;
      if (!adin.inblockdefrflag SUBN) adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
      else {
        adin.dwgfiler SUBN =adin.dwgfilerblk SUBN ;
        newloc+=adin.blkdefstartr SUBN;
      }
    }

    dwgfilerseek(newloc);              /* seek the ent that goes here */

    retval=readentmainqq();                  /* read it */
    if (retval!=1) return(0);                /* if invalid, out */
  } /* while adenhd.enttype is 18 */
  return(1);
}


#endif

#ifndef OLDCHDR
void startentityread(void)
#else
void startentityread()
#endif
{
  adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
  dwgfilerseek(adin.entliststartr SUBN);
  adin.inblockdefrflag SUBN=0;
  distancethroughentities();
}

short distancethroughentities()
{
  short dist;

  if (adin.entliststartr SUBN==adin.entlistendr SUBN) {
    lastdist=100;
    return(100);
  }
  dist=(short)(((double)(ad_ftell(adin.dwgfiler SUBN)-adin.entliststartr SUBN))/
               ((double)(adin.entlistendr SUBN-adin.entliststartr SUBN))*100.0);
  dist++;  /* 1 -- 100 is range */

  if (dist<0) dist=lastdist;
  if (dist>100) dist=lastdist;
  lastdist=dist;
  return(dist);
}

void saveentreadloc()
{
  entreadloc=ad_ftell(adin.dwgfiler SUBN);
  holdneed=adin.needtoreadsequencestart SUBN;
}

void restoreentreadloc()
{
  adin.needtoreadsequencestart SUBN=holdneed;
  adin.dwgfiler SUBN=adin.dwgfilerent SUBN;
  ad_fseek(adin.dwgfiler SUBN,entreadloc,0);
}
