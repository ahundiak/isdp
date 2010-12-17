
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* avpolyr.c -- autoview polyline in-line readentityav version */

if (ad3in.displayitemtype==1) {
  readentityav();
}
else {

adenhd.xddatapresent=adenhd.paperspace=adin.xddataflagr
  =adenhd.extrusioninfovalid=adenhd.erasedflag=0;

if (ad3in.globalreadingfromcache==-1) {
  adenhd.enttype=(unsigned char)frdc();
  adin.entprop=frdc();
  adin.entlengthr=frdw();
}
else {
  nextcacheloc=adin.entptr;   /* for the moment */
  adenhd.enttype=rdc();
  adin.entprop=rdc();
  adin.entlengthr=rdw();
  nextcacheloc+=adin.entlengthr;       /* now this is correct */
}

/* this code assumes that type 18's do not occur in blocks */
if (adenhd.enttype==18) {                       /* pointer -- follow it */
  adin.nextentloc=frdlong();
  if (adin.nextentloc & (long)0x80000000L)
    exts=1; else exts=0;
               /* that flag determines whether we jump to the extra ent
                  section or back to entities */
  adin.nextentloc &= (long)0x03FFFFFF;
  if (exts==1) {
    adin.dwgfiler =adin.dwgfilerext;
    if (!adin.inblockdefrflag) newloc=adin.extraentlocr+adin.nextentloc;
    else newloc=adin.blkdefstartr+adin.nextentloc;
  }
  else {
    newloc=adin.nextentloc;
    if (adin.inblockdefrflag) newloc+=adin.blkdefstartr;
    if (!adin.inblockdefrflag) adin.dwgfiler =adin.dwgfilerent;
    else if (adin.inblockdefrflag==1) adin.dwgfiler =adin.dwgfilerblk ;
    else adin.dwgfiler =adin.dwgfilerblk2;
  }
  dwgfilerseek(newloc);
}
else if (adenhd.enttype!=20) {
/* skip the rest of this endseq entity */
  if (ad3in.globalreadingfromcache==-1)
    readpastentity(adin.entlengthr-4);
  /* if it is in the cache, the last stmt fixes up the location */
}
else {  /* adenhd.enttype==20 -- vertex */
/* if we get to here, it was not a pointer */
  if (ad3in.globalreadingfromcache==-1) {
    adenhd.layerindex=frdw();
    adin.entflagr=frdw();
  }
  else {
    adenhd.layerindex=rdw();          
    adin.entflagr=rdw();
  }
/* change layer index if we are in a block def and this was layer 0 */
  if (adin.inblockdefrflag && adenhd.layerindex==0) adenhd.layerindex=ad3in.insentlayer;
  

/* be careful -- above this point, adin.entlengthr must have its real value
   for the skips to work properly from the cache */

  adin.entlengthr-=8;   /* at this point */

#ifndef OCTALONLY
  if ((adct.ouracadverr>=ACAD11) && (adin.entprop & '\x40')) {
#else
  if ((adct.ouracadverr>=ACAD11) && (adin.entprop & 64)) {
#endif
    if (ad3in.globalreadingfromcache==-1)
      adin.xddataflagr=frdc();
    else adin.xddataflagr=rdc();
    adin.entlengthr--;
    if (adin.xddataflagr & 2) adenhd.xddatapresent=1;
  }
  if (adenhd.xddatapresent) {
    if (ad3in.globalreadingfromcache==-1) {
      adin.xddatalengthr=frdw();
      adin.entlengthr-=2;
      readpastentity(adin.xddatalengthr);
    }
    else {
      adin.xddatalengthr=rdw();
      adin.entptr+=adin.xddatalengthr;
    }
    adin.entlengthr-=adin.xddatalengthr; /* seems correct */
  }

  if (ad3in.globalreadingfromcache==-1) {
    ad_fread(adin.readbuf,adin.entlengthr,1,adin.dwgfiler );   /* read into buffer */
    adin.entptr=adin.readbuf;
  }
  adenhd.entcolor=0; /* bylayer */
  adenhd.entlinetype=256; /* bylayer */
  /* extrusionx=extrusiony=extrusionz= */ adenhd.entelevation=adenhd.entthickness=0.0;
  /* if the "color present" flag is one but the color is zero, the
     entity color is BYBLOCK, NOT ZERO OR BYLAYER!!! */
  if (adin.entprop & 1) {
    adenhd.entcolor=rdc();
    adenhd.entcolor &= 255;
    if (adenhd.entcolor==0) adenhd.entcolor=BYBLOCK;
  }
  if (adin.entprop & 2) {
    if (adct.ouracadverr<=ACAD10) {
      adenhd.entlinetype=rdc();
      adenhd.entlinetype &= 255;
    }
    else adenhd.entlinetype=rdw();
  }
  if ((adin.entprop & 4) &&
       ((adct.ouracadverr<ACAD10) ||
          (adenhd.enttype!=1 && adenhd.enttype!=2 && adenhd.enttype!=21 && adenhd.enttype!=22))
     ) adenhd.entelevation=rdreal();
  if (adin.entprop & 8) adenhd.entthickness=rdreal();
  if ((adct.ouracadverr >= ACAD11) || 
      (adct.ouracadverr==ACAD10 && !adin.inblockdefrflag)) {
#ifndef OCTALONLY
    if (adin.entprop & '\x20') {    /* handle present */
#else
    if (adin.entprop & 32) {    /* handle present */
#endif
      adenhd.enthandlelength=(unsigned)rdc();
/* skip the entity handle */
      adin.entptr+=adenhd.enthandlelength;
    }
  } /* if ACAD10 */

  if ((adct.ouracadverr >= ACAD11) && (adin.xddataflagr & 4)) { /* adin.entflagr2 is present */
    adin.entflagr2=(unsigned)rdw();
    if (adin.entflagr2 & 1) adenhd.paperspace=1; 
  }

  adin.entmask=1;

  ad3in.vert->pt0[X]=ad3in.vert->pt0[Y]=ad3in.vert->endwidth=ad3in.vert->bulge=ad3in.vert->tangentdir=ad3in.vert->startwidth=0.0;
  aden.vertex.polyfacevertcount=aden.vertex.startwidthvalid=aden.vertex.endwidthvalid=ad3in.vert->vertflag=0;
  ad3in.vert->pt0[Z]=adenhd.entelevation;
  if (adct.ouracadverr < ACAD11 || (!(adin.entflagr & 0x4000))) {
    ad3in.vert->pt0[X]=rdreal();
    ad3in.vert->pt0[Y]=rdreal();
  }
  if (adin.entflagr & adin.entmask) { /* start width present 1 bit*/
    ad3in.vert->startwidth=rdreal();
    aden.vertex.startwidthvalid=1;
  }
  adin.entmask<<=1;
  if (adin.entflagr & adin.entmask) {                /* 2 bit */
 /* end width present */
    ad3in.vert->endwidth=rdreal();
    aden.vertex.endwidthvalid=1;
  }
  adin.entmask<<=1;
  if (adin.entflagr & adin.entmask)  /* has a bulge value    4 bit */
    ad3in.vert->bulge=rdreal();
  adin.entmask<<=1;
  if (adin.entflagr & adin.entmask) { /* vertex flag present   8 bit */ 
    ad3in.vert->vertflag=rdc();
    ad3in.vert->vertflag &= 255;
  }
  adin.entmask<<=1;
  if (adin.entflagr & adin.entmask) /* curve fit tangent direction  16 bit */
    ad3in.vert->tangentdir=rdreal();
  adin.entmask<<=1;
  if (adct.ouracadverr==ACAD10) {
    if (adin.entflagr & adin.entmask) readextrusioninfo();
    adin.entmask<<=1;
  }
  if (adct.ouracadverr > ACAD10) {
    if (!(adin.entflagr & 0x4000)) {  /* not a polyface face defining vertices */
      if (adin.entflagr & adin.entmask) {
        bs=rdreal(); bs=rdreal(); bs=rdreal();
      }
      adin.entmask<<=1;
    }
    else {                         /* this is a face definition */
      for (i=0; i<4; i++) {
        if (adin.entflagr & adin.entmask) {
          aden.vertex.polyfacevert[i]=rdw();
          aden.vertex.polyfacevertcount++;
        }
        adin.entmask<<=1;
      }
    }
  }
}
if (ad3in.globalreadingfromcache!=-1) adin.entptr=nextcacheloc;
}
