class implementation DIrectory;

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "OMmacros.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIomac.h"

DIfast_trans ( name, p_objid, p_osnum )
               DIchar        *name       /* Object name                  IN  */;
               DIobjid       *p_objid    /* Pointer to the object objid  OUT */;
               DIspacenum    *p_osnum    /* Pointer to the object osnum  OUT */;
{
  DIint   status = DIR_S_SUCCESS;
  DIgrid  target;
  DIobjid objid;
  DIchar  base_name   [DI_PATH_MAX],
          target_name [DI_PATH_MAX],
          dirname     [DI_PATH_MAX],
          full_name   [DI_PATH_MAX];

  if (p_objid) *p_objid = NULL_OBJID;
  if ( strchr ( name, DIR_G_car_dir ) )
  {
    DIexpanse ( name, full_name );
    if ( strcmp ( full_name, "" ) )
    {
      di$split ( pathname = name, dirname = target_name, name = base_name );

      if ( ! strcmp ( target_name, "" ) )
	strcpy ( target_name, DIR_G_str_dir );

#define PATIENCE
#ifdef PATIENCE
      for ( status = OM_E_ABORT; status != DIR_S_SUCCESS; )
      {
#endif
        status = DIfind_dir ( dirname, &target.osnum, &target.objid, target_name, NULL );

#ifdef PATIENCE
        if (strcmp ( target_name, DIR_G_str_dir ) && (status != DIR_S_SUCCESS))
        /* recursive dump: kludge for ACmacros	*/
        {
          char dir [DI_PATH_MAX], base [DI_PATH_MAX];

          di$split ( pathname = target_name, dirname = dir, name = base );
          DIstrcpy ( target_name, dir );
          DIfrtcat ( base_name, base );
        }
        else
          break;
      }
#endif

      if (status == DIR_S_SUCCESS)
      {
        DIcheck_link ( target.osnum, target.objid );
        om_send_for (IGRdir.translate ( &status, base_name, 0, NULL, &objid),
                     NULL_OBJID, target.objid, target.osnum );
        if (status == DIR_S_SUCCESS)
        {
          status = DItranslate ( name, NULL, target, base_name,
                                 objid, NULL, p_objid, p_osnum );
        }
      }
    }
    else
    {
      if (p_objid) *p_objid = DIR_G_root_id;
      if (p_osnum) *p_osnum = DIR_G_root_os;
    }
  }
  else
  {
    om_send_for (IGRdir.translate ( &status, name, 0, NULL, &objid),
                 NULL_OBJID, DIR_G_cur_dir_id, DIR_G_cur_dir_os );
    if (status == DIR_S_SUCCESS)
    {
      if (p_objid) *p_objid = objid;
      if (p_osnum) *p_osnum = DIR_G_cur_dir_os;
    }
  }

  return status;
}

end implementation DIrectory;
