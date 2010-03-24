class implementation Root;

#include <stdio.h>
#include "OMprimitives.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"
#include "OMminimum.h"

suntrans ( objid, osnum, path )
  DIobjid    objid;
  DIspacenum osnum;
  DIchar     *path;
{
  DIint      i, sts, count=0;
  DIchar     objname [PATH_MAX];
  DIobjid    objid2;
  DIspacenum osnum2;

  sts = di$start_untrans( objid =  objid, ptr   = &count,
			  path  = path,   osnum =  osnum );
  if (sts != DIR_S_SUCCESS)
    di$report_error ( comment = "suntrans : start", sts = sts );

  for (i = 0; i < count; i++)
  {
    sts = di$fetch_untrans ( objname = objname, index = i );
    if (sts != DIR_S_SUCCESS)
      di$report_error ( comment = "suntrans : fetch_untranslate", sts = sts );

    sts = di$translate(objname = objname, p_objid = &objid2, p_osnum = &osnum2);
    if (sts != DIR_S_SUCCESS)
      di$report_error ( comment = "suntrans : translate1", sts = sts );

    if ( ( objid != objid2 ) || ( osnum != osnum2 ) )
      printf ( "suntrans : incompatibility for fetch_untranslate\n" );
  }

  sts = di$untranslate ( objname =  objname,
			 ptr     = &count,
			 objid   =  objid,
			 path    =  path );
  if (sts != DIR_S_SUCCESS) di$report_error ( comment = "untrans", sts = sts );
  for ( i=0; i<count; i++ )
  {
    sts = di$untranslate ( objname = objname, ptr  = &count, objid =  objid,
			   osnum   =  osnum,  index =  i,    path  =  path   );
    if (sts!=DIR_S_SUCCESS) di$report_error (comment="untrans",sts=sts);

    sts = di$translate(objname = objname, p_objid = &objid2, p_osnum = &osnum2);
    if ( sts! = DIR_S_SUCCESS )
      di$report_error ( comment = "suntrans : translate2", sts = sts );

    if ( ( objid != objid2 ) || ( osnum != osnum2 ) )
      printf ( "suntrans : incompatibility for fetch_untranslate\n" );
  }


  return DIR_S_SUCCESS;
}

end implementation Root;
