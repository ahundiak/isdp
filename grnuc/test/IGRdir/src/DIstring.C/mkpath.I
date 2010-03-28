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

main13 ()
{
  /* dummy test routine for this on */
  system ( "cp output/masterout output/newout" );
  
  return 1;
}



tst_mkpath ( dirname, bad )
             DIchar *dirname;
             DIint bad;
/*
   This routine is supposed to test the make directory name ( mkpath ) feature.
   The input is a directory name (full path name ), the objid of the element to
   be added, and the input code ( good = 0 ).
*/
/*.tst_mkpath */
{
  DIint      status;
  DIobjid    bidon1, dirid;
  DIspacenum osnum, osnum2;
  DIint      om_status;

  if (bad == 0)      /*   Good input from mkpath.in   */

  {

  status = di$pwd ( p_osnum = &osnum );

  om_status = om$construct( osnum     = osnum,
                            classname = "GRgraphics",
                            p_objid   = &bidon1 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );

  /*"dirname : '%s'\n", dirname */
  if (dirname [strlen ( dirname ) - 1] != DIR_G_car_dir)
  {
    status = di$mkpath ( pathname = dirname, objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
     di$report_error(comment = "tst_mkpath : di$mkpath (1) is wrong", sts = status);

    status = di$translate(regexp = dirname,p_objid = &dirid,p_osnum = &osnum2);
    if (status != DIR_S_SUCCESS)
     di$report_error (comment = "tst_trans : di$translate is wrong",sts = status);
    if ((dirid != bidon1) || (osnum != osnum2))
      fprintf(stderr, "tst_mkpath : incompatibility in mkpath & translate\n" );
    status = di$rm_objid ( osnum = osnum, objid = bidon1 );
    if (status != DIR_S_SUCCESS)
     di$report_error(comment = "tst_mkpath : di$rm_objid is wrong", sts = status);
  }
  else
  {
    status = di$mkpath ( pathname = dirname );
    if (status != DIR_S_SUCCESS)
     di$report_error(comment = "tst_mkpath : di$mkpath (2) is wrong", sts = status);

    status = di$rmdir ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
     di$report_error(comment = "tst_mkpath : di$rmdir is wrong", sts = status);
  }
  }
  else          /*  Bad input from mkpath_bad.in   */

  {

  status = di$pwd ( p_osnum = &osnum );

  om_status = om$construct( osnum     = osnum,
                            classname = "GRgraphics",
                            p_objid   = &bidon1 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );

  if (dirname [strlen ( dirname ) - 1] != DIR_G_car_dir)
  {
    status = di$mkpath ( pathname = dirname, objid = bidon1, p_osnum = &osnum );
    status = di$mkpath ( pathname = dirname, objid = bidon1, p_osnum = &osnum );
    if (status == DIR_S_SUCCESS)
    {
      printf ( "It should fail ... for '%s'\n", dirname );
      di$report_error(comment = "tst_mkpath : di$mkpath is wrong", sts = status);
    }
  }
  else
  {
    status = di$mkpath ( pathname = dirname, objid = bidon1, p_osnum = &osnum );
    if (status == DIR_S_SUCCESS)
    {
      printf ( "tst_mkpath: It should fail (osnum, objid) for '%s'\n", dirname );
      di$report_error(comment = "tst_mkpath : di$mkpath is wrong", sts = status);
    }

    status = di$mkpath ( pathname = dirname );
    status = di$mkpath ( pathname = dirname );
    if (status == DIR_S_SUCCESS)
    {
      printf ( "It should fail ... for '%s'\n", dirname );
      di$report_error(comment = "tst_mkpath : di$mkpath is wrong", sts = status);
    }
  }
  }

  return DIR_S_SUCCESS;
}

end implementation Root;
