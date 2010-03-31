/*
  DESCRIPTION

  Test driver function to test the pwGetPersistXYZTols
*/

#include <stdio.h>
#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/xyztol.h"


PWboolean test_pwGetTols (infile, outfile, clock)
FILE *infile, *outfile;
int clock;
{
  int ios;
  double chttol, bastol;
  PWosnum os;
  PWboolean status=TRUE;
  PWresult result=PW_K_Success;

  /*
   * Read in the osnum in which the tols are to be obtained.
   */

  fscanf (infile, "%d", &ios);
  os = ios;

  /*
   * Now that the input has been gathered, invoke the function
   */

  pwStartClock (clock);

  result = pwGetPersistXYZTols (os, &bastol, &chttol);
  pwSetActiveXYZChtTol (chttol*10);
  pwSetActiveXYZLenTol (bastol*10);

  pwStopClock (clock);


  /*
   * Dump the output
   */

  fprintf (outfile, "Result Code _: ");
  pwPrintCode (outfile, result);
  fprintf (outfile, "Cht Read: %7.12lf, Len Read: %7.12lf\n", chttol, bastol);
  fprintf (outfile, "Setting Tol * 10:\n");
  fprintf (outfile, "Cht Read back: %7.12lf, Len Read back: %7.12lf\n", 
   pwActiveXYZChtTol(), pwActiveXYZLenTol());

  return (status);  
}

