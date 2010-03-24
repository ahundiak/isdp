class implementation Root;

#include <stdio.h>
#include <time.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#define AS_DEBUG

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

#include "GRtypedef.h" 
#include "GRdef.h"
#include "GRprims.h"


from DIbobpt	import init, retrieve_info, remove_info, remove_dup_info,
                       store_info;

entry ()
/*.entry */
{
  DIint   status, i, count;
  DIchar  **lines;

  /*!return 1 */
  status = di$init ();
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "Initialization" );

  /*|make a new group */
  status = gr$add_group ( groupname = "coucou", 
                          type      = DIR_D_PRIVATE,
                          passwd    = "lap1" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "gr$add_group ( coucou )" );

  /*|make this new group the current one */
  status = gr$cg ( groupname = "coucou", passwd = "lap1" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "gr$cg ( coucou )" );

  /*|make some directories */
  status = di$mkdir ( dirname = ":usr20" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "mkdir ( usr20 )" );
  status = di$mkdir ( dirname = ":usr30" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "mkdir ( usr20 )" );
  status = di$mkdir ( dirname = ":usr40" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "mkdir ( usr20 )" );

  /*|back to the usr group */
  status = gr$cg ( groupname = "usr" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "gr$cg ( usr )" );

  /*|try to cd into :usr20 */
  status = di$cd ( dirname = ":usr20" );
  if (status == DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "bad cd ( usr20 )" );

  /*|try to add a name in usr20 */
  status = di$add_name ( objname = ":usr20:a", objid = 1 ); 
  if (status == DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "bad add_name ( usr20:a )" );

  /*|a find starting at root */
  status = di$find ( start_dir = ":",
                     lines     = &lines,
                     ptr       = &count );
  if (status == DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "find" );

  printf ( "A find starting at root (%d)\n", count );
  for (i = 0; i < count; i++)
    printf ( "%s\n", lines [i] );

  return 1;
}

end implementation Root;
