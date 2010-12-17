
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrh2.c -- library routines for accessing autocad drawing files */
/* header read section */
#include "adrhdr.h"

#ifndef OLDCHDR
void readheader2qq(void)
#else
void readheader2qq()
#endif
{
  short i;

  /* second part of menu, if any, is hiding here */
  ad_fread(&(adhd.acadmenu[14]),45,1,adin.dwgfiler SUBN );
  adhd.elevation=frdreal();					/* offset 229 */
  adhd.thickness=frdreal();					/* offset 231 */
  adhd.vpointhdr[0]=frdreal();					/* offset 239 */
  adhd.vpointhdr[1]=frdreal();					/* offset 241 */
  adhd.vpointhdr[2]=frdreal();					/* offset 249 */

  readgarbage(adin.garbage10 SUBN,146);

  adhd.blipmode=frdw();					/* offset 2E3 */
  adhd.dimzin=frdc();					/* offset 2E5 */
  adhd.dimrnd=frdreal();					/* offset 2E6 */
  adhd.dimdle=frdreal();					/* offset 2EE */
  ad_fread(adhd.dimblk,31,1,adin.dwgfiler SUBN );				/* offset 2F6 */
  readgarbage(adin.garbage11 SUBN,4);
  adhd.coords=frdw();					/* offset 319 */
  adhd.cecolor=frdw();					/* offset 31B */
  adhd.celtype=frdw();					/* offset 31D */
  adhd.tdcreate1=frdlong();					/* offset 31F */
  adhd.tdcreate2=frdlong();					/* offset 323 */
  adhd.tdupdate1=frdlong();					/* offset 327 */
  adhd.tdupdate2=frdlong();					/* offset 32B */
  adhd.tdindwg1=frdlong();					/* offset 32F */
  adhd.tdindwg2=frdlong();					/* offset 333 */
  adhd.tdusrtimer1=frdlong();				/* offset 337 */
  adhd.tdusrtimer2=frdlong();				/* offset 33B */
  adhd.usrtimer=frdw();					/* offset 33F */
  adhd.fastzoom=frdw();					/* offset 341 */
  adhd.skpoly=frdw();					/* offset 343 */
  readgarbage(adin.garbage12 SUBN,14);
  adhd.angbase=frdreal();					/* offset 353 */
  adhd.angdir=frdw();					/* offset 35B */
  adhd.pdmode=frdw();					/* offset 35D */
  adhd.pdsize=frdreal();					/* offset 35F */
  adhd.plinewid=frdreal();					/* offset 367 */
  if (adct.ouracadverr SUBN>ACAD25 || adin.actualdrawingversionr SUBN>0x68) {
    for (i=0; i<5; i++) adhd.useri[i]=frdw();		/* offset 36F */
    for (i=0; i<5; i++) adhd.userr[i]=frdreal();		/* offset 379 */
  }
  else for (i=0; i<5; i++) {
         adhd.useri[i]=0;
         adhd.userr[i]=0.0;
       }
  if (adct.ouracadverr SUBN>=ACAD26) {
    /* these two items appear in autocad, but not in 2.5 file (?) */
    adhd.dimalt=frdc();					/* offset 3A1 */
    adhd.dimaltd=frdc();					/* offset 3A2 */
    adhd.dimaso=frdc();					/* offset 3A3 */
    adhd.dimsho=frdc();					/* offset 3A4 */
    ad_fread(adhd.dimpost,16,1,adin.dwgfiler SUBN );			/* offset 3A5 */
    ad_fread(adhd.dimapost,16,1,adin.dwgfiler SUBN );			/* offset 3B5 */
    /* same for these two */
    adhd.dimaltf=frdreal();					/* offset 3C5 */
    adhd.dimlfac=frdreal();					/* offset 3CD */
  }
  if (adct.ouracadverr SUBN>=ACAD9) {
    adhd.splinesegs=frdw();					/* offset 3D5 */
    adhd.splframe=frdw();					/* offset 3D7 */
    adhd.attreq=frdw();					/* offset 3D9 */
    adhd.attdia=frdw();					/* offset 3DB */
    adhd.chamfera=frdreal();                                 /* offset 3DD */
    adhd.chamferb=frdreal();                                 /* offset 3E5 */
    if (adin.actualdrawingversionr SUBN>=(unsigned short)81) {
      adin.mysttwopresent SUBN=1;
      adhd.mirrtext=frdw();
    }
    else { adin.mysttwopresent SUBN=0; adhd.mirrtext=0; }
    if (adhd.mirrtext!=1 && adhd.mirrtext!=0) adhd.mirrtext=0;
  }
  /* release 10 info */
  if (adct.ouracadverr SUBN>=ACAD10) {
    adin.sizeofucsentryr SUBN=frdw();       /* location 3EF */
    adct.numucsr SUBN=frdlong();            /* location 3F1 */
    adin.ucsliststartr SUBN=frdlong();      /* location 3F5 */
    adin.garbage15 SUBN=frdw();             /* location 3F9 */
    if (adct.ouracadverr SUBN >=ACAD11)
      adhd.dwgcodepage=adin.garbage15 SUBN;
	else adhd.dwgcodepage=0;
    adhd.ucsorih[0]=frdreal();              /* location 3FB */
    adhd.ucsorih[1]=frdreal();              /* location 403 */
    adhd.ucsorih[2]=frdreal();              /* location 40B */
    adhd.ucsxdirh[0]=frdreal();             /* location 413 */
    adhd.ucsxdirh[1]=frdreal();             /* location 41B */
    adhd.ucsxdirh[2]=frdreal();             /* location 423 */
    adhd.ucsydirh[0]=frdreal();             /* location 42B */
    adhd.ucsydirh[1]=frdreal();             /* location 433 */
    adhd.ucsydirh[2]=frdreal();             /* location 43B */
    adhd.target[0]=frdreal();               /* location 443 */
    adhd.target[1]=frdreal();               /* location 44B */
    adhd.target[2]=frdreal();               /* location 453 */
    adhd.lenslength=frdreal();            /* location 45B */
    adhd.viewtwisthdr=frdreal();             /* location 463 */
    adhd.frontz=frdreal();                /* location 46B */
    adhd.backz=frdreal();                 /* location 473 */
    adhd.ucsflag=frdw();                  /* location 47B */
    adhd.dimtofl=frdc();                  /* location 47D */
    ad_fread(adhd.dimblk1,32,1,adin.dwgfiler SUBN );/* location 47E */
    adin.garbage16 SUBN=frdc();             /* probably an extra byte on dimblk1 */
    ad_fread(adhd.dimblk2,32,1,adin.dwgfiler SUBN );/* location 49F */
    adin.garbage17 SUBN=frdc();             /*          4BF*/
    adhd.dimsah=frdc();                   /* location 4C0 */
    adhd.dimtix=frdc();
    adhd.dimsoxd=frdc();
    adhd.dimtvp=frdreal();                /* location 4C3 */
    ad_fread(adhd.ucsname,32,1,adin.dwgfiler SUBN );
    adin.garbage18 SUBN=frdc();             /* 1 byte garbage */
    adhd.enthandles=frdw();               /* location 4EC */
    ad_fread(adhd.enthandseed,8,1,adin.dwgfiler SUBN );/* location 4EE */
    adhd.surfu=frdw();                    /* location 4F6 */
    adhd.surfv=frdw();                    /* location 4F8 */
    adhd.surftype=frdw();                 /* location 4FA */
    adhd.surftab1=frdw();                 /* location 4FC */
    adhd.surftab2=frdw();                 /* location 4FE */
    adin.sizeofvportentryr SUBN=frdw();     /* location 500 */
    adct.numvportsr SUBN=frdlong();         /* location 502 */
    adin.vportliststartr SUBN=frdlong();    /* location 506 */
    adhd.flatland=frdw();                 /* location 50A */
    adhd.splinetype=frdw();               /* location 50C */
    adhd.ucsicon=frdw();                  /* location 50E */
    adhd.curucsindex=frdw();              /* location 510 */
    if (adin.actualdrawingversionr SUBN>159) {
      if (adct.ouracadverr SUBN<ACAD11) {
        adin.garbage21 SUBN=frdw();           /* location 512 don't know what this is */
        adin.garbage25 SUBN=frdlong();
        adin.curvportlocr SUBN=frdlong();     /* location 518 pointer to current vport */
      }
      else {
        adin.sizeofregappentryr SUBN=frdw();    /* location 512 */
        adct.numregappsr SUBN=frdlong();        /* location 514 */
        adin.regappliststartr SUBN=frdlong();   /* location 518 */
      }
      adhd.worldview=frdw();              /* location 51C */
    }
    else { adhd.worldview=1; adin.curvportlocr SUBN=adin.vportliststartr SUBN; }
  }
  if (adct.ouracadverr SUBN>=ACAD11) {
    adhd.cyclekeep=frdw();                /* location 51E */
    adhd.cyclecurr=frdw();                /* location 520 */
    adin.sizeofdimstyleentryr SUBN=frdw();  /* location 522 */
    adct.numdimstylesr SUBN=frdlong();      /* location 524 */
    adin.dimstyleliststartr SUBN=frdlong(); /* location 528 */
    adhd.curdimstyleno=frdw();            /* location 52C */
    readgarbage(adin.garbage22 SUBN,3);     /* location 52E */
    adhd.dimclrd=frdw();                  /* location 531 */
    adhd.dimclre=frdw();                  /* location 533 */
    adhd.dimclrt=frdw();                  /* location 535 */
    adhd.shadedge=frdw();                 /* location 537 */
    adhd.shadedif=frdw();                 /* location 539 */
    adin.garbage23 SUBN=frdw();             /* location 53B */
    adhd.unitmode=frdw();                 /* location 53D */
/* my drawing units.dwg has info here */
    readgarbage(adin.garbage24 SUBN,160);   /* location 53F */
                                     /* location 547 -- 8 byte real */
                                     /* location 54F -- 8 byte real */
                                     /* location 557 -- 8 byte real */
                                     /* location 55F */
    adhd.dimtfac=frdreal();               /* location 5DF */
    adhd.pucsorg[0]=frdreal();              /* location 5E7 */
    adhd.pucsorg[1]=frdreal();              /* location 5EF */
    adhd.pucsorg[2]=frdreal();              /* location 5F7 */
    adhd.pucsxdir[0]=frdreal();             /* location 5FF */
    adhd.pucsxdir[1]=frdreal();             /* location 607 */
    adhd.pucsxdir[2]=frdreal();             /* location 60F */
    adhd.pucsydir[0]=frdreal();             /* location 617 */
    adhd.pucsydir[1]=frdreal();             /* location 61F */
    adhd.pucsydir[2]=frdreal();             /* location 627 */
    adhd.pucsnameindex=frdw();            /* location 62F */
    adhd.tilemode=frdw();                 /* location 631 */
    adhd.plimcheck=frdw();                /* location 633 */
    adhd.cvport=frdw();                   /* location 635 */
    adhd.pextmin[0]=frdreal();              /* location 637 */
    adhd.pextmin[1]=frdreal();              /* location 63F */
    adhd.pextmin[2]=frdreal();              /* location 647 */
    adhd.pextmax[0]=frdreal();              /* location 64F */
    adhd.pextmax[1]=frdreal();              /* location 657 */
    adhd.pextmax[2]=frdreal();              /* location 65F */
    adhd.plimmin[0]=frdreal();              /* location 667 */
    adhd.plimmin[1]=frdreal();              /* location 66F */
    adhd.plimmax[0]=frdreal();              /* location 677 */
    adhd.plimmax[1]=frdreal();              /* location 67F */
    adhd.pinsbase[0]=frdreal();             /* location 687 */
    adhd.pinsbase[1]=frdreal();             /* location 68F */
    adhd.pinsbase[2]=frdreal();             /* location 697 */
    adin.sizeofvportenthdrentryr SUBN=frdw();  /* location 69F */
    adct.numvportenthdrsr SUBN=frdlong();      /* location 6A1 */
    adin.vportenthdrliststartr SUBN=frdlong(); /* location 6A5 */
    adhd.maxactvp=frdw();                 /* location 6A9 */
    adhd.dimgap=frdreal();                /* location 6AB */
    adhd.pelevation=frdreal();            /* location 6B3 */
/* this should be present in all "real" release 11 files */
    if (adin.actualdrawingversionr SUBN>204) adhd.visretain=frdw();
    adin.crc1=frdw();                     /* location 6BD, if above is present */
  }
}

