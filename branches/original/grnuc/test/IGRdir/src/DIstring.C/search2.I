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


main19 ()
{
  /* dummy test routine for this on */
  system ( "cp output/masterout output/newout" );
  
  return 1;
}



tst_search2 ( bad, path, name )
              DIint   bad;
              DIchar *path,
                     *name;
/*
   This routine is tests di$rmdir() with the search path parameter set. 

   Specific features of search path that should be tested:

    o linear search path with full path prefix ( e.g. [ :master:foo:test:@ ] )
    o linear search path with relative path prefix ( e.g. [ .:@ ] )
    o search path with multiple path specifiers ( e.g. 
         [ :master:foo:test  :transient:test:@ :master:usr:tmp ] )

   The input is a path specification and the name of the target element.
   We use the same code for good and bad input checking.

*/

/*.tst_search2 */
{
   DIint      status;
   DIchar     pwd[DI_PATH_MAX];

   if ( ! bad )
   {
     status = di$pwd ( dirname = pwd );

     /*"pwd = '%s'\n", pwd */
     /*"path specification is '%s'\n", path */
     /*"name specification is '%s'\n", name */

     status = di$rmdir( path    = path,
                        dirname = name );

     if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "tst_search2 : di$rmdir FAILED",
                          sts     = status );
   }
   else
   {
     status = di$pwd ( dirname = pwd );

     /*"pwd = '%s'\n", pwd */
     /*"path specification is '%s'\n", path */
     /*"name specification is '%s'\n", name */

     status = di$rmdir( path    = path,
                        dirname = name );

     if (status == DIR_S_SUCCESS)
        di$report_error ( comment = "tst_search2 : di$rmdir SUCCEEDED",
                          sts     = status );
   }

   return DIR_S_SUCCESS;
}

end implementation Root;
