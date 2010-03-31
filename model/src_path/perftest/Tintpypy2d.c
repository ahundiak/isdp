/*
  DESCRIPTION

  Test driver function to test the pwIntPyPy2d function
*/

#include <alloca.h>
#include <math.h>
#include "PWminimum.h"
#include "PWerror.h"
#include "PWattrib.h"
#include "PWgmdata.h"
#include "PWgmint.h"

#include "PWapi/intpypy2d.h"
#include "PWapi/printerr.h"
#include "PWapi/clock.h"

PWboolean test_pwIntPyPy2d (infile, outfile, clock)
FILE *infile, *outfile;
int clock;
{
  int is_b_adjpt, is_i_adjpt, num_inters;
  int b_reverse, i_reverse, b_process_start, i_process_start;
  double lentol;
  PWboolean status=TRUE;
  PWrange2d b_range, i_range;
  PWresult result;
  struct PWadjseg b_adjseg, i_adjseg;
  struct PWpoly2d b_py, i_py;
  struct PWcvintpt_list *inters_pts=NULL;

  /*
   * Read in the input. The input is going to be ordered exactly
   * as in the prototype. Each argument specified on a different line.
   * The optional arguments (which if not required, go in as NULL - b_adjpt,
   * i_adjpt) are first indicated by reading in a Boolean flag. If the flag is
   * TRUE, then this argument follows, else this argument will be not be
   * present in the file. The scan should pick up the following argument.
   */

  OnErrorState (!pwReadPy2d (infile, &b_py), status, FALSE, wrapup);
  fscanf (infile, "%d", &is_b_adjpt);
  if (is_b_adjpt)
  {
    OnErrorState (!pwReadPt2d (infile, b_adjseg.adjpt), status,
     FALSE, wrapup);
    b_adjseg.p_cvdata = NULL;
    b_adjseg.reversed = FALSE;
  }
  fscanf (infile, "%lf %lf %lf %lf", 
   &b_range[0][0], &b_range[0][1], &b_range[1][0], &b_range[1][1]);
  fscanf (infile, "%d", &b_reverse);
  fscanf (infile, "%d", &b_process_start);

  OnErrorState (!pwReadPy2d (infile, &i_py), status, FALSE, wrapup);
  fscanf (infile, "%d", &is_i_adjpt);
  if (is_i_adjpt)
  {
    OnErrorState (!pwReadPt2d (infile, i_adjseg.adjpt), status,
     FALSE, wrapup);
    i_adjseg.p_cvdata = NULL;
    i_adjseg.reversed = FALSE;
  }
  fscanf (infile, "%lf %lf %lf %lf", 
   &i_range[0][0], &i_range[0][1], &i_range[1][0], &i_range[1][1]);
  fscanf (infile, "%d", &i_reverse);
  fscanf (infile, "%d", &i_process_start);

  fscanf (infile, "%lf", &lentol);

  /*
   * Now that the input has been gathered, invoke the function
   */

  pwStartClock (clock);
  result = pwIntPyPy2d (b_py.num_pts, b_py.p_pts, 
            is_b_adjpt ? &b_adjseg : NULL, b_range,
            (PWboolean) b_reverse, (PWboolean) b_process_start,
            i_py.num_pts, i_py.p_pts, 
            is_i_adjpt ? &i_adjseg : NULL, i_range,
            (PWboolean) i_reverse, (PWboolean) i_process_start,
            lentol, 
            &num_inters, &inters_pts);
  pwStopClock (clock);

  /*
   * Dump the output
   */

  fprintf (outfile, "Result Code _: ");
  pwPrintCode (outfile, result);
  fprintf (outfile, "Number of intersections _: %d\n", num_inters);
  fprintf (outfile, "Intersection List _:\n");
  pwPrintCvintptList (outfile, 0, inters_pts);

wrapup:
  pwFreeCvintptList (inters_pts);
  if (b_py.p_pts)
    free (b_py.p_pts);
  if (i_py.p_pts)
    free (i_py.p_pts);

  return (status);  
}
