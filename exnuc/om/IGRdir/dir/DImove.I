class implementation DIrectory;

#include "OMminimum.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

DImove_names ( old_name, old_objid, new_name, new_objid )
               DIchar     *old_name;
               DIobjid     old_objid;
               DIchar     *new_name;
               DIobjid     new_objid;
{
  DIint   i, count = 0, sts = DIR_S_SUCCESS;
  DIchar  objname[DI_PATH_MAX];

  if ( old_name )
    sts = di$translate ( regexp = old_name, p_objid = &old_objid );

  if ( sts == DIR_S_SUCCESS )
  {
    if ( new_name )
      sts = di$translate ( regexp = new_name, p_objid = &new_objid );
  }

  if ( sts == DIR_S_SUCCESS )
    sts = di$untranslate ( objid = old_objid, ptr = &count );

  if ( sts == DIR_S_SUCCESS )
  {
    for ( i=0; i<count; i++ )
    {
      sts = di$untranslate ( objname = objname, objid = old_objid );

      sts = di$rm_name ( regexp = objname );

      sts = di$add_name ( objname = objname, objid = new_objid );
    }
  }

  return ( sts );
}

end implementation DIrectory;
