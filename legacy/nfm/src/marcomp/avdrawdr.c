
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* avdrawdr.c -- autoview engine draw routine */
#include "avhdr.h"
/* #include "aveng.h" */
#ifdef AV
#ifdef PROTOTYPES
void  readtheviews(void);
#else
void readtheviews();
#endif
#endif

#ifndef OLDCHDR
void DefaultExamineXref(char *xrefname)
#else
void DefaultExamineXref(xrefname)
char *xrefname;
#endif
/* the default xref examine -- if the file isn't pathed to the right place,
   then search the ACAD environment variable for the drawing */
{
  char *envptr,*cptr;
  char testpath[128];
  short lastone,z,i;
  char acadenv[128];
/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifndef OS_UNIX
  static char pathchar='\\';
  static char oldpathchar='/';
#else
  static char pathchar='/';
  static char oldpathchar='\\';
#endif

  for (i=0; i<strlen(xrefname); i++)
    if (xrefname[i]==oldpathchar) xrefname[i]=pathchar;

/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifndef OS_UNIX
/* remove DOS drive specifier if present */
  if (xrefname[1]==':')
    for (i=0; i<strlen(xrefname)-1; i++)  /* get the null also */
      xrefname[i]=xrefname[i+2];
#endif

/* if it's a fully qualified path, just return */
  if (strchr(xrefname,pathchar)!=NULL) return;

  if (!access(xrefname,0)) return;   /* it is there (current dir) */
  else {

/* MSSP - 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifndef OS_UNIX
    if (strchr(xrefname,':')!=NULL) return;  /* path with drive id */
#endif

    if ((envptr=getenv("ACAD"))==NULL) return;  /* no environment to search */
    if (strlen(envptr) > 127) return;
	strcpy(acadenv,envptr);
	envptr=acadenv;

    lastone=0;
    cptr=envptr;
    do {
      while (*cptr!=';' && *cptr!=0) cptr++;
      if (*cptr==0) lastone=1;
      *cptr=0;
      strcpy(testpath,envptr);
      if (testpath[(z=strlen(testpath))-1]!=pathchar) {
        testpath[z]=pathchar;
        testpath[z+1]=0;
      }

      strcat(testpath,xrefname);
      if (!access(testpath,0)) {
        strcpy(xrefname,testpath);
        return;
      }
	  cptr++;
	  envptr=cptr;
    } while (!lastone);
  }
}

#ifndef OLDCHDR
double stretchamt(double mat[4][4])
#else
double stretchamt(mat)
double mat[4][4];
#endif
{
/* how much does this matrix stretch the vectors? */
  double temppt[4];

  temppt[0]=temppt[1]=temppt[2]=1.0/sqrt(3.0); /* length 1.0 vector */
  temppt[3]=0.0;   /* avoid translation by setting to 0.0 */
  transformpoint3d(temppt,mat,temppt);
  return(sqrt(temppt[0]*temppt[0]+temppt[1]*temppt[1]+temppt[2]*temppt[2]));
}

#ifndef OLDCHDR
short DrawDrawingqq(short drawblockno)
#else
short DrawDrawingqq(drawblockno)
short drawblockno;
#endif
/* return 1 if xrefs were encountered, 0 otherwise */
{
  short i,byblockcolor,level,overrideattmode,overridefillmode,overrideqtextmode;
  char  xreffilename[80];
  short xrefsfound,layer0color,holdspace;
  double initpt[3],initpt2[3],holdscale;
  double topmatrix[4][4];

  initpt[X]=initpt[Y]=initpt[Z]=0.0;
/*
  estremainingmem();
*/
  xrefsfound=0;
  overrideattmode=adhd.attmode;
  overridefillmode=adhd.fillmode;
  overrideqtextmode=adhd.qtextmode;
  holdspace=ad3in.enginespace;

  ad3ct.keepvectorizing=1;

  clearblockcache(1);
  identity(topmatrix);

  if (drawblockno==-1) {
    startentityread();
  }
  else {
  /* don't map this block number, it is already the "new" one */
    adin.blockdefoffsetr=ad3in.blk[drawblockno]->blkdefoffsetr;
    startblockdefread();
  }

/* init indicator */
  ad3in.lastperc=
/* init vector count */
  ad3in.vecfunccount=
  ad3in.firstvpentfound=0;
  ad3in.entlisttargstep=(adin.entlistendr-adin.entliststartr)/20L;
  ad3in.entlisttarg=adin.entliststartr+ad3in.entlisttargstep;
  if (ad_Odometer!=NULL) (*ad_Odometer)(0);
  ad3ct.vecfunclimit=100;

  ad3in.xrefreadptr=ad3in.xrefwriteptr=0L;
  ad3in.xreffile=NULL;

  byblockcolor=7;
  level=0;
  if (adct.ouracadverr<=ACAD10) {  /* set linetype values */
    ad3in.byblockltpval=255;
    ad3in.bylayerltpval=256;
  }
  else {
    ad3in.byblockltpval=32766;
    ad3in.bylayerltpval=32767;
  }

  if (ad3in.enginespace==PAPERSPACE ||
      fabs(adhd.ltscale*ad3in.viewplanetransmat[0][1][1])+
      fabs(adhd.ltscale*ad3in.viewplanetransmat[0][0][0]) > 4.0)
    ad3in.overridedolinetypes=1;
  else ad3in.overridedolinetypes=0;

/* compute matrix stretch amounts */
  for (i=0; i<ad3in.numvptmats; i++)
    ad3in.stretchamt[i]=stretchamt(ad3in.viewplanetransmat[i]);
  holdscale=adhd.ltscale;

  DrawEntityGroup(topmatrix,initpt,0.0,1.0,1.0,1.0,byblockcolor,0,level,-1,0);
  if (adin.inblockdefrflag) endblockdefread();
  ad3in.topleveldrawing=0;

  if (adct.ouracadverr>=ACAD11) {
    if (ad3in.xrefreadptr!=ad3in.xrefwriteptr) { /* we found some xrefs */
      layer0color=lay[0]->laycolor;
      endread();                  /* terminate read of last drawing */
      ad3in.ignorepspaceents=xrefsfound=1;
      while (!feof(ad3in.xreffile)) {
        fseek(ad3in.xreffile,ad3in.xrefreadptr,SEEK_SET);
        fread(&i,1,sizeof(short),ad3in.xreffile);
        if (!feof(ad3in.xreffile)) {
          fread(xreffilename,i,sizeof(char),ad3in.xreffile);
          xreffilename[i]=0;
          if (ad3in.displayitemtype==0) {
            if (strstr(xreffilename,".DWG")==NULL &&
                strstr(xreffilename,".dwg")==NULL)
              strcat(xreffilename,".dwg");
          }
          else {
            if (strstr(xreffilename,".DXF")==NULL &&
              strstr(xreffilename,".dxf")==NULL)
              strcat(xreffilename,".dxf");
          }

          fread(topmatrix,1,4*4*sizeof(double),ad3in.xreffile);
          fread(&byblockcolor,1,sizeof(short),ad3in.xreffile);
          fread(&level,1,sizeof(short),ad3in.xreffile);
          level=0;
          fread(&ad3in.overridepaperspace,1,sizeof(short),ad3in.xreffile);

          ad3in.globalvpflags=0;

          ad3in.xrefreadptr=ftell(ad3in.xreffile); /* save where to read from for next time */

          if (ad_Examinexref!=NULL) (*ad_Examinexref)(xreffilename);

          if (!initializeread(xreffilename,ad3in.avbufsz1,ad3in.avbufsz2,ad3in.avbufsz3)) { /* open file for read */
            if (ad_Badxref!=NULL) (*ad_Badxref)(xreffilename);
          }
          else {
            if (!readheader()) {
              terminateread();
              if (ad_Badxref!=NULL) (*ad_Badxref)(xreffilename);
            }
            else {
              ReadTables();
#ifdef AV
readtheviews();   /* basically, just read these for consistency, and */
#endif            /* free 'em later */

              lay[0]->laycolor=layer0color;
          /* set these */
              adhd.attmode=overrideattmode;
              adhd.qtextmode=overrideqtextmode;
              adhd.fillmode=overridefillmode;
              adhd.ltscale=holdscale;

              ad3in.lastperc=0;
              ad3in.entlisttargstep=(adin.entlistendr-adin.entliststartr)/20L;
              ad3in.entlisttarg=adin.entliststartr+ad3in.entlisttargstep;
              if (ad_Odometer!=NULL) (*ad_Odometer)(0);

#ifdef YAMAMA
              if (ad3in.displayitemtype==0 && adct.ouracadverr>=ACAD11 &&
                adct.numvportenthdrsr>0 &&
                adhd.tilemode==0)      /* saved in pspace */
              {                        /* override to pspace */
                SetSpace(PAPERSPACE);
              }
              else {
                SetSpace(MODELSPACE);
              }
#endif

              clearblockcache(1);
              startentityread();

              memcpy(initpt2,adhd.base,3*sizeof(double));
              initpt2[X] = -initpt2[X];
              initpt2[Y] = -initpt2[Y];
              initpt2[Z] = -initpt2[Z];
              translatematrix(initpt2,topmatrix);
              if (adct.ouracadverr<=ACAD10) {  /* set linetype values */
                ad3in.byblockltpval=255;
                ad3in.bylayerltpval=256;
              }
              else {
                ad3in.byblockltpval=32766;
                ad3in.bylayerltpval=32767;
              }
              DrawEntityGroup(topmatrix,initpt,0.0,1.0,1.0,
                1.0,byblockcolor,0,level,-1,ad3in.globalvpflags);
              endread();
            } /* readheader was successful */
          } /* initializeread was successful */
        } /* if !feof(ad3in.xreffile) */
      } /* while !feof(ad3in.xreffile) */
      ad3in.ignorepspaceents=0;
    }
  }
  if (ad3in.xreffile!=NULL) {
    fclose(ad3in.xreffile);
    strcpy(ad3in.pathbuf,ad3ct.tempfilepath);
    strcat(ad3in.pathbuf,"AVX.TMP");
    unlink(ad3in.pathbuf);
  }
  ad3in.overridepaperspace=0;
  ad3in.topleveldrawing=1;
  SetSpace(holdspace);
  return(xrefsfound);
}

#ifndef OLDCHDR
short DrawDrawing(void)
#else
short DrawDrawing()
#endif
{
  return(DrawDrawingqq(-1));
}

