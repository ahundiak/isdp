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



tst_rmdir ( dirname, bad )
            DIchar *dirname;
	    DIint bad                                           /* IN  */;
/*
   This routine is supposed to test the remove directory ( rmdir ) feature.
   The input is a directory name ( full path name or base name ) and a code
   for the input stream ( good = 0 ).
*/
/*.tst_rmdir */
{
  DIint      status;
  DIobjid    dirid;
  DIspacenum osnum;

  if (bad == 0)      /*   Good input from rmdir.in   */

  {

  status = di$mkdir ( dirname = dirname, p_dirid = &dirid, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_rmdir : di$mkdir is wrong", sts = status );

  status = di$cd (dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_rmdir : di$cd_1 is wrong", sts = status );

  status = di$cd (dirname = ":transient" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_rmdir : di$cd_2 is wrong", sts = status );

  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_rmdir : di$rmdir is wrong", sts = status );

  status = di$cd (dirname = dirname );
  if (status == DIR_S_SUCCESS)
    di$report_error ( comment = "tst_rmdir : di$cd_3 is wrong", sts = status );

  status = di$mkdir ( dirname = "dummy_dir", p_dirid = &dirid, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_rmdir : di$mkdir is wrong", sts = status );

  status = di$add_name ( objname = "dummy_dir:dummy_name", objid = NULL, osnum = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_rmdir : di$add_name is wrong", sts = status );
  
  status = di$mkdir ( dirname = "dummy_dir:dummy_dir1", p_dirid = &dirid, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_rmdir : di$mkdir is wrong (2)", sts = status );

  status = di$mkdir ( dirname = "dummy_dir:dummy_dir2", p_dirid = &dirid, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_rmdir : di$mkdir is wrong (3)", sts = status );

  status = di$rmdir ( dirname = "dummy_dir:*" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_rmdir : di$rmdir is wrong (2)", sts = status );

  status = di$rm_name ( regexp = "dummy_dir:dummy_name" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_rmdir : di$rm is wrong", sts = status );

  status = di$rmdir ( dirname = "dummy_dir" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_rmdir : di$rmdir is wrong (3)", sts = status );
  }

  else          /*  Bad input from rmdir_bad.in   */

  {

  status = di$rmdir ( dirname = dirname );
  if (status == DIR_S_SUCCESS)
    di$report_error (comment = "tst_rmdir : di$rmdir_1 is wrong",sts = status );

  status = di$mkdir ( dirname = dirname, p_dirid = &dirid, p_osnum = &osnum  );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_rmdir_bad : di$mkdir is wrong", sts=status);

  status = di$cd ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_rmdir : di$cd is wrong", sts = status );

  status = di$rmdir ( dirname = dirname );
  if (status == DIR_S_SUCCESS)
    di$report_error (comment = "tst_rmdir : di$rmdir_2 is wrong",sts = status );

  status = di$cd ( dirname = "-" );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_rmdir : di$cd - is wrong", sts = status );

  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_rmdir : di$rmdir_3 is wrong",sts = status );

  }

  return DIR_S_SUCCESS;
}

end implementation Root;
