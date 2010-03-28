class implementation DEso;
#include <stdio.h>
#include <memory.h>
#include <limits.h>
#include <sys/types.h>
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include <tools.h>
#include "DEso.h"
#include "DEglob.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "madef.h"

#include "DEsomacros.h"

#define MIN_X -1300.0
#define MIN_Y -1000.0

#define MAX_X 1300.0
#define MAX_Y 1000.0

from IGEgragad import DPfit;


main ()
/*
   Call all the test routines for symbology override.
*/
{
  /* test in the module */
  DEtst_place ( 200 );
  DEtst_linestr ( 200 );
  DEtst_arc ( 200 );
  
  /* display everything */
  DEcheck_display ();
  
  return 1;
}


DEcheck_display ()
/*
   Check the display (fit in each window).
*/
{
  return DEcheck_display2 ( "graphics" );
}


DEcheck_display2 ( fname )
char *fname	/* The file to put the output in			IN  */;
/*
   Check display using the file passed as argument.
*/
{
  FILE        *fet;
  char        command [DI_PATH_MAX],
              new_path [DI_PATH_MAX], master_path [DI_PATH_MAX];

  strcat ( strcpy ( new_path, "output/new." ), fname );
  strcat ( strcpy ( master_path, "output/mstr." ), fname );

  /* set the graphics ATP file */
  TSSetGraphicsATPFile ( new_path );

  /* remove the ATP file */
  unlink ( new_path );

  Fit();
  
  /* if there is a master copy then we compare */
  if (fet = fopen ( master_path, "r" ))
  {
    sprintf ( command, "cmp %s %s", new_path, master_path );
    system ( command );
    fclose ( fet );
  }
  else
    fprintf ( stderr, "WARNING: there is no master copy for display\n" );

  return 1;
}

Fit()
{
  int         i, count = 0, status;
  DIgrid      *grids;
  long        msg;
  OMuword     mod_os;
  char	      path [DI_PATH_MAX];

  /* get the windows */
  ex$get_cur_mod ( osnum = &mod_os );
  DIstmocpy ( path, "views", "regviews", "GRviews", "*", 0, mod_os );
  status = di$dump ( regexp = path,
                     grids =  &grids, 
                     ptr = &count );
  if (status != DIR_S_SUCCESS || !count)
  {
    di$report_error ( sts = status, comment = "CANNOT get the windows" );
    return 0;
  }
  
  for (i = 0; i < count; i++)
  {
    status = om$send( msg = message IGEgragad.DPfit ( &msg, 1 ),
                      senderid = NULL_OBJID,
                      targetid = grids [i].objid,
                      targetos = grids [i].osnum );
    if (!(status & 1))
    {
      printf("\nerror in COfit call to DPfit\n");
      om$report_error(sts = status);
      return 0;
    }
  }
  return 1;
}
 
end implementation DEso;
