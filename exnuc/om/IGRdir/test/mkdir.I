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



tst_mkdir ( dirname, bad )
            DIchar *dirname                                     /* IN  */;
	    DIint bad                                           /* IN  */;
/*
   This routine is supposed to test the make directory (mkdir) feature.
   The input is a directory name (full path name or base name) and a code
   for good or bad input ( good = 0).
*/
/*.tst_mkdir */
{
  DIint      status;
  DIobjid    dirid, dirid2;
  DIspacenum osnum, osnum2;
  DIchar     dirname2 [PATH_MAX];

  if (bad == 0)      /*   Good input from mkdir.in   */

  {
  status = di$mkdir ( dirname = dirname, p_dirid = &dirid, p_osnum = &osnum  );
  if (status != DIR_S_SUCCESS)
  {
    di$report_error ( comment = "tst_mkdir : di$mkdir is wrong", sts = status );
    printf ( "dirname : '%s'\n", dirname );
  }

  if (om$is_objid_valid ( osnum = osnum, objid = dirid ) != OM_S_SUCCESS)
    fprintf ( stderr, "tst_mkdir : illegal objid from di$mkdir\n" );

  status = di$translate(regexp = dirname,p_objid = &dirid2,p_osnum = &osnum2);
  if (status != DIR_S_SUCCESS)
   di$report_error (comment = "tst_mkdir : di$translate is wrong",sts = status);
  if ((dirid != dirid2) || (osnum != osnum2))
   fprintf (stderr, "tst_mkdir : incompatibility between mkdir & translate\n" );

  status = di$cd ( dirname = dirname, p_dirid = &dirid2, p_osnum = &osnum2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_mkdir : di$cd is wrong", sts = status );
  if ((dirid != dirid2) || (osnum != osnum2))
    fprintf ( stderr, "tst_mkdir : incompatibility between mkdir & cd\n" );

  status = di$cd ( dirname = ":" );
  if (status != DIR_S_SUCCESS)
   di$report_error(comment = "tst_mkdir : di$cd (\":\") is wrong",sts = status);

  status = di$pwd ( dirname = dirname2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_mkdir : di$pwd is wrong", sts = status );
  else
    if (strcmp ( dirname2, ":" ))
      printf ( "tst_mkdir : Problem ... current directory : '%s'\n", dirname2 );

  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_mkdir : di$rmdir is wrong", sts = status );

  /* checking mkdir with classname and/or osnum given */
  status = di$cd ( dirname = ":transient" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_mkdir : di$cd error", sts = status );

  strcpy ( dirname, ":transient:dir1" );

  status = di$mkdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_mkdir : di$mkdir error", sts = status );

  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_mkdir : di$rmdir error", sts = status );

  status = di$mkdir ( dirname = dirname, osnum = 5 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_mkdir : di$mkdir error", sts = status );

  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_mkdir : di$rmdir error", sts = status );

  status = di$mkdir ( dirname = dirname, osnum = 5, classname = "myclass" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_mkdir : di$mkdir error", sts = status );

  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_mkdir : di$rmdir error", sts = status );

  status = di$mkdir ( dirname = dirname, classname = "myclass" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_mkdir : di$mkdir error", sts = status );

  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_mkdir : di$rmdir error", sts = status );

  }

  else          /*  Bad input from mkdir_bad.in   */

  {

  status = di$mkdir ( dirname = dirname, p_dirid = &dirid, p_osnum = &osnum  );
  if (status == DIR_S_SUCCESS)
   di$report_error (comment = "tst_mkdir_bad : di$mkdir_1 is wrong",sts=status);

  }

  return DIR_S_SUCCESS;
}

end implementation Root;
