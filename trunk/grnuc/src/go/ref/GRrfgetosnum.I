/*
Name
  GRgetosnum

Synopsis
  GRgetosnum ( msg, p_osnum )

       long        *msg             return message
       OMuword     *p_osnum         the osnum of the reference file

Description
  This method returns the osnum of the reference file.  It will fail if
  the file is missing.  

Diagnostics
  The possible return codes values in the msg field are:

  MSSUCC - successful completion
  MSFAIL - error occured (probably missing file)
*/

class implementation GRreffile;

#include "grimport.h"
#include "godef.h"
#include "msdef.h"
#include "dpdef.h"
#include "referr.h"
#include "refdef.h"
#include "refpriv.h"
#include "exdef.h"
#include "exmacros.h"
#include "dpmacros.h"
#include "dpsavevw.h"
#include "OMmacros.h"
#include "grerr.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"


from GRcontext import GRgetosnum;


method GRgetosnum ( long *msg; GRspacenum *p_osnum )
{
  OM_S_CHANSELECT to_context;

  /* we ask the first context object (he knows) */
  om$make_chanselect ( p_chanselect = &to_context, channame = "GRreffile.to_context" );
  return om$send ( msg = message GRcontext.GRgetosnum ( msg, p_osnum ),
                   p_chanselect = &to_context,
                   from = 0,
                   to = 0 );
}


end implementation GRreffile;

