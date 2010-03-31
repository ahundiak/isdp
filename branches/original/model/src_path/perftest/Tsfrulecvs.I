/*
  DESCRIPTION

  Test driver function to test the pwGetSfRuleCvs function.
*/

class implementation EMSsurface;

#include <stdio.h>
#include "madef.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "sfdpdata.h"
#include "PWapi/sfdp.h"
#include "PWapi/mx.h"
#include "PWapi/cvdisp.h"
#include "PWapi/printerr.h"
#include "PWapi/clock.h"
#include "PWapi/rdminim.h"

PWboolean test_pwSfRuleCvs (infile, outfile, clock)
FILE *infile, *outfile;
int clock;
{
  PWboolean status=TRUE;
  PWresult result=PW_K_Success;
  PWmatrix mx;
  char class[PW_K_MaxStringLen];
  int i, num_rule_cvs=0;
  struct PWid id;
  struct IGRbsp_curve **rule_cvs=NULL;

  /*
   * Read in the surface object-id whose rule-lines are to be extracted
   * and drawn.
   */

  OnErrorState (!pwReadId (infile, &id.objid, &id.osnum, class),
   status, FALSE, wrapup);

  /*
   * Now that the input has been gathered, invoke the function
   */

  pwStartClock (clock);
  result = pwGetSfRuleLineCvs (id.objid, id.osnum, MAIDMX, pwIdMx (mx),
            &num_rule_cvs, &rule_cvs);
  pwStopClock (clock);

  for (i=0; i<num_rule_cvs; i++)
  {
    result = pwDisplayCv (rule_cvs[i], GRbd);
    OnErrorState (IsError (result), result, SetError (0,PW_K_Interrupt),
     Output);
  }

  /*
   * Display the curves. Dump the output into file. 
   */

  Output:
  fprintf (outfile, "Result Code _: ");
  pwPrintCode (outfile, result);
  fprintf (outfile, "Num rule cvs = %d\n", num_rule_cvs);

wrapup:
  if (rule_cvs)
  {
    for (i=0; i<num_rule_cvs; i++)
      if (rule_cvs[i])
        free (rule_cvs[i]);
    free (rule_cvs);
  }
  return (status);  
}

end implementation EMSsurface;
