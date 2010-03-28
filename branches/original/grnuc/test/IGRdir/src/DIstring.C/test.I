class implementation Root;

#include "OMerrordef.h"
#include "OMprimitives.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

from GRgraphics import debug;

#define DEBUG


main25 ()
{
  /* dummy test routine for this on */
  system ( "cp output/masterout output/newout" );
  
  return 1;
}

test ()
/*.test */
{
  DIint   status;
  DIobjid objid;

  /*|create an object */
  status = om$construct ( classname = "GRgraphics",
                          p_objid   = &objid );
  if (status != OM_S_SUCCESS)
    om$report_error ( sts = status );

  /*|add it to a directory called IGE in the current space    */
  /*|the full path name is : :master:IGE:GRgraphics, assuming that */
  /*|the current object space has been loaded as :master      */
  status = di$add_name ( objname = ":transient:IGE:GRgraphics",
                         objid   = objid );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "test: add_name" );

  /*|send this object the message debug */
  status = di$send ( msg        = message GRgraphics.debug (),
                     senderid   = NULL_OBJID,
                     targetname = ":transient:IGE:GRgraphics" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "test: send" );

  return 1;
}  

end implementation Root;
