
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adwh.c -- library routines for writing autocad drawing files */
/* version 1/12/89 */
/* header write section */
/* define one of the following for turbo c or microsoft c */
/* #define turboc 1 */
/* #define microsoftc 1 */

#include "adwhdr.h"

#ifndef OLDCHDR
void writeheader(void)
#else
void writeheader()
#endif
{
  short i;
  zeroes(94);                              /* dummy top of file */
  fwrreal(adhd.base[0]);                     /* offset 5E */
  fwrreal(adhd.base[1]);                     /* offset 66 */
  fwrreal(adhd.base[2]);
  if (adct.ouracadverw SUBN >=ACAD11)
    fwrw(adhd.plinegen);
  else fwrw(adin.numentitiesw SUBN);                  /* offset 76 */
  fwrreal(adhd.extmin[0]);                      /* offset 78 */
  fwrreal(adhd.extmin[1]);                      /* offset 80 */
  fwrreal(adhd.extmin[2]);                      /* offset 88 */
  fwrreal(adhd.extmax[0]);                      /* offset 90 */
  fwrreal(adhd.extmax[1]);                      /* offset 98 */
  fwrreal(adhd.extmax[2]);                      /* offset A0 */
  fwrreal(adhd.limmin[0]);                      /* offset A8 */
  fwrreal(adhd.limmin[1]);                      /* offset B0 */
  fwrreal(adhd.limmax[0]);                      /* offset B8 */
  fwrreal(adhd.limmax[1]);                      /* offset C0 */
  fwrreal(adhd.viewctr[0]);                     /* offset C8 */
  fwrreal(adhd.viewctr[1]);                     /* offset D0 */
  fwrreal(adhd.viewctr[2]); /* conjecture */              /* offset D8 */
  fwrreal(adhd.viewsize);                       /* offset E0 */
  fwrw(adhd.snapmode);                          /* offset E8 */
  fwrreal(adhd.snapunit[0]);                      /* offset EA */
  fwrreal(adhd.snapunit[1]);                      /* offset F2 */
  fwrreal(adhd.snapbase[0]);                      /* offset FA */
  fwrreal(adhd.snapbase[1]);                      /* offset 102 */
  fwrreal(adhd.snapang);                        /* offset 10A */
  fwrw(adhd.snapstyle);                         /* offset 112 */
  fwrw(adhd.snapisopair);                            /* offset 114 */
  fwrw(adhd.gridmode);                          /* offset 116 */
  fwrreal(adhd.gridunit[0]);                      /* offset 118 */
  fwrreal(adhd.gridunit[1]);                      /* offset 120 */
  fwrw(adhd.orthomode);                         /* offset 128 */
  fwrw(adhd.regenmode);                         /* offset 12A */
  fwrw(adhd.fillmode);                          /* offset 12C */
  fwrw(adhd.qtextmode);                         /* offset 12E */
  fwrw(adhd.dragmode);                          /* offset 130 */
  fwrreal(adhd.ltscale);                        /* offset 132 */
  fwrreal(adhd.textsize);                       /* offset 13A */
  fwrreal(adhd.tracewid);                       /* offset 142 */
  fwrw(adhd.curlayerindex);                          /* offset 14A */
  dogarbage9();
  fwrw(adhd.lunits);                            /* offset 164 */
  fwrw(adhd.luprec);                            /* offset 166 */
  fwrw(adhd.axismode);                          /* offset 168 */
  fwrreal(adhd.axisunit[0]);                      /* offset 16A */
  fwrreal(adhd.axisunit[1]);                      /* offset 172 */
  fwrreal(adhd.sketchinc);                      /* offset 17A */
  fwrreal(adhd.filletrad);                      /* offset 182 */
  fwrw(adhd.aunits);                            /* offset 18A */
  fwrw(adhd.auprec);                            /* offset 18C */
  fwrw(adhd.curstyleindex);                          /* offset 18E */
  fwrw(adhd.osmode);                            /* offset 190 */
  fwrw(adhd.attmode);                           /* offset 192 */
  fwrite(adhd.acadmenu,14,1,adin.dwgfilew SUBN);               /* offset 194 */
  fputc(0,adin.dwgfilew SUBN);
  fwrreal(adhd.dimscale);                       /* offset 1A3 */
  fwrreal(adhd.dimasz);                         /* offset 1AB */
  fwrreal(adhd.dimexo);                         /* offset 1B3 */
  fwrreal(adhd.dimdli);                         /* offset 1BB */
  fwrreal(adhd.dimexe);                         /* offset 1C3 */
  fwrreal(adhd.dimtp);                     /* offset 1CB */
  fwrreal(adhd.dimtm);                     /* offset 1D3 */
  fwrreal(adhd.dimtxt);                         /* offset 1DB */
  fwrreal(adhd.dimcen);                         /* offset 1E3 */
  fwrreal(adhd.dimtsz);                         /* offset 1EB */
  fputc(adhd.dimtol,adin.dwgfilew SUBN);                  /* offset 1F3 */
  fputc(adhd.dimlim,adin.dwgfilew SUBN);                  /* offset 1F4 */
  fputc(adhd.dimtih,adin.dwgfilew SUBN);                  /* offset 1F5 */
  fputc(adhd.dimtoh,adin.dwgfilew SUBN);                  /* offset 1F6 */
  fputc(adhd.dimse1,adin.dwgfilew SUBN);                  /* offset 1F7 */
  fputc(adhd.dimse2,adin.dwgfilew SUBN);                  /* offset 1F8 */
  fputc(adhd.dimtad,adin.dwgfilew SUBN);                  /* offset 1F9 */
  fwrw(adhd.limcheck);                          /* offset 1FA */
  /* second part of menu, if any, is hiding here */
  fwrite(&adhd.acadmenu[14],45,1,adin.dwgfilew SUBN);
  fwrreal(adhd.elevation);                      /* offset 229 */
  fwrreal(adhd.thickness);                      /* offset 231 */
  fwrreal(adhd.vpointhdr[0]);                     /* offset 239 */
  fwrreal(adhd.vpointhdr[1]);                     /* offset 241 */
  fwrreal(adhd.vpointhdr[2]);                     /* offset 249 */
  dogarbage10();
  fwrw(adhd.blipmode);                          /* offset 2E3 */
  fputc(adhd.dimzin,adin.dwgfilew SUBN);                  /* offset 2E5 */
  fwrreal(adhd.dimrnd);                         /* offset 2E6 */
  fwrreal(adhd.dimdle);                         /* offset 2EE */
  fwrite(adhd.dimblk,31,1,adin.dwgfilew SUBN);                 /* offset 2F6 */
  dogarbage11();
  fwrw(adhd.coords);                            /* offset 319 */
  fwrw(adhd.cecolor);                           /* offset 31B */
  if (adct.ouracadverw SUBN<ACAD11 && adhd.celtype==32767)
    fwrw(256);
  else if (adct.ouracadverw SUBN >=ACAD11 &&
/*  just clamp after 256
           copymode==1 &&
           ouracadverr SUBN <ACAD11 &&
*/
           adhd.celtype==256)
    fwrw(32767);
  else fwrw(adhd.celtype);                      /* offset 31D */
  fwrlong(adhd.tdcreate1);                      /* offset 31F */
  fwrlong(adhd.tdcreate2);                      /* offset 323 */
  fwrlong(adhd.tdupdate1);                      /* offset 327 */
  fwrlong(adhd.tdupdate2);                      /* offset 32B */
  fwrlong(adhd.tdindwg1);                       /* offset 32F */
  fwrlong(adhd.tdindwg2);                       /* offset 333 */
  fwrlong(adhd.tdusrtimer1);                         /* offset 337 */
  fwrlong(adhd.tdusrtimer2);                         /* offset 33B */
  fwrw(adhd.usrtimer);                          /* offset 33F */
  fwrw(adhd.fastzoom);                          /* offset 341 */
  fwrw(adhd.skpoly);                            /* offset 343 */
  dogarbage12();
  fwrreal(adhd.angbase);                        /* offset 353 */
  fwrw(adhd.angdir);                            /* offset 35B */
  fwrw(adhd.pdmode);                            /* offset 35D */
  fwrreal(adhd.pdsize);                         /* offset 35F */
  fwrreal(adhd.plinewid);                       /* offset 367 */
/* we always write these for the version 72H 2.5s and up that
   we are writing */
  for (i=0; i<5; i++) fwrw(adhd.useri[i]);              /* offset 36F */
  for (i=0; i<5; i++) fwrreal(adhd.userr[i]);      /* offset 379 */
  if (adct.ouracadverw SUBN>ACAD25) {
    fputc(adhd.dimalt,adin.dwgfilew SUBN);                /* offset 3A1 */
    fputc(adhd.dimaltd,adin.dwgfilew SUBN);                    /* offset 3A2 */
    fputc(adhd.dimaso,adin.dwgfilew SUBN);                /* offset 3A3 */
    fputc(adhd.dimsho,adin.dwgfilew SUBN);                /* offset 3A4 */
    fwrite(adhd.dimpost,16,1,adin.dwgfilew SUBN);              /* offset 3A5 */
    fwrite(adhd.dimapost,16,1,adin.dwgfilew SUBN);             /* offset 3B5 */
    fwrreal(adhd.dimaltf);                      /* offset 3C5 */
    fwrreal(adhd.dimlfac);                      /* offset 3CD */
  }
  if (adct.ouracadverw SUBN>=ACAD9) {
    fwrw(adhd.splinesegs);                           /* offset 3D5 */
    fwrw(adhd.splframe);                             /* offset 3D7 */
    fwrw(adhd.attreq);                          /* offset 3D9 */
    fwrw(adhd.attdia);                          /* offset 3DB */
    fwrreal(adhd.chamfera);
    fwrreal(adhd.chamferb);
    if (adct.copymode SUBN && adin.mysttwopresent) fwrw(adhd.mirrtext);
             else if (!adct.copymode SUBN) fwrw(1);
  }
  /* the release 10 info as it evolves */
  if (adct.ouracadverw SUBN>=ACAD10) {
    fwrw(adin.sizeofucsentryw SUBN);            /* 3EF overwrite later */
    fwrlong(adct.numucsw SUBN);                 /* 3F1  overwrite later */
    fwrlong(adin.ucsliststartw SUBN);           /* 3F5  start of ucs list -- overwrite later */
    dogarbage15();                    /* 3F9  2 bytes garbage */
    fwrreal(adhd.ucsorih[0]);
    fwrreal(adhd.ucsorih[1]);
    fwrreal(adhd.ucsorih[2]);
    fwrreal(adhd.ucsxdirh[0]);
    fwrreal(adhd.ucsxdirh[1]);
    fwrreal(adhd.ucsxdirh[2]);
    fwrreal(adhd.ucsydirh[0]);
    fwrreal(adhd.ucsydirh[1]);
    fwrreal(adhd.ucsydirh[2]);
    fwrreal(adhd.target[0]);
    fwrreal(adhd.target[1]);
    fwrreal(adhd.target[2]);
    fwrreal(adhd.lenslength);
    fwrreal(adhd.viewtwisthdr);
    fwrreal(adhd.frontz);
    fwrreal(adhd.backz);
    fwrw(adhd.ucsflag);                    /* really only seems to use 1st byte */
    fwrc(adhd.dimtofl);
    fwrite(adhd.dimblk1,32,1,adin.dwgfilew SUBN);    /* location 47E */
    dogarbage16();                    /* probably an extra byte on dimblk1 */
    fwrite(adhd.dimblk2,32,1,adin.dwgfilew SUBN);    /* location 49F */
    dogarbage17();                    /* 1 byte garbage at 4BF*/
    fwrc(adhd.dimsah);                     /* location 4C0 */
    fwrc(adhd.dimtix);
    fwrc(adhd.dimsoxd);
    fwrreal(adhd.dimtvp);
    fwrite(adhd.ucsname,32,1,adin.dwgfilew SUBN);
    dogarbage18();                    /* 1 byte garbage */
    fwrw(adhd.enthandles);                 /* location 4EC */
    fwrite(adhd.enthandseed,8,1,adin.dwgfilew SUBN);    /* location 4EE */
    fwrw(adhd.surfu);                      /* location 4F6 */
    fwrw(adhd.surfv);                      /* location 4F8 */
    fwrw(adhd.surftype);                   /* location 4FA */
    fwrw(adhd.surftab1);                   /* location 4FC */
    fwrw(adhd.surftab2);                   /* location 4FE */
    fwrw(adin.sizeofvportentryw SUBN);          /* location 500 */
    fwrlong(adct.numvportsw SUBN);              /* location 502 */ /* overwrite later */
    fwrlong(adin.vportliststartw SUBN);         /* location 506 */ /* overwrite later */
    fwrw(adhd.flatland);                   /* location 50A */
    fwrw(adhd.splinetype);                 /* location 50C */
    fwrw(adhd.ucsicon);                    /* location 50E */
    fwrw(adhd.curucsindex);                /* location 510 */
    if (adct.ouracadverw SUBN < ACAD11) {
      dogarbage21();                    /* location 512 don't know what this is */
      dogarbage25();
      fwrlong(adin.curvportlocw SUBN);            /* location 518 overwrite later */
    }
    else {
      fwrw(adin.sizeofregappentryw SUBN);    /* location 512 */
      fwrlong(adct.numregappsw SUBN);        /* location 514 */
      fwrlong(adin.regappliststartw SUBN);   /* location 518 */
    }
    fwrw(adhd.worldview);                  /* location 51C */
  }
  if (adct.ouracadverw SUBN>=ACAD11) {
    fwrw(adhd.cyclekeep);                 /* location 51E */
    fwrw(adhd.cyclecurr);                 /* location 520 */
    fwrw(adin.sizeofdimstyleentryw SUBN);   /* location 522 */
    fwrlong(adct.numdimstylesw SUBN);       /* location 524 */
    fwrlong(adin.dimstyleliststartw SUBN);  /* location 528 */
    fwrw(adhd.curdimstyleno);             /* location 52C */
    dogarbage22();                   /* location 52E */
    fwrw(adhd.dimclrd);                   /* location 531 */
    fwrw(adhd.dimclre);                   /* location 533 */
    fwrw(adhd.dimclrt);                   /* location 535 */
    fwrw(adhd.shadedge);                  /* location 537 */
    fwrw(adhd.shadedif);                  /* location 539 */
    dogarbage23();                   /* location 53B */
    fwrw(adhd.unitmode);                  /* location 53D */
/* my drawing units.dwg has info here */
    dogarbage24();                   /* location 53F */
                                     /* location 547 -- 8 byte real */
                                     /* location 54F -- 8 byte real */
                                     /* location 557 -- 8 byte real */
                                     /* location 55F */
    fwrreal(adhd.dimtfac);                /* location 5DF */
    fwrreal(adhd.pucsorg[0]);               /* location 5E7 */
    fwrreal(adhd.pucsorg[1]);               /* location 5EF */
    fwrreal(adhd.pucsorg[2]);               /* location 5F7 */
    fwrreal(adhd.pucsxdir[0]);              /* location 5FF */
    fwrreal(adhd.pucsxdir[1]);              /* location 607 */
    fwrreal(adhd.pucsxdir[2]);              /* location 60F */
    fwrreal(adhd.pucsydir[0]);              /* location 617 */
    fwrreal(adhd.pucsydir[1]);              /* location 61F */
    fwrreal(adhd.pucsydir[2]);              /* location 627 */
    fwrw(adhd.pucsnameindex);             /* location 62F */
    fwrw(adhd.tilemode);                  /* location 631 */
    fwrw(adhd.plimcheck);                 /* location 633 */
    fwrw(adhd.cvport);                    /* location 635 */
    fwrreal(adhd.pextmin[0]);               /* location 637 */
    fwrreal(adhd.pextmin[1]);               /* location 63F */
    fwrreal(adhd.pextmin[2]);               /* location 647 */
    fwrreal(adhd.pextmax[0]);               /* location 64F */
    fwrreal(adhd.pextmax[1]);               /* location 657 */
    fwrreal(adhd.pextmax[2]);               /* location 65F */
    fwrreal(adhd.plimmin[0]);               /* location 667 */
    fwrreal(adhd.plimmin[1]);               /* location 66F */
    fwrreal(adhd.plimmax[0]);               /* location 677 */
    fwrreal(adhd.plimmax[1]);               /* location 67F */
    fwrreal(adhd.pinsbase[0]);              /* location 687 */
    fwrreal(adhd.pinsbase[1]);              /* location 68F */
    fwrreal(adhd.pinsbase[2]);              /* location 697 */
    fwrw(adin.sizeofvportenthdrentryw SUBN);   /* location 69F */
    fwrlong(adct.numvportenthdrsw SUBN);       /* location 6A1 */
    fwrlong(adin.vportenthdrliststartw SUBN);  /* location 6A5 */
    fwrw(adhd.maxactvp);                  /* location 6A9 */
    fwrreal(adhd.dimgap);                 /* location 6AB */
    fwrreal(adhd.pelevation);             /* location 6B3 */
/* this should be present in all "real" release 11 files */
    fwrw(adhd.visretain);
/* this is just a fake crc until we get done */
    fwrw(0);                         /* location 6BD, if above is present */
  }
  adin.headersize SUBN=(short)ftell(adin.dwgfilew SUBN);
}

