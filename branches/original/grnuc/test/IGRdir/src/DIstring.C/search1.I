class implementation Root;

#include <stdio.h>
#include <time.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

main18 ()
{
  /* dummy test routine for this on */
  system ( "cp output/masterout output/newout" );
  
  return 1;
}


/*
   This routine tests the directory OM style macros that use the search
   path parameter.  The macros tested in this routine are 

     di$translate()
     di$rename()

   Specific features of search path to be tested:

    o linear search path with full path prefix ( e.g. [ :master:foo:test:@ ] )
    o linear search path with relative path prefix ( e.g. [ .:@ ] )
    o search path with multiple path specifiers ( e.g. 
         [ :master:foo:test  :transient:test:@ :master:usr:tmp ] )

   The input is a path specification and the name of the target element.
   For now we use the same code for bad or good input

*/

tst_search1 ( bad, path, name, newname )
	      DIint   bad;
              DIchar *path,
                     *name,
                     *newname;
{
/*.tst_search1 */
   DIint      status;
   DIobjid    dirid;
   DIspacenum osnum, osnum2;
   DIchar     save_pwd[DI_PATH_MAX];

   if ( ! bad )
   {
     status = di$pwd ( p_osnum = &osnum,
		       dirname = save_pwd );

     /*"pwd = '%s'\n", save_pwd */
     /*"path specification is '%s'\n", path */
     /*"name specification is '%s'\n", name */
   
     status = di$translate ( path    = path,
                             objname = name,
                             p_objid = &dirid,
                             p_osnum = &osnum2);

     if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "1st tst_search1: di$translate FAILED",
                          sts     = status );

     /*"old name specification is '%s'\n", name */
     /*"new name specification is '%s'\n", newname */

     status = di$rename( path    = path,
                         oldname = name,
                         newname = newname );

     if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "tst_search1 : di$rename FAILED",
                          sts     = status );

     status = di$split ( pathname = newname, name = name );
     if (status != DIR_S_SUCCESS)
       di$report_error ( sts = status, 
                         comment = "tst_add: di$split" );

     /*"path specification is '%s'\n", path */
     /*"name specification is '%s'\n", name */

     status = di$translate ( path    = path,
                             objname = name,
                             p_objid = &dirid,
                             p_osnum = &osnum2);

     if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "2nd tst_search1 : di$translate FAILED",
                          sts     = status );
   }
   else
   {
     status = di$pwd ( p_osnum = &osnum,
		       dirname = save_pwd );

     /*"pwd = '%s'\n", save_pwd */
     /*"path specification is '%s'\n", path */
     /*"name specification is '%s'\n", name */
   
     status = di$translate ( path    = path,
                             objname = name,
                             p_objid = &dirid,
                             p_osnum = &osnum2);

     if (status == DIR_S_SUCCESS)
        di$report_error ( comment = "tst_search1: di$translate SUCCEEDED",
                          sts     = status );

     /*"old name specification is '%s'\n", name */
     /*"new name specification is '%s'\n", newname */

     status = di$rename( path    = path,
                         oldname = name,
                         newname = newname );

     if (status == DIR_S_SUCCESS)
        di$report_error ( comment = "1st tst_search1 : di$rename SUCCEEDED",
                          sts     = status );

     status = di$split ( pathname = newname, name = name );
     if (status != DIR_S_SUCCESS)
       di$report_error ( sts = status, 
                         comment = "tst_search1: di$split FAILED" );

     /*"path specification is '%s'\n", path */
     /*"name specification is '%s'\n", name */

     status = di$translate ( path    = path,
                             objname = name,
                             p_objid = &dirid,
                             p_osnum = &osnum2);

     if (status == DIR_S_SUCCESS)
        di$report_error ( comment = "2nd tst_search1 : di$translate SUCCEEDED",
                          sts     = status );
   }

   return DIR_S_SUCCESS;
}

end implementation Root;
