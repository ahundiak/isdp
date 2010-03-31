/*
  DESCRIPTION

  Test driver function to test the functions in the file: sfquery/sfgmqtys.c
  The functions are:
    pwGetMinDistAdjPoles
*/

#include <stdio.h>
#include "madef.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/sfgmqtys.h"
#include "PWapi/mx.h"

#define GET_MIN_DIST_ADJ_POLES 0

PWboolean test_pwSfGmQtys (infile, outfile, clock)
FILE *infile, *outfile;
int clock;
{
  char class[PW_K_MaxStringLen];
  int os, func_inx, poleinx[2];
  double mindist;
  PWmatrix mx;
  PWboolean status=TRUE, in_u_dir;
  PWresult result=PW_K_Success;
  PWobjid sfobj;

  /*
   * Read in the surface object-id on whom this test is to be performed.
   */

  OnErrorState (!pwReadId (infile, &sfobj, &os, class),
   status, FALSE, wrapup);

  /*
   * Get the function specific input
   */

  fscanf (infile, "%d", &func_inx);
  switch (func_inx)
  {
    case GET_MIN_DIST_ADJ_POLES:
      result = pwGetMinDistAdjPoles (sfobj, os, MAIDMX, pwIdMx (mx), 
                &mindist, poleinx, &in_u_dir);
      break;

    default:
      status = FALSE;
      goto wrapup;
  }

  /*
   * Invoke the function
   */

  pwStartClock (clock);

  switch (func_inx)
  {
    case GET_MIN_DIST_ADJ_POLES:
      break;

    default:
      status = FALSE;
      goto wrapup;
  }

  pwStopClock (clock);


  /*
   * Dump the output
   */

  fprintf (outfile, "Result Code _: ");
  pwPrintCode (outfile, result);

  switch (func_inx)
  {
    case GET_MIN_DIST_ADJ_POLES:
      fprintf (outfile, "Min Dist _: %7.12lf\n", mindist);
      fprintf (outfile, "Pole Index _: %d %d\n", poleinx[U], poleinx[V]);
      fprintf (outfile, "In U Dir _: %d\n", in_u_dir ? 1 : 0);
      break;
  }

wrapup:
  return (status);  
}

