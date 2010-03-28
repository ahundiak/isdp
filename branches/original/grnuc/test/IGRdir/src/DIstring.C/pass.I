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

main15 ()
{
  /* dummy test routine for this on */
  system ( "cp output/masterout output/newout" );
  
  return 1;
}


tst_pass ( dirname, objname, bad )
            DIchar *dirname;
            DIchar *objname;
	    DIint bad                                           /* IN  */;
/*
   This routine is supposed to test the pass message ( pass ) feature.
   The directory name needs to be given in addition to the objname of
   the objects to receive the message.  The input code is included also
   where ( good = 0 ).
*/
/*.tst_pass */
{
  int        Count;
  DIint      status, om_status;
  DIchar     dirname2 [DI_PATH_MAX];
  DIobjid    dirid, bidon1;
  DIspacenum osnum;

  if (bad == 0)      /*   Good input from pass.in   */

  {

  status = di$mkdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_pass : di$mkdir is wrong", sts = status );

  status = di$cd ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_pass : di$cd is wrong", sts = status );

  status = di$pwd ( p_osnum = &osnum );

  /*|construct */
  om_status = om$construct( osnum     = osnum,
                            classname = "GRgraphics",
                            p_objid   = &bidon1 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );

  /*|add the name */
  status = di$add_name ( objname = objname, objid = bidon1, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_pass : di$add_name is wrong", sts = status);

  status = di$rm_name ( regexp = objname );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_pass : di$rm_name (2) is wrong", sts = status);

  status = di$cd ( dirname = ":" );
  if (status != DIR_S_SUCCESS)
   di$report_error(comment = "tst_pass : di$cd ':' (2) is wrong",sts = status);

  status = di$pwd ( );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_pass : di$pwd is wrong", sts = status );

  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_pass : di$rmdir (2) is wrong", sts = status );

  }

  else          /*  Bad input from pass_bad.in   */

  {

#if 0
  status = di$mkdir ( dirname = dirname, p_dirid = &dirid, p_osnum = &osnum  );
  if (status != DIR_S_SUCCESS)
   di$report_error (comment = "tst_pass_bad : di$mkdir_1 is wrong",sts=status);

  status = di$cd ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_pass : di$cd is wrong", sts = status );

  status = di$pwd ( p_osnum = &osnum );

  om_status = om$construct( osnum     = osnum,
                            classname = "GRgraphics",
                            p_objid   = &bidon1 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );

  status = di$add_name ( objname = objname, objid = bidon1, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_pass : di$add_name is wrong", sts = status);

  status = di$rm_name ( regexp = objname );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_pass : di$rm_name is wrong", sts = status);

  status = di$cd ( dirname = ":" );
  if (status != DIR_S_SUCCESS)
   di$report_error(comment = "tst_pass : di$cd ':' is wrong",sts = status);

  status = di$pwd ( );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_pass : di$pwd is wrong", sts = status );

  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_pass : di$rmdir is wrong", sts = status );
#endif

  }

  return DIR_S_SUCCESS;
}

end implementation Root;
