class implementation Root;


#include <stdio.h>
#include <time.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#define DEBUG

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"
main7 ()
{
  /* dummy test routine for this on */
  system ( "cp output/masterout output/newout" );
  
  return 1;
}




tst_find ( dirname, bad )
           DIchar *dirname;
	   DIint bad                                           /* IN  */;
/*
   This routine is supposed to test the find feature.
*/
{
  DIint      i, status, count;
  DIobjid    dirid;
  DIspacenum osnum;
  DIchar     **lines;
  DIgrid     *grids;
  DIchar tmp [DI_PATH_MAX];
  extern FILE *log_fet;

  if (bad == 0)      /*   Good input from ls.in   */

  {
    status = di$cd ( dirname = ":transient" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_find : di$cd is wrong", sts = status );

    for ( i=0; i<5; ++i )
    {
  
      sprintf ( tmp, "fool_find_%d_%s", i, dirname );
      status=di$mkdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_find : di$mkdir is wrong 1", sts = status );

      sprintf ( tmp, "fool_find_%d_%s:first", i, dirname );
      status=di$mkdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_find : di$mkdir is wrong 2", sts = status );

      sprintf ( tmp, "fool_find_%d_%s:second", i, dirname );
      status=di$mkdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_find : di$mkdir is wrong 3", sts = status );

      sprintf ( tmp, "fool2_find_%d_%s", i, dirname );
      status=di$mkdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_find : di$mkdir is wrong 4", sts = status );
    }

    status=di$mkdir(dirname = dirname, p_dirid = &dirid, p_osnum = &osnum  );
    if (status != DIR_S_SUCCESS)
      di$report_error(comment = "tst_find : di$mkdir is wrong 5", sts = status );

    status = di$find ( regexp = "*", lines = &lines, ptr = &count );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_find : ls is wrong 1", sts = status );
    di$free ( lines = lines, count = count );
    status = di$find ( regexp = "*", lines = &lines, ptr = &count,
                       options = OPT_LEVEL | OPT_TRAILER );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_find : ls is wrong 2", sts = status );
    di$free ( lines = lines, count = count );

    status = di$find ( start_dir = ":", 
                     lines = &lines, grids = &grids,
                       ptr = &count, options = 0 );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "find from Root", sts = status );
    else
    {
      di$free ( lines = lines, count = count );
      DIfree ( grids );
    }

    status = di$find ( start_dir = ":", 
                       lines = &lines, grids = &grids,
                       ptr = &count, options = OPT_LEVEL );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "find from Root 1", sts = status );
    else
    {
      di$free ( lines = lines, count = count );
      DIfree ( grids );
    }
    status = di$find ( start_dir = ":", 
                       lines = &lines, grids = &grids,
                       ptr = &count, options = OPT_TRAILER );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "find from Root 2", sts = status );
    else
    {
      di$free ( lines = lines, count = count );
      DIfree ( grids );
    }
    status = di$find ( start_dir = ":", 
                       lines = &lines, grids = &grids,
                       ptr = &count, options = OPT_LEVEL | OPT_TRAILER );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "find from Root 3", sts = status );
    else
    {
      di$free ( lines = lines, count = count );
      DIfree ( grids );
    }

    status = di$find ( start_dir = ":transient:option1:option1:option1", 
                       lines = &lines, grids = &grids,
                       ptr = &count, options = 0 );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "find from nowhere", sts = status );
    else
    {
      di$free ( lines = lines, count = count );
      DIfree ( grids );
    }
  }

  else          /*  Bad input from ls_bad.in   */

  {

  status = di$mkdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
   di$report_error ( comment = "tst_find : di$mkdir is wrong 1", sts = status );

  status = di$cd ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_find : di$cd is wrong", sts = status );

  status = di$ls ( lines = &lines, ptr = &count );
  if (status == DIR_S_SUCCESS)
    di$report_error ( comment = "bad tst_find : ls is wrong", sts = status );

  status = di$dump ( lines = &lines, grids = &grids, ptr = &count );
  if (status == DIR_S_SUCCESS)
    di$report_error ( comment = "tst_dump : di$dump is wrong", sts = status );

  status = di$find ( start_dir = dirname, 
                     lines = &lines, grids = &grids,
                     ptr = &count, options = 0 );
  if (status == DIR_S_SUCCESS)
    di$report_error ( comment = "find from dirname 1", sts = status );
  status = di$find ( start_dir = dirname, 
                     lines = &lines, grids = &grids,
                     ptr = &count, options = OPT_LEVEL );
  if (status == DIR_S_SUCCESS)
    di$report_error ( comment = "find from dirname 2", sts = status );
  status = di$find ( start_dir = dirname, 
                     lines = &lines, grids = &grids,
                     ptr = &count, options = OPT_TRAILER );
  if (status == DIR_S_SUCCESS)
    di$report_error ( comment = "find from dirname 3", sts = status );

  status = di$cd ( dirname = "-" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_find : di$cd ':' is wrong", sts = status );

  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_find : di$rmdir is wrong (last)", sts = status );

  }

  return DIR_S_SUCCESS;
}

end implementation Root;
