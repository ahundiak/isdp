
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrh.c -- library routines for accessing autocad drawing files */
/* header read section */
/* version 01/12/89 */
#include "adrhdr.h"

#ifndef OLDCHDR
void readgarbage(char *garbagestr,short length)
#else
void readgarbage(garbagestr,length)
char *garbagestr;
short length;
#endif
{
  ad_fread(garbagestr,length,1,adin.dwgfiler SUBN);
}

#ifndef OLDCHDR
void skip(short n)  /* skip n bytes */
#else
void skip(n)
short n;
#endif
{
  char crap[256];
  ad_fread(crap,1,n,adin.dwgfiler SUBN);
}


#ifndef OLDCHDR
void readheader1qq(void)
#else
void readheader1qq()
#endif
{
  adct.numblocksr SUBN=adct.numlayersr SUBN=adct.numshapefilesr SUBN=adct.numlinetypesr SUBN=
    adct.numviewsr SUBN=adct.numucsr SUBN=adct.numvportsr SUBN=
    adct.numregappsr SUBN=adct.numdimstylesr SUBN=adct.numvportenthdrsr SUBN=0L;

  readgarbage(adin.garbage1 SUBN,14);
  adin.actualdrawingversionr SUBN  = buf2short(&adin.garbage1 SUBN [11]);
  if (adct.ouracadverr SUBN==ACAD10 && adin.actualdrawingversionr SUBN<(unsigned short)160) {
     /* fix to 160 type for write */
#ifndef OCTALONLY
    adin.garbage1 SUBN [11]='\xA0';
#else
    adin.garbage1 SUBN [11]='\240';  /* octal */
#endif
    adin.garbage1 SUBN [12]='\0';
    adin.actualdrawingversionr SUBN=(unsigned short)160;
  }
  adin.entliststartr SUBN =frdlong();				/* offset 14 */
  adin.entlistendr SUBN =frdlong();				/* offset 18 */
  adin.blkdefstartr SUBN =frdlong();				/* offset 1C */
  adin.blkdefsizer SUBN = frdlong() & 0x3FFFFFFFL;             /* offset 20 */
  adin.extraentlocr SUBN =frdlong();				/* offset 24 */
  if (adin.extraentlocr SUBN==0L) adin.extraentlocr SUBN=adin.blkdefstartr SUBN+adin.blkdefsizer SUBN;
  adin.extraentsizer SUBN = frdlong() & 0x3FFFFFFFL;           /* offset 28 */
  adin.sizeofblockheaderentryr SUBN =frdw();                   /* offset 2C */
  adct.numblocksr SUBN =frdlong();				/* offset 2E */
  if (adct.ouracadverr SUBN <ACAD9) adct.numblocksr SUBN &= (long)0xFFFF;
  adin.blkliststartr SUBN=frdlong();				/* offset 32 */

  adin.sizeoflayerentryr SUBN =frdw();
  adct.numlayersr SUBN =frdlong();					/* offset 38 */
  if (adct.ouracadverr SUBN <ACAD9) adct.numlayersr SUBN &= (long)0xFFFF;
  adin.layerliststartr SUBN =frdlong();				/* offset 3C */

  adin.sizeofshapefileentryr SUBN =frdw();                          /* offset 40 */
  adct.numshapefilesr SUBN =frdlong();				/* offset 42 */
  if (adct.ouracadverr SUBN <ACAD9) adct.numshapefilesr SUBN &= (long)0xFFFF;
  adin.shapeliststartr SUBN =frdlong();				/* offset 46 */

  adin.sizeoflinetypeentryr SUBN =frdw();                          /* offset 4A */
  adct.numlinetypesr SUBN =frdlong();				/* offset 4C */
  if (adct.ouracadverr SUBN <ACAD9) adct.numlinetypesr SUBN &= (long)0xFFFF;
  adin.linetypeliststartr SUBN =frdlong();				/* offset 50 */

  adin.sizeofviewentryr SUBN =frdw();                              /* offset 54 */
  adct.numviewsr SUBN =frdlong();					/* offset 56 */
  if (adct.ouracadverr SUBN <ACAD9) adct.numviewsr SUBN &= (long)0xFFFF;
  adin.viewliststartr SUBN =frdlong();				/* offset 5A */

  adhd.base[0]=frdreal();					/* offset 5E */
  adhd.base[1]=frdreal();					/* offset 66 */
  adhd.base[2]=frdreal();                                      /* offset 6E */
  adin.numentitiesr SUBN =frdw();					/* offset 76 */
  if (adct.ouracadverr SUBN>=ACAD11)
	adhd.plinegen=adin.numentitiesr SUBN;   /* R12 plinegen variable */
  adhd.extmin[0]=frdreal();					/* offset 78 */
  adhd.extmin[1]=frdreal();					/* offset 80 */
  adhd.extmin[2]=frdreal();					/* offset 88 */
  adhd.extmax[0]=frdreal();					/* offset 90 */
  adhd.extmax[1]=frdreal();					/* offset 98 */
  adhd.extmax[2]=frdreal();					/* offset A0 */
  adhd.limmin[0]=frdreal();					/* offset A8 */
  adhd.limmin[1]=frdreal();					/* offset B0 */
  adhd.limmax[0]=frdreal();					/* offset B8 */
  adhd.limmax[1]=frdreal();					/* offset C0 */
  adhd.viewctr[0]=frdreal();					/* offset C8 */
  adhd.viewctr[1]=frdreal();					/* offset D0 */
  adhd.viewctr[2]=frdreal(); /* conjecture */			/* offset D8 */
  adhd.viewsize=frdreal();					/* offset E0 */
  adhd.snapmode=frdw();					/* offset E8 */
  adhd.snapunit[0]=frdreal();					/* offset EA */
  adhd.snapunit[1]=frdreal();					/* offset F2 */
  adhd.snapbase[0]=frdreal();					/* offset FA */
  adhd.snapbase[1]=frdreal();					/* offset 102 */
  adhd.snapang=frdreal();					/* offset 10A */
  adhd.snapstyle=frdw();					/* offset 112 */
  adhd.snapisopair=frdw();					/* offset 114 */
  adhd.gridmode=frdw();					/* offset 116 */
  adhd.gridunit[0]=frdreal();					/* offset 118 */
  adhd.gridunit[1]=frdreal();					/* offset 120 */
  adhd.orthomode=frdw();					/* offset 128 */
  adhd.regenmode=frdw();					/* offset 12A */
  adhd.fillmode=frdw();					/* offset 12C */
  adhd.qtextmode=frdw();					/* offset 12E */
  adhd.dragmode=frdw();					/* offset 130 */
  adhd.ltscale=frdreal();					/* offset 132 */
  adhd.textsize=frdreal();					/* offset 13A */
  adhd.tracewid=frdreal();					/* offset 142 */
  adhd.curlayerindex=frdw();					/* offset 14A */
  readgarbage(adin.garbage9 SUBN,24);       /* offset 14C */
  if (adct.ouracadverr SUBN >=ACAD11)
    adhd.psltscale=adin.garbage9 SUBN [10]; /* 156 */
  else adhd.psltscale=0;
  if (adct.ouracadverr SUBN >=ACAD11)       /* at 158 */
	adhd.treedepth=(short)(adin.garbage9 SUBN [12] & 255)+256*(short)adin.garbage9 SUBN[13];
  else adhd.treedepth=0;
  adhd.lunits=frdw();					/* offset 164 */
  adhd.luprec=frdw();					/* offset 166 */
  adhd.axismode=frdw();					/* offset 168 */
  adhd.axisunit[0]=frdreal();					/* offset 16A */
  adhd.axisunit[1]=frdreal();					/* offset 172 */
  adhd.sketchinc=frdreal();					/* offset 17A */
  adhd.filletrad=frdreal();					/* offset 182 */
  adhd.aunits=frdw();					/* offset 18A */
  adhd.auprec=frdw();					/* offset 18C */
  adhd.curstyleindex=frdw();					/* offset 18E */
  adhd.osmode=frdw();					/* offset 190 */
  adhd.attmode=frdw();					/* offset 192 */
  ad_fread(adhd.acadmenu,15,1,adin.dwgfiler SUBN );			/* offset 194 */
  adhd.dimscale=frdreal();					/* offset 1A3 */
  adhd.dimasz=frdreal();					/* offset 1AB */
  adhd.dimexo=frdreal();					/* offset 1B3 */
  adhd.dimdli=frdreal();					/* offset 1BB */
  adhd.dimexe=frdreal();					/* offset 1C3 */
  adhd.dimtp=frdreal();					/* offset 1CB */
  adhd.dimtm=frdreal();					/* offset 1D3 */
  adhd.dimtxt=frdreal();					/* offset 1DB */
  adhd.dimcen=frdreal();					/* offset 1E3 */
  adhd.dimtsz=frdreal();					/* offset 1EB */
  adhd.dimtol=frdc();					/* offset 1F3 */
  adhd.dimlim=frdc();					/* offset 1F4 */
  adhd.dimtih=frdc();					/* offset 1F5 */
  adhd.dimtoh=frdc();					/* offset 1F6 */
  adhd.dimse1=frdc();					/* offset 1F7 */
  adhd.dimse2=frdc();					/* offset 1F8 */
  adhd.dimtad=frdc();					/* offset 1F9 */
  adhd.limcheck=frdw();					/* offset 1FA */
}

#ifndef OLDCHDR
short valhdrstr(char *acadverr)
#else
short valhdrstr(acadverr)
char *acadverr;
#endif
{
  if (!strcmp(acadverr,"AC1002")) return(ACAD25);
  else if (!strcmp(acadverr,"AC1003")) return(ACAD26);
  else if (!strcmp(acadverr,"AC1004")) return(ACAD9);
  else if (!strcmp(acadverr,"AC1006")) return(ACAD10);
  else if (!strcmp(acadverr,"AC1009")) return(ACAD11);
  return(-1);
}

#ifndef OLDCHDR
short readheader(void)
#else
short readheader()
#endif
{
  adin.dwgfiler SUBN =adin.dwgfilerent SUBN;
  ad_fseek(adin.dwgfiler SUBN,0L,0 );
  /* read autocad version */
  ad_fread(adhd.acadverr,6,1,adin.dwgfiler SUBN );
  adhd.acadverr[6]='\0';
  adct.ouracadverr SUBN=valhdrstr(adhd.acadverr);
  if (adct.ouracadverr SUBN==-1) {
    return(0);
  }
  readheader1qq();
#ifdef EVAL
  if ((short)adct.numblocksr SUBN>3 ||
      (short)adct.numlayersr SUBN>3) {
    adin.blkliststartr SUBN=
    adin.layerliststartr SUBN =
    adin.blkdefstartr SUBN =
    adin.shapeliststartr SUBN =
    adin.linetypeliststartr SUBN =
    adin.viewliststartr SUBN =
    adin.vportliststartr SUBN =
    adin.regappliststartr SUBN =
    adin.dimstyleliststartr SUBN =
    adin.entliststartr SUBN =0L;
    adhd.extmin[X]=adhd.extmin[Y]=adhd.extmax[X]=adhd.extmax[Y]=0.0;
    return(0);
  }
#endif
  readheader2qq();
  return(1);
}
