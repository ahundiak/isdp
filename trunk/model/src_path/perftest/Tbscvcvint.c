/*
  DESCRIPTION

  Test driver function to test BScvcv_int function
*/

#include "igrtypedef.h"
#include "igr.h"
#include "bserr.h"
#include "bsparameters.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"

#include "prototypes/bscvcv_int.h"
#include "PWapi/clock.h"

PWboolean test_BScvcv_int (infile, outfile, clock)
FILE *infile, *outfile;
int clock;
{
  int i, num_intpts;
  long msg_loc, num_ovrpts;
  double bastol, chttol, curr_bastol, curr_chttol;
  double *intpts=NULL, *ovrpts=NULL;
  double *intpts_par1=NULL, *intpts_par2=NULL;
  double *ovrpts_par1=NULL, *ovrpts_par2=NULL;
  struct IGRbsp_curve cv1, cv2;
  PWboolean status=TRUE;
  PWpoint *pts;

  cv1.poles = cv1.knots = cv1.weights = cv1.bdrys = NULL;
  cv2.poles = cv2.knots = cv2.weights = cv2.bdrys = NULL;

  fscanf (infile, "%lf", &bastol);
  fscanf (infile, "%lf", &chttol);
  BSEXTRACTPAR (&msg_loc, BSTOLBASIS, curr_bastol);
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, curr_chttol);

  OnErrorState (!pwReadBspCv (infile, &cv1), status, FALSE, wrapup);
  OnErrorState (!pwReadBspCv (infile, &cv2), status, FALSE, wrapup);

  /*
   * Now that the input has been gathered, invoke the function
   */

  pwStartClock (clock);
  BScvcv_int (&msg_loc, &cv1, &cv2, 
   &num_intpts, &intpts, &intpts_par1, &intpts_par2, 
   &num_ovrpts, &ovrpts, &ovrpts_par1, &ovrpts_par2);
  pwStopClock (clock);

  /*
   * Dump the output
   */

  fprintf (outfile, "BS Code _: ");
  fprintf (outfile, "%d\n", msg_loc);
  fprintf (outfile, "Number of intersection points _: %d\n", num_intpts);
  fprintf (outfile, "Number of overlap points _: %d\n", num_ovrpts);
  if (num_intpts)
  {
    fprintf (outfile, "INTERSECTION POINTS:\n");
    pts = (PWpoint *) intpts;
    for (i=0; i<num_intpts; i++)
    {
      fprintf (outfile, "%2d) Cv1 par = %7.12lf, Cv2 par = %7.12lf\n", i,
       intpts_par1[i], intpts_par2[i]);
      pwPrintPt (outfile, 5, pts[i]);
    }
  }
  if (num_ovrpts)
  {
    fprintf (outfile, "\nOVERLAP POINTS:\n");
    pts = (PWpoint *) ovrpts;
    for (i=0; i<num_ovrpts; i++)
    {
      fprintf (outfile, "%2d) Cv1 par = %7.12lf, Cv2 par = %7.12lf\n", i,
       ovrpts_par1[i], ovrpts_par2[i]);
      pwPrintPt (outfile, 5, pts[i]);
    }
  }

wrapup:
  BSchgdeppar (curr_bastol, &msg_loc);
  BSchangepar (&msg_loc, BSTOLCHRDHT, curr_chttol);

  if (cv1.poles)
    free (cv1.poles);
  if (cv1.knots)
    free (cv1.knots);
  if (cv1.weights)
    free (cv1.weights);
  if (cv1.bdrys)
    free (cv1.bdrys);

  if (cv2.poles)
    free (cv2.poles);
  if (cv2.knots)
    free (cv2.knots);
  if (cv2.weights)
    free (cv2.weights);
  if (cv2.bdrys)
    free (cv2.bdrys);

  if (intpts)
    free (intpts);
  if (intpts_par1)
    free (intpts_par1);
  if (intpts_par2)
    free (intpts_par2);

  if (ovrpts)
    free (ovrpts);
  if (ovrpts_par1)
    free (ovrpts_par1);
  if (ovrpts_par2)
    free (ovrpts_par2);

  return (status);  
}
