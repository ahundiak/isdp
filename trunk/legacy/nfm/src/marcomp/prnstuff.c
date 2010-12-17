
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* MSSP - 29 Dec 93. changed sun to OS_SUNOS */
#ifndef OS_SUNOS
void writeheaderinfo(void)
#else
void writeheaderinfo()
#endif
{ short i;

  printf(
"  0\nSECTION\n  2\nHEADER\n  9\n$ACADVER\n  1\n%s\n",adhd.acadverr);
  printf("  9\n$INSBASE\n 10\n");
  printf("%lf\n",adhd.base[0]);
  printf(" 20\n");
  printf("%lf\n",adhd.base[1]);
  printf("  9\n$EXTMIN\n 10\n");
  printf("%lf\n",adhd.extmin[0]);
  printf(" 20\n");
  printf("%lf\n",adhd.extmin[1]);
  printf("  9\n$EXTMAX\n 10\n");
  printf("%lf\n",adhd.extmax[0]);
  printf(" 20\n");
  printf("%lf\n",adhd.extmax[1]);
  printf("  9\n$LIMMIN\n 10\n");
  printf("%lf\n",adhd.limmin[0]);
  printf(" 20\n");
  printf("%lf\n",adhd.limmin[1]);
  printf("  9\n$LIMMAX\n 10\n");
  printf("%lf\n",adhd.limmax[0]);
  printf(" 20\n");
  printf("%lf\n",adhd.limmax[1]);
  printf("  9\n$VIEWCTR\n 10\n");
  printf("%lf\n",adhd.viewctr[0]);
  printf(" 20\n");
  printf("%lf\n",adhd.viewctr[1]);
  printf("  9\n$VIEWSIZE\n 40\n");
  printf("%lf\n",adhd.viewsize);
  printf("  9\n$SNAPMODE\n 70\n");
  printf("%d\n",adhd.snapmode);
  printf("  9\n$SNAPUNIT\n 10\n");
  printf("%lf\n",adhd.snapunit[0]);
  printf(" 20\n");
  printf("%lf\n",adhd.snapunit[1]);
  printf("  9\n$SNAPBASE\n 10\n");
  printf("%lf\n",adhd.snapbase[0]);
  printf(" 20\n");
  printf("%lf\n",adhd.snapbase[1]);
  printf("  9\n$SNAPANG\n 50\n");
  printf("%lf\n",adhd.snapang);
  printf("  9\n$SNAPSTYLE\n 70\n");
  printf("%d\n",adhd.snapstyle);
  printf("  9\n$SNAPISOPAIR\n 70\n");
  printf("%d\n",adhd.snapisopair);
  printf("  9\n$GRIDMODE\n 70\n");
  printf("%d\n",adhd.gridmode);
  printf("  9\n$GRIDUNIT\n 10\n");
  printf("%lf\n",adhd.gridunit[0]);
  printf(" 20\n");
  printf("%lf\n",adhd.gridunit[1]);
  printf("  9\n$ORTHOMODE\n 70\n");
  printf("%d\n",adhd.orthomode);
  printf("  9\n$REGENMODE\n 70\n");
  printf("%d\n",adhd.regenmode);
  printf("  9\n$FILLMODE\n 70\n");
  printf("%d\n",adhd.fillmode);
  printf("  9\n$QTEXTMODE\n 70\n");
  printf("%d\n",adhd.qtextmode);
  printf("  9\n$DRAGMODE\n 70\n");
  printf("%d\n",adhd.dragmode);
  printf("  9\n$LTSCALE\n 40\n");
  printf("%lf\n",adhd.ltscale);
  printf("  9\n$OSMODE\n 70\n");
  printf("%d\n",adhd.osmode);
  printf("  9\n$ATTMODE\n 70\n");
  printf("%d\n",adhd.attmode);
  printf("  9\n$TEXTSIZE\n 40\n");
  printf("%lf\n",adhd.textsize);
  printf("  9\n$TRACEWID\n 40\n");
  printf("%lf\n",adhd.tracewid);
  printf("  9\n$TEXTSTYLE\n  7\n");
  printf("%d\n",adhd.curstyleindex);
  printf("  9\n$CLAYER\n  8\n");
  printf("%d\n",adhd.curlayerindex);
  printf("  9\n$CELTYPE\n  6\n");
  if (adhd.celtype==256) printf("BYLAYER\n");
    else printf("%d\n",adhd.celtype);
  printf("  9\n$CECOLOR\n 62\n");
  printf("%d\n",adhd.cecolor);
  printf("  9\n$DIMSCALE\n 40\n");
  printf("%lf\n",adhd.dimscale);
  printf("  9\n$DIMASZ\n 40\n");
  printf("%lf\n",adhd.dimasz);
  printf("  9\n$DIMEXO\n 40\n");
  printf("%lf\n",adhd.dimexo);
  printf("  9\n$DIMDLI\n 40\n");
  printf("%lf\n",adhd.dimdli);
  printf("  9\n$DIMRND\n 40\n");
  printf("%lf\n",adhd.dimrnd);
  printf("  9\n$DIMDLE\n 40\n");
  printf("%lf\n",adhd.dimdle);
  printf("  9\n$DIMEXE\n 40\n");
  printf("%lf\n",adhd.dimexe);
  printf("  9\n$DIMTP\n 40\n");
  printf("%lf\n",adhd.dimtp);
  printf("  9\n$DIMTM\n 40\n");
  printf("%lf\n",adhd.dimtm);
  printf("  9\n$DIMTXT\n 40\n");
  printf("%lf\n",adhd.dimtxt);
  printf("  9\n$DIMCEN\n 40\n");
  printf("%lf\n",adhd.dimcen);
  printf("  9\n$DIMTSZ\n 40\n");
  printf("%lf\n",adhd.dimtsz);
  printf("  9\n$DIMTOL\n 70\n");
  printf("%d\n",adhd.dimtol);
  printf("  9\n$DIMLIM\n 70\n");
  printf("%d\n",adhd.dimlim);
  printf("  9\n$DIMTIH\n 70\n");
  printf("%d\n",adhd.dimtih);
  printf("  9\n$DIMTOH\n 70\n");
  printf("%d\n",adhd.dimtoh);
  printf("  9\n$DIMSE1\n 70\n");
  printf("%d\n",adhd.dimse1);
  printf("  9\n$DIMSE2\n 70\n");
  printf("%d\n",adhd.dimse2);
  printf("  9\n$DIMTAD\n 70\n");
  printf("%d\n",adhd.dimtad);
  printf("  9\n$DIMZIN\n 70\n");
  printf("%d\n",adhd.dimzin);
  printf("  9\n$DIMBLK\n  1\n");
  printf("%s\n",adhd.dimblk);
  printf("  9\n$DIMASO\n 70\n");
  printf("%d\n",adhd.dimaso);
  printf("  9\n$DIMSHO\n 70\n");
  printf("%d\n",adhd.dimsho);
  printf("  9\n$DIMPOST\n  1\n");
  printf("%s\n",adhd.dimpost);
  printf("  9\n$DIMAPOST\n  1\n");
  printf("%s\n",adhd.dimapost);
  printf("  9\n$DIMALT\n 70\n");
  printf("%d\n",adhd.dimalt);
  printf("  9\n$DIMALTD\n 70\n");
  printf("%d\n",adhd.dimaltd);
  printf("  9\n$DIMALTF\n 40\n");
  printf("%lf\n",adhd.dimaltf);
  printf("  9\n$DIMLFAC\n 40\n");
  printf("%lf\n",adhd.dimlfac);
  printf("  9\n$LUNITS\n 70\n");
  printf("%d\n",adhd.lunits);
  printf("  9\n$LUPREC\n 70\n");
  printf("%d\n",adhd.luprec);
  printf("  9\n$AXISMODE\n 70\n");
  printf("%d\n",adhd.axismode);
  printf("  9\n$AXISUNIT\n 10\n");
  printf("%lf\n",adhd.axisunit[0]);
  printf(" 20\n");
  printf("%lf\n",adhd.axisunit[1]);
  printf("  9\n$SKETCHINC\n 40\n");
  printf("%lf\n",adhd.sketchinc);
  printf("  9\n$FILLETRAD\n 40\n");
  printf("%lf\n",adhd.filletrad);
  printf("  9\n$AUNITS\n 70\n");
  printf("%d\n",adhd.aunits);
  printf("  9\n$AUPREC\n 70\n");
  printf("%d\n",adhd.auprec);
  printf("  9\n$MENU\n  1\n");
  printf("%s\n",adhd.acadmenu);
  printf("  9\n$ELEVATION\n 40\n");
  printf("%lf\n",adhd.elevation);
  printf("  9\n$THICKNESS\n 40\n");
  printf("%lf\n",adhd.thickness);
  printf("  9\n$VIEWDIR\n 10\n");
  printf("%lf\n",adhd.vpointhdr[0]);
  printf(" 20\n");
  printf("%lf\n",adhd.vpointhdr[1]);
  printf(" 30\n");
  printf("%lf\n",adhd.vpointhdr[2]);
  printf("  9\n$LIMCHECK\n 70\n");
  printf("%d\n",adhd.limcheck);
  printf("  9\n$BLIPMODE\n 70\n");
  printf("%d\n",adhd.blipmode);
  printf("  9\n$CHAMFERA\n 40\n");
  printf("%lf\n",adhd.chamfera);
  printf("  9\n$CHAMFERB\n 40\n");
  printf("%lf\n",adhd.chamferb);
  printf("  9\n$FASTZOOM\n 70\n");
  printf("%d\n",adhd.fastzoom);
  printf("  9\n$SKPOLY\n 70\n");
  printf("%d\n",adhd.skpoly);
  printf("  9\n$TDCREATE\n 40\n");
  printf("%.10f\n",((double)adhd.tdcreate2) / 86400000.0+(double)adhd.tdcreate1);
  printf("  9\n$TDUPDATE\n 40\n");
  printf("%.10f\n",((double)adhd.tdupdate2) / 86400000.0+(double)adhd.tdupdate1);
  printf("  9\n$TDINDWG\n 40\n");
  printf("%.10f\n",((double)adhd.tdindwg2)  / 86400000.0+(double)adhd.tdindwg1);
  printf("  9\n$TDUSRTIMER\n 40\n");
  printf("%.10f\n",((double)adhd.tdusrtimer2)/86400000.0+(double)adhd.tdusrtimer1);
  printf("  9\n$USRTIMER\n 70\n");
  printf("%d\n",adhd.usrtimer);
  printf("  9\n$ANGBASE\n 50\n");
  printf("%lf\n",adhd.angbase);
  printf("  9\n$ANGDIR\n 70\n");
  printf("%d\n",adhd.angdir);
  printf("  9\n$PDMODE\n 70\n");
  printf("%d\n",adhd.pdmode);
  printf("  9\n$PDSIZE\n 40\n");
  printf("%lf\n",adhd.pdsize);
  printf("  9\n$PLINEWID\n 40\n");
  printf("%lf\n",adhd.plinewid);
  printf("  9\n$COORDS\n 70\n");
  printf("%d\n",adhd.coords);
  printf("  9\n$SPLFRAME\n 70\n");
  printf("%d\n",adhd.splframe);
  printf("  9\n$SPLINESEGS\n 70\n");
  printf("%d\n",(short)(adhd.splinesegs & 255));
  printf("  9\n$ATTDIA\n 70\n");
  printf("%d\n",adhd.attdia);
  printf("  9\n$ATTREQ\n 70\n");
  printf("%d\n",adhd.attreq);
  printf("  9\n$HANDLES\n 70\n");
  printf("%d\n",adhd.enthandles);
  printf("  9\n$HANDSEED\n  5\n");
printf("???\n");
  printf("  9\n$SURFTAB1\n 70\n");
  printf("%d\n",adhd.surftab1);
  printf("  9\n$SURFTAB2\n 70\n");
  printf("%d\n",adhd.surftab2);
  printf("  9\n$SURFTYPE\n 70\n");
  printf("%d\n",adhd.surftype);
  printf("  9\n$SURFU\n 70\n");
  printf("%d\n",adhd.surfu);
  printf("  9\n$SURFV\n 70\n");
  printf("%d\n",adhd.surfv);
  printf("  9\n$FLATLAND\n 70\n");
  printf("%d\n",adhd.flatland);
  printf("  9\n$UCSNAME\n  2\n");
  printf("%s\n",adhd.ucsname);
  printf("  9\n$UCSORG\n 10\n");
  printf("%lf\n",adhd.ucsorih[0]);
  printf("  20\n%lf\n",adhd.ucsorih[1]);
  printf("  30\n%lf\n",adhd.ucsorih[2]);
  printf("  9\n$UCSXDIR\n 10\n");
  printf("%lf\n",adhd.ucsxdirh[0]);
  printf("  20\n%lf\n",adhd.ucsxdirh[1]);
  printf("  30\n%lf\n",adhd.ucsxdirh[2]);
  printf("  9\n$UCSYDIR\n 10\n");
  printf("%lf\n",adhd.ucsydirh[0]);
  printf("  20\n%lf\n",adhd.ucsydirh[1]);
  printf("  30\n%lf\n",adhd.ucsydirh[2]);
  printf("  9\n$WORLDVIEW\n 70\n");
  printf("???\n");
  for (i=0; i<5; i++) {
    printf("  9\n$USERI%d\n 70\n",i+1);
    printf("%d\n",adhd.useri[i]);
  }
  for (i=0; i<5; i++) {
    printf("  9\n$USERR%d\n 40\n",i+1);
    printf("%lf\n",adhd.userr[i]);
  }
  printf("  0\nENDSEC\n");
}

/* MSSP - 29 Dec 93. replaced sun with OS_SUNOS */
#ifndef OS_SUNOS
void text2(struct adtdatastru *tdata) /* 2nd part of an attdef or attrib */
#else
void text2(tdata)
struct adtdatastru *tdata;
#endif
{
  printf(" 50\n");
  printf("%lf\n",tdata->rotang);
  printf(" 41\n");
  printf("%lf\n",tdata->widthfactor);
  printf(" 51\n");
  printf("%lf\n",tdata->oblique);
  printf("  7\n%d\n",tdata->styleno);
  printf(" 71\n");
  printf("%d\n",tdata->generationflag);
  printf(" 72\n");
  printf("%d\n",tdata->justification);
  printf(" 11\n");
  printf("%lf\n",tdata->secondtextloc[0]);
  printf(" 21\n");
  printf("%lf\n",tdata->secondtextloc[1]);
}

/* MSSP - 29 Dec 93. replaced sun with OS_SUNOS */
#ifndef OS_SUNOS
void printentity(void)  /* write an entity */
#else
void printentity()
#endif

{

  char flag2;
  short i;

  switch (adenhd.enttype) {
    case 1: printf("LINE\n");     break;
    case 2: printf("POINT\n");    break;
    case 3: printf("CIRCLE\n");   break;
    case 4: printf("SHAPE\n");    break;
    case 7: printf("TEXT\n");     break;
    case 8: printf("ARC\n");      break;
    case 9: printf("TRACE\n");    break;
    case 11: printf("SOLID\n");   break;
    case 12: printf("BLOCK\n");   break;
    case 13: printf("ENDBLK\n");  break;
    case 14: printf("INSERT\n");  break;
    case 15: printf("ATTDEF\n");  break;
    case 16: printf("ATTRIB\n");  break;
    case 17: printf("SEQEND\n");  break;
    case 18:                           break;
    case 19: printf("POLYLINE\n");   break;
    case 20: printf("VERTEX\n");  break;
    case 21: printf("3DLINE\n");  break;
    case 22: printf("3DFACE\n");  break;
    case 23: printf("DIMENSION\n"); break;
    case 24: printf("VPORTENT\n"); break;
  }

  printf("Layernumber:\n");
  printf("%d\n",adenhd.layerindex);
  if (adhd.enthandles && adenhd.enthandlelength) {
    printf("  5\n");
    i=0;
    while (i<8 && adenhd.enthandle[i]==0) i++;
    while (i<8)
      printf("%.2X",((unsigned)adenhd.enthandle[i++]) & 255);
    printf("\n");
  }

  switch (adenhd.enttype) {
  case 1: /* line */
    printf(" 10\n");
    printf("%lf\n",aden.line.pt0[0]);
    printf(" 20\n");
    printf("%lf\n",aden.line.pt0[1]);
    if (adct.ouracadverr SUBN>=ACAD10 && aden.line.pt0[2]!=0.0) {
      printf(" 30\n");
      printf("%lf\n",aden.line.pt0[2]);
    }
    printf(" 11\n");
    printf("%lf\n",aden.line.pt1[0]);
    printf(" 21\n");
    printf("%lf\n",aden.line.pt1[1]);
    if (adct.ouracadverr SUBN>=ACAD10 && aden.line.pt1[2]!=0.0) {
      printf(" 31\n");
      printf("%lf\n",aden.line.pt1[2]);
    }
    break;

  case 2: /* point */
    printf(" 10\n");
    printf("%lf\n",aden.point.pt0[0]);
    printf(" 20\n");
    printf("%lf\n",aden.point.pt0[1]);
    if (adct.ouracadverr SUBN>=ACAD10) {
      if (aden.point.pt0[2]!=0.0) {
        printf(" 30\n");
        printf("%lf\n",aden.point.pt0[2]);
      }
      if (aden.point.ucsxangle!=0.0) {
        printf(" 50\n");
        printf("%lf\n",aden.point.ucsxangle);
      }
    }
    break;


  case 3:  /* circle */
    printf(" 10\n");
    printf("%lf\n",aden.circle.pt0[0]);
    printf(" 20\n");
    printf("%lf\n",aden.circle.pt0[1]);
    if (adct.ouracadverr SUBN>=ACAD10 && aden.circle.pt0[2]!=0.0)
      printf(" 30\n%lf\n",aden.circle.pt0[2]);
    printf(" 40\n");
    printf("%lf\n",aden.circle.radius);
    break;

  case 4: /* shape */ /* missing name, obl angle and rel x scale */
    printf(" 10\n");
    printf("%lf\n",aden.shape.pt0[0]);
    printf(" 20\n");
    printf("%lf\n",aden.shape.pt0[1]);
    printf(" 40\n");
    printf("%lf\n",aden.shape.scale);
    printf("  2\n");
    printf("%d\n",aden.shape.whichshape);
    printf(" 50\n");
    printf("%lf\n",aden.shape.rotang);
    break;

  case 7: /* text */
    printf(" 10\n");
    printf("%lf\n",aden.text.pt0[0]);
    printf(" 20\n");
    printf("%lf\n",aden.text.pt0[1]);
    if (adct.ouracadverr SUBN>=ACAD10 && aden.text.pt0[2]!=0.0) {
      printf(" 30\n");
      printf("%lf\n",aden.text.pt0[2]);
    }
    printf(" 40\n");
    printf("%lf\n",aden.text.tdata.height);
    printf("  1\n");
    printf("%s\n",aden.text.textstr);
    printf(" 50\n");
    text2(&aden.text.tdata);
    break;

  case 8: /* arc */
    printf(" 10\n");
    printf("%lf\n",aden.arc.pt0[0]);
    printf(" 20\n");
    printf("%lf\n",aden.arc.pt0[1]);
    printf(" 40\n");
    printf("%lf\n",aden.arc.radius);
    printf(" 50\n");
    printf("%lf\n",aden.arc.stang);
    printf(" 51\n");
    printf("%lf\n",aden.arc.endang);
    break;

  case 9:
  case 11: /* trace or solid */
    printf(" 10\n");
    printf("%lf\n",aden.trace.pt0[0]);
    printf(" 20\n");
    printf("%lf\n",aden.trace.pt0[1]);
    printf(" 11\n");
    printf("%lf\n",aden.trace.pt1[0]);
    printf(" 21\n");
    printf("%lf\n",aden.trace.pt1[1]);
    printf(" 12\n");
    printf("%lf\n",aden.trace.pt2[0]);
    printf(" 22\n");
    printf("%lf\n",aden.trace.pt2[1]);
    printf(" 13\n");
    printf("%lf\n",aden.trace.pt3[0]);
    printf(" 23\n");
    printf("%lf\n",aden.trace.pt3[1]);
    break;

  case 12:/* block */
    printf(" 10\n");
    printf("%lf\n",aden.block.base[0]);
    printf(" 20\n");
    printf("%lf\n",aden.block.base[1]);
    break;

  case 13:/* endblk */
    break;

  case 14: /* insert */
    if (aden.insert.attribsfollow) {
      printf(" 66\n");
      printf("%d\n",1);
    }
    printf("  2\n");
    printf("%d\n",aden.insert.blockno);
    printf("\n");
    printf(" 10\n");
    printf("%lf\n",aden.insert.pt0[0]);
    printf(" 20\n");
    printf("%lf\n",aden.insert.pt0[1]);
    printf(" 41\n");
    printf("%lf\n",aden.insert.xscale);
    printf(" 42\n");
    printf("%lf\n",aden.insert.yscale);
    printf(" 50\n");
    printf("%lf\n",aden.insert.rotang);
    printf(" 43\n");
    printf("%lf\n",aden.insert.zscale);
    printf(" 70\n");
    printf("%d\n",aden.insert.numcols);
    printf(" 71\n");
    printf("%d\n",aden.insert.numrows);
    printf(" 44\n");
    printf("%lf\n",aden.insert.coldist);
    printf(" 45\n");
    printf("%lf\n",aden.insert.rowdist);
    break;

  case 15: /* attdef */
    printf(" 10\n");
    printf("%lf\n",aden.attdef.pt0[0]);
    printf(" 20\n");
    printf("%lf\n",aden.attdef.pt0[1]);
    printf(" 40\n");
    printf("%lf\n",aden.attdef.tdata.height);
    printf("  1\n");
    printf("%s\n",aden.attdef.defaultval);
    printf("  3\n");
    printf("%s\n",aden.attdef.prompt);
    printf("  2\n");
    printf("%s\n",aden.attdef.tag);
    printf(" 70\n");
    printf("%d\n",aden.attdef.attflag);
    text2(&aden.attdef.tdata);
    break;

  case 16: /* attrib */
    printf(" 10\n");
    printf("%lf\n",aden.attrib.pt0[0]);
    printf(" 20\n");
    printf("%lf\n",aden.attrib.pt0[1]);
    printf(" 40\n");
    printf("%lf\n",aden.attrib.tdata.height);
    printf("  1\n");
    printf("%s\n",aden.attrib.attval);
    printf("  2\n");
    printf("%s\n",aden.attrib.tag);
    printf(" 70\n");
    printf("%d\n",aden.attrib.attflag);
    text2(&aden.attdef.tdata);
    break;

  case 17: /* seqend */
    break;

  case 18: /* placeholder */
    break;

  case 19: /* polyline */
    printf(" 66\n"); /* entities follow ? weird */
    printf("%d\n",1);
    printf(" 70\n");
    printf("%d\n",aden.pline.polyflag);
    printf(" 40\n");
    printf("%lf\n",aden.pline.startwidth);
    printf(" 41\n");
    printf("%lf\n",aden.pline.endwidth);
    break;

  case 20: /* vertex */
    printf(" 10\n");
    printf("%lf\n",aden.vertex.pt0[0]);
    printf(" 20\n");
    printf("%lf\n",aden.vertex.pt0[1]);
    printf(" 40\n");
    printf("%lf\n",aden.vertex.startwidth);
    printf(" 41\n");
    printf("%lf\n",aden.vertex.endwidth);
    printf(" 42\n");
    printf("%lf\n",aden.vertex.bulge);
    printf(" 70\n");
    printf("%d\n",aden.vertex.vertexflag);
    printf(" 50\n");
    printf("%lf\n",aden.vertex.tangentdir);
    break;

  case 21: /* 3dline */
    printf(" 10\n");
    printf("%lf\n",aden.line3d.pt0[0]);
    printf(" 20\n");
    printf("%lf\n",aden.line3d.pt0[1]);
    printf(" 30\n");
    printf("%lf\n",aden.line3d.pt0[2]);
    printf(" 11\n");
    printf("%lf\n",aden.line3d.pt1[0]);
    printf(" 21\n");
    printf("%lf\n",aden.line3d.pt1[1]);
    printf(" 31\n");
    printf("%lf\n",aden.line3d.pt1[2]);
    break;
    
  case 22: /* 3dface */
    printf(" 10\n");
    printf("%lf\n",aden.face3d.pt0[0]);
    printf(" 20\n");
    printf("%lf\n",aden.face3d.pt0[1]);
    printf(" 30\n");
    printf("%lf\n",aden.face3d.pt0[2]);
    printf(" 11\n");
    printf("%lf\n",aden.face3d.pt1[0]);
    printf(" 21\n");
    printf("%lf\n",aden.face3d.pt1[1]);
    printf(" 31\n");
    printf("%lf\n",aden.face3d.pt1[2]);
    printf(" 12\n");
    printf("%lf\n",aden.face3d.pt2[0]);
    printf(" 22\n");
    printf("%lf\n",aden.face3d.pt2[1]);
    printf(" 32\n");
    printf("%lf\n",aden.face3d.pt2[2]);
    printf(" 13\n");
    printf("%lf\n",aden.face3d.pt3[0]);
    printf(" 23\n");
    printf("%lf\n",aden.face3d.pt3[1]);
    printf(" 33\n");
    printf("%lf\n",aden.face3d.pt3[2]);
    break;

  case 23: /* associative dimension */
    printf("  2\n");
    printf("%d\n",aden.dim.dimblkno);
    printf(" 10\n");
    printf("%lf\n",aden.dim.dimlinedefpt[0]);
    printf(" 20\n");
    printf("%lf\n",aden.dim.dimlinedefpt[1]);
    printf(" 11\n");
    printf("%lf\n",aden.dim.dimtextmidpt[0]);
    printf(" 21\n");
    printf("%lf\n",aden.dim.dimtextmidpt[1]);
    printf(" 12\n");
    printf("%lf\n",aden.dim.dimcloneinspt[0]);
    printf(" 22\n");
    printf("%lf\n",aden.dim.dimcloneinspt[1]);
    printf(" 70\n");
    printf("%d\n",(short)(aden.dim.dimflag & 255));
    printf("  1\n");
    printf("%s\n",aden.dim.dimtext);
    flag2=aden.dim.dimflag & '\07';
    if (flag2==0 || flag2==1 || flag2==2) { /* lin, ali or ang */
      printf(" 13\n");
      printf("%lf\n",aden.dim.defpt2[0]);
      printf(" 23\n");
      printf("%lf\n",aden.dim.defpt2[1]);
    }
    if (flag2==0 || flag2==1 || flag2==2) { /* lin, ali or ang */
      printf(" 14\n");
      printf("%lf\n",aden.dim.defpt3[0]);
      printf(" 24\n");
      printf("%lf\n",aden.dim.defpt3[1]);
    }
    if (flag2==2 || flag2==3 || flag2==4) { /* ang diam or rad */
      printf(" 15\n");
      printf("%lf\n",aden.dim.defpt4[0]);
      printf(" 25\n");
      printf("%lf\n",aden.dim.defpt4[1]);
    }
    if (flag2==2) { /* ang */
      printf(" 16\n");
      printf("%lf\n",aden.dim.arcdefpt[0]);
      printf(" 26\n");
      printf("%lf\n",aden.dim.arcdefpt[1]);
    }
    printf(" 40\n");
    printf("%lf\n",aden.dim.leaderlen);
    printf(" 50\n");
    printf("%lf\n",aden.dim.dimrotang);
    break;

  case 24: if (adct.ouracadverr SUBN>=ACAD11) {      /* vport entity */
             printf(" 10\n");
             printf("%lf\n",aden.vpent.cen[0]);
             printf(" 20\n");
             printf("%lf\n",aden.vpent.cen[1]);
             printf(" 30\n");
             printf("%lf\n",aden.vpent.cen[2]);
             printf(" 40\n");
             printf("%lf\n",aden.vpent.width);
             printf(" 41\n");
             printf("%lf\n",aden.vpent.height);
             printf(" 69\n");
             printf("%d\n",aden.vpent.id);
           }

    break;
  default: printf("Unknown entity %d encountered\n",adenhd.enttype);
           break;
  } /* end of switch */
  if (adenhd.extrusion[0]!=0.0 ||
      adenhd.extrusion[1]!=0.0 ||
      adenhd.extrusion[2]!=0.0)
    printf("210\n%lf\n220\n%lf\n230\n%lf\n",adenhd.extrusion[0],adenhd.extrusion[1],adenhd.extrusion[2]);
}

