/*
  DESCRIPTION

  Test driver function to test the pwIsSfOpen function
*/

class implementation EMSsurface;

#include <alloca.h>
#include <math.h>
#include "PWminimum.h"
#include "PWerror.h"
#include "PWattrib.h"
#include "PWgmdata.h"
#include "PWgmint.h"

#include "PWapi/sfprops.h"
#include "PWapi/printerr.h"
#include "PWapi/clock.h"
#include "PWapi/rdminim.h"

PWboolean test_pwIsSfOpen (infile, outfile, clock)
FILE *infile, *outfile;
int clock;
{
  PWboolean status=TRUE;
  PWboolean is_open;
  char str[10], class[PW_K_MaxStringLen];
  struct PWid id;

  /*
   * Read in the input. The input is going to be ordered exactly
   * as in the prototype. Each argument specified on a different line.
   */

  OnErrorState (!pwReadId (infile, &id.objid, &id.osnum, class), 
   status, FALSE, wrapup);

  /*
   * Now that the input has been gathered, invoke the function
   */

  pwStartClock (clock);
  is_open = pwIsSfOpen (id.objid, id.osnum);
  pwStopClock (clock);

  /*
   * Dump the output
   */

  if (is_open)
    strcpy (str, "OPEN");
  else
    strcpy (str, "CLOSED");
  fprintf (outfile, "Surface [%d, %d] is %s\n", id.objid, id.osnum, str);

wrapup:
  return (status);  
}

PWboolean test_pwIsSfOpen_old (infile, outfile, clock)
FILE *infile, *outfile;
int clock;
{
  PWboolean status=TRUE;
  char str[10], class[PW_K_MaxStringLen];
  int num_comp_edges=0, comp_buf_size=0;
  long msg_loc;
  PWresult result;
  struct GRid *comp_edges=NULL;
  struct PWid id;

  /*
   * Read in the input. The input is going to be ordered exactly
   * as in the prototype. Each argument specified on a different line.
   */

  OnErrorState (!pwReadId (infile, &id.objid, &id.osnum, class),
   status, FALSE, wrapup);

  /*
   * Now that the input has been gathered, invoke the function
   */

  pwStartClock (clock);
  result = om$send (msg = message EMSsurface.EMgetedges (&msg_loc,
            EMS_OPT_CONNECTABLE, &comp_edges, &comp_buf_size,
            &num_comp_edges, NULL, NULL, NULL, NULL), targetid = id.objid,
            targetos = id.osnum, senderid = NULL_OBJID);
  pwStopClock (clock);

  /*
   * Dump the output
   */

  fprintf (outfile, "Result Code _: ");
  pwPrintCode (outfile, result);
  if (comp_edges)
    strcpy (str, "OPEN");
  else
    strcpy (str, "CLOSED");
  fprintf (outfile, "Surface [%d, %d] is %s\n", id.objid, id.osnum, str);

wrapup:
  if (comp_edges)
    om$dealloc (ptr = comp_edges);
  return (status);  
}

end implementation EMSsurface;
