/*
  DESCRIPTION

  Test driver function to test the function that get the various top-owners
  in a given OS.
*/

#include "igrtypedef.h"
#include "igr.h"

#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/sfobjs.h"

PWboolean test_pwGetTopOwnersOfOS (infile, outfile, clock)
FILE *infile, *outfile;
int clock;
{
  PWboolean status=TRUE;
  int i, os, num;
  PWobjid *objs=NULL;
  PWresult result=PW_K_Success;

  fscanf (infile, "%d", &os);

  /*
   * Now that the input has been gathered, invoke the function(s) and
   * dump output. First try the API using space-map lookup and then using
   * the R-tree.
   */

  pwStartClock (clock);
  result = pwGetSolidsOfOS ((PWosnum) os, FALSE, &num, &objs);
  pwStopClock (clock);

  fprintf (outfile, "Get Solids (Space Map) Return Code _: ");
  pwPrintCode (outfile, result);
  fprintf (outfile, "Number of Solids _: %d\n", num);
  for (i=0; i<num; i++)
    fprintf (outfile, "%d) %d\n", i, objs[i]);
  pwPrintClock (outfile, clock);
  fprintf (outfile, "\n");

  if (objs)
    free (objs);

  pwStartClock (clock);
  result = pwGetSolidsOfOS ((PWosnum) os, TRUE, &num, &objs);
  pwStopClock (clock);

  fprintf (outfile, "Get Solids (R-tree) Return Code _: ");
  pwPrintCode (outfile, result);
  fprintf (outfile, "Number of Solids _: %d\n", num);
  for (i=0; i<num; i++)
    fprintf (outfile, "%d) %d\n", i, objs[i]);
  pwPrintClock (outfile, clock);
  pwInitClock (clock);
  fprintf (outfile, "\n");

  if (objs)
    free (objs);

  pwStartClock (clock);
  result = pwGetSingleSfsOfOS ((PWosnum) os, FALSE, &num, &objs);
  pwStopClock (clock);

  fprintf (outfile, "Get Surfaces (Space Map) Return Code _: ");
  pwPrintCode (outfile, result);
  fprintf (outfile, "Number of Surfaces _: %d\n", num);
  for (i=0; i<num; i++)
    fprintf (outfile, "%d) %d\n", i, objs[i]);
  pwPrintClock (outfile, clock);
  pwInitClock (clock);
  fprintf (outfile, "\n");

  if (objs)
    free (objs);

  pwStartClock (clock);
  result = pwGetSingleSfsOfOS ((PWosnum) os, TRUE, &num, &objs);
  pwStopClock (clock);

  fprintf (outfile, "Get Surfaces (R-tree) Return Code _: ");
  pwPrintCode (outfile, result);
  fprintf (outfile, "Number of Surfaces _: %d\n", num);
  for (i=0; i<num; i++)
    fprintf (outfile, "%d) %d\n", i, objs[i]);
  pwPrintClock (outfile, clock);
  pwInitClock (clock);
  fprintf (outfile, "\n");

  if (objs)
    free (objs);

  return (status);  
}
