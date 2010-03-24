#include	<stdio.h>
#include	<malloc.h>
#include	<math.h>
#include	"pk.h"


extern	char	*optarg;


#define	SPECCLUSTER		-1
#define	BIGCLUSTER		-2
#define CLUSTERGROWTH           500

#define SPECOBJGROWTH 100
int	specIdx = 0;
int     specCount = SPECOBJGROWTH;
int	*specObjs;

struct  ClusterStat
{
  int           size;
  int           numGridPts;
};
typedef struct  ClusterStat CLUSTERSTAT;
typedef struct  ClusterStat *pCLUSTERSTAT;


static	pPk2Rec		outArray =	NULL;
static	pGridPt		*Grid =		NULL;
static	uint		gridGrowth = 	10;
static	uint		verbose =	NULL;
static	uint		Verbose =	NULL;
static  uint    	lcdEqPcd =      NULL;
static	uint		numX =		NULL;
static	uint		numY =		NULL;
static  int     	curCluster =    NULL;
static  int    		curClustSize =	NULL;
static  int     	curClustGrCnt =	NULL;
static  uint    	phyClustSize =  61440;
static  uint    	clusterFactor = 10;
static	int		mergeLPobjs =	0;  
static  pCLUSTERSTAT 	clustStats =   	NULL;
static	int		clustStatsSize= CLUSTERGROWTH;

#define START 0
#define UP    1
#define LEFT  2
#define DOWN  3

static  int     direction =     START;
static  int     curClusLoX =    0;
static  int     curClusLoY =    0;
static  int     markClusX =     0;
static  int     curgrx =      	0;
static  int     curgry =      	0;
static  int     moveSpiral =   	0;
static  int     breakoutRt =   	0;

#define	CARTESIAN	1
#define	CANTORIAN	2

static	int	growthType =	CARTESIAN;

	HEAD	header;
        FILE    *iFile;
        FILE    *oFile;


#define ADJ_CLUSTSTATS_ARRY \
{ \
  if (curCluster >= clustStatsSize) \
  { \
    clustStatsSize += CLUSTERGROWTH; \
    clustStats = (pCLUSTERSTAT) \
      realloc ( clustStatsSize * sizeof (CLUSTERSTAT), clustStats); \
  } \
  clustStats[curCluster].size = clustStats[curCluster].numGridPts = 0; \
}


static  char    *direc[] = {"START", "UP", "LEFT", "DOWN"};

void  displayGrid ()
{
  int           ii, jj, current;

  printf 
("\nLoX/LoY: (%d, %d); grid (%d, %d); %s; xMark: %d; curCluster: %d (size: %d)\n",
    curClusLoX, curClusLoY, curgrx, curgry, direc[direction], markClusX,
    curCluster, curClustSize);
  for (jj=(numY-1); jj>=0; jj--)
  {
    for (ii=0; ii<numX; ii++)
    {
      if (!(Grid[jj])[ii].visited) printf ("o");
      else
      {
        if ((Grid[jj])[ii].clustNum == BIGCLUSTER) printf ("B");
        else if ((Grid[jj])[ii].clustNum == curCluster) printf ("+");
        else printf ("X");
      }
      if (numX <= 26) printf (" ");
    }
    printf ("\n");
  }
}

void  displayClusters ()
{
  int           ii, jj;
  double        tpcs, tf, tf2, meanDens = 0.0;
  double        stdDev = 0.0;
  double        variance = 0.0;
  
  printf ("\nCluster Map\n");
  for (jj=(numY-1); jj>=0; jj--)
  {
    for (ii=0; ii<numX; ii++)
    {
      if (!(Grid[jj])[ii].visited) printf ("__");
      else printf ("%2d", ((Grid[jj])[ii].clustNum));
      if (numX <= 26) printf (" ");
    }
    printf ("\n");
  }
  tpcs = phyClustSize;
  printf ("\nCluster Statistics: %d clusters\n", curCluster);
  for (ii=0; ii<curCluster; ii++)
  {
    tf = clustStats[ii].size;
    meanDens += tf2 = 100.0 * (tf / tpcs);
    if (verbose)
      printf ("cluster #%3d: numGridPts: %2d, size: %6d, density: %3.3f\n",
        ii, clustStats[ii].numGridPts, clustStats[ii].size, tf2);
  }
  meanDens /= curCluster;

  for (ii=0; ii<curCluster; ii++)
  {
    tf = clustStats[ii].size;
    variance += tf2 = pow (fabs ((100.0 * (tf / tpcs) - meanDens)), 2.0);
  }
  variance /= curCluster;
  stdDev = sqrt (variance);
  printf ("Mean density: %3.3f. Variance: %3.3f. StdDeviation: %3.3f\n",
  meanDens, variance, stdDev);
}

void  displayGridDensity()
{
  int           ii, jj, kk, percent;
  double        fPercent, ft1, fpcs;

  fpcs = phyClustSize/ clusterFactor;
  printf ("\nGrid Density Map \n");
  printf ("each pt represents percent of phyClust/clusterFactor\n");
  printf ("(\"$$\" => exceeds 100 percent of phyClustSize/clUstFactor (%d))\n",
    ii=fpcs);
  for (jj=(numY-1); jj>=0; jj--)
  {
    for (ii=0; ii<numX; ii++)
    {
      ft1 = (Grid[jj])[ii].totalSize;
      fPercent = (ft1 / fpcs) * 100.0;
      if (fPercent >= 100.0)
        printf ("$$");
      else
      {
        percent = fPercent;
        printf ("%2d", percent);
      }
      if (numX <= 26) printf (" ");
    }
    printf ("\n");
  }
}


int countFreeCols (col)
int             col;
{
  int           ii, jj = 0;
  
  for (ii=0; ii<numY; ii++) if (!(Grid[ii])[col].visited) jj++;
  return (jj);
}


void  buildGrid ()
{
  int           ii, jj, numPts, mean;
  double        fNumPts;
  
  numPts = numX * numY;
  if (numX == 0 || numY == 0)
  {
    mean = header.meanSize;
    fNumPts = numPts = 
      ((mean * header.numObjs) / phyClustSize ) * clusterFactor;
    if (numX == 0 && numY == 0) numX = numY = sqrt (fNumPts);
    else if (numX) numY = numPts / numX;
    else numX = numPts / numY;
  }
  if (numX == 0) numX = 1;
  if (numY == 0) numY = 1;
  
  Grid = (pGridPt *) malloc ((numY+1) * sizeof (pGridPt));
  for (jj=0; jj<(numY+1); jj++) 
  {
    Grid[jj] = (pGridPt) malloc ((numX+1) * sizeof (GridPt));
    for (ii=0; ii<(numX+1); ii++)
    {
      (Grid[jj])[ii].count = 0;
      (Grid[jj])[ii].totalSize = 0;
      (Grid[jj])[ii].visited = 0;
      (Grid[jj])[ii].objIdxs = (int *) malloc (gridGrowth * sizeof (int));
      (Grid[jj])[ii].idxSize = gridGrowth;
    }
  }
}


void  fillGrid ()
{
  int         ii, jj, kk, ll;
  double      *xIndices, *yIndices, xInc, yInc;
  Pk1Rec      rec;

  xIndices = (double*) malloc ((numX+1) * sizeof (double));
  yIndices = (double*) malloc ((numY+1) * sizeof (double));
  xInc = (header.maxX - header.minX) / numX;
  yInc = (header.maxY - header.minY) / numY;
  xIndices[0] = header.minX;
  yIndices[0] = header.minY;
  xIndices[numX] = header.maxX + xInc;
  yIndices[numY] = header.maxY + yInc;
  for (ii=1; ii<numX; ii++) xIndices[ii] = header.minX + ii * xInc;
  for (ii=1; ii<numY; ii++) yIndices[ii] = header.minY + ii * yInc;
  
  for (kk=0; kk<header.numObjs; kk++)
  {
    if (sizeof (Pk1Rec) != (ll = fread (&rec, 1, sizeof (Pk1Rec), iFile)))
    {
      printf ("error reading record %d, readonly %d bytes of %d\n", kk,
        ll, sizeof(Pk1Rec));
      perror ("");
      exit (0);
    }
    outArray[kk].x1 = rec.x1;
    outArray[kk].y1 = rec.y1;
    outArray[kk].x2 = rec.x2;
    outArray[kk].y2 = rec.y2;
    outArray[kk].size = rec.size;
    outArray[kk].clustNum = SPECCLUSTER;
    if (rec.flag)
    {
      if ((specIdx + 2) > specCount)
      {
        specObjs = 
          (int*) realloc (specObjs, specCount + SPECOBJGROWTH * sizeof (int));
        specCount += SPECOBJGROWTH;
      }
      specObjs[specIdx++] = kk;
      continue;
    }
    if (rec.size > phyClustSize)
    {
      outArray[kk].clustNum = BIGCLUSTER;
      printf ("rec #%d has BIG OBJECT (%d bytes)\n", kk, rec.size);
      continue;
    }
    
    for (ii=0; ii<numX; ii++)
    {
      if (! ((rec.xc >= xIndices[ii]) && 
             (rec.xc < xIndices[ii+1]))) continue;
      {
        for (jj=0; jj<numY; jj++)
        {
          if (! ((rec.yc >= yIndices[jj]) && 
                 (rec.yc < yIndices[jj+1]))) continue;
          {
            if (((Grid[jj])[ii].count + 3) > (Grid[jj])[ii].idxSize)
            {
              (Grid[jj])[ii].objIdxs = (int*)
               realloc ((Grid[jj])[ii].objIdxs,
                       ( ((Grid[jj])[ii].idxSize + gridGrowth) * sizeof(int)));
              (Grid[jj])[ii].idxSize += gridGrowth;
            }
            (Grid[jj])[ii].totalSize += rec.size;
            if (lcdEqPcd)
            {
              if ( (Grid[jj])[ii].totalSize  > phyClustSize)
              {
                printf 
                  ("\nREC #%d, grid (%d, %d) has GROWN TOO BIG (%d bytes)\n",
                  kk, ii, jj, (Grid[jj])[ii].totalSize);
                (Grid[jj])[ii].visited = 1;
                (Grid[jj])[ii].clustNum = BIGCLUSTER;
              }
            }
            (Grid[jj])[ii].objIdxs [(Grid[jj])[ii].count++] = kk;

          } /* in this Y area */
        } /* locate Y coord */
      } /* if in this X area */
    } /* locate X coord */
  } /* big for loop (reading) */
}



int getNextCartesian ()
{
  int       kk, ii;


  moveSpiral = 0;
  switch (direction)
  {
  case START:
    direction = UP;
    if (((curgrx+1) < numX) && !(Grid[curgry])[curgrx+1].visited)
    {
      if (((curgry+1) < numY) && (Grid[curgry+1])[curgrx].visited)
        breakoutRt = 1;
      curgrx++;
      markClusX = curgrx + 1;
      return (1);
    }
    if (((curgry+1) < numY) && !(Grid[curgry+1])[curgrx].visited)
    {
      curgry++;
      markClusX = curgrx + 1;
      return (1);
    }
    return (-1);
    break;
    
  case UP:
    if (curgrx)
    {
      if ( ( (curgry + 1) < numY) &&
           ( (Grid[curgry])[curgrx - 1].visited) &&
           (!(Grid[curgry + 1])[curgrx].visited) )
      {
        if (breakoutRt)
        {
          breakoutRt = 0;
          if (((curgrx+1) < numX) && !(Grid[curgry])[curgrx+1].visited)
          {
            curClusLoX = curgrx++;
            return (1);
          }
        }
        curgry++;
        return (1);
      }
      if (( (curgrx - 1) >= curClusLoX) &&
	   !(Grid[curgry])[curgrx - 1].visited)
      {
        curgrx--;
        direction = LEFT;
        return (1);
      }
      if ((curgrx + 1) < numX && countFreeCols (curgrx+1))
      {
        for (kk=curClusLoY; kk<numY; kk++)
          if ( !(Grid[kk])[curgrx + 1].visited)
          {
            curgrx++;
            markClusX = curgrx + 1;
            moveSpiral++;
            curgry = kk;
            return (1);
          }
      }
      
     /* all other (better) possibilities exhauster, let it just go up */
     
      if ( ( (curgry + 1) < numY) &&
           (!(Grid[curgry + 1])[curgrx].visited) )
      {
        if (breakoutRt)
        {
          breakoutRt = 0;
          if (((curgrx+1) < numX) && !(Grid[curgry])[curgrx+1].visited)
          {
            curClusLoX = curgrx++;
            return (1);
          }
        }
        curgry++;
        return (1);
      }
      return (0);
    }

    /* check left boundary condition - can we break right yet? */

    if (!(Grid[curgry])[curgrx+1].visited)
    {
      curgrx++;
      return (1);
    }
    
    /* if not, continue up */
    if ( ( (curgry + 1) < numY) &&
         (!(Grid[curgry + 1])[curgrx].visited) )
    {
      curgry++;
      return (1);
    }
    /* since we checked all the way, up, we know there is no free grid */
    return (0);
    
  case LEFT:
    if (curgry)
    {
      if ( ( (curgrx - 1) >= curClusLoX) &&
           ( (Grid[curgry - 1])[curgrx].visited) &&
           (!(Grid[curgry])[curgrx - 1].visited) )
      {
        curgrx--;
        return (1);
      }
      if (! (Grid[curgry - 1])[curgrx].visited)
      {
        curgry--;
        direction = DOWN;
        return (1);
      }
      if (markClusX < numX && countFreeCols (markClusX))
      {
        for (kk=curClusLoY; kk<numY; kk++)
          if ( !(Grid[kk])[markClusX].visited)
          {
            curgrx = markClusX++;
            moveSpiral++;
            curgry = kk;
            direction = UP;
            return (1);
          }
      }
      
     /* all other (better) possibilities exhauster, let it just go down */
      
      if ( ( (curgrx - 1) >= curClusLoX) &&
           (!(Grid[curgry])[curgrx - 1].visited) )
      {
        curgrx--;
        return (1);
      }
      return (0);
    }
    printf ("**MUNGUP**: direction is LEFT & in ZERO row (grid %d, %d)\n",
      curgrx, curgry);
    exit (0);

  case DOWN:
    if ((curgry) &&
        (! (Grid[curgry - 1])[curgrx].visited))
    {
      curgry--;
      return (1);
    };
    if (markClusX < numX && countFreeCols (markClusX))
    {
      for (kk=curClusLoY; kk<numY; kk++)
        if ( !(Grid[kk])[markClusX].visited)
        {
          curgrx = markClusX++;
          moveSpiral++;
          curgry = kk;
          direction = UP;
          return (1);
        }
    }
    return (0);
  }
}


int getNextCantorian ()
{
  return (getNextCartesian ());
}


int getNextGrid ()
{
  switch (growthType)
  {
  case CARTESIAN:
    return (getNextCartesian());
    break;
  case CANTORIAN:
    return (getNextCantorian());
    break;
  }
}


int fillCluster ()
{
  int     ii, sts;
  
  curClustGrCnt = 0;
  curClustSize = 0;
  while (1)
  {
    if ( ((Grid[curgry])[curgrx].totalSize + curClustSize) > phyClustSize)
    {
      if (curClustGrCnt)
      {
        if (curClustSize)
        {
          clustStats[curCluster].size = curClustSize;
          clustStats[curCluster].numGridPts = curClustGrCnt;
          curCluster++;
          ADJ_CLUSTSTATS_ARRY;
        }
        return (1);
      }
      printf ("cur grid tot size: %d\n", (Grid[curgry])[curgrx].totalSize);
      clustStats[curCluster].size = (Grid[curgry])[curgrx].totalSize;
      clustStats[curCluster].numGridPts = 1;
      (Grid[curgry])[curgrx].clustNum = curCluster;
      for (ii=0; ii<(Grid[curgry])[curgrx].count; ii++)
        outArray[(Grid[curgry])[curgrx].objIdxs[ii]].clustNum = curCluster;

      curCluster++;
      ADJ_CLUSTSTATS_ARRY;
      if (Verbose) displayGrid ();
      (Grid[curgry])[curgrx].visited = 1;
      return (1);
    }
    curClustGrCnt++;
    curClustSize += (Grid[curgry])[curgrx].totalSize;
    (Grid[curgry])[curgrx].clustNum = curCluster;
    for (ii=0; ii<(Grid[curgry])[curgrx].count; ii++)
      outArray[(Grid[curgry])[curgrx].objIdxs[ii]].clustNum = curCluster;
    (Grid[curgry])[curgrx].visited = 1;
    if (Verbose) displayGrid ();
    sts = getNextGrid ();
    if (!sts)
    {
      if (curClustSize)
      {
        clustStats[curCluster].size = curClustSize;
        clustStats[curCluster].numGridPts = curClustGrCnt;
        curCluster++;
        ADJ_CLUSTSTATS_ARRY;
      }
      return (1);
    }
    if (-1 == sts) return (0);
  }
}


int getNextClusterOrigin ()
{
  int         cnt, ii, jj;
  
 
  breakoutRt = 0;
  direction = START;
/*
  if (markClusX < numX)
  {
    if (moveSpiral) markClusX--;
    curgrx = curClusLoX = markClusX;
    curgry = curClusLoY;
    return (1);
  }
*/
  for (ii=0; ii<numX; ii++)
  {
    if (cnt = countFreeCols (ii))
    {
      for (jj=0; jj<numY; jj++)
      {
        if (! (Grid[jj])[ii].visited)
        {
          if ( ( ((ii+1) < numX) && !(Grid[jj])[ii+1].visited)  
                                 ||
               ( ((jj+1) < numY) && !(Grid[jj+1])[ii].visited) )
          {
            curgrx = curClusLoX = ii;
            curgry = curClusLoY = jj;
            return (1);
          }
        }
      }
    }
  }
  return (0);
}



void  lastPass ()
{
  int       ii, jj, kk;
  int       unVisited = 0;
  int       unVisitedSize = 0;
  
  curClustSize =	NULL;
  curClustGrCnt =	NULL;

  for (jj=0; jj<numY; jj++)
  {
    for (ii=0; ii<numX; ii++)
    {
      if (! (Grid[jj])[ii].visited)
      {
        unVisited++;
        unVisitedSize += (Grid[jj])[ii].totalSize;
        (Grid[jj])[ii].visited = 1;
        if (!mergeLPobjs)
        {
          if ((Grid[jj])[ii].totalSize)
          {
            (Grid[jj])[ii].clustNum = curCluster;
            for (kk=0; kk<(Grid[jj])[ii].count; kk++)
              outArray[(Grid[jj])[ii].objIdxs[kk]].clustNum = curCluster;
            if (verbose) 
            {
              printf ("add LAST PASS cluster #%d\n", curCluster);
              displayClusters();
            }
            clustStats[curCluster].size = (Grid[jj])[ii].totalSize;
            clustStats[curCluster].numGridPts = 1;
            curCluster++;
            ADJ_CLUSTSTATS_ARRY;
          }
        }
        else  /* merge all singleton grid pts */
        {
          if ((Grid[jj])[ii].totalSize)
          {
            if ((curClustSize + (Grid[jj])[ii].totalSize) > phyClustSize)
            {
              if (curClustGrCnt)
              {
                clustStats[curCluster].numGridPts = curClustGrCnt;
                curClustGrCnt = 0;
                clustStats[curCluster].size = curClustSize;
                (Grid[jj])[ii].clustNum = curCluster;
                for (kk=0; kk<(Grid[jj])[ii].count; kk++)
                  outArray[(Grid[jj])[ii].objIdxs[kk]].clustNum = curCluster;
                curCluster++;
                ADJ_CLUSTSTATS_ARRY;
              }
              else
              {
                (Grid[jj])[ii].clustNum = curCluster;
                for (kk=0; kk<(Grid[jj])[ii].count; kk++)
                  outArray[(Grid[jj])[ii].objIdxs[kk]].clustNum = curCluster;
                curCluster++;
                ADJ_CLUSTSTATS_ARRY;
                clustStats[curCluster].size = (Grid[jj])[ii].totalSize;
                clustStats[curCluster].numGridPts = 1;
              }
              curClustSize = 0;
            }
            else
            {
              curClustSize += (Grid[jj])[ii].totalSize;
              (Grid[jj])[ii].clustNum = curCluster;
              for (kk=0; kk<(Grid[jj])[ii].count; kk++)
                outArray[(Grid[jj])[ii].objIdxs[kk]].clustNum = curCluster;
              curClustGrCnt++;
            }
          } /* anything in this grid pt */
        } /* else: merge singeltons */
      } /* not visited */
    }
  }

  if (unVisited) printf ("\n%d unvisited grid pts had total of %d bytes\n",
    unVisited, unVisitedSize);
      
  for (ii=0; ii<header.numObjs; ii++);
  {
    if (outArray[ii].clustNum == BIGCLUSTER)
    {
      printf ("created BIGCLUSTER for object index %d\n", ii);
      outArray[ii].clustNum = curCluster++;
    }
  }

  if (specIdx)
  {
    kk = 0;
    for (ii=0; ii<specIdx; ii++)
    {
      if (verbose)
        printf ("specObjs[%d] is index %d\n", ii, specObjs[ii]);
      outArray[specObjs[ii]].clustNum = curCluster; 
      kk += outArray[specObjs[ii]].size;
    }
    printf ("\n%d objects (totalling %d bytes) in SPECIAL CLUSTER %d\n",
      specIdx, kk, curCluster);
    clustStats[curCluster].size += kk;
    clustStats[curCluster].numGridPts += specIdx;
    curCluster++;
  }
}


main (argc, argv)
int         argc;
char        *argv[];
{
  int       ii, jj;
  char      option, infile[132], outfile[132];
  

  
  strcpy (infile, "pk1.out");
  strcpy (outfile, "pk2.out");
  clustStats = (int *) calloc (1, CLUSTERGROWTH * (sizeof CLUSTERSTAT));
  specObjs = (int*) malloc (SPECOBJGROWTH * sizeof (int));
  
  while (EOF != (option = getopt (argc,argv,"f:o:p:F:x:y:vecVm")))
  {
    switch (option)
    {
    case 'm':
      mergeLPobjs = 1;
      break;
    case 'e':
      lcdEqPcd = 1;
      break;
    case 'f':
      strcpy (infile, optarg);
      break;
    case 'o':
      strcpy (outfile, optarg);
      break;
    case 'p':
      phyClustSize = atoi (optarg);
      break;
    case 'F':
      clusterFactor = atoi (optarg);
      break;
    case 'x':
      numX = atoi (optarg);
      break;
    case 'y':
      numY = atoi (optarg);
      break;
    case 'v':
      verbose = 1;
      break;
    case 'V':
      Verbose = 1;
      break;
    case 'c':
      growthType  = CANTORIAN;
      break;
    case '?':
    default:
      printf ("usage: -f <infile> -o <outfile> -x <numX> -y <numY>\n");
      printf ("       -p <clustSize> -F <clusterFactor>\n");
      printf ("       -v [verbose] -V [verbose grid growth]\n");
      printf ("       -c [CANTORIAN] -e [make LCD == PCD]\n");
      printf ("       -m [merge LastPass Singleton Grids]\n");
      exit (0);
    }
  }
  
  if (NULL == (iFile = fopen (infile, "r")))
  {
    printf ("error opening %s for input\n", infile);
    perror ("");
    exit (0);
  }
  if (NULL == (oFile = fopen (outfile, "w")))
  {
    printf ("error opening %s for output\n", outfile);
    perror ("");
    exit (0);
  }

  fread (&header, sizeof (HEAD), 1, iFile);
  buildGrid ();
  
  printf ("from input file:\n");
  printf (" numObjs: %6d; meanSize: %5.0f;\n", header.numObjs,
    header.meanSize);
  printf (" minX: %8.1f; minY: %8.1f\n", header.minX, header.minY);
  printf (" maxX: %8.1f; maxY: %8.1f\n", header.maxX, header.maxY);
  printf ("Grid is (%d(x) * %d(y)); gridGrowth: %d\n", numX, numY,
    gridGrowth);

  outArray = (pPk2Rec) malloc (header.numObjs * sizeof (Pk2Rec));
  fillGrid ();
  displayGridDensity ();
  if ((Grid[curgrx])[curgry].visited && ! getNextGrid())
    printf ("cannot find a starting grid\n");

  else 
  {
    while (fillCluster())
    {
      if (verbose)
      {
        printf (" cluster %d COMPLETE; looks like this:\n", curCluster-1);
        displayClusters ();
      }
      if (!getNextClusterOrigin ()) break;
      if (verbose) printf (" next cluster begins at (%d, %d)\n", curgrx, 
        curgry);
    }
  }
  printf ("\Before Last Pass, grid looks like:\n");
  displayClusters ();
  printf ("\nBegin Last Pass... NOW\n");
  lastPass ();
  printf ("\nFinal result looks like THIS:\n");
  displayClusters ();
  fprintf (oFile, "%d\n", curCluster);
  for (ii=0; ii<header.numObjs; ii++)
    fprintf (oFile, "%f %f %f %f %d %d\n",
      outArray[ii].x1, outArray[ii].y1, outArray[ii].x2, outArray[ii].y2, 
      outArray[ii].size, outArray[ii].clustNum+1);
  exit (0);
}

