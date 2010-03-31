/*
  DESCRIPTION

  Test driver function to test the pwPrintObject and pwReadObject function
*/

#include <stdio.h>
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/grprtread.h"
#include "PWapi/rdminim.h"

PWboolean test_pwPrintRead (infile, outfile, clock)
FILE *infile, *outfile;
int clock;
{
  PWboolean status=TRUE;
  PWresult result=PW_K_Success;
  char filename[PW_K_MaxCharFilename+1], r[2]="r", w[2]="w", *action;
  char class[PW_K_MaxStringLen];
  int i, toread, full_format, num_objsread=0;
  PWobjid *objsread=NULL;
  struct PWid id;
  FILE *file;

  /*
   * Read in the object to be printed or read into. Followed by the read
   * of a flag (0/1) to print/read. Followed by the flag indicating a 
   * full format print/read. Followed by the file-name to print into
   * or read from.
   */

  OnErrorState (!pwReadId (infile, &id.objid, &id.osnum, class),
   status, FALSE, wrapup);
  fscanf (infile, "%d", &toread);
  fscanf (infile, "%d", &full_format);
  fscanf (infile, "%s", filename);

  /*
   * Now that the input has been gathered, invoke the function
   */

  if (toread)
    action = r;
  else
    action = w;
  file = fopen (filename, action);
  OnErrorState (!file, result, SetError (PW_K_Pathway, PW_K_InvalidArg),
   Output);

  pwStartClock (clock);
  if (toread)
    result = pwReadAllObjects (file, id.osnum, (PWboolean) full_format,
              &num_objsread, &objsread);
  else
    result = pwPrintObject (id.objid, id.osnum, file, (PWboolean) full_format);
  pwStopClock (clock);

  fclose (file);

  /*
   * Dump the output
   */

  Output:
  fprintf (outfile, "Result Code _: ");
  pwPrintCode (outfile, result);
  if (!toread)
  {
    fprintf (outfile, "Objects Read:\n");
    for (i=0; i<num_objsread; i++)
      fprintf (outfile, "%d) %d\n", i, objsread[i]);
  }

wrapup:
  if (objsread)
    free (objsread);
  return (status);  
}

