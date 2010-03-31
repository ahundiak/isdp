/*
  DESCRIPTION

  Test driver function to test the pwGetSfRuleCvs function.
*/

class implementation EMSsurface;

#include <stdio.h>
#include <alloca.h>
#include "madef.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "sfdpdata.h"
#include "PWapi/sfbnds.h"
#include "PWapi/mx.h"
#include "PWapi/cvdisp.h"
#include "PWapi/printerr.h"
#include "PWapi/clock.h"
#include "PWapi/rdminim.h"

PWboolean test_pwSfEdCvs (infile, outfile, clock)
FILE *infile, *outfile;
int clock;
{
  PWboolean status=TRUE;
  PWresult result=PW_K_Success;
  PWmatrix mx;
  char class[PW_K_MaxStringLen];
  int i, j, num_sfids, num_ed_cvs=0, total_num_ed_cvs=0;
  int is_dominant, is_not_degenerate, is_not_tangent;
  struct PWid *sfids;
  struct IGRbsp_curve **ed_cvs=NULL;

  /*
   * Read in the surface object-id whose edge-curves are to be extracted
   * and drawn. Also read in the three flags.
   */

  fscanf (infile, "%d %d %d", 
   &is_dominant, &is_not_degenerate, &is_not_tangent);
  fscanf (infile, "%d", &num_sfids);
  sfids = (struct PWid *) alloca (num_sfids * sizeof (struct PWid));
  for (i=0; i<num_sfids; i++)
    OnErrorState (!pwReadId (infile, &sfids[i].objid, &sfids[i].osnum, class),
     status, FALSE, wrapup);

  /*
   * Now that the input has been gathered, invoke the function
   */

  pwStartClock (clock);
  for (i=0; i<num_sfids; i++)
  {
    result = pwGetSfEdCvs (sfids[i].objid, sfids[i].osnum, MAIDMX, pwIdMx (mx),
              (PWboolean) is_dominant,
              (PWboolean) is_not_degenerate,
              (PWboolean) is_not_tangent,
              &num_ed_cvs, &ed_cvs);
    OnErrorCode (result, Output);

    for (j=0; j<num_ed_cvs; j++)
    {
      result = pwDisplayCv (ed_cvs[j], GRbd);
      OnErrorState (IsError (result), result, SetError (0,PW_K_Interrupt),
       Output);
    }

    if (ed_cvs)
    {
      for (j=0; j<num_ed_cvs; j++)
        if (ed_cvs[j])
          free (ed_cvs[j]);
      free (ed_cvs);
    }

    total_num_ed_cvs += num_ed_cvs;
  }
  pwStopClock (clock);

  /*
   * Display the curves. Dump the output into file. 
   */


  Output:
  fprintf (outfile, "Result Code _: ");
  pwPrintCode (outfile, result);
  fprintf (outfile, "Num sfs = %d\n", num_sfids);
  fprintf (outfile, "Num ed cvs = %d\n", total_num_ed_cvs);

wrapup:
  return (status);  
}

end implementation EMSsurface;
