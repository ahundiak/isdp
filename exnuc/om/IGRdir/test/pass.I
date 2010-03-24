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

from dummy import test_pass;


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
  DIchar     dirname2 [PATH_MAX];
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
                            classname = "dummy",
                            p_objid   = &bidon1 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );

  /*|add the name */
  status = di$add_name ( objname = objname, objid = bidon1, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_pass : di$add_name is wrong", sts = status);

  {
    DIint i;
    Count = 0;

    for ( i=0; i<10; ++i )
    {
      DIstrcpy (dirname2, dirname);
      DIstrcat (dirname2, objname);
      /*"call di$pass with '%s'\n", dirname2 */
      status = di$pass ( regexp = dirname2,
			 flag   = OM_e_wrt_message,
                         msg    = message dummy.test_pass ( &Count ) );
      if (status != DIR_S_SUCCESS)
      {
        DIchar **lines;
        DIgrid *grids;
        DIint  count, i;

        di$report_error ( comment = "tst_pass : di$pass..wrong", sts = status );
        printf ( "regular expression : '%s'\n", dirname2 );

        status = di$find ( start_dir = ":", 
                           lines = &lines, grids = &grids,
                           ptr = &count, options = 0 );
        if (status != DIR_S_SUCCESS)
          di$report_error ( comment = "find from Root", sts = status );
        else
        {
          printf ( "count : %d\n", count );
          for (i = 0; i < count; i++)
            printf ( "'%s' - (%d, %d)\n", lines [i],
               grids [i].osnum, grids [i].objid );

          di$free ( lines = lines, count = count );
          DIfree ( grids );
        }
      }
    }
  }

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
                            classname = "dummy",
                            p_objid   = &bidon1 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );

  status = di$add_name ( objname = objname, objid = bidon1, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_pass : di$add_name is wrong", sts = status);

  status = di$pass ( regexp = ":wa[aeiou]ti?g*:obj*",
                     flag   = OM_e_wrt_message,
                     msg    = message dummy.test_pass ( &Count ) );
  if (status == DIR_S_SUCCESS)
    di$report_error ( comment = "tst_pass : di$pass..wrong", sts = status );

  status = di$pass ( regexp = "obj*",
                     flag   = OM_e_wrt_message,
                     msg    = message dummy.test_pass ( &Count ) );
  if (status == DIR_S_SUCCESS)
    di$report_error ( comment = "tst_pass : di$pass..wrong", sts = status );

  status = di$pass ( regexp = ":transient:waiting:object*:test*",
                     flag   = OM_e_wrt_message,
                     msg    = message dummy.test_pass ( &Count ) );
  if (status == DIR_S_SUCCESS)
    di$report_error ( comment = "tst_pass : di$pass..wrong", sts = status );

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
