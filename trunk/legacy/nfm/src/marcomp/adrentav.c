
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrentav.c -- library routines for accessing autocad drawing files */
/* read entities from file */
/* autoview specific version */

#include "adrhdr.h"

/*#include "avdatax.h"*/ /* include file added by SSRS - 25/11/93 */

#ifdef highc
#define min(a,b)    (((a) < (b)) ? (a) : (b))
#endif

/* the AUTOVIEW version of READENTITY */
#ifndef OLDCHDR
short readentityav(void)
#else
short readentityav()
#endif
{
  short exts;
  long newloc;
  short i;
  char *nextcacheloc,done;       /* help us make this robust */

  done=0;
  while (!done) {
  if (!adin.inblockdefrflag SUBN &&
         ad_ftell(adin.dwgfiler SUBN) >=adin.entlistendr SUBN &&
         ad_ftell(adin.dwgfiler SUBN) <adin.extraentlocr SUBN ) return(0);
/*
    printf("Location in adin.dwgfiler is %lX ",ad_ftell(adin.dwgfiler SUBN ));
    if (adin.dwgfiler SUBN ==adin.dwgfilerent SUBN) printf("In adin.dwgfilerent\n");
    if (adin.dwgfiler SUBN ==adin.dwgfilerext SUBN) printf("In adin.dwgfilerext\n");
    if (adin.dwgfiler SUBN ==adin.dwgfilerblk SUBN ) printf("In adin.dwgfilerblk\n");
    if (adin.dwgfiler SUBN ==adin.dwgfilerblk2 SUBN) printf("In adin.dwgfilerblk2\n");

    if (ad3in.globalreadingfromcache!=-1) printf("In cache --  ptr is %p\n",adin.entptr);
    else printf("Loc is %lX\n",ad_ftell(adin.dwgfiler SUBN ));
*/

  if (ad3in.globalreadingfromcache!=-1) {
    nextcacheloc=adin.entptr;   /* for the moment */
    adenhd.enttype=rdc();
  }
  else adenhd.enttype=frdc();

/*
    printf("grfc is %d  adenhd.enttype %d",ad3in.globalreadingfromcache,adenhd.enttype);
    if (adenhd.enttype & 128) printf(" (%d)",adenhd.enttype & 127);
    printf("\n");
*/

    adenhd.xddatapresent=adenhd.paperspace=adin.xddataflagr=adenhd.extrusioninfovalid=adenhd.erasedflag=0;
    memset(&aden,0,200);  /* the sleazy initialization method */

    if (adenhd.enttype & 128) adenhd.erasedflag=1;
    adenhd.enttype &= (unsigned char)127;

    if (!(adenhd.enttype>0 && adenhd.enttype<25 && adenhd.enttype!=5 && adenhd.enttype!=6 && adenhd.enttype!=10))
      return(0);

    if (ad3in.globalreadingfromcache==-1) {
      adin.entprop=frdc();
      adin.entlengthr=frdw();
    }
    else {
      adin.entprop=rdc();
      adin.entlengthr=rdw();
      nextcacheloc+=adin.entlengthr;       /* now this is correct */
    }

    if (adenhd.erasedflag) {              /* erased */
      if (ad3in.globalreadingfromcache==-1)
        readpastentity(adin.entlengthr-4);
      else adin.entptr+=adin.entlengthr-4;
    }
    else {

      if (adenhd.enttype==13) return(1);              /* end of block */

      if (adenhd.enttype==18) {                       /* pointer -- follow it */
        adin.nextentloc SUBN=frdlong();

        if (adin.nextentloc SUBN & (long)0x80000000L)
          exts=1; else exts=0;
                     /* that flag determines whether we jump to the extra ent
                        section or back to entities */
        adin.nextentloc SUBN &= (long)0x03FFFFFF;

        if (exts) {
          adin.dwgfiler SUBN =adin.dwgfilerext SUBN;
          if (!adin.inblockdefrflag SUBN) newloc=adin.extraentlocr SUBN+adin.nextentloc SUBN;
          else newloc=adin.blkdefstartr SUBN+adin.nextentloc SUBN;
        }
        else {
          newloc=adin.nextentloc SUBN;
          if (adin.inblockdefrflag SUBN) newloc+=adin.blkdefstartr SUBN;
          if (!adin.inblockdefrflag SUBN) adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
          else if (adin.inblockdefrflag SUBN==1) adin.dwgfiler SUBN =adin.dwgfilerblk SUBN;
          else adin.dwgfiler SUBN =adin.dwgfilerblk2 SUBN;
        }

        dwgfilerseek(newloc);
      }
      else {
    /* if we get to here, it was not a pointer */
        if (ad3in.globalreadingfromcache==-1)
          adenhd.layerindex=frdw();
        else adenhd.layerindex=rdw();
/* change layer index if we are in a block def and this was layer 0 */
        if (adin.inblockdefrflag SUBN && adenhd.layerindex==0) adenhd.layerindex=ad3in.insentlayer;
        /* if not frozen, jump out of loop */
        if (adin.readfrozen || adenhd.enttype==12 || !(lay[newlayno(adenhd.layerindex)]->layflag & 1)) {
          done=1;
        }
        else {  /* frozen */
          /* skip over this entity */
          if (ad3in.globalreadingfromcache!=-1) adin.entptr+=adin.entlengthr-6;
          else readpastentity(adin.entlengthr-6);

          if ((adenhd.enttype==14 && (adin.entprop & 128)) || adenhd.enttype==19) {
  /* frozen polyline or insert -- skip over all of polyline, any
     attributes which follow the insert */
            do {
              if (ad3in.globalreadingfromcache==-1) {
                adenhd.enttype=frdc();
                adin.entprop=frdc();
                adin.entlengthr=frdw();
              }
              else {
                adenhd.enttype=rdc();
                adin.entprop=rdc();
                adin.entlengthr=rdw();
              }
              if (adenhd.enttype==20 || adenhd.enttype==16) {  /* vertex or attrib */
                if (ad3in.globalreadingfromcache==-1)
                  readpastentity(adin.entlengthr-4);
                else adin.entptr+=adin.entlengthr-4;
              } /* skip the vertex or attrib */
              else if (adenhd.enttype==18) { /* follow the pointer */
                adin.nextentloc SUBN=frdlong();
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
                  if (adin.inblockdefrflag SUBN) newloc+=adin.blkdefstartr SUBN;

                  if (!adin.inblockdefrflag SUBN) adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
                  else if (adin.inblockdefrflag SUBN==1) adin.dwgfiler SUBN =adin.dwgfilerblk SUBN ;
                  else adin.dwgfiler SUBN =adin.dwgfilerblk2 SUBN;
                }
                /* seek the ent that goes here */
               dwgfilerseek(newloc);
              }
            } while (adenhd.enttype!=17);  /* seqend */
            /* skip over the body of the seqend */
            if (ad3in.globalreadingfromcache==-1)
              readpastentity(adin.entlengthr-4);
            else adin.entptr+=adin.entlengthr-4;
          } /* end of frozen polyline/insert section */
        }   /* end of frozen entity section */
      }     /* Not a pointer */
    }       /* not erased */
  }         /* while (!done) */

  if (ad3in.globalreadingfromcache==-1)
    adin.entflagr=frdw();
  else adin.entflagr=rdw();

/* be careful -- above this point, adin.entlengthr must have its real value
   for the skips to work properly from the cache */

  adin.entlengthr-=8;   /* at this point */
/* end of change area */
#ifndef OCTALONLY
  if ((adct.ouracadverr SUBN>=ACAD11) && (adin.entprop & '\x40')) {
#else
  if ((adct.ouracadverr SUBN>=ACAD11) && (adin.entprop & 64)) {
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

      if (adenhd.enttype==24)
        ad_fread(adin.readbuf,adin.xddatalengthr,1,adin.dwgfiler SUBN);
      else
        readpastentity(adin.xddatalengthr);
    }
    else {
      adin.xddatalengthr=rdw();
/* grab some xdata for vport entity */
      if (adenhd.enttype==24) {
#ifdef bc286
/*
        for (i=0; i<adin.xddatalengthr; i++) {
          adin.readbuf[i]=adin.entptr[i];
        }
*/
        _fmemcpy(adin.readbuf,adin.entptr,adin.xddatalengthr);
#else
        memcpy(adin.readbuf,adin.entptr,adin.xddatalengthr);
#endif
      }
      adin.entptr+=adin.xddatalengthr;
    }
    adin.entlengthr-=adin.xddatalengthr; /* seems correct */
  }

  if (adenhd.enttype==24) {   /* read the extended data we need */
    adin.vportenttarget[0]  = buf2double(&adin.readbuf[16]);
    adin.vportenttarget[1]  = buf2double(&adin.readbuf[24]);
    adin.vportenttarget[2]  = buf2double(&adin.readbuf[32]);
    adin.vportentviewdir[0] = buf2double(&adin.readbuf[41]);
    adin.vportentviewdir[1] = buf2double(&adin.readbuf[49]);
    adin.vportentviewdir[2] = buf2double(&adin.readbuf[57]);
    adin.vportentviewtwist  = buf2double(&adin.readbuf[66]);
    adin.vportentviewheight = buf2double(&adin.readbuf[75]);
    adin.vportentviewctr[0] = buf2double(&adin.readbuf[84]);
    adin.vportentviewctr[1] = buf2double(&adin.readbuf[93]);
/* vport extended data is in adin.readbuf, need to get frozen vports out */
/* they start at location 221 */
    i=220;
    while (adin.readbuf[i++]==3) {
      done = buf2short(&adin.readbuf[i]);  /* reuse done -- adenhd.layerindex frozen for this vport */
/* printf("or-ing layer %s's flags with %X\n",lay[newlayno(done)]->layname,ad3in.layvpflags); */
      lay[newlayno(done)]->vpfrozflags |= ad3in.layvpflags; /* set the bit */
      i+=2;
    }
  }
/* READ INTO BUFFER down here instead -- adin.entlengthr is remaining length */
  if (ad3in.globalreadingfromcache==-1) {
    ad_fread(adin.readbuf,adin.entlengthr,1,adin.dwgfiler SUBN );   /* read into buffer */
    adin.entptr=adin.readbuf;
  }
  adenhd.entcolor=0; /* bylayer */
  adenhd.entlinetype=256; /* bylayer */
  if (adct.ouracadverr SUBN>=ACAD11) adenhd.entlinetype=32767; /* bylayer for R11 */

  adenhd.extrusion[0]=adenhd.extrusion[1]=adenhd.extrusion[2]=adenhd.entelevation=adenhd.entthickness=0.0;
  /* if the "color present" flag is one but the color is zero, the
     entity color is BYBLOCK, NOT ZERO OR BYLAYER!!! */
  if (adin.entprop & 1) {
    adenhd.entcolor=rdc();
    adenhd.entcolor &= 255;
    if (adenhd.entcolor==0) adenhd.entcolor=BYBLOCK;
  }
  if (adin.entprop & 2) {
    if (adct.ouracadverr SUBN<=ACAD10) {
      adenhd.entlinetype=rdc();
      adenhd.entlinetype &= 255;
    }
    else adenhd.entlinetype=rdw();
  }
  if ((adin.entprop & 4) &&
       ((adct.ouracadverr SUBN<ACAD10) ||
          (adenhd.enttype!=1 && adenhd.enttype!=2 && adenhd.enttype!=21 && adenhd.enttype!=22))
     ) adenhd.entelevation=rdreal();

 if (adin.entprop & 8) adenhd.entthickness=rdreal();

  if ((adct.ouracadverr SUBN >= ACAD11) ||
      (adct.ouracadverr SUBN==ACAD10 && !adin.inblockdefrflag SUBN)) {
    if (adin.entprop & 32) {    /* handle present */
      adenhd.enthandlelength=(unsigned char)rdc();
/* skip the entity handle */
      adin.entptr+=adenhd.enthandlelength;
    }
  } /* if ACAD10 */

  if ((adct.ouracadverr SUBN >= ACAD11) && (adin.xddataflagr & 4)) { /* adin.entflagr2 is present */
    adin.entflagr2=(unsigned short)rdw();
    if (adin.entflagr2 & 1) adenhd.paperspace=1;
  }

  adin.entmask=1;

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
    case 23: if (adct.ouracadverr SUBN>ACAD25) assodimrqq(adin.entmask); break;
    case 24: if (adct.ouracadverr SUBN>ACAD10) vportentrqq(); break;
    default: return(0);
  };
  if (ad3in.globalreadingfromcache!=-1) adin.entptr=nextcacheloc;
#ifndef AV
  if (ad_Examineentity!=NULL) (*ad_Examineentity)();
#endif
  return(1);
}

