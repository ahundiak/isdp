#include  <stdio.h>
#include  <time.h>
#include  <malloc.h>
#include  "ST.h"

/****************************************************************************/
/*
    header of profile looks like:
    

      numSTA
      numSTB
      numSTC
      numSTD
      numObjsToInit
      STsizes[STAIDX]
      STsizes[STBIDX]
      STsizes[STCIDX]
      STsizes[STDIDX]
      numMsgs
      
then,

      construction profile
      if (numObjsToInit)
      {
        sequential msgs
      }
      numMsgs random msgs

*/
   
extern  char  	*optarg;
extern	double	drand48();

double	regions[5] = {0.0, 0.0, 0.0, 0.0, 1.0};
double  msgRegions[4] = {0.0, 1.0, 1.0, 1.0};
double  msgPercents[3] = {0.0, 0.0, 0.0};
int     msgCount[3] = {0, 0, 0};
int     msgLimits[3] = {0, 0, 0};
char    msgNames[3];
int     msgType[3];

char	STnames[] = {STA, STB, STC, STD};
int     STsizes[] = {STASIZE, STBSIZE, STCSIZE, STDSIZE};
int     STuserLimits[] = {-1,-1,-1,-1};
main (argc, argv)
int     argc;
char    *argv[];
{  
  double        percentA, percentB, percentC, percentD;
  double        percentDelete, percentConst;
  double        curProb, which, percents[4], tfloat, fNumObjs, percentRem;
  int           numSTA, numSTB, numSTC, numSTD, numObjs;
  int           numMsgs =       MAXMSGS;
  int           numObjsToMake = MAXOBJS;
  int		numObjsToInit =	3*(MAXOBJS/4);
  int		numDoits = 	3*(MAXMSGS/4);
  int		numConstsInMsg=	0;
  int		numDeletes =	0;
  int           numConstructed = 0;
  int           count[4], limits[4];
  int           ii, jj, numdivs, kk, isum, numMsgDivs;
  int           rii =           0;
  int		verbose	=	0;
  int		noVary =        0;
  int		numPos =	0;
  int		numNeg = 	0;
  int		numZero =	0;
  int		NumPos =	0;
  int		NumNeg = 	0;
  int		NumZero =	0;
  int           declaredMsgCon= 0;
  int           declaredDelete= 0;
  int           STAsize, STBsize, STCsize, STDsize;
  char          proFile[132], option;
  FILE          *prof;
  char		*classArray;
  MsgProf       randomMsg;
  
  strcpy (proFile, "STproFile.d");
  while (EOF != (option = getopt (argc,argv,"f:N:M:a:b:c:d:A:B:C:D:k:z:vV")))
  {
    switch (option)
    {
    case '?':
      printf ("usage: -f <profile name>  -v verbose -V no vary in msgs\n");
      printf ("       -N <numObjsToMake[dflt:%d]>\n", MAXOBJS);
      printf ("       -M <numMsgs:[dflt:%d]>\n", MAXMSGS);
      printf ("       -[abcd] <num[abcd]> -[ABCD] <size[abcd]>\n");
      printf ("       -k <num const in msging[dflt: 25%% of numObjs]>\n");
      printf ("       -z <num deletes in msging[dflt: 25%% of numMsgs]>\n");
      exit ();
    case 'V':
      noVary = 1;
      break;
    case 'k':
      declaredMsgCon = 1;
      numConstsInMsg = atoi (optarg);
      break;
    case 'z':
      declaredDelete = 1;
      numDeletes = atoi (optarg);
      break;
    case 'v':
      verbose = 1;
      break;
    case 'f':
      strcpy (proFile, optarg);
      break;
    case 'N':
      numObjsToMake = atoi (optarg);
      break;
    case 'M':
      numMsgs = atoi (optarg);
      break;
    case 'a':
      STuserLimits[STAIDX] = atoi (optarg);
      break;
    case 'b':
      STuserLimits[STBIDX] = atoi (optarg);
      break;
    case 'c':
      STuserLimits[STCIDX] = atoi (optarg);
      break;
    case 'd':
      STuserLimits[STDIDX] = atoi (optarg);
      break;
    case 'A':
      STAsize = STsizes[STAIDX] = atoi (optarg);
      break;
    case 'B':
      STBsize = STsizes[STBIDX] = atoi (optarg);
      break;
    case 'C':
      STCsize = STsizes[STCIDX] = atoi (optarg);
      break;
    case 'D':
      STDsize = STsizes[STDIDX] = atoi (optarg);
      break;
    default:
      break;
    }
  }

  if (NULL == (prof = fopen (proFile, "w")))
  {
    printf ("error opening %s\n", proFile);
    perror ("");
    exit ();
  }

  
  srand48 (time(0));
  
  fNumObjs = numObjsToMake;
  percentRem = 1.0;
  for (ii=0; ii<4; ii++)
  {
    if (STuserLimits[ii] != -1)
    {
      isum = 0;
      for (jj=0; jj<4; jj++)
      {
        if (STuserLimits[jj] != -1)
        {
          tfloat = isum += STuserLimits[jj];
          percentRem -= tfloat / fNumObjs;
        }
      }
      if (isum > numObjsToMake) numObjsToMake = isum;
      break;
    }
  }
  
  printf ("determine relative distribution of %d objects\n", numObjsToMake);
  
  if (STuserLimits[STAIDX] != -1)
  {
    tfloat = numSTA = STuserLimits[STAIDX];
    percentA = percents[STAIDX] = tfloat / fNumObjs;
  }
  else
  {
    percentA = percents[STAIDX] = 
    	(percentRem/2.0) +  ((percentRem / 2.0) * drand48());
    numSTA = percentA * numObjsToMake;
    percentRem -= percentA;
  }
  printf ("percentA = %f (%5d objs)\n", percentA, numSTA);

  if (STuserLimits[STBIDX] != -1)
  {
    tfloat = numSTB = STuserLimits[STBIDX];
    percentB = percents[STBIDX] = tfloat / fNumObjs;
  }
  else
  {
    percentB = percents[STBIDX] = percentRem * drand48();
    numSTB = percentB * numObjsToMake;
    percentRem -= percentB;
  }
  printf ("percentB = %f (%5d objs)\n", percentB, numSTB);

  if (STuserLimits[STCIDX] != -1)
  {
    tfloat = numSTC = STuserLimits[STCIDX];
    percentC = percents[STCIDX] = tfloat / fNumObjs;
  }
  else
  {
    percentC = percents[STCIDX] = percentRem * drand48();
    numSTC = percentC * numObjsToMake;
    percentRem -= percentC;
  }
  printf ("percentC = %f (%5d objs)\n", percentC, numSTC);

  if (STuserLimits[STDIDX] != -1)
  {
    tfloat = numSTD = STuserLimits[STDIDX];
    percentD = percents[STDIDX] = tfloat / fNumObjs;
  }
  else
  {
    percentD = percents[STDIDX] = percentRem;
    numSTD = percentD * numObjsToMake;
  }
  printf ("percentD = %f (%5d objs)\n", percentD, numSTD);

  numObjs = numSTA + numSTB + numSTC + numSTD;

  if (!numConstsInMsg && !declaredMsgCon) numConstsInMsg = numObjs/4;
  if (!numDeletes && !declaredDelete) numDeletes = numMsgs/4;

  if (numObjs < numConstsInMsg)
  {
    printf 
      ("**Number of objects to make < number to construct in msgs (%d < %d)\n",
        numObjsToMake, numConstsInMsg);
    printf ("do all constructs during msgs\n");
    numConstsInMsg  = numObjs;
  }
  if (numMsgs < (numConstsInMsg + numDeletes))
  {
    while (numConstsInMsg > numMsgs) numConstsInMsg /= 2;
    while (numDeletes > numMsgs) numDeletes /= 2;
  }
  
  tfloat = numConstsInMsg;
  fNumObjs = numDeletes;
  percentConst = tfloat/numMsgs;
  percentDelete= fNumObjs/numMsgs;
  if (numMsgs < (numConstsInMsg + numDeletes))
  {
    printf 
      ("**number of total msgs < (consts in msg + deletes) (%d < (%d + %d)\n",
        numMsgs, numConstsInMsg, numDeletes);
    numDeletes = percentDelete * numMsgs;
    numConstsInMsg =  numMsgs - numDeletes;
    printf ("Use %d consts & %d deletes\n", numDeletes, numConstsInMsg);
  }

  if ((numObjs - numConstsInMsg) < 0) numConstsInMsg = numObjs;
  numObjsToInit = numObjs - numConstsInMsg;

  fwrite (&numSTA, sizeof (int), 1, prof);
  fwrite (&numSTB, sizeof (int), 1, prof);
  fwrite (&numSTC, sizeof (int), 1, prof);
  fwrite (&numSTD, sizeof (int), 1, prof);
  fwrite (&numObjsToInit, sizeof (int), 1, prof);
  fwrite (&(STsizes[STAIDX]), sizeof (int), 1, prof);
  fwrite (&(STsizes[STBIDX]), sizeof (int), 1, prof);
  fwrite (&(STsizes[STCIDX]), sizeof (int), 1, prof);
  fwrite (&(STsizes[STDIDX]), sizeof (int), 1, prof);
  fwrite (&numMsgs, sizeof (int), 1, prof);

/* header is now written */
  
 
  printf ("determine construction profile\n");
  
  regions[0] = 0.0;
  regions[1] = percentA;
  regions[2] = percentA + percentB;
  regions[3] = percentA + percentB + percentC;
  limits[0] = numSTA;
  limits[1] = numSTB;
  limits[2] = numSTC;
  limits[3] = numSTD;
  count[0] = count[1] = count[2] = count[3] = 0;
  numdivs = 4;
  numConstructed = 0;
  printf ("%d objects go into %d regions to start. they look like this:\n", 
    numObjs, numdivs);
  for (jj=0; jj<numdivs; jj++)
  printf 
    (" region(L/U): %0.5f / %0.5f; class: %c\n limit=%5d; count=%5d; percent=%0.5f\n",
      regions[jj], regions[jj+1], STnames[jj], limits[jj],
      count[jj], percents[jj]);
  ii = 0;
  classArray = malloc (numObjs);
  while(ii<numObjs)
  {
    which = drand48 ();
    for (kk = 0; kk<numdivs; kk++)
    {
      if ((which > regions[kk]) && (which <= regions[kk+1]))
      {
        if (limits[kk] != NULL)
        {
          classArray[ii] = STnames[kk];
          fprintf (prof, "%c", classArray[ii++]);
          count[kk]++;
        }
        if (count[kk] >= limits[kk])
        {
          printf ("\nFinished ST%c\n", STnames[kk]);
          numdivs--;
          if (kk != numdivs)
          {
            for (; kk<numdivs; kk++)
            {
              limits[kk] =    limits[kk+1];
              percents[kk] =  percents[kk+1];
              STnames[kk] =   STnames[kk+1];
              count[kk] =     count[kk+1];
            }
          }
          for (kk=1; kk<numdivs; kk++)
          {
            curProb = 0.0;
            for (jj=0; jj<kk; jj++) curProb += percents[jj];
            regions[kk] = curProb;
          }
          regions[numdivs] = 1.0;
          printf ("iteration=%d; %d regions left. they look like this:\n", 
            ii, numdivs);
          for (jj=0; jj<numdivs; jj++) printf
(" region(L/U): %0.5f / %0.5f; class: %c\n limit=%5d; count=%5d; percent=%0.5f\n",
    regions[jj], regions[jj+1], STnames[jj], limits[jj],
    count[jj], percents[jj]);
      } /* if limit exceeded */
        break;
      } /* if this is region */
    } /* for (locating region) */
  } /* for to make all stuff */
  
  if (verbose)
  {
    printf ("construction sequence looks like:\n");
    for (ii=0; ii<numObjs; ii+=30)
    {
      for (jj=ii; jj<(ii+30) && jj<numObjs; jj++) printf (" %c", classArray[jj]);
      printf ("\n");
    }
  }

  if (numObjsToInit)
  {  
    printf ("determine sequential message profile\n");
    for (numConstructed=0; numConstructed<numObjsToInit; numConstructed++)
    {
      ii = STsizes[classArray[numConstructed]-STA];
      if (noVary)
      {
        ii = 0;
        numZero++;
        fwrite (&ii, sizeof (int), 1, prof);
      }
      else
      {
        which = drand48();
        if ((0.0 <= which) && (which < 0.3333))
        {
          ii = -(drand48() * ii);
          numNeg++;
          fwrite (&ii, sizeof (int), 1, prof);
        }
        else if ((0.3333 <= which) && (which < 0.6666))
        {
          ii = drand48() * ii;
          numPos++;
          fwrite (&ii, sizeof (int), 1, prof);
        }
        else
        {
          ii = 0;
          numZero++;
          fwrite (&ii, sizeof (int), 1, prof);
        }
      } /* noVAry? */
      if (verbose) printf ("msg: %5d; cls: ST%c; size: %6d; varyAmt: %6d\n", 
        numConstructed, classArray[numConstructed], 
        STsizes[classArray[numConstructed] - STA], ii);
    }
  
    if (verbose)
      printf ("-vary: %5d; +vary: %5d; 0vary: %5d\n", numNeg, numPos, numZero);
    NumNeg += numNeg;
    NumPos += numPos;
    NumZero += numZero;
    numNeg = numZero = numPos;
  }

  printf ("determine random message profile\n");
  numMsgDivs = 0;
  if (numConstsInMsg)
  {
    msgPercents[0] = percentConst;
    msgLimits[0] = numConstsInMsg;
    msgType[0] = CONSTRUCT;
    msgNames[0] = 'C';
    numMsgDivs++;
  } /* any consts in msgs? */
  
  if (numDeletes)
  {
    msgPercents[numMsgDivs] = percentDelete;
    msgLimits[numMsgDivs] = numDeletes;
    msgType[numMsgDivs] = DELETE;
    msgNames[numMsgDivs] = 'D';
    numMsgDivs++;
  }
  if (numMsgs > (numDeletes + numConstsInMsg))
  {
    tfloat = 1.0;
    for (ii=0; ii<numMsgDivs; ii++) tfloat -= msgPercents[ii];
    msgPercents[numMsgDivs] = tfloat;
    msgType[numMsgDivs] = DOIT;
    msgLimits[numMsgDivs] = numMsgs - (numDeletes + numConstsInMsg);
    msgNames[numMsgDivs] = 'V';
    numMsgDivs++;
  }
  for (kk=1; kk<numMsgDivs; kk++)
  {
    curProb = 0.0;
    for (jj=0; jj<kk; jj++) curProb += msgPercents[jj];
    msgRegions[kk] = curProb;
  }

  if (verbose)
  {
    printf ("initial conditions: %d regions. they look like this:\n",
      numMsgDivs);
    for (jj=0; jj<numMsgDivs; jj++) printf
(" region(L/U): %0.5f / %0.5f; msgType: %c\n limit=%5d; count=%5d; percent=%0.5f\n",
            msgRegions[jj], msgRegions[jj+1], msgNames[jj], msgLimits[jj],
            msgCount[jj], msgPercents[jj]);
  }
  
  ii = 0;
  
  while(rii<numMsgs)
  {
    which = drand48 ();
    for (kk = 0; kk<numMsgDivs; kk++)
    {
      if ((which > msgRegions[kk]) && (which <= msgRegions[kk+1]))
      {
        switch (msgType[kk])
        {
        case DOIT:
          randomMsg.cmd = DOIT;
          randomMsg.u1.m.objIdx = jj = lrand48() % numObjs;
          ii = STsizes[classArray[jj]-STA];
          if (noVary)
          {
            randomMsg.u1.m.varyAmt = 0;
            numZero++;
            fwrite (&randomMsg, sizeof (MsgProf), 1, prof);
          }
          else
          {
            which = drand48();
            if ((0.0 <= which) && (which < 0.3333))
            {
              randomMsg.u1.m.varyAmt = -(drand48() * ii);
              numNeg++;
              fwrite (&randomMsg, sizeof (MsgProf), 1, prof);
            }
            else if ((0.3333 <= which) && (which < 0.6666))
            {
              randomMsg.u1.m.varyAmt = (drand48() * ii);
              numPos++;
              fwrite (&randomMsg, sizeof (MsgProf), 1, prof);
            }
            else
            {
              randomMsg.u1.m.varyAmt = 0;
              numZero++;
              fwrite (&randomMsg, sizeof (MsgProf), 1, prof);
            }
          }
          if (verbose) printf 
          ("msg: %5d (DOIT); objIdx: %6d; cls: ST%c; size: %6d; varyAmt: %6d\n",
              rii, jj, classArray[jj], ii, randomMsg.u1.m.varyAmt);
          break;
          
        case DELETE:
          randomMsg.cmd = DELETE;
          randomMsg.u1.m.objIdx = jj = lrand48() % numObjs;
          fwrite (&randomMsg, sizeof (MsgProf), 1, prof);
          if (verbose) printf
            ("msg: %5d (DELE); objIdx: %6d; cls: ST%c\n", rii, jj, 
            classArray[jj]);
          break;
          
        case CONSTRUCT:
          randomMsg.cmd = CONSTRUCT;
          randomMsg.u1.cls =  classArray[numConstructed++];
          fwrite (&randomMsg, sizeof (MsgProf), 1, prof);
          if (verbose) printf
            ("msg: %5d (CONS); cls: ST%c; numConstructed: %5d\n", rii,  
            classArray[numConstructed-1], numConstructed-1);
          break;

        } /* swicth */
        msgCount[kk]++;
        if (msgCount[kk] >= msgLimits[kk])
        {
          printf ("finished \"%c\" portion of messages\n", msgNames[kk]);
          numMsgDivs--;
          if (kk != numMsgDivs)
          {
            for (; kk<numMsgDivs; kk++)
            {
              msgLimits[kk] =    msgLimits[kk+1];
              msgPercents[kk] =  msgPercents[kk+1];
              msgCount[kk] =     msgCount[kk+1];
              msgNames[kk] =     msgNames[kk+1];
              msgType[kk] =      msgType[kk+1];
            }
          }
          for (kk=1; kk<numMsgDivs; kk++)
          {
            curProb = 0.0;
            for (jj=0; jj<kk; jj++) curProb += msgPercents[jj];
            msgRegions[kk] = curProb;
          }
          msgRegions[numMsgDivs] = 1.0;
          printf ("iteration=%d; %d regions left. they look like this:\n", 
            rii, numMsgDivs);
          for (jj=0; jj<numMsgDivs; jj++) printf
(" region(L/U): %0.5f / %0.5f; msgType: %c\n limit=%5d; count=%5d; percent=%0.5f\n",
            msgRegions[jj], msgRegions[jj+1], msgNames[jj], msgLimits[jj],
            msgCount[jj], msgPercents[jj]);
        } /* if limit exceeded */
        break;
      } /* if this is region */
    } /* for (locating region) */
    rii++;
  } /* for to make all stuff */

  if (verbose)
    printf ("-vary: %5d; +vary: %5d; 0vary: %5d\n", numNeg, numPos, numZero);
  NumNeg += numNeg;
  NumPos += numPos;
  NumZero += numZero;
  numNeg = numZero = numPos;

  if (verbose) 
    printf ("Total -vary: %5d; Total +vary: %5d; Total 0vary: %5d\n",
      NumNeg, NumPos, NumZero);

  free (classArray);
  fclose (prof);
  exit ();  
}

