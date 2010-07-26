#include	<stdio.h>
#include        <malloc.h>
#include	"ST.h"

#define IFPAUSE(tst) if (pause && (tst)) { printf ("\n[?] "); scanf ("%c", &option); if (option == 'q') exit (0);}
#define IFRDERR if (rdErr) {printf ("premature exit due to file read error\n"); exit (0); }

extern  char  *optarg;

main  (argc, argv)
int     argc;
char    *argv[];

{
  char          filename[132], *tptr;
  FILE          *fp;
  char          option;
  int           numSTA, numSTB, numSTC, numSTD, numObjs, numObjsToInit;
  int           sizeSTA, sizeSTB, sizeSTC, sizeSTD, numMsgs;
  int           consProf =      0;
  int           seqMsg =        0;
  int           randomMsg =     0;
  int           pause =         0;
  int           rdErr =         0;
  int           ii, jj, kk, *iptr;
  char          *classArray;
  int           *seqProf, *Aprof, *Bprof, *Cprof, *Dprof;
  MsgProf       *randomProf;
  
  strcpy (filename, "STproFile.d");
  while (EOF != (option = getopt (argc,argv,"f:csrap")))
  {
    switch (option)
    {
    case 'f':
      strcpy(filename, optarg);
      break;
    case 'c':
      consProf = 1;
      break;
    case 's':
      seqMsg = 1;
      break;
    case 'r':
      randomMsg = 1;
      break;
    case 'a':
      consProf = 1;
      seqMsg = 1;
      randomMsg = 1;
      break;
    case 'p':
      pause = 1;
      break;
    case '?':
      printf ("usage: -f filename -c (cons profile) -s (seq msgs)\n");
      printf ("       -r (random msgs)\n");
      printf ("       -a (all) -p (pause)\n");
      exit (0);
    }
  }
  if (NULL == (fp = fopen (filename, "r")))
  {
    printf ("error opening %s\n", filename);
    perror ("");
    exit (0);
  }
  fread (&numSTA, sizeof (int), 1, fp);
  fread (&numSTB, sizeof (int), 1, fp);
  fread (&numSTC, sizeof (int), 1, fp);
  fread (&numSTD, sizeof (int), 1, fp);
  fread (&numObjsToInit, sizeof (int), 1, fp);
  fread (&sizeSTA, sizeof (int), 1, fp);
  fread (&sizeSTB, sizeof (int), 1, fp);
  fread (&sizeSTC, sizeof (int), 1, fp);
  fread (&sizeSTD, sizeof (int), 1, fp);
  fread (&numMsgs, sizeof (int), 1, fp);
  numObjs = numSTA + numSTB + numSTC + numSTD;

  printf ("Objects to construct:   %6d\n", numObjs);
  printf ("To initially construct: %6d\n", numObjsToInit);
  printf (" %5d STA        (size: %5d)\n", numSTA, sizeSTA);
  printf (" %5d STB        (size: %5d)\n", numSTB, sizeSTB);
  printf (" %5d STC        (size: %5d)\n", numSTC, sizeSTC);
  printf (" %5d STD        (size: %5d)\n", numSTD, sizeSTD);
  printf ("Messages to transmit:   %6d\n", numMsgs);
  
  if (!consProf && !randomMsg) exit (0);
  IFPAUSE(1);
  if (NULL == (classArray = malloc (numObjs)))
  {
    perror ("error in malloc");
    exit (0);
  }
  if (numObjs != (ii = fread (classArray, 1, numObjs, fp)))
  {
    printf 
      ("error reading classArray; only read %d of %d chars\n", ii, numObjs);
    perror ("");
    rdErr = 1;
    numObjs = ii;
  }
  
  if (consProf)
  {
    printf ("construction sequence looks like:\n");
    for (ii=0; ii<numObjs; ii+=30)
    {
      for (jj=ii; jj<(ii+30) && jj<numObjs; jj++) printf (" %c", classArray[jj]);
      printf ("\n");
    }
  }
  IFRDERR;  
  IFPAUSE(consProf);

  if (numObjsToInit)
  {
    seqProf = malloc (sizeof (int) * numObjsToInit);
    if (numObjsToInit != (ii = 
        fread (seqProf, sizeof (int), numObjsToInit, fp)))
    {
      printf("error reading sequential msg profile; only read %d of %d items\n",
      ii, numObjsToInit);
      perror ("");
      numObjsToInit = ii;
      rdErr = 1;
    }
    if (seqMsg)
    {
      printf ("Sequential messages:\n");
      for (ii=0; ii<numObjsToInit; ii+=10)
      {
        for (jj=ii; jj<(ii+10) && jj<numObjsToInit; jj++) 
          printf ("  %6d", seqProf[jj]);
        printf ("\n");
      }
    }
  }

  if (randomMsg)
  {
    IFRDERR;
    IFPAUSE(seqMsg);
    randomProf = malloc (sizeof (MsgProf) * numMsgs);
    if (numMsgs != (ii = fread (randomProf, sizeof (MsgProf), numMsgs, fp)))
    {
      printf ("error reading random msg profile; % d of %d items read\n",
        ii, numMsgs);
      perror ("");
      numMsgs = ii;
      rdErr = 1;
    }
    printf ("%d random msgs\n", numMsgs);
    for (ii = 0; ii<numMsgs; ii+=22)
    {
      for (jj = ii; jj<(ii+22) && jj<numMsgs; jj++) 
      {
        printf (" msg #%5d: ", jj);
        switch (randomProf[jj].cmd)
        {
        case DOIT:
          printf ("DOIT (class: ST%c, objIdx: %5d, varyAmt: %6d)\n", 
            classArray[randomProf[jj].u1.m.objIdx],
            randomProf[jj].u1.m.objIdx, randomProf[jj].u1.m.varyAmt);
          break;
        case CONSTRUCT:
          printf ("CONS (class: ST%c)\n", randomProf[jj].u1.cls);
          break;
        case DELETE:
          printf ("DELE (class: ST%c, objIdx: %5d)\n", 
            classArray[randomProf[jj].u1.m.objIdx],
            randomProf[jj].u1.m.objIdx);
          break;
        default:
          printf ("UNKN (cmd = %d; ascii: \\", randomProf[jj].cmd);
          tptr = (char*) &randomProf[jj];
          for (kk = 0; kk<sizeof(MsgProf); kk++) printf ("%c", tptr[kk]);
          printf ("\\; int: ");
          iptr = (int*) &randomProf[jj];
          for (kk=0;  kk<sizeof(MsgProf)/4; kk++) printf (" %6d", iptr[kk]);
          printf (")\n");
        }
      }
      IFPAUSE(1);
    }
  }

  exit (0);
}
